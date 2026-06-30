import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  static const _deviceRegisteredKey = 'sv_device_registered';
  static const _withdrawnUntilKey = 'sv_withdrawn_until';

  Future<User> register(String email, String password, String nickname) async {
    final prefs = await SharedPreferences.getInstance();

    // Re-registration is blocked for 30 days after a withdrawal.
    final until = prefs.getInt(_withdrawnUntilKey);
    if (until != null && DateTime.now().millisecondsSinceEpoch < until) {
      final d = DateTime.fromMillisecondsSinceEpoch(until);
      throw '탈퇴 후 30일간 재가입이 제한됩니다. ${d.year}년 ${d.month}월 ${d.day}일 이후 가능합니다.';
    }

    // One account per device: block a second sign-up on the same device.
    if (prefs.getBool(_deviceRegisteredKey) ?? false) {
      throw '이 기기에서는 이미 계정을 생성했습니다. 로그인해 주세요.';
    }

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
      // Firestore profile write is non-fatal: the auth account is already
      // created, so a missing/locked Firestore must not fail registration.
      final referralCode = _generateReferralCode();
      try {
        await _users.doc(fbUser.uid).set({
          'email': user.email,
          'nickname': user.nickname,
          'level': 1,
          'totalStudyHours': 0.0,
          'todayStudyHours': 0.0,
          'streakDays': 0,
          'points': 0, // 0부터 시작 (활동으로 적립)
          'role': 'user',
          'provider': 'email',
          'referralCode': referralCode,
          'referredBy': null,
          'createdAt': FieldValue.serverTimestamp(),
        });
        // Reverse lookup map for referral redemption.
        await _db.collection('referralCodes').doc(referralCode).set({
          'uid': fbUser.uid,
          'pending': 0,
        });
      } catch (_) {/* profile doc can be created on next login */}

      // Send a verification email (non-fatal).
      try {
        await fbUser.sendEmailVerification();
      } catch (_) {/* user can resend from the verification screen */}

      await prefs.setBool(_deviceRegisteredKey, true);
      return user;
    } on fb.FirebaseAuthException catch (e) {
      throw _mapError(e);
    } catch (e) {
      if (e is String) rethrow;
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

      // Firestore profile creation is non-fatal (login must succeed even if
      // Firestore is locked/unavailable).
      try {
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
      } catch (_) {/* profile syncs once Firestore rules allow it */}
      return _fetchUser(fbUser);
    } on fb.FirebaseAuthException catch (e) {
      throw _mapError(e);
    } catch (e) {
      if (e is String) rethrow;
      final msg = e.toString();
      if (msg.contains('ApiException: 10') ||
          msg.contains('sign_in_failed')) {
        throw 'Google 로그인 설정이 필요합니다. (Firebase 콘솔에 Android 앱 등록 + SHA-1 지문 추가)';
      }
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

  /// Whether the current user's email is verified.
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  /// Re-send the verification email to the current user.
  Future<void> resendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on fb.FirebaseAuthException catch (e) {
      throw _mapError(e);
    } catch (e) {
      throw _genericError(e);
    }
  }

  /// Reloads the user from Firebase and returns the latest verified status.
  Future<bool> reloadAndCheckEmailVerified() async {
    try {
      await _auth.currentUser?.reload();
      return _auth.currentUser?.emailVerified ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Delete the account. Records a 30-day re-registration block on this device,
  /// removes the Firestore profile, and deletes the Firebase Auth user.
  Future<void> withdraw() async {
    final user = _auth.currentUser;
    if (user == null) throw '로그인 상태가 아닙니다.';

    // Best-effort server record + profile cleanup.
    try {
      await _db.collection('withdrawals').doc(user.uid).set({
        'email': user.email,
        'withdrawnAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {/* ignore */}
    try {
      await _users.doc(user.uid).delete();
    } catch (_) {/* ignore */}

    // Device-side: allow a new account only after 30 days.
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deviceRegisteredKey);
    await prefs.setInt(
      _withdrawnUntilKey,
      DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch,
    );

    try {
      await user.delete();
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw '보안을 위해 다시 로그인한 뒤 탈퇴를 진행해 주세요.';
      }
      throw _mapError(e);
    }
    try {
      await _google.signOut();
    } catch (_) {/* ignore */}
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
    // Reading the Firestore profile must never fail the login. If Firestore
    // is locked (permission-denied) or unavailable, fall back to the auth
    // account info so the user still gets in.
    try {
      final doc = await _users.doc(fbUser.uid).get();
      final data = doc.data();
      if (data == null) return _basicUser(fbUser);
      return User(
        id: fbUser.uid,
        email: fbUser.email ?? (data['email'] as String? ?? ''),
        nickname:
            (data['nickname'] as String?) ?? fbUser.displayName ?? '사용자',
        level: (data['level'] as num?)?.toInt() ?? 1,
        totalStudyHours: (data['totalStudyHours'] as num?)?.toDouble() ?? 0.0,
        streakDays: (data['streakDays'] as num?)?.toInt() ?? 0,
        points: (data['points'] as num?)?.toInt() ?? 0,
      );
    } catch (_) {
      return _basicUser(fbUser);
    }
  }

  User _basicUser(fb.User u) => User(
        id: u.uid,
        email: u.email ?? '',
        nickname: u.displayName ?? '사용자',
      );

  String _generateReferralCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final now = DateTime.now().microsecondsSinceEpoch;
    final buf = StringBuffer();
    var seed = now;
    for (var i = 0; i < 6; i++) {
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      buf.write(chars[seed % chars.length]);
    }
    return buf.toString();
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
