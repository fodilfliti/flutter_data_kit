import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_data_kit_drift/flutter_data_kit_drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('upgrades v1 notes schema by adding body', () async {
    final dir = await Directory.systemTemp.createTemp('drift_mig');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/notes.sqlite');

    final sqlite = sqlite3.open(file.path);
    sqlite
      ..execute('''
        CREATE TABLE note_rows (
          id TEXT NOT NULL PRIMARY KEY,
          title TEXT NOT NULL,
          updated_at INTEGER NOT NULL DEFAULT 0
        );
      ''')
      ..execute('''
        CREATE TABLE sync_queue_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          kind TEXT NOT NULL,
          payload_json TEXT NOT NULL,
          entity_id TEXT NULL,
          created_at INTEGER NOT NULL DEFAULT 0
        );
      ''')
      ..execute(
        'INSERT INTO note_rows (id, title, updated_at) '
        "VALUES ('old', 'v1', 0);",
      )
      ..execute('PRAGMA user_version = 1;')
      ..close();

    final db = DriftKitDatabase(NativeDatabase(file));
    addTearDown(db.close);

    final columns = await db.customSelect('PRAGMA table_info(note_rows)').get();
    final names = columns.map((row) => row.read<String>('name')).toList();
    expect(names, contains('body'));

    final source = NoteSource(db);
    final migrated = await source.read('old');
    expect(migrated.title, 'v1');
    expect(migrated.body, isNull);

    final created = await source.create(
      const NoteDraft(id: 'new', title: 'v2', body: 'hello'),
    );
    expect(created.body, 'hello');
  });
}
