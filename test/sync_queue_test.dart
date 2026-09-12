import 'package:flutter_data_kit/flutter_data_kit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('InMemorySyncQueue enqueues and counts', () async {
    final queue = InMemorySyncQueue();
    expect(await queue.enqueue({'title': 'x'}), isTrue);
    await queue.markDirty('1');
    expect(await queue.pendingCount(), 2);
    await queue.flush();
    expect(await queue.pendingCount(), 0);
  });
}
