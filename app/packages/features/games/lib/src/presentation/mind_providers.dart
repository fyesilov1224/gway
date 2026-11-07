import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mind_repository_impl.dart';
import '../domain/chess.dart';
import '../domain/mind.dart';
import 'providers.dart';

final mindRepositoryProvider = Provider<MindRepository>(
  (ref) => MindRepositoryImpl(ref.watch(supabaseClientProvider), ref.watch(apiClientProvider)),
);

final mindProfileProvider = FutureProvider.autoDispose.family<MindProfile, String>((ref, userId) async {
  ref.cacheFor();
  return (await ref.watch(mindRepositoryProvider).profile(userId)).getOrThrow();
});

final mindRecentProvider = FutureProvider.autoDispose.family<List<MindMatchSummary>, String>((ref, userId) async {
  ref.cacheFor();
  return (await ref.watch(mindRepositoryProvider).recentMatches(userId)).getOrThrow();
});

final mindActiveProvider = FutureProvider.autoDispose<MindMatch?>((ref) async {
  ref.watch(currentUserIdProvider);
  return (await ref.watch(mindRepositoryProvider).activeMatch()).getOrThrow();
});

/// Open duel invitations in and out; refreshed by Realtime.
final mindChallengesProvider = FutureProvider.autoDispose<List<MindChallenge>>((ref) async {
  ref.watch(currentUserIdProvider);
  final repo = ref.watch(mindRepositoryProvider);
  final sub = repo.challengeChanges().listen((_) => ref.invalidateSelf());
  ref.onDispose(sub.cancel);
  return (await repo.challenges()).getOrThrow();
});

final mindLeaderboardProvider = FutureProvider.autoDispose.family<List<LeaderboardEntry>, int>((ref, length) async {
  ref.cacheFor();
  return (await ref.watch(mindRepositoryProvider).leaderboard(length, pageSize: 100)).getOrThrow();
});

/// The length chosen on the home screen, kept while the app runs.
class MindLengthNotifier extends Notifier<int> {
  @override
  int build() => mindDefaultLength;

  void set(int length) => state = length;
}

final mindLengthProvider = NotifierProvider<MindLengthNotifier, int>(MindLengthNotifier.new);

/// One open duel: the server's state kept in step by Realtime, the person's current question and the last answer's result.
class MindMatchState {
  const MindMatchState({
    required this.match,
    required this.offset,
    required this.players,
    this.question,
    this.startedLocal,
    this.result,
    this.given,
    this.sending = false,
  });

  final MindMatch match;

  /// Server clock minus the phone's.
  final Duration offset;
  final Map<String, ChessPlayer> players;
  final MindQuestion? question;

  /// When the question began on this phone (its serving time, in phone time).
  final DateTime? startedLocal;

  /// The last answer's score and solution, shown for a moment before the next question.
  final MindAnswered? result;

  /// What the person answered, to mark it against the solution.
  final Map<String, Object?>? given;
  final bool sending;

  DateTime get serverNow => DateTime.now().add(offset);

  /// Milliseconds since the question began.
  int get elapsedMs => startedLocal == null ? 0 : DateTime.now().difference(startedLocal!).inMilliseconds;

  MindMatchState copyWith({
    MindMatch? match,
    Duration? offset,
    Map<String, ChessPlayer>? players,
    MindQuestion? Function()? question,
    DateTime? Function()? startedLocal,
    MindAnswered? Function()? result,
    Map<String, Object?>? Function()? given,
    bool? sending,
  }) =>
      MindMatchState(
        match: match ?? this.match,
        offset: offset ?? this.offset,
        players: players ?? this.players,
        question: question == null ? this.question : question(),
        startedLocal: startedLocal == null ? this.startedLocal : startedLocal(),
        result: result == null ? this.result : result(),
        given: given == null ? this.given : given(),
        sending: sending ?? this.sending,
      );
}

final mindMatchControllerProvider =
    AsyncNotifierProvider.autoDispose.family<MindMatchController, MindMatchState, String>(MindMatchController.new);

class MindMatchController extends AsyncNotifier<MindMatchState> {
  MindMatchController(this.id);

  final String id;

  /// How long the right answer stays on screen.
  static const feedback = Duration(milliseconds: 1100);

  final _errors = StreamController<String>.broadcast();

  Stream<String> get errors => _errors.stream;

  MindRepository get _repo => ref.read(mindRepositoryProvider);

  Timer? _wait;
  bool _fetching = false;
  bool _disposed = false;

  @override
  Future<MindMatchState> build() async {
    final repo = ref.watch(mindRepositoryProvider);
    final view = (await repo.match(id)).getOrThrow();
    final players = <String, ChessPlayer>{};
    for (final userId in [?view.match.aId, ?view.match.bId]) {
      if ((await ref.read(chessRepositoryProvider).profile(userId)) case Ok(:final value)) players[userId] = value.player;
    }
    final sub = repo.matchUpdates(id).listen(_onUpdate);
    // Realtime can miss a change while the phone sleeps; a slow poll catches up.
    final poll = Timer.periodic(const Duration(seconds: 10), (_) => _refresh());
    ref.onDispose(() {
      _disposed = true;
      sub.cancel();
      poll.cancel();
      _wait?.cancel();
      _errors.close();
    });
    Timer.run(_advance);
    return MindMatchState(match: view.match, offset: view.serverNow.difference(DateTime.now()), players: players);
  }

  String? get _me => ref.read(currentUserIdProvider);

  MindSide? get mySide => state.value?.match.sideOf(_me);

  void _onUpdate(MindMatch incoming) {
    final s = state.value;
    if (s == null) return;
    final before = s.match;
    // Out-of-order Realtime: never step back.
    final progressed = incoming.aPoints.length >= before.aPoints.length && incoming.bPoints.length >= before.bPoints.length;
    if (!progressed && incoming.status == before.status) return;
    state = AsyncData(s.copyWith(match: incoming));
    if (before.isActive && !incoming.isActive) {
      _wait?.cancel();
      _invalidateLists();
    }
  }

  Future<void> _refresh() async {
    if ((await _repo.match(id)) case Ok(:final value)) {
      final s = state.value;
      if (s != null && !_disposed) {
        state = AsyncData(s.copyWith(offset: value.serverNow.difference(DateTime.now())));
        _onUpdate(value.match);
      }
    }
  }

  void _invalidateLists() {
    final me = _me;
    ref
      ..invalidate(mindActiveProvider)
      // The result moved ratings: the leaderboard shows it at once.
      ..invalidate(mindLeaderboardProvider);
    if (me != null) {
      ref.invalidate(mindRecentProvider(me));
      ref.invalidate(mindProfileProvider(me));
    }
  }

  /// Takes the next question, or waits for the start.
  Future<void> _advance() async {
    final s = state.value;
    final side = mySide;
    if (_disposed || s == null || side == null || !s.match.isActive || s.match.doneBy(side) || _fetching) return;
    final untilStart = s.match.startsAt.difference(s.serverNow);
    if (untilStart > Duration.zero) {
      _wait?.cancel();
      _wait = Timer(untilStart, _advance);
      return;
    }
    _fetching = true;
    final next = await _repo.next(id);
    _fetching = false;
    if (_disposed) return;
    final now = state.value!;
    switch (next) {
      case Ok(:final value):
        final offset = value.serverNow.difference(DateTime.now());
        final q = value.question;
        state = AsyncData(now.copyWith(
          match: value.match,
          offset: offset,
          question: () => q,
          // A question served before (the app was reopened) keeps its clock.
          startedLocal: () => q?.servedAt.subtract(offset),
          result: () => null,
          given: () => null,
        ));
        // Served too early by a phone clock ahead of the server: try again in a moment.
        if (q == null && value.match.isActive && !value.match.doneBy(side) && value.match.startsAt.isAfter(value.serverNow)) {
          _wait = Timer(value.match.startsAt.difference(value.serverNow), _advance);
        }
      case Err(:final failure):
        if (!_errors.isClosed) _errors.add(failure.userMessage);
        _wait = Timer(const Duration(seconds: 2), _advance);
    }
  }

  /// Sends the answer to the current question; the solution shows for [feedback], then the next question comes.
  Future<void> answer(Map<String, Object?> answer) async {
    final s = state.value;
    final q = s?.question;
    if (s == null || q == null || s.sending || s.result != null) return;
    state = AsyncData(s.copyWith(sending: true, given: () => answer));
    final result = await _repo.answer(id, q.index, answer, s.elapsedMs);
    if (_disposed) return;
    final now = state.value!;
    switch (result) {
      case Ok(:final value):
        state = AsyncData(now.copyWith(match: value.match, offset: value.serverNow.difference(DateTime.now()), result: () => value, sending: false));
        if (!value.match.isActive) _invalidateLists();
        _wait = Timer(feedback, _advance);
      case Err(:final failure):
        state = AsyncData(now.copyWith(sending: false, question: () => null, given: () => null));
        if (!_errors.isClosed) _errors.add(failure.userMessage);
        unawaited(_refresh().then((_) => _advance()));
    }
  }

  Future<void> resign() async {
    switch (await _repo.resign(id)) {
      case Ok(:final value):
        _onUpdate(value.match);
      case Err(:final failure):
        if (!_errors.isClosed) _errors.add(failure.userMessage);
    }
  }

  Future<Result<MindRematch>> rematch() => _repo.rematch(id);
}
