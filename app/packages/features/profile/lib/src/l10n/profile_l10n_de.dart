// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'profile_l10n.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class ProfileL10nDe extends ProfileL10n {
  ProfileL10nDe([String locale = 'de']) : super(locale);

  @override
  String get unsupportedImage =>
      'Dieser Dateityp wird nicht unterstützt. Wähle JPEG, PNG oder WebP.';

  @override
  String get usernameTaken =>
      'Dieser Benutzername ist vergeben. Versuche einen anderen.';

  @override
  String get checkInput => 'Prüfe deine Eingaben.';

  @override
  String get usernameReserved =>
      'Dieser Benutzername ist nicht erlaubt. Versuche einen anderen.';

  @override
  String get usernameCooldown =>
      'Du kannst deinen Benutzernamen nur einmal alle 30 Tage ändern.';

  @override
  String get maxInterests10 => 'Du kannst bis zu 10 Interessen wählen.';

  @override
  String get levelBeginner => 'Anfänger';

  @override
  String get levelBeginnerHint => 'Ich fange gerade an';

  @override
  String get levelIntermediate => 'Fortgeschritten';

  @override
  String get levelIntermediateHint => 'Ich mache es regelmäßig';

  @override
  String get levelAdvanced => 'Erfahren';

  @override
  String get levelAdvancedHint => 'Ich habe viel Erfahrung';

  @override
  String get slotWeekdayMorning => 'Werktags morgens';

  @override
  String get slotWeekdayNoon => 'Werktags mittags';

  @override
  String get slotWeekdayEvening => 'Werktags abends';

  @override
  String get slotWeekendMorning => 'Am Wochenende morgens';

  @override
  String get slotWeekendAfternoon => 'Am Wochenende nachmittags';

  @override
  String get slotWeekendEvening => 'Am Wochenende abends';

  @override
  String get partMorning => 'Morgens';

  @override
  String get partNoon => 'Mittags';

  @override
  String get partEvening => 'Abends';

  @override
  String get goalFun => 'Spaß haben';

  @override
  String get goalFitness => 'Fit bleiben';

  @override
  String get goalCompetition => 'Mich auf Wettkämpfe vorbereiten';

  @override
  String get goalLearning => 'Neues lernen';

  @override
  String get goalMentoring => 'Meine Erfahrung weitergeben';

  @override
  String get goalSocial => 'Neue Leute kennenlernen';

  @override
  String get freqMonthly => 'Ein paarmal im Monat';

  @override
  String get freqWeekly => 'Einmal pro Woche';

  @override
  String get freqFewWeekly => '2–3 Mal pro Woche';

  @override
  String get freqDaily => 'Fast jeden Tag';

  @override
  String get sizePair => 'Zu zweit';

  @override
  String get sizeSmall => 'Kleine Gruppe (3–6)';

  @override
  String get sizeLarge => 'Große Gruppe';

  @override
  String get looking => 'Sucht ein Team';

  @override
  String lookingWithLevel(String level) {
    return 'Sucht ein Team · $level';
  }

  @override
  String reasonActivities(String list) {
    return 'Gleiche Aktivität: $list';
  }

  @override
  String reasonInterests(String list) {
    return 'Gemeinsame Interessen: $list';
  }

  @override
  String get reasonProvince => 'Ihr seid in derselben Provinz';

  @override
  String reasonGroup(String group) {
    return 'Gemeinsame Gruppe: $group';
  }

  @override
  String reasonGroups(int count) {
    return '$count gemeinsame Gruppen';
  }

  @override
  String reasonLevel(String level) {
    return 'Gleiches Level: $level';
  }

  @override
  String reasonTimes(String list) {
    return 'Gemeinsame Zeit: $list';
  }

  @override
  String reasonGoals(String list) {
    return 'Gemeinsame Ziele: $list';
  }

  @override
  String get reasonFrequency => 'Ihr wollt euch gleich oft treffen';

  @override
  String get hasVehicle => 'Hat ein Fahrzeug';

  @override
  String get hasEquipment => 'Hat eigene Ausrüstung';

  @override
  String get usernameRequired => 'Wähle einen Benutzernamen.';

  @override
  String usernameMin(int min) {
    return 'Der Benutzername muss mindestens $min Zeichen lang sein.';
  }

  @override
  String usernameMax(int max) {
    return 'Der Benutzername darf höchstens $max Zeichen lang sein.';
  }

  @override
  String get usernameChars =>
      'Verwende nur a–z, 0–9, Unterstrich (_) und Punkt (.).';

  @override
  String get usernameDots =>
      'Der Benutzername darf nicht mit einem Punkt beginnen oder enden.';

  @override
  String get usernameDoubleDot =>
      'Zwei Punkte hintereinander sind nicht erlaubt.';

  @override
  String get nameRequired => 'Gib deinen Namen ein.';

  @override
  String nameMax(int max) {
    return 'Der Name darf höchstens $max Zeichen lang sein.';
  }

  @override
  String get editProfile => 'Profil bearbeiten';

  @override
  String get save => 'Speichern';

  @override
  String get profileInfo => 'Profilangaben';

  @override
  String get profileInfoHint =>
      'Diese Angaben sind in deinem Profil für alle sichtbar.';

  @override
  String get yourName => 'Dein Name';

  @override
  String get usernameEvery30 =>
      'Du kannst deinen Benutzernamen alle 30 Tage ändern.';

  @override
  String usernameLockedUntil(String date) {
    return 'Du kannst ihn nach dem $date ändern.';
  }

  @override
  String get about => 'Über mich';

  @override
  String get aboutHint => 'Erzähl von dir und den Aktivitäten, die du liebst.';

  @override
  String get interests => 'Interessen';

  @override
  String interestsMax(int max) {
    return 'Du kannst bis zu $max wählen.';
  }

  @override
  String get cancel => 'Abbrechen';

  @override
  String get saveChanges => 'Änderungen speichern';

  @override
  String get remove => 'Entfernen';

  @override
  String get removeCover => 'Titelbild entfernen';

  @override
  String get addCover => 'Titelbild hinzufügen';

  @override
  String get changeCover => 'Titelbild ändern';

  @override
  String get changeAvatar => 'Profilbild ändern';

  @override
  String get photos => 'Profil- und Titelbild';

  @override
  String get photosHint => 'JPEG, PNG oder WebP · bis 5 MB';

  @override
  String get addAvatar => 'Profilbild hinzufügen';

  @override
  String get removeAvatar => 'Profilbild entfernen';

  @override
  String get followers => 'Follower';

  @override
  String get following => 'Folge ich';

  @override
  String get privateLists =>
      'Dieses Konto ist privat. Folge ihm, um seine Listen zu sehen.';

  @override
  String get backToProfile => 'Zurück zum Profil';

  @override
  String get noFollowers => 'Noch keine Follower.';

  @override
  String get noFollowing => 'Folgt noch niemandem.';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get removeFollower => 'Follower entfernen';

  @override
  String removeFollowerBody(String username) {
    return '@$username aus deinen Followern entfernen? Die Person wird nicht benachrichtigt.';
  }

  @override
  String get removeAction => 'Entfernen';

  @override
  String get friends => 'Ihr seid befreundet';

  @override
  String get followRequests => 'Follower-Anfragen';

  @override
  String get noFollowRequests =>
      'Keine offenen Follower-Anfragen. Private Konten bestätigen Anfragen hier.';

  @override
  String get approve => 'Bestätigen';

  @override
  String get delete => 'Löschen';

  @override
  String get blockedAccounts => 'Blockierte Konten';

  @override
  String get noBlocked =>
      'Du hast niemanden blockiert. Blockieren geht über das Menü eines Profils.';

  @override
  String get unblock => 'Blockierung aufheben';

  @override
  String get onboardWho => 'Lass uns dich kennenlernen';

  @override
  String get onboardWhoHint =>
      'Wähle den Namen und Benutzernamen, die in deinem Profil stehen.';

  @override
  String get onboardPhoto => 'Profilbild';

  @override
  String get onboardPhotoHint =>
      'Damit dich deine Gruppen erkennen. Du kannst es auch später hinzufügen.';

  @override
  String get onboardInterests => 'Deine Interessen';

  @override
  String onboardInterestsHint(int max) {
    return 'Wähle bis zu $max, damit wir dir passende Gruppen vorschlagen können.';
  }

  @override
  String get back => 'Zurück';

  @override
  String stepOf(int step, int total) {
    return 'Schritt $step von $total';
  }

  @override
  String get signOut => 'Abmelden';

  @override
  String get skipForNow => 'Vorerst überspringen';

  @override
  String get continueAction => 'Weiter';

  @override
  String get finish => 'Fertig';

  @override
  String get usernameHelper => 'Kleinbuchstaben, Zahlen, _ und . sind erlaubt.';

  @override
  String get avatarPreview => 'Vorschau des Profilbilds';

  @override
  String get choosePhoto => 'Foto auswählen';

  @override
  String get chooseAnotherPhoto => 'Anderes Foto wählen';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Einstellungen';

  @override
  String get profileNotFound =>
      'Dieses Profil wurde nicht gefunden oder ist nicht mehr sichtbar.';

  @override
  String get backToMyProfile => 'Zurück zu meinem Profil';

  @override
  String suspendedUntil(String date) {
    return 'Dieses Konto ist bis $date gesperrt.';
  }

  @override
  String get followsYou => 'Folgt dir';

  @override
  String get yourTeammate => 'Dein Teammitglied';

  @override
  String joined(String date) {
    return 'Dabei seit $date';
  }

  @override
  String followRequestsPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Follower-Anfragen warten auf Bestätigung.',
      one: '1 Follower-Anfrage wartet auf Bestätigung.',
    );
    return '$_temp0';
  }

  @override
  String get review => 'Ansehen';

  @override
  String teammateRequestsPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Teamanfragen warten auf dich.',
      one: '1 Teamanfrage wartet auf dich.',
    );
    return '$_temp0';
  }

  @override
  String get youBlocked => 'Du hast dieses Konto blockiert';

  @override
  String get youBlockedHint =>
      'Wenn du die Blockierung aufhebst, seht ihr die Beiträge des anderen wieder.';

  @override
  String get privateAccount => 'Dieses Konto ist privat';

  @override
  String get privateAccountHint =>
      'Folge diesem Konto, um Fotos, Videos und Storys zu sehen.';

  @override
  String get addInterestsNudge =>
      'Füge deine Interessen hinzu, dann finden wir passende Gruppen und Teammitglieder.';

  @override
  String get add => 'Hinzufügen';

  @override
  String blockTitle(String username) {
    return '@$username blockieren?';
  }

  @override
  String get blockBody =>
      'Die Person sieht dein Profil, deine Beiträge und Storys nicht mehr, findet dich nicht und kann dir nicht schreiben. Ihr folgt euch nicht mehr. Sie erfährt nicht, dass du sie blockiert hast.';

  @override
  String get block => 'Blockieren';

  @override
  String get becomeTeammates => 'Teammitglied werden';

  @override
  String nowTeammates(String name) {
    return 'Du und $name seid jetzt Teammitglieder.';
  }

  @override
  String get acceptTeammate => 'Teamanfrage annehmen';

  @override
  String get requestWithdrawn => 'Anfrage zurückgezogen.';

  @override
  String get withdrawTeammate => 'Teamanfrage zurückziehen';

  @override
  String get teammateEnded => 'Teamverbindung beendet.';

  @override
  String get endTeammate => 'Teamverbindung beenden';

  @override
  String get moreOptions => 'Weitere Optionen';

  @override
  String get linkCopied => 'Profillink kopiert.';

  @override
  String get copyLink => 'Profillink kopieren';

  @override
  String get removedFromFollowers => 'Aus deinen Followern entfernt.';

  @override
  String get removeFromFollowers => 'Aus meinen Followern entfernen';

  @override
  String get report => 'Melden';

  @override
  String get unblocked => 'Blockierung aufgehoben.';

  @override
  String get statPosts => 'Beiträge';

  @override
  String get statFollowers => 'Follower';

  @override
  String get statFollowing => 'Folgt';

  @override
  String withdrawFollowBody(String username) {
    return 'Deine Follower-Anfrage an @$username zurückziehen?';
  }

  @override
  String unfollowBody(String username) {
    return '@$username nicht mehr folgen?';
  }

  @override
  String unfollowPrivateBody(String username) {
    return '@$username nicht mehr folgen? Das Konto ist privat; um die Beiträge zu sehen, müsstest du erneut anfragen.';
  }

  @override
  String get withdrawRequest => 'Anfrage zurückziehen';

  @override
  String get unfollow => 'Nicht mehr folgen';

  @override
  String get followBack => 'Zurückfolgen';

  @override
  String get follow => 'Folgen';

  @override
  String get requestSent => 'Angefragt';

  @override
  String get followingState => 'Folge ich';

  @override
  String noAccountMatch(String query) {
    return 'Keine Konten passen zu „$query“.';
  }

  @override
  String get clearSearch => 'Suche löschen';

  @override
  String get searchHint => 'Tippe, um nach Personen oder Tags zu suchen.';

  @override
  String get refreshSuggestions => 'Vorschläge aktualisieren';

  @override
  String get suggestionsForYou => 'Vorschläge für dich';

  @override
  String mutualFollows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Personen, denen du folgst, folgen diesem Konto',
      one: '1 Person, der du folgst, folgt diesem Konto',
    );
    return '$_temp0';
  }

  @override
  String get popularAccount => 'Beliebtes Konto';

  @override
  String get seePackage => 'Paket ansehen';

  @override
  String requestSentNotify(String name) {
    return 'Anfrage gesendet. Wir sagen dir Bescheid, wenn $name annimmt.';
  }

  @override
  String becomeTeammatesWith(String name) {
    return 'Mit $name ein Team werden';
  }

  @override
  String get shortMessage => 'Eine kurze Nachricht (optional)';

  @override
  String get shortMessageHint => 'Samstagmorgen im Park?';

  @override
  String get sendRequest => 'Anfrage senden';

  @override
  String get findTeammates => 'Teammitglieder finden';

  @override
  String get myTeammatePrefs => 'Meine Team-Einstellungen';

  @override
  String get tabSuggestions => 'Vorschläge';

  @override
  String get tabRequests => 'Anfragen';

  @override
  String tabRequestsCount(int count) {
    return 'Anfragen ($count)';
  }

  @override
  String get tabMyTeam => 'Mein Team';

  @override
  String get findYourTeammate => 'Finde dein Teammitglied';

  @override
  String waitingForYou(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Personen möchten mit dir ein Team werden',
      one: '1 Person möchte mit dir ein Team werden',
    );
    return '$_temp0';
  }

  @override
  String get teammatesLocked =>
      'Vorschläge sehen, Anfragen senden und annehmen und mit Teammitgliedern schreiben – das bietet das Teammitglied-Paket.';

  @override
  String get beVisible => 'Werde auch sichtbar';

  @override
  String get beVisibleBody =>
      'Aktiviere „Suche ein Team“, dann können dir Leute mit denselben Interessen Anfragen senden.';

  @override
  String get setPrefs => 'Einstellungen festlegen';

  @override
  String get nowPublicSuggest =>
      'Dein Konto ist jetzt öffentlich; du kannst in Vorschlägen erscheinen.';

  @override
  String get privateHidden =>
      'Dein Konto ist privat, du erscheinst nicht in Vorschlägen';

  @override
  String get privateHiddenBody =>
      'Private Konten erscheinen nicht in Teamvorschlägen. Wenn du dein Konto öffentlich machst, werden offene Follower-Anfragen ebenfalls angenommen.';

  @override
  String get makePublic => 'Mein Konto öffentlich machen';

  @override
  String get noSuggestions =>
      'Gerade passt niemand. Fülle Interessen und Einstellungen aus, um mehr Vorschläge zu erhalten.';

  @override
  String quoted(String text) {
    return '„$text“';
  }

  @override
  String get whySuggested => 'Warum vorgeschlagen';

  @override
  String get noPendingTeammate => 'Keine offenen Teamanfragen.';

  @override
  String get seeSuggestions => 'Vorschläge ansehen';

  @override
  String get incoming => 'Erhalten';

  @override
  String get accept => 'Annehmen';

  @override
  String get decline => 'Ablehnen';

  @override
  String get requestDeclined => 'Anfrage abgelehnt.';

  @override
  String get outgoing => 'Gesendet';

  @override
  String get awaitingReply => 'Wartet auf Antwort';

  @override
  String get withdraw => 'Zurückziehen';

  @override
  String get noTeammates =>
      'Du hast noch keine Teammitglieder. Sende zuerst einer vorgeschlagenen Person eine Anfrage.';

  @override
  String optionsFor(String name) {
    return 'Optionen für $name';
  }

  @override
  String get teammatePrefs => 'Team-Einstellungen';

  @override
  String get prefsSavedVisible =>
      'Einstellungen gespeichert. Du erscheinst jetzt in Vorschlägen.';

  @override
  String get prefsSaved => 'Einstellungen gespeichert.';

  @override
  String get whatToDo => 'Was möchtest du machen?';

  @override
  String activitiesHint(int max) {
    return 'Aktivitäten, für die du ein Team suchst. Bis zu $max.';
  }

  @override
  String get yourLevel => 'Dein Level';

  @override
  String get yourGoals => 'Deine Ziele';

  @override
  String get multipleChoice => 'Du kannst mehrere wählen.';

  @override
  String get howOften => 'Wie oft möchtest du dich treffen?';

  @override
  String get whenFree => 'Wann hast du Zeit?';

  @override
  String get whenFreeHint => 'Tippe auf die Zeiten, zu denen du kannst.';

  @override
  String get whatTeam => 'Was für ein Team möchtest du?';

  @override
  String get whichProvince => 'In welcher Provinz bist du?';

  @override
  String get provinceHint =>
      'Wird nur für Vorschläge genutzt und nicht im Profil angezeigt.';

  @override
  String get province => 'Provinz';

  @override
  String get ratherNotSay => 'Keine Angabe';

  @override
  String get extras => 'Weitere Angaben';

  @override
  String get iHaveVehicle => 'Ich habe ein Fahrzeug';

  @override
  String get iHaveVehicleHint => 'Ich kann Mitfahrgelegenheiten anbieten.';

  @override
  String get iHaveEquipment => 'Ich habe eigene Ausrüstung';

  @override
  String get iHaveEquipmentHint =>
      'Fahrrad, Zelt, Schläger oder andere Ausrüstung habe ich.';

  @override
  String get describeYourself => 'Beschreib dich';

  @override
  String get describeHint => 'Erscheint in Vorschlägen unter deinem Namen.';

  @override
  String get describeExample =>
      'Suche Begleitung für Wochenend-Wanderungen am Morgen.';

  @override
  String get willAppear => 'Du erscheinst in Vorschlägen.';

  @override
  String get notAppearing => 'Du erscheinst gerade nicht in Vorschlägen.';

  @override
  String get lookingForTeam => 'Ich suche ein Team';

  @override
  String get lookingOn =>
      'Du erscheinst in Vorschlägen; andere können dir Teamanfragen senden.';

  @override
  String get lookingOff =>
      'Wenn du es aktivierst, finden dich Leute mit denselben Interessen. Private Konten erscheinen nicht in Vorschlägen.';

  @override
  String prefsComplete(int percent) {
    return 'Einstellungen zu $percent % ausgefüllt';
  }

  @override
  String get prefsCompleteHint =>
      'Je mehr du ausfüllst, desto besser die Vorschläge.';

  @override
  String get weekday => 'Werktags';

  @override
  String get weekend => 'Wochenende';

  @override
  String get username => 'Benutzername';

  @override
  String get available => 'Verfügbar';

  @override
  String get taken => 'Vergeben';
}
