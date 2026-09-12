/// Dio adapter for flutter_data_kit.
///
/// FailureInterceptor maps Dio errors to AppFailure. Use runDio in sources
/// so DioException never reaches controllers.
library;

export 'src/build_dio_client.dart';
export 'src/failure_interceptor.dart';
export 'src/map_dio.dart';
export 'src/run_dio.dart';
export 'src/token_interceptor.dart';
