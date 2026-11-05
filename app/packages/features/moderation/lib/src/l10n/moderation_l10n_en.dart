// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'moderation_l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class ModerationL10nEn extends ModerationL10n {
  ModerationL10nEn([String locale = 'en']) : super(locale);

  @override
  String get ruleRateLimited =>
      'You\'ve sent too many reports today. You can try again tomorrow.';

  @override
  String get ruleTargetInvalid =>
      'This content no longer exists or you can\'t see it.';

  @override
  String get ruleSelf => 'You can\'t report yourself or your own content.';

  @override
  String get ruleAppealNotAllowed => 'This sanction can no longer be appealed.';

  @override
  String get ruleDuplicate =>
      'You\'ve already reported this; it\'s under review.';

  @override
  String get deletedAccount => 'Deleted account';

  @override
  String get reasonSpam => 'Spam or misleading';

  @override
  String get reasonHarassment => 'Harassment or bullying';

  @override
  String get reasonHate => 'Hate speech';

  @override
  String get reasonViolence => 'Violence or threats';

  @override
  String get reasonSexual => 'Sexual content';

  @override
  String get reasonMisinformation => 'False information';

  @override
  String get reasonOther => 'Other';

  @override
  String get sanctionWarning => 'Warning';

  @override
  String get sanctionMute => 'Mute';

  @override
  String get sanctionKick => 'Removal from group';

  @override
  String get sanctionBan => 'Ban';

  @override
  String get illegalViolence => 'Violence';

  @override
  String get illegalThreat => 'Threat';

  @override
  String get illegalInsult => 'Insult';

  @override
  String get illegalHate => 'Hate speech';

  @override
  String get illegalSexual => 'Sexual abuse';

  @override
  String get illegalFraud => 'Fraud';

  @override
  String get illegalDrugs => 'Drugs';

  @override
  String get illegalTerror => 'Terrorism';

  @override
  String get illegalOther => 'Another crime';

  @override
  String muteDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days-day mute',
      one: '1-day mute',
    );
    return '$_temp0';
  }

  @override
  String banDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days-day ban',
      one: '1-day ban',
    );
    return '$_temp0';
  }

  @override
  String get permanentBan => 'Permanent ban';

  @override
  String get thresholdMajority => 'Simple majority';

  @override
  String get thresholdMajorityText => 'More than half of the votes';

  @override
  String get thresholdTwoThirds => 'Two-thirds';

  @override
  String get thresholdTwoThirdsText => 'At least two-thirds of the votes';

  @override
  String get thresholdUnanimous => 'Unanimous';

  @override
  String get thresholdUnanimousText => 'All of the votes';

  @override
  String get targetPost => 'Post';

  @override
  String get targetComment => 'Comment';

  @override
  String get targetEvent => 'Event';

  @override
  String get targetLiveComment => 'Live comment';

  @override
  String get targetMessage => 'Group chat message';

  @override
  String get targetMember => 'Member';

  @override
  String get appealPending => 'Awaiting decision';

  @override
  String get appealUpheld => 'Sanction upheld';

  @override
  String get appealOverturned => 'Sanction lifted';

  @override
  String get banApplied => 'Ban applied.';

  @override
  String get banAppliedSuspended =>
      'Ban applied. The person\'s account is suspended until the platform reviews it.';

  @override
  String get caseOpened => 'Case opened. The board will vote within 72 hours.';

  @override
  String get openCaseTitle => 'Open a disciplinary case';

  @override
  String caseAboutNow(String name) {
    return 'About $name. The ban is applied right away, without a board vote.';
  }

  @override
  String caseAboutVote(String name) {
    return 'About $name. The disciplinary board votes on your proposed sanction within 72 hours.';
  }

  @override
  String get proposedSanction => 'Proposed sanction';

  @override
  String get duration => 'Duration';

  @override
  String get permanent => 'Permanent';

  @override
  String get permanentLower => 'permanent';

  @override
  String days(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get applyNow => 'Apply now, without a vote';

  @override
  String get applyNowHint =>
      'Bans without waiting for the board. The person can appeal within 7 days.';

  @override
  String get illegalActivity => 'Illegal activity';

  @override
  String get illegalHintNow =>
      'Once the ban is applied, the case goes to the platform team and the account is suspended pending review. This mark can\'t be changed later.';

  @override
  String get illegalHintVote =>
      'If the board approves, the case goes to the platform team and the account is suspended pending review. This mark can\'t be changed later.';

  @override
  String get reason => 'Reason';

  @override
  String get reasonHintNow =>
      'What happened? The person and whoever reviews an appeal see this text.';

  @override
  String get reasonHintVote =>
      'What happened? The board will vote based on this text.';

  @override
  String get reasonMin10 => 'The reason must be at least 10 characters.';

  @override
  String get muteNow => 'Mute now (24 hours)';

  @override
  String get muteNowHint =>
      'Until the board decides, they can\'t comment or speak in live audio.';

  @override
  String get ban => 'Ban';

  @override
  String get openCase => 'Open case';

  @override
  String leftDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String leftDaysHours(int days, int hours) {
    return '${days}d ${hours}h';
  }

  @override
  String leftHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours hours',
      one: '1 hour',
    );
    return '$_temp0';
  }

  @override
  String get leftFewMinutes => 'a few minutes';

  @override
  String minChars(int min) {
    return 'Write at least $min characters.';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get threshold => 'Board decision threshold';

  @override
  String thresholdChanged(String threshold) {
    return 'The threshold is now \"$threshold\". It applies to new cases.';
  }

  @override
  String moderationOf(String group) {
    return 'Moderation · $group';
  }

  @override
  String get reports => 'Reports';

  @override
  String reportsCount(int count) {
    return 'Reports ($count)';
  }

  @override
  String get cases => 'Cases';

  @override
  String casesCount(int count) {
    return 'Cases ($count)';
  }

  @override
  String get sanctions => 'Sanctions';

  @override
  String sanctionsCount(int count) {
    return 'Sanctions ($count)';
  }

  @override
  String get moderationTeamOnly =>
      'Only the group owner and the moderation team see this group\'s moderation.';

  @override
  String get goBack => 'Go back';

  @override
  String get noReports => 'No open reports. Members\' reports gather here.';

  @override
  String get refresh => 'Refresh';

  @override
  String get removeContent => 'Remove content';

  @override
  String get remove => 'Remove';

  @override
  String get contentRemoved => 'Content removed.';

  @override
  String reportCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reports',
      one: '1 report',
    );
    return '$_temp0';
  }

  @override
  String get view => 'View';

  @override
  String get reportDismissed => 'Report dismissed.';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get openCaseShort => 'Open case';

  @override
  String get rankOnlyDismiss =>
      'This person\'s rank isn\'t below yours, so you can only dismiss.';

  @override
  String get noCases =>
      'No disciplinary cases yet. Cases are opened from a report or the members page.';

  @override
  String get voteApproved =>
      'Your vote was saved. The board approved the sanction; it has been applied.';

  @override
  String get voteRejected =>
      'Your vote was saved. The board rejected the sanction.';

  @override
  String get voteSaved =>
      'Your vote was saved. You can change it until there is a decision.';

  @override
  String get statusVoting => 'Voting';

  @override
  String get statusApproved => 'Approved';

  @override
  String get statusRejected => 'Rejected';

  @override
  String proposed(String sanction) {
    return 'Proposed: $sanction';
  }

  @override
  String get directBan => 'Ban without a vote';

  @override
  String illegalLabel(String category) {
    return 'Illegal activity: $category';
  }

  @override
  String tally(int approvals, int rejections, int voters) {
    return '$approvals for · $rejections against · $voters voters';
  }

  @override
  String votingEndsIn(String time) {
    return 'Voting ends in $time';
  }

  @override
  String bannedBy(String name) {
    return 'Banned by: $name';
  }

  @override
  String openedBy(String name) {
    return 'Opened by: $name';
  }

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Reject';

  @override
  String get noSanctions =>
      'No sanctions yet. Sanctions approved by the board and appeals appear here.';

  @override
  String get liftSanction => 'Lift the sanction';

  @override
  String get keepSanction => 'Keep the sanction';

  @override
  String get noteToPerson => 'Note to the person (optional)';

  @override
  String get liftedNotified => 'Sanction lifted; the person was notified.';

  @override
  String get appealRejectedNotified =>
      'Appeal rejected; the person was notified.';

  @override
  String get lifted => 'Lifted';

  @override
  String get interimMute => 'Emergency mute';

  @override
  String get running => 'Active';

  @override
  String get applied => 'Applied';

  @override
  String get interimUntilDecision => 'Emergency mute · until the board decides';

  @override
  String until(String date) {
    return 'until $date';
  }

  @override
  String appealLine(String status) {
    return 'Appeal · $status';
  }

  @override
  String noteLine(String note) {
    return 'Note: $note';
  }

  @override
  String get ownerParty =>
      'The owner is a party to this case, so the platform team reviews the appeal.';

  @override
  String get keep => 'Keep';

  @override
  String casesAwaitingVote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cases await your vote',
      one: '1 case awaits your vote',
    );
    return '$_temp0';
  }

  @override
  String appealsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count appeals',
      one: '1 appeal',
    );
    return '$_temp0';
  }

  @override
  String get moderation => 'Moderation';

  @override
  String get noWork => 'Nothing waiting';

  @override
  String get mySanctions => 'My sanctions';

  @override
  String get noMySanctions =>
      'You have no sanctions in any group. Thanks for following the community rules.';

  @override
  String get interimEnded => 'Emergency mute ended';

  @override
  String interimLatest(String date) {
    return 'Emergency mute · until the board decides, $date at the latest';
  }

  @override
  String untilCap(String date) {
    return 'Until $date';
  }

  @override
  String get ended => 'Ended';

  @override
  String get appeal => 'Appeal';

  @override
  String get appealHint => 'Why do you think it was unfair?';

  @override
  String get send => 'Send';

  @override
  String get appealSent =>
      'Your appeal was sent. You\'ll be notified when there\'s a decision.';

  @override
  String reasonLine(String reason) {
    return 'Reason: $reason';
  }

  @override
  String yourAppealLine(String status) {
    return 'Your appeal · $status';
  }

  @override
  String get appealOnce => 'You can appeal this decision once within 7 days.';

  @override
  String get reportPost => 'Report post';

  @override
  String get reportComment => 'Report comment';

  @override
  String get reportEvent => 'Report event';

  @override
  String get reportMessage => 'Report message';

  @override
  String get reportMatchProfile => 'Report matching profile';

  @override
  String get reportPhoto => 'Report photo';

  @override
  String get reportUser => 'Report user';

  @override
  String get reportReceived =>
      'We\'ve received your report. We\'ll review it and take action; your identity isn\'t shown to the reported person.';

  @override
  String get whyReport => 'Why are you reporting this?';

  @override
  String get detailsOptional => 'Details (optional)';

  @override
  String get detailsHint => 'Briefly describe what happened.';

  @override
  String get report => 'Report';
}
