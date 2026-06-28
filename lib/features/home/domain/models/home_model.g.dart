// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HomeDataImpl _$$HomeDataImplFromJson(Map<String, dynamic> json) =>
    _$HomeDataImpl(
      userNickname: json['userNickname'] as String,
      todayStudyHours: (json['todayStudyHours'] as num).toDouble(),
      targetHours: (json['targetHours'] as num).toDouble(),
      streakDays: (json['streakDays'] as num).toInt(),
      bestStreak: (json['bestStreak'] as num).toInt(),
      points: (json['points'] as num).toInt(),
      focusScore: (json['focusScore'] as num).toDouble(),
      recentSessions: (json['recentSessions'] as num).toInt(),
      isStudying: json['isStudying'] as bool,
    );

Map<String, dynamic> _$$HomeDataImplToJson(_$HomeDataImpl instance) =>
    <String, dynamic>{
      'userNickname': instance.userNickname,
      'todayStudyHours': instance.todayStudyHours,
      'targetHours': instance.targetHours,
      'streakDays': instance.streakDays,
      'bestStreak': instance.bestStreak,
      'points': instance.points,
      'focusScore': instance.focusScore,
      'recentSessions': instance.recentSessions,
      'isStudying': instance.isStudying,
    };

_$StudySessionImpl _$$StudySessionImplFromJson(Map<String, dynamic> json) =>
    _$StudySessionImpl(
      id: json['id'] as String,
      subject: json['subject'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      durationHours: (json['durationHours'] as num?)?.toDouble() ?? 0.0,
      focusScore: (json['focusScore'] as num?)?.toDouble() ?? 0.0,
      isAiVerified: json['isAiVerified'] as bool? ?? false,
    );

Map<String, dynamic> _$$StudySessionImplToJson(_$StudySessionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'subject': instance.subject,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'durationHours': instance.durationHours,
      'focusScore': instance.focusScore,
      'isAiVerified': instance.isAiVerified,
    };
