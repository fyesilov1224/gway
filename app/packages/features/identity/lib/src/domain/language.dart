import 'package:core/core.dart';

/// The person's language on the server (docs/ARCHITECTURE.md §11, Sunucu): `profiles.locale` for push texts and
/// server messages, the account's metadata for the sign-in e-mails.
abstract interface class ServerLanguageRepository {
  Future<Result<void>> save(AppLanguage language);
}
