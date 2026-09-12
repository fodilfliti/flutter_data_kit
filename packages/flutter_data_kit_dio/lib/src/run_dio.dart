import 'package:dio/dio.dart';
import 'package:flutter_data_kit_dio/src/map_dio.dart';
import 'package:lemsa_core_kit/lemsa_core_kit.dart';

/// Runs a Dio call and rethrows [AppFailure] (never [DioException]).
///
/// Use on every public source method that talks to Dio, including Retrofit.
Future<T> runDio<T>(Future<T> Function() body) async {
  try {
    return await body();
  } on AppFailure {
    rethrow;
  } on DioException catch (e, s) {
    Error.throwWithStackTrace(mapDioException(e), s);
  }
}
