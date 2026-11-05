"""Rewrites the notification sentence getters to localized calls."""
import pathlib, sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))
from dartedit import edit, load  # noqa: E402

app = pathlib.Path(__file__).resolve().parents[3]
f = str(app / 'packages/features/notifications/lib/src/domain/notification.dart')
s, _ = load(f)
start = s.index('  /// What happened, after the actor\'s username.\n  String get action => switch (type) {')
end = s.index('  /// Opens the comments rather than the post.')
new = """  /// What happened, after the actor's username (in the app language).
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
    };
  }

  /// The bold lead before [action]: the group for group notices, otherwise the person.
  String get lead => switch (type) {
        _ when type.fromGroup || type == NotificationType.leagueResult => group?.name ?? '',
        NotificationType.matchCreated => notificationsL10n.leadNewMatch,
        NotificationType.eventSeriesLimit => notificationsL10n.leadSeries,
        NotificationType.eventVenueRevealed => notificationsL10n.leadVenue,
        _ when type.isCallPermission => notificationsL10n.leadCalls,
        _ => actor.username,
      };

"""
edit(f, [(s[start:end], new),
         ("""  today('Bugün'),
  thisWeek('Bu hafta'),
  earlier('Daha önce');

  const NotificationPeriod(this.label);

  final String label;""", """  today,
  thisWeek,
  earlier;

  String get label => switch (this) {
        today => notificationsL10n.periodToday,
        thisWeek => notificationsL10n.periodWeek,
        earlier => notificationsL10n.periodEarlier,
      };""")], ['../l10n.dart'])

g = str(app / 'packages/features/notifications/lib/src/presentation/notifications_screen.dart')
edit(g, [("""  if (diff.inMinutes < 1) return 'şimdi';
  if (diff.inHours < 1) return '${diff.inMinutes} dk';
  if (diff.inDays < 1) return '${diff.inHours} sa';
  if (diff.inDays < 7) return '${diff.inDays} g';""", """  final l = notificationsL10n;
  if (diff.inMinutes < 1) return l.agoNow;
  if (diff.inHours < 1) return l.agoMinutes(diff.inMinutes);
  if (diff.inDays < 1) return l.agoHours(diff.inHours);
  if (diff.inDays < 7) return l.agoDays(diff.inDays);""")], ['../l10n.dart'])
print('notifications structure done')
