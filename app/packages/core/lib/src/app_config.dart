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
    String shareUrl = '',
    this.turnstileSiteKey = '',
  }) : shareUrl = shareUrl == '' ? apiUrl : shareUrl;

  factory AppConfig.fromEnvironment() {
    const config = AppConfig(
      supabaseUrl: String.fromEnvironment('SUPABASE_URL'),
      supabasePublishableKey: String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
      apiUrl: String.fromEnvironment('API_URL'),
      shareUrl: String.fromEnvironment('SHARE_URL'),
      turnstileSiteKey: String.fromEnvironment('TURNSTILE_SITE_KEY'),
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

  /// Where share links point (`<shareUrl>/s/...`): the web app's address in production, where the proxy hands
  /// `/s/*` to the API; the API itself otherwise (docs/ARCHITECTURE.md §3b, Paylaşım sayfaları).
  final String shareUrl;

  /// Cloudflare Turnstile's site key for the bot check on sign-up, sign-in and password reset (docs/ARCHITECTURE.md
  /// §3k). Empty: no check is shown and no token is sent (a local Supabase without CAPTCHA).
  final String turnstileSiteKey;
}
