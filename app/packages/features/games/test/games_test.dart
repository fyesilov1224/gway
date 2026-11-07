import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games/games.dart';
import 'package:games/src/domain/countries.dart';
import 'package:games/src/presentation/chess_board.dart';
import 'package:games/src/presentation/providers.dart';
import 'package:go_router/go_router.dart';

Map<String, dynamic> _row({List<String> moves = const [], String status = 'active', String? result, String? termination}) => {
      'id': 'g1',
      'white_id': 'me',
      'black_id': 'them',
      'category': 'blitz',
      'base_seconds': 180,
      'increment_seconds': 2,
      'rated': true,
      'source': 'seek',
      'status': status,
      'result': result,
      'termination': termination,
      'moves': moves,
      'san': [for (final _ in moves) 'x'],
      'fen': 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
      'white_ms': 180000,
      'black_ms': 175000,
      // Realtime writes timestamps with a space and a short offset.
      'turn_started_at': '2026-11-05 18:00:00.000+00',
      'draw_offer': null,
      'white_rating': 1500,
      'black_rating': 1480,
      'white_delta': null,
      'black_delta': null,
      'created_at': '2026-11-05T17:59:00.000+00:00',
      'ended_at': null,
    };

class _FakeChess implements ChessRepository {
  _FakeChess(this.board);

  final List<LeaderboardEntry> board;

  @override
  Future<Result<List<LeaderboardEntry>>> leaderboard(ChessCategory category, {int offset = 0, int pageSize = 50}) async => Ok(board);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

LeaderboardEntry _entry(int rank, String name, int rating, {String? country, bool provisional = false, int? trend}) => LeaderboardEntry(
      rank: rank,
      provisional: provisional,
      trend: trend,
      player: ChessPlayer(userId: 'u$rank', username: name.toLowerCase(), displayName: name, country: country),
      rating: rating,
      games: 20,
      wins: 10,
      draws: 4,
      losses: 6,
    );

void main() {
  group('time controls', () {
    test('fall into bullet, blitz and rapid like the server', () {
      expect(const TimeControl(60, 0).category, ChessCategory.bullet);
      expect(const TimeControl(120, 1).category, ChessCategory.bullet);
      expect(const TimeControl(180, 2).category, ChessCategory.blitz);
      expect(const TimeControl(300, 3).category, ChessCategory.blitz);
      expect(const TimeControl(600, 0).category, ChessCategory.rapid);
      expect(const TimeControl(180, 2).label, '3+2');
    });

    test('the seek route keeps only catalog controls', () {
      expect(ChessRoutes.parseSeek('180-2'), const TimeControl(180, 2));
      expect(ChessRoutes.parseSeek('240-0'), TimeControl.standard);
      expect(ChessRoutes.parseSeek(null), TimeControl.standard);
      expect(ChessRoutes.seek(const TimeControl(900, 10)), '/games/chess/seek?tc=900-10');
    });
  });

  group('a game row', () {
    test('parses the Realtime shape and knows whose turn it is', () {
      final g = ChessGame.fromRow(_row(moves: ['e2e4']));
      expect(g.timeControl, const TimeControl(180, 2));
      expect(g.toMove, ChessColor.black);
      expect(g.colorOf('me'), ChessColor.white);
      expect(g.colorOf('someone'), isNull);
      expect(g.lastMove, ('e2', 'e4'));
      expect(g.turnStartedAt.toUtc(), DateTime.utc(2026, 11, 5, 18));
    });

    test('the clock does not run before both sides moved', () {
      final g = ChessGame.fromRow(_row(moves: ['e2e4']));
      expect(g.remainingMs(ChessColor.black, DateTime.utc(2026, 11, 5, 18, 0, 20)), 175000);
    });

    test('after two plies the side to move is charged from the turn start', () {
      final g = ChessGame.fromRow(_row(moves: ['e2e4', 'e7e5']));
      expect(g.remainingMs(ChessColor.white, DateTime.utc(2026, 11, 5, 18, 0, 30)), 150000);
      expect(g.remainingMs(ChessColor.black, DateTime.utc(2026, 11, 5, 18, 0, 30)), 175000);
      expect(g.remainingMs(ChessColor.white, DateTime.utc(2026, 11, 5, 18, 10)), 0);
    });

    test('scores the result for each side', () {
      final won = ChessGame.fromRow(_row(status: 'finished', result: 'white', termination: 'checkmate'));
      expect(won.scoreFor(ChessColor.white), 1);
      expect(won.scoreFor(ChessColor.black), 0);
      expect(won.termination, Termination.checkmate);
      final drawn = ChessGame.fromRow(_row(status: 'finished', result: 'draw', termination: 'repetition'));
      expect(drawn.scoreFor(ChessColor.black), 0.5);
      final aborted = ChessGame.fromRow(_row(status: 'aborted', termination: 'aborted'));
      expect(aborted.scoreFor(ChessColor.white), isNull);
    });
  });

  test('every language names every country', () {
    for (final names in countryNames.values) {
      expect(names.length, countryCodes.length);
    }
    expect(countryCodes, contains('TR'));
  });

  testWidgets('tapping a piece and a target proposes the move; the board turns for black', (tester) async {
    late PieceSet pieces;
    await tester.runAsync(() async => pieces = await loadPieceSet(rootBundle, 'classic'));
    final moves = <String>[];

    Future<void> pump(ChessColor side) => tester.pumpWidget(MaterialApp(
          theme: GwTheme.light(),
          home: Center(
            child: SizedBox(
              width: 400,
              child: ChessBoard(
                fen: 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
                pieces: pieces,
                orientation: side,
                movable: ChessColor.white,
                onMove: moves.add,
              ),
            ),
          ),
        ));

    await pump(ChessColor.white);
    final board = tester.getTopLeft(find.byType(ChessBoard));
    Offset square(int file, int rank) => board + Offset(file * 50 + 25, (7 - rank) * 50 + 25);
    await tester.tapAt(square(4, 1));
    await tester.pump();
    await tester.tapAt(square(4, 3));
    await tester.pump();
    expect(moves, ['e2e4']);

    // An illegal target only clears the selection.
    await tester.tapAt(square(4, 1));
    await tester.pump();
    await tester.tapAt(square(4, 4));
    await tester.pump();
    expect(moves, ['e2e4']);

    // From black's side the same square is mirrored.
    await pump(ChessColor.black);
    Offset flipped(int file, int rank) => board + Offset((7 - file) * 50 + 25, rank * 50 + 25);
    await tester.tapAt(flipped(6, 0));
    await tester.pump();
    await tester.tapAt(flipped(5, 2));
    await tester.pump();
    expect(moves, ['e2e4', 'g1f3']);
  });

  testWidgets('the leaderboard puts the top three on a podium with medals', (tester) async {
    final semantics = tester.ensureSemantics();
    // Tall enough for the whole board, the provisional list included.
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repo = _FakeChess([
      _entry(1, 'Deniz', 2105, country: 'TR'),
      _entry(2, 'Lena', 2010, country: 'DE'),
      _entry(3, 'Hugo', 1990, country: 'FR'),
      _entry(4, 'Ayşe', 1800, trend: 24),
      _entry(0, 'Yeni', 1650, provisional: true),
    ]);
    final router = GoRouter(routes: [GoRoute(path: '/', builder: (_, _) => const ChessLeaderboardScreen())]);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        currentUserIdProvider.overrideWithValue('u4'),
        chessRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp.router(theme: GwTheme.light(), routerConfig: router),
    ));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel(RegExp(gamesL10n.medalGold)), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(gamesL10n.medalSilver)), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(gamesL10n.medalBronze)), findsOneWidget);
    expect(find.text('2105'), findsOneWidget);
    expect(find.text('Ayşe'), findsOneWidget);
    // A table row: record and score percentage, the month's change, the rating.
    expect(find.text('${gamesL10n.record(10, 4, 6)} · ${gamesL10n.winRate(60)}'), findsNWidgets(2));
    expect(find.text('+24'), findsNWidgets(2));
    // The reader (u4) sees their own place on top.
    expect(find.text(gamesL10n.yourPlace), findsOneWidget);
    expect(find.text('#4'), findsOneWidget);
    // A provisional rating is listed apart, with "?" and without a place.
    expect(find.text(gamesL10n.provisionalPlayers), findsOneWidget);
    expect(find.text('1650?'), findsOneWidget);
    semantics.dispose();
  });
}
