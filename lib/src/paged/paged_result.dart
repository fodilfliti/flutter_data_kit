import 'package:flutter/foundation.dart';

/// One page returned by `PagedSource.fetch`.
@immutable
class PagedResult<T> {
  const PagedResult({
    required this.items,
    required this.hasMore,
  });

  final List<T> items;
  final bool hasMore;

  @override
  bool operator ==(Object other) =>
      other is PagedResult<T> &&
      listEquals(other.items, items) &&
      other.hasMore == hasMore;

  @override
  int get hashCode => Object.hash(Object.hashAll(items), hasMore);
}
