import 'package:core/core.dart';

import '../l10n.dart';

/// Time categories; each has its own Elo and leaderboard (docs/ARCHITECTURE.md §3i).
enum ChessCategory {
  bullet('bullet'),
  blitz('blitz'),
  rapid('rapid');

  const ChessCategory(this.code);

  final String code;

  String get label => switch (this) {
        bullet => gamesL10n.bullet,
        blitz => gamesL10n.blitz,
        rapid => gamesL10n.rapid,
      };

  static ChessCategory parse(Object? code) => values.firstWhere((c) => c.code == code, orElse: () => blitz);
}

/// A time control from the server's catalog: base minutes plus seconds added per move.
class TimeControl {
  const TimeControl(this.baseSeconds, this.incrementSeconds);

  final int baseSeconds;
  final int incrementSeconds;

  static const catalog = [
    TimeControl(60, 0), TimeControl(120, 1),
    TimeControl(180, 0), TimeControl(180, 2), TimeControl(300, 0), TimeControl(300, 3),
    TimeControl(600, 0), TimeControl(600, 5), TimeControl(900, 10),
  ];

  /// The default for invitations: 5+0 blitz.
  static const standard = TimeControl(300, 0);

  ChessCategory get category => switch (baseSeconds + 40 * incrementSeconds) {
        < 180 => ChessCategory.bullet,
        < 480 => ChessCategory.blitz,
        _ => ChessCategory.rapid,
      };

  /// "3+2": minutes and increment, the way players say it.
  String get label => '${baseSeconds ~/ 60}+$incrementSeconds';

  @override
  bool operator ==(Object other) => other is TimeControl && other.baseSeconds == baseSeconds && other.incrementSeconds == incrementSeconds;

  @override
  int get hashCode => Object.hash(baseSeconds, incrementSeconds);
}

enum ChessColor {
  white('white'),
  black('black');

  const ChessColor(this.code);

  final String code;

  ChessColor get opposite => this == white ? black : white;

  String get label => this == white ? gamesL10n.white : gamesL10n.black;

  static ChessColor? tryParse(Object? code) => switch (code) {
        'white' => white,
        'black' => black,
        _ => null,
      };
}

/// The color the challenger asks for.
enum ColorChoice {
  random('random'),
  white('white'),
  black('black');

  const ColorChoice(this.code);

  final String code;

  String get label => switch (this) {
        random => gamesL10n.colorRandom,
        white => gamesL10n.white,
        black => gamesL10n.black,
      };
}

enum GameStatus { active, finished, aborted }

enum Termination {
  checkmate('checkmate'),
  resign('resign'),
  timeout('timeout'),
  timeoutDraw('timeout_draw'),
  stalemate('stalemate'),
  insufficient('insufficient'),
  fiftyMoves('fifty_moves'),
  repetition('repetition'),
  agreement('agreement'),
  aborted('aborted');

  const Termination(this.code);

  final String code;

  String get label => switch (this) {
        checkmate => gamesL10n.endCheckmate,
        resign => gamesL10n.endResign,
        timeout => gamesL10n.endTimeout,
        timeoutDraw => gamesL10n.endTimeoutDraw,
        stalemate => gamesL10n.endStalemate,
        insufficient => gamesL10n.endInsufficient,
        fiftyMoves => gamesL10n.endFiftyMoves,
        repetition => gamesL10n.endRepetition,
        agreement => gamesL10n.endAgreement,
        aborted => gamesL10n.endAborted,
      };

  static Termination? tryParse(Object? code) => values.where((t) => t.code == code).firstOrNull;
}

/// One game as the server stores it (`chess_games`); the same shape comes from Realtime and the API.
class ChessGame {
  const ChessGame({
    required this.id,
    required this.whiteId,
    required this.blackId,
    required this.timeControl,
    required this.rated,
    required this.status,
    required this.moves,
    required this.san,
    required this.fen,
    required this.whiteMs,
    required this.blackMs,
    required this.turnStartedAt,
    required this.whiteRating,
    required this.blackRating,
    required this.createdAt,
    this.winner,
    this.isDraw = false,
    this.termination,
    this.drawOffer,
    this.whiteDelta,
    this.blackDelta,
    this.endedAt,
    this.tournamentId,
    this.teamMatchId,
  });

  factory ChessGame.fromRow(Map<String, dynamic> j) {
    final result = j['result'] as String?;
    return ChessGame(
      id: j['id'] as String,
      whiteId: j['white_id'] as String?,
      blackId: j['black_id'] as String?,
      timeControl: TimeControl((j['base_seconds'] as num).toInt(), (j['increment_seconds'] as num).toInt()),
      rated: j['rated'] as bool,
      status: switch (j['status']) {
        'finished' => GameStatus.finished,
        'aborted' => GameStatus.aborted,
        _ => GameStatus.active,
      },
      winner: ChessColor.tryParse(result),
      isDraw: result == 'draw',
      termination: Termination.tryParse(j['termination']),
      moves: [...(j['moves'] as List? ?? const []).cast<String>()],
      san: [...(j['san'] as List? ?? const []).cast<String>()],
      fen: j['fen'] as String,
      whiteMs: (j['white_ms'] as num).toInt(),
      blackMs: (j['black_ms'] as num).toInt(),
      turnStartedAt: DateTime.parse(j['turn_started_at'] as String),
      drawOffer: ChessColor.tryParse(j['draw_offer']),
      whiteRating: (j['white_rating'] as num).toInt(),
      blackRating: (j['black_rating'] as num).toInt(),
      whiteDelta: (j['white_delta'] as num?)?.toInt(),
      blackDelta: (j['black_delta'] as num?)?.toInt(),
      createdAt: DateTime.parse(j['created_at'] as String),
      endedAt: j['ended_at'] is String ? DateTime.parse(j['ended_at'] as String) : null,
      tournamentId: j['tournament_id'] as String?,
      teamMatchId: j['team_match_id'] as String?,
    );
  }

  final String id;
  final String? whiteId;
  final String? blackId;
  final TimeControl timeControl;
  final bool rated;
  final GameStatus status;
  final ChessColor? winner;
  final bool isDraw;
  final Termination? termination;

  /// UCI moves (`e2e4`, `e7e8q`) and the same moves in SAN (`e4`, `e8=Q+`).
  final List<String> moves;
  final List<String> san;
  final String fen;

  /// Time left at [turnStartedAt]; the side to move is charged from then on, from the third half-move.
  final int whiteMs;
  final int blackMs;
  final DateTime turnStartedAt;
  final ChessColor? drawOffer;
  final int whiteRating;
  final int blackRating;
  final int? whiteDelta;
  final int? blackDelta;
  final DateTime createdAt;
  final DateTime? endedAt;

  /// An arena game: the arena pairs the next one, so no rematch.
  final String? tournamentId;

  /// A board of a team match.
  final String? teamMatchId;

  int get ply => moves.length;

  ChessColor get toMove => ply.isEven ? ChessColor.white : ChessColor.black;

  bool get isActive => status == GameStatus.active;

  /// Whether the clocks run yet: both sides must have made their first move.
  bool get clockRunning => isActive && ply >= 2;

  ChessColor? colorOf(String? userId) => userId == null
      ? null
      : userId == whiteId
          ? ChessColor.white
          : userId == blackId
              ? ChessColor.black
              : null;

  String? idOf(ChessColor color) => color == ChessColor.white ? whiteId : blackId;

  int ratingOf(ChessColor color) => color == ChessColor.white ? whiteRating : blackRating;

  int? deltaOf(ChessColor color) => color == ChessColor.white ? whiteDelta : blackDelta;

  /// Time left for [color] at server time [now].
  int remainingMs(ChessColor color, DateTime now) {
    final stored = color == ChessColor.white ? whiteMs : blackMs;
    if (!clockRunning || color != toMove) return stored;
    return (stored - now.difference(turnStartedAt).inMilliseconds).clamp(0, stored);
  }

  /// The last move's squares, e.g. ('e2', 'e4').
  (String, String)? get lastMove {
    if (moves.isEmpty) return null;
    final m = moves.last;
    return (m.substring(0, 2), m.substring(2, 4));
  }

  /// The game's outcome seen by [color]: 1 win, 0.5 draw, 0 loss; null while running or aborted.
  double? scoreFor(ChessColor color) {
    if (status != GameStatus.finished) return null;
    if (isDraw) return 0.5;
    return winner == color ? 1 : 0;
  }
}

/// The game plus the server clock at the moment it was read, to keep the app's clocks in step.
typedef GameView = ({ChessGame game, DateTime serverNow});

/// A person as chess shows them: name, picture and the flag they chose.
class ChessPlayer {
  const ChessPlayer({required this.userId, required this.username, required this.displayName, this.avatarUrl, this.country});

  final String userId;
  final String username;
  final String displayName;
  final String? avatarUrl;

  /// ISO 3166-1 alpha-2; null until chosen.
  final String? country;
}

class ChessRating {
  const ChessRating({
    required this.category,
    this.rating = startRating,
    this.peak = startRating,
    this.games = 0,
    this.wins = 0,
    this.draws = 0,
    this.losses = 0,
  });

  static const startRating = 1200;

  /// Rated games needed to appear on the leaderboard.
  static const rankedAfter = 5;

  final ChessCategory category;
  final int rating;
  final int peak;
  final int games;
  final int wins;
  final int draws;
  final int losses;

  bool get ranked => games >= rankedAfter;
}

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.player,
    required this.rating,
    required this.games,
    required this.wins,
    required this.draws,
    required this.losses,
  });

  final int rank;
  final ChessPlayer player;
  final int rating;
  final int games;
  final int wins;
  final int draws;
  final int losses;
}

/// A player page: the person, their ratings in each category and their places on the leaderboards.
class ChessProfile {
  const ChessProfile({required this.player, required this.ratings, required this.ranks, this.suspendedUntil});

  final ChessPlayer player;
  final Map<ChessCategory, ChessRating> ratings;
  final Map<ChessCategory, int?> ranks;
  final DateTime? suspendedUntil;

  ChessRating ratingOf(ChessCategory c) => ratings[c] ?? ChessRating(category: c);

  bool get suspended => suspendedUntil?.isAfter(DateTime.now()) ?? false;
}

enum ChallengeStatus { pending, accepted, declined, canceled, expired }

class ChessChallenge {
  const ChessChallenge({
    required this.id,
    required this.challengerId,
    required this.opponentId,
    required this.timeControl,
    required this.rated,
    required this.color,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.gameId,
    this.rematchOf,
    this.other,
  });

  final String id;
  final String challengerId;
  final String opponentId;
  final TimeControl timeControl;
  final bool rated;

  /// The challenger's color.
  final ColorChoice color;
  final ChallengeStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String? gameId;
  final String? rematchOf;

  /// The person on the other side from the reader.
  final ChessPlayer? other;

  bool isIncomingFor(String? me) => opponentId == me;

  bool get isOpen => status == ChallengeStatus.pending && expiresAt.isAfter(DateTime.now());
}

/// A finished or running game in a list, with the reader's opponent.
class GameSummary {
  const GameSummary({required this.game, required this.color, this.opponent});

  final ChessGame game;

  /// The color of the person whose list it is.
  final ChessColor color;
  final ChessPlayer? opponent;
}

typedef RematchOutcome = ({String? challengeId, String? gameId});

abstract interface class ChessRepository {
  Future<Result<ChessProfile>> profile(String userId);

  Future<Result<void>> setCountry(String code);

  Future<Result<List<LeaderboardEntry>>> leaderboard(ChessCategory category, {int offset = 0, int pageSize = 50});

  Future<Result<Map<ChessCategory, int?>>> myRanks();

  Future<Result<List<GameSummary>>> recentGames(String userId, {int limit = 20});

  /// The signed-in person's running game, to come back to.
  Future<Result<ChessGame?>> activeGame();

  Future<Result<List<ChessChallenge>>> challenges();

  /// Something changed in the person's challenges (new, answered, expired).
  Stream<void> challengeChanges();

  Future<Result<List<ChessPlayer>>> searchPlayers(String query);

  /// Starts or replaces the quick-game seek; a game id when paired at once.
  Future<Result<String?>> seek(TimeControl timeControl, {bool rated = true});

  Future<Result<String?>> heartbeat();

  Future<Result<void>> cancelSeek();

  /// The game the seek was paired into.
  Stream<String> seekMatches();

  Future<Result<String>> challenge(String opponentId, TimeControl timeControl, {bool rated = true, ColorChoice color = ColorChoice.random});

  /// The game it started.
  Future<Result<String>> accept(String challengeId);

  Future<Result<void>> decline(String challengeId);

  Future<Result<void>> cancelChallenge(String challengeId);

  Future<Result<GameView>> game(String id);

  Stream<ChessGame> gameUpdates(String id);

  Future<Result<GameView>> move(String id, String uci, int ply);

  Future<Result<GameView>> resign(String id);

  Future<Result<GameView>> abort(String id);

  Future<Result<GameView>> offerDraw(String id);

  Future<Result<GameView>> acceptDraw(String id);

  Future<Result<GameView>> declineDraw(String id);

  Future<Result<GameView>> flag(String id);

  Future<Result<RematchOutcome>> rematch(String id);
}
