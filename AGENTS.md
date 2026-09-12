# Agent instructions — Flutter Data Kit

This is a **Dart pub workspace**: core package `flutter_data_kit` plus adapters
under `packages/`. One git repo; adapters publish separately later.

## Load context

1. Read `spec/README.md`, then `package.md` / `invariants.md` / `decisions.md`.
2. Use **code** under `lib/` and `packages/*/lib/` as implementation truth.
3. Do **not** ingest `README.md` as working memory.

## Working rules

- Core public API only via `lib/flutter_data_kit.dart`.
- Core must **not** depend on dio, supabase_flutter, firebase_*, or drift.
- Vendor exceptions stop at adapters. Map to `AppFailure` (no message strings).
- Repositories **throw** `AppFailure`. Never `Either<String, T>`.
- `empty_catches` is an analyzer **error**.
- Call `ref.cacheFor` **after** a successful await so failures are not cached.

## Flutter SDK

Pinned in `.fvmrc` to **3.35.7**. Use `fvm flutter` / `fvm dart`. Never run
`flutter upgrade` / `flutter channel` on `C:\Users\lemsa\Documents\flutter`.

## Out of scope unless asked

Publishing, full firebase/drift adapters (stub READMEs only), flutter_input_kit,
flutter_nav_kit, flutter_app_kit, migrating kiwash/lightnessword.
