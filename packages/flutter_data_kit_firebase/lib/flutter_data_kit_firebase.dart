/// Firebase adapter for flutter_data_kit.
///
/// `mapFirebase` converts Firebase Auth / Firestore / Storage / Messaging
/// exceptions into `AppFailure`. Wrap every public source method.
///
/// Supabase-only apps must **not** depend on this package.
library;

export 'src/auth/firebase_auth_helpers.dart';
export 'src/fcm/firebase_messaging_helper.dart';
export 'src/firestore/note.dart';
export 'src/firestore/note_source.dart';
export 'src/firestore/notes_collection.dart';
export 'src/map_firebase.dart';
export 'src/storage/firebase_object_storage.dart';
