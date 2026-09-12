import 'package:drift/drift.dart';
import 'package:flutter_data_kit_drift/src/map_drift.dart';
import 'package:flutter_data_kit_drift/src/tables.dart';

part 'drift_kit_database.g.dart';

/// Example Drift database: notes + sync queue.
///
/// Apps may use this as a starting point or copy [NoteRows] /
/// [SyncQueueItems] into their own `@DriftDatabase`.
@DriftDatabase(tables: [NoteRows, SyncQueueItems])
class DriftKitDatabase extends _$DriftKitDatabase {
  DriftKitDatabase(super.executor);

  /// v1: notes without `body`. v2: add nullable `body`.
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(noteRows, noteRows.body);
      }
    },
  );

  /// Sign-out / account switch — wipe user tables (app_kit hook).
  ///
  /// Testable without UI. Apps with extra tables should override or
  /// extend this in their own database class.
  Future<void> deleteUserData() => mapDrift(() async {
    await batch((b) {
      b.deleteWhere(noteRows, (_) => const Constant(true));
      b.deleteWhere(syncQueueItems, (_) => const Constant(true));
    });
  });
}
