import 'package:core/core.dart';

import '../l10n.dart';
import 'chess.dart';

/// A group as chess shows it: name, handle and logo (rounded square).
class ChessGroup {
  const ChessGroup({required this.id, required this.handle, required this.name, this.logoUrl});

  final String id;
  final String handle;
  final String name;
  final String? logoUrl;
}

enum TeamMatchStatus {
  invited,
  accepted,
  declined,
  canceled,
  live,
  finished;

  static TeamMatchStatus parse(Object? code) => values.firstWhere((s) => s.name == code, orElse: () => canceled);

  String get label => switch (this) {
        invited => gamesL10n.teamInvited,
        accepted => gamesL10n.teamAccepted,
        declined => gamesL10n.teamDeclined,
        canceled => gamesL10n.teamCanceled,
        live => gamesL10n.teamLive,
        finished => gamesL10n.teamFinished,
      };

  bool get isOpen => this == invited || this == accepted;
}

/// Team matches use these time controls (no bullet).
const teamTimeControls = [
  TimeControl(180, 0), TimeControl(180, 2), TimeControl(300, 0), TimeControl(300, 3),
  TimeControl(600, 0), TimeControl(600, 5), TimeControl(900, 10),
];

class TeamMatch {
  const TeamMatch({
    required this.id,
    required this.home,
    required this.away,
    required this.boards,
    required this.timeControl,
    required this.startsAt,
    required this.status,
    this.homePoints,
    this.awayPoints,
    this.homeDelta,
    this.awayDelta,
  });

  final String id;

  /// The inviting group.
  final ChessGroup home;
  final ChessGroup away;
  final int boards;
  final TimeControl timeControl;
  final DateTime startsAt;
  final TeamMatchStatus status;
  final double? homePoints;
  final double? awayPoints;
  final int? homeDelta;
  final int? awayDelta;

  bool involves(String groupId) => home.id == groupId || away.id == groupId;
}

/// One board: who sits there for each side and, once started, its game and points.
class TeamBoard {
  const TeamBoard({required this.board, this.home, this.away, this.gameId, this.homePoints, this.awayPoints});

  final int board;
  final ChessPlayer? home;
  final ChessPlayer? away;
  final String? gameId;
  final double? homePoints;
  final double? awayPoints;

  /// The home side has white on odd boards.
  bool get homeIsWhite => board.isOdd;
}

/// A team match page: the match, its boards (from the lineups before the start) and which sides the reader captains.
class TeamMatchDetail {
  const TeamMatchDetail({required this.match, required this.boards, required this.captainOf, required this.homeRating, required this.awayRating});

  final TeamMatch match;
  final List<TeamBoard> boards;
  final Set<String> captainOf;

  /// The groups' Elo now (1200 before their first match).
  final int homeRating;
  final int awayRating;
}

class TeamCandidate {
  const TeamCandidate({required this.player, required this.rating, required this.games});

  final ChessPlayer player;
  final int rating;
  final int games;
}

class GroupLeaderboardEntry {
  const GroupLeaderboardEntry({
    required this.rank,
    required this.group,
    required this.memberCount,
    required this.rating,
    required this.matches,
    required this.wins,
    required this.draws,
    required this.losses,
  });

  final int rank;
  final ChessGroup group;
  final int memberCount;
  final int rating;
  final int matches;
  final int wins;
  final int draws;
  final int losses;
}

abstract interface class TeamMatchRepository {
  Future<Result<List<GroupLeaderboardEntry>>> groupLeaderboard();

  /// Groups the reader may arrange team matches for.
  Future<Result<List<ChessGroup>>> captainGroups();

  Future<Result<List<ChessGroup>>> searchGroups(String query);

  /// Recent and upcoming matches of the reader's groups, newest start first.
  Future<Result<List<TeamMatch>>> myMatches();

  Future<Result<TeamMatchDetail>> detail(String id);

  /// The match or one of its boards changed.
  Stream<void> changes(String id);

  Future<Result<List<TeamCandidate>>> candidates(String matchId, String groupId);

  Future<Result<String>> create({
    required String homeGroupId,
    required String awayGroupId,
    required int boards,
    required TimeControl timeControl,
    required DateTime startsAt,
  });

  Future<Result<void>> respond(String id, {required bool accept});

  Future<Result<void>> cancel(String id);

  /// Board 1 first; null leaves a board empty.
  Future<Result<void>> setLineup(String id, String groupId, List<String?> players);
}
