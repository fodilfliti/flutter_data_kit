# flutter_data_kit

Backend contracts, pagination (`PagedList`), cache policy (`cacheFor`), and
failure mapping for Lemsa Flutter apps. Vendor SDKs live in **adapter
packages** in this repo.

## Workspace

| Package | Role |
| --- | --- |
| `flutter_data_kit` | Contracts, `PagedList`, `cacheFor`, `SyncQueue` |
| `flutter_data_kit_dio` | Dio client + `FailureInterceptor` |
| `flutter_data_kit_supabase` | `mapSupabase()` + typed table source |
| `flutter_data_kit_firebase` | In progress — `mapFirebase`, Auth/Firestore/Storage/FCM |
| `flutter_data_kit_drift` | In progress — `mapDrift`, local notes, `DriftSyncQueue` |

Apps depend on the core package plus **only** the adapters they need. A
Supabase app never resolves Firebase.

## Install (path, unpublished)

```yaml
dependencies:
  flutter_data_kit:
    path: ../flutter_data_kit
  flutter_data_kit_dio:
    path: ../flutter_data_kit/packages/flutter_data_kit_dio
  lemsa_core_kit:
    path: ../lemsa_core_kit
```

```dart
import 'package:flutter_data_kit/flutter_data_kit.dart';
```

## Core

- `PagedList<T,Q>` mixin on a Riverpod AsyncNotifier (`build() => fetchFirstPage()`)
- `PagedSource.fetch` throws `AppFailure`
- `ref.cacheFor(duration)` after a successful await
- Repositories throw; controllers catch. `Result` only at branching sites
  (`lemsa_core_kit`)

## Adapters

Dio: `buildDioClient(readToken: () => yourJwt())` + `runDio` on source methods.

Supabase: wrap every public source method in `mapSupabase(() async { ... })`.

Firebase: wrap every public source method in `mapFirebase(() async { ... })`.

Drift: wrap every public source method in `mapDrift(() async { ... })`.
Inject `DriftSyncQueue` for a persistent `SyncQueue`. Call
`db.deleteUserData()` on sign-out.

Vendor exception types must not escape the adapter.

## Example

`example/` is a fake `PagedSource` + `PagedList` notifier. No backend required.

## Agent skill

Consumer agents: load `skills/flutter-data-kit/`.
