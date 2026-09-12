import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_data_kit_dio/flutter_data_kit_dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemsa_core_kit/lemsa_core_kit.dart';

void main() {
  group('mapDioException', () {
    test('connectionError → NetworkFailure', () {
      expect(
        mapDioException(_dio(type: DioExceptionType.connectionError)),
        isA<NetworkFailure>(),
      );
    });

    test('connectionTimeout → NetworkFailure', () {
      expect(
        mapDioException(_dio(type: DioExceptionType.connectionTimeout)),
        isA<NetworkFailure>(),
      );
    });

    test('sendTimeout → TimeoutFailure', () {
      expect(
        mapDioException(_dio(type: DioExceptionType.sendTimeout)),
        isA<TimeoutFailure>(),
      );
    });

    test('receiveTimeout → TimeoutFailure', () {
      expect(
        mapDioException(_dio(type: DioExceptionType.receiveTimeout)),
        isA<TimeoutFailure>(),
      );
    });

    test('cancel → CancelledFailure', () {
      expect(
        mapDioException(_dio(type: DioExceptionType.cancel)),
        isA<CancelledFailure>(),
      );
    });

    test('401 → AuthFailure expired', () {
      final failure = mapDioException(_dio(status: 401));
      expect(failure, isA<AuthFailure>());
      expect((failure as AuthFailure).reason, AuthReason.expired);
    });

    test('403 → AuthFailure expired', () {
      final failure = mapDioException(_dio(status: 403));
      expect(failure, isA<AuthFailure>());
      expect((failure as AuthFailure).reason, AuthReason.expired);
    });

    test('404 → NotFoundFailure', () {
      final failure = mapDioException(_dio(status: 404));
      expect(failure, isA<NotFoundFailure>());
      expect((failure as NotFoundFailure).what, 'resource');
    });

    test('409 → ConflictFailure with code', () {
      final failure = mapDioException(
        _dio(status: 409, data: {'code': 'version'}),
      );
      expect(failure, isA<ConflictFailure>());
      expect((failure as ConflictFailure).code, 'version');
    });

    test('422 → ValidationFailure field tokens', () {
      final failure = mapDioException(
        _dio(
          status: 422,
          data: {
            'errors': {
              'email': ['taken'],
            },
          },
        ),
      );
      expect(failure, isA<ValidationFailure>());
      expect((failure as ValidationFailure).fields['email'], 'taken');
    });

    test('500 → ServerFailure status+code', () {
      final failure = mapDioException(
        _dio(status: 500, data: {'code': 'boom'}),
      );
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).status, 500);
      expect(failure.code, 'boom');
    });

    test('already-mapped AppFailure is passed through', () {
      const inner = NetworkFailure();
      final failure = mapDioException(
        DioException(
          requestOptions: RequestOptions(path: '/x'),
          error: inner,
        ),
      );
      expect(identical(failure, inner), isTrue);
    });
  });

  test('runDio unwraps DioException to AppFailure', () async {
    await expectLater(
      runDio(() async {
        throw _dio(status: 404);
      }),
      throwsA(isA<NotFoundFailure>()),
    );
  });

  test('runDio does not leak DioException', () async {
    await expectLater(
      runDio(() async {
        throw _dio(type: DioExceptionType.connectionError);
      }),
      throwsA(isA<NetworkFailure>()),
    );
  });

  test('buildDioClient installs FailureInterceptor and token hook', () async {
    String? captured;
    final dio = buildDioClient(
      baseUrl: 'https://example.test',
      readToken: () async => 'jwt-token',
    );
    expect(dio.interceptors.whereType<FailureInterceptor>(), isNotEmpty);
    expect(dio.interceptors.whereType<TokenInterceptor>(), isNotEmpty);

    dio.httpClientAdapter = _OkAdapter((options) {
      captured = options.headers['Authorization'] as String?;
    });
    await dio.get<void>('/ping');
    expect(captured, 'Bearer jwt-token');
  });
}

DioException _dio({
  DioExceptionType type = DioExceptionType.badResponse,
  int? status,
  Object? data,
}) {
  final options = RequestOptions(path: '/x');
  return DioException(
    requestOptions: options,
    type: type,
    response:
        status == null
            ? null
            : Response<dynamic>(
              requestOptions: options,
              statusCode: status,
              data: data,
            ),
  );
}

class _OkAdapter implements HttpClientAdapter {
  _OkAdapter(this.onFetch);

  final void Function(RequestOptions options) onFetch;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    onFetch(options);
    return ResponseBody.fromString(
      '{}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}
