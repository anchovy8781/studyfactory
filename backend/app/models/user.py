import uuid
import enum
from datetime import datetime
from sqlalchemy import (
    String, Boolean, Integer, Float, Enum, DateTime, Text, func
)
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import UUID

from app.core.database import Base


class UserRole(str, enum.Enum):
    USER = "user"
    ADMIN = "admin"
    MODERATOR = "moderator"


class User(Base):
    __tablename__ = "users"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        index=True,
    )
    email: Mapped[str] = mapped_column(
        String(255),
        unique=True,
        nullable=False,
        index=True,
    )
    username: Mapped[str] = mapped_column(
        String(50),
        unique=True,
        nullable=False,
        index=True,
    )
    nickname: Mapped[str] = mapped_column(
        String(50),
        nullable=False,
    )
    hashed_password: Mapped[str] = mapped_column(
        String(255),
        nullable=False,
    )
    profile_image_url: Mapped[str | None] = mapped_column(
        String(500),
        nullable=True,
    )
    bio: Mapped[str | None] = mapped_column(
        Text,
        nullable=True,
    )

    # Study metrics
    level: Mapped[int] = mapped_column(
        Integer,
        default=1,
        nullable=False,
    )
    total_study_hours: Mapped[float] = mapped_column(
        Float,
        default=0.0,
        nullable=False,
    )
    certified_study_hours: Mapped[float] = mapped_column(
        Float,
        default=0.0,
        nullable=False,
        comment="AI-certified pure study hours",
    )
    streak_days: Mapped[int] = mapped_column(
        Integer,
        default=0,
        nullable=False,
    )
    max_streak_days: Mapped[int] = mapped_column(
        Integer,
        default=0,
        nullable=False,
    )
    last_study_date: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True),
        nullable=True,
    )

    # Points and rewards
    total_points: Mapped[int] = mapped_column(
        Integer,
        default=0,
        nullable=False,
    )
    available_points: Mapped[int] = mapped_column(
        Integer,
        default=0,
        nullable=False,
    )

    # Account status
    is_active: Mapped[bool] = mapped_column(
        Boolean,
        default=True,
        nullable=False,
    )
    is_verified: Mapped[bool] = mapped_column(
        Boolean,
        default=False,
        nullable=False,
    )
    role: Mapped[UserRole] = mapped_column(
        Enum(UserRole),
        default=UserRole.USER,
        nullable=False,
    )

    # Notification preferences
    push_notifications_enabled: Mapped[bool] = mapped_column(
        Boolean,
        default=True,
        nullable=False,
    )
    email_notifications_enabled: Mapped[bool] = mapped_column(
        Boolean,
        default=True,
        nullable=False,
    )
    firebase_token: Mapped[str | None] = mapped_column(
        String(500),
        nullable=True,
    )

    # Timestamps
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False,
    )

    # Relationships
    study_sessions: Mapped[list["StudySession"]] = relationship(
        "StudySession",
        back_populates="user",
        cascade="all, delete-orphan",
        lazy="dynamic",
    )
    ai_reports: Mapped[list["AIReport"]] = relationship(
        "AIReport",
        back_populates="user",
        cascade="all, delete-orphan",
        lazy="dynamic",
    )
    user_badges: Mapped[list["UserBadge"]] = relationship(
        "UserBadge",
        back_populates="user",
        cascade="all, delete-orphan",
        lazy="dynamic",
    )
    point_transactions: Mapped[list["PointTransaction"]] = relationship(
        "PointTransaction",
        back_populates="user",
        cascade="all, delete-orphan",
        lazy="dynamic",
    )
    posts: Mapped[list["Post"]] = relationship(
        "Post",
        back_populates="author",
        cascade="all, delete-orphan",
        lazy="dynamic",
    )
    comments: Mapped[list["Comment"]] = relationship(
        "Comment",
        back_populates="author",
        cascade="all, delete-orphan",
        lazy="dynamic",
    )
    crew_memberships: Mapped[list["CrewMember"]] = relationship(
        "CrewMember",
        back_populates="user",
        cascade="all, delete-orphan",
        lazy="dynamic",
    )

    def __repr__(self) -> str:
        return f"<User id={self.id} email={self.email} username={self.username}>"
