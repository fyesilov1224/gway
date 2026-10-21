import 'package:flutter_test/flutter_test.dart';
import 'package:notifications/notifications.dart';

AppNotification _n(int id, DateTime at, {NotificationType type = NotificationType.like, String? comment}) => AppNotification(
      id: id,
      type: type,
      actor: const NotificationActor(id: 'u2', username: 'elif', displayName: 'Elif'),
      createdAt: at,
      postId: 'p1',
      comment: comment,
    );

void main() {
  test('sections are today, this week and earlier, empty ones left out', () {
    final now = DateTime(2026, 10, 19, 15);
    final groups = groupByPeriod([
      _n(4, DateTime(2026, 10, 19, 9)),
      _n(3, DateTime(2026, 10, 17)),
      _n(2, DateTime(2026, 10, 13, 1)),
      _n(1, DateTime(2026, 9, 1)),
    ], now);

    expect(groups.map((g) => g.$1), [NotificationPeriod.today, NotificationPeriod.thisWeek, NotificationPeriod.earlier]);
    expect(groups[1].$2.map((n) => n.id), [3, 2]);
    expect(groupByPeriod([_n(1, DateTime(2026, 9, 1))], now).single.$1, NotificationPeriod.earlier);
  });

  test('every type has a Turkish sentence; comment ones open the comments', () {
    final at = DateTime(2026);
    for (final type in NotificationType.values) {
      expect(_n(1, at, type: type).action, isNotEmpty);
    }
    final reply = _n(1, at, type: NotificationType.reply, comment: 'Katılıyorum');
    expect(reply.action, 'yorumuna yanıt verdi: Katılıyorum');
    expect(reply.aboutComment, isTrue);
    expect(_n(1, at).aboutComment, isFalse);
  });

  test('codes from the database parse; unknown ones are skipped', () {
    expect(NotificationType.tryParse('comment_like'), NotificationType.commentLike);
    expect(NotificationType.tryParse('follow_request')!.isFollow, isTrue);
    expect(NotificationType.tryParse('later_type'), isNull);
  });

  test('a live_started notification names the broadcast', () {
    final n = AppNotification(
      id: 1,
      type: NotificationType.liveStarted,
      actor: const NotificationActor(id: 'u2', username: 'elif', displayName: 'Elif'),
      createdAt: DateTime(2026),
      liveId: 'b1',
      liveTitle: 'Pazar konseri',
    );
    expect(NotificationType.tryParse('live_started'), NotificationType.liveStarted);
    expect(n.action, 'canlı yayına başladı: Pazar konseri');
  });

  test('event reminders say tomorrow or within the hour', () {
    AppNotification reminder(Duration before) {
      final created = DateTime(2026, 10, 20, 9);
      return AppNotification(
        id: 1,
        type: NotificationType.eventReminder,
        actor: const NotificationActor(id: 'u2', username: 'elif', displayName: 'Elif'),
        createdAt: created,
        eventId: 'e1',
        eventTitle: 'Gece yürüyüşü',
        eventStartsAt: created.add(before),
      );
    }

    expect(reminder(const Duration(hours: 20)).action, '"Gece yürüyüşü" yarın başlıyor.');
    expect(reminder(const Duration(minutes: 40)).action, '"Gece yürüyüşü" 1 saat içinde başlıyor.');
    expect(NotificationType.tryParse('event_promoted'), NotificationType.eventPromoted);
  });
  test('sanction notices speak for the group; case votes name the group', () {
    const group = NotificationGroup(id: 'g1', handle: 'doga', name: 'Doğa Yürüyüşçüleri');
    final ban = AppNotification(
      id: 1,
      type: NotificationType.sanctionApplied,
      actor: const NotificationActor(id: 'u1', username: 'sahip', displayName: 'Sahip'),
      createdAt: DateTime(2026),
      group: group,
      sanctionType: 'ban',
    );
    expect(ban.type.fromGroup, isTrue);
    expect(ban.lead, 'Doğa Yürüyüşçüleri');
    expect(ban.action, 'grubundan uzaklaştırıldın. Ayrıntılar ve itiraz için dokun.');

    final vote = AppNotification(
      id: 2,
      type: NotificationType.caseVote,
      actor: const NotificationActor(id: 'u2', username: 'moderator', displayName: 'Moderatör'),
      createdAt: DateTime(2026),
      group: group,
    );
    expect(vote.lead, 'moderator');
    expect(vote.action, 'Doğa Yürüyüşçüleri grubunda bir disiplin dosyası açtı; oyunu bekliyor.');
  });
}
