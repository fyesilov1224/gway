import 'package:core/core.dart';

import '../l10n.dart';
import 'chess.dart';
import 'mind.dart';
import 'team.dart';

enum ArenaKind { weekly, monthly, custom }

enum ArenaStatus { scheduled, live, finished, canceled }

/// An arena tournament (docs/ARCHITECTURE.md §3i, Arena turnuvaları).
class Arena {
  const Arena({
    required this.id,
    required this.kind,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    this.title,
    this.game = TeamGame.chess,
    this.timeControl,
    this.questions,
  });

  final String id;
  final ArenaKind kind;

  /// Only custom arenas have one; weekly and monthly ones are named in the reader's language.
  final String? title;
  final TeamGame game;

  /// Chess: the time control; a duel arena: the question count ([questions]).
  final TimeControl? timeControl;
  final int? questions;
  final DateTime startsAt;
  final DateTime endsAt;
  final ArenaStatus status;

  String get name => switch (kind) {
        ArenaKind.weekly => gamesL10n.weeklyArena,
        ArenaKind.monthly => gamesL10n.monthlyArena,
        ArenaKind.custom => title ?? gamesL10n.arena,
      };

  Duration get length => endsAt.difference(startsAt);

  /// "3+2" or "10 soru": what the card's header shows.
  String get formatShort => timeControl?.label ?? gamesL10n.mindQuestions(questions ?? mindDefaultLength);

  /// "3+2 · Blitz" or "10 soru".
  String get format => timeControl == null ? formatShort : '${timeControl!.label} · ${timeControl!.category.label}';
}

/// A player's line in an arena's standings.
class ArenaStanding {
  const ArenaStanding({
    required this.rank,
    required this.player,
    required this.points,
    required this.games,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.streak,
    required this.waiting,
    required this.playing,
    this.performance,
    this.finalRank,
  });

  final int rank;
  final ChessPlayer player;
  final int points;
  final int games;
  final int wins;
  final int draws;
  final int losses;

  /// Wins in a row; from two on, the next result scores double.
  final int streak;
  final int? performance;
  final bool waiting;
  final bool playing;
  final int? finalRank;

  bool get onFire => streak >= 2;
}

class ArenaDetail {
  const ArenaDetail({required this.arena, required this.standings, this.myGameId, this.myMatchId, this.joined = false});

  final Arena arena;
  final List<ArenaStanding> standings;

  /// The reader joined (or registered for) this arena.
  final bool joined;

  /// The reader's running arena game (chess) or duel.
  final String? myGameId;
  final String? myMatchId;

  ArenaStanding? standingOf(String? userId) => standings.where((s) => s.player.userId == userId).firstOrNull;
}

/// A finished arena with its podium.
typedef ArenaResult = ({Arena arena, List<ChessPlayer> podium});

typedef ArenaLists = ({List<Arena> live, List<Arena> upcoming, List<ArenaResult> finished, Set<String> joined});

class ChessMedals {
  const ChessMedals({this.gold = 0, this.silver = 0, this.bronze = 0});

  final int gold;
  final int silver;
  final int bronze;

  int get total => gold + silver + bronze;
}

abstract interface class ArenaRepository {
  Future<Result<ArenaLists>> arenas(TeamGame game);

  Future<Result<ArenaDetail>> detail(String id);

  /// The arena or its standings changed.
  Stream<void> changes(String id);

  Future<Result<void>> join(String id);

  Future<Result<void>> pause(String id);

  Future<Result<void>> leave(String id);

  Future<Result<ChessMedals>> medals(String userId, TeamGame game);
}
