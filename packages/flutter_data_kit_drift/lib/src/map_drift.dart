import 'package:drift/drift.dart'
    show CouldNotRollBackException, DriftWrappedException, InvalidDataException;
import 'package:lemsa_core_kit/lemsa_core_kit.dart';
import 'package:sqlite3/common.dart' show SqliteException;

/// SQLITE_CONSTRAINT (primary result code).
const _sqliteConstraint = 19;

/// SQLITE_NOTFOUND.
const _sqliteNotFound = 12;

const _constraintCheck = 275;
const _constraintForeignKey = 787;
const _constraintNotNull = 1299;
const _constraintPrimaryKey = 1555;
const _constraintUnique = 2067;
const _constraintRowId = 2579;

/// Runs [body] and maps Drift / SQLite exceptions to [AppFailure].
///
/// Wrap **every** public source method — Drift has no interceptor that
/// cannot be forgotten. Prefer [StorageFailure] for local DB faults.
///
/// Re-throws [AppFailure] unchanged. Never leaks [SqliteException].
Future<T> mapDrift<T>(Future<T> Function() body) async {
  try {
    return await body();
  } on AppFailure {
    rethrow;
  } on SqliteException catch (e, s) {
    throw mapSqliteException(e, s);
  } on CouldNotRollBackException catch (e, s) {
    throw _mapCouldNotRollBack(e, s);
  } on DriftWrappedException catch (e, s) {
    throw _mapWrapped(e, s);
  } on InvalidDataException catch (e) {
    throw ValidationFailure({'_': 'invalid'}, cause: e);
  } catch (e, s) {
    if (e is StateError) {
      throw _mapStateError(e, s);
    }
    if (_isSqliteNamed(e)) {
      throw StorageFailure(cause: e, trace: s);
    }
    throw UnknownFailure(cause: e, trace: s);
  }
}

/// Alias of [mapDrift] for callers who think in SQLite terms.
Future<T> mapSqlite<T>(Future<T> Function() body) => mapDrift(body);

/// Maps a [SqliteException] to [AppFailure]. Adapter-zone only.
AppFailure mapSqliteException(SqliteException error, [StackTrace? trace]) {
  final primary = error.resultCode;
  if (primary == _sqliteNotFound) {
    return NotFoundFailure('row', cause: error);
  }
  if (primary == _sqliteConstraint) {
    return _mapConstraint(error);
  }
  return StorageFailure(cause: error, trace: trace);
}

AppFailure _mapConstraint(SqliteException error) {
  final code = error.extendedResultCode;
  switch (code) {
    case _constraintUnique:
    case _constraintPrimaryKey:
    case _constraintRowId:
      return ConflictFailure(code: 'unique', cause: error);
    case _constraintForeignKey:
      return ConflictFailure(code: 'foreign_key', cause: error);
    case _constraintNotNull:
      return ValidationFailure({'_': 'not_null'}, cause: error);
    case _constraintCheck:
      return ValidationFailure({'_': 'check'}, cause: error);
    default:
      return ConflictFailure(code: '$code', cause: error);
  }
}

AppFailure _mapCouldNotRollBack(
  CouldNotRollBackException error,
  StackTrace trace,
) {
  final cause = error.cause;
  if (cause is AppFailure) {
    return cause;
  }
  if (cause is SqliteException) {
    return mapSqliteException(cause, trace);
  }
  return StorageFailure(cause: error, trace: trace);
}

AppFailure _mapWrapped(DriftWrappedException error, StackTrace trace) {
  final cause = error.cause;
  if (cause is AppFailure) {
    return cause;
  }
  if (cause is SqliteException) {
    return mapSqliteException(cause, trace);
  }
  return StorageFailure(cause: error, trace: trace);
}

AppFailure _mapStateError(StateError error, StackTrace trace) {
  final message = error.message.toLowerCase();
  if (message.contains('no row') ||
      message.contains('no result') ||
      message.contains('no element') ||
      message.contains('got 0') ||
      message.contains('too few')) {
    return NotFoundFailure('row', cause: error);
  }
  return UnknownFailure(cause: error, trace: trace);
}

bool _isSqliteNamed(Object error) {
  final name = error.runtimeType.toString();
  return name.contains('SqliteException');
}
