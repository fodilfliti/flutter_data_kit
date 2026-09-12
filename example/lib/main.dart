import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_data_kit/flutter_data_kit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: DemoApp()));
}

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DemoListPage(),
    );
  }
}

@immutable
class DemoItem implements Identifiable {
  const DemoItem({required this.id, required this.title});

  @override
  final String id;
  final String title;

  DemoItem copyWith({String? title}) =>
      DemoItem(id: id, title: title ?? this.title);

  @override
  bool operator ==(Object other) =>
      other is DemoItem && other.id == id && other.title == title;

  @override
  int get hashCode => Object.hash(id, title);
}

class DemoQuery extends PagedQuery {
  const DemoQuery({
    super.page,
    super.pageSize = 12,
    this.search = '',
  });

  final String search;
}

class FakeDemoSource implements PagedSource<DemoItem, DemoQuery> {
  FakeDemoSource() {
    _all = [
      for (var i = 1; i <= 40; i++) DemoItem(id: '$i', title: 'Item $i'),
    ];
  }

  late final List<DemoItem> _all;

  @override
  Future<PagedResult<DemoItem>> fetch(DemoQuery query) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final q = query.search.trim().toLowerCase();
    final filtered =
        q.isEmpty
            ? _all
            : _all.where((e) => e.title.toLowerCase().contains(q)).toList();
    final start = (query.page - 1) * query.pageSize;
    if (start >= filtered.length) {
      return const PagedResult(items: [], hasMore: false);
    }
    final end = (start + query.pageSize).clamp(0, filtered.length);
    return PagedResult(
      items: filtered.sublist(start, end),
      hasMore: end < filtered.length,
    );
  }
}

final demoSourceProvider = Provider<PagedSource<DemoItem, DemoQuery>>(
  (ref) => FakeDemoSource(),
);

final demoListProvider = AsyncNotifierProvider<DemoList, PagedState<DemoItem>>(
  DemoList.new,
);

class DemoList extends AsyncNotifier<PagedState<DemoItem>>
    with PagedList<DemoItem, DemoQuery> {
  @override
  PagedSource<DemoItem, DemoQuery> get source => ref.watch(demoSourceProvider);

  @override
  DemoQuery get initialQuery => const DemoQuery();

  @override
  DemoQuery queryWithPage(DemoQuery query, int page) {
    return DemoQuery(
      page: page,
      pageSize: query.pageSize,
      search: query.search,
    );
  }

  @override
  Future<PagedState<DemoItem>> build() => fetchFirstPage();
}

class DemoListPage extends ConsumerWidget {
  const DemoListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(demoListProvider);
    final notifier = ref.read(demoListProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('flutter_data_kit PagedList')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Filter (server-side setQuery)',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                unawaited(notifier.setQuery(DemoQuery(search: value)));
              },
            ),
          ),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (page) {
                return ListView.builder(
                  itemCount: page.items.length + (page.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == page.items.length) {
                      return TextButton(
                        onPressed:
                            page.isLoadingMore
                                ? null
                                : () => unawaited(notifier.loadMore()),
                        child: Text(
                          page.isLoadingMore ? 'Loading…' : 'Load more',
                        ),
                      );
                    }
                    final item = page.items[index];
                    return ListTile(
                      title: Text(item.title),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => notifier.removeById(item.id),
                      ),
                      onTap:
                          () => notifier.patch(
                            item.id,
                            (current) =>
                                current.copyWith(title: '${current.title} ✓'),
                          ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => notifier.upsert(
              DemoItem(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: 'Local upsert',
              ),
            ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
