// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'social_app_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class SocialAppL10nNl extends SocialAppL10n {
  SocialAppL10nNl([String locale = 'nl']) : super(locale);

  @override
  String get posts => 'Berichten';

  @override
  String get newPost => 'Nieuw bericht';

  @override
  String get noOwnPosts =>
      'Je hebt nog niets gedeeld. Deel je eerste foto of video.';

  @override
  String get noPosts => 'Nog geen berichten.';

  @override
  String get shareFirstOwn => 'Deel je eerste bericht';

  @override
  String get groupFirstPost =>
      'Plaats als eerste een bericht in de groepsfeed.';

  @override
  String get groupNoPosts => 'Er zijn nog geen berichten in deze groep.';

  @override
  String get shareFirstGroup => 'Eerste bericht delen';

  @override
  String get groupNotFound => 'Groep niet gevonden.';

  @override
  String get memoriesEmpty =>
      'Nog geen herinneringen gedeeld. Deelnemers kunnen hier hun foto’s toevoegen.';

  @override
  String get plan => 'Pakket';

  @override
  String get payment => 'Betaling';

  @override
  String get onlyOwnerBilling =>
      'Alleen de eigenaar van de groep kan pakketten beheren.';

  @override
  String get backToGroup => 'Terug naar groep';

  @override
  String get writeSupportAboutGroup =>
      'Neem contact op met het platformteam over deze groep';

  @override
  String get search => 'Zoeken';

  @override
  String get notifications => 'Meldingen';

  @override
  String get goodNight => 'Goedenacht';

  @override
  String get goodMorning => 'Goedemorgen';

  @override
  String get goodAfternoon => 'Goedemiddag';

  @override
  String get goodEvening => 'Goedenavond';

  @override
  String greetingName(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String get tabToday => 'Vandaag';

  @override
  String get tabGroups => 'Groepen';

  @override
  String get tabCalendar => 'Agenda';

  @override
  String get tabMe => 'Ik';

  @override
  String get tonightSay => 'Tijd? Zeg het en zet een tafel op';

  @override
  String get tonightTableSet => 'Je tafel staat klaar';

  @override
  String get tonightInvited => 'Je bent uitgenodigd aan een tafel';

  @override
  String tonightFreeWithYou(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensen hebben net als jij tijd',
      one: '1 persoon heeft net als jij tijd',
    );
    return '$_temp0';
  }

  @override
  String get tonightFreeUntil => 'Je hebt tijd · tot 4:00 uur';

  @override
  String tonightFreeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensen hebben vanavond tijd',
      one: '1 persoon heeft vanavond tijd',
    );
    return '$_temp0';
  }

  @override
  String get upcomingNone => 'Plannen van je groepen';

  @override
  String upcomingMine(int count, int mine) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plannen',
      one: '1 plan',
    );
    return '$_temp0 · $mine aanmeldingen';
  }

  @override
  String upcomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plannen',
      one: '1 plan',
    );
    return '$_temp0, 60 dagen';
  }

  @override
  String get forToday => 'Voor vandaag';

  @override
  String get tonight => 'Vanavond';

  @override
  String get upcoming => 'Binnenkort';

  @override
  String get share => 'Delen';

  @override
  String get post => 'Bericht';

  @override
  String get postHint => 'Tot 10 foto\'s of video\'s';

  @override
  String get story => 'Verhaal';

  @override
  String get storyHint => '24 uur zichtbaar';

  @override
  String get group => 'Groep';

  @override
  String get groupHint => 'Start je eigen community';

  @override
  String get create => 'Maken';

  @override
  String get messages => 'Berichten';

  @override
  String get matching => 'Matchen';

  @override
  String get myGroups => 'Mijn groepen';

  @override
  String get pageNotFound =>
      'De pagina is niet gevonden. De link is misschien oud of onjuist.';

  @override
  String get backHome => 'Terug naar start';

  @override
  String get groupsLeague => 'Groepencompetitie';

  @override
  String get exploreOnMap => 'Verkennen op de kaart';

  @override
  String get yearMenu =>
      'Jaaroverzicht, mijn ontdekkingskaart en mensen die ik ontmoette';

  @override
  String get yearSummary => 'Jaaroverzicht';

  @override
  String get yearSummaryHint => 'Je meetups van dit jaar, als deelbare kaart';

  @override
  String get explorationMap => 'Mijn ontdekkingskaart';

  @override
  String get explorationMapHint =>
      'Provincies van de evenementen waaraan je meedeed';

  @override
  String get metPeople => 'Mensen die ik ontmoette';

  @override
  String get metPeopleHint =>
      'Mensen met wie je bij evenementen een handdruk deed';

  @override
  String get findTeammates => 'Teamgenoten vinden';

  @override
  String get saved => 'Opgeslagen';

  @override
  String get gateError =>
      'Je gegevens konden niet worden geladen. Controleer je verbinding en probeer het opnieuw.';

  @override
  String get searchPeople => 'Mensen zoeken';

  @override
  String get clearSearch => 'Zoekopdracht wissen';

  @override
  String get settings => 'Instellingen';

  @override
  String get editProfile => 'Profiel bewerken';

  @override
  String get teammatePrefs => 'Voorkeuren voor teamgenoten';

  @override
  String get matchProfile => 'Matchprofiel';

  @override
  String get voiceCalls => 'Spraakoproepen';

  @override
  String get blockedAccounts => 'Geblokkeerde accounts';

  @override
  String get storyArchive => 'Verhalenarchief';

  @override
  String get notificationPrefs => 'Meldingsvoorkeuren';

  @override
  String get mySanctions => 'Mijn groepssancties';

  @override
  String get userGuide => 'Gebruikershandleiding';

  @override
  String get supportFeedback => 'Ondersteuning en feedback';

  @override
  String newReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nieuwe antwoorden',
      one: '1 nieuw antwoord',
    );
    return '$_temp0';
  }

  @override
  String get twoFactor => 'Verificatie in twee stappen';

  @override
  String get legalDocuments => 'Juridische documenten';

  @override
  String get deleteAccount => 'Account verwijderen';

  @override
  String get signOut => 'Uitloggen';

  @override
  String get nowPrivate => 'Je account is nu privé.';

  @override
  String get nowPublic =>
      'Je account is nu openbaar; openstaande verzoeken zijn goedgekeurd.';

  @override
  String get privateAccount => 'Privéaccount';

  @override
  String get privateAccountHint =>
      'Als dit aan staat, zien alleen volgers die je goedkeurt je berichten en verhalen.';

  @override
  String get groupsNowPublic =>
      'Je groepen zijn nu voor iedereen zichtbaar op je profiel.';

  @override
  String get groupsNowMembers =>
      'Je groepen zijn nu alleen zichtbaar voor leden van dezelfde groep.';

  @override
  String get showGroups => 'Mijn groepen op mijn profiel tonen';

  @override
  String get showGroupsHint =>
      'Als dit uit staat, zien alleen leden van een groep dat je erbij hoort; beheerders van andere groepen niet.';

  @override
  String get language => 'Taal';
}
