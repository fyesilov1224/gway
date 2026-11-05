import 'package:core/core.dart';
import 'package:feed/feed.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:identity/identity.dart';
import 'package:messaging/messaging.dart';
import 'package:moderation/moderation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';
import 'src/app.dart';
import 'src/feed_pages.dart';

/// Pushes while the app is closed or in the background (a separate isolate): a ringing call opens the phone's own
/// incoming call screen (docs/ARCHITECTURE.md §8c, Akış). Other pushes are shown by the system.
@pragma('vm:entry-point')
Future<void> _onBackgroundPush(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // The phone's call screen speaks the chosen language.
  await restoreAppLanguage();
  await handleCallPush(message.data);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = AppConfig.fromEnvironment();
  await Supabase.initialize(url: config.supabaseUrl, publishableKey: config.supabasePublishableKey);
  final languagePreferences = await openLanguagePreferences();
  // Push runs on phones only (docs/ARCHITECTURE.md §3c, Push); web keys are not set up yet.
  if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseMessaging.onBackgroundMessage(_onBackgroundPush);
    await registerNativeDeclineInBackground();
  }

  runApp(
    ProviderScope(
      // Repositories already return typed failures; retrying hides them.
      retry: (_, _) => null,
      overrides: [
        appConfigProvider.overrideWithValue(config),
        languagePreferencesProvider.overrideWithValue(languagePreferences),
        feedLinksProvider.overrideWithValue(feedLinks),
        reportLauncherProvider.overrideWithValue(showReportSheet),
        packageOpenerProvider.overrideWithValue((context, slug) => context.push('/matching/packages/$slug')),
        authRedirectUrlProvider.overrideWithValue(
          kIsWeb ? Uri.base.origin : 'com.gway.app://auth-callback',
        ),
      ],
      child: const SocialApp(),
    ),
  );
}
