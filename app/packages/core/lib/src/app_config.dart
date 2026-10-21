import 'package:flutter/foundation.dart';

/// Build-time configuration passed with `--dart-define`.
///
/// Only the public (publishable) Supabase key belongs here. The
/// service role key never reaches the client.
@immutable
class AppConfig {
  const AppConfig({
    required this.supabaseUrl,
    required this.supabasePublishableKey,
    required this.apiUrl,
  });

  factory AppConfig.fromEnvironment() {
    const config = AppConfig(
      supabaseUrl: String.fromEnvironment('SUPABASE_URL'),
      supabasePublishableKey: String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
      apiUrl: String.fromEnvironment('API_URL'),
    );
    final missing = [
      if (config.supabaseUrl.isEmpty) 'SUPABASE_URL',
      if (config.supabasePublishableKey.isEmpty) 'SUPABASE_PUBLISHABLE_KEY',
      if (config.apiUrl.isEmpty) 'API_URL',
    ];
    if (missing.isNotEmpty) {
      throw StateError(
        'Missing --dart-define values: ${missing.join(', ')}. '
        'See docs/ARCHITECTURE.md §4.',
      );
    }
    return config;
  }

  final String supabaseUrl;
  final String supabasePublishableKey;
  final String apiUrl;
}
