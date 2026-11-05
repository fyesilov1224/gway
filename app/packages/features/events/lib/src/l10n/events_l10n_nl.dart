// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'events_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class EventsL10nNl extends EventsL10n {
  EventsL10nNl([String locale = 'nl']) : super(locale);

  @override
  String get pollSingle => 'In deze peiling kun je maar één optie kiezen.';

  @override
  String get pollOptionGone =>
      'Deze optie bestaat niet meer. Vernieuw de pagina.';

  @override
  String get reviewWindow =>
      'Deelnemers kunnen het evenement tot 30 dagen na afloop beoordelen.';

  @override
  String get greeterNeedsAttendance =>
      'Om gastheer te zijn, moet je aan een evenement van de groep hebben deelgenomen.';

  @override
  String get note80 => 'De notitie mag maximaal 80 tekens hebben.';

  @override
  String get pollClosed => 'Deze peiling is gesloten of je kunt niet stemmen.';

  @override
  String get cover5mb => 'De omslagafbeelding mag maximaal 5 MB zijn.';

  @override
  String get imagesOnly =>
      'Alleen JPEG-, PNG- of WebP-afbeeldingen kunnen worden geüpload.';

  @override
  String get claimNotAllowed =>
      'Je kunt deze taak nu niet melden: hij is afgelopen of je zit niet in de groep.';

  @override
  String get claimApprovedLocked =>
      'Een goedgekeurde melding kan niet worden ingetrokken.';

  @override
  String get claimDuplicate => 'Je hebt deze taak al gemeld.';

  @override
  String get repeatsWeekly => 'Herhaalt elke week';

  @override
  String get repeatsBiweekly => 'Herhaalt om de week';

  @override
  String surprisePlace(String place) {
    return 'Verrassingslocatie · $place';
  }

  @override
  String get goalPersonal => 'Persoonlijk doel';

  @override
  String get goalPersonalHint => 'Elk lid haalt zijn eigen aantal.';

  @override
  String get goalGroup => 'Groepsdoel';

  @override
  String get goalGroupHint => 'Ieders bijdrage telt op in één teller.';

  @override
  String get goalTeam => 'Teamdoel';

  @override
  String get goalTeamHint =>
      'Beheerders stellen teams samen; elk team heeft een gedeelde teller.';

  @override
  String get goalTask => 'Goedgekeurde taak';

  @override
  String get goalTaskHint =>
      'Een lid meldt ‘Gedaan’ en een beheerder keurt goed.';

  @override
  String unitAttended(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'deelnames',
      one: 'deelname',
    );
    return '$_temp0';
  }

  @override
  String unitOrganized(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'georganiseerde evenementen',
      one: 'georganiseerd evenement',
    );
    return '$_temp0';
  }

  @override
  String unitMemories(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'herinneringen',
      one: 'herinnering',
    );
    return '$_temp0';
  }

  @override
  String get claimPending => 'Wacht op goedkeuring';

  @override
  String get claimApproved => 'Goedgekeurd';

  @override
  String get claimRejected => 'Niet goedgekeurd';

  @override
  String get notClaimedYet => 'Nog niet gemeld';

  @override
  String get whenAny => 'Altijd';

  @override
  String get whenToday => 'Vandaag';

  @override
  String get whenWeek => 'Binnen 7 dagen';

  @override
  String get viewDay => 'Dag';

  @override
  String get viewWeek => 'Week';

  @override
  String get viewMonth => 'Maand';

  @override
  String countAttended(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count deelnames',
      one: '1 deelname',
    );
    return '$_temp0';
  }

  @override
  String countOrganized(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count evenementen georganiseerd',
      one: '1 evenement georganiseerd',
    );
    return '$_temp0';
  }

  @override
  String countMemories(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count herinneringen',
      one: '1 herinnering',
    );
    return '$_temp0';
  }

  @override
  String countReviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count beoordelingen',
      one: '1 beoordeling',
    );
    return '$_temp0';
  }

  @override
  String countWelcomed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nieuwkomers verwelkomd',
      one: '1 nieuwkomer verwelkomd',
    );
    return '$_temp0';
  }

  @override
  String countHandshakes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count handdrukken',
      one: '1 handdruk',
    );
    return '$_temp0';
  }

  @override
  String countHeld(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count evenementen',
      one: '1 evenement',
    );
    return '$_temp0';
  }

  @override
  String countGoodReviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count goede beoordelingen',
      one: '1 goede beoordeling',
    );
    return '$_temp0';
  }

  @override
  String leagueStanding(String month, int groups, int rank, int points) {
    return '$month: plaats $rank van $groups groepen, $points punten.';
  }

  @override
  String goingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count deelnemers',
      one: '1 deelnemer',
    );
    return '$_temp0';
  }

  @override
  String goingOfCapacity(int count, int capacity) {
    return '$count / $capacity deelnemers';
  }

  @override
  String firstEventOfYear(String title) {
    return 'Eerste evenement van het jaar: $title';
  }

  @override
  String firstEventOfYearOn(String title, String date) {
    return 'Eerste evenement van het jaar: $title · $date';
  }

  @override
  String get myCalendar => 'Mijn agenda';

  @override
  String get groupCalendar => 'Groepsagenda';

  @override
  String get previous => 'Vorige';

  @override
  String get next => 'Volgende';

  @override
  String get today => 'Vandaag';

  @override
  String get groupsEvents => 'Evenementen van mijn groepen';

  @override
  String get showNotJoined => 'Ook evenementen tonen waar je niet aan meedoet';

  @override
  String get noJoinedInRange =>
      'Je doet op deze data aan geen evenement mee. Bekijk ook de evenementen van je groepen.';

  @override
  String get noEventsInRange => 'Geen evenementen op deze data.';

  @override
  String get showGroupsEvents => 'Evenementen van mijn groepen tonen';

  @override
  String get backToToday => 'Terug naar vandaag';

  @override
  String get noEventsDay => 'Geen evenementen op deze dag.';

  @override
  String get contributions => 'Bijdrage aan de community';

  @override
  String get howBadges => 'Hoe verdien je badges?';

  @override
  String get badgesEmpty =>
      'Als je aan een evenement deelneemt, verschijnen hier je bijdrage en eerste badge.';

  @override
  String get badgesRules =>
      'Badges komen alleen uit wat je echt doet: evenementen die je bijwoont en organiseert, gedeelde herinneringen en beoordelingen. Likes en volgers tellen niet. Deelnames die de organisator als ‘niet gekomen’ markeert, tellen niet. Niemand wordt gerangschikt.';

  @override
  String get categoryFan => 'Categoriefan';

  @override
  String get pastEvents => 'Eerdere evenementen';

  @override
  String get noPastEvents => 'Deze groep heeft nog geen eerdere evenementen.';

  @override
  String get refresh => 'Vernieuwen';

  @override
  String get canceled => 'Geannuleerd';

  @override
  String get olderEvents => 'Oudere evenementen';

  @override
  String get completed => 'Voltooid';

  @override
  String get ended => 'Afgelopen';

  @override
  String teamName(String name) {
    return 'Team: $name';
  }

  @override
  String get teamNotice =>
      'Zodra je aan een team bent toegevoegd, zie je hier je voortgang.';

  @override
  String get goals => 'Doelen';

  @override
  String get createGoal => 'Doel maken';

  @override
  String get goalsEmpty =>
      'Bijvoorbeeld ‘Deze maand 4 wandelingen’ of ‘Samen 50 deelnames’: maak het eerste doel.';

  @override
  String get claimSent => 'Je melding is naar de beheerder gestuurd.';

  @override
  String get goal => 'Doel';

  @override
  String get goalCountsRule =>
      'Alleen evenementen van deze groep binnen de periode tellen; deelnames gemarkeerd als ‘niet gekomen’ tellen niet.';

  @override
  String get withdrawClaim => 'Melding intrekken';

  @override
  String get claimWithdrawn => 'Je melding is ingetrokken.';

  @override
  String get done => 'Gedaan';

  @override
  String get teams => 'Teams';

  @override
  String get createTeam => 'Team maken';

  @override
  String get noTeams => 'Nog geen teams.';

  @override
  String deleteTeam(String name) {
    return 'Team $name verwijderen';
  }

  @override
  String get teamDeleted => 'Team verwijderd.';

  @override
  String pendingClaims(int count) {
    return 'Meldingen in afwachting ($count)';
  }

  @override
  String get claimRejectedToast => 'Melding niet goedgekeurd.';

  @override
  String get decline => 'Weigeren';

  @override
  String get approve => 'Goedkeuren';

  @override
  String taskDone(String name) {
    return '$name heeft de taak voltooid.';
  }

  @override
  String completions(int count) {
    return 'Voltooid door ($count)';
  }

  @override
  String get noCompletions =>
      'Nog niemand heeft het gehaald. Wie het haalt, krijgt de badge van dit doel op zijn profiel.';

  @override
  String get goalCanceled => 'Doel geannuleerd.';

  @override
  String get cancelGoal => 'Doel annuleren';

  @override
  String teamCreated(String name) {
    return 'Team ‘$name’ gemaakt.';
  }

  @override
  String get teamNameLabel => 'Teamnaam';

  @override
  String get createTheTeam => 'Team maken';

  @override
  String createTeamWith(int count) {
    return 'Team maken ($count mensen)';
  }

  @override
  String get goalCreated => 'Doel gemaakt.';

  @override
  String get title => 'Titel';

  @override
  String get goalTitleExample => 'Bijv. Oktoberwandelingen';

  @override
  String get taskTitleExample => 'Bijv. Een nieuw lid de route uitleggen';

  @override
  String get titleMin3 => 'De titel moet minstens 3 tekens hebben.';

  @override
  String get descriptionOptional => 'Beschrijving (optioneel)';

  @override
  String get targetNumber => 'Doelaantal';

  @override
  String get target1to1000 => 'Voer een getal van 1 tot 1000 in.';

  @override
  String get period => 'Periode';

  @override
  String periodRange(String from, String to) {
    return '$from – $to (maximaal 92 dagen)';
  }

  @override
  String get createTheGoal => 'Doel maken';

  @override
  String get iDidTask => 'Ik heb de taak gedaan';

  @override
  String get whatDidYouDo => 'Wat heb je gedaan? (optioneel)';

  @override
  String get whatDidYouDoHint =>
      'De beheerder keurt goed na het lezen van deze notitie.';

  @override
  String get cancel => 'Annuleren';

  @override
  String get send => 'Versturen';

  @override
  String get handshake => 'Handdruk';

  @override
  String get handshakeHint =>
      'Scan elkaars codes; jullie komen allebei in ‘Mensen die ik ontmoette’.';

  @override
  String get open => 'Openen';

  @override
  String handshakeAt(String title) {
    return 'Handdruk · $title';
  }

  @override
  String get myCode => 'Mijn code';

  @override
  String get scan => 'Scannen';

  @override
  String get yourHandshakeCode => 'Je handdrukcode';

  @override
  String get codeHint =>
      'Laat de ander deze code scannen via ‘Scannen’ of intypen. De code verandert om de paar minuten; een foto werkt later niet.';

  @override
  String get cameraFailed =>
      'De camera kon niet openen. Sta cameratoegang toe in de instellingen of typ de code hieronder.';

  @override
  String get scanHint =>
      'Richt de camera op de QR-code van de ander of typ de code.';

  @override
  String get typeCodeHint =>
      'Typ de 6-cijferige code op het scherm van de ander.';

  @override
  String get code => 'Code';

  @override
  String get alreadyMet => 'Jullie kennen elkaar al';

  @override
  String get metNow => 'Jullie hebben elkaar ontmoet!';

  @override
  String personWithUsername(String name, String username) {
    return '$name (@$username)';
  }

  @override
  String get ok => 'Oké';

  @override
  String get metPeople => 'Mensen die ik ontmoette';

  @override
  String get metEmpty =>
      'Als je bij een evenement iemand de hand schudt, verschijnt diegene hier. Handdrukken open je op de evenementpagina.';

  @override
  String get goToCalendar => 'Naar mijn agenda';

  @override
  String get metPrivacy =>
      'Alleen jij ziet dit. Op je profiel staat alleen je aantal handdrukken.';

  @override
  String metRow(String username, String event, String date) {
    return '@$username · $event · $date';
  }

  @override
  String get howPoints => 'Hoe worden punten berekend?';

  @override
  String get leagueIntro =>
      'Groepen van dezelfde categorie in dezelfde provincie strijden elke maand. Evenementen die die maand eindigden, tellen.';

  @override
  String get ruleAttendance => 'Deelname: 1 punt';

  @override
  String get ruleAttendanceHint =>
      'Elke persoon die komt; maximaal 30 per evenement.';

  @override
  String get ruleHeld => 'Evenement: 5 punten';

  @override
  String get ruleHeldHint =>
      'Elk evenement waar naast de organisator minstens 3 mensen kwamen.';

  @override
  String get ruleWelcome => 'Verwelkoming: 3 punten';

  @override
  String get ruleWelcomeHint => 'Iemand verwelkomen die voor het eerst komt.';

  @override
  String get ruleReview => 'Goede beoordeling: 1 punt';

  @override
  String get ruleReviewHint => 'Elke beoordeling met 4 of 5 sterren.';

  @override
  String get leagueRulesNote =>
      'Mensen gemarkeerd als ‘niet gekomen’ tellen niet. Uitslagen zijn 8 dagen na het einde van de maand definitief; leden van de top 3 krijgen bericht.';

  @override
  String get groupsLeague => 'Groepencompetitie';

  @override
  String get category => 'Categorie';

  @override
  String get province => 'Provincie';

  @override
  String get month => 'Maand';

  @override
  String seasonClosed(String month) {
    return 'Het seizoen $month is voorbij; de stand is definitief.';
  }

  @override
  String get seasonRunning =>
      'Het seizoen loopt. Punten worden bijgewerkt als evenementen eindigen; uitslagen zijn 8 dagen na het einde van de maand definitief.';

  @override
  String leagueEmpty(String province) {
    return 'Nog geen groep in de competitie $province heeft deze maand punten.';
  }

  @override
  String points(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count punten',
      one: '1 punt',
    );
    return '$_temp0';
  }

  @override
  String rank(int rank) {
    return '$rank.';
  }

  @override
  String leagueName(String province, String category) {
    return '$province · Competitie $category';
  }

  @override
  String get noPointsYet =>
      'Nog geen punten deze maand. Afgeronde evenementen, deelnames en verwelkomingen leveren punten op.';

  @override
  String get mapAttribution =>
      '© Stadia Maps © OpenMapTiles © OpenStreetMap-bijdragers';

  @override
  String get map => 'Kaart';

  @override
  String get mapView => 'Kaartweergave';

  @override
  String get listView => 'Lijstweergave';

  @override
  String get all => 'Alle';

  @override
  String get wholeArea => 'Hele gebied';

  @override
  String km(int km) {
    return '$km km';
  }

  @override
  String get mapLoadFailed => 'De kaartgegevens konden niet worden geladen.';

  @override
  String get retry => 'Opnieuw proberen';

  @override
  String get noFilterResults => 'Niets gevonden met deze filters.';

  @override
  String get clearFilters => 'Filters wissen';

  @override
  String get noNearby => 'Geen komende evenementen of groepen in dit gebied.';

  @override
  String get zoomOut => 'Uitzoomen';

  @override
  String get openEvent => 'Evenement openen';

  @override
  String memberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count leden',
      one: '1 lid',
    );
    return '$_temp0';
  }

  @override
  String get noVisible =>
      'Geen komende evenementen of groepen in het zichtbare gebied.';

  @override
  String get backToMap => 'Terug naar kaart';

  @override
  String upcomingCount(int count) {
    return 'Komende evenementen ($count)';
  }

  @override
  String get directions => 'Routebeschrijving';

  @override
  String get meetingPointOptional => 'Verzamelpunt (optioneel)';

  @override
  String get meetingPointHint =>
      'Kies hem op de kaart; het evenement verschijnt dan op de kaart.';

  @override
  String pointPicked(String lat, String lng) {
    return 'Geselecteerd · $lat, $lng';
  }

  @override
  String get removeMeetingPoint => 'Verzamelpunt verwijderen';

  @override
  String get meetingPoint => 'Verzamelpunt';

  @override
  String get pickHint => 'Zoom in en tik op het verzamelpunt.';

  @override
  String get pickAgainHint => 'Tik ergens anders om het punt te verplaatsen.';

  @override
  String get pickThisPoint => 'Dit punt kiezen';

  @override
  String get mapUnavailable => 'De kaart is nu niet beschikbaar.';
}
