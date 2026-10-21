import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live/live.dart';

const _group = LiveGroup(id: 'g1', handle: 'akustik', name: 'Akustik Geceler');
const _host = LivePerson(id: 'host', username: 'deniz', displayName: 'Deniz');

LiveBroadcast _broadcast(String id, LiveStatus status, {DateTime? scheduledAt, LivePerson? host = _host}) => LiveBroadcast(
      id: id,
      title: status == LiveStatus.live ? 'Akşam sohbeti' : 'Pazar konseri',
      status: status,
      group: _group,
      host: host,
      scheduledAt: scheduledAt,
      startedAt: status == LiveStatus.live ? DateTime.now() : null,
    );

/// Records starts and reminders; nothing else is called by these screens.
class _FakeLive implements LiveRepository {
  final starts = <(String, String, DateTime?)>[];
  final reminders = <(String, bool)>[];

  @override
  Future<Result<String>> start(String groupId, {required String title, DateTime? scheduledAt}) async {
    starts.add((groupId, title, scheduledAt));
    return const Ok('new');
  }

  @override
  Future<Result<void>> setReminder(String id, {required bool on}) async {
    reminders.add((id, on));
    return const Ok(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<_FakeLive> _pump(WidgetTester tester, Widget child, {GroupLive? data, String me = 'member'}) async {
  final fake = _FakeLive();
  await tester.pumpWidget(ProviderScope(
    overrides: [
      liveRepositoryProvider.overrideWithValue(fake),
      currentUserIdProvider.overrideWithValue(me),
      if (data != null) groupLiveProvider.overrideWith((ref, id) async => data),
      liveBroadcastProvider.overrideWith((ref, id) async => _broadcast(id, LiveStatus.ended)),
    ],
    child: MaterialApp(theme: GxTheme.light(), home: Scaffold(body: SingleChildScrollView(child: child))),
  ));
  await tester.pumpAndSettle();
  return fake;
}

void main() {
  group('actions on others follow the rank rule', () {
    const listener = (role: LiveRole.listener, rank: 10, muted: false);
    const speaker = (role: LiveRole.speaker, rank: 10, muted: false);
    const hostTarget = (role: LiveRole.host, rank: 80, muted: false);

    test('only managers get a menu', () {
      expect(liveActionsFor(manager: false, myRank: 100, target: listener), isEmpty);
    });

    test('listeners can be invited and kicked, speakers removed, muted and kicked', () {
      expect(liveActionsFor(manager: true, myRank: 50, target: listener), [LiveAction.inviteToStage, LiveAction.kick]);
      expect(liveActionsFor(manager: true, myRank: 50, target: speaker),
          [LiveAction.removeFromStage, LiveAction.mute, LiveAction.kick]);
      expect(liveActionsFor(manager: true, myRank: 50, target: (role: LiveRole.speaker, rank: 10, muted: true)),
          [LiveAction.removeFromStage, LiveAction.unmute, LiveAction.kick]);
    });

    test('nobody sanctions an equal or higher rank; inviting needs no rank', () {
      expect(liveActionsFor(manager: true, myRank: 50, target: hostTarget), isEmpty);
      expect(liveActionsFor(manager: true, myRank: 10, target: (role: LiveRole.listener, rank: 10, muted: false)),
          [LiveAction.inviteToStage]);
      expect(liveActionsFor(manager: true, myRank: 100, target: hostTarget), [LiveAction.mute]);
    });
  });

  test('a scheduled broadcast starts from 15 minutes before its time', () {
    final at = DateTime(2026, 10, 20, 20);
    final b = _broadcast('b', LiveStatus.scheduled, scheduledAt: at);
    expect(b.canStartAt(at.subtract(const Duration(minutes: 16))), isFalse);
    expect(b.canStartAt(at.subtract(const Duration(minutes: 15))), isTrue);
  });

  testWidgets('members see the live card and remind themselves of upcoming broadcasts', (tester) async {
    final fake = await _pump(
      tester,
      const GroupLiveSection(groupId: 'g1', canStart: false),
      data: GroupLive(
        live: _broadcast('b1', LiveStatus.live),
        scheduled: [_broadcast('b2', LiveStatus.scheduled, scheduledAt: DateTime.now().add(const Duration(days: 1)))],
      ),
    );

    expect(find.byType(GxLiveBadge), findsOneWidget);
    expect(find.text('Akşam sohbeti'), findsOneWidget);
    expect(find.text('Deniz sunuyor'), findsOneWidget);
    expect(find.text('Katıl'), findsOneWidget);
    expect(find.text('Yayın başlat'), findsNothing);

    await tester.tap(find.text('Hatırlat'));
    await tester.pumpAndSettle();
    expect(fake.reminders.single, ('b2', true));
    expect(find.text('Hatırlatılacak'), findsOneWidget);
  });

  testWidgets('the host manages a scheduled broadcast instead of reminding', (tester) async {
    await _pump(
      tester,
      const GroupLiveSection(groupId: 'g1', canStart: true),
      me: 'host',
      data: GroupLive(scheduled: [_broadcast('b2', LiveStatus.scheduled, scheduledAt: DateTime.now().add(const Duration(minutes: 10)))]),
    );

    expect(find.text('İptal'), findsOneWidget);
    expect(find.text('Başlat'), findsOneWidget);
    expect(find.text('Hatırlat'), findsNothing);
    expect(find.text('Yayın başlat'), findsOneWidget);
  });

  testWidgets('nothing shows for members when there is no broadcast', (tester) async {
    await _pump(tester, const GroupLiveSection(groupId: 'g1', canStart: false), data: const GroupLive());
    expect(find.byType(GxLiveButton), findsNothing);
    expect(find.byType(GxLiveBadge), findsNothing);
  });

  testWidgets('starting asks for a title, shows the minutes left and can schedule', (tester) async {
    final fake = await _pump(tester, const GroupLiveSection(groupId: 'g1', canStart: true), data: const GroupLive(minutesLeft: 45));

    await tester.tap(find.text('Yayın başlat'));
    await tester.pumpAndSettle();
    expect(find.text('Bu ay kalan canlı yayın süren: 45 dakika.'), findsOneWidget);

    await tester.tap(find.text('Yayını başlat'));
    await tester.pumpAndSettle();
    expect(find.text('Başlık en az 3 karakter olmalı.'), findsOneWidget);
    expect(fake.starts, isEmpty);

    await tester.enterText(find.widgetWithText(TextFormField, 'Başlık'), 'Pazar yürüyüşü planı');
    await tester.tap(find.text('Planla').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(GxButton, 'Planla'));
    await tester.pumpAndSettle();

    final (group, title, at) = fake.starts.single;
    expect((group, title), ('g1', 'Pazar yürüyüşü planı'));
    expect(at!.isAfter(DateTime.now().add(const Duration(minutes: 50))), isTrue);
    expect(find.text('Yayın planlandı. Üyeler hatırlatma isteyebilir.'), findsOneWidget);
  });

  testWidgets('no minutes left keeps the start button off', (tester) async {
    await _pump(tester, const GroupLiveSection(groupId: 'g1', canStart: true), data: const GroupLive(minutesLeft: 0));
    await tester.tap(find.text('Yayın başlat'));
    await tester.pumpAndSettle();

    expect(find.textContaining('canlı yayın süresi doldu'), findsOneWidget);
    expect(tester.widget<GxLiveButton>(find.widgetWithText(GxLiveButton, 'Yayını başlat')).onPressed, isNull);
  });

  testWidgets('an ended broadcast opens as a closed room', (tester) async {
    await _pump(tester, const SizedBox(height: 800, child: LiveRoomScreen(broadcastId: 'b9')));
    expect(find.text('Bu yayın sona erdi.'), findsOneWidget);
  });
}
