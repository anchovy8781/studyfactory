// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StudySessionModelImpl _$$StudySessionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$StudySessionModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      subject: $enumDecode(_$StudySubjectEnumMap, json['subject']),
      status: $enumDecode(_$StudySessionStatusEnumMap, json['status']),
      mode: $enumDecodeNullable(_$StudyModeEnumMap, json['mode']) ??
          StudyMode.free,
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
      pausedAt: json['pausedAt'] == null
          ? null
          : DateTime.parse(json['pausedAt'] as String),
      totalDurationSeconds:
          (json['totalDurationSeconds'] as num?)?.toInt() ?? 0,
      pureStudySeconds: (json['pureStudySeconds'] as num?)?.toInt() ?? 0,
      pausedSeconds: (json['pausedSeconds'] as num?)?.toInt() ?? 0,
      breakCount: (json['breakCount'] as num?)?.toInt() ?? 0,
      focusScore: (json['focusScore'] as num?)?.toInt() ?? 0,
      pointsEarned: (json['pointsEarned'] as num?)?.toInt() ?? 0,
      certificationPhotoUrl: json['certificationPhotoUrl'] as String?,
      notes: json['notes'] as String?,
      goalDescription: json['goalDescription'] as String?,
      goalMinutes: (json['goalMinutes'] as num?)?.toInt() ?? 0,
      aiMonitoringEnabled: json['aiMonitoringEnabled'] as bool? ?? false,
      breaks: (json['breaks'] as List<dynamic>?)
              ?.map((e) => StudyBreakRecord.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      tagIds: (json['tagIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      analytics: json['analytics'] == null
          ? null
          : StudyAnalytics.fromJson(json['analytics'] as Map<String, dynamic>),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$StudySessionModelImplToJson(
        _$StudySessionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'subject': _$StudySubjectEnumMap[instance.subject]!,
      'status': _$StudySessionStatusEnumMap[instance.status]!,
      'mode': _$StudyModeEnumMap[instance.mode]!,
      'startedAt': instance.startedAt?.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'pausedAt': instance.pausedAt?.toIso8601String(),
      'totalDurationSeconds': instance.totalDurationSeconds,
      'pureStudySeconds': instance.pureStudySeconds,
      'pausedSeconds': instance.pausedSeconds,
      'breakCount': instance.breakCount,
      'focusScore': instance.focusScore,
      'pointsEarned': instance.pointsEarned,
      'certificationPhotoUrl': instance.certificationPhotoUrl,
      'notes': instance.notes,
      'goalDescription': instance.goalDescription,
      'goalMinutes': instance.goalMinutes,
      'aiMonitoringEnabled': instance.aiMonitoringEnabled,
      'breaks': instance.breaks,
      'tagIds': instance.tagIds,
      'analytics': instance.analytics,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$StudySubjectEnumMap = {
  StudySubject.math: 'math',
  StudySubject.science: 'science',
  StudySubject.english: 'english',
  StudySubject.history: 'history',
  StudySubject.korean: 'korean',
  StudySubject.social: 'social',
  StudySubject.art: 'art',
  StudySubject.music: 'music',
  StudySubject.pe: 'pe',
  StudySubject.coding: 'coding',
  StudySubject.other: 'other',
};

const _$StudySessionStatusEnumMap = {
  StudySessionStatus.pending: 'pending',
  StudySessionStatus.active: 'active',
  StudySessionStatus.paused: 'paused',
  StudySessionStatus.completed: 'completed',
  StudySessionStatus.cancelled: 'cancelled',
};

const _$StudyModeEnumMap = {
  StudyMode.free: 'free',
  StudyMode.pomodoro: 'pomodoro',
  StudyMode.deepFocus: 'deep_focus',
  StudyMode.exam: 'exam',
};

_$StudyBreakRecordImpl _$$StudyBreakRecordImplFromJson(
        Map<String, dynamic> json) =>
    _$StudyBreakRecordImpl(
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      reason: json['reason'] as String?,
    );

Map<String, dynamic> _$$StudyBreakRecordImplToJson(
        _$StudyBreakRecordImpl instance) =>
    <String, dynamic>{
      'startedAt': instance.startedAt.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'durationSeconds': instance.durationSeconds,
      'reason': instance.reason,
    };

_$StudyAnalyticsImpl _$$StudyAnalyticsImplFromJson(Map<String, dynamic> json) =>
    _$StudyAnalyticsImpl(
      avgFocusScore: (json['avgFocusScore'] as num?)?.toInt() ?? 0,
      peakFocusScore: (json['peakFocusScore'] as num?)?.toInt() ?? 0,
      focusTimeline: (json['focusTimeline'] as List<dynamic>?)
              ?.map((e) => FocusDataPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      aiSummary: json['aiSummary'] as String?,
      improvementTip: json['improvementTip'] as String?,
      detectedActivities: (json['detectedActivities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$StudyAnalyticsImplToJson(
        _$StudyAnalyticsImpl instance) =>
    <String, dynamic>{
      'avgFocusScore': instance.avgFocusScore,
      'peakFocusScore': instance.peakFocusScore,
      'focusTimeline': instance.focusTimeline,
      'aiSummary': instance.aiSummary,
      'improvementTip': instance.improvementTip,
      'detectedActivities': instance.detectedActivities,
    };

_$FocusDataPointImpl _$$FocusDataPointImplFromJson(Map<String, dynamic> json) =>
    _$FocusDataPointImpl(
      timestamp: DateTime.parse(json['timestamp'] as String),
      score: (json['score'] as num).toInt(),
      label: json['label'] as String?,
    );

Map<String, dynamic> _$$FocusDataPointImplToJson(
        _$FocusDataPointImpl instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'score': instance.score,
      'label': instance.label,
    };

_$StartSessionRequestImpl _$$StartSessionRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$StartSessionRequestImpl(
      subject: $enumDecode(_$StudySubjectEnumMap, json['subject']),
      mode: $enumDecodeNullable(_$StudyModeEnumMap, json['mode']) ??
          StudyMode.free,
      goalMinutes: (json['goalMinutes'] as num?)?.toInt() ?? 0,
      aiMonitoringEnabled: json['aiMonitoringEnabled'] as bool? ?? true,
      goalDescription: json['goalDescription'] as String?,
      tagIds:
          (json['tagIds'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$StartSessionRequestImplToJson(
        _$StartSessionRequestImpl instance) =>
    <String, dynamic>{
      'subject': _$StudySubjectEnumMap[instance.subject]!,
      'mode': _$StudyModeEnumMap[instance.mode]!,
      'goalMinutes': instance.goalMinutes,
      'aiMonitoringEnabled': instance.aiMonitoringEnabled,
      'goalDescription': instance.goalDescription,
      'tagIds': instance.tagIds,
    };

_$EndSessionRequestImpl _$$EndSessionRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$EndSessionRequestImpl(
      notes: json['notes'] as String?,
      certificationPhotoUrl: json['certificationPhotoUrl'] as String?,
    );

Map<String, dynamic> _$$EndSessionRequestImplToJson(
        _$EndSessionRequestImpl instance) =>
    <String, dynamic>{
      'notes': instance.notes,
      'certificationPhotoUrl': instance.certificationPhotoUrl,
    };

_$DailyStudyStatsImpl _$$DailyStudyStatsImplFromJson(
        Map<String, dynamic> json) =>
    _$DailyStudyStatsImpl(
      date: DateTime.parse(json['date'] as String),
      totalMinutes: (json['totalMinutes'] as num?)?.toInt() ?? 0,
      pureMinutes: (json['pureMinutes'] as num?)?.toInt() ?? 0,
      sessionCount: (json['sessionCount'] as num?)?.toInt() ?? 0,
      pointsEarned: (json['pointsEarned'] as num?)?.toInt() ?? 0,
      avgFocusScore: (json['avgFocusScore'] as num?)?.toInt() ?? 0,
      minutesBySubject:
          (json['minutesBySubject'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, (e as num).toInt()),
              ) ??
              const {},
    );

Map<String, dynamic> _$$DailyStudyStatsImplToJson(
        _$DailyStudyStatsImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'totalMinutes': instance.totalMinutes,
      'pureMinutes': instance.pureMinutes,
      'sessionCount': instance.sessionCount,
      'pointsEarned': instance.pointsEarned,
      'avgFocusScore': instance.avgFocusScore,
      'minutesBySubject': instance.minutesBySubject,
    };
