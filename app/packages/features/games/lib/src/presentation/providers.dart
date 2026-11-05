import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:chess/chess.dart' as rules;
import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/arena_repository_impl.dart';
import '../data/chess_repository_impl.dart';
import '../data/team_repository_impl.dart';
import '../domain/arena.dart';
import '../domain/chess.dart';
import '../domain/team.dart';

final chessRepositoryProvider = Provider<ChessRepository>(
  (ref) => ChessRepositoryImpl(ref.watch(supabaseClientProvider), ref.watch(apiClientProvider)),
);

final chessProfileProvider = FutureProvider.autoDispose.family<ChessProfile, String>((ref, userId) async {
  ref.cacheFor();
  return (await ref.watch(chessRepositoryProvider).profile(userId)).getOrThrow();
});

final recentGamesProvider = FutureProvider.autoDispose.family<List<GameSummary>, String>((ref, userId) async {
  ref.cacheFor();
  return (await ref.watch(chessRepositoryProvider).recentGames(userId)).getOrThrow();
});

final activeGameProvider = FutureProvider.autoDispose<ChessGame?>((ref) async {
  ref.watch(currentUserIdProvider);
  return (await ref.watch(chessRepositoryProvider).activeGame()).getOrThrow();
});

/// Open invitations in and out; refreshed by Realtime.
final challengesProvider = FutureProvider.autoDispose<List<ChessChallenge>>((ref) async {
  ref.watch(currentUserIdProvider);
  final repo = ref.watch(chessRepositoryProvider);
  final sub = repo.challengeChanges().listen((_) => ref.invalidateSelf());
  ref.onDispose(sub.cancel);
  return (await repo.challenges()).getOrThrow();
});

final leaderboardProvider = FutureProvider.autoDispose.family<List<LeaderboardEntry>, ChessCategory>((ref, category) async {
  ref.cacheFor();
  return (await ref.watch(chessRepositoryProvider).leaderboard(category, pageSize: 100)).getOrThrow();
});

/// The chess sounds (GWAY's own, assets/sounds): one player each so a capture can follow a move at once.
class ChessSounds {
  final _players = <String, AudioPlayer>{};

  Future<void> play(String name) async {
    final player = _players[name] ??= AudioPlayer()..audioCache = AudioCache(prefix: 'packages/games/assets/sounds/');
    try {
      await player.stop();
      await player.play(AssetSource('$name.wav'), mode: PlayerMode.lowLatency);
    } on Object {
      // A device without audio simply plays nothing.
    }
  }

  void forSan(String san) => unawaited(play(san.contains('x') ? 'capture' : 'move'));

  Future<void> dispose() async {
    for (final p in _players.values) {
      await p.dispose();
    }
  }
}

final chessSoundsProvider = Provider<ChessSounds>((ref) {
  final sounds = ChessSounds();
  ref.onDispose(sounds.dispose);
  return sounds;
});

/// One open game: the server's state, kept in step by Realtime, with the person's move shown at once.
class GameState {
  const GameState({required this.game, required this.offset, required this.players, this.premove, this.sending = false});

  final ChessGame game;

  /// Server clock minus the phone's, so the clocks count from server time.
  final Duration offset;
  final Map<String, ChessPlayer> players;
  final String? premove;

  /// A move is on its way; the next one waits.
  final bool sending;

  DateTime get serverNow => DateTime.now().add(offset);

  GameState copyWith({ChessGame? game, Duration? offset, Map<String, ChessPlayer>? players, String? Function()? premove, bool? sending}) =>
      GameState(
        game: game ?? this.game,
        offset: offset ?? this.offset,
        players: players ?? this.players,
        premove: premove == null ? this.premove : premove(),
        sending: sending ?? this.sending,
      );
}

final gameControllerProvider = AsyncNotifierProvider.autoDispose.family<GameController, GameState, String>(GameController.new);

class GameController extends AsyncNotifier<GameState> {
  GameController(this.id);

  final String id;

  /// The last failure to show once (rule message from the server).
  final _errors = StreamController<String>.broadcast();

  Stream<String> get errors => _errors.stream;

  ChessRepository get _repo => ref.read(chessRepositoryProvider);

  ChessSounds get _sounds => ref.read(chessSoundsProvider);

  /// The ply a flag was already asked for, so a stuck clock does not call the server every tick.
  int? _flaggedAt;

  @override
  Future<GameState> build() async {
    final repo = ref.watch(chessRepositoryProvider);
    final view = (await repo.game(id)).getOrThrow();
    final game = view.game;
    final players = (await _players(repo, game)) ?? const {};
    final sub = repo.gameUpdates(id).listen(_onUpdate);
    // Realtime can miss a change while the phone sleeps; a slow poll catches up.
    final poll = Timer.periodic(const Duration(seconds: 15), (_) => _refresh());
    ref.onDispose(() {
      sub.cancel();
      poll.cancel();
      _errors.close();
    });
    if (game.isActive && game.ply == 0) unawaited(_sounds.play('notify'));
    return GameState(game: game, offset: view.serverNow.difference(DateTime.now()), players: players);
  }

  Future<Map<String, ChessPlayer>?> _players(ChessRepository repo, ChessGame game) async {
    final ids = [?game.whiteId, ?game.blackId];
    final profiles = <String, ChessPlayer>{};
    for (final id in ids) {
      if ((await repo.profile(id)) case Ok(:final value)) profiles[id] = value.player;
    }
    return profiles;
  }

  String? get _me => ref.read(currentUserIdProvider);

  Future<void> _refresh() async {
    if ((await _repo.game(id)) case Ok(:final value)) _apply(value.game, serverNow: value.serverNow);
  }

  void _onUpdate(ChessGame incoming) => _apply(incoming);

  /// Takes a newer server state; plays the opponent's move sound and a queued premove.
  void _apply(ChessGame incoming, {DateTime? serverNow}) {
    final current = state.value;
    if (current == null) return;
    final before = current.game;
    // Out-of-order Realtime: never step back.
    if (incoming.ply < before.ply && incoming.status == before.status) return;
    var next = current.copyWith(game: incoming, offset: serverNow?.difference(DateTime.now()));
    if (incoming.ply > before.ply && incoming.san.isNotEmpty) {
      final mine = incoming.colorOf(_me);
      final byOpponent = mine != null && incoming.toMove == mine;
      if (byOpponent || mine == null) _sounds.forSan(incoming.san.last);
    }
    if (before.isActive && !incoming.isActive) {
      unawaited(_sounds.play('notify'));
      next = next.copyWith(premove: () => null);
    }
    state = AsyncData(next);
    _playPremove();
  }

  void _playPremove() {
    final s = state.value;
    final premove = s?.premove;
    if (s == null || premove == null || s.sending || !s.game.isActive) return;
    if (s.game.toMove != s.game.colorOf(_me)) return;
    state = AsyncData(s.copyWith(premove: () => null));
    final position = rules.Chess.fromFEN(s.game.fen);
    final legal = position.generate_moves({'legal': true}).any((m) =>
        m.fromAlgebraic == premove.substring(0, 2) &&
        m.toAlgebraic == premove.substring(2, 4) &&
        (premove.length == 4 || m.promotion?.name == premove[4]));
    if (legal) unawaited(move(premove));
  }

  void setPremove(String? uci) {
    final s = state.value;
    if (s != null) state = AsyncData(s.copyWith(premove: () => uci));
  }

  /// Shows the move on the board at once, then lets the server decide.
  Future<void> move(String uci) async {
    final s = state.value;
    if (s == null || s.sending || !s.game.isActive) return;
    final game = s.game;
    final position = rules.Chess.fromFEN(game.fen);
    final candidate = position.generate_moves({'legal': true}).where((m) =>
        m.fromAlgebraic == uci.substring(0, 2) &&
        m.toAlgebraic == uci.substring(2, 4) &&
        (m.promotion == null || m.promotion!.name == (uci.length == 5 ? uci[4] : 'q'))).firstOrNull;
    if (candidate == null) return;
    final san = position.move_to_san(candidate);
    position.move(candidate);
    final optimistic = ChessGame(
      id: game.id,
      whiteId: game.whiteId,
      blackId: game.blackId,
      timeControl: game.timeControl,
      rated: game.rated,
      status: game.status,
      moves: [...game.moves, uci],
      san: [...game.san, san],
      fen: position.fen,
      whiteMs: game.whiteMs,
      blackMs: game.blackMs,
      turnStartedAt: s.serverNow,
      whiteRating: game.whiteRating,
      blackRating: game.blackRating,
      createdAt: game.createdAt,
      drawOffer: game.drawOffer == game.toMove ? game.drawOffer : null,
      tournamentId: game.tournamentId,
      teamMatchId: game.teamMatchId,
    );
    _sounds.forSan(san);
    state = AsyncData(s.copyWith(game: optimistic, sending: true));
    final result = await _repo.move(id, uci, game.ply);
    final after = state.value!;
    switch (result) {
      case Ok(:final value):
        state = AsyncData(after.copyWith(sending: false));
        _apply(value.game, serverNow: value.serverNow);
      case Err(:final failure):
        state = AsyncData(after.copyWith(game: game, sending: false));
        if (!_errors.isClosed) _errors.add(failure.userMessage);
        unawaited(_refresh());
    }
  }

  Future<void> _act(Future<Result<GameView>> Function(String id) action) async {
    switch (await action(id)) {
      case Ok(:final value):
        _apply(value.game, serverNow: value.serverNow);
      case Err(:final failure):
        if (!_errors.isClosed) _errors.add(failure.userMessage);
    }
  }

  Future<void> resign() => _act(_repo.resign);

  Future<void> abort() => _act(_repo.abort);

  Future<void> offerDraw() => _act(_repo.offerDraw);

  Future<void> acceptDraw() => _act(_repo.acceptDraw);

  Future<void> declineDraw() => _act(_repo.declineDraw);

  /// The clock on screen reached zero: ask the server to settle it (once per position).
  Future<void> flag() async {
    final game = state.value?.game;
    if (game == null || !game.isActive || _flaggedAt == game.ply) return;
    _flaggedAt = game.ply;
    await _act(_repo.flag);
  }

  Future<Result<RematchOutcome>> rematch() => _repo.rematch(id);
}

// ---------------------------------------------------------------------------
// Team matches and the group leaderboard (20b)
// ---------------------------------------------------------------------------

final teamRepositoryProvider = Provider<TeamMatchRepository>(
  (ref) => TeamMatchRepositoryImpl(ref.watch(supabaseClientProvider), ref.watch(apiClientProvider)),
);

final groupLeaderboardProvider = FutureProvider.autoDispose.family<List<GroupLeaderboardEntry>, TeamGame>((ref, game) async {
  ref.cacheFor();
  return (await ref.watch(teamRepositoryProvider).groupLeaderboard(game)).getOrThrow();
});

final captainGroupsProvider = FutureProvider.autoDispose<List<ChessGroup>>((ref) async {
  ref.watch(currentUserIdProvider);
  return (await ref.watch(teamRepositoryProvider).captainGroups()).getOrThrow();
});

final myTeamMatchesProvider = FutureProvider.autoDispose.family<List<TeamMatch>, TeamGame>((ref, game) async {
  ref.watch(currentUserIdProvider);
  return (await ref.watch(teamRepositoryProvider).myMatches(game)).getOrThrow();
});

/// One team match, refreshed when it or a board changes.
final teamMatchProvider = FutureProvider.autoDispose.family<TeamMatchDetail, String>((ref, id) async {
  final repo = ref.watch(teamRepositoryProvider);
  final sub = repo.changes(id).listen((_) => ref.invalidateSelf());
  ref.onDispose(sub.cancel);
  return (await repo.detail(id)).getOrThrow();
});

// ---------------------------------------------------------------------------
// Arenas (20c)
// ---------------------------------------------------------------------------

final arenaRepositoryProvider = Provider<ArenaRepository>(
  (ref) => ArenaRepositoryImpl(ref.watch(supabaseClientProvider), ref.watch(apiClientProvider)),
);

final arenasProvider = FutureProvider.autoDispose<ArenaLists>((ref) async {
  ref.watch(currentUserIdProvider);
  return (await ref.watch(arenaRepositoryProvider).arenas()).getOrThrow();
});

/// One arena with its standings, refreshed by Realtime.
final arenaProvider = FutureProvider.autoDispose.family<ArenaDetail, String>((ref, id) async {
  final repo = ref.watch(arenaRepositoryProvider);
  final sub = repo.changes(id).listen((_) => ref.invalidateSelf());
  ref.onDispose(sub.cancel);
  return (await repo.detail(id)).getOrThrow();
});

final medalsProvider = FutureProvider.autoDispose.family<ChessMedals, String>((ref, userId) async {
  ref.cacheFor();
  return (await ref.watch(arenaRepositoryProvider).medals(userId)).getOrThrow();
});
