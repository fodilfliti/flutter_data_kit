import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every public NoteSource method wraps mapSupabase', () {
    final file = _firstExisting([
      'lib/src/note_source.dart',
      'packages/flutter_data_kit_supabase/lib/src/note_source.dart',
    ]);
    final text = file.readAsStringSync();
    const methods = ['create', 'read', 'update', 'delete', 'list'];
    for (final name in methods) {
      expect(text.contains('$name('), isTrue, reason: 'missing $name');
    }
    expect(
      RegExp(r'mapSupabase\(').allMatches(text).length,
      greaterThanOrEqualTo(methods.length),
    );
  });

  test('supabase pubspec does not depend on firebase', () {
    final file = _firstExisting([
      'pubspec.yaml',
      'packages/flutter_data_kit_supabase/pubspec.yaml',
    ]);
    expect(file.readAsStringSync().contains('firebase'), isFalse);
  });

  test('workspace package graph does not include firebase', () {
    final file = _firstExisting([
      '.dart_tool/package_config.json',
      '../../.dart_tool/package_config.json',
    ]);
    final text = file.readAsStringSync();
    expect(text.contains('firebase_core'), isFalse);
    expect(text.contains('firebase_auth'), isFalse);
    expect(text.contains('cloud_firestore'), isFalse);
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
