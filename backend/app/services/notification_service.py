import logging
from typing import Optional
from app.core.config import settings

logger = logging.getLogger(__name__)

# Lazy-initialize Firebase Admin SDK
_firebase_app = None


def _get_firebase():
    global _firebase_app
    if _firebase_app is not None:
        return _firebase_app

    if not settings.FIREBASE_CREDENTIALS:
        logger.warning("Firebase credentials not configured; push notifications disabled")
        return None

    try:
        import firebase_admin
        from firebase_admin import credentials

        cred = credentials.Certificate(settings.FIREBASE_CREDENTIALS)
        _firebase_app = firebase_admin.initialize_app(cred)
        logger.info("Firebase Admin SDK initialized")
        return _firebase_app
    except Exception as e:
        logger.error(f"Failed to initialize Firebase: {e}")
        return None


class NotificationService:
    """Service for sending push notifications via Firebase Cloud Messaging."""

    async def send_push(
        self,
        token: str,
        title: str,
        body: str,
        data: Optional[dict] = None,
    ) -> bool:
        """
        Send a push notification to a device.

        Args:
            token: Firebase device token
            title: Notification title
            body: Notification body text
            data: Optional data payload

        Returns:
            True if sent successfully
        """
        app = _get_firebase()
        if app is None:
            logger.debug(f"[STUB] Push notification: {title} -> {body}")
            return False

        try:
            from firebase_admin import messaging

            message = messaging.Message(
                notification=messaging.Notification(
                    title=title,
                    body=body,
                ),
                data=data or {},
                token=token,
                android=messaging.AndroidConfig(
                    priority="high",
                    notification=messaging.AndroidNotification(
                        channel_id="studyverse_alerts",
                    ),
                ),
                apns=messaging.APNSConfig(
                    payload=messaging.APNSPayload(
                        aps=messaging.Aps(sound="default"),
                    ),
                ),
            )

            response = messaging.send(message)
            logger.info(f"Push notification sent: {response}")
            return True

        except Exception as e:
            logger.error(f"Failed to send push notification: {e}")
            return False

    async def send_study_reminder(self, token: str, streak_days: int) -> bool:
        """Remind user to maintain their study streak."""
        return await self.send_push(
            token=token,
            title="📚 공부 스트릭을 유지하세요!",
            body=f"오늘도 공부해서 {streak_days}일 스트릭을 지켜보세요!",
            data={"type": "streak_reminder", "streak_days": str(streak_days)},
        )

    async def send_session_complete(
        self,
        token: str,
        duration_minutes: int,
        ai_score: float,
        points_earned: int,
    ) -> bool:
        """Notify user their study session analysis is complete."""
        return await self.send_push(
            token=token,
            title="✅ 공부 인증 완료!",
            body=(
                f"{duration_minutes}분 공부 완료! "
                f"AI 점수: {ai_score:.0f}점, +{points_earned} 포인트 획득"
            ),
            data={
                "type": "session_complete",
                "ai_score": str(ai_score),
                "points": str(points_earned),
            },
        )

    async def send_badge_earned(self, token: str, badge_name: str) -> bool:
        """Notify user they earned a new badge."""
        return await self.send_push(
            token=token,
            title="🏅 새 배지 획득!",
            body=f"'{badge_name}' 배지를 획득했습니다!",
            data={"type": "badge_earned", "badge_name": badge_name},
        )

    async def send_crew_invitation(
        self, token: str, crew_name: str, inviter_name: str
    ) -> bool:
        """Notify user they've been invited to a crew."""
        return await self.send_push(
            token=token,
            title="👥 크루 초대!",
            body=f"{inviter_name}님이 '{crew_name}' 크루에 초대했습니다.",
            data={"type": "crew_invitation", "crew_name": crew_name},
        )

    async def send_ranking_update(self, token: str, rank: int) -> bool:
        """Notify user of their weekly ranking."""
        return await self.send_push(
            token=token,
            title="📊 주간 랭킹 업데이트",
            body=f"이번 주 랭킹: {rank}위입니다!",
            data={"type": "ranking_update", "rank": str(rank)},
        )
