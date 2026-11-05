// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'social_app_l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SocialAppL10nEn extends SocialAppL10n {
  SocialAppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get posts => 'Posts';

  @override
  String get newPost => 'New post';

  @override
  String get noOwnPosts =>
      'You haven\'t shared any posts yet. Share your first photo or video.';

  @override
  String get noPosts => 'No posts yet.';

  @override
  String get shareFirstOwn => 'Share your first post';

  @override
  String get groupFirstPost => 'Be the first to post in the group\'s feed.';

  @override
  String get groupNoPosts => 'There are no posts in this group yet.';

  @override
  String get shareFirstGroup => 'Share the first post';

  @override
  String get groupNotFound => 'Group not found.';

  @override
  String get memoriesEmpty =>
      'No memories shared yet. Attendees can add their photos here.';

  @override
  String get plan => 'Plan';

  @override
  String get payment => 'Payment';

  @override
  String get onlyOwnerBilling => 'Only the group owner can manage plans.';

  @override
  String get backToGroup => 'Back to group';

  @override
  String get writeSupportAboutGroup =>
      'Contact the platform team about this group';

  @override
  String get search => 'Search';

  @override
  String get notifications => 'Notifications';

  @override
  String get goodNight => 'Good night';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String greetingName(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String get tabToday => 'Today';

  @override
  String get tabGroups => 'Groups';

  @override
  String get tabCalendar => 'Calendar';

  @override
  String get tabMe => 'Me';

  @override
  String get tonightSay => 'Free? Say so and set up a table';

  @override
  String get tonightTableSet => 'Your table is set';

  @override
  String get tonightInvited => 'You\'re invited to a table';

  @override
  String tonightFreeWithYou(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people are free like you',
      one: '1 person is free like you',
    );
    return '$_temp0';
  }

  @override
  String get tonightFreeUntil => 'You\'re free · until 4:00 AM';

  @override
  String tonightFreeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people are free tonight',
      one: '1 person is free tonight',
    );
    return '$_temp0';
  }

  @override
  String get upcomingNone => 'Your groups\' plans';

  @override
  String upcomingMine(int count, int mine) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plans',
      one: '1 plan',
    );
    return '$_temp0 · $mine joined';
  }

  @override
  String upcomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plans',
      one: '1 plan',
    );
    return '$_temp0, 60 days';
  }

  @override
  String get forToday => 'For today';

  @override
  String get tonight => 'Tonight';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get share => 'Share';

  @override
  String get post => 'Post';

  @override
  String get postHint => 'Up to 10 photos or videos';

  @override
  String get story => 'Story';

  @override
  String get storyHint => 'Visible for 24 hours';

  @override
  String get group => 'Group';

  @override
  String get groupHint => 'Start your own community';

  @override
  String get create => 'Create';

  @override
  String get messages => 'Messages';

  @override
  String get matching => 'Matching';

  @override
  String get myGroups => 'My groups';

  @override
  String get pageNotFound =>
      'We couldn\'t find that page. The link may be old or wrong.';

  @override
  String get backHome => 'Back to home';

  @override
  String get groupsLeague => 'Groups League';

  @override
  String get exploreOnMap => 'Explore on the map';

  @override
  String get yearMenu => 'Year in review, my exploration map and people I met';

  @override
  String get yearSummary => 'Year in review';

  @override
  String get yearSummaryHint => 'This year\'s meetups, as a card you can share';

  @override
  String get explorationMap => 'My exploration map';

  @override
  String get explorationMapHint => 'Provinces of the events you attended';

  @override
  String get metPeople => 'People I met';

  @override
  String get metPeopleHint => 'People you shook hands with at events';

  @override
  String get findTeammates => 'Find teammates';

  @override
  String get saved => 'Saved';

  @override
  String get gateError =>
      'Couldn\'t load your details. Check your connection and try again.';

  @override
  String get searchPeople => 'Search people';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get settings => 'Settings';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get teammatePrefs => 'Teammate preferences';

  @override
  String get matchProfile => 'Matching profile';

  @override
  String get voiceCalls => 'Voice calls';

  @override
  String get blockedAccounts => 'Blocked accounts';

  @override
  String get storyArchive => 'Story archive';

  @override
  String get notificationPrefs => 'Notification preferences';

  @override
  String get mySanctions => 'My group sanctions';

  @override
  String get userGuide => 'User guide';

  @override
  String get supportFeedback => 'Support and feedback';

  @override
  String newReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new replies',
      one: '1 new reply',
    );
    return '$_temp0';
  }

  @override
  String get twoFactor => 'Two-step verification';

  @override
  String get legalDocuments => 'Legal documents';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get signOut => 'Sign out';

  @override
  String get nowPrivate => 'Your account is now private.';

  @override
  String get nowPublic =>
      'Your account is now public; pending requests have been approved.';

  @override
  String get privateAccount => 'Private account';

  @override
  String get privateAccountHint =>
      'When on, only followers you approve can see your posts and stories.';

  @override
  String get groupsNowPublic =>
      'Your groups are now visible to everyone on your profile.';

  @override
  String get groupsNowMembers =>
      'Your groups are now visible only to members of the same group.';

  @override
  String get showGroups => 'Show my groups on my profile';

  @override
  String get showGroupsHint =>
      'When off, only members of a group can see that you belong to it; other groups\' admins can\'t.';

  @override
  String get language => 'Language';

  @override
  String get games => 'Games';

  @override
  String get chessHint =>
      'Quick games, challenge friends, climb the Elo leaderboard.';

  @override
  String get gamesHint => 'Chess: quick games, tournaments, team matches';
}
