import 'package:flutter_data_kit/src/identifiable.dart';
import 'package:flutter_data_kit/src/paged/paged_query.dart';
import 'package:flutter_data_kit/src/paged/paged_source.dart';
import 'package:flutter_data_kit/src/paged/paged_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lemsa_core_kit/lemsa_core_kit.dart';

/// Pagination + local list mutations for a Riverpod `AsyncNotifier`.
///
/// Apply on a `@riverpod` class whose `build()` returns
/// `Future<PagedState<T>>` (typically `fetchFirstPage()`).
///
/// ```dart
/// @riverpod
/// class ItemList extends _$ItemList with PagedList<Item, ItemQuery> {
///   @override
///   PagedSource<Item, ItemQuery> get source => ref.watch(itemSourceProvider);
///
///   @override
///   ItemQuery get initialQuery => const ItemQuery(pageSize: 20);
///
///   @override
///   ItemQuery queryWithPage(ItemQuery query, int page) =>
///       ItemQuery(page: page, pageSize: query.pageSize, search: query.search);
///
///   @override
///   Future<PagedState<Item>> build() => fetchFirstPage();
/// }
/// ```
///
/// Writes (`upsert` / `removeById` / `patch` / `apply`) are local — they do
/// not hit the network. After a form save, the page calls `upsert` with the
/// server-returned entity (list_updates: callback).
mixin PagedList<T extends Identifiable, Q extends PagedQuery> {
  /// Backing source. Throw AppFailure from [PagedSource.fetch].
  PagedSource<T, Q> get source;

  /// Query used for the first fetch (and after [setQuery] until then).
  Q get initialQuery;

  /// Copy [query] with a new 1-based [page], preserving filters/search.
  Q queryWithPage(Q query, int page);

  /// Notifier state. Satisfied by Riverpod `AsyncNotifier.state`.
  AsyncValue<PagedState<T>> get state;
  set state(AsyncValue<PagedState<T>> value);

  Q? _query;

  /// Active query (filters + current page size). Page index lives on state.
  Q get query => _query ?? initialQuery;

  PagedState<T>? get _data => state.value;

  /// First page for `build() => fetchFirstPage()`. Does **not** assign [state]
  /// — Riverpod sets it from the returned future.
  Future<PagedState<T>> fetchFirstPage() async {
    final q = queryWithPage(query, 1);
    _query = q;
    final result = await source.fetch(q);
    return PagedState<T>(
      items: List<T>.of(result.items),
      hasMore: result.hasMore,
    );
  }

  /// Reload page 1 of the current query.
  Future<void> refresh() async {
    try {
      final next = await fetchFirstPage();
      state = AsyncData(next);
    } on AppFailure catch (e, s) {
      state = AsyncError(e, s);
      rethrow;
    }
  }

  /// Replace filters/search and refetch from page 1.
  Future<void> setQuery(Q next) async {
    _query = queryWithPage(next, 1);
    await refresh();
  }

  /// Append the next page. Keeps existing items if the fetch fails.
  Future<void> loadMore() async {
    final current = _data;
    if (current == null || !current.hasMore || current.isLoadingMore) {
      return;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final nextPage = current.page + 1;
      final q = queryWithPage(query, nextPage);
      final result = await source.fetch(q);
      _query = q;
      final latest = _data ?? current;
      state = AsyncData(
        latest.copyWith(
          items: [...latest.items, ...result.items],
          hasMore: result.hasMore,
          page: nextPage,
          isLoadingMore: false,
        ),
      );
    } on AppFailure catch (e, s) {
      final latest = _data ?? current;
      state = AsyncData(latest.copyWith(isLoadingMore: false));
      Error.throwWithStackTrace(e, s);
    } on Object catch (e, s) {
      final latest = _data ?? current;
      state = AsyncData(latest.copyWith(isLoadingMore: false));
      Error.throwWithStackTrace(UnknownFailure(cause: e, trace: s), s);
    }
  }

  /// Insert or replace [item] by id (local, no network).
  void upsert(T item) {
    final current = _data;
    if (current == null) {
      state = AsyncData(
        PagedState<T>(items: [item], hasMore: false),
      );
      return;
    }
    final items = List<T>.of(current.items);
    final index = items.indexWhere((T e) => e.id == item.id);
    if (index >= 0) {
      items[index] = item;
    } else {
      items.insert(0, item);
    }
    state = AsyncData(current.copyWith(items: items));
  }

  /// Drop the row with [id] (local, no network).
  void removeById(String id) {
    final current = _data;
    if (current == null) {
      return;
    }
    state = AsyncData(
      current.copyWith(
        items: current.items.where((T e) => e.id != id).toList(),
      ),
    );
  }

  /// Replace the row with [id] using [update] (local, no network).
  void patch(String id, T Function(T current) update) {
    final current = _data;
    if (current == null) {
      return;
    }
    final items = List<T>.of(current.items);
    final index = items.indexWhere((T e) => e.id == id);
    if (index < 0) {
      return;
    }
    items[index] = update(items[index]);
    state = AsyncData(current.copyWith(items: items));
  }

  /// Apply a [Change] from a repository stream (list_updates: change_stream).
  void apply(Change<T> change) {
    switch (change) {
      case Created(:final item):
        upsert(item);
      case Updated(:final item):
        upsert(item);
      case Deleted(:final id):
        removeById(id);
    }
  }
}
