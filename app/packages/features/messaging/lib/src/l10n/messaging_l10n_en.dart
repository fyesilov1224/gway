// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'messaging_l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class MessagingL10nEn extends MessagingL10n {
  MessagingL10nEn([String locale = 'en']) : super(locale);

  @override
  String get groupInvalid =>
      'You can only send the request to a group you belong to.';

  @override
  String get permissionExists =>
      'Your request was already received or your permission is on.';

  @override
  String get permissionCooldown =>
      'You can send a new request 7 days after the last decision.';

  @override
  String noteTooLong(int max) {
    return 'The note can be up to $max characters.';
  }

  @override
  String get requestForbidden => 'The request can\'t be sent right now.';

  @override
  String get unsupportedImage =>
      'This file type is not supported. Choose JPEG, PNG or WebP.';

  @override
  String get voiceCallHandle => 'GWAY voice call';

  @override
  String get incomingCalls => 'Incoming calls';

  @override
  String get missedCalls => 'Missed calls';

  @override
  String get answer => 'Answer';

  @override
  String get decline => 'Decline';

  @override
  String get noAnswer => 'No answer';

  @override
  String get missedCall => 'Missed call';

  @override
  String get callDeclined => 'Call declined';

  @override
  String get youDeclined => 'You declined the call';

  @override
  String get callNotAllowed => 'Calling is no longer possible';

  @override
  String get callCanceled => 'Call canceled';

  @override
  String get timeLimit => '60 minutes are up; the call has ended';

  @override
  String get endedNotAllowed =>
      'Call ended: voice calls are no longer possible';

  @override
  String get callEnded => 'Call ended';

  @override
  String get messageDeleted => 'Message deleted';

  @override
  String get photo => 'Photo';

  @override
  String get tonightTable => 'Tonight\'s table';

  @override
  String get blockRequestPending =>
      'Accept the message request before replying.';

  @override
  String get blockDeclined =>
      'This person didn\'t accept your message request.';

  @override
  String get blockMuted =>
      'You\'re muted in this group, so you can\'t write right now.';

  @override
  String get blockAdminsOnly => 'Only admins can write in this chat.';

  @override
  String get blockTableClosed =>
      'The table is closed; you can read messages but not write new ones.';

  @override
  String get blockBlocked => 'You can\'t write here because of a block.';

  @override
  String get blockMatchEnded =>
      'This chat is closed because the match has ended.';

  @override
  String get blockMatchLocked =>
      'Writing to your match needs the Match Chat plan. Reading messages is free.';

  @override
  String get blockTeammateLocked =>
      'Writing to your teammate needs the Teammate plan. Reading messages is free.';

  @override
  String get blockNotAllowed =>
      'Direct messages are now only for matches and teammates. You can still read your old messages.';

  @override
  String get blockOther => 'You can\'t write in this chat right now.';

  @override
  String get hiddenUser => 'GWAY user';

  @override
  String get voiceCalls => 'Voice calls';

  @override
  String get voiceCallsHeadline =>
      'Talk by voice with your matches and teammates';

  @override
  String voiceCallsIntro(int minutes) {
    return 'Voice calls let you call your matches and teammates from your private chat. They\'re not open to everyone: you request them from a group you belong to, and the group\'s owner or an admin turns them on. Calls are never recorded or listened to; a call lasts up to $minutes minutes.';
  }

  @override
  String get status => 'Status';

  @override
  String get notRequested => 'Not requested';

  @override
  String get underReview => 'Under review';

  @override
  String get statusOn => 'On';

  @override
  String get statusOff => 'Off';

  @override
  String get notRequestedYet => 'You haven\'t requested it yet.';

  @override
  String requestedFrom(String group) {
    return 'Your request reached $group\'s admins. You\'ll be notified when they decide.';
  }

  @override
  String get requestedFromGroup =>
      'Your request reached the group\'s admins. You\'ll be notified when they decide.';

  @override
  String activeFrom(String group) {
    return 'Your voice calls are on ($group). Call your matches and teammates with the phone icon at the top of the chat; they need permission too.';
  }

  @override
  String get active =>
      'Your voice calls are on. Call your matches and teammates with the phone icon at the top of the chat; they need permission too.';

  @override
  String get declined => 'Your request wasn\'t approved for now.';

  @override
  String get revokedLeftGroup =>
      'Your voice calls are off because you left the group that granted them. You can request again from another group.';

  @override
  String get revoked => 'Your voice calls were turned off.';

  @override
  String reasonLine(String reason) {
    return 'Reason: $reason';
  }

  @override
  String yourNote(String note) {
    return 'Your note: $note';
  }

  @override
  String waitUntil(String date) {
    return 'You can request again after $date.';
  }

  @override
  String get requestSent => 'Your request was sent.';

  @override
  String get joinGroupFirst =>
      'Group owners and admins turn on voice calls. Join a group first to request them.';

  @override
  String get requestToGroup => 'Group to send the request to';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get noteHint => 'You can briefly say why you want voice calls.';

  @override
  String get request => 'Request';

  @override
  String get lockScreenCalls => 'Calls on the lock screen';

  @override
  String get lockScreenHint =>
      'Let GWAY ring full screen when your phone is locked.';

  @override
  String get allow => 'Allow';

  @override
  String get callInfoFailed =>
      'Couldn\'t load the call. Check your connection.';

  @override
  String get tapEndToHangUp => 'Tap End to hang up.';

  @override
  String get callNotFound => 'This call was not found.';

  @override
  String get close => 'Close';

  @override
  String callLimitNote(int minutes) {
    return 'A call lasts up to $minutes minutes and is never recorded.';
  }

  @override
  String get audioFailed =>
      'Couldn\'t connect the audio. Check your connection and try again.';

  @override
  String get reconnect => 'Reconnect';

  @override
  String get incoming => 'is calling you…';

  @override
  String get calling => 'Calling…';

  @override
  String get connecting => 'Connecting…';

  @override
  String get answerCall => 'Answer';

  @override
  String get mute => 'Mute';

  @override
  String get unmute => 'Unmute';

  @override
  String get end => 'End';

  @override
  String get speaker => 'Speaker';

  @override
  String get peerUnencrypted =>
      'The other person\'s app is outdated; their audio isn\'t encrypted, so it isn\'t played. Ask them to update the app.';

  @override
  String get encrypting => 'Setting up an encrypted connection…';

  @override
  String e2eeCode(String code) {
    return 'End-to-end encrypted. Safety code $code';
  }

  @override
  String get e2ee => 'End-to-end encrypted';

  @override
  String get codeMatchHint =>
      'If this code matches the one on the other person\'s screen, nobody can listen in.';

  @override
  String get micFailed =>
      'Couldn\'t turn on the mic. Check the microphone permission.';

  @override
  String get chatNotFound =>
      'This chat wasn\'t found or you can no longer see it.';

  @override
  String get backToMessages => 'Back to messages';

  @override
  String get cantCallNow => 'You can\'t call right now.';

  @override
  String get voiceCall => 'Voice call';

  @override
  String get groupChatAdminsOnly => 'Group chat · only admins write';

  @override
  String get groupChat => 'Group chat';

  @override
  String smallTableMembers(int count) {
    return 'Small table · $count people';
  }

  @override
  String get adminsOnlyOn =>
      'Now only the group owner and admins can write in this chat.';

  @override
  String get adminsOnlyOff => 'Now all group members can write in this chat.';

  @override
  String get chatSettings => 'Chat settings';

  @override
  String get adminsOnlyToggle => 'Only admins can write';

  @override
  String get sendingPhoto => '📷 Sending photo…';

  @override
  String get requestPendingNote =>
      'Your message request was sent. Until it\'s accepted, you can\'t see whether it was read.';

  @override
  String get groupChatEmpty =>
      'No messages in the group chat yet. Write the first one.';

  @override
  String get chatEmpty => 'No messages yet. Write the first one.';

  @override
  String get startWriting => 'Start writing';

  @override
  String get sending => 'Sending…';

  @override
  String get seen => 'Seen';

  @override
  String get sent => 'Sent';

  @override
  String get seePackage => 'See the plan';

  @override
  String get today => 'Today';

  @override
  String get messageRemoved => 'This message was removed.';

  @override
  String get thisMessageDeleted => 'This message was deleted.';

  @override
  String get messageOptions => 'Message options';

  @override
  String profileOf(String name) {
    return '$name\'s profile';
  }

  @override
  String get you => 'You';

  @override
  String get copy => 'Copy';

  @override
  String get copied => 'Message copied.';

  @override
  String get deleteForAll => 'Delete for everyone';

  @override
  String get report => 'Report';

  @override
  String get deleteForAllTitle => 'Delete the message for everyone?';

  @override
  String get deleteForAllBody =>
      'Everyone in the chat will see \"This message was deleted\". This can\'t be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get requestDeleted => 'Message request deleted.';

  @override
  String wantsToMessage(String name) {
    return '$name wants to message you. If you accept, you can chat and they\'ll see when you\'ve read messages.';
  }

  @override
  String get accept => 'Accept';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get addPhoto => 'Add photo';

  @override
  String get writeMessage => 'Write a message';

  @override
  String get send => 'Send';

  @override
  String get messages => 'Messages';

  @override
  String get chats => 'Chats';

  @override
  String get requests => 'Requests';

  @override
  String requestsCount(int count) {
    return 'Requests ($count)';
  }

  @override
  String get noChats =>
      'You don\'t have any chats yet. You can write to your matches and teammates.';

  @override
  String get findPeople => 'Find people';

  @override
  String get oldRequestsNote =>
      'Old message requests stay here. Direct messages are now only for matches and teammates; no new requests arrive.';

  @override
  String get noRequests => 'No pending message requests.';

  @override
  String get backToChats => 'Back to chats';

  @override
  String get callRequests => 'Voice call requests';

  @override
  String noPendingWithActive(int count) {
    return 'No pending requests · $count active';
  }

  @override
  String pendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count requests waiting',
      one: '1 request waiting',
    );
    return '$_temp0';
  }

  @override
  String get pending => 'Pending';

  @override
  String get activeTab => 'Active';

  @override
  String get requestsOwnersOnly =>
      'Only the group owner and admins see voice call requests.';

  @override
  String get goBack => 'Go back';

  @override
  String noPendingFor(String group) {
    return 'No pending requests. When $group members request, they appear here.';
  }

  @override
  String get noActive => 'This group has not granted any voice calls.';

  @override
  String get refresh => 'Refresh';

  @override
  String get grantHint =>
      'With the permission you grant, the person can call all their matches and teammates. Calls are never recorded; the permission ends if they leave the group.';

  @override
  String get granted => 'Voice calls turned on.';

  @override
  String get turnedOff => 'Voice calls turned off.';

  @override
  String theirNote(String note) {
    return 'Note: $note';
  }

  @override
  String get turnOff => 'Turn off';

  @override
  String get turnOn => 'Turn on';

  @override
  String get rankOnlyGrant =>
      'Their rank is equal to or above yours, so you can only approve this request.';

  @override
  String get rankCannotRevoke =>
      'Their rank is equal to or above yours, so you can\'t turn this off.';

  @override
  String get declineRequest => 'Decline request';

  @override
  String get turnOffCalls => 'Turn off voice calls';

  @override
  String get declineHint =>
      'They see the reason and can request again after 7 days.';

  @override
  String get revokeHint =>
      'Any ongoing call ends right away. They see the reason and can request again after 7 days.';

  @override
  String get reason => 'Reason';

  @override
  String get reasonMin3 => 'The reason must be at least 3 characters.';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get sendMessage => 'Message';

  @override
  String get groupChatMembersOnly =>
      'Only group members can see the group chat.';
}
