import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:identity/identity.dart';

class _FakePresence implements PresenceRepository {
  final log = <String>[];

  @override
  Future<Result<void>> touch(PresencePlatform platform) async {
    log.add('touch ${platform.name}');
    return const Ok(null);
  }

  @override
  Future<Result<void>> leave() async {
    log.add('leave');
    return const Ok(null);
  }
}

Future<_FakePresence> _pump(WidgetTester tester, {String? role = 'authenticated'}) async {
  final presence = _FakePresence();
  await tester.pumpWidget(ProviderScope(
    overrides: [
      presenceRepositoryProvider.overrideWithValue(presence),
      sessionRoleProvider.overrideWithValue(role),
      currentUserIdProvider.overrideWithValue(role == null ? null : 'u1'),
    ],
    child: const PresenceBeacon(child: SizedBox()),
  ));
  return presence;
}

void main() {
  testWidgets('beats while the app is in front and leaves the list when it goes to the background', (tester) async {
    final presence = await _pump(tester);
    expect(presence.log, ['touch android']);

    await tester.pump(PresenceBeacon.beat);
    expect(presence.log, ['touch android', 'touch android'], reason: 'a beat every 45 seconds');

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    await tester.pump(PresenceBeacon.beat * 2);
    expect(presence.log.last, 'leave');
    expect(presence.log.where((e) => e.startsWith('touch')), hasLength(2), reason: 'no beats in the background');

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(presence.log.last, 'touch android');
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('an unverified session does not appear on the live list', (tester) async {
    final presence = await _pump(tester, role: 'unverified');
    await tester.pump(PresenceBeacon.beat);
    expect(presence.log, isEmpty);
    await tester.pumpWidget(const SizedBox());
  });
}
