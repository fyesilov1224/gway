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
    if (name.isEmpty) return 'Bir kullanıcı adı seç.';
    if (name.length < minLength) return 'Kullanıcı adı en az $minLength karakter olmalı.';
    if (name.length > maxLength) return 'Kullanıcı adı en fazla $maxLength karakter olabilir.';
    if (!_allowed.hasMatch(name)) {
      return 'Yalnızca a-z, 0-9, alt çizgi (_) ve nokta (.) kullanabilirsin.';
    }
    if (name.startsWith('.') || name.endsWith('.')) {
      return 'Kullanıcı adı nokta ile başlayamaz veya bitemez.';
    }
    if (name.contains('..')) return 'Art arda iki nokta kullanılamaz.';
    return null;
  }
}

abstract final class ProfileRules {
  static const displayNameMaxLength = 50;
  static const bioMaxLength = 160;
  static const maxInterests = 10;

  static String? validateDisplayName(String? input) {
    final name = input?.trim() ?? '';
    if (name.isEmpty) return 'Adını gir.';
    if (name.length > displayNameMaxLength) {
      return 'Ad en fazla $displayNameMaxLength karakter olabilir.';
    }
    return null;
  }
}
