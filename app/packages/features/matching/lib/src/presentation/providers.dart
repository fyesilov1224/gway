import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/matching_repository_impl.dart';
import '../domain/matching.dart';

final matchingRepositoryProvider = Provider<MatchingRepository>(
  (ref) => MatchingRepositoryImpl(ref.watch(supabaseClientProvider), ref.watch(apiClientProvider)),
);

final myMatchProfileProvider = FutureProvider.autoDispose<MatchProfile?>((ref) async {
  ref.cacheFor();
  ref.watch(currentUserIdProvider);
  return (await ref.watch(matchingRepositoryProvider).myProfile()).getOrThrow();
});

final matchListProvider = FutureProvider.autoDispose<List<MatchSummary>>(
  (ref) async {
    ref.cacheFor();
    return (await ref.watch(matchingRepositoryProvider).matches()).getOrThrow();
  },
);

/// The user's packages and today's allowances.
final matchStatusProvider = FutureProvider.autoDispose<MatchStatus>((ref) async {
  ref.cacheFor();
  ref.watch(currentUserIdProvider);
  return (await ref.watch(matchingRepositoryProvider).status()).getOrThrow();
});

/// Seni Beğenenler: the people waiting for an answer in one mode.
final admirersProvider = FutureProvider.autoDispose.family<List<MatchCard>, MatchMode>(
  (ref, mode) async {
    ref.cacheFor();
    return (await ref.watch(matchingRepositoryProvider).admirers(mode)).getOrThrow();
  },
);

/// The deck filters for this session (Sınırsız Beğeni).
final deckFiltersProvider = NotifierProvider<DeckFilters, MatchFilters>(DeckFilters.new);

class DeckFilters extends Notifier<MatchFilters> {
  @override
  MatchFilters build() {
    ref.watch(currentUserIdProvider);
    return const MatchFilters();
  }

  void set(MatchFilters filters) => state = filters;
}

/// The cards still to swipe in one mode; a swipe takes the top card off at once.
final deckProvider = AsyncNotifierProvider.autoDispose.family<Deck, List<MatchCard>, MatchMode>(Deck.new);

class Deck extends AsyncNotifier<List<MatchCard>> {
  Deck(this.mode);

  final MatchMode mode;

  /// The last card passed, so a rewind can put it back on top.
  MatchCard? _lastPassed;

  @override
  Future<List<MatchCard>> build() async {
    ref.watch(currentUserIdProvider);
    final filters = ref.watch(deckFiltersProvider);
    return (await ref.watch(matchingRepositoryProvider).deck(mode, filters: filters)).getOrThrow();
  }

  /// Takes [card] off, then sends the swipe; a failed swipe puts it back on top.
  Future<Result<SwipeOutcome>> swipe(MatchCard card, SwipeKind kind) async {
    final before = state.value ?? const <MatchCard>[];
    final rest = [...before.where((c) => c.userId != card.userId)];
    state = AsyncData(rest);
    final result = await ref.read(matchingRepositoryProvider).swipe(card.userId, mode, kind);
    switch (result) {
      case Ok(:final value):
        _lastPassed = kind == SwipeKind.pass ? card : null;
        ref.invalidate(matchStatusProvider);
        if (value.matched) ref.invalidate(matchListProvider);
        // Fetch more before the deck runs dry.
        if (rest.length < 3) ref.invalidateSelf();
      case Err():
        state = AsyncData([card, ...rest]);
    }
    return result;
  }

  /// Sınırsız Beğeni: the last pass comes back on top.
  Future<Result<Rewound>> rewind() async {
    final result = await ref.read(matchingRepositoryProvider).rewind();
    if (result case Ok(:final value) when value.mode == mode) {
      final card = _lastPassed?.userId == value.userId ? _lastPassed : null;
      _lastPassed = null;
      if (card != null) {
        state = AsyncData([card, ...?state.value?.where((c) => c.userId != card.userId)]);
      } else {
        ref.invalidateSelf();
      }
    }
    return result;
  }
}
