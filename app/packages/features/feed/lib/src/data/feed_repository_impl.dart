import 'dart:math';
import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/post.dart';

const mediaBucket = 'media';

/// Trigger codes users can run into, as Turkish messages (docs/ARCHITECTURE.md §3c).
const _rules = {
  'comments_disabled': 'Bu gönderide yorumlar kapalı.',
  'blocked': 'Bu hesapla etkileşime geçemezsin.',
  'comment_rate_limited': 'Kısa sürede çok fazla yorum yazdın. Biraz bekleyip tekrar dene.',
  'muted': 'Bu grupta susturulduğun için şu anda yorum yazamazsın.',
  'like_rate_limited': 'Kısa sürede çok fazla beğeni yaptın. Biraz bekleyip tekrar dene.',
  'reply_target_invalid': 'Yanıt verdiğin yorum artık yok.',
  'story_rate_limited': 'Bugün çok fazla hikaye paylaştın. Yarın tekrar dene.',
  'highlight_limit': 'En fazla 100 öne çıkan oluşturabilirsin.',
  'highlight_full': 'Bir öne çıkanda en fazla 100 hikaye olabilir.',
};

/// Maps feed errors; storage size and type errors get media-specific messages.
Failure failureFromFeed(Object error) => switch (error) {
      Failure() => error,
      PostgrestException(code: 'P0001', :final message) when _rules.containsKey(message) =>
        RuleFailure('feed.$message', _rules[message]!),
      PostgrestException(code: '23505') => const RuleFailure('feed.duplicate', 'Bu işlem zaten yapılmış.'),
      StorageException(statusCode: '413') =>
        const RuleFailure('feed.too_large', 'Dosya çok büyük. Fotoğraflar en fazla 10 MB, videolar 50 MB olabilir.'),
      StorageException(statusCode: '415') =>
        const RuleFailure('feed.unsupported_type', 'Yalnızca JPEG, PNG, WebP fotoğraf ve MP4, MOV video paylaşılabilir.'),
      _ => failureFromSupabase(error),
    };

Future<Result<T>> runFeed<T>(Future<T> Function() action) async {
  try {
    return Ok(await action());
  } on Object catch (e) {
    return Err(failureFromFeed(e));
  }
}

/// Builds domain objects from rows, with public Storage URLs.
class FeedMapper {
  const FeedMapper(this._client);

  final SupabaseClient _client;

  String? url(String bucket, Object? path) => path is String ? _client.storage.from(bucket).getPublicUrl(path) : null;

  PostAuthor author(Map<String, dynamic> r) => PostAuthor(
        id: r['id'] as String,
        username: r['username'] as String,
        displayName: r['display_name'] as String,
        avatarUrl: url('avatars', r['avatar_path']),
      );

  PostMedia media(Map<String, dynamic> r) => PostMedia(
        kind: MediaKind.parse(r['kind']),
        url: url(mediaBucket, r['path'])!,
        width: (r['width'] as num).toInt(),
        height: (r['height'] as num).toInt(),
        duration: r['duration_ms'] is num ? Duration(milliseconds: (r['duration_ms'] as num).toInt()) : null,
        posterUrl: url(mediaBucket, r['poster_path']),
        thumbUrl: url(mediaBucket, r['thumb_path']),
      );

  /// A `public.post_card` row.
  Post post(Map<String, dynamic> r) {
    final group = r['group'] as Map?;
    final author = r['author'] as Map?;
    final event = r['event'] as Map?;
    return Post(
      id: r['id'] as String,
      caption: r['caption'] as String,
      createdAt: DateTime.parse(r['created_at'] as String),
      editedAt: r['edited_at'] == null ? null : DateTime.parse(r['edited_at'] as String),
      author: author == null ? null : this.author(author.cast()),
      group: group == null
          ? null
          : PostGroup(
              id: group['id'] as String,
              handle: group['handle'] as String,
              name: group['name'] as String,
              logoUrl: url('group-images', group['logo_path']),
            ),
      event: event == null ? null : PostEvent(id: event['id'] as String, title: event['title'] as String),
      media: [for (final m in r['media'] as List) media((m as Map).cast())],
      commentsDisabled: r['comments_disabled'] as bool,
      hideLikeCount: r['hide_like_count'] as bool,
      likeCount: (r['like_count'] as num?)?.toInt(),
      commentCount: (r['comment_count'] as num).toInt(),
      liked: r['liked'] as bool,
      saved: r['saved'] as bool,
      canManage: r['can_manage'] as bool,
    );
  }
}

/// Random (v4) uuid for upload names; paths must be unguessable (docs/ARCHITECTURE.md §3c, Depolama).
String randomUuid() {
  final random = Random.secure();
  final b = [for (var i = 0; i < 16; i++) random.nextInt(256)];
  b[6] = (b[6] & 0x0f) | 0x40;
  b[8] = (b[8] & 0x3f) | 0x80;
  final hex = [for (final x in b) x.toRadixString(16).padLeft(2, '0')].join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}

/// Uploads to `media/<uid>/<uuid>.<ext>` and returns the path.
Future<String> uploadMedia(SupabaseClient client, Uint8List bytes, {required String extension, required String? contentType}) async {
  final uid = client.auth.currentUser?.id ?? (throw const UnauthorizedFailure());
  final path = '$uid/${randomUuid()}.$extension';
  await client.storage.from(mediaBucket).uploadBinary(path, bytes, fileOptions: FileOptions(contentType: contentType));
  return path;
}

/// Reads through Supabase (RLS); likes, comments and saves are the user's own writes;
/// creating, editing and deleting posts go through the C# API (docs/ARCHITECTURE.md §3c).
class FeedRepositoryImpl implements FeedRepository {
  FeedRepositoryImpl(this._client, this._api) : _map = FeedMapper(_client);

  final SupabaseClient _client;
  final ApiClient _api;
  final FeedMapper _map;

  static const pageSize = 18;

  String get _me => _client.auth.currentUser?.id ?? (throw const UnauthorizedFailure());

  @override
  Future<Result<List<Post>>> posts(PostSource source, {Post? after, int offset = 0}) => runFeed(() async {
        final cursor = {
          'before_at': after?.createdAt.toUtc().toIso8601String(),
          'before_id': after?.id,
          'page_size': pageSize,
        };
        final (fn, params) = switch (source) {
          HomeFeed() => ('home_feed', cursor),
          UserPosts(:final userId) => ('user_posts', {'target': userId, ...cursor}),
          GroupPosts(:final groupId) => ('group_posts', {'target': groupId, ...cursor}),
          EventPosts(:final eventId) => ('event_posts', {'target_event': eventId, ...cursor}),
          HashtagPosts(:final tag) => ('hashtag_posts', {'tag': tag, ...cursor}),
          ExplorePosts() => ('explore_posts', {'page_offset': offset, 'page_size': pageSize}),
          SavedPosts() => ('saved_feed', {'page_size': 60}),
        };
        final rows = await _client.rpc<List<dynamic>>(fn, params: params);
        return [for (final r in rows) _map.post((r as Map).cast())];
      });

  @override
  Future<Result<Post>> post(String id) => runFeed(() async {
        final rows = await _client.rpc<List<dynamic>>('post_by_id', params: {'target': id});
        if (rows.isEmpty) throw const NotFoundFailure();
        return _map.post((rows.first as Map).cast());
      });

  @override
  Future<Result<List<HashtagCount>>> searchHashtags(String query) => runFeed(() async {
        final rows = await _client.rpc<List<dynamic>>('search_hashtags', params: {'query': query, 'max_results': 20});
        return [
          for (final r in rows.cast<Map<String, dynamic>>())
            HashtagCount(tag: r['tag'] as String, postCount: (r['post_count'] as num).toInt()),
        ];
      });

  @override
  Future<Result<List<PostGroup>>> publishableGroups() => runFeed(() async {
        final rows = await _client.rpc<List<dynamic>>('my_publishable_groups');
        return [
          for (final r in rows.cast<Map<String, dynamic>>())
            PostGroup(
              id: r['id'] as String,
              handle: r['handle'] as String,
              name: r['name'] as String,
              logoUrl: _map.url('group-images', r['logo_path']),
            ),
        ];
      });

  @override
  Future<Result<String>> create(NewPost post, {void Function(int done, int total)? onProgress}) async {
    if (post.problem case final problem?) return Err(RuleFailure('feed.invalid_post', problem));
    final paths = <String>[];
    final thumbs = <String?>[];
    final uploaded = await runFeed(() async {
      for (final (i, m) in post.media.indexed) {
        paths.add(await uploadMedia(_client, m.bytes, extension: m.extension, contentType: m.contentType));
        thumbs.add(m.thumb == null ? null : await uploadMedia(_client, m.thumb!, extension: 'jpg', contentType: 'image/jpeg'));
        onProgress?.call(i + 1, post.media.length);
      }
    });
    final files = [...paths, ...thumbs.nonNulls];
    if (uploaded case Err(:final failure)) {
      await _discard(files);
      return Err(failure);
    }
    final result = await _api.post(
      '/posts',
      body: {
        'caption': post.caption.trim(),
        'groupId': post.groupId,
        'eventId': post.eventId,
        'commentsDisabled': post.commentsDisabled,
        'hideLikeCount': post.hideLikeCount,
        'media': [
          for (final (i, m) in post.media.indexed)
            {
              'kind': m.kind.name,
              'path': paths[i],
              'width': m.width,
              'height': m.height,
              'durationMs': m.duration?.inMilliseconds,
              'thumbPath': thumbs[i],
            },
        ],
      },
      decode: (json) => (json! as Map)['id'] as String,
    );
    if (result is Err) await _discard(files);
    return result;
  }

  /// Best effort: an orphaned upload is unreachable anyway.
  Future<void> _discard(List<String> paths) async {
    if (paths.isEmpty) return;
    try {
      await _client.storage.from(mediaBucket).remove(paths);
    } on Object {
      // Ignored on purpose.
    }
  }

  @override
  Future<Result<void>> update(String id, {required String caption, required bool commentsDisabled, required bool hideLikeCount}) =>
      _api.patch(
        '/posts/$id',
        body: {'caption': caption.trim(), 'commentsDisabled': commentsDisabled, 'hideLikeCount': hideLikeCount},
        decode: (_) {},
      );

  @override
  Future<Result<void>> delete(String id) => _api.delete('/posts/$id', decode: (_) {});

  @override
  Future<Result<void>> setLiked(String postId, bool liked) => runFeed(() async {
        final table = _client.from('post_likes');
        liked
            ? await table.upsert({'post_id': postId, 'user_id': _me}, ignoreDuplicates: true)
            : await table.delete().eq('post_id', postId).eq('user_id', _me);
      });

  @override
  Future<Result<void>> setSaved(String postId, bool saved) => runFeed(() async {
        final table = _client.from('saved_posts');
        saved
            ? await table.upsert({'post_id': postId, 'user_id': _me}, ignoreDuplicates: true)
            : await table.delete().eq('post_id', postId).eq('user_id', _me);
      });

  @override
  Future<Result<List<Comment>>> comments(String postId) => runFeed(() async {
        final rows = await _client
            .from('comments')
            .select('id, parent_id, body, like_count, created_at, '
                'author:profiles!comments_author_id_fkey(id, username, display_name, avatar_path)')
            .eq('post_id', postId)
            .order('created_at')
            .limit(500);
        final me = _client.auth.currentUser?.id;
        final ids = [for (final r in rows) r['id'] as String];
        final liked = me == null || ids.isEmpty
            ? const <String>{}
            : {
                for (final r in await _client.from('comment_likes').select('comment_id').eq('user_id', me).inFilter('comment_id', ids))
                  r['comment_id'] as String,
              };
        return threadComments([
          for (final r in rows)
            if (r['author'] != null)
              Comment(
                id: r['id'] as String,
                postId: postId,
                author: _map.author((r['author'] as Map).cast()),
                parentId: r['parent_id'] as String?,
                body: r['body'] as String,
                createdAt: DateTime.parse(r['created_at'] as String),
                likeCount: (r['like_count'] as num).toInt(),
                liked: liked.contains(r['id']),
              ),
        ]);
      });

  @override
  Future<Result<void>> addComment(String postId, String body, {String? replyTo}) => runFeed(() async {
        final text = body.trim();
        if (text.isEmpty || text.length > NewPost.maxCaption) {
          throw const RuleFailure('feed.invalid_comment', 'Yorum 1–2.200 karakter olmalı.');
        }
        await _client.from('comments').insert({'post_id': postId, 'author_id': _me, 'parent_id': replyTo, 'body': text});
      });

  @override
  Future<Result<void>> deleteComment(String commentId) => runFeed(() async {
        final deleted = await _client.from('comments').delete().eq('id', commentId).select('id');
        if (deleted.isEmpty) throw const ForbiddenFailure();
      });

  @override
  Future<Result<void>> setCommentLiked(String commentId, bool liked) => runFeed(() async {
        final table = _client.from('comment_likes');
        liked
            ? await table.upsert({'comment_id': commentId, 'user_id': _me}, ignoreDuplicates: true)
            : await table.delete().eq('comment_id', commentId).eq('user_id', _me);
      });
}
