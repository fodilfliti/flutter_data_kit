import 'package:drift/native.dart';
import 'package:flutter_data_kit_drift/flutter_data_kit_drift.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('deleteUserData clears notes and sync queue', () async {
    final db = DriftKitDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final source = NoteSource(db);
    await source.create(const NoteDraft(id: 'n1', title: 'keep?'));
    final queue = DriftSyncQueue(db);
    expect(await queue.enqueue({'x': 1}), isTrue);
    await queue.markDirty('n1');

    expect(await source.list(), isNotEmpty);
    expect(await queue.pendingCount(), greaterThan(0));

    await db.deleteUserData();

    expect(await source.list(), isEmpty);
    expect(await queue.pendingCount(), 0);
  });
}
