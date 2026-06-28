from datetime import timedelta
from typing import Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from fastapi import HTTPException, status

from app.models.user import User
from app.core.security import (
    hash_password,
    verify_password,
    create_access_token,
    create_refresh_token,
    decode_refresh_token,
)
from app.core.redis import RedisCache, CacheKeys
from app.core.config import settings
from app.schemas.auth import RegisterRequest, LoginRequest, TokenResponse


class AuthService:
    def __init__(self, db: AsyncSession, cache: RedisCache):
        self.db = db
        self.cache = cache

    async def register(self, data: RegisterRequest) -> User:
        """Register a new user."""
        # Check email uniqueness
        existing_email = await self.db.execute(
            select(User).where(User.email == data.email)
        )
        if existing_email.scalar_one_or_none():
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Email already registered",
            )

        # Check username uniqueness
        existing_username = await self.db.execute(
            select(User).where(User.username == data.username)
        )
        if existing_username.scalar_one_or_none():
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Username already taken",
            )

        # Create user
        user = User(
            email=data.email,
            username=data.username,
            nickname=data.nickname,
            hashed_password=hash_password(data.password),
        )
        self.db.add(user)
        await self.db.flush()
        await self.db.refresh(user)
        return user

    async def login(self, data: LoginRequest) -> TokenResponse:
        """Authenticate user and return JWT tokens."""
        result = await self.db.execute(
            select(User).where(User.email == data.email)
        )
        user = result.scalar_one_or_none()

        if not user or not verify_password(data.password, user.hashed_password):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect email or password",
                headers={"WWW-Authenticate": "Bearer"},
            )

        if not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Account is deactivated",
            )

        return await self._issue_tokens(user)

    async def refresh(self, refresh_token: str) -> TokenResponse:
        """Issue new access token from valid refresh token."""
        payload = decode_refresh_token(refresh_token)
        user_id: str = payload.get("sub")

        # Check token is stored (not revoked)
        stored = await self.cache.get(CacheKeys.refresh_token(user_id))
        if stored != refresh_token:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Refresh token is invalid or expired",
            )

        result = await self.db.execute(
            select(User).where(User.id == user_id)
        )
        user = result.scalar_one_or_none()
        if not user or not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User not found or deactivated",
            )

        # Revoke old refresh token and issue new pair
        await self.cache.delete(CacheKeys.refresh_token(user_id))
        return await self._issue_tokens(user)

    async def logout(self, user_id: str, access_token: str, refresh_token: Optional[str] = None) -> None:
        """Revoke tokens on logout."""
        # Blacklist access token (store short hash as key)
        jti = access_token[-16:]
        await self.cache.set(
            CacheKeys.blacklisted_token(jti),
            "1",
            expire=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        )

        # Revoke refresh token
        if refresh_token:
            await self.cache.delete(CacheKeys.refresh_token(user_id))

    async def _issue_tokens(self, user: User) -> TokenResponse:
        """Generate and store access + refresh token pair."""
        user_id = str(user.id)

        access_token = create_access_token(
            subject=user_id,
            additional_claims={"role": user.role.value, "email": user.email},
        )
        refresh_token = create_refresh_token(subject=user_id)

        # Store refresh token in Redis
        await self.cache.set(
            CacheKeys.refresh_token(user_id),
            refresh_token,
            expire=settings.REFRESH_TOKEN_EXPIRE_DAYS * 24 * 3600,
        )

        return TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        )

    async def change_password(
        self,
        user: User,
        current_password: str,
        new_password: str,
    ) -> None:
        """Change user password after verifying current one."""
        if not verify_password(current_password, user.hashed_password):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Current password is incorrect",
            )
        user.hashed_password = hash_password(new_password)
        self.db.add(user)
        # Invalidate all refresh tokens
        await self.cache.delete(CacheKeys.refresh_token(str(user.id)))
