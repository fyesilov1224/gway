import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/social_repository_impl.dart';
import '../domain/social.dart';

final socialRepositoryProvider = Provider<SocialRepository>(
  (ref) => SocialRepositoryImpl(ref.watch(supabaseClientProvider), ref.watch(apiClientProvider)),
);

final profileSocialProvider = FutureProvider.autoDispose.family<ProfileSocial, String>((ref, userId) async {
  ref.cacheFor();
  ref.watch(currentUserIdProvider);
  return (await ref.watch(socialRepositoryProvider).social(userId)).getOrThrow();
});

typedef FollowListKey = ({String userId, FollowList list});

final followListProvider = FutureProvider.autoDispose.family<List<PersonSummary>, FollowListKey>(
  (ref, key) async {
    ref.cacheFor();
    return (await ref.watch(socialRepositoryProvider).list(key.userId, key.list)).getOrThrow();
  },
);

final followRequestsProvider = FutureProvider.autoDispose<List<PersonSummary>>((ref) async {
  ref.cacheFor();
  ref.watch(currentUserIdProvider);
  return (await ref.watch(socialRepositoryProvider).requests()).getOrThrow();
});

final blockedAccountsProvider = FutureProvider.autoDispose<List<PersonSummary>>(
  (ref) async {
    ref.cacheFor();
    return (await ref.watch(socialRepositoryProvider).blocked()).getOrThrow();
  },
);

final peopleSearchProvider = FutureProvider.autoDispose.family<List<PersonSummary>, String>((ref, query) async {
  ref.cacheFor();
  if (query.trim().isEmpty) return const [];
  return (await ref.watch(socialRepositoryProvider).search(query)).getOrThrow();
});

final suggestedPeopleProvider = FutureProvider.autoDispose<List<PersonSummary>>(
  (ref) async {
    ref.cacheFor();
    return (await ref.watch(socialRepositoryProvider).suggestions()).getOrThrow();
  },
);

/// Reloads everything that shows the relationship with [userId] after a follow or block change.
void refreshRelationship(WidgetRef ref, String userId) {
  ref
    ..invalidate(profileSocialProvider(userId))
    ..invalidate(followListProvider)
    ..invalidate(followRequestsProvider)
    ..invalidate(blockedAccountsProvider)
    ..invalidate(peopleSearchProvider)
    ..invalidate(suggestedPeopleProvider);
  final me = ref.read(currentUserIdProvider);
  if (me != null) ref.invalidate(profileSocialProvider(me));
}
