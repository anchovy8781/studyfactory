import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:studyverse/core/network/api_endpoints.dart';

/// Keys used in secure storage for token management.
abstract final class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
}

/// Dio interceptor that automatically attaches JWT access tokens
/// and refreshes them when a 401 is received.
final class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required Dio dio,
    required FlutterSecureStorage secureStorage,
  })  : _dio = dio,
        _secureStorage = secureStorage;

  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  /// Prevents concurrent refresh calls.
  bool _isRefreshing = false;
  final List<RequestOptions> _pendingRequests = [];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.read(key: StorageKeys.accessToken);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Skip refresh for the refresh endpoint itself to avoid infinite loop.
      if (err.requestOptions.path == ApiEndpoints.refreshToken) {
        await _clearTokens();
        handler.next(err);
        return;
      }

      if (_isRefreshing) {
        // Queue request to retry after refresh.
        _pendingRequests.add(err.requestOptions);
        return;
      }

      _isRefreshing = true;
      try {
        final newAccessToken = await _refreshAccessToken();
        if (newAccessToken == null) {
          await _clearTokens();
          handler.next(err);
          return;
        }

        // Retry original request with new token.
        final response = await _retryRequest(
          err.requestOptions,
          newAccessToken,
        );

        // Retry queued requests.
        for (final pending in _pendingRequests) {
          await _retryRequest(pending, newAccessToken);
        }
        _pendingRequests.clear();

        handler.resolve(response);
      } catch (e) {
        debugPrint('[AuthInterceptor] Token refresh failed: $e');
        await _clearTokens();
        _pendingRequests.clear();
        handler.next(err);
      } finally {
        _isRefreshing = false;
      }
      return;
    }
    handler.next(err);
  }

  Future<String?> _refreshAccessToken() async {
    final refreshToken =
        await _secureStorage.read(key: StorageKeys.refreshToken);
    if (refreshToken == null || refreshToken.isEmpty) return null;

    final refreshDio = Dio(
      BaseOptions(baseUrl: ApiEndpoints.baseUrl),
    );

    final response = await refreshDio.post<Map<String, dynamic>>(
      ApiEndpoints.refreshToken,
      data: {'refresh_token': refreshToken},
    );

    final data = response.data;
    if (data == null) return null;

    final newAccess = data['access_token'] as String?;
    final newRefresh = data['refresh_token'] as String?;

    if (newAccess != null) {
      await _secureStorage.write(
        key: StorageKeys.accessToken,
        value: newAccess,
      );
    }
    if (newRefresh != null) {
      await _secureStorage.write(
        key: StorageKeys.refreshToken,
        value: newRefresh,
      );
    }

    return newAccess;
  }

  Future<Response<dynamic>> _retryRequest(
    RequestOptions requestOptions,
    String token,
  ) {
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $token',
      },
    );
    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: StorageKeys.accessToken);
    await _secureStorage.delete(key: StorageKeys.refreshToken);
    await _secureStorage.delete(key: StorageKeys.userId);
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
});
