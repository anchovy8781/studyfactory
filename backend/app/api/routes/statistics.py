from datetime import date, timedelta
from typing import Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, and_

from app.core.dependencies import get_db, get_cache, get_current_user
from app.core.redis import RedisCache
from app.models.user import User
from app.models.study_session import StudySession, Subject
from app.schemas.study import DailyStats, WeeklyStats, MonthlyStats, SubjectStats
from app.services.study_service import StudyService

router = APIRouter(prefix="/statistics", tags=["Statistics"])


@router.get(
    "/daily",
    response_model=DailyStats,
    summary="Get daily study statistics",
)
async def get_daily_stats(
    target_date: Optional[date] = Query(
        default=None,
        description="Date in YYYY-MM-DD format, defaults to today",
    ),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
    cache: RedisCache = Depends(get_cache),
):
    """Get study statistics for a specific day."""
    if target_date is None:
        target_date = date.today()

    service = StudyService(db, cache)
    return await service.get_daily_stats(current_user.id, str(target_date))


@router.get(
    "/weekly",
    response_model=WeeklyStats,
    summary="Get weekly study statistics",
)
async def get_weekly_stats(
    week_offset: int = Query(default=0, ge=-52, le=0, description="0 = current week, -1 = last week"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
    cache: RedisCache = Depends(get_cache),
):
    """Get aggregated study statistics for a week."""
    today = date.today()
    week_start = today - timedelta(days=today.weekday()) + timedelta(weeks=week_offset)
    week_end = week_start + timedelta(days=6)

    # Fetch daily stats for each day of the week
    service = StudyService(db, cache)
    daily_stats = []
    for i in range(7):
        day = week_start + timedelta(days=i)
        stats = await service.get_daily_stats(current_user.id, str(day))
        daily_stats.append(stats)

    total_secs = sum(d.total_seconds for d in daily_stats)
    certified_secs = sum(d.certified_seconds for d in daily_stats)
    session_count = sum(d.session_count for d in daily_stats)

    scored = [d for d in daily_stats if d.ai_score is not None]
    avg_score = round(sum(d.ai_score for d in scored) / len(scored), 1) if scored else None

    return WeeklyStats(
        week_start=str(week_start),
        week_end=str(week_end),
        total_seconds=total_secs,
        certified_seconds=certified_secs,
        average_ai_score=avg_score,
        session_count=session_count,
        daily_breakdown=daily_stats,
    )


@router.get(
    "/monthly",
    response_model=MonthlyStats,
    summary="Get monthly study statistics",
)
async def get_monthly_stats(
    year: int = Query(default=None),
    month: int = Query(default=None, ge=1, le=12),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
    cache: RedisCache = Depends(get_cache),
):
    """Get aggregated study statistics for a calendar month."""
    today = date.today()
    if year is None:
        year = today.year
    if month is None:
        month = today.month

    # Get all sessions in this month
    result = await db.execute(
        select(
            func.count(StudySession.id).label("count"),
            func.coalesce(func.sum(StudySession.duration_seconds), 0).label("total"),
            func.coalesce(func.sum(StudySession.certified_duration_seconds), 0).label("certified"),
            func.avg(StudySession.ai_score).label("avg_score"),
        ).where(
            and_(
                StudySession.user_id == current_user.id,
                func.extract("year", StudySession.started_at) == year,
                func.extract("month", StudySession.started_at) == month,
                StudySession.ended_at.isnot(None),
            )
        )
    )
    row = result.one()

    # Build weekly breakdown
    from calendar import monthrange
    _, days_in_month = monthrange(year, month)

    service = StudyService(db, cache)
    weekly_stats = []
    week_start = date(year, month, 1)

    while week_start.month == month:
        week_end = min(
            week_start + timedelta(days=6),
            date(year, month, days_in_month),
        )
        daily_list = []
        current = week_start
        while current <= week_end:
            ds = await service.get_daily_stats(current_user.id, str(current))
            daily_list.append(ds)
            current += timedelta(days=1)

        week_total = sum(d.total_seconds for d in daily_list)
        week_certified = sum(d.certified_seconds for d in daily_list)
        week_sessions = sum(d.session_count for d in daily_list)
        week_scored = [d for d in daily_list if d.ai_score is not None]
        week_avg = round(sum(d.ai_score for d in week_scored) / len(week_scored), 1) if week_scored else None

        weekly_stats.append(WeeklyStats(
            week_start=str(week_start),
            week_end=str(week_end),
            total_seconds=week_total,
            certified_seconds=week_certified,
            average_ai_score=week_avg,
            session_count=week_sessions,
            daily_breakdown=daily_list,
        ))
        week_start = week_end + timedelta(days=1)

    return MonthlyStats(
        year=year,
        month=month,
        total_seconds=int(row.total or 0),
        certified_seconds=int(row.certified or 0),
        average_ai_score=round(float(row.avg_score), 1) if row.avg_score else None,
        session_count=int(row.count or 0),
        weekly_breakdown=weekly_stats,
    )


@router.get(
    "/subjects",
    response_model=list[SubjectStats],
    summary="Get statistics broken down by subject",
)
async def get_subject_stats(
    days: int = Query(default=30, ge=1, le=365, description="Days to look back"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Get study time distribution across subjects."""
    from datetime import datetime, timezone
    since = datetime.now(timezone.utc) - timedelta(days=days)

    result = await db.execute(
        select(
            StudySession.subject,
            func.count(StudySession.id).label("count"),
            func.coalesce(func.sum(StudySession.duration_seconds), 0).label("total"),
            func.coalesce(func.sum(StudySession.certified_duration_seconds), 0).label("certified"),
            func.avg(StudySession.ai_score).label("avg_score"),
        )
        .where(
            and_(
                StudySession.user_id == current_user.id,
                StudySession.started_at >= since,
                StudySession.ended_at.isnot(None),
            )
        )
        .group_by(StudySession.subject)
    )
    rows = result.all()

    total_all = sum(r.total for r in rows) or 1

    return [
        SubjectStats(
            subject=row.subject,
            total_seconds=int(row.total),
            certified_seconds=int(row.certified),
            session_count=int(row.count),
            average_ai_score=round(float(row.avg_score), 1) if row.avg_score else None,
            percentage=round(row.total / total_all * 100, 1),
        )
        for row in rows
    ]
