// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'live_l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class LiveL10nEn extends LiveL10n {
  LiveL10nEn([String locale = 'en']) : super(locale);

  @override
  String get commentRate =>
      'You\'ve commented a lot in a short time. Wait a bit and try again.';

  @override
  String get mutedListenOnly =>
      'You\'re muted in this group, so you can only listen.';

  @override
  String get cannotComment => 'You can\'t comment on this broadcast right now.';

  @override
  String get roleHost => 'Host';

  @override
  String get roleSpeaker => 'Speaker';

  @override
  String get roleListener => 'Listener';

  @override
  String get startLive => 'Go live';

  @override
  String hostedBy(String name) {
    return 'Hosted by $name';
  }

  @override
  String get join => 'Join';

  @override
  String upcomingAt(String date) {
    return 'Upcoming · $date';
  }

  @override
  String get scheduledCanceled => 'Scheduled broadcast canceled.';

  @override
  String get cancel => 'Cancel';

  @override
  String get start => 'Start';

  @override
  String get reminderRemoved => 'Reminder removed.';

  @override
  String get reminderSet => 'We\'ll let you know when it starts.';

  @override
  String get reminding => 'Reminder on';

  @override
  String get remind => 'Remind me';

  @override
  String get schedule5min =>
      'A scheduled broadcast must be at least 5 minutes from now.';

  @override
  String get scheduled =>
      'Broadcast scheduled. Members can ask for a reminder.';

  @override
  String get liveBroadcast => 'Live broadcast';

  @override
  String get liveIntro =>
      'Group members join the audio room; people you bring on stage can speak.';

  @override
  String get title => 'Title';

  @override
  String get titleExample => 'E.g. Planning Sunday\'s hike';

  @override
  String get titleMin3 => 'The title must be at least 3 characters.';

  @override
  String get now => 'Now';

  @override
  String get scheduleIt => 'Schedule';

  @override
  String minutesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes of live time left this month.',
      one: '1 minute of live time left this month.',
    );
    return '$_temp0';
  }

  @override
  String get minutesUsedUp =>
      'This month\'s live time is used up. Upgrade your plan for more.';

  @override
  String get startTheLive => 'Start broadcast';

  @override
  String get liveNow => 'Live now';

  @override
  String trayLabel(String group, String title) {
    return '$group is live: $title';
  }

  @override
  String youAreLive(String title) {
    return 'You\'re in a live broadcast: $title. Tap to go back.';
  }

  @override
  String get connecting => 'Connecting to the broadcast…';

  @override
  String get inBroadcast => 'You\'re live · tap to go back';

  @override
  String get micMutedByMod => 'A manager turned off your mic';

  @override
  String get micOff => 'Turn off mic';

  @override
  String get micOn => 'Turn on mic';

  @override
  String startsOn(String date) {
    return 'This broadcast starts on $date.';
  }

  @override
  String get ended => 'This broadcast has ended.';

  @override
  String get notFound =>
      'This broadcast wasn\'t found. You may need to be a member of the group.';

  @override
  String get goBack => 'Go back';

  @override
  String get onStageNow => 'You\'re on stage. Turn on your mic to speak.';

  @override
  String get nowListener => 'You\'re a listener now.';

  @override
  String get leaveBroadcast => 'Leave broadcast';

  @override
  String get leaveHostBody =>
      'You can end it for everyone. If you just leave, it ends by itself after 2 minutes.';

  @override
  String get justLeave => 'Just leave';

  @override
  String get endBroadcast => 'End broadcast';

  @override
  String get inviteToStage => 'Invite to stage';

  @override
  String get removeFromStage => 'Remove from stage';

  @override
  String get muteMic => 'Turn off their mic';

  @override
  String get unmuteMic => 'Turn on their mic';

  @override
  String get kick => 'Remove from broadcast';

  @override
  String kickBody(String name) {
    return '$name won\'t be able to join this broadcast again.';
  }

  @override
  String get cancelAction => 'Cancel';

  @override
  String get remove => 'Remove';

  @override
  String get raisedHands => 'Raised hands';

  @override
  String get commentDeleted => 'Comment deleted.';

  @override
  String get thanksForJoining => 'The broadcast has ended. Thanks for joining.';

  @override
  String get youWereKicked => 'You were removed from this broadcast.';

  @override
  String get connectFailedShort => 'Couldn\'t connect to the broadcast.';

  @override
  String handsRaised(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hands raised',
      one: '1 hand raised',
    );
    return '$_temp0';
  }

  @override
  String get onStage => 'On stage';

  @override
  String listeners(int count) {
    return 'Listeners · $count';
  }

  @override
  String get noListeners => 'No listeners yet.';

  @override
  String get minimize => 'Minimize and stay in the broadcast';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
    );
    return '$_temp0';
  }

  @override
  String get broadcastOptions => 'Broadcast options';

  @override
  String get endForAll => 'End for everyone';

  @override
  String get handRaised =>
      'Your hand is raised. The host may bring you on stage.';

  @override
  String get you => 'You';

  @override
  String get speaking => 'speaking';

  @override
  String get micOffState => 'mic off';

  @override
  String get handUp => 'hand raised';

  @override
  String get sendReaction => 'Send a reaction';

  @override
  String get leave => 'Leave';

  @override
  String get leaveStage => 'Leave the stage';

  @override
  String get reactions => 'Reactions';

  @override
  String get comments => 'Comments';

  @override
  String get raiseHand => 'Raise hand';

  @override
  String get lowerHand => 'Lower hand';

  @override
  String get report => 'Report';

  @override
  String get deleteComment => 'Delete comment';

  @override
  String get firstComment => 'Be the first to comment.';

  @override
  String get writeComment => 'Write a comment…';

  @override
  String get send => 'Send';

  @override
  String get connectFailed =>
      'Couldn\'t connect to the broadcast. Check your connection and try again.';

  @override
  String get participant => 'Participant';

  @override
  String get micNeedsManager =>
      'Only a broadcast manager can turn your mic on.';

  @override
  String get micFailed =>
      'Couldn\'t turn on the mic. Check the microphone permission.';
}
