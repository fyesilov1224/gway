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
}
