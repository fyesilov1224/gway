import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/post.dart';
import '../domain/story.dart';
import '../l10n.dart';
import 'feed_repository_impl.dart';

/// Stories and highlights are the user's own writes under RLS (docs/ARCHITECTURE.md §3c, Hikaye).
class StoryRepositoryImpl implements StoryRepository {
  StoryRepositoryImpl(this._client) : _map = FeedMapper(_client);

  final SupabaseClient _client;
  final FeedMapper _map;

  static const _columns = 'id, kind, path, width, height, duration_ms, poster_path, created_at, expires_at, '
      'author:profiles!stories_author_id_fkey(id, username, display_name, avatar_path)';

  String get _me => _client.auth.currentUser?.id ?? (throw const UnauthorizedFailure());

  Future<List<Story>> _stories(List<Map<String, dynamic>> rows) async {
    final me = _client.auth.currentUser?.id;
    final ids = [for (final r in rows) r['id'] as String];
    final seen = me == null || ids.isEmpty
        ? const <String>{}
        : {
            for (final r in await _client.from('story_views').select('story_id').eq('viewer_id', me).inFilter('story_id', ids))
              r['story_id'] as String,
          };
    return [
      for (final r in rows)
        if (r['author'] != null)
          Story(
            id: r['id'] as String,
            author: _map.author((r['author'] as Map).cast()),
            media: _map.media(r),
            createdAt: DateTime.parse(r['created_at'] as String),
            expiresAt: DateTime.parse(r['expires_at'] as String),
            seen: seen.contains(r['id']) || (r['author'] as Map)['id'] == me,
          ),
    ];
  }

  @override
  Future<Result<List<StoryRing>>> tray() => runFeed(() async {
        final me = _client.auth.currentUser?.id;
        final rows = await _client.rpc<List<dynamic>>('story_tray');
        return [
          for (final r in rows.cast<Map<String, dynamic>>())
            StoryRing(
              userId: r['user_id'] as String,
              username: r['username'] as String,
              avatarUrl: _map.url('avatars', r['avatar_path']),
              hasUnseen: r['has_unseen'] as bool && r['user_id'] != me,
              isMine: r['user_id'] == me,
            ),
        ];
      });

  @override
  Future<Result<List<Story>>> active(String userId) => runFeed(() async {
        final rows = await _client
            .from('stories')
            .select(_columns)
            .eq('author_id', userId)
            .gt('expires_at', DateTime.now().toUtc().toIso8601String())
            .order('created_at');
        return _stories(rows);
      });

  @override
  Future<Result<List<Story>>> archive() => runFeed(() async {
        final rows = await _client.from('stories').select(_columns).eq('author_id', _me).order('created_at', ascending: false).limit(500);
        return _stories(rows);
      });

  @override
  Future<Result<void>> create(NewMedia media) => runFeed(() async {
        if (media.problem case final problem?) throw RuleFailure('feed.invalid_story', problem);
        final path = await uploadMedia(_client, media.bytes, extension: media.extension, contentType: media.contentType);
        try {
          await _client.from('stories').insert({
            'author_id': _me,
            'kind': media.kind.name,
            'path': path,
            'width': media.width,
            'height': media.height,
            'duration_ms': media.duration?.inMilliseconds,
          });
        } on Object {
          await _client.storage.from(mediaBucket).remove([path]);
          rethrow;
        }
      });

  /// Deletes the story, then its file (a failed file delete only leaves an unreachable object).
  @override
  Future<Result<void>> delete(Story story) => runFeed(() async {
        final rows = await _client.from('stories').delete().eq('id', story.id).select('path, poster_path');
        if (rows.isEmpty) throw const ForbiddenFailure();
        final files = [for (final r in rows) ...[r['path'] as String, ?r['poster_path'] as String?]];
        try {
          await _client.storage.from(mediaBucket).remove(files);
        } on Object {
          // Ignored on purpose.
        }
      });

  @override
  Future<Result<void>> markSeen(String storyId) => runFeed(() async {
        await _client.from('story_views').upsert({'story_id': storyId, 'viewer_id': _me}, ignoreDuplicates: true);
      });

  @override
  Future<Result<List<StoryViewer>>> viewers(String storyId) => runFeed(() async {
        final rows = await _client
            .from('story_views')
            .select('viewed_at, person:profiles!story_views_viewer_id_fkey(id, username, display_name, avatar_path)')
            .eq('story_id', storyId)
            .order('viewed_at', ascending: false);
        return [
          for (final r in rows)
            if (r['person'] != null)
              StoryViewer(person: _map.author((r['person'] as Map).cast()), viewedAt: DateTime.parse(r['viewed_at'] as String)),
        ];
      });

  @override
  Future<Result<List<Highlight>>> highlights(String userId) => runFeed(() async {
        final rows = await _client
            .from('highlights')
            .select('id, owner_id, title, created_at, '
                'highlight_stories(added_at, stories(kind, path, width, height, duration_ms, poster_path, created_at))')
            .eq('owner_id', userId)
            .order('created_at');
        return [
          for (final r in rows)
            () {
              // RLS leaves out stories the viewer may not see; covers come from what is left.
              final stories = [
                for (final h in r['highlight_stories'] as List)
                  if ((h as Map)['stories'] != null) (h['stories'] as Map).cast<String, dynamic>(),
              ]..sort((a, b) => (b['created_at'] as String).compareTo(a['created_at'] as String));
              return Highlight(
                id: r['id'] as String,
                ownerId: r['owner_id'] as String,
                title: r['title'] as String,
                cover: stories.isEmpty ? null : _map.media(stories.first),
                storyCount: stories.length,
              );
            }(),
        ];
      });

  @override
  Future<Result<List<Story>>> highlightStories(String highlightId) => runFeed(() async {
        final rows = await _client
            .from('highlight_stories')
            .select('stories($_columns)')
            .eq('highlight_id', highlightId);
        final stories = [
          for (final r in rows)
            if (r['stories'] != null) (r['stories'] as Map).cast<String, dynamic>(),
        ]..sort((a, b) => (a['created_at'] as String).compareTo(b['created_at'] as String));
        return _stories(stories);
      });

  static String _title(String title) {
    final t = title.trim();
    if (t.isEmpty || t.length > 30) throw RuleFailure('feed.invalid_highlight', feedL10n.highlightTitleLength);
    return t;
  }

  @override
  Future<Result<String>> createHighlight(String title, List<String> storyIds) => runFeed(() async {
        final name = _title(title);
        if (storyIds.isEmpty) throw RuleFailure('feed.empty_highlight', feedL10n.pickStory);
        final id = randomUuid();
        await _client.from('highlights').insert({'id': id, 'owner_id': _me, 'title': name});
        await _client.from('highlight_stories').insert([for (final s in storyIds) {'highlight_id': id, 'story_id': s}]);
        return id;
      });

  @override
  Future<Result<void>> renameHighlight(String id, String title) => runFeed(() async {
        await _client.from('highlights').update({'title': _title(title)}).eq('id', id);
      });

  @override
  Future<Result<void>> deleteHighlight(String id) => runFeed(() async {
        await _client.from('highlights').delete().eq('id', id);
      });

  @override
  Future<Result<void>> addToHighlight(String id, List<String> storyIds) => runFeed(() async {
        if (storyIds.isEmpty) return;
        await _client
            .from('highlight_stories')
            .upsert([for (final s in storyIds) {'highlight_id': id, 'story_id': s}], ignoreDuplicates: true);
      });

  @override
  Future<Result<void>> removeFromHighlight(String id, String storyId) => runFeed(() async {
        await _client.from('highlight_stories').delete().eq('highlight_id', id).eq('story_id', storyId);
      });
}
