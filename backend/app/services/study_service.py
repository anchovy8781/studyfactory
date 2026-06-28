import uuid
from datetime import datetime, timezone
from typing import Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, and_, extract
from fastapi import HTTPException, status

from app.models.study_session import StudySession, Subject, CertificationStatus
from app.models.ai_report import AIReport
from app.models.user import User
from app.core.redis import RedisCache, CacheKeys
from app.core.config import settings
from app.schemas.study import (
    StudySessionCreate, StudyStartResponse, StudyStopResponse,
    DailyStats, WeeklyStats
)
from app.services.ai_service import AIService, SessionAnalysisAccumulator


class StudyService:
    def __init__(self, db: AsyncSession, cache: RedisCache):
        self.db = db
        self.cache = cache
        self.ai_service = AIService()

    async def start_session(
        self,
        user: User,
        data: StudySessionCreate,
    ) -> StudyStartResponse:
        """Start a new study session. Fails if one is already active."""
        # Check for active session
        active = await self.cache.get(CacheKeys.active_study(str(user.id)))
        if active:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="You already have an active study session",
            )

        session = StudySession(
            user_id=user.id,
            subject=data.subject,
            title=data.title,
            started_at=datetime.now(timezone.utc),
            certification_status=CertificationStatus.PENDING,
        )
        self.db.add(session)
        await self.db.flush()
        await self.db.refresh(session)

        # Cache active session reference
        await self.cache.set(
            CacheKeys.active_study(str(user.id)),
            str(session.id),
            expire=24 * 3600,  # 24h max session
        )

        return StudyStartResponse(
            session_id=session.id,
            started_at=session.started_at,
            subject=session.subject,
            title=session.title,
        )

    async def stop_session(
        self,
        user: User,
        session_id: uuid.UUID,
        notes: Optional[str] = None,
    ) -> StudyStopResponse:
        """End a study session and compute final metrics."""
        session = await self._get_user_session(user.id, session_id)

        if session.ended_at is not None:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Session already stopped",
            )

        now = datetime.now(timezone.utc)
        session.ended_at = now
        session.duration_seconds = int(
            (now - session.started_at).total_seconds()
        )
        session.notes = notes

        # Check minimum duration
        if session.duration_seconds < settings.MIN_STUDY_DURATION_SECONDS:
            session.certification_status = CertificationStatus.REJECTED
            session.certified_duration_seconds = 0
            session.ai_score = 0.0
            points = 0
        else:
            session.certification_status = CertificationStatus.PROCESSING

        self.db.add(session)
        await self.db.flush()

        # Remove active session from cache
        await self.cache.delete(CacheKeys.active_study(str(user.id)))

        # Clear user stats cache
        await self.cache.delete_pattern(f"stats:{user.id}:*")

        return StudyStopResponse(
            session_id=session.id,
            duration_seconds=session.duration_seconds,
            certified_duration_seconds=session.certified_duration_seconds,
            ai_score=session.ai_score,
            points_earned=session.points_earned,
            certification_status=session.certification_status,
            message=(
                "Session ended. AI analysis in progress."
                if session.certification_status == CertificationStatus.PROCESSING
                else "Session too short to be certified (minimum 5 minutes)"
            ),
        )

    async def finalize_session(
        self,
        session_id: uuid.UUID,
        accumulator: SessionAnalysisAccumulator,
    ) -> None:
        """
        Finalize a session after all frames are analyzed.
        Called by the frame analysis endpoint when session ends.
        """
        result = await self.db.execute(
            select(StudySession).where(StudySession.id == session_id)
        )
        session = result.scalar_one_or_none()
        if not session:
            return

        summary = accumulator.finalize()
        feedback = self.ai_service.generate_feedback(summary)

        session.ai_score = summary["overall_score"]
        session.face_detected_ratio = summary["face_detected_ratio"]
        session.gaze_ratio = summary["gaze_ratio"]
        session.absence_ratio = summary["absence_ratio"]
        session.phone_detected_ratio = summary["phone_detected_ratio"]
        session.drowsy_ratio = summary["drowsy_ratio"]
        session.total_frames_analyzed = summary["total_frames"]

        certified_secs = self.ai_service.compute_certified_duration(
            session.duration_seconds, summary
        )
        session.certified_duration_seconds = certified_secs
        session.points_earned = self.ai_service.compute_points(
            certified_secs, summary["overall_score"]
        )
        session.certification_status = (
            CertificationStatus.CERTIFIED
            if session.ai_score >= 50
            else CertificationStatus.PARTIAL
        )

        # Create AI report
        report = AIReport(
            user_id=session.user_id,
            study_session_id=session.id,
            overall_score=summary["overall_score"],
            attention_score=summary["average_attention_score"],
            consistency_score=summary["consistency_score"],
            face_detected_ratio=summary["face_detected_ratio"],
            gaze_ratio=summary["gaze_ratio"],
            absence_ratio=summary["absence_ratio"],
            phone_detected_ratio=summary["phone_detected_ratio"],
            drowsy_ratio=summary["drowsy_ratio"],
            total_frames=summary["total_frames"],
            valid_frames=summary["valid_frames"],
            alert_frames=summary["alert_frames"],
            focused_time_seconds=int(
                session.duration_seconds * summary["gaze_ratio"]
            ),
            distracted_time_seconds=int(
                session.duration_seconds * (1 - summary["gaze_ratio"]) * 0.5
            ),
            absent_time_seconds=int(
                session.duration_seconds * summary["absence_ratio"]
            ),
            drowsy_time_seconds=int(
                session.duration_seconds * summary["drowsy_ratio"]
            ),
            phone_time_seconds=int(
                session.duration_seconds * summary["phone_detected_ratio"]
            ),
            feedback_summary=feedback["feedback"],
            improvement_tips=feedback["tips"],
            strengths=feedback["strengths"],
            attention_timeline=summary.get("attention_timeline"),
            certified_minutes=certified_secs // 60,
        )
        self.db.add(report)

        # Update user stats
        user_result = await self.db.execute(
            select(User).where(User.id == session.user_id)
        )
        user = user_result.scalar_one_or_none()
        if user:
            user.total_study_hours += session.duration_seconds / 3600
            user.certified_study_hours += certified_secs / 3600
            user.total_points += session.points_earned
            user.available_points += session.points_earned
            user.last_study_date = session.ended_at
            await self._update_streak(user, session.ended_at)
            self.db.add(user)

        await self.db.flush()

    async def _update_streak(self, user: User, study_date: datetime) -> None:
        """Update streak days based on last study date."""
        if user.last_study_date is None:
            user.streak_days = 1
        else:
            last = user.last_study_date
            days_diff = (study_date.date() - last.date()).days
            if days_diff == 1:
                user.streak_days += 1
            elif days_diff == 0:
                pass  # Same day, no change
            else:
                user.streak_days = 1  # Reset

        if user.streak_days > user.max_streak_days:
            user.max_streak_days = user.streak_days

    async def get_session(
        self, user_id: uuid.UUID, session_id: uuid.UUID
    ) -> StudySession:
        return await self._get_user_session(user_id, session_id)

    async def get_history(
        self,
        user_id: uuid.UUID,
        page: int = 1,
        size: int = 20,
        subject: Optional[Subject] = None,
    ) -> tuple[list[StudySession], int]:
        """Paginated study session history."""
        query = select(StudySession).where(StudySession.user_id == user_id)
        count_query = (
            select(func.count())
            .select_from(StudySession)
            .where(StudySession.user_id == user_id)
        )

        if subject:
            query = query.where(StudySession.subject == subject)
            count_query = count_query.where(StudySession.subject == subject)

        total_result = await self.db.execute(count_query)
        total = total_result.scalar_one()

        query = (
            query.order_by(StudySession.started_at.desc())
            .offset((page - 1) * size)
            .limit(size)
        )
        result = await self.db.execute(query)
        sessions = result.scalars().all()
        return list(sessions), total

    async def get_daily_stats(
        self, user_id: uuid.UUID, date_str: str
    ) -> DailyStats:
        """Stats for a single day."""
        cache_key = CacheKeys.user_stats(str(user_id), f"daily:{date_str}")
        cached = await self.cache.get(cache_key)
        if cached:
            return DailyStats(**cached)

        result = await self.db.execute(
            select(
                func.count(StudySession.id).label("count"),
                func.coalesce(func.sum(StudySession.duration_seconds), 0).label("total"),
                func.coalesce(func.sum(StudySession.certified_duration_seconds), 0).label("certified"),
                func.avg(StudySession.ai_score).label("avg_score"),
            ).where(
                and_(
                    StudySession.user_id == user_id,
                    func.date(StudySession.started_at) == date_str,
                    StudySession.ended_at.isnot(None),
                )
            )
        )
        row = result.one()

        stats = DailyStats(
            date=date_str,
            total_seconds=int(row.total or 0),
            certified_seconds=int(row.certified or 0),
            ai_score=round(float(row.avg_score), 1) if row.avg_score else None,
            session_count=int(row.count or 0),
        )
        await self.cache.set(cache_key, stats.model_dump(), expire=3600)
        return stats

    async def _get_user_session(
        self, user_id: uuid.UUID, session_id: uuid.UUID
    ) -> StudySession:
        result = await self.db.execute(
            select(StudySession).where(
                and_(
                    StudySession.id == session_id,
                    StudySession.user_id == user_id,
                )
            )
        )
        session = result.scalar_one_or_none()
        if not session:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Study session not found",
            )
        return session
