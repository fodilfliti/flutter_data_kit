# flutter_data_kit_firebase

Firebase Auth / Firestore / Storage / FCM adapter for `flutter_data_kit`.

**Supabase-only apps must not depend on this package.** A Supabase app should
pull `flutter_data_kit` + `flutter_data_kit_supabase` only.

## Install (path, unpublished)

```yaml
dependencies:
  flutter_data_kit:
    path: ../../flutter_data_kit   # or your path
  flutter_data_kit_firebase:
    path: ../../flutter_data_kit/packages/flutter_data_kit_firebase
  lemsa_core_kit:
    path: ../../lemsa_core_kit
```

Apps must also run `Firebase.initializeApp()` (with their own
`GoogleService-Info.plist` / `google-services.json` — never shipped in this kit).

## Firebase packages (pinned for FVM Flutter 3.35.7)

| Package | Version |
| --- | --- |
| `firebase_core` | ^4.14.0 |
| `firebase_auth` | ^6.6.1 |
| `cloud_firestore` | ^6.9.0 |
| `firebase_storage` | ^13.5.0 |
| `firebase_messaging` | ^16.6.0 |

No `dio`, `supabase_flutter`, or `drift` — compose adapters in the app.

## `mapFirebase`

Wrap **every** public source method:

```dart
Future<Note> read(String id) => mapFirebase(() async {
  // Firestore / Auth / Storage calls here
});
```

### Mapping table

| Firebase code / type | `AppFailure` |
| --- | --- |
| `unavailable`, `network-request-failed` | `NetworkFailure` |
| `deadline-exceeded` | `TimeoutFailure` |
| `permission-denied` | `PermissionFailure` |
| `not-found` | `NotFoundFailure` |
| `already-exists` | `ConflictFailure` |
| `cancelled` / `canceled` | `CancelledFailure` |
| `unauthenticated` | `AuthFailure(signedOut)` |
| `resource-exhausted` | `AuthFailure(rateLimited)` |
| `invalid-argument`, `failed-precondition` | `ValidationFailure` |
| Auth: `invalid-credential`, `wrong-password`, … | `AuthFailure(invalidCredentials)` |
| Auth: `user-disabled` | `AuthFailure(disabled)` |
| Auth: `too-many-requests` | `AuthFailure(rateLimited)` |
| Auth: `requires-recent-login`, token expiry | `AuthFailure(expired)` |
| Auth: `email-not-verified` | `AuthFailure(emailNotConfirmed)` |
| `firebase_storage` (other codes) | `StorageFailure` |
| else | `ServerFailure` / `UnknownFailure` |

Existing `AppFailure`s are rethrown. Failures carry **no** user-facing strings.

## Auth

Apps map the session stream — this kit does **not** hardcode Riverpod providers:

```dart
@Riverpod(keepAlive: true)
Stream<FirebaseSession?> session(Ref ref) {
  return watchFirebaseSession(FirebaseAuth.instance);
}
```

Optional kiwash-style bearer for Dio (no dio dependency here):

```dart
buildDioClient(
  readToken: firebaseIdTokenReader(FirebaseAuth.instance),
);
```

Thin helpers: `signInWithEmailPassword`, `signOutFirebase` — all wrapped in
`mapFirebase`. Public returns use `FirebaseSession`, not `User`.

## Firestore

`NoteSource` + `FirestoreNotesCollection` are a typed CRUD example for a
`notes` collection. Inject `NotesCollection` so tests can use an in-memory fake
without a real Firebase project.

## Storage

`FirebaseObjectStorage` — `uploadBytes` / `downloadBytes` / `delete`, mapped
via `mapFirebase` (storage plugin → usually `StorageFailure`).

## FCM

`FirebaseMessagingHelper` — `requestPermission` + `getToken` only. Notification
handlers and UI stay in the app.

## Tests

Mapper table + wrapped `NoteSource` run without a Firebase project (synthetic
`FirebaseException`s and a fake `NotesCollection`).
