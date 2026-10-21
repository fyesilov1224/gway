import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/events.dart';
import '../domain/goals.dart';

/// Trigger codes users can run into on their own writes (docs/ARCHITECTURE.md §3d, Hedefler).
const _rules = {
  'claim_not_allowed': 'Bu göreve şu anda bildirim yapılamaz; görev bitmiş ya da gruptan değilsin.',
  'claim_forbidden': 'Onaylanmış bir bildirim geri çekilemez.',
};

Future<Result<T>> _run<T>(Future<T> Function() action) async {
  try {
    return Ok(await action());
  } on Object catch (e) {
    return Err(switch (e) {
      Failure() => e,
      PostgrestException(code: 'P0001', :final message) when _rules.containsKey(message) => RuleFailure('goal.$message', _rules[message]!),
      PostgrestException(code: '23505') => const RuleFailure('goal.claimed', 'Bu görevi zaten bildirdin.'),
      _ => failureFromSupabase(e),
    });
  }
}

class GoalsRepositoryImpl implements GoalsRepository {
  GoalsRepositoryImpl(this._client, this._api);

  final SupabaseClient _client;
  final ApiClient _api;

  String? _url(String bucket, Object? path) => path is String ? _client.storage.from(bucket).getPublicUrl(path) : null;

  EventPerson _person(Map<String, dynamic> r) => EventPerson(
        id: r['id'] as String,
        username: r['username'] as String,
        displayName: r['display_name'] as String,
        avatarUrl: _url('avatars', r['avatar_path']),
      );

  List<Map<String, dynamic>> _list(Object? v) => (v as List? ?? const []).cast<Map<String, dynamic>>();

  /// A `private.goal_card` object.
  Goal _goal(Map<String, dynamic> r) {
    final g = (r['group'] as Map).cast<String, dynamic>();
    return Goal(
      id: r['id'] as String,
      group: EventGroup(id: g['id'] as String, handle: g['handle'] as String, name: g['name'] as String, logoUrl: _url('group-images', g['logo_path'])),
      title: r['title'] as String,
      description: r['description'] as String? ?? '',
      kind: GoalKind.parse(r['kind']),
      metric: GoalMetric.tryParse(r['metric']),
      target: (r['target'] as num).toInt(),
      startsAt: DateTime.parse(r['starts_at'] as String),
      endsAt: DateTime.parse(r['ends_at'] as String),
      canceledAt: r['canceled_at'] == null ? null : DateTime.parse(r['canceled_at'] as String),
      progress: (r['progress'] as num?)?.toInt() ?? 0,
      myTeam: r['my_team'] as String?,
      myClaim: ClaimStatus.tryParse(r['my_claim']),
      completed: r['completed'] == true,
      completions: (r['completions'] as num?)?.toInt() ?? 0,
      canManage: r['can_manage'] == true,
    );
  }

  @override
  Future<Result<List<Goal>>> groupGoals(String groupId) => _run(() async {
        final r = await _client.rpc<List<dynamic>>('group_goals', params: {'target_group': groupId});
        return [for (final g in r.cast<Map<String, dynamic>>()) _goal(g)];
      });

  @override
  Future<Result<GoalDetail>> goal(String id) => _run(() async {
        final r = await _client.rpc<Map<String, dynamic>?>('goal_detail', params: {'target_goal': id});
        if (r == null) throw const NotFoundFailure();
        final claims = r['claims'] as List?;
        final candidates = r['members'] as List?;
        return GoalDetail(
          goal: _goal(r),
          teams: [
            for (final t in _list(r['teams']))
              GoalTeam(
                id: t['id'] as String,
                name: t['name'] as String,
                progress: (t['progress'] as num).toInt(),
                members: [for (final m in _list(t['members'])) _person(m)],
              ),
          ],
          claims: claims == null
              ? null
              : [for (final c in claims.cast<Map<String, dynamic>>()) GoalClaim(person: _person(c), note: c['note'] as String? ?? '')],
          completers: [for (final p in _list(r['completers'])) _person(p)],
          candidates: candidates == null ? null : [for (final p in candidates.cast<Map<String, dynamic>>()) _person(p)],
        );
      });

  @override
  Future<Result<String>> create(String groupId, GoalForm form) =>
      _api.post('/groups/$groupId/goals', body: form.toJson(), decode: (json) => (json! as Map)['id'] as String);

  @override
  Future<Result<void>> cancel(String id) => _api.post('/goals/$id/cancellation', decode: (_) {});

  @override
  Future<Result<void>> createTeam(String goalId, String name, List<String> memberIds) =>
      _api.post('/goals/$goalId/teams', body: {'name': name.trim(), 'memberIds': memberIds}, decode: (_) {});

  @override
  Future<Result<void>> deleteTeam(String goalId, String teamId) => _api.delete('/goals/$goalId/teams/$teamId', decode: (_) {});

  @override
  Future<Result<void>> claim(String goalId, {String note = ''}) => _run(() async {
        final me = _client.auth.currentUser!.id;
        // A rejected claim is replaced by the new one.
        await _client.from('goal_claims').delete().eq('goal_id', goalId).eq('user_id', me).eq('status', 'rejected');
        await _client.from('goal_claims').insert({'goal_id': goalId, 'user_id': me, 'note': note.trim()});
      });

  @override
  Future<Result<void>> withdrawClaim(String goalId) => _run(() async {
        await _client.from('goal_claims').delete().eq('goal_id', goalId).eq('user_id', _client.auth.currentUser!.id);
      });

  @override
  Future<Result<void>> decideClaim(String goalId, String userId, {required bool approve}) => approve
      ? _api.post('/goals/$goalId/claims/$userId/approval', decode: (_) {})
      : _api.delete('/goals/$goalId/claims/$userId', decode: (_) {});
}
