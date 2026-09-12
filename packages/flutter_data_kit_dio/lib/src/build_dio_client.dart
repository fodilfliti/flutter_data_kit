import 'package:dio/dio.dart';
import 'package:flutter_data_kit_dio/src/failure_interceptor.dart';
import 'package:flutter_data_kit_dio/src/token_interceptor.dart';

/// Shared Dio client: JSON headers, optional token hook, FailureInterceptor.
///
/// FailureInterceptor is added last so `onError` runs first (LIFO) and maps
/// to AppFailure before other interceptors see the failure.
Dio buildDioClient({
  required String baseUrl,
  TokenReader? readToken,
  Duration connectTimeout = const Duration(seconds: 15),
  Duration sendTimeout = const Duration(seconds: 15),
  Duration receiveTimeout = const Duration(seconds: 15),
  Map<String, Object?>? headers,
  List<Interceptor> extraInterceptors = const [],
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      sendTimeout: sendTimeout,
      receiveTimeout: receiveTimeout,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        ...?headers,
      },
    ),
  );
  if (readToken != null) {
    dio.interceptors.add(TokenInterceptor(readToken));
  }
  dio.interceptors.addAll(extraInterceptors);
  dio.interceptors.add(FailureInterceptor());
  return dio;
}
