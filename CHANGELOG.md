# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.1] - 2026-09-12

### Added

- Workspace: `flutter_data_kit` core + `_dio` + `_supabase` + `_firebase` + `_drift`.
- `PagedQuery`, `PagedState`, `PagedSource`, `PagedList` mixin (loadMore / refresh / setQuery / upsert / removeById / patch / apply).
- `ref.cacheFor(Duration)` — failed fetches are not kept alive.
- `CrudSource` / `DataSource` / `Repository` throw-`AppFailure` contracts.
- `SyncQueue` + in-memory stub (no persistence).
- Dio `buildDioClient`, `FailureInterceptor`, `TokenReader` hook, `runDio`.
- Supabase `mapSupabase` + typed `NoteSource` example.
- Firebase `mapFirebase` + Auth helpers + Firestore `NoteSource` + Storage + FCM helpers.
- Drift adapter (`packages/flutter_data_kit_drift`): `mapDrift` / `mapSqlite`,
  example `NoteSource` / `NotePagedSource`, persistent `DriftSyncQueue`,
  `deleteUserData`, schema v1→v2 migration test.
