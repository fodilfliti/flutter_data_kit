import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_data_kit_firebase/src/map_firebase.dart';

/// Kit-owned session snapshot — no [User] on the public API.
@immutable
class FirebaseSession {
  const FirebaseSession({
    required this.uid,
    this.email,
  });

  final String uid;
  final String? email;

  @override
  bool operator ==(Object other) =>
      other is FirebaseSession && other.uid == uid && other.email == email;

  @override
  int get hashCode => Object.hash(uid, email);
}

/// Maps `auth.authStateChanges()` → [FirebaseSession]? for app StreamNotifiers.
///
/// Apps own the Riverpod / session provider. Typical shape:
/// ```dart
/// @Riverpod(keepAlive: true)
/// Stream<FirebaseSession?> session(Ref ref) {
///   return watchFirebaseSession(FirebaseAuth.instance);
/// }
/// ```
Stream<FirebaseSession?> watchFirebaseSession(FirebaseAuth auth) {
  return auth.authStateChanges().map(_toSession);
}

FirebaseSession? _toSession(User? user) {
  if (user == null) {
    return null;
  }
  return FirebaseSession(uid: user.uid, email: user.email);
}

/// Callback shape compatible with Dio `TokenReader` / `buildDioClient(readToken:)`.
///
/// No dependency on the dio adapter — consumers compose packages.
typedef IdTokenReader = Future<String?> Function();

/// kiwash-style JWT reader for REST clients (Firebase Auth → bearer).
IdTokenReader firebaseIdTokenReader(
  FirebaseAuth auth, {
  bool forceRefresh = false,
}) {
  return () => mapFirebase(() async {
    final user = auth.currentUser;
    if (user == null) {
      return null;
    }
    return user.getIdToken(forceRefresh);
  });
}

/// Email/password sign-in wrapped in [mapFirebase].
Future<FirebaseSession> signInWithEmailPassword(
  FirebaseAuth auth, {
  required String email,
  required String password,
}) => mapFirebase(() async {
  final cred = await auth.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
  final user = cred.user;
  if (user == null) {
    throw FirebaseAuthException(
      code: 'no-current-user',
      message: 'missing',
    );
  }
  return FirebaseSession(uid: user.uid, email: user.email);
});

/// Sign out wrapped in [mapFirebase].
Future<void> signOutFirebase(FirebaseAuth auth) => mapFirebase(auth.signOut);
