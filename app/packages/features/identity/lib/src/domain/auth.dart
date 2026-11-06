import 'package:core/core.dart';

enum SocialProvider { google, apple }

/// [captchaToken]: Cloudflare Turnstile's one-time token for the bot check, required by the auth server on sign-up,
/// e-mail sign-in, password reset and resending the verification e-mail (docs/ARCHITECTURE.md §3k). Null when the
/// check is off (no site key).
abstract interface class AuthRepository {
  Future<Result<void>> signIn({required String email, required String password, String? captchaToken});

  /// Sends a verification e-mail; the user signs in after confirming it.
  Future<Result<void>> signUp({required String email, required String password, String? captchaToken});

  Future<Result<void>> resendVerification(String email, {String? captchaToken});

  /// Opens the provider's sign-in page; the session arrives via deep link.
  Future<Result<void>> signInWith(SocialProvider provider);

  /// The providers the auth server has switched on, so the screen offers no button that cannot work
  /// (e.g. Apple before its keys exist, or Google on a local server).
  Future<Set<SocialProvider>> socialProviders();

  Future<Result<void>> sendPasswordReset(String email, {String? captchaToken});

  Future<Result<void>> updatePassword(String password);

  Future<Result<void>> signOut();
}
