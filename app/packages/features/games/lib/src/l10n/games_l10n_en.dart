// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'games_l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class GamesL10nEn extends GamesL10n {
  GamesL10nEn([String locale = 'en']) : super(locale);

  @override
  String get chess => 'Chess';

  @override
  String get bullet => 'Bullet';

  @override
  String get blitz => 'Blitz';

  @override
  String get rapid => 'Rapid';

  @override
  String get white => 'White';

  @override
  String get black => 'Black';

  @override
  String get colorRandom => 'Random';

  @override
  String get endCheckmate => 'Checkmate';

  @override
  String get endResign => 'Resignation';

  @override
  String get endTimeout => 'Time out';

  @override
  String get endTimeoutDraw => 'Time out; the opponent cannot mate';

  @override
  String get endStalemate => 'Stalemate';

  @override
  String get endInsufficient => 'Insufficient material';

  @override
  String get endFiftyMoves => '50-move rule';

  @override
  String get endRepetition => 'Threefold repetition';

  @override
  String get endAgreement => 'Draw by agreement';

  @override
  String get endAborted => 'Aborted';

  @override
  String get boardLabel => 'Chess board';

  @override
  String get promoteTo => 'Promote the pawn to';

  @override
  String get queen => 'Queen';

  @override
  String get rook => 'Rook';

  @override
  String get bishop => 'Bishop';

  @override
  String get knight => 'Knight';

  @override
  String get medalGold => 'Gold medal';

  @override
  String get medalSilver => 'Silver medal';

  @override
  String get medalBronze => 'Bronze medal';

  @override
  String get youWon => 'You won';

  @override
  String get youLost => 'You lost';

  @override
  String get draw => 'Draw';

  @override
  String get inProgress => 'In progress';

  @override
  String get whiteWon => 'White won';

  @override
  String get blackWon => 'Black won';

  @override
  String get rated => 'Rated';

  @override
  String get casual => 'Casual';

  @override
  String get ratedHint => 'The result changes your Elo rating.';

  @override
  String get flipBoard => 'Flip board';

  @override
  String get cancel => 'Cancel';

  @override
  String get resign => 'Resign';

  @override
  String get resignTitle => 'Resign the game?';

  @override
  String get resignBody =>
      'Your opponent wins; in a rated game your Elo goes down.';

  @override
  String get abort => 'Abort';

  @override
  String get offerDraw => 'Draw?';

  @override
  String get drawOffered => 'Offered';

  @override
  String get drawOfferReceived => 'Your opponent offers a draw.';

  @override
  String get accept => 'Accept';

  @override
  String get decline => 'Decline';

  @override
  String get rematch => 'Rematch';

  @override
  String get rematchSent => 'Rematch request sent.';

  @override
  String get newGame => 'New game';

  @override
  String newRating(String category, int rating) {
    return 'Your $category rating: $rating';
  }

  @override
  String get deletedPlayer => 'Deleted account';

  @override
  String get firstMove => 'First move: 30 s';

  @override
  String get noMovesYet => 'No moves yet. White starts.';

  @override
  String get watching => 'You\'re watching';

  @override
  String get quickGame => 'Quick game';

  @override
  String get quickGameHint =>
      'Pick a time and get paired with someone near your rating.';

  @override
  String get searching => 'Looking for an opponent…';

  @override
  String waitedSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seconds',
      one: '1 second',
    );
    return 'You\'ve waited $_temp0';
  }

  @override
  String get chessProfile => 'Chess profile';

  @override
  String get recentGames => 'Recent games';

  @override
  String get noGamesMine => 'No games yet. Play your first one.';

  @override
  String get noGamesTheirs => 'No games yet. Invite them to their first.';

  @override
  String get playNow => 'Play now';

  @override
  String get challenge => 'Challenge';

  @override
  String get noFlag => 'No flag chosen';

  @override
  String get chooseFlag => 'Choose your flag';

  @override
  String get chooseFlagHint =>
      'It appears next to your name on the leaderboard.';

  @override
  String get searchCountry => 'Search country';

  @override
  String get flagSaved => 'Flag saved.';

  @override
  String get pickFlagPrompt =>
      'Choose the flag shown with you on the leaderboard.';

  @override
  String get suspendedNotice => 'Chess is closed for this person right now.';

  @override
  String get notPlayed => 'Not played';

  @override
  String gamesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count games',
      one: '1 game',
    );
    return '$_temp0';
  }

  @override
  String rankShort(int rank) {
    return 'Ranked #$rank';
  }

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String leaderboardEmpty(int count) {
    return 'Play $count rated games in this category to join the leaderboard.';
  }

  @override
  String record(int wins, int draws, int losses) {
    return '${wins}W · ${draws}D · ${losses}L';
  }

  @override
  String get seeAll => 'See all';

  @override
  String get invitations => 'Invitations';

  @override
  String invitesYou(String what) {
    return 'Invites you to a game: $what';
  }

  @override
  String wantsRematch(String what) {
    return 'Wants a rematch: $what';
  }

  @override
  String waitingFor(String what) {
    return 'Waiting for an answer: $what';
  }

  @override
  String get withdraw => 'Withdraw';

  @override
  String get gameInProgress => 'You have a game in progress';

  @override
  String get resume => 'Resume';

  @override
  String get challengeFriend => 'Challenge a friend';

  @override
  String get challengeSent =>
      'Invitation sent. The game starts when they accept.';

  @override
  String get challengeTitle => 'Invite to a game';

  @override
  String get changePerson => 'Change person';

  @override
  String get searchPerson => 'Username or name';

  @override
  String get timeControl => 'Time control';

  @override
  String get yourColor => 'Your color';

  @override
  String get sendChallenge => 'Send invitation';

  @override
  String get teamMatch => 'Team match';

  @override
  String get teamMatches => 'Team matches';

  @override
  String get teamMatchesHint =>
      'Your groups\' chess matches; the result moves the group\'s Elo.';

  @override
  String get noTeamMatches =>
      'No team matches yet. Invite another group on behalf of yours.';

  @override
  String get newTeamMatch => 'Arrange a team match';

  @override
  String get newTeamMatchHint =>
      'Once the other group\'s captain accepts, both groups line up their players.';

  @override
  String get yourGroup => 'Your group';

  @override
  String get opponentGroup => 'Opponent group';

  @override
  String get searchGroup => 'Group name or handle';

  @override
  String get startsAt => 'Starts';

  @override
  String get sendTeamInvite => 'Invite the group';

  @override
  String get boards => 'Boards';

  @override
  String get boardsShort => 'boards';

  @override
  String boardsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count boards',
      one: '1 board',
    );
    return '$_temp0';
  }

  @override
  String groupElo(int rating) {
    return 'Group Elo $rating';
  }

  @override
  String get versus => 'VS';

  @override
  String get versusShort => '–';

  @override
  String get teamInvited => 'Awaiting reply';

  @override
  String get teamAccepted => 'Accepted';

  @override
  String get teamDeclined => 'Declined';

  @override
  String get teamCanceled => 'Called off';

  @override
  String get teamLive => 'Live';

  @override
  String get teamFinished => 'Finished';

  @override
  String teamInviteReceived(String group) {
    return '$group invites your group to a team match.';
  }

  @override
  String get teamAcceptedDone => 'Match accepted. Now line up your players.';

  @override
  String get teamDeclinedDone => 'Invitation declined.';

  @override
  String get teamCanceledDone => 'Match called off.';

  @override
  String get callOff => 'Call off the match';

  @override
  String get lineupHint =>
      'A board left empty at the start counts as a point for the other side.';

  @override
  String get lineupSheetHint =>
      'Tap members to place them on the boards in order; board 1 is for your strongest player.';

  @override
  String editLineup(String group) {
    return '$group lineup';
  }

  @override
  String get saveLineup => 'Save lineup';

  @override
  String get emptyBoard => 'Empty';

  @override
  String ratingGames(int rating, int games) {
    return 'Elo $rating · $games games';
  }

  @override
  String get groupsTab => 'Groups';

  @override
  String get groupLeaderboardEmpty =>
      'No group has played a team match yet. Let yours be first.';

  @override
  String get backToChess => 'Back to chess';

  @override
  String get arena => 'Tournament';

  @override
  String get tournaments => 'Tournaments';

  @override
  String get tournamentsHint =>
      'Weekly and monthly arena tournaments; the top three win medals.';

  @override
  String get weeklyArena => 'Weekly Arena';

  @override
  String get monthlyArena => 'Monthly Arena';

  @override
  String get arenaRules =>
      'Arena: play as many games as you like until time runs out. A win is 2 points, a draw 1; after two wins in a row your points double until the streak ends. Games started before the end count.';

  @override
  String get arenaLiveNow => 'Live now';

  @override
  String get arenaUpcoming => 'Upcoming';

  @override
  String get arenaFinished => 'Finished';

  @override
  String get registered => 'Registered';

  @override
  String get arenaRegister => 'Register';

  @override
  String get arenaRegistered =>
      'You\'re registered. You\'ll be notified at the start and paired as soon as you open it.';

  @override
  String get arenaJoin => 'Join';

  @override
  String get arenaResume => 'Keep playing';

  @override
  String get arenaPause => 'Take a break';

  @override
  String get arenaWaiting =>
      'Waiting for an opponent; the game opens by itself when someone near your score is free.';

  @override
  String get backToGame => 'Back to the game';

  @override
  String get backToArena => 'Back to the tournament';

  @override
  String get backToTeamMatch => 'Back to the team match';

  @override
  String arenaStartsIn(String time) {
    return 'Starts in $time';
  }

  @override
  String arenaEndsIn(String time) {
    return '$time left';
  }

  @override
  String get arenaLastGames => 'Time is up; the last games are finishing';

  @override
  String arenaFinishedAt(String time) {
    return 'Finished · $time';
  }

  @override
  String hoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String minutesLong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String playersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count players',
      one: '1 player',
    );
    return '$_temp0';
  }

  @override
  String myArenaScore(int points, int games) {
    return '$points points · $games games';
  }

  @override
  String get onFire => 'On a streak: the next result scores double';

  @override
  String get standings => 'Standings';

  @override
  String get arenaEmpty => 'Nobody has joined yet. Be the first.';

  @override
  String performance(int value) {
    return 'Performance $value';
  }

  @override
  String get playingNow => 'playing';

  @override
  String get arenaMedals => 'Tournament medals';

  @override
  String medalsSummary(int gold, int silver, int bronze) {
    return 'Tournament medals: $gold gold, $silver silver, $bronze bronze';
  }

  @override
  String get firstMoveTeam => 'First move: 5 min';
}
