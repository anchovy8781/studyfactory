import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:studyverse/core/errors/app_exception.dart';

/// Dio interceptor that converts HTTP errors into typed [AppException]s.
final class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _mapDioException(err);
    debugPrint(
      '[ErrorInterceptor] ${exception.runtimeType}: ${exception.message}',
    );

    // Wrap in a DioException so downstream code can still catch DioException.
    handler.next(
      err.copyWith(
        error: exception,
        message: exception.message,
      ),
    );
  }

  AppException _mapDioException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException('요청 시간이 초과되었습니다. 네트워크를 확인해주세요.');

      case DioExceptionType.connectionError:
        return const NetworkException('인터넷 연결을 확인해주세요.');

      case DioExceptionType.cancel:
        return const RequestCancelledException('요청이 취소되었습니다.');

      case DioExceptionType.badCertificate:
        return const ServerException('보안 인증서 오류가 발생했습니다.');

      case DioExceptionType.badResponse:
        return _mapStatusCode(err);

      case DioExceptionType.unknown:
        final message = err.message ?? '알 수 없는 오류가 발생했습니다.';
        return UnknownException(message);
    }
  }

  AppException _mapStatusCode(DioException err) {
    final statusCode = err.response?.statusCode ?? 0;
    final data = err.response?.data;

    final serverMessage = _extractMessage(data);

    return switch (statusCode) {
      400 => BadRequestException(serverMessage ?? '잘못된 요청입니다.'),
      401 => const UnauthorizedException('로그인이 필요합니다.'),
      403 => const ForbiddenException('접근 권한이 없습니다.'),
      404 => NotFoundException(serverMessage ?? '요청한 리소스를 찾을 수 없습니다.'),
      409 => ConflictException(serverMessage ?? '이미 존재하는 데이터입니다.'),
      422 => ValidationException(serverMessage ?? '입력값을 확인해주세요.'),
      429 => const RateLimitException('요청이 너무 많습니다. 잠시 후 다시 시도해주세요.'),
      >= 500 => ServerException(serverMessage ?? '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.'),
      _ => UnknownException(serverMessage ?? '오류가 발생했습니다. ($statusCode)'),
    };
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return (data['message'] as String?) ??
          (data['error'] as String?) ??
          (data['detail'] as String?);
    }
    if (data is String && data.isNotEmpty) return data;
    return null;
  }
}
