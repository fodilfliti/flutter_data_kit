# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.1] - 2026-09-12

### Added

- Workspace: `flutter_data_kit` core + `flutter_data_kit_dio` + `flutter_data_kit_supabase`.
- `PagedQuery`, `PagedState`, `PagedSource`, `PagedList` mixin (loadMore / refresh / setQuery / upsert / removeById / patch / apply).
- `ref.cacheFor(Duration)` — failed fetches are not kept alive.
- `CrudSource` / `DataSource` / `Repository` throw-`AppFailure` contracts.
- `SyncQueue` + in-memory stub (no persistence).
- Dio `buildDioClient`, `FailureInterceptor`, `TokenReader` hook, `runDio`.
- Supabase `mapSupabase` + typed `NoteSource` example.
- Stub READMEs for firebase and drift adapters.
