import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:studyverse/core/network/api_endpoints.dart';
import 'package:studyverse/core/network/interceptors/auth_interceptor.dart';
import 'package:studyverse/core/network/interceptors/error_interceptor.dart';

/// Configured [Dio] HTTP client with auth, error handling, and logging.
final class DioClient {
  DioClient._();

  static Dio create({
    required AuthInterceptor authInterceptor,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-App-Version': '1.0.0',
          'X-Platform': defaultTargetPlatform.name,
        },
        validateStatus: (status) => status != null && status < 500,
        responseType: ResponseType.json,
      ),
    );

    // Add interceptors in order: auth → error → logging.
    dio.interceptors.addAll([
      authInterceptor,
      ErrorInterceptor(),
      if (kDebugMode) _buildLoggingInterceptor(),
    ]);

    return dio;
  }

  static LogInterceptor _buildLoggingInterceptor() => LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        responseHeader: false,
        error: true,
        logPrint: (object) => debugPrint('[DioClient] $object'),
      );
}

// ── Providers ─────────────────────────────────────────────────────────────────

final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  // Dio instance for the auth interceptor (used internally for refresh).
  final internalDio = Dio(
    BaseOptions(baseUrl: ApiEndpoints.baseUrl),
  );
  return AuthInterceptor(
    dio: internalDio,
    secureStorage: secureStorage,
  );
});

final dioProvider = Provider<Dio>((ref) {
  final authInterceptor = ref.watch(authInterceptorProvider);
  return DioClient.create(authInterceptor: authInterceptor);
});
