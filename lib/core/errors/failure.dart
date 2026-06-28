import 'package:equatable/equatable.dart';

import 'package:studyverse/core/errors/app_exception.dart';

/// Value-object that represents a known failure in the domain layer.
/// Repositories return [Either<Failure, T>] instead of throwing exceptions.
sealed class Failure extends Equatable {
  const Failure(this.message, {this.details});

  final String message;
  final Map<String, dynamic>? details;

  @override
  List<Object?> get props => [message, details];

  @override
  String toString() => '$runtimeType: $message';

  /// Creates the appropriate [Failure] subtype from an [AppException].
  factory Failure.fromException(AppException exception) =>
      switch (exception) {
        NetworkException() => NetworkFailure(exception.message),
        TimeoutException() => NetworkFailure(exception.message),
        UnauthorizedException() => AuthFailure(exception.message),
        NotAuthenticatedException() => AuthFailure(exception.message),
        TokenExpiredException() => AuthFailure(exception.message),
        ForbiddenException() => PermissionFailure(exception.message),
        PermissionDeniedException() => PermissionFailure(exception.message),
        NotFoundException() => NotFoundFailure(exception.message),
        ValidationException() => ValidationFailure(
            exception.message,
            fieldErrors: exception.fieldErrors ?? {},
          ),
        ConflictException() => ConflictFailure(exception.message),
        CacheException() => CacheFailure(exception.message),
        StudySessionException() => StudySessionFailure(exception.message),
        AiProcessingException() => AiProcessingFailure(exception.message),
        ServerException() => ServerFailure(exception.message),
        BadRequestException() => ServerFailure(exception.message),
        RateLimitException() => ServerFailure(exception.message),
        RequestCancelledException() => RequestCancelledFailure(
            exception.message,
          ),
        UnknownException() => UnknownFailure(exception.message),
      };
}

// ── Concrete failure types ────────────────────────────────────────────────────

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = '인터넷 연결을 확인해주세요.']);
}

final class AuthFailure extends Failure {
  const AuthFailure([super.message = '인증에 실패했습니다.']);
}

final class PermissionFailure extends Failure {
  const PermissionFailure([super.message = '권한이 없습니다.']);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = '데이터를 찾을 수 없습니다.']);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(
    super.message, {
    this.fieldErrors = const {},
  });

  final Map<String, String> fieldErrors;

  @override
  List<Object?> get props => [message, fieldErrors];
}

final class ConflictFailure extends Failure {
  const ConflictFailure([super.message = '이미 존재하는 데이터입니다.']);
}

final class ServerFailure extends Failure {
  const ServerFailure([super.message = '서버 오류가 발생했습니다.']);
}

final class CacheFailure extends Failure {
  const CacheFailure([super.message = '로컬 데이터 오류가 발생했습니다.']);
}

final class StudySessionFailure extends Failure {
  const StudySessionFailure([super.message = '공부 세션 오류가 발생했습니다.']);
}

final class AiProcessingFailure extends Failure {
  const AiProcessingFailure([super.message = 'AI 처리 중 오류가 발생했습니다.']);
}

final class RequestCancelledFailure extends Failure {
  const RequestCancelledFailure([super.message = '요청이 취소되었습니다.']);
}

final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = '알 수 없는 오류가 발생했습니다.']);
}
