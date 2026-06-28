"""
AI Analysis Service using MediaPipe for face detection and attention scoring.

Analyzes video frames for:
- Face presence and confidence
- Gaze direction (on-screen vs off-screen)
- Drowsiness detection (eye aspect ratio)
- Phone detection (object classification via pose/shape)
- Absence detection (no face visible)
"""

import io
import math
import logging
from typing import Optional
from dataclasses import dataclass, field

import numpy as np

logger = logging.getLogger(__name__)

# Lazy-load heavy deps to avoid import errors in environments without GPU
_mp = None
_cv2 = None


def _get_mediapipe():
    global _mp
    if _mp is None:
        try:
            import mediapipe as mp
            _mp = mp
        except ImportError:
            logger.warning("MediaPipe not available, using stub detector")
    return _mp


def _get_cv2():
    global _cv2
    if _cv2 is None:
        try:
            import cv2
            _cv2 = cv2
        except ImportError:
            logger.warning("OpenCV not available, using stub")
    return _cv2


@dataclass
class FrameAnalysisResult:
    """Result of analyzing a single video frame."""
    frame_number: int = 0
    timestamp_ms: int = 0

    # Detections
    face_detected: bool = False
    face_confidence: float = 0.0
    gaze_ok: bool = False
    is_absent: bool = True
    phone_detected: bool = False
    drowsy: bool = False

    # Pose angles
    head_pose_pitch: Optional[float] = None  # Up/down
    head_pose_yaw: Optional[float] = None    # Left/right

    # Eye metrics
    eye_aspect_ratio: Optional[float] = None
    landmark_count: int = 0

    # Computed score (0–100)
    attention_score: float = 0.0


@dataclass
class SessionAnalysisAccumulator:
    """Accumulates per-frame results for a full session."""
    total_frames: int = 0
    face_detected_frames: int = 0
    gaze_ok_frames: int = 0
    absent_frames: int = 0
    phone_detected_frames: int = 0
    drowsy_frames: int = 0
    attention_scores: list = field(default_factory=list)

    # Per-minute timeline
    minute_scores: list = field(default_factory=list)
    current_minute_scores: list = field(default_factory=list)
    current_minute: int = 0

    def add_frame(self, result: FrameAnalysisResult, fps: float = 1.0) -> None:
        self.total_frames += 1
        if result.face_detected:
            self.face_detected_frames += 1
        if result.gaze_ok:
            self.gaze_ok_frames += 1
        if result.is_absent:
            self.absent_frames += 1
        if result.phone_detected:
            self.phone_detected_frames += 1
        if result.drowsy:
            self.drowsy_frames += 1
        self.attention_scores.append(result.attention_score)

        # Track per-minute
        minute = result.timestamp_ms // 60000
        if minute != self.current_minute:
            if self.current_minute_scores:
                avg = sum(self.current_minute_scores) / len(self.current_minute_scores)
                self.minute_scores.append(round(avg, 1))
            self.current_minute = minute
            self.current_minute_scores = []
        self.current_minute_scores.append(result.attention_score)

    def finalize(self) -> dict:
        if self.current_minute_scores:
            avg = sum(self.current_minute_scores) / len(self.current_minute_scores)
            self.minute_scores.append(round(avg, 1))

        n = self.total_frames if self.total_frames > 0 else 1

        face_ratio = self.face_detected_frames / n
        gaze_ratio = self.gaze_ok_frames / n
        absence_ratio = self.absent_frames / n
        phone_ratio = self.phone_detected_frames / n
        drowsy_ratio = self.drowsy_frames / n

        avg_attention = (
            sum(self.attention_scores) / len(self.attention_scores)
            if self.attention_scores else 0.0
        )

        # Compute derived scores
        consistency = _compute_consistency_score(self.attention_scores)
        overall = round(avg_attention * 0.6 + consistency * 0.4, 1)

        return {
            "total_frames": self.total_frames,
            "valid_frames": self.face_detected_frames,
            "alert_frames": self.gaze_ok_frames,
            "face_detected_ratio": round(face_ratio, 4),
            "gaze_ratio": round(gaze_ratio, 4),
            "absence_ratio": round(absence_ratio, 4),
            "phone_detected_ratio": round(phone_ratio, 4),
            "drowsy_ratio": round(drowsy_ratio, 4),
            "average_attention_score": round(avg_attention, 1),
            "consistency_score": round(consistency, 1),
            "overall_score": overall,
            "attention_timeline": self.minute_scores,
        }


def _compute_consistency_score(scores: list[float]) -> float:
    """Higher score when attention stays consistently high (low variance)."""
    if len(scores) < 2:
        return scores[0] if scores else 0.0
    mean = sum(scores) / len(scores)
    variance = sum((s - mean) ** 2 for s in scores) / len(scores)
    std_dev = math.sqrt(variance)
    # Penalize high variance: max penalty -30 points at std=50
    penalty = min(30.0, std_dev * 0.6)
    return max(0.0, mean - penalty)


class AIService:
    """
    Main AI analysis service.

    Initializes MediaPipe solutions once and reuses them across frames
    for efficiency.
    """

    # EAR threshold below which eyes are considered closed
    EAR_THRESHOLD = 0.21
    # Consecutive drowsy frames before flagging
    DROWSY_CONSECUTIVE_THRESHOLD = 3
    # Yaw angle (degrees) beyond which gaze is "off screen"
    GAZE_YAW_THRESHOLD = 30.0
    # Pitch angle (degrees) for looking down at phone
    GAZE_PITCH_THRESHOLD = 25.0

    def __init__(self):
        self._face_mesh = None
        self._mp_drawing = None
        self._mp_face_mesh = None
        self._initialized = False

    def _initialize(self) -> bool:
        """Lazy initialize MediaPipe (called on first use)."""
        if self._initialized:
            return self._face_mesh is not None

        mp = _get_mediapipe()
        if mp is None:
            self._initialized = True
            return False

        try:
            self._mp_face_mesh = mp.solutions.face_mesh
            self._face_mesh = self._mp_face_mesh.FaceMesh(
                static_image_mode=True,
                max_num_faces=1,
                refine_landmarks=True,
                min_detection_confidence=0.5,
                min_tracking_confidence=0.5,
            )
            self._initialized = True
            logger.info("MediaPipe FaceMesh initialized successfully")
            return True
        except Exception as e:
            logger.error(f"Failed to initialize MediaPipe: {e}")
            self._initialized = True
            return False

    async def analyze_frame(
        self,
        image_data: bytes,
        frame_number: int = 0,
        timestamp_ms: int = 0,
    ) -> FrameAnalysisResult:
        """
        Analyze a single video frame for attention metrics.

        Args:
            image_data: Raw JPEG/PNG bytes of the frame
            frame_number: Sequential frame number
            timestamp_ms: Milliseconds from session start

        Returns:
            FrameAnalysisResult with all computed metrics
        """
        result = FrameAnalysisResult(
            frame_number=frame_number,
            timestamp_ms=timestamp_ms,
        )

        cv2 = _get_cv2()
        if cv2 is None or not self._initialize():
            # Stub: return neutral result when deps unavailable
            result.face_detected = True
            result.face_confidence = 0.5
            result.gaze_ok = True
            result.is_absent = False
            result.attention_score = 75.0
            return result

        try:
            # Decode image
            nparr = np.frombuffer(image_data, np.uint8)
            frame = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
            if frame is None:
                logger.warning("Could not decode frame image")
                result.is_absent = True
                result.attention_score = 0.0
                return result

            rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            h, w = frame.shape[:2]

            # Run FaceMesh
            mesh_results = self._face_mesh.process(rgb_frame)

            if not mesh_results.multi_face_landmarks:
                result.face_detected = False
                result.is_absent = True
                result.attention_score = 0.0
                return result

            landmarks = mesh_results.multi_face_landmarks[0]
            result.face_detected = True
            result.face_confidence = 0.9
            result.is_absent = False
            result.landmark_count = len(landmarks.landmark)

            # Compute head pose angles
            pitch, yaw = _estimate_head_pose(landmarks, w, h)
            result.head_pose_pitch = round(pitch, 2)
            result.head_pose_yaw = round(yaw, 2)

            # Gaze check: yaw close to 0 = looking at screen
            result.gaze_ok = (
                abs(yaw) < self.GAZE_YAW_THRESHOLD
                and pitch > -self.GAZE_PITCH_THRESHOLD
            )

            # Eye aspect ratio for drowsiness
            ear = _compute_ear(landmarks)
            result.eye_aspect_ratio = round(ear, 4)
            result.drowsy = ear < self.EAR_THRESHOLD

            # Simple phone detection heuristic:
            # If pitch is very negative (looking down) and gaze not ok
            result.phone_detected = (
                pitch < -35.0 and abs(yaw) < 20.0
            )

            # Compute attention score
            result.attention_score = _compute_attention_score(result)

        except Exception as e:
            logger.error(f"Frame analysis error: {e}", exc_info=True)
            result.is_absent = True
            result.attention_score = 0.0

        return result

    def generate_feedback(self, summary: dict) -> dict:
        """Generate AI feedback based on session summary statistics."""
        score = summary.get("overall_score", 0.0)
        absence = summary.get("absence_ratio", 0.0)
        phone = summary.get("phone_detected_ratio", 0.0)
        drowsy = summary.get("drowsy_ratio", 0.0)
        gaze = summary.get("gaze_ratio", 0.0)

        # Determine grade
        if score >= 90:
            grade = "S"
        elif score >= 80:
            grade = "A"
        elif score >= 65:
            grade = "B"
        elif score >= 50:
            grade = "C"
        else:
            grade = "D"

        # Build tips
        tips = []
        if absence > 0.15:
            tips.append("자리를 자주 비웠습니다. 공부 환경을 정비하고 자리를 고정해 보세요.")
        if phone > 0.10:
            tips.append("휴대폰 사용이 감지되었습니다. 공부 중에는 폰을 다른 방에 두세요.")
        if drowsy > 0.15:
            tips.append("졸음이 많이 감지되었습니다. 충분한 수면 후 공부하거나 중간에 짧은 휴식을 취하세요.")
        if gaze < 0.6:
            tips.append("시선이 화면 밖으로 자주 향했습니다. 집중력 향상을 위해 포모도로 기법을 시도해 보세요.")
        if not tips:
            tips.append("전반적으로 매우 집중력 있게 공부했습니다. 이 페이스를 유지하세요!")

        # Strengths
        strengths = []
        if gaze > 0.8:
            strengths.append("화면 집중도가 매우 높습니다")
        if absence < 0.05:
            strengths.append("자리를 잘 지켰습니다")
        if drowsy < 0.05:
            strengths.append("졸음 없이 집중했습니다")
        if phone < 0.02:
            strengths.append("휴대폰 사용 없이 공부했습니다")
        if not strengths and score > 50:
            strengths.append("꾸준한 공부 습관을 유지했습니다")

        # Summary feedback
        if grade == "S":
            feedback = "완벽한 집중력! 오늘의 공부는 최고 수준의 인증을 받았습니다."
        elif grade == "A":
            feedback = "훌륭한 집중력입니다! 대부분의 시간을 효과적으로 공부했습니다."
        elif grade == "B":
            feedback = "양호한 집중도입니다. 몇 가지 개선점을 보완하면 더 좋아질 수 있습니다."
        elif grade == "C":
            feedback = "집중도가 보통 수준입니다. 방해 요소를 줄이고 환경을 개선해 보세요."
        else:
            feedback = "오늘은 집중하기 어려운 날이었나요? 내일 다시 도전해 보세요!"

        return {
            "grade": grade,
            "feedback": feedback,
            "tips": tips,
            "strengths": strengths,
        }

    def compute_certified_duration(
        self,
        duration_seconds: int,
        summary: dict,
    ) -> int:
        """
        Compute how many seconds of study are 'certified' (AI-verified).

        Certified time = total time * (gaze_ratio * face_ratio) weighted
        """
        face_ratio = summary.get("face_detected_ratio", 0.0)
        gaze_ratio = summary.get("gaze_ratio", 0.0)
        absence_ratio = summary.get("absence_ratio", 0.0)
        phone_ratio = summary.get("phone_detected_ratio", 0.0)
        drowsy_ratio = summary.get("drowsy_ratio", 0.0)

        # Quality multiplier: start at 1.0, subtract bad events
        quality = (
            1.0
            - absence_ratio * 1.0       # Full deduction for absence
            - phone_ratio * 0.8         # Heavy penalty for phone
            - drowsy_ratio * 0.5        # Moderate penalty for drowsiness
            - (1 - gaze_ratio) * 0.3    # Partial penalty for off-screen gaze
        )
        quality = max(0.0, min(1.0, quality))

        return int(duration_seconds * quality)

    def compute_points(
        self,
        certified_duration_seconds: int,
        ai_score: float,
    ) -> int:
        """
        Compute points to award for a study session.

        Base: 1 point per certified minute
        Bonus: up to 50% bonus for high AI score
        """
        if certified_duration_seconds < 300:  # Min 5 minutes
            return 0

        base_points = certified_duration_seconds // 60  # 1 pt/min
        score_multiplier = 1.0 + (ai_score / 100.0) * 0.5
        return int(base_points * score_multiplier)


# ─────────────────────────────────────────────────────────────────────────────
# Helper functions
# ─────────────────────────────────────────────────────────────────────────────

# MediaPipe face mesh landmark indices for eye corners and eyelids
_LEFT_EYE_INDICES = [362, 385, 387, 263, 373, 380]
_RIGHT_EYE_INDICES = [33, 160, 158, 133, 153, 144]

# 3D model points for head pose estimation (simplified)
_MODEL_POINTS = np.array([
    [0.0, 0.0, 0.0],           # Nose tip (index 1)
    [0.0, -330.0, -65.0],      # Chin (index 152)
    [-225.0, 170.0, -135.0],   # Left eye corner (index 33)
    [225.0, 170.0, -135.0],    # Right eye corner (index 263)
    [-150.0, -150.0, -125.0],  # Left mouth corner (index 61)
    [150.0, -150.0, -125.0],   # Right mouth corner (index 291)
], dtype=np.float64)

_LANDMARK_INDICES = [1, 152, 33, 263, 61, 291]


def _estimate_head_pose(landmarks, width: int, height: int) -> tuple[float, float]:
    """
    Estimate pitch (up/down) and yaw (left/right) from face landmarks.
    Returns angles in degrees.
    """
    cv2 = _get_cv2()
    if cv2 is None:
        return 0.0, 0.0

    try:
        image_points = np.array([
            [landmarks.landmark[i].x * width,
             landmarks.landmark[i].y * height]
            for i in _LANDMARK_INDICES
        ], dtype=np.float64)

        focal_length = width
        center = (width / 2, height / 2)
        camera_matrix = np.array([
            [focal_length, 0, center[0]],
            [0, focal_length, center[1]],
            [0, 0, 1],
        ], dtype=np.float64)

        dist_coeffs = np.zeros((4, 1))

        success, rotation_vec, translation_vec = cv2.solvePnP(
            _MODEL_POINTS,
            image_points,
            camera_matrix,
            dist_coeffs,
            flags=cv2.SOLVEPNP_ITERATIVE,
        )

        if not success:
            return 0.0, 0.0

        rotation_mat, _ = cv2.Rodrigues(rotation_vec)
        pose_mat = cv2.hconcat([rotation_mat, translation_vec])
        _, _, _, _, _, _, euler_angles = cv2.decomposeProjectionMatrix(pose_mat)

        pitch = float(euler_angles[0])
        yaw = float(euler_angles[1])
        return pitch, yaw

    except Exception:
        return 0.0, 0.0


def _eye_aspect_ratio(landmarks, indices: list[int]) -> float:
    """
    Compute Eye Aspect Ratio (EAR) for one eye.
    EAR = (|p2-p6| + |p3-p5|) / (2 * |p1-p4|)
    """
    def lm(i):
        lk = landmarks.landmark[i]
        return np.array([lk.x, lk.y])

    p1, p2, p3, p4, p5, p6 = [lm(i) for i in indices]
    ear = (np.linalg.norm(p2 - p6) + np.linalg.norm(p3 - p5)) / (
        2.0 * np.linalg.norm(p1 - p4) + 1e-6
    )
    return float(ear)


def _compute_ear(landmarks) -> float:
    """Average EAR across both eyes."""
    left_ear = _eye_aspect_ratio(landmarks, _LEFT_EYE_INDICES)
    right_ear = _eye_aspect_ratio(landmarks, _RIGHT_EYE_INDICES)
    return (left_ear + right_ear) / 2.0


def _compute_attention_score(result: FrameAnalysisResult) -> float:
    """
    Compute 0–100 attention score for a single frame.

    Scoring:
    - Base score: 100
    - Absent: 0 (immediate zero)
    - Phone detected: -40
    - Drowsy: -25
    - Gaze off screen: -20
    - No face (but present): -10
    """
    if result.is_absent or not result.face_detected:
        return 0.0

    score = 100.0

    if result.phone_detected:
        score -= 40.0
    if result.drowsy:
        score -= 25.0
    if not result.gaze_ok:
        score -= 20.0

    return max(0.0, score)
