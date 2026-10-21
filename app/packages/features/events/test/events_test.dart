import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:events/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _group = EventGroup(id: 'g1', handle: 'doga', name: 'Doğa Yürüyüşçüleri');

GroupEvent _event({int? capacity, int going = 3, AttendanceStatus? mine, int? place, DateTime? canceledAt}) => GroupEvent(
      id: 'e1',
      group: _group,
      title: 'Belgrad Ormanı yürüyüşü',
      startsAt: DateTime(2026, 10, 24, 9),
      endsAt: DateTime(2026, 10, 24, 13),
      location: 'Bahçeköy girişi',
      capacity: capacity,
      goingCount: going,
      waitlistCount: capacity != null && going >= capacity ? 2 : 0,
      fee: const EventFee(amountMinor: 15000, currency: 'TRY'),
      feeNote: 'Yerinde nakit',
      myStatus: mine,
      myPlace: place,
      canceledAt: canceledAt,
      cancelReason: canceledAt == null ? null : 'Hava durumu',
    );

const _poll = Poll(
  id: 'p1',
  question: 'Hangi gün?',
  options: [PollOption(id: 1, label: 'Cumartesi', votes: 3), PollOption(id: 2, label: 'Pazar', votes: 1)],
  voters: 4,
);

/// Records attendance and votes; nothing else is called by these screens.
class _FakeEvents implements EventsRepository {
  final attended = <String>[];
  final votes = <(String, Set<int>)>[];

  @override
  Future<Result<AttendanceResult>> attend(String id) async {
    attended.add(id);
    return const Ok((status: AttendanceStatus.waitlisted, place: 3));
  }

  @override
  Future<Result<void>> vote(Poll poll, Set<int> optionIds) async {
    votes.add((poll.id, optionIds));
    return const Ok(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _links = EventLinks(openGroup: (_, _) {}, openProfile: (_, _) {});

Future<_FakeEvents> _pump(WidgetTester tester, Widget child, {EventDetail? detail, List<Poll> polls = const [], GroupEvents? events}) async {
  final fake = _FakeEvents();
  await tester.pumpWidget(ProviderScope(
    overrides: [
      eventsRepositoryProvider.overrideWithValue(fake),
      currentUserIdProvider.overrideWithValue('u1'),
      if (detail != null) eventDetailProvider.overrideWith((ref, id) async => detail),
      pollsProvider.overrideWith((ref, scope) async => polls),
      if (events != null) groupEventsProvider.overrideWith((ref, id) async => events),
    ],
    child: MaterialApp(theme: GxTheme.light(), home: child),
  ));
  await tester.pumpAndSettle();
  return fake;
}

void main() {
  test('dates read like a calendar entry', () {
    expect(eventWhen(_event()), 'Cumartesi, 24 Ekim 2026 · 09:00–13:00');
    expect(eventSeats(_event(capacity: 3)), '3 / 3 kişi · 2 bekliyor');
    expect(eventSeats(_event()), '3 kişi katılıyor');
    expect(_event(capacity: 3).isFull, isTrue);
    expect(const EventFee(amountMinor: 15000, currency: 'TRY').label, '150 ₺');
  });

  test('poll shares add up from the votes', () {
    expect(_poll.totalVotes, 4);
    expect(_poll.share(_poll.options.first), 0.75);
    expect(_poll.voted, isFalse);
  });

  testWidgets('a full event offers the waitlist and says where you are', (tester) async {
    final future = DateTime.now().add(const Duration(days: 3));
    final full = GroupEvent(
      id: 'e1', group: _group, title: 'Gece yürüyüşü', startsAt: future, location: 'Kadıköy', capacity: 2, goingCount: 2,
    );
    final fake = await _pump(tester, EventScreen(eventId: 'e1', links: _links), detail: EventDetail(event: full, isMember: true, attendees: const []));

    expect(find.text('Bekleme listesine gir'), findsOneWidget);
    await tester.tap(find.text('Bekleme listesine gir'));
    await tester.pumpAndSettle();
    expect(fake.attended, ['e1']);
    expect(find.text('Bekleme listesine girdin (3. sıra). Yer açılınca haber vereceğiz.'), findsOneWidget);
  });

  testWidgets('the fee is information only; outsiders are pointed to the group', (tester) async {
    final future = DateTime.now().add(const Duration(days: 3));
    final e = GroupEvent(
      id: 'e1', group: _group, title: 'Konser', startsAt: future, location: 'Moda Sahnesi',
      fee: const EventFee(amountMinor: 25000, currency: 'TRY'), feeNote: 'Kapıda ödenir',
    );
    await _pump(tester, EventScreen(eventId: 'e1', links: _links), detail: EventDetail(event: e));

    expect(find.text('Katılım ücreti: 250 ₺'), findsOneWidget);
    expect(find.text('Ücret organizasyon sahibine ödenir; GrupX ödeme almaz.'), findsOneWidget);
    expect(find.text('Doğa Yürüyüşçüleri grubuna katıl'), findsOneWidget);
    expect(find.text('Katıl'), findsNothing);
    expect(find.byTooltip('Şikayet et'), findsOneWidget);
  });

  testWidgets('a canceled event shows why and takes nobody', (tester) async {
    final e = GroupEvent(
      id: 'e1', group: _group, title: 'Konser', startsAt: DateTime.now().add(const Duration(days: 3)), location: 'Moda',
      canceledAt: DateTime.now(), cancelReason: 'Hava durumu',
    );
    await _pump(tester, EventScreen(eventId: 'e1', links: _links), detail: EventDetail(event: e, isMember: true));

    expect(find.text('Bu organizasyon iptal edildi: Hava durumu'), findsOneWidget);
    expect(find.text('Katıl'), findsNothing);
  });

  testWidgets('a single-choice vote is sent at once and shows the results', (tester) async {
    final fake = await _pump(
      tester,
      const Scaffold(body: SingleChildScrollView(child: PollsSection(scope: (groupId: 'g1', eventId: null), canManage: false))),
      polls: [_poll],
    );

    expect(find.text('75%'), findsNothing);
    await tester.tap(find.text('Cumartesi'));
    await tester.pumpAndSettle();
    expect(fake.votes.single.$1, 'p1');
    expect(fake.votes.single.$2, {1});
  });

  testWidgets('a multiple-choice poll waits for "Oy ver"', (tester) async {
    const multi = Poll(
      id: 'p2',
      question: 'Neler getirelim?',
      allowsMultiple: true,
      options: [PollOption(id: 1, label: 'Su'), PollOption(id: 2, label: 'Kumanya'), PollOption(id: 3, label: 'Kamp ocağı')],
    );
    final fake = await _pump(
      tester,
      const Scaffold(body: SingleChildScrollView(child: PollsSection(scope: (groupId: 'g1', eventId: null), canManage: false))),
      polls: [multi],
    );

    await tester.tap(find.text('Su'));
    await tester.tap(find.text('Kumanya'));
    await tester.pump();
    expect(fake.votes, isEmpty);
    await tester.tap(find.text('Oy ver'));
    await tester.pumpAndSettle();
    expect(fake.votes.single.$1, 'p2');
    expect(fake.votes.single.$2, {1, 2});
  });

  testWidgets('results are shown after voting; anonymous polls hide voters', (tester) async {
    const voted = Poll(
      id: 'p3',
      question: 'Hangi gün?',
      isAnonymous: true,
      options: [PollOption(id: 1, label: 'Cumartesi', votes: 3, mine: true), PollOption(id: 2, label: 'Pazar', votes: 1)],
      voters: 4,
    );
    await _pump(
      tester,
      const Scaffold(body: SingleChildScrollView(child: PollsSection(scope: (groupId: 'g1', eventId: null), canManage: true))),
      polls: [voted],
    );

    expect(find.text('75%'), findsOneWidget);
    expect(find.text('25%'), findsOneWidget);
    expect(find.textContaining('Gizli oylama'), findsOneWidget);
    expect(find.byTooltip('Oy verenler'), findsNothing);
    expect(find.text('Anket aç'), findsOneWidget);
  });

  testWidgets('members see nothing when a group has no events', (tester) async {
    await _pump(tester, const Scaffold(body: GroupEventsSection(groupId: 'g1', canManage: false)), events: const GroupEvents());
    expect(find.text('Organizasyonlar'), findsNothing);
  });

  testWidgets('managers see how many events are left this month', (tester) async {
    await _pump(tester, const Scaffold(body: GroupEventsSection(groupId: 'g1', canManage: true)), events: const GroupEvents(eventsLeft: 0));
    expect(find.textContaining('organizasyon hakkı doldu'), findsOneWidget);
    expect(tester.widget<TextButton>(find.widgetWithText(TextButton, 'Oluştur')).onPressed, isNull);
  });
}
