import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games/games.dart';
import 'package:games/src/domain/arena.dart';
import 'package:games/src/presentation/providers.dart';
import 'package:go_router/go_router.dart';

ChessPlayer _p(String id, String name) => ChessPlayer(userId: id, username: id, displayName: name, country: 'TR');

ArenaStanding _s(int rank, String id, String name, int points, {int streak = 0, bool waiting = false}) => ArenaStanding(
      rank: rank,
      player: _p(id, name),
      points: points,
      games: 3,
      wins: 2,
      draws: 0,
      losses: 1,
      streak: streak,
      waiting: waiting,
      playing: false,
      performance: 1500,
    );

class _FakeArenas implements ArenaRepository {
  _FakeArenas(this.value);

  ArenaDetail value;
  final joins = <String>[];

  @override
  Future<Result<ArenaDetail>> detail(String id) async => Ok(value);

  @override
  Stream<void> changes(String id) => const Stream.empty();

  @override
  Future<Result<void>> join(String id) async {
    joins.add(id);
    return const Ok(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Arena _arena(ArenaStatus status, {ArenaKind kind = ArenaKind.weekly}) => Arena(
      id: 'a1',
      kind: kind,
      timeControl: const TimeControl(180, 2),
      startsAt: DateTime.now().subtract(const Duration(minutes: 10)),
      endsAt: DateTime.now().add(const Duration(minutes: 50)),
      status: status,
    );

Future<void> _pump(WidgetTester tester, ArenaRepository repo) async {
  tester.view.physicalSize = const Size(1200, 3000);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final router = GoRouter(routes: [
    GoRoute(path: '/', builder: (_, _) => const ArenaScreen(arenaId: 'a1')),
    GoRoute(path: '/games/chess/g/:id', builder: (_, state) => Text('game ${state.pathParameters['id']}')),
  ]);
  await tester.pumpWidget(ProviderScope(
    overrides: [currentUserIdProvider.overrideWithValue('me'), arenaRepositoryProvider.overrideWithValue(repo)],
    child: MaterialApp.router(theme: GwTheme.light(), routerConfig: router),
  ));
  await tester.pump(const Duration(milliseconds: 200));
  await tester.pump(const Duration(milliseconds: 200));
}

void main() {
  testWidgets('a live arena someone has not joined offers Katıl and shows the standings with streaks', (tester) async {
    final repo = _FakeArenas(ArenaDetail(
      arena: _arena(ArenaStatus.live),
      standings: [_s(1, 'u1', 'Deniz', 8, streak: 3), _s(2, 'u2', 'Lena', 4)],
    ));
    await _pump(tester, repo);

    expect(find.text(gamesL10n.weeklyArena), findsWidgets);
    expect(find.text('Deniz'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.byIcon(Icons.local_fire_department_rounded), findsOneWidget);
    await tester.tap(find.text(gamesL10n.arenaJoin));
    await tester.pump();
    expect(repo.joins, ['a1']);
  });

  testWidgets('a waiting player sees the waiting notice and can take a break', (tester) async {
    final repo = _FakeArenas(ArenaDetail(
      arena: _arena(ArenaStatus.live),
      joined: true,
      standings: [_s(1, 'me', 'Ben', 2, waiting: true)],
    ));
    await _pump(tester, repo);
    expect(find.text(gamesL10n.arenaWaiting), findsOneWidget);
    expect(find.text(gamesL10n.arenaPause), findsOneWidget);
  });

  testWidgets('before the start a custom arena shows its title and Kayıt ol', (tester) async {
    final upcoming = Arena(
      id: 'a1',
      kind: ArenaKind.custom,
      title: 'Cuma Blitz',
      timeControl: const TimeControl(300, 0),
      startsAt: DateTime.now().add(const Duration(hours: 2)),
      endsAt: DateTime.now().add(const Duration(hours: 3)),
      status: ArenaStatus.scheduled,
    );
    await _pump(tester, _FakeArenas(ArenaDetail(arena: upcoming, standings: const [])));
    expect(find.text('Cuma Blitz'), findsOneWidget);
    expect(find.text(gamesL10n.arenaRegister), findsOneWidget);
    expect(find.text(gamesL10n.arenaEmpty), findsOneWidget);
  });
}
