import 'package:dio/dio.dart';

/// Supplies an access token. The app owns Firebase/Supabase/session lookup —
/// this package never imports those SDKs.
typedef TokenReader = Future<String?> Function();

/// Sets `Authorization: Bearer <token>` when [readToken] returns a value.
class TokenInterceptor extends Interceptor {
  TokenInterceptor(this.readToken);

  final TokenReader readToken;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await readToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    } on Object catch (e, s) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: e,
          stackTrace: s,
        ),
      );
    }
  }
}
