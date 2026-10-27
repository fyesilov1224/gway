import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/matching.dart';

/// The profile and photos are the user's own writes under RLS; swipes, ending a match and
/// deleting everything go through the API (docs/ARCHITECTURE.md §3g).
class MatchingRepositoryImpl implements MatchingRepository {
  MatchingRepositoryImpl(this._client, this._api);

  final SupabaseClient _client;
  final ApiClient _api;

  static const _bucket = 'match-photos';
  static const _urlLifetime = Duration(hours: 1);

  String get _me => _client.auth.currentUser?.id ?? (throw const UnauthorizedFailure());

  Future<Result<T>> _run<T>(Future<T> Function() action) async {
    try {
      return Ok(await action());
    } on Failure catch (f) {
      return Err(f);
    } on Object catch (e) {
      return Err(failureFromSupabase(e));
    }
  }

  /// Signed addresses for private photos, in the same order; a missing one is empty.
  Future<List<String>> _urls(List<String> paths) async {
    if (paths.isEmpty) return const [];
    final signed = await _client.storage.from(_bucket).createSignedUrlsResult(paths, _urlLifetime.inSeconds);
    final byPath = {
      for (final s in signed)
        if (s case SignedUrlSuccess(:final path, :final signedUrl)) path: signedUrl,
    };
    return [for (final p in paths) byPath[p] ?? ''];
  }

  @override
  Future<Result<MatchProfile?>> myProfile() => _run(() async {
        final row = await _client.from('match_profiles').select().eq('user_id', _me).maybeSingle();
        if (row == null) return null;
        final photoRows = await _client.from('match_photos').select('id, path, position').eq('user_id', _me).order('position');
        final urls = await _urls([for (final p in photoRows) p['path'] as String]);
        return MatchProfile(
          draft: MatchProfileDraft(
            birthDate: DateTime.parse(row['birth_date'] as String),
            gender: MatchGender.parse(row['gender']),
            province: row['province'] as int,
            about: row['about'] as String,
            job: row['job'] as String,
            education: row['education'] as String,
            friend: row['friend'] as bool,
            dating: row['dating'] as bool,
            interestedIn: {for (final g in (row['interested_in'] as List).cast<String>()) MatchGender.parse(g)},
            ageMin: row['age_min'] as int,
            ageMax: row['age_max'] as int,
          ),
          photos: [
            for (final (i, p) in photoRows.indexed)
              MatchPhoto(id: p['id'] as String, path: p['path'] as String, position: p['position'] as int, url: urls[i]),
          ],
          paused: row['paused'] as bool,
          suspendedUntil: switch (row['suspended_until']) {
            // Postgres "infinity" is the platform's permanent suspension.
            'infinity' => DateTime(9999),
            final String at => DateTime.parse(at),
            _ => null,
          },
        );
      });

  @override
  Future<Result<void>> saveProfile(MatchProfileDraft d, {required bool create}) => _run(() async {
        final values = {
          'birth_date': '${d.birthDate.year.toString().padLeft(4, '0')}-${d.birthDate.month.toString().padLeft(2, '0')}-'
              '${d.birthDate.day.toString().padLeft(2, '0')}',
          'gender': d.gender.code,
          'province': d.province,
          'about': d.about.trim(),
          'job': d.job.trim(),
          'education': d.education.trim(),
          'friend': d.friend,
          'dating': d.dating,
          'interested_in': d.dating ? [for (final g in d.interestedIn) g.code] : <String>[],
          'age_min': d.ageMin,
          'age_max': d.ageMax,
          'consent_version': matchConsentVersion,
        };
        if (create) {
          await _client.from('match_profiles').insert({'user_id': _me, ...values});
        } else {
          await _client.from('match_profiles').update(values).eq('user_id', _me);
        }
      });

  @override
  Future<Result<void>> setPaused(bool paused) => _run(() async {
        await _client.from('match_profiles').update({'paused': paused}).eq('user_id', _me);
      });

  @override
  Future<Result<void>> addPhoto(ImageUpload image, int position) => _run(() async {
        final type = image.contentType ?? (throw const RuleFailure('match.photo_type', 'Yalnızca JPEG, PNG ya da WebP fotoğraf yüklenebilir.'));
        final path = '$_me/${DateTime.now().microsecondsSinceEpoch}.${image.extension}';
        await _client.storage.from(_bucket).uploadBinary(path, image.bytes, fileOptions: FileOptions(contentType: type));
        try {
          await _client.from('match_photos').insert({'user_id': _me, 'path': path, 'position': position});
        } on Object {
          await _client.storage.from(_bucket).remove([path]);
          rethrow;
        }
      });

  @override
  Future<Result<void>> removePhoto(MatchPhoto photo) => _run(() async {
        await _client.from('match_photos').delete().eq('id', photo.id);
        await _client.storage.from(_bucket).remove([photo.path]);
      });

  @override
  Future<Result<void>> makeCover(MatchPhoto photo, MatchPhoto cover) => _run(() async {
        // The position constraint is checked at commit, so the swap is one statement.
        await _client.rpc<void>('swap_match_photos', params: {'first': photo.id, 'second': cover.id});
      });

  MatchCard _card(Map<String, dynamic> j, List<String> urls) => MatchCard(
        userId: j['user_id'] as String,
        displayName: j['display_name'] as String,
        age: j['age'] as int,
        gender: MatchGender.parse(j['gender']),
        province: j['province'] as int,
        about: j['about'] as String,
        job: j['job'] as String,
        education: j['education'] as String,
        photoUrls: urls,
        photoIds: [for (final p in (j['photos'] as List).cast<Map<String, dynamic>>()) p['id'] as String],
        interests: (j['interests'] as List).cast<String>(),
        sharedInterests: {...(j['shared_interests'] as List).cast<String>()},
        sharedGroups: [
          for (final g in (j['shared_groups'] as List).cast<Map<String, dynamic>>()) (name: g['name'] as String, handle: g['handle'] as String),
        ],
        superLikedMe: j['super_liked_me'] as bool? ?? false,
      );

  /// Cards with their photos signed in one call.
  Future<List<(Map<String, dynamic>, MatchCard)>> _cards(List<dynamic> rows) async {
    final maps = [for (final r in rows) (r as Map).cast<String, dynamic>()];
    final paths = [
      for (final m in maps)
        for (final p in (m['photos'] as List).cast<Map<String, dynamic>>()) p['path'] as String,
    ];
    final urls = await _urls(paths);
    var i = 0;
    return [
      for (final m in maps)
        (m, _card(m, [for (final _ in m['photos'] as List) urls[i++]])),
    ];
  }

  @override
  Future<Result<List<MatchCard>>> deck(MatchMode mode, {MatchFilters filters = const MatchFilters()}) => _run(() async {
        final rows = await _client.rpc<List<dynamic>>('match_deck', params: {
          'deck': mode.code,
          'page_size': 20,
          'min_age': filters.minAge,
          'max_age': filters.maxAge,
          'in_province': filters.province,
          'with_interest': filters.interest,
        });
        return [for (final (_, card) in await _cards(rows)) card];
      });

  @override
  Future<Result<MatchStatus>> status() => _run(() async {
        final j = (await _client.rpc<Map<String, dynamic>>('match_status')).cast<String, Object?>();
        final admirers = (j['admirers']! as Map).cast<String, Object?>();
        DateTime? at(Object? v) => v is String ? DateTime.parse(v) : null;
        return MatchStatus(
          features: {for (final f in (j['features']! as List)) ?MatchFeature.parse(f)},
          fullAccess: j['full_access'] == true,
          packages: {
            for (final MapEntry(:key, :value) in (j['packages']! as Map).cast<String, Object?>().entries)
              if ((MatchPackage.bySlug(key), at(value)) case (final p?, final until?)) p: until,
          },
          likesLeft: j['likes_left'] as int?,
          superLikesLeft: j['super_likes_left']! as int,
          boostEndsAt: at(j['boost_ends_at']),
          boostUsedToday: j['boost_used_today']! as bool,
          boostMinutes: j['boost_minutes']! as int,
          admirers: {for (final m in MatchMode.values) m: admirers[m.code] as int? ?? 0},
        );
      });

  @override
  Future<Result<SwipeOutcome>> swipe(String userId, MatchMode mode, SwipeKind kind) => _api.post(
        '/matching/swipes',
        body: {'targetId': userId, 'mode': mode.code, 'like': kind != SwipeKind.pass, 'super': kind == SwipeKind.superLike},
        decode: (json) {
          final j = (json! as Map).cast<String, Object?>();
          return SwipeOutcome(
            matched: j['matched']! as bool,
            matchId: j['matchId'] as String?,
            likesLeft: j['likesLeft'] as int?,
            superLikesLeft: j['superLikesLeft']! as int,
          );
        },
      );

  @override
  Future<Result<Rewound>> rewind() => _api.post('/matching/rewind', decode: (json) {
        final j = (json! as Map).cast<String, Object?>();
        return (userId: j['targetId']! as String, mode: j['mode'] == 'dating' ? MatchMode.dating : MatchMode.friend);
      });

  @override
  Future<Result<DateTime>> boost() =>
      _api.post('/matching/boost', decode: (json) => DateTime.parse((json! as Map)['endsAt']! as String));

  @override
  Future<Result<List<MatchCard>>> admirers(MatchMode mode) => _run(() async {
        final rows = await _client.rpc<List<dynamic>>('match_admirers', params: {'deck': mode.code});
        return [for (final (_, card) in await _cards(rows)) card];
      });

  @override
  Future<Result<List<MatchSummary>>> matches() => _run(() async {
        final rows = [for (final r in await _client.rpc<List<dynamic>>('my_matches')) (r as Map).cast<String, dynamic>()];
        // Locked matches (no reveal) carry no card.
        final cards = {for (final (m, card) in await _cards([for (final r in rows) if (r['locked'] != true) r])) m['user_id']: card};
        return [
          for (final m in rows)
            MatchSummary(
              modes: {
                for (final x in (m['modes'] as List).cast<Map<String, dynamic>>())
                  (x['mode'] == 'dating' ? MatchMode.dating : MatchMode.friend): x['match_id'] as String,
              },
              matchedAt: DateTime.parse(m['matched_at'] as String),
              username: m['username'] as String?,
              card: cards[m['user_id']],
            ),
        ];
      });

  @override
  Future<Result<void>> endMatch(String matchId) => _api.delete('/matching/matches/$matchId', decode: (_) {});

  @override
  Future<Result<String>> openChat(String userId) =>
      _api.post('/messages/direct/$userId', decode: (json) => (json! as Map)['id']! as String);

  @override
  Future<Result<void>> block(String userId) => _api.post('/users/$userId/block', decode: (_) {});

  @override
  Future<Result<void>> deleteAll() => _api.delete('/me/matching', decode: (_) {});
}
