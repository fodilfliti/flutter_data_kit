import 'package:dio/dio.dart';
import 'package:flutter_data_kit_dio/src/map_dio.dart';
import 'package:lemsa_core_kit/lemsa_core_kit.dart';

/// Converts DioException into AppFailure on the error pipeline.
///
/// Prefer this over wrapping every call: it cannot be forgotten on a shared
/// client. Pair with `runDio` so callers see AppFailure, not DioException.
class FailureInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.error is AppFailure) {
      handler.next(err);
      return;
    }
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: mapDioException(err),
        type: err.type,
        response: err.response,
      ),
    );
  }
}
