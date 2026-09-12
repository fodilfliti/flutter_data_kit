# flutter_data_kit_dio

Dio client factory + [FailureInterceptor] mapping `DioException` → `AppFailure`.

Token attachment is a **callback** (`TokenReader`) — this package does not
depend on Firebase. The app supplies `() => firebaseUser.getIdToken()`.

Use [runDio] on every public REST source method so `DioException` never
escapes the adapter.
