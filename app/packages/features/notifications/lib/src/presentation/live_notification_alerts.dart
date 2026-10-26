import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/notification.dart';
import 'providers.dart';

/// While the app is open, a broadcast scheduled or started in one of the user's groups
/// rings the live alert and shows a strip that opens it (docs/ARCHITECTURE.md §3c, Sesli uyarı).
class LiveNotificationAlerts extends ConsumerWidget {
  const LiveNotificationAlerts({super.key, required this.openLive, required this.child});

  /// The live room; the app supplies the route.
  final void Function(String liveId) openLive;

  final Widget child;

  Future<void> _alert(BuildContext context, WidgetRef ref, NotificationArrival arrival, String liveId) async {
    final repo = ref.read(notificationsRepositoryProvider);
    // A sound that cannot play must not hide the strip.
    unawaited(ref.read(liveAlertSoundProvider)().catchError((Object _) {}));
    final items = switch (await repo.list()) {
      Ok(:final value) => value,
      Err() => const <AppNotification>[],
    };
    final n = items.where((i) => i.id == arrival.id).firstOrNull;
    if (n == null || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${n.lead} ${n.action}'),
      duration: const Duration(seconds: 8),
      action: SnackBarAction(
        label: n.type == NotificationType.liveStarted ? 'Katıl' : 'Gör',
        onPressed: () => openLive(liveId),
      ),
    ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(notificationArrivalsProvider, (_, next) {
      if (next case AsyncData(value: final arrival) when arrival.type?.isLive ?? false) {
        if (arrival.liveId case final liveId?) _alert(context, ref, arrival, liveId);
      }
    });
    return child;
  }
}
