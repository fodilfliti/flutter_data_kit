import 'package:lemsa_core_kit/lemsa_core_kit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Runs [body] and maps vendor exceptions to [AppFailure].
///
/// Wrap **every** public source method — unlike Dio, Supabase has no
/// interceptor that cannot be forgotten.
Future<T> mapSupabase<T>(Future<T> Function() body) async {
  try {
    return await body();
  } on AppFailure {
    rethrow;
  } on PostgrestException catch (e, s) {
    throw switch (e.code) {
      '23505' => ValidationFailure({'_': 'duplicate'}, cause: e),
      '23503' => ConflictFailure(code: e.code, cause: e),
      '42501' => PermissionFailure('row', cause: e),
      'PGRST116' => NotFoundFailure('row', cause: e),
      _ => ServerFailure(code: e.code, cause: e, trace: s),
    };
  } on AuthException catch (e) {
    throw AuthFailure(authReasonFrom(e), cause: e);
  } on StorageException catch (e, s) {
    throw StorageFailure(cause: e, trace: s);
  } catch (e, s) {
    if (_isNetworkException(e)) {
      throw NetworkFailure(cause: e, trace: s);
    }
    throw UnknownFailure(cause: e, trace: s);
  }
}

/// Maps GoTrue [AuthException] to [AuthReason] (no user-facing strings).
AuthReason authReasonFrom(AuthException error) {
  final code = error.code ?? '';
  switch (code) {
    case 'invalid_credentials':
    case 'invalid_grant':
      return AuthReason.invalidCredentials;
    case 'email_not_confirmed':
      return AuthReason.emailNotConfirmed;
    case 'session_not_found':
    case 'bad_jwt':
    case 'invalid_jwt':
    case 'user_not_found':
      return AuthReason.expired;
    case 'user_banned':
    case 'user_disabled':
      return AuthReason.disabled;
    case 'over_request_rate_limit':
    case 'over_email_send_rate_limit':
      return AuthReason.rateLimited;
  }
  final status = error.statusCode;
  if (status == '401') {
    return AuthReason.expired;
  }
  if (status == '403') {
    return AuthReason.disabled;
  }
  if (status == '429') {
    return AuthReason.rateLimited;
  }
  return AuthReason.invalidCredentials;
}

bool _isNetworkException(Object error) {
  final name = error.runtimeType.toString();
  return name == 'SocketException' ||
      name == 'ClientException' ||
      name == 'HandshakeException' ||
      name == 'TlsException';
}
