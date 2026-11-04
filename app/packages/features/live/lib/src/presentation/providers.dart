import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/live_repository_impl.dart';
import '../domain/live.dart';
import 'live_session.dart';

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

/// The broadcast the user is in. The connection belongs to the app, not to the room screen:
/// going back or opening other pages keeps the user in the room until they leave (docs/ARCHITECTURE.md §8).
final activeLiveProvider = NotifierProvider<ActiveLive, LiveSession?>(ActiveLive.new);

class ActiveLive extends Notifier<LiveSession?> {
  LiveSession? _session;

  @override
  LiveSession? build() {
    // Signing out or switching accounts leaves the room.
    ref.watch(currentUserIdProvider);
    ref.onDispose(() {
      final session = _session;
      _session = null;
      if (session != null) _dispose(session);
    });
    return null;
  }

  /// The session for [broadcastId]: the running one, or a new connection (leaving any other room).
  LiveSession join(String broadcastId) {
    final current = _session;
    if (current != null && current.broadcastId == broadcastId && current.isActive) return current;
    if (current != null) _dispose(current);
    final storage = ref.read(supabaseClientProvider).storage;
    final session = LiveSession(
      repository: ref.read(liveRepositoryProvider),
      broadcastId: broadcastId,
      avatarUrl: (path) => storage.from('avatars').getPublicUrl(path),
    );
    session.addListener(() => _onChange(session));
    _session = session;
    state = session;
    unawaited(session.connect());
    return session;
  }

  /// Leaves the room on purpose.
  Future<void> leave() async {
    final session = _session;
    if (session == null) return;
    _session = null;
    state = null;
    await session.leave();
    _dispose(session);
  }

  /// Drops a session that could not connect once its screen is closed.
  void releaseIfInactive(LiveSession session) {
    if (_session == session && !session.isActive) _release(session);
  }

  // The room ended or the user was removed: the screen still shows why, the app forgets the session.
  void _onChange(LiveSession session) {
    if (session.state == LiveSessionState.ended || session.state == LiveSessionState.kicked) {
      scheduleMicrotask(() => _release(session));
    }
  }

  void _release(LiveSession session) {
    if (_session != session) return;
    _session = null;
    state = null;
    _dispose(session);
  }

  // Never dispose while the session is notifying its listeners.
  void _dispose(LiveSession session) => scheduleMicrotask(session.dispose);
}
