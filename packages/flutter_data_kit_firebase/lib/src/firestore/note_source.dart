import 'package:flutter_data_kit/flutter_data_kit.dart';
import 'package:flutter_data_kit_firebase/src/firestore/note.dart';
import 'package:flutter_data_kit_firebase/src/firestore/notes_collection.dart';
import 'package:flutter_data_kit_firebase/src/map_firebase.dart';

/// Example typed CRUD source for a single Firestore `notes` collection.
///
/// Every public method is wrapped in [mapFirebase]. Copy this shape for
/// app collections — do not return `Map<String, dynamic>` from sources.
class NoteSource implements CrudSource<Note, NoteDraft>, DataSource {
  NoteSource(this.collection);

  /// Inject [FirestoreNotesCollection] in apps; fakes in tests.
  final NotesCollection collection;

  @override
  Future<Note> create(NoteDraft draft) => mapFirebase(() async {
    final row = await collection.insert(draft.toDoc());
    return noteFromRow(row);
  });

  @override
  Future<Note> read(String id) => mapFirebase(() async {
    final row = await collection.get(id);
    return noteFromRow(row);
  });

  @override
  Future<Note> update(Note entity) => mapFirebase(() async {
    final row = await collection.update(entity.id, entity.toDoc());
    return noteFromRow(row);
  });

  @override
  Future<void> delete(String id) => mapFirebase(() async {
    await collection.delete(id);
  });

  Future<List<Note>> list() => mapFirebase(() async {
    final rows = await collection.list();
    return [
      for (final row in rows) Note.fromDoc(row.id, row.data),
    ];
  });
}
