// coverage:ignore-file
// ignore_for_file: type=lint

import 'package:freezed_annotation/freezed_annotation.dart';

part 'study_session_model.freezed.dart';
part 'study_session_model.g.dart';

/// Current status of a study session.
enum StudySessionStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('active')
  active,
  @JsonValue('paused')
  paused,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}

extension StudySessionStatusX on StudySessionStatus {
  bool get isActive => this == StudySessionStatus.active;
  bool get isPaused => this == StudySessionStatus.paused;
  bool get isCompleted => this == StudySessionStatus.completed;
  bool get isOngoing =>
      this == StudySessionStatus.active ||
      this == StudySessionStatus.paused;

  String get displayName => switch (this) {
        StudySessionStatus.pending => '대기 중',
        StudySessionStatus.active => '공부 중',
        StudySessionStatus.paused => '일시정지',
        StudySessionStatus.completed => '완료',
        StudySessionStatus.cancelled => '취소됨',
      };
}

/// Study subject categories.
enum StudySubject {
  @JsonValue('math')
  math,
  @JsonValue('science')
  science,
  @JsonValue('english')
  english,
  @JsonValue('history')
  history,
  @JsonValue('korean')
  korean,
  @JsonValue('social')
  social,
  @JsonValue('art')
  art,
  @JsonValue('music')
  music,
  @JsonValue('pe')
  pe,
  @JsonValue('coding')
  coding,
  @JsonValue('other')
  other,
}

extension StudySubjectX on StudySubject {
  String get displayName => switch (this) {
        StudySubject.math => '수학',
        StudySubject.science => '과학',
        StudySubject.english => '영어',
        StudySubject.history => '역사',
        StudySubject.korean => '국어',
        StudySubject.social => '사회',
        StudySubject.art => '미술',
        StudySubject.music => '음악',
        StudySubject.pe => '체육',
        StudySubject.coding => '코딩',
        StudySubject.other => '기타',
      };

  String get emoji => switch (this) {
        StudySubject.math => '📐',
        StudySubject.science => '🔬',
        StudySubject.english => '📖',
        StudySubject.history => '🏛',
        StudySubject.korean => '✍️',
        StudySubject.social => '🌏',
        StudySubject.art => '🎨',
        StudySubject.music => '🎵',
        StudySubject.pe => '⚽',
        StudySubject.coding => '💻',
        StudySubject.other => '📚',
      };
}

/// Study mode used during the session.
enum StudyMode {
  @JsonValue('free')
  free,
  @JsonValue('pomodoro')
  pomodoro,
  @JsonValue('deep_focus')
  deepFocus,
  @JsonValue('exam')
  exam,
}

extension StudyModeX on StudyMode {
  String get displayName => switch (this) {
        StudyMode.free => '자유 공부',
        StudyMode.pomodoro => '뽀모도로',
        StudyMode.deepFocus => '딥 포커스',
        StudyMode.exam => '시험 모드',
      };
}

/// A single study session record.
@freezed
class StudySessionModel with _$StudySessionModel {
  const factory StudySessionModel({
    required String id,
    required String userId,
    required StudySubject subject,
    required StudySessionStatus status,
    @Default(StudyMode.free) StudyMode mode,
    DateTime? startedAt,
    DateTime? endedAt,
    DateTime? pausedAt,
    @Default(0) int totalDurationSeconds,
    @Default(0) int pureStudySeconds,
    @Default(0) int pausedSeconds,
    @Default(0) int breakCount,
    @Default(0) int focusScore,
    @Default(0) int pointsEarned,
    String? certificationPhotoUrl,
    String? notes,
    String? goalDescription,
    @Default(0) int goalMinutes,
    @Default(false) bool aiMonitoringEnabled,
    @Default([]) List<StudyBreakRecord> breaks,
    @Default([]) List<String> tagIds,
    StudyAnalytics? analytics,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _StudySessionModel;

  factory StudySessionModel.fromJson(Map<String, dynamic> json) =>
      _$StudySessionModelFromJson(json);
}

/// A pause / break interval within a session.
@freezed
class StudyBreakRecord with _$StudyBreakRecord {
  const factory StudyBreakRecord({
    required DateTime startedAt,
    DateTime? endedAt,
    @Default(0) int durationSeconds,
    String? reason,
  }) = _StudyBreakRecord;

  factory StudyBreakRecord.fromJson(Map<String, dynamic> json) =>
      _$StudyBreakRecordFromJson(json);
}

/// AI-generated analytics for a completed session.
@freezed
class StudyAnalytics with _$StudyAnalytics {
  const factory StudyAnalytics({
    @Default(0) int avgFocusScore,
    @Default(0) int peakFocusScore,
    @Default([]) List<FocusDataPoint> focusTimeline,
    String? aiSummary,
    String? improvementTip,
    @Default([]) List<String> detectedActivities,
  }) = _StudyAnalytics;

  factory StudyAnalytics.fromJson(Map<String, dynamic> json) =>
      _$StudyAnalyticsFromJson(json);
}

/// A single focus score measurement at a point in time.
@freezed
class FocusDataPoint with _$FocusDataPoint {
  const factory FocusDataPoint({
    required DateTime timestamp,
    required int score,
    String? label,
  }) = _FocusDataPoint;

  factory FocusDataPoint.fromJson(Map<String, dynamic> json) =>
      _$FocusDataPointFromJson(json);
}

/// Request body to start a new study session.
@freezed
class StartSessionRequest with _$StartSessionRequest {
  const factory StartSessionRequest({
    required StudySubject subject,
    @Default(StudyMode.free) StudyMode mode,
    @Default(0) int goalMinutes,
    @Default(true) bool aiMonitoringEnabled,
    String? goalDescription,
    List<String>? tagIds,
  }) = _StartSessionRequest;

  factory StartSessionRequest.fromJson(Map<String, dynamic> json) =>
      _$StartSessionRequestFromJson(json);
}

/// Request body to end / complete a session.
@freezed
class EndSessionRequest with _$EndSessionRequest {
  const factory EndSessionRequest({
    String? notes,
    String? certificationPhotoUrl,
  }) = _EndSessionRequest;

  factory EndSessionRequest.fromJson(Map<String, dynamic> json) =>
      _$EndSessionRequestFromJson(json);
}

/// Daily aggregated study statistics.
@freezed
class DailyStudyStats with _$DailyStudyStats {
  const factory DailyStudyStats({
    required DateTime date,
    @Default(0) int totalMinutes,
    @Default(0) int pureMinutes,
    @Default(0) int sessionCount,
    @Default(0) int pointsEarned,
    @Default(0) int avgFocusScore,
    @Default({}) Map<String, int> minutesBySubject,
  }) = _DailyStudyStats;

  factory DailyStudyStats.fromJson(Map<String, dynamic> json) =>
      _$DailyStudyStatsFromJson(json);
}
