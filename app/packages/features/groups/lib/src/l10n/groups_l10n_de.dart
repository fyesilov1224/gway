// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'groups_l10n.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class GroupsL10nDe extends GroupsL10n {
  GroupsL10nDe([String locale = 'de']) : super(locale);

  @override
  String get unsupportedImage =>
      'Dieser Dateityp wird nicht unterstützt. Wähle JPEG, PNG oder WebP.';

  @override
  String get joinOpen => 'Offener Beitritt';

  @override
  String get joinOpenHint => 'Alle können direkt beitreten.';

  @override
  String get joinRequest => 'Beitritt auf Anfrage';

  @override
  String get joinRequestHint => 'Admins bestätigen Beitrittsanfragen.';

  @override
  String get joinInvite => 'Nur mit Einladung';

  @override
  String get joinInviteHint => 'Nur eingeladene Personen können beitreten.';

  @override
  String get roleOwner => 'Gruppeninhaber:in';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleDiscipline => 'Disziplinarausschuss';

  @override
  String get roleModerator => 'Moderator:in';

  @override
  String get roleMember => 'Mitglied';

  @override
  String get handleMin =>
      'Die Gruppenadresse muss mindestens 3 Zeichen lang sein.';

  @override
  String get handleChars =>
      'Verwende nur Kleinbuchstaben, Zahlen, Unterstriche und Punkte.';

  @override
  String get handleDots =>
      'Darf nicht mit einem Punkt beginnen oder enden und keine zwei Punkte hintereinander enthalten.';

  @override
  String get nameMin => 'Der Gruppenname muss mindestens 3 Zeichen lang sein.';

  @override
  String nameMax(int max) {
    return 'Der Gruppenname darf höchstens $max Zeichen lang sein.';
  }

  @override
  String get httpsOnly => 'Gib eine Adresse ein, die mit https:// beginnt.';

  @override
  String get createGroup => 'Gruppe erstellen';

  @override
  String get groupInfo => 'Gruppenangaben';

  @override
  String get groupInfoHint =>
      'Logo, Titelbild, Regeln und Links kannst du nach dem Erstellen hinzufügen.';

  @override
  String get groupName => 'Gruppenname';

  @override
  String get about => 'Beschreibung';

  @override
  String get aboutHint => 'Was macht eure Gruppe, und wer kann mitmachen?';

  @override
  String get joining => 'Beitritt';

  @override
  String get changeLater => 'Das kannst du später ändern.';

  @override
  String get createTheGroup => 'Gruppe erstellen';

  @override
  String get editGroup => 'Gruppe bearbeiten';

  @override
  String get noEditPermission => 'Du darfst diese Gruppe nicht bearbeiten.';

  @override
  String get backToGroup => 'Zurück zur Gruppe';

  @override
  String get save => 'Speichern';

  @override
  String get logoAndCover => 'Logo und Titelbild';

  @override
  String get imageHint => 'JPEG, PNG oder WebP · bis 5 MB';

  @override
  String get logo => 'Logo';

  @override
  String get cover => 'Titelbild';

  @override
  String groupHandle(String handle) {
    return 'Gruppenadresse: @$handle';
  }

  @override
  String get rules => 'Regeln';

  @override
  String get rulesHint =>
      'Was du von Mitgliedern erwartest, eine Regel pro Zeile.';

  @override
  String get links => 'Links';

  @override
  String linksHint(int max) {
    return 'Website und Social-Media-Konten. Bis zu $max.';
  }

  @override
  String get enterLabel => 'Gib eine Bezeichnung ein.';

  @override
  String get label => 'Bezeichnung';

  @override
  String get address => 'Adresse';

  @override
  String get removeLink => 'Link entfernen';

  @override
  String get addLink => 'Link hinzufügen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get saveChanges => 'Änderungen speichern';

  @override
  String get deleteGroup => 'Gruppe löschen';

  @override
  String get deleteGroupBody =>
      'Gruppe, Mitgliedschaften, Rollen, Anfragen und Einladungen werden endgültig gelöscht. Die Restlaufzeit des Pakets wird nicht erstattet.';

  @override
  String deleteGroupNamed(String name) {
    return '$name löschen';
  }

  @override
  String changeImage(String label) {
    return '$label ändern';
  }

  @override
  String addImage(String label) {
    return '$label hinzufügen';
  }

  @override
  String get remove => 'Entfernen';

  @override
  String get deleteForever => 'Gruppe endgültig löschen';

  @override
  String deleteConfirm(String handle) {
    return 'Das kann nicht rückgängig gemacht werden. Gib zur Bestätigung die Gruppenadresse ein: $handle';
  }

  @override
  String get delete => 'Löschen';

  @override
  String get group => 'Gruppe';

  @override
  String get share => 'Teilen';

  @override
  String shareText(String name) {
    return 'Sieh dir $name auf GWAY an:';
  }

  @override
  String get moreOptions => 'Weitere Optionen';

  @override
  String get leaveGroup => 'Gruppe verlassen';

  @override
  String get groupNotFound =>
      'Diese Gruppe wurde nicht gefunden oder ist nicht mehr sichtbar.';

  @override
  String get backToGroups => 'Zurück zu Gruppen';

  @override
  String leaveConfirm(String name) {
    return '$name verlassen? Falls du eine Rolle in der Gruppe hast, wird sie ebenfalls entfernt.';
  }

  @override
  String get leave => 'Verlassen';

  @override
  String leftGroup(String name) {
    return 'Du hast $name verlassen.';
  }

  @override
  String get suspendedNotice =>
      'Das Plattform-Team hat diese Gruppe gesperrt. Während der Sperre sehen sie nur Mitglieder.';

  @override
  String founded(String date) {
    return 'Gegründet $date';
  }

  @override
  String joinRequestsPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Beitrittsanfragen warten auf Bestätigung.',
      one: '1 Beitrittsanfrage wartet auf Bestätigung.',
    );
    return '$_temp0';
  }

  @override
  String get review => 'Ansehen';

  @override
  String get requestSent => 'Deine Beitrittsanfrage wurde gesendet.';

  @override
  String get youAreMember => 'Du bist Mitglied';

  @override
  String get join => 'Beitreten';

  @override
  String joined(String name) {
    return 'Du bist $name beigetreten.';
  }

  @override
  String get sendJoinRequest => 'Beitritt anfragen';

  @override
  String get requestSentShort => 'Angefragt';

  @override
  String get withdrawRequest => 'Anfrage zurückziehen';

  @override
  String get withdrawConfirm => 'Beitrittsanfrage zurückziehen?';

  @override
  String get undo => 'Zurückziehen';

  @override
  String get requestWithdrawn => 'Deine Beitrittsanfrage wurde zurückgezogen.';

  @override
  String get decline => 'Ablehnen';

  @override
  String get inviteDeclined => 'Einladung abgelehnt.';

  @override
  String get acceptInvite => 'Einladung annehmen';

  @override
  String followOn(String name) {
    return 'Beiträge von $name erscheinen in deinem Feed.';
  }

  @override
  String get followOff => 'Du folgst der Gruppe nicht mehr.';

  @override
  String get following => 'Folge ich';

  @override
  String get follow => 'Folgen';

  @override
  String get managementTeam => 'Leitungsteam';

  @override
  String allMembers(int count) {
    return 'Alle Mitglieder ($count)';
  }

  @override
  String get groups => 'Gruppen';

  @override
  String get discover => 'Entdecken';

  @override
  String get myGroups => 'Meine Gruppen';

  @override
  String get plans => 'Pakete';

  @override
  String get searchHint => 'Nach Gruppenname oder Adresse suchen';

  @override
  String get clearSearch => 'Suche löschen';

  @override
  String get all => 'Alle';

  @override
  String get noMatch => 'Keine Gruppe passt zu deiner Suche.';

  @override
  String get clearFilters => 'Filter löschen';

  @override
  String get noGroupsYet => 'Noch gibt es keine Gruppen. Gründe die erste.';

  @override
  String get showMore => 'Mehr anzeigen';

  @override
  String get notJoinedYet => 'Du bist noch keiner Gruppe beigetreten.';

  @override
  String get discoverGroups => 'Gruppen entdecken';

  @override
  String get plansHint =>
      'Pakete kaufen Gruppeninhaber:innen. Gründe deine Gruppe und wähle ein Paket.';

  @override
  String get yourInvitations => 'Deine Einladungen';

  @override
  String get invitationsHint => 'Diese Gruppen haben dich eingeladen.';

  @override
  String invitedBy(String name) {
    return 'Eingeladen von $name';
  }

  @override
  String get linkCopied => 'Link kopiert.';

  @override
  String inviteShareText(String name) {
    return 'Tritt $name auf GWAY bei:';
  }

  @override
  String get revokeLinkTitle => 'Link widerrufen?';

  @override
  String get revokeLinkBody =>
      'Mit diesem Link kann niemand mehr beitreten. Wer schon beigetreten ist, bleibt Mitglied.';

  @override
  String get revoke => 'Widerrufen';

  @override
  String get inviteLink => 'Einladungslink';

  @override
  String get inviteLinkHint =>
      'Teile ihn auf WhatsApp oder Instagram. Wer den Link öffnet, wird unabhängig von der Beitrittsart direkt Mitglied.';

  @override
  String get createLink => 'Link erstellen';

  @override
  String validUntil(String date) {
    return 'Bis $date';
  }

  @override
  String peopleJoined(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Personen beigetreten',
      one: '1 Person beigetreten',
    );
    return '$_temp0';
  }

  @override
  String peopleJoinedOf(int count, int max) {
    return '$count / $max beigetreten';
  }

  @override
  String get newInviteLink => 'Neuer Einladungslink';

  @override
  String get validity => 'Gültig für';

  @override
  String days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage',
      one: '1 Tag',
    );
    return '$_temp0';
  }

  @override
  String get howMany => 'Wie viele Personen können beitreten?';

  @override
  String get unlimited => 'Unbegrenzt';

  @override
  String people(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Personen',
      one: '1 Person',
    );
    return '$_temp0';
  }

  @override
  String get createAndShare => 'Erstellen und teilen';

  @override
  String get invitation => 'Einladung';

  @override
  String get linkInvalid =>
      'Dieser Einladungslink ist nicht mehr gültig. Bitte die Gruppenadmins um einen neuen.';

  @override
  String get seeGroup => 'Gruppe ansehen';

  @override
  String get invitedToGroup => 'Du wurdest in diese Gruppe eingeladen.';

  @override
  String get joinGroup => 'Gruppe beitreten';

  @override
  String get members => 'Mitglieder';

  @override
  String get requests => 'Anfragen';

  @override
  String get invitations => 'Einladungen';

  @override
  String get roles => 'Rollen';

  @override
  String get openCase => 'Disziplinarverfahren eröffnen';

  @override
  String get report => 'Melden';

  @override
  String membersVisibility(int shown, int total) {
    return 'Die vollständige Mitgliederliste sehen nur Mitglieder. Hier: das Leitungsteam und $shown Personen, die ihre Gruppen öffentlich zeigen; insgesamt hat die Gruppe $total Mitglieder.';
  }

  @override
  String optionsFor(String name) {
    return 'Optionen für $name';
  }

  @override
  String get transferOwnership => 'Inhaberschaft übertragen';

  @override
  String transferBody(String group, String person) {
    return 'Die Inhaberschaft von $group geht an $person. Du bleibst normales Mitglied und kannst das nicht rückgängig machen.';
  }

  @override
  String get transfer => 'Übertragen';

  @override
  String transferred(String name) {
    return 'Inhaberschaft an $name übertragen.';
  }

  @override
  String get hintAdmin =>
      'Bearbeitet die Gruppe und verwaltet Beitrittsanfragen und Einladungen.';

  @override
  String get hintDiscipline =>
      'Prüft Beschwerdefälle und entscheidet über Sanktionen.';

  @override
  String get hintModerator => 'Prüft Inhalte und Kommentare.';

  @override
  String personJoined(String name) {
    return '$name ist der Gruppe beigetreten.';
  }

  @override
  String get requestDeclined => 'Anfrage abgelehnt.';

  @override
  String get noPendingRequests => 'Keine offenen Beitrittsanfragen.';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get approve => 'Bestätigen';

  @override
  String get inviteSent => 'Einladung gesendet.';

  @override
  String get inviteByUsername => 'Per Benutzername einladen';

  @override
  String get invite => 'Einladen';

  @override
  String get noPendingInvites => 'Keine offenen Einladungen.';

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
  String get suspended => 'Gesperrt';

  @override
  String get groupsSection => 'Gruppen';

  @override
  String get groupsOwnHint =>
      'Deine Gruppen sehen nur Mitglieder derselben Gruppe. In den Einstellungen kannst du sie öffentlich machen.';

  @override
  String get groupsOtherHint =>
      'Nur gemeinsame Gruppen und Gruppen, in deren Leitung die Person ist, werden angezeigt.';

  @override
  String get noGroupsToShow => 'Keine Gruppen zum Anzeigen.';

  @override
  String get handleTaken =>
      'Diese Gruppenadresse ist vergeben. Versuche eine andere.';

  @override
  String get groupAddress => 'Gruppenadresse';

  @override
  String get groupAddressHint =>
      'Die Adresse deiner Gruppenseite. Sie kann später nicht geändert werden.';

  @override
  String get available => 'Verfügbar';

  @override
  String get taken => 'Vergeben';

  @override
  String get notSpecified => 'Keine Angabe';

  @override
  String get provinceOptional => 'Provinz (optional)';

  @override
  String get provinceHint =>
      'Die Gruppe erscheint auf der Karte in dieser Provinz.';

  @override
  String get chooseCategory => 'Wähle eine Kategorie.';

  @override
  String get category => 'Kategorie';
}
