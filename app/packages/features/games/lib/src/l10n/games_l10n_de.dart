// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'games_l10n.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class GamesL10nDe extends GamesL10n {
  GamesL10nDe([String locale = 'de']) : super(locale);

  @override
  String get chess => 'Schach';

  @override
  String get bullet => 'Bullet';

  @override
  String get blitz => 'Blitz';

  @override
  String get rapid => 'Schnellschach';

  @override
  String get white => 'Weiß';

  @override
  String get black => 'Schwarz';

  @override
  String get colorRandom => 'Zufällig';

  @override
  String get endCheckmate => 'Schachmatt';

  @override
  String get endResign => 'Aufgabe';

  @override
  String get endTimeout => 'Zeit abgelaufen';

  @override
  String get endTimeoutDraw =>
      'Zeit abgelaufen, der Gegner kann nicht mattsetzen';

  @override
  String get endStalemate => 'Patt';

  @override
  String get endInsufficient => 'Ungenügendes Material';

  @override
  String get endFiftyMoves => '50-Züge-Regel';

  @override
  String get endRepetition => 'Dreifache Stellungswiederholung';

  @override
  String get endAgreement => 'Remis durch Einigung';

  @override
  String get endAborted => 'Abgebrochen';

  @override
  String get boardLabel => 'Schachbrett';

  @override
  String get promoteTo => 'Bauer umwandeln in';

  @override
  String get queen => 'Dame';

  @override
  String get rook => 'Turm';

  @override
  String get bishop => 'Läufer';

  @override
  String get knight => 'Springer';

  @override
  String get medalGold => 'Goldmedaille';

  @override
  String get medalSilver => 'Silbermedaille';

  @override
  String get medalBronze => 'Bronzemedaille';

  @override
  String get youWon => 'Du hast gewonnen';

  @override
  String get youLost => 'Du hast verloren';

  @override
  String get draw => 'Remis';

  @override
  String get inProgress => 'Läuft';

  @override
  String get whiteWon => 'Weiß gewinnt';

  @override
  String get blackWon => 'Schwarz gewinnt';

  @override
  String get rated => 'Gewertet';

  @override
  String get casual => 'Ungewertet';

  @override
  String get ratedHint => 'Das Ergebnis ändert deine Elo-Zahl.';

  @override
  String get flipBoard => 'Brett drehen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get resign => 'Aufgeben';

  @override
  String get resignTitle => 'Partie aufgeben?';

  @override
  String get resignBody =>
      'Dein Gegner gewinnt; in einer gewerteten Partie sinkt deine Elo-Zahl.';

  @override
  String get abort => 'Abbrechen';

  @override
  String get offerDraw => 'Remis?';

  @override
  String get drawOffered => 'Angeboten';

  @override
  String get drawOfferReceived => 'Dein Gegner bietet Remis an.';

  @override
  String get accept => 'Annehmen';

  @override
  String get decline => 'Ablehnen';

  @override
  String get rematch => 'Revanche';

  @override
  String get rematchSent => 'Revanche angefragt.';

  @override
  String get newGame => 'Neue Partie';

  @override
  String newRating(String category, int rating) {
    return 'Deine $category-Zahl: $rating';
  }

  @override
  String get deletedPlayer => 'Gelöschtes Konto';

  @override
  String get firstMove => 'Erster Zug: 30 s';

  @override
  String get noMovesYet => 'Noch keine Züge. Weiß beginnt.';

  @override
  String get watching => 'Du schaust zu';

  @override
  String get quickGame => 'Schnelle Partie';

  @override
  String get quickGameHint =>
      'Wähle eine Bedenkzeit und spiele gegen jemanden mit ähnlicher Zahl.';

  @override
  String get searching => 'Gegner wird gesucht …';

  @override
  String waitedSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Seit $count Sekunden',
      one: 'Seit 1 Sekunde',
    );
    return '$_temp0';
  }

  @override
  String get chessProfile => 'Schachprofil';

  @override
  String get recentGames => 'Letzte Partien';

  @override
  String get noGamesMine => 'Noch keine Partien. Spiel deine erste.';

  @override
  String get noGamesTheirs => 'Noch keine Partien. Lade zur ersten ein.';

  @override
  String get playNow => 'Jetzt spielen';

  @override
  String get challenge => 'Herausfordern';

  @override
  String get noFlag => 'Keine Flagge gewählt';

  @override
  String get chooseFlag => 'Wähle deine Flagge';

  @override
  String get chooseFlagHint =>
      'Sie erscheint neben deinem Namen in der Rangliste.';

  @override
  String get searchCountry => 'Land suchen';

  @override
  String get flagSaved => 'Flagge gespeichert.';

  @override
  String get pickFlagPrompt => 'Wähle die Flagge für die Rangliste.';

  @override
  String get suspendedNotice => 'Schach ist für diese Person gerade gesperrt.';

  @override
  String get notPlayed => 'Nicht gespielt';

  @override
  String gamesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Partien',
      one: '1 Partie',
    );
    return '$_temp0';
  }

  @override
  String rankShort(int rank) {
    return 'Platz $rank';
  }

  @override
  String get leaderboard => 'Rangliste';

  @override
  String leaderboardEmpty(int count) {
    return 'Spiele $count gewertete Partien in dieser Kategorie, um in die Rangliste zu kommen.';
  }

  @override
  String record(int wins, int draws, int losses) {
    return '${wins}S · ${draws}R · ${losses}N';
  }

  @override
  String get seeAll => 'Alle ansehen';

  @override
  String get invitations => 'Einladungen';

  @override
  String invitesYou(String what) {
    return 'Lädt dich zu einer Partie ein: $what';
  }

  @override
  String wantsRematch(String what) {
    return 'Möchte eine Revanche: $what';
  }

  @override
  String waitingFor(String what) {
    return 'Warte auf Antwort: $what';
  }

  @override
  String get withdraw => 'Zurückziehen';

  @override
  String get gameInProgress => 'Du hast eine laufende Partie';

  @override
  String get resume => 'Fortsetzen';

  @override
  String get challengeFriend => 'Freund herausfordern';

  @override
  String get challengeSent =>
      'Einladung gesendet. Die Partie beginnt, wenn sie angenommen wird.';

  @override
  String get challengeTitle => 'Zu einer Partie einladen';

  @override
  String get changePerson => 'Person ändern';

  @override
  String get searchPerson => 'Benutzername oder Name';

  @override
  String get timeControl => 'Bedenkzeit';

  @override
  String get yourColor => 'Deine Farbe';

  @override
  String get sendChallenge => 'Einladung senden';

  @override
  String get teamMatch => 'Mannschaftskampf';

  @override
  String get teamMatches => 'Mannschaftskämpfe';

  @override
  String get teamMatchesHint =>
      'Die Schachkämpfe deiner Gruppen; das Ergebnis ändert die Gruppen-Elo.';

  @override
  String get noTeamMatches =>
      'Noch keine Mannschaftskämpfe. Lade im Namen deiner Gruppe eine andere ein.';

  @override
  String get newTeamMatch => 'Mannschaftskampf planen';

  @override
  String get newTeamMatchHint =>
      'Sobald die andere Gruppe annimmt, stellen beide Gruppen ihre Spieler auf.';

  @override
  String get yourGroup => 'Deine Gruppe';

  @override
  String get opponentGroup => 'Gegnerische Gruppe';

  @override
  String get searchGroup => 'Gruppenname oder Kennung';

  @override
  String get startsAt => 'Beginn';

  @override
  String get sendTeamInvite => 'Gruppe einladen';

  @override
  String get boards => 'Bretter';

  @override
  String get boardsShort => 'Bretter';

  @override
  String boardsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Bretter',
      one: '1 Brett',
    );
    return '$_temp0';
  }

  @override
  String groupElo(int rating) {
    return 'Gruppen-Elo $rating';
  }

  @override
  String get versus => 'VS';

  @override
  String get versusShort => '–';

  @override
  String get teamInvited => 'Wartet auf Antwort';

  @override
  String get teamAccepted => 'Angenommen';

  @override
  String get teamDeclined => 'Abgelehnt';

  @override
  String get teamCanceled => 'Abgesagt';

  @override
  String get teamLive => 'Läuft';

  @override
  String get teamFinished => 'Beendet';

  @override
  String teamInviteReceived(String group) {
    return '$group lädt eure Gruppe zu einem Mannschaftskampf ein.';
  }

  @override
  String get teamAcceptedDone =>
      'Kampf angenommen. Stellt jetzt eure Spieler auf.';

  @override
  String get teamDeclinedDone => 'Einladung abgelehnt.';

  @override
  String get teamCanceledDone => 'Kampf abgesagt.';

  @override
  String get callOff => 'Kampf absagen';

  @override
  String get lineupHint =>
      'Ein beim Start leeres Brett zählt als Punkt für die andere Seite.';

  @override
  String get lineupSheetHint =>
      'Tippe Mitglieder an, um sie der Reihe nach aufzustellen; Brett 1 gehört dem stärksten Spieler.';

  @override
  String editLineup(String group) {
    return 'Aufstellung $group';
  }

  @override
  String get saveLineup => 'Aufstellung speichern';

  @override
  String get emptyBoard => 'Leer';

  @override
  String ratingGames(int rating, int games) {
    return 'Elo $rating · $games Partien';
  }

  @override
  String get groupsTab => 'Gruppen';

  @override
  String get groupLeaderboardEmpty =>
      'Noch keine Gruppe hat einen Mannschaftskampf gespielt. Sei die erste.';

  @override
  String get backToChess => 'Zurück zum Schach';

  @override
  String get arena => 'Turnier';

  @override
  String get tournaments => 'Turniere';

  @override
  String get tournamentsHint =>
      'Wöchentliche und monatliche Arena-Turniere; die ersten drei bekommen Medaillen.';

  @override
  String get weeklyArena => 'Wöchentliche Arena';

  @override
  String get monthlyArena => 'Monatliche Arena';

  @override
  String get arenaRules =>
      'Arena: Spiele bis zum Ende so viele Partien, wie du willst. Sieg 2 Punkte, Remis 1; nach zwei Siegen in Folge zählen die Punkte doppelt, bis die Serie reißt. Vor dem Ende begonnene Partien zählen.';

  @override
  String get arenaLiveNow => 'Jetzt live';

  @override
  String get arenaUpcoming => 'Demnächst';

  @override
  String get arenaFinished => 'Beendet';

  @override
  String get registered => 'Angemeldet';

  @override
  String get arenaRegister => 'Anmelden';

  @override
  String get arenaRegistered =>
      'Du bist angemeldet. Zum Start bekommst du eine Mitteilung und wirst beim Öffnen sofort gepaart.';

  @override
  String get arenaJoin => 'Mitspielen';

  @override
  String get arenaResume => 'Weiterspielen';

  @override
  String get arenaPause => 'Pause';

  @override
  String get arenaWaiting =>
      'Warte auf einen Gegner; die Partie öffnet sich, sobald jemand mit ähnlicher Punktzahl frei ist.';

  @override
  String get backToGame => 'Zurück zur Partie';

  @override
  String get backToArena => 'Zurück zum Turnier';

  @override
  String get backToTeamMatch => 'Zurück zum Mannschaftskampf';

  @override
  String arenaStartsIn(String time) {
    return 'Beginnt in $time';
  }

  @override
  String arenaEndsIn(String time) {
    return 'Noch $time';
  }

  @override
  String get arenaLastGames => 'Zeit ist um; die letzten Partien laufen noch';

  @override
  String arenaFinishedAt(String time) {
    return 'Beendet · $time';
  }

  @override
  String hoursMinutes(int hours, int minutes) {
    return '$hours Std. $minutes Min.';
  }

  @override
  String minutesLong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Minuten',
      one: '1 Minute',
    );
    return '$_temp0';
  }

  @override
  String playersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Spieler',
      one: '1 Spieler',
    );
    return '$_temp0';
  }

  @override
  String myArenaScore(int points, int games) {
    return '$points Punkte · $games Partien';
  }

  @override
  String get onFire => 'Serie: das nächste Ergebnis zählt doppelt';

  @override
  String get standings => 'Tabelle';

  @override
  String get arenaEmpty => 'Noch niemand dabei. Sei der Erste.';

  @override
  String performance(int value) {
    return 'Leistung $value';
  }

  @override
  String get playingNow => 'spielt';

  @override
  String get arenaMedals => 'Turniermedaillen';

  @override
  String medalsSummary(int gold, int silver, int bronze) {
    return 'Turniermedaillen: $gold Gold, $silver Silber, $bronze Bronze';
  }

  @override
  String get firstMoveTeam => 'Erster Zug: 5 Min.';
}
