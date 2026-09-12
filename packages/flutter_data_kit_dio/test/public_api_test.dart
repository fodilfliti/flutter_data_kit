import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dio pubspec has no firebase dependency', () {
    final file = _firstExisting([
      'packages/flutter_data_kit_dio/pubspec.yaml',
      'pubspec.yaml',
    ]);
    final text = file.readAsStringSync();
    expect(text.contains('name: flutter_data_kit_dio'), isTrue);
    expect(
      RegExp(r'^\s+firebase', multiLine: true).hasMatch(text),
      isFalse,
    );
  });

  test('runDio and FailureInterceptor exist as public API', () {
    final barrel = _firstExisting([
      'lib/flutter_data_kit_dio.dart',
      'packages/flutter_data_kit_dio/lib/flutter_data_kit_dio.dart',
    ]);
    final text = barrel.readAsStringSync();
    expect(text.contains('run_dio.dart'), isTrue);
    expect(text.contains('failure_interceptor.dart'), isTrue);
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
