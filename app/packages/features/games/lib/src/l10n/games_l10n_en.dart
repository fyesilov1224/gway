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

  @override
  String get games => 'Games';

  @override
  String get gamesIntro =>
      'Play with your community: quick games, tournaments and matches between groups.';

  @override
  String get chessCardText =>
      'Elo rating, weekly and monthly tournaments, team matches between groups and medals.';

  @override
  String get playChess => 'Play chess';

  @override
  String blitzRating(int rating) {
    return 'Blitz $rating';
  }

  @override
  String nextArena(String time) {
    return 'Next tournament: $time';
  }

  @override
  String invitesWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count invitations waiting',
      one: '1 invitation waiting',
    );
    return '$_temp0';
  }

  @override
  String get playOnline => 'Play online';

  @override
  String findOpponent(String tc) {
    return 'Find an opponent · $tc';
  }

  @override
  String get challengeFriendHint => 'You pick the time and color';

  @override
  String get leaderboardHint => 'Elo rankings and medals';

  @override
  String openTeamMatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count open matches',
      one: '1 open match',
    );
    return '$_temp0';
  }

  @override
  String get appearance => 'Board and pieces';

  @override
  String get boardTheme => 'Board';

  @override
  String get pieceSet => 'Pieces';

  @override
  String get boardWood => 'Wood';

  @override
  String get boardGreen => 'Green';

  @override
  String get boardBlue => 'Blue';

  @override
  String get boardSlate => 'Gray';

  @override
  String get boardLilac => 'GWAY lilac';

  @override
  String get piecesClassic => 'Classic';

  @override
  String get piecesCeltic => 'Celtic';

  @override
  String get piecesSpatial => 'Spatial';

  @override
  String get piecesFantasy => 'Fantasy';

  @override
  String get piecesModern => 'Modern';

  @override
  String get piecesWarm => 'Warm';

  @override
  String get firstPosition => 'Start';

  @override
  String get previousMove => 'Previous move';

  @override
  String get nextMove => 'Next move';

  @override
  String get lastPosition => 'Latest position';

  @override
  String get backToLive => 'Back to live';

  @override
  String pointsShort(int points) {
    return '$points pts';
  }

  @override
  String mindColorWord(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'red_m': 'red',
      'red_f': 'red',
      'red_n': 'red',
      'blue_m': 'blue',
      'blue_f': 'blue',
      'blue_n': 'blue',
      'green_m': 'green',
      'green_f': 'green',
      'green_n': 'green',
      'yellow_m': 'yellow',
      'yellow_f': 'yellow',
      'yellow_n': 'yellow',
      'purple_m': 'purple',
      'purple_f': 'purple',
      'purple_n': 'purple',
      'orange_m': 'orange',
      'orange_f': 'orange',
      'orange_n': 'orange',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String mindPatternWord(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'solid_m': 'solid',
      'solid_f': 'solid',
      'solid_n': 'solid',
      'striped_m': 'striped',
      'striped_f': 'striped',
      'striped_n': 'striped',
      'dotted_m': 'dotted',
      'dotted_f': 'dotted',
      'dotted_n': 'dotted',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String mindShapeWord(String shape) {
    String _temp0 = intl.Intl.selectLogic(shape, {
      'circle': 'circle',
      'square': 'square',
      'triangle': 'triangle',
      'star': 'star',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String mindShapeGender(String shape) {
    String _temp0 = intl.Intl.selectLogic(shape, {
      'circle': 'm',
      'square': 'm',
      'triangle': 'm',
      'star': 'm',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String mindFigure(String color, String pattern, String shape) {
    return '$color $pattern $shape';
  }

  @override
  String get mindDuel => 'Mind Duel';

  @override
  String get mindCardText =>
      'A live duel of math, attention, memory and reflex questions. Elo rating, leaderboards and medals.';

  @override
  String get mindPlay => 'Start a duel';

  @override
  String mindBestRating(int rating, int length) {
    return 'Elo $rating · $length questions';
  }

  @override
  String mindQuestions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions',
      one: '1 question',
    );
    return '$_temp0';
  }

  @override
  String get mindHowMany => 'How many questions?';

  @override
  String mindRatingAt(int count) {
    return 'Your rating at $count questions';
  }

  @override
  String get mindFindOpponent => 'Find an opponent';

  @override
  String get mindSuspended => 'You can\'t play games right now.';

  @override
  String get mindActive => 'You have a duel in progress';

  @override
  String get mindProfile => 'Duel profile';

  @override
  String get mindHowTo => 'How to play';

  @override
  String get mindRecent => 'Recent duels';

  @override
  String get mindNoMatchesMine => 'No duels yet. Find your first opponent.';

  @override
  String get mindNoMatchesTheirs =>
      'No duels yet. Be the first to challenge them.';

  @override
  String mindLeaderboardEmpty(int count) {
    return 'Play $count rated duels at this length to enter the leaderboard.';
  }

  @override
  String get mindChallengeTitle => 'Challenge to a duel';

  @override
  String get mindChallengeSent =>
      'Challenge sent. The duel starts when they accept.';

  @override
  String get mindKindMath => 'Math';

  @override
  String get mindKindAttention => 'Attention';

  @override
  String get mindKindMemory => 'Memory';

  @override
  String get mindKindReflex => 'Reflex';

  @override
  String get mindKindMathHint =>
      'Four operations, with precedence. Pick the right result.';

  @override
  String get mindKindAttentionHint =>
      'Ignore the ink: pick the figure the words describe.';

  @override
  String get mindKindMemoryHint =>
      'Remember the colored letters and digits, in order and in color.';

  @override
  String get mindKindReflexHint =>
      'Tap the target the moment it shows. Early or wrong taps cost points.';

  @override
  String get mindScoringHint =>
      'Right and fast answers score more. The higher total wins.';

  @override
  String get mindYou => 'You';

  @override
  String get mindOpponent => 'Opponent';

  @override
  String mindProgress(String who, int done, int total) {
    return '$who: $done/$total questions';
  }

  @override
  String mindQuestionOf(int n, int total) {
    return '$n/$total';
  }

  @override
  String get mindGetReady => 'Get ready';

  @override
  String get mindYouFinished => 'You finished!';

  @override
  String mindOpponentAt(int done, int total) {
    return 'Your opponent is at $done/$total. The result comes when they finish.';
  }

  @override
  String get mindMathPrompt => 'What\'s the result?';

  @override
  String get mindAttentionPrompt => 'Pick the figure the words describe';

  @override
  String get mindMemoryLook => 'Remember the order and the colors';

  @override
  String get mindMemoryPick => 'Pick them in the same order and colors';

  @override
  String mindCharLabel(String char, String color) {
    return '$color $char';
  }

  @override
  String get mindUndo => 'Undo';

  @override
  String get mindReflexTarget => 'Target';

  @override
  String get mindReflexWait => 'Wait…';

  @override
  String get mindReflexTap => 'Tap now!';

  @override
  String mindRight(int points) {
    return 'Right · +$points';
  }

  @override
  String mindPartly(int points) {
    return 'Partly right · +$points';
  }

  @override
  String get mindWrong => 'Wrong';

  @override
  String mindWrongPenalty(int points) {
    return 'Wrong · −$points';
  }

  @override
  String mindTooEarly(int points) {
    return 'Too early · −$points';
  }

  @override
  String get mindResignTitle => 'Leave the duel?';

  @override
  String get mindResignBody =>
      'Your opponent wins; in a rated duel your Elo drops.';

  @override
  String get mindFinished => 'Duel over';

  @override
  String get mindEndCompleted => 'All questions answered';

  @override
  String get mindEndTime => 'Time\'s up';

  @override
  String mindNewRating(int rating) {
    return 'New rating $rating';
  }

  @override
  String get mindNewDuel => 'New duel';

  @override
  String get mindBackHome => 'Back to duels';

  @override
  String get mindTeamMatches => 'Group duels';

  @override
  String get mindTeamMatchesHint =>
      'Your groups\' duels against other groups; the result moves the group\'s duel Elo.';

  @override
  String get mindNoTeamMatches =>
      'No group duels yet. Challenge another group for yours.';

  @override
  String get mindNewTeamMatch => 'Arrange a group duel';

  @override
  String get mindNewTeamHint =>
      'Once the other group accepts, both line up their players. At the start each seat\'s two players duel at the same time.';

  @override
  String get mindTeamMatch => 'Group duel';

  @override
  String get mindSeats => 'Seats';

  @override
  String mindSeatsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seats',
      one: '1 seat',
    );
    return '$_temp0';
  }

  @override
  String get mindLineupHint =>
      'A seat left empty at the start counts for the other side. A seat waits 5 minutes for the first question.';

  @override
  String get mindGroupLeaderboardEmpty =>
      'No group has played a group duel yet. Let yours arrange the first.';

  @override
  String get mindTournaments => 'Tournaments';

  @override
  String get mindTournamentsHint =>
      'Weekly every Saturday at 21:00 (10 questions), monthly on the last Saturday at 19:00 (20 questions); the top three get medals.';

  @override
  String get mindNoTournaments => 'No upcoming tournaments.';
}
