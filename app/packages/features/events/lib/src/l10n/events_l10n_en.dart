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

  @override
  String get pollClosedShort => 'Closed';

  @override
  String closesAt(String date) {
    return 'Closes: $date';
  }

  @override
  String get multipleAllowed => 'Multiple choice';

  @override
  String get anonymousVote => 'Anonymous vote';

  @override
  String votersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votes',
      one: '1 vote',
    );
    return '$_temp0';
  }

  @override
  String get pollOptions => 'Poll options';

  @override
  String get pollClosedToast => 'Poll closed.';

  @override
  String get pollDeleted => 'Poll deleted.';

  @override
  String get closePoll => 'Close poll';

  @override
  String get deletePoll => 'Delete poll';

  @override
  String get vote => 'Vote';

  @override
  String get voteSaved => 'Your vote was saved.';

  @override
  String get voters => 'Voters';

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
  String get polls => 'Polls';

  @override
  String get openPoll => 'Start a poll';

  @override
  String get pollsEmpty => 'Ask members a question, like which day to meet?';

  @override
  String get pollOpened => 'Poll started.';

  @override
  String get question => 'Question';

  @override
  String get questionExample => 'E.g. Which day shall we meet?';

  @override
  String get questionMin3 => 'The question must be at least 3 characters.';

  @override
  String optionN(int n) {
    return 'Option $n';
  }

  @override
  String get removeOption => 'Remove option';

  @override
  String get optionRequired => 'Fill in the option or remove it.';

  @override
  String get addOption => 'Add option';

  @override
  String get allowMultiple => 'Allow multiple choices';

  @override
  String get anonymousHint => 'Nobody sees who voted for what.';

  @override
  String get noEndTime => 'No end time';

  @override
  String get add => 'Add';

  @override
  String get removeEndTime => 'Remove end time';

  @override
  String get startPoll => 'Start the poll';

  @override
  String get cardFooter => 'gway · find your community';

  @override
  String myYear(int year) {
    return 'My $year';
  }

  @override
  String get statAttended => 'events attended';

  @override
  String get statHours => 'hours together';

  @override
  String get statOneGroup => 'group met';

  @override
  String get statGroups => 'different groups met';

  @override
  String get statProvinces => 'different provinces';

  @override
  String get statOrganized => 'events organized';

  @override
  String get statWelcomed => 'newcomers welcomed';

  @override
  String get statMemories => 'memories shared';

  @override
  String get favorites => 'My favourites';

  @override
  String get topGroup => 'The group I spent the most time with';

  @override
  String topGroupLine(String group, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meetups',
      one: '1 meetup',
    );
    return '$group · $_temp0';
  }

  @override
  String get iWasThere => 'I was there';

  @override
  String get firstWithGroup => 'My first event with this group.';

  @override
  String nthWithGroup(int n) {
    return 'My event no. $n with this group.';
  }

  @override
  String get shareFailed =>
      'Couldn\'t share on this device. Take a screenshot of the card and share that.';

  @override
  String get share => 'Share';

  @override
  String yearSummaryTitle(int year) {
    return 'My $year in review';
  }

  @override
  String get yearEmpty =>
      'You haven\'t attended an event this year yet. Your summary appears here after your first meetup.';

  @override
  String yearShareText(int year) {
    return 'My $year on GWAY';
  }

  @override
  String mapSemantics(int count) {
    return 'Map of Turkey: $count provinces explored';
  }

  @override
  String get explorationMap => 'My exploration map';

  @override
  String get statExplored => 'provinces explored';

  @override
  String get statMetAt => 'events met at';

  @override
  String get recentExplored => 'Recent discoveries';

  @override
  String get explorationEmpty =>
      'The provinces of events you attend light up here. Your map gets its colours after your first meetup.';

  @override
  String get findOnMap => 'Find events on the map';

  @override
  String explorationShareText(int count) {
    return 'I explored $count provinces on GWAY';
  }

  @override
  String get exploredProvinces => 'Provinces you explored';

  @override
  String get explorationPrivacy =>
      'Only you can see this. Events you attended and weren’t marked \"didn’t come\" count.';

  @override
  String get tonightVisible =>
      'People in your shared groups will see you\'re free tonight. It turns off by itself at 4:00 AM.';

  @override
  String get joinedTable => 'You joined the table.';

  @override
  String get declinedInvite => 'You declined the invitation.';

  @override
  String get yourStatus => 'Your status';

  @override
  String get visibleUntil4 => 'You\'re visible until 4:00 AM';

  @override
  String get notVisible => 'You\'re not visible right now';

  @override
  String get youreFree => 'You\'re free';

  @override
  String get tonightIntro =>
      'If you\'re free, let people in your shared groups know; you can set up a small table together.';

  @override
  String get imFreeTonight => 'I\'m free tonight';

  @override
  String get noLongerFree => 'You no longer appear as free.';

  @override
  String get turnOffStatus => 'Turn off status';

  @override
  String get leftTable => 'You left the table.';

  @override
  String get smallTable => 'Small table';

  @override
  String get smallTableHint =>
      'Invite a few people who are free; the table chat opens once three people join.';

  @override
  String get setUpTable => 'Set up a small table';

  @override
  String tableInvitesSent(int count) {
    return 'Invitations sent to $count people. The table chat opens once three people join.';
  }

  @override
  String needMorePeople(int min, int now) {
    return 'A small table needs at least $min more free people from your shared groups (now $now). Once someone says they’re free, you can set one up here.';
  }

  @override
  String freeFromGroups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people from your groups are free tonight',
      one: '1 person from your groups is free tonight',
    );
    return '$_temp0';
  }

  @override
  String get chipCoffee => 'Coffee';

  @override
  String get chipWalk => 'Short walk';

  @override
  String get chipFood => 'Food';

  @override
  String get chipCinema => 'Cinema';

  @override
  String get tonightSheetHint =>
      'Only people in your shared groups see it. Your status turns off by itself at 4:00 AM.';

  @override
  String get whatToDo => 'What would you like to do? (optional)';

  @override
  String get whatToDoHint => 'e.g. coffee, a short walk';

  @override
  String get imFree => 'I\'m free';

  @override
  String get yourTable => 'Your table';

  @override
  String joinedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count joined',
      one: '1 joined',
    );
    return '$_temp0';
  }

  @override
  String waitingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'waiting for $count',
      one: 'waiting for 1',
    );
    return '$_temp0';
  }

  @override
  String get settingUp => 'Getting ready';

  @override
  String get chatOpen => 'Chat open';

  @override
  String get tableChat => 'Table chat';

  @override
  String chatOpensWhen(int count) {
    return 'The chat opens when $count more people join. You choose the place and time there together.';
  }

  @override
  String get leaveTable => 'Leave table';

  @override
  String tableInviteTitle(String name) {
    return '$name set up a small table and is inviting you.';
  }

  @override
  String tableInviteStatus(int joined, int pending) {
    return '$joined joined · $pending pending. The chat opens at three people.';
  }

  @override
  String get join => 'Join';

  @override
  String get notTonight => 'Not tonight';

  @override
  String get tonight => 'Tonight';

  @override
  String get freeTonight => 'Free tonight';

  @override
  String get sharedGroupsOnly => 'Only people in your shared groups';

  @override
  String get nobodyFree => 'Nobody from your shared groups is free right now.';

  @override
  String get howItWorks => 'How does it work?';

  @override
  String get howStep1 =>
      'Say \"I’m free tonight\"; add what you’d like to do if you want.';

  @override
  String get howStep2 =>
      'People in your shared groups see you, and you see who’s free.';

  @override
  String get howStep3 =>
      'Set up a small table; the chat opens at three people, and you pick the place and time there.';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get calendar => 'Calendar';

  @override
  String get noUpcomingJoined => 'You haven\'t joined any upcoming events.';

  @override
  String get showAll => 'Show all';

  @override
  String get noUpcoming60 => 'Your groups have no events in the next 60 days.';

  @override
  String get findGroup => 'Find a group';

  @override
  String filterAll(int count) {
    return 'All · $count';
  }

  @override
  String filterMine(int count) {
    return 'Joined · $count';
  }

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get going => 'You\'re going';

  @override
  String get waitlisted => 'On the waitlist';

  @override
  String get awaitingApproval => 'Awaiting approval';

  @override
  String get full => 'Full';

  @override
  String goingOfCapacityShort(int count, int capacity) {
    return '$count/$capacity going';
  }

  @override
  String get startingSoon => 'Starting soon';

  @override
  String get next6Hours => 'Next 6 hours';

  @override
  String get wantWelcome => 'I\'d like to be welcomed';

  @override
  String get wantWelcomeHint =>
      'A volunteer from the group meets you at the entrance, so you don’t go alone.';

  @override
  String get noteForGreeter => 'A note so they can recognise you (optional)';

  @override
  String get noteForGreeterHint => 'E.g. I\'m in a red jacket with a blue bag';

  @override
  String get sendRequest => 'Send request';

  @override
  String get welcomeRequestSent =>
      'Your request was sent to the greeters. We\'ll let you know when someone takes it.';

  @override
  String get editMeetingNote => 'Edit meeting note';

  @override
  String welcomePerson(String name) {
    return 'Welcome $name';
  }

  @override
  String describedAs(String note) {
    return 'They described themselves: $note';
  }

  @override
  String get whereMeet => 'Where will you meet?';

  @override
  String get whereMeetHint => 'E.g. In front of the café at the entrance, 8:45';

  @override
  String get save => 'Save';

  @override
  String get iWillWelcome => 'I\'ll welcome them';

  @override
  String get noteUpdated => 'Meeting note updated.';

  @override
  String youWillWelcome(String name) {
    return 'You\'ll welcome $name; they\'ve seen the meeting note.';
  }

  @override
  String get stopWelcoming => 'Stop welcoming';

  @override
  String stopWelcomingBody(String name) {
    return 'We\'ll look for another greeter for $name and let them know.';
  }

  @override
  String get release => 'Stop';

  @override
  String get releasedWelcome =>
      'You stopped welcoming; we\'re looking for a new greeter.';

  @override
  String get firstTime => 'Coming for the first time?';

  @override
  String greetersAvailable(int count) {
    return 'This group has $count greeters. Have one meet you at the entrance and introduce you to the group.';
  }

  @override
  String get youWelcomed => 'People you welcome';

  @override
  String meetingAt(String note) {
    return 'Meeting: $note';
  }

  @override
  String get thankedYou => 'Thanked you';

  @override
  String optionsFor(String name) {
    return 'Options for $name';
  }

  @override
  String waitingWelcome(int count) {
    return 'Waiting to be welcomed ($count)';
  }

  @override
  String matchedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people have a greeter.',
      one: '1 person has a greeter.',
    );
    return '$_temp0';
  }

  @override
  String get firstTimer => 'First time';

  @override
  String get max3Welcomes => 'You can welcome up to 3 people per event.';

  @override
  String get greeterJoinHint =>
      'You\'re a greeter. Join the event to welcome first-timers.';

  @override
  String get lookingGreeter => 'Looking for a greeter';

  @override
  String get lookingGreeterHint =>
      'We\'ve told the group\'s greeters. You\'ll be notified when someone takes it.';

  @override
  String yourNote(String note) {
    return 'Your note: $note';
  }

  @override
  String get welcomeWithdrawn => 'Your welcome request was withdrawn.';

  @override
  String get withdrawRequest => 'Withdraw request';

  @override
  String get greetedBy => 'Welcomed by';

  @override
  String get willGreet => 'Will welcome you';

  @override
  String get thank => 'Say thanks';

  @override
  String thankReceived(String name) {
    return '$name got your thanks.';
  }

  @override
  String get thanked => 'You said thanks.';

  @override
  String get cancelWelcome => 'Cancel welcome';

  @override
  String get nowGreeter =>
      'You\'re now a greeter. We\'ll let you know when a first-timer asks to be welcomed.';

  @override
  String get noLongerGreeter => 'You stopped being a greeter.';

  @override
  String get welcomeSection => 'Welcoming';

  @override
  String greetersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count greeters',
      one: '1 greeter',
    );
    return '$_temp0';
  }

  @override
  String get greeterIntro =>
      'First-timers can ask to be welcomed on the event page. If you become a greeter, you\'ll be notified; you meet them at the entrance and introduce them to the group.';

  @override
  String greeterMemberHint(int count) {
    return 'This group has $count greeters. At your first event, tap \"I\'d like to be welcomed\" on the page.';
  }

  @override
  String greeterVisitorHint(int count) {
    return 'This group has $count greeters: you won\'t go alone to your first event; someone meets you at the entrance.';
  }

  @override
  String get becomeGreeter => 'Become a greeter';

  @override
  String quoted(String text) {
    return '\"$text\"';
  }
}
