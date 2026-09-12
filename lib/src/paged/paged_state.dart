import 'package:flutter/foundation.dart';

/// In-memory page of [T] held by a `PagedList` notifier.
///
/// Value equality is required so Riverpod 3 can filter notifications.
@immutable
class PagedState<T> {
  const PagedState({
    required this.items,
    required this.hasMore,
    this.page = 1,
    this.isLoadingMore = false,
  });

  final List<T> items;
  final bool hasMore;
  final int page;
  final bool isLoadingMore;

  bool get isEmpty => items.isEmpty;

  PagedState<T> copyWith({
    List<T>? items,
    bool? hasMore,
    int? page,
    bool? isLoadingMore,
  }) {
    return PagedState<T>(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PagedState<T> &&
      listEquals(other.items, items) &&
      other.hasMore == hasMore &&
      other.page == page &&
      other.isLoadingMore == isLoadingMore;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(items),
    hasMore,
    page,
    isLoadingMore,
  );
}
