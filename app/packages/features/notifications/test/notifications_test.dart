import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notifications/notifications.dart';

class _FakePreferences implements NotificationsRepository {
  final saved = <NotificationPreferences>[];

  @override
  Future<Result<NotificationPreferences>> preferences() async => const Ok(NotificationPreferences());

  @override
  Future<Result<void>> savePreferences(NotificationPreferences preferences) async {
    saved.add(preferences);
    return const Ok(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Delivers arrivals by hand; list() answers with [listed].
class _FakeArrivals implements NotificationsRepository {
  final arrivals$ = StreamController<NotificationArrival>.broadcast();
  final listed = <AppNotification>[];

  @override
  Stream<NotificationArrival> arrivals() => arrivals$.stream;

  @override
  Future<Result<List<AppNotification>>> list({int? beforeId}) async => Ok(listed);

  @override
  Future<Result<int>> unreadCount() async => const Ok(0);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePush implements PushMessaging {
  final refreshes = StreamController<String>.broadcast();
  final tapped = StreamController<Map<String, Object?>>.broadcast();
  var deleted = 0;

  @override
  String get platform => 'android';

  @override
  Future<String?> token() async => 'token-of-this-phone';

  @override
  Stream<String> get tokenRefreshes => refreshes.stream;

  @override
  Future<void> deleteToken() async => deleted++;

  @override
  Stream<Map<String, Object?>> get taps => tapped.stream;
}

/// The session's token role: `unverified` during security verification, then `authenticated`.
final _signedIn = NotifierProvider<_SignedIn, String?>(_SignedIn.new);

class _SignedIn extends Notifier<String?> {
  @override
  String? build() => 'unverified';

  void verify() => state = 'authenticated';

  void signOut() => state = null;
}

class _FakeDevices implements NotificationsRepository {
  final registered = <(String, String)>[];

  @override
  Future<Result<void>> registerPushDevice(String token, String platform) async {
    registered.add((token, platform));
    return const Ok(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

AppNotification _n(int id, DateTime at, {NotificationType type = NotificationType.like, String? comment}) => AppNotification(
      id: id,
      type: type,
      actor: const NotificationActor(id: 'u2', username: 'elif', displayName: 'Elif'),
      createdAt: at,
      postId: 'p1',
      comment: comment,
    );

void main() {
  test('sections are today, this week and earlier, empty ones left out', () {
    final now = DateTime(2026, 10, 19, 15);
    final groups = groupByPeriod([
      _n(4, DateTime(2026, 10, 19, 9)),
      _n(3, DateTime(2026, 10, 17)),
      _n(2, DateTime(2026, 10, 13, 1)),
      _n(1, DateTime(2026, 9, 1)),
    ], now);

    expect(groups.map((g) => g.$1), [NotificationPeriod.today, NotificationPeriod.thisWeek, NotificationPeriod.earlier]);
    expect(groups[1].$2.map((n) => n.id), [3, 2]);
    expect(groupByPeriod([_n(1, DateTime(2026, 9, 1))], now).single.$1, NotificationPeriod.earlier);
  });

  test('every type has a Turkish sentence; comment ones open the comments', () {
    final at = DateTime(2026);
    for (final type in NotificationType.values) {
      expect(_n(1, at, type: type).action, isNotEmpty);
    }
    final reply = _n(1, at, type: NotificationType.reply, comment: 'Katılıyorum');
    expect(reply.action, 'yorumuna yanıt verdi: Katılıyorum');
    expect(reply.aboutComment, isTrue);
    expect(_n(1, at).aboutComment, isFalse);
  });

  test('codes from the database parse; unknown ones are skipped', () {
    expect(NotificationType.tryParse('comment_like'), NotificationType.commentLike);
    expect(NotificationType.tryParse('follow_request')!.isFollow, isTrue);
    expect(NotificationType.tryParse('later_type'), isNull);
  });

  test('a live_started notification names the broadcast', () {
    final n = AppNotification(
      id: 1,
      type: NotificationType.liveStarted,
      actor: const NotificationActor(id: 'u2', username: 'elif', displayName: 'Elif'),
      createdAt: DateTime(2026),
      liveId: 'b1',
      liveTitle: 'Pazar konseri',
    );
    expect(NotificationType.tryParse('live_started'), NotificationType.liveStarted);
    expect(n.action, 'canlı yayına başladı: Pazar konseri');
  });

  test('a live_scheduled notification names the broadcast and its time', () {
    final n = AppNotification(
      id: 1,
      type: NotificationType.liveScheduled,
      actor: const NotificationActor(id: 'u2', username: 'elif', displayName: 'Elif'),
      createdAt: DateTime(2026),
      liveId: 'b1',
      liveTitle: 'Pazar konseri',
      liveScheduledAt: DateTime(2026, 10, 27, 20),
    );
    expect(NotificationType.tryParse('live_scheduled'), NotificationType.liveScheduled);
    expect(n.action, '27 Ekim 2026, 20:00 için canlı yayın planladı: Pazar konseri');
    expect(NotificationType.liveScheduled.isLive && NotificationType.liveStarted.isLive, isTrue);
    expect(NotificationType.like.isLive, isFalse);
  });

  testWidgets('a live notification rings and its strip opens the broadcast; others stay quiet', (tester) async {
    final repo = _FakeArrivals();
    var rings = 0;
    final opened = <String>[];
    await tester.pumpWidget(ProviderScope(
      overrides: [
        currentUserIdProvider.overrideWithValue('u1'),
        notificationsRepositoryProvider.overrideWithValue(repo),
        liveAlertSoundProvider.overrideWithValue(() async => rings++),
      ],
      child: MaterialApp(
        theme: GwTheme.light(),
        builder: (_, child) => LiveNotificationAlerts(openLive: opened.add, child: child!),
        home: const Scaffold(),
      ),
    ));
    await tester.pump();

    repo.arrivals$.add(const NotificationArrival(id: 7, type: NotificationType.like));
    await tester.pump();
    expect(rings, 0);

    repo.listed.add(AppNotification(
      id: 8,
      type: NotificationType.liveStarted,
      actor: const NotificationActor(id: 'u2', username: 'elif', displayName: 'Elif'),
      createdAt: DateTime(2026),
      liveId: 'b1',
      liveTitle: 'Pazar konseri',
    ));
    repo.arrivals$.add(const NotificationArrival(id: 8, type: NotificationType.liveStarted, liveId: 'b1'));
    await tester.pumpAndSettle();
    expect(rings, 1);
    expect(find.text('elif canlı yayına başladı: Pazar konseri'), findsOneWidget);

    await tester.tap(find.text('Katıl'));
    expect(opened, ['b1']);
  });

  test('event reminders say tomorrow or within the hour', () {
    AppNotification reminder(Duration before) {
      final created = DateTime(2026, 10, 20, 9);
      return AppNotification(
        id: 1,
        type: NotificationType.eventReminder,
        actor: const NotificationActor(id: 'u2', username: 'elif', displayName: 'Elif'),
        createdAt: created,
        eventId: 'e1',
        eventTitle: 'Gece yürüyüşü',
        eventStartsAt: created.add(before),
      );
    }

    expect(reminder(const Duration(hours: 20)).action, '"Gece yürüyüşü" yarın başlıyor. Geliyor musun? Teyit et.');
    expect(reminder(const Duration(minutes: 40)).action, '"Gece yürüyüşü" 1 saat içinde başlıyor.');
    expect(NotificationType.tryParse('event_promoted'), NotificationType.eventPromoted);
  });
  test('sanction notices speak for the group; case votes name the group', () {
    const group = NotificationGroup(id: 'g1', handle: 'doga', name: 'Doğa Yürüyüşçüleri');
    final ban = AppNotification(
      id: 1,
      type: NotificationType.sanctionApplied,
      actor: const NotificationActor(id: 'u1', username: 'sahip', displayName: 'Sahip'),
      createdAt: DateTime(2026),
      group: group,
      sanctionType: 'ban',
    );
    expect(ban.type.fromGroup, isTrue);
    expect(ban.lead, 'Doğa Yürüyüşçüleri');
    expect(ban.action, 'grubundan uzaklaştırıldın. Ayrıntılar ve itiraz için dokun.');

    final vote = AppNotification(
      id: 2,
      type: NotificationType.caseVote,
      actor: const NotificationActor(id: 'u2', username: 'moderator', displayName: 'Moderatör'),
      createdAt: DateTime(2026),
      group: group,
    );
    expect(vote.lead, 'moderator');
    expect(vote.action, 'Doğa Yürüyüşçüleri grubunda bir disiplin dosyası açtı; oyunu bekliyor.');
  });
  testWidgets('the phone registers for push while signed in, forgets it on sign-out and opens taps', (tester) async {
    final push = _FakePush();
    final repo = _FakeDevices();
    final opened = <String>[];
    var listOpened = 0;
    await tester.pumpWidget(ProviderScope(
      overrides: [
        sessionRoleProvider.overrideWith((ref) => ref.watch(_signedIn)),
        notificationsRepositoryProvider.overrideWithValue(repo),
        pushMessagingProvider.overrideWithValue(push),
      ],
      child: PushNotifications(openLive: opened.add, openNotifications: () => listOpened++, child: const SizedBox()),
    ));
    await tester.pump();
    // Not while the session is still in security verification: its token may not write yet.
    expect(repo.registered, isEmpty);

    ProviderScope.containerOf(tester.element(find.byType(SizedBox))).read(_signedIn.notifier).verify();
    await tester.pump();
    expect(repo.registered, [('token-of-this-phone', 'android')]);

    push.refreshes.add('new-token-of-this-phone');
    push.tapped
      ..add({'type': 'live_started', 'live_id': 'b1'})
      ..add({'type': 'like'});
    await tester.pump();
    expect(repo.registered.last, ('new-token-of-this-phone', 'android'));
    expect(opened, ['b1']);
    expect(listOpened, 1);

    ProviderScope.containerOf(tester.element(find.byType(SizedBox))).read(_signedIn.notifier).signOut();
    await tester.pump();
    expect(push.deleted, 1);
  });
  testWidgets('turning live broadcast notices off saves it', (tester) async {
    final repo = _FakePreferences();
    await tester.pumpWidget(ProviderScope(
      overrides: [notificationsRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(theme: GwTheme.light(), home: const NotificationPreferencesScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Planlanan ve başlayan yayınlar'), 100);
    await tester.tap(find.text('Planlanan ve başlayan yayınlar'));
    await tester.pumpAndSettle();
    expect(repo.saved.single.liveBroadcasts, isFalse);
    expect(repo.saved.single.reminderDay, isTrue);
  });
  testWidgets('turning a reminder off saves it', (tester) async {
    final repo = _FakePreferences();
    await tester.pumpWidget(ProviderScope(
      overrides: [notificationsRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(theme: GwTheme.light(), home: const NotificationPreferencesScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('1 saat önce hatırlat'));
    await tester.pumpAndSettle();
    expect(repo.saved.single.reminderHour, isFalse);
    expect(repo.saved.single.reminderDay, isTrue);
    expect(tester.widget<SwitchListTile>(find.widgetWithText(SwitchListTile, '1 saat önce hatırlat')).value, isFalse);
  });
  test('a completed goal names it', () {
    final n = AppNotification(
      id: 3,
      type: NotificationType.goalCompleted,
      actor: const NotificationActor(id: 'u1', username: 'sahip', displayName: 'Sahip'),
      createdAt: DateTime(2026),
      goalId: 'q1',
      goalTitle: 'Ekim yürüyüşleri',
    );
    expect(n.action, '"Ekim yürüyüşleri" hedefini tamamladın! Rozetin profilinde.');
  });
}
