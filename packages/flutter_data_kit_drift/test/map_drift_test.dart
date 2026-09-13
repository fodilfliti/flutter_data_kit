import 'package:drift/drift.dart';
import 'package:flutter_data_kit_drift/flutter_data_kit_drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemsa_core_kit/lemsa_core_kit.dart';
import 'package:sqlite3/common.dart';

SqliteException _sqlite(int code, String message) =>
    SqliteException(extendedResultCode: code, message: message);

void main() {
  group('mapDrift', () {
    test('unique constraint → ConflictFailure', () async {
      await expectLater(
        mapDrift(
          () async => throw _sqlite(2067, 'UNIQUE'),
        ),
        throwsA(
          isA<ConflictFailure>().having((f) => f.code, 'code', 'unique'),
        ),
      );
    });

    test('primary key constraint → ConflictFailure', () async {
      await expectLater(
        mapDrift(
          () async => throw _sqlite(1555, 'PRIMARY KEY'),
        ),
        throwsA(
          isA<ConflictFailure>().having((f) => f.code, 'code', 'unique'),
        ),
      );
    });

    test('foreign key constraint → ConflictFailure', () async {
      await expectLater(
        mapDrift(
          () async => throw _sqlite(787, 'FOREIGN KEY'),
        ),
        throwsA(
          isA<ConflictFailure>().having(
            (f) => f.code,
            'code',
            'foreign_key',
          ),
        ),
      );
    });

    test('NOT NULL constraint → ValidationFailure', () async {
      await expectLater(
        mapDrift(
          () async => throw _sqlite(1299, 'NOT NULL'),
        ),
        throwsA(
          isA<ValidationFailure>().having(
            (f) => f.fields['_'],
            'token',
            'not_null',
          ),
        ),
      );
    });

    test('CHECK constraint → ValidationFailure', () async {
      await expectLater(
        mapDrift(
          () async => throw _sqlite(275, 'CHECK'),
        ),
        throwsA(
          isA<ValidationFailure>().having(
            (f) => f.fields['_'],
            'token',
            'check',
          ),
        ),
      );
    });

    test('SQLITE_NOTFOUND → NotFoundFailure', () async {
      await expectLater(
        mapDrift(
          () async => throw _sqlite(12, 'not found'),
        ),
        throwsA(isA<NotFoundFailure>()),
      );
    });

    test('SQLITE_IOERR → StorageFailure', () async {
      await expectLater(
        mapDrift(
          () async => throw _sqlite(10, 'io'),
        ),
        throwsA(isA<StorageFailure>()),
      );
    });

    test('SQLITE_CORRUPT → StorageFailure', () async {
      await expectLater(
        mapDrift(
          () async => throw _sqlite(11, 'corrupt'),
        ),
        throwsA(isA<StorageFailure>()),
      );
    });

    test('SQLITE_BUSY → StorageFailure', () async {
      await expectLater(
        mapDrift(
          () async => throw _sqlite(5, 'busy'),
        ),
        throwsA(isA<StorageFailure>()),
      );
    });

    test('generic SQLITE_CONSTRAINT → ConflictFailure', () async {
      await expectLater(
        mapDrift(
          () async => throw _sqlite(19, 'constraint'),
        ),
        throwsA(isA<ConflictFailure>()),
      );
    });

    test('getSingle miss → NotFoundFailure', () async {
      await expectLater(
        mapDrift(
          () async => throw StateError('Bad state: No element'),
        ),
        throwsA(isA<NotFoundFailure>()),
      );
    });

    test('InvalidDataException → ValidationFailure', () async {
      await expectLater(
        mapDrift(
          () async => throw InvalidDataException('bad'),
        ),
        throwsA(
          isA<ValidationFailure>().having(
            (f) => f.fields['_'],
            'token',
            'invalid',
          ),
        ),
      );
    });

    test('CouldNotRollBackException unwraps SqliteException', () async {
      final inner = _sqlite(10, 'io');
      await expectLater(
        mapDrift(
          () async =>
              throw CouldNotRollBackException(
                inner,
                StackTrace.current,
                Exception('rollback'),
              ),
        ),
        throwsA(isA<StorageFailure>()),
      );
    });

    test('unknown → UnknownFailure', () async {
      await expectLater(
        mapDrift(() async => throw StateError('other')),
        throwsA(isA<UnknownFailure>()),
      );
    });

    test('AppFailure is not remapped', () async {
      await expectLater(
        mapDrift(() async => throw const NotFoundFailure('row')),
        throwsA(isA<NotFoundFailure>()),
      );
    });

    test('mapSqlite is an alias of mapDrift', () async {
      await expectLater(
        mapSqlite(
          () async => throw _sqlite(10, 'io'),
        ),
        throwsA(isA<StorageFailure>()),
      );
    });
  });
}
