import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:identity/identity.dart';
import 'package:live/live.dart';
import 'package:messaging/messaging.dart';
import 'package:notifications/notifications.dart';

import 'l10n.dart';
import 'router.dart';

class SocialApp extends ConsumerWidget {
  const SocialApp({super.key});

  /// When each live room was last opened from a notice.
  static final _liveOpened = <String, DateTime>{};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final language = ref.watch(appLanguageProvider);
    ref.listen(appLanguageProvider, (_, _) => WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) rebuildAll(context);
        }));
    // The ringing push, the in-app listener and the phone's call screen can all ask; one call screen is enough.
    // An answer from the phone's screen goes to a screen that is already open or opening (docs/ARCHITECTURE.md §8c).
    void openCall(String id, {bool answer = false}) {
      if (ref.read(callScreensProvider).claim(id, answer: answer)) router.push(MessagingRoutes.call(id, answer: answer));
    }

    // Opening the room the user is already looking at does nothing; a room left in the background is reopened.
    // The router learns about a pushed room only after a frame, so a second ask (a push tap and the in-app strip) a
    // moment later is dropped too: one room screen, not two stacked.
    void openLive(String id) {
      final now = DateTime.now();
      final last = _liveOpened[id];
      if (last != null && now.difference(last) < const Duration(seconds: 2)) return;
      if (router.routerDelegate.currentConfiguration.uri.path == LiveRoutes.room(id)) return;
      _liveOpened[id] = now;
      router.push(LiveRoutes.room(id));
    }

    return MaterialApp.router(
      title: 'GWAY',
      debugShowCheckedModeBanner: false,
      locale: language.locale,
      supportedLocales: AppLanguage.locales,
      localizationsDelegates: appLocalizationsDelegates,
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
                    child: LanguageSync(child: child!),
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
