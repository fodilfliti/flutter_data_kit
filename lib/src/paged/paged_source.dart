import 'package:flutter_data_kit/src/paged/paged_query.dart';
import 'package:flutter_data_kit/src/paged/paged_result.dart';

/// Fetches one page. Implementations throw AppFailure, never vendor types.
abstract interface class PagedSource<T, Q extends PagedQuery> {
  Future<PagedResult<T>> fetch(Q query);
}
