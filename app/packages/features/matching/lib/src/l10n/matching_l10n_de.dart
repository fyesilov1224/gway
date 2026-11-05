// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'matching_l10n.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class MatchingL10nDe extends MatchingL10n {
  MatchingL10nDe([String locale = 'de']) : super(locale);

  @override
  String get unsupportedImage =>
      'Nur JPEG-, PNG- oder WebP-Fotos können hochgeladen werden.';

  @override
  String get modeFriend => 'Freundschaft';

  @override
  String get modeDating => 'Dating';

  @override
  String get genderWoman => 'Frau';

  @override
  String get genderMan => 'Mann';

  @override
  String get genderNonbinary => 'Nicht-binär';

  @override
  String get adultsOnly => 'Matching ist nur für Personen ab 18.';

  @override
  String get pickMode =>
      'Wähle mindestens einen Modus: Freundschaft oder Dating.';

  @override
  String get pickInterest => 'Wähle für Dating, wen du suchst.';

  @override
  String get ageRangeInvalid => 'Der Altersbereich ist ungültig.';

  @override
  String sharedGroup(String group) {
    return 'Gemeinsame Gruppe: $group';
  }

  @override
  String sharedGroupsMore(String group, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Gemeinsam: $group und $count weitere Gruppen',
      one: 'Gemeinsam: $group und 1 weitere Gruppe',
    );
    return '$_temp0';
  }

  @override
  String get pkgReveal => 'Meine Matches';

  @override
  String get pkgRevealText =>
      'Sieh, mit wem du ein Match hast: Name, Fotos und Profil.';

  @override
  String get pkgChat => 'Match-Chat';

  @override
  String get pkgChatText =>
      'Schreib deinen Matches. Enthält auch „Meine Matches“.';

  @override
  String get pkgAdmirers => 'Wer dich mag';

  @override
  String get pkgAdmirersText =>
      'Sieh, wer dich mag, und matche sofort mit einem Like zurück.';

  @override
  String get pkgUnlimited => 'Unbegrenzte Likes';

  @override
  String get pkgUnlimitedText =>
      'Kein tägliches Like-Limit; Rückgängig und Filter inklusive.';

  @override
  String get pkgSuper => 'Super-Like';

  @override
  String get pkgSuperText =>
      '5 Super-Likes pro Tag; die Person sieht dich zuerst in ihrem Stapel.';

  @override
  String get pkgBoost => 'Boost';

  @override
  String get pkgBoostText =>
      'Einmal am Tag 30 Minuten ganz oben in den Stapeln deiner gemeinsamen Gruppen.';

  @override
  String get pkgTeammates => 'Teammitglied';

  @override
  String get pkgTeammatesText =>
      'Sende Teamanfragen und chatte mit deinen Teammitgliedern.';

  @override
  String get pkgAll => 'Alles in einem';

  @override
  String get pkgAllText => 'Alle Pakete in einem, viel günstiger als einzeln.';

  @override
  String get superLikedYou => 'Hat dir ein Super-Like gegeben';

  @override
  String get options => 'Optionen';

  @override
  String get fullProfile => 'Ganzes Profil';

  @override
  String get stampLike => 'LIKE';

  @override
  String get stampPass => 'NOPE';

  @override
  String get stampSuper => 'SUPER';

  @override
  String photoOf(String name, int number) {
    return '$name, Foto $number';
  }

  @override
  String get about => 'Über mich';

  @override
  String get interests => 'Interessen';

  @override
  String get sharedGroupsTitle => 'Gemeinsame Gruppen';

  @override
  String get createProfileTitle => 'Matching-Profil erstellen';

  @override
  String get myProfile => 'Mein Matching-Profil';

  @override
  String get birthDateLabel => 'Dein Geburtsdatum';

  @override
  String get pickBasics => 'Wähle Geburtsdatum, Geschlecht und Provinz.';

  @override
  String get confirmAgeConsent =>
      'Bestätige zum Fortfahren, dass du über 18 bist, und gib deine ausdrückliche Einwilligung.';

  @override
  String profileReady(int min) {
    return 'Dein Profil ist fertig. Füge jetzt mindestens $min Fotos hinzu.';
  }

  @override
  String get saved => 'Gespeichert.';

  @override
  String get pickBirthDate => 'Geburtsdatum wählen';

  @override
  String ageNote(int age) {
    return '$age Jahre · deine Karte zeigt nur dein Alter';
  }

  @override
  String get gender => 'Geschlecht';

  @override
  String get province => 'Provinz';

  @override
  String get aboutHint => 'Erzähl etwas über dich';

  @override
  String get jobOptional => 'Beruf (optional)';

  @override
  String get educationOptional => 'Ausbildung (optional)';

  @override
  String get interestsFromProfile =>
      'Deine Interessen stammen aus deinem sozialen Profil.';

  @override
  String get lookingFor => 'Was suchst du?';

  @override
  String get friendHint => 'Leute für Events und Gespräche';

  @override
  String get datingHint => 'Eine romantische Beziehung';

  @override
  String get whoLookingFor => 'Wen suchst du?';

  @override
  String ageRange(int min, int max) {
    return 'Altersbereich: $min–$max';
  }

  @override
  String get consentTitle => 'Einwilligung';

  @override
  String get iam18 => 'Ich bin über 18.';

  @override
  String get consentText =>
      'Ich willige ausdrücklich ein, dass für das Matching mein Geschlecht, wen ich suche, mein Geburtsdatum, meine Provinz und meine Fotos verarbeitet und Personen in meinen gemeinsamen Gruppen mit aktiviertem Matching gezeigt werden. Ich kann meine Einwilligung jederzeit widerrufen, indem ich meine Matching-Daten lösche.';

  @override
  String get createProfile => 'Profil erstellen';

  @override
  String get save => 'Speichern';

  @override
  String get photos => 'Fotos';

  @override
  String photosMin(int min) {
    return 'Füge mindestens $min Fotos hinzu, damit deine Karte erscheint. Das erste ist das Titelbild.';
  }

  @override
  String photosMax(int max) {
    return 'Höchstens $max Fotos. Das erste ist das Titelbild; tippe auf ein Foto, um es zu ändern.';
  }

  @override
  String get addPhoto => 'Foto hinzufügen';

  @override
  String get cover => 'Titelbild';

  @override
  String get removePhoto => 'Foto entfernen';

  @override
  String get pauseProfile => 'Profil pausieren';

  @override
  String get pauseHint =>
      'Niemand sieht dich und es kommen keine neuen Karten; Matches und Chats bleiben.';

  @override
  String get deleteData => 'Meine Matching-Daten löschen';

  @override
  String get deleteDataHint =>
      'Profil, Fotos und Likes werden gelöscht; deine Matches enden. Deine Einwilligung gilt als widerrufen.';

  @override
  String get deleteDataTitle => 'Matching-Daten löschen';

  @override
  String get deleteDataBody =>
      'Dein Matching-Profil, deine Fotos und Likes werden endgültig gelöscht; alle Matches enden. Das kann nicht rückgängig gemacht werden.';

  @override
  String get delete => 'Löschen';

  @override
  String get dataDeleted => 'Deine Matching-Daten wurden gelöscht.';

  @override
  String get itsAMatch => 'It\'s a Match!';

  @override
  String bothLiked(String name) {
    return 'Du und $name mögt euch gegenseitig.';
  }

  @override
  String get keepSwiping => 'Weiter swipen';

  @override
  String get sendMessage => 'Nachricht senden';

  @override
  String get reportProfile => 'Profil melden';

  @override
  String get reportPhoto => 'Dieses Foto melden';

  @override
  String get block => 'Blockieren';

  @override
  String get blockHint => 'Ihr seht euch nirgends mehr.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get newMatch => 'Du hast ein Match!';

  @override
  String tapToSee(String date) {
    return 'Tippe, um zu sehen, wer es ist · $date';
  }

  @override
  String get revealReason =>
      'Du hast ein Match! Hol dir das Paket Meine Matches, um zu sehen, wer es ist.';

  @override
  String get keepFriend => 'Nur Freundschaft';

  @override
  String get keepDating => 'Nur Dating';

  @override
  String keepFriendBody(String name) {
    return 'Euer Dating-Match mit $name endet für euch beide; Freundschafts-Match und Chat bleiben.';
  }

  @override
  String keepDatingBody(String name) {
    return 'Euer Freundschafts-Match mit $name endet für euch beide; Dating-Match und Chat bleiben.';
  }

  @override
  String get keptFriend => 'Ihr seid jetzt nur noch als Freunde gematcht.';

  @override
  String get keptDating => 'Ihr seid jetzt nur noch fürs Dating gematcht.';

  @override
  String get continueAction => 'Weiter';

  @override
  String get endMatch => 'Match beenden';

  @override
  String endMatchBody(String name) {
    return 'Dein Match mit $name endet und euer Chat wird für euch beide geschlossen. Das kann nicht rückgängig gemacht werden.';
  }

  @override
  String get end => 'Beenden';

  @override
  String get matchEnded => 'Das Match ist beendet.';

  @override
  String get noMatches =>
      'Noch keine Matches. Personen, die ihr euch gegenseitig mögt, erscheinen hier.';

  @override
  String get backToDiscover => 'Zurück zum Entdecken';

  @override
  String get report => 'Melden';

  @override
  String get matching => 'Matching';

  @override
  String get admirers => 'Wer dich mag';

  @override
  String get packages => 'Pakete';

  @override
  String get more => 'Mehr';

  @override
  String get filtersLocked =>
      'Filter nach Alter, Provinz und Interesse gibt es mit dem Paket Unbegrenzte Likes.';

  @override
  String get filters => 'Filter';

  @override
  String get suspended =>
      'Dein Matching-Profil wurde vom Plattform-Team geschlossen. Schreib dem Support für Details.';

  @override
  String addPhotosToStart(int min) {
    return 'Füge mindestens $min Fotos hinzu, damit deine Karte erscheint und du loslegen kannst.';
  }

  @override
  String get paused =>
      'Dein Profil ist pausiert; niemand sieht dich. Matches und Chats bleiben.';

  @override
  String get likesOut =>
      'Deine kostenlosen Likes für heute sind aufgebraucht. Mit Unbegrenzte Likes so viel du willst.';

  @override
  String get supersOut =>
      'Deine Super-Likes für heute sind aufgebraucht. Morgen gibt es neue.';

  @override
  String get superUsed =>
      'Du hast deinen Super-Like für heute genutzt. Mit dem Super-Like-Paket 5 pro Tag.';

  @override
  String get rewindLocked =>
      'Versehentlich übersprungene Personen zurückholen gibt es mit Unbegrenzte Likes.';

  @override
  String rewoundTo(String mode) {
    return 'Die zuletzt übersprungene Person ist zurück im Stapel $mode.';
  }

  @override
  String boostReason(int minutes) {
    return 'Mit einem Boost erscheinst du $minutes Minuten ganz oben in den Stapeln.';
  }

  @override
  String boosting(int minutes) {
    return 'Du bist geboostet. Noch $minutes Minuten.';
  }

  @override
  String get boostUsed =>
      'Du hast deinen Boost für heute genutzt. Morgen gibt es einen neuen.';

  @override
  String get boost => 'Boosten';

  @override
  String boostBody(int minutes) {
    return '$minutes Minuten lang erscheinst du zuerst in den Stapeln deiner gemeinsamen Gruppen. Einmal pro Tag.';
  }

  @override
  String boosted(int minutes) {
    return 'Geboostet! Du bist $minutes Minuten ganz oben.';
  }

  @override
  String get deckEmpty =>
      'Gerade ist niemand mehr da. Hier wird es voller, wenn du Gruppen beitrittst und andere Matching aktivieren.';

  @override
  String get deckEmptyFiltered =>
      'Niemand passt mehr zu deinen Filtern. Erweitere sie.';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get clearFilters => 'Filter zurücksetzen';

  @override
  String allowanceUnlimited(int supers) {
    return 'Unbegrenzte Likes · noch $supers Super-Likes.';
  }

  @override
  String get allowanceOut =>
      'Deine Likes für heute sind aufgebraucht; morgen gibt es neue.';

  @override
  String allowance(int likes, int supers) {
    return 'Heute hast du noch $likes Likes und $supers Super-Likes.';
  }

  @override
  String get undo => 'Rückgängig';

  @override
  String get pass => 'Überspringen';

  @override
  String get superLike => 'Super-Like';

  @override
  String get like => 'Like';

  @override
  String get introTitle =>
      'Lerne neue Leute aus deinen gemeinsamen Gruppen kennen';

  @override
  String get intro1 =>
      'Du siehst nur Personen mit aktiviertem Matching aus Gruppen, in denen du bist oder denen du folgst.';

  @override
  String get intro2 =>
      'Wische nach rechts für Like, nach links zum Überspringen, nach oben für Super-Like.';

  @override
  String get intro3 =>
      'Mögt ihr euch gegenseitig, habt ihr ein Match. Schreiben kannst du mit dem Paket Match-Chat.';

  @override
  String get intro4 =>
      'Freundschaft und Dating sind getrennte Modi; wähle einen oder beide.';

  @override
  String get intro5 =>
      'Dein Profil sehen nur Personen mit aktiviertem Matching. Pausiere oder lösche es jederzeit.';

  @override
  String get createMyProfile => 'Mein Matching-Profil erstellen';

  @override
  String seePackageOf(String package) {
    return 'Paket $package ansehen';
  }

  @override
  String get allPackages => 'Alle Pakete';

  @override
  String get packagesTitle => 'Matching-Pakete';

  @override
  String get packagesIntro =>
      'Profil und Swipen sind kostenlos. Jede Funktion ist ein eigenes Paket; nimm nur, was du willst.';

  @override
  String get adminAllOpen => 'Als Admin sind alle Pakete für dich aktiv';

  @override
  String openUntil(String date) {
    return 'Aktiv bis $date';
  }

  @override
  String ageFilter(int min, int max) {
    return 'Alter: $min – $max';
  }

  @override
  String get allProvinces => 'Alle Provinzen';

  @override
  String get interest => 'Interesse';

  @override
  String get all => 'Alle';

  @override
  String get apply => 'Anwenden';

  @override
  String get clear => 'Zurücksetzen';

  @override
  String get noAdmirers =>
      'Gerade keine offenen Likes. Swipe weiter; wer dich mag, erscheint hier.';

  @override
  String get backToSwiping => 'Zurück zum Swipen';

  @override
  String get likeAndMatch => 'Liken und matchen';

  @override
  String get noPendingLikes => 'Noch keine offenen Likes';

  @override
  String likedYouCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Personen mögen dich',
      one: '1 Person mag dich',
    );
    return '$_temp0';
  }

  @override
  String get admirersPitch =>
      'Mit dem Paket Wer dich mag siehst du, wer es ist, und matchst sofort mit einem Like.';

  @override
  String get seePackage => 'Paket ansehen';
}
