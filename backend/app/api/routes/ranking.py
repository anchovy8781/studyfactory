from typing import Literal
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, and_, desc
from datetime import datetime, timedelta, timezone

from app.core.dependencies import get_db, get_cache, get_current_user
from app.core.redis import RedisCache, CacheKeys
from app.models.user import User
from app.models.study_session import StudySession
from app.schemas.user import UserRankingEntry, UserPublic

router = APIRouter(prefix="/ranking", tags=["Ranking"])


@router.get(
    "",
    response_model=list[UserRankingEntry],
    summary="Get study leaderboard",
)
async def get_ranking(
    period: Literal["daily", "weekly", "monthly", "all_time"] = Query(default="weekly"),
    limit: int = Query(default=50, ge=1, le=100),
    subject: str | None = None,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
    cache: RedisCache = Depends(get_cache),
):
    """
    Get the study leaderboard ranked by certified study hours.

    Periods: daily, weekly, monthly, all_time
    Results are cached for 5 minutes.
    """
    cache_key = CacheKeys.ranking(f"{period}:{subject or 'all'}:{limit}")
    cached = await cache.get(cache_key)
    if cached:
        return cached

    # Compute time filter
    now = datetime.now(timezone.utc)
    time_filter = None
    if period == "daily":
        time_filter = now - timedelta(days=1)
    elif period == "weekly":
        time_filter = now - timedelta(weeks=1)
    elif period == "monthly":
        time_filter = now - timedelta(days=30)

    # Build aggregation query
    query = (
        select(
            User,
            func.coalesce(func.sum(StudySession.duration_seconds), 0).label("study_secs"),
            func.coalesce(func.sum(StudySession.certified_duration_seconds), 0).label("certified_secs"),
            func.coalesce(func.avg(StudySession.ai_score), 0).label("avg_ai_score"),
        )
        .outerjoin(
            StudySession,
            and_(
                StudySession.user_id == User.id,
                StudySession.ended_at.isnot(None),
                *(
                    [StudySession.started_at >= time_filter]
                    if time_filter
                    else []
                ),
            ),
        )
        .where(User.is_active == True)
        .group_by(User.id)
        .order_by(desc("certified_secs"), desc("avg_ai_score"))
        .limit(limit)
    )

    result = await db.execute(query)
    rows = result.all()

    ranking = []
    for rank, row in enumerate(rows, start=1):
        user = row[0]
        study_hours = row[1] / 3600
        certified_hours = row[2] / 3600
        avg_score = float(row[3] or 0)

        ranking.append(
            UserRankingEntry(
                rank=rank,
                user=UserPublic.model_validate(user),
                study_hours=round(study_hours, 2),
                certified_hours=round(certified_hours, 2),
                ai_score=round(avg_score, 1),
                streak_days=user.streak_days,
                points=user.total_points,
            ).model_dump(mode="json")
        )

    await cache.set(cache_key, ranking, expire=300)  # 5-minute cache
    return ranking


@router.get(
    "/me",
    summary="Get current user's rank",
)
async def get_my_rank(
    period: Literal["daily", "weekly", "monthly", "all_time"] = Query(default="weekly"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
    cache: RedisCache = Depends(get_cache),
):
    """Get the current user's position in the leaderboard."""
    # Get full ranking and find current user's position
    from datetime import datetime, timedelta, timezone
    now = datetime.now(timezone.utc)
    time_filter = None
    if period == "daily":
        time_filter = now - timedelta(days=1)
    elif period == "weekly":
        time_filter = now - timedelta(weeks=1)
    elif period == "monthly":
        time_filter = now - timedelta(days=30)

    # Count users with more certified hours
    subq = (
        select(func.coalesce(func.sum(StudySession.certified_duration_seconds), 0))
        .where(
            and_(
                StudySession.user_id == current_user.id,
                StudySession.ended_at.isnot(None),
                *(
                    [StudySession.started_at >= time_filter]
                    if time_filter
                    else []
                ),
            )
        )
        .scalar_subquery()
    )

    count_result = await db.execute(
        select(func.count())
        .select_from(User)
        .outerjoin(
            StudySession,
            and_(
                StudySession.user_id == User.id,
                StudySession.ended_at.isnot(None),
                *(
                    [StudySession.started_at >= time_filter]
                    if time_filter
                    else []
                ),
            ),
        )
        .where(User.is_active == True)
        .group_by(User.id)
        .having(
            func.coalesce(func.sum(StudySession.certified_duration_seconds), 0) > subq
        )
    )

    rows_above = count_result.scalar() or 0
    my_rank = rows_above + 1

    return {
        "rank": my_rank,
        "period": period,
        "user_id": str(current_user.id),
        "certified_hours": round(current_user.certified_study_hours, 2),
        "total_points": current_user.total_points,
        "streak_days": current_user.streak_days,
    }
