import uuid
import enum
from datetime import datetime
from sqlalchemy import (
    String, Integer, DateTime, ForeignKey, func, Text,
    Boolean, Enum, UniqueConstraint, Float
)
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import UUID

from app.core.database import Base


class CrewMemberRole(str, enum.Enum):
    LEADER = "leader"
    MODERATOR = "moderator"
    MEMBER = "member"


class Crew(Base):
    """Study crew/group model."""
    __tablename__ = "crews"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        index=True,
    )
    leader_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    name: Mapped[str] = mapped_column(
        String(100),
        nullable=False,
        unique=True,
    )
    description: Mapped[str | None] = mapped_column(
        Text,
        nullable=True,
    )
    icon_url: Mapped[str | None] = mapped_column(
        String(500),
        nullable=True,
    )
    banner_url: Mapped[str | None] = mapped_column(
        String(500),
        nullable=True,
    )

    # Settings
    is_public: Mapped[bool] = mapped_column(
        Boolean,
        default=True,
        nullable=False,
        comment="Public crews can be found in search",
    )
    requires_approval: Mapped[bool] = mapped_column(
        Boolean,
        default=False,
        nullable=False,
        comment="Whether joining requires leader approval",
    )
    max_members: Mapped[int] = mapped_column(
        Integer,
        default=50,
        nullable=False,
    )
    min_weekly_study_hours: Mapped[float] = mapped_column(
        Float,
        default=0.0,
        nullable=False,
        comment="Minimum weekly study hours required to stay in crew",
    )

    # Stats (denormalized for performance)
    member_count: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    total_study_hours: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    weekly_study_hours: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)
    average_ai_score: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)

    # Focus subjects
    subjects: Mapped[list | None] = mapped_column(
        "subjects_json",
        nullable=True,
        comment="JSON array of focus subjects",
    )

    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)

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
    members: Mapped[list["CrewMember"]] = relationship(
        "CrewMember",
        back_populates="crew",
        cascade="all, delete-orphan",
        lazy="dynamic",
    )

    def __repr__(self) -> str:
        return f"<Crew id={self.id} name={self.name} members={self.member_count}>"


class CrewMember(Base):
    """Crew membership."""
    __tablename__ = "crew_members"
    __table_args__ = (
        UniqueConstraint("user_id", "crew_id", name="uq_crew_members_user_crew"),
    )

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
    crew_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("crews.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    role: Mapped[CrewMemberRole] = mapped_column(
        Enum(CrewMemberRole),
        default=CrewMemberRole.MEMBER,
        nullable=False,
    )
    status: Mapped[str] = mapped_column(
        String(20),
        default="active",
        nullable=False,
        comment="active, pending, kicked",
    )
    contribution_hours: Mapped[float] = mapped_column(
        Float,
        default=0.0,
        nullable=False,
        comment="Total study hours contributed to crew",
    )
    joined_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )

    # Relationships
    user: Mapped["User"] = relationship(
        "User",
        back_populates="crew_memberships",
    )
    crew: Mapped["Crew"] = relationship(
        "Crew",
        back_populates="members",
    )

    def __repr__(self) -> str:
        return f"<CrewMember user={self.user_id} crew={self.crew_id} role={self.role}>"
