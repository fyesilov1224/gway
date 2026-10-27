import 'dart:async';

import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/notification.dart';

/// The recipient's own rows under RLS; written only by database triggers (docs/ARCHITECTURE.md §3c).
class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._client);

  final SupabaseClient _client;

  static const pageSize = 30;

  static final _stillImage = RegExp(r'\.(jpe?g|png|webp)$', caseSensitive: false);

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

  String? _url(String bucket, Object? path) => path is String ? _client.storage.from(bucket).getPublicUrl(path) : null;

  @override
  Future<Result<NotificationPreferences>> preferences() => _run(() async {
        final r = await _client.from('notification_preferences').select().eq('user_id', _me).maybeSingle();
        if (r == null) return const NotificationPreferences();
        return NotificationPreferences(
          reminderDay: r['event_reminder_day'] as bool,
          reminderHour: r['event_reminder_hour'] as bool,
          eventUpdates: r['event_updates'] as bool,
          reviewRequests: r['event_review_requests'] as bool,
          liveBroadcasts: r['live_broadcasts'] as bool,
          matchAlerts: r['match_alerts'] as bool,
        );
      });

  @override
  Future<Result<void>> savePreferences(NotificationPreferences p) => _run(() async {
        await _client.from('notification_preferences').upsert({
          'user_id': _me,
          'event_reminder_day': p.reminderDay,
          'event_reminder_hour': p.reminderHour,
          'event_updates': p.eventUpdates,
          'event_review_requests': p.reviewRequests,
          'live_broadcasts': p.liveBroadcasts,
          'match_alerts': p.matchAlerts,
        });
      });

  @override
  Future<Result<void>> registerPushDevice(String token, String platform) => _run(() async {
        await _client.rpc<void>('register_push_device', params: {'device_token': token, 'device_platform': platform});
      });

  AppNotification? _notification(Map<String, dynamic> r) {
    final type = NotificationType.tryParse(r['type']);
    if (type == null) return null;
    final actor = (r['actor'] as Map).cast<String, dynamic>();
    final video = r['post_thumb_kind'] == 'video';
    final thumb = r['post_thumb'] as String?;
    return AppNotification(
      id: (r['id'] as num).toInt(),
      type: type,
      createdAt: DateTime.parse(r['created_at'] as String),
      read: r['read'] as bool,
      actor: NotificationActor(
        id: actor['id'] as String,
        username: actor['username'] as String,
        displayName: actor['display_name'] as String,
        avatarUrl: _url('avatars', actor['avatar_path']),
        iFollow: r['i_follow'] as bool,
        requested: r['requested'] as bool,
      ),
      postId: r['post_id'] as String?,
      // A video without a cover has no still image to show.
      thumbUrl: video && !_stillImage.hasMatch(thumb ?? '') ? null : _url('media', thumb),
      thumbIsVideo: video,
      comment: r['comment'] as String?,
      liveId: r['live_id'] as String?,
      liveTitle: r['live_title'] as String?,
      liveScheduledAt: r['live_scheduled_at'] == null ? null : DateTime.parse(r['live_scheduled_at'] as String),
      eventId: r['event_id'] as String?,
      eventTitle: r['event_title'] as String?,
      eventStartsAt: r['event_starts_at'] == null ? null : DateTime.parse(r['event_starts_at'] as String),
      group: switch (r['group']) {
        final Map<String, dynamic> g => NotificationGroup(
            id: g['id'] as String,
            handle: g['handle'] as String,
            name: g['name'] as String,
            logoUrl: _url('group-images', g['logo_path']),
          ),
        _ => null,
      },
      sanctionType: r['sanction_type'] as String?,
      goalId: r['goal_id'] as String?,
      goalTitle: r['goal_title'] as String?,
    );
  }

  @override
  Future<Result<List<AppNotification>>> list({int? beforeId}) => _run(() async {
        final rows = await _client.rpc<List<dynamic>>('my_notifications', params: {'before_id': beforeId, 'page_size': pageSize});
        return [for (final r in rows) ?_notification((r as Map).cast())];
      });

  @override
  Future<Result<int>> unreadCount() => _run(() async {
        final response = await _client
            .from('notifications')
            .select('id')
            .eq('recipient_id', _me)
            .isFilter('read_at', null)
            .count(CountOption.exact);
        return response.count;
      });

  @override
  Future<Result<void>> markAllRead() => _run(() async {
        await _client
            .from('notifications')
            .update({'read_at': DateTime.now().toUtc().toIso8601String()})
            .eq('recipient_id', _me)
            .isFilter('read_at', null);
      });

  @override
  Future<Result<void>> delete(int id) => _run(() async {
        await _client.from('notifications').delete().eq('id', id);
      });

  @override
  Stream<NotificationArrival> arrivals() {
    final me = _client.auth.currentUser?.id;
    if (me == null) return const Stream.empty();
    late final RealtimeChannel channel;
    final controller = StreamController<NotificationArrival>(onCancel: () => _client.removeChannel(channel));
    channel = _client
        .channel('notifications:$me')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'recipient_id', value: me),
          callback: (payload) => controller.add(NotificationArrival(
            id: (payload.newRecord['id'] as num).toInt(),
            type: NotificationType.tryParse(payload.newRecord['type']),
            liveId: payload.newRecord['live_id'] as String?,
          )),
        )
        .subscribe();
    return controller.stream;
  }
}
