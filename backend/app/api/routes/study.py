import uuid
from typing import Optional
from fastapi import APIRouter, Depends, Query, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
import math

from app.core.dependencies import get_db, get_cache, get_current_user
from app.core.redis import RedisCache
from app.models.user import User
from app.models.study_session import Subject
from app.schemas.study import (
    StudySessionCreate, StudySessionRead, StudyStartResponse,
    StudyStopRequest, StudyStopResponse, StudyHistoryResponse,
)
from app.services.study_service import StudyService

router = APIRouter(prefix="/study", tags=["Study Sessions"])


@router.post(
    "/start",
    response_model=StudyStartResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Start a new study session",
)
async def start_session(
    data: StudySessionCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
    cache: RedisCache = Depends(get_cache),
):
    """Begin a new study session. Fails if a session is already active."""
    service = StudyService(db, cache)
    return await service.start_session(current_user, data)


@router.post(
    "/stop/{session_id}",
    response_model=StudyStopResponse,
    summary="Stop an active study session",
)
async def stop_session(
    session_id: uuid.UUID,
    data: StudyStopRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
    cache: RedisCache = Depends(get_cache),
):
    """End a study session and queue AI analysis."""
    service = StudyService(db, cache)
    return await service.stop_session(current_user, session_id, data.notes)


@router.get(
    "/active",
    summary="Check for active study session",
)
async def get_active_session(
    current_user: User = Depends(get_current_user),
    cache: RedisCache = Depends(get_cache),
):
    """Return the current active session ID or null."""
    from app.core.redis import CacheKeys
    session_id = await cache.get(CacheKeys.active_study(str(current_user.id)))
    return {"active_session_id": session_id}


@router.get(
    "/history",
    response_model=StudyHistoryResponse,
    summary="Get study session history",
)
async def get_history(
    page: int = Query(default=1, ge=1),
    size: int = Query(default=20, ge=1, le=100),
    subject: Optional[Subject] = None,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
    cache: RedisCache = Depends(get_cache),
):
    """Paginated list of past study sessions."""
    service = StudyService(db, cache)
    sessions, total = await service.get_history(
        current_user.id, page=page, size=size, subject=subject
    )
    return StudyHistoryResponse(
        sessions=[StudySessionRead.model_validate(s) for s in sessions],
        total=total,
        page=page,
        size=size,
        total_pages=math.ceil(total / size) if total > 0 else 0,
    )


@router.get(
    "/{session_id}",
    response_model=StudySessionRead,
    summary="Get study session details",
)
async def get_session(
    session_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
    cache: RedisCache = Depends(get_cache),
):
    """Get details of a specific study session."""
    service = StudyService(db, cache)
    session = await service.get_session(current_user.id, session_id)
    return StudySessionRead.model_validate(session)
