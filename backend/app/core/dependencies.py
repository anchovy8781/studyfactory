from typing import Optional, AsyncGenerator
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
import uuid

from app.core.database import AsyncSessionLocal
from app.core.security import decode_access_token
from app.core.redis import get_redis, RedisCache, CacheKeys
from app.models.user import User, UserRole

# Bearer token security scheme
bearer_scheme = HTTPBearer(auto_error=False)


async def get_db() -> AsyncGenerator[AsyncSession, None]:
    """Dependency to get async database session."""
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()


async def get_cache() -> RedisCache:
    """Dependency to get Redis cache instance."""
    client = await get_redis()
    return RedisCache(client)


async def get_current_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(bearer_scheme),
    db: AsyncSession = Depends(get_db),
    cache: RedisCache = Depends(get_cache),
) -> User:
    """
    Dependency to get the currently authenticated user.

    Validates the JWT Bearer token, checks blacklist in Redis,
    and returns the User ORM object.
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )

    if credentials is None:
        raise credentials_exception

    token = credentials.credentials
    payload = decode_access_token(token)

    user_id: str = payload.get("sub")
    if user_id is None:
        raise credentials_exception

    # Check if token is blacklisted
    jti = payload.get("jti", token[-16:])
    if await cache.exists(CacheKeys.blacklisted_token(jti)):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token has been revoked",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # Try cache first
    cached_user = await cache.get(CacheKeys.user(user_id))
    if cached_user:
        # Reconstruct User from cached dict
        user = User(**{k: v for k, v in cached_user.items() if hasattr(User, k)})
        return user

    # Fetch from database
    try:
        uid = uuid.UUID(user_id)
    except ValueError:
        raise credentials_exception

    result = await db.execute(select(User).where(User.id == uid))
    user = result.scalar_one_or_none()

    if user is None:
        raise credentials_exception

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User account is deactivated",
        )

    return user


async def get_current_active_user(
    current_user: User = Depends(get_current_user),
) -> User:
    """Dependency that also checks user is active."""
    if not current_user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Inactive user",
        )
    return current_user


async def get_current_admin_user(
    current_user: User = Depends(get_current_user),
) -> User:
    """Dependency that requires admin role."""
    if current_user.role != UserRole.ADMIN:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin privileges required",
        )
    return current_user


async def get_optional_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(bearer_scheme),
    db: AsyncSession = Depends(get_db),
    cache: RedisCache = Depends(get_cache),
) -> Optional[User]:
    """
    Dependency that optionally authenticates a user.
    Returns None if no token provided, raises if token is invalid.
    """
    if credentials is None:
        return None
    return await get_current_user(credentials, db, cache)
