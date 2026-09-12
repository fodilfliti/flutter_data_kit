# flutter_data_kit_drift

Drift-backed local sources, SQLite → `AppFailure` mapping, a persistent
[SyncQueue], and a sign-out wipe hook. Lives in the `flutter_data_kit`
workspace — not a separate GitHub repo.

## Install (path, unpublished)

```yaml
dependencies:
  flutter_data_kit:
    path: ../flutter_data_kit
  flutter_data_kit_drift:
    path: ../flutter_data_kit/packages/flutter_data_kit_drift
  lemsa_core_kit:
    path: ../lemsa_core_kit
```

A Dio or Supabase app does **not** need this package. Drift stays out of
those adapter graphs.

```dart
import 'package:flutter_data_kit_drift/flutter_data_kit_drift.dart';
```

## mapDrift / mapSqlite

Wrap **every** public source method. Same discipline as `mapSupabase`.

```dart
Future<Note> read(String id) => mapDrift(() async {
  final row = await (db.select(db.noteRows)
        ..where((t) => t.id.equals(id)))
      .getSingle();
  return Note(id: row.id, title: row.title, body: row.body);
});
```

`mapSqlite` is an alias of `mapDrift`.

| Vendor | `AppFailure` |
| --- | --- |
| SQLite unique / PK | `ConflictFailure(code: 'unique')` |
| SQLite foreign key | `ConflictFailure(code: 'foreign_key')` |
| SQLite NOT NULL / CHECK | `ValidationFailure` (token only, no user string) |
| Missing row (`getSingle` / empty update) | `NotFoundFailure` |
| IO, busy, corrupt, cantopen, … | `StorageFailure` |
| Anything else | `UnknownFailure` |
| Already `AppFailure` | rethrown unchanged |

`SqliteException` never leaves this package.

## Example local source

[NoteSource] implements `CrudSource<Note, NoteDraft>`. [NotePagedSource]
implements `PagedSource<Note, PagedQuery>`. Both sit on
[DriftKitDatabase] (in-memory in tests, `openDriftKitDatabase()` in apps).

Copy the shape for app tables. Do not return `Map` soup.

## Persistent SyncQueue

Core `InMemorySyncQueue` does not survive process death. Inject
[DriftSyncQueue] instead:

```dart
@Riverpod(keepAlive: true)
DriftKitDatabase driftDb(Ref ref) {
  final db = openDriftKitDatabase();
  ref.onDispose(db.close);
  return db;
}

@Riverpod(keepAlive: true)
SyncQueue syncQueue(Ref ref) => DriftSyncQueue(ref.watch(driftDbProvider));
```

The database schema must include `SyncQueueItems` (already on
`DriftKitDatabase`). Enqueue is persisted; a new connection still sees
pending rows.

`flush` deletes queued rows. Drain `pendingPayloads()` through a real
transport in the app before flushing.

## Sign-out

```dart
await db.deleteUserData();
```

Clears notes and the sync queue. Call from app_kit / the session teardown
path. No UI required — covered by a unit test.

## Migrations

`DriftKitDatabase.schemaVersion` is `2`. Opening a v1 file adds the notes
`body` column. Copy the `onUpgrade` pattern (and a file-backed test) for
app schemas.

## Versions

- `drift` / `drift_dev` `>=2.26.0 <2.30.0` (family floor 2.34.3 needs Dart >=3.10; `drift_dev` 2.30+ fights `flutter_test` on this SDK)
- `sqlite3_flutter_libs` ^0.5.32
- File open via `path_provider` (not `drift_flutter`, which pulls Drift 2.30+)

Optional: `drift_postgres` for shared query code against server Postgres
— not required for typical mobile apps, not a dependency of this package.
