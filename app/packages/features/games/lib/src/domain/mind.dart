import 'package:core/core.dart';

import '../l10n.dart';
import 'chess.dart';

/// Zihin Düellosu (docs/ARCHITECTURE.md §3j): a live duel of mixed questions. Each length has its own Elo.
const mindLengths = [5, 10, 20, 50];

/// The default length on the home screen.
const mindDefaultLength = 10;

/// Matches needed at a length to appear on its leaderboard.
const mindRankedAfter = 5;

enum MindKind {
  math('math'),
  attention('attention'),
  memory('memory'),
  reflex('reflex');

  const MindKind(this.code);

  final String code;

  String get label => switch (this) {
        math => gamesL10n.mindKindMath,
        attention => gamesL10n.mindKindAttention,
        memory => gamesL10n.mindKindMemory,
        reflex => gamesL10n.mindKindReflex,
      };

  String get hint => switch (this) {
        math => gamesL10n.mindKindMathHint,
        attention => gamesL10n.mindKindAttentionHint,
        memory => gamesL10n.mindKindMemoryHint,
        reflex => gamesL10n.mindKindReflexHint,
      };

  static MindKind parse(Object? code) => values.firstWhere((k) => k.code == code, orElse: () => math);
}

enum MindPattern { solid, striped, dotted }

enum MindShape { circle, square, triangle, star }

/// A drawn figure: color (a `GwMindColor` name), pattern and shape.
class MindFigure {
  const MindFigure({required this.color, this.pattern = MindPattern.solid, required this.shape});

  factory MindFigure.fromJson(Map<String, dynamic> j) => MindFigure(
        color: j['color'] as String,
        pattern: MindPattern.values.firstWhere((p) => p.name == j['pattern'], orElse: () => MindPattern.solid),
        shape: MindShape.values.firstWhere((s) => s.name == j['shape'], orElse: () => MindShape.circle),
      );

  final String color;
  final MindPattern pattern;
  final MindShape shape;

  @override
  bool operator ==(Object other) => other is MindFigure && other.color == color && other.pattern == pattern && other.shape == shape;

  @override
  int get hashCode => Object.hash(color, pattern, shape);
}

/// A letter or digit in a color, for the memory questions.
class MindChar {
  const MindChar(this.char, this.color);

  factory MindChar.fromJson(Map<String, dynamic> j) => MindChar(j['char'] as String, j['color'] as String);

  final String char;
  final String color;
}

enum MindStatus { active, finished, aborted }

enum MindTermination {
  completed('completed'),
  time('time'),
  resign('resign'),
  aborted('aborted');

  const MindTermination(this.code);

  final String code;

  String get label => switch (this) {
        completed => gamesL10n.mindEndCompleted,
        time => gamesL10n.mindEndTime,
        resign => gamesL10n.endResign,
        aborted => gamesL10n.endAborted,
      };

  static MindTermination? tryParse(Object? code) => values.where((t) => t.code == code).firstOrNull;
}

/// The two seats of a duel; neither has an advantage.
enum MindSide {
  a,
  b;

  MindSide get other => this == a ? b : a;
}

/// One duel as the server stores it (`mind_matches`); the same shape comes from Realtime and the API.
class MindMatch {
  const MindMatch({
    required this.id,
    required this.aId,
    required this.bId,
    required this.length,
    required this.rated,
    required this.status,
    required this.aPoints,
    required this.bPoints,
    required this.aScore,
    required this.bScore,
    required this.aJoined,
    required this.bJoined,
    required this.aRating,
    required this.bRating,
    required this.startsAt,
    required this.deadlineAt,
    required this.createdAt,
    this.winner,
    this.isDraw = false,
    this.termination,
    this.aDelta,
    this.bDelta,
    this.endedAt,
  });

  factory MindMatch.fromRow(Map<String, dynamic> j) {
    final result = j['result'] as String?;
    List<int> ints(Object? v) => [for (final n in (v as List? ?? const [])) (n as num).toInt()];
    return MindMatch(
      id: j['id'] as String,
      aId: j['a_id'] as String?,
      bId: j['b_id'] as String?,
      length: (j['length'] as num).toInt(),
      rated: j['rated'] as bool,
      status: switch (j['status']) {
        'finished' => MindStatus.finished,
        'aborted' => MindStatus.aborted,
        _ => MindStatus.active,
      },
      winner: switch (result) {
        'a' => MindSide.a,
        'b' => MindSide.b,
        _ => null,
      },
      isDraw: result == 'draw',
      termination: MindTermination.tryParse(j['termination']),
      aPoints: ints(j['a_points']),
      bPoints: ints(j['b_points']),
      aScore: (j['a_score'] as num).toInt(),
      bScore: (j['b_score'] as num).toInt(),
      aJoined: j['a_joined'] as bool? ?? false,
      bJoined: j['b_joined'] as bool? ?? false,
      aRating: (j['a_rating'] as num).toInt(),
      bRating: (j['b_rating'] as num).toInt(),
      aDelta: (j['a_delta'] as num?)?.toInt(),
      bDelta: (j['b_delta'] as num?)?.toInt(),
      startsAt: DateTime.parse(j['starts_at'] as String),
      deadlineAt: DateTime.parse(j['deadline_at'] as String),
      createdAt: DateTime.parse(j['created_at'] as String),
      endedAt: j['ended_at'] is String ? DateTime.parse(j['ended_at'] as String) : null,
    );
  }

  final String id;
  final String? aId;
  final String? bId;
  final int length;
  final bool rated;
  final MindStatus status;
  final MindSide? winner;
  final bool isDraw;
  final MindTermination? termination;

  /// Points per answered question, in order.
  final List<int> aPoints;
  final List<int> bPoints;
  final int aScore;
  final int bScore;
  final bool aJoined;
  final bool bJoined;
  final int aRating;
  final int bRating;
  final int? aDelta;
  final int? bDelta;
  final DateTime startsAt;
  final DateTime deadlineAt;
  final DateTime createdAt;
  final DateTime? endedAt;

  bool get isActive => status == MindStatus.active;

  MindSide? sideOf(String? userId) => userId == null
      ? null
      : userId == aId
          ? MindSide.a
          : userId == bId
              ? MindSide.b
              : null;

  String? idOf(MindSide side) => side == MindSide.a ? aId : bId;

  List<int> pointsOf(MindSide side) => side == MindSide.a ? aPoints : bPoints;

  int scoreOf(MindSide side) => side == MindSide.a ? aScore : bScore;

  int ratingOf(MindSide side) => side == MindSide.a ? aRating : bRating;

  int? deltaOf(MindSide side) => side == MindSide.a ? aDelta : bDelta;

  bool joined(MindSide side) => side == MindSide.a ? aJoined : bJoined;

  /// Questions answered by [side].
  int answeredBy(MindSide side) => pointsOf(side).length;

  bool doneBy(MindSide side) => answeredBy(side) >= length;

  /// 1 win, 0.5 draw, 0 loss; null while running or aborted.
  double? scoreFor(MindSide side) {
    if (status != MindStatus.finished) return null;
    if (isDraw) return 0.5;
    return winner == side ? 1 : 0;
  }
}

typedef MindView = ({MindMatch match, DateTime serverNow});

/// A question as served: no solution with it (docs/ARCHITECTURE.md §3j, Sorular).
class MindQuestion {
  const MindQuestion({
    required this.index,
    required this.kind,
    required this.level,
    required this.payload,
    required this.limitMs,
    required this.servedAt,
  });

  factory MindQuestion.fromJson(Map<String, dynamic> j) => MindQuestion(
        index: (j['index'] as num).toInt(),
        kind: MindKind.parse(j['kind']),
        level: (j['level'] as num).toInt(),
        payload: (j['payload'] as Map).cast<String, dynamic>(),
        limitMs: (j['limitMs'] as num).toInt(),
        servedAt: DateTime.parse(j['servedAt'] as String),
      );

  final int index;
  final MindKind kind;
  final int level;
  final Map<String, dynamic> payload;
  final int limitMs;
  final DateTime servedAt;

  // Math
  String get expression => payload['expression'] as String? ?? '';

  List<int> get numberChoices => [for (final n in (payload['choices'] as List? ?? const [])) if (n is num) n.toInt()];

  // Attention
  MindFigure get described => MindFigure.fromJson(payload);

  String get ink => payload['ink'] as String? ?? '';

  List<MindFigure> get figureChoices =>
      [for (final f in (payload['choices'] as List? ?? const [])) if (f is Map) MindFigure.fromJson(f.cast<String, dynamic>())];

  // Memory
  List<MindChar> get items => [for (final i in (payload['items'] as List? ?? const [])) MindChar.fromJson((i as Map).cast<String, dynamic>())];

  List<MindChar> get options => [for (final i in (payload['options'] as List? ?? const [])) MindChar.fromJson((i as Map).cast<String, dynamic>())];

  int get showMs => (payload['showMs'] as num?)?.toInt() ?? 0;

  // Reflex
  MindFigure get target => MindFigure.fromJson((payload['target'] as Map).cast<String, dynamic>());

  int get grid => (payload['grid'] as num?)?.toInt() ?? 3;

  List<MindFigure> get decoys => [for (final d in (payload['decoys'] as List? ?? const [])) MindFigure.fromJson((d as Map).cast<String, dynamic>())];

  int get delayMs => (payload['delayMs'] as num?)?.toInt() ?? 0;

  int get visibleMs => (payload['visibleMs'] as num?)?.toInt() ?? 0;

  int get targetCell => (payload['cell'] as num?)?.toInt() ?? 0;
}

typedef MindNext = ({MindMatch match, DateTime serverNow, MindQuestion? question});

/// How an answer scored, with the solution: `choice`, `picks` or `cell`.
class MindAnswered {
  const MindAnswered({required this.points, required this.correct, required this.solution, required this.match, required this.serverNow});

  final int points;
  final bool correct;
  final Map<String, dynamic> solution;
  final MindMatch match;
  final DateTime serverNow;

  int? get choice => (solution['choice'] as num?)?.toInt();

  List<int> get picks => [for (final n in (solution['picks'] as List? ?? const [])) (n as num).toInt()];

  int? get cell => (solution['cell'] as num?)?.toInt();
}

class MindRating {
  const MindRating({
    required this.length,
    this.rating = ChessRating.startRating,
    this.peak = ChessRating.startRating,
    this.games = 0,
    this.wins = 0,
    this.draws = 0,
    this.losses = 0,
  });

  final int length;
  final int rating;
  final int peak;
  final int games;
  final int wins;
  final int draws;
  final int losses;

  bool get ranked => games >= mindRankedAfter;
}

/// A player page: the person, their rating at each length and their places on the leaderboards.
class MindProfile {
  const MindProfile({required this.player, required this.ratings, required this.ranks, this.suspendedUntil});

  final ChessPlayer player;
  final Map<int, MindRating> ratings;
  final Map<int, int?> ranks;
  final DateTime? suspendedUntil;

  MindRating ratingOf(int length) => ratings[length] ?? MindRating(length: length);

  bool get suspended => suspendedUntil?.isAfter(DateTime.now()) ?? false;
}

class MindChallenge {
  const MindChallenge({
    required this.id,
    required this.challengerId,
    required this.opponentId,
    required this.length,
    required this.rated,
    required this.expiresAt,
    this.matchId,
    this.rematchOf,
    this.other,
  });

  final String id;
  final String challengerId;
  final String opponentId;
  final int length;
  final bool rated;
  final DateTime expiresAt;
  final String? matchId;
  final String? rematchOf;

  /// The person on the other side from the reader.
  final ChessPlayer? other;

  bool isIncomingFor(String? me) => opponentId == me;

  bool get isOpen => expiresAt.isAfter(DateTime.now());
}

/// A duel in a list, with the reader's opponent.
class MindMatchSummary {
  const MindMatchSummary({required this.match, required this.side, this.opponent});

  final MindMatch match;
  final MindSide side;
  final ChessPlayer? opponent;
}

typedef MindRematch = ({String? challengeId, String? matchId});

abstract interface class MindRepository {
  Future<Result<MindProfile>> profile(String userId);

  Future<Result<List<LeaderboardEntry>>> leaderboard(int length, {int offset = 0, int pageSize = 50});

  Future<Result<List<MindMatchSummary>>> recentMatches(String userId, {int limit = 20});

  /// The signed-in person's running duel, to come back to.
  Future<Result<MindMatch?>> activeMatch();

  Future<Result<List<MindChallenge>>> challenges();

  Stream<void> challengeChanges();

  /// Starts or replaces the quick-match seek; a match id when paired at once.
  Future<Result<String?>> seek(int length);

  Future<Result<String?>> heartbeat();

  Future<Result<void>> cancelSeek();

  Stream<String> seekMatches();

  Future<Result<String>> challenge(String opponentId, int length, {bool rated = true});

  /// The match it started.
  Future<Result<String>> accept(String challengeId);

  Future<Result<void>> decline(String challengeId);

  Future<Result<void>> cancelChallenge(String challengeId);

  Future<Result<MindView>> match(String id);

  Stream<MindMatch> matchUpdates(String id);

  Future<Result<MindNext>> next(String id);

  Future<Result<MindAnswered>> answer(String id, int index, Map<String, Object?> answer, int elapsedMs);

  Future<Result<MindView>> resign(String id);

  Future<Result<MindRematch>> rematch(String id);
}
