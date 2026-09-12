import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_data_kit_drift/flutter_data_kit_drift.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('enqueue persists across a new connection', () async {
    final dir = await Directory.systemTemp.createTemp('drift_sync');
    final file = File('${dir.path}/queue.sqlite');

    final first = DriftKitDatabase(NativeDatabase(file));
    final queue = DriftSyncQueue(first);
    expect(await queue.enqueue({'title': 'offline'}), isTrue);
    await queue.markDirty('note-1');
    expect(await queue.pendingCount(), 2);
    await first.close();

    final second = DriftKitDatabase(NativeDatabase(file));
    final restored = DriftSyncQueue(second);
    expect(await restored.pendingCount(), 2);
    final payloads = await restored.pendingPayloads();
    expect(payloads, hasLength(1));
    expect(jsonDecode(payloads.single), {'title': 'offline'});
    await restored.flush();
    expect(await restored.pendingCount(), 0);
    await second.close();

    await dir.delete(recursive: true);
  });

  test('markDirty is idempotent for the same id', () async {
    final db = DriftKitDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final queue = DriftSyncQueue(db);
    await queue.markDirty('a');
    await queue.markDirty('a');
    expect(await queue.pendingCount(), 1);
  });
}
