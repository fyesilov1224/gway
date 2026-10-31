import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/age.dart';

class SupabaseBirthDateRepository implements BirthDateRepository {
  SupabaseBirthDateRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<Result<DateTime?>> mine() async {
    try {
      final row = await _client.from('birth_dates').select('birth_date').maybeSingle();
      return Ok(row == null ? null : DateTime.parse(row['birth_date'] as String));
    } on Object catch (e) {
      return Err(failureFromSupabase(e));
    }
  }

  @override
  Future<Result<void>> save(DateTime birthDate) async {
    final date = '${birthDate.year.toString().padLeft(4, '0')}-'
        '${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}';
    try {
      await _client.from('birth_dates').insert({'birth_date': date});
      return const Ok(null);
    } on PostgrestException catch (e) {
      // Already given (e.g. a double tap): the goal is reached.
      if (e.code == '23505') return const Ok(null);
      if (e.message.contains('birth_date_under_18')) {
        return const Err(RuleFailure('birth_date_under_18', 'GWAY\'i kullanmak için en az 18 yaşında olmalısın.'));
      }
      return Err(failureFromSupabase(e));
    } on Object catch (e) {
      return Err(failureFromSupabase(e));
    }
  }
}
