import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_data_kit_firebase/src/map_firebase.dart';

/// Thin Storage upload/download helpers. Errors map via `mapFirebase`
/// (usually `StorageFailure` for the storage plugin).
class FirebaseObjectStorage {
  FirebaseObjectStorage(this.storage);

  final FirebaseStorage storage;

  /// Uploads [bytes] to [path] and returns the download URL string.
  Future<String> uploadBytes({
    required String path,
    required Uint8List bytes,
    String? contentType,
  }) => mapFirebase(() async {
    final ref = storage.ref(path);
    final meta =
        contentType == null ? null : SettableMetadata(contentType: contentType);
    await ref.putData(bytes, meta);
    return ref.getDownloadURL();
  });

  /// Downloads object bytes at [path].
  Future<Uint8List> downloadBytes(String path) => mapFirebase(() async {
    final data = await storage.ref(path).getData();
    if (data == null) {
      throw FirebaseException(
        plugin: 'firebase_storage',
        code: 'not-found',
        message: 'missing',
      );
    }
    return data;
  });

  /// Deletes the object at [path].
  Future<void> delete(String path) => mapFirebase(() async {
    await storage.ref(path).delete();
  });
}
