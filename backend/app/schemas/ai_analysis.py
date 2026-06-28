import uuid
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field


class FrameAnalysisRequest(BaseModel):
    """Request to analyze a single video frame."""
    session_id: uuid.UUID
    frame_number: int
    timestamp_ms: int = Field(..., description="Milliseconds from session start")
    # image_data is sent as multipart form data (base64 or bytes)


class FrameAnalysisResponse(BaseModel):
    """Result of analyzing a single frame."""
    frame_number: int
    timestamp_ms: int

    # Detection results
    face_detected: bool
    face_confidence: float = Field(..., ge=0.0, le=1.0)
    gaze_ok: bool = Field(..., description="True if gaze is directed at screen")
    is_absent: bool = Field(..., description="True if user is not visible")
    phone_detected: bool
    drowsy: bool

    # Computed score for this frame
    attention_score: float = Field(..., ge=0.0, le=100.0)

    # Optional detail
    landmark_count: Optional[int] = None
    head_pose_pitch: Optional[float] = None
    head_pose_yaw: Optional[float] = None
    eye_aspect_ratio: Optional[float] = None


class AIReportRead(BaseModel):
    """Serialized AI report for API response."""
    id: uuid.UUID
    user_id: uuid.UUID
    study_session_id: uuid.UUID

    # Scores
    overall_score: float
    attention_score: float
    consistency_score: float

    # Ratios
    face_detected_ratio: float
    gaze_ratio: float
    absence_ratio: float
    phone_detected_ratio: float
    drowsy_ratio: float

    # Counts
    total_frames: int
    valid_frames: int
    alert_frames: int

    # Time breakdowns (seconds)
    focused_time_seconds: int
    distracted_time_seconds: int
    absent_time_seconds: int
    drowsy_time_seconds: int
    phone_time_seconds: int

    # AI feedback
    feedback_summary: Optional[str] = None
    improvement_tips: Optional[list[str]] = None
    strengths: Optional[list[str]] = None
    attention_timeline: Optional[list[float]] = None

    certified_minutes: int
    analyzed_at: datetime
    created_at: datetime

    model_config = {"from_attributes": True}


class CoachRequest(BaseModel):
    """Request for AI study coach advice."""
    session_id: Optional[uuid.UUID] = None
    question: str = Field(..., max_length=500)
    context: Optional[str] = Field(
        None,
        max_length=1000,
        description="Additional context about the study situation",
    )


class CoachResponse(BaseModel):
    """AI coach response."""
    advice: str
    tips: list[str]
    suggested_break_minutes: Optional[int] = None
    motivation_message: str
    based_on_session: bool = False


class SessionSummaryAnalysis(BaseModel):
    """Summary analysis generated at end of session."""
    session_id: uuid.UUID
    duration_minutes: float
    certified_minutes: float
    certification_rate: float = Field(..., description="certified/total ratio 0-1")
    overall_score: float
    attention_score: float

    # Breakdown
    focused_percentage: float
    absent_percentage: float
    distracted_percentage: float
    drowsy_percentage: float

    # Verdict
    grade: str = Field(..., description="S/A/B/C/D grade based on score")
    feedback: str
    tips: list[str]
    strengths: list[str]
    points_earned: int
