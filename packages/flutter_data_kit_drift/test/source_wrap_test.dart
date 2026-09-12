import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every public NoteSource method wraps mapDrift', () {
    final file = _firstExisting([
      'lib/src/note_source.dart',
      'packages/flutter_data_kit_drift/lib/src/note_source.dart',
    ]);
    final text = file.readAsStringSync();
    const methods = ['create', 'read', 'update', 'delete', 'list'];
    for (final name in methods) {
      expect(text.contains('$name('), isTrue, reason: 'missing $name');
    }
    expect(
      RegExp(r'mapDrift\(').allMatches(text).length,
      greaterThanOrEqualTo(methods.length),
    );
  });

  test('NotePagedSource.fetch wraps mapDrift', () {
    final file = _firstExisting([
      'lib/src/note_paged_source.dart',
      'packages/flutter_data_kit_drift/lib/src/note_paged_source.dart',
    ]);
    final text = file.readAsStringSync();
    expect(text.contains('fetch('), isTrue);
    expect(
      RegExp(r'mapDrift\(').allMatches(text).length,
      greaterThanOrEqualTo(1),
    );
  });

  test('DriftSyncQueue public methods wrap mapDrift', () {
    final file = _firstExisting([
      'lib/src/drift_sync_queue.dart',
      'packages/flutter_data_kit_drift/lib/src/drift_sync_queue.dart',
    ]);
    final text = file.readAsStringSync();
    const methods = ['enqueue', 'markDirty', 'pendingCount', 'flush'];
    for (final name in methods) {
      expect(text.contains('$name('), isTrue, reason: 'missing $name');
    }
    expect(
      RegExp(r'mapDrift\(').allMatches(text).length,
      greaterThanOrEqualTo(methods.length),
    );
  });

  test('deleteUserData wraps mapDrift', () {
    final file = _firstExisting([
      'lib/src/drift_kit_database.dart',
      'packages/flutter_data_kit_drift/lib/src/drift_kit_database.dart',
    ]);
    final text = file.readAsStringSync();
    expect(text.contains('deleteUserData('), isTrue);
    expect(text.contains('mapDrift('), isTrue);
  });

  test('drift pubspec does not depend on dio, supabase, firebase', () {
    final file = _firstExisting([
      'pubspec.yaml',
      'packages/flutter_data_kit_drift/pubspec.yaml',
    ]);
    final text = file.readAsStringSync();
    final deps = text.split('dev_dependencies:').first;
    expect(RegExp(r'^\s+dio:', multiLine: true).hasMatch(deps), isFalse);
    expect(RegExp(r'^\s+supabase', multiLine: true).hasMatch(deps), isFalse);
    expect(RegExp(r'^\s+firebase', multiLine: true).hasMatch(deps), isFalse);
  });

  test('dio and supabase pubspecs do not depend on drift', () {
    final dio = _firstExisting([
      '../flutter_data_kit_dio/pubspec.yaml',
      'packages/flutter_data_kit_dio/pubspec.yaml',
    ]);
    final supabase = _firstExisting([
      '../flutter_data_kit_supabase/pubspec.yaml',
      'packages/flutter_data_kit_supabase/pubspec.yaml',
    ]);
    expect(dio.readAsStringSync().contains('drift'), isFalse);
    expect(supabase.readAsStringSync().contains('drift'), isFalse);
  });
}

File _firstExisting(List<String> paths) {
  for (final path in paths) {
    final file = File(path);
    if (file.existsSync()) {
      return file;
    }
  }
  fail('none of $paths exist (cwd=${Directory.current.path})');
}
