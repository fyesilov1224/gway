// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'messaging_l10n.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class MessagingL10nDe extends MessagingL10n {
  MessagingL10nDe([String locale = 'de']) : super(locale);

  @override
  String get groupInvalid =>
      'Du kannst die Anfrage nur an eine Gruppe senden, in der du Mitglied bist.';

  @override
  String get permissionExists =>
      'Deine Anfrage liegt bereits vor oder deine Berechtigung ist aktiv.';

  @override
  String get permissionCooldown =>
      'Eine neue Anfrage ist 7 Tage nach der letzten Entscheidung möglich.';

  @override
  String noteTooLong(int max) {
    return 'Die Notiz darf höchstens $max Zeichen lang sein.';
  }

  @override
  String get requestForbidden =>
      'Die Anfrage kann gerade nicht gesendet werden.';

  @override
  String get unsupportedImage =>
      'Dieser Dateityp wird nicht unterstützt. Wähle JPEG, PNG oder WebP.';

  @override
  String get voiceCallHandle => 'GWAY-Sprachanruf';

  @override
  String get incomingCalls => 'Eingehende Anrufe';

  @override
  String get missedCalls => 'Verpasste Anrufe';

  @override
  String get answer => 'Annehmen';

  @override
  String get decline => 'Ablehnen';

  @override
  String get noAnswer => 'Keine Antwort';

  @override
  String get missedCall => 'Verpasster Anruf';

  @override
  String get callDeclined => 'Anruf abgelehnt';

  @override
  String get youDeclined => 'Du hast den Anruf abgelehnt';

  @override
  String get callNotAllowed => 'Anrufen ist nicht mehr möglich';

  @override
  String get callCanceled => 'Anruf abgebrochen';

  @override
  String get timeLimit => '60 Minuten sind um; der Anruf ist beendet';

  @override
  String get endedNotAllowed =>
      'Anruf beendet: Sprachanrufe sind nicht mehr möglich';

  @override
  String get callEnded => 'Anruf beendet';

  @override
  String get messageDeleted => 'Nachricht gelöscht';

  @override
  String get photo => 'Foto';

  @override
  String get tonightTable => 'Tisch heute Abend';

  @override
  String get blockRequestPending =>
      'Nimm die Nachrichtenanfrage an, bevor du antwortest.';

  @override
  String get blockDeclined =>
      'Diese Person hat deine Nachrichtenanfrage nicht angenommen.';

  @override
  String get blockMuted =>
      'Du bist in dieser Gruppe stummgeschaltet und kannst gerade nicht schreiben.';

  @override
  String get blockAdminsOnly => 'In diesem Chat können nur Admins schreiben.';

  @override
  String get blockTableClosed =>
      'Der Tisch ist geschlossen; du kannst lesen, aber nichts Neues schreiben.';

  @override
  String get blockBlocked =>
      'Wegen einer Blockierung kannst du hier nicht schreiben.';

  @override
  String get blockMatchEnded =>
      'Dieser Chat ist geschlossen, weil das Match beendet wurde.';

  @override
  String get blockMatchLocked =>
      'Um deinem Match zu schreiben, brauchst du das Paket Match-Chat. Lesen ist kostenlos.';

  @override
  String get blockTeammateLocked =>
      'Um deinem Teammitglied zu schreiben, brauchst du das Teammitglied-Paket. Lesen ist kostenlos.';

  @override
  String get blockNotAllowed =>
      'Direktnachrichten gibt es jetzt nur zwischen Matches und Teammitgliedern. Alte Nachrichten kannst du weiter lesen.';

  @override
  String get blockOther => 'Du kannst gerade nicht in diesem Chat schreiben.';

  @override
  String get hiddenUser => 'GWAY-Nutzer:in';

  @override
  String get voiceCalls => 'Sprachanrufe';

  @override
  String get voiceCallsHeadline =>
      'Sprich mit deinen Matches und Teammitgliedern';

  @override
  String voiceCallsIntro(int minutes) {
    return 'Mit Sprachanrufen rufst du Matches und Teammitglieder aus dem privaten Chat an. Sie stehen nicht allen offen: Du beantragst sie bei einer deiner Gruppen, Inhaber:in oder Admin schalten sie frei. Anrufe werden nie aufgezeichnet oder mitgehört; ein Anruf dauert höchstens $minutes Minuten.';
  }

  @override
  String get status => 'Status';

  @override
  String get notRequested => 'Nicht beantragt';

  @override
  String get underReview => 'Wird geprüft';

  @override
  String get statusOn => 'Aktiv';

  @override
  String get statusOff => 'Aus';

  @override
  String get notRequestedYet => 'Du hast es noch nicht beantragt.';

  @override
  String requestedFrom(String group) {
    return 'Deine Anfrage ist bei den Admins von $group angekommen. Du wirst benachrichtigt, sobald sie entscheiden.';
  }

  @override
  String get requestedFromGroup =>
      'Deine Anfrage ist bei den Gruppenadmins angekommen. Du wirst benachrichtigt, sobald sie entscheiden.';

  @override
  String activeFrom(String group) {
    return 'Deine Sprachanrufe sind aktiv ($group). Ruf Matches und Teammitglieder über das Telefonsymbol oben im Chat an; sie brauchen auch die Berechtigung.';
  }

  @override
  String get active =>
      'Deine Sprachanrufe sind aktiv. Ruf Matches und Teammitglieder über das Telefonsymbol oben im Chat an; sie brauchen auch die Berechtigung.';

  @override
  String get declined => 'Deine Anfrage wurde vorerst nicht angenommen.';

  @override
  String get revokedLeftGroup =>
      'Deine Sprachanrufe sind aus, weil du die freigebende Gruppe verlassen hast. Du kannst sie bei einer anderen Gruppe neu beantragen.';

  @override
  String get revoked => 'Deine Sprachanrufe wurden ausgeschaltet.';

  @override
  String reasonLine(String reason) {
    return 'Grund: $reason';
  }

  @override
  String yourNote(String note) {
    return 'Deine Notiz: $note';
  }

  @override
  String waitUntil(String date) {
    return 'Nach dem $date kannst du es erneut beantragen.';
  }

  @override
  String get requestSent => 'Deine Anfrage wurde gesendet.';

  @override
  String get joinGroupFirst =>
      'Gruppeninhaber:innen und Admins schalten Sprachanrufe frei. Tritt zuerst einer Gruppe bei, um sie zu beantragen.';

  @override
  String get requestToGroup => 'Gruppe für die Anfrage';

  @override
  String get noteOptional => 'Notiz (optional)';

  @override
  String get noteHint =>
      'Du kannst kurz schreiben, warum du Sprachanrufe möchtest.';

  @override
  String get request => 'Beantragen';

  @override
  String get lockScreenCalls => 'Anrufe auf dem Sperrbildschirm';

  @override
  String get lockScreenHint =>
      'Erlaube GWAY, bei gesperrtem Telefon im Vollbild zu klingeln.';

  @override
  String get allow => 'Erlauben';

  @override
  String get callInfoFailed =>
      'Anrufdaten konnten nicht geladen werden. Prüfe deine Verbindung.';

  @override
  String get tapEndToHangUp => 'Tippe auf Beenden, um aufzulegen.';

  @override
  String get callNotFound => 'Dieser Anruf wurde nicht gefunden.';

  @override
  String get close => 'Schließen';

  @override
  String callLimitNote(int minutes) {
    return 'Ein Anruf dauert höchstens $minutes Minuten und wird nie aufgezeichnet.';
  }

  @override
  String get audioFailed =>
      'Audio konnte nicht verbunden werden. Prüfe deine Verbindung und versuche es erneut.';

  @override
  String get reconnect => 'Erneut verbinden';

  @override
  String get incoming => 'ruft dich an…';

  @override
  String get calling => 'Wird angerufen…';

  @override
  String get connecting => 'Verbinden…';

  @override
  String get answerCall => 'Annehmen';

  @override
  String get mute => 'Stumm';

  @override
  String get unmute => 'Ton an';

  @override
  String get end => 'Beenden';

  @override
  String get speaker => 'Lautsprecher';

  @override
  String get peerUnencrypted =>
      'Die App der anderen Person ist veraltet; der Ton ist unverschlüsselt und wird nicht abgespielt. Bitte sie, die App zu aktualisieren.';

  @override
  String get encrypting => 'Verschlüsselte Verbindung wird aufgebaut…';

  @override
  String e2eeCode(String code) {
    return 'Ende-zu-Ende-verschlüsselt. Sicherheitscode $code';
  }

  @override
  String get e2ee => 'Ende-zu-Ende-verschlüsselt';

  @override
  String get codeMatchHint =>
      'Wenn dieser Code mit dem auf dem anderen Bildschirm übereinstimmt, kann niemand mithören.';

  @override
  String get micFailed =>
      'Das Mikro konnte nicht eingeschaltet werden. Prüfe die Mikrofon-Berechtigung.';

  @override
  String get chatNotFound =>
      'Dieser Chat wurde nicht gefunden oder ist für dich nicht mehr sichtbar.';

  @override
  String get backToMessages => 'Zurück zu den Nachrichten';

  @override
  String get cantCallNow => 'Anrufen ist gerade nicht möglich.';

  @override
  String get voiceCall => 'Sprachanruf';

  @override
  String get groupChatAdminsOnly => 'Gruppenchat · nur Admins schreiben';

  @override
  String get groupChat => 'Gruppenchat';

  @override
  String smallTableMembers(int count) {
    return 'Kleiner Tisch · $count Personen';
  }

  @override
  String get adminsOnlyOn =>
      'Jetzt können nur Inhaber:in und Admins in diesem Chat schreiben.';

  @override
  String get adminsOnlyOff =>
      'Jetzt können alle Gruppenmitglieder in diesem Chat schreiben.';

  @override
  String get chatSettings => 'Chat-Einstellungen';

  @override
  String get adminsOnlyToggle => 'Nur Admins schreiben';

  @override
  String get sendingPhoto => '📷 Foto wird gesendet…';

  @override
  String get requestPendingNote =>
      'Deine Nachrichtenanfrage wurde gesendet. Bis sie angenommen ist, siehst du nicht, ob sie gelesen wurde.';

  @override
  String get groupChatEmpty =>
      'Noch keine Nachrichten im Gruppenchat. Schreib die erste.';

  @override
  String get chatEmpty => 'Noch keine Nachrichten. Schreib die erste.';

  @override
  String get startWriting => 'Schreiben';

  @override
  String get sending => 'Wird gesendet…';

  @override
  String get seen => 'Gesehen';

  @override
  String get sent => 'Gesendet';

  @override
  String get seePackage => 'Paket ansehen';

  @override
  String get today => 'Heute';

  @override
  String get messageRemoved => 'Diese Nachricht wurde entfernt.';

  @override
  String get thisMessageDeleted => 'Diese Nachricht wurde gelöscht.';

  @override
  String get messageOptions => 'Nachrichtenoptionen';

  @override
  String profileOf(String name) {
    return 'Profil von $name';
  }

  @override
  String get you => 'Du';

  @override
  String get copy => 'Kopieren';

  @override
  String get copied => 'Nachricht kopiert.';

  @override
  String get deleteForAll => 'Für alle löschen';

  @override
  String get report => 'Melden';

  @override
  String get deleteForAllTitle => 'Nachricht für alle löschen?';

  @override
  String get deleteForAllBody =>
      'Alle im Chat sehen „Diese Nachricht wurde gelöscht“. Das kann nicht rückgängig gemacht werden.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get requestDeleted => 'Nachrichtenanfrage gelöscht.';

  @override
  String wantsToMessage(String name) {
    return '$name möchte dir schreiben. Wenn du annimmst, könnt ihr chatten und die Person sieht, wenn du gelesen hast.';
  }

  @override
  String get accept => 'Annehmen';

  @override
  String get removePhoto => 'Foto entfernen';

  @override
  String get addPhoto => 'Foto hinzufügen';

  @override
  String get writeMessage => 'Nachricht schreiben';

  @override
  String get send => 'Senden';

  @override
  String get messages => 'Nachrichten';

  @override
  String get chats => 'Chats';

  @override
  String get requests => 'Anfragen';

  @override
  String requestsCount(int count) {
    return 'Anfragen ($count)';
  }

  @override
  String get noChats =>
      'Du hast noch keine Chats. Du kannst deinen Matches und Teammitgliedern schreiben.';

  @override
  String get findPeople => 'Leute finden';

  @override
  String get oldRequestsNote =>
      'Alte Nachrichtenanfragen bleiben hier. Direktnachrichten gibt es nur noch zwischen Matches und Teammitgliedern; neue Anfragen kommen nicht.';

  @override
  String get noRequests => 'Keine offenen Nachrichtenanfragen.';

  @override
  String get backToChats => 'Zurück zu den Chats';

  @override
  String get callRequests => 'Anfragen für Sprachanrufe';

  @override
  String noPendingWithActive(int count) {
    return 'Keine offenen Anfragen · $count aktiv';
  }

  @override
  String pendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Anfragen offen',
      one: '1 Anfrage offen',
    );
    return '$_temp0';
  }

  @override
  String get pending => 'Offen';

  @override
  String get activeTab => 'Aktiv';

  @override
  String get requestsOwnersOnly =>
      'Nur Inhaber:in und Admins sehen Anfragen für Sprachanrufe.';

  @override
  String get goBack => 'Zurück';

  @override
  String noPendingFor(String group) {
    return 'Keine offenen Anfragen. Anfragen von Mitgliedern von $group erscheinen hier.';
  }

  @override
  String get noActive => 'Diese Gruppe hat keine Sprachanrufe freigegeben.';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get grantHint =>
      'Mit deiner Freigabe kann die Person alle Matches und Teammitglieder anrufen. Anrufe werden nie aufgezeichnet; verlässt sie die Gruppe, endet die Freigabe.';

  @override
  String get granted => 'Sprachanrufe aktiviert.';

  @override
  String get turnedOff => 'Sprachanrufe deaktiviert.';

  @override
  String theirNote(String note) {
    return 'Notiz: $note';
  }

  @override
  String get turnOff => 'Ausschalten';

  @override
  String get turnOn => 'Einschalten';

  @override
  String get rankOnlyGrant =>
      'Der Rang ist gleich oder höher als deiner; du kannst diese Anfrage nur annehmen.';

  @override
  String get rankCannotRevoke =>
      'Der Rang ist gleich oder höher als deiner; du kannst das nicht ausschalten.';

  @override
  String get declineRequest => 'Anfrage ablehnen';

  @override
  String get turnOffCalls => 'Sprachanrufe ausschalten';

  @override
  String get declineHint =>
      'Die Person sieht den Grund und kann nach 7 Tagen erneut anfragen.';

  @override
  String get revokeHint =>
      'Ein laufender Anruf endet sofort. Die Person sieht den Grund und kann nach 7 Tagen erneut anfragen.';

  @override
  String get reason => 'Grund';

  @override
  String get reasonMin3 => 'Der Grund muss mindestens 3 Zeichen lang sein.';

  @override
  String get yesterday => 'Gestern';

  @override
  String get sendMessage => 'Nachricht senden';

  @override
  String get groupChatMembersOnly =>
      'Nur Gruppenmitglieder sehen den Gruppenchat.';

  @override
  String get callVerifying => 'Verschlüsselung wird geprüft …';

  @override
  String get callSecure => 'Sicheres Gespräch';

  @override
  String get callSecureDetail =>
      'Ende-zu-Ende-verschlüsselt. Die Sicherheitscodes beider Telefone stimmen überein, niemand hört mit.';

  @override
  String get callCheckFailed =>
      'Verschlüsselung nicht bestätigt: Die Sicherheitscodes der Telefone stimmen nicht überein. Beende das Gespräch und rufe erneut an.';

  @override
  String get showSecurityCode => 'Sicherheitscode anzeigen';
}
