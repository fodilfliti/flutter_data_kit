import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_data_kit/flutter_data_kit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemsa_core_kit/lemsa_core_kit.dart';

void main() {
  late FakeSource source;
  late Harness harness;

  setUp(() {
    source = FakeSource([
      const Item(id: '1', title: 'alpha'),
      const Item(id: '2', title: 'beta'),
      const Item(id: '3', title: 'gamma'),
      const Item(id: '4', title: 'delta'),
      const Item(id: '5', title: 'epsilon'),
    ]);
    harness = Harness(source);
  });

  test('fetchFirstPage loads page 1', () async {
    final page = await harness.fetchFirstPage();
    harness.state = AsyncData(page);

    expect(page.items.map((e) => e.id), ['1', '2']);
    expect(page.hasMore, isTrue);
    expect(page.page, 1);
    expect(source.fetches, 1);
  });

  test('loadMore appends the next page', () async {
    harness.state = AsyncData(await harness.fetchFirstPage());
    await harness.loadMore();

    final items = harness.state.value!.items;
    expect(items.map((e) => e.id), ['1', '2', '3', '4']);
    expect(harness.state.value!.hasMore, isTrue);
    expect(harness.state.value!.page, 2);

    await harness.loadMore();
    expect(harness.state.value!.items.map((e) => e.id), [
      '1',
      '2',
      '3',
      '4',
      '5',
    ]);
    expect(harness.state.value!.hasMore, isFalse);
  });

  test('loadMore is a no-op when hasMore is false', () async {
    harness.state = AsyncData(await harness.fetchFirstPage());
    await harness.loadMore();
    await harness.loadMore();
    final fetches = source.fetches;
    await harness.loadMore();
    expect(source.fetches, fetches);
  });

  test('refresh reloads page 1', () async {
    harness.state = AsyncData(await harness.fetchFirstPage());
    await harness.loadMore();
    await harness.refresh();

    expect(harness.state.value!.items.map((e) => e.id), ['1', '2']);
    expect(harness.state.value!.page, 1);
  });

  test('setQuery refetches from page 1 with the new filter', () async {
    harness.state = AsyncData(await harness.fetchFirstPage());
    await harness.setQuery(const ItemQuery(search: 'amm'));

    expect(
      harness.state.value!.items.map((e) => e.title),
      ['gamma'],
    );
    expect(source.last!.search, 'amm');
    expect(source.last!.page, 1);
  });

  test('upsert inserts then replaces by id', () async {
    harness.state = AsyncData(await harness.fetchFirstPage());
    harness.upsert(const Item(id: '9', title: 'new'));
    expect(harness.state.value!.items.first.id, '9');

    harness.upsert(const Item(id: '1', title: 'alpha-edit'));
    expect(
      harness.state.value!.items.singleWhere((e) => e.id == '1').title,
      'alpha-edit',
    );
  });

  test('removeById drops the row', () async {
    harness.state = AsyncData(await harness.fetchFirstPage());
    harness.removeById('1');
    expect(harness.state.value!.items.map((e) => e.id), ['2']);
  });

  test('patch updates one row', () async {
    harness.state = AsyncData(await harness.fetchFirstPage());
    harness.patch('2', (item) => Item(id: item.id, title: '${item.title}!'));
    expect(harness.state.value!.items[1].title, 'beta!');
  });

  test('apply routes Change to local writes', () async {
    harness.state = AsyncData(await harness.fetchFirstPage());
    harness.apply(const Created(Item(id: '8', title: 'created')));
    expect(harness.state.value!.items.first.id, '8');

    harness.apply(const Updated(Item(id: '8', title: 'updated')));
    expect(harness.state.value!.items.first.title, 'updated');

    harness.apply(const Deleted('8'));
    expect(harness.state.value!.items.any((e) => e.id == '8'), isFalse);
  });
}

@immutable
class Item implements Identifiable {
  const Item({required this.id, required this.title});

  @override
  final String id;
  final String title;

  @override
  bool operator ==(Object other) =>
      other is Item && other.id == id && other.title == title;

  @override
  int get hashCode => Object.hash(id, title);
}

class ItemQuery extends PagedQuery {
  const ItemQuery({
    super.page,
    super.pageSize = 2,
    this.search,
  });

  final String? search;
}

class FakeSource implements PagedSource<Item, ItemQuery> {
  FakeSource(this.all);

  final List<Item> all;
  int fetches = 0;
  ItemQuery? last;

  @override
  Future<PagedResult<Item>> fetch(ItemQuery query) async {
    fetches++;
    last = query;
    final filtered =
        (query.search == null || query.search!.isEmpty)
            ? all
            : all.where((e) => e.title.contains(query.search!)).toList();
    final start = (query.page - 1) * query.pageSize;
    if (start >= filtered.length) {
      return const PagedResult(items: [], hasMore: false);
    }
    final end = math.min(start + query.pageSize, filtered.length);
    return PagedResult(
      items: filtered.sublist(start, end),
      hasMore: end < filtered.length,
    );
  }
}

class Harness with PagedList<Item, ItemQuery> {
  Harness(this.source);

  @override
  final PagedSource<Item, ItemQuery> source;

  @override
  ItemQuery get initialQuery => const ItemQuery();

  @override
  AsyncValue<PagedState<Item>> state = const AsyncLoading();

  @override
  ItemQuery queryWithPage(ItemQuery query, int page) {
    return ItemQuery(
      page: page,
      pageSize: query.pageSize,
      search: query.search,
    );
  }
}
