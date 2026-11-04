// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'social_app_l10n.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class SocialAppL10nDe extends SocialAppL10n {
  SocialAppL10nDe([String locale = 'de']) : super(locale);

  @override
  String get posts => 'Beiträge';

  @override
  String get newPost => 'Neuer Beitrag';

  @override
  String get noOwnPosts =>
      'Du hast noch keine Beiträge geteilt. Teile dein erstes Foto oder Video.';

  @override
  String get noPosts => 'Noch keine Beiträge.';

  @override
  String get shareFirstOwn => 'Teile deinen ersten Beitrag';

  @override
  String get groupFirstPost =>
      'Teile als Erste:r einen Beitrag im Gruppen-Feed.';

  @override
  String get groupNoPosts => 'In dieser Gruppe gibt es noch keine Beiträge.';

  @override
  String get shareFirstGroup => 'Ersten Beitrag teilen';

  @override
  String get groupNotFound => 'Gruppe nicht gefunden.';

  @override
  String get memoriesEmpty =>
      'Noch keine Erinnerungen geteilt. Teilnehmende können hier ihre Fotos hinzufügen.';

  @override
  String get plan => 'Paket';

  @override
  String get payment => 'Zahlung';

  @override
  String get onlyOwnerBilling =>
      'Nur der/die Gruppeninhaber:in kann Pakete verwalten.';

  @override
  String get backToGroup => 'Zurück zur Gruppe';

  @override
  String get writeSupportAboutGroup =>
      'Schreib dem Plattform-Team zu dieser Gruppe';

  @override
  String get search => 'Suchen';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get goodNight => 'Gute Nacht';

  @override
  String get goodMorning => 'Guten Morgen';

  @override
  String get goodAfternoon => 'Guten Tag';

  @override
  String get goodEvening => 'Guten Abend';

  @override
  String greetingName(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String get tabToday => 'Heute';

  @override
  String get tabGroups => 'Gruppen';

  @override
  String get tabCalendar => 'Kalender';

  @override
  String get tabMe => 'Ich';

  @override
  String get tonightSay => 'Zeit? Sag Bescheid und gründe einen Tisch';

  @override
  String get tonightTableSet => 'Dein Tisch steht';

  @override
  String get tonightInvited => 'Du bist an einen Tisch eingeladen';

  @override
  String tonightFreeWithYou(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Personen haben wie du Zeit',
      one: '1 Person hat wie du Zeit',
    );
    return '$_temp0';
  }

  @override
  String get tonightFreeUntil => 'Du hast Zeit · bis 4:00 Uhr';

  @override
  String tonightFreeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Personen haben heute Abend Zeit',
      one: '1 Person hat heute Abend Zeit',
    );
    return '$_temp0';
  }

  @override
  String get upcomingNone => 'Pläne deiner Gruppen';

  @override
  String upcomingMine(int count, int mine) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Pläne',
      one: '1 Plan',
    );
    return '$_temp0 · $mine Zusagen';
  }

  @override
  String upcomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Pläne',
      one: '1 Plan',
    );
    return '$_temp0, 60 Tage';
  }

  @override
  String get forToday => 'Für heute';

  @override
  String get tonight => 'Heute Abend';

  @override
  String get upcoming => 'Demnächst';

  @override
  String get share => 'Teilen';

  @override
  String get post => 'Beitrag';

  @override
  String get postHint => 'Bis zu 10 Fotos oder Videos';

  @override
  String get story => 'Story';

  @override
  String get storyHint => '24 Stunden sichtbar';

  @override
  String get group => 'Gruppe';

  @override
  String get groupHint => 'Gründe deine eigene Community';

  @override
  String get create => 'Erstellen';

  @override
  String get messages => 'Nachrichten';

  @override
  String get matching => 'Matching';

  @override
  String get myGroups => 'Meine Gruppen';

  @override
  String get pageNotFound =>
      'Die Seite wurde nicht gefunden. Der Link ist vielleicht veraltet oder fehlerhaft.';

  @override
  String get backHome => 'Zur Startseite';

  @override
  String get groupsLeague => 'Gruppenliga';

  @override
  String get exploreOnMap => 'Auf der Karte entdecken';

  @override
  String get yearMenu =>
      'Jahresrückblick, meine Entdeckerkarte und Leute, die ich getroffen habe';

  @override
  String get yearSummary => 'Jahresrückblick';

  @override
  String get yearSummaryHint =>
      'Deine Treffen in diesem Jahr als teilbare Karte';

  @override
  String get explorationMap => 'Meine Entdeckerkarte';

  @override
  String get explorationMapHint =>
      'Provinzen der Events, an denen du teilgenommen hast';

  @override
  String get metPeople => 'Leute, die ich getroffen habe';

  @override
  String get metPeopleHint =>
      'Leute, mit denen du bei Events einen Handshake gemacht hast';

  @override
  String get findTeammates => 'Teammitglieder finden';

  @override
  String get saved => 'Gespeichert';

  @override
  String get gateError =>
      'Deine Daten konnten nicht geladen werden. Prüfe deine Verbindung und versuche es erneut.';

  @override
  String get searchPeople => 'Personen suchen';

  @override
  String get clearSearch => 'Suche löschen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get editProfile => 'Profil bearbeiten';

  @override
  String get teammatePrefs => 'Teammitglieder-Einstellungen';

  @override
  String get matchProfile => 'Matching-Profil';

  @override
  String get voiceCalls => 'Sprachanrufe';

  @override
  String get blockedAccounts => 'Blockierte Konten';

  @override
  String get storyArchive => 'Story-Archiv';

  @override
  String get notificationPrefs => 'Benachrichtigungseinstellungen';

  @override
  String get mySanctions => 'Meine Gruppensanktionen';

  @override
  String get userGuide => 'Benutzerhandbuch';

  @override
  String get supportFeedback => 'Support und Feedback';

  @override
  String newReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count neue Antworten',
      one: '1 neue Antwort',
    );
    return '$_temp0';
  }

  @override
  String get twoFactor => 'Zweistufige Bestätigung';

  @override
  String get legalDocuments => 'Rechtliche Dokumente';

  @override
  String get deleteAccount => 'Konto löschen';

  @override
  String get signOut => 'Abmelden';

  @override
  String get nowPrivate => 'Dein Konto ist jetzt privat.';

  @override
  String get nowPublic =>
      'Dein Konto ist jetzt öffentlich; offene Anfragen wurden angenommen.';

  @override
  String get privateAccount => 'Privates Konto';

  @override
  String get privateAccountHint =>
      'Wenn aktiv, sehen nur von dir bestätigte Follower deine Beiträge und Storys.';

  @override
  String get groupsNowPublic =>
      'Deine Gruppen sind jetzt in deinem Profil für alle sichtbar.';

  @override
  String get groupsNowMembers =>
      'Deine Gruppen sind jetzt nur noch für Mitglieder derselben Gruppe sichtbar.';

  @override
  String get showGroups => 'Meine Gruppen im Profil zeigen';

  @override
  String get showGroupsHint =>
      'Wenn aus, sehen nur die Mitglieder einer Gruppe, dass du dazugehörst; Admins anderer Gruppen nicht.';

  @override
  String get language => 'Sprache';
}
