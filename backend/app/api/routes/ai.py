import uuid
import json
from typing import Optional
from fastapi import (
    APIRouter, Depends, HTTPException, UploadFile, File,
    Form, status
)
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.core.dependencies import get_db, get_cache, get_current_user
from app.core.redis import RedisCache, CacheKeys
from app.models.user import User
from app.models.ai_report import AIReport
from app.schemas.ai_analysis import (
    FrameAnalysisResponse, AIReportRead, CoachRequest, CoachResponse,
    SessionSummaryAnalysis
)
from app.services.ai_service import AIService, SessionAnalysisAccumulator
from app.services.study_service import StudyService

router = APIRouter(prefix="/ai", tags=["AI Analysis"])

# In-memory accumulator per session (for demo; use Redis in production)
_accumulators: dict[str, SessionAnalysisAccumulator] = {}


@router.post(
    "/analyze-frame",
    response_model=FrameAnalysisResponse,
    summary="Analyze a single video frame",
)
async def analyze_frame(
    session_id: uuid.UUID = Form(...),
    frame_number: int = Form(...),
    timestamp_ms: int = Form(...),
    image: UploadFile = File(..., description="JPEG/PNG frame image"),
    current_user: User = Depends(get_current_user),
    cache: RedisCache = Depends(get_cache),
):
    """
    Analyze a single captured video frame for attention metrics.

    This endpoint is called repeatedly during a study session (e.g., every 5s).
    Results are accumulated per session to produce the final AI report.
    """
    # Verify session belongs to user
    active = await cache.get(CacheKeys.active_study(str(current_user.id)))
    if not active or active != str(session_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No active study session with this ID",
        )

    # Validate file type
    content_type = image.content_type or ""
    if not content_type.startswith("image/"):
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="File must be an image (JPEG or PNG)",
        )

    # Read image bytes
    image_data = await image.read()
    if len(image_data) > 5 * 1024 * 1024:  # 5MB limit
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail="Image too large (max 5MB)",
        )

    # Analyze frame
    ai_service = AIService()
    result = await ai_service.analyze_frame(
        image_data=image_data,
        frame_number=frame_number,
        timestamp_ms=timestamp_ms,
    )

    # Accumulate results
    acc_key = str(session_id)
    if acc_key not in _accumulators:
        _accumulators[acc_key] = SessionAnalysisAccumulator()
    _accumulators[acc_key].add_frame(result)

    return FrameAnalysisResponse(
        frame_number=result.frame_number,
        timestamp_ms=result.timestamp_ms,
        face_detected=result.face_detected,
        face_confidence=result.face_confidence,
        gaze_ok=result.gaze_ok,
        is_absent=result.is_absent,
        phone_detected=result.phone_detected,
        drowsy=result.drowsy,
        attention_score=result.attention_score,
        landmark_count=result.landmark_count,
        head_pose_pitch=result.head_pose_pitch,
        head_pose_yaw=result.head_pose_yaw,
        eye_aspect_ratio=result.eye_aspect_ratio,
    )


@router.post(
    "/finalize/{session_id}",
    response_model=SessionSummaryAnalysis,
    summary="Finalize session AI analysis",
)
async def finalize_session_analysis(
    session_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
    cache: RedisCache = Depends(get_cache),
):
    """
    Finalize AI analysis for a completed study session.
    Call this after stopping the session to commit the AI report.
    """
    acc_key = str(session_id)
    accumulator = _accumulators.pop(acc_key, None)
    if accumulator is None:
        # Create empty accumulator if no frames were submitted
        accumulator = SessionAnalysisAccumulator()

    study_service = StudyService(db, cache)
    await study_service.finalize_session(session_id, accumulator)

    # Return summary from the newly created report
    result = await db.execute(
        select(AIReport).where(AIReport.study_session_id == session_id)
    )
    report = result.scalar_one_or_none()

    if not report:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Session not found or already finalized",
        )

    from app.models.study_session import StudySession
    session_result = await db.execute(
        select(StudySession).where(StudySession.id == session_id)
    )
    session = session_result.scalar_one_or_none()

    ai_service = AIService()
    feedback = ai_service.generate_feedback({
        "overall_score": report.overall_score,
        "absence_ratio": report.absence_ratio,
        "phone_detected_ratio": report.phone_detected_ratio,
        "drowsy_ratio": report.drowsy_ratio,
        "gaze_ratio": report.gaze_ratio,
    })

    duration_minutes = (session.duration_seconds / 60) if session else 0
    total_secs = session.duration_seconds if session else 1

    return SessionSummaryAnalysis(
        session_id=session_id,
        duration_minutes=round(duration_minutes, 1),
        certified_minutes=report.certified_minutes,
        certification_rate=report.certified_minutes / (duration_minutes or 1),
        overall_score=report.overall_score,
        attention_score=report.attention_score,
        focused_percentage=round(report.focused_time_seconds / total_secs * 100, 1),
        absent_percentage=round(report.absent_time_seconds / total_secs * 100, 1),
        distracted_percentage=round(report.distracted_time_seconds / total_secs * 100, 1),
        drowsy_percentage=round(report.drowsy_time_seconds / total_secs * 100, 1),
        grade=feedback["grade"],
        feedback=feedback["feedback"],
        tips=feedback["tips"],
        strengths=feedback["strengths"],
        points_earned=session.points_earned if session else 0,
    )


@router.get(
    "/report/{session_id}",
    response_model=AIReportRead,
    summary="Get AI analysis report for a session",
)
async def get_report(
    session_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Retrieve the detailed AI analysis report for a completed session."""
    result = await db.execute(
        select(AIReport).where(
            AIReport.study_session_id == session_id,
            AIReport.user_id == current_user.id,
        )
    )
    report = result.scalar_one_or_none()

    if not report:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="AI report not found for this session",
        )

    return AIReportRead.model_validate(report)


@router.post(
    "/coach",
    response_model=CoachResponse,
    summary="Get AI study coach advice",
)
async def get_coach_advice(
    data: CoachRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
    cache: RedisCache = Depends(get_cache),
):
    """
    Get personalized AI coach advice based on study history and current situation.
    """
    # Build context from recent session if provided
    session_context = ""
    based_on_session = False

    if data.session_id:
        from app.models.ai_report import AIReport as AIReportModel
        report_result = await db.execute(
            select(AIReportModel).where(
                AIReportModel.study_session_id == data.session_id,
                AIReportModel.user_id == current_user.id,
            )
        )
        report = report_result.scalar_one_or_none()
        if report:
            based_on_session = True
            session_context = (
                f"세션 점수: {report.overall_score:.0f}, "
                f"집중률: {report.gaze_ratio*100:.0f}%, "
                f"부재율: {report.absence_ratio*100:.0f}%"
            )

    # Rule-based coach response (integrate LLM here for production)
    question = data.question.lower()
    advice_parts = []
    tips = []
    motivation = "오늘도 포기하지 말고 한 걸음씩 나아가세요!"
    break_minutes = None

    if any(w in question for w in ["졸려", "졸음", "집중이 안"]):
        advice_parts.append(
            "짧은 휴식이 필요합니다. 5-10분 스트레칭이나 차가운 물 세수를 해보세요."
        )
        tips = [
            "25분 공부 후 5분 휴식하는 포모도로 기법을 시도해보세요",
            "공부 중 껌을 씹으면 졸음 방지에 도움이 됩니다",
            "적당한 밝기의 조명을 확보하세요",
        ]
        break_minutes = 10
        motivation = "잠깐 쉬고 다시 시작하면 더 효율적으로 공부할 수 있어요!"

    elif any(w in question for w in ["집중", "방해", "산만"]):
        advice_parts.append(
            "집중력을 높이려면 환경 정리가 중요합니다. 휴대폰을 다른 방에 두고, "
            "소음 차단 이어폰을 활용해보세요."
        )
        tips = [
            "공부 전 5분간 명상으로 마음을 안정시키세요",
            "집중 방해 앱을 차단하세요 (Forest, Freedom 등)",
            "목표를 작게 나눠 달성감을 느끼세요",
        ]
        motivation = "집중하는 1시간이 산만한 5시간보다 효과적입니다!"

    elif any(w in question for w in ["시험", "암기", "외우"]):
        advice_parts.append(
            "암기에는 반복 학습이 효과적입니다. "
            "에빙하우스 망각 곡선에 따라 1일, 3일, 7일, 30일 후 복습하세요."
        )
        tips = [
            "마인드맵으로 개념을 시각화하세요",
            "소리 내어 읽거나 누군가에게 설명하면 기억에 도움됩니다",
            "플래시카드(Anki 앱)를 활용하세요",
        ]
        motivation = "반복이 실력이 됩니다. 꾸준히 복습하세요!"

    else:
        advice_parts.append(
            "꾸준한 공부가 성과로 이어집니다. "
            "매일 일정한 시간에 공부하는 습관을 만들어보세요."
        )
        tips = [
            "공부 시간을 캘린더에 미리 예약하세요",
            "목표를 구체적으로 설정하세요 (예: '오늘 수학 3단원 완료')",
            "공부 후 자신에게 작은 보상을 주세요",
        ]
        motivation = "지금 이 순간의 노력이 미래를 만듭니다. 화이팅!"

    if session_context:
        advice_parts.append(f"(최근 세션 기준: {session_context})")

    return CoachResponse(
        advice=" ".join(advice_parts),
        tips=tips,
        suggested_break_minutes=break_minutes,
        motivation_message=motivation,
        based_on_session=based_on_session,
    )
