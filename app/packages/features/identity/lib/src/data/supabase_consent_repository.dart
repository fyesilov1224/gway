import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/legal.dart';

class SupabaseConsentRepository implements ConsentRepository {
  SupabaseConsentRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<Result<List<LegalDocument>>> pending() => _load(
        () => _client.rpc<List<dynamic>>('pending_legal_documents'),
      );

  @override
  Future<Result<List<LegalDocument>>> latest() => _load(() async {
        final rows = await _client
            .from('legal_documents')
            .select('kind, version, title, body')
            .order('version', ascending: false);
        // Keep the highest published version of each kind.
        final seen = <String>{};
        return [
          for (final row in rows)
            if (seen.add(row['kind'] as String)) row,
        ];
      });

  @override
  Future<Result<void>> accept(List<LegalDocument> documents) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const Err(UnauthorizedFailure());
    try {
      await _client.from('consents').insert([
        for (final d in documents)
          {'user_id': userId, 'kind': d.kind.code, 'version': d.version},
      ]);
      return const Ok(null);
    } on PostgrestException catch (e) {
      // Already accepted (e.g. double tap): the goal is reached.
      if (e.code == '23505') return const Ok(null);
      return Err(failureFromSupabase(e));
    } on Object catch (e) {
      return Err(failureFromSupabase(e));
    }
  }

  /// The app-language translations of [docs]; Turkish needs none.
  Future<List<LegalDocument>> _withTranslations(List<LegalDocument> docs) async {
    final language = currentAppLanguage;
    if (language == AppLanguage.tr || docs.isEmpty) return docs;
    final rows = await _client
        .from('legal_document_translations')
        .select('kind, version, title, body')
        .eq('language', language.code)
        .inFilter('kind', [for (final d in docs) d.kind.code]);
    final byKey = {
      for (final r in rows) (r['kind'] as String, r['version'] as int): LegalTranslation(title: r['title'] as String, body: r['body'] as String),
    };
    return [for (final d in docs) d.withTranslation(byKey[(d.kind.code, d.version)])];
  }

  Future<Result<List<LegalDocument>>> _load(
    Future<List<dynamic>> Function() query,
  ) async {
    try {
      final rows = await query();
      final docs = [
        for (final row in rows.cast<Map<String, dynamic>>())
          LegalDocument(
            kind: LegalKind.fromCode(row['kind'] as String),
            version: row['version'] as int,
            title: row['title'] as String,
            body: row['body'] as String,
          ),
      ]..sort((a, b) => a.kind.index.compareTo(b.kind.index));
      return Ok(await _withTranslations(docs));
    } on Object catch (e) {
      return Err(failureFromSupabase(e));
    }
  }
}
