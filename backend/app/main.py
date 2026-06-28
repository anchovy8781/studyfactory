import logging
import time
from contextlib import asynccontextmanager

from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from sqlalchemy.exc import IntegrityError

from app.core.config import settings
from app.core.database import init_db, close_db
from app.core.redis import get_redis, close_redis
from app.middleware.cors import setup_cors
from app.middleware.rate_limiter import RateLimiterMiddleware
from app.api.routes import auth, users, study, ai, statistics, community, crew, rewards, ranking, admin

# Configure logging
logging.basicConfig(
    level=logging.DEBUG if settings.DEBUG else logging.INFO,
    format="%(asctime)s | %(levelname)-8s | %(name)s | %(message)s",
)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup and shutdown events."""
    # Startup
    logger.info(f"Starting {settings.APP_NAME} v{settings.VERSION}")

    # Initialize Redis connection
    try:
        redis = await get_redis()
        await redis.ping()
        logger.info("Redis connection established")
    except Exception as e:
        logger.error(f"Redis connection failed: {e}")

    # Initialize database (creates tables if they don't exist)
    try:
        await init_db()
        logger.info("Database initialized")
    except Exception as e:
        logger.error(f"Database initialization failed: {e}")

    logger.info("Application startup complete")
    yield

    # Shutdown
    logger.info("Shutting down...")
    await close_redis()
    await close_db()
    logger.info("Shutdown complete")


# ─────────────── App Factory ───────────────

def create_app() -> FastAPI:
    app = FastAPI(
        title=settings.APP_NAME,
        version=settings.VERSION,
        description=(
            "StudyVerse API — AI-powered study certification and gamification platform.\n\n"
            "Authenticate with the `/api/v1/auth/login` endpoint to get a JWT bearer token, "
            "then click 'Authorize' and enter `Bearer <token>`."
        ),
        docs_url="/docs",
        redoc_url="/redoc",
        openapi_url="/openapi.json",
        lifespan=lifespan,
    )

    # ── Middleware (order matters: outermost = first to receive request) ──
    setup_cors(app)
    app.add_middleware(RateLimiterMiddleware)

    # ── Request timing middleware ──
    @app.middleware("http")
    async def add_request_timing(request: Request, call_next):
        start = time.perf_counter()
        response = await call_next(request)
        elapsed = time.perf_counter() - start
        response.headers["X-Process-Time"] = f"{elapsed:.4f}s"
        return response

    # ── Exception handlers ──

    @app.exception_handler(RequestValidationError)
    async def validation_exception_handler(request: Request, exc: RequestValidationError):
        errors = []
        for error in exc.errors():
            errors.append({
                "field": " -> ".join(str(loc) for loc in error["loc"]),
                "message": error["msg"],
                "type": error["type"],
            })
        return JSONResponse(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            content={"detail": "Validation error", "errors": errors},
        )

    @app.exception_handler(IntegrityError)
    async def integrity_error_handler(request: Request, exc: IntegrityError):
        logger.warning(f"Database integrity error: {exc}")
        return JSONResponse(
            status_code=status.HTTP_409_CONFLICT,
            content={"detail": "Database constraint violation"},
        )

    @app.exception_handler(Exception)
    async def unhandled_exception_handler(request: Request, exc: Exception):
        logger.error(f"Unhandled exception on {request.url}: {exc}", exc_info=True)
        return JSONResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            content={"detail": "Internal server error"},
        )

    # ── Health check ──

    @app.get("/health", tags=["Health"], include_in_schema=False)
    async def health_check():
        """Health check endpoint for load balancers and Docker."""
        checks = {}

        # Redis check
        try:
            redis = await get_redis()
            await redis.ping()
            checks["redis"] = "ok"
        except Exception as e:
            checks["redis"] = f"error: {e}"

        all_ok = all(v == "ok" for v in checks.values())
        return {
            "status": "healthy" if all_ok else "degraded",
            "version": settings.VERSION,
            "checks": checks,
        }

    @app.get("/", include_in_schema=False)
    async def root():
        return {
            "name": settings.APP_NAME,
            "version": settings.VERSION,
            "docs": "/docs",
        }

    # ── Routers ──
    prefix = "/api/v1"
    app.include_router(auth.router, prefix=prefix)
    app.include_router(users.router, prefix=prefix)
    app.include_router(study.router, prefix=prefix)
    app.include_router(ai.router, prefix=prefix)
    app.include_router(statistics.router, prefix=prefix)
    app.include_router(community.router, prefix=prefix)
    app.include_router(crew.router, prefix=prefix)
    app.include_router(rewards.router, prefix=prefix)
    app.include_router(ranking.router, prefix=prefix)
    app.include_router(admin.router, prefix=prefix)

    return app


app = create_app()
