import 'package:drift/drift.dart';
import 'package:flutter_data_kit/flutter_data_kit.dart';
import 'package:flutter_data_kit_drift/src/drift_kit_database.dart';
import 'package:flutter_data_kit_drift/src/map_drift.dart';
import 'package:flutter_data_kit_drift/src/note.dart';

/// Example [PagedSource] over local notes, newest first.
class NotePagedSource implements PagedSource<Note, PagedQuery> {
  NotePagedSource(this.db);

  final DriftKitDatabase db;

  @override
  Future<PagedResult<Note>> fetch(PagedQuery query) => mapDrift(() async {
    final offset = (query.page - 1) * query.pageSize;
    final rows =
        await (db.select(db.noteRows)
              ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
              ..limit(query.pageSize + 1, offset: offset))
            .get();
    final hasMore = rows.length > query.pageSize;
    final page = hasMore ? rows.take(query.pageSize) : rows;
    return PagedResult(
      items: page
          .map((row) => Note(id: row.id, title: row.title, body: row.body))
          .toList(growable: false),
      hasMore: hasMore,
    );
  });
}
