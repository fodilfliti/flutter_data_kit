import 'package:flutter_data_kit_drift/src/drift_kit_database.dart';

/// Native helper — on web, pass a wasm executor to [DriftKitDatabase].
DriftKitDatabase openDriftKitDatabase({
  String name = 'flutter_data_kit.sqlite',
}) {
  throw UnsupportedError(
    'openDriftKitDatabase is native-only. '
    'Construct DriftKitDatabase with a wasm QueryExecutor on web.',
  );
}
