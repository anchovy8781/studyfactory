import uuid
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, EmailStr, Field, field_validator


class UserBase(BaseModel):
    email: EmailStr
    username: str = Field(..., min_length=3, max_length=50, pattern=r"^[a-zA-Z0-9_]+$")
    nickname: str = Field(..., min_length=2, max_length=50)


class UserRead(BaseModel):
    """Full user profile (for authenticated user - own profile)."""
    id: uuid.UUID
    email: EmailStr
    username: str
    nickname: str
    profile_image_url: Optional[str] = None
    bio: Optional[str] = None
    level: int
    total_study_hours: float
    certified_study_hours: float
    streak_days: int
    max_streak_days: int
    total_points: int
    available_points: int
    is_active: bool
    is_verified: bool
    role: str
    push_notifications_enabled: bool
    email_notifications_enabled: bool
    last_study_date: Optional[datetime] = None
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


class UserPublic(BaseModel):
    """Public user profile (for viewing other users)."""
    id: uuid.UUID
    username: str
    nickname: str
    profile_image_url: Optional[str] = None
    bio: Optional[str] = None
    level: int
    total_study_hours: float
    certified_study_hours: float
    streak_days: int
    max_streak_days: int
    created_at: datetime

    model_config = {"from_attributes": True}


class UserUpdate(BaseModel):
    """Schema for updating user profile."""
    nickname: Optional[str] = Field(None, min_length=2, max_length=50)
    bio: Optional[str] = Field(None, max_length=500)
    profile_image_url: Optional[str] = Field(None, max_length=500)
    push_notifications_enabled: Optional[bool] = None
    email_notifications_enabled: Optional[bool] = None
    firebase_token: Optional[str] = None


class UserRankingEntry(BaseModel):
    """User entry in ranking leaderboard."""
    rank: int
    user: UserPublic
    study_hours: float
    certified_hours: float
    ai_score: float
    streak_days: int
    points: int

    model_config = {"from_attributes": True}
