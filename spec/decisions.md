# Decisions

## D1 — One git repo, pub workspace for adapters

**Choice:** `flutter_data_kit` + `_dio` + `_supabase` in one repo (`resolution: workspace`).

**Why:** Adapters are version-locked to the contract. Splitting repos would mean
coordinating N releases per contract change. Apps still depend on only the
adapters they need, so a Supabase app never resolves Firebase.

## D2 — cacheFor after success

**Choice:** `keepAlive` + `Timer` + `onDispose(timer.cancel)`. Call after a
successful await. `Ref.listenSelf` is codegen-only in Riverpod 3.3, so the
kit does not hook AsyncError from `Ref`.

**Why:** A bare `keepAlive: true` caches failures. Placement after await is the
documented contract; the AsyncError guard covers mistaken early calls.

**SDK note:** Family floor lists `flutter_riverpod` 3.4.2, which requires Dart
`>=3.12`. FVM pin 3.35.7 ships Dart 3.9.2, so this kit depends on `^3.3.2`
(Riverpod 3, Dart `>=3.7`).

## D3 — PagedList mixin does not `on AsyncNotifier`

**Choice:** Abstract `state` getter/setter so tests can host the mixin without
`ProviderScope`. Generated/manual AsyncNotifiers already provide `state`.

**Why:** Unit-test upsert/loadMore without pumping a container. The bridge.md
snippet that returns a query from `build()` is schematic; `build()` returns
`Future<PagedState<T>>` via `fetchFirstPage()`.

## D4 — No freezed in the kit

**Choice:** `PagedState` implements `==` / `hashCode` (Riverpod 3 notification filter).

**Why:** Avoid build_runner in the kit. Apps may still wrap their own query types
in freezed.

## D5 — TokenReader callback, not Firebase

**Choice:** Dio token interceptor takes `Future<String?> Function()`.

**Why:** kiwash hard-depends on FirebaseAuth inside the client. The adapter must
not.

## D6 — InMemorySyncQueue is a stub

**Choice:** Process-local list. `flush` clears without I/O. Documented.

**Why:** Offline persistence belongs in `flutter_data_kit_drift` (later).
Controllers can still call `enqueue` for the queued-offline branch.

## D7 — Firebase / Drift stub READMEs only

**Choice:** No pubspec, no code.

**Why:** T13 scope. Adding packages now would pull those SDKs into the workspace
lockfile.
