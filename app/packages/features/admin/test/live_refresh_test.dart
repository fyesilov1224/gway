import 'package:admin/src/presentation/live_refresh.dart';
import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late int builds;

  ProviderContainer containerWith() {
    builds = 0;
    final c = ProviderContainer(overrides: [currentUserIdProvider.overrideWithValue('u1')]);
    addTearDown(c.dispose);
    return c;
  }

  FutureProvider<int> counter() => FutureProvider.autoDispose<int>((ref) async {
        ref.liveFor(every: const Duration(milliseconds: 30));
        return ++builds;
      });

  test('fetches again while a screen shows the value, keeping the old value meanwhile', () async {
    final container = containerWith();
    final provider = counter();
    final seen = <AsyncValue<int>>[];
    container.listen(provider, (_, next) => seen.add(next), fireImmediately: true);
    await container.read(provider.future);

    await Future<void>.delayed(const Duration(milliseconds: 100));

    expect(builds, greaterThanOrEqualTo(3));
    expect(seen.skipWhile((v) => !v.hasValue).every((v) => v.hasValue), isTrue, reason: 'no skeleton between refreshes');
  });

  test('stops fetching once no screen listens', () async {
    final container = containerWith();
    final provider = counter();
    final sub = container.listen(provider, (_, _) {});
    await container.read(provider.future);
    sub.close();
    final afterLeave = builds;

    await Future<void>.delayed(const Duration(milliseconds: 100));

    expect(builds, afterLeave);
  });
}
