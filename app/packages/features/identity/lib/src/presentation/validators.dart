final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'E-posta adresini gir.';
  if (!_emailPattern.hasMatch(email)) return 'Geçerli bir e-posta adresi gir.';
  return null;
}

/// Mirrors supabase/config.toml: at least 8 characters with lower case,
/// upper case and digits.
String? validateNewPassword(String? value) {
  final password = value ?? '';
  if (password.length < 8) return 'Şifre en az 8 karakter olmalı.';
  if (!password.contains(RegExp('[a-z]')) ||
      !password.contains(RegExp('[A-Z]')) ||
      !password.contains(RegExp('[0-9]'))) {
    return 'Şifre büyük harf, küçük harf ve rakam içermeli.';
  }
  return null;
}

String? validatePasswordPresent(String? value) =>
    (value ?? '').isEmpty ? 'Şifreni gir.' : null;
