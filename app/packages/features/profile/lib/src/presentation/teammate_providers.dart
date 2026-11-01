import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/teammates_repository_impl.dart';
import '../domain/teammates.dart';

final teammatesRepositoryProvider = Provider<TeammatesRepository>(
  (ref) => TeammatesRepositoryImpl(ref.watch(supabaseClientProvider), ref.watch(apiClientProvider)),
);

final teammatePreferencesProvider = FutureProvider.autoDispose<TeammatePreferences>((ref) async {
  ref.cacheFor();
  ref.watch(currentUserIdProvider);
  return (await ref.watch(teammatesRepositoryProvider).preferences()).getOrThrow();
});

final teammateStatusProvider = FutureProvider.autoDispose.family<TeammateStatus?, String>((ref, userId) async {
  ref.cacheFor();
  ref.watch(currentUserIdProvider);
  return (await ref.watch(teammatesRepositoryProvider).status(userId)).getOrThrow();
});

final teammateSuggestionsProvider = FutureProvider.autoDispose<List<TeammateSuggestion>>(
  (ref) async {
    ref.cacheFor();
    return (await ref.watch(teammatesRepositoryProvider).suggestions()).getOrThrow();
  },
);

final myTeammatesProvider = FutureProvider.autoDispose<MyTeammates>((ref) async {
  ref.cacheFor();
  ref.watch(currentUserIdProvider);
  return (await ref.watch(teammatesRepositoryProvider).mine()).getOrThrow();
});

/// Reloads everything that shows teammates after a request or a settings change.
void refreshTeammates(WidgetRef ref) {
  ref
    ..invalidate(teammatePreferencesProvider)
    ..invalidate(teammateStatusProvider)
    ..invalidate(teammateSuggestionsProvider)
    ..invalidate(myTeammatesProvider);
}
