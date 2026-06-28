from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.dependencies import get_db, get_cache, get_current_user
from app.core.redis import RedisCache
from app.models.user import User
from app.schemas.reward import (
    RewardRead, RewardExchangeRequest, RewardExchangeResponse,
    PointTransactionRead, PointTransactionListResponse,
    BadgeRead, UserBadgeRead
)
from app.services.reward_service import RewardService
from app.models.badge import Badge, UserBadge
from sqlalchemy import select

router = APIRouter(prefix="/rewards", tags=["Rewards"])


@router.get(
    "",
    response_model=list[RewardRead],
    summary="List available rewards",
)
async def list_rewards(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
    cache: RedisCache = Depends(get_cache),
):
    """Get all rewards available for point exchange."""
    service = RewardService(db, cache)
    rewards = await service.get_available_rewards()
    return [RewardRead.model_validate(r) for r in rewards]


@router.post(
    "/exchange",
    response_model=RewardExchangeResponse,
    summary="Exchange points for a reward",
)
async def exchange_reward(
    data: RewardExchangeRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
    cache: RedisCache = Depends(get_cache),
):
    """Spend points to obtain a reward."""
    service = RewardService(db, cache)
    user_reward = await service.exchange_reward(current_user, data.reward_id, data.quantity)

    await db.refresh(current_user)

    reward_result = await db.execute(
        select(__import__("app.models.reward", fromlist=["Reward"]).Reward)
        .where(__import__("app.models.reward", fromlist=["Reward"]).Reward.id == data.reward_id)
    )
    reward = reward_result.scalar_one()

    return RewardExchangeResponse(
        user_reward_id=user_reward.id,
        reward=RewardRead.model_validate(reward),
        points_spent=user_reward.points_spent,
        remaining_points=current_user.available_points,
        status=user_reward.status,
        message=f"Successfully exchanged {reward.name}! Fulfillment will be processed shortly.",
    )


@router.get(
    "/transactions",
    response_model=PointTransactionListResponse,
    summary="Get point transaction history",
)
async def get_transactions(
    page: int = Query(default=1, ge=1),
    size: int = Query(default=20, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
    cache: RedisCache = Depends(get_cache),
):
    """Paginated list of point transactions for the current user."""
    service = RewardService(db, cache)
    transactions, total = await service.get_transaction_history(
        current_user.id, page=page, size=size
    )
    return PointTransactionListResponse(
        transactions=[PointTransactionRead.model_validate(t) for t in transactions],
        total=total,
        page=page,
        size=size,
    )


@router.get(
    "/badges",
    response_model=list[BadgeRead],
    summary="List all available badges",
)
async def list_badges(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Get all badges that can be earned."""
    result = await db.execute(
        select(Badge).where(Badge.is_active == True).order_by(Badge.rarity.asc())
    )
    return [BadgeRead.model_validate(b) for b in result.scalars().all()]


@router.get(
    "/badges/my",
    response_model=list[UserBadgeRead],
    summary="Get badges earned by current user",
)
async def get_my_badges(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """List all badges the current user has earned."""
    result = await db.execute(
        select(UserBadge)
        .where(UserBadge.user_id == current_user.id)
        .order_by(UserBadge.earned_at.desc())
    )
    return [UserBadgeRead.model_validate(ub) for ub in result.scalars().all()]
