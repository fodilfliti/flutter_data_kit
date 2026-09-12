import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_data_kit_firebase/flutter_data_kit_firebase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemsa_core_kit/lemsa_core_kit.dart';

void main() {
  group('mapFirebase', () {
    test('unavailable → NetworkFailure', () async {
      await expectLater(
        mapFirebase(
          () async => throw FirebaseException(
            plugin: 'cloud_firestore',
            code: 'unavailable',
          ),
        ),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('network-request-failed → NetworkFailure', () async {
      await expectLater(
        mapFirebase(
          () async => throw FirebaseException(
            plugin: 'firebase_auth',
            code: 'network-request-failed',
          ),
        ),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('deadline-exceeded → TimeoutFailure', () async {
      await expectLater(
        mapFirebase(
          () async => throw FirebaseException(
            plugin: 'cloud_firestore',
            code: 'deadline-exceeded',
          ),
        ),
        throwsA(isA<TimeoutFailure>()),
      );
    });

    test('permission-denied → PermissionFailure', () async {
      await expectLater(
        mapFirebase(
          () async => throw FirebaseException(
            plugin: 'cloud_firestore',
            code: 'permission-denied',
          ),
        ),
        throwsA(
          isA<PermissionFailure>().having((f) => f.what, 'what', 'document'),
        ),
      );
    });

    test('not-found → NotFoundFailure', () async {
      await expectLater(
        mapFirebase(
          () async => throw FirebaseException(
            plugin: 'cloud_firestore',
            code: 'not-found',
          ),
        ),
        throwsA(
          isA<NotFoundFailure>().having(
            (f) => f.what,
            'what',
            'document',
          ),
        ),
      );
    });

    test('already-exists → ConflictFailure', () async {
      await expectLater(
        mapFirebase(
          () async => throw FirebaseException(
            plugin: 'cloud_firestore',
            code: 'already-exists',
          ),
        ),
        throwsA(
          isA<ConflictFailure>().having(
            (f) => f.code,
            'code',
            'already-exists',
          ),
        ),
      );
    });

    test('cancelled → CancelledFailure', () async {
      await expectLater(
        mapFirebase(
          () async => throw FirebaseException(
            plugin: 'cloud_firestore',
            code: 'cancelled',
          ),
        ),
        throwsA(isA<CancelledFailure>()),
      );
    });

    test('storage plugin unknown code → StorageFailure', () async {
      await expectLater(
        mapFirebase(
          () async => throw FirebaseException(
            plugin: 'firebase_storage',
            code: 'unknown',
          ),
        ),
        throwsA(isA<StorageFailure>()),
      );
    });

    test('other FirebaseException → ServerFailure', () async {
      await expectLater(
        mapFirebase(
          () async => throw FirebaseException(
            plugin: 'cloud_firestore',
            code: 'internal',
          ),
        ),
        throwsA(
          isA<ServerFailure>().having((f) => f.code, 'code', 'internal'),
        ),
      );
    });

    test('invalid-credential → AuthFailure.invalidCredentials', () async {
      await expectLater(
        mapFirebase(
          () async => throw FirebaseAuthException(code: 'invalid-credential'),
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

    test('user-disabled → AuthFailure.disabled', () async {
      await expectLater(
        mapFirebase(
          () async => throw FirebaseAuthException(code: 'user-disabled'),
        ),
        throwsA(
          isA<AuthFailure>().having(
            (f) => f.reason,
            'reason',
            AuthReason.disabled,
          ),
        ),
      );
    });

    test('too-many-requests → AuthFailure.rateLimited', () async {
      await expectLater(
        mapFirebase(
          () async => throw FirebaseAuthException(code: 'too-many-requests'),
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

    test('requires-recent-login → AuthFailure.expired', () async {
      await expectLater(
        mapFirebase(
          () async =>
              throw FirebaseAuthException(code: 'requires-recent-login'),
        ),
        throwsA(
          isA<AuthFailure>().having(
            (f) => f.reason,
            'reason',
            AuthReason.expired,
          ),
        ),
      );
    });

    test('email-not-verified → AuthFailure.emailNotConfirmed', () async {
      await expectLater(
        mapFirebase(
          () async => throw FirebaseAuthException(code: 'email-not-verified'),
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

    test('SocketException → NetworkFailure', () async {
      await expectLater(
        mapFirebase(() async => throw const SocketException('offline')),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('unknown → UnknownFailure', () async {
      await expectLater(
        mapFirebase(() async => throw StateError('x')),
        throwsA(isA<UnknownFailure>()),
      );
    });

    test('AppFailure is not remapped', () async {
      await expectLater(
        mapFirebase(() async => throw const NotFoundFailure('document')),
        throwsA(isA<NotFoundFailure>()),
      );
    });

    test('success path returns value', () async {
      final value = await mapFirebase(() async => 42);
      expect(value, 42);
    });
  });
}
