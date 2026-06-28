import uuid
import math
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, and_

from app.core.dependencies import get_db, get_cache, get_current_user
from app.core.redis import RedisCache
from app.models.user import User
from app.models.crew import Crew, CrewMember, CrewMemberRole
from app.schemas.community import (
    CrewCreate, CrewUpdate, CrewRead, CrewMemberRead
)

router = APIRouter(prefix="/crews", tags=["Crews"])


@router.post(
    "",
    response_model=CrewRead,
    status_code=status.HTTP_201_CREATED,
    summary="Create a new study crew",
)
async def create_crew(
    data: CrewCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    # Check name uniqueness
    existing = await db.execute(select(Crew).where(Crew.name == data.name))
    if existing.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Crew name already taken",
        )

    crew = Crew(
        leader_id=current_user.id,
        **data.model_dump(),
    )
    db.add(crew)
    await db.flush()

    # Add creator as leader member
    member = CrewMember(
        user_id=current_user.id,
        crew_id=crew.id,
        role=CrewMemberRole.LEADER,
        status="active",
    )
    db.add(member)
    crew.member_count = 1
    db.add(crew)

    await db.flush()
    await db.refresh(crew)
    return CrewRead.model_validate(crew)


@router.get(
    "",
    response_model=list[CrewRead],
    summary="List public crews",
)
async def list_crews(
    page: int = Query(default=1, ge=1),
    size: int = Query(default=20, ge=1, le=100),
    search: Optional[str] = Query(default=None, max_length=100),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    query = select(Crew).where(and_(Crew.is_public == True, Crew.is_active == True))
    if search:
        query = query.where(Crew.name.ilike(f"%{search}%"))

    result = await db.execute(
        query.order_by(Crew.member_count.desc())
        .offset((page - 1) * size)
        .limit(size)
    )
    return [CrewRead.model_validate(c) for c in result.scalars().all()]


@router.get(
    "/my",
    response_model=list[CrewRead],
    summary="Get crews the current user belongs to",
)
async def get_my_crews(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Crew)
        .join(CrewMember, CrewMember.crew_id == Crew.id)
        .where(
            and_(
                CrewMember.user_id == current_user.id,
                CrewMember.status == "active",
                Crew.is_active == True,
            )
        )
    )
    return [CrewRead.model_validate(c) for c in result.scalars().all()]


@router.get(
    "/{crew_id}",
    response_model=CrewRead,
    summary="Get crew details",
)
async def get_crew(
    crew_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return CrewRead.model_validate(await _get_crew_or_404(db, crew_id))


@router.put(
    "/{crew_id}",
    response_model=CrewRead,
    summary="Update crew details",
)
async def update_crew(
    crew_id: uuid.UUID,
    data: CrewUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    crew = await _get_crew_or_404(db, crew_id)
    _require_leader(crew, current_user.id)

    for field, value in data.model_dump(exclude_none=True).items():
        setattr(crew, field, value)

    db.add(crew)
    await db.flush()
    await db.refresh(crew)
    return CrewRead.model_validate(crew)


@router.delete(
    "/{crew_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Disband a crew",
)
async def delete_crew(
    crew_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    crew = await _get_crew_or_404(db, crew_id)
    _require_leader(crew, current_user.id)
    crew.is_active = False
    db.add(crew)


@router.post(
    "/{crew_id}/join",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Join a crew",
)
async def join_crew(
    crew_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    crew = await _get_crew_or_404(db, crew_id)

    if not crew.is_public:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="This crew requires an invitation",
        )

    # Check already a member
    existing = await db.execute(
        select(CrewMember).where(
            and_(
                CrewMember.user_id == current_user.id,
                CrewMember.crew_id == crew_id,
            )
        )
    )
    if existing.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Already a member of this crew",
        )

    if crew.member_count >= crew.max_members:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Crew is full",
        )

    member_status = "pending" if crew.requires_approval else "active"
    member = CrewMember(
        user_id=current_user.id,
        crew_id=crew_id,
        role=CrewMemberRole.MEMBER,
        status=member_status,
    )
    db.add(member)

    if member_status == "active":
        crew.member_count += 1
        db.add(crew)


@router.post(
    "/{crew_id}/leave",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Leave a crew",
)
async def leave_crew(
    crew_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    crew = await _get_crew_or_404(db, crew_id)

    if crew.leader_id == current_user.id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Leader cannot leave. Transfer leadership or disband the crew first.",
        )

    result = await db.execute(
        select(CrewMember).where(
            and_(
                CrewMember.user_id == current_user.id,
                CrewMember.crew_id == crew_id,
                CrewMember.status == "active",
            )
        )
    )
    member = result.scalar_one_or_none()
    if not member:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Not a member of this crew",
        )

    await db.delete(member)
    crew.member_count = max(0, crew.member_count - 1)
    db.add(crew)


@router.get(
    "/{crew_id}/members",
    response_model=list[CrewMemberRead],
    summary="Get crew members",
)
async def get_crew_members(
    crew_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    await _get_crew_or_404(db, crew_id)
    result = await db.execute(
        select(CrewMember)
        .where(and_(CrewMember.crew_id == crew_id, CrewMember.status == "active"))
        .order_by(CrewMember.joined_at.asc())
    )
    return [CrewMemberRead.model_validate(m) for m in result.scalars().all()]


# ─────────────── Helpers ───────────────

async def _get_crew_or_404(db: AsyncSession, crew_id: uuid.UUID) -> Crew:
    result = await db.execute(
        select(Crew).where(and_(Crew.id == crew_id, Crew.is_active == True))
    )
    crew = result.scalar_one_or_none()
    if not crew:
        raise HTTPException(status_code=404, detail="Crew not found")
    return crew


def _require_leader(crew: Crew, user_id: uuid.UUID) -> None:
    if crew.leader_id != user_id:
        raise HTTPException(status_code=403, detail="Only the crew leader can do this")
