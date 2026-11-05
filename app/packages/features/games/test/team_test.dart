import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games/games.dart';
import 'package:games/src/domain/team.dart';
import 'package:games/src/presentation/providers.dart';
import 'package:games/src/presentation/team_screens.dart';
import 'package:go_router/go_router.dart';

const _a = ChessGroup(id: 'ga', handle: 'kale.kulubu', name: 'Kale Kulübü');
const _b = ChessGroup(id: 'gb', handle: 'fil.takimi', name: 'Fil Takımı');

ChessPlayer _p(String id, String name) => ChessPlayer(userId: id, username: id, displayName: name, country: 'TR');

class _FakeTeams implements TeamMatchRepository {
  _FakeTeams(this.detailValue);

  final TeamMatchDetail detailValue;
  final responses = <bool>[];

  @override
  Future<Result<TeamMatchDetail>> detail(String id) async => Ok(detailValue);

  @override
  Stream<void> changes(String id) => const Stream.empty();

  @override
  Future<Result<void>> respond(String id, {required bool accept}) async {
    responses.add(accept);
    return const Ok(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pump(WidgetTester tester, Widget screen, TeamMatchRepository repo) async {
  // A phone-shaped screen tall enough for the boards.
  tester.view.physicalSize = const Size(1200, 3000);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final router = GoRouter(routes: [GoRoute(path: '/', builder: (_, _) => screen)]);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      currentUserIdProvider.overrideWithValue('me'),
      teamRepositoryProvider.overrideWithValue(repo),
    ],
    child: MaterialApp.router(theme: GwTheme.light(), routerConfig: router),
  ));
  await tester.pumpAndSettle();
}

void main() {
  test('points print with halves', () {
    expect(formatPoints(0), '0');
    expect(formatPoints(0.5), '½');
    expect(formatPoints(2.5), '2½');
    expect(formatPoints(3), '3');
  });

  testWidgets('the invited captain answers; boards show who sits where', (tester) async {
    final repo = _FakeTeams(TeamMatchDetail(
      match: TeamMatch(
        id: 'm1',
        home: _a,
        away: _b,
        boards: 2,
        timeControl: const TimeControl(300, 3),
        startsAt: DateTime.now().add(const Duration(days: 1)),
        status: TeamMatchStatus.invited,
      ),
      boards: [TeamBoard(board: 1, home: _p('u1', 'Deniz')), const TeamBoard(board: 2)],
      captainOf: const {'gb'},
      homeRating: 1232,
      awayRating: 1200,
    ));
    await _pump(tester, const TeamMatchScreen(matchId: 'm1'), repo);

    expect(find.text('Kale Kulübü'), findsOneWidget);
    expect(find.text(gamesL10n.groupElo(1232)), findsOneWidget);
    expect(find.text('Deniz'), findsOneWidget);
    expect(find.text(gamesL10n.emptyBoard), findsNWidgets(3));
    expect(find.text(gamesL10n.editLineup('Fil Takımı')), findsOneWidget);
    expect(find.text(gamesL10n.editLineup('Kale Kulübü')), findsNothing);

    await tester.tap(find.text(gamesL10n.accept));
    await tester.pumpAndSettle();
    expect(repo.responses, [true]);
  });

  testWidgets('a finished match shows the score and both groups\' Elo change', (tester) async {
    final repo = _FakeTeams(TeamMatchDetail(
      match: TeamMatch(
        id: 'm2',
        home: _a,
        away: _b,
        boards: 2,
        timeControl: const TimeControl(600, 0),
        startsAt: DateTime.now().subtract(const Duration(hours: 1)),
        status: TeamMatchStatus.finished,
        homePoints: 1.5,
        awayPoints: 0.5,
        homeDelta: 11,
        awayDelta: -11,
      ),
      boards: [
        TeamBoard(board: 1, home: _p('u1', 'Deniz'), away: _p('u2', 'Lena'), gameId: 'g1', homePoints: 1, awayPoints: 0),
        TeamBoard(board: 2, home: _p('u3', 'Ece'), away: _p('u4', 'Hugo'), gameId: 'g2', homePoints: 0.5, awayPoints: 0.5),
      ],
      captainOf: const {},
      homeRating: 1211,
      awayRating: 1189,
    ));
    await _pump(tester, const TeamMatchScreen(matchId: 'm2'), repo);

    expect(find.text('1½ – ½'), findsOneWidget);
    expect(find.text('+11'), findsOneWidget);
    expect(find.text('−11'), findsOneWidget);
    expect(find.text('½ – ½'), findsOneWidget);
    expect(find.text(gamesL10n.accept), findsNothing);
  });

  testWidgets('a group duel shows seats and the question count, without board colors', (tester) async {
    final repo = _FakeTeams(TeamMatchDetail(
      match: TeamMatch(
        id: 'm2',
        home: _a,
        away: _b,
        boards: 2,
        game: TeamGame.mind,
        length: 20,
        startsAt: DateTime.now().subtract(const Duration(minutes: 3)),
        status: TeamMatchStatus.live,
      ),
      boards: [
        TeamBoard(board: 1, home: _p('me', 'Deniz'), away: _p('u2', 'Lena'), mindMatchId: 'd1'),
        TeamBoard(board: 2, home: _p('u3', 'Hugo'), homePoints: 1, awayPoints: 0),
      ],
      captainOf: const {},
      homeRating: 1216,
      awayRating: 1184,
    ));
    await _pump(tester, const TeamMatchScreen(matchId: 'm2'), repo);

    expect(find.text(gamesL10n.mindTeamMatch), findsOneWidget);
    expect(find.text(gamesL10n.mindQuestions(20)), findsOneWidget);
    expect(find.text(gamesL10n.mindSeatsCount(2)), findsOneWidget);
    expect(find.text(gamesL10n.mindSeats), findsOneWidget);
    // The reader's own seat leads to the duel.
    expect(find.byIcon(Icons.play_circle_fill_rounded), findsOneWidget);
    // The match score and seat 2 both read 1–0.
    expect(find.text('1 – 0'), findsNWidgets(2));
  });
}
