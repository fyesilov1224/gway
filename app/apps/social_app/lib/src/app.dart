import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:identity/identity.dart';
import 'package:live/live.dart';
import 'package:notifications/notifications.dart';

import 'router.dart';

class SocialApp extends ConsumerWidget {
  const SocialApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'GWAY',
      debugShowCheckedModeBanner: false,
      theme: GwTheme.light(),
      routerConfig: router,
      builder: (_, child) => PushNotifications(
        openLive: (liveId) => router.push(LiveRoutes.room(liveId)),
        openNotifications: () => router.push(NotificationRoutes.list),
        child: LiveNotificationAlerts(
          openLive: (liveId) => router.push(LiveRoutes.room(liveId)),
          child: SecurityHeartbeat(
            navigatorContext: () => router.routerDelegate.navigatorKey.currentContext,
            child: child!,
          ),
        ),
      ),
    );
  }
}
