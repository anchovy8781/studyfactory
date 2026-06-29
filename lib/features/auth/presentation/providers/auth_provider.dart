import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyverse/features/auth/data/auth_repository.dart';
import 'package:studyverse/features/auth/domain/models/auth_model.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository) : super(const AuthState.initial()) {
    _checkCurrentUser();
  }

  final AuthRepository _repository;

  /// Check if a session is already active on startup.
  Future<void> _checkCurrentUser() async {
    state = const AuthState.loading();
    try {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (_) {
      state = const AuthState.unauthenticated();
    }
  }

  /// Log in with [email] and [password].
  Future<void> login(String email, String password) async {
    state = const AuthState.loading();
    try {
      final user = await _repository.login(email, password);
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Register with the provided credentials.
  Future<void> register(String email, String password, String nickname) async {
    state = const AuthState.loading();
    try {
      final user = await _repository.register(email, password, nickname);
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Social login (provider: 'google' | 'kakao').
  Future<void> socialLogin(String provider) async {
    state = const AuthState.loading();
    try {
      final user = await _repository.socialLogin(provider);
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Verify an email is registered before allowing a reset.
  Future<void> requestPasswordReset(String email) =>
      _repository.requestPasswordReset(email);

  /// Set a new password for an existing account.
  Future<void> resetPassword(String email, String newPassword) =>
      _repository.resetPassword(email, newPassword);

  /// Log out and clear local session.
  Future<void> logout() async {
    state = const AuthState.loading();
    try {
      await _repository.logout();
    } finally {
      state = const AuthState.unauthenticated();
    }
  }

  /// Dismiss an error state so the UI can try again.
  void clearError() {
    state.maybeWhen(
      error: (_) => state = const AuthState.unauthenticated(),
      orElse: () {},
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

/// Convenience provider that returns the authenticated user or null.
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).whenOrNull(
        authenticated: (user) => user,
      );
});
