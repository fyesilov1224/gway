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
    // The ringing push, the in-app listener and the phone's call screen can all ask; one call screen is enough.
    // An answer from the phone's screen replaces a screen that is still ringing.
    void openCall(String id, {bool answer = false}) {
      final here = router.routerDelegate.currentConfiguration.uri;
      if (here.path != MessagingRoutes.call(id)) {
        router.push(MessagingRoutes.call(id, answer: answer));
      } else if (answer && here.queryParameters['answer'] != '1') {
        router.pushReplacement(MessagingRoutes.call(id, answer: true));
      }
    }

    // Opening the room the user is already looking at does nothing; a room left in the background is reopened.
    void openLive(String id) {
      if (router.routerDelegate.currentConfiguration.uri.path != LiveRoutes.room(id)) router.push(LiveRoutes.room(id));
    }

    return MaterialApp.router(
      title: 'GWAY',
      debugShowCheckedModeBanner: false,
      theme: GwTheme.light(),
      routerConfig: router,
      builder: (_, child) => PushNotifications(
        openLive: openLive,
        openCall: openCall,
        openConversation: (id) => router.push(MessagingRoutes.chat(id)),
        openNotifications: () => router.push(NotificationRoutes.list),
        isConversationOpen: (id) => router.routerDelegate.currentConfiguration.uri.path == MessagingRoutes.chat(id),
        child: LiveNotificationAlerts(
          openLive: openLive,
          child: NativeCallBridge(
            openCall: openCall,
            child: IncomingCallAlerts(
              openCall: openCall,
              child: SecurityHeartbeat(
                navigatorContext: () => router.routerDelegate.navigatorKey.currentContext,
                child: PresenceBeacon(
                  child: LiveOngoingBar(
                    routeChanges: router.routerDelegate,
                    currentPath: () => router.routerDelegate.currentConfiguration.uri.path,
                    openLive: openLive,
                    child: child!,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
