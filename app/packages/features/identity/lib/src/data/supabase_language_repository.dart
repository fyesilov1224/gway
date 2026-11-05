import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/language.dart';

/// The person's own row and account (a simple write of their own data; docs/ARCHITECTURE.md §2).
class SupabaseLanguageRepository implements ServerLanguageRepository {
  SupabaseLanguageRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<Result<void>> save(AppLanguage language) async {
    final user = _client.auth.currentUser;
    if (user == null) return const Err(UnauthorizedFailure());
    try {
      // Before onboarding there is no profile yet; the profile is then created in this language.
      await _client.from('profiles').update({'locale': language.code}).eq('id', user.id);
      if (user.userMetadata?['locale'] != language.code) {
        await _client.auth.updateUser(UserAttributes(data: {'locale': language.code}));
      }
      return const Ok(null);
    } on Object catch (e) {
      return Err(failureFromSupabase(e));
    }
  }
}
