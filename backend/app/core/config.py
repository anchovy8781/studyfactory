from pydantic_settings import BaseSettings
from typing import Optional


class Settings(BaseSettings):
    APP_NAME: str = "StudyVerse API"
    VERSION: str = "1.0.0"
    DEBUG: bool = False

    # Database
    DATABASE_URL: str = "postgresql+asyncpg://studyverse:studyverse_pass@localhost:5432/studyverse"

    # Redis
    REDIS_URL: str = "redis://localhost:6379"

    # JWT
    SECRET_KEY: str = "change-this-secret-key-in-production-at-least-32-chars"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 30

    # Firebase
    FIREBASE_CREDENTIALS: str = ""

    # AWS
    AWS_ACCESS_KEY: str = ""
    AWS_SECRET_KEY: str = ""
    S3_BUCKET: str = "studyverse-uploads"

    # AI Settings
    AI_CONFIDENCE_THRESHOLD: float = 0.85
    MIN_STUDY_DURATION_SECONDS: int = 300

    # CORS
    ALLOWED_ORIGINS: list[str] = [
        "http://localhost:3000",
        "http://localhost:8080",
        "https://studyverse.app",
        "https://www.studyverse.app",
    ]

    # Rate limiting
    RATE_LIMIT_PER_MINUTE: int = 60
    RATE_LIMIT_BURST: int = 10

    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
