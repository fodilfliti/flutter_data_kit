import 'package:drift/drift.dart';

/// Example local row for `NoteSource`. Copy this shape; do not store Maps.
class NoteRows extends Table {
  TextColumn get id => text()();

  TextColumn get title => text().withLength(min: 1, max: 512)();

  /// Added in schema v2 (see DriftKitDatabase.schemaVersion).
  TextColumn get body => text().nullable()();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Offline enqueue + dirty-id rows for `DriftSyncQueue`.
///
/// Include this table in the app `@DriftDatabase` and pass that database to
/// `DriftSyncQueue`.
class SyncQueueItems extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// `enqueue` | `dirty`
  TextColumn get kind => text().withLength(min: 1, max: 16)();

  TextColumn get payloadJson => text()();

  TextColumn get entityId => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
