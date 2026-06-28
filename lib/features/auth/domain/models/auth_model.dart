import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_model.freezed.dart';
part 'auth_model.g.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String nickname,
    String? profileImageUrl,
    @Default(1) int level,
    @Default(0.0) double totalStudyHours,
    @Default(0) int streakDays,
    @Default(0) int points,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
