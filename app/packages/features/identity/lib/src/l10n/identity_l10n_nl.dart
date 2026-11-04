// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'identity_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class IdentityL10nNl extends IdentityL10n {
  IdentityL10nNl([String locale = 'nl']) : super(locale);

  @override
  String get authInvalidCredentials => 'E-mailadres of wachtwoord is onjuist.';

  @override
  String get authEmailNotConfirmed =>
      'Je hebt je e-mailadres nog niet bevestigd. Kijk in je inbox.';

  @override
  String get authEmailExists =>
      'Er bestaat al een account met dit e-mailadres. Probeer in te loggen.';

  @override
  String get authWeakPassword =>
      'Je wachtwoord moet minstens 8 tekens hebben, met een hoofdletter, een kleine letter en een cijfer.';

  @override
  String get authSamePassword =>
      'Je nieuwe wachtwoord moet anders zijn dan het oude.';

  @override
  String get authInvalidEmail => 'Voer een geldig e-mailadres in.';

  @override
  String get authUserBanned =>
      'Je kunt niet inloggen omdat je account is geschorst.';

  @override
  String get authProviderDisabled =>
      'Deze inlogmethode is nu niet beschikbaar.';

  @override
  String ageMinimum(int age) {
    return 'Je moet minstens $age jaar zijn om GWAY te gebruiken.';
  }

  @override
  String get deletionPendingTitle => 'Je account wordt binnenkort verwijderd';

  @override
  String get deletionRequested =>
      'We hebben je verzoek om je account te verwijderen ontvangen.';

  @override
  String deletionScheduled(String date) {
    return 'Je account en al je gegevens worden op $date definitief verwijderd. Tot die tijd kun je nog van gedachten veranderen.';
  }

  @override
  String get undoDeletion => 'Verwijdering annuleren';

  @override
  String get signOut => 'Uitloggen';

  @override
  String get bannedTitle => 'Je account is definitief gesloten';

  @override
  String get suspendedTitle => 'Je account is geschorst';

  @override
  String get bannedBody =>
      'Het platformteam heeft je account definitief gesloten. Je profiel is voor niemand meer zichtbaar.';

  @override
  String suspendedBody(String date) {
    return 'Je account is geschorst tot $date. In die tijd kun je de app niet gebruiken; op je profiel is te zien dat je geschorst bent.';
  }

  @override
  String banReason(String reason) {
    return 'Reden van de ban: $reason';
  }

  @override
  String suspensionReason(String reason) {
    return 'Reden van de schorsing: $reason';
  }

  @override
  String get retry => 'Opnieuw proberen';

  @override
  String get deleteAccount => 'Account verwijderen';

  @override
  String get beforeDeleting => 'Voordat je je account verwijdert';

  @override
  String get deletionHidesNow =>
      'Je profiel wordt meteen verborgen; niemand kan je vinden.';

  @override
  String deletionGraceRestore(int days) {
    return 'Je kunt binnen $days dagen inloggen en de verwijdering annuleren.';
  }

  @override
  String get deletionAfterGrace =>
      'Daarna worden je profiel, foto’s en al je gegevens definitief verwijderd.';

  @override
  String get deletionUnderstood =>
      'Ik begrijp het en wil mijn account verwijderen.';

  @override
  String get deleteMyAccount => 'Mijn account verwijderen';

  @override
  String get heroTitle => 'Je community wacht op je.';

  @override
  String get heroBody =>
      'Van wandelen tot muziek, van hardlopen tot kunst: vind je groep, maak samen plannen en wees er tegelijk bij.';

  @override
  String get heroPointGroups =>
      'Word lid van groepen of start je eigen community';

  @override
  String get heroPointEvents =>
      'Zet evenementen in je agenda en vind teamgenoten';

  @override
  String get heroPointLive => 'Ontmoet je groep in live audiogesprekken';

  @override
  String get showPassword => 'Wachtwoord tonen';

  @override
  String get hidePassword => 'Wachtwoord verbergen';

  @override
  String get signIn => 'Inloggen';

  @override
  String get signInSubtitle =>
      'Ga verder waar je gebleven was met je groepen en vrienden.';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Wachtwoord';

  @override
  String get forgotPassword => 'Wachtwoord vergeten?';

  @override
  String get continueWithGoogle => 'Doorgaan met Google';

  @override
  String get continueWithApple => 'Doorgaan met Apple';

  @override
  String get noAccountSignUp => 'Nog geen account? Registreren';

  @override
  String get signUp => 'Registreren';

  @override
  String get signUpSubtitle =>
      'Vind je groepen, doe mee aan evenementen en leer nieuwe mensen kennen.';

  @override
  String get passwordRepeat => 'Wachtwoord bevestigen';

  @override
  String get passwordsDontMatch => 'De wachtwoorden komen niet overeen.';

  @override
  String get haveAccountSignIn => 'Heb je al een account? Inloggen';

  @override
  String get checkEmailTitle => 'Controleer je e-mail';

  @override
  String checkEmailBody(String email) {
    return 'We hebben een verificatielink naar $email gestuurd. Na het tikken op de link kun je inloggen.';
  }

  @override
  String get linkResent => 'We hebben de link opnieuw gestuurd.';

  @override
  String get backToSignIn => 'Terug naar inloggen';

  @override
  String get resendLink => 'Link opnieuw sturen';

  @override
  String get resetPasswordTitle => 'Wachtwoord opnieuw instellen';

  @override
  String get resetPasswordSubtitle =>
      'Voer je e-mailadres in, dan sturen we je een link om je wachtwoord opnieuw in te stellen.';

  @override
  String get resetLinkSent =>
      'Als er een account bij dit adres hoort, hebben we een resetlink gestuurd.';

  @override
  String get sendLink => 'Link sturen';

  @override
  String get newPasswordTitle => 'Nieuw wachtwoord instellen';

  @override
  String get newPassword => 'Nieuw wachtwoord';

  @override
  String get newPasswordRepeat => 'Nieuw wachtwoord bevestigen';

  @override
  String get savePassword => 'Wachtwoord opslaan';

  @override
  String get enterEmail => 'Voer je e-mailadres in.';

  @override
  String get passwordMin8 => 'Je wachtwoord moet minstens 8 tekens hebben.';

  @override
  String get passwordMix =>
      'Je wachtwoord moet een hoofdletter, een kleine letter en een cijfer bevatten.';

  @override
  String get enterPassword => 'Voer je wachtwoord in.';

  @override
  String get birthDateTitle => 'Je geboortedatum';

  @override
  String get chooseBirthDate => 'Kies je geboortedatum.';

  @override
  String birthDateExplain(int age) {
    return 'GWAY is voor mensen van $age jaar en ouder. Je geboortedatum wordt aan niemand getoond en kan later niet worden gewijzigd.';
  }

  @override
  String get chooseDate => 'Datum kiezen';

  @override
  String get continueAction => 'Doorgaan';

  @override
  String get agreeTerms =>
      'Ik heb de Gebruiksvoorwaarden gelezen en ga ermee akkoord.';

  @override
  String get agreePrivacy => 'Ik heb de Privacyverklaring (KVKK) gelezen.';

  @override
  String get agreeExplicitConsent =>
      'Ik geef uitdrukkelijk toestemming voor de verwerking van mijn persoonsgegevens op servers buiten Turkije.';

  @override
  String get agreeCommunityRules =>
      'Ik heb de Overeenkomst over communityregels, sancties en juridische stappen gelezen en ga ermee akkoord.';

  @override
  String get agreeDistanceSales =>
      'Ik heb de Overeenkomst op afstand gelezen en ga ermee akkoord.';

  @override
  String get readAndAccept => 'Gelezen en akkoord';

  @override
  String get readWholeText =>
      'Lees de volledige tekst voordat je akkoord gaat.';

  @override
  String get beforeContinue => 'Voordat je verdergaat';

  @override
  String get consentIntro =>
      'Lees en accepteer de onderstaande teksten om GWAY te gebruiken.';

  @override
  String get readText => 'Tekst lezen';

  @override
  String get readToEnd => 'Lees de tekst tot het einde om akkoord te gaan.';

  @override
  String versionLabel(int version) {
    return 'Versie $version';
  }

  @override
  String get legalDocuments => 'Juridische documenten';

  @override
  String get documentNotPublished =>
      'Deze tekst is momenteel niet gepubliceerd.';

  @override
  String get deletionInfoTitle => 'Je GWAY-account verwijderen';

  @override
  String get deletionInfoIntro =>
      'Je kunt je account en gegevens verwijderen in de app of op deze website:';

  @override
  String get deletionInfoStep1 => 'Log in op de GWAY-app of -website.';

  @override
  String get deletionInfoStep2 =>
      'Ga naar Ik → Instellingen → Account verwijderen.';

  @override
  String get deletionInfoStep3 =>
      'Bevestig de verwijdering. Je profiel wordt meteen verborgen.';

  @override
  String get deletionInfoWhat => 'Wat wordt verwijderd en wat blijft?';

  @override
  String deletionInfoBody(int days) {
    return 'Je kunt binnen $days dagen inloggen en de verwijdering annuleren. Daarna worden je profiel, berichten, foto’s, chats, groepslidmaatschappen, locatiecontroles en verificatiegegevens definitief verwijderd. Betalingsgegevens met een wettelijke bewaarplicht en anonieme transactielogs worden bewaard zolang de wet voorschrijft. Bij accounts die om veiligheidsredenen zijn gesloten, wordt het telefoonnummer bewaard om te voorkomen dat er met hetzelfde nummer een nieuw account wordt geopend.';
  }

  @override
  String get securityTitle => 'Beveiligingscontrole';

  @override
  String get securityChecking => 'Beveiliging wordt gecontroleerd';

  @override
  String get securityWarning =>
      'Uw locatie, de telefoon die u gebruikt en een VPN zijn gedetecteerd. Volg de regels van het land waar u zich bevindt en log veilig in.';

  @override
  String get vpnInstalledWarning =>
      'Er is een VPN-app op uw apparaat gedetecteerd. Volg de regels van het land waar u zich bevindt en log veilig in.';

  @override
  String get securityWarningTitle => 'Beveiligingswaarschuwing';

  @override
  String get understood => 'Begrepen';

  @override
  String get passkeyNotAdded =>
      'Vingerafdruk niet toegevoegd: de actie is geannuleerd of dit apparaat is al geregistreerd.';

  @override
  String get locationDeniedForever =>
      'Je hebt locatietoegang eerder geweigerd. Zet locatietoegang voor GWAY aan in je apparaatinstellingen en probeer het opnieuw.';

  @override
  String get locationRequired => 'Zonder locatietoegang kun je niet verder.';

  @override
  String get locationServiceOff =>
      'Locatievoorzieningen staan uit op je apparaat. Zet ze aan en probeer het opnieuw.';

  @override
  String get locationTitle => 'Laten we je locatie controleren';

  @override
  String get locationBody =>
      'Voor accountbeveiliging en tegen nepaccounts gebruikt GWAY je locatie bij het inloggen en openen van de app. Zonder locatietoegang opent de app niet.';

  @override
  String get openSettings => 'Instellingen openen';

  @override
  String get grantLocation => 'Locatietoegang toestaan';

  @override
  String get readPrivacyNotice => 'Privacyverklaring lezen';

  @override
  String get privacyNoticeUnavailable =>
      'De privacyverklaring kon nu niet worden geladen.';

  @override
  String get enterMobileNumber => 'Voer je mobiele nummer in.';

  @override
  String get speedUpTitle => 'Sneller inloggen';

  @override
  String get speedUpBodyPasskey =>
      'De volgende keer kun je bevestigen met je vingerafdruk of een Google Authenticator-code in plaats van op een sms te wachten.';

  @override
  String get speedUpBodyTotp =>
      'De volgende keer kun je bevestigen met een Google Authenticator-code in plaats van op een sms te wachten.';

  @override
  String get addFingerprint => 'Vingerafdruk toevoegen';

  @override
  String get addAuthenticator => 'Google Authenticator toevoegen';

  @override
  String get notNow => 'Niet nu';

  @override
  String get fingerprintAdded => 'Vingerafdruk toegevoegd.';

  @override
  String get verifyPhoneTitle => 'Bevestig je telefoon';

  @override
  String get verifyPhoneBody =>
      'Bevestig met een mobiel nummer uit het land waar je bent. Je nummer wordt nooit aan anderen getoond.';

  @override
  String get mobilePhone => 'Mobiel nummer';

  @override
  String get sendCode => 'Code sturen';

  @override
  String get verify => 'Bevestigen';

  @override
  String resendCodeIn(int seconds) {
    return 'Code opnieuw sturen ($seconds s)';
  }

  @override
  String get resendCode => 'Code opnieuw sturen';

  @override
  String get changeNumber => 'Nummer wijzigen';

  @override
  String get passkeyFailed =>
      'De verificatie is geannuleerd of er is geen vingerafdruk op dit apparaat geregistreerd. Je kunt een andere methode kiezen.';

  @override
  String get verifySignInTitle => 'Bevestig je inlogpoging';

  @override
  String get verifyWithPasskey =>
      'Bevestig je inlogpoging met de vingerafdruk, gezichtsherkenning of schermvergrendeling van dit apparaat.';

  @override
  String get verifyWithTotp =>
      'Voer de 6-cijferige code uit je authenticator-app in.';

  @override
  String smsWillSendTo(String phone) {
    return 'Voor je veiligheid moet je deze inlogpoging bevestigen. We sturen een code naar $phone.';
  }

  @override
  String get smsWillSendSaved =>
      'Voor je veiligheid moet je deze inlogpoging bevestigen. We sturen een code naar je opgeslagen nummer.';

  @override
  String get methodFingerprint => 'Vingerafdruk';

  @override
  String get methodApp => 'App';

  @override
  String get verifyWithFingerprint => 'Bevestigen met vingerafdruk';

  @override
  String get reviewTitle => 'Veilig inloggen is niet gelukt';

  @override
  String get reviewBody =>
      'Je account wordt beoordeeld op beveiliging. Zodra de beoordeling klaar is, kun je verder waar je gebleven was.';

  @override
  String get refreshStatus => 'Status vernieuwen';

  @override
  String get removeTotpTitle => 'Authenticator-app verwijderen';

  @override
  String get removeTotpBody =>
      'Daarna kun je nieuwe inlogpogingen alleen nog met een sms-code bevestigen.';

  @override
  String get cancel => 'Annuleren';

  @override
  String get remove => 'Verwijderen';

  @override
  String get totpRemoved => 'Authenticator-app verwijderd.';

  @override
  String get twoFactorTitle => 'Verificatie in twee stappen';

  @override
  String get phoneNumber => 'Telefoonnummer';

  @override
  String get notVerifiedYet => 'Nog niet bevestigd';

  @override
  String get authenticatorApp => 'Authenticator-app';

  @override
  String get totpOn =>
      'Aan. Je kunt nieuwe inlogpogingen ook met de code uit de app bevestigen.';

  @override
  String get totpOff =>
      'Log in zonder op een sms te wachten met een app zoals Google Authenticator.';

  @override
  String get addTotp => 'Authenticator-app toevoegen';

  @override
  String get signInRequired => 'Je moet inloggen.';

  @override
  String passkeyRemoved(String name) {
    return '$name verwijderd.';
  }

  @override
  String get passkeysTitle => 'Vingerafdruk en gezichtsherkenning';

  @override
  String get passkeysOff =>
      'Bevestig inlogpogingen met de vingerafdruk, gezichtsherkenning of schermvergrendeling van je apparaat.';

  @override
  String passkeysOn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count apparaten geregistreerd.',
      one: '1 apparaat geregistreerd.',
    );
    return '$_temp0 Bij het inloggen wordt eerst om deze methode gevraagd.';
  }

  @override
  String get notUsedYet => 'Nog niet gebruikt';

  @override
  String lastUsed(String date) {
    return 'Laatst gebruikt: $date';
  }

  @override
  String get addFingerprintHere => 'Vingerafdruk op dit apparaat toevoegen';

  @override
  String get passkeyUnsupported =>
      'Dit apparaat of deze browser ondersteunt inloggen met vingerafdruk niet.';

  @override
  String passkeyDefaultName(String date) {
    return 'Vingerafdruk · $date';
  }

  @override
  String get totpAdded => 'Authenticator-app toegevoegd.';

  @override
  String get totpStep1 =>
      '1. Voeg een nieuw account toe in je authenticator-app en scan deze code. Op dezelfde telefoon tik je op ‘Openen in app’ of voer je de sleutel handmatig in.';

  @override
  String get copyKey => 'Sleutel kopiëren';

  @override
  String get openInApp => 'Openen in app';

  @override
  String get totpStep2 => '2. Voer de 6-cijferige code uit de app in.';

  @override
  String get activate => 'Inschakelen';

  @override
  String get codeHint => '6-cijferige code';

  @override
  String get enterCode => 'Voer de 6-cijferige code in.';

  @override
  String get enterSmsCode => 'Voer de 6-cijferige code uit de sms in.';

  @override
  String get enterAppCode => 'Voer de 6-cijferige code uit de app in.';

  @override
  String get refresh => 'Vernieuwen';

  @override
  String get language => 'Taal';

  @override
  String get chooseLanguage => 'Taal kiezen';

  @override
  String get languageNote =>
      'Menu’s, knoppen, meldingen en overeenkomsten worden in deze taal getoond. Berichten, reacties en chats blijven in de taal waarin ze zijn geschreven.';

  @override
  String get or => 'of';
}
