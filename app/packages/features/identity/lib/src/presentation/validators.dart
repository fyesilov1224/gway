import '../l10n.dart';

final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return identityL10n.enterEmail;
  if (!_emailPattern.hasMatch(email)) return identityL10n.authInvalidEmail;
  return null;
}

/// Mirrors supabase/config.toml: at least 8 characters with lower case,
/// upper case and digits.
String? validateNewPassword(String? value) {
  final password = value ?? '';
  if (password.length < 8) return identityL10n.passwordMin8;
  if (!password.contains(RegExp('[a-z]')) ||
      !password.contains(RegExp('[A-Z]')) ||
      !password.contains(RegExp('[0-9]'))) {
    return identityL10n.passwordMix;
  }
  return null;
}

String? validatePasswordPresent(String? value) =>
    (value ?? '').isEmpty ? identityL10n.enterPassword : null;
