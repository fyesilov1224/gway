import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/notifications_repository_impl.dart';
import '../domain/notification.dart';

final notificationsRepositoryProvider =
    Provider<NotificationsRepository>((ref) => NotificationsRepositoryImpl(ref.watch(supabaseClientProvider)));

/// Unread count for the navigation badge; recounts when a notification arrives.
final unreadNotificationsProvider = StreamProvider.autoDispose<int>((ref) async* {
  if (ref.watch(currentUserIdProvider) == null) {
    yield 0;
    return;
  }
  final repo = ref.watch(notificationsRepositoryProvider);
  Future<int> count() async => switch (await repo.unreadCount()) {
        Ok(:final value) => value,
        Err() => 0,
      };
  yield await count();
  await for (final _ in repo.arrivals()) {
    yield await count();
  }
});

final notificationPreferencesProvider = FutureProvider.autoDispose<NotificationPreferences>(
  (ref) async => (await ref.watch(notificationsRepositoryProvider).preferences()).getOrThrow(),
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
    ref.watch(currentUserIdProvider);
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
