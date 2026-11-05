// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'identity_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class IdentityL10nIt extends IdentityL10n {
  IdentityL10nIt([String locale = 'it']) : super(locale);

  @override
  String get authInvalidCredentials => 'Email o password non corretti.';

  @override
  String get authEmailNotConfirmed =>
      'Non hai ancora verificato l\'email. Controlla la posta in arrivo.';

  @override
  String get authEmailExists =>
      'Esiste già un account con questa email. Prova ad accedere.';

  @override
  String get authWeakPassword =>
      'La password deve avere almeno 8 caratteri e contenere una maiuscola, una minuscola e un numero.';

  @override
  String get authSamePassword =>
      'La nuova password deve essere diversa da quella vecchia.';

  @override
  String get authInvalidEmail => 'Inserisci un indirizzo email valido.';

  @override
  String get authUserBanned =>
      'Non puoi accedere perché il tuo account è sospeso.';

  @override
  String get authProviderDisabled =>
      'Questo metodo di accesso non è disponibile al momento.';

  @override
  String ageMinimum(int age) {
    return 'Devi avere almeno $age anni per usare GWAY.';
  }

  @override
  String get deletionPendingTitle => 'Il tuo account sta per essere eliminato';

  @override
  String get deletionRequested =>
      'Abbiamo ricevuto la tua richiesta di eliminazione dell’account.';

  @override
  String deletionScheduled(String date) {
    return 'Il tuo account e tutti i tuoi dati verranno eliminati definitivamente il $date. Fino ad allora puoi cambiare idea.';
  }

  @override
  String get undoDeletion => 'Annulla l\'eliminazione';

  @override
  String get signOut => 'Esci';

  @override
  String get bannedTitle => 'Il tuo account è stato chiuso definitivamente';

  @override
  String get suspendedTitle => 'Il tuo account è stato sospeso';

  @override
  String get bannedBody =>
      'Il team della piattaforma ha chiuso definitivamente il tuo account. Il tuo profilo non è più visibile a nessuno.';

  @override
  String suspendedBody(String date) {
    return 'Il tuo account è sospeso fino al $date. In questo periodo non puoi usare l\'app; il tuo profilo mostra la sospensione.';
  }

  @override
  String banReason(String reason) {
    return 'Motivo del ban: $reason';
  }

  @override
  String suspensionReason(String reason) {
    return 'Motivo della sospensione: $reason';
  }

  @override
  String get retry => 'Riprova';

  @override
  String get deleteAccount => 'Elimina account';

  @override
  String get beforeDeleting => 'Prima di eliminare l\'account';

  @override
  String get deletionHidesNow =>
      'Il tuo profilo viene nascosto subito; nessuno potrà trovarti.';

  @override
  String deletionGraceRestore(int days) {
    return 'Puoi accedere entro $days giorni e annullare l\'eliminazione.';
  }

  @override
  String get deletionAfterGrace =>
      'Dopo, il tuo profilo, le foto e tutti i tuoi dati vengono eliminati definitivamente.';

  @override
  String get deletionUnderstood =>
      'Ho capito, voglio eliminare il mio account.';

  @override
  String get deleteMyAccount => 'Elimina il mio account';

  @override
  String get heroTitle => 'La tua community ti aspetta.';

  @override
  String get heroBody =>
      'Dall\'escursionismo alla musica, dalla corsa all\'arte: trova il tuo gruppo, organizzatevi insieme e siate lì nello stesso momento.';

  @override
  String get heroPointGroups => 'Unisciti ai gruppi o crea la tua community';

  @override
  String get heroPointEvents =>
      'Aggiungi eventi al calendario e trova compagni di squadra';

  @override
  String get heroPointLive => 'Incontra il tuo gruppo in chat audio dal vivo';

  @override
  String get showPassword => 'Mostra password';

  @override
  String get hidePassword => 'Nascondi password';

  @override
  String get signIn => 'Accedi';

  @override
  String get signInSubtitle =>
      'Riprendi da dove avevi lasciato con i tuoi gruppi e amici.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Password dimenticata?';

  @override
  String get continueWithGoogle => 'Continua con Google';

  @override
  String get continueWithApple => 'Continua con Apple';

  @override
  String get noAccountSignUp => 'Non hai un account? Registrati';

  @override
  String get signUp => 'Registrati';

  @override
  String get signUpSubtitle =>
      'Trova i tuoi gruppi, partecipa agli eventi e conosci persone nuove.';

  @override
  String get passwordRepeat => 'Conferma password';

  @override
  String get passwordsDontMatch => 'Le password non corrispondono.';

  @override
  String get haveAccountSignIn => 'Hai già un account? Accedi';

  @override
  String get checkEmailTitle => 'Controlla l\'email';

  @override
  String checkEmailBody(String email) {
    return 'Abbiamo inviato un link di verifica a $email. Potrai accedere dopo aver toccato il link.';
  }

  @override
  String get linkResent => 'Abbiamo inviato di nuovo il link.';

  @override
  String get backToSignIn => 'Torna all\'accesso';

  @override
  String get resendLink => 'Invia di nuovo il link';

  @override
  String get resetPasswordTitle => 'Reimposta la password';

  @override
  String get resetPasswordSubtitle =>
      'Inserisci la tua email e ti invieremo un link per reimpostare la password.';

  @override
  String get resetLinkSent =>
      'Se esiste un account con questo indirizzo, abbiamo inviato un link di reimpostazione.';

  @override
  String get sendLink => 'Invia link';

  @override
  String get newPasswordTitle => 'Imposta una nuova password';

  @override
  String get newPassword => 'Nuova password';

  @override
  String get newPasswordRepeat => 'Conferma nuova password';

  @override
  String get savePassword => 'Salva password';

  @override
  String get enterEmail => 'Inserisci il tuo indirizzo email.';

  @override
  String get passwordMin8 => 'La password deve avere almeno 8 caratteri.';

  @override
  String get passwordMix =>
      'La password deve contenere una maiuscola, una minuscola e un numero.';

  @override
  String get enterPassword => 'Inserisci la password.';

  @override
  String get birthDateTitle => 'La tua data di nascita';

  @override
  String get chooseBirthDate => 'Scegli la tua data di nascita.';

  @override
  String birthDateExplain(int age) {
    return 'GWAY è per persone dai $age anni in su. La tua data di nascita non viene mostrata a nessuno e non può essere modificata in seguito.';
  }

  @override
  String get chooseDate => 'Scegli una data';

  @override
  String get continueAction => 'Continua';

  @override
  String get agreeTerms => 'Ho letto e accetto le Condizioni d\'uso.';

  @override
  String get agreePrivacy => 'Ho letto l\'Informativa sulla privacy (KVKK).';

  @override
  String get agreeExplicitConsent =>
      'Do il mio consenso esplicito al trattamento dei miei dati personali su server situati fuori dalla Turchia.';

  @override
  String get agreeCommunityRules =>
      'Ho letto e accetto l\'Accordo su regole della community, sanzioni e azioni legali.';

  @override
  String get agreeDistanceSales =>
      'Ho letto e accetto il Contratto di vendita a distanza.';

  @override
  String get readAndAccept => 'Ho letto e accetto';

  @override
  String get readWholeText => 'Leggi l\'intero testo prima di accettarlo.';

  @override
  String get beforeContinue => 'Prima di continuare';

  @override
  String get consentIntro =>
      'Per usare GWAY, leggi e accetta i testi qui sotto.';

  @override
  String get readText => 'Leggi il testo';

  @override
  String get readToEnd => 'Leggi il testo fino in fondo per accettarlo.';

  @override
  String versionLabel(int version) {
    return 'Versione $version';
  }

  @override
  String get legalDocuments => 'Documenti legali';

  @override
  String get documentNotPublished =>
      'Questo testo non è pubblicato al momento.';

  @override
  String get deletionInfoTitle => 'Eliminare il tuo account GWAY';

  @override
  String get deletionInfoIntro =>
      'Puoi eliminare l\'account e i dati dall\'app o da questo sito:';

  @override
  String get deletionInfoStep1 => 'Accedi all\'app o al sito di GWAY.';

  @override
  String get deletionInfoStep2 => 'Vai su Io → Impostazioni → Elimina account.';

  @override
  String get deletionInfoStep3 =>
      'Conferma l\'eliminazione. Il tuo profilo viene nascosto subito.';

  @override
  String get deletionInfoWhat => 'Cosa viene eliminato e cosa resta?';

  @override
  String deletionInfoBody(int days) {
    return 'Puoi accedere entro $days giorni e annullare l\'eliminazione. Trascorso questo periodo, il tuo profilo, i post, le foto, i messaggi, le iscrizioni ai gruppi, i controlli della posizione e i dati di verifica vengono eliminati definitivamente. Le registrazioni di pagamento soggette a obbligo legale di conservazione e i registri anonimi delle operazioni vengono conservati per il periodo previsto dalla legge. Per gli account chiusi per motivi di sicurezza, il numero di telefono viene conservato per impedire l\'apertura di un nuovo account con lo stesso numero.';
  }

  @override
  String get securityTitle => 'Verifica di sicurezza';

  @override
  String get securityChecking => 'Verifica in corso';

  @override
  String get securityWarning =>
      'Sono stati rilevati la sua posizione, il telefono in uso e una VPN. La preghiamo di rispettare le regole del Paese in cui si trova e di accedere in modo sicuro.';

  @override
  String get vpnInstalledWarning =>
      'È stata rilevata un’app VPN sul suo dispositivo. La preghiamo di rispettare le regole del Paese in cui si trova e di accedere in modo sicuro.';

  @override
  String get securityWarningTitle => 'Avviso di sicurezza';

  @override
  String get understood => 'Ho capito';

  @override
  String get passkeyNotAdded =>
      'Impronta non aggiunta: l\'operazione è stata annullata o il dispositivo è già registrato.';

  @override
  String get locationDeniedForever =>
      'Hai già negato l\'accesso alla posizione. Attivalo per GWAY nelle impostazioni del dispositivo e riprova.';

  @override
  String get locationRequired =>
      'Non puoi continuare senza l\'accesso alla posizione.';

  @override
  String get locationServiceOff =>
      'I servizi di localizzazione sono disattivati. Attivali e riprova.';

  @override
  String get locationTitle => 'Verifichiamo la tua posizione';

  @override
  String get locationBody =>
      'Per la sicurezza dell\'account e contro gli account falsi, GWAY usa la tua posizione quando accedi e apri l\'app. Senza accesso alla posizione l\'app non si apre.';

  @override
  String get openSettings => 'Apri impostazioni';

  @override
  String get grantLocation => 'Consenti l\'accesso alla posizione';

  @override
  String get readPrivacyNotice => 'Leggi l\'informativa sulla privacy';

  @override
  String get privacyNoticeUnavailable =>
      'Impossibile caricare l\'informativa sulla privacy al momento.';

  @override
  String get enterMobileNumber => 'Inserisci il tuo numero di cellulare.';

  @override
  String get speedUpTitle => 'Accedi più velocemente';

  @override
  String get speedUpBodyPasskey =>
      'La prossima volta verifica con l\'impronta o con un codice di Google Authenticator invece di aspettare un SMS.';

  @override
  String get speedUpBodyTotp =>
      'La prossima volta verifica con un codice di Google Authenticator invece di aspettare un SMS.';

  @override
  String get addFingerprint => 'Aggiungi impronta';

  @override
  String get addAuthenticator => 'Aggiungi Google Authenticator';

  @override
  String get notNow => 'Non ora';

  @override
  String get fingerprintAdded => 'Impronta aggiunta.';

  @override
  String get verifyPhoneTitle => 'Verifica il tuo telefono';

  @override
  String get verifyPhoneBody =>
      'Verifica con un numero di cellulare del Paese in cui ti trovi. Il tuo numero non viene mai mostrato agli altri.';

  @override
  String get mobilePhone => 'Cellulare';

  @override
  String get sendCode => 'Invia codice';

  @override
  String get verify => 'Verifica';

  @override
  String resendCodeIn(int seconds) {
    return 'Invia di nuovo il codice ($seconds s)';
  }

  @override
  String get resendCode => 'Invia di nuovo il codice';

  @override
  String get changeNumber => 'Cambia numero';

  @override
  String get passkeyFailed =>
      'La verifica è stata annullata o su questo dispositivo non è registrata alcuna impronta. Puoi scegliere un altro metodo.';

  @override
  String get verifySignInTitle => 'Verifica l\'accesso';

  @override
  String get verifyWithPasskey =>
      'Verifica l\'accesso con l\'impronta, il riconoscimento del volto o il blocco schermo di questo dispositivo.';

  @override
  String get verifyWithTotp =>
      'Inserisci il codice a 6 cifre dell\'app di autenticazione.';

  @override
  String smsWillSendTo(String phone) {
    return 'Per la tua sicurezza devi verificare questo accesso. Invieremo un codice al $phone.';
  }

  @override
  String get smsWillSendSaved =>
      'Per la tua sicurezza devi verificare questo accesso. Invieremo un codice al numero registrato.';

  @override
  String get methodFingerprint => 'Impronta';

  @override
  String get methodApp => 'App';

  @override
  String get verifyWithFingerprint => 'Verifica con l\'impronta';

  @override
  String get reviewTitle => 'Accesso sicuro non riuscito';

  @override
  String get reviewBody =>
      'Il tuo account è in fase di verifica di sicurezza. Al termine potrai riprendere da dove avevi lasciato.';

  @override
  String get refreshStatus => 'Aggiorna stato';

  @override
  String get removeTotpTitle => 'Rimuovi l\'app di autenticazione';

  @override
  String get removeTotpBody =>
      'D\'ora in poi potrai verificare i nuovi accessi solo con un codice SMS.';

  @override
  String get cancel => 'Annulla';

  @override
  String get remove => 'Rimuovi';

  @override
  String get totpRemoved => 'App di autenticazione rimossa.';

  @override
  String get twoFactorTitle => 'Verifica in due passaggi';

  @override
  String get phoneNumber => 'Numero di telefono';

  @override
  String get notVerifiedYet => 'Non ancora verificato';

  @override
  String get authenticatorApp => 'App di autenticazione';

  @override
  String get totpOn =>
      'Attiva. Puoi verificare i nuovi accessi anche con il codice dell\'app.';

  @override
  String get totpOff =>
      'Accedi senza aspettare un SMS con un’app come Google Authenticator.';

  @override
  String get addTotp => 'Aggiungi un\'app di autenticazione';

  @override
  String get signInRequired => 'Devi accedere.';

  @override
  String passkeyRemoved(String name) {
    return '$name rimosso.';
  }

  @override
  String get passkeysTitle => 'Impronta e riconoscimento del volto';

  @override
  String get passkeysOff =>
      'Verifica gli accessi con l\'impronta, il riconoscimento del volto o il blocco schermo del dispositivo.';

  @override
  String passkeysOn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dispositivi registrati.',
      one: '1 dispositivo registrato.',
    );
    return '$_temp0 Questo metodo viene chiesto per primo all’accesso.';
  }

  @override
  String get notUsedYet => 'Non ancora usato';

  @override
  String lastUsed(String date) {
    return 'Ultimo utilizzo: $date';
  }

  @override
  String get addFingerprintHere => 'Aggiungi impronta su questo dispositivo';

  @override
  String get passkeyUnsupported =>
      'Questo dispositivo o browser non supporta l\'accesso con impronta.';

  @override
  String passkeyDefaultName(String date) {
    return 'Impronta · $date';
  }

  @override
  String get totpAdded => 'App di autenticazione aggiunta.';

  @override
  String get totpStep1 =>
      '1. Aggiungi un nuovo account nell\'app di autenticazione e scansiona questo codice. Sullo stesso telefono tocca «Apri nell\'app» o inserisci la chiave a mano.';

  @override
  String get copyKey => 'Copia chiave';

  @override
  String get openInApp => 'Apri nell\'app';

  @override
  String get totpStep2 =>
      '2. Inserisci il codice a 6 cifre mostrato nell\'app.';

  @override
  String get activate => 'Attiva';

  @override
  String get codeHint => 'Codice a 6 cifre';

  @override
  String get enterCode => 'Inserisci il codice a 6 cifre.';

  @override
  String get enterSmsCode => 'Inserisci il codice a 6 cifre ricevuto via SMS.';

  @override
  String get enterAppCode => 'Inserisci il codice a 6 cifre dell\'app.';

  @override
  String get refresh => 'Aggiorna';

  @override
  String get language => 'Lingua';

  @override
  String get chooseLanguage => 'Scegli la lingua';

  @override
  String get languageNote =>
      'Menu, pulsanti, notifiche e accordi vengono mostrati in questa lingua. Post, commenti e messaggi restano nella lingua in cui sono stati scritti.';

  @override
  String get or => 'oppure';

  @override
  String get legalTranslationNote =>
      'Questa traduzione è informativa. Il testo vincolante, e quello che accetti, è l\'originale in turco.';

  @override
  String get legalShowOriginal => 'Mostra l\'originale in turco';

  @override
  String get legalShowTranslation => 'Mostra la traduzione';
}
