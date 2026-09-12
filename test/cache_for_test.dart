import 'package:flutter_data_kit/flutter_data_kit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemsa_core_kit/lemsa_core_kit.dart';

void main() {
  ProviderContainer container() => ProviderContainer.test(
    retry: (int _, Object _) => null,
  );

  test('failed fetch is not cached', () async {
    var calls = 0;
    final provider = FutureProvider.autoDispose<String>((ref) async {
      calls++;
      throw const NetworkFailure();
    });

    final c = container();

    final sub = c.listen(
      provider,
      (AsyncValue<String>? _, AsyncValue<String> _) {},
    );
    await Future<void>.delayed(Duration.zero);

    expect(c.read(provider).hasError, isTrue);
    expect(c.read(provider).error, isA<NetworkFailure>());
    expect(calls, 1);

    sub.close();
    await Future<void>.delayed(Duration.zero);

    expect(c.exists(provider), isFalse);

    c.listen(provider, (AsyncValue<String>? _, AsyncValue<String> _) {});
    await Future<void>.delayed(Duration.zero);
    expect(calls, 2);
  });

  test('successful fetch stays cached for the duration', () async {
    var calls = 0;
    final provider = FutureProvider.autoDispose<String>((ref) async {
      calls++;
      const value = 'ok';
      ref.cacheFor(const Duration(minutes: 5));
      return value;
    });

    final c = container();

    final sub = c.listen(
      provider,
      (AsyncValue<String>? _, AsyncValue<String> _) {},
    );
    await Future<void>.delayed(Duration.zero);

    expect(c.read(provider).value, 'ok');
    expect(calls, 1);

    sub.close();
    await Future<void>.delayed(Duration.zero);

    expect(c.exists(provider), isTrue);
    expect(c.read(provider).value, 'ok');
    expect(calls, 1);
  });
}
