# flutter_data_kit

[![pub package](https://img.shields.io/pub/v/flutter_data_kit.svg)](https://pub.dev/packages/flutter_data_kit)

Backend contracts, pagination (`PagedList`), cache policy (`cacheFor`), and repository patterns for Lemsa Flutter apps. Vendor SDKs live in **adapter packages**.

**Platforms:** Android, iOS, Linux, macOS, Web, Windows  
**Requires:** Flutter `>=3.44.0`

## Workspace packages

| Package | Role |
| --- | --- |
| `flutter_data_kit` | Contracts, `PagedList`, `cacheFor`, `SyncQueue` |
| `flutter_data_kit_dio` | Dio client + `FailureInterceptor` |
| `flutter_data_kit_supabase` | `mapSupabase()` + typed table source |
| `flutter_data_kit_firebase` | `mapFirebase`, Auth/Firestore/Storage/FCM helpers |
| `flutter_data_kit_drift` | `mapDrift`, local sources, `DriftSyncQueue` |

Apps depend on the core package plus **only** the adapters they need.

## Install

```yaml
dependencies:
  flutter_data_kit: ^1.0.0
  flutter_data_kit_dio: ^1.0.0   # optional
  lemsa_core_kit: ^1.0.0
```

```dart
import 'package:flutter_data_kit/flutter_data_kit.dart';
```

## Core

- `PagedList<T,Q>` mixin on a Riverpod AsyncNotifier
- `PagedSource.fetch` throws `AppFailure` (never vendor types)
- `ref.cacheFor(duration)` after a successful await

## Agent skill

```bash
npx skills add fodilfliti/flutter_data_kit
# or: npx skills add fodilfliti/lemsa-skills
```

## Links

- [GitHub](https://github.com/fodilfliti/flutter_data_kit)
- [Lemsa skills](https://github.com/fodilfliti/lemsa-skills)
