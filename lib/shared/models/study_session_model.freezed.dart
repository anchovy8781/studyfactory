// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'study_session_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StudySessionModel _$StudySessionModelFromJson(Map<String, dynamic> json) {
  return _StudySessionModel.fromJson(json);
}

/// @nodoc
mixin _$StudySessionModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  StudySubject get subject => throw _privateConstructorUsedError;
  StudySessionStatus get status => throw _privateConstructorUsedError;
  StudyMode get mode => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get endedAt => throw _privateConstructorUsedError;
  DateTime? get pausedAt => throw _privateConstructorUsedError;
  int get totalDurationSeconds => throw _privateConstructorUsedError;
  int get pureStudySeconds => throw _privateConstructorUsedError;
  int get pausedSeconds => throw _privateConstructorUsedError;
  int get breakCount => throw _privateConstructorUsedError;
  int get focusScore => throw _privateConstructorUsedError;
  int get pointsEarned => throw _privateConstructorUsedError;
  String? get certificationPhotoUrl => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get goalDescription => throw _privateConstructorUsedError;
  int get goalMinutes => throw _privateConstructorUsedError;
  bool get aiMonitoringEnabled => throw _privateConstructorUsedError;
  List<StudyBreakRecord> get breaks => throw _privateConstructorUsedError;
  List<String> get tagIds => throw _privateConstructorUsedError;
  StudyAnalytics? get analytics => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this StudySessionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StudySessionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudySessionModelCopyWith<StudySessionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudySessionModelCopyWith<$Res> {
  factory $StudySessionModelCopyWith(
          StudySessionModel value, $Res Function(StudySessionModel) then) =
      _$StudySessionModelCopyWithImpl<$Res, StudySessionModel>;
  @useResult
  $Res call(
      {String id,
      String userId,
      StudySubject subject,
      StudySessionStatus status,
      StudyMode mode,
      DateTime? startedAt,
      DateTime? endedAt,
      DateTime? pausedAt,
      int totalDurationSeconds,
      int pureStudySeconds,
      int pausedSeconds,
      int breakCount,
      int focusScore,
      int pointsEarned,
      String? certificationPhotoUrl,
      String? notes,
      String? goalDescription,
      int goalMinutes,
      bool aiMonitoringEnabled,
      List<StudyBreakRecord> breaks,
      List<String> tagIds,
      StudyAnalytics? analytics,
      DateTime? createdAt,
      DateTime? updatedAt});

  $StudyAnalyticsCopyWith<$Res>? get analytics;
}

/// @nodoc
class _$StudySessionModelCopyWithImpl<$Res, $Val extends StudySessionModel>
    implements $StudySessionModelCopyWith<$Res> {
  _$StudySessionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudySessionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? subject = null,
    Object? status = null,
    Object? mode = null,
    Object? startedAt = freezed,
    Object? endedAt = freezed,
    Object? pausedAt = freezed,
    Object? totalDurationSeconds = null,
    Object? pureStudySeconds = null,
    Object? pausedSeconds = null,
    Object? breakCount = null,
    Object? focusScore = null,
    Object? pointsEarned = null,
    Object? certificationPhotoUrl = freezed,
    Object? notes = freezed,
    Object? goalDescription = freezed,
    Object? goalMinutes = null,
    Object? aiMonitoringEnabled = null,
    Object? breaks = null,
    Object? tagIds = null,
    Object? analytics = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as StudySubject,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as StudySessionStatus,
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as StudyMode,
      startedAt: freezed == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endedAt: freezed == endedAt
          ? _value.endedAt
          : endedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      pausedAt: freezed == pausedAt
          ? _value.pausedAt
          : pausedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalDurationSeconds: null == totalDurationSeconds
          ? _value.totalDurationSeconds
          : totalDurationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      pureStudySeconds: null == pureStudySeconds
          ? _value.pureStudySeconds
          : pureStudySeconds // ignore: cast_nullable_to_non_nullable
              as int,
      pausedSeconds: null == pausedSeconds
          ? _value.pausedSeconds
          : pausedSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      breakCount: null == breakCount
          ? _value.breakCount
          : breakCount // ignore: cast_nullable_to_non_nullable
              as int,
      focusScore: null == focusScore
          ? _value.focusScore
          : focusScore // ignore: cast_nullable_to_non_nullable
              as int,
      pointsEarned: null == pointsEarned
          ? _value.pointsEarned
          : pointsEarned // ignore: cast_nullable_to_non_nullable
              as int,
      certificationPhotoUrl: freezed == certificationPhotoUrl
          ? _value.certificationPhotoUrl
          : certificationPhotoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      goalDescription: freezed == goalDescription
          ? _value.goalDescription
          : goalDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      goalMinutes: null == goalMinutes
          ? _value.goalMinutes
          : goalMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      aiMonitoringEnabled: null == aiMonitoringEnabled
          ? _value.aiMonitoringEnabled
          : aiMonitoringEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      breaks: null == breaks
          ? _value.breaks
          : breaks // ignore: cast_nullable_to_non_nullable
              as List<StudyBreakRecord>,
      tagIds: null == tagIds
          ? _value.tagIds
          : tagIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      analytics: freezed == analytics
          ? _value.analytics
          : analytics // ignore: cast_nullable_to_non_nullable
              as StudyAnalytics?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of StudySessionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StudyAnalyticsCopyWith<$Res>? get analytics {
    if (_value.analytics == null) {
      return null;
    }

    return $StudyAnalyticsCopyWith<$Res>(_value.analytics!, (value) {
      return _then(_value.copyWith(analytics: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$StudySessionModelImplCopyWith<$Res>
    implements $StudySessionModelCopyWith<$Res> {
  factory _$$StudySessionModelImplCopyWith(_$StudySessionModelImpl value,
          $Res Function(_$StudySessionModelImpl) then) =
      __$$StudySessionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      StudySubject subject,
      StudySessionStatus status,
      StudyMode mode,
      DateTime? startedAt,
      DateTime? endedAt,
      DateTime? pausedAt,
      int totalDurationSeconds,
      int pureStudySeconds,
      int pausedSeconds,
      int breakCount,
      int focusScore,
      int pointsEarned,
      String? certificationPhotoUrl,
      String? notes,
      String? goalDescription,
      int goalMinutes,
      bool aiMonitoringEnabled,
      List<StudyBreakRecord> breaks,
      List<String> tagIds,
      StudyAnalytics? analytics,
      DateTime? createdAt,
      DateTime? updatedAt});

  @override
  $StudyAnalyticsCopyWith<$Res>? get analytics;
}

/// @nodoc
class __$$StudySessionModelImplCopyWithImpl<$Res>
    extends _$StudySessionModelCopyWithImpl<$Res, _$StudySessionModelImpl>
    implements _$$StudySessionModelImplCopyWith<$Res> {
  __$$StudySessionModelImplCopyWithImpl(_$StudySessionModelImpl _value,
      $Res Function(_$StudySessionModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of StudySessionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? subject = null,
    Object? status = null,
    Object? mode = null,
    Object? startedAt = freezed,
    Object? endedAt = freezed,
    Object? pausedAt = freezed,
    Object? totalDurationSeconds = null,
    Object? pureStudySeconds = null,
    Object? pausedSeconds = null,
    Object? breakCount = null,
    Object? focusScore = null,
    Object? pointsEarned = null,
    Object? certificationPhotoUrl = freezed,
    Object? notes = freezed,
    Object? goalDescription = freezed,
    Object? goalMinutes = null,
    Object? aiMonitoringEnabled = null,
    Object? breaks = null,
    Object? tagIds = null,
    Object? analytics = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$StudySessionModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as StudySubject,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as StudySessionStatus,
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as StudyMode,
      startedAt: freezed == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endedAt: freezed == endedAt
          ? _value.endedAt
          : endedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      pausedAt: freezed == pausedAt
          ? _value.pausedAt
          : pausedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalDurationSeconds: null == totalDurationSeconds
          ? _value.totalDurationSeconds
          : totalDurationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      pureStudySeconds: null == pureStudySeconds
          ? _value.pureStudySeconds
          : pureStudySeconds // ignore: cast_nullable_to_non_nullable
              as int,
      pausedSeconds: null == pausedSeconds
          ? _value.pausedSeconds
          : pausedSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      breakCount: null == breakCount
          ? _value.breakCount
          : breakCount // ignore: cast_nullable_to_non_nullable
              as int,
      focusScore: null == focusScore
          ? _value.focusScore
          : focusScore // ignore: cast_nullable_to_non_nullable
              as int,
      pointsEarned: null == pointsEarned
          ? _value.pointsEarned
          : pointsEarned // ignore: cast_nullable_to_non_nullable
              as int,
      certificationPhotoUrl: freezed == certificationPhotoUrl
          ? _value.certificationPhotoUrl
          : certificationPhotoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      goalDescription: freezed == goalDescription
          ? _value.goalDescription
          : goalDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      goalMinutes: null == goalMinutes
          ? _value.goalMinutes
          : goalMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      aiMonitoringEnabled: null == aiMonitoringEnabled
          ? _value.aiMonitoringEnabled
          : aiMonitoringEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      breaks: null == breaks
          ? _value._breaks
          : breaks // ignore: cast_nullable_to_non_nullable
              as List<StudyBreakRecord>,
      tagIds: null == tagIds
          ? _value._tagIds
          : tagIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      analytics: freezed == analytics
          ? _value.analytics
          : analytics // ignore: cast_nullable_to_non_nullable
              as StudyAnalytics?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StudySessionModelImpl implements _StudySessionModel {
  const _$StudySessionModelImpl(
      {required this.id,
      required this.userId,
      required this.subject,
      required this.status,
      this.mode = StudyMode.free,
      this.startedAt,
      this.endedAt,
      this.pausedAt,
      this.totalDurationSeconds = 0,
      this.pureStudySeconds = 0,
      this.pausedSeconds = 0,
      this.breakCount = 0,
      this.focusScore = 0,
      this.pointsEarned = 0,
      this.certificationPhotoUrl,
      this.notes,
      this.goalDescription,
      this.goalMinutes = 0,
      this.aiMonitoringEnabled = false,
      final List<StudyBreakRecord> breaks = const [],
      final List<String> tagIds = const [],
      this.analytics,
      this.createdAt,
      this.updatedAt})
      : _breaks = breaks,
        _tagIds = tagIds;

  factory _$StudySessionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudySessionModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final StudySubject subject;
  @override
  final StudySessionStatus status;
  @override
  @JsonKey()
  final StudyMode mode;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? endedAt;
  @override
  final DateTime? pausedAt;
  @override
  @JsonKey()
  final int totalDurationSeconds;
  @override
  @JsonKey()
  final int pureStudySeconds;
  @override
  @JsonKey()
  final int pausedSeconds;
  @override
  @JsonKey()
  final int breakCount;
  @override
  @JsonKey()
  final int focusScore;
  @override
  @JsonKey()
  final int pointsEarned;
  @override
  final String? certificationPhotoUrl;
  @override
  final String? notes;
  @override
  final String? goalDescription;
  @override
  @JsonKey()
  final int goalMinutes;
  @override
  @JsonKey()
  final bool aiMonitoringEnabled;
  final List<StudyBreakRecord> _breaks;
  @override
  @JsonKey()
  List<StudyBreakRecord> get breaks {
    if (_breaks is EqualUnmodifiableListView) return _breaks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_breaks);
  }

  final List<String> _tagIds;
  @override
  @JsonKey()
  List<String> get tagIds {
    if (_tagIds is EqualUnmodifiableListView) return _tagIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tagIds);
  }

  @override
  final StudyAnalytics? analytics;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'StudySessionModel(id: $id, userId: $userId, subject: $subject, status: $status, mode: $mode, startedAt: $startedAt, endedAt: $endedAt, pausedAt: $pausedAt, totalDurationSeconds: $totalDurationSeconds, pureStudySeconds: $pureStudySeconds, pausedSeconds: $pausedSeconds, breakCount: $breakCount, focusScore: $focusScore, pointsEarned: $pointsEarned, certificationPhotoUrl: $certificationPhotoUrl, notes: $notes, goalDescription: $goalDescription, goalMinutes: $goalMinutes, aiMonitoringEnabled: $aiMonitoringEnabled, breaks: $breaks, tagIds: $tagIds, analytics: $analytics, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudySessionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.endedAt, endedAt) || other.endedAt == endedAt) &&
            (identical(other.pausedAt, pausedAt) ||
                other.pausedAt == pausedAt) &&
            (identical(other.totalDurationSeconds, totalDurationSeconds) ||
                other.totalDurationSeconds == totalDurationSeconds) &&
            (identical(other.pureStudySeconds, pureStudySeconds) ||
                other.pureStudySeconds == pureStudySeconds) &&
            (identical(other.pausedSeconds, pausedSeconds) ||
                other.pausedSeconds == pausedSeconds) &&
            (identical(other.breakCount, breakCount) ||
                other.breakCount == breakCount) &&
            (identical(other.focusScore, focusScore) ||
                other.focusScore == focusScore) &&
            (identical(other.pointsEarned, pointsEarned) ||
                other.pointsEarned == pointsEarned) &&
            (identical(other.certificationPhotoUrl, certificationPhotoUrl) ||
                other.certificationPhotoUrl == certificationPhotoUrl) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.goalDescription, goalDescription) ||
                other.goalDescription == goalDescription) &&
            (identical(other.goalMinutes, goalMinutes) ||
                other.goalMinutes == goalMinutes) &&
            (identical(other.aiMonitoringEnabled, aiMonitoringEnabled) ||
                other.aiMonitoringEnabled == aiMonitoringEnabled) &&
            const DeepCollectionEquality().equals(other._breaks, _breaks) &&
            const DeepCollectionEquality().equals(other._tagIds, _tagIds) &&
            (identical(other.analytics, analytics) ||
                other.analytics == analytics) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        userId,
        subject,
        status,
        mode,
        startedAt,
        endedAt,
        pausedAt,
        totalDurationSeconds,
        pureStudySeconds,
        pausedSeconds,
        breakCount,
        focusScore,
        pointsEarned,
        certificationPhotoUrl,
        notes,
        goalDescription,
        goalMinutes,
        aiMonitoringEnabled,
        const DeepCollectionEquality().hash(_breaks),
        const DeepCollectionEquality().hash(_tagIds),
        analytics,
        createdAt,
        updatedAt
      ]);

  /// Create a copy of StudySessionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudySessionModelImplCopyWith<_$StudySessionModelImpl> get copyWith =>
      __$$StudySessionModelImplCopyWithImpl<_$StudySessionModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StudySessionModelImplToJson(
      this,
    );
  }
}

abstract class _StudySessionModel implements StudySessionModel {
  const factory _StudySessionModel(
      {required final String id,
      required final String userId,
      required final StudySubject subject,
      required final StudySessionStatus status,
      final StudyMode mode,
      final DateTime? startedAt,
      final DateTime? endedAt,
      final DateTime? pausedAt,
      final int totalDurationSeconds,
      final int pureStudySeconds,
      final int pausedSeconds,
      final int breakCount,
      final int focusScore,
      final int pointsEarned,
      final String? certificationPhotoUrl,
      final String? notes,
      final String? goalDescription,
      final int goalMinutes,
      final bool aiMonitoringEnabled,
      final List<StudyBreakRecord> breaks,
      final List<String> tagIds,
      final StudyAnalytics? analytics,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$StudySessionModelImpl;

  factory _StudySessionModel.fromJson(Map<String, dynamic> json) =
      _$StudySessionModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  StudySubject get subject;
  @override
  StudySessionStatus get status;
  @override
  StudyMode get mode;
  @override
  DateTime? get startedAt;
  @override
  DateTime? get endedAt;
  @override
  DateTime? get pausedAt;
  @override
  int get totalDurationSeconds;
  @override
  int get pureStudySeconds;
  @override
  int get pausedSeconds;
  @override
  int get breakCount;
  @override
  int get focusScore;
  @override
  int get pointsEarned;
  @override
  String? get certificationPhotoUrl;
  @override
  String? get notes;
  @override
  String? get goalDescription;
  @override
  int get goalMinutes;
  @override
  bool get aiMonitoringEnabled;
  @override
  List<StudyBreakRecord> get breaks;
  @override
  List<String> get tagIds;
  @override
  StudyAnalytics? get analytics;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of StudySessionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudySessionModelImplCopyWith<_$StudySessionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StudyBreakRecord _$StudyBreakRecordFromJson(Map<String, dynamic> json) {
  return _StudyBreakRecord.fromJson(json);
}

/// @nodoc
mixin _$StudyBreakRecord {
  DateTime get startedAt => throw _privateConstructorUsedError;
  DateTime? get endedAt => throw _privateConstructorUsedError;
  int get durationSeconds => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;

  /// Serializes this StudyBreakRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StudyBreakRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudyBreakRecordCopyWith<StudyBreakRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudyBreakRecordCopyWith<$Res> {
  factory $StudyBreakRecordCopyWith(
          StudyBreakRecord value, $Res Function(StudyBreakRecord) then) =
      _$StudyBreakRecordCopyWithImpl<$Res, StudyBreakRecord>;
  @useResult
  $Res call(
      {DateTime startedAt,
      DateTime? endedAt,
      int durationSeconds,
      String? reason});
}

/// @nodoc
class _$StudyBreakRecordCopyWithImpl<$Res, $Val extends StudyBreakRecord>
    implements $StudyBreakRecordCopyWith<$Res> {
  _$StudyBreakRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudyBreakRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startedAt = null,
    Object? endedAt = freezed,
    Object? durationSeconds = null,
    Object? reason = freezed,
  }) {
    return _then(_value.copyWith(
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endedAt: freezed == endedAt
          ? _value.endedAt
          : endedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      durationSeconds: null == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StudyBreakRecordImplCopyWith<$Res>
    implements $StudyBreakRecordCopyWith<$Res> {
  factory _$$StudyBreakRecordImplCopyWith(_$StudyBreakRecordImpl value,
          $Res Function(_$StudyBreakRecordImpl) then) =
      __$$StudyBreakRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime startedAt,
      DateTime? endedAt,
      int durationSeconds,
      String? reason});
}

/// @nodoc
class __$$StudyBreakRecordImplCopyWithImpl<$Res>
    extends _$StudyBreakRecordCopyWithImpl<$Res, _$StudyBreakRecordImpl>
    implements _$$StudyBreakRecordImplCopyWith<$Res> {
  __$$StudyBreakRecordImplCopyWithImpl(_$StudyBreakRecordImpl _value,
      $Res Function(_$StudyBreakRecordImpl) _then)
      : super(_value, _then);

  /// Create a copy of StudyBreakRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startedAt = null,
    Object? endedAt = freezed,
    Object? durationSeconds = null,
    Object? reason = freezed,
  }) {
    return _then(_$StudyBreakRecordImpl(
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endedAt: freezed == endedAt
          ? _value.endedAt
          : endedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      durationSeconds: null == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StudyBreakRecordImpl implements _StudyBreakRecord {
  const _$StudyBreakRecordImpl(
      {required this.startedAt,
      this.endedAt,
      this.durationSeconds = 0,
      this.reason});

  factory _$StudyBreakRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudyBreakRecordImplFromJson(json);

  @override
  final DateTime startedAt;
  @override
  final DateTime? endedAt;
  @override
  @JsonKey()
  final int durationSeconds;
  @override
  final String? reason;

  @override
  String toString() {
    return 'StudyBreakRecord(startedAt: $startedAt, endedAt: $endedAt, durationSeconds: $durationSeconds, reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudyBreakRecordImpl &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.endedAt, endedAt) || other.endedAt == endedAt) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, startedAt, endedAt, durationSeconds, reason);

  /// Create a copy of StudyBreakRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudyBreakRecordImplCopyWith<_$StudyBreakRecordImpl> get copyWith =>
      __$$StudyBreakRecordImplCopyWithImpl<_$StudyBreakRecordImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StudyBreakRecordImplToJson(
      this,
    );
  }
}

abstract class _StudyBreakRecord implements StudyBreakRecord {
  const factory _StudyBreakRecord(
      {required final DateTime startedAt,
      final DateTime? endedAt,
      final int durationSeconds,
      final String? reason}) = _$StudyBreakRecordImpl;

  factory _StudyBreakRecord.fromJson(Map<String, dynamic> json) =
      _$StudyBreakRecordImpl.fromJson;

  @override
  DateTime get startedAt;
  @override
  DateTime? get endedAt;
  @override
  int get durationSeconds;
  @override
  String? get reason;

  /// Create a copy of StudyBreakRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudyBreakRecordImplCopyWith<_$StudyBreakRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StudyAnalytics _$StudyAnalyticsFromJson(Map<String, dynamic> json) {
  return _StudyAnalytics.fromJson(json);
}

/// @nodoc
mixin _$StudyAnalytics {
  int get avgFocusScore => throw _privateConstructorUsedError;
  int get peakFocusScore => throw _privateConstructorUsedError;
  List<FocusDataPoint> get focusTimeline => throw _privateConstructorUsedError;
  String? get aiSummary => throw _privateConstructorUsedError;
  String? get improvementTip => throw _privateConstructorUsedError;
  List<String> get detectedActivities => throw _privateConstructorUsedError;

  /// Serializes this StudyAnalytics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StudyAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudyAnalyticsCopyWith<StudyAnalytics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudyAnalyticsCopyWith<$Res> {
  factory $StudyAnalyticsCopyWith(
          StudyAnalytics value, $Res Function(StudyAnalytics) then) =
      _$StudyAnalyticsCopyWithImpl<$Res, StudyAnalytics>;
  @useResult
  $Res call(
      {int avgFocusScore,
      int peakFocusScore,
      List<FocusDataPoint> focusTimeline,
      String? aiSummary,
      String? improvementTip,
      List<String> detectedActivities});
}

/// @nodoc
class _$StudyAnalyticsCopyWithImpl<$Res, $Val extends StudyAnalytics>
    implements $StudyAnalyticsCopyWith<$Res> {
  _$StudyAnalyticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudyAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? avgFocusScore = null,
    Object? peakFocusScore = null,
    Object? focusTimeline = null,
    Object? aiSummary = freezed,
    Object? improvementTip = freezed,
    Object? detectedActivities = null,
  }) {
    return _then(_value.copyWith(
      avgFocusScore: null == avgFocusScore
          ? _value.avgFocusScore
          : avgFocusScore // ignore: cast_nullable_to_non_nullable
              as int,
      peakFocusScore: null == peakFocusScore
          ? _value.peakFocusScore
          : peakFocusScore // ignore: cast_nullable_to_non_nullable
              as int,
      focusTimeline: null == focusTimeline
          ? _value.focusTimeline
          : focusTimeline // ignore: cast_nullable_to_non_nullable
              as List<FocusDataPoint>,
      aiSummary: freezed == aiSummary
          ? _value.aiSummary
          : aiSummary // ignore: cast_nullable_to_non_nullable
              as String?,
      improvementTip: freezed == improvementTip
          ? _value.improvementTip
          : improvementTip // ignore: cast_nullable_to_non_nullable
              as String?,
      detectedActivities: null == detectedActivities
          ? _value.detectedActivities
          : detectedActivities // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StudyAnalyticsImplCopyWith<$Res>
    implements $StudyAnalyticsCopyWith<$Res> {
  factory _$$StudyAnalyticsImplCopyWith(_$StudyAnalyticsImpl value,
          $Res Function(_$StudyAnalyticsImpl) then) =
      __$$StudyAnalyticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int avgFocusScore,
      int peakFocusScore,
      List<FocusDataPoint> focusTimeline,
      String? aiSummary,
      String? improvementTip,
      List<String> detectedActivities});
}

/// @nodoc
class __$$StudyAnalyticsImplCopyWithImpl<$Res>
    extends _$StudyAnalyticsCopyWithImpl<$Res, _$StudyAnalyticsImpl>
    implements _$$StudyAnalyticsImplCopyWith<$Res> {
  __$$StudyAnalyticsImplCopyWithImpl(
      _$StudyAnalyticsImpl _value, $Res Function(_$StudyAnalyticsImpl) _then)
      : super(_value, _then);

  /// Create a copy of StudyAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? avgFocusScore = null,
    Object? peakFocusScore = null,
    Object? focusTimeline = null,
    Object? aiSummary = freezed,
    Object? improvementTip = freezed,
    Object? detectedActivities = null,
  }) {
    return _then(_$StudyAnalyticsImpl(
      avgFocusScore: null == avgFocusScore
          ? _value.avgFocusScore
          : avgFocusScore // ignore: cast_nullable_to_non_nullable
              as int,
      peakFocusScore: null == peakFocusScore
          ? _value.peakFocusScore
          : peakFocusScore // ignore: cast_nullable_to_non_nullable
              as int,
      focusTimeline: null == focusTimeline
          ? _value._focusTimeline
          : focusTimeline // ignore: cast_nullable_to_non_nullable
              as List<FocusDataPoint>,
      aiSummary: freezed == aiSummary
          ? _value.aiSummary
          : aiSummary // ignore: cast_nullable_to_non_nullable
              as String?,
      improvementTip: freezed == improvementTip
          ? _value.improvementTip
          : improvementTip // ignore: cast_nullable_to_non_nullable
              as String?,
      detectedActivities: null == detectedActivities
          ? _value._detectedActivities
          : detectedActivities // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StudyAnalyticsImpl implements _StudyAnalytics {
  const _$StudyAnalyticsImpl(
      {this.avgFocusScore = 0,
      this.peakFocusScore = 0,
      final List<FocusDataPoint> focusTimeline = const [],
      this.aiSummary,
      this.improvementTip,
      final List<String> detectedActivities = const []})
      : _focusTimeline = focusTimeline,
        _detectedActivities = detectedActivities;

  factory _$StudyAnalyticsImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudyAnalyticsImplFromJson(json);

  @override
  @JsonKey()
  final int avgFocusScore;
  @override
  @JsonKey()
  final int peakFocusScore;
  final List<FocusDataPoint> _focusTimeline;
  @override
  @JsonKey()
  List<FocusDataPoint> get focusTimeline {
    if (_focusTimeline is EqualUnmodifiableListView) return _focusTimeline;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_focusTimeline);
  }

  @override
  final String? aiSummary;
  @override
  final String? improvementTip;
  final List<String> _detectedActivities;
  @override
  @JsonKey()
  List<String> get detectedActivities {
    if (_detectedActivities is EqualUnmodifiableListView)
      return _detectedActivities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_detectedActivities);
  }

  @override
  String toString() {
    return 'StudyAnalytics(avgFocusScore: $avgFocusScore, peakFocusScore: $peakFocusScore, focusTimeline: $focusTimeline, aiSummary: $aiSummary, improvementTip: $improvementTip, detectedActivities: $detectedActivities)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudyAnalyticsImpl &&
            (identical(other.avgFocusScore, avgFocusScore) ||
                other.avgFocusScore == avgFocusScore) &&
            (identical(other.peakFocusScore, peakFocusScore) ||
                other.peakFocusScore == peakFocusScore) &&
            const DeepCollectionEquality()
                .equals(other._focusTimeline, _focusTimeline) &&
            (identical(other.aiSummary, aiSummary) ||
                other.aiSummary == aiSummary) &&
            (identical(other.improvementTip, improvementTip) ||
                other.improvementTip == improvementTip) &&
            const DeepCollectionEquality()
                .equals(other._detectedActivities, _detectedActivities));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      avgFocusScore,
      peakFocusScore,
      const DeepCollectionEquality().hash(_focusTimeline),
      aiSummary,
      improvementTip,
      const DeepCollectionEquality().hash(_detectedActivities));

  /// Create a copy of StudyAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudyAnalyticsImplCopyWith<_$StudyAnalyticsImpl> get copyWith =>
      __$$StudyAnalyticsImplCopyWithImpl<_$StudyAnalyticsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StudyAnalyticsImplToJson(
      this,
    );
  }
}

abstract class _StudyAnalytics implements StudyAnalytics {
  const factory _StudyAnalytics(
      {final int avgFocusScore,
      final int peakFocusScore,
      final List<FocusDataPoint> focusTimeline,
      final String? aiSummary,
      final String? improvementTip,
      final List<String> detectedActivities}) = _$StudyAnalyticsImpl;

  factory _StudyAnalytics.fromJson(Map<String, dynamic> json) =
      _$StudyAnalyticsImpl.fromJson;

  @override
  int get avgFocusScore;
  @override
  int get peakFocusScore;
  @override
  List<FocusDataPoint> get focusTimeline;
  @override
  String? get aiSummary;
  @override
  String? get improvementTip;
  @override
  List<String> get detectedActivities;

  /// Create a copy of StudyAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudyAnalyticsImplCopyWith<_$StudyAnalyticsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FocusDataPoint _$FocusDataPointFromJson(Map<String, dynamic> json) {
  return _FocusDataPoint.fromJson(json);
}

/// @nodoc
mixin _$FocusDataPoint {
  DateTime get timestamp => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError;
  String? get label => throw _privateConstructorUsedError;

  /// Serializes this FocusDataPoint to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FocusDataPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FocusDataPointCopyWith<FocusDataPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FocusDataPointCopyWith<$Res> {
  factory $FocusDataPointCopyWith(
          FocusDataPoint value, $Res Function(FocusDataPoint) then) =
      _$FocusDataPointCopyWithImpl<$Res, FocusDataPoint>;
  @useResult
  $Res call({DateTime timestamp, int score, String? label});
}

/// @nodoc
class _$FocusDataPointCopyWithImpl<$Res, $Val extends FocusDataPoint>
    implements $FocusDataPointCopyWith<$Res> {
  _$FocusDataPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FocusDataPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? score = null,
    Object? label = freezed,
  }) {
    return _then(_value.copyWith(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      label: freezed == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FocusDataPointImplCopyWith<$Res>
    implements $FocusDataPointCopyWith<$Res> {
  factory _$$FocusDataPointImplCopyWith(_$FocusDataPointImpl value,
          $Res Function(_$FocusDataPointImpl) then) =
      __$$FocusDataPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime timestamp, int score, String? label});
}

/// @nodoc
class __$$FocusDataPointImplCopyWithImpl<$Res>
    extends _$FocusDataPointCopyWithImpl<$Res, _$FocusDataPointImpl>
    implements _$$FocusDataPointImplCopyWith<$Res> {
  __$$FocusDataPointImplCopyWithImpl(
      _$FocusDataPointImpl _value, $Res Function(_$FocusDataPointImpl) _then)
      : super(_value, _then);

  /// Create a copy of FocusDataPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? score = null,
    Object? label = freezed,
  }) {
    return _then(_$FocusDataPointImpl(
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      label: freezed == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FocusDataPointImpl implements _FocusDataPoint {
  const _$FocusDataPointImpl(
      {required this.timestamp, required this.score, this.label});

  factory _$FocusDataPointImpl.fromJson(Map<String, dynamic> json) =>
      _$$FocusDataPointImplFromJson(json);

  @override
  final DateTime timestamp;
  @override
  final int score;
  @override
  final String? label;

  @override
  String toString() {
    return 'FocusDataPoint(timestamp: $timestamp, score: $score, label: $label)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FocusDataPointImpl &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.label, label) || other.label == label));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, timestamp, score, label);

  /// Create a copy of FocusDataPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FocusDataPointImplCopyWith<_$FocusDataPointImpl> get copyWith =>
      __$$FocusDataPointImplCopyWithImpl<_$FocusDataPointImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FocusDataPointImplToJson(
      this,
    );
  }
}

abstract class _FocusDataPoint implements FocusDataPoint {
  const factory _FocusDataPoint(
      {required final DateTime timestamp,
      required final int score,
      final String? label}) = _$FocusDataPointImpl;

  factory _FocusDataPoint.fromJson(Map<String, dynamic> json) =
      _$FocusDataPointImpl.fromJson;

  @override
  DateTime get timestamp;
  @override
  int get score;
  @override
  String? get label;

  /// Create a copy of FocusDataPoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FocusDataPointImplCopyWith<_$FocusDataPointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StartSessionRequest _$StartSessionRequestFromJson(Map<String, dynamic> json) {
  return _StartSessionRequest.fromJson(json);
}

/// @nodoc
mixin _$StartSessionRequest {
  StudySubject get subject => throw _privateConstructorUsedError;
  StudyMode get mode => throw _privateConstructorUsedError;
  int get goalMinutes => throw _privateConstructorUsedError;
  bool get aiMonitoringEnabled => throw _privateConstructorUsedError;
  String? get goalDescription => throw _privateConstructorUsedError;
  List<String>? get tagIds => throw _privateConstructorUsedError;

  /// Serializes this StartSessionRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StartSessionRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StartSessionRequestCopyWith<StartSessionRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StartSessionRequestCopyWith<$Res> {
  factory $StartSessionRequestCopyWith(
          StartSessionRequest value, $Res Function(StartSessionRequest) then) =
      _$StartSessionRequestCopyWithImpl<$Res, StartSessionRequest>;
  @useResult
  $Res call(
      {StudySubject subject,
      StudyMode mode,
      int goalMinutes,
      bool aiMonitoringEnabled,
      String? goalDescription,
      List<String>? tagIds});
}

/// @nodoc
class _$StartSessionRequestCopyWithImpl<$Res, $Val extends StartSessionRequest>
    implements $StartSessionRequestCopyWith<$Res> {
  _$StartSessionRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StartSessionRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subject = null,
    Object? mode = null,
    Object? goalMinutes = null,
    Object? aiMonitoringEnabled = null,
    Object? goalDescription = freezed,
    Object? tagIds = freezed,
  }) {
    return _then(_value.copyWith(
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as StudySubject,
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as StudyMode,
      goalMinutes: null == goalMinutes
          ? _value.goalMinutes
          : goalMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      aiMonitoringEnabled: null == aiMonitoringEnabled
          ? _value.aiMonitoringEnabled
          : aiMonitoringEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      goalDescription: freezed == goalDescription
          ? _value.goalDescription
          : goalDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      tagIds: freezed == tagIds
          ? _value.tagIds
          : tagIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StartSessionRequestImplCopyWith<$Res>
    implements $StartSessionRequestCopyWith<$Res> {
  factory _$$StartSessionRequestImplCopyWith(_$StartSessionRequestImpl value,
          $Res Function(_$StartSessionRequestImpl) then) =
      __$$StartSessionRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {StudySubject subject,
      StudyMode mode,
      int goalMinutes,
      bool aiMonitoringEnabled,
      String? goalDescription,
      List<String>? tagIds});
}

/// @nodoc
class __$$StartSessionRequestImplCopyWithImpl<$Res>
    extends _$StartSessionRequestCopyWithImpl<$Res, _$StartSessionRequestImpl>
    implements _$$StartSessionRequestImplCopyWith<$Res> {
  __$$StartSessionRequestImplCopyWithImpl(_$StartSessionRequestImpl _value,
      $Res Function(_$StartSessionRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of StartSessionRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subject = null,
    Object? mode = null,
    Object? goalMinutes = null,
    Object? aiMonitoringEnabled = null,
    Object? goalDescription = freezed,
    Object? tagIds = freezed,
  }) {
    return _then(_$StartSessionRequestImpl(
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as StudySubject,
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as StudyMode,
      goalMinutes: null == goalMinutes
          ? _value.goalMinutes
          : goalMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      aiMonitoringEnabled: null == aiMonitoringEnabled
          ? _value.aiMonitoringEnabled
          : aiMonitoringEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      goalDescription: freezed == goalDescription
          ? _value.goalDescription
          : goalDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      tagIds: freezed == tagIds
          ? _value._tagIds
          : tagIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StartSessionRequestImpl implements _StartSessionRequest {
  const _$StartSessionRequestImpl(
      {required this.subject,
      this.mode = StudyMode.free,
      this.goalMinutes = 0,
      this.aiMonitoringEnabled = true,
      this.goalDescription,
      final List<String>? tagIds})
      : _tagIds = tagIds;

  factory _$StartSessionRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$StartSessionRequestImplFromJson(json);

  @override
  final StudySubject subject;
  @override
  @JsonKey()
  final StudyMode mode;
  @override
  @JsonKey()
  final int goalMinutes;
  @override
  @JsonKey()
  final bool aiMonitoringEnabled;
  @override
  final String? goalDescription;
  final List<String>? _tagIds;
  @override
  List<String>? get tagIds {
    final value = _tagIds;
    if (value == null) return null;
    if (_tagIds is EqualUnmodifiableListView) return _tagIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'StartSessionRequest(subject: $subject, mode: $mode, goalMinutes: $goalMinutes, aiMonitoringEnabled: $aiMonitoringEnabled, goalDescription: $goalDescription, tagIds: $tagIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StartSessionRequestImpl &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.goalMinutes, goalMinutes) ||
                other.goalMinutes == goalMinutes) &&
            (identical(other.aiMonitoringEnabled, aiMonitoringEnabled) ||
                other.aiMonitoringEnabled == aiMonitoringEnabled) &&
            (identical(other.goalDescription, goalDescription) ||
                other.goalDescription == goalDescription) &&
            const DeepCollectionEquality().equals(other._tagIds, _tagIds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      subject,
      mode,
      goalMinutes,
      aiMonitoringEnabled,
      goalDescription,
      const DeepCollectionEquality().hash(_tagIds));

  /// Create a copy of StartSessionRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StartSessionRequestImplCopyWith<_$StartSessionRequestImpl> get copyWith =>
      __$$StartSessionRequestImplCopyWithImpl<_$StartSessionRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StartSessionRequestImplToJson(
      this,
    );
  }
}

abstract class _StartSessionRequest implements StartSessionRequest {
  const factory _StartSessionRequest(
      {required final StudySubject subject,
      final StudyMode mode,
      final int goalMinutes,
      final bool aiMonitoringEnabled,
      final String? goalDescription,
      final List<String>? tagIds}) = _$StartSessionRequestImpl;

  factory _StartSessionRequest.fromJson(Map<String, dynamic> json) =
      _$StartSessionRequestImpl.fromJson;

  @override
  StudySubject get subject;
  @override
  StudyMode get mode;
  @override
  int get goalMinutes;
  @override
  bool get aiMonitoringEnabled;
  @override
  String? get goalDescription;
  @override
  List<String>? get tagIds;

  /// Create a copy of StartSessionRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StartSessionRequestImplCopyWith<_$StartSessionRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EndSessionRequest _$EndSessionRequestFromJson(Map<String, dynamic> json) {
  return _EndSessionRequest.fromJson(json);
}

/// @nodoc
mixin _$EndSessionRequest {
  String? get notes => throw _privateConstructorUsedError;
  String? get certificationPhotoUrl => throw _privateConstructorUsedError;

  /// Serializes this EndSessionRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EndSessionRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EndSessionRequestCopyWith<EndSessionRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EndSessionRequestCopyWith<$Res> {
  factory $EndSessionRequestCopyWith(
          EndSessionRequest value, $Res Function(EndSessionRequest) then) =
      _$EndSessionRequestCopyWithImpl<$Res, EndSessionRequest>;
  @useResult
  $Res call({String? notes, String? certificationPhotoUrl});
}

/// @nodoc
class _$EndSessionRequestCopyWithImpl<$Res, $Val extends EndSessionRequest>
    implements $EndSessionRequestCopyWith<$Res> {
  _$EndSessionRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EndSessionRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notes = freezed,
    Object? certificationPhotoUrl = freezed,
  }) {
    return _then(_value.copyWith(
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      certificationPhotoUrl: freezed == certificationPhotoUrl
          ? _value.certificationPhotoUrl
          : certificationPhotoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EndSessionRequestImplCopyWith<$Res>
    implements $EndSessionRequestCopyWith<$Res> {
  factory _$$EndSessionRequestImplCopyWith(_$EndSessionRequestImpl value,
          $Res Function(_$EndSessionRequestImpl) then) =
      __$$EndSessionRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? notes, String? certificationPhotoUrl});
}

/// @nodoc
class __$$EndSessionRequestImplCopyWithImpl<$Res>
    extends _$EndSessionRequestCopyWithImpl<$Res, _$EndSessionRequestImpl>
    implements _$$EndSessionRequestImplCopyWith<$Res> {
  __$$EndSessionRequestImplCopyWithImpl(_$EndSessionRequestImpl _value,
      $Res Function(_$EndSessionRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of EndSessionRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notes = freezed,
    Object? certificationPhotoUrl = freezed,
  }) {
    return _then(_$EndSessionRequestImpl(
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      certificationPhotoUrl: freezed == certificationPhotoUrl
          ? _value.certificationPhotoUrl
          : certificationPhotoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EndSessionRequestImpl implements _EndSessionRequest {
  const _$EndSessionRequestImpl({this.notes, this.certificationPhotoUrl});

  factory _$EndSessionRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$EndSessionRequestImplFromJson(json);

  @override
  final String? notes;
  @override
  final String? certificationPhotoUrl;

  @override
  String toString() {
    return 'EndSessionRequest(notes: $notes, certificationPhotoUrl: $certificationPhotoUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EndSessionRequestImpl &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.certificationPhotoUrl, certificationPhotoUrl) ||
                other.certificationPhotoUrl == certificationPhotoUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, notes, certificationPhotoUrl);

  /// Create a copy of EndSessionRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EndSessionRequestImplCopyWith<_$EndSessionRequestImpl> get copyWith =>
      __$$EndSessionRequestImplCopyWithImpl<_$EndSessionRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EndSessionRequestImplToJson(
      this,
    );
  }
}

abstract class _EndSessionRequest implements EndSessionRequest {
  const factory _EndSessionRequest(
      {final String? notes,
      final String? certificationPhotoUrl}) = _$EndSessionRequestImpl;

  factory _EndSessionRequest.fromJson(Map<String, dynamic> json) =
      _$EndSessionRequestImpl.fromJson;

  @override
  String? get notes;
  @override
  String? get certificationPhotoUrl;

  /// Create a copy of EndSessionRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EndSessionRequestImplCopyWith<_$EndSessionRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DailyStudyStats _$DailyStudyStatsFromJson(Map<String, dynamic> json) {
  return _DailyStudyStats.fromJson(json);
}

/// @nodoc
mixin _$DailyStudyStats {
  DateTime get date => throw _privateConstructorUsedError;
  int get totalMinutes => throw _privateConstructorUsedError;
  int get pureMinutes => throw _privateConstructorUsedError;
  int get sessionCount => throw _privateConstructorUsedError;
  int get pointsEarned => throw _privateConstructorUsedError;
  int get avgFocusScore => throw _privateConstructorUsedError;
  Map<String, int> get minutesBySubject => throw _privateConstructorUsedError;

  /// Serializes this DailyStudyStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyStudyStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyStudyStatsCopyWith<DailyStudyStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyStudyStatsCopyWith<$Res> {
  factory $DailyStudyStatsCopyWith(
          DailyStudyStats value, $Res Function(DailyStudyStats) then) =
      _$DailyStudyStatsCopyWithImpl<$Res, DailyStudyStats>;
  @useResult
  $Res call(
      {DateTime date,
      int totalMinutes,
      int pureMinutes,
      int sessionCount,
      int pointsEarned,
      int avgFocusScore,
      Map<String, int> minutesBySubject});
}

/// @nodoc
class _$DailyStudyStatsCopyWithImpl<$Res, $Val extends DailyStudyStats>
    implements $DailyStudyStatsCopyWith<$Res> {
  _$DailyStudyStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyStudyStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? totalMinutes = null,
    Object? pureMinutes = null,
    Object? sessionCount = null,
    Object? pointsEarned = null,
    Object? avgFocusScore = null,
    Object? minutesBySubject = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalMinutes: null == totalMinutes
          ? _value.totalMinutes
          : totalMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      pureMinutes: null == pureMinutes
          ? _value.pureMinutes
          : pureMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      sessionCount: null == sessionCount
          ? _value.sessionCount
          : sessionCount // ignore: cast_nullable_to_non_nullable
              as int,
      pointsEarned: null == pointsEarned
          ? _value.pointsEarned
          : pointsEarned // ignore: cast_nullable_to_non_nullable
              as int,
      avgFocusScore: null == avgFocusScore
          ? _value.avgFocusScore
          : avgFocusScore // ignore: cast_nullable_to_non_nullable
              as int,
      minutesBySubject: null == minutesBySubject
          ? _value.minutesBySubject
          : minutesBySubject // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DailyStudyStatsImplCopyWith<$Res>
    implements $DailyStudyStatsCopyWith<$Res> {
  factory _$$DailyStudyStatsImplCopyWith(_$DailyStudyStatsImpl value,
          $Res Function(_$DailyStudyStatsImpl) then) =
      __$$DailyStudyStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime date,
      int totalMinutes,
      int pureMinutes,
      int sessionCount,
      int pointsEarned,
      int avgFocusScore,
      Map<String, int> minutesBySubject});
}

/// @nodoc
class __$$DailyStudyStatsImplCopyWithImpl<$Res>
    extends _$DailyStudyStatsCopyWithImpl<$Res, _$DailyStudyStatsImpl>
    implements _$$DailyStudyStatsImplCopyWith<$Res> {
  __$$DailyStudyStatsImplCopyWithImpl(
      _$DailyStudyStatsImpl _value, $Res Function(_$DailyStudyStatsImpl) _then)
      : super(_value, _then);

  /// Create a copy of DailyStudyStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? totalMinutes = null,
    Object? pureMinutes = null,
    Object? sessionCount = null,
    Object? pointsEarned = null,
    Object? avgFocusScore = null,
    Object? minutesBySubject = null,
  }) {
    return _then(_$DailyStudyStatsImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalMinutes: null == totalMinutes
          ? _value.totalMinutes
          : totalMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      pureMinutes: null == pureMinutes
          ? _value.pureMinutes
          : pureMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      sessionCount: null == sessionCount
          ? _value.sessionCount
          : sessionCount // ignore: cast_nullable_to_non_nullable
              as int,
      pointsEarned: null == pointsEarned
          ? _value.pointsEarned
          : pointsEarned // ignore: cast_nullable_to_non_nullable
              as int,
      avgFocusScore: null == avgFocusScore
          ? _value.avgFocusScore
          : avgFocusScore // ignore: cast_nullable_to_non_nullable
              as int,
      minutesBySubject: null == minutesBySubject
          ? _value._minutesBySubject
          : minutesBySubject // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyStudyStatsImpl implements _DailyStudyStats {
  const _$DailyStudyStatsImpl(
      {required this.date,
      this.totalMinutes = 0,
      this.pureMinutes = 0,
      this.sessionCount = 0,
      this.pointsEarned = 0,
      this.avgFocusScore = 0,
      final Map<String, int> minutesBySubject = const {}})
      : _minutesBySubject = minutesBySubject;

  factory _$DailyStudyStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyStudyStatsImplFromJson(json);

  @override
  final DateTime date;
  @override
  @JsonKey()
  final int totalMinutes;
  @override
  @JsonKey()
  final int pureMinutes;
  @override
  @JsonKey()
  final int sessionCount;
  @override
  @JsonKey()
  final int pointsEarned;
  @override
  @JsonKey()
  final int avgFocusScore;
  final Map<String, int> _minutesBySubject;
  @override
  @JsonKey()
  Map<String, int> get minutesBySubject {
    if (_minutesBySubject is EqualUnmodifiableMapView) return _minutesBySubject;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_minutesBySubject);
  }

  @override
  String toString() {
    return 'DailyStudyStats(date: $date, totalMinutes: $totalMinutes, pureMinutes: $pureMinutes, sessionCount: $sessionCount, pointsEarned: $pointsEarned, avgFocusScore: $avgFocusScore, minutesBySubject: $minutesBySubject)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyStudyStatsImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.totalMinutes, totalMinutes) ||
                other.totalMinutes == totalMinutes) &&
            (identical(other.pureMinutes, pureMinutes) ||
                other.pureMinutes == pureMinutes) &&
            (identical(other.sessionCount, sessionCount) ||
                other.sessionCount == sessionCount) &&
            (identical(other.pointsEarned, pointsEarned) ||
                other.pointsEarned == pointsEarned) &&
            (identical(other.avgFocusScore, avgFocusScore) ||
                other.avgFocusScore == avgFocusScore) &&
            const DeepCollectionEquality()
                .equals(other._minutesBySubject, _minutesBySubject));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      date,
      totalMinutes,
      pureMinutes,
      sessionCount,
      pointsEarned,
      avgFocusScore,
      const DeepCollectionEquality().hash(_minutesBySubject));

  /// Create a copy of DailyStudyStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyStudyStatsImplCopyWith<_$DailyStudyStatsImpl> get copyWith =>
      __$$DailyStudyStatsImplCopyWithImpl<_$DailyStudyStatsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyStudyStatsImplToJson(
      this,
    );
  }
}

abstract class _DailyStudyStats implements DailyStudyStats {
  const factory _DailyStudyStats(
      {required final DateTime date,
      final int totalMinutes,
      final int pureMinutes,
      final int sessionCount,
      final int pointsEarned,
      final int avgFocusScore,
      final Map<String, int> minutesBySubject}) = _$DailyStudyStatsImpl;

  factory _DailyStudyStats.fromJson(Map<String, dynamic> json) =
      _$DailyStudyStatsImpl.fromJson;

  @override
  DateTime get date;
  @override
  int get totalMinutes;
  @override
  int get pureMinutes;
  @override
  int get sessionCount;
  @override
  int get pointsEarned;
  @override
  int get avgFocusScore;
  @override
  Map<String, int> get minutesBySubject;

  /// Create a copy of DailyStudyStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyStudyStatsImplCopyWith<_$DailyStudyStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
