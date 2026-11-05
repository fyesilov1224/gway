import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games/games.dart';
import 'package:games/src/domain/mind.dart';
import 'package:games/src/presentation/mind_figure.dart';
import 'package:games/src/presentation/mind_providers.dart';
import 'package:games/src/presentation/providers.dart';
import 'package:go_router/go_router.dart';

Map<String, dynamic> _row({List<int> a = const [], List<int> b = const [], String status = 'active', String? result}) => {
      'id': 'm1',
      'a_id': 'me',
      'b_id': 'them',
      'length': 5,
      'rated': true,
      'source': 'seek',
      'status': status,
      'result': result,
      'termination': status == 'finished' ? 'completed' : null,
      'a_points': a,
      'b_points': b,
      'a_score': a.fold(0, (s, p) => s + p),
      'b_score': b.fold(0, (s, p) => s + p),
      'a_joined': true,
      'b_joined': true,
      'a_rating': 1300,
      'b_rating': 1250,
      'a_delta': status == 'finished' ? 18 : null,
      'b_delta': status == 'finished' ? -18 : null,
      // Realtime writes timestamps with a space and a short offset.
      'starts_at': '2026-11-05 18:00:00.000+00',
      'deadline_at': '2099-11-05 18:10:00.000+00',
      'created_at': '2026-11-05T17:59:55.000+00:00',
      'ended_at': null,
    };

final _question = MindQuestion(
  index: 0,
  kind: MindKind.math,
  level: 1,
  payload: const {'expression': '49 + 9 × 2', 'choices': [116, 67, 65, 70]},
  limitMs: 11000,
  servedAt: DateTime.now().toUtc(),
);

class _FakeMind implements MindRepository {
  _FakeMind({this.board = const []});

  final List<LeaderboardEntry> board;
  final answers = <Map<String, Object?>>[];

  @override
  Future<Result<MindView>> match(String id) async => Ok((match: MindMatch.fromRow(_row()), serverNow: DateTime.now().toUtc()));

  @override
  Stream<MindMatch> matchUpdates(String id) => const Stream.empty();

  @override
  Future<Result<MindNext>> next(String id) async => Ok((
        match: MindMatch.fromRow(_row(a: [for (final _ in answers) 160])),
        serverNow: DateTime.now().toUtc(),
        question: answers.isEmpty ? _question : null,
      ));

  @override
  Future<Result<MindAnswered>> answer(String id, int index, Map<String, Object?> answer, int elapsedMs) async {
    answers.add(answer);
    return Ok(MindAnswered(
      points: 160,
      correct: true,
      solution: const {'choice': 1},
      match: MindMatch.fromRow(_row(a: [160])),
      serverNow: DateTime.now().toUtc(),
    ));
  }

  @override
  Future<Result<List<LeaderboardEntry>>> leaderboard(int length, {int offset = 0, int pageSize = 50}) async => Ok(board);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoProfiles implements ChessRepository {
  @override
  Future<Result<ChessProfile>> profile(String userId) async => const Err(NotFoundFailure());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

LeaderboardEntry _entry(int rank, String name, int rating) => LeaderboardEntry(
      rank: rank,
      player: ChessPlayer(userId: 'u$rank', username: name.toLowerCase(), displayName: name, country: 'TR'),
      rating: rating,
      games: 12,
      wins: 8,
      draws: 1,
      losses: 3,
    );

void main() {
  tearDown(() => setCurrentAppLanguage(AppLanguage.tr));

  test('a match row reads the same from Realtime and the API', () {
    final m = MindMatch.fromRow(_row(a: [160, 0, -50], b: [120], status: 'finished', result: 'a'));
    expect(m.sideOf('me'), MindSide.a);
    expect(m.sideOf('them'), MindSide.b);
    expect(m.sideOf('someone'), isNull);
    expect(m.scoreOf(MindSide.a), 110);
    expect(m.answeredBy(MindSide.a), 3);
    expect(m.scoreFor(MindSide.a), 1);
    expect(m.scoreFor(MindSide.b), 0);
    expect(m.deltaOf(MindSide.b), -18);
    expect(m.startsAt.isUtc, isTrue);
  });

  test('the length in a link falls back to ten questions', () {
    expect(MindRoutes.parseLength('50'), 50);
    expect(MindRoutes.parseLength('7'), mindDefaultLength);
    expect(MindRoutes.parseLength(null), mindDefaultLength);
    expect(MindRoutes.seek(20), '/games/mind/seek?n=20');
  });

  test('figure words agree with the shape in every language', () {
    const redStripedCircle = MindFigure(color: 'red', pattern: MindPattern.striped, shape: MindShape.circle);
    const redStripedStar = MindFigure(color: 'red', pattern: MindPattern.striped, shape: MindShape.star);
    const blueDottedSquare = MindFigure(color: 'blue', pattern: MindPattern.dotted, shape: MindShape.square);
    expect(describeFigure(redStripedCircle), 'kırmızı çizgili yuvarlak');
    setCurrentAppLanguage(AppLanguage.en);
    expect(describeFigure(blueDottedSquare), 'blue dotted square');
    setCurrentAppLanguage(AppLanguage.de);
    expect(describeFigure(blueDottedSquare), 'blaues gepunktetes Quadrat');
    expect(describeFigure(redStripedCircle), 'roter gestreifter Kreis');
    setCurrentAppLanguage(AppLanguage.fr);
    expect(describeFigure(redStripedStar), 'étoile rouge rayée');
    setCurrentAppLanguage(AppLanguage.ru);
    expect(describeFigure(redStripedStar), 'красная полосатая звезда');
    setCurrentAppLanguage(AppLanguage.uk);
    expect(describeFigure(redStripedCircle), 'червоне смугасте коло');
    setCurrentAppLanguage(AppLanguage.ar);
    expect(describeFigure(redStripedStar), 'نجمة حمراء مخططة');
  });

  testWidgets('a duel shows the question, sends the tapped choice and marks it right', (tester) async {
    final mind = _FakeMind();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        currentUserIdProvider.overrideWithValue('me'),
        mindRepositoryProvider.overrideWithValue(mind),
        chessRepositoryProvider.overrideWithValue(_NoProfiles()),
      ],
      child: MaterialApp(theme: GwTheme.light(), home: const MindMatchScreen(matchId: 'm1')),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('49 + 9 × 2 = ?'), findsOneWidget);
    expect(find.text(gamesL10n.mindQuestionOf(1, 5)), findsOneWidget);
    await tester.tap(find.text('67'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(mind.answers, [
      {'choice': 1},
    ]);
    expect(find.text(gamesL10n.mindRight(160)), findsOneWidget);
    expect(find.text('160'), findsOneWidget);

    // After the moment of feedback the next question is asked for; none left here, so the duel waits.
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('49 + 9 × 2 = ?'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 11));
  });

  testWidgets('each length has its leaderboard with medals and crowns on the podium', (tester) async {
    final semantics = tester.ensureSemantics();
    final mind = _FakeMind(board: [_entry(1, 'Deniz', 1610), _entry(2, 'Lena', 1540), _entry(3, 'Hugo', 1490), _entry(4, 'Ayşe', 1300)]);
    final router = GoRouter(routes: [GoRoute(path: '/', builder: (_, _) => const MindLeaderboardScreen(initial: 20))]);
    await tester.pumpWidget(ProviderScope(
      overrides: [currentUserIdProvider.overrideWithValue('u4'), mindRepositoryProvider.overrideWithValue(mind)],
      child: MaterialApp.router(theme: GwTheme.light(), routerConfig: router),
    ));
    await tester.pumpAndSettle();

    for (final n in mindLengths) {
      expect(find.text(gamesL10n.mindQuestions(n)), findsOneWidget);
    }
    expect(find.bySemanticsLabel(RegExp(gamesL10n.medalGold)), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(gamesL10n.medalBronze)), findsOneWidget);
    expect(find.byType(GwCrown), findsNWidgets(3));
    expect(find.text('1610'), findsOneWidget);
    expect(find.text('Ayşe'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('figures are drawn for every shape and pattern', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: GwTheme.light(),
      home: Scaffold(
        body: Wrap(children: [
          for (final s in MindShape.values)
            for (final p in MindPattern.values) MindFigureView(figure: MindFigure(color: 'green', pattern: p, shape: s)),
        ]),
      ),
    ));
    expect(find.byType(MindFigureView), findsNWidgets(12));
    expect(tester.takeException(), isNull);
  });
}
