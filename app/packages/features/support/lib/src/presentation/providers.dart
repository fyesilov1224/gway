import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/support_repository_impl.dart';
import '../domain/support.dart';

final supportRepositoryProvider = Provider<SupportRepository>(
  (ref) => SupportRepositoryImpl(ref.watch(supabaseClientProvider)),
);

final myTicketsProvider = FutureProvider.autoDispose<List<SupportTicket>>((ref) async {
  ref.watch(currentUserIdProvider);
  return (await ref.watch(supportRepositoryProvider).myTickets()).getOrThrow();
});

/// Tickets with a team reply the user has not opened yet (settings badge).
final unreadSupportCountProvider = Provider.autoDispose<int>(
  (ref) => ref.watch(myTicketsProvider).value?.where((t) => t.hasUnreadReply).length ?? 0,
);

final supportThreadProvider = FutureProvider.autoDispose.family<SupportThread, String>(
  (ref, id) async => (await ref.watch(supportRepositoryProvider).thread(id)).getOrThrow(),
);

final managedGroupsProvider = FutureProvider.autoDispose<List<ManagedGroup>>(
  (ref) async => (await ref.watch(supportRepositoryProvider).managedGroups()).getOrThrow(),
);

final attachmentUrlProvider = FutureProvider.autoDispose.family<String, String>(
  (ref, path) async => (await ref.watch(supportRepositoryProvider).attachmentUrl(path)).getOrThrow(),
);
