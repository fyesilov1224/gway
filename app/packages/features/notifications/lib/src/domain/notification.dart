import 'package:core/core.dart';

enum NotificationType {
  like('like'),
  comment('comment'),
  reply('reply'),
  commentLike('comment_like'),
  mention('mention'),
  follow('follow'),
  followRequest('follow_request'),
  followAccepted('follow_accepted'),
  liveStarted('live_started'),
  eventPromoted('event_promoted'),
  eventUpdated('event_updated'),
  eventCanceled('event_canceled'),
  eventReminder('event_reminder'),
  caseVote('case_vote'),
  sanctionApplied('sanction_applied'),
  appealSubmitted('appeal_submitted'),
  appealDecided('appeal_decided'),
  eventApproved('event_approved'),
  eventDeclined('event_declined'),
  eventReview('event_review'),
  goalCompleted('goal_completed'),
  teammateRequest('teammate_request'),
  teammateAccepted('teammate_accepted');

  const NotificationType(this.code);

  final String code;

  static NotificationType? tryParse(Object? code) => values.where((t) => t.code == code).firstOrNull;

  /// About a person rather than a post.
  bool get isFollow => this == follow || this == followRequest || this == followAccepted;

  /// Sent on behalf of a group (docs/ARCHITECTURE.md §3e): the group is shown, not a person.
  bool get fromGroup => this == sanctionApplied || this == appealDecided;
}

class NotificationGroup {
  const NotificationGroup({required this.id, required this.handle, required this.name, this.logoUrl});

  final String id;
  final String handle;
  final String name;
  final String? logoUrl;
}

class NotificationActor {
  const NotificationActor({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.iFollow = false,
    this.requested = false,
  });

  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final bool iFollow;
  final bool requested;
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.actor,
    required this.createdAt,
    this.read = false,
    this.postId,
    this.thumbUrl,
    this.thumbIsVideo = false,
    this.comment,
    this.liveId,
    this.liveTitle,
    this.eventId,
    this.eventTitle,
    this.eventStartsAt,
    this.group,
    this.sanctionType,
    this.goalId,
    this.goalTitle,
  });

  final int id;
  final NotificationType type;
  final NotificationActor actor;
  final DateTime createdAt;
  final bool read;
  final String? postId;
  final String? thumbUrl;
  final bool thumbIsVideo;

  /// The first 120 characters of the comment, for comment notifications.
  final String? comment;

  /// The broadcast of [NotificationType.liveStarted].
  final String? liveId;
  final String? liveTitle;

  /// The event of the event_* types.
  final String? eventId;
  final String? eventTitle;
  final DateTime? eventStartsAt;

  /// The group of the moderation types.
  final NotificationGroup? group;

  /// `warning`, `mute`, `kick` or `ban`, for sanction_applied.
  final String? sanctionType;

  /// The goal of goal_completed.
  final String? goalId;
  final String? goalTitle;

  /// What happened, after the actor's username.
  String get action => switch (type) {
        NotificationType.like => 'gönderini beğendi.',
        NotificationType.comment => 'yorum yaptı: ${comment ?? ''}',
        NotificationType.reply => 'yorumuna yanıt verdi: ${comment ?? ''}',
        NotificationType.commentLike => 'yorumunu beğendi: ${comment ?? ''}',
        NotificationType.mention => comment == null ? 'bir gönderide senden bahsetti.' : 'bir yorumda senden bahsetti: $comment',
        NotificationType.follow => 'seni takip etmeye başladı.',
        NotificationType.followRequest => 'seni takip etmek istiyor.',
        NotificationType.followAccepted => 'takip isteğini kabul etti.',
        NotificationType.liveStarted => 'canlı yayına başladı: ${liveTitle ?? ''}',
        NotificationType.eventPromoted => '"${eventTitle ?? ''}" için yer açıldı, artık katılıyorsun.',
        NotificationType.eventUpdated => '"${eventTitle ?? ''}" organizasyonunun zamanını ya da yerini değiştirdi.',
        NotificationType.eventCanceled => '"${eventTitle ?? ''}" organizasyonunu iptal etti.',
        NotificationType.eventReminder => eventStartsAt != null && eventStartsAt!.difference(createdAt) > const Duration(hours: 1)
            ? '"${eventTitle ?? ''}" yarın başlıyor.'
            : '"${eventTitle ?? ''}" 1 saat içinde başlıyor.',
        NotificationType.caseVote => '${group?.name ?? ''} grubunda bir disiplin dosyası açtı; oyunu bekliyor.',
        NotificationType.sanctionApplied => switch (sanctionType) {
            'mute' => 'grubunda susturuldun. Ayrıntılar ve itiraz için dokun.',
            'kick' => 'grubundan çıkarıldın. Ayrıntılar ve itiraz için dokun.',
            'ban' => 'grubundan uzaklaştırıldın. Ayrıntılar ve itiraz için dokun.',
            _ => 'grubu sana uyarı verdi. Ayrıntılar ve itiraz için dokun.',
          },
        NotificationType.appealSubmitted => '${group?.name ?? ''} grubundaki yaptırıma itiraz etti.',
        NotificationType.appealDecided => 'grubu itirazını karara bağladı.',
        NotificationType.eventApproved => '"${eventTitle ?? ''}" için katılım isteğini onayladı.',
        NotificationType.eventDeclined => '"${eventTitle ?? ''}" için katılım isteğini kabul edemedi.',
        NotificationType.eventReview => '"${eventTitle ?? ''}" nasıldı? Değerlendir, anılarını paylaş.',
        NotificationType.goalCompleted => '"${goalTitle ?? ''}" hedefini tamamladın! Rozetin profilinde.',
        NotificationType.teammateRequest => 'seninle ekip arkadaşı olmak istiyor.',
        NotificationType.teammateAccepted => 'ekip arkadaşlığı isteğini kabul etti.',
      };

  /// The bold lead before [action]: the group for group notices, otherwise the person.
  String get lead => type.fromGroup ? group?.name ?? '' : actor.username;

  /// Opens the comments rather than the post.
  bool get aboutComment => comment != null;
}

enum NotificationPeriod {
  today('Bugün'),
  thisWeek('Bu hafta'),
  earlier('Daha önce');

  const NotificationPeriod(this.label);

  final String label;

  static NotificationPeriod of(DateTime time, DateTime now) {
    final t = time.toLocal();
    final n = now.toLocal();
    final startOfToday = DateTime(n.year, n.month, n.day);
    if (!t.isBefore(startOfToday)) return today;
    if (!t.isBefore(startOfToday.subtract(const Duration(days: 6)))) return thisWeek;
    return earlier;
  }
}

/// Splits a newest-first list into the screen's sections, skipping empty ones.
List<(NotificationPeriod, List<AppNotification>)> groupByPeriod(List<AppNotification> items, DateTime now) => [
      for (final period in NotificationPeriod.values)
        if (items.where((n) => NotificationPeriod.of(n.createdAt, now) == period).toList() case final group when group.isNotEmpty)
          (period, group),
    ];

/// Which event notices the user wants (docs/ARCHITECTURE.md §3c, Tercihler); everything is on by default.
class NotificationPreferences {
  const NotificationPreferences({this.reminderDay = true, this.reminderHour = true, this.eventUpdates = true, this.reviewRequests = true});

  /// "Yarın başlıyor" reminder.
  final bool reminderDay;

  /// "1 saat içinde başlıyor" reminder.
  final bool reminderHour;

  /// Time, place and cancellation notices.
  final bool eventUpdates;

  /// "Nasıldı?" after an event.
  final bool reviewRequests;

  NotificationPreferences copyWith({bool? reminderDay, bool? reminderHour, bool? eventUpdates, bool? reviewRequests}) =>
      NotificationPreferences(
        reminderDay: reminderDay ?? this.reminderDay,
        reminderHour: reminderHour ?? this.reminderHour,
        eventUpdates: eventUpdates ?? this.eventUpdates,
        reviewRequests: reviewRequests ?? this.reviewRequests,
      );
}

abstract interface class NotificationsRepository {
  /// Newest first; [beforeId] pages back.
  Future<Result<List<AppNotification>>> list({int? beforeId});

  Future<Result<int>> unreadCount();

  Future<Result<void>> markAllRead();

  Future<Result<void>> delete(int id);

  /// Fires when a notification for the signed-in user arrives.
  Stream<void> arrivals();

  Future<Result<NotificationPreferences>> preferences();

  Future<Result<void>> savePreferences(NotificationPreferences preferences);
}
