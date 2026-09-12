import 'package:drift/drift.dart';
import 'package:flutter_data_kit/flutter_data_kit.dart';
import 'package:flutter_data_kit_drift/src/drift_kit_database.dart';
import 'package:flutter_data_kit_drift/src/map_drift.dart';
import 'package:flutter_data_kit_drift/src/note.dart';
import 'package:lemsa_core_kit/lemsa_core_kit.dart';

/// Example typed CRUD source backed by [DriftKitDatabase.noteRows].
///
/// Every public method is wrapped in [mapDrift]. Copy this shape for
/// app tables — do not return `Map<String, dynamic>` from sources.
class NoteSource implements CrudSource<Note, NoteDraft>, DataSource {
  NoteSource(this.db);

  final DriftKitDatabase db;

  @override
  Future<Note> create(NoteDraft draft) => mapDrift(() async {
    final id = draft.id ?? _allocateId();
    final row = await db
        .into(db.noteRows)
        .insertReturning(
          NoteRowsCompanion.insert(
            id: id,
            title: draft.title,
            body: Value(draft.body),
          ),
        );
    return _toNote(row);
  });

  @override
  Future<Note> read(String id) => mapDrift(() async {
    final row =
        await (db.select(
          db.noteRows,
        )..where((t) => t.id.equals(id))).getSingle();
    return _toNote(row);
  });

  @override
  Future<Note> update(Note entity) => mapDrift(() async {
    final count = await (db.update(
      db.noteRows,
    )..where((t) => t.id.equals(entity.id))).write(
      NoteRowsCompanion(
        title: Value(entity.title),
        body: Value(entity.body),
        updatedAt: Value(DateTime.now()),
      ),
    );
    if (count == 0) {
      throw const NotFoundFailure('row');
    }
    final row =
        await (db.select(
          db.noteRows,
        )..where((t) => t.id.equals(entity.id))).getSingle();
    return _toNote(row);
  });

  @override
  Future<void> delete(String id) => mapDrift(() async {
    final count =
        await (db.delete(
          db.noteRows,
        )..where((t) => t.id.equals(id))).go();
    if (count == 0) {
      throw const NotFoundFailure('row');
    }
  });

  Future<List<Note>> list() => mapDrift(() async {
    final rows = await db.select(db.noteRows).get();
    return rows.map(_toNote).toList(growable: false);
  });
}

Note _toNote(NoteRow row) {
  return Note(id: row.id, title: row.title, body: row.body);
}

String _allocateId() {
  return DateTime.now().toUtc().microsecondsSinceEpoch.toString();
}
