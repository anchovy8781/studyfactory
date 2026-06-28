import uuid
import enum
from datetime import datetime
from sqlalchemy import (
    String, Integer, Float, Enum, DateTime, ForeignKey, func, Text
)
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import UUID

from app.core.database import Base


class Subject(str, enum.Enum):
    MATH = "수학"
    ENGLISH = "영어"
    KOREAN = "국어"
    SCIENCE = "과학"
    SOCIAL = "사회"
    OTHER = "기타"


class CertificationStatus(str, enum.Enum):
    PENDING = "pending"          # Session ongoing
    PROCESSING = "processing"    # AI analysis in progress
    CERTIFIED = "certified"      # Fully AI-certified
    PARTIAL = "partial"          # Partially certified
    REJECTED = "rejected"        # Not enough valid study time
    FAILED = "failed"            # Analysis failed


class StudySession(Base):
    __tablename__ = "study_sessions"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        index=True,
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    # Study details
    subject: Mapped[Subject] = mapped_column(
        Enum(Subject),
        nullable=False,
    )
    title: Mapped[str | None] = mapped_column(
        String(200),
        nullable=True,
        comment="Optional study title/topic",
    )
    notes: Mapped[str | None] = mapped_column(
        Text,
        nullable=True,
        comment="User's study notes",
    )

    # Timing
    started_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
    )
    ended_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True),
        nullable=True,
    )
    duration_seconds: Mapped[int] = mapped_column(
        Integer,
        default=0,
        nullable=False,
        comment="Total elapsed time in seconds",
    )
    certified_duration_seconds: Mapped[int] = mapped_column(
        Integer,
        default=0,
        nullable=False,
        comment="AI-certified pure study time in seconds",
    )

    # AI Analysis scores (all ratios are 0.0 - 1.0)
    ai_score: Mapped[float | None] = mapped_column(
        Float,
        nullable=True,
        comment="Overall attention/concentration score 0-100",
    )
    face_detected_ratio: Mapped[float | None] = mapped_column(
        Float,
        nullable=True,
        comment="Ratio of frames with face detected (0.0-1.0)",
    )
    gaze_ratio: Mapped[float | None] = mapped_column(
        Float,
        nullable=True,
        comment="Ratio of frames with on-screen gaze (0.0-1.0)",
    )
    absence_ratio: Mapped[float | None] = mapped_column(
        Float,
        nullable=True,
        comment="Ratio of frames where user was absent (0.0-1.0)",
    )
    phone_detected_ratio: Mapped[float | None] = mapped_column(
        Float,
        nullable=True,
        comment="Ratio of frames with phone detected (0.0-1.0)",
    )
    drowsy_ratio: Mapped[float | None] = mapped_column(
        Float,
        nullable=True,
        comment="Ratio of frames with drowsiness detected (0.0-1.0)",
    )

    # Frame analysis counts
    total_frames_analyzed: Mapped[int] = mapped_column(
        Integer,
        default=0,
        nullable=False,
    )

    # Certification
    certification_status: Mapped[CertificationStatus] = mapped_column(
        Enum(CertificationStatus),
        default=CertificationStatus.PENDING,
        nullable=False,
        index=True,
    )

    # Points awarded for this session
    points_earned: Mapped[int] = mapped_column(
        Integer,
        default=0,
        nullable=False,
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
    user: Mapped["User"] = relationship(
        "User",
        back_populates="study_sessions",
    )
    ai_report: Mapped["AIReport | None"] = relationship(
        "AIReport",
        back_populates="study_session",
        uselist=False,
        cascade="all, delete-orphan",
    )

    def __repr__(self) -> str:
        return (
            f"<StudySession id={self.id} user_id={self.user_id} "
            f"subject={self.subject} status={self.certification_status}>"
        )
