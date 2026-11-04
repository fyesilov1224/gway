import '../l10n.dart';

/// Mirrors the `profiles_username_format` constraint in
/// supabase/migrations/0002_identity_profile.sql.
abstract final class UsernameRules {
  static const minLength = 3;
  static const maxLength = 30;
  static final _allowed = RegExp(r'^[a-z0-9_.]+$');

  static String normalize(String input) => input.trim().toLowerCase();

  /// Turkish error message, or null when the format is valid.
  /// Availability is checked separately against the server.
  static String? validate(String? input) {
    final name = normalize(input ?? '');
    if (name.isEmpty) return profileL10n.usernameRequired;
    if (name.length < minLength) return profileL10n.usernameMin(minLength);
    if (name.length > maxLength) return profileL10n.usernameMax(maxLength);
    if (!_allowed.hasMatch(name)) {
      return profileL10n.usernameChars;
    }
    if (name.startsWith('.') || name.endsWith('.')) {
      return profileL10n.usernameDots;
    }
    if (name.contains('..')) return profileL10n.usernameDoubleDot;
    return null;
  }
}

abstract final class ProfileRules {
  static const displayNameMaxLength = 50;
  static const bioMaxLength = 160;
  static const maxInterests = 10;

  static String? validateDisplayName(String? input) {
    final name = input?.trim() ?? '';
    if (name.isEmpty) return profileL10n.nameRequired;
    if (name.length > displayNameMaxLength) {
      return profileL10n.nameMax(displayNameMaxLength);
    }
    return null;
  }
}
