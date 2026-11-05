// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'profile_l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class ProfileL10nEn extends ProfileL10n {
  ProfileL10nEn([String locale = 'en']) : super(locale);

  @override
  String get unsupportedImage =>
      'This file type is not supported. Choose JPEG, PNG or WebP.';

  @override
  String get usernameTaken => 'This username is taken. Try another one.';

  @override
  String get checkInput => 'Check the details you entered.';

  @override
  String get usernameReserved =>
      'This username can\'t be used. Try another one.';

  @override
  String get usernameCooldown =>
      'You can change your username only once every 30 days.';

  @override
  String get maxInterests10 => 'You can choose up to 10 interests.';

  @override
  String get levelBeginner => 'Beginner';

  @override
  String get levelBeginnerHint => 'I\'m just starting';

  @override
  String get levelIntermediate => 'Intermediate';

  @override
  String get levelIntermediateHint => 'I do it regularly';

  @override
  String get levelAdvanced => 'Advanced';

  @override
  String get levelAdvancedHint => 'I\'m experienced';

  @override
  String get slotWeekdayMorning => 'Weekday mornings';

  @override
  String get slotWeekdayNoon => 'Weekday middays';

  @override
  String get slotWeekdayEvening => 'Weekday evenings';

  @override
  String get slotWeekendMorning => 'Weekend mornings';

  @override
  String get slotWeekendAfternoon => 'Weekend afternoons';

  @override
  String get slotWeekendEvening => 'Weekend evenings';

  @override
  String get partMorning => 'Morning';

  @override
  String get partNoon => 'Midday';

  @override
  String get partEvening => 'Evening';

  @override
  String get goalFun => 'Having fun';

  @override
  String get goalFitness => 'Staying fit';

  @override
  String get goalCompetition => 'Training for a competition';

  @override
  String get goalLearning => 'Learning new things';

  @override
  String get goalMentoring => 'Sharing my experience';

  @override
  String get goalSocial => 'Meeting new people';

  @override
  String get freqMonthly => 'A few times a month';

  @override
  String get freqWeekly => 'Once a week';

  @override
  String get freqFewWeekly => '2–3 times a week';

  @override
  String get freqDaily => 'Almost every day';

  @override
  String get sizePair => 'One-on-one';

  @override
  String get sizeSmall => 'Small group (3–6)';

  @override
  String get sizeLarge => 'Large group';

  @override
  String get looking => 'Looking for a team';

  @override
  String lookingWithLevel(String level) {
    return 'Looking for a team · $level';
  }

  @override
  String reasonActivities(String list) {
    return 'Same activity: $list';
  }

  @override
  String reasonInterests(String list) {
    return 'Shared interests: $list';
  }

  @override
  String get reasonProvince => 'You\'re in the same province';

  @override
  String reasonGroup(String group) {
    return 'Shared group: $group';
  }

  @override
  String reasonGroups(int count) {
    return '$count shared groups';
  }

  @override
  String reasonLevel(String level) {
    return 'Same level: $level';
  }

  @override
  String reasonTimes(String list) {
    return 'Free at: $list';
  }

  @override
  String reasonGoals(String list) {
    return 'Shared goals: $list';
  }

  @override
  String get reasonFrequency => 'You want to meet equally often';

  @override
  String get hasVehicle => 'Has a vehicle';

  @override
  String get hasEquipment => 'Has own equipment';

  @override
  String get usernameRequired => 'Choose a username.';

  @override
  String usernameMin(int min) {
    return 'Your username must be at least $min characters.';
  }

  @override
  String usernameMax(int max) {
    return 'Your username can be at most $max characters.';
  }

  @override
  String get usernameChars =>
      'Use only a–z, 0–9, underscore (_) and period (.).';

  @override
  String get usernameDots => 'Your username can\'t start or end with a period.';

  @override
  String get usernameDoubleDot => 'You can\'t use two periods in a row.';

  @override
  String get nameRequired => 'Enter your name.';

  @override
  String nameMax(int max) {
    return 'Your name can be at most $max characters.';
  }

  @override
  String get editProfile => 'Edit profile';

  @override
  String get save => 'Save';

  @override
  String get profileInfo => 'Profile details';

  @override
  String get profileInfoHint =>
      'These details are visible to everyone on your profile.';

  @override
  String get yourName => 'Your name';

  @override
  String get usernameEvery30 =>
      'You can change your username once every 30 days.';

  @override
  String usernameLockedUntil(String date) {
    return 'You can change it after $date.';
  }

  @override
  String get about => 'About';

  @override
  String get aboutHint =>
      'Tell people about yourself and the activities you love.';

  @override
  String get interests => 'Interests';

  @override
  String interestsMax(int max) {
    return 'You can choose up to $max.';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get remove => 'Remove';

  @override
  String get removeCover => 'Remove cover photo';

  @override
  String get addCover => 'Add cover';

  @override
  String get changeCover => 'Change cover';

  @override
  String get changeAvatar => 'Change profile photo';

  @override
  String get photos => 'Profile and cover photo';

  @override
  String get photosHint => 'JPEG, PNG or WebP · up to 5 MB';

  @override
  String get addAvatar => 'Add profile photo';

  @override
  String get removeAvatar => 'Remove profile photo';

  @override
  String get followers => 'Followers';

  @override
  String get following => 'Following';

  @override
  String get privateLists =>
      'This account is private. Follow it to see its lists.';

  @override
  String get backToProfile => 'Back to profile';

  @override
  String get noFollowers => 'No followers yet.';

  @override
  String get noFollowing => 'Not following anyone yet.';

  @override
  String get refresh => 'Refresh';

  @override
  String get removeFollower => 'Remove follower';

  @override
  String removeFollowerBody(String username) {
    return 'Remove $username from your followers? They won’t be notified.';
  }

  @override
  String get removeAction => 'Remove';

  @override
  String get friends => 'You\'re friends';

  @override
  String get followRequests => 'Follow requests';

  @override
  String get noFollowRequests =>
      'No pending follow requests. Private accounts approve requests here.';

  @override
  String get approve => 'Approve';

  @override
  String get delete => 'Delete';

  @override
  String get blockedAccounts => 'Blocked accounts';

  @override
  String get noBlocked =>
      'You haven\'t blocked anyone. You can block from a profile\'s menu.';

  @override
  String get unblock => 'Unblock';

  @override
  String get onboardWho => 'Let\'s get to know you';

  @override
  String get onboardWhoHint =>
      'Choose the name and username shown on your profile.';

  @override
  String get onboardPhoto => 'Profile photo';

  @override
  String get onboardPhotoHint =>
      'Let your groups recognise you. You can also add one later.';

  @override
  String get onboardInterests => 'Your interests';

  @override
  String onboardInterestsHint(int max) {
    return 'Pick up to $max so we can suggest groups that suit you.';
  }

  @override
  String get back => 'Back';

  @override
  String stepOf(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get signOut => 'Sign out';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get continueAction => 'Continue';

  @override
  String get finish => 'Finish';

  @override
  String get usernameHelper => 'Use lowercase letters, numbers, _ and .';

  @override
  String get avatarPreview => 'Profile photo preview';

  @override
  String get choosePhoto => 'Choose photo';

  @override
  String get chooseAnotherPhoto => 'Choose another photo';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get profileNotFound =>
      'This profile was not found or is no longer visible.';

  @override
  String get backToMyProfile => 'Back to my profile';

  @override
  String suspendedUntil(String date) {
    return 'This account is suspended until $date.';
  }

  @override
  String get followsYou => 'Follows you';

  @override
  String get yourTeammate => 'Your teammate';

  @override
  String joined(String date) {
    return 'Joined $date';
  }

  @override
  String followRequestsPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count follow requests are waiting for approval.',
      one: '1 follow request is waiting for approval.',
    );
    return '$_temp0';
  }

  @override
  String get review => 'Review';

  @override
  String teammateRequestsPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count teammate requests are waiting for you.',
      one: '1 teammate request is waiting for you.',
    );
    return '$_temp0';
  }

  @override
  String get youBlocked => 'You blocked this account';

  @override
  String get youBlockedHint =>
      'If you unblock, you\'ll see each other\'s posts again.';

  @override
  String get privateAccount => 'This account is private';

  @override
  String get privateAccountHint =>
      'Follow this account to see its photos, videos and stories.';

  @override
  String get addInterestsNudge =>
      'Add your interests and we\'ll find groups and teammates for you.';

  @override
  String get add => 'Add';

  @override
  String blockTitle(String username) {
    return 'Block $username?';
  }

  @override
  String get blockBody =>
      'They won\'t see your profile, posts or stories, find you or message you. You\'ll stop following each other. They won\'t be told you blocked them.';

  @override
  String get block => 'Block';

  @override
  String get becomeTeammates => 'Become teammates';

  @override
  String nowTeammates(String name) {
    return 'You and $name are now teammates.';
  }

  @override
  String get acceptTeammate => 'Accept teammate request';

  @override
  String get requestWithdrawn => 'Request withdrawn.';

  @override
  String get withdrawTeammate => 'Withdraw teammate request';

  @override
  String get teammateEnded => 'Teammate connection ended.';

  @override
  String get endTeammate => 'End teammate connection';

  @override
  String get moreOptions => 'More options';

  @override
  String get linkCopied => 'Profile link copied.';

  @override
  String get copyLink => 'Copy profile link';

  @override
  String get removedFromFollowers => 'Removed from your followers.';

  @override
  String get removeFromFollowers => 'Remove from my followers';

  @override
  String get report => 'Report';

  @override
  String get unblocked => 'Unblocked.';

  @override
  String get statPosts => 'Posts';

  @override
  String get statFollowers => 'Followers';

  @override
  String get statFollowing => 'Following';

  @override
  String withdrawFollowBody(String username) {
    return 'Withdraw your follow request to $username?';
  }

  @override
  String unfollowBody(String username) {
    return 'Unfollow $username?';
  }

  @override
  String unfollowPrivateBody(String username) {
    return 'Unfollow $username? The account is private, so you would need to send a new request to see their posts.';
  }

  @override
  String get withdrawRequest => 'Withdraw request';

  @override
  String get unfollow => 'Unfollow';

  @override
  String get followBack => 'Follow back';

  @override
  String get follow => 'Follow';

  @override
  String get requestSent => 'Requested';

  @override
  String get followingState => 'Following';

  @override
  String noAccountMatch(String query) {
    return 'No accounts match \"$query\".';
  }

  @override
  String get clearSearch => 'Clear search';

  @override
  String get searchHint => 'Start typing to search for people or tags.';

  @override
  String get refreshSuggestions => 'Refresh suggestions';

  @override
  String get suggestionsForYou => 'Suggested for you';

  @override
  String mutualFollows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Followed by $count people you follow',
      one: 'Followed by 1 person you follow',
    );
    return '$_temp0';
  }

  @override
  String get popularAccount => 'Popular account';

  @override
  String get seePackage => 'See the plan';

  @override
  String requestSentNotify(String name) {
    return 'Request sent. We\'ll let you know when $name accepts.';
  }

  @override
  String becomeTeammatesWith(String name) {
    return 'Become teammates with $name';
  }

  @override
  String get shortMessage => 'A short message (optional)';

  @override
  String get shortMessageHint => 'Saturday morning in the park?';

  @override
  String get sendRequest => 'Send request';

  @override
  String get findTeammates => 'Find teammates';

  @override
  String get myTeammatePrefs => 'My teammate preferences';

  @override
  String get tabSuggestions => 'Suggestions';

  @override
  String get tabRequests => 'Requests';

  @override
  String tabRequestsCount(int count) {
    return 'Requests ($count)';
  }

  @override
  String get tabMyTeam => 'My team';

  @override
  String get findYourTeammate => 'Find your teammate';

  @override
  String waitingForYou(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people want to be your teammate',
      one: '1 person wants to be your teammate',
    );
    return '$_temp0';
  }

  @override
  String get teammatesLocked =>
      'Seeing suggestions, sending and accepting requests and messaging your teammates come with the Teammate plan.';

  @override
  String get beVisible => 'Be visible too';

  @override
  String get beVisibleBody =>
      'Turn on \"Looking for a team\" and people who love the same things can send you requests.';

  @override
  String get setPrefs => 'Set my preferences';

  @override
  String get nowPublicSuggest =>
      'Your account is now public; you can appear in suggestions.';

  @override
  String get privateHidden =>
      'Your account is private, so you don\'t appear in suggestions';

  @override
  String get privateHiddenBody =>
      'Private accounts don\'t appear in teammate suggestions. If you make your account public, pending follow requests are approved too.';

  @override
  String get makePublic => 'Make my account public';

  @override
  String get noSuggestions =>
      'No matches for now. Fill in your interests and preferences to get more suggestions.';

  @override
  String quoted(String text) {
    return '\"$text\"';
  }

  @override
  String get whySuggested => 'Why suggested';

  @override
  String get noPendingTeammate => 'No pending teammate requests.';

  @override
  String get seeSuggestions => 'See suggestions';

  @override
  String get incoming => 'Received';

  @override
  String get accept => 'Accept';

  @override
  String get decline => 'Decline';

  @override
  String get requestDeclined => 'Request declined.';

  @override
  String get outgoing => 'Sent';

  @override
  String get awaitingReply => 'Awaiting reply';

  @override
  String get withdraw => 'Withdraw';

  @override
  String get noTeammates =>
      'You don\'t have teammates yet. Start by sending a request to someone suggested.';

  @override
  String optionsFor(String name) {
    return 'Options for $name';
  }

  @override
  String get teammatePrefs => 'Teammate preferences';

  @override
  String get prefsSavedVisible =>
      'Preferences saved. You\'ll now appear in suggestions.';

  @override
  String get prefsSaved => 'Preferences saved.';

  @override
  String get whatToDo => 'What do you want to do?';

  @override
  String activitiesHint(int max) {
    return 'Activities you want teammates for. Up to $max.';
  }

  @override
  String get yourLevel => 'Your level';

  @override
  String get yourGoals => 'Your goals';

  @override
  String get multipleChoice => 'You can choose more than one.';

  @override
  String get howOften => 'How often do you want to meet?';

  @override
  String get whenFree => 'When are you free?';

  @override
  String get whenFreeHint => 'Tap the times you\'re free.';

  @override
  String get whatTeam => 'What kind of team do you want?';

  @override
  String get whichProvince => 'Which province are you in?';

  @override
  String get provinceHint =>
      'Only used for matching; it doesn\'t appear on your profile.';

  @override
  String get province => 'Province';

  @override
  String get ratherNotSay => 'I\'d rather not say';

  @override
  String get extras => 'Extra details';

  @override
  String get iHaveVehicle => 'I have a vehicle';

  @override
  String get iHaveVehicleHint => 'I can share rides.';

  @override
  String get iHaveEquipment => 'I have my own equipment';

  @override
  String get iHaveEquipmentHint =>
      'My bike, tent, racket or other gear is ready.';

  @override
  String get describeYourself => 'Describe yourself';

  @override
  String get describeHint => 'Shown under your name in suggestions.';

  @override
  String get describeExample =>
      'Looking for someone for weekend morning walks.';

  @override
  String get willAppear => 'You\'ll appear in suggestions.';

  @override
  String get notAppearing => 'You don\'t appear in suggestions right now.';

  @override
  String get lookingForTeam => 'I\'m looking for a team';

  @override
  String get lookingOn =>
      'You appear in suggestions; people can send you teammate requests.';

  @override
  String get lookingOff =>
      'Turn it on and people who love the same things will find you. Private accounts don\'t appear in suggestions.';

  @override
  String prefsComplete(int percent) {
    return 'Preferences $percent% complete';
  }

  @override
  String get prefsCompleteHint =>
      'The more you fill in, the better your suggestions.';

  @override
  String get weekday => 'Weekdays';

  @override
  String get weekend => 'Weekends';

  @override
  String get username => 'Username';

  @override
  String get available => 'Available';

  @override
  String get taken => 'Taken';

  @override
  String blockedUser(String username) {
    return '$username is blocked.';
  }
}
