import 'dart:math';

import 'package:core/core.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/events.dart';

const coverBucket = 'event-images';

/// Trigger codes users can run into on their own writes (docs/ARCHITECTURE.md §3d).
const _rules = {
  'poll_single_choice': 'Bu ankette tek seçenek işaretlenebilir.',
  'poll_option_invalid': 'Bu seçenek artık yok. Sayfayı yenile.',
  'review_not_allowed': 'Değerlendirme, organizasyona katılanlar için bitişinden sonraki 30 gün açıktır.',
  'greeter_not_allowed': 'Karşılayıcı olmak için grubun bir organizasyonuna katılmış olmalısın.',
};

Failure _failure(Object error) => switch (error) {
      Failure() => error,
      PostgrestException(code: 'P0001', :final message) when _rules.containsKey(message) => RuleFailure('poll.$message', _rules[message]!),
      PostgrestException(code: '42501') => const RuleFailure('poll.closed', 'Bu anket kapandı ya da oy veremezsin.'),
      StorageException(statusCode: '413') => const RuleFailure('event.cover_too_large', 'Kapak görseli en fazla 5 MB olabilir.'),
      _ => failureFromSupabase(error),
    };

Future<Result<T>> _run<T>(Future<T> Function() action) async {
  try {
    return Ok(await action());
  } on Object catch (e) {
    return Err(_failure(e));
  }
}

class EventsRepositoryImpl implements EventsRepository {
  EventsRepositoryImpl(this._client, this._api);

  final SupabaseClient _client;
  final ApiClient _api;

  String? _url(String bucket, Object? path) => path is String ? _client.storage.from(bucket).getPublicUrl(path) : null;

  DateTime? _time(Object? v) => v is String ? DateTime.parse(v) : null;

  EventPerson _person(Map<String, dynamic> r) => EventPerson(
        id: r['id'] as String,
        username: r['username'] as String,
        displayName: r['display_name'] as String,
        avatarUrl: _url('avatars', r['avatar_path']),
      );

  /// A `private.event_card` object.
  GroupEvent _event(Map<String, dynamic> r) {
    final g = (r['group'] as Map).cast<String, dynamic>();
    final amount = r['fee_amount'] as num?;
    return GroupEvent(
      id: r['id'] as String,
      group: EventGroup(
        id: g['id'] as String,
        handle: g['handle'] as String,
        name: g['name'] as String,
        logoUrl: _url('group-images', g['logo_path']),
      ),
      title: r['title'] as String,
      description: r['description'] as String? ?? '',
      startsAt: DateTime.parse(r['starts_at'] as String),
      endsAt: _time(r['ends_at']),
      location: r['location'] as String,
      linkUrl: r['link_url'] as String?,
      capacity: (r['capacity'] as num?)?.toInt(),
      fee: amount == null ? null : EventFee(amountMinor: amount.toInt(), currency: r['fee_currency'] as String),
      feeNote: r['fee_note'] as String?,
      coverPath: r['cover_path'] as String?,
      coverUrl: _url(coverBucket, r['cover_path']),
      goingCount: (r['going_count'] as num).toInt(),
      waitlistCount: (r['waitlist_count'] as num).toInt(),
      canceledAt: _time(r['canceled_at']),
      cancelReason: r['cancel_reason'] as String?,
      myStatus: AttendanceStatus.tryParse(r['my_status']),
      myPlace: (r['my_place'] as num?)?.toInt(),
      categoryName: (r['category'] as Map?)?['name'] as String?,
      requirements: r['requirements'] as String? ?? '',
      equipment: [for (final e in (r['equipment'] as List? ?? const [])) e as String],
      approvalRequired: r['approval_required'] == true,
      ratingAvg: (r['rating_avg'] as num?)?.toDouble(),
      ratingCount: (r['rating_count'] as num?)?.toInt() ?? 0,
      postsCount: (r['posts_count'] as num?)?.toInt() ?? 0,
      meeting: switch (r['meeting']) {
        {'lat': final num lat, 'lng': final num lng} => LatLng(lat.toDouble(), lng.toDouble()),
        _ => null,
      },
    );
  }

  Poll _poll(Map<String, dynamic> r) => Poll(
        id: r['id'] as String,
        eventId: r['event_id'] as String?,
        question: r['question'] as String,
        allowsMultiple: r['allows_multiple'] as bool,
        isAnonymous: r['is_anonymous'] as bool,
        closesAt: _time(r['closes_at']),
        isOpen: r['is_open'] as bool,
        voters: (r['voters'] as num).toInt(),
        options: [
          for (final o in (r['options'] as List? ?? const []).cast<Map<String, dynamic>>())
            PollOption(id: (o['id'] as num).toInt(), label: o['label'] as String, votes: (o['votes'] as num).toInt(), mine: o['mine'] as bool),
        ],
      );

  // Events --------------------------------------------------------------------------------

  @override
  Future<Result<GroupEvents>> groupEvents(String groupId) => _run(() async {
        final r = await _client.rpc<Map<String, dynamic>>('group_events', params: {'target_group': groupId});
        return GroupEvents(
          events: [for (final e in (r['events'] as List).cast<Map<String, dynamic>>()) _event(e)],
          eventsLeft: (r['events_left'] as num?)?.toInt(),
        );
      });

  @override
  Future<Result<EventDetail>> event(String id) => _run(() async {
        final r = await _client.rpc<Map<String, dynamic>?>('event_detail', params: {'target_event': id});
        if (r == null) throw const NotFoundFailure();
        final attendees = r['attendees'] as List?;
        final requests = r['requests'] as List?;
        final reviews = r['reviews'] as List?;
        final mine = r['my_review'] as Map?;
        final roll = r['roll'] as List?;
        return EventDetail(
          event: _event(r),
          canManage: r['can_manage'] == true,
          isMember: r['is_member'] == true,
          attendees: attendees == null ? null : [for (final p in attendees.cast<Map<String, dynamic>>()) _person(p)],
          requests: requests == null ? null : [for (final p in requests.cast<Map<String, dynamic>>()) _person(p)],
          conflicts: [
            for (final c in (r['conflicts'] as List? ?? const []).cast<Map<String, dynamic>>())
              EventConflict(id: c['id'] as String, title: c['title'] as String, startsAt: DateTime.parse(c['starts_at'] as String)),
          ],
          canPost: r['can_post'] == true,
          canReview: r['can_review'] == true,
          myReview: mine == null ? null : EventReview(rating: (mine['rating'] as num).toInt(), comment: mine['comment'] as String? ?? ''),
          reviews: reviews == null
              ? null
              : [
                  for (final v in reviews.cast<Map<String, dynamic>>())
                    EventReview(
                      rating: (v['rating'] as num).toInt(),
                      comment: v['comment'] as String? ?? '',
                      person: _person(v),
                      updatedAt: DateTime.parse(v['updated_at'] as String),
                    ),
                ],
          roll: roll == null
              ? null
              : [for (final p in roll.cast<Map<String, dynamic>>()) RollEntry(person: _person(p), noShow: p['no_show'] == true)],
        );
      });

  @override
  Future<Result<String>> uploadCover(String groupId, ImageUpload image) => _run(() async {
        final type = image.contentType;
        if (type == null) throw const RuleFailure('event.cover_type', 'Yalnızca JPEG, PNG ya da WebP görsel yüklenebilir.');
        final random = Random.secure();
        final name = List.generate(16, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
        final path = '$groupId/$name.${image.extension}';
        await _client.storage.from(coverBucket).uploadBinary(path, image.bytes, fileOptions: FileOptions(contentType: type));
        return path;
      });

  @override
  Future<Result<String>> create(String groupId, EventForm form) =>
      _api.post('/groups/$groupId/events', body: form.toJson(), decode: (json) => (json! as Map)['id'] as String);

  @override
  Future<Result<void>> update(String id, EventForm form) => _api.put('/events/$id', body: form.toJson(), decode: (_) {});

  @override
  Future<Result<void>> cancel(String id, {required String reason}) =>
      _api.post('/events/$id/cancellation', body: {'reason': reason}, decode: (_) {});

  @override
  Future<Result<AttendanceResult>> attend(String id) => _api.post(
        '/events/$id/attendance',
        decode: (json) {
          final j = (json! as Map).cast<String, Object?>();
          return (status: AttendanceStatus.tryParse(j['status'])!, place: (j['place'] as num?)?.toInt());
        },
      );

  @override
  Future<Result<void>> leave(String id) => _api.delete('/events/$id/attendance', decode: (_) {});

  WelcomeEntry _welcomeEntry(Map<String, dynamic> r) => WelcomeEntry(
        person: _person((r['person'] as Map).cast()),
        note: r['note'] as String?,
        greeterNote: r['greeter_note'] as String?,
        thanked: r['thanked'] == true,
      );

  @override
  Future<Result<EventWelcome?>> eventWelcome(String eventId) => _run(() async {
        final r = await _client.rpc<Map<String, dynamic>?>('event_welcome', params: {'target_event': eventId});
        if (r == null) return null;
        final mine = r['mine'] as Map?;
        final open = r['open'] as List?;
        return EventWelcome(
          greeters: (r['greeters'] as num?)?.toInt() ?? 0,
          canRequest: r['can_request'] == true,
          mine: mine == null
              ? null
              : MyWelcome(
                  note: mine['note'] as String?,
                  greeter: mine['greeter'] == null ? null : _person((mine['greeter'] as Map).cast()),
                  greeterNote: mine['greeter_note'] as String?,
                  thanked: mine['thanked'] == true,
                  canThank: mine['can_thank'] == true,
                ),
          isGreeter: r['is_greeter'] == true,
          greeting: r['greeting'] == true,
          open: open == null ? null : [for (final w in open.cast<Map<String, dynamic>>()) _welcomeEntry(w)],
          taken: [for (final w in (r['taken'] as List? ?? const []).cast<Map<String, dynamic>>()) _welcomeEntry(w)],
          matched: (r['matched'] as num?)?.toInt(),
        );
      });

  @override
  Future<Result<GroupWelcome?>> groupWelcome(String groupId) => _run(() async {
        final r = await _client.rpc<Map<String, dynamic>?>('group_welcome', params: {'target_group': groupId});
        if (r == null) return null;
        return GroupWelcome(
          greeters: (r['greeters'] as num?)?.toInt() ?? 0,
          isGreeter: r['is_greeter'] == true,
          canGreet: r['can_greet'] == true,
        );
      });

  @override
  Future<Result<void>> setGreeter(String groupId, {required bool greeter}) => _run(() async {
        final me = _client.auth.currentUser?.id ?? (throw const UnauthorizedFailure());
        if (greeter) {
          await _client.from('group_greeters').insert({'group_id': groupId, 'user_id': me});
        } else {
          await _client.from('group_greeters').delete().eq('group_id', groupId).eq('user_id', me);
        }
      });

  @override
  Future<Result<void>> requestWelcome(String eventId, {String? note}) =>
      _api.post('/events/$eventId/welcome', body: {'note': note}, decode: (_) {});

  @override
  Future<Result<void>> withdrawWelcome(String eventId) => _api.delete('/events/$eventId/welcome', decode: (_) {});

  @override
  Future<Result<void>> takeWelcome(String eventId, String newcomerId, String note) =>
      _api.put('/events/$eventId/welcome/$newcomerId/greeter', body: {'note': note}, decode: (_) {});

  @override
  Future<Result<void>> releaseWelcome(String eventId, String newcomerId) =>
      _api.delete('/events/$eventId/welcome/$newcomerId/greeter', decode: (_) {});

  @override
  Future<Result<void>> thankGreeter(String eventId) => _api.post('/events/$eventId/welcome/thanks', decode: (_) {});

  @override
  Future<Result<int?>> similarEventsCount(String groupId, DateTime day) => _run(() async {
        final start = DateTime(day.year, day.month, day.day);
        final end = DateTime(day.year, day.month, day.day + 1);
        final n = await _client.rpc<int?>('similar_events_count', params: {
          'target_group': groupId,
          'day_start': start.toUtc().toIso8601String(),
          'day_end': end.toUtc().toIso8601String(),
        });
        return n;
      });

  @override
  Future<Result<void>> decideRequest(String eventId, String userId, {required bool approve}) => approve
      ? _api.post('/events/$eventId/requests/$userId/approval', decode: (_) {})
      : _api.delete('/events/$eventId/requests/$userId', decode: (_) {});

  @override
  Uri calendarUrl(String id) => _api.baseUrl.resolve('/events/$id/calendar.ics');

  @override
  Future<Result<void>> saveReview(String eventId, {required int rating, String comment = ''}) => _run(() async {
        await _client.from('event_reviews').upsert({
          'event_id': eventId,
          'user_id': _client.auth.currentUser!.id,
          'rating': rating,
          'comment': comment.trim(),
        });
      });

  @override
  Future<Result<void>> deleteReview(String eventId) => _run(() async {
        await _client.from('event_reviews').delete().eq('event_id', eventId).eq('user_id', _client.auth.currentUser!.id);
      });

  @override
  Future<Result<void>> setNoShow(String eventId, String userId, {required bool noShow}) => noShow
      ? _api.put('/events/$eventId/no-shows/$userId', decode: (_) {})
      : _api.delete('/events/$eventId/no-shows/$userId', decode: (_) {});

  ContributionBadge _badge(Map<String, dynamic> b) =>
      ContributionBadge(slug: b['slug'] as String, name: b['name'] as String, description: b['description'] as String);

  @override
  Future<Result<Contributions?>> contributions(String userId) => _run(() async {
        final r = await _client.rpc<Map<String, dynamic>?>('user_contributions', params: {'target': userId});
        if (r == null) return null;
        int n(String key) => (r[key] as num?)?.toInt() ?? 0;
        return Contributions(
          attended: n('attended'),
          organized: n('organized'),
          memories: n('memories'),
          reviews: n('reviews'),
          groups: n('groups'),
          welcomed: n('welcomed'),
          badges: [for (final b in (r['badges'] as List? ?? const []).cast<Map<String, dynamic>>()) _badge(b)],
        );
      });

  @override
  Future<Result<List<ContributionBadge>>> badgeCatalog() => _run(() async {
        final r = await _client.rpc<List<dynamic>>('badge_catalog');
        return [for (final b in r.cast<Map<String, dynamic>>()) _badge(b)];
      });

  @override
  Future<Result<Map<String, ({int attended, int organized})>>> groupContributions(String groupId) => _run(() async {
        final r = await _client.rpc<Map<String, dynamic>>('group_contributions', params: {'target_group': groupId});
        return {
          for (final MapEntry(:key, :value) in r.entries)
            key: (attended: ((value as Map)['attended'] as num).toInt(), organized: (value['organized'] as num).toInt()),
        };
      });

  @override
  Future<Result<List<GroupEvent>>> history(String groupId, {DateTime? before}) => _run(() async {
        final r = await _client.rpc<List<dynamic>>('group_event_history', params: {
          'target_group': groupId,
          'before_at': before?.toUtc().toIso8601String(),
        });
        return [for (final e in r.cast<Map<String, dynamic>>()) _event(e)];
      });

  @override
  Future<Result<List<GroupEvent>>> calendar(DateTime from, DateTime to, {String? groupId, bool includeGroups = false}) =>
      _run(() async {
        final r = await _client.rpc<List<dynamic>>('calendar_events', params: {
          'range_start': from.toUtc().toIso8601String(),
          'range_end': to.toUtc().toIso8601String(),
          'target_group': groupId,
          'include_groups': includeGroups,
        });
        return [for (final e in r.cast<Map<String, dynamic>>()) _event(e)];
      });

  // Polls ---------------------------------------------------------------------------------

  @override
  Future<Result<List<Poll>>> polls(String groupId, {String? eventId}) => _run(() async {
        final r = await _client.rpc<List<dynamic>>('group_polls', params: {'target_group': groupId, 'target_event': eventId});
        return [for (final p in r.cast<Map<String, dynamic>>()) _poll(p)];
      });

  @override
  Future<Result<void>> createPoll(String groupId, PollForm form) =>
      _api.post('/groups/$groupId/polls', body: form.toJson(), decode: (_) {});

  @override
  Future<Result<void>> closePoll(String id) => _api.post('/polls/$id/close', decode: (_) {});

  @override
  Future<Result<void>> deletePoll(String id) => _api.delete('/polls/$id', decode: (_) {});

  @override
  Future<Result<void>> vote(Poll poll, Set<int> optionIds) => _run(() async {
        final me = _client.auth.currentUser!.id;
        await _client.from('poll_votes').delete().eq('poll_id', poll.id).eq('user_id', me);
        if (optionIds.isEmpty) return;
        await _client.from('poll_votes').insert([
          for (final o in optionIds) {'poll_id': poll.id, 'option_id': o, 'user_id': me},
        ]);
      });

  @override
  Future<Result<List<EventPerson>>> voters(int optionId) => _run(() async {
        final rows = await _client
            .from('poll_votes')
            .select('person:profiles!poll_votes_user_id_fkey(id, username, display_name, avatar_path)')
            .eq('option_id', optionId)
            .order('created_at', ascending: true)
            .limit(100);
        return [for (final r in rows) _person((r['person'] as Map).cast())];
      });
}
