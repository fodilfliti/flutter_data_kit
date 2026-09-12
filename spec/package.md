# flutter_data_kit

Pub workspace: core package at repo root, adapters under `packages/`.

## Layers (core)

| Layer | Path | Role |
| --- | --- | --- |
| Barrel | `lib/flutter_data_kit.dart` | Only public export |
| Paged | `lib/src/paged/` | Query, state, source, `PagedList` mixin |
| Cache | `lib/src/cache/` | `ref.cacheFor` |
| Source | `lib/src/source/` | `DataSource`, `Repository`, `CrudSource` |
| Sync | `lib/src/sync/` | `SyncQueue` + in-memory stub |

## Public API (core)

- `Identifiable`
- `PagedQuery`, `PagedResult<T>`, `PagedState<T>`, `PagedSource<T,Q>`
- `PagedList<T,Q>` mixin
- `Ref.cacheFor`
- `CrudSource`, `DataSource`, `Repository`
- `SyncQueue`, `InMemorySyncQueue`

`Change` / `Created` / `Updated` / `Deleted` come from `lemsa_core_kit` — not redefined.

## Adapters

| Package | Public API |
| --- | --- |
| `flutter_data_kit_dio` | `buildDioClient`, `FailureInterceptor`, `TokenInterceptor` / `TokenReader`, `mapDioException`, `runDio`, `readCode`, `readFieldErrors` |
| `flutter_data_kit_supabase` | `mapSupabase`, `authReasonFrom`, `Note`, `NoteDraft`, `NoteSource` |

Firebase and Drift: stub README only.

## Depends on (core)

`lemsa_core_kit` (path), Flutter, `flutter_riverpod` (for `AsyncValue` + `Ref.cacheFor`).

## Must not depend on (core)

`dio`, `supabase_flutter`, `firebase_*`, `drift`.
