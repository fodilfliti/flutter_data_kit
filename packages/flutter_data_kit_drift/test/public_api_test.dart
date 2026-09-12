import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('barrel does not export sqlite3 or SqliteException', () {
    final file = _firstExisting([
      'lib/flutter_data_kit_drift.dart',
      'packages/flutter_data_kit_drift/lib/flutter_data_kit_drift.dart',
    ]);
    final text = file.readAsStringSync();
    expect(text.contains('sqlite3'), isFalse);
    expect(text.contains('SqliteException'), isFalse);
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
