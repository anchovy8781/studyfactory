import uuid
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field

from app.models.study_session import Subject, CertificationStatus


class StudySessionCreate(BaseModel):
    subject: Subject
    title: Optional[str] = Field(None, max_length=200)


class StudyStartResponse(BaseModel):
    session_id: uuid.UUID
    started_at: datetime
    subject: Subject
    title: Optional[str] = None
    message: str = "Study session started"


class StudyStopRequest(BaseModel):
    notes: Optional[str] = Field(None, max_length=2000)


class StudyStopResponse(BaseModel):
    session_id: uuid.UUID
    duration_seconds: int
    certified_duration_seconds: int
    ai_score: Optional[float] = None
    points_earned: int
    certification_status: CertificationStatus
    message: str


class StudySessionUpdate(BaseModel):
    title: Optional[str] = Field(None, max_length=200)
    notes: Optional[str] = Field(None, max_length=2000)


class StudySessionRead(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    subject: Subject
    title: Optional[str] = None
    notes: Optional[str] = None
    started_at: datetime
    ended_at: Optional[datetime] = None
    duration_seconds: int
    certified_duration_seconds: int
    ai_score: Optional[float] = None
    face_detected_ratio: Optional[float] = None
    gaze_ratio: Optional[float] = None
    absence_ratio: Optional[float] = None
    phone_detected_ratio: Optional[float] = None
    drowsy_ratio: Optional[float] = None
    total_frames_analyzed: int
    certification_status: CertificationStatus
    points_earned: int
    created_at: datetime

    model_config = {"from_attributes": True}


class StudyHistoryResponse(BaseModel):
    sessions: list[StudySessionRead]
    total: int
    page: int
    size: int
    total_pages: int


class DailyStats(BaseModel):
    date: str
    total_seconds: int
    certified_seconds: int
    ai_score: Optional[float] = None
    session_count: int


class WeeklyStats(BaseModel):
    week_start: str
    week_end: str
    total_seconds: int
    certified_seconds: int
    average_ai_score: Optional[float] = None
    session_count: int
    daily_breakdown: list[DailyStats]


class MonthlyStats(BaseModel):
    year: int
    month: int
    total_seconds: int
    certified_seconds: int
    average_ai_score: Optional[float] = None
    session_count: int
    weekly_breakdown: list[WeeklyStats]


class SubjectStats(BaseModel):
    subject: Subject
    total_seconds: int
    certified_seconds: int
    session_count: int
    average_ai_score: Optional[float] = None
    percentage: float
