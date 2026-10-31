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
  final decisions = <String>[];
  final reviews = <String>[];
  final noShows = <String>[];
  final left = <String>[];
  final welcome = <String>[];

  @override
  Future<Result<void>> requestWelcome(String eventId, {String? note}) async {
    welcome.add('request:$eventId:$note');
    return const Ok(null);
  }

  @override
  Future<Result<void>> takeWelcome(String eventId, String newcomerId, String note) async {
    welcome.add('take:$newcomerId:$note');
    return const Ok(null);
  }

  @override
  Future<Result<void>> thankGreeter(String eventId) async {
    welcome.add('thank:$eventId');
    return const Ok(null);
  }

  @override
  Future<Result<void>> setGreeter(String groupId, {required bool greeter}) async {
    welcome.add('greeter:$groupId:$greeter');
    return const Ok(null);
  }

  final stopped = <String>[];
  final confirmed = <String>[];

  @override
  Future<Result<void>> confirmAttendance(String id) async {
    confirmed.add(id);
    return const Ok(null);
  }

  @override
  Future<Result<void>> stopSeries(String seriesId) async {
    stopped.add(seriesId);
    return const Ok(null);
  }

  @override
  Future<Result<void>> leave(String id) async {
    left.add(id);
    return const Ok(null);
  }

  @override
  Future<Result<void>> setNoShow(String eventId, String userId, {required bool noShow}) async {
    noShows.add('$userId:$noShow');
    return const Ok(null);
  }

  @override
  Future<Result<void>> saveReview(String eventId, {required int rating, String comment = ''}) async {
    reviews.add('$eventId:$rating:$comment');
    return const Ok(null);
  }

  @override
  Future<Result<void>> decideRequest(String eventId, String userId, {required bool approve}) async {
    decisions.add('$userId:$approve');
    return const Ok(null);
  }

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
    child: MaterialApp(theme: GwTheme.light(), home: child),
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

  testWidgets('joining at a busy hour offers to free the other seat; the user decides', (tester) async {
    final future = DateTime.now().add(const Duration(days: 3));
    final e = GroupEvent(id: 'e1', group: _group, title: 'Gece yürüyüşü', startsAt: future, location: 'Kadıköy');
    final fake = await _pump(
      tester,
      EventScreen(eventId: 'e1', links: _links),
      detail: EventDetail(
        event: e,
        isMember: true,
        attendees: const [],
        conflicts: [EventConflict(id: 'e2', title: 'Sahil koşusu', startsAt: future)],
      ),
    );

    await tester.tap(find.text('Katıl'));
    await tester.pumpAndSettle();
    expect(find.text('Aynı saatte başka organizasyonun var'), findsOneWidget);
    expect(find.textContaining('Sahil koşusu'), findsWidgets);
    await tester.tap(find.text('Diğerinden vazgeç'));
    await tester.pumpAndSettle();
    expect(fake.attended, ['e1']);
    expect(fake.left, ['e2']);
    expect(find.text('Diğer organizasyondan vazgeçtin; yerin boşaldı.'), findsOneWidget);
  });

  testWidgets('the event form shows how many similar groups meet that day, without names', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        eventsRepositoryProvider.overrideWithValue(_FakeEvents()),
        currentUserIdProvider.overrideWithValue('u1'),
        groupEventsProvider.overrideWith((ref, id) async => const GroupEvents(eventsLeft: 3)),
        similarEventsProvider.overrideWith((ref, key) async => key.groupId == 'g1' ? 2 : null),
      ],
      child: MaterialApp(theme: GwTheme.light(), home: const EventEditorScreen(groupId: 'g1')),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('Bu tarihte ilinde aynı kategoride 2 organizasyon daha var.'), findsOneWidget);
  });

  group('Yılın özeti', () {
    const summary = YearSummary(
      year: 2026,
      attended: 14,
      hours: 41,
      groups: 3,
      provinces: 2,
      organized: 2,
      memories: 5,
      welcomed: 1,
      categories: [('Koşu', 9), ('Doğa', 4), ('Müzik', 1)],
      topGroup: 'Sahil Koşucuları',
      topGroupCount: 9,
    );

    Widget app(YearSummary? value) => ProviderScope(
          overrides: [
            eventsRepositoryProvider.overrideWithValue(_FakeEvents()),
            yearSummaryProvider.overrideWith((ref, year) async => value),
          ],
          child: MaterialApp(theme: GwTheme.light(), home: const YearSummaryScreen(year: 2026)),
        );

    testWidgets('the card fits a small phone at 130% text', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(app(summary));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('2026 yılım'), findsOneWidget);
      expect(find.text('organizasyona katıldım'), findsOneWidget);
      expect(find.text('Koşu · Doğa · Müzik'), findsOneWidget);
      expect(find.text('Sahil Koşucuları · 9 buluşma'), findsOneWidget);
      expect(find.text('Paylaş'), findsOneWidget);
    });

    testWidgets('an empty year says how it fills', (tester) async {
      await tester.pumpWidget(app(const YearSummary(year: 2026)));
      await tester.pumpAndSettle();
      expect(find.textContaining('İlk buluşmandan sonra özetin burada oluşur'), findsOneWidget);
    });

    testWidgets('someone who was there gets the card on the event page', (tester) async {
      final e = GroupEvent(
        id: 'e1', group: _group, title: 'Sabah koşusu', startsAt: DateTime.now().subtract(const Duration(days: 2)), location: 'Sahil',
      );
      await _pump(tester, EventScreen(eventId: 'e1', links: _links), detail: EventDetail(event: e, isMember: true, wasThereCount: 3));

      await tester.scrollUntilVisible(find.text('Ben de oradaydım kartını paylaş'), 200, scrollable: find.byType(Scrollable).first);
      await tester.tap(find.text('Ben de oradaydım kartını paylaş'));
      await tester.pumpAndSettle();
      expect(find.text('Bu grupla 3. organizasyonum.'), findsOneWidget);
    });
  });

  group('Geliyor musun?', () {
    GroupEvent soon({Duration inTime = const Duration(hours: 20)}) => GroupEvent(
          id: 'e1', group: _group, title: 'Sabah koşusu', startsAt: DateTime.now().add(inTime), location: 'Sahil',
          myStatus: AttendanceStatus.going, goingCount: 5,
        );

    test('asked only of a going attendee in the last day', () {
      final now = DateTime.now();
      expect(EventDetail(event: soon(), myConfirmed: false).asksConfirmation(now), isTrue);
      expect(EventDetail(event: soon(), myConfirmed: true).asksConfirmation(now), isFalse);
      expect(EventDetail(event: soon()).asksConfirmation(now), isFalse, reason: 'not going');
      expect(EventDetail(event: soon(inTime: const Duration(days: 3)), myConfirmed: false).asksConfirmation(now), isFalse);
    });

    testWidgets('a going attendee confirms the day before', (tester) async {
      final fake = await _pump(tester, EventScreen(eventId: 'e1', links: _links),
          detail: EventDetail(event: soon(), isMember: true, myConfirmed: false));

      expect(find.text('Geliyor musun?'), findsOneWidget);
      await tester.tap(find.text('Evet, geliyorum'));
      await tester.pumpAndSettle();
      expect(fake.confirmed, ['e1']);
    });

    testWidgets('"Gelemiyorum" gives the seat up', (tester) async {
      final fake = await _pump(tester, EventScreen(eventId: 'e1', links: _links),
          detail: EventDetail(event: soon(), isMember: true, myConfirmed: false));

      await tester.tap(find.text('Gelemiyorum'));
      await tester.pumpAndSettle();
      expect(fake.left, ['e1']);
    });

    testWidgets('organizers see who confirmed', (tester) async {
      await _pump(tester, EventScreen(eventId: 'e1', links: _links),
          detail: EventDetail(
            event: soon(),
            isMember: true,
            canManage: true,
            confirmedCount: 1,
            attendees: const [
              EventPerson(id: 'u2', username: 'ayse', displayName: 'Ayşe', confirmed: true),
              EventPerson(id: 'u3', username: 'can', displayName: 'Can', confirmed: false),
            ],
          ));

      await tester.scrollUntilVisible(find.textContaining('kişi geleceğini teyit etti'), 200, scrollable: find.byType(Scrollable).first);
      expect(find.text('5 katılandan 1 kişi geleceğini teyit etti.'), findsOneWidget);
      expect(find.byTooltip('Ayşe · teyit etti'), findsOneWidget);
      expect(find.byTooltip('Can'), findsOneWidget);
    });
  });

  group('Tekrarlayan organizasyon', () {
    test('a repeat goes with a new event, its last day as a date', () {
      final form = EventForm(
        title: 'Salı koşusu',
        startsAt: DateTime(2026, 11, 3, 19),
        location: 'Moda',
        repeat: EventRepeat(weeks: 2, until: DateTime(2026, 12, 29)),
      );
      expect(form.toJson()['repeat'], {'weeks': 2, 'until': '2026-12-29'});
      expect(EventForm(title: 'Tek', startsAt: DateTime(2026, 11, 3), location: 'Moda').toJson()['repeat'], isNull);
    });

    testWidgets('a new event can repeat; the last day is optional', (tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          eventsRepositoryProvider.overrideWithValue(_FakeEvents()),
          currentUserIdProvider.overrideWithValue('u1'),
          groupEventsProvider.overrideWith((ref, id) async => const GroupEvents(eventsLeft: 3)),
          similarEventsProvider.overrideWith((ref, key) async => null),
        ],
        child: MaterialApp(theme: GwTheme.light(), home: const EventEditorScreen(groupId: 'g1')),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Son tarih (isteğe bağlı)'), findsNothing);
      await tester.scrollUntilVisible(find.text('Her hafta'), 200, scrollable: find.byType(Scrollable).first);
      await tester.tap(find.text('Her hafta'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Sen durdurana kadar'), 200, scrollable: find.byType(Scrollable).first);
      expect(find.text('Sen durdurana kadar'), findsOneWidget);
      expect(find.textContaining('aylık organizasyon hakkından düşer'), findsOneWidget);
    });

    testWidgets('a repeating date says so and managers can stop the repeat', (tester) async {
      final e = GroupEvent(
        id: 'e1', group: _group, title: 'Salı koşusu', startsAt: DateTime.now().add(const Duration(days: 3)), location: 'Moda',
        series: const EventSeries(id: 's1', weeks: 1, active: true),
      );
      final fake = await _pump(tester, EventScreen(eventId: 'e1', links: _links), detail: EventDetail(event: e, isMember: true, canManage: true));

      expect(find.text('Her hafta tekrarlanır'), findsOneWidget);
      await tester.tap(find.byTooltip('Organizasyon seçenekleri'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tekrarı durdur'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(GwButton, 'Durdur'));
      await tester.pumpAndSettle();
      expect(fake.stopped, ['s1']);
    });
  });

  group('Karşılama', () {
    final upcoming = GroupEvent(
      id: 'e1', group: _group, title: 'Pazar yürüyüşü', startsAt: DateTime.now().add(const Duration(days: 2)), location: 'Belgrad',
    );
    const newcomer = EventPerson(id: 'u3', username: 'ayse', displayName: 'Ayşe Yeni');
    const greeter = EventPerson(id: 'u2', username: 'elif', displayName: 'Elif Rehber');

    Future<_FakeEvents> pumpWelcome(WidgetTester tester, EventWelcome w, {GroupEvent? event}) async {
      final fake = _FakeEvents();
      await tester.pumpWidget(ProviderScope(
        overrides: [
          eventsRepositoryProvider.overrideWithValue(fake),
          eventWelcomeProvider.overrideWith((ref, id) async => w),
        ],
        child: MaterialApp(
          theme: GwTheme.light(),
          home: Scaffold(body: SingleChildScrollView(child: EventWelcomeSection(event: event ?? upcoming, links: _links))),
        ),
      ));
      await tester.pumpAndSettle();
      return fake;
    }

    testWidgets('a first-timer asks to be greeted, with a note to be recognized by', (tester) async {
      final fake = await pumpWelcome(tester, const EventWelcome(greeters: 3, canRequest: true));

      expect(find.text('İlk kez mi geliyorsun?'), findsOneWidget);
      expect(find.textContaining('Bu grupta 3 karşılayıcı var.'), findsOneWidget);
      await tester.tap(find.text('Karşılanmak istiyorum'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Kırmızı montluyum');
      await tester.tap(find.text('İstek gönder'));
      await tester.pumpAndSettle();
      expect(fake.welcome, ['request:e1:Kırmızı montluyum']);
    });

    testWidgets('no greeters, no offer', (tester) async {
      await pumpWelcome(tester, const EventWelcome(canRequest: true));
      expect(find.text('Karşılanmak istiyorum'), findsNothing);
    });

    testWidgets('a greeted first-timer sees who and where, and thanks them afterwards', (tester) async {
      final fake = await pumpWelcome(
        tester,
        const EventWelcome(greeters: 2, mine: MyWelcome(greeter: greeter, greeterNote: 'Girişteki kafe, 08:45', canThank: true)),
      );

      expect(find.text('Elif Rehber'), findsOneWidget);
      expect(find.text('Buluşma: Girişteki kafe, 08:45'), findsOneWidget);
      await tester.tap(find.text('Teşekkür et'));
      await tester.pumpAndSettle();
      expect(fake.welcome, ['thank:e1']);
    });

    testWidgets('a going greeter takes a first-timer with a meeting note', (tester) async {
      final fake = await pumpWelcome(
        tester,
        const EventWelcome(greeters: 2, isGreeter: true, greeting: true, open: [WelcomeEntry(person: newcomer, note: 'Mavi çanta')]),
      );

      expect(find.text('Karşılanmayı bekleyenler (1)'), findsOneWidget);
      expect(find.text('Mavi çanta'), findsOneWidget);
      await tester.tap(find.widgetWithText(GwButton, 'Karşılarım'));
      await tester.pumpAndSettle();
      final take = find.widgetWithText(TextButton, 'Karşılarım');
      expect(tester.widget<TextButton>(take).onPressed, isNull, reason: 'a meeting note is required');
      await tester.enterText(find.byType(TextField), 'Otopark girişi');
      await tester.pump();
      await tester.tap(take);
      await tester.pumpAndSettle();
      expect(fake.welcome, ['take:u3:Otopark girişi']);
    });

    testWidgets('a member who went volunteers on the group page', (tester) async {
      final fake = _FakeEvents();
      await tester.pumpWidget(ProviderScope(
        overrides: [
          eventsRepositoryProvider.overrideWithValue(fake),
          groupWelcomeProvider.overrideWith((ref, id) async => const GroupWelcome(greeters: 4, canGreet: true)),
        ],
        child: MaterialApp(
          theme: GwTheme.light(),
          home: const Scaffold(body: GroupWelcomeSection(groupId: 'g1', isMember: true)),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('4 karşılayıcı'), findsOneWidget);
      await tester.tap(find.text('Karşılayıcı ol'));
      await tester.pumpAndSettle();
      expect(fake.welcome, ['greeter:g1:true']);
    });

    testWidgets('visitors only learn that first-timers are greeted', (tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [groupWelcomeProvider.overrideWith((ref, id) async => const GroupWelcome(greeters: 2))],
        child: MaterialApp(
          theme: GwTheme.light(),
          home: const Scaffold(body: GroupWelcomeSection(groupId: 'g1', isMember: false)),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('ilk organizasyonuna yalnız gitmezsin'), findsOneWidget);
      expect(find.text('Karşılayıcı ol'), findsNothing);
    });
  });

  group('Gruplar Ligi', () {
    const categories = [LeagueCategory(slug: 'hiking', name: 'Yürüyüş'), LeagueCategory(slug: 'running', name: 'Koşu')];

    testWidgets('a league table ranks groups with their points and breakdown', (tester) async {
      final opened = <String>[];
      await tester.pumpWidget(ProviderScope(
        overrides: [
          leagueCategoriesProvider.overrideWith((ref) async => categories),
          leagueTableProvider.overrideWith(
            (ref, key) async => LeagueTable(
              month: key.month,
              category: key.category,
              province: key.province,
              rows: const [
                LeagueRow(rank: 1, group: LeagueGroup(id: 'g1', handle: 'doga', name: 'Doğa Yürüyüşçüleri'), points: 42, attended: 22, held: 3, welcomes: 1),
                LeagueRow(rank: 2, group: LeagueGroup(id: 'g2', handle: 'eymir', name: 'Eymir Adımları'), points: 9, attended: 9),
              ],
            ),
          ),
        ],
        child: MaterialApp(
          theme: GwTheme.light(),
          home: LeagueScreen(category: 'hiking', province: 6, openGroup: (_, handle) => opened.add(handle)),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('42 puan'), findsOneWidget);
      expect(find.text('22 katılım · 3 organizasyon · 1 karşılama'), findsOneWidget);
      expect(find.textContaining('Sezon sürüyor.'), findsOneWidget);
      await tester.tap(find.text('Eymir Adımları'));
      expect(opened, ['eymir']);

      await tester.tap(find.byTooltip('Puanlar nasıl hesaplanır?'));
      await tester.pumpAndSettle();
      expect(find.text('Organizasyon: 5 puan'), findsOneWidget);
    });

    testWidgets('the group card shows the place and the titles', (tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          leagueCategoriesProvider.overrideWith((ref) async => categories),
          groupLeagueProvider.overrideWith(
            (ref, id) async => GroupLeague(
              month: DateTime(2026, 11),
              category: 'hiking',
              province: 6,
              rank: 2,
              points: 18,
              groups: 5,
              titles: [LeagueTitle(month: DateTime(2026, 10), rank: 1)],
            ),
          ),
        ],
        child: MaterialApp(theme: GwTheme.light(), home: const Scaffold(body: GroupLeagueSection(groupId: 'g1'))),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Ankara · Yürüyüş ligi'), findsOneWidget);
      expect(find.textContaining('5 grup arasında 2. sırada, 18 puan.'), findsOneWidget);
      expect(find.text('Ekim 2026 · Şampiyon'), findsOneWidget);
    });

    test('a month in the address is read back', () {
      expect(LeagueScreen.parseMonth('2026-10'), DateTime(2026, 10));
      expect(LeagueScreen.parseMonth('ekim'), isNull);
      expect(EventRoutes.league(category: 'hiking', province: 6, month: DateTime(2026, 10)), '/league?category=hiking&province=6&month=2026-10');
      expect(EventRoutes.league(), '/league');
    });
  });

  testWidgets('the fee is information only; outsiders are pointed to the group', (tester) async {
    final future = DateTime.now().add(const Duration(days: 3));
    final e = GroupEvent(
      id: 'e1', group: _group, title: 'Konser', startsAt: future, location: 'Moda Sahnesi',
      fee: const EventFee(amountMinor: 25000, currency: 'TRY'), feeNote: 'Kapıda ödenir',
    );
    await _pump(tester, EventScreen(eventId: 'e1', links: _links), detail: EventDetail(event: e));

    expect(find.text('Katılım ücreti: 250 ₺'), findsOneWidget);
    expect(find.text('Ücret organizasyon sahibine ödenir; GWAY ödeme almaz.'), findsOneWidget);
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

  testWidgets('the group page shows its rating and lets an attendee rate an ended event', (tester) async {
    final fake = await _pump(
      tester,
      const Scaffold(body: SingleChildScrollView(child: GroupEventsSection(groupId: 'g1', canManage: false))),
      events: GroupEvents(ratingAvg: 4.5, ratingCount: 12, toReview: [_event()]),
    );
    expect(find.text('4,5 · organizasyonlarına 12 değerlendirme'), findsOneWidget);
    expect(find.text('Nasıldı?'), findsOneWidget);
    expect(find.textContaining('Belgrad Ormanı yürüyüşü ·'), findsOneWidget);

    await tester.tap(find.byTooltip('5 yıldız'));
    await tester.pump();
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();
    expect(fake.reviews, ['e1:5:']);
  });
  test('equipment is typed comma separated', () {
    expect(equipmentItems(' Kask, Su ,, Mont '), ['Kask', 'Su', 'Mont']);
    expect(equipmentItems(''), isEmpty);
  });

  testWidgets('an approval event asks for a request and shows what to bring', (tester) async {
    final e = GroupEvent(
      id: 'e1', group: _group, title: 'Şile turu', startsAt: DateTime.now().add(const Duration(days: 3)), location: 'Kadıköy',
      categoryName: 'Motosiklet', requirements: 'En az 1 yıllık ehliyet', equipment: const ['Kask', 'Mont'], approvalRequired: true,
    );
    await _pump(tester, EventScreen(eventId: 'e1', links: _links), detail: EventDetail(event: e, isMember: true));

    expect(find.text('Katılım isteği gönder'), findsOneWidget);
    expect(find.text('En az 1 yıllık ehliyet'), findsOneWidget);
    expect(find.text('Kask'), findsOneWidget);
    expect(find.text('Doğa Yürüyüşçüleri · Motosiklet'), findsOneWidget);
    expect(find.text('Takvime ekle'), findsOneWidget);
  });

  testWidgets('managers approve or decline requests', (tester) async {
    final e = GroupEvent(
      id: 'e1', group: _group, title: 'Şile turu', startsAt: DateTime.now().add(const Duration(days: 3)), location: 'Kadıköy',
      approvalRequired: true,
    );
    final fake = await _pump(
      tester,
      EventScreen(eventId: 'e1', links: _links),
      detail: EventDetail(
        event: e,
        isMember: true,
        canManage: true,
        requests: const [EventPerson(id: 'u7', username: 'ayse', displayName: 'Ayşe Yıldız')],
      ),
    );

    expect(find.text('Katılım istekleri (1)'), findsOneWidget);
    expect(find.text('Katıl'), findsOneWidget, reason: 'managers join without a request');
    await tester.tap(find.widgetWithText(GwButton, 'Onayla'));
    await tester.pumpAndSettle();
    expect(fake.decisions, ['u7:true']);
  });
  test('calendar pages: whole weeks for a month, Monday-first weeks', () {
    final focus = DateTime(2026, 10, 21);
    final month = calendarRange(CalendarView.month, focus);
    expect(month.from, DateTime(2026, 9, 28));
    expect(month.to, DateTime(2026, 11, 2));
    expect(calendarRange(CalendarView.week, focus).from, DateTime(2026, 10, 19));
    expect(calendarRange(CalendarView.day, focus).to, DateTime(2026, 10, 22));
    expect(shiftFocus(CalendarView.month, DateTime(2026, 1, 31), 1), DateTime(2026, 2));
    expect(calendarTitle(CalendarView.week, focus), '19 – 25 Ekim 2026');
  });

  test('only my own overlapping events conflict', () {
    GroupEvent at(String id, int hour, {int? until, AttendanceStatus? mine = AttendanceStatus.going}) => GroupEvent(
          id: id, group: _group, title: id, startsAt: DateTime(2026, 10, 24, hour),
          endsAt: until == null ? null : DateTime(2026, 10, 24, until), location: 'Park', myStatus: mine,
        );
    expect(conflictingIds([at('a', 9, until: 12), at('b', 11), at('c', 13), at('d', 10, mine: null)]), {'a', 'b'});
    expect(conflictingIds([at('a', 9), at('b', 11)]), isEmpty, reason: 'without an end an event takes two hours');
  });

  testWidgets('the calendar shows the selected day and marks conflicts', (tester) async {
    final today = DateTime.now();
    final e1 = GroupEvent(id: 'e1', group: _group, title: 'Sabah yürüyüşü', startsAt: DateTime(today.year, today.month, today.day, 9),
        endsAt: DateTime(today.year, today.month, today.day, 12), location: 'Park', myStatus: AttendanceStatus.going);
    final e2 = GroupEvent(id: 'e2', group: _group, title: 'Kahvaltı', startsAt: DateTime(today.year, today.month, today.day, 11),
        location: 'Kafe', myStatus: AttendanceStatus.requested);
    final fake = _FakeEvents();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        eventsRepositoryProvider.overrideWithValue(fake),
        calendarProvider.overrideWith((ref, q) async => [e1, e2]),
      ],
      child: MaterialApp(theme: GwTheme.light(), home: const CalendarScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Takvimim'), findsOneWidget);
    expect(find.text('Sabah yürüyüşü'), findsOneWidget);
    expect(find.text('Çakışıyor'), findsNWidgets(2));
    await tester.tap(find.text('Hafta'));
    await tester.pumpAndSettle();
    expect(find.text('Kahvaltı'), findsOneWidget);
  });

  testWidgets('the event page warns about my other event at the same time', (tester) async {
    final e = GroupEvent(id: 'e1', group: _group, title: 'Konser', startsAt: DateTime.now().add(const Duration(days: 3)), location: 'Moda');
    await _pump(
      tester,
      EventScreen(eventId: 'e1', links: _links),
      detail: EventDetail(
        event: e,
        isMember: true,
        conflicts: [EventConflict(id: 'e2', title: 'Gece koşusu', startsAt: DateTime(2026, 10, 24, 20))],
      ),
    );
    expect(find.text('Bu saatte başka bir organizasyonun var'), findsOneWidget);
    expect(find.textContaining('Gece koşusu'), findsOneWidget);
  });
  test('a past event sums up attendance, stars and memories', () {
    final e = GroupEvent(
      id: 'e1', group: _group, title: 'Yürüyüş', startsAt: DateTime(2026, 10, 1, 9), location: 'Park',
      goingCount: 18, ratingAvg: 4.6, ratingCount: 8, postsCount: 12,
    );
    expect(eventSummary(e), '18 kişi katıldı · 4,6 ★ (8 değerlendirme) · 12 anı');
    expect(e.hasEnded(DateTime(2026, 10, 1, 11)), isTrue, reason: 'no end: two hours');
    expect(e.hasEnded(DateTime(2026, 10, 1, 10, 59)), isFalse);
  });

  testWidgets('attendees review a past event; memories come from the app', (tester) async {
    tester.view.physicalSize = const Size(1170, 3600);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final shared = <String>[];
    final links = EventLinks(
      openGroup: (_, _) {},
      openProfile: (_, _) {},
      shareMemory: (_, id) => shared.add(id),
      memories: (_, id) => Text('anılar:$id'),
    );
    final e = GroupEvent(
      id: 'e1', group: _group, title: 'Yürüyüş', startsAt: DateTime.now().subtract(const Duration(days: 1)), location: 'Park',
      goingCount: 3, myStatus: AttendanceStatus.going,
    );
    final fake = await _pump(
      tester,
      EventScreen(eventId: 'e1', links: links),
      detail: EventDetail(event: e, isMember: true, canPost: true, canReview: true),
    );

    expect(find.text('Nasıl geçti?'), findsOneWidget);
    expect(find.text('anılar:e1'), findsOneWidget);
    await tester.tap(find.text('Anı paylaş'));
    expect(shared, ['e1']);

    await tester.tap(find.byTooltip('4 yıldız'));
    await tester.enterText(find.widgetWithText(TextField, 'Düzenleyenlere notun (isteğe bağlı)'), 'Rota güzeldi');
    await tester.tap(find.widgetWithText(GwButton, 'Kaydet'));
    await tester.pumpAndSettle();
    expect(fake.reviews, ['e1:4:Rota güzeldi']);
  });
  testWidgets('managers take the roll after the event', (tester) async {
    tester.view.physicalSize = const Size(1170, 3600);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final e = GroupEvent(id: 'e1', group: _group, title: 'Yürüyüş', startsAt: DateTime.now().subtract(const Duration(days: 1)), location: 'Park');
    final fake = await _pump(
      tester,
      EventScreen(eventId: 'e1', links: _links),
      detail: EventDetail(
        event: e,
        isMember: true,
        canManage: true,
        roll: const [
          RollEntry(person: EventPerson(id: 'u2', username: 'elif', displayName: 'Elif Koşar')),
          RollEntry(person: EventPerson(id: 'u3', username: 'can', displayName: 'Can Dağ'), noShow: true),
        ],
      ),
    );
    expect(find.text('Yoklama'), findsOneWidget);
    expect(find.text('Gelmedi'), findsOneWidget);
    await tester.tap(find.widgetWithText(SwitchListTile, 'Elif Koşar'));
    await tester.pumpAndSettle();
    expect(fake.noShows, ['u2:true']);
  });

  testWidgets('a profile shows contributions and badges, and explains them', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        contributionsProvider.overrideWith((ref, id) async => const Contributions(
              attended: 12, organized: 2, memories: 5,
              badges: [ContributionBadge(slug: 'regular', name: 'Müdavim', description: '10 organizasyona katıl.')],
            )),
        badgeCatalogProvider.overrideWith((ref) async => const [
              ContributionBadge(slug: 'first_step', name: 'İlk adım', description: 'İlk organizasyonuna katıl.'),
              ContributionBadge(slug: 'category', name: 'tutkunu', description: 'Bir kategoride 5 organizasyona katıl.'),
            ]),
      ],
      child: MaterialApp(theme: GwTheme.light(), home: const Scaffold(body: ContributionsSection(userId: 'u1', isOwn: false))),
    ));
    await tester.pumpAndSettle();

    expect(find.text('12 katılım · 2 düzenleme · 5 anı'), findsOneWidget);
    expect(find.text('Müdavim'), findsOneWidget);
    await tester.tap(find.text('Rozetler nasıl kazanılır?'));
    await tester.pumpAndSettle();
    expect(find.text('Kategori tutkunu'), findsOneWidget);
    expect(find.textContaining('Beğeni ve takipçi sayısı sayılmaz'), findsOneWidget);
  });

  test('member lines leave out what is zero', () {
    expect(groupContributionLine((attended: 3, organized: 0)), '3 katılım');
    expect(groupContributionLine(null), isNull);
  });
}
