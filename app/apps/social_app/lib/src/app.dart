import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:identity/identity.dart';
import 'package:live/live.dart';
import 'package:messaging/messaging.dart';
import 'package:notifications/notifications.dart';

import 'router.dart';

class SocialApp extends ConsumerWidget {
  const SocialApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    // The ringing push and the in-app listener can both ask; one call screen is enough.
    void openCall(String id) {
      if (router.routerDelegate.currentConfiguration.uri.path != MessagingRoutes.call(id)) {
        router.push(MessagingRoutes.call(id));
      }
    }

    return MaterialApp.router(
      title: 'GWAY',
      debugShowCheckedModeBanner: false,
      theme: GwTheme.light(),
      routerConfig: router,
      builder: (_, child) => PushNotifications(
        openLive: (liveId) => router.push(LiveRoutes.room(liveId)),
        openCall: openCall,
        openConversation: (id) => router.push(MessagingRoutes.chat(id)),
        openNotifications: () => router.push(NotificationRoutes.list),
        child: LiveNotificationAlerts(
          openLive: (liveId) => router.push(LiveRoutes.room(liveId)),
          child: IncomingCallAlerts(
            openCall: openCall,
            child: SecurityHeartbeat(
              navigatorContext: () => router.routerDelegate.navigatorKey.currentContext,
              child: child!,
            ),
          ),
        ),
      ),
    );
  }
}
