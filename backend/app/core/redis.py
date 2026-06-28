import json
from typing import Optional, Any
import redis.asyncio as aioredis
from app.core.config import settings

# Global Redis client instance
redis_client: Optional[aioredis.Redis] = None


async def get_redis() -> aioredis.Redis:
    """Get or create Redis client instance."""
    global redis_client
    if redis_client is None:
        redis_client = aioredis.from_url(
            settings.REDIS_URL,
            encoding="utf-8",
            decode_responses=True,
            max_connections=20,
        )
    return redis_client


async def close_redis() -> None:
    """Close Redis connection."""
    global redis_client
    if redis_client is not None:
        await redis_client.aclose()
        redis_client = None


class RedisCache:
    """High-level Redis cache interface with JSON serialization."""

    def __init__(self, client: aioredis.Redis):
        self.client = client

    async def get(self, key: str) -> Optional[Any]:
        """Get a cached value by key."""
        value = await self.client.get(key)
        if value is None:
            return None
        try:
            return json.loads(value)
        except (json.JSONDecodeError, TypeError):
            return value

    async def set(
        self,
        key: str,
        value: Any,
        expire: Optional[int] = None,
    ) -> bool:
        """
        Set a cache value.

        Args:
            key: Cache key
            value: Value to cache (will be JSON-serialized)
            expire: TTL in seconds

        Returns:
            True if successful
        """
        serialized = json.dumps(value, default=str)
        if expire:
            return await self.client.setex(key, expire, serialized)
        return await self.client.set(key, serialized)

    async def delete(self, key: str) -> int:
        """Delete a cache key. Returns number of keys deleted."""
        return await self.client.delete(key)

    async def delete_pattern(self, pattern: str) -> int:
        """Delete all keys matching a pattern."""
        keys = await self.client.keys(pattern)
        if keys:
            return await self.client.delete(*keys)
        return 0

    async def exists(self, key: str) -> bool:
        """Check if a key exists."""
        return bool(await self.client.exists(key))

    async def expire(self, key: str, seconds: int) -> bool:
        """Set TTL on an existing key."""
        return bool(await self.client.expire(key, seconds))

    async def ttl(self, key: str) -> int:
        """Get remaining TTL for a key (-1 if no TTL, -2 if not exists)."""
        return await self.client.ttl(key)

    async def increment(self, key: str, amount: int = 1) -> int:
        """Atomically increment a counter."""
        return await self.client.incrby(key, amount)

    async def sadd(self, key: str, *values: str) -> int:
        """Add members to a set."""
        return await self.client.sadd(key, *values)

    async def sismember(self, key: str, value: str) -> bool:
        """Check if value is in a set."""
        return bool(await self.client.sismember(key, value))

    async def smembers(self, key: str) -> set:
        """Get all members of a set."""
        return await self.client.smembers(key)


# Cache key builders
class CacheKeys:
    """Centralized cache key definitions."""

    @staticmethod
    def user(user_id: str) -> str:
        return f"user:{user_id}"

    @staticmethod
    def user_by_email(email: str) -> str:
        return f"user:email:{email}"

    @staticmethod
    def refresh_token(user_id: str) -> str:
        return f"refresh_token:{user_id}"

    @staticmethod
    def blacklisted_token(jti: str) -> str:
        return f"token:blacklist:{jti}"

    @staticmethod
    def study_session(session_id: str) -> str:
        return f"study_session:{session_id}"

    @staticmethod
    def active_study(user_id: str) -> str:
        return f"active_study:{user_id}"

    @staticmethod
    def ranking(period: str) -> str:
        return f"ranking:{period}"

    @staticmethod
    def user_stats(user_id: str, period: str) -> str:
        return f"stats:{user_id}:{period}"

    @staticmethod
    def rate_limit(ip: str, endpoint: str) -> str:
        return f"rate_limit:{ip}:{endpoint}"
