import 'dart:async';

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
  // A failed reload keeps the list that is shown.
  yield* _reloads(ref, repo.changes(), () async => switch (await repo.conversations()) {
        Ok(:final value) => value,
        Err() => null,
      });
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
  // Side by side: one round trip instead of two.
  Future<ChatThread> load() async {
    final (conversation, messages) = await (repo.conversation(id), repo.messages(id)).wait;
    return ChatThread(
      conversation: conversation.getOrThrow() ?? (throw const NotFoundFailure()),
      messages: messages.getOrThrow(),
    );
  }

  yield await load();
  yield* _reloads(ref, repo.changes(conversationId: id), () async {
    try {
      return await load();
    } on NotFoundFailure {
      // Removed from the group or blocked meanwhile.
      rethrow;
    } on Failure {
      // A dropped reload; the next change tries again.
      return null;
    }
  });
});

/// Loads again after a change. Changes that arrive while a reload runs cause one more reload, not one each: a sent
/// message changes the message and the read time at once. Null from [load] keeps what is shown.
Stream<T> _reloads<T>(Ref ref, Stream<void> changes, Future<T?> Function() load) async* {
  var dirty = false;
  Completer<void>? wake;
  void signal() {
    final c = wake;
    wake = null;
    c?.complete();
  }

  final subscription = changes.listen((_) {
    dirty = true;
    signal();
  });
  ref.onDispose(() {
    unawaited(subscription.cancel());
    signal();
  });
  while (ref.mounted) {
    if (!dirty) {
      final c = wake = Completer<void>();
      await c.future;
      if (!ref.mounted) return;
    }
    dirty = false;
    if (await load() case final value?) yield value;
  }
}

/// A message the user sent that the chat does not show from the server yet (docs/ARCHITECTURE.md §3f, Anında
/// gönderim): it appears the moment Gönder is tapped.
class PendingMessage {
  const PendingMessage({required this.localId, required this.body, required this.hasImage, required this.createdAt, this.id});

  final int localId;
  final String body;
  final bool hasImage;
  final DateTime createdAt;

  /// The server's id once it accepted the message; the pending bubble goes when the chat shows that id.
  final String? id;
}

final pendingMessagesProvider =
    NotifierProvider.autoDispose.family<PendingMessages, List<PendingMessage>, String>(PendingMessages.new);

class PendingMessages extends Notifier<List<PendingMessage>> {
  PendingMessages(this.conversationId);

  final String conversationId;
  int _next = 0;

  @override
  List<PendingMessage> build() => const [];

  int add(String body, {required bool hasImage}) {
    final localId = _next++;
    state = [...state, PendingMessage(localId: localId, body: body, hasImage: hasImage, createdAt: DateTime.now())];
    return localId;
  }

  void sent(int localId, String id) => state = [
        for (final p in state)
          p.localId == localId
              ? PendingMessage(localId: localId, body: p.body, hasImage: p.hasImage, createdAt: p.createdAt, id: id)
              : p,
      ];

  void remove(int localId) => state = [for (final p in state) if (p.localId != localId) p];
}
