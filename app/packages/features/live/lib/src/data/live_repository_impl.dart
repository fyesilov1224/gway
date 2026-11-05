import 'dart:async';

import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/live.dart';
import '../l10n.dart';

/// Trigger codes users can run into (docs/ARCHITECTURE.md §8).
// A getter, so the messages follow the app language.
Map<String, String> get _rules => {
  'comment_rate_limited': liveL10n.commentRate,
  'muted': liveL10n.mutedListenOnly,
};

Failure _failure(Object error) => switch (error) {
      Failure() => error,
      PostgrestException(code: 'P0001', :final message) when _rules.containsKey(message) => RuleFailure('live.$message', _rules[message]!),
      PostgrestException(code: '42501') => RuleFailure('live.cannot_comment', liveL10n.cannotComment),
      _ => failureFromSupabase(error),
    };

Future<Result<T>> _run<T>(Future<T> Function() action) async {
  try {
    return Ok(await action());
  } on Object catch (e) {
    return Err(_failure(e));
  }
}

class LiveRepositoryImpl implements LiveRepository {
  LiveRepositoryImpl(this._client, this._api);

  final SupabaseClient _client;
  final ApiClient _api;

  static const _commentColumns = 'id, body, created_at, author:profiles!live_comments_user_id_fkey(id, username, display_name, avatar_path)';

  String? _url(String bucket, Object? path) => path is String ? _client.storage.from(bucket).getPublicUrl(path) : null;

  LivePerson _person(Map<String, dynamic> r) => LivePerson(
        id: r['id'] as String,
        username: r['username'] as String,
        displayName: r['display_name'] as String,
        avatarUrl: _url('avatars', r['avatar_path']),
      );

  DateTime? _time(Object? value) => value is String ? DateTime.parse(value) : null;

  /// A `private.live_card` object.
  LiveBroadcast _broadcast(Map<String, dynamic> r) {
    final group = (r['group'] as Map).cast<String, dynamic>();
    final host = r['host'] as Map?;
    return LiveBroadcast(
      id: r['id'] as String,
      title: r['title'] as String,
      status: LiveStatus.parse(r['status']),
      group: LiveGroup(
        id: group['id'] as String,
        handle: group['handle'] as String,
        name: group['name'] as String,
        logoUrl: _url('group-images', group['logo_path']),
      ),
      host: host == null ? null : _person(host.cast()),
      scheduledAt: _time(r['scheduled_at']),
      startedAt: _time(r['started_at']),
      endedAt: _time(r['ended_at']),
      reminded: r['reminded'] == true,
    );
  }

  /// Null when RLS hides the author (suspended, banned or being deleted); such comments are left out.
  LiveComment? _comment(Map<String, dynamic> r) => switch (r['author']) {
        final Map<String, dynamic> author => LiveComment(
            id: (r['id'] as num).toInt(),
            author: _person(author),
            body: r['body'] as String,
            createdAt: DateTime.parse(r['created_at'] as String),
          ),
        _ => null,
      };

  /// A Realtime channel as a stream; leaving the stream leaves the channel.
  Stream<T> _changes<T>(String name, String table, String column, String value, void Function(PostgresChangePayload, StreamController<T>) onChange) {
    late final RealtimeChannel channel;
    final controller = StreamController<T>(onCancel: () => _client.removeChannel(channel));
    channel = _client
        .channel(name)
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: table,
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: column, value: value),
          callback: (payload) => onChange(payload, controller),
        )
        .subscribe();
    return controller.stream;
  }

  // Reads -------------------------------------------------------------------------------

  @override
  Future<Result<GroupLive>> groupLive(String groupId) => _run(() async {
        final r = (await _client.rpc<Map<String, dynamic>>('group_live', params: {'target_group': groupId}));
        final live = r['live'] as Map?;
        return GroupLive(
          live: live == null ? null : _broadcast(live.cast()),
          scheduled: [for (final b in (r['scheduled'] as List).cast<Map<String, dynamic>>()) _broadcast(b)],
          minutesLeft: (r['minutes_left'] as num?)?.toInt(),
        );
      });

  @override
  Stream<void> groupChanges(String groupId) =>
      _changes<void>('live-group:$groupId', 'live_broadcasts', 'group_id', groupId, (_, out) => out.add(null));

  @override
  Future<Result<List<LiveBroadcast>>> myLive() => _run(() async {
        final rows = await _client.rpc<List<dynamic>>('my_live_broadcasts');
        return [for (final r in rows.cast<Map<String, dynamic>>()) _broadcast(r)];
      });

  @override
  Future<Result<LiveBroadcast>> broadcast(String id) => _run(() async {
        final r = await _client.rpc<Map<String, dynamic>?>('live_broadcast', params: {'target_broadcast': id});
        if (r == null) throw const NotFoundFailure();
        return _broadcast(r);
      });

  @override
  Future<Result<Set<String>>> myPermissions(String groupId) => _run(() async {
        final r = await _client.rpc<List<dynamic>>('my_group_permissions', params: {'target_group': groupId});
        return r.cast<String>().toSet();
      });

  @override
  Future<Result<List<LiveComment>>> comments(String id) => _run(() async {
        final rows = await _client
            .from('live_comments')
            .select(_commentColumns)
            .eq('broadcast_id', id)
            .order('id', ascending: false)
            .limit(100);
        return [for (final r in rows.reversed) ?_comment(r)];
      });

  @override
  Stream<LiveCommentChange> commentChanges(String id) =>
      _changes<LiveCommentChange>('live-comments:$id', 'live_comments', 'broadcast_id', id, (payload, out) async {
        switch (payload.eventType) {
          case PostgresChangeEvent.insert:
            // The change carries no profile; read the row with its author.
            final row = await _client.from('live_comments').select(_commentColumns).eq('id', payload.newRecord['id'] as Object).maybeSingle();
            if (row case final r? when !out.isClosed) {
              if (_comment(r) case final comment?) out.add(LiveCommentAdded(comment));
            }
          case PostgresChangeEvent.delete:
            if (payload.oldRecord['id'] case final num commentId) out.add(LiveCommentRemoved(commentId.toInt()));
          default:
        }
      });

  // Own writes (RLS) --------------------------------------------------------------------------

  @override
  Future<Result<void>> comment(String id, String body) => _run(() async {
        await _client.from('live_comments').insert({
          'broadcast_id': id,
          'user_id': _client.auth.currentUser!.id,
          'body': body.trim(),
        });
      });

  @override
  Future<Result<void>> deleteComment(String id, LiveComment comment) async {
    if (comment.author.id == _client.auth.currentUser?.id) {
      return _run(() => _client.from('live_comments').delete().eq('id', comment.id));
    }
    return _api.delete('/live/$id/comments/${comment.id}', decode: (_) {});
  }

  @override
  Future<Result<void>> setReminder(String id, {required bool on}) => _run(() async {
        final me = _client.auth.currentUser!.id;
        if (on) {
          await _client.from('live_reminders').insert({'broadcast_id': id, 'user_id': me});
        } else {
          await _client.from('live_reminders').delete().eq('broadcast_id', id).eq('user_id', me);
        }
      });

  // API writes ---------------------------------------------------------------------------------

  @override
  Future<Result<String>> start(String groupId, {required String title, DateTime? scheduledAt}) => _api.post(
        '/groups/$groupId/live',
        body: {'title': title.trim(), 'scheduledAt': ?scheduledAt?.toUtc().toIso8601String()},
        decode: (json) => (json! as Map)['id'] as String,
      );

  @override
  Future<Result<void>> startScheduled(String id) => _api.post('/live/$id/start', decode: (_) {});

  @override
  Future<Result<void>> cancel(String id) => _api.delete('/live/$id', decode: (_) {});

  @override
  Future<Result<void>> end(String id) => _api.post('/live/$id/end', decode: (_) {});

  @override
  Future<Result<LiveJoin>> join(String id) => _api.post(
        '/live/$id/token',
        decode: (json) {
          final j = (json! as Map).cast<String, Object?>();
          return LiveJoin(url: j['url']! as String, token: j['token']! as String, role: LiveRole.parse(j['role']));
        },
      );

  @override
  Future<Result<void>> setHand(String id, {required bool raised}) =>
      raised ? _api.put('/live/$id/hand', decode: (_) {}) : _api.delete('/live/$id/hand', decode: (_) {});

  @override
  Future<Result<void>> inviteToStage(String id, String userId) => _api.put('/live/$id/speakers/$userId', decode: (_) {});

  @override
  Future<Result<void>> removeFromStage(String id, String userId) => _api.delete('/live/$id/speakers/$userId', decode: (_) {});

  @override
  Future<Result<void>> setMuted(String id, String userId, {required bool muted}) => muted
      ? _api.put('/live/$id/muted/$userId', decode: (_) {})
      : _api.delete('/live/$id/muted/$userId', decode: (_) {});

  @override
  Future<Result<void>> kick(String id, String userId) => _api.post('/live/$id/kicks/$userId', decode: (_) {});
}
