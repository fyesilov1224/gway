import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/profile.dart';

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._client);

  final SupabaseClient _client;

  static const _columns =
      'id, username, display_name, bio, avatar_path, cover_path, created_at, username_changed_at, is_private, groups_public';

  String? get _userId => _client.auth.currentUser?.id;

  @override
  Future<Result<Profile?>> mine() async {
    final id = _userId;
    if (id == null) return const Err(UnauthorizedFailure());
    return _run(() async {
      final row = await _client.from('profiles').select(_columns).eq('id', id).maybeSingle();
      return row == null ? null : _toProfile(row);
    });
  }

  @override
  Future<Result<Profile>> byUsername(String username) => _run(() async {
        final row = await _client
            .from('profiles')
            .select(_columns)
            .eq('username', username.toLowerCase())
            .maybeSingle();
        if (row == null) throw const NotFoundFailure();
        return _toProfile(row);
      });

  @override
  Future<Result<bool>> isUsernameAvailable(String username) => _run(
        () => _client.rpc<bool>('is_username_available', params: {'name': username}),
      );

  @override
  Future<Result<void>> create(ProfileDraft draft) async {
    final id = _userId;
    if (id == null) return const Err(UnauthorizedFailure());
    return _run(() async {
      final avatar = draft.avatar;
      final avatarPath = avatar == null ? null : await _upload(id, ProfileImage.avatar, avatar);
      await _client.from('profiles').insert({
        'id': id,
        'username': draft.username,
        'display_name': draft.displayName,
        'bio': draft.bio,
        'avatar_path': avatarPath,
      });
      if (draft.interests.isNotEmpty) {
        await _client.from('profile_interests').insert([
          for (final slug in draft.interests) {'user_id': id, 'category_slug': slug},
        ]);
      }
    });
  }

  @override
  Future<Result<void>> update({
    required String username,
    required String displayName,
    required String bio,
  }) async {
    final id = _userId;
    if (id == null) return const Err(UnauthorizedFailure());
    return _run(
      () => _client
          .from('profiles')
          .update({'username': username, 'display_name': displayName, 'bio': bio})
          .eq('id', id),
    );
  }

  @override
  Future<Result<void>> setImage(ProfileImage kind, ImageUpload upload) async {
    final id = _userId;
    if (id == null) return const Err(UnauthorizedFailure());
    return _run(() async {
      final old = await _currentPath(id, kind);
      final path = await _upload(id, kind, upload);
      await _client.from('profiles').update({_column(kind): path}).eq('id', id);
      if (old != null) await _client.storage.from(kind.bucket).remove([old]);
    });
  }

  @override
  Future<Result<void>> removeImage(ProfileImage kind) async {
    final id = _userId;
    if (id == null) return const Err(UnauthorizedFailure());
    return _run(() async {
      final old = await _currentPath(id, kind);
      await _client.from('profiles').update({_column(kind): null}).eq('id', id);
      if (old != null) await _client.storage.from(kind.bucket).remove([old]);
    });
  }

  @override
  Future<Result<List<String>>> interests(String userId) => _run(() async {
        final rows = await _client
            .from('profile_interests')
            .select('category_slug')
            .eq('user_id', userId);
        return [for (final r in rows) r['category_slug'] as String];
      });

  @override
  Future<Result<void>> setInterests(List<String> slugs) async {
    final id = _userId;
    if (id == null) return const Err(UnauthorizedFailure());
    return _run(() async {
      final current = (await interests(id)).getOrThrow().toSet();
      final wanted = slugs.toSet();
      final removed = current.difference(wanted);
      final added = wanted.difference(current);
      // Delete first so swapping interests never hits the limit.
      if (removed.isNotEmpty) {
        await _client
            .from('profile_interests')
            .delete()
            .eq('user_id', id)
            .inFilter('category_slug', removed.toList());
      }
      if (added.isNotEmpty) {
        await _client.from('profile_interests').insert([
          for (final slug in added) {'user_id': id, 'category_slug': slug},
        ]);
      }
    });
  }

  // -------------------------------------------------------------------------

  static String _column(ProfileImage kind) => switch (kind) {
        ProfileImage.avatar => 'avatar_path',
        ProfileImage.cover => 'cover_path',
      };

  Future<String?> _currentPath(String id, ProfileImage kind) async {
    final row = await _client.from('profiles').select(_column(kind)).eq('id', id).single();
    return row[_column(kind)] as String?;
  }

  Future<String> _upload(String userId, ProfileImage kind, ImageUpload upload) async {
    final contentType = upload.contentType;
    if (contentType == null) {
      throw const RuleFailure(
        'storage.unsupported_type',
        'Bu dosya türü desteklenmiyor. JPEG, PNG veya WebP seç.',
      );
    }
    // A new name per upload avoids stale cached images.
    final path = '$userId/${kind.name}-${DateTime.now().millisecondsSinceEpoch}.${upload.extension}';
    await _client.storage.from(kind.bucket).uploadBinary(
          path,
          upload.bytes,
          fileOptions: FileOptions(contentType: contentType, cacheControl: '31536000'),
        );
    return path;
  }

  Profile _toProfile(Map<String, dynamic> row) {
    String? url(ProfileImage kind, Object? path) =>
        path is String ? _client.storage.from(kind.bucket).getPublicUrl(path) : null;
    return Profile(
      id: row['id'] as String,
      username: row['username'] as String,
      displayName: row['display_name'] as String,
      bio: row['bio'] as String,
      avatarUrl: url(ProfileImage.avatar, row['avatar_path']),
      coverUrl: url(ProfileImage.cover, row['cover_path']),
      createdAt: DateTime.parse(row['created_at'] as String),
      isPrivate: row['is_private'] as bool? ?? false,
      groupsPublic: row['groups_public'] as bool? ?? false,
      usernameChangedAt: row['username_changed_at'] == null
          ? null
          : DateTime.parse(row['username_changed_at'] as String),
    );
  }

  Future<Result<T>> _run<T>(Future<T> Function() action) async {
    try {
      return Ok(await action());
    } on Failure catch (f) {
      return Err(f);
    } on Object catch (e) {
      return Err(failureFromProfile(e));
    }
  }
}

/// Database rule violations from 0002_identity_profile.sql → Turkish messages.
Failure failureFromProfile(Object error) {
  if (error is PostgrestException) {
    RuleFailure rule(String code, String message) => RuleFailure('profile.$code', message);
    switch (error.code) {
      case '23505':
        return rule('username_taken', 'Bu kullanıcı adı alınmış. Başka bir tane dene.');
      case '23514':
        return rule('invalid', 'Girdiğin bilgileri kontrol et.');
      case 'P0001':
        switch (error.message) {
          case 'username_reserved':
            return rule('username_reserved', 'Bu kullanıcı adı kullanılamaz. Başka bir tane dene.');
          case 'username_change_too_soon':
            return rule('username_change_too_soon', 'Kullanıcı adını 30 günde yalnızca bir kez değiştirebilirsin.');
          case 'interest_limit_reached':
            return rule('interest_limit_reached', 'En fazla 10 ilgi alanı seçebilirsin.');
        }
    }
  }
  return failureFromSupabase(error);
}
