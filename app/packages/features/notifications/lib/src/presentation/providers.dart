import 'package:audioplayers/audioplayers.dart';
import 'package:core/core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/firebase_push_messaging.dart';
import '../data/notifications_repository_impl.dart';
import '../domain/notification.dart';

final notificationsRepositoryProvider =
    Provider<NotificationsRepository>((ref) => NotificationsRepositoryImpl(ref.watch(supabaseClientProvider)));

/// Null where the app did not start Firebase (web, desktop, tests).
final pushMessagingProvider =
    Provider<PushMessaging?>((ref) => Firebase.apps.isEmpty ? null : FirebasePushMessaging(FirebaseMessaging.instance));

/// Notifications as they arrive; one Realtime channel shared by the badge and the live alert.
final notificationArrivalsProvider = StreamProvider.autoDispose<NotificationArrival>((ref) {
  if (ref.watch(currentUserIdProvider) == null) return const Stream.empty();
  return ref.watch(notificationsRepositoryProvider).arrivals();
});

/// Unread count for the navigation badge; recounts when a notification arrives.
final unreadNotificationsProvider = FutureProvider.autoDispose<int>((ref) async {
  ref.cacheFor();
  if (ref.watch(currentUserIdProvider) == null) return 0;
  ref.watch(notificationArrivalsProvider);
  return switch (await ref.watch(notificationsRepositoryProvider).unreadCount()) {
    Ok(:final value) => value,
    Err() => 0,
  };
});

/// Plays the short live alert; quiet in silent mode and mixed over other audio, such as a live room.
final liveAlertSoundProvider = Provider<Future<void> Function()>((ref) {
  final player = AudioPlayer()..audioCache = AudioCache(prefix: 'packages/notifications/assets/');
  ref.onDispose(player.dispose);
  final context = AudioContextConfig(respectSilence: true, focus: AudioContextConfigFocus.mixWithOthers).build();
  return () async {
    await player.setAudioContext(context);
    await player.play(AssetSource('live_alert.wav'));
  };
});

final notificationPreferencesProvider = FutureProvider.autoDispose<NotificationPreferences>(
  (ref) async {
    ref.cacheFor();
    return (await ref.watch(notificationsRepositoryProvider).preferences()).getOrThrow();
  },
);

class NotificationPage {
  const NotificationPage(this.items, {required this.hasMore, this.loadingMore = false});

  final List<AppNotification> items;
  final bool hasMore;
  final bool loadingMore;
}

final notificationListProvider = AsyncNotifierProvider.autoDispose<NotificationList, NotificationPage>(NotificationList.new);

class NotificationList extends AsyncNotifier<NotificationPage> {
  @override
  Future<NotificationPage> build() async {
    // Pages loaded with loadMore would be lost to a background refresh; pull to refresh reloads.
    ref.cacheFor(staleAfter: screenCacheKeep);
    final items = (await ref.watch(notificationsRepositoryProvider).list()).getOrThrow();
    return NotificationPage(items, hasMore: items.length >= NotificationsRepositoryImpl.pageSize);
  }

  Future<void> loadMore() async {
    final page = state.value;
    if (page == null || !page.hasMore || page.loadingMore || page.items.isEmpty) return;
    state = AsyncData(NotificationPage(page.items, hasMore: true, loadingMore: true));
    final result = await ref.read(notificationsRepositoryProvider).list(beforeId: page.items.last.id);
    state = AsyncData(switch (result) {
      Ok(:final value) =>
        NotificationPage([...page.items, ...value], hasMore: value.length >= NotificationsRepositoryImpl.pageSize),
      Err() => NotificationPage(page.items, hasMore: true),
    });
  }

  Future<Result<void>> delete(AppNotification n) async {
    final page = state.value;
    if (page != null) state = AsyncData(NotificationPage([...page.items.where((i) => i.id != n.id)], hasMore: page.hasMore));
    final result = await ref.read(notificationsRepositoryProvider).delete(n.id);
    if (result is Err) ref.invalidateSelf();
    return result;
  }
}
