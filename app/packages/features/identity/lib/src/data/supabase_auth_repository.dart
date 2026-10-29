import 'dart:convert';

import 'package:core/core.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/auth.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client, {required this.redirectUrl, required this.supabaseUrl, required this.publishableKey});

  final SupabaseClient _client;

  /// For the auth server's public settings (`/auth/v1/settings`).
  final String supabaseUrl;
  final String publishableKey;

  /// Where e-mail links and OAuth return (deep link on mobile, origin on web).
  final String redirectUrl;

  GoTrueClient get _auth => _client.auth;

  @override
  Future<Result<void>> signIn({required String email, required String password}) =>
      _run(() => _auth.signInWithPassword(email: email.trim(), password: password));

  @override
  Future<Result<void>> signUp({required String email, required String password}) =>
      _run(
        () => _auth.signUp(
          email: email.trim(),
          password: password,
          emailRedirectTo: redirectUrl,
        ),
      );

  @override
  Future<Result<void>> resendVerification(String email) => _run(
        () => _auth.resend(
          type: OtpType.signup,
          email: email.trim(),
          emailRedirectTo: redirectUrl,
        ),
      );

  @override
  Future<Result<void>> signInWith(SocialProvider provider) => _run(
        () => _auth.signInWithOAuth(
          switch (provider) {
            SocialProvider.google => OAuthProvider.google,
            SocialProvider.apple => OAuthProvider.apple,
          },
          redirectTo: redirectUrl,
        ),
      );

  @override
  Future<Set<SocialProvider>> socialProviders() async {
    try {
      final response = await http
          .get(Uri.parse('$supabaseUrl/auth/v1/settings'), headers: {'apikey': publishableKey})
          .timeout(const Duration(seconds: 10));
      final external = (jsonDecode(response.body) as Map)['external'] as Map;
      return {
        if (external['google'] == true) SocialProvider.google,
        if (external['apple'] == true) SocialProvider.apple,
      };
    } on Object {
      // Unknown: offer both rather than none; a closed one then explains itself.
      return SocialProvider.values.toSet();
    }
  }

  @override
  Future<Result<void>> sendPasswordReset(String email) => _run(
        () => _auth.resetPasswordForEmail(email.trim(), redirectTo: redirectUrl),
      );

  @override
  Future<Result<void>> updatePassword(String password) =>
      _run(() => _auth.updateUser(UserAttributes(password: password)));

  @override
  Future<Result<void>> signOut() => _run(_auth.signOut);

  Future<Result<void>> _run(Future<Object?> Function() action) async {
    try {
      await action();
      return const Ok(null);
    } on Object catch (e) {
      return Err(failureFromAuth(e));
    }
  }
}

/// Supabase Auth error codes → safe Turkish messages.
Failure failureFromAuth(Object error) {
  if (error is! AuthException) return failureFromSupabase(error);
  RuleFailure rule(String message) => RuleFailure('auth.${error.code}', message);
  return switch (error.code) {
    'invalid_credentials' => rule('E-posta adresi veya şifre hatalı.'),
    'email_not_confirmed' =>
      rule('E-posta adresini henüz doğrulamadın. Gelen kutunu kontrol et.'),
    'user_already_exists' || 'email_exists' =>
      rule('Bu e-posta adresiyle zaten bir hesap var. Giriş yapmayı dene.'),
    'weak_password' => rule(
        'Şifre en az 8 karakter olmalı ve büyük harf, küçük harf ve rakam içermeli.',
      ),
    'same_password' => rule('Yeni şifren eskisinden farklı olmalı.'),
    'email_address_invalid' => rule('Geçerli bir e-posta adresi gir.'),
    'user_banned' => rule('Hesabın askıya alındığı için giriş yapamazsın.'),
    'over_email_send_rate_limit' || 'over_request_rate_limit' =>
      const RateLimitedFailure(),
    'provider_disabled' || 'email_provider_disabled' =>
      rule('Bu giriş yöntemi şu anda kullanılamıyor.'),
    _ => failureFromSupabase(error),
  };
}
