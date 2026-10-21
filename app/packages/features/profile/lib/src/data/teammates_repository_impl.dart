import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/social.dart';
import '../domain/teammates.dart';

/// Preferences are the user's own row (RLS); requests and pairs go through the C# API (docs/ARCHITECTURE.md §3c).
class TeammatesRepositoryImpl implements TeammatesRepository {
  TeammatesRepositoryImpl(this._client, this._api);

  final SupabaseClient _client;
  final ApiClient _api;

  Future<Result<T>> _read<T>(Future<T> Function() query) async {
    try {
      return Ok(await query());
    } on Failure catch (f) {
      return Err(f);
    } on Object catch (e) {
      return Err(failureFromSupabase(e));
    }
  }

  String _me() => _client.auth.currentUser?.id ?? (throw const UnauthorizedFailure());

  PersonSummary _person(Map<String, dynamic> r) => PersonSummary(
        id: r['id'] as String,
        username: r['username'] as String,
        displayName: r['display_name'] as String,
        avatarUrl: r['avatar_path'] is String ? _client.storage.from('avatars').getPublicUrl(r['avatar_path'] as String) : null,
      );

  TeammateRequest _request(Map<String, dynamic> r) => TeammateRequest(
        person: _person(r),
        message: r['message'] as String? ?? '',
        createdAt: DateTime.parse(r['created_at'] as String).toLocal(),
      );

  static List<String> _strings(Object? v) => [if (v is List) for (final s in v) s as String];

  @override
  Future<Result<TeammatePreferences>> preferences() => _read(() async {
        final r = await _client.from('teammate_preferences').select().eq('user_id', _me()).maybeSingle();
        if (r == null) return const TeammatePreferences();
        return TeammatePreferences(
          looking: r['looking'] as bool,
          level: TeammateLevel.parse(r['level']),
          availability: TeammateSlot.parseAll(r['availability']).toSet(),
          province: (r['province'] as num?)?.toInt(),
          note: r['note'] as String? ?? '',
        );
      });

  @override
  Future<Result<void>> savePreferences(TeammatePreferences p) => _read(() async {
        await _client.from('teammate_preferences').upsert({
          'user_id': _me(),
          'looking': p.looking,
          'level': p.level?.key,
          'availability': [for (final s in TeammateSlot.values) if (p.availability.contains(s)) s.key],
          'province': p.province,
          'note': p.note.trim(),
        });
      });

  @override
  Future<Result<TeammateStatus?>> status(String userId) => _read(() async {
        final r = await _client.rpc<dynamic>('teammate_status', params: {'target': userId});
        if (r is! Map) return null;
        return TeammateStatus(
          looking: r['looking'] as bool,
          level: TeammateLevel.parse(r['level']),
          relation: TeammateRelation.values.byName(r['relation'] as String),
        );
      });

  @override
  Future<Result<List<TeammateSuggestion>>> suggestions() => _read(() async {
        final rows = await _client.rpc<List<dynamic>>('teammate_suggestions');
        return [
          for (final r in rows.cast<Map<String, dynamic>>())
            TeammateSuggestion(
              person: _person((r['person'] as Map).cast<String, dynamic>()),
              level: TeammateLevel.parse(r['level']),
              note: r['note'] as String? ?? '',
              interests: _strings(r['interests']),
              groups: _strings(r['groups']),
              times: TeammateSlot.parseAll(r['times']),
              sameLevel: r['same_level'] == true,
              sameProvince: r['same_province'] == true,
            ),
        ];
      });

  @override
  Future<Result<MyTeammates>> mine() => _read(() async {
        final r = (await _client.rpc<Map<String, dynamic>>('my_teammates'));
        List<Map<String, dynamic>> rows(String key) => (r[key] as List).cast<Map<String, dynamic>>();
        return MyTeammates(
          teammates: [for (final p in rows('teammates')) _person(p)],
          incoming: [for (final p in rows('incoming')) _request(p)],
          outgoing: [for (final p in rows('outgoing')) _request(p)],
        );
      });

  @override
  Future<Result<TeammateRelation>> request(String userId, {String message = ''}) => _api.post(
        '/users/$userId/teammate',
        body: {'message': message.trim()},
        decode: (json) => (json! as Map)['status'] == 'teammates' ? TeammateRelation.teammates : TeammateRelation.requested,
      );

  @override
  Future<Result<void>> remove(String userId) => _api.delete('/users/$userId/teammate', decode: (_) {});

  @override
  Future<Result<void>> accept(String userId) => _api.post('/me/teammate-requests/$userId/approval', decode: (_) {});

  @override
  Future<Result<void>> decline(String userId) => _api.delete('/me/teammate-requests/$userId', decode: (_) {});
}
