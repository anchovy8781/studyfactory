import uuid
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.core.dependencies import get_db, get_cache, get_current_user
from app.core.redis import RedisCache
from app.models.user import User
from app.schemas.user import UserRead, UserUpdate, UserPublic

router = APIRouter(prefix="/users", tags=["Users"])


@router.get(
    "/me",
    response_model=UserRead,
    summary="Get current user profile",
)
async def get_me(
    current_user: User = Depends(get_current_user),
):
    """Return the authenticated user's full profile."""
    return current_user


@router.put(
    "/me",
    response_model=UserRead,
    summary="Update current user profile",
)
async def update_me(
    data: UserUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
    cache: RedisCache = Depends(get_cache),
):
    """Update profile fields for the authenticated user."""
    update_data = data.model_dump(exclude_none=True)

    for field, value in update_data.items():
        setattr(current_user, field, value)

    db.add(current_user)
    await db.flush()
    await db.refresh(current_user)

    # Invalidate user cache
    await cache.delete(f"user:{current_user.id}")

    return current_user


@router.get(
    "/{user_id}",
    response_model=UserPublic,
    summary="Get public user profile",
)
async def get_user(
    user_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
    cache: RedisCache = Depends(get_cache),
):
    """Get a user's public profile by ID."""
    # Check cache
    cache_key = f"user:public:{user_id}"
    cached = await cache.get(cache_key)
    if cached:
        return cached

    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )

    public_data = UserPublic.model_validate(user)
    await cache.set(cache_key, public_data.model_dump(mode="json"), expire=300)
    return public_data


@router.delete(
    "/me",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Deactivate account",
)
async def deactivate_account(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
    cache: RedisCache = Depends(get_cache),
):
    """Soft-delete (deactivate) the authenticated user's account."""
    current_user.is_active = False
    db.add(current_user)

    # Invalidate tokens
    await cache.delete(f"user:{current_user.id}")
    await cache.delete(f"refresh_token:{current_user.id}")
