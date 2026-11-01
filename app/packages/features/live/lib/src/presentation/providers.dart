import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/live_repository_impl.dart';
import '../domain/live.dart';

final liveRepositoryProvider = Provider<LiveRepository>(
  (ref) => LiveRepositoryImpl(ref.watch(supabaseClientProvider), ref.watch(apiClientProvider)),
);

/// A group's live and upcoming broadcasts; reloads when one starts, ends or is scheduled.
final groupLiveProvider = FutureProvider.autoDispose.family<GroupLive, String>((ref, groupId) async {
  ref.cacheFor();
  final repository = ref.watch(liveRepositoryProvider);
  final changes = repository.groupChanges(groupId).listen((_) => ref.invalidateSelf());
  ref.onDispose(changes.cancel);
  return (await repository.groupLive(groupId)).getOrThrow();
});

/// Live right now in the signed-in user's groups (home).
final myLiveProvider = FutureProvider.autoDispose<List<LiveBroadcast>>(
  (ref) async {
    ref.cacheFor();
    return (await ref.watch(liveRepositoryProvider).myLive()).getOrThrow();
  },
);

final liveBroadcastProvider = FutureProvider.autoDispose.family<LiveBroadcast, String>(
  (ref, id) async => (await ref.watch(liveRepositoryProvider).broadcast(id)).getOrThrow(),
);

/// Host or live.moderate holder: sees raised hands and the actions menu.
final isLiveManagerProvider = FutureProvider.autoDispose.family<bool, LiveBroadcast>((ref, b) async {
  ref.cacheFor();
  if (b.host?.id == ref.watch(currentUserIdProvider)) return true;
  final permissions = (await ref.watch(liveRepositoryProvider).myPermissions(b.group.id)).getOrThrow();
  return permissions.contains('live.moderate');
});
