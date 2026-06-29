import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:studyverse/features/auth/domain/models/auth_model.dart';

/// Local-first authentication.
///
/// StudyVerse has no remote backend yet, so accounts, sessions and password
/// resets are all persisted on-device via [FlutterSecureStorage]. Everything
/// works fully offline. When a real API becomes available, only this class
/// needs to change — the provider/notifier/UI layers stay the same.
class AuthRepository {
  AuthRepository({required FlutterSecureStorage secureStorage})
      : _storage = secureStorage;

  final FlutterSecureStorage _storage;

  static const _accountsKey = 'sv_accounts_v1';
  static const _sessionKey = 'sv_session_user_id';

  // ── Public API ──────────────────────────────────────────────────────────

  /// Register a new email account. Throws a Korean error message on failure.
  Future<User> register(String email, String password, String nickname) async {
    final normalizedEmail = email.trim().toLowerCase();
    final accounts = await _loadAccounts();

    if (accounts.any((a) => a['email'] == normalizedEmail)) {
      throw '이미 사용 중인 이메일입니다.';
    }

    final record = <String, dynamic>{
      'id': _newId(),
      'email': normalizedEmail,
      'nickname': nickname.trim(),
      'passwordHash': _hash(password),
      'provider': 'email',
      'level': 1,
      'totalStudyHours': 0.0,
      'streakDays': 0,
      'points': 0,
    };

    accounts.add(record);
    await _saveAccounts(accounts);
    await _storage.write(key: _sessionKey, value: record['id'] as String);
    return _toUser(record);
  }

  /// Log in with [email] and [password].
  Future<User> login(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    final accounts = await _loadAccounts();

    final record = accounts.firstWhereOrNull(
      (a) => a['email'] == normalizedEmail,
    );
    if (record == null) {
      throw '가입되지 않은 이메일입니다. 회원가입을 먼저 진행해 주세요.';
    }
    if (record['passwordHash'] != _hash(password)) {
      throw '비밀번호가 올바르지 않습니다.';
    }

    await _storage.write(key: _sessionKey, value: record['id'] as String);
    return _toUser(record);
  }

  /// Social login. Creates (or restores) a local account for [provider]
  /// ('google' | 'kakao'). Real OAuth requires provider API keys + a backend;
  /// until then this provides a fully working local social-account flow.
  Future<User> socialLogin(String provider) async {
    final label = provider == 'kakao' ? '카카오' : 'Google';
    final pseudoEmail = '$provider@studyverse.local';
    final accounts = await _loadAccounts();

    var record = accounts.firstWhereOrNull((a) => a['email'] == pseudoEmail);
    record ??= () {
      final created = <String, dynamic>{
        'id': _newId(),
        'email': pseudoEmail,
        'nickname': '$label 사용자',
        'passwordHash': '',
        'provider': provider,
        'level': 1,
        'totalStudyHours': 0.0,
        'streakDays': 0,
        'points': 0,
      };
      accounts.add(created);
      return created;
    }();

    await _saveAccounts(accounts);
    await _storage.write(key: _sessionKey, value: record['id'] as String);
    return _toUser(record);
  }

  /// Verify an email exists so a reset can proceed. Throws if not found.
  Future<void> requestPasswordReset(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    final accounts = await _loadAccounts();
    final record = accounts.firstWhereOrNull(
      (a) => a['email'] == normalizedEmail,
    );
    if (record == null) {
      throw '가입되지 않은 이메일입니다.';
    }
    if (record['provider'] != 'email') {
      throw '소셜 로그인 계정은 비밀번호를 재설정할 수 없습니다.';
    }
  }

  /// Set a new password for an existing email account.
  Future<void> resetPassword(String email, String newPassword) async {
    final normalizedEmail = email.trim().toLowerCase();
    final accounts = await _loadAccounts();
    final index =
        accounts.indexWhere((a) => a['email'] == normalizedEmail);
    if (index == -1) {
      throw '가입되지 않은 이메일입니다.';
    }
    accounts[index]['passwordHash'] = _hash(newPassword);
    await _saveAccounts(accounts);
  }

  /// Clear the active session (accounts are kept).
  Future<void> logout() async {
    await _storage.delete(key: _sessionKey);
  }

  /// Returns the logged-in [User], or null if no active session.
  Future<User?> getCurrentUser() async {
    try {
      final id = await _storage.read(key: _sessionKey);
      if (id == null) return null;
      final accounts = await _loadAccounts();
      final record = accounts.firstWhereOrNull((a) => a['id'] == id);
      return record == null ? null : _toUser(record);
    } catch (_) {
      return null;
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> _loadAccounts() async {
    try {
      final raw = await _storage.read(key: _accountsKey);
      if (raw == null || raw.isEmpty) return [];
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveAccounts(List<Map<String, dynamic>> accounts) async {
    await _storage.write(key: _accountsKey, value: jsonEncode(accounts));
  }

  User _toUser(Map<String, dynamic> r) => User(
        id: r['id'] as String,
        email: r['email'] as String,
        nickname: r['nickname'] as String,
        level: (r['level'] as num?)?.toInt() ?? 1,
        totalStudyHours: (r['totalStudyHours'] as num?)?.toDouble() ?? 0.0,
        streakDays: (r['streakDays'] as num?)?.toInt() ?? 0,
        points: (r['points'] as num?)?.toInt() ?? 0,
      );

  String _newId() =>
      DateTime.now().microsecondsSinceEpoch.toRadixString(16);

  /// Non-cryptographic FNV-1a hash. Local demo only — avoids storing the
  /// raw password in clear text while keeping deterministic comparison.
  String _hash(String input) {
    if (input.isEmpty) return '';
    var hash = 0x811c9dc5;
    for (final unit in utf8.encode('sv_salt::$input')) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16);
  }
}

// ── Riverpod providers ─────────────────────────────────────────────────────

final _secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    ),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    secureStorage: ref.watch(_secureStorageProvider),
  );
});
