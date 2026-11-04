// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'identity_l10n.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class IdentityL10nDe extends IdentityL10n {
  IdentityL10nDe([String locale = 'de']) : super(locale);

  @override
  String get authInvalidCredentials =>
      'E-Mail-Adresse oder Passwort ist falsch.';

  @override
  String get authEmailNotConfirmed =>
      'Du hast deine E-Mail-Adresse noch nicht bestätigt. Sieh in deinem Posteingang nach.';

  @override
  String get authEmailExists =>
      'Mit dieser E-Mail-Adresse gibt es bereits ein Konto. Versuche, dich anzumelden.';

  @override
  String get authWeakPassword =>
      'Das Passwort muss mindestens 8 Zeichen lang sein und Groß- und Kleinbuchstaben sowie eine Zahl enthalten.';

  @override
  String get authSamePassword =>
      'Dein neues Passwort muss sich vom alten unterscheiden.';

  @override
  String get authInvalidEmail => 'Gib eine gültige E-Mail-Adresse ein.';

  @override
  String get authUserBanned =>
      'Du kannst dich nicht anmelden, weil dein Konto gesperrt ist.';

  @override
  String get authProviderDisabled =>
      'Diese Anmeldemethode ist gerade nicht verfügbar.';

  @override
  String ageMinimum(int age) {
    return 'Du musst mindestens $age Jahre alt sein, um GWAY zu nutzen.';
  }

  @override
  String get deletionPendingTitle => 'Dein Konto wird bald gelöscht';

  @override
  String get deletionRequested =>
      'Wir haben deine Anfrage zur Kontolöschung erhalten.';

  @override
  String deletionScheduled(String date) {
    return 'Dein Konto und alle deine Daten werden am $date endgültig gelöscht. Bis dahin kannst du es dir anders überlegen.';
  }

  @override
  String get undoDeletion => 'Löschung abbrechen';

  @override
  String get signOut => 'Abmelden';

  @override
  String get bannedTitle => 'Dein Konto wurde dauerhaft geschlossen';

  @override
  String get suspendedTitle => 'Dein Konto wurde gesperrt';

  @override
  String get bannedBody =>
      'Das Plattform-Team hat dein Konto dauerhaft geschlossen. Dein Profil ist für niemanden mehr sichtbar.';

  @override
  String suspendedBody(String date) {
    return 'Dein Konto ist bis $date gesperrt. In dieser Zeit kannst du die App nicht nutzen; in deinem Profil ist die Sperre sichtbar.';
  }

  @override
  String banReason(String reason) {
    return 'Grund der Sperre: $reason';
  }

  @override
  String suspensionReason(String reason) {
    return 'Grund der Sperrung: $reason';
  }

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get deleteAccount => 'Konto löschen';

  @override
  String get beforeDeleting => 'Bevor du dein Konto löschst';

  @override
  String get deletionHidesNow =>
      'Dein Profil wird sofort ausgeblendet; niemand kann dich finden.';

  @override
  String deletionGraceRestore(int days) {
    return 'Du kannst dich innerhalb von $days Tagen anmelden und die Löschung abbrechen.';
  }

  @override
  String get deletionAfterGrace =>
      'Danach werden dein Profil, deine Fotos und alle deine Daten endgültig gelöscht.';

  @override
  String get deletionUnderstood =>
      'Ich habe verstanden und möchte mein Konto löschen.';

  @override
  String get deleteMyAccount => 'Mein Konto löschen';

  @override
  String get heroTitle => 'Deine Community wartet auf dich.';

  @override
  String get heroBody =>
      'Vom Wandern bis zur Musik, vom Laufen bis zur Kunst: Finde deine Gruppe, plant gemeinsam und seid zur gleichen Zeit dort.';

  @override
  String get heroPointGroups =>
      'Tritt Gruppen bei oder gründe deine eigene Community';

  @override
  String get heroPointEvents =>
      'Füge Events deinem Kalender hinzu und finde Teammitglieder';

  @override
  String get heroPointLive => 'Triff deine Gruppe in Live-Audio-Chats';

  @override
  String get showPassword => 'Passwort anzeigen';

  @override
  String get hidePassword => 'Passwort verbergen';

  @override
  String get signIn => 'Anmelden';

  @override
  String get signInSubtitle =>
      'Mach mit deinen Gruppen und Freunden dort weiter, wo du aufgehört hast.';

  @override
  String get email => 'E-Mail';

  @override
  String get password => 'Passwort';

  @override
  String get forgotPassword => 'Passwort vergessen?';

  @override
  String get continueWithGoogle => 'Weiter mit Google';

  @override
  String get continueWithApple => 'Weiter mit Apple';

  @override
  String get noAccountSignUp => 'Noch kein Konto? Registrieren';

  @override
  String get signUp => 'Registrieren';

  @override
  String get signUpSubtitle =>
      'Finde deine Gruppen, nimm an Events teil und lerne neue Leute kennen.';

  @override
  String get passwordRepeat => 'Passwort bestätigen';

  @override
  String get passwordsDontMatch => 'Die Passwörter stimmen nicht überein.';

  @override
  String get haveAccountSignIn => 'Schon ein Konto? Anmelden';

  @override
  String get checkEmailTitle => 'Sieh in dein E-Mail-Postfach';

  @override
  String checkEmailBody(String email) {
    return 'Wir haben einen Bestätigungslink an $email gesendet. Nachdem du auf den Link getippt hast, kannst du dich anmelden.';
  }

  @override
  String get linkResent => 'Wir haben den Link erneut gesendet.';

  @override
  String get backToSignIn => 'Zurück zur Anmeldung';

  @override
  String get resendLink => 'Link erneut senden';

  @override
  String get resetPasswordTitle => 'Passwort zurücksetzen';

  @override
  String get resetPasswordSubtitle =>
      'Gib deine E-Mail-Adresse ein und wir senden dir einen Link zum Zurücksetzen.';

  @override
  String get resetLinkSent =>
      'Falls zu dieser Adresse ein Konto existiert, haben wir einen Link zum Zurücksetzen gesendet.';

  @override
  String get sendLink => 'Link senden';

  @override
  String get newPasswordTitle => 'Neues Passwort festlegen';

  @override
  String get newPassword => 'Neues Passwort';

  @override
  String get newPasswordRepeat => 'Neues Passwort bestätigen';

  @override
  String get savePassword => 'Passwort speichern';

  @override
  String get enterEmail => 'Gib deine E-Mail-Adresse ein.';

  @override
  String get passwordMin8 =>
      'Das Passwort muss mindestens 8 Zeichen lang sein.';

  @override
  String get passwordMix =>
      'Das Passwort muss Groß- und Kleinbuchstaben sowie eine Zahl enthalten.';

  @override
  String get enterPassword => 'Gib dein Passwort ein.';

  @override
  String get birthDateTitle => 'Dein Geburtsdatum';

  @override
  String get chooseBirthDate => 'Wähle dein Geburtsdatum.';

  @override
  String birthDateExplain(int age) {
    return 'GWAY ist für Menschen ab $age Jahren. Dein Geburtsdatum wird niemandem gezeigt und kann später nicht geändert werden.';
  }

  @override
  String get chooseDate => 'Datum wählen';

  @override
  String get continueAction => 'Weiter';

  @override
  String get agreeTerms =>
      'Ich habe die Nutzungsbedingungen gelesen und akzeptiere sie.';

  @override
  String get agreePrivacy => 'Ich habe die Datenschutzhinweise (KVKK) gelesen.';

  @override
  String get agreeExplicitConsent =>
      'Ich willige ausdrücklich ein, dass meine personenbezogenen Daten auf Servern außerhalb der Türkei verarbeitet werden.';

  @override
  String get agreeCommunityRules =>
      'Ich habe die Vereinbarung zu Community-Regeln, Sanktionen und rechtlichen Schritten gelesen und akzeptiere sie.';

  @override
  String get agreeDistanceSales =>
      'Ich habe den Fernabsatzvertrag gelesen und akzeptiere ihn.';

  @override
  String get readAndAccept => 'Gelesen und akzeptiert';

  @override
  String get readWholeText =>
      'Bitte lies den gesamten Text, bevor du zustimmst.';

  @override
  String get beforeContinue => 'Bevor es weitergeht';

  @override
  String get consentIntro =>
      'Um GWAY zu nutzen, lies und akzeptiere die folgenden Texte.';

  @override
  String get readText => 'Text lesen';

  @override
  String get readToEnd => 'Lies den Text bis zum Ende, um zuzustimmen.';

  @override
  String versionLabel(int version) {
    return 'Version $version';
  }

  @override
  String get legalDocuments => 'Rechtliche Dokumente';

  @override
  String get documentNotPublished =>
      'Dieser Text ist derzeit nicht veröffentlicht.';

  @override
  String get deletionInfoTitle => 'Dein GWAY-Konto löschen';

  @override
  String get deletionInfoIntro =>
      'Du kannst dein Konto und deine Daten in der App oder auf dieser Website löschen:';

  @override
  String get deletionInfoStep1 =>
      'Melde dich in der GWAY-App oder auf der Website an.';

  @override
  String get deletionInfoStep2 =>
      'Gehe zu Ich → Einstellungen → Konto löschen.';

  @override
  String get deletionInfoStep3 =>
      'Bestätige die Löschung. Dein Profil wird sofort ausgeblendet.';

  @override
  String get deletionInfoWhat => 'Was wird gelöscht, was bleibt?';

  @override
  String deletionInfoBody(int days) {
    return 'Du kannst dich innerhalb von $days Tagen anmelden und die Löschung abbrechen. Danach werden dein Profil, deine Beiträge, Fotos, Nachrichten, Gruppenmitgliedschaften, Standortprüfungen und Verifizierungsdaten endgültig gelöscht. Zahlungsbelege mit gesetzlicher Aufbewahrungspflicht und anonyme Vorgangsprotokolle werden für die gesetzlich vorgeschriebene Dauer aufbewahrt. Bei aus Sicherheitsgründen geschlossenen Konten wird die Telefonnummer gespeichert, damit mit derselben Nummer kein neues Konto eröffnet werden kann.';
  }

  @override
  String get securityTitle => 'Sicherheitsprüfung';

  @override
  String get securityChecking => 'Sicherheit wird geprüft';

  @override
  String get securityWarning =>
      'Ihr Standort, Ihr Telefon und ein VPN wurden erkannt. Bitte halten Sie sich an die Regeln des Landes, in dem Sie sich befinden, und melden Sie sich sicher an.';

  @override
  String get vpnInstalledWarning =>
      'Auf Ihrem Gerät wurde eine VPN-App erkannt. Bitte halten Sie sich an die Regeln des Landes, in dem Sie sich befinden, und melden Sie sich sicher an.';

  @override
  String get securityWarningTitle => 'Sicherheitshinweis';

  @override
  String get understood => 'Verstanden';

  @override
  String get passkeyNotAdded =>
      'Fingerabdruck nicht hinzugefügt: Der Vorgang wurde abgebrochen oder das Gerät ist bereits registriert.';

  @override
  String get locationDeniedForever =>
      'Du hast den Standortzugriff zuvor abgelehnt. Erlaube GWAY den Standortzugriff in den Geräteeinstellungen und versuche es erneut.';

  @override
  String get locationRequired =>
      'Ohne Standortzugriff kannst du nicht fortfahren.';

  @override
  String get locationServiceOff =>
      'Die Standortdienste deines Geräts sind aus. Schalte sie ein und versuche es erneut.';

  @override
  String get locationTitle => 'Lass uns deinen Standort prüfen';

  @override
  String get locationBody =>
      'Zur Kontosicherheit und gegen gefälschte Konten nutzt GWAY deinen Standort bei der Anmeldung und beim Öffnen der App. Ohne Standortzugriff öffnet sich die App nicht.';

  @override
  String get openSettings => 'Einstellungen öffnen';

  @override
  String get grantLocation => 'Standortzugriff erlauben';

  @override
  String get readPrivacyNotice => 'Datenschutzhinweise lesen';

  @override
  String get privacyNoticeUnavailable =>
      'Die Datenschutzhinweise konnten gerade nicht geladen werden.';

  @override
  String get enterMobileNumber => 'Gib deine Handynummer ein.';

  @override
  String get speedUpTitle => 'Schneller anmelden';

  @override
  String get speedUpBodyPasskey =>
      'Beim nächsten Mal kannst du dich per Fingerabdruck oder Google-Authenticator-Code bestätigen, statt auf eine SMS zu warten.';

  @override
  String get speedUpBodyTotp =>
      'Beim nächsten Mal kannst du dich mit einem Google-Authenticator-Code bestätigen, statt auf eine SMS zu warten.';

  @override
  String get addFingerprint => 'Fingerabdruck hinzufügen';

  @override
  String get addAuthenticator => 'Google Authenticator hinzufügen';

  @override
  String get notNow => 'Nicht jetzt';

  @override
  String get fingerprintAdded => 'Fingerabdruck hinzugefügt.';

  @override
  String get verifyPhoneTitle => 'Telefonnummer bestätigen';

  @override
  String get verifyPhoneBody =>
      'Bestätige mit einer Handynummer des Landes, in dem du dich befindest. Deine Nummer wird anderen nie angezeigt.';

  @override
  String get mobilePhone => 'Handynummer';

  @override
  String get sendCode => 'Code senden';

  @override
  String get verify => 'Bestätigen';

  @override
  String resendCodeIn(int seconds) {
    return 'Code erneut senden ($seconds s)';
  }

  @override
  String get resendCode => 'Code erneut senden';

  @override
  String get changeNumber => 'Nummer ändern';

  @override
  String get passkeyFailed =>
      'Die Bestätigung wurde abgebrochen oder auf diesem Gerät ist kein Fingerabdruck registriert. Du kannst eine andere Methode wählen.';

  @override
  String get verifySignInTitle => 'Anmeldung bestätigen';

  @override
  String get verifyWithPasskey =>
      'Bestätige die Anmeldung mit Fingerabdruck, Gesichtserkennung oder Bildschirmsperre dieses Geräts.';

  @override
  String get verifyWithTotp =>
      'Gib den 6-stelligen Code aus deiner Authenticator-App ein.';

  @override
  String smsWillSendTo(String phone) {
    return 'Zu deiner Sicherheit musst du diese Anmeldung bestätigen. Wir senden einen Code an $phone.';
  }

  @override
  String get smsWillSendSaved =>
      'Zu deiner Sicherheit musst du diese Anmeldung bestätigen. Wir senden einen Code an deine hinterlegte Nummer.';

  @override
  String get methodFingerprint => 'Fingerabdruck';

  @override
  String get methodApp => 'App';

  @override
  String get verifyWithFingerprint => 'Mit Fingerabdruck bestätigen';

  @override
  String get reviewTitle => 'Sichere Anmeldung nicht möglich';

  @override
  String get reviewBody =>
      'Dein Konto wird aus Sicherheitsgründen geprüft. Sobald die Prüfung abgeschlossen ist, kannst du dort weitermachen, wo du aufgehört hast.';

  @override
  String get refreshStatus => 'Status aktualisieren';

  @override
  String get removeTotpTitle => 'Authenticator-App entfernen';

  @override
  String get removeTotpBody =>
      'Danach kannst du neue Anmeldungen nur noch per SMS-Code bestätigen.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get remove => 'Entfernen';

  @override
  String get totpRemoved => 'Authenticator-App entfernt.';

  @override
  String get twoFactorTitle => 'Zweistufige Bestätigung';

  @override
  String get phoneNumber => 'Telefonnummer';

  @override
  String get notVerifiedYet => 'Noch nicht bestätigt';

  @override
  String get authenticatorApp => 'Authenticator-App';

  @override
  String get totpOn =>
      'Aktiv. Du kannst neue Anmeldungen auch mit dem Code aus der App bestätigen.';

  @override
  String get totpOff =>
      'Melde dich mit einer App wie Google Authenticator an, ohne auf eine SMS zu warten.';

  @override
  String get addTotp => 'Authenticator-App hinzufügen';

  @override
  String get signInRequired => 'Du musst dich anmelden.';

  @override
  String passkeyRemoved(String name) {
    return '$name entfernt.';
  }

  @override
  String get passkeysTitle => 'Fingerabdruck und Gesichtserkennung';

  @override
  String get passkeysOff =>
      'Bestätige Anmeldungen mit Fingerabdruck, Gesichtserkennung oder Bildschirmsperre deines Geräts.';

  @override
  String passkeysOn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Geräte registriert.',
      one: '1 Gerät registriert.',
    );
    return '$_temp0 Bei der Anmeldung wird zuerst diese Methode abgefragt.';
  }

  @override
  String get notUsedYet => 'Noch nicht verwendet';

  @override
  String lastUsed(String date) {
    return 'Zuletzt verwendet: $date';
  }

  @override
  String get addFingerprintHere => 'Fingerabdruck auf diesem Gerät hinzufügen';

  @override
  String get passkeyUnsupported =>
      'Dieses Gerät oder dieser Browser unterstützt keine Anmeldung per Fingerabdruck.';

  @override
  String passkeyDefaultName(String date) {
    return 'Fingerabdruck · $date';
  }

  @override
  String get totpAdded => 'Authenticator-App hinzugefügt.';

  @override
  String get totpStep1 =>
      '1. Füge in deiner Authenticator-App ein neues Konto hinzu und scanne diesen Code. Auf demselben Telefon tippe auf „In App öffnen“ oder gib den Schlüssel manuell ein.';

  @override
  String get copyKey => 'Schlüssel kopieren';

  @override
  String get openInApp => 'In App öffnen';

  @override
  String get totpStep2 => '2. Gib den 6-stelligen Code aus der App ein.';

  @override
  String get activate => 'Aktivieren';

  @override
  String get codeHint => '6-stelliger Code';

  @override
  String get enterCode => 'Gib den 6-stelligen Code ein.';

  @override
  String get enterSmsCode => 'Gib den 6-stelligen Code aus der SMS ein.';

  @override
  String get enterAppCode => 'Gib den 6-stelligen Code aus der App ein.';

  @override
  String get refresh => 'Aktualisieren';
}
