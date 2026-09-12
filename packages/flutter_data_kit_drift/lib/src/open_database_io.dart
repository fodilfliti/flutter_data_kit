import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_data_kit_drift/src/drift_kit_database.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Opens the example kit database under the app documents directory.
///
/// Apps typically wrap this in a keepAlive Riverpod provider and inject
/// [DriftSyncQueue] / [NoteSource] from it. Tests should construct
/// [DriftKitDatabase] with `NativeDatabase.memory()` instead.
DriftKitDatabase openDriftKitDatabase({
  String name = 'flutter_data_kit.sqlite',
}) {
  return DriftKitDatabase(
    LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, name));
      return NativeDatabase.createInBackground(file);
    }),
  );
}
