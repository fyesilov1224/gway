import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:matching/matching.dart';

const _elif = MatchCard(
  userId: 'u2',
  displayName: 'Elif',
  age: 29,
  gender: MatchGender.woman,
  province: 34,
  about: 'Kamp ve akustik gitar.',
  interests: ['music', 'hiking'],
  sharedInterests: {'music'},
  sharedGroups: [(name: 'Akustik Geceler', handle: 'akustik.geceler'), (name: 'Doğa Yürüyüşü', handle: 'doga')],
);

final _profile = MatchProfile(
  draft: MatchProfileDraft(birthDate: DateTime(1994, 4, 4), gender: MatchGender.man, province: 34, dating: true, interestedIn: const {MatchGender.woman}),
  photos: const [
    MatchPhoto(id: 'p1', path: 'me/a.jpg', position: 0, url: ''),
    MatchPhoto(id: 'p2', path: 'me/b.jpg', position: 1, url: ''),
  ],
);

/// Records swipes and ended matches; [matchOnLike] makes every like a match.
class _FakeMatching implements MatchingRepository {
  _FakeMatching({this.profile, this.matchOnLike = false, this.premium = false});

  final MatchProfile? profile;
  final bool matchOnLike;
  final bool premium;
  final swipes = <(String, MatchMode, SwipeKind)>[];
  final ended = <String>[];
  final saved = <MatchProfileDraft>[];

  @override
  Future<Result<MatchProfile?>> myProfile() async => Ok(profile);

  @override
  Future<Result<List<MatchCard>>> deck(MatchMode mode, {MatchFilters filters = const MatchFilters()}) async => const Ok([_elif]);

  @override
  Future<Result<MatchStatus>> status() async => Ok(MatchStatus(
        features: premium ? {...MatchFeature.values} : const {},
        packages: premium ? {MatchPackage.all: DateTime(2026, 11, 26)} : const {},
        likesLeft: premium ? null : 7,
        superLikesLeft: 1,
        boostUsedToday: false,
        boostMinutes: 30,
        admirers: const {MatchMode.friend: 0, MatchMode.dating: 2},
      ));

  @override
  Future<Result<List<MatchCard>>> admirers(MatchMode mode) async => const Ok([_elif]);

  @override
  Future<Result<SwipeOutcome>> swipe(String userId, MatchMode mode, SwipeKind kind) async {
    swipes.add((userId, mode, kind));
    return Ok(SwipeOutcome(matched: kind != SwipeKind.pass && matchOnLike, matchId: 'm1', likesLeft: 6, superLikesLeft: 0));
  }

  /// Locked without the reveal package.
  @override
  Future<Result<List<MatchSummary>>> matches() async => Ok([
        premium
            ? MatchSummary(
                modes: const {MatchMode.friend: 'm2', MatchMode.dating: 'm1'},
                matchedAt: DateTime(2026, 10, 26),
                username: 'elif',
                card: _elif,
              )
            : MatchSummary(modes: const {MatchMode.dating: 'm1'}, matchedAt: DateTime(2026, 10, 26)),
      ]);

  @override
  Future<Result<void>> endMatch(String matchId) async {
    ended.add(matchId);
    return const Ok(null);
  }

  @override
  Future<Result<void>> saveProfile(MatchProfileDraft draft, {required bool create}) async {
    saved.add(draft);
    return const Ok(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pump(WidgetTester tester, _FakeMatching repo, Widget home) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.5;
  addTearDown(tester.view.reset);
  final router = GoRouter(routes: [
    GoRoute(path: '/', builder: (_, _) => home),
    GoRoute(path: MatchingRoutes.setup, builder: (_, _) => const Text('setup')),
    GoRoute(path: MatchingRoutes.profile, builder: (_, _) => const Text('profile')),
    GoRoute(path: MatchingRoutes.matches, builder: (_, _) => const Text('matches')),
    GoRoute(path: MatchingRoutes.packages, builder: (_, _) => const Text('packages')),
    GoRoute(path: '${MatchingRoutes.packages}/:slug', builder: (_, state) => Text('package ${state.pathParameters['slug']}')),
  ]);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      currentUserIdProvider.overrideWithValue('me'),
      matchingRepositoryProvider.overrideWithValue(repo),
      categoriesProvider.overrideWith((ref) async => const [Category(slug: 'music', name: 'Müzik'), Category(slug: 'hiking', name: 'Yürüyüş')]),
    ],
    child: MaterialApp.router(theme: GwTheme.light(), routerConfig: router),
  ));
  await tester.pumpAndSettle();
}

void main() {
  test('a draft explains what keeps it from saving', () {
    final today = DateTime(2026, 10, 26);
    MatchProfileDraft draft({DateTime? born, bool friend = true, bool dating = false, Set<MatchGender> into = const {}}) =>
        MatchProfileDraft(birthDate: born ?? DateTime(1990), gender: MatchGender.woman, province: 6, friend: friend, dating: dating, interestedIn: into);

    expect(draft(born: DateTime(2008, 10, 27)).problem(today), 'Eşleşme 18 yaşından büyükler içindir.');
    expect(draft(born: DateTime(2008, 10, 26)).problem(today), isNull);
    expect(draft(friend: false).problem(today), isNotNull);
    expect(draft(dating: true).problem(today), 'Sevgili modu için kimi aradığını seç.');
    expect(draft(dating: true, into: {MatchGender.man}).problem(today), isNull);
    expect(ageOn(DateTime(2000, 10, 27), today), 25);
  });

  test('the card names the shared groups', () {
    expect(_elif.sharedGroupsLine, 'Ortak: Akustik Geceler ve 1 grup daha');
    expect(_elif.provinceLabel, 'İstanbul');
  });

  testWidgets('without a profile the screen explains matching and starts the setup', (tester) async {
    await _pump(tester, _FakeMatching(), const MatchingScreen(openChat: _noChat));

    expect(find.text('Ortak gruplarından yeni insanlarla tanış'), findsOneWidget);
    await tester.tap(find.text('Eşleşme profilimi oluştur'));
    await tester.pumpAndSettle();
    expect(find.text('setup'), findsOneWidget);
  });

  testWidgets('a card shows the shared groups and a mutual like opens the match dialog', (tester) async {
    final repo = _FakeMatching(profile: _profile, matchOnLike: true);
    await _pump(tester, repo, const MatchingScreen(openChat: _noChat));

    expect(find.text('Elif  29', findRichText: true), findsOneWidget);
    expect(find.text('Ortak: Akustik Geceler ve 1 grup daha'), findsOneWidget);
    expect(find.text('Bugün 7 beğeni ve 1 süper beğeni hakkın var.'), findsOneWidget);
    expect(find.text('Sevgili'), findsOneWidget);

    await tester.tap(find.byTooltip('Beğen'));
    await tester.pumpAndSettle();
    expect(repo.swipes.single, ('u2', MatchMode.friend, SwipeKind.like));
    expect(find.text('Eşleştiniz!'), findsOneWidget);
  });

  testWidgets('dragging the card up super likes; rewind offers its package', (tester) async {
    final repo = _FakeMatching(profile: _profile);
    await _pump(tester, repo, const MatchingScreen(openChat: _noChat));

    await tester.dragFrom(tester.getCenter(find.byType(Scaffold)), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(repo.swipes.single, ('u2', MatchMode.friend, SwipeKind.superLike));

    await tester.tap(find.byTooltip('Geri al'));
    await tester.pumpAndSettle();
    expect(find.text('Sınırsız Beğeni'), findsOneWidget);
    await tester.tap(find.text('Sınırsız Beğeni paketini incele'));
    await tester.pumpAndSettle();
    expect(find.text('package matching_unlimited'), findsOneWidget);
  });

  testWidgets('without the package the likes screen shows only how many', (tester) async {
    await _pump(tester, _FakeMatching(profile: _profile), const MatchLikesScreen(openChat: _noChat));

    await tester.tap(find.text('Sevgili (2)'));
    await tester.pumpAndSettle();
    expect(find.text('2 kişi seni beğendi'), findsOneWidget);
    expect(find.text('Elif, 29'), findsNothing);
  });

  testWidgets('with the package a like back from the likes screen makes a match', (tester) async {
    final repo = _FakeMatching(profile: _profile, premium: true, matchOnLike: true);
    await _pump(tester, repo, const MatchLikesScreen(openChat: _noChat));

    await tester.tap(find.text('Elif, 29'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Beğen ve eşleş'));
    await tester.pumpAndSettle();
    expect(repo.swipes.single, ('u2', MatchMode.friend, SwipeKind.like));
    expect(find.text('Eşleştiniz!'), findsOneWidget);
  });

  testWidgets('Hepsi Bir Arada lists every package above the purchase', (tester) async {
    await _pump(
      tester,
      _FakeMatching(profile: _profile, premium: true),
      MatchPackageScreen(
        package: MatchPackage.all,
        purchase: (_, slug, String? order) => Text('satın al $slug ${order ?? '-'}'),
        orderId: 'o1',
      ),
    );

    expect(find.text('Eşleşme Sohbeti'), findsOneWidget);
    expect(find.textContaining('tarihine kadar açık'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('satın al matching_premium o1'), 200, scrollable: find.byType(Scrollable).first);
    expect(find.text('satın al matching_premium o1'), findsOneWidget);
  });

  testWidgets('without Eşleşmelerim a match is locked and offers the package', (tester) async {
    await _pump(tester, _FakeMatching(profile: _profile), const MatchesScreen(openChat: _noChat));

    expect(find.text('Biriyle eşleştin!'), findsOneWidget);
    expect(find.text('Elif, 29'), findsNothing);
    await tester.tap(find.text('Biriyle eşleştin!'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eşleşmelerim paketini incele'));
    await tester.pumpAndSettle();
    expect(find.text('package matching_reveal'), findsOneWidget);
  });

  testWidgets('opening a profile needs the age and consent confirmations', (tester) async {
    final repo = _FakeMatching();
    await _pump(tester, repo, const MatchProfileScreen());

    expect(find.text('Eşleşme profili oluştur'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Profilimi oluştur'), 200, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Profilimi oluştur'));
    await tester.pumpAndSettle();
    expect(find.text('Doğum tarihini, cinsiyetini ve ilini seç.'), findsOneWidget);
    expect(repo.saved, isEmpty);
  });

  testWidgets('who you look for can be picked and unpicked', (tester) async {
    await _pump(tester, _FakeMatching(), const MatchProfileScreen());

    final dating = find.widgetWithText(SwitchListTile, 'Sevgili');
    await tester.scrollUntilVisible(dating, 200, scrollable: find.byType(Scrollable).first);
    await tester.tap(dating);
    await tester.pumpAndSettle();

    FilterChip chip(String label) => tester.widget<FilterChip>(find.widgetWithText(FilterChip, label));
    await tester.scrollUntilVisible(find.widgetWithText(FilterChip, 'Kadın'), 200, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.widgetWithText(FilterChip, 'Kadın'));
    await tester.tap(find.widgetWithText(FilterChip, 'Erkek'));
    await tester.pumpAndSettle();
    expect(chip('Kadın').selected, isTrue);
    expect(chip('Erkek').selected, isTrue);
    expect(chip('İkili olmayan').selected, isFalse);

    await tester.tap(find.widgetWithText(FilterChip, 'Erkek'));
    await tester.pumpAndSettle();
    expect(chip('Erkek').selected, isFalse);
    expect(chip('Kadın').selected, isTrue);
  });

  testWidgets('a match can be ended after confirming', (tester) async {
    final repo = _FakeMatching(profile: _profile, premium: true);
    await _pump(tester, repo, const MatchesScreen(openChat: _noChat));

    expect(find.text('Elif, 29'), findsOneWidget);
    expect(find.text('Sevgili'), findsOneWidget);
    await tester.tap(find.byTooltip('Seçenekler'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eşleşmeyi bitir'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(GwButton, 'Bitir'));
    await tester.pumpAndSettle();
    expect(repo.ended, ['m2', 'm1']);
  });

  testWidgets('matched both ways shows once and the person picks which stays', (tester) async {
    final repo = _FakeMatching(profile: _profile, premium: true);
    await _pump(tester, repo, const MatchesScreen(openChat: _noChat));

    expect(find.text('Elif, 29'), findsOneWidget);
    expect(find.text('Arkadaş'), findsOneWidget);
    expect(find.text('Sevgili'), findsOneWidget);
    await tester.tap(find.byTooltip('Seçenekler'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yalnızca arkadaş kal'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(GwButton, 'Devam et'));
    await tester.pumpAndSettle();
    expect(repo.ended, ['m1']);
  });
}

void _noChat(BuildContext context, String conversationId) {}
