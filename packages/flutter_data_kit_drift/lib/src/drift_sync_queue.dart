import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_data_kit/flutter_data_kit.dart';
import 'package:flutter_data_kit_drift/src/map_drift.dart';
import 'package:lemsa_core_kit/lemsa_core_kit.dart';

/// Persistent [SyncQueue] stored in `sync_queue_items`.
///
/// Inject as the app `SyncQueue` (Riverpod override / constructor).
/// The database must include `SyncQueueItems` (for example
/// `DriftKitDatabase`).
///
/// `flush` clears persisted rows. Wire a real transport in the app
/// before calling it, or drain [pendingPayloads] yourself.
class DriftSyncQueue implements SyncQueue {
  DriftSyncQueue(this.db);

  /// Any Drift database whose schema contains `sync_queue_items`.
  final GeneratedDatabase db;

  @override
  Future<bool> enqueue(Object payload) async {
    try {
      await mapDrift(() async {
        await db.customInsert(
          'INSERT INTO sync_queue_items '
          '(kind, payload_json, created_at) VALUES (?, ?, ?)',
          variables: [
            Variable.withString('enqueue'),
            Variable.withString(_encode(payload)),
            Variable.withDateTime(DateTime.now()),
          ],
        );
      });
      return true;
    } on AppFailure {
      return false;
    }
  }

  @override
  Future<void> markDirty(String id) => mapDrift(() async {
    final existing =
        await db
            .customSelect(
              'SELECT id FROM sync_queue_items '
              'WHERE kind = ? AND entity_id = ?',
              variables: [
                Variable.withString('dirty'),
                Variable.withString(id),
              ],
            )
            .get();
    if (existing.isNotEmpty) {
      return;
    }
    await db.customInsert(
      'INSERT INTO sync_queue_items '
      '(kind, payload_json, entity_id, created_at) VALUES (?, ?, ?, ?)',
      variables: [
        Variable.withString('dirty'),
        Variable.withString('{}'),
        Variable.withString(id),
        Variable.withDateTime(DateTime.now()),
      ],
    );
  });

  @override
  Future<int> pendingCount() => mapDrift(() async {
    final row =
        await db
            .customSelect('SELECT COUNT(*) AS c FROM sync_queue_items')
            .getSingle();
    return row.read<int>('c');
  });

  @override
  Future<void> flush() => mapDrift(() async {
    await db.customStatement('DELETE FROM sync_queue_items');
  });

  /// JSON strings of enqueue payloads, oldest first (not dirty ids).
  Future<List<String>> pendingPayloads() => mapDrift(() async {
    final rows =
        await db
            .customSelect(
              'SELECT payload_json FROM sync_queue_items '
              'WHERE kind = ? ORDER BY id ASC',
              variables: [Variable.withString('enqueue')],
            )
            .get();
    return rows
        .map((row) => row.read<String>('payload_json'))
        .toList(growable: false);
  });
}

String _encode(Object payload) {
  if (payload is String) {
    return payload;
  }
  return jsonEncode(payload);
}
