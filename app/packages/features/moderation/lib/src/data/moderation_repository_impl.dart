import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/moderation.dart';

/// Trigger codes users can run into on their own writes (docs/ARCHITECTURE.md §3e).
const _rules = {
  'report_rate_limited': 'Bugün çok fazla şikayet gönderdin. Yarın tekrar deneyebilirsin.',
  'report_target_invalid': 'Bu içerik artık yok ya da göremiyorsun.',
  'report_self': 'Kendini ya da kendi içeriğini şikayet edemezsin.',
  'appeal_not_allowed': 'Bu yaptırıma artık itiraz edilemez.',
};

Failure _failure(Object error) => switch (error) {
      Failure() => error,
      PostgrestException(code: 'P0001', :final message) when _rules.containsKey(message) => RuleFailure('moderation.$message', _rules[message]!),
      PostgrestException(code: '23505') => const RuleFailure('moderation.duplicate', 'Bunu zaten bildirdin; inceleniyor.'),
      _ => failureFromSupabase(error),
    };

Future<Result<T>> _run<T>(Future<T> Function() action) async {
  try {
    return Ok(await action());
  } on Object catch (e) {
    return Err(_failure(e));
  }
}

class ModerationRepositoryImpl implements ModerationRepository {
  ModerationRepositoryImpl(this._client, this._api);

  final SupabaseClient _client;
  final ApiClient _api;

  String? _url(String bucket, Object? path) => path is String ? _client.storage.from(bucket).getPublicUrl(path) : null;

  DateTime? _time(Object? v) => v is String ? DateTime.parse(v) : null;

  int _int(Object? v) => (v as num?)?.toInt() ?? 0;

  ModerationPerson? _person(Object? json) {
    if (json is! Map) return null;
    final r = json.cast<String, dynamic>();
    return ModerationPerson(
      id: r['id'] as String,
      username: r['username'] as String,
      displayName: r['display_name'] as String,
      avatarUrl: _url('avatars', r['avatar_path']),
      rank: _int(r['rank']),
    );
  }

  /// Deleted accounts keep their place in the history without a profile.
  ModerationPerson _someone(Object? json) =>
      _person(json) ?? const ModerationPerson(id: '', username: '', displayName: 'Silinmiş hesap');

  Appeal? _appeal(Object? json) {
    if (json is! Map) return null;
    final r = json.cast<String, dynamic>();
    return Appeal(
      id: r['id'] as String,
      body: r['body'] as String,
      status: AppealStatus.parse(r['status']),
      byPlatform: r['handler'] == 'platform',
      decisionNote: r['decision_note'] as String?,
      createdAt: DateTime.parse(r['created_at'] as String),
    );
  }

  List<Map<String, dynamic>> _list(Object? v) => (v as List? ?? const []).cast<Map<String, dynamic>>();

  @override
  Future<Result<void>> report(ReportTarget target, ReportReason reason, {String? note}) => _run(() async {
        await _client.from('reports').insert({
          'reporter_id': _client.auth.currentUser!.id,
          'target_type': target.type,
          'target_id': target.id,
          'group_id': target.groupId,
          'reason': reason.code,
          'note': (note?.trim().isEmpty ?? true) ? null : note!.trim(),
        });
      });

  @override
  Future<Result<GroupModeration?>> groupModeration(String groupId) => _run(() async {
        final r = await _client.rpc<Map<String, dynamic>?>('group_moderation', params: {'target_group': groupId});
        if (r == null) return null;
        return GroupModeration(
          rank: _int(r['rank']),
          isOwner: r['is_owner'] == true,
          canMute: r['can_mute'] == true,
          threshold: CaseThreshold.parse(r['threshold']),
          reports: [
            for (final x in _list(r['reports']))
              GroupReport(
                id: x['id'] as String,
                targetType: x['target_type'] as String,
                targetId: x['target_id'] as String,
                postId: x['post_id'] as String?,
                subject: _person(x['subject']),
                excerpt: x['excerpt'] as String? ?? '',
                reasons: [for (final c in (x['reasons'] as List? ?? const [])) ReportReason.parse(c)],
                notes: [for (final n in (x['notes'] as List? ?? const [])) n as String],
                count: _int(x['count']),
                lastAt: DateTime.parse(x['last_at'] as String),
              ),
          ],
          cases: [
            for (final c in _list(r['cases']))
              ModerationCase(
                id: c['id'] as String,
                subject: _someone(c['subject']),
                openedBy: _person(c['opened_by']),
                sanction: SanctionType.parse(c['sanction']),
                durationDays: (c['duration_days'] as num?)?.toInt(),
                reason: c['reason'] as String,
                threshold: CaseThreshold.parse(c['threshold']),
                status: CaseStatus.parse(c['status']),
                votingEndsAt: DateTime.parse(c['voting_ends_at'] as String),
                decidedAt: _time(c['decided_at']),
                createdAt: DateTime.parse(c['created_at'] as String),
                voters: _int(c['voters']),
                approvals: _int(c['approvals']),
                rejections: _int(c['rejections']),
                isVoter: c['is_voter'] == true,
                myVote: switch (c['my_vote']) { 'approve' => true, 'reject' => false, _ => null },
              ),
          ],
          sanctions: [
            for (final s in _list(r['sanctions']))
              GroupSanction(
                id: s['id'] as String,
                user: _someone(s['user']),
                type: SanctionType.parse(s['type']),
                interim: s['interim'] == true,
                startsAt: DateTime.parse(s['starts_at'] as String),
                endsAt: _time(s['ends_at']),
                liftedAt: _time(s['lifted_at']),
                reason: s['reason'] as String? ?? '',
                appeal: _appeal(s['appeal']),
              ),
          ],
        );
      });

  @override
  Future<Result<void>> dismiss(String reportId) => _api.post('/reports/$reportId/dismissal', decode: (_) {});

  @override
  Future<Result<void>> removeContent(String reportId, {required String reason}) =>
      _api.post('/reports/$reportId/removal', body: {'reason': reason}, decode: (_) {});

  @override
  Future<Result<void>> openCase(String groupId, CaseForm form) =>
      _api.post('/groups/$groupId/cases', body: form.toJson(), decode: (_) {});

  @override
  Future<Result<CaseStatus>> vote(String caseId, {required bool approve}) => _api.put(
        '/cases/$caseId/vote',
        body: {'approve': approve},
        decode: (json) => CaseStatus.parse((json! as Map)['status']),
      );

  @override
  Future<Result<void>> decideAppeal(String appealId, {required bool overturn, String? note}) =>
      _api.post('/appeals/$appealId/decision', body: {'overturn': overturn, 'note': note}, decode: (_) {});

  @override
  Future<Result<void>> setThreshold(String groupId, CaseThreshold threshold) =>
      _api.put('/groups/$groupId/case-threshold', body: {'threshold': threshold.code}, decode: (_) {});

  @override
  Future<Result<List<MySanction>>> mySanctions() => _run(() async {
        final r = await _client.rpc<List<dynamic>>('my_sanctions');
        return [for (final s in r.cast<Map<String, dynamic>>()) _mySanction(s, (s['group'] as Map).cast())];
      });

  MySanction _mySanction(Map<String, dynamic> s, Map<String, dynamic> g) => MySanction(
        id: s['id'] as String,
        group: SanctionGroup(
          id: g['id'] as String,
          handle: g['handle'] as String,
          name: g['name'] as String,
          logoUrl: _url('group-images', g['logo_path']),
        ),
        type: SanctionType.parse(s['type']),
        interim: s['interim'] == true,
        startsAt: DateTime.parse(s['starts_at'] as String),
        endsAt: _time(s['ends_at']),
        liftedAt: _time(s['lifted_at']),
        reason: s['reason'] as String? ?? '',
        canAppeal: s['can_appeal'] == true,
        appeal: _appeal(s['appeal']),
      );

  @override
  Future<Result<void>> appeal(String sanctionId, String body) => _run(() async {
        await _client.from('sanction_appeals').insert({
          'sanction_id': sanctionId,
          'user_id': _client.auth.currentUser!.id,
          'body': body.trim(),
        });
      });
}
