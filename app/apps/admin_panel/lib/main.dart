import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:identity/identity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = AppConfig.fromEnvironment();
  await Supabase.initialize(url: config.supabaseUrl, publishableKey: config.supabasePublishableKey);

  runApp(
    ProviderScope(
      // Repositories already return typed failures; retrying hides them.
      retry: (_, _) => null,
      overrides: [
        appConfigProvider.overrideWithValue(config),
        authRedirectUrlProvider.overrideWithValue(
          kIsWeb ? Uri.base.origin : 'com.gway.admin://auth-callback',
        ),
      ],
      child: const AdminPanelApp(),
    ),
  );
}
