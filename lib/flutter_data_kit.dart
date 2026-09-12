/// Backend contracts, pagination, cache policy, and repository patterns.
///
/// Import only this library:
/// ```dart
/// import 'package:flutter_data_kit/flutter_data_kit.dart';
/// ```
///
/// Vendor SDKs belong in adapter packages (`flutter_data_kit_dio`,
/// `flutter_data_kit_supabase`, …).
library;

export 'src/cache/cache_for.dart';
export 'src/identifiable.dart';
export 'src/paged/paged_list.dart';
export 'src/paged/paged_query.dart';
export 'src/paged/paged_result.dart';
export 'src/paged/paged_source.dart';
export 'src/paged/paged_state.dart';
export 'src/source/crud_source.dart';
export 'src/source/data_source.dart';
export 'src/source/repository.dart';
export 'src/sync/sync_queue.dart';
