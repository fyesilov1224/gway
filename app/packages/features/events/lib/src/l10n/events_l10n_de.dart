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

  @override
  String get pollClosedShort => 'Beendet';

  @override
  String closesAt(String date) {
    return 'Endet: $date';
  }

  @override
  String get multipleAllowed => 'Mehrfachauswahl';

  @override
  String get anonymousVote => 'Anonyme Abstimmung';

  @override
  String votersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Stimmen',
      one: '1 Stimme',
    );
    return '$_temp0';
  }

  @override
  String get pollOptions => 'Umfrageoptionen';

  @override
  String get pollClosedToast => 'Umfrage beendet.';

  @override
  String get pollDeleted => 'Umfrage gelöscht.';

  @override
  String get closePoll => 'Umfrage beenden';

  @override
  String get deletePoll => 'Umfrage löschen';

  @override
  String get vote => 'Abstimmen';

  @override
  String get voteSaved => 'Deine Stimme wurde gespeichert.';

  @override
  String get voters => 'Abstimmende';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Personen',
      one: '1 Person',
    );
    return '$_temp0';
  }

  @override
  String get polls => 'Umfragen';

  @override
  String get openPoll => 'Umfrage starten';

  @override
  String get pollsEmpty =>
      'Stell den Mitgliedern eine Frage, z. B. an welchem Tag ihr euch trefft?';

  @override
  String get pollOpened => 'Umfrage gestartet.';

  @override
  String get question => 'Frage';

  @override
  String get questionExample => 'Z. B. An welchem Tag treffen wir uns?';

  @override
  String get questionMin3 => 'Die Frage muss mindestens 3 Zeichen lang sein.';

  @override
  String optionN(int n) {
    return 'Option $n';
  }

  @override
  String get removeOption => 'Option entfernen';

  @override
  String get optionRequired => 'Fülle die Option aus oder entferne sie.';

  @override
  String get addOption => 'Option hinzufügen';

  @override
  String get allowMultiple => 'Mehrfachauswahl erlauben';

  @override
  String get anonymousHint => 'Niemand sieht, wer wofür gestimmt hat.';

  @override
  String get noEndTime => 'Kein Ende';

  @override
  String get add => 'Hinzufügen';

  @override
  String get removeEndTime => 'Ende entfernen';

  @override
  String get startPoll => 'Umfrage starten';

  @override
  String get cardFooter => 'gway · finde deine Community';

  @override
  String myYear(int year) {
    return 'Mein $year';
  }

  @override
  String get statAttended => 'Events besucht';

  @override
  String get statHours => 'Stunden zusammen';

  @override
  String get statOneGroup => 'Gruppe getroffen';

  @override
  String get statGroups => 'verschiedene Gruppen getroffen';

  @override
  String get statProvinces => 'verschiedene Provinzen';

  @override
  String get statOrganized => 'Events organisiert';

  @override
  String get statWelcomed => 'Neulinge begrüßt';

  @override
  String get statMemories => 'Erinnerungen geteilt';

  @override
  String get favorites => 'Meine Favoriten';

  @override
  String get topGroup => 'Die Gruppe, mit der ich am meisten unterwegs war';

  @override
  String topGroupLine(String group, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Treffen',
      one: '1 Treffen',
    );
    return '$group · $_temp0';
  }

  @override
  String get iWasThere => 'Ich war dabei';

  @override
  String get firstWithGroup => 'Mein erstes Event mit dieser Gruppe.';

  @override
  String nthWithGroup(int n) {
    return 'Mein $n. Event mit dieser Gruppe.';
  }

  @override
  String get shareFailed =>
      'Teilen ist auf diesem Gerät nicht möglich. Mach einen Screenshot der Karte und teile ihn.';

  @override
  String get share => 'Teilen';

  @override
  String yearSummaryTitle(int year) {
    return 'Mein Jahresrückblick $year';
  }

  @override
  String get yearEmpty =>
      'Du warst dieses Jahr noch bei keinem Event. Nach deinem ersten Treffen erscheint hier deine Zusammenfassung.';

  @override
  String yearShareText(int year) {
    return 'Mein $year bei GWAY';
  }

  @override
  String mapSemantics(int count) {
    return 'Türkei-Karte: $count Provinzen entdeckt';
  }

  @override
  String get explorationMap => 'Meine Entdeckerkarte';

  @override
  String get statExplored => 'Provinzen entdeckt';

  @override
  String get statMetAt => 'Events getroffen';

  @override
  String get recentExplored => 'Zuletzt entdeckt';

  @override
  String get explorationEmpty =>
      'Hier leuchten die Provinzen deiner Events auf. Nach deinem ersten Treffen bekommt deine Karte Farbe.';

  @override
  String get findOnMap => 'Events auf der Karte finden';

  @override
  String explorationShareText(int count) {
    return 'Ich habe bei GWAY $count Provinzen entdeckt';
  }

  @override
  String get exploredProvinces => 'Entdeckte Provinzen';

  @override
  String get explorationPrivacy =>
      'Nur du siehst das. Es zählen Events, bei denen du warst und nicht als „nicht erschienen“ markiert wurdest.';

  @override
  String get tonightVisible =>
      'Leute aus gemeinsamen Gruppen sehen, dass du heute Abend Zeit hast. Um 4:00 Uhr schaltet es sich ab.';

  @override
  String get joinedTable => 'Du bist am Tisch dabei.';

  @override
  String get declinedInvite => 'Du hast die Einladung abgelehnt.';

  @override
  String get yourStatus => 'Dein Status';

  @override
  String get visibleUntil4 => 'Du bist bis 4:00 Uhr sichtbar';

  @override
  String get notVisible => 'Du bist gerade nicht sichtbar';

  @override
  String get youreFree => 'Du hast Zeit';

  @override
  String get tonightIntro =>
      'Wenn du Zeit hast, sollen es Leute aus gemeinsamen Gruppen sehen; ihr könnt zusammen einen kleinen Tisch bilden.';

  @override
  String get imFreeTonight => 'Ich habe heute Abend Zeit';

  @override
  String get noLongerFree => 'Du wirst nicht mehr als frei angezeigt.';

  @override
  String get turnOffStatus => 'Status beenden';

  @override
  String get leftTable => 'Du hast den Tisch verlassen.';

  @override
  String get smallTable => 'Kleiner Tisch';

  @override
  String get smallTableHint =>
      'Lade ein paar freie Leute ein; ab drei Personen öffnet sich der Tisch-Chat.';

  @override
  String get setUpTable => 'Kleinen Tisch bilden';

  @override
  String tableInvitesSent(int count) {
    return 'Einladungen an $count Personen gesendet. Ab drei Personen öffnet sich der Tisch-Chat.';
  }

  @override
  String needMorePeople(int min, int now) {
    return 'Für einen kleinen Tisch brauchen mindestens $min weitere Leute aus gemeinsamen Gruppen Zeit (gerade $now). Sobald jemand Zeit hat, kannst du hier einen bilden.';
  }

  @override
  String freeFromGroups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Personen aus deinen Gruppen haben heute Abend Zeit',
      one: '1 Person aus deinen Gruppen hat heute Abend Zeit',
    );
    return '$_temp0';
  }

  @override
  String get chipCoffee => 'Kaffee';

  @override
  String get chipWalk => 'Kurzer Spaziergang';

  @override
  String get chipFood => 'Essen';

  @override
  String get chipCinema => 'Kino';

  @override
  String get tonightSheetHint =>
      'Nur Leute aus gemeinsamen Gruppen sehen es. Dein Status endet um 4:00 Uhr von selbst.';

  @override
  String get whatToDo => 'Was möchtest du machen? (optional)';

  @override
  String get whatToDoHint => 'z. B. Kaffee, kurzer Spaziergang';

  @override
  String get imFree => 'Ich habe Zeit';

  @override
  String get yourTable => 'Dein Tisch';

  @override
  String joinedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dabei',
      one: '1 dabei',
    );
    return '$_temp0';
  }

  @override
  String waitingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ausstehend',
      one: '1 ausstehend',
    );
    return '$_temp0';
  }

  @override
  String get settingUp => 'Wird gebildet';

  @override
  String get chatOpen => 'Chat offen';

  @override
  String get tableChat => 'Tisch-Chat';

  @override
  String chatOpensWhen(int count) {
    return 'Der Chat öffnet sich, wenn $count weitere Personen dabei sind. Ort und Zeit wählt ihr dort zusammen.';
  }

  @override
  String get leaveTable => 'Tisch verlassen';

  @override
  String tableInviteTitle(String name) {
    return '$name hat einen kleinen Tisch gebildet und lädt dich ein.';
  }

  @override
  String tableInviteStatus(int joined, int pending) {
    return '$joined dabei · $pending ausstehend. Ab drei Personen öffnet sich der Chat.';
  }

  @override
  String get join => 'Mitmachen';

  @override
  String get notTonight => 'Heute nicht';

  @override
  String get tonight => 'Heute Abend';

  @override
  String get freeTonight => 'Heute Abend frei';

  @override
  String get sharedGroupsOnly => 'Nur Leute aus gemeinsamen Gruppen';

  @override
  String get nobodyFree => 'Gerade hat niemand aus deinen Gruppen Zeit.';

  @override
  String get howItWorks => 'Wie funktioniert das?';

  @override
  String get howStep1 =>
      'Sag „Ich habe heute Abend Zeit“ und schreib, was du machen möchtest.';

  @override
  String get howStep2 =>
      'Leute aus gemeinsamen Gruppen sehen dich, und du siehst, wer Zeit hat.';

  @override
  String get howStep3 =>
      'Bilde einen kleinen Tisch; ab drei Personen öffnet sich der Chat, dort wählt ihr Ort und Zeit.';

  @override
  String get upcoming => 'Demnächst';

  @override
  String get calendar => 'Kalender';

  @override
  String get noUpcomingJoined => 'Du nimmst an keinem anstehenden Event teil.';

  @override
  String get showAll => 'Alle zeigen';

  @override
  String get noUpcoming60 =>
      'Deine Gruppen haben in den nächsten 60 Tagen keine Events.';

  @override
  String get findGroup => 'Gruppe finden';

  @override
  String filterAll(int count) {
    return 'Alle · $count';
  }

  @override
  String filterMine(int count) {
    return 'Meine · $count';
  }

  @override
  String get tomorrow => 'Morgen';

  @override
  String get going => 'Du bist dabei';

  @override
  String get waitlisted => 'Auf der Warteliste';

  @override
  String get awaitingApproval => 'Wartet auf Bestätigung';

  @override
  String get full => 'Voll';

  @override
  String goingOfCapacityShort(int count, int capacity) {
    return '$count/$capacity Teilnehmende';
  }

  @override
  String get startingSoon => 'Beginnt bald';

  @override
  String get next6Hours => 'Nächste 6 Stunden';

  @override
  String get wantWelcome => 'Ich möchte begrüßt werden';

  @override
  String get wantWelcomeHint =>
      'Ein freiwilliges Mitglied der Gruppe empfängt dich am Eingang – du gehst nicht allein hin.';

  @override
  String get noteForGreeter => 'Eine Notiz, damit man dich erkennt (optional)';

  @override
  String get noteForGreeterHint => 'Z. B. Rote Jacke, blaue Tasche';

  @override
  String get sendRequest => 'Anfrage senden';

  @override
  String get welcomeRequestSent =>
      'Deine Anfrage ging an die Begrüßer:innen. Wir melden uns, sobald jemand übernimmt.';

  @override
  String get editMeetingNote => 'Treffpunkt-Notiz bearbeiten';

  @override
  String welcomePerson(String name) {
    return '$name begrüßen';
  }

  @override
  String describedAs(String note) {
    return 'Selbstbeschreibung: $note';
  }

  @override
  String get whereMeet => 'Wo trefft ihr euch?';

  @override
  String get whereMeetHint => 'Z. B. Vor dem Café am Eingang, 8:45';

  @override
  String get save => 'Speichern';

  @override
  String get iWillWelcome => 'Ich begrüße';

  @override
  String get noteUpdated => 'Treffpunkt-Notiz aktualisiert.';

  @override
  String youWillWelcome(String name) {
    return 'Du begrüßt $name; die Person hat die Notiz gesehen.';
  }

  @override
  String get stopWelcoming => 'Begrüßung abgeben';

  @override
  String stopWelcomingBody(String name) {
    return 'Für $name wird eine neue begrüßende Person gesucht, und sie wird informiert.';
  }

  @override
  String get release => 'Abgeben';

  @override
  String get releasedWelcome =>
      'Du hast die Begrüßung abgegeben; eine neue Person wird gesucht.';

  @override
  String get firstTime => 'Zum ersten Mal dabei?';

  @override
  String greetersAvailable(int count) {
    return 'Diese Gruppe hat $count Begrüßer:innen. Lass dich am Eingang empfangen und der Gruppe vorstellen.';
  }

  @override
  String get youWelcomed => 'Von dir begrüßt';

  @override
  String meetingAt(String note) {
    return 'Treffpunkt: $note';
  }

  @override
  String get thankedYou => 'Hat sich bedankt';

  @override
  String optionsFor(String name) {
    return 'Optionen für $name';
  }

  @override
  String waitingWelcome(int count) {
    return 'Warten auf Begrüßung ($count)';
  }

  @override
  String matchedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Personen haben eine Begrüßung.',
      one: '1 Person hat eine Begrüßung.',
    );
    return '$_temp0';
  }

  @override
  String get firstTimer => 'Zum ersten Mal';

  @override
  String get max3Welcomes => 'Pro Event kannst du bis zu 3 Personen begrüßen.';

  @override
  String get greeterJoinHint =>
      'Du bist Begrüßer:in. Nimm am Event teil, um Neulinge zu begrüßen.';

  @override
  String get lookingGreeter => 'Begrüßung wird gesucht';

  @override
  String get lookingGreeterHint =>
      'Wir haben die Begrüßer:innen informiert. Du bekommst eine Nachricht, sobald jemand übernimmt.';

  @override
  String yourNote(String note) {
    return 'Deine Notiz: $note';
  }

  @override
  String get welcomeWithdrawn => 'Deine Begrüßungsanfrage wurde zurückgezogen.';

  @override
  String get withdrawRequest => 'Anfrage zurückziehen';

  @override
  String get greetedBy => 'Begrüßt von';

  @override
  String get willGreet => 'Begrüßt dich';

  @override
  String get thank => 'Danke sagen';

  @override
  String thankReceived(String name) {
    return '$name hat deinen Dank erhalten.';
  }

  @override
  String get thanked => 'Du hast dich bedankt.';

  @override
  String get cancelWelcome => 'Begrüßung absagen';

  @override
  String get nowGreeter =>
      'Du bist jetzt Begrüßer:in. Wir melden uns, wenn ein Neuling begrüßt werden möchte.';

  @override
  String get noLongerGreeter => 'Du bist kein:e Begrüßer:in mehr.';

  @override
  String get welcomeSection => 'Begrüßung';

  @override
  String greetersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Begrüßer:innen',
      one: '1 Begrüßer:in',
    );
    return '$_temp0';
  }

  @override
  String get greeterIntro =>
      'Neulinge können auf der Event-Seite um eine Begrüßung bitten. Als Begrüßer:in wirst du benachrichtigt, empfängst sie am Eingang und stellst sie der Gruppe vor.';

  @override
  String greeterMemberHint(int count) {
    return 'Diese Gruppe hat $count Begrüßer:innen. Tippe bei deinem ersten Event auf „Ich möchte begrüßt werden“.';
  }

  @override
  String greeterVisitorHint(int count) {
    return 'Diese Gruppe hat $count Begrüßer:innen: Zu deinem ersten Event gehst du nicht allein, jemand empfängt dich am Eingang.';
  }

  @override
  String get becomeGreeter => 'Begrüßer:in werden';

  @override
  String quoted(String text) {
    return '„$text“';
  }

  @override
  String seatsGoing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Personen dabei',
      one: '1 Person dabei',
    );
    return '$_temp0';
  }

  @override
  String seatsOf(int count, int capacity) {
    return '$count / $capacity Personen';
  }

  @override
  String seatsOfWaiting(int count, int capacity, int waiting) {
    return '$count / $capacity Personen · $waiting warten';
  }

  @override
  String summaryAttended(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Personen waren dabei',
      one: '1 Person war dabei',
    );
    return '$_temp0';
  }

  @override
  String summaryRating(String avg, int count) {
    return '$avg ★ ($count Bewertungen)';
  }

  @override
  String waitlistPlace(int place) {
    return 'Warteliste · Platz $place';
  }

  @override
  String get eventCanceled => 'Dieses Event wurde abgesagt.';

  @override
  String eventCanceledBecause(String reason) {
    return 'Dieses Event wurde abgesagt: $reason';
  }

  @override
  String reviewBy(String name, int stars) {
    return '$name, $stars Sterne';
  }

  @override
  String get conflicting => 'Überschneidung';

  @override
  String get events => 'Events';

  @override
  String get create => 'Erstellen';

  @override
  String eventsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Noch $count Events diesen Monat.',
      one: 'Noch 1 Event diesen Monat.',
    );
    return '$_temp0';
  }

  @override
  String get eventsLimitReached =>
      'Das Event-Kontingent dieses Monats ist erschöpft. Mit einem größeren Paket bekommst du mehr.';

  @override
  String groupRating(String avg, int count) {
    return '$avg · $count Bewertungen der Events';
  }

  @override
  String get howWasIt => 'Wie war es?';

  @override
  String get howWasItHint =>
      'Bewerte das Event, an dem du teilgenommen hast; alle sehen nur den Durchschnitt.';

  @override
  String titleOnDate(String title, String date) {
    return '$title · $date';
  }

  @override
  String get eventsEmpty =>
      'Wanderung, Konzert oder Treffen: Erstelle das erste Event.';

  @override
  String get requestSent =>
      'Deine Anfrage wurde gesendet. Wir melden uns, sobald entschieden ist.';

  @override
  String get attendanceSaved =>
      'Du bist dabei. Wir erinnern dich vor dem Start.';

  @override
  String waitlistJoined(int place) {
    return 'Du stehst auf der Warteliste (Platz $place). Wir melden uns, wenn ein Platz frei wird.';
  }

  @override
  String get conflictTitle => 'Du hast zur gleichen Zeit ein anderes Event';

  @override
  String conflictLine(String title, String date) {
    return '• $title · $date';
  }

  @override
  String get conflictOne =>
      'Wenn du nicht hingehen kannst, sag ab und gib deinen Platz frei.';

  @override
  String get conflictMany =>
      'Wenn du nicht hingehen kannst, sag ab und gib deine Plätze frei.';

  @override
  String get keepBoth => 'Beide behalten';

  @override
  String get leaveOther => 'Das andere absagen';

  @override
  String get leaveOthers => 'Die anderen absagen';

  @override
  String get leftOther =>
      'Du hast das andere Event abgesagt; dein Platz ist frei.';

  @override
  String get leftOthers => 'Du hast die anderen Events abgesagt.';

  @override
  String approvedPerson(String name) {
    return '$name ist jetzt dabei.';
  }

  @override
  String declinedPerson(String name) {
    return 'Anfrage abgelehnt; $name wurde informiert.';
  }

  @override
  String get calendarFailed =>
      'Die Kalenderdatei konnte nicht geöffnet werden. Versuche es erneut.';

  @override
  String get stopSeriesTitle => 'Wiederholung beenden?';

  @override
  String get stopSeriesBody =>
      'Es werden keine neuen Termine geöffnet. Bestehende bleiben; du kannst sie einzeln absagen.';

  @override
  String get stop => 'Beenden';

  @override
  String get seriesStopped => 'Wiederholung beendet.';

  @override
  String get eventCanceledToast => 'Event abgesagt.';

  @override
  String get eventNotFound =>
      'Dieses Event wurde nicht gefunden oder ist nicht mehr sichtbar.';

  @override
  String get goBack => 'Zurück';

  @override
  String joinGroupFirst(String name) {
    return '$name beitreten';
  }

  @override
  String get sendJoinRequest => 'Teilnahme anfragen';

  @override
  String get joinWaitlist => 'Auf die Warteliste';

  @override
  String get leaveEvent => 'Absagen';

  @override
  String get leaveWaitlist => 'Warteliste verlassen';

  @override
  String get requestWithdrawn => 'Deine Anfrage wurde zurückgezogen.';

  @override
  String get attendanceRemoved => 'Du bist nicht mehr dabei.';

  @override
  String eventShareText(String title) {
    return '$title · bei GWAY mitmachen:';
  }

  @override
  String get eventLinkCopied => 'Eventlink kopiert.';

  @override
  String get report => 'Melden';

  @override
  String get eventOptions => 'Event-Optionen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get cancelThisDate => 'Diesen Termin absagen';

  @override
  String get stopRepeat => 'Wiederholung beenden';

  @override
  String get startedOrEnded => 'Begonnen oder beendet';

  @override
  String seriesUntil(String label, String date) {
    return '$label · bis $date';
  }

  @override
  String get addToCalendar => 'Zum Kalender hinzufügen';

  @override
  String fee(String fee) {
    return 'Teilnahmegebühr: $fee';
  }

  @override
  String get feeNotice =>
      'Die Gebühr wird an die Organisatoren gezahlt; GWAY nimmt keine Zahlungen an.';

  @override
  String get areYouComing => 'Kommst du?';

  @override
  String get areYouComingHint =>
      'Wenn du nicht kommen kannst, gib deinen Platz für die Warteliste frei.';

  @override
  String get yesComing => 'Ja, ich komme';

  @override
  String get confirmThanks =>
      'Danke, wir haben den Organisatoren gesagt, dass du kommst.';

  @override
  String get cantCome => 'Ich kann nicht';

  @override
  String get spotFreed => 'Du bist abgemeldet; dein Platz ist frei.';

  @override
  String get confirmedComing => 'Du hast bestätigt, dass du kommst.';

  @override
  String get otherEventSameTime => 'Zu dieser Zeit hast du ein anderes Event';

  @override
  String get needsApproval => 'Teilnahme nur mit Bestätigung';

  @override
  String get requirements => 'Voraussetzungen';

  @override
  String get equipment => 'Benötigte Ausrüstung';

  @override
  String joinRequestsCount(int count) {
    return 'Teilnahmeanfragen ($count)';
  }

  @override
  String get attendees => 'Teilnehmende';

  @override
  String confirmedOf(int going, int confirmed) {
    return '$confirmed von $going Teilnehmenden haben zugesagt.';
  }

  @override
  String confirmedName(String name) {
    return '$name · zugesagt';
  }

  @override
  String get shareWasThere => 'Die Karte „Ich war dabei“ teilen';

  @override
  String get howDidItGo => 'Wie war es?';

  @override
  String reviewsCount(int count) {
    return 'Bewertungen ($count)';
  }

  @override
  String get reviewNotesPrivate => 'Nur die Organisatoren sehen die Notizen.';

  @override
  String get attendanceCheck => 'Anwesenheit';

  @override
  String get attendanceCheckHint =>
      'Markiere, wer nicht kam; nur Anwesende zählen für Beiträge und Abzeichen. 7 Tage nach Ende offen.';

  @override
  String markedCame(String name) {
    return '$name als anwesend markiert.';
  }

  @override
  String markedMissed(String name) {
    return '$name als nicht erschienen markiert.';
  }

  @override
  String get didntCome => 'Nicht erschienen';

  @override
  String get came => 'Anwesend';

  @override
  String get memories => 'Erinnerungen';

  @override
  String get shareMemory => 'Erinnerung teilen';

  @override
  String get eventPolls => 'Event-Umfragen';

  @override
  String get noEditPermission => 'Du darfst dieses Event nicht bearbeiten.';

  @override
  String get editEvent => 'Event bearbeiten';

  @override
  String get newEvent => 'Neues Event';

  @override
  String get addCover => 'Titelbild hinzufügen';

  @override
  String get titleExample => 'Z. B. Waldwanderung';

  @override
  String get starts => 'Beginn';

  @override
  String get endsOptional => 'Ende (optional)';

  @override
  String get notSpecified => 'Keine Angabe';

  @override
  String get removeEnd => 'Ende entfernen';

  @override
  String get repeat => 'Wiederholen';

  @override
  String get noRepeat => 'Keine Wiederholung';

  @override
  String get weekly => 'Jede Woche';

  @override
  String get biweekly => 'Alle zwei Wochen';

  @override
  String get lastDateOptional => 'Letzter Termin (optional)';

  @override
  String get untilYouStop => 'Bis du es beendest';

  @override
  String get removeLastDate => 'Letzten Termin entfernen';

  @override
  String get repeatHint =>
      'Weitere Termine öffnen sich automatisch 4 Wochen vorher und zählen jeweils zum Monatskontingent.';

  @override
  String get surpriseVenue => 'Überraschungsort';

  @override
  String get surpriseHint =>
      'Der Ort wird nur Teilnehmenden zu der von dir gewählten Zeit vor Beginn verraten.';

  @override
  String get hintPublic => 'Hinweis (für alle sichtbar)';

  @override
  String get place => 'Ort';

  @override
  String get hintExample => 'Z. B. Am Meer, auf der asiatischen Seite';

  @override
  String get placeExample => 'Z. B. Parkeingang oder Online';

  @override
  String get writeHint => 'Schreib einen Hinweis.';

  @override
  String get writePlace => 'Gib den Ort ein.';

  @override
  String get realVenue => 'Echter Ort (nur für Teilnehmende)';

  @override
  String get realVenueExample => 'Z. B. Vor dem Theater';

  @override
  String get writeRealVenue => 'Gib den echten Ort ein.';

  @override
  String get whenReveal => 'Wann soll er verraten werden?';

  @override
  String hoursBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Stunden vorher',
      one: '1 Stunde vorher',
    );
    return '$_temp0';
  }

  @override
  String get linkOptional => 'Karten- oder Online-Link (optional)';

  @override
  String get httpsRequired => 'Der Link muss mit https:// beginnen.';

  @override
  String get description => 'Beschreibung';

  @override
  String get capacity => 'Kapazität (leer = unbegrenzt)';

  @override
  String get capacityHint => 'Wenn voll, kommen Neue auf die Warteliste.';

  @override
  String get capacityRange => 'Die Kapazität muss 1–10.000 sein.';

  @override
  String get requirementsOptional => 'Voraussetzungen (optional)';

  @override
  String get requirementsExample => 'Z. B. Mindestens 10 km Wandererfahrung';

  @override
  String get equipmentOptional => 'Benötigte Ausrüstung (optional)';

  @override
  String get equipmentExample => 'Z. B. Helm, Wasser, Regenjacke';

  @override
  String get equipmentHint => 'Durch Kommas trennen; bis zu 10 Einträge.';

  @override
  String get equipmentLimit => 'Bis zu 10 Einträge, je höchstens 60 Zeichen.';

  @override
  String get approvalRequired => 'Teilnahme nur mit Bestätigung';

  @override
  String get approvalHint =>
      'Interessierte senden eine Anfrage; du bestätigst.';

  @override
  String get feeOptional => 'Teilnahmegebühr (optional)';

  @override
  String get feeInfoOnly =>
      'Nur zur Information; GWAY nimmt keine Zahlungen an.';

  @override
  String get amount => 'Betrag';

  @override
  String get amountExample => 'Z. B. 150';

  @override
  String get validAmount => 'Gib einen gültigen Betrag ein.';

  @override
  String get paymentNote => 'Zahlungshinweis';

  @override
  String get paymentNoteExample => 'Z. B. Barzahlung vor Ort';

  @override
  String get createEvent => 'Event erstellen';

  @override
  String get rateEvent => 'Event bewerten';

  @override
  String get yourReview => 'Deine Bewertung';

  @override
  String starsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Sterne',
      one: '1 Stern',
    );
    return '$_temp0';
  }

  @override
  String get noteToOrganizers => 'Notiz an die Organisatoren (optional)';

  @override
  String get noteToOrganizersHint =>
      'Nur die Organisatoren sehen deine Notiz; alle anderen nur den Durchschnitt.';

  @override
  String get reviewDeleted => 'Deine Bewertung wurde gelöscht.';

  @override
  String get delete => 'Löschen';

  @override
  String get reviewSaved => 'Danke, deine Bewertung wurde gespeichert.';

  @override
  String get groupNext => 'Nächste Events der Gruppe';

  @override
  String sameDayOthers(int count) {
    return 'An diesem Tag gibt es in deiner Provinz $count weitere Events derselben Kategorie. Wähle einen anderen Tag, wenn deine Mitglieder nicht wählen müssen sollen.';
  }

  @override
  String get cancelEvent => 'Event absagen';

  @override
  String get cancelEventBody =>
      'Teilnehmende und Warteliste werden benachrichtigt. Das kann nicht rückgängig gemacht werden.';

  @override
  String get reason => 'Grund';

  @override
  String get cancelAction => 'Absagen';

  @override
  String hint(String hint) {
    return 'Hinweis: $hint';
  }

  @override
  String hintRevealAt(String hint, String when) {
    return 'Hinweis: $hint · Wird Teilnehmenden am $when verraten.';
  }

  @override
  String get venueRevealed =>
      'Der Ort wurde den Teilnehmenden verraten. Nimm teil, um ihn zu sehen.';

  @override
  String venueRevealAt(String when) {
    return 'Der Ort wird den Teilnehmenden am $when verraten.';
  }

  @override
  String get currencyTry => '₺ TRY';
}
