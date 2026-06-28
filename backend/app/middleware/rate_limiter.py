import time
import logging
from fastapi import Request, Response
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.responses import JSONResponse

from app.core.redis import get_redis
from app.core.config import settings

logger = logging.getLogger(__name__)

# Endpoints with custom per-minute limits
ENDPOINT_LIMITS: dict[str, int] = {
    "/api/v1/auth/login": 10,
    "/api/v1/auth/register": 5,
    "/api/v1/ai/analyze-frame": 120,  # High frequency for video frames
    "/api/v1/ai/coach": 20,
}


class RateLimiterMiddleware(BaseHTTPMiddleware):
    """
    Sliding-window rate limiter using Redis.
    Default: 60 requests/minute per IP.
    Certain endpoints have custom limits (see ENDPOINT_LIMITS).
    """

    async def dispatch(self, request: Request, call_next) -> Response:
        # Skip rate limiting for health checks and docs
        path = request.url.path
        if path in ("/health", "/docs", "/redoc", "/openapi.json"):
            return await call_next(request)

        client_ip = self._get_client_ip(request)
        limit = ENDPOINT_LIMITS.get(path, settings.RATE_LIMIT_PER_MINUTE)

        try:
            redis = await get_redis()
            key = f"rate_limit:{client_ip}:{path}"
            now = int(time.time())
            window_start = now - 60

            # Remove old entries and count current window
            pipe = redis.pipeline()
            pipe.zremrangebyscore(key, 0, window_start)
            pipe.zadd(key, {str(now): now})
            pipe.zcard(key)
            pipe.expire(key, 60)
            results = await pipe.execute()

            current_count = results[2]

            if current_count > limit:
                remaining = 0
                retry_after = 60
                logger.warning(
                    f"Rate limit exceeded for {client_ip} on {path} "
                    f"({current_count}/{limit})"
                )
                response = JSONResponse(
                    status_code=429,
                    content={
                        "detail": "Too many requests. Please try again later.",
                        "retry_after": retry_after,
                    },
                )
                response.headers["Retry-After"] = str(retry_after)
                response.headers["X-Rate-Limit-Limit"] = str(limit)
                response.headers["X-Rate-Limit-Remaining"] = "0"
                return response

            remaining = max(0, limit - current_count)

        except Exception as e:
            logger.error(f"Rate limiter error: {e}")
            # Fail open — don't block requests if Redis is down
            remaining = limit

        response = await call_next(request)
        response.headers["X-Rate-Limit-Limit"] = str(limit)
        response.headers["X-Rate-Limit-Remaining"] = str(remaining)
        return response

    @staticmethod
    def _get_client_ip(request: Request) -> str:
        """Extract real client IP, respecting proxy headers."""
        forwarded_for = request.headers.get("X-Forwarded-For")
        if forwarded_for:
            return forwarded_for.split(",")[0].strip()
        real_ip = request.headers.get("X-Real-IP")
        if real_ip:
            return real_ip
        if request.client:
            return request.client.host
        return "unknown"
