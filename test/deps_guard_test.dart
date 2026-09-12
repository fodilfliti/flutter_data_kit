import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('core pubspec has no vendor backend dependencies', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final depsBlock =
        pubspec.split('dev_dependencies:').first.split('dependencies:').last;
    expect(
      RegExp(r'^\s+dio:', multiLine: true).hasMatch(depsBlock),
      isFalse,
    );
    expect(
      RegExp(r'^\s+supabase', multiLine: true).hasMatch(depsBlock),
      isFalse,
    );
    expect(
      RegExp(r'^\s+firebase', multiLine: true).hasMatch(depsBlock),
      isFalse,
    );
    expect(
      RegExp(r'^\s+drift:', multiLine: true).hasMatch(depsBlock),
      isFalse,
    );
  });

  test('core lib does not import vendor SDKs', () {
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    for (final file in files) {
      final text = file.readAsStringSync();
      expect(text.contains('package:dio/'), isFalse, reason: file.path);
      expect(text.contains('package:supabase'), isFalse, reason: file.path);
      expect(text.contains('package:firebase_'), isFalse, reason: file.path);
      expect(text.contains('package:drift/'), isFalse, reason: file.path);
    }
  });
}
