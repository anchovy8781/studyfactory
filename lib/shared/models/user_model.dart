// coverage:ignore-file
// ignore_for_file: type=lint

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// User rank levels in the StudyVerse gamification system.
enum UserRank {
  @JsonValue('bronze')
  bronze,
  @JsonValue('silver')
  silver,
  @JsonValue('gold')
  gold,
  @JsonValue('diamond')
  diamond,
  @JsonValue('master')
  master,
}

extension UserRankX on UserRank {
  String get displayName => switch (this) {
        UserRank.bronze => '브론즈',
        UserRank.silver => '실버',
        UserRank.gold => '골드',
        UserRank.diamond => '다이아',
        UserRank.master => '마스터',
      };

  String get emoji => switch (this) {
        UserRank.bronze => '🥉',
        UserRank.silver => '🥈',
        UserRank.gold => '🥇',
        UserRank.diamond => '💎',
        UserRank.master => '👑',
      };
}

/// User role for access control.
enum UserRole {
  @JsonValue('student')
  student,
  @JsonValue('mentor')
  mentor,
  @JsonValue('admin')
  admin,
}

/// Immutable user model returned by the API.
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required String nickname,
    @Default(UserRole.student) UserRole role,
    @Default(UserRank.bronze) UserRank rank,
    String? avatarUrl,
    String? bio,
    String? school,
    String? grade,
    @Default(0) int totalPoints,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
    @Default(0) int totalStudyMinutes,
    @Default(0) int weeklyStudyMinutes,
    @Default(0) int followersCount,
    @Default(0) int followingCount,
    @Default(false) bool isFollowing,
    @Default(false) bool isVerified,
    @Default(false) bool isPremium,
    @Default([]) List<String> badgeIds,
    DateTime? lastStudiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

/// Minimal user reference (for posts, rankings, etc.)
@freezed
class UserRef with _$UserRef {
  const factory UserRef({
    required String id,
    required String nickname,
    String? avatarUrl,
    @Default(UserRank.bronze) UserRank rank,
    @Default(false) bool isVerified,
  }) = _UserRef;

  factory UserRef.fromJson(Map<String, dynamic> json) =>
      _$UserRefFromJson(json);
}

/// Auth token pair returned after login/register.
@freezed
class AuthTokens with _$AuthTokens {
  const factory AuthTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) = _AuthTokens;

  factory AuthTokens.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensFromJson(json);
}

/// Full auth response including user + tokens.
@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required UserModel user,
    required AuthTokens tokens,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}

/// Update profile request body.
@freezed
class UpdateProfileRequest with _$UpdateProfileRequest {
  const factory UpdateProfileRequest({
    String? nickname,
    String? bio,
    String? school,
    String? grade,
  }) = _UpdateProfileRequest;

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileRequestFromJson(json);
}
