# Invariants

- Public core export **only** via `lib/flutter_data_kit.dart`.
- Core has **no** dio / supabase / firebase / drift dependencies or imports.
- Vendor exception types are not re-exported from adapter barrels.
- Every public adapter source method is wrapped (`runDio` / interceptor, `mapSupabase`, `mapFirebase`, or `mapDrift`).
- Repositories and sources **throw** `AppFailure`. No `Either<String, T>`.
- `AppFailure` carries **no** user message. Mappers use field/code tokens only.
- `ref.cacheFor` must not keep a failed fetch alive.
- `PagedList` writes (`upsert` / `removeById` / `patch` / `apply`) are local.
- `setQuery` refetches from page 1 (no client-side filter of already-loaded pages).
- Empty `catch` is banned (`empty_catches: error`).
- Do not redefine `Change` / `Created` / `Updated` / `Deleted`.
