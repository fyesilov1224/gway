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

  @override
  String get teamMatch => 'Teamwedstrijd';

  @override
  String get teamMatches => 'Teamwedstrijden';

  @override
  String get teamMatchesHint =>
      'Schaakwedstrijden van je groepen; de uitslag verandert de groeps-Elo.';

  @override
  String get noTeamMatches =>
      'Nog geen teamwedstrijden. Daag namens je groep een andere groep uit.';

  @override
  String get newTeamMatch => 'Teamwedstrijd regelen';

  @override
  String get newTeamMatchHint =>
      'Zodra de andere groep accepteert, stellen beide groepen hun spelers op.';

  @override
  String get yourGroup => 'Jouw groep';

  @override
  String get opponentGroup => 'Tegenstander';

  @override
  String get searchGroup => 'Groepsnaam of handle';

  @override
  String get startsAt => 'Start';

  @override
  String get sendTeamInvite => 'Groep uitnodigen';

  @override
  String get boards => 'Borden';

  @override
  String get boardsShort => 'borden';

  @override
  String boardsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count borden',
      one: '1 bord',
    );
    return '$_temp0';
  }

  @override
  String groupElo(int rating) {
    return 'Groeps-Elo $rating';
  }

  @override
  String get versus => 'VS';

  @override
  String get versusShort => '–';

  @override
  String get teamInvited => 'Wacht op antwoord';

  @override
  String get teamAccepted => 'Geaccepteerd';

  @override
  String get teamDeclined => 'Geweigerd';

  @override
  String get teamCanceled => 'Afgelast';

  @override
  String get teamLive => 'Bezig';

  @override
  String get teamFinished => 'Afgelopen';

  @override
  String teamInviteReceived(String group) {
    return '$group daagt jullie groep uit voor een teamwedstrijd.';
  }

  @override
  String get teamAcceptedDone =>
      'Wedstrijd geaccepteerd. Stel nu je spelers op.';

  @override
  String get teamDeclinedDone => 'Uitnodiging geweigerd.';

  @override
  String get teamCanceledDone => 'Wedstrijd afgelast.';

  @override
  String get callOff => 'Wedstrijd afgelasten';

  @override
  String get lineupHint =>
      'Een leeg bord bij de start telt als punt voor de tegenpartij.';

  @override
  String get lineupSheetHint =>
      'Tik op leden om ze op volgorde te plaatsen; bord 1 is voor je sterkste speler.';

  @override
  String editLineup(String group) {
    return 'Opstelling $group';
  }

  @override
  String get saveLineup => 'Opstelling opslaan';

  @override
  String get emptyBoard => 'Leeg';

  @override
  String ratingGames(int rating, int games) {
    return 'Elo $rating · $games partijen';
  }

  @override
  String get groupsTab => 'Groepen';

  @override
  String get groupLeaderboardEmpty =>
      'Nog geen groep heeft een teamwedstrijd gespeeld. Wees de eerste.';

  @override
  String get backToChess => 'Terug naar schaken';

  @override
  String get arena => 'Toernooi';

  @override
  String get tournaments => 'Toernooien';

  @override
  String get tournamentsHint =>
      'Wekelijkse en maandelijkse arenatoernooien; de eerste drie krijgen een medaille.';

  @override
  String get weeklyArena => 'Wekelijkse Arena';

  @override
  String get monthlyArena => 'Maandelijkse Arena';

  @override
  String get arenaRules =>
      'Arena: speel zoveel partijen als je wilt tot de tijd om is. Winst 2 punten, remise 1; na twee overwinningen op rij tellen punten dubbel tot de reeks stopt. Partijen die voor het einde begonnen, tellen mee.';

  @override
  String get arenaLiveNow => 'Nu bezig';

  @override
  String get arenaUpcoming => 'Binnenkort';

  @override
  String get arenaFinished => 'Afgelopen';

  @override
  String get registered => 'Aangemeld';

  @override
  String get arenaRegister => 'Aanmelden';

  @override
  String get arenaRegistered =>
      'Je bent aangemeld. Bij de start krijg je een melding en word je meteen gekoppeld.';

  @override
  String get arenaJoin => 'Meedoen';

  @override
  String get arenaResume => 'Verder spelen';

  @override
  String get arenaPause => 'Pauzeren';

  @override
  String get arenaWaiting =>
      'Wachten op een tegenstander; de partij opent vanzelf zodra iemand met een vergelijkbare score vrij is.';

  @override
  String get backToGame => 'Terug naar de partij';

  @override
  String get backToArena => 'Terug naar het toernooi';

  @override
  String get backToTeamMatch => 'Terug naar de teamwedstrijd';

  @override
  String arenaStartsIn(String time) {
    return 'Begint over $time';
  }

  @override
  String arenaEndsIn(String time) {
    return 'Nog $time';
  }

  @override
  String get arenaLastGames => 'Tijd is om; de laatste partijen lopen nog';

  @override
  String arenaFinishedAt(String time) {
    return 'Afgelopen · $time';
  }

  @override
  String hoursMinutes(int hours, int minutes) {
    return '$hours u $minutes min';
  }

  @override
  String minutesLong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minuten',
      one: '1 minuut',
    );
    return '$_temp0';
  }

  @override
  String playersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spelers',
      one: '1 speler',
    );
    return '$_temp0';
  }

  @override
  String myArenaScore(int points, int games) {
    return '$points punten · $games partijen';
  }

  @override
  String get onFire => 'Op een reeks: het volgende resultaat telt dubbel';

  @override
  String get standings => 'Stand';

  @override
  String get arenaEmpty => 'Nog niemand doet mee. Wees de eerste.';

  @override
  String performance(int value) {
    return 'Prestatie $value';
  }

  @override
  String get playingNow => 'speelt';

  @override
  String get arenaMedals => 'Toernooimedailles';

  @override
  String medalsSummary(int gold, int silver, int bronze) {
    return 'Medailles: $gold goud, $silver zilver, $bronze brons';
  }

  @override
  String get firstMoveTeam => 'Eerste zet: 5 min';

  @override
  String get games => 'Spellen';

  @override
  String get gamesIntro =>
      'Speel met je community: snelle partijen, toernooien en wedstrijden tussen groepen.';

  @override
  String get chessCardText =>
      'Elo-rating, wekelijkse en maandelijkse toernooien, teamwedstrijden tussen groepen en medailles.';

  @override
  String get playChess => 'Schaken';

  @override
  String blitzRating(int rating) {
    return 'Snelschaak $rating';
  }

  @override
  String nextArena(String time) {
    return 'Volgend toernooi: $time';
  }

  @override
  String invitesWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count uitdagingen wachten',
      one: '1 uitdaging wacht',
    );
    return '$_temp0';
  }

  @override
  String get playOnline => 'Online spelen';

  @override
  String findOpponent(String tc) {
    return 'Tegenstander zoeken · $tc';
  }

  @override
  String get challengeFriendHint => 'Jij kiest tijd en kleur';

  @override
  String get leaderboardHint => 'Elo-ranglijsten en medailles';

  @override
  String openTeamMatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count open wedstrijden',
      one: '1 open wedstrijd',
    );
    return '$_temp0';
  }

  @override
  String get appearance => 'Bord en stukken';

  @override
  String get boardTheme => 'Bord';

  @override
  String get pieceSet => 'Stukken';

  @override
  String get boardWood => 'Hout';

  @override
  String get boardGreen => 'Groen';

  @override
  String get boardBlue => 'Blauw';

  @override
  String get boardSlate => 'Grijs';

  @override
  String get boardLilac => 'GWAY-lila';

  @override
  String get piecesClassic => 'Klassiek';

  @override
  String get piecesCeltic => 'Keltisch';

  @override
  String get piecesSpatial => 'Ruimte';

  @override
  String get piecesFantasy => 'Fantasie';

  @override
  String get piecesModern => 'Modern';

  @override
  String get piecesWarm => 'Warm';

  @override
  String get firstPosition => 'Begin';

  @override
  String get previousMove => 'Vorige zet';

  @override
  String get nextMove => 'Volgende zet';

  @override
  String get lastPosition => 'Huidige stelling';

  @override
  String get backToLive => 'Terug naar live';

  @override
  String pointsShort(int points) {
    return '$points ptn';
  }

  @override
  String mindColorWord(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'red_m': 'rode',
      'red_f': 'rode',
      'red_n': 'rood',
      'blue_m': 'blauwe',
      'blue_f': 'blauwe',
      'blue_n': 'blauw',
      'green_m': 'groene',
      'green_f': 'groene',
      'green_n': 'groen',
      'yellow_m': 'gele',
      'yellow_f': 'gele',
      'yellow_n': 'geel',
      'purple_m': 'paarse',
      'purple_f': 'paarse',
      'purple_n': 'paars',
      'orange_m': 'oranje',
      'orange_f': 'oranje',
      'orange_n': 'oranje',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String mindPatternWord(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'solid_m': 'effen',
      'solid_f': 'effen',
      'solid_n': 'effen',
      'striped_m': 'gestreepte',
      'striped_f': 'gestreepte',
      'striped_n': 'gestreept',
      'dotted_m': 'gestippelde',
      'dotted_f': 'gestippelde',
      'dotted_n': 'gestippeld',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String mindShapeWord(String shape) {
    String _temp0 = intl.Intl.selectLogic(shape, {
      'circle': 'cirkel',
      'square': 'vierkant',
      'triangle': 'driehoek',
      'star': 'ster',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String mindShapeGender(String shape) {
    String _temp0 = intl.Intl.selectLogic(shape, {
      'circle': 'm',
      'square': 'n',
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
  String get mindDuel => 'Breinduel';

  @override
  String get mindCardText =>
      'Een live duel met reken-, aandachts-, geheugen- en reactievragen. Elo-rating, ranglijsten en medailles.';

  @override
  String get mindPlay => 'Start een duel';

  @override
  String mindBestRating(int rating, int length) {
    return 'Elo $rating · $length vragen';
  }

  @override
  String mindQuestions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vragen',
      one: '1 vraag',
    );
    return '$_temp0';
  }

  @override
  String get mindHowMany => 'Hoeveel vragen?';

  @override
  String mindRatingAt(int count) {
    return 'Je rating bij $count vragen';
  }

  @override
  String get mindFindOpponent => 'Tegenstander zoeken';

  @override
  String get mindSuspended => 'Je kunt nu geen spellen spelen.';

  @override
  String get mindActive => 'Je hebt een lopend duel';

  @override
  String get mindProfile => 'Duelprofiel';

  @override
  String get mindHowTo => 'Zo speel je';

  @override
  String get mindRecent => 'Recente duels';

  @override
  String get mindNoMatchesMine =>
      'Nog geen duels. Zoek je eerste tegenstander.';

  @override
  String get mindNoMatchesTheirs => 'Nog geen duels. Daag als eerste uit.';

  @override
  String mindLeaderboardEmpty(int count) {
    return 'Speel $count duels met rating van deze lengte om op de ranglijst te komen.';
  }

  @override
  String get mindChallengeTitle => 'Uitdagen voor een duel';

  @override
  String get mindChallengeSent =>
      'Uitdaging verstuurd. Het duel begint zodra die wordt geaccepteerd.';

  @override
  String get mindKindMath => 'Rekenen';

  @override
  String get mindKindAttention => 'Aandacht';

  @override
  String get mindKindMemory => 'Geheugen';

  @override
  String get mindKindReflex => 'Reactie';

  @override
  String get mindKindMathHint =>
      'Vier bewerkingen, met voorrangsregels. Kies de juiste uitkomst.';

  @override
  String get mindKindAttentionHint =>
      'Let niet op de inktkleur, maar op de beschreven figuur.';

  @override
  String get mindKindMemoryHint =>
      'Onthoud de gekleurde letters en cijfers, op volgorde en met kleur.';

  @override
  String get mindKindReflexHint =>
      'Tik het doel aan zodra het verschijnt. Te vroeg of mis kost punten.';

  @override
  String get mindScoringHint =>
      'Goede en snelle antwoorden leveren meer op. Het hoogste totaal wint.';

  @override
  String get mindYou => 'Jij';

  @override
  String get mindOpponent => 'Tegenstander';

  @override
  String mindProgress(String who, int done, int total) {
    return '$who: $done/$total vragen';
  }

  @override
  String mindQuestionOf(int n, int total) {
    return '$n/$total';
  }

  @override
  String get mindGetReady => 'Maak je klaar';

  @override
  String get mindYouFinished => 'Je bent klaar!';

  @override
  String mindOpponentAt(int done, int total) {
    return 'Je tegenstander is bij $done/$total. De uitslag volgt als die klaar is.';
  }

  @override
  String get mindMathPrompt => 'Wat is de uitkomst?';

  @override
  String get mindAttentionPrompt => 'Kies de beschreven figuur';

  @override
  String get mindMemoryLook => 'Onthoud de volgorde en de kleuren';

  @override
  String get mindMemoryPick => 'Kies ze in dezelfde volgorde en kleuren';

  @override
  String mindCharLabel(String char, String color) {
    return '$color $char';
  }

  @override
  String get mindUndo => 'Ongedaan maken';

  @override
  String get mindReflexTarget => 'Doel';

  @override
  String get mindReflexWait => 'Wacht…';

  @override
  String get mindReflexTap => 'Tik nu!';

  @override
  String mindRight(int points) {
    return 'Goed · +$points';
  }

  @override
  String mindPartly(int points) {
    return 'Deels goed · +$points';
  }

  @override
  String get mindWrong => 'Fout';

  @override
  String mindWrongPenalty(int points) {
    return 'Fout · −$points';
  }

  @override
  String mindTooEarly(int points) {
    return 'Te vroeg · −$points';
  }

  @override
  String get mindResignTitle => 'Duel opgeven?';

  @override
  String get mindResignBody =>
      'Je tegenstander wint; in een duel met rating daalt je Elo.';

  @override
  String get mindFinished => 'Duel afgelopen';

  @override
  String get mindEndCompleted => 'Alle vragen beantwoord';

  @override
  String get mindEndTime => 'Tijd om';

  @override
  String mindNewRating(int rating) {
    return 'Nieuwe rating $rating';
  }

  @override
  String get mindNewDuel => 'Nieuw duel';

  @override
  String get mindBackHome => 'Terug naar duels';
}
