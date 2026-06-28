import uuid
from typing import Optional
from fastapi import APIRouter, Depends, Query, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, and_, update
from datetime import datetime, timedelta, timezone

from app.core.dependencies import get_db, get_cache, get_current_admin_user
from app.core.redis import RedisCache
from app.models.user import User, UserRole
from app.models.study_session import StudySession
from app.models.badge import Badge
from app.models.reward import Reward, PointTransaction, TransactionType
from app.schemas.user import UserRead
from app.schemas.reward import RewardRead, BadgeRead
from app.services.reward_service import RewardService

router = APIRouter(prefix="/admin", tags=["Admin"])


# ─────────────── Dashboard ───────────────

@router.get(
    "/dashboard",
    summary="Admin dashboard stats",
)
async def get_dashboard(
    admin: User = Depends(get_current_admin_user),
    db: AsyncSession = Depends(get_db),
):
    """High-level platform statistics for admin dashboard."""
    now = datetime.now(timezone.utc)
    last_7d = now - timedelta(days=7)
    last_30d = now - timedelta(days=30)

    total_users = (await db.execute(select(func.count(User.id)))).scalar_one()
    active_users_7d = (
        await db.execute(
            select(func.count(User.id)).where(User.last_study_date >= last_7d)
        )
    ).scalar_one()

    total_sessions = (await db.execute(
        select(func.count(StudySession.id)).where(StudySession.ended_at.isnot(None))
    )).scalar_one()

    total_study_hours = (await db.execute(
        select(func.coalesce(func.sum(StudySession.duration_seconds), 0))
        .where(StudySession.ended_at.isnot(None))
    )).scalar_one() / 3600

    sessions_30d = (await db.execute(
        select(func.count(StudySession.id))
        .where(and_(StudySession.started_at >= last_30d, StudySession.ended_at.isnot(None)))
    )).scalar_one()

    return {
        "total_users": total_users,
        "active_users_last_7d": active_users_7d,
        "total_sessions": total_sessions,
        "total_study_hours": round(float(total_study_hours), 1),
        "sessions_last_30d": sessions_30d,
        "generated_at": now.isoformat(),
    }


# ─────────────── Users ───────────────

@router.get(
    "/users",
    response_model=list[UserRead],
    summary="List all users",
)
async def list_users(
    page: int = Query(default=1, ge=1),
    size: int = Query(default=50, ge=1, le=200),
    search: Optional[str] = None,
    is_active: Optional[bool] = None,
    admin: User = Depends(get_current_admin_user),
    db: AsyncSession = Depends(get_db),
):
    query = select(User)
    if search:
        like = f"%{search}%"
        query = query.where(User.email.ilike(like) | User.username.ilike(like))
    if is_active is not None:
        query = query.where(User.is_active == is_active)

    result = await db.execute(
        query.order_by(User.created_at.desc())
        .offset((page - 1) * size)
        .limit(size)
    )
    return [UserRead.model_validate(u) for u in result.scalars().all()]


@router.patch(
    "/users/{user_id}/activate",
    response_model=UserRead,
    summary="Activate or deactivate a user",
)
async def set_user_active(
    user_id: uuid.UUID,
    is_active: bool,
    admin: User = Depends(get_current_admin_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    user.is_active = is_active
    db.add(user)
    await db.flush()
    await db.refresh(user)
    return UserRead.model_validate(user)


@router.patch(
    "/users/{user_id}/role",
    response_model=UserRead,
    summary="Change a user's role",
)
async def set_user_role(
    user_id: uuid.UUID,
    role: UserRole,
    admin: User = Depends(get_current_admin_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    user.role = role
    db.add(user)
    await db.flush()
    await db.refresh(user)
    return UserRead.model_validate(user)


@router.post(
    "/users/{user_id}/grant-points",
    summary="Manually grant points to a user",
)
async def grant_points(
    user_id: uuid.UUID,
    amount: int = Query(..., ge=1),
    reason: str = Query(..., max_length=200),
    admin: User = Depends(get_current_admin_user),
    db: AsyncSession = Depends(get_db),
    cache: RedisCache = Depends(get_cache),
):
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    service = RewardService(db, cache)
    transaction = await service.credit_points(
        user=user,
        amount=amount,
        transaction_type=TransactionType.ADMIN_GRANT,
        description=f"Admin grant: {reason}",
    )

    return {
        "user_id": str(user_id),
        "granted_amount": amount,
        "new_balance": user.available_points,
        "transaction_id": str(transaction.id),
    }


# ─────────────── Badges ───────────────

@router.post(
    "/badges",
    response_model=BadgeRead,
    status_code=status.HTTP_201_CREATED,
    summary="Create a new badge",
)
async def create_badge(
    name: str,
    description: str,
    category: str,
    rarity: str = "common",
    points_reward: int = 0,
    icon_url: Optional[str] = None,
    admin: User = Depends(get_current_admin_user),
    db: AsyncSession = Depends(get_db),
):
    badge = Badge(
        name=name,
        description=description,
        category=category,
        rarity=rarity,
        points_reward=points_reward,
        icon_url=icon_url,
    )
    db.add(badge)
    await db.flush()
    await db.refresh(badge)
    return BadgeRead.model_validate(badge)


# ─────────────── Rewards ───────────────

@router.post(
    "/rewards",
    response_model=RewardRead,
    status_code=status.HTTP_201_CREATED,
    summary="Create a new reward",
)
async def create_reward(
    name: str,
    description: str,
    category: str,
    points_cost: int = Query(..., ge=1),
    stock_quantity: Optional[int] = None,
    image_url: Optional[str] = None,
    admin: User = Depends(get_current_admin_user),
    db: AsyncSession = Depends(get_db),
):
    from app.models.reward import Reward as RewardModel
    reward = RewardModel(
        name=name,
        description=description,
        category=category,
        points_cost=points_cost,
        stock_quantity=stock_quantity,
        image_url=image_url,
    )
    db.add(reward)
    await db.flush()
    await db.refresh(reward)
    return RewardRead.model_validate(reward)
