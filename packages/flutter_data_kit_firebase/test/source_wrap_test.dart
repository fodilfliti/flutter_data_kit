import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every public NoteSource method wraps mapFirebase', () {
    final file = _firstExisting([
      'lib/src/firestore/note_source.dart',
      'packages/flutter_data_kit_firebase/lib/src/firestore/note_source.dart',
    ]);
    final text = file.readAsStringSync();
    const methods = ['create', 'read', 'update', 'delete', 'list'];
    for (final name in methods) {
      expect(text.contains('$name('), isTrue, reason: 'missing $name');
    }
    expect(
      RegExp(r'mapFirebase\(').allMatches(text).length,
      greaterThanOrEqualTo(methods.length),
    );
  });

  test('firebase pubspec does not depend on dio/supabase/drift', () {
    final file = _firstExisting([
      'packages/flutter_data_kit_firebase/pubspec.yaml',
      'pubspec.yaml',
    ]);
    final text = file.readAsStringSync();
    expect(text.contains('name: flutter_data_kit_firebase'), isTrue);
    expect(RegExp(r'^\s+dio:', multiLine: true).hasMatch(text), isFalse);
    expect(
      RegExp(r'^\s+supabase', multiLine: true).hasMatch(text),
      isFalse,
    );
    expect(RegExp(r'^\s+drift:', multiLine: true).hasMatch(text), isFalse);
  });

  test('dio and supabase pubspecs do not depend on firebase', () {
    final dio = _firstExisting([
      'packages/flutter_data_kit_dio/pubspec.yaml',
      '../flutter_data_kit_dio/pubspec.yaml',
    ]);
    final supabase = _firstExisting([
      'packages/flutter_data_kit_supabase/pubspec.yaml',
      '../flutter_data_kit_supabase/pubspec.yaml',
    ]);
    final dioText = dio.readAsStringSync();
    final supabaseText = supabase.readAsStringSync();
    expect(dioText.contains('name: flutter_data_kit_dio'), isTrue);
    expect(supabaseText.contains('name: flutter_data_kit_supabase'), isTrue);
    expect(
      RegExp(r'^\s+firebase', multiLine: true).hasMatch(dioText),
      isFalse,
    );
    expect(
      RegExp(r'^\s+firebase', multiLine: true).hasMatch(supabaseText),
      isFalse,
    );
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
