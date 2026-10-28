import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/social.dart';

/// Reads through Supabase (RLS); follow and block writes through the C# API (docs/ARCHITECTURE.md §3c).
class SocialRepositoryImpl implements SocialRepository {
  SocialRepositoryImpl(this._client, this._api);

  final SupabaseClient _client;
  final ApiClient _api;

  static const _personColumns = 'id, username, display_name, avatar_path, is_private';

  String? get _me => _client.auth.currentUser?.id;

  Future<Result<T>> _read<T>(Future<T> Function() query) async {
    try {
      return Ok(await query());
    } on Failure catch (f) {
      return Err(f);
    } on Object catch (e) {
      return Err(failureFromSupabase(e));
    }
  }

  String? _avatar(Object? path) => path is String ? _client.storage.from('avatars').getPublicUrl(path) : null;

  PersonSummary _person(Map<String, dynamic> r, {FollowState follow = FollowState.none, bool followsMe = false}) => PersonSummary(
        id: r['id'] as String,
        username: r['username'] as String,
        displayName: r['display_name'] as String,
        avatarUrl: _avatar(r['avatar_path']),
        isPrivate: r['is_private'] as bool? ?? false,
        follow: follow,
        followsMe: followsMe,
        mutualCount: (r['mutual_count'] as num?)?.toInt() ?? 0,
      );

  static FollowState _state(Map<String, dynamic> r) => r['i_follow'] == true
      ? FollowState.following
      : r['requested'] == true
          ? FollowState.requested
          : FollowState.none;

  @override
  Future<Result<ProfileSocial>> social(String userId) => _read(() async {
        final rows = await _client.rpc<List<dynamic>>('profile_social', params: {'target': userId});
        if (rows.isEmpty) throw const NotFoundFailure();
        final r = (rows.first as Map).cast<String, dynamic>();
        return ProfileSocial(
          postCount: (r['post_count'] as num).toInt(),
          followerCount: (r['follower_count'] as num).toInt(),
          followingCount: (r['following_count'] as num).toInt(),
          isPrivate: r['is_private'] as bool,
          follow: _state(r),
          followsMe: r['follows_me'] as bool,
          blockedByMe: r['blocked_by_me'] as bool,
          canView: r['can_view'] as bool,
        );
      });

  @override
  Future<Result<FollowState>> follow(String userId) => _api.post(
        '/users/$userId/follow',
        decode: (json) => (json! as Map)['status'] == 'requested' ? FollowState.requested : FollowState.following,
      );

  @override
  Future<Result<void>> unfollow(String userId) => _api.delete('/users/$userId/follow', decode: (_) {});

  @override
  Future<Result<void>> acceptRequest(String userId) => _api.post('/me/follow-requests/$userId/approval', decode: (_) {});

  @override
  Future<Result<void>> rejectRequest(String userId) => _api.delete('/me/follow-requests/$userId', decode: (_) {});

  @override
  Future<Result<void>> removeFollower(String userId) => _api.delete('/me/followers/$userId', decode: (_) {});

  @override
  Future<Result<void>> block(String userId) => _api.post('/users/$userId/block', decode: (_) {});

  @override
  Future<Result<void>> unblock(String userId) => _api.delete('/users/$userId/block', decode: (_) {});

  /// Follow lists with the viewer's own relation to each person.
  @override
  Future<Result<List<PersonSummary>>> list(String userId, FollowList list) => _read(() async {
        final (column, other) = list == FollowList.followers ? ('followee_id', 'follower_id') : ('follower_id', 'followee_id');
        final rows = await _client
            .from('follows')
            .select('created_at, person:profiles!follows_${other}_fkey($_personColumns)')
            .eq(column, userId)
            .order('created_at', ascending: false)
            .limit(500);
        final people = [for (final r in rows) if (r['person'] != null) (r['person'] as Map).cast<String, dynamic>()];
        return _withRelations(people);
      });

  /// Adds whether the viewer follows / was asked by / is followed by each person.
  Future<List<PersonSummary>> _withRelations(List<Map<String, dynamic>> people) async {
    final me = _me;
    if (me == null || people.isEmpty) return [for (final p in people) _person(p)];
    final ids = [for (final p in people) p['id'] as String];
    final following = {
      for (final r in await _client.from('follows').select('followee_id').eq('follower_id', me).inFilter('followee_id', ids))
        r['followee_id'] as String,
    };
    final followers = {
      for (final r in await _client.from('follows').select('follower_id').eq('followee_id', me).inFilter('follower_id', ids))
        r['follower_id'] as String,
    };
    final requested = {
      for (final r in await _client.from('follow_requests').select('target_id').eq('requester_id', me).inFilter('target_id', ids))
        r['target_id'] as String,
    };
    return [
      for (final p in people)
        _person(
          p,
          follow: following.contains(p['id'])
              ? FollowState.following
              : requested.contains(p['id'])
                  ? FollowState.requested
                  : FollowState.none,
          followsMe: followers.contains(p['id']),
        ),
    ];
  }

  @override
  Future<Result<List<PersonSummary>>> requests() => _read(() async {
        final me = _me ?? (throw const UnauthorizedFailure());
        final rows = await _client
            .from('follow_requests')
            .select('created_at, person:profiles!follow_requests_requester_id_fkey($_personColumns)')
            .eq('target_id', me)
            .order('created_at', ascending: false);
        return _withRelations([for (final r in rows) if (r['person'] != null) (r['person'] as Map).cast<String, dynamic>()]);
      });

  @override
  Future<Result<List<PersonSummary>>> blocked() => _read(() async {
        final me = _me ?? (throw const UnauthorizedFailure());
        final rows = await _client
            .from('blocks')
            .select('created_at, person:profiles!blocks_blocked_id_fkey($_personColumns)')
            .eq('blocker_id', me)
            .order('created_at', ascending: false);
        return [for (final r in rows) if (r['person'] != null) _person((r['person'] as Map).cast<String, dynamic>())];
      });

  @override
  Future<Result<List<PersonSummary>>> search(String query) => _read(() async {
        final rows = await _client.rpc<List<dynamic>>('search_profiles', params: {'query': query, 'max_results': 30});
        return [
          for (final r in rows.cast<Map<String, dynamic>>()) _person(r, follow: _state(r), followsMe: r['follows_me'] == true),
        ];
      });

  @override
  Future<Result<List<PersonSummary>>> suggestions() => _read(() async {
        final rows = await _client.rpc<List<dynamic>>('suggested_profiles', params: {'max_results': 15});
        return [for (final r in rows.cast<Map<String, dynamic>>()) _person(r)];
      });

  @override
  Future<Result<void>> setPrivate(bool isPrivate) => _read(() async {
        final me = _me ?? (throw const UnauthorizedFailure());
        await _client.from('profiles').update({'is_private': isPrivate}).eq('id', me);
      });

  @override
  Future<Result<void>> setGroupsPublic(bool value) => _read(() async {
        final me = _me ?? (throw const UnauthorizedFailure());
        await _client.from('profiles').update({'groups_public': value}).eq('id', me);
      });
}
