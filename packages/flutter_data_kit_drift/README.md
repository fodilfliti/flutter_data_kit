# flutter_data_kit_drift

Drift-backed local source and a persistent [SyncQueue]. **Later** — not in T13.

Will own SQLite → `AppFailure` mapping, local tables, migrations, and reactive
queries. The core [InMemorySyncQueue] is a process-local stub until this lands.

Not a dependency of `flutter_data_kit_supabase` or `_dio`.
