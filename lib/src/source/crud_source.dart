import 'package:flutter_data_kit/src/identifiable.dart';

/// Typed CRUD against one backend. Methods throw AppFailure.
abstract interface class CrudSource<T extends Identifiable, TDraft> {
  Future<T> create(TDraft draft);
  Future<T> read(String id);
  Future<T> update(T entity);
  Future<void> delete(String id);
}
