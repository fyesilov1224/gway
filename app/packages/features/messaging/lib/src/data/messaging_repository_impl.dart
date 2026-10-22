import 'dart:async';

import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/messaging.dart';

Future<Result<T>> _run<T>(Future<T> Function() action) async {
  try {
    return Ok(await action());
  } on Failure catch (f) {
    return Err(f);
  } on Object catch (e) {
    return Err(failureFromSupabase(e));
  }
}

/// Reads under RLS, writes through the C# API (docs/ARCHITECTURE.md §3f).
class MessagingRepositoryImpl implements MessagingRepository {
  MessagingRepositoryImpl(this._client, this._api);

  final SupabaseClient _client;
  final ApiClient _api;

  static const _bucket = 'message-images';

  static const _messageColumns =
      'id, body, image_path, created_at, deleted_at, removed_reason, sender:profiles!messages_sender_id_fkey(id, username, display_name, avatar_path)';

  String get _me => _client.auth.currentUser?.id ?? (throw const UnauthorizedFailure());

  String? _url(String bucket, Object? path) => path is String ? _client.storage.from(bucket).getPublicUrl(path) : null;

  DateTime? _time(Object? value) => value is String ? DateTime.parse(value) : null;

  /// A `private.conversation_card` object.
  Conversation _conversation(Map<String, dynamic> r) {
    final peer = r['peer'] as Map?;
    final group = r['group'] as Map?;
    final last = r['last_message'] as Map?;
    return Conversation(
      id: r['id'] as String,
      kind: r['kind'] == 'group' ? ConversationKind.group : ConversationKind.direct,
      myState: MemberState.parse(r['my_state']),
      peer: peer == null
          ? null
          : ChatPeer(
              id: peer['id'] as String,
              username: peer['username'] as String,
              displayName: peer['display_name'] as String,
              avatarUrl: _url('avatars', peer['avatar_path']),
              state: MemberState.parse(peer['state']),
              readAt: _time(peer['read_at']),
            ),
      group: group == null
          ? null
          : ChatGroup(
              id: group['id'] as String,
              handle: group['handle'] as String,
              name: group['name'] as String,
              logoUrl: _url('group-images', group['logo_path']),
            ),
      lastMessage: last == null
          ? null
          : LastMessage(
              senderId: last['sender_id'] as String,
              body: last['body'] as String,
              createdAt: DateTime.parse(last['created_at'] as String),
              hasImage: last['has_image'] == true,
              deleted: last['deleted'] == true,
            ),
      unread: (r['unread'] as num?)?.toInt() ?? 0,
      adminsOnly: r['admins_only'] == true,
      blocker: r['blocker'] as String?,
      canManage: r['can_manage'] == true,
    );
  }

  MessageSender _sender(Map<String, dynamic> s) => MessageSender(
        id: s['id'] as String,
        username: s['username'] as String,
        displayName: s['display_name'] as String,
        avatarUrl: _url('avatars', s['avatar_path']),
      );

  @override
  Future<Result<List<Conversation>>> conversations() => _run(() async {
        final rows = await _client.rpc<List<dynamic>>('my_conversations');
        return [for (final r in rows) _conversation((r as Map).cast())];
      });

  @override
  Future<Result<Conversation?>> conversation(String id) => _run(() async {
        final r = await _client.rpc<Map<String, dynamic>?>('conversation_detail', params: {'conv': id});
        return r == null ? null : _conversation(r);
      });

  @override
  Future<Result<List<ChatMessage>>> messages(String conversationId, {int limit = 100}) => _run(() async {
        final rows = await _client
            .from('messages')
            .select(_messageColumns)
            .eq('conversation_id', conversationId)
            .order('created_at', ascending: false)
            .limit(limit);
        final paths = [for (final r in rows) ?r['image_path'] as String?];
        final urls = <String, String>{
          if (paths.isNotEmpty)
            for (final s in await _client.storage.from(_bucket).createSignedUrlsResult(paths, const Duration(hours: 1).inSeconds))
              if (s case SignedUrlSuccess(:final path, :final signedUrl)) path: signedUrl,
        };
        return [
          for (final r in rows.reversed)
            ChatMessage(
              id: r['id'] as String,
              sender: _sender((r['sender'] as Map).cast()),
              createdAt: DateTime.parse(r['created_at'] as String),
              body: r['body'] as String,
              imagePath: r['image_path'] as String?,
              imageUrl: urls[r['image_path']],
              deletedAt: _time(r['deleted_at']),
              removed: r['removed_reason'] != null,
            ),
        ];
      });

  @override
  Stream<void> changes({String? conversationId}) {
    if (_client.auth.currentUser == null) return const Stream.empty();
    final filter = conversationId == null
        ? null
        : PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'conversation_id', value: conversationId);
    late final RealtimeChannel channel;
    final controller = StreamController<void>(onCancel: () => _client.removeChannel(channel));
    // RLS decides which rows arrive; a read time of either side changes the badge and "Görüldü".
    channel = _client
        .channel('messages:${conversationId ?? _me}:${DateTime.now().microsecondsSinceEpoch}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'messages',
          filter: filter,
          callback: (_) => controller.add(null),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'conversation_members',
          filter: filter,
          callback: (_) => controller.add(null),
        )
        .subscribe();
    return controller.stream;
  }

  @override
  Future<Result<DirectChat>> openDirect(String userId) => _api.post(
        '/messages/direct/$userId',
        decode: (json) {
          final map = json! as Map<String, dynamic>;
          return (id: map['id'] as String, isRequest: map['state'] == 'request');
        },
      );

  @override
  Future<Result<String?>> groupConversation(String groupId) =>
      _run(() => _client.rpc<String?>('group_conversation', params: {'target_group': groupId}));

  @override
  Future<Result<void>> send(String conversationId, {String body = '', ImageUpload? image}) async {
    String? imagePath;
    if (image != null) {
      final type = image.contentType;
      if (type == null) {
        return const Err(RuleFailure('storage.unsupported_type', 'Bu dosya türü desteklenmiyor. JPEG, PNG veya WebP seç.'));
      }
      // `{konuşma}/{dosya}`, the only layout the database accepts.
      final path = '$conversationId/$_me-${DateTime.now().microsecondsSinceEpoch}.${image.extension}';
      final uploaded = await _run(
          () => _client.storage.from(_bucket).uploadBinary(path, image.bytes, fileOptions: FileOptions(contentType: type)));
      if (uploaded case Err(:final failure)) return Err(failure);
      imagePath = path;
    }
    return _api.post(
      '/conversations/$conversationId/messages',
      body: {'body': body, 'imagePath': imagePath},
      decode: (_) {},
    );
  }

  @override
  Future<Result<void>> answerRequest(String conversationId, {required bool accept}) => accept
      ? _api.post('/conversations/$conversationId/acceptance', decode: (_) {})
      : _api.delete('/conversations/$conversationId/acceptance', decode: (_) {});

  @override
  Future<Result<void>> delete(String messageId) => _api.delete('/messages/$messageId', decode: (_) {});

  @override
  Future<Result<void>> markRead(String conversationId) =>
      _run(() => _client.rpc<void>('mark_conversation_read', params: {'conv': conversationId}));

  @override
  Future<Result<void>> setAdminsOnly(String groupId, {required bool adminsOnly}) =>
      _api.put('/groups/$groupId/chat', body: {'adminsOnly': adminsOnly}, decode: (_) {});
}
