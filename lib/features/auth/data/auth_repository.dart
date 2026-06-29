import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:studyverse/features/auth/domain/models/auth_model.dart';

/// Firebase-backed authentication (no local accounts).
///
/// - Auth: Firebase Authentication (email/password + Google).
/// - Profile data: Cloud Firestore `users/{uid}`.
/// - Password reset: real reset email via Firebase.
///
/// Requires a real `google-services.json` from your Firebase project. Until
/// that is added, calls will surface a clear "Firebase 미설정" error.
class AuthRepository {
  AuthRepository({
    fb.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? fb.FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance,
        _google = googleSignIn ?? GoogleSignIn();

  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final GoogleSignIn _google;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  // ── Public API ────────────────────────────────────────────────────────────

  Future<User> register(String email, String password, String nickname) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final fbUser = cred.user!;
      await fbUser.updateDisplayName(nickname.trim());

      final user = User(
        id: fbUser.uid,
        email: email.trim(),
        nickname: nickname.trim(),
      );
      await _users.doc(fbUser.uid).set({
        'email': user.email,
        'nickname': user.nickname,
        'level': 1,
        'totalStudyHours': 0.0,
        'streakDays': 0,
        'points': 0,
        'role': 'user',
        'provider': 'email',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return user;
    } on fb.FirebaseAuthException catch (e) {
      throw _mapError(e);
    } catch (e) {
      throw _genericError(e);
    }
  }

  Future<User> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return _fetchUser(cred.user!);
    } on fb.FirebaseAuthException catch (e) {
      throw _mapError(e);
    } catch (e) {
      throw _genericError(e);
    }
  }

  /// Google sign-in via Firebase credential.
  Future<User> signInWithGoogle() async {
    try {
      final googleUser = await _google.signIn();
      if (googleUser == null) throw 'Google 로그인이 취소되었습니다.';
      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final cred = await _auth.signInWithCredential(credential);
      final fbUser = cred.user!;

      final doc = await _users.doc(fbUser.uid).get();
      if (!doc.exists) {
        await _users.doc(fbUser.uid).set({
          'email': fbUser.email ?? '',
          'nickname': fbUser.displayName ?? 'Google 사용자',
          'level': 1,
          'totalStudyHours': 0.0,
          'streakDays': 0,
          'points': 0,
          'role': 'user',
          'provider': 'google',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return _fetchUser(fbUser);
    } on fb.FirebaseAuthException catch (e) {
      throw _mapError(e);
    } catch (e) {
      if (e is String) rethrow;
      throw _genericError(e);
    }
  }

  /// Send a real password-reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on fb.FirebaseAuthException catch (e) {
      throw _mapError(e);
    } catch (e) {
      throw _genericError(e);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    try {
      await _google.signOut();
    } catch (_) {/* ignore */}
  }

  Future<User?> getCurrentUser() async {
    final fbUser = _auth.currentUser;
    if (fbUser == null) return null;
    try {
      return await _fetchUser(fbUser);
    } catch (_) {
      return User(
        id: fbUser.uid,
        email: fbUser.email ?? '',
        nickname: fbUser.displayName ?? '사용자',
      );
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<User> _fetchUser(fb.User fbUser) async {
    final doc = await _users.doc(fbUser.uid).get();
    final data = doc.data();
    if (data == null) {
      return User(
        id: fbUser.uid,
        email: fbUser.email ?? '',
        nickname: fbUser.displayName ?? '사용자',
      );
    }
    return User(
      id: fbUser.uid,
      email: fbUser.email ?? (data['email'] as String? ?? ''),
      nickname: (data['nickname'] as String?) ?? fbUser.displayName ?? '사용자',
      level: (data['level'] as num?)?.toInt() ?? 1,
      totalStudyHours: (data['totalStudyHours'] as num?)?.toDouble() ?? 0.0,
      streakDays: (data['streakDays'] as num?)?.toInt() ?? 0,
      points: (data['points'] as num?)?.toInt() ?? 0,
    );
  }

  String _mapError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return '이미 사용 중인 이메일입니다.';
      case 'invalid-email':
        return '올바른 이메일 형식을 입력해 주세요.';
      case 'weak-password':
        return '비밀번호가 너무 약합니다. 더 복잡하게 입력해 주세요.';
      case 'user-not-found':
        return '가입되지 않은 이메일입니다.';
      case 'wrong-password':
      case 'invalid-credential':
        return '이메일 또는 비밀번호가 올바르지 않습니다.';
      case 'user-disabled':
        return '비활성화된 계정입니다.';
      case 'too-many-requests':
        return '잠시 후 다시 시도해 주세요.';
      case 'network-request-failed':
        return '네트워크 연결을 확인해 주세요.';
      case 'operation-not-allowed':
        return '이메일/비밀번호 로그인이 비활성화되어 있습니다. (Firebase 콘솔에서 활성화 필요)';
      default:
        return e.message ?? '인증 중 오류가 발생했습니다.';
    }
  }

  String _genericError(Object e) {
    final msg = e.toString();
    if (msg.contains('No Firebase App') ||
        msg.contains('configuration') ||
        msg.contains('api-key')) {
      return 'Firebase가 설정되지 않았습니다. 실제 google-services.json을 추가해 주세요.';
    }
    return '오류가 발생했습니다. 잠시 후 다시 시도해 주세요.';
  }
}

// ── Riverpod provider ──────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});
