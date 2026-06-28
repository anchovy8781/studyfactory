import uuid
from datetime import datetime
from sqlalchemy import String, Integer, DateTime, ForeignKey, func, Text, Boolean, JSON
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import UUID

from app.core.database import Base


class Badge(Base):
    """Badge/Achievement definitions."""
    __tablename__ = "badges"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        index=True,
    )
    name: Mapped[str] = mapped_column(
        String(100),
        unique=True,
        nullable=False,
    )
    description: Mapped[str] = mapped_column(
        Text,
        nullable=False,
    )
    icon_url: Mapped[str | None] = mapped_column(
        String(500),
        nullable=True,
    )
    category: Mapped[str] = mapped_column(
        String(50),
        nullable=False,
        comment="streak, study_time, ai_score, social, special",
    )

    # Unlock criteria (stored as JSON for flexibility)
    criteria: Mapped[dict | None] = mapped_column(
        JSON,
        nullable=True,
        comment="JSON criteria for earning this badge, e.g. {'streak_days': 7}",
    )

    # Badge value
    points_reward: Mapped[int] = mapped_column(
        Integer,
        default=0,
        nullable=False,
        comment="Points awarded when badge is earned",
    )
    rarity: Mapped[str] = mapped_column(
        String(20),
        default="common",
        nullable=False,
        comment="common, rare, epic, legendary",
    )

    is_active: Mapped[bool] = mapped_column(
        Boolean,
        default=True,
        nullable=False,
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )

    # Relationships
    user_badges: Mapped[list["UserBadge"]] = relationship(
        "UserBadge",
        back_populates="badge",
        lazy="dynamic",
    )

    def __repr__(self) -> str:
        return f"<Badge id={self.id} name={self.name} rarity={self.rarity}>"


class UserBadge(Base):
    """User-Badge association tracking when a user earned a badge."""
    __tablename__ = "user_badges"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    badge_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("badges.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    earned_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )

    # Relationships
    user: Mapped["User"] = relationship(
        "User",
        back_populates="user_badges",
    )
    badge: Mapped["Badge"] = relationship(
        "Badge",
        back_populates="user_badges",
    )

    def __repr__(self) -> str:
        return f"<UserBadge user={self.user_id} badge={self.badge_id}>"
