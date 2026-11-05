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

  @override
  String get games => 'Spiele';

  @override
  String get gamesIntro =>
      'Spiele mit deiner Community: schnelle Partien, Turniere und Kämpfe zwischen Gruppen.';

  @override
  String get chessCardText =>
      'Elo-Zahl, wöchentliche und monatliche Turniere, Mannschaftskämpfe zwischen Gruppen und Medaillen.';

  @override
  String get playChess => 'Schach spielen';

  @override
  String blitzRating(int rating) {
    return 'Blitz $rating';
  }

  @override
  String nextArena(String time) {
    return 'Nächstes Turnier: $time';
  }

  @override
  String invitesWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einladungen warten',
      one: '1 Einladung wartet',
    );
    return '$_temp0';
  }

  @override
  String get playOnline => 'Online spielen';

  @override
  String findOpponent(String tc) {
    return 'Gegner finden · $tc';
  }

  @override
  String get challengeFriendHint => 'Du wählst Zeit und Farbe';

  @override
  String get leaderboardHint => 'Elo-Ranglisten und Medaillen';

  @override
  String openTeamMatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count offene Kämpfe',
      one: '1 offener Kampf',
    );
    return '$_temp0';
  }

  @override
  String get appearance => 'Brett und Figuren';

  @override
  String get boardTheme => 'Brett';

  @override
  String get pieceSet => 'Figuren';

  @override
  String get boardWood => 'Holz';

  @override
  String get boardGreen => 'Grün';

  @override
  String get boardBlue => 'Blau';

  @override
  String get boardSlate => 'Grau';

  @override
  String get boardLilac => 'GWAY-Lila';

  @override
  String get piecesClassic => 'Klassisch';

  @override
  String get piecesCeltic => 'Keltisch';

  @override
  String get piecesSpatial => 'Raum';

  @override
  String get piecesFantasy => 'Fantasy';

  @override
  String get piecesModern => 'Modern';

  @override
  String get piecesWarm => 'Warm';

  @override
  String get firstPosition => 'Anfang';

  @override
  String get previousMove => 'Vorheriger Zug';

  @override
  String get nextMove => 'Nächster Zug';

  @override
  String get lastPosition => 'Aktuelle Stellung';

  @override
  String get backToLive => 'Zurück zu live';

  @override
  String pointsShort(int points) {
    return '$points Pkt.';
  }

  @override
  String mindColorWord(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'red_m': 'roter',
      'red_f': 'rote',
      'red_n': 'rotes',
      'blue_m': 'blauer',
      'blue_f': 'blaue',
      'blue_n': 'blaues',
      'green_m': 'grüner',
      'green_f': 'grüne',
      'green_n': 'grünes',
      'yellow_m': 'gelber',
      'yellow_f': 'gelbe',
      'yellow_n': 'gelbes',
      'purple_m': 'violetter',
      'purple_f': 'violette',
      'purple_n': 'violettes',
      'orange_m': 'oranger',
      'orange_f': 'orange',
      'orange_n': 'oranges',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String mindPatternWord(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'solid_m': 'einfarbiger',
      'solid_f': 'einfarbige',
      'solid_n': 'einfarbiges',
      'striped_m': 'gestreifter',
      'striped_f': 'gestreifte',
      'striped_n': 'gestreiftes',
      'dotted_m': 'gepunkteter',
      'dotted_f': 'gepunktete',
      'dotted_n': 'gepunktetes',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String mindShapeWord(String shape) {
    String _temp0 = intl.Intl.selectLogic(shape, {
      'circle': 'Kreis',
      'square': 'Quadrat',
      'triangle': 'Dreieck',
      'star': 'Stern',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String mindShapeGender(String shape) {
    String _temp0 = intl.Intl.selectLogic(shape, {
      'circle': 'm',
      'square': 'n',
      'triangle': 'n',
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
  String get mindDuel => 'Gedankenduell';

  @override
  String get mindCardText =>
      'Ein Live-Duell mit Mathe-, Aufmerksamkeits-, Gedächtnis- und Reaktionsfragen. Elo-Wertung, Ranglisten und Medaillen.';

  @override
  String get mindPlay => 'Duell starten';

  @override
  String mindBestRating(int rating, int length) {
    return 'Elo $rating · $length Fragen';
  }

  @override
  String mindQuestions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Fragen',
      one: '1 Frage',
    );
    return '$_temp0';
  }

  @override
  String get mindHowMany => 'Wie viele Fragen?';

  @override
  String mindRatingAt(int count) {
    return 'Deine Wertung bei $count Fragen';
  }

  @override
  String get mindFindOpponent => 'Gegner finden';

  @override
  String get mindSuspended => 'Du kannst gerade keine Spiele spielen.';

  @override
  String get mindActive => 'Du hast ein laufendes Duell';

  @override
  String get mindProfile => 'Duellprofil';

  @override
  String get mindHowTo => 'So wird\'s gespielt';

  @override
  String get mindRecent => 'Letzte Duelle';

  @override
  String get mindNoMatchesMine =>
      'Noch keine Duelle. Finde deinen ersten Gegner.';

  @override
  String get mindNoMatchesTheirs =>
      'Noch keine Duelle. Fordere als Erste:r heraus.';

  @override
  String mindLeaderboardEmpty(int count) {
    return 'Spiele $count gewertete Duelle dieser Länge, um in die Rangliste zu kommen.';
  }

  @override
  String get mindChallengeTitle => 'Zum Duell herausfordern';

  @override
  String get mindChallengeSent =>
      'Herausforderung gesendet. Das Duell beginnt nach der Zusage.';

  @override
  String get mindKindMath => 'Mathe';

  @override
  String get mindKindAttention => 'Aufmerksamkeit';

  @override
  String get mindKindMemory => 'Gedächtnis';

  @override
  String get mindKindReflex => 'Reaktion';

  @override
  String get mindKindMathHint =>
      'Grundrechenarten, Punkt vor Strich. Wähle das richtige Ergebnis.';

  @override
  String get mindKindAttentionHint =>
      'Achte nicht auf die Schriftfarbe, sondern auf die beschriebene Figur.';

  @override
  String get mindKindMemoryHint =>
      'Merke dir die farbigen Buchstaben und Ziffern samt Reihenfolge und Farbe.';

  @override
  String get mindKindReflexHint =>
      'Tippe das Ziel an, sobald es erscheint. Zu früh oder daneben kostet Punkte.';

  @override
  String get mindScoringHint =>
      'Richtige und schnelle Antworten bringen mehr Punkte. Die höhere Summe gewinnt.';

  @override
  String get mindYou => 'Du';

  @override
  String get mindOpponent => 'Gegner';

  @override
  String mindProgress(String who, int done, int total) {
    return '$who: $done/$total Fragen';
  }

  @override
  String mindQuestionOf(int n, int total) {
    return '$n/$total';
  }

  @override
  String get mindGetReady => 'Mach dich bereit';

  @override
  String get mindYouFinished => 'Geschafft!';

  @override
  String mindOpponentAt(int done, int total) {
    return 'Dein Gegner ist bei $done/$total. Das Ergebnis kommt, wenn er fertig ist.';
  }

  @override
  String get mindMathPrompt => 'Was ist das Ergebnis?';

  @override
  String get mindAttentionPrompt => 'Wähle die beschriebene Figur';

  @override
  String get mindMemoryLook => 'Merke dir Reihenfolge und Farben';

  @override
  String get mindMemoryPick => 'Wähle sie in derselben Reihenfolge und Farbe';

  @override
  String mindCharLabel(String char, String color) {
    return '$char, $color';
  }

  @override
  String get mindUndo => 'Rückgängig';

  @override
  String get mindReflexTarget => 'Ziel';

  @override
  String get mindReflexWait => 'Warte…';

  @override
  String get mindReflexTap => 'Jetzt tippen!';

  @override
  String mindRight(int points) {
    return 'Richtig · +$points';
  }

  @override
  String mindPartly(int points) {
    return 'Teilweise richtig · +$points';
  }

  @override
  String get mindWrong => 'Falsch';

  @override
  String mindWrongPenalty(int points) {
    return 'Falsch · −$points';
  }

  @override
  String mindTooEarly(int points) {
    return 'Zu früh · −$points';
  }

  @override
  String get mindResignTitle => 'Duell aufgeben?';

  @override
  String get mindResignBody =>
      'Dein Gegner gewinnt; in einem gewerteten Duell sinkt deine Elo.';

  @override
  String get mindFinished => 'Duell beendet';

  @override
  String get mindEndCompleted => 'Alle Fragen beantwortet';

  @override
  String get mindEndTime => 'Zeit abgelaufen';

  @override
  String mindNewRating(int rating) {
    return 'Neue Wertung $rating';
  }

  @override
  String get mindNewDuel => 'Neues Duell';

  @override
  String get mindBackHome => 'Zurück zu den Duellen';

  @override
  String get mindTeamMatches => 'Gruppenduelle';

  @override
  String get mindTeamMatchesHint =>
      'Duelle deiner Gruppen gegen andere; das Ergebnis ändert die Duell-Elo der Gruppe.';

  @override
  String get mindNoTeamMatches =>
      'Noch keine Gruppenduelle. Fordere im Namen deiner Gruppe eine andere heraus.';

  @override
  String get mindNewTeamMatch => 'Gruppenduell planen';

  @override
  String get mindNewTeamHint =>
      'Sobald die andere Gruppe zusagt, stellen beide ihre Spieler auf. Zum Start duellieren sich die beiden Spieler jedes Platzes gleichzeitig.';

  @override
  String get mindTeamMatch => 'Gruppenduell';

  @override
  String get mindSeats => 'Plätze';

  @override
  String mindSeatsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Plätze',
      one: '1 Platz',
    );
    return '$_temp0';
  }

  @override
  String get mindLineupHint =>
      'Ein beim Start leerer Platz zählt für die andere Seite. Auf die erste Frage wird 5 Minuten gewartet.';

  @override
  String get mindGroupLeaderboardEmpty =>
      'Noch keine Gruppe hat ein Gruppenduell gespielt. Lass deine das erste planen.';
}
