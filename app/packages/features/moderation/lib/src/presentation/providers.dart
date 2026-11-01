import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/moderation_repository_impl.dart';
import '../domain/moderation.dart';

final moderationRepositoryProvider = Provider<ModerationRepository>(
  (ref) => ModerationRepositoryImpl(ref.watch(supabaseClientProvider), ref.watch(apiClientProvider)),
);

/// Null when the user may not review the group's reports.
final groupModerationProvider = FutureProvider.autoDispose.family<GroupModeration?, String>(
  (ref, groupId) async {
    ref.cacheFor();
    return (await ref.watch(moderationRepositoryProvider).groupModeration(groupId)).getOrThrow();
  },
);

final mySanctionsProvider = FutureProvider.autoDispose<List<MySanction>>(
  (ref) async {
    ref.cacheFor();
    return (await ref.watch(moderationRepositoryProvider).mySanctions()).getOrThrow();
  },
);
