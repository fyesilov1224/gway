import 'dart:async';

import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/calls.dart';

Future<Result<T>> _run<T>(Future<T> Function() action) async {
  try {
    return Ok(await action());
  } on Failure catch (f) {
    return Err(f);
  } on Object catch (e) {
    return Err(failureFromSupabase(e));
  }
}

/// Calls go through the C# API; the call row and the permission are read under RLS (docs/ARCHITECTURE.md §8c).
class CallsRepositoryImpl implements CallsRepository {
  CallsRepositoryImpl(this._client, this._api);

  final SupabaseClient _client;
  final ApiClient _api;

  String get _me => _client.auth.currentUser?.id ?? (throw const UnauthorizedFailure());

  static CallJoin _join(Object? json) {
    final j = json! as Map<String, dynamic>;
    return CallJoin(callId: j['callId'] as String, url: j['url'] as String, token: j['token'] as String);
  }

  static CallInfo _call(Map<String, dynamic> r) => CallInfo(
        id: r['id'] as String,
        conversationId: r['conversation_id'] as String,
        callerId: r['caller_id'] as String,
        calleeId: r['callee_id'] as String,
        status: CallStatus.parse(r['status']),
        createdAt: DateTime.parse(r['created_at'] as String),
        answeredAt: r['answered_at'] is String ? DateTime.parse(r['answered_at'] as String) : null,
        endReason: r['end_reason'] as String?,
      );

  @override
  Future<Result<CallEligibility>> eligibility(String conversationId) => _api.get(
        '/conversations/$conversationId/calls/eligibility',
        decode: (json) {
          final j = json! as Map<String, dynamic>;
          return CallEligibility(allowed: j['allowed'] as bool, code: j['code'] as String?, message: j['message'] as String?);
        },
      );

  @override
  Future<Result<CallJoin>> start(String conversationId) => _api.post('/conversations/$conversationId/calls', decode: _join);

  @override
  Future<Result<CallJoin>> accept(String callId) => _api.post('/calls/$callId/accept', decode: _join);

  @override
  Future<Result<CallJoin>> rejoin(String callId) => _api.post('/calls/$callId/token', decode: _join);

  @override
  Future<Result<void>> decline(String callId) => _api.post('/calls/$callId/decline', decode: (_) {});

  @override
  Future<Result<void>> end(String callId) => _api.post('/calls/$callId/end', decode: (_) {});

  @override
  Stream<CallInfo?> watch(String callId) => _client
      .from('calls')
      .stream(primaryKey: ['id'])
      .eq('id', callId)
      .map((rows) => rows.isEmpty ? null : _call(rows.first));

  @override
  Stream<List<CallInfo>> incoming() => _client
      .from('calls')
      .stream(primaryKey: ['id'])
      .eq('callee_id', _me)
      .map((rows) => [for (final r in rows) if (r['status'] == 'ringing') _call(r)]);

  @override
  Future<Result<CallPeer>> peer(String userId) => _run(() async {
        final r = await _client.from('profiles').select('id, username, display_name, avatar_path').eq('id', userId).single();
        final avatar = r['avatar_path'] as String?;
        return CallPeer(
          id: r['id'] as String,
          username: r['username'] as String,
          displayName: r['display_name'] as String,
          avatarUrl: avatar == null ? null : _client.storage.from('avatars').getPublicUrl(avatar),
        );
      });

  @override
  Future<Result<CallPermission>> myPermission() => _run(() async {
        final r = await _client.rpc<Map<String, dynamic>?>('my_call_permission');
        if (r == null) return const CallPermission();
        return CallPermission(
          status: CallPermissionStatus.parse(r['status']),
          note: r['note'] as String?,
          reason: r['reason'] as String?,
          decidedAt: r['decided_at'] is String ? DateTime.parse(r['decided_at'] as String) : null,
          decidedByPerson: r['decided_by_person'] == true,
          groupName: (r['group'] as Map<String, dynamic>?)?['name'] as String?,
        );
      });

  @override
  Future<Result<List<CallGroup>>> myGroups() => _run(() async {
        final rows = await _client.from('group_members').select('groups!inner(id, name, status)').eq('user_id', _me);
        return [
          for (final g in rows.map((r) => r['groups'] as Map<String, dynamic>))
            if (g['status'] == 'active') CallGroup(id: g['id'] as String, name: g['name'] as String),
        ]..sort((a, b) => a.name.compareTo(b.name));
      });

  @override
  Future<Result<GroupCallDesk?>> groupDesk(String groupId) => _run(() async {
        final r = await _client.rpc<Map<String, dynamic>?>('group_call_permissions', params: {'target_group': groupId});
        if (r == null) return null;
        DateTime? at(Object? v) => v is String ? DateTime.parse(v) : null;
        return GroupCallDesk(
          rank: (r['rank'] as num).toInt(),
          items: [
            for (final (i, p) in [
              for (final i in (r['items'] as List).cast<Map<String, dynamic>>()) (i, i['person'] as Map<String, dynamic>),
            ])
              GroupCallRequest(
                userId: p['id'] as String,
                username: p['username'] as String,
                displayName: p['display_name'] as String,
                avatarUrl: switch (p['avatar_path']) {
                  final String path => _client.storage.from('avatars').getPublicUrl(path),
                  _ => null,
                },
                rank: (p['rank'] as num).toInt(),

                status: CallPermissionStatus.parse(i['status']),
                note: i['note'] as String?,
                requestedAt: at(i['requested_at']),
                decidedAt: at(i['decided_at']),
              ),
          ],
        );
      });

  @override
  Future<Result<void>> decide(String groupId, String userId, {required bool active, String? reason}) =>
      _api.put('/groups/$groupId/call-permissions/$userId', body: {'active': active, 'reason': reason}, decode: (_) {});

  @override
  Future<Result<void>> requestPermission(String groupId, String? note) => _run(() async {
        try {
          await _client.rpc<void>('request_call_permission', params: {'target_group': groupId, 'request_note': note});
        } on PostgrestException catch (e) {
          if (e.code != 'P0001') rethrow;
          throw switch (e.message) {
            'call_group_invalid' => const RuleFailure('call.group_invalid', 'Talebi üyesi olduğun bir gruba gönderebilirsin.'),

            'call_permission_exists' => const RuleFailure('call.permission_exists', 'Talebin zaten alındı ya da yetkin açık.'),
            'call_permission_cooldown' =>
              const RuleFailure('call.permission_cooldown', 'Yeni bir talebi son karardan 7 gün sonra gönderebilirsin.'),
            'call_note_too_long' => const RuleFailure('call.note_too_long', 'Not en fazla ${CallRules.noteMax} karakter olabilir.'),
            _ => const RuleFailure('call.forbidden', 'Talep şu anda gönderilemiyor.'),
          };
        }
      });
}
