// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'events_l10n.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class EventsL10nDe extends EventsL10n {
  EventsL10nDe([String locale = 'de']) : super(locale);

  @override
  String get pollSingle => 'In dieser Umfrage ist nur eine Antwort möglich.';

  @override
  String get pollOptionGone =>
      'Diese Option gibt es nicht mehr. Lade die Seite neu.';

  @override
  String get reviewWindow =>
      'Teilnehmende können das Event bis 30 Tage nach dem Ende bewerten.';

  @override
  String get greeterNeedsAttendance =>
      'Um Begrüßer:in zu werden, musst du an einem Event der Gruppe teilgenommen haben.';

  @override
  String get note80 => 'Die Notiz darf höchstens 80 Zeichen lang sein.';

  @override
  String get pollClosed =>
      'Diese Umfrage ist beendet oder du kannst nicht abstimmen.';

  @override
  String get cover5mb => 'Das Titelbild darf höchstens 5 MB groß sein.';

  @override
  String get imagesOnly =>
      'Nur JPEG-, PNG- oder WebP-Bilder können hochgeladen werden.';

  @override
  String get claimNotAllowed =>
      'Diese Aufgabe kann gerade nicht gemeldet werden: Sie ist beendet oder du bist nicht in der Gruppe.';

  @override
  String get claimApprovedLocked =>
      'Eine bestätigte Meldung kann nicht zurückgezogen werden.';

  @override
  String get claimDuplicate => 'Du hast diese Aufgabe bereits gemeldet.';

  @override
  String get repeatsWeekly => 'Wiederholt sich jede Woche';

  @override
  String get repeatsBiweekly => 'Wiederholt sich alle zwei Wochen';

  @override
  String surprisePlace(String place) {
    return 'Überraschungsort · $place';
  }

  @override
  String get goalPersonal => 'Persönliches Ziel';

  @override
  String get goalPersonalHint => 'Jedes Mitglied erreicht seine eigene Zahl.';

  @override
  String get goalGroup => 'Gruppenziel';

  @override
  String get goalGroupHint =>
      'Alle Beiträge zählen in einem gemeinsamen Zähler.';

  @override
  String get goalTeam => 'Teamziel';

  @override
  String get goalTeamHint =>
      'Admins bilden die Teams; jedes Team hat einen gemeinsamen Zähler.';

  @override
  String get goalTask => 'Bestätigte Aufgabe';

  @override
  String get goalTaskHint =>
      'Ein Mitglied meldet „Erledigt“, ein Admin bestätigt.';

  @override
  String unitAttended(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Teilnahmen',
      one: 'Teilnahme',
    );
    return '$_temp0';
  }

  @override
  String unitOrganized(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'organisierte Events',
      one: 'organisiertes Event',
    );
    return '$_temp0';
  }

  @override
  String unitMemories(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Erinnerungen',
      one: 'Erinnerung',
    );
    return '$_temp0';
  }

  @override
  String get claimPending => 'Wartet auf Bestätigung';

  @override
  String get claimApproved => 'Bestätigt';

  @override
  String get claimRejected => 'Nicht bestätigt';

  @override
  String get notClaimedYet => 'Noch nicht gemeldet';

  @override
  String get whenAny => 'Jederzeit';

  @override
  String get whenToday => 'Heute';

  @override
  String get whenWeek => 'In 7 Tagen';

  @override
  String get viewDay => 'Tag';

  @override
  String get viewWeek => 'Woche';

  @override
  String get viewMonth => 'Monat';

  @override
  String countAttended(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Teilnahmen',
      one: '1 Teilnahme',
    );
    return '$_temp0';
  }

  @override
  String countOrganized(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Events organisiert',
      one: '1 Event organisiert',
    );
    return '$_temp0';
  }

  @override
  String countMemories(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Erinnerungen',
      one: '1 Erinnerung',
    );
    return '$_temp0';
  }

  @override
  String countReviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Bewertungen',
      one: '1 Bewertung',
    );
    return '$_temp0';
  }

  @override
  String countWelcomed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Neulinge begrüßt',
      one: '1 Neuling begrüßt',
    );
    return '$_temp0';
  }

  @override
  String countHandshakes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Handshakes',
      one: '1 Handshake',
    );
    return '$_temp0';
  }

  @override
  String countHeld(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Events',
      one: '1 Event',
    );
    return '$_temp0';
  }

  @override
  String countGoodReviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gute Bewertungen',
      one: '1 gute Bewertung',
    );
    return '$_temp0';
  }

  @override
  String leagueStanding(String month, int groups, int rank, int points) {
    return '$month: Platz $rank von $groups Gruppen, $points Punkte.';
  }

  @override
  String goingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Teilnehmende',
      one: '1 Teilnehmer:in',
    );
    return '$_temp0';
  }

  @override
  String goingOfCapacity(int count, int capacity) {
    return '$count / $capacity Teilnehmende';
  }

  @override
  String firstEventOfYear(String title) {
    return 'Erstes Event des Jahres: $title';
  }

  @override
  String firstEventOfYearOn(String title, String date) {
    return 'Erstes Event des Jahres: $title · $date';
  }

  @override
  String get myCalendar => 'Mein Kalender';

  @override
  String get groupCalendar => 'Gruppenkalender';

  @override
  String get previous => 'Zurück';

  @override
  String get next => 'Weiter';

  @override
  String get today => 'Heute';

  @override
  String get groupsEvents => 'Events meiner Gruppen';

  @override
  String get showNotJoined =>
      'Auch Events zeigen, an denen ich nicht teilnehme';

  @override
  String get noJoinedInRange =>
      'An diesen Tagen nimmst du an keinem Event teil. Sieh dir auch die Events deiner Gruppen an.';

  @override
  String get noEventsInRange => 'An diesen Tagen gibt es keine Events.';

  @override
  String get showGroupsEvents => 'Events meiner Gruppen zeigen';

  @override
  String get backToToday => 'Zurück zu heute';

  @override
  String get noEventsDay => 'An diesem Tag gibt es keine Events.';

  @override
  String get contributions => 'Beitrag zur Community';

  @override
  String get howBadges => 'Wie bekommt man Abzeichen?';

  @override
  String get badgesEmpty =>
      'Wenn du an einem Event teilnimmst, erscheinen hier dein Beitrag und dein erstes Abzeichen.';

  @override
  String get badgesRules =>
      'Abzeichen zählen nur, was du wirklich tust: Events, an denen du teilnimmst und die du organisierst, geteilte Erinnerungen und Bewertungen. Likes und Follower zählen nicht. Als „nicht erschienen“ markierte Teilnahmen zählen nicht. Niemand wird gerankt.';

  @override
  String get categoryFan => 'Kategorie-Fan';

  @override
  String get pastEvents => 'Vergangene Events';

  @override
  String get noPastEvents => 'Diese Gruppe hat noch keine vergangenen Events.';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get canceled => 'Abgesagt';

  @override
  String get olderEvents => 'Ältere Events';

  @override
  String get completed => 'Geschafft';

  @override
  String get ended => 'Beendet';

  @override
  String teamName(String name) {
    return 'Team: $name';
  }

  @override
  String get teamNotice =>
      'Sobald du einem Team zugeordnet bist, siehst du hier deinen Fortschritt.';

  @override
  String get goals => 'Ziele';

  @override
  String get createGoal => 'Ziel erstellen';

  @override
  String get goalsEmpty =>
      'Zum Beispiel „Diesen Monat 4 Wanderungen“ oder „Gemeinsam 50 Teilnahmen“: Erstelle das erste Ziel.';

  @override
  String get claimSent => 'Deine Meldung wurde an die Admins gesendet.';

  @override
  String get goal => 'Ziel';

  @override
  String get goalCountsRule =>
      'Es zählen nur Events dieser Gruppe im Zeitraum; als „nicht erschienen“ markierte Teilnahmen zählen nicht.';

  @override
  String get withdrawClaim => 'Meldung zurückziehen';

  @override
  String get claimWithdrawn => 'Deine Meldung wurde zurückgezogen.';

  @override
  String get done => 'Erledigt';

  @override
  String get teams => 'Teams';

  @override
  String get createTeam => 'Team bilden';

  @override
  String get noTeams => 'Noch keine Teams.';

  @override
  String deleteTeam(String name) {
    return 'Team $name löschen';
  }

  @override
  String get teamDeleted => 'Team gelöscht.';

  @override
  String pendingClaims(int count) {
    return 'Meldungen zur Bestätigung ($count)';
  }

  @override
  String get claimRejectedToast => 'Meldung nicht bestätigt.';

  @override
  String get decline => 'Ablehnen';

  @override
  String get approve => 'Bestätigen';

  @override
  String taskDone(String name) {
    return '$name hat die Aufgabe erledigt.';
  }

  @override
  String completions(int count) {
    return 'Geschafft von ($count)';
  }

  @override
  String get noCompletions =>
      'Noch hat es niemand geschafft. Wer es schafft, bekommt das Abzeichen dieses Ziels im Profil.';

  @override
  String get goalCanceled => 'Ziel abgesagt.';

  @override
  String get cancelGoal => 'Ziel absagen';

  @override
  String teamCreated(String name) {
    return 'Team „$name“ erstellt.';
  }

  @override
  String get teamNameLabel => 'Teamname';

  @override
  String get createTheTeam => 'Team bilden';

  @override
  String createTeamWith(int count) {
    return 'Team bilden ($count Personen)';
  }

  @override
  String get goalCreated => 'Ziel erstellt.';

  @override
  String get title => 'Titel';

  @override
  String get goalTitleExample => 'Z. B. Oktober-Wanderungen';

  @override
  String get taskTitleExample => 'Z. B. Einem neuen Mitglied die Route zeigen';

  @override
  String get titleMin3 => 'Der Titel muss mindestens 3 Zeichen lang sein.';

  @override
  String get descriptionOptional => 'Beschreibung (optional)';

  @override
  String get targetNumber => 'Zielwert';

  @override
  String get target1to1000 => 'Gib eine Zahl von 1 bis 1000 ein.';

  @override
  String get period => 'Zeitraum';

  @override
  String periodRange(String from, String to) {
    return '$from – $to (höchstens 92 Tage)';
  }

  @override
  String get createTheGoal => 'Ziel erstellen';

  @override
  String get iDidTask => 'Ich habe die Aufgabe erledigt';

  @override
  String get whatDidYouDo => 'Was hast du gemacht? (optional)';

  @override
  String get whatDidYouDoHint =>
      'Die Admins bestätigen nach dem Lesen dieser Notiz.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get send => 'Senden';

  @override
  String get handshake => 'Handshake';

  @override
  String get handshakeHint =>
      'Scannt gegenseitig eure Codes; ihr landet beide in „Leute, die ich getroffen habe“.';

  @override
  String get open => 'Öffnen';

  @override
  String handshakeAt(String title) {
    return 'Handshake · $title';
  }

  @override
  String get myCode => 'Mein Code';

  @override
  String get scan => 'Scannen';

  @override
  String get yourHandshakeCode => 'Dein Handshake-Code';

  @override
  String get codeHint =>
      'Die andere Person scannt den Code im Tab „Scannen“ oder tippt ihn ein. Er erneuert sich alle paar Minuten; ein Foto davon funktioniert später nicht.';

  @override
  String get cameraFailed =>
      'Die Kamera konnte nicht geöffnet werden. Erlaube den Kamerazugriff in den Einstellungen oder gib den Code unten ein.';

  @override
  String get scanHint =>
      'Halte die Kamera auf den QR-Code der anderen Person oder gib den Code ein.';

  @override
  String get typeCodeHint =>
      'Gib den 6-stelligen Code vom Bildschirm der anderen Person ein.';

  @override
  String get code => 'Code';

  @override
  String get alreadyMet => 'Ihr kennt euch schon';

  @override
  String get metNow => 'Ihr habt euch kennengelernt!';

  @override
  String personWithUsername(String name, String username) {
    return '$name (@$username)';
  }

  @override
  String get ok => 'OK';

  @override
  String get metPeople => 'Leute, die ich getroffen habe';

  @override
  String get metEmpty =>
      'Wenn du bei einem Event jemandem die Hand gibst, erscheint die Person hier. Handshakes öffnest du auf der Event-Seite.';

  @override
  String get goToCalendar => 'Zu meinem Kalender';

  @override
  String get metPrivacy =>
      'Nur du siehst das. In deinem Profil steht nur die Anzahl deiner Handshakes.';

  @override
  String metRow(String username, String event, String date) {
    return '@$username · $event · $date';
  }

  @override
  String get howPoints => 'Wie werden Punkte berechnet?';

  @override
  String get leagueIntro =>
      'Gruppen derselben Kategorie in derselben Provinz treten jeden Monat an. Es zählen die im Monat beendeten Events.';

  @override
  String get ruleAttendance => 'Teilnahme: 1 Punkt';

  @override
  String get ruleAttendanceHint =>
      'Jede Person, die kommt; höchstens 30 pro Event.';

  @override
  String get ruleHeld => 'Event: 5 Punkte';

  @override
  String get ruleHeldHint =>
      'Jedes Event mit mindestens 3 Teilnehmenden außer der organisierenden Person.';

  @override
  String get ruleWelcome => 'Begrüßung: 3 Punkte';

  @override
  String get ruleWelcomeHint => 'Jemanden begrüßen, der zum ersten Mal kommt.';

  @override
  String get ruleReview => 'Gute Bewertung: 1 Punkt';

  @override
  String get ruleReviewHint => 'Jede Bewertung mit 4 oder 5 Sternen.';

  @override
  String get leagueRulesNote =>
      'Als „nicht erschienen“ markierte zählen nicht. Die Ergebnisse stehen 8 Tage nach Monatsende fest; Mitglieder der Top 3 werden benachrichtigt.';

  @override
  String get groupsLeague => 'Gruppenliga';

  @override
  String get category => 'Kategorie';

  @override
  String get province => 'Provinz';

  @override
  String get month => 'Monat';

  @override
  String seasonClosed(String month) {
    return 'Die Saison $month ist vorbei; die Tabelle steht fest.';
  }

  @override
  String get seasonRunning =>
      'Die Saison läuft. Punkte aktualisieren sich, sobald Events enden; Ergebnisse stehen 8 Tage nach Monatsende fest.';

  @override
  String leagueEmpty(String province) {
    return 'In der Liga $province hat diesen Monat noch keine Gruppe gepunktet.';
  }

  @override
  String points(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Punkte',
      one: '1 Punkt',
    );
    return '$_temp0';
  }

  @override
  String rank(int rank) {
    return '$rank.';
  }

  @override
  String leagueName(String province, String category) {
    return '$province · Liga $category';
  }

  @override
  String get noPointsYet =>
      'Diesen Monat noch keine Punkte. Beendete Events, Teilnahmen und Begrüßungen bringen Punkte.';

  @override
  String get mapAttribution =>
      '© Stadia Maps © OpenMapTiles © OpenStreetMap-Mitwirkende';

  @override
  String get map => 'Karte';

  @override
  String get mapView => 'Kartenansicht';

  @override
  String get listView => 'Listenansicht';

  @override
  String get all => 'Alle';

  @override
  String get wholeArea => 'Ganzer Bereich';

  @override
  String km(int km) {
    return '$km km';
  }

  @override
  String get mapLoadFailed => 'Die Kartendaten konnten nicht geladen werden.';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get noFilterResults => 'Mit diesen Filtern wurde nichts gefunden.';

  @override
  String get clearFilters => 'Filter löschen';

  @override
  String get noNearby =>
      'In dieser Gegend gibt es keine anstehenden Events oder Gruppen.';

  @override
  String get zoomOut => 'Herauszoomen';

  @override
  String get openEvent => 'Event öffnen';

  @override
  String memberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mitglieder',
      one: '1 Mitglied',
    );
    return '$_temp0';
  }

  @override
  String get noVisible =>
      'Im sichtbaren Bereich gibt es keine anstehenden Events oder Gruppen.';

  @override
  String get backToMap => 'Zurück zur Karte';

  @override
  String upcomingCount(int count) {
    return 'Anstehende Events ($count)';
  }

  @override
  String get directions => 'Route';

  @override
  String get meetingPointOptional => 'Treffpunkt (optional)';

  @override
  String get meetingPointHint =>
      'Wähle ihn auf der Karte; das Event erscheint dann auf der Karte.';

  @override
  String pointPicked(String lat, String lng) {
    return 'Ausgewählt · $lat, $lng';
  }

  @override
  String get removeMeetingPoint => 'Treffpunkt entfernen';

  @override
  String get meetingPoint => 'Treffpunkt';

  @override
  String get pickHint => 'Zoome hinein und tippe auf den Treffpunkt.';

  @override
  String get pickAgainHint =>
      'Tippe woanders hin, um den Punkt zu verschieben.';

  @override
  String get pickThisPoint => 'Diesen Punkt wählen';

  @override
  String get mapUnavailable => 'Die Karte ist gerade nicht verfügbar.';
}
