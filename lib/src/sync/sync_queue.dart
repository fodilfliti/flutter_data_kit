/// Offline enqueue used by controllers (e.g. save-while-offline).
///
/// A Drift-backed implementation ships later in `flutter_data_kit_drift`.
/// [InMemorySyncQueue] is a process-local stub: it does not persist.
abstract interface class SyncQueue {
  /// Store [payload] for a later flush. Returns `false` if it cannot be queued.
  Future<bool> enqueue(Object payload);

  /// Mark an entity as needing a later pull/push.
  Future<void> markDirty(String id);

  Future<int> pendingCount();

  /// Drain the queue through a real transport. The in-memory stub is a no-op.
  Future<void> flush();
}

/// Process-local [SyncQueue]. Survives neither restart nor isolate death.
///
/// `flush` does not send work anywhere — it only drops in-memory items.
/// Replace with a Drift-backed queue before shipping offline-first.
class InMemorySyncQueue implements SyncQueue {
  final List<Object> _pending = [];
  final Set<String> _dirty = {};

  @override
  Future<bool> enqueue(Object payload) async {
    _pending.add(payload);
    return true;
  }

  @override
  Future<void> markDirty(String id) async {
    _dirty.add(id);
  }

  @override
  Future<int> pendingCount() async => _pending.length + _dirty.length;

  @override
  Future<void> flush() async {
    _pending.clear();
    _dirty.clear();
  }
}
