---
name: flutter-data-kit
description: >
  Use flutter_data_kit for PagedList mixins, PagedSource, cacheFor, SyncQueue,
  and AppFailure-throwing repositories. Use flutter_data_kit_dio for Dio
  FailureInterceptor/runDio, flutter_data_kit_supabase for mapSupabase, and
  flutter_data_kit_drift for mapDrift / DriftSyncQueue. Activate for
  pagination, list upsert after save, vendor error mapping, and offline
  enqueue — not for form controllers, navigation, or the Firebase adapter
  (not shipped).
license: MIT
metadata:
  author: fodilfliti
  version: "0.0.1"
  homepage: https://pub.dev/packages/flutter_data_kit
---

# flutter_data_kit (consumer)

## Imports

```dart
import 'package:flutter_data_kit/flutter_data_kit.dart';
import 'package:flutter_data_kit_dio/flutter_data_kit_dio.dart';
import 'package:flutter_data_kit_supabase/flutter_data_kit_supabase.dart';
import 'package:flutter_data_kit_drift/flutter_data_kit_drift.dart';
```

Depend on core plus **only** the adapters this app needs.

## Rules

- Sources and repositories **throw** `AppFailure`. Controllers catch. Do not
  return `Either<String, T>`.
- Map vendor exceptions only in adapters. Never catch `DioException` /
  `PostgrestException` in a controller.
- `AppFailure` has no user message. Localize in the app.
- After a form save, `notifier.upsert(saved)` — do not `ref.invalidate` the list.
- Filters go through `setQuery` (server-side). Do not client-filter paginated lists.
- Call `ref.cacheFor(duration)` **after** a successful fetch so errors are not cached.
- Wrap every Supabase source method in `mapSupabase`. Use `runDio` (and the
  Dio `FailureInterceptor`) on REST sources. Wrap every Drift source method
  in `mapDrift`. Inject `DriftSyncQueue` for a persistent `SyncQueue`.
- Token for Dio: pass `readToken: () => yourJwt()`. Do not import Firebase in
  the adapter.

## PagedList

```dart
@riverpod
class ItemList extends _$ItemList with PagedList<Item, ItemQuery> {
  @override
  PagedSource<Item, ItemQuery> get source => ref.watch(itemSourceProvider);

  @override
  ItemQuery get initialQuery => const ItemQuery(pageSize: 20);

  @override
  ItemQuery queryWithPage(ItemQuery query, int page) =>
      ItemQuery(page: page, pageSize: query.pageSize, search: query.search);

  @override
  Future<PagedState<Item>> build() => fetchFirstPage();
}
```

`Item` must implement `Identifiable` (`String id`). Use `Change` from
`lemsa_core_kit` with `apply`.

## Do not put here

| Concern | Where |
| --- | --- |
| AppFailure / Result / Change types | `lemsa_core_kit` |
| Form controllers / busy / Notices | `flutter_page_kit` |
| Firebase adapter | not shipped yet |
| Persistent SyncQueue / local SQL | `flutter_data_kit_drift` (`DriftSyncQueue`, `mapDrift`) |
