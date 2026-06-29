import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyverse/features/auth/domain/models/auth_model.dart';

const _accessTokenKey = 'access_token';
const _refreshTokenKey = 'refresh_token';

class AuthRepository {
  AuthRepository({
    required Dio dio,
    required FlutterSecureStorage secureStorage,
  })  : _dio = dio,
        _secureStorage = secureStorage;

  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  /// Attempt login with [email] and [password].
  /// Stores access/refresh tokens on success and returns the [User].
  Future<User> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final data = response.data as Map<String, dynamic>;
      await _storeTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
      );

      return User.fromJson(data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  /// Register a new account with the given credentials.
  Future<User> register(String email, String password, String nickname) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'nickname': nickname,
        },
      );

      final data = response.data as Map<String, dynamic>;
      await _storeTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
      );

      return User.fromJson(data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  /// Invalidate the session on the server and clear local tokens.
  Future<void> logout() async {
    try {
      final token = await _secureStorage.read(key: _accessTokenKey);
      if (token != null) {
        await _dio.post(
          '/auth/logout',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      }
    } catch (_) {
      // Best-effort server logout; always clear local tokens.
    } finally {
      await _clearTokens();
    }
  }

  /// Returns the currently authenticated [User] using the stored token,
  /// or `null` if no valid session exists.
  Future<User?> getCurrentUser() async {
    try {
      final token = await _secureStorage.read(key: _accessTokenKey);
      if (token == null) return null;

      final response = await _dio.get(
        '/auth/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return User.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        final refreshed = await _tryRefreshToken();
        if (refreshed) return getCurrentUser();
        await _clearTokens();
      }
      return null;
    } catch (_) {
      // PlatformException from Keystore or unexpected errors — treat as no session.
      return null;
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<void> _storeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _secureStorage.write(key: _accessTokenKey, value: accessToken),
      _secureStorage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }

  Future<void> _clearTokens() async {
    await Future.wait([
      _secureStorage.delete(key: _accessTokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
    ]);
  }

  Future<bool> _tryRefreshToken() async {
    final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
    if (refreshToken == null) return false;

    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      final data = response.data as Map<String, dynamic>;
      await _storeTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String? ?? refreshToken,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  String _mapDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final serverMessage = (e.response?.data as Map<String, dynamic>?)?['message'] as String?;

    if (serverMessage != null) return serverMessage;

    switch (statusCode) {
      case 400:
        return '입력 정보를 확인해 주세요.';
      case 401:
        return '이메일 또는 비밀번호가 올바르지 않습니다.';
      case 403:
        return '접근이 거부되었습니다.';
      case 404:
        return '계정을 찾을 수 없습니다.';
      case 409:
        return '이미 사용 중인 이메일입니다.';
      case 422:
        return '입력 형식이 올바르지 않습니다.';
      case 500:
        return '서버 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.';
      default:
        if (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout) {
          return '네트워크 연결을 확인해 주세요.';
        }
        return '알 수 없는 오류가 발생했습니다.';
    }
  }
}

// ── Riverpod providers ─────────────────────────────────────────────────────

final _dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.studyverse.app/v1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );
  return dio;
});

final _secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      // If the Keystore is corrupt (e.g. after factory-reset or reinstall),
      // clear stored values rather than crashing.
      resetOnError: true,
    ),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    dio: ref.watch(_dioProvider),
    secureStorage: ref.watch(_secureStorageProvider),
  );
});
