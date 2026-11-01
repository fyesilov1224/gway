import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late int builds;
  late ProviderContainer container;

  ProviderContainer containerWith() {
    builds = 0;
    final c = ProviderContainer(overrides: [currentUserIdProvider.overrideWithValue('u1')]);
    addTearDown(c.dispose);
    return c;
  }

  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 20));

  test('keeps the value after the screen is left and shows it again without fetching', () async {
    container = containerWith();
    final provider = FutureProvider.autoDispose<int>((ref) async {
      ref.cacheFor(keep: const Duration(hours: 1), staleAfter: const Duration(hours: 1));
      return ++builds;
    });

    var sub = container.listen(provider, (_, _) {});
    expect(await container.read(provider.future), 1);
    sub.close();
    await settle();

    sub = container.listen(provider, (_, _) {});
    expect(sub.read(), const AsyncData(1));
    await settle();
    expect(builds, 1);
  });

  test('refetches stale data in the background while the old value stays', () async {
    container = containerWith();
    final provider = FutureProvider.autoDispose<int>((ref) async {
      ref.cacheFor(keep: const Duration(hours: 1), staleAfter: Duration.zero);
      return ++builds;
    });

    var sub = container.listen(provider, (_, _) {});
    await container.read(provider.future);
    sub.close();
    await settle();

    final seen = <AsyncValue<int>>[];
    sub = container.listen(provider, (_, next) => seen.add(next), fireImmediately: true);
    await settle();

    expect(seen.first, const AsyncData(1));
    expect(seen.every((v) => v.hasValue), isTrue, reason: 'no skeleton while refreshing');
    expect(sub.read().value, 2);
  });

  test('drops the value once the keep time has passed', () async {
    container = containerWith();
    final provider = FutureProvider.autoDispose<int>((ref) async {
      ref.cacheFor(keep: const Duration(milliseconds: 10), staleAfter: const Duration(hours: 1));
      return ++builds;
    });

    final sub = container.listen(provider, (_, _) {});
    await container.read(provider.future);
    sub.close();
    await Future<void>.delayed(const Duration(milliseconds: 60));

    expect(container.exists(provider), isFalse);
  });
}
