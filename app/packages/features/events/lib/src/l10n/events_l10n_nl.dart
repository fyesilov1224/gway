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

  @override
  String get pollClosedShort => 'Gesloten';

  @override
  String closesAt(String date) {
    return 'Sluit: $date';
  }

  @override
  String get multipleAllowed => 'Meerdere keuzes';

  @override
  String get anonymousVote => 'Anonieme stemming';

  @override
  String votersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stemmen',
      one: '1 stem',
    );
    return '$_temp0';
  }

  @override
  String get pollOptions => 'Peilingopties';

  @override
  String get pollClosedToast => 'Peiling gesloten.';

  @override
  String get pollDeleted => 'Peiling verwijderd.';

  @override
  String get closePoll => 'Peiling sluiten';

  @override
  String get deletePoll => 'Peiling verwijderen';

  @override
  String get vote => 'Stemmen';

  @override
  String get voteSaved => 'Je stem is opgeslagen.';

  @override
  String get voters => 'Stemmers';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensen',
      one: '1 persoon',
    );
    return '$_temp0';
  }

  @override
  String get polls => 'Peilingen';

  @override
  String get openPoll => 'Peiling starten';

  @override
  String get pollsEmpty =>
      'Stel de leden een vraag, bijvoorbeeld op welke dag jullie afspreken?';

  @override
  String get pollOpened => 'Peiling gestart.';

  @override
  String get question => 'Vraag';

  @override
  String get questionExample => 'Bijv. Op welke dag spreken we af?';

  @override
  String get questionMin3 => 'De vraag moet minstens 3 tekens hebben.';

  @override
  String optionN(int n) {
    return 'Optie $n';
  }

  @override
  String get removeOption => 'Optie verwijderen';

  @override
  String get optionRequired => 'Vul de optie in of verwijder hem.';

  @override
  String get addOption => 'Optie toevoegen';

  @override
  String get allowMultiple => 'Meerdere keuzes toestaan';

  @override
  String get anonymousHint => 'Niemand ziet wie waarop heeft gestemd.';

  @override
  String get noEndTime => 'Geen eindtijd';

  @override
  String get add => 'Toevoegen';

  @override
  String get removeEndTime => 'Eindtijd verwijderen';

  @override
  String get startPoll => 'Peiling starten';

  @override
  String get cardFooter => 'gway · vind je community';

  @override
  String myYear(int year) {
    return 'Mijn $year';
  }

  @override
  String get statAttended => 'evenementen bijgewoond';

  @override
  String get statHours => 'uur samen';

  @override
  String get statOneGroup => 'groep ontmoet';

  @override
  String get statGroups => 'verschillende groepen ontmoet';

  @override
  String get statProvinces => 'verschillende provincies';

  @override
  String get statOrganized => 'evenementen georganiseerd';

  @override
  String get statWelcomed => 'nieuwkomers verwelkomd';

  @override
  String get statMemories => 'herinneringen gedeeld';

  @override
  String get favorites => 'Mijn favorieten';

  @override
  String get topGroup => 'De groep waarmee ik het vaakst was';

  @override
  String topGroupLine(String group, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meetups',
      one: '1 meetup',
    );
    return '$group · $_temp0';
  }

  @override
  String get iWasThere => 'Ik was erbij';

  @override
  String get firstWithGroup => 'Mijn eerste evenement met deze groep.';

  @override
  String nthWithGroup(int n) {
    return 'Mijn ${n}e evenement met deze groep.';
  }

  @override
  String get shareFailed =>
      'Delen lukt niet op dit apparaat. Maak een screenshot van de kaart en deel die.';

  @override
  String get share => 'Delen';

  @override
  String yearSummaryTitle(int year) {
    return 'Mijn $year in beeld';
  }

  @override
  String get yearEmpty =>
      'Je hebt dit jaar nog geen evenement bijgewoond. Na je eerste meetup verschijnt hier je overzicht.';

  @override
  String yearShareText(int year) {
    return 'Mijn $year op GWAY';
  }

  @override
  String mapSemantics(int count) {
    return 'Kaart van Turkije: $count provincies ontdekt';
  }

  @override
  String get explorationMap => 'Mijn ontdekkingskaart';

  @override
  String get statExplored => 'provincies ontdekt';

  @override
  String get statMetAt => 'evenementen ontmoet';

  @override
  String get recentExplored => 'Recent ontdekt';

  @override
  String get explorationEmpty =>
      'De provincies van je evenementen lichten hier op. Na je eerste meetup krijgt je kaart kleur.';

  @override
  String get findOnMap => 'Evenementen op de kaart vinden';

  @override
  String explorationShareText(int count) {
    return 'Ik ontdekte $count provincies op GWAY';
  }

  @override
  String get exploredProvinces => 'Ontdekte provincies';

  @override
  String get explorationPrivacy =>
      'Alleen jij ziet dit. Evenementen die je bijwoonde en waar je niet als ‘niet gekomen’ staat, tellen.';

  @override
  String get tonightVisible =>
      'Mensen uit je gedeelde groepen zien dat je vanavond tijd hebt. Om 4:00 uur gaat het vanzelf uit.';

  @override
  String get joinedTable => 'Je zit aan tafel.';

  @override
  String get declinedInvite => 'Je hebt de uitnodiging afgeslagen.';

  @override
  String get yourStatus => 'Je status';

  @override
  String get visibleUntil4 => 'Je bent zichtbaar tot 4:00 uur';

  @override
  String get notVisible => 'Je bent nu niet zichtbaar';

  @override
  String get youreFree => 'Je hebt tijd';

  @override
  String get tonightIntro =>
      'Heb je tijd, laat het je gedeelde groepen weten; samen kunnen jullie een kleine tafel opzetten.';

  @override
  String get imFreeTonight => 'Ik heb vanavond tijd';

  @override
  String get noLongerFree => 'Je wordt niet meer als vrij getoond.';

  @override
  String get turnOffStatus => 'Status uitzetten';

  @override
  String get leftTable => 'Je hebt de tafel verlaten.';

  @override
  String get smallTable => 'Kleine tafel';

  @override
  String get smallTableHint =>
      'Nodig een paar vrije mensen uit; bij drie mensen opent de tafelchat.';

  @override
  String get setUpTable => 'Kleine tafel opzetten';

  @override
  String tableInvitesSent(int count) {
    return 'Uitnodigingen naar $count mensen gestuurd. Bij drie mensen opent de tafelchat.';
  }

  @override
  String needMorePeople(int min, int now) {
    return 'Voor een kleine tafel moeten nog minstens $min mensen uit je gedeelde groepen tijd hebben (nu $now). Zodra iemand tijd heeft, kun je er hier een opzetten.';
  }

  @override
  String freeFromGroups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensen uit je groepen hebben vanavond tijd',
      one: '1 persoon uit je groepen heeft vanavond tijd',
    );
    return '$_temp0';
  }

  @override
  String get chipCoffee => 'Koffie';

  @override
  String get chipWalk => 'Korte wandeling';

  @override
  String get chipFood => 'Eten';

  @override
  String get chipCinema => 'Bioscoop';

  @override
  String get tonightSheetHint =>
      'Alleen mensen uit je gedeelde groepen zien het. Je status gaat om 4:00 uur vanzelf uit.';

  @override
  String get whatToDo => 'Wat wil je doen? (optioneel)';

  @override
  String get whatToDoHint => 'bijv. koffie, korte wandeling';

  @override
  String get imFree => 'Ik heb tijd';

  @override
  String get yourTable => 'Je tafel';

  @override
  String joinedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count doen mee',
      one: '1 doet mee',
    );
    return '$_temp0';
  }

  @override
  String waitingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count in afwachting',
      one: '1 in afwachting',
    );
    return '$_temp0';
  }

  @override
  String get settingUp => 'Wordt opgezet';

  @override
  String get chatOpen => 'Chat open';

  @override
  String get tableChat => 'Tafelchat';

  @override
  String chatOpensWhen(int count) {
    return 'De chat opent als er nog $count mensen meedoen. Plaats en tijd kiezen jullie daar samen.';
  }

  @override
  String get leaveTable => 'Tafel verlaten';

  @override
  String tableInviteTitle(String name) {
    return '$name heeft een kleine tafel opgezet en nodigt je uit.';
  }

  @override
  String tableInviteStatus(int joined, int pending) {
    return '$joined doen mee · $pending in afwachting. Bij drie mensen opent de chat.';
  }

  @override
  String get join => 'Meedoen';

  @override
  String get notTonight => 'Vanavond niet';

  @override
  String get tonight => 'Vanavond';

  @override
  String get freeTonight => 'Vanavond vrij';

  @override
  String get sharedGroupsOnly => 'Alleen mensen uit je gedeelde groepen';

  @override
  String get nobodyFree => 'Er heeft nu niemand uit je groepen tijd.';

  @override
  String get howItWorks => 'Hoe werkt het?';

  @override
  String get howStep1 =>
      'Zeg ‘Ik heb vanavond tijd’ en schrijf wat je wilt doen.';

  @override
  String get howStep2 =>
      'Mensen uit je gedeelde groepen zien jou, en jij ziet wie tijd heeft.';

  @override
  String get howStep3 =>
      'Zet een kleine tafel op; bij drie mensen opent de chat en kiezen jullie daar plaats en tijd.';

  @override
  String get upcoming => 'Binnenkort';

  @override
  String get calendar => 'Agenda';

  @override
  String get noUpcomingJoined => 'Je doet niet mee aan komende evenementen.';

  @override
  String get showAll => 'Alles tonen';

  @override
  String get noUpcoming60 =>
      'Je groepen hebben de komende 60 dagen geen evenementen.';

  @override
  String get findGroup => 'Groep vinden';

  @override
  String filterAll(int count) {
    return 'Alle · $count';
  }

  @override
  String filterMine(int count) {
    return 'Mijn · $count';
  }

  @override
  String get tomorrow => 'Morgen';

  @override
  String get going => 'Je doet mee';

  @override
  String get waitlisted => 'Op de wachtlijst';

  @override
  String get awaitingApproval => 'Wacht op goedkeuring';

  @override
  String get full => 'Vol';

  @override
  String goingOfCapacityShort(int count, int capacity) {
    return '$count/$capacity deelnemers';
  }

  @override
  String get startingSoon => 'Begint binnenkort';

  @override
  String get next6Hours => 'Komende 6 uur';

  @override
  String get wantWelcome => 'Ik wil verwelkomd worden';

  @override
  String get wantWelcomeHint =>
      'Een vrijwilliger van de groep vangt je bij de ingang op, zodat je niet alleen gaat.';

  @override
  String get noteForGreeter => 'Een notitie zodat ze je herkennen (optioneel)';

  @override
  String get noteForGreeterHint => 'Bijv. rode jas, blauwe tas';

  @override
  String get sendRequest => 'Verzoek sturen';

  @override
  String get welcomeRequestSent =>
      'Je verzoek is naar de gastheren gestuurd. We laten het weten zodra iemand het oppakt.';

  @override
  String get editMeetingNote => 'Ontmoetingsnotitie bewerken';

  @override
  String welcomePerson(String name) {
    return '$name verwelkomen';
  }

  @override
  String describedAs(String note) {
    return 'Beschrijving: $note';
  }

  @override
  String get whereMeet => 'Waar spreken jullie af?';

  @override
  String get whereMeetHint => 'Bijv. voor het café bij de ingang, 8:45';

  @override
  String get save => 'Opslaan';

  @override
  String get iWillWelcome => 'Ik verwelkom';

  @override
  String get noteUpdated => 'Ontmoetingsnotitie bijgewerkt.';

  @override
  String youWillWelcome(String name) {
    return 'Je verwelkomt $name; diegene heeft de notitie gezien.';
  }

  @override
  String get stopWelcoming => 'Verwelkomen stoppen';

  @override
  String stopWelcomingBody(String name) {
    return 'We zoeken een andere gastheer voor $name en laten het weten.';
  }

  @override
  String get release => 'Stoppen';

  @override
  String get releasedWelcome =>
      'Je bent gestopt; we zoeken een nieuwe gastheer.';

  @override
  String get firstTime => 'Kom je voor het eerst?';

  @override
  String greetersAvailable(int count) {
    return 'Deze groep heeft $count gastheren. Laat je bij de ingang opvangen en voorstellen aan de groep.';
  }

  @override
  String get youWelcomed => 'Door jou verwelkomd';

  @override
  String meetingAt(String note) {
    return 'Ontmoeting: $note';
  }

  @override
  String get thankedYou => 'Heeft je bedankt';

  @override
  String optionsFor(String name) {
    return 'Opties voor $name';
  }

  @override
  String waitingWelcome(int count) {
    return 'Wachten op verwelkoming ($count)';
  }

  @override
  String matchedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensen hebben een gastheer.',
      one: '1 persoon heeft een gastheer.',
    );
    return '$_temp0';
  }

  @override
  String get firstTimer => 'Voor het eerst';

  @override
  String get max3Welcomes =>
      'Je kunt per evenement maximaal 3 mensen verwelkomen.';

  @override
  String get greeterJoinHint =>
      'Je bent gastheer. Doe mee aan het evenement om nieuwkomers te verwelkomen.';

  @override
  String get lookingGreeter => 'Gastheer gezocht';

  @override
  String get lookingGreeterHint =>
      'We hebben de gastheren ingelicht. Je krijgt een melding zodra iemand het oppakt.';

  @override
  String yourNote(String note) {
    return 'Je notitie: $note';
  }

  @override
  String get welcomeWithdrawn => 'Je verzoek is ingetrokken.';

  @override
  String get withdrawRequest => 'Verzoek intrekken';

  @override
  String get greetedBy => 'Verwelkomd door';

  @override
  String get willGreet => 'Verwelkomt je';

  @override
  String get thank => 'Bedanken';

  @override
  String thankReceived(String name) {
    return '$name heeft je dank ontvangen.';
  }

  @override
  String get thanked => 'Je hebt bedankt.';

  @override
  String get cancelWelcome => 'Verwelkoming annuleren';

  @override
  String get nowGreeter =>
      'Je bent nu gastheer. We laten het weten als een nieuwkomer verwelkomd wil worden.';

  @override
  String get noLongerGreeter => 'Je bent geen gastheer meer.';

  @override
  String get welcomeSection => 'Verwelkoming';

  @override
  String greetersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gastheren',
      one: '1 gastheer',
    );
    return '$_temp0';
  }

  @override
  String get greeterIntro =>
      'Nieuwkomers kunnen op de evenementpagina om verwelkoming vragen. Als gastheer krijg je bericht; je vangt ze op bij de ingang en stelt ze voor aan de groep.';

  @override
  String greeterMemberHint(int count) {
    return 'Deze groep heeft $count gastheren. Tik bij je eerste evenement op ‘Ik wil verwelkomd worden’.';
  }

  @override
  String greeterVisitorHint(int count) {
    return 'Deze groep heeft $count gastheren: je gaat niet alleen naar je eerste evenement, iemand vangt je op bij de ingang.';
  }

  @override
  String get becomeGreeter => 'Gastheer worden';

  @override
  String quoted(String text) {
    return '‘$text’';
  }
}
