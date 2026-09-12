import 'package:flutter/foundation.dart';

/// Server-side page cursor used by `PagedSource`.
///
/// Apps extend this with search/filter fields and implement
/// `queryWithPage` on `PagedList` so those extra fields survive paging.
@immutable
class PagedQuery {
  const PagedQuery({
    this.page = 1,
    this.pageSize = 20,
  });

  /// 1-based page index.
  final int page;

  /// Page length sent to the source.
  final int pageSize;

  @override
  bool operator ==(Object other) =>
      other is PagedQuery && other.page == page && other.pageSize == pageSize;

  @override
  int get hashCode => Object.hash(page, pageSize);
}
