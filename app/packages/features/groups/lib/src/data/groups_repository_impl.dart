import 'dart:async';

import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/group.dart';

/// Reads from Supabase (RLS), writes through the C# API (docs/ARCHITECTURE.md §2, §3b).
class GroupsRepositoryImpl implements GroupsRepository {
  GroupsRepositoryImpl(this._client, this._api);

  final SupabaseClient _client;
  final ApiClient _api;

  static const bucket = 'group-images';

  static const _columns =
      'id, handle, name, category_slug, join_policy, about, rules, links, logo_path, cover_path, owner_id, member_count, status, created_at';
  static const _person = 'username, display_name, avatar_path';

  String? get _userId => _client.auth.currentUser?.id;

  // Reads -------------------------------------------------------------------

  @override
  Future<Result<List<Group>>> discover({String query = '', String? categorySlug, required int limit}) => _read(() async {
        var request = _client.from('groups').select(_columns).eq('status', 'active');
        if (categorySlug != null) request = request.eq('category_slug', categorySlug);
        // PostgREST filter syntax reserves these characters; they never occur in names worth matching.
        final term = query.replaceAll(RegExp(r'[,()*%\\:"]'), ' ').trim();
        if (term.isNotEmpty) request = request.or('name.ilike.*$term*,handle.ilike.*$term*');
        final rows = await request
            .order('member_count', ascending: false)
            .order('created_at', ascending: false)
            .limit(limit);
        return [for (final r in rows) _toGroup(r)];
      });

  @override
  Future<Result<List<Group>>> groupsOf(String userId) => _read(() async {
        final rows = await _client
            .from('group_members')
            .select('joined_at, groups!inner($_columns)')
            .eq('user_id', userId)
            .order('joined_at', ascending: false);
        return [for (final r in rows) _toGroup((r['groups'] as Map).cast())];
      });

  @override
  Future<Result<Group>> byHandle(String handle) => _read(() async {
        final row = await _client.from('groups').select(_columns).eq('handle', handle.toLowerCase()).maybeSingle();
        if (row == null) throw const NotFoundFailure();
        return _toGroup(row);
      });

  @override
  Future<Result<bool>> isHandleAvailable(String handle) =>
      _read(() => _client.rpc<bool>('is_group_handle_available', params: {'name': handle}));

  @override
  Future<Result<MyMembership>> myMembership(String groupId) async {
    final me = _userId;
    if (me == null) return const Ok(MyMembership());
    return _read(() async {
      Future<bool> exists(String table) async =>
          (await _client.from(table).select('user_id').eq('group_id', groupId).eq('user_id', me).maybeSingle()) != null;

      final (permissions, roles, isMember, requested, invited, following) = await (
        _client.rpc<List<dynamic>>('my_group_permissions', params: {'target_group': groupId}),
        _client.from('group_member_roles').select('role').eq('group_id', groupId).eq('user_id', me),
        exists('group_members'),
        exists('group_join_requests'),
        exists('group_invitations'),
        exists('group_follows'),
      ).wait;
      return MyMembership(
        isMember: isMember,
        roles: _sortRoles([for (final r in roles) ?GroupRole.tryParse(r['role'])]),
        permissions: permissions.cast<String>().toSet(),
        hasPendingRequest: requested,
        hasInvitation: invited,
        isFollowing: following,
      );
    });
  }

  @override
  Future<Result<List<GroupPerson>>> members(String groupId, {required String ownerId}) => _read(() async {
        final (rows, roleRows) = await (
          _client
              .from('group_members')
              .select('user_id, joined_at, profiles!inner($_person)')
              .eq('group_id', groupId)
              .order('joined_at', ascending: true),
          _client.from('group_member_roles').select('user_id, role').eq('group_id', groupId),
        ).wait;
        final assigned = <String, List<GroupRole>>{};
        for (final r in roleRows) {
          final role = GroupRole.tryParse(r['role']);
          if (role != null) (assigned[r['user_id'] as String] ??= []).add(role);
        }
        final people = [
          for (final r in rows)
            _toPerson(r, roles: [
              if (r['user_id'] == ownerId) GroupRole.owner,
              ...?assigned[r['user_id']],
              GroupRole.member,
            ], since: r['joined_at']),
        ];
        // Highest rank first; within a rank, earliest member first.
        int byJoin(GroupPerson a, GroupPerson b) => (a.since ?? DateTime(0)).compareTo(b.since ?? DateTime(0));
        return people
          ..sort((a, b) => b.topRole.rank != a.topRole.rank ? b.topRole.rank.compareTo(a.topRole.rank) : byJoin(a, b));
      });

  @override
  Future<Result<List<GroupPerson>>> joinRequests(String groupId) => _read(() async {
        final rows = await _client
            .from('group_join_requests')
            .select('user_id, created_at, profiles!inner($_person)')
            .eq('group_id', groupId)
            .order('created_at', ascending: true);
        return [for (final r in rows) _toPerson(r, roles: const [], since: r['created_at'])];
      });

  @override
  Future<Result<List<GroupPerson>>> invitations(String groupId) => _read(() async {
        final rows = await _client
            .from('group_invitations')
            .select('user_id, created_at, profiles:profiles!group_invitations_user_id_fkey!inner($_person)')
            .eq('group_id', groupId)
            .order('created_at', ascending: false);
        return [for (final r in rows) _toPerson(r, roles: const [], since: r['created_at'])];
      });

  @override
  Future<Result<List<GroupInvitation>>> myInvitations() async {
    final me = _userId;
    if (me == null) return const Ok([]);
    return _read(() async {
      final rows = await _client
          .from('group_invitations')
          .select('created_at, groups!inner($_columns), inviter:profiles!group_invitations_invited_by_fkey(display_name)')
          .eq('user_id', me)
          .order('created_at', ascending: false);
      return [
        for (final r in rows)
          GroupInvitation(
            group: _toGroup((r['groups'] as Map).cast()),
            createdAt: DateTime.parse(r['created_at'] as String),
            invitedBy: (r['inviter'] as Map?)?['display_name'] as String?,
          ),
      ];
    });
  }

  // Writes (C# API) -----------------------------------------------------------

  @override
  Future<Result<String>> create(GroupDraft draft) => _api.post(
        '/groups',
        body: {
          'handle': draft.handle,
          'name': draft.name,
          'categorySlug': draft.categorySlug,
          'joinPolicy': draft.joinPolicy.code,
          'about': draft.about,
        },
        decode: (json) => (json! as Map)['handle']! as String,
      );

  @override
  Future<Result<void>> update(String groupId, GroupUpdate update) =>
      _api.patch('/groups/$groupId', body: update.toJson(), decode: (_) {});

  @override
  Future<Result<void>> setImage(Group group, GroupImage kind, ImageUpload upload) async {
    final contentType = upload.contentType;
    if (contentType == null) {
      return const Err(RuleFailure('storage.unsupported_type', 'Bu dosya türü desteklenmiyor. JPEG, PNG veya WebP seç.'));
    }
    // A new name per upload avoids stale cached images.
    final path = '${group.id}/${kind.name}-${DateTime.now().millisecondsSinceEpoch}.${upload.extension}';
    try {
      await _client.storage.from(bucket).uploadBinary(
            path,
            upload.bytes,
            fileOptions: FileOptions(contentType: contentType, cacheControl: '31536000'),
          );
    } on Object catch (e) {
      return Err(failureFromSupabase(e));
    }
    final result = await _api.patch('/groups/${group.id}', body: {_field(kind): path}, decode: (_) {});
    await _removeFile(result is Ok ? _path(group, kind) : path);
    return result;
  }

  @override
  Future<Result<void>> removeImage(Group group, GroupImage kind) async {
    final result = await _api.patch('/groups/${group.id}', body: {_field(kind): ''}, decode: (_) {});
    if (result is Ok) await _removeFile(_path(group, kind));
    return result;
  }

  @override
  Future<Result<void>> delete(String groupId) => _api.delete('/groups/$groupId', decode: (_) {});

  @override
  Future<Result<JoinOutcome>> join(String groupId) => _api.post(
        '/groups/$groupId/join',
        decode: (json) => (json! as Map)['status'] == 'requested' ? JoinOutcome.requested : JoinOutcome.member,
      );

  @override
  Future<Result<void>> cancelRequest(String groupId) => _api.delete('/groups/$groupId/join-request', decode: (_) {});

  @override
  Future<Result<void>> leave(String groupId) => _api.delete('/groups/$groupId/membership', decode: (_) {});

  @override
  Future<Result<void>> declineInvitation(String groupId) => _api.delete('/groups/$groupId/invitation', decode: (_) {});

  @override
  Future<Result<void>> setFollowing(String groupId, bool follow) => _read(() async {
        final me = _userId ?? (throw const UnauthorizedFailure());
        final table = _client.from('group_follows');
        follow
            ? await table.upsert({'user_id': me, 'group_id': groupId}, ignoreDuplicates: true)
            : await table.delete().eq('user_id', me).eq('group_id', groupId);
      });

  @override
  Future<Result<void>> approve(String groupId, String userId) =>
      _api.post('/groups/$groupId/join-requests/$userId/approval', decode: (_) {});

  @override
  Future<Result<void>> reject(String groupId, String userId) =>
      _api.delete('/groups/$groupId/join-requests/$userId', decode: (_) {});

  @override
  Future<Result<void>> invite(String groupId, String username) =>
      _api.post('/groups/$groupId/invitations', body: {'username': username}, decode: (_) {});

  @override
  Future<Result<void>> revokeInvitation(String groupId, String userId) =>
      _api.delete('/groups/$groupId/invitations/$userId', decode: (_) {});

  @override
  Future<Result<void>> assignRole(String groupId, String userId, GroupRole role) =>
      _api.put('/groups/$groupId/members/$userId/roles/${role.code}', decode: (_) {});

  @override
  Future<Result<void>> removeRole(String groupId, String userId, GroupRole role) =>
      _api.delete('/groups/$groupId/members/$userId/roles/${role.code}', decode: (_) {});

  @override
  Future<Result<void>> transferOwnership(String groupId, String userId) =>
      _api.post('/groups/$groupId/ownership', body: {'userId': userId}, decode: (_) {});

  // ---------------------------------------------------------------------------

  static String _field(GroupImage kind) => switch (kind) {
        GroupImage.logo => 'logoPath',
        GroupImage.cover => 'coverPath',
      };

  static String? _path(Group group, GroupImage kind) => switch (kind) {
        GroupImage.logo => group.logoPath,
        GroupImage.cover => group.coverPath,
      };

  /// Best effort: a leftover file only costs storage.
  Future<void> _removeFile(String? path) async {
    if (path == null) return;
    try {
      await _client.storage.from(bucket).remove([path]);
    } on Object {
      // Ignored on purpose.
    }
  }

  static List<GroupRole> _sortRoles(List<GroupRole> roles) => roles..sort((a, b) => b.rank.compareTo(a.rank));

  String? _url(Object? path) => path is String ? _client.storage.from(bucket).getPublicUrl(path) : null;

  Group _toGroup(Map<String, dynamic> row) => Group(
        id: row['id'] as String,
        handle: row['handle'] as String,
        name: row['name'] as String,
        categorySlug: row['category_slug'] as String,
        joinPolicy: JoinPolicy.parse(row['join_policy']),
        ownerId: row['owner_id'] as String,
        memberCount: row['member_count'] as int,
        createdAt: DateTime.parse(row['created_at'] as String),
        about: row['about'] as String? ?? '',
        rules: row['rules'] as String? ?? '',
        links: [
          for (final l in (row['links'] as List? ?? const []).cast<Map<String, dynamic>>())
            GroupLink(label: l['label'] as String, url: l['url'] as String),
        ],
        logoPath: row['logo_path'] as String?,
        coverPath: row['cover_path'] as String?,
        logoUrl: _url(row['logo_path']),
        coverUrl: _url(row['cover_path']),
        isSuspended: row['status'] == 'suspended',
      );

  GroupPerson _toPerson(Map<String, dynamic> row, {required List<GroupRole> roles, Object? since}) {
    final profile = (row['profiles'] as Map).cast<String, dynamic>();
    final avatar = profile['avatar_path'];
    return GroupPerson(
      userId: row['user_id'] as String,
      username: profile['username'] as String,
      displayName: profile['display_name'] as String,
      avatarUrl: avatar is String ? _client.storage.from('avatars').getPublicUrl(avatar) : null,
      roles: roles,
      since: since is String ? DateTime.parse(since) : null,
    );
  }

  Future<Result<T>> _read<T>(Future<T> Function() action) async {
    try {
      return Ok(await action());
    } on Failure catch (f) {
      return Err(f);
    } on Object catch (e) {
      return Err(failureFromSupabase(e));
    }
  }
}
