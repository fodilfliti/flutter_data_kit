import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cache this provider for `duration` after a **successful** fetch.
///
/// Call after `await`:
/// ```dart
/// @riverpod
/// Future<Debt> debt(Ref ref, {required String id}) async {
///   final debt = await ref.watch(repoProvider).byId(id);
///   ref.cacheFor(const Duration(minutes: 5));
///   return debt;
/// }
/// ```
///
/// A failed fetch must not be cached: do not call this if the await throws.
extension RefCacheFor on Ref {
  void cacheFor(Duration duration) {
    final link = keepAlive();
    var held = true;

    void release() {
      if (!held) {
        return;
      }
      held = false;
      link.close();
    }

    final timer = Timer(duration, release);
    onDispose(timer.cancel);
  }
}
