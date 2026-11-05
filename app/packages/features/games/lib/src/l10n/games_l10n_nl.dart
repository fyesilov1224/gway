// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'games_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class GamesL10nNl extends GamesL10n {
  GamesL10nNl([String locale = 'nl']) : super(locale);

  @override
  String get chess => 'Schaken';

  @override
  String get bullet => 'Bullet';

  @override
  String get blitz => 'Snelschaak';

  @override
  String get rapid => 'Rapid';

  @override
  String get white => 'Wit';

  @override
  String get black => 'Zwart';

  @override
  String get colorRandom => 'Willekeurig';

  @override
  String get endCheckmate => 'Schaakmat';

  @override
  String get endResign => 'Opgave';

  @override
  String get endTimeout => 'Tijd om';

  @override
  String get endTimeoutDraw => 'Tijd om, de tegenstander kan niet matzetten';

  @override
  String get endStalemate => 'Pat';

  @override
  String get endInsufficient => 'Onvoldoende materiaal';

  @override
  String get endFiftyMoves => '50-zettenregel';

  @override
  String get endRepetition => 'Drievoudige herhaling';

  @override
  String get endAgreement => 'Remise in overleg';

  @override
  String get endAborted => 'Afgebroken';

  @override
  String get boardLabel => 'Schaakbord';

  @override
  String get promoteTo => 'Promoveer de pion tot';

  @override
  String get queen => 'Dame';

  @override
  String get rook => 'Toren';

  @override
  String get bishop => 'Loper';

  @override
  String get knight => 'Paard';

  @override
  String get medalGold => 'Gouden medaille';

  @override
  String get medalSilver => 'Zilveren medaille';

  @override
  String get medalBronze => 'Bronzen medaille';

  @override
  String get youWon => 'Je hebt gewonnen';

  @override
  String get youLost => 'Je hebt verloren';

  @override
  String get draw => 'Remise';

  @override
  String get inProgress => 'Bezig';

  @override
  String get whiteWon => 'Wit wint';

  @override
  String get blackWon => 'Zwart wint';

  @override
  String get rated => 'Rating';

  @override
  String get casual => 'Vriendschappelijk';

  @override
  String get ratedHint => 'De uitslag verandert je Elo-rating.';

  @override
  String get flipBoard => 'Bord draaien';

  @override
  String get cancel => 'Annuleren';

  @override
  String get resign => 'Opgeven';

  @override
  String get resignTitle => 'Partij opgeven?';

  @override
  String get resignBody =>
      'Je tegenstander wint; in een ratingpartij daalt je Elo.';

  @override
  String get abort => 'Afbreken';

  @override
  String get offerDraw => 'Remise?';

  @override
  String get drawOffered => 'Aangeboden';

  @override
  String get drawOfferReceived => 'Je tegenstander biedt remise aan.';

  @override
  String get accept => 'Accepteren';

  @override
  String get decline => 'Weigeren';

  @override
  String get rematch => 'Revanche';

  @override
  String get rematchSent => 'Revanche aangevraagd.';

  @override
  String get newGame => 'Nieuwe partij';

  @override
  String newRating(String category, int rating) {
    return 'Je $category-rating: $rating';
  }

  @override
  String get deletedPlayer => 'Verwijderd account';

  @override
  String get firstMove => 'Eerste zet: 30 s';

  @override
  String get noMovesYet => 'Nog geen zetten. Wit begint.';

  @override
  String get watching => 'Je kijkt mee';

  @override
  String get quickGame => 'Snelle partij';

  @override
  String get quickGameHint =>
      'Kies een tijd en speel tegen iemand met een vergelijkbare rating.';

  @override
  String get searching => 'Tegenstander zoeken…';

  @override
  String waitedSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Al $count seconden',
      one: 'Al 1 seconde',
    );
    return '$_temp0';
  }

  @override
  String get chessProfile => 'Schaakprofiel';

  @override
  String get recentGames => 'Recente partijen';

  @override
  String get noGamesMine => 'Nog geen partijen. Speel je eerste.';

  @override
  String get noGamesTheirs => 'Nog geen partijen. Daag uit voor de eerste.';

  @override
  String get playNow => 'Nu spelen';

  @override
  String get challenge => 'Uitdagen';

  @override
  String get noFlag => 'Geen vlag gekozen';

  @override
  String get chooseFlag => 'Kies je vlag';

  @override
  String get chooseFlagHint => 'Hij staat naast je naam in de ranglijst.';

  @override
  String get searchCountry => 'Land zoeken';

  @override
  String get flagSaved => 'Vlag opgeslagen.';

  @override
  String get pickFlagPrompt => 'Kies de vlag die in de ranglijst bij je staat.';

  @override
  String get suspendedNotice => 'Schaken is nu gesloten voor deze persoon.';

  @override
  String get notPlayed => 'Niet gespeeld';

  @override
  String gamesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count partijen',
      one: '1 partij',
    );
    return '$_temp0';
  }

  @override
  String rankShort(int rank) {
    return 'Plaats $rank';
  }

  @override
  String get leaderboard => 'Ranglijst';

  @override
  String leaderboardEmpty(int count) {
    return 'Speel $count ratingpartijen in deze categorie om in de ranglijst te komen.';
  }

  @override
  String record(int wins, int draws, int losses) {
    return '${wins}W · ${draws}R · ${losses}V';
  }

  @override
  String get seeAll => 'Alles bekijken';

  @override
  String get invitations => 'Uitdagingen';

  @override
  String invitesYou(String what) {
    return 'Daagt je uit voor een partij: $what';
  }

  @override
  String wantsRematch(String what) {
    return 'Wil een revanche: $what';
  }

  @override
  String waitingFor(String what) {
    return 'Wacht op antwoord: $what';
  }

  @override
  String get withdraw => 'Intrekken';

  @override
  String get gameInProgress => 'Je hebt een lopende partij';

  @override
  String get resume => 'Verder';

  @override
  String get challengeFriend => 'Daag een vriend uit';

  @override
  String get challengeSent =>
      'Uitdaging verstuurd. De partij begint zodra die is geaccepteerd.';

  @override
  String get challengeTitle => 'Uitdagen voor een partij';

  @override
  String get changePerson => 'Andere persoon';

  @override
  String get searchPerson => 'Gebruikersnaam of naam';

  @override
  String get timeControl => 'Bedenktijd';

  @override
  String get yourColor => 'Jouw kleur';

  @override
  String get sendChallenge => 'Uitdaging versturen';
}
