import 'package:core/core.dart';

import '../l10n.dart';

enum NotificationType {
  like('like'),
  comment('comment'),
  reply('reply'),
  commentLike('comment_like'),
  mention('mention'),
  follow('follow'),
  followRequest('follow_request'),
  followAccepted('follow_accepted'),
  liveScheduled('live_scheduled'),
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
  teammateAccepted('teammate_accepted'),
  matchCreated('match_created'),
  matchSuperLiked('match_super_liked'),
  welcomeRequested('welcome_requested'),
  welcomeMatched('welcome_matched'),
  welcomeReleased('welcome_released'),
  welcomeWithdrawn('welcome_withdrawn'),
  welcomeThanked('welcome_thanked'),
  leagueResult('league_result'),
  eventSeriesLimit('event_series_limit'),
  tonightTableInvite('tonight_table_invite'),
  tonightTableReady('tonight_table_ready'),
  eventVenueRevealed('event_venue_revealed'),
  handshake('handshake'),
  callMissed('call_missed'),
  callPermissionGranted('call_permission_granted'),
  callPermissionDeclined('call_permission_declined'),
  callPermissionRevoked('call_permission_revoked'),
  chessChallenge('chess_challenge'),
  chessTeamInvite('chess_team_invite'),
  chessTeamAccepted('chess_team_accepted'),
  chessTeamDeclined('chess_team_declined'),
  chessTeamStart('chess_team_start'),
  chessArenaStart('chess_arena_start'),
  chessArenaMedal('chess_arena_medal'),
  mindChallenge('mind_challenge'),
  mindTeamInvite('mind_team_invite'),
  mindTeamAccepted('mind_team_accepted'),
  mindTeamDeclined('mind_team_declined'),
  mindTeamStart('mind_team_start'),
  mindArenaStart('mind_arena_start'),
  mindArenaMedal('mind_arena_medal');

  const NotificationType(this.code);

  final String code;

  static NotificationType? tryParse(Object? code) => values.where((t) => t.code == code).firstOrNull;

  /// About a person rather than a post.
  bool get isFollow => this == follow || this == followRequest || this == followAccepted;

  /// Sent on behalf of a group (docs/ARCHITECTURE.md §3e): the group is shown, not a person.
  bool get fromGroup => this == sanctionApplied || this == appealDecided;

  /// Names nobody: who matched needs a package (docs/ARCHITECTURE.md §3g).
  bool get anonymous => this == matchCreated;

  /// A decision on the person's voice call permission (docs/ARCHITECTURE.md §8c): named by the feature, not a person.
  bool get isCallPermission => this == callPermissionGranted || this == callPermissionDeclined || this == callPermissionRevoked;

  /// About a chess team match between groups (docs/ARCHITECTURE.md §3i); opens chess.
  bool get isChess => this == chessChallenge || this == chessTeamInvite || this == chessTeamAccepted || this == chessTeamDeclined || this == chessTeamStart ||
      this == chessArenaStart || this == chessArenaMedal;

  /// A Zihin Düellosu invitation or group duel (docs/ARCHITECTURE.md §3j); opens the duel home.
  bool get isMind => this == mindChallenge || this == mindTeamInvite || this == mindTeamAccepted || this == mindTeamDeclined || this == mindTeamStart ||
      this == mindArenaStart || this == mindArenaMedal;

  /// Rings the live alert while the app is open (docs/ARCHITECTURE.md §3c, Sesli uyarı).
  bool get isLive => this == liveScheduled || this == liveStarted;
}

/// A notification row the moment Realtime delivers it, before [NotificationsRepository.list] reads it in full.
class NotificationArrival {
  const NotificationArrival({required this.id, this.type, this.liveId});

  final int id;

  /// Null for a type this version does not know.
  final NotificationType? type;
  final String? liveId;
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
    this.liveScheduledAt,
    this.eventId,
    this.eventTitle,
    this.eventStartsAt,
    this.group,
    this.sanctionType,
    this.goalId,
    this.goalTitle,
    this.conversationId,
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

  /// The broadcast of [NotificationType.liveScheduled] and [NotificationType.liveStarted].
  final String? liveId;
  final String? liveTitle;
  final DateTime? liveScheduledAt;

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

  /// The chat of call_missed.
  final String? conversationId;

  /// What happened, after the actor's username (in the app language).
  String get action {
    final l = notificationsL10n;
    final event = eventTitle ?? '';
    final text = comment ?? '';
    return switch (type) {
      NotificationType.like => l.actLike,
      NotificationType.comment => l.actComment(text),
      NotificationType.reply => l.actReply(text),
      NotificationType.commentLike => l.actCommentLike(text),
      NotificationType.mention => comment == null ? l.actMentionPost : l.actMentionComment(text),
      NotificationType.follow => l.actFollow,
      NotificationType.followRequest => l.actFollowRequest,
      NotificationType.followAccepted => l.actFollowAccepted,
      NotificationType.liveScheduled => liveScheduledAt == null
          ? l.actLiveScheduled(liveTitle ?? '')
          : l.actLiveScheduledAt(formatDateTime(liveScheduledAt!), liveTitle ?? ''),
      NotificationType.liveStarted => l.actLiveStarted(liveTitle ?? ''),
      NotificationType.eventPromoted => l.actEventPromoted(event),
      NotificationType.eventUpdated => l.actEventUpdated(event),
      NotificationType.eventCanceled => l.actEventCanceled(event),
      NotificationType.eventReminder => eventStartsAt != null && eventStartsAt!.difference(createdAt) > const Duration(hours: 1)
          ? l.actReminderTomorrow(event)
          : l.actReminderHour(event),
      NotificationType.caseVote => l.actCaseVote(group?.name ?? ''),
      NotificationType.sanctionApplied => switch (sanctionType) {
          'mute' => l.actMuted,
          'kick' => l.actKicked,
          'ban' => l.actBanned,
          _ => l.actWarned,
        },
      NotificationType.appealSubmitted => l.actAppealSubmitted(group?.name ?? ''),
      NotificationType.appealDecided => l.actAppealDecided,
      NotificationType.eventApproved => l.actEventApproved(event),
      NotificationType.eventDeclined => l.actEventDeclined(event),
      NotificationType.eventReview => l.actEventReview(event),
      NotificationType.goalCompleted => l.actGoalCompleted(goalTitle ?? ''),
      NotificationType.teammateRequest => l.actTeammateRequest,
      NotificationType.teammateAccepted => l.actTeammateAccepted,
      NotificationType.matchCreated => l.actMatchCreated,
      NotificationType.matchSuperLiked => l.actSuperLiked,
      NotificationType.welcomeRequested => l.actWelcomeRequested(event),
      NotificationType.welcomeMatched => l.actWelcomeMatched(event),
      NotificationType.welcomeReleased => l.actWelcomeReleased(event),
      NotificationType.welcomeWithdrawn => l.actWelcomeWithdrawn(event),
      NotificationType.leagueResult => l.actLeagueResult,
      NotificationType.welcomeThanked => l.actWelcomeThanked(event),
      NotificationType.tonightTableInvite => l.actTableInvite,
      NotificationType.tonightTableReady => l.actTableReady,
      NotificationType.eventVenueRevealed => l.actVenueRevealed(event),
      NotificationType.handshake => l.actHandshake(event),
      NotificationType.callMissed => l.actCallMissed,
      NotificationType.callPermissionGranted => l.actCallGranted,
      NotificationType.callPermissionDeclined => l.actCallDeclined,
      NotificationType.callPermissionRevoked => l.actCallRevoked,
      NotificationType.eventSeriesLimit => l.actSeriesLimit(event),
      NotificationType.chessChallenge => l.actChessChallenge,
      NotificationType.chessTeamInvite => l.actChessTeamInvite(group?.name ?? ''),
      NotificationType.chessTeamAccepted => l.actChessTeamAccepted(group?.name ?? ''),
      NotificationType.chessTeamDeclined => l.actChessTeamDeclined(group?.name ?? ''),
      NotificationType.chessTeamStart => l.actChessTeamStart(group?.name ?? ''),
      NotificationType.chessArenaStart => l.actChessArenaStart,
      NotificationType.chessArenaMedal => l.actChessArenaMedal,
      NotificationType.mindChallenge => l.actMindChallenge,
      NotificationType.mindTeamInvite => l.actMindTeamInvite(group?.name ?? ''),
      NotificationType.mindTeamAccepted => l.actMindTeamAccepted(group?.name ?? ''),
      NotificationType.mindTeamDeclined => l.actMindTeamDeclined(group?.name ?? ''),
      NotificationType.mindTeamStart => l.actMindTeamStart(group?.name ?? ''),
      NotificationType.mindArenaStart => l.actMindArenaStart,
      NotificationType.mindArenaMedal => l.actMindArenaMedal,
    };
  }

  /// The bold lead before [action]: the group for group notices, otherwise the person.
  String get lead => switch (type) {
        _ when type.fromGroup || type == NotificationType.leagueResult => group?.name ?? '',
        NotificationType.matchCreated => notificationsL10n.leadNewMatch,
        NotificationType.eventSeriesLimit => notificationsL10n.leadSeries,
        NotificationType.chessTeamStart => notificationsL10n.leadTeamMatch,
        NotificationType.mindTeamStart => notificationsL10n.leadGroupDuel,
        NotificationType.mindArenaStart || NotificationType.mindArenaMedal => notificationsL10n.leadDuelArena,
        NotificationType.chessArenaStart || NotificationType.chessArenaMedal => notificationsL10n.leadArena,
        NotificationType.eventVenueRevealed => notificationsL10n.leadVenue,
        _ when type.isCallPermission => notificationsL10n.leadCalls,
        _ => actor.username,
      };

  /// Opens the comments rather than the post.
  bool get aboutComment => comment != null;
}

enum NotificationPeriod {
  today,
  thisWeek,
  earlier;

  String get label => switch (this) {
        today => notificationsL10n.periodToday,
        thisWeek => notificationsL10n.periodWeek,
        earlier => notificationsL10n.periodEarlier,
      };

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

/// Which event, live, match and message notices the user wants (docs/ARCHITECTURE.md §3c, Tercihler); everything is on by default.
class NotificationPreferences {
  const NotificationPreferences({
    this.reminderDay = true,
    this.reminderHour = true,
    this.eventUpdates = true,
    this.reviewRequests = true,
    this.liveBroadcasts = true,
    this.matchAlerts = true,
    this.messages = true,
    this.groupMessages = true,
  });

  /// "Yarın başlıyor" reminder.
  final bool reminderDay;

  /// "1 saat içinde başlıyor" reminder.
  final bool reminderHour;

  /// Time, place and cancellation notices.
  final bool eventUpdates;

  /// "Nasıldı?" after an event.
  final bool reviewRequests;

  /// Broadcasts scheduled or started in the user's groups.
  final bool liveBroadcasts;

  /// New matches (docs/ARCHITECTURE.md §3g).
  final bool matchAlerts;

  /// Direct chat messages ring the phone (docs/ARCHITECTURE.md §3c, Mesaj bildirimi).
  final bool messages;

  /// Group chat messages ring the phone; separate from [messages] since 2026-11-03.
  final bool groupMessages;

  NotificationPreferences copyWith({
    bool? reminderDay,
    bool? reminderHour,
    bool? eventUpdates,
    bool? reviewRequests,
    bool? liveBroadcasts,
    bool? matchAlerts,
    bool? messages,
    bool? groupMessages,
  }) =>
      NotificationPreferences(
        reminderDay: reminderDay ?? this.reminderDay,
        reminderHour: reminderHour ?? this.reminderHour,
        eventUpdates: eventUpdates ?? this.eventUpdates,
        reviewRequests: reviewRequests ?? this.reviewRequests,
        liveBroadcasts: liveBroadcasts ?? this.liveBroadcasts,
        matchAlerts: matchAlerts ?? this.matchAlerts,
        messages: messages ?? this.messages,
        groupMessages: groupMessages ?? this.groupMessages,
      );
}

abstract interface class NotificationsRepository {
  /// Newest first; [beforeId] pages back.
  Future<Result<List<AppNotification>>> list({int? beforeId});

  Future<Result<int>> unreadCount();

  Future<Result<void>> markAllRead();

  Future<Result<void>> delete(int id);

  /// Fires when a notification for the signed-in user arrives.
  Stream<NotificationArrival> arrivals();

  Future<Result<NotificationPreferences>> preferences();

  Future<Result<void>> savePreferences(NotificationPreferences preferences);

  /// This device's FCM token now belongs to the signed-in user (docs/ARCHITECTURE.md §3c, Push).
  Future<Result<void>> registerPushDevice(String token, String platform);
}

/// The phone's push service; only where Firebase runs (Android and iOS).
abstract interface class PushMessaging {
  /// `android` or `ios`.
  String get platform;

  /// Asks for permission the first time; null when the user refuses.
  Future<String?> token();

  Stream<String> get tokenRefreshes;

  /// After sign-out the device stops receiving the previous user's notifications.
  Future<void> deleteToken();

  /// The data of the notification the user tapped, including the one that opened the app.
  Stream<Map<String, Object?>> get taps;

  /// The data of pushes that arrive while the app is in the foreground; the phone shows none of them.
  Stream<Map<String, Object?>> get arrivals;
}
