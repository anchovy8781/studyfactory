import 'package:equatable/equatable.dart';

/// Base class for all application-level exceptions.
/// Every concrete exception carries a [message] and an optional [details] map.
sealed class AppException extends Equatable implements Exception {
  const AppException(this.message, {this.details});

  final String message;
  final Map<String, dynamic>? details;

  @override
  List<Object?> get props => [message, details];

  @override
  String toString() => '$runtimeType: $message';
}

// ── Network ───────────────────────────────────────────────────────────────────

/// Device has no internet connectivity.
final class NetworkException extends AppException {
  const NetworkException([
    super.message = '인터넷 연결을 확인해주세요.',
  ]);
}

/// Request or response timed out.
final class TimeoutException extends AppException {
  const TimeoutException([
    super.message = '요청 시간이 초과되었습니다.',
  ]);
}

/// HTTP 400 – malformed request.
final class BadRequestException extends AppException {
  const BadRequestException([
    super.message = '잘못된 요청입니다.',
  ]);
}

/// HTTP 401 – authentication required.
final class UnauthorizedException extends AppException {
  const UnauthorizedException([
    super.message = '로그인이 필요합니다.',
  ]);
}

/// HTTP 403 – insufficient permissions.
final class ForbiddenException extends AppException {
  const ForbiddenException([
    super.message = '접근 권한이 없습니다.',
  ]);
}

/// HTTP 404 – resource does not exist.
final class NotFoundException extends AppException {
  const NotFoundException([
    super.message = '요청한 리소스를 찾을 수 없습니다.',
  ]);
}

/// HTTP 409 – resource conflict.
final class ConflictException extends AppException {
  const ConflictException([
    super.message = '이미 존재하는 데이터입니다.',
  ]);
}

/// HTTP 422 – validation failed.
final class ValidationException extends AppException {
  const ValidationException([
    super.message = '입력값을 확인해주세요.',
  ]) : super(details: null);

  const ValidationException.withFields(
    super.message,
    Map<String, String> fieldErrors,
  ) : super(details: fieldErrors);

  Map<String, String>? get fieldErrors =>
      details?.cast<String, String>();
}

/// HTTP 429 – rate limited.
final class RateLimitException extends AppException {
  const RateLimitException([
    super.message = '요청이 너무 많습니다. 잠시 후 다시 시도해주세요.',
  ]);
}

/// HTTP 5xx – server-side error.
final class ServerException extends AppException {
  const ServerException([
    super.message = '서버 오류가 발생했습니다.',
  ]);
}

/// Request was cancelled before completing.
final class RequestCancelledException extends AppException {
  const RequestCancelledException([
    super.message = '요청이 취소되었습니다.',
  ]);
}

/// Catch-all for unmapped errors.
final class UnknownException extends AppException {
  const UnknownException([
    super.message = '알 수 없는 오류가 발생했습니다.',
  ]);
}

// ── Auth / Business ───────────────────────────────────────────────────────────

/// User is not authenticated (token absent or invalid).
final class NotAuthenticatedException extends AppException {
  const NotAuthenticatedException([
    super.message = '인증 정보가 유효하지 않습니다. 다시 로그인해주세요.',
  ]);
}

/// Token has expired and could not be refreshed.
final class TokenExpiredException extends AppException {
  const TokenExpiredException([
    super.message = '세션이 만료되었습니다. 다시 로그인해주세요.',
  ]);
}

/// Feature requires a device permission the user denied.
final class PermissionDeniedException extends AppException {
  const PermissionDeniedException(super.message);
}

/// Local cache miss or parse failure.
final class CacheException extends AppException {
  const CacheException([
    super.message = '로컬 데이터를 불러오는 데 실패했습니다.',
  ]);
}

/// Study session related error.
final class StudySessionException extends AppException {
  const StudySessionException(super.message);
}

/// AI / ML processing error.
final class AiProcessingException extends AppException {
  const AiProcessingException([
    super.message = 'AI 처리 중 오류가 발생했습니다.',
  ]);
}
