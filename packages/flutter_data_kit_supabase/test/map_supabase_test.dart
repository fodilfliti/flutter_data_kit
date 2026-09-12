import 'dart:io';

import 'package:flutter_data_kit_supabase/flutter_data_kit_supabase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemsa_core_kit/lemsa_core_kit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('mapSupabase', () {
    test('23505 → ValidationFailure duplicate token', () async {
      await expectLater(
        mapSupabase(
          () async =>
              throw const PostgrestException(message: 'dup', code: '23505'),
        ),
        throwsA(
          isA<ValidationFailure>().having(
            (f) => f.fields['_'],
            'token',
            'duplicate',
          ),
        ),
      );
    });

    test('23503 → ConflictFailure', () async {
      await expectLater(
        mapSupabase(
          () async =>
              throw const PostgrestException(message: 'fk', code: '23503'),
        ),
        throwsA(
          isA<ConflictFailure>().having((f) => f.code, 'code', '23503'),
        ),
      );
    });

    test('42501 → PermissionFailure', () async {
      await expectLater(
        mapSupabase(
          () async =>
              throw const PostgrestException(message: 'rls', code: '42501'),
        ),
        throwsA(isA<PermissionFailure>()),
      );
    });

    test('PGRST116 → NotFoundFailure', () async {
      await expectLater(
        mapSupabase(
          () async =>
              throw const PostgrestException(
                message: 'missing',
                code: 'PGRST116',
              ),
        ),
        throwsA(isA<NotFoundFailure>()),
      );
    });

    test('other Postgrest → ServerFailure', () async {
      await expectLater(
        mapSupabase(
          () async =>
              throw const PostgrestException(message: 'x', code: 'XX000'),
        ),
        throwsA(isA<ServerFailure>()),
      );
    });

    test('AuthException invalid_credentials', () async {
      await expectLater(
        mapSupabase(
          () async =>
              throw const AuthException(
                'bad',
                statusCode: '400',
                code: 'invalid_credentials',
              ),
        ),
        throwsA(
          isA<AuthFailure>().having(
            (f) => f.reason,
            'reason',
            AuthReason.invalidCredentials,
          ),
        ),
      );
    });

    test('AuthException email_not_confirmed', () async {
      await expectLater(
        mapSupabase(
          () async =>
              throw const AuthException(
                'mail',
                code: 'email_not_confirmed',
              ),
        ),
        throwsA(
          isA<AuthFailure>().having(
            (f) => f.reason,
            'reason',
            AuthReason.emailNotConfirmed,
          ),
        ),
      );
    });

    test('AuthException rate limit', () async {
      await expectLater(
        mapSupabase(
          () async =>
              throw const AuthException(
                'slow',
                code: 'over_request_rate_limit',
              ),
        ),
        throwsA(
          isA<AuthFailure>().having(
            (f) => f.reason,
            'reason',
            AuthReason.rateLimited,
          ),
        ),
      );
    });

    test('StorageException → StorageFailure', () async {
      await expectLater(
        mapSupabase(
          () async => throw const StorageException('blob'),
        ),
        throwsA(isA<StorageFailure>()),
      );
    });

    test('SocketException → NetworkFailure', () async {
      await expectLater(
        mapSupabase(() async => throw const SocketException('offline')),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('unknown → UnknownFailure', () async {
      await expectLater(
        mapSupabase(() async => throw StateError('x')),
        throwsA(isA<UnknownFailure>()),
      );
    });

    test('AppFailure is not remapped', () async {
      await expectLater(
        mapSupabase(() async => throw const NotFoundFailure('row')),
        throwsA(isA<NotFoundFailure>()),
      );
    });
  });
}
