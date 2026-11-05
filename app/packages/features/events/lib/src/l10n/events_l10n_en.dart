// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'events_l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class EventsL10nEn extends EventsL10n {
  EventsL10nEn([String locale = 'en']) : super(locale);

  @override
  String get pollSingle => 'You can pick only one option in this poll.';

  @override
  String get pollOptionGone =>
      'This option no longer exists. Refresh the page.';

  @override
  String get reviewWindow =>
      'Attendees can review the event for 30 days after it ends.';

  @override
  String get greeterNeedsAttendance =>
      'To be a greeter, you must have attended one of the group’s events.';

  @override
  String get note80 => 'The note can be up to 80 characters.';

  @override
  String get pollClosed => 'This poll is closed or you can\'t vote.';

  @override
  String get cover5mb => 'The cover image can be up to 5 MB.';

  @override
  String get imagesOnly => 'Only JPEG, PNG or WebP images can be uploaded.';

  @override
  String get claimNotAllowed =>
      'You can\'t report this task right now: it has ended or you\'re not in the group.';

  @override
  String get claimApprovedLocked => 'An approved report can\'t be withdrawn.';

  @override
  String get claimDuplicate => 'You\'ve already reported this task.';

  @override
  String get repeatsWeekly => 'Repeats every week';

  @override
  String get repeatsBiweekly => 'Repeats every other week';

  @override
  String surprisePlace(String place) {
    return 'Surprise venue · $place';
  }

  @override
  String get goalPersonal => 'Personal goal';

  @override
  String get goalPersonalHint => 'Each member reaches their own count.';

  @override
  String get goalGroup => 'Group goal';

  @override
  String get goalGroupHint =>
      'Everyone\'s contributions add up in one counter.';

  @override
  String get goalTeam => 'Team goal';

  @override
  String get goalTeamHint =>
      'Admins form the teams; each team has a shared counter.';

  @override
  String get goalTask => 'Approved task';

  @override
  String get goalTaskHint => 'A member says \"Done\" and an admin approves.';

  @override
  String unitAttended(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'attendances',
      one: 'attendance',
    );
    return '$_temp0';
  }

  @override
  String unitOrganized(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'events organized',
      one: 'event organized',
    );
    return '$_temp0';
  }

  @override
  String unitMemories(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'memories',
      one: 'memory',
    );
    return '$_temp0';
  }

  @override
  String get claimPending => 'Awaiting approval';

  @override
  String get claimApproved => 'Approved';

  @override
  String get claimRejected => 'Not approved';

  @override
  String get notClaimedYet => 'Not reported yet';

  @override
  String get whenAny => 'Any time';

  @override
  String get whenToday => 'Today';

  @override
  String get whenWeek => 'Within 7 days';

  @override
  String get viewDay => 'Day';

  @override
  String get viewWeek => 'Week';

  @override
  String get viewMonth => 'Month';

  @override
  String countAttended(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count events attended',
      one: '1 event attended',
    );
    return '$_temp0';
  }

  @override
  String countOrganized(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count events organized',
      one: '1 event organized',
    );
    return '$_temp0';
  }

  @override
  String countMemories(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count memories',
      one: '1 memory',
    );
    return '$_temp0';
  }

  @override
  String countReviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '1 review',
    );
    return '$_temp0';
  }

  @override
  String countWelcomed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count newcomers welcomed',
      one: '1 newcomer welcomed',
    );
    return '$_temp0';
  }

  @override
  String countHandshakes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count handshakes',
      one: '1 handshake',
    );
    return '$_temp0';
  }

  @override
  String countHeld(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count events',
      one: '1 event',
    );
    return '$_temp0';
  }

  @override
  String countGoodReviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count happy reviews',
      one: '1 happy review',
    );
    return '$_temp0';
  }

  @override
  String leagueStanding(String month, int groups, int rank, int points) {
    return '$month: ranked $rank of $groups groups, $points points.';
  }

  @override
  String goingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count going',
      one: '1 going',
    );
    return '$_temp0';
  }

  @override
  String goingOfCapacity(int count, int capacity) {
    return '$count / $capacity going';
  }

  @override
  String firstEventOfYear(String title) {
    return 'First event of the year: $title';
  }

  @override
  String firstEventOfYearOn(String title, String date) {
    return 'First event of the year: $title · $date';
  }

  @override
  String get myCalendar => 'My calendar';

  @override
  String get groupCalendar => 'Group calendar';

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get today => 'Today';

  @override
  String get groupsEvents => 'My groups\' events';

  @override
  String get showNotJoined => 'Also show ones you haven\'t joined';

  @override
  String get noJoinedInRange =>
      'You haven\'t joined any events on these dates. You can also look at your groups\' events.';

  @override
  String get noEventsInRange => 'No events on these dates.';

  @override
  String get showGroupsEvents => 'Show my groups\' events';

  @override
  String get backToToday => 'Back to today';

  @override
  String get noEventsDay => 'No events on this day.';

  @override
  String get contributions => 'Community contribution';

  @override
  String get howBadges => 'How do you earn badges?';

  @override
  String get badgesEmpty =>
      'When you attend an event, your contribution and first badge appear here.';

  @override
  String get badgesRules =>
      'Badges come only from what you actually do: events you attend and organize, memories you share and your reviews. Likes and followers don’t count. Attendance the organizer marks as \"didn’t come\" doesn’t count. Nobody is ranked.';

  @override
  String get categoryFan => 'Category enthusiast';

  @override
  String get pastEvents => 'Past events';

  @override
  String get noPastEvents => 'This group has no past events yet.';

  @override
  String get refresh => 'Refresh';

  @override
  String get canceled => 'Canceled';

  @override
  String get olderEvents => 'Older events';

  @override
  String get completed => 'Completed';

  @override
  String get ended => 'Ended';

  @override
  String teamName(String name) {
    return 'Team: $name';
  }

  @override
  String get teamNotice =>
      'Once you’re added to a team, your progress shows here.';

  @override
  String get goals => 'Goals';

  @override
  String get createGoal => 'Create goal';

  @override
  String get goalsEmpty =>
      'For example \"Join 4 hikes this month\" or \"50 attendances together\": create the first goal.';

  @override
  String get claimSent => 'Your report was sent to the admin.';

  @override
  String get goal => 'Goal';

  @override
  String get goalCountsRule =>
      'Only this group\'s events within the period count; attendance marked \"didn\'t come\" doesn\'t count.';

  @override
  String get withdrawClaim => 'Withdraw report';

  @override
  String get claimWithdrawn => 'Your report was withdrawn.';

  @override
  String get done => 'Done';

  @override
  String get teams => 'Teams';

  @override
  String get createTeam => 'Create team';

  @override
  String get noTeams => 'No teams yet.';

  @override
  String deleteTeam(String name) {
    return 'Delete team $name';
  }

  @override
  String get teamDeleted => 'Team deleted.';

  @override
  String pendingClaims(int count) {
    return 'Reports awaiting approval ($count)';
  }

  @override
  String get claimRejectedToast => 'Report not approved.';

  @override
  String get decline => 'Decline';

  @override
  String get approve => 'Approve';

  @override
  String taskDone(String name) {
    return '$name completed the task.';
  }

  @override
  String completions(int count) {
    return 'Completed by ($count)';
  }

  @override
  String get noCompletions =>
      'No one has completed it yet. Everyone who does gets this goal\'s badge on their profile.';

  @override
  String get goalCanceled => 'Goal canceled.';

  @override
  String get cancelGoal => 'Cancel goal';

  @override
  String teamCreated(String name) {
    return 'Team \"$name\" created.';
  }

  @override
  String get teamNameLabel => 'Team name';

  @override
  String get createTheTeam => 'Create the team';

  @override
  String createTeamWith(int count) {
    return 'Create the team ($count people)';
  }

  @override
  String get goalCreated => 'Goal created.';

  @override
  String get title => 'Title';

  @override
  String get goalTitleExample => 'E.g. October hikes';

  @override
  String get taskTitleExample => 'E.g. Show a new member the route';

  @override
  String get titleMin3 => 'The title must be at least 3 characters.';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get targetNumber => 'Target';

  @override
  String get target1to1000 => 'Enter a number from 1 to 1000.';

  @override
  String get period => 'Period';

  @override
  String periodRange(String from, String to) {
    return '$from – $to (up to 92 days)';
  }

  @override
  String get createTheGoal => 'Create the goal';

  @override
  String get iDidTask => 'I did the task';

  @override
  String get whatDidYouDo => 'What did you do? (optional)';

  @override
  String get whatDidYouDoHint => 'The admin approves after reading this note.';

  @override
  String get cancel => 'Cancel';

  @override
  String get send => 'Send';

  @override
  String get handshake => 'Handshake';

  @override
  String get handshakeHint =>
      'Scan each other’s codes with someone you meet; you’re both added to \"People I met\".';

  @override
  String get open => 'Open';

  @override
  String handshakeAt(String title) {
    return 'Handshake · $title';
  }

  @override
  String get myCode => 'My code';

  @override
  String get scan => 'Scan';

  @override
  String get yourHandshakeCode => 'Your handshake code';

  @override
  String get codeHint =>
      'Have the other person scan this code in the \"Scan\" tab or type it. The code refreshes every few minutes; a photo of it won’t work later.';

  @override
  String get cameraFailed =>
      'The camera couldn\'t open. Allow camera access in settings or type the code below.';

  @override
  String get scanHint =>
      'Point the camera at the other person\'s QR code or type their code.';

  @override
  String get typeCodeHint =>
      'Type the 6-character code on the other person\'s screen.';

  @override
  String get code => 'Code';

  @override
  String get alreadyMet => 'You already know each other';

  @override
  String get metNow => 'You met!';

  @override
  String personWithUsername(String name, String username) {
    return '$name (@$username)';
  }

  @override
  String get ok => 'OK';

  @override
  String get metPeople => 'People I met';

  @override
  String get metEmpty =>
      'When you shake hands with someone at an event, they appear here. Handshakes open on the event page.';

  @override
  String get goToCalendar => 'Go to my calendar';

  @override
  String get metPrivacy =>
      'Only you can see this. Your profile shows only your handshake count.';

  @override
  String metRow(String username, String event, String date) {
    return '@$username · $event · $date';
  }

  @override
  String get howPoints => 'How are points calculated?';

  @override
  String get leagueIntro =>
      'Groups of the same category in the same province compete each month. Events that ended that month count.';

  @override
  String get ruleAttendance => 'Attendance: 1 point';

  @override
  String get ruleAttendanceHint => 'Each person who comes; up to 30 per event.';

  @override
  String get ruleHeld => 'Event: 5 points';

  @override
  String get ruleHeldHint =>
      'Each event at least 3 people besides the organizer came to.';

  @override
  String get ruleWelcome => 'Welcome: 3 points';

  @override
  String get ruleWelcomeHint =>
      'Welcoming someone who comes for the first time.';

  @override
  String get ruleReview => 'Happy review: 1 point';

  @override
  String get ruleReviewHint => 'Each 4- or 5-star review.';

  @override
  String get leagueRulesNote =>
      'People marked as \"didn’t come\" don’t count. Results become final 8 days after the month ends; members of the top three groups are notified.';

  @override
  String get groupsLeague => 'Groups League';

  @override
  String get category => 'Category';

  @override
  String get province => 'Province';

  @override
  String get month => 'Month';

  @override
  String seasonClosed(String month) {
    return 'The $month season is over; the standings are final.';
  }

  @override
  String get seasonRunning =>
      'The season is on. Points update as events end; results become final 8 days after the month ends.';

  @override
  String leagueEmpty(String province) {
    return 'No group in the $province league has scored this month yet.';
  }

  @override
  String points(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count points',
      one: '1 point',
    );
    return '$_temp0';
  }

  @override
  String rank(int rank) {
    return '$rank.';
  }

  @override
  String leagueName(String province, String category) {
    return '$province · $category league';
  }

  @override
  String get noPointsYet =>
      'No points yet this month. Finished events, attendance and welcomes earn points.';

  @override
  String get mapAttribution =>
      '© Stadia Maps © OpenMapTiles © OpenStreetMap contributors';

  @override
  String get map => 'Map';

  @override
  String get mapView => 'Map view';

  @override
  String get listView => 'List view';

  @override
  String get all => 'All';

  @override
  String get wholeArea => 'Whole area';

  @override
  String km(int km) {
    return '$km km';
  }

  @override
  String get mapLoadFailed => 'Couldn\'t load the map details.';

  @override
  String get retry => 'Try again';

  @override
  String get noFilterResults => 'Nothing matches these filters.';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get noNearby => 'No upcoming events or groups in this area.';

  @override
  String get zoomOut => 'Zoom out';

  @override
  String get openEvent => 'Open event';

  @override
  String memberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
    );
    return '$_temp0';
  }

  @override
  String get noVisible => 'No upcoming events or groups in the visible area.';

  @override
  String get backToMap => 'Back to map';

  @override
  String upcomingCount(int count) {
    return 'Upcoming events ($count)';
  }

  @override
  String get directions => 'Directions';

  @override
  String get meetingPointOptional => 'Meeting point (optional)';

  @override
  String get meetingPointHint =>
      'Pick it on the map; the event then appears on the map.';

  @override
  String pointPicked(String lat, String lng) {
    return 'Selected · $lat, $lng';
  }

  @override
  String get removeMeetingPoint => 'Remove meeting point';

  @override
  String get meetingPoint => 'Meeting point';

  @override
  String get pickHint => 'Zoom in and tap the meeting point.';

  @override
  String get pickAgainHint => 'Tap somewhere else to move the point.';

  @override
  String get pickThisPoint => 'Choose this point';

  @override
  String get mapUnavailable => 'The map is not available right now.';
}
