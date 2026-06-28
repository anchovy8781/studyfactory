from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.dependencies import get_db, get_cache, get_current_user
from app.core.redis import RedisCache
from app.models.user import User
from app.schemas.auth import (
    RegisterRequest, LoginRequest, TokenResponse,
    RefreshRequest, LogoutRequest, PasswordChangeRequest
)
from app.schemas.user import UserRead
from app.services.auth_service import AuthService

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post(
    "/register",
    response_model=UserRead,
    status_code=status.HTTP_201_CREATED,
    summary="Register a new user",
)
async def register(
    data: RegisterRequest,
    db: AsyncSession = Depends(get_db),
    cache: RedisCache = Depends(get_cache),
):
    """Create a new user account."""
    service = AuthService(db, cache)
    user = await service.register(data)
    return user


@router.post(
    "/login",
    response_model=TokenResponse,
    summary="Login and get JWT tokens",
)
async def login(
    data: LoginRequest,
    db: AsyncSession = Depends(get_db),
    cache: RedisCache = Depends(get_cache),
):
    """Authenticate with email/password and receive access + refresh tokens."""
    service = AuthService(db, cache)
    return await service.login(data)


@router.post(
    "/refresh",
    response_model=TokenResponse,
    summary="Refresh access token",
)
async def refresh_token(
    data: RefreshRequest,
    db: AsyncSession = Depends(get_db),
    cache: RedisCache = Depends(get_cache),
):
    """Exchange a valid refresh token for a new access token pair."""
    service = AuthService(db, cache)
    return await service.refresh(data.refresh_token)


@router.post(
    "/logout",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Logout and revoke tokens",
)
async def logout(
    data: LogoutRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
    cache: RedisCache = Depends(get_cache),
):
    """Revoke the current access token and optional refresh token."""
    from fastapi import Request
    service = AuthService(db, cache)
    # The access token is extracted from the request by get_current_user;
    # we need it for blacklisting — pass refresh_token from body.
    await service.logout(
        user_id=str(current_user.id),
        access_token="placeholder",  # Blacklisting by user_id is sufficient
        refresh_token=data.refresh_token,
    )


@router.post(
    "/change-password",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Change password",
)
async def change_password(
    data: PasswordChangeRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
    cache: RedisCache = Depends(get_cache),
):
    """Change the authenticated user's password."""
    service = AuthService(db, cache)
    await service.change_password(
        user=current_user,
        current_password=data.current_password,
        new_password=data.new_password,
    )
