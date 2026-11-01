import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/messaging_repository_impl.dart';
import '../domain/messaging.dart';

final messagingRepositoryProvider = Provider<MessagingRepository>(
  (ref) => MessagingRepositoryImpl(ref.watch(supabaseClientProvider), ref.watch(apiClientProvider)),
);

/// The user's conversations and requests; reloads when a message or a read time changes.
final conversationsProvider = StreamProvider.autoDispose<List<Conversation>>((ref) async* {
  if (ref.watch(currentUserIdProvider) == null) {
    yield const [];
    return;
  }
  final repo = ref.watch(messagingRepositoryProvider);
  yield (await repo.conversations()).getOrThrow();
  await for (final _ in repo.changes()) {
    // A failed reload keeps the list that is shown.
    if (await repo.conversations() case Ok(:final value)) yield value;
  }
});

/// Conversations with unread messages, including requests (the messages icon badge).
/// Whether another person's profile shows the message button.
final canMessageProvider = FutureProvider.autoDispose.family<bool, String>(
  (ref, userId) async {
    ref.cacheFor();
    return (await ref.watch(messagingRepositoryProvider).canMessage(userId)).getOrThrow();
  },
);

final unreadConversationsProvider = Provider.autoDispose<int>(
  (ref) => ref.watch(conversationsProvider).value?.where((c) => c.unread > 0).length ?? 0,
);

/// One conversation and its newest messages, live.
final chatProvider = StreamProvider.autoDispose.family<ChatThread, String>((ref, id) async* {
  ref.watch(currentUserIdProvider);
  final repo = ref.watch(messagingRepositoryProvider);
  Future<ChatThread> load() async {
    final (conversation, messages) = (await repo.conversation(id), await repo.messages(id));
    return ChatThread(
      conversation: conversation.getOrThrow() ?? (throw const NotFoundFailure()),
      messages: messages.getOrThrow(),
    );
  }

  yield await load();
  await for (final _ in repo.changes(conversationId: id)) {
    try {
      yield await load();
    } on NotFoundFailure {
      // Removed from the group or blocked meanwhile.
      rethrow;
    } on Failure {
      // A dropped reload; the next change tries again.
    }
  }
});
