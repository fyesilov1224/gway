// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'notifications_l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class NotificationsL10nEn extends NotificationsL10n {
  NotificationsL10nEn([String locale = 'en']) : super(locale);

  @override
  String get actLike => 'liked your post.';

  @override
  String actComment(String text) {
    return 'commented: $text';
  }

  @override
  String actReply(String text) {
    return 'replied to your comment: $text';
  }

  @override
  String actCommentLike(String text) {
    return 'liked your comment: $text';
  }

  @override
  String get actMentionPost => 'mentioned you in a post.';

  @override
  String actMentionComment(String text) {
    return 'mentioned you in a comment: $text';
  }

  @override
  String get actFollow => 'started following you.';

  @override
  String get actFollowRequest => 'wants to follow you.';

  @override
  String get actFollowAccepted => 'accepted your follow request.';

  @override
  String actLiveScheduled(String title) {
    return 'scheduled a live broadcast: $title';
  }

  @override
  String actLiveScheduledAt(String date, String title) {
    return 'scheduled a live broadcast for $date: $title';
  }

  @override
  String actLiveStarted(String title) {
    return 'is live now: $title';
  }

  @override
  String actEventPromoted(String title) {
    return 'A spot opened for \"$title\" — you\'re going now.';
  }

  @override
  String actEventUpdated(String title) {
    return 'changed the time or place of \"$title\".';
  }

  @override
  String actEventCanceled(String title) {
    return 'canceled \"$title\".';
  }

  @override
  String actReminderTomorrow(String title) {
    return '\"$title\" starts tomorrow. Are you coming? Confirm.';
  }

  @override
  String actReminderHour(String title) {
    return '\"$title\" starts within an hour.';
  }

  @override
  String actCaseVote(String group) {
    return 'opened a disciplinary case in $group; your vote is needed.';
  }

  @override
  String get actMuted => 'muted you. Tap for details or to appeal.';

  @override
  String get actKicked =>
      'removed you from the group. Tap for details or to appeal.';

  @override
  String get actBanned =>
      'banned you from the group. Tap for details or to appeal.';

  @override
  String get actWarned => 'gave you a warning. Tap for details or to appeal.';

  @override
  String actAppealSubmitted(String group) {
    return 'appealed a sanction in $group.';
  }

  @override
  String get actAppealDecided => 'decided on your appeal.';

  @override
  String actEventApproved(String title) {
    return 'approved your request to join \"$title\".';
  }

  @override
  String actEventDeclined(String title) {
    return 'couldn\'t accept your request to join \"$title\".';
  }

  @override
  String actEventReview(String title) {
    return 'How was \"$title\"? Rate it and share your memories.';
  }

  @override
  String actGoalCompleted(String title) {
    return 'You completed \"$title\"! Your badge is on your profile.';
  }

  @override
  String get actTeammateRequest => 'wants to be your teammate.';

  @override
  String get actTeammateAccepted => 'accepted your teammate request.';

  @override
  String get actMatchCreated => 'See who it is in My matches.';

  @override
  String get actSuperLiked =>
      'super liked you! They show up first in your deck.';

  @override
  String actWelcomeRequested(String title) {
    return 'is coming to \"$title\" for the first time and would like to be welcomed.';
  }

  @override
  String actWelcomeMatched(String title) {
    return 'will welcome you at \"$title\". See the meeting note.';
  }

  @override
  String actWelcomeReleased(String title) {
    return 'can\'t welcome you at \"$title\" anymore; we\'re finding someone else.';
  }

  @override
  String actWelcomeWithdrawn(String title) {
    return 'withdrew their welcome request for \"$title\".';
  }

  @override
  String get actLeagueResult =>
      'made the top three in last month\'s league! See the standings on the group page.';

  @override
  String actWelcomeThanked(String title) {
    return 'thanked you for welcoming them at \"$title\".';
  }

  @override
  String get actTableInvite =>
      'set up a small table tonight and is inviting you.';

  @override
  String get actTableReady =>
      'joined the table; it’s set. Agree on the place and time in the chat.';

  @override
  String actVenueRevealed(String title) {
    return '\"$title\": tap to see where to go.';
  }

  @override
  String actHandshake(String title) {
    return 'shook hands with you at \"$title\".';
  }

  @override
  String get actCallMissed => 'called you; you missed it.';

  @override
  String get actCallGranted =>
      '— you now have permission. You can call your matches from the chat.';

  @override
  String get actCallDeclined =>
      '— your request wasn’t approved for now. Tap for details.';

  @override
  String get actCallRevoked =>
      '— your permission was turned off. Tap for details.';

  @override
  String actSeriesLimit(String title) {
    return '— the next date for \"$title\" couldn\'t open: the group\'s event limit for this month is reached. It opens when the new month starts or the plan is upgraded.';
  }

  @override
  String get leadNewMatch => 'You have a new match!';

  @override
  String get leadSeries => 'Repeating event';

  @override
  String get leadVenue => 'Surprise venue revealed';

  @override
  String get leadCalls => 'Voice calls';

  @override
  String get periodToday => 'Today';

  @override
  String get periodWeek => 'This week';

  @override
  String get periodEarlier => 'Earlier';

  @override
  String get agoNow => 'now';

  @override
  String agoMinutes(int n) {
    return '${n}m';
  }

  @override
  String agoHours(int n) {
    return '${n}h';
  }

  @override
  String agoDays(int n) {
    return '${n}d';
  }

  @override
  String get join => 'Join';

  @override
  String get see => 'View';

  @override
  String get prefsTitle => 'Notification preferences';

  @override
  String get messages => 'Messages';

  @override
  String get directMessages => 'Direct messages';

  @override
  String get directMessagesHint =>
      'When a direct message arrives, with sound even when the app is closed';

  @override
  String get groupMessages => 'Group messages';

  @override
  String get groupMessagesHint =>
      'When messages arrive in group chats and tonight\'s table, with sound even when the app is closed';

  @override
  String get events => 'Events';

  @override
  String get remindDay => 'Remind me 1 day before';

  @override
  String get remindDayHint => 'If an event you joined starts tomorrow';

  @override
  String get remindHour => 'Remind me 1 hour before';

  @override
  String get remindHourHint => 'If an event you joined starts within an hour';

  @override
  String get changes => 'Changes and cancellations';

  @override
  String get changesHint =>
      'When the time or place changes, or an event is canceled';

  @override
  String get reviewRequests => 'Review requests';

  @override
  String get reviewRequestsHint =>
      'Ask \"How was it?\" after an event you attended ends';

  @override
  String get live => 'Live broadcasts';

  @override
  String get liveAlerts => 'Scheduled and started broadcasts';

  @override
  String get liveAlertsHint =>
      'When your group schedules or starts a broadcast, with a sound alert if the app is open';

  @override
  String get matching => 'Matching';

  @override
  String get newMatches => 'New matches';

  @override
  String get newMatchesHint => 'When you and someone like each other';

  @override
  String get alwaysSent =>
      'The result of your join requests, moving up from a waitlist and group sanctions concern you directly, so they are always notified.';

  @override
  String get notifications => 'Notifications';

  @override
  String get empty => 'Likes, comments and new followers appear here.';

  @override
  String get refresh => 'Refresh';

  @override
  String get followRequests => 'Follow requests';

  @override
  String andOthers(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count others',
      one: '1 other',
    );
    return '$name and $_temp0';
  }

  @override
  String get delete => 'Delete';

  @override
  String get actChessChallenge => 'invited you to play chess.';
}
