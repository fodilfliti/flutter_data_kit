import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_data_kit_firebase/src/firestore/note.dart';

/// Low-level ops for one notes collection.
///
/// Throws vendor Firebase exceptions — `NoteSource` wraps with `mapFirebase`.
/// Tests inject an in-memory fake; production uses [FirestoreNotesCollection].
abstract interface class NotesCollection {
  Future<Map<String, dynamic>> insert(Map<String, dynamic> data);
  Future<Map<String, dynamic>> get(String id);
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> data);
  Future<void> delete(String id);
  Future<List<({String id, Map<String, dynamic> data})>> list();
}

/// Production [NotesCollection] over Cloud Firestore.
class FirestoreNotesCollection implements NotesCollection {
  FirestoreNotesCollection(
    this.firestore, {
    this.collection = 'notes',
  });

  final FirebaseFirestore firestore;
  final String collection;

  CollectionReference<Map<String, dynamic>> get _col =>
      firestore.collection(collection);

  @override
  Future<Map<String, dynamic>> insert(Map<String, dynamic> data) async {
    final ref = await _col.add(data);
    final snap = await ref.get();
    final doc = snap.data();
    if (doc == null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'not-found',
        message: 'missing',
      );
    }
    return {'id': ref.id, ...doc};
  }

  @override
  Future<Map<String, dynamic>> get(String id) async {
    final snap = await _col.doc(id).get();
    final doc = snap.data();
    if (doc == null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'not-found',
        message: 'missing',
      );
    }
    return {'id': snap.id, ...doc};
  }

  @override
  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> data,
  ) async {
    await _col.doc(id).update(data);
    return get(id);
  }

  @override
  Future<void> delete(String id) => _col.doc(id).delete();

  @override
  Future<List<({String id, Map<String, dynamic> data})>> list() async {
    final snap = await _col.get();
    return [
      for (final doc in snap.docs) (id: doc.id, data: doc.data()),
    ];
  }
}

/// Convenience: build a [Note] from a store row that includes `id`.
Note noteFromRow(Map<String, dynamic> row) {
  final id = row['id']! as String;
  final data = Map<String, dynamic>.from(row)..remove('id');
  return Note.fromDoc(id, data);
}
