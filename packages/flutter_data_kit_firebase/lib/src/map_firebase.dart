import 'package:firebase_auth/firebase_auth.dart';
import 'package:lemsa_core_kit/lemsa_core_kit.dart';

/// Runs [body] and maps Firebase vendor exceptions to [AppFailure].
///
/// Wrap **every** public source method — unlike Dio, Firebase has no
/// interceptor that cannot be forgotten.
///
/// Existing [AppFailure]s are rethrown unchanged. Failures carry no
/// user-facing message strings.
Future<T> mapFirebase<T>(Future<T> Function() body) async {
  try {
    return await body();
  } on AppFailure {
    rethrow;
  } on FirebaseAuthException catch (e, s) {
    throw _mapAuth(e, s);
  } on FirebaseException catch (e, s) {
    throw _mapFirebase(e, s);
  } catch (e, s) {
    if (_isNetworkException(e)) {
      throw NetworkFailure(cause: e, trace: s);
    }
    throw UnknownFailure(cause: e, trace: s);
  }
}

/// Maps Firebase Auth codes to [AuthReason] (no user-facing strings).
AuthReason authReasonFrom(FirebaseAuthException error) {
  switch (error.code) {
    case 'invalid-credential':
    case 'invalid-email':
    case 'wrong-password':
    case 'user-not-found':
    case 'INVALID_LOGIN_CREDENTIALS':
      return AuthReason.invalidCredentials;
    case 'user-disabled':
      return AuthReason.disabled;
    case 'too-many-requests':
      return AuthReason.rateLimited;
    case 'user-token-expired':
    case 'invalid-user-token':
    case 'requires-recent-login':
    case 'expired-action-code':
    case 'invalid-action-code':
      return AuthReason.expired;
    case 'email-not-verified':
      return AuthReason.emailNotConfirmed;
    case 'no-current-user':
      return AuthReason.signedOut;
    default:
      return AuthReason.invalidCredentials;
  }
}

AppFailure _mapAuth(FirebaseAuthException e, StackTrace s) {
  return AuthFailure(authReasonFrom(e), cause: e);
}

AppFailure _mapFirebase(FirebaseException e, StackTrace s) {
  final code = e.code;
  final plugin = e.plugin;

  switch (code) {
    case 'unavailable':
    case 'network-request-failed':
      return NetworkFailure(cause: e, trace: s);
    case 'deadline-exceeded':
      return TimeoutFailure(cause: e, trace: s);
    case 'permission-denied':
      return PermissionFailure(_permissionWhat(plugin), cause: e);
    case 'not-found':
      return NotFoundFailure(_notFoundWhat(plugin), cause: e);
    case 'already-exists':
      return ConflictFailure(code: code, cause: e);
    case 'cancelled':
    case 'canceled':
      return const CancelledFailure();
    case 'unauthenticated':
      return AuthFailure(AuthReason.signedOut, cause: e);
    case 'resource-exhausted':
      return AuthFailure(AuthReason.rateLimited, cause: e);
    case 'invalid-argument':
    case 'failed-precondition':
      return ValidationFailure({'_': code}, cause: e);
  }

  if (plugin == 'firebase_storage' || plugin == 'storage') {
    return StorageFailure(cause: e, trace: s);
  }

  return ServerFailure(code: code, cause: e, trace: s);
}

String _permissionWhat(String plugin) {
  if (plugin.contains('storage')) {
    return 'storage';
  }
  if (plugin.contains('auth')) {
    return 'auth';
  }
  return 'document';
}

String _notFoundWhat(String plugin) {
  if (plugin.contains('storage')) {
    return 'object';
  }
  return 'document';
}

bool _isNetworkException(Object error) {
  final name = error.runtimeType.toString();
  return name == 'SocketException' ||
      name == 'ClientException' ||
      name == 'HandshakeException' ||
      name == 'TlsException';
}
