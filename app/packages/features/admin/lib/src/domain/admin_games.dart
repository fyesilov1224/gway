import 'package:core/core.dart';

/// A running chess game in the admin panel.
class AdminChessGame {
  const AdminChessGame({
    required this.id,
    required this.whiteId,
    required this.white,
    required this.blackId,
    required this.black,
    required this.category,
    required this.baseSeconds,
    required this.incrementSeconds,
    required this.rated,
    required this.plies,
    required this.createdAt,
  });

  factory AdminChessGame.fromJson(Map<String, Object?> j) => AdminChessGame(
        id: j['id']! as String,
        whiteId: j['whiteId'] as String?,
        white: j['white'] as String?,
        blackId: j['blackId'] as String?,
        black: j['black'] as String?,
        category: j['category']! as String,
        baseSeconds: j['baseSeconds']! as int,
        incrementSeconds: j['incrementSeconds']! as int,
        rated: j['rated']! as bool,
        plies: j['plies']! as int,
        createdAt: DateTime.parse(j['createdAt']! as String),
      );

  final String id;
  final String? whiteId;
  final String? white;
  final String? blackId;
  final String? black;
  final String category;
  final int baseSeconds;
  final int incrementSeconds;
  final bool rated;
  final int plies;
  final DateTime createdAt;

  String get timeControl => '${baseSeconds ~/ 60}+$incrementSeconds';
}

class AdminChessSuspension {
  const AdminChessSuspension({required this.userId, required this.username, this.until, this.reason});

  factory AdminChessSuspension.fromJson(Map<String, Object?> j) => AdminChessSuspension(
        userId: j['userId']! as String,
        username: j['username']! as String,
        until: j['until'] is String ? DateTime.parse(j['until']! as String) : null,
        reason: j['reason'] as String?,
      );

  final String userId;
  final String username;

  /// Null: for good.
  final DateTime? until;
  final String? reason;
}

/// Chess at a glance (docs/ARCHITECTURE.md §3i, Yönetim paneli).
class AdminChessOverview {
  const AdminChessOverview({
    required this.gamesToday,
    required this.gamesTotal,
    required this.activeGames,
    required this.waitingSeeks,
    required this.pendingChallenges,
    required this.ratedPlayers,
    required this.active,
    required this.suspended,
  });

  factory AdminChessOverview.fromJson(Map<String, Object?> j) => AdminChessOverview(
        gamesToday: j['gamesToday']! as int,
        gamesTotal: j['gamesTotal']! as int,
        activeGames: j['activeGames']! as int,
        waitingSeeks: j['waitingSeeks']! as int,
        pendingChallenges: j['pendingChallenges']! as int,
        ratedPlayers: j['ratedPlayers']! as int,
        active: [for (final g in (j['active']! as List).cast<Map<String, Object?>>()) AdminChessGame.fromJson(g)],
        suspended: [for (final s in (j['suspended']! as List).cast<Map<String, Object?>>()) AdminChessSuspension.fromJson(s)],
      );

  final int gamesToday;
  final int gamesTotal;
  final int activeGames;
  final int waitingSeeks;
  final int pendingChallenges;
  final int ratedPlayers;
  final List<AdminChessGame> active;
  final List<AdminChessSuspension> suspended;
}

/// An open team match between two groups.
class AdminTeamMatch {
  const AdminTeamMatch({
    required this.id,
    required this.home,
    required this.away,
    required this.boards,
    required this.baseSeconds,
    required this.incrementSeconds,
    required this.status,
    required this.startsAt,
    this.game = 'chess',
    this.length,
  });

  factory AdminTeamMatch.fromJson(Map<String, Object?> j) => AdminTeamMatch(
        id: j['id']! as String,
        home: j['home']! as String,
        away: j['away']! as String,
        boards: j['boards']! as int,
        baseSeconds: j['baseSeconds'] as int?,
        incrementSeconds: j['incrementSeconds'] as int?,
        status: j['status']! as String,
        startsAt: DateTime.parse(j['startsAt']! as String),
        game: j['game'] as String? ?? 'chess',
        length: j['length'] as int?,
      );

  final String id;
  final String home;
  final String away;
  final int boards;

  /// Chess only; a duel match has [length] instead.
  final int? baseSeconds;
  final int? incrementSeconds;

  /// `chess` or `mind` (Zihin Düellosu).
  final String game;
  final int? length;

  /// invited, accepted or live.
  final String status;
  final DateTime startsAt;
}

/// An arena: weekly and monthly ones are scheduled by the database, custom ones opened from the panel.
class AdminTournament {
  const AdminTournament({
    required this.id,
    required this.kind,
    required this.title,
    required this.baseSeconds,
    required this.incrementSeconds,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    required this.players,
    this.game = 'chess',
    this.length,
  });

  factory AdminTournament.fromJson(Map<String, Object?> j) => AdminTournament(
        id: j['id']! as String,
        kind: j['kind']! as String,
        title: j['title'] as String?,
        baseSeconds: j['baseSeconds'] as int?,
        incrementSeconds: j['incrementSeconds'] as int?,
        startsAt: DateTime.parse(j['startsAt']! as String),
        endsAt: DateTime.parse(j['endsAt']! as String),
        status: j['status']! as String,
        players: j['players']! as int,
        game: j['game'] as String? ?? 'chess',
        length: j['length'] as int?,
      );

  final String id;
  final String kind;
  final String? title;

  /// Chess only; a duel arena has [length] (questions) instead.
  final int? baseSeconds;
  final int? incrementSeconds;
  final DateTime startsAt;
  final DateTime endsAt;
  final String status;
  final int players;

  /// `chess` or `mind` (Zihin Düellosu).
  final String game;
  final int? length;

  String get name => title ?? '${game == 'mind' ? 'Zihin Düellosu · ' : 'Satranç · '}${kind == 'weekly' ? 'Haftalık' : 'Aylık'} turnuva';

  /// "3+2" or "10 soru".
  String get format => game == 'mind' ? '$length soru' : '${baseSeconds! ~/ 60}+$incrementSeconds';
}

/// A running Zihin Düellosu match (docs/ARCHITECTURE.md §3j, Yönetim paneli).
class AdminMindMatch {
  const AdminMindMatch({
    required this.id,
    required this.a,
    required this.b,
    required this.length,
    required this.rated,
    required this.aScore,
    required this.bScore,
    required this.aAnswered,
    required this.bAnswered,
    required this.createdAt,
  });

  factory AdminMindMatch.fromJson(Map<String, Object?> j) => AdminMindMatch(
        id: j['id']! as String,
        a: j['a'] as String?,
        b: j['b'] as String?,
        length: j['length']! as int,
        rated: j['rated']! as bool,
        aScore: j['aScore']! as int,
        bScore: j['bScore']! as int,
        aAnswered: j['aAnswered']! as int,
        bAnswered: j['bAnswered']! as int,
        createdAt: DateTime.parse(j['createdAt']! as String),
      );

  final String id;
  final String? a;
  final String? b;
  final int length;
  final bool rated;
  final int aScore;
  final int bScore;
  final int aAnswered;
  final int bAnswered;
  final DateTime createdAt;
}

class AdminMindOverview {
  const AdminMindOverview({
    required this.matchesToday,
    required this.matchesTotal,
    required this.activeMatches,
    required this.waitingSeeks,
    required this.pendingChallenges,
    required this.ratedPlayers,
    required this.active,
  });

  factory AdminMindOverview.fromJson(Map<String, Object?> j) => AdminMindOverview(
        matchesToday: j['matchesToday']! as int,
        matchesTotal: j['matchesTotal']! as int,
        activeMatches: j['activeMatches']! as int,
        waitingSeeks: j['waitingSeeks']! as int,
        pendingChallenges: j['pendingChallenges']! as int,
        ratedPlayers: j['ratedPlayers']! as int,
        active: [for (final m in (j['active']! as List).cast<Map<String, Object?>>()) AdminMindMatch.fromJson(m)],
      );

  final int matchesToday;
  final int matchesTotal;
  final int activeMatches;
  final int waitingSeeks;
  final int pendingChallenges;
  final int ratedPlayers;
  final List<AdminMindMatch> active;
}

abstract interface class AdminGamesRepository {
  Future<Result<AdminMindOverview>> mind();

  /// Ends a running duel without a result or rating change.
  Future<Result<void>> abortMindMatch(String matchId, {required String reason});

  Future<Result<List<AdminTournament>>> tournaments();

  Future<Result<void>> createTournament({String game = 'chess', int? length, required String title, required int baseSeconds, required int incrementSeconds,
      required DateTime startsAt, required int minutes});

  Future<Result<void>> cancelTournament(String id, {required String reason});

  Future<Result<List<AdminTeamMatch>>> teamMatches();

  /// Only before the start.
  Future<Result<void>> cancelTeamMatch(String id, {required String reason});

  Future<Result<AdminChessOverview>> chess();

  Future<Result<void>> abortGame(String gameId, {required String reason});

  Future<Result<void>> suspendPlayer(String userId, {required String reason, DateTime? until});

  Future<Result<void>> restorePlayer(String userId);
}
