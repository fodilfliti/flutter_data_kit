import 'package:drift/native.dart';
import 'package:flutter_data_kit/flutter_data_kit.dart';
import 'package:flutter_data_kit_drift/flutter_data_kit_drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemsa_core_kit/lemsa_core_kit.dart';

void main() {
  late DriftKitDatabase db;
  late NoteSource source;

  setUp(() {
    db = DriftKitDatabase(NativeDatabase.memory());
    source = NoteSource(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('CRUD create / read / update / list / delete', () async {
    final created = await source.create(
      const NoteDraft(id: 'n1', title: 'hello', body: 'world'),
    );
    expect(created.id, 'n1');
    expect(created.title, 'hello');
    expect(created.body, 'world');

    final read = await source.read('n1');
    expect(read, created);

    final updated = await source.update(
      const Note(id: 'n1', title: 'hi', body: 'there'),
    );
    expect(updated.title, 'hi');
    expect(updated.body, 'there');

    final all = await source.list();
    expect(all, [updated]);

    await source.delete('n1');
    expect(await source.list(), isEmpty);
  });

  test('read missing row → NotFoundFailure', () async {
    await expectLater(source.read('missing'), throwsA(isA<NotFoundFailure>()));
  });

  test('delete missing row → NotFoundFailure', () async {
    await expectLater(
      source.delete('missing'),
      throwsA(isA<NotFoundFailure>()),
    );
  });

  test('duplicate id → ConflictFailure', () async {
    await source.create(const NoteDraft(id: 'dup', title: 'a'));
    await expectLater(
      source.create(const NoteDraft(id: 'dup', title: 'b')),
      throwsA(isA<ConflictFailure>()),
    );
  });

  test('empty title → ValidationFailure', () async {
    await expectLater(
      source.create(const NoteDraft(id: 'x', title: '')),
      throwsA(isA<ValidationFailure>()),
    );
  });

  test('paged fetch hasMore', () async {
    final paged = NotePagedSource(db);
    for (var i = 0; i < 3; i++) {
      await source.create(NoteDraft(id: 'p$i', title: 't$i'));
    }
    final page = await paged.fetch(const PagedQuery(page: 1, pageSize: 2));
    expect(page.items.length, 2);
    expect(page.hasMore, isTrue);

    final last = await paged.fetch(const PagedQuery(page: 2, pageSize: 2));
    expect(last.items.length, 1);
    expect(last.hasMore, isFalse);
  });
}
