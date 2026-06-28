import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_model.freezed.dart';
part 'home_model.g.dart';

@freezed
class HomeData with _$HomeData {
  const factory HomeData({
    required String userNickname,
    required double todayStudyHours,
    required double targetHours,
    required int streakDays,
    required int bestStreak,
    required int points,
    required double focusScore,
    required int recentSessions,
    required bool isStudying,
  }) = _HomeData;

  factory HomeData.fromJson(Map<String, dynamic> json) => _$HomeDataFromJson(json);
}

@freezed
class StudySession with _$StudySession {
  const factory StudySession({
    required String id,
    required String subject,
    required DateTime startTime,
    DateTime? endTime,
    @Default(0.0) double durationHours,
    @Default(0.0) double focusScore,
    @Default(false) bool isAiVerified,
  }) = _StudySession;

  factory StudySession.fromJson(Map<String, dynamic> json) => _$StudySessionFromJson(json);
}

/// State envelope for the home screen data feed.
@freezed
class HomeState with _$HomeState {
  const factory HomeState.initial() = _HomeInitial;
  const factory HomeState.loading() = _HomeLoading;
  const factory HomeState.loaded(HomeData data) = _HomeLoaded;
  const factory HomeState.error(String message) = _HomeError;
}
