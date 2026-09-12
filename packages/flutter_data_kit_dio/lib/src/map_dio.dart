import 'package:dio/dio.dart';
import 'package:lemsa_core_kit/lemsa_core_kit.dart';

/// Maps a [DioException] to [AppFailure]. Adapter-zone only.
AppFailure mapDioException(DioException error) {
  final existing = error.error;
  if (existing is AppFailure) {
    return existing;
  }

  return switch (error.type) {
    DioExceptionType.connectionError ||
    DioExceptionType.connectionTimeout => NetworkFailure(cause: error),
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout => TimeoutFailure(cause: error),
    DioExceptionType.cancel => const CancelledFailure(),
    _ => switch (error.response?.statusCode) {
      401 || 403 => AuthFailure(AuthReason.expired, cause: error),
      404 => NotFoundFailure('resource', cause: error),
      409 => ConflictFailure(
        code: readCode(error.response?.data),
        cause: error,
      ),
      422 => ValidationFailure(
        readFieldErrors(error.response?.data),
        cause: error,
      ),
      final status => ServerFailure(
        status: status,
        code: readCode(error.response?.data),
        cause: error,
      ),
    },
  };
}

/// Machine token from a JSON error body (`code` / `error_code` / `error`).
String? readCode(Object? data) {
  if (data is Map) {
    final code = data['code'] ?? data['error_code'];
    if (code is String && code.isNotEmpty) {
      return code;
    }
    final error = data['error'];
    if (error is String && error.isNotEmpty) {
      return error;
    }
  }
  return null;
}

/// Field-token map from `errors` or `fields`. Values are tokens, not messages.
Map<String, String> readFieldErrors(Object? data) {
  if (data is Map) {
    final raw = data['errors'] ?? data['fields'];
    if (raw is Map) {
      return {
        for (final entry in raw.entries)
          entry.key.toString(): _token(entry.value),
      };
    }
  }
  return const {'_': 'invalid'};
}

String _token(Object? value) {
  if (value is List && value.isNotEmpty) {
    return value.first.toString();
  }
  return value?.toString() ?? 'invalid';
}
