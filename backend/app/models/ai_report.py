import uuid
from datetime import datetime
from sqlalchemy import (
    String, Integer, Float, DateTime, ForeignKey, func, Text, JSON
)
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import UUID

from app.core.database import Base


class AIReport(Base):
    """
    Detailed AI analysis report for a study session.
    Stores aggregated frame-by-frame analysis results.
    """
    __tablename__ = "ai_reports"

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
    study_session_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("study_sessions.id", ondelete="CASCADE"),
        nullable=False,
        unique=True,
        index=True,
    )

    # Overall scores
    overall_score: Mapped[float] = mapped_column(
        Float,
        nullable=False,
        comment="Overall AI-computed study quality score (0-100)",
    )
    attention_score: Mapped[float] = mapped_column(
        Float,
        nullable=False,
        comment="Attention/focus score (0-100)",
    )
    consistency_score: Mapped[float] = mapped_column(
        Float,
        nullable=False,
        comment="Study consistency score (0-100)",
    )

    # Detailed ratios
    face_detected_ratio: Mapped[float] = mapped_column(Float, nullable=False)
    gaze_ratio: Mapped[float] = mapped_column(Float, nullable=False)
    absence_ratio: Mapped[float] = mapped_column(Float, nullable=False)
    phone_detected_ratio: Mapped[float] = mapped_column(Float, nullable=False)
    drowsy_ratio: Mapped[float] = mapped_column(Float, nullable=False)

    # Frame statistics
    total_frames: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    valid_frames: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    alert_frames: Mapped[int] = mapped_column(Integer, nullable=False, default=0)

    # Time breakdowns (in seconds)
    focused_time_seconds: Mapped[int] = mapped_column(Integer, default=0)
    distracted_time_seconds: Mapped[int] = mapped_column(Integer, default=0)
    absent_time_seconds: Mapped[int] = mapped_column(Integer, default=0)
    drowsy_time_seconds: Mapped[int] = mapped_column(Integer, default=0)
    phone_time_seconds: Mapped[int] = mapped_column(Integer, default=0)

    # AI-generated feedback
    feedback_summary: Mapped[str | None] = mapped_column(
        Text,
        nullable=True,
        comment="AI-generated study feedback summary",
    )
    improvement_tips: Mapped[list | None] = mapped_column(
        JSON,
        nullable=True,
        comment="List of AI improvement suggestions",
    )
    strengths: Mapped[list | None] = mapped_column(
        JSON,
        nullable=True,
        comment="List of identified strengths",
    )

    # Raw timeline data (optional, for charts)
    attention_timeline: Mapped[list | None] = mapped_column(
        JSON,
        nullable=True,
        comment="Array of attention scores per minute interval",
    )

    # Certification result
    certified_minutes: Mapped[int] = mapped_column(
        Integer,
        default=0,
        nullable=False,
        comment="AI-certified pure study minutes",
    )

    # Timestamps
    analyzed_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )

    # Relationships
    user: Mapped["User"] = relationship(
        "User",
        back_populates="ai_reports",
    )
    study_session: Mapped["StudySession"] = relationship(
        "StudySession",
        back_populates="ai_report",
    )

    def __repr__(self) -> str:
        return (
            f"<AIReport id={self.id} session_id={self.study_session_id} "
            f"score={self.overall_score}>"
        )
