// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'messaging_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class MessagingL10nIt extends MessagingL10n {
  MessagingL10nIt([String locale = 'it']) : super(locale);

  @override
  String get groupInvalid =>
      'Puoi inviare la richiesta solo a un gruppo di cui fai parte.';

  @override
  String get permissionExists =>
      'La tua richiesta è già stata ricevuta o il permesso è attivo.';

  @override
  String get permissionCooldown =>
      'Potrai inviare una nuova richiesta 7 giorni dopo l’ultima decisione.';

  @override
  String noteTooLong(int max) {
    return 'La nota può avere fino a $max caratteri.';
  }

  @override
  String get requestForbidden =>
      'Al momento non è possibile inviare la richiesta.';

  @override
  String get unsupportedImage =>
      'Questo tipo di file non è supportato. Scegli JPEG, PNG o WebP.';

  @override
  String get voiceCallHandle => 'Chiamata vocale GWAY';

  @override
  String get incomingCalls => 'Chiamate in arrivo';

  @override
  String get missedCalls => 'Chiamate perse';

  @override
  String get answer => 'Rispondi';

  @override
  String get decline => 'Rifiuta';

  @override
  String get noAnswer => 'Nessuna risposta';

  @override
  String get missedCall => 'Chiamata persa';

  @override
  String get callDeclined => 'Chiamata rifiutata';

  @override
  String get youDeclined => 'Hai rifiutato la chiamata';

  @override
  String get callNotAllowed => 'Non è più possibile chiamare';

  @override
  String get callCanceled => 'Chiamata annullata';

  @override
  String get timeLimit => 'I 60 minuti sono finiti; la chiamata è terminata';

  @override
  String get endedNotAllowed =>
      'Chiamata terminata: le chiamate vocali non sono più possibili';

  @override
  String get callEnded => 'Chiamata terminata';

  @override
  String get messageDeleted => 'Messaggio eliminato';

  @override
  String get photo => 'Foto';

  @override
  String get tonightTable => 'Il tavolo di stasera';

  @override
  String get blockRequestPending =>
      'Accetta la richiesta di messaggio prima di rispondere.';

  @override
  String get blockDeclined =>
      'Questa persona non ha accettato la tua richiesta di messaggio.';

  @override
  String get blockMuted =>
      'Sei silenziato in questo gruppo e al momento non puoi scrivere.';

  @override
  String get blockAdminsOnly =>
      'In questa chat possono scrivere solo gli amministratori.';

  @override
  String get blockTableClosed =>
      'Il tavolo è chiuso; puoi leggere i messaggi ma non scriverne di nuovi.';

  @override
  String get blockBlocked => 'Non puoi scrivere qui a causa di un blocco.';

  @override
  String get blockMatchEnded =>
      'Questa chat è chiusa perché il match è terminato.';

  @override
  String get blockMatchLocked =>
      'Per scrivere al tuo match serve il piano Chat match. Leggere i messaggi è gratis.';

  @override
  String get blockTeammateLocked =>
      'Per scrivere al tuo compagno serve il piano Compagno di squadra. Leggere è gratis.';

  @override
  String get blockNotAllowed =>
      'I messaggi diretti ora sono solo per match e compagni di squadra. Puoi leggere i vecchi messaggi.';

  @override
  String get blockOther => 'Al momento non puoi scrivere in questa chat.';

  @override
  String get hiddenUser => 'Utente GWAY';

  @override
  String get voiceCalls => 'Chiamate vocali';

  @override
  String get voiceCallsHeadline =>
      'Parla a voce con i tuoi match e compagni di squadra';

  @override
  String voiceCallsIntro(int minutes) {
    return 'Le chiamate vocali ti permettono di chiamare match e compagni dalla chat privata. Non sono aperte a tutti: le richiedi a un gruppo di cui fai parte e il proprietario o un amministratore le attiva. Le chiamate non vengono registrate né ascoltate; durano al massimo $minutes minuti.';
  }

  @override
  String get status => 'Stato';

  @override
  String get notRequested => 'Non richiesto';

  @override
  String get underReview => 'In revisione';

  @override
  String get statusOn => 'Attivo';

  @override
  String get statusOff => 'Disattivato';

  @override
  String get notRequestedYet => 'Non l’hai ancora richiesto.';

  @override
  String requestedFrom(String group) {
    return 'La richiesta è arrivata agli amministratori di $group. Riceverai una notifica alla decisione.';
  }

  @override
  String get requestedFromGroup =>
      'La richiesta è arrivata agli amministratori del gruppo. Riceverai una notifica alla decisione.';

  @override
  String activeFrom(String group) {
    return 'Le tue chiamate vocali sono attive ($group). Chiama match e compagni con l’icona del telefono in alto nella chat; serve anche il loro permesso.';
  }

  @override
  String get active =>
      'Le tue chiamate vocali sono attive. Chiama match e compagni con l’icona del telefono in alto nella chat; serve anche il loro permesso.';

  @override
  String get declined => 'Per ora la tua richiesta non è stata approvata.';

  @override
  String get revokedLeftGroup =>
      'Le chiamate vocali sono disattivate perché hai lasciato il gruppo che le aveva concesse. Puoi richiederle a un altro gruppo.';

  @override
  String get revoked => 'Le tue chiamate vocali sono state disattivate.';

  @override
  String reasonLine(String reason) {
    return 'Motivo: $reason';
  }

  @override
  String yourNote(String note) {
    return 'La tua nota: $note';
  }

  @override
  String waitUntil(String date) {
    return 'Potrai richiederlo di nuovo dopo il $date.';
  }

  @override
  String get requestSent => 'La tua richiesta è stata inviata.';

  @override
  String get joinGroupFirst =>
      'Proprietari e amministratori dei gruppi attivano le chiamate vocali. Unisciti prima a un gruppo per richiederle.';

  @override
  String get requestToGroup => 'Gruppo a cui inviare la richiesta';

  @override
  String get noteOptional => 'Nota (facoltativa)';

  @override
  String get noteHint =>
      'Puoi spiegare in breve perché vuoi le chiamate vocali.';

  @override
  String get request => 'Richiedi';

  @override
  String get lockScreenCalls => 'Chiamate sulla schermata di blocco';

  @override
  String get lockScreenHint =>
      'Consenti a GWAY di squillare a schermo intero con il telefono bloccato.';

  @override
  String get allow => 'Consenti';

  @override
  String get callInfoFailed =>
      'Impossibile caricare la chiamata. Controlla la connessione.';

  @override
  String get tapEndToHangUp => 'Tocca Chiudi per riagganciare.';

  @override
  String get callNotFound => 'Chiamata non trovata.';

  @override
  String get close => 'Chiudi';

  @override
  String callLimitNote(int minutes) {
    return 'Una chiamata dura al massimo $minutes minuti e non viene registrata.';
  }

  @override
  String get audioFailed =>
      'Impossibile collegare l’audio. Controlla la connessione e riprova.';

  @override
  String get reconnect => 'Riconnetti';

  @override
  String get incoming => 'ti sta chiamando…';

  @override
  String get calling => 'Chiamata in corso…';

  @override
  String get connecting => 'Connessione…';

  @override
  String get answerCall => 'Rispondi';

  @override
  String get mute => 'Disattiva microfono';

  @override
  String get unmute => 'Attiva microfono';

  @override
  String get end => 'Chiudi';

  @override
  String get speaker => 'Altoparlante';

  @override
  String get peerUnencrypted =>
      'L\'app dell\'altra persona è vecchia: l\'audio non è cifrato e non viene riprodotto. Chiedile di aggiornarla.';

  @override
  String get encrypting => 'Connessione cifrata in corso…';

  @override
  String e2eeCode(String code) {
    return 'Crittografia end-to-end. Codice di sicurezza $code';
  }

  @override
  String get e2ee => 'Crittografia end-to-end';

  @override
  String get codeMatchHint =>
      'Se questo codice è uguale a quello dell\'altra persona, nessuno può ascoltare.';

  @override
  String get micFailed =>
      'Impossibile accendere il microfono. Controlla il permesso del microfono.';

  @override
  String get chatNotFound => 'Chat non trovata o non puoi più vederla.';

  @override
  String get backToMessages => 'Torna ai messaggi';

  @override
  String get cantCallNow => 'Al momento non è possibile chiamare.';

  @override
  String get voiceCall => 'Chiamata vocale';

  @override
  String get groupChatAdminsOnly =>
      'Chat di gruppo · scrivono solo gli amministratori';

  @override
  String get groupChat => 'Chat di gruppo';

  @override
  String smallTableMembers(int count) {
    return 'Piccolo tavolo · $count persone';
  }

  @override
  String get adminsOnlyOn =>
      'Ora in questa chat possono scrivere solo il proprietario e gli amministratori.';

  @override
  String get adminsOnlyOff =>
      'Ora tutti i membri del gruppo possono scrivere in questa chat.';

  @override
  String get chatSettings => 'Impostazioni chat';

  @override
  String get adminsOnlyToggle => 'Scrivono solo gli amministratori';

  @override
  String get sendingPhoto => '📷 Invio foto…';

  @override
  String get requestPendingNote =>
      'La richiesta di messaggio è stata inviata. Finché non viene accettata non vedi se è stata letta.';

  @override
  String get groupChatEmpty =>
      'Ancora nessun messaggio nella chat di gruppo. Scrivi tu il primo.';

  @override
  String get chatEmpty => 'Ancora nessun messaggio. Scrivi tu il primo.';

  @override
  String get startWriting => 'Inizia a scrivere';

  @override
  String get sending => 'Invio…';

  @override
  String get seen => 'Visualizzato';

  @override
  String get sent => 'Inviato';

  @override
  String get seePackage => 'Vedi il piano';

  @override
  String get today => 'Oggi';

  @override
  String get messageRemoved => 'Questo messaggio è stato rimosso.';

  @override
  String get thisMessageDeleted => 'Questo messaggio è stato eliminato.';

  @override
  String get messageOptions => 'Opzioni del messaggio';

  @override
  String profileOf(String name) {
    return 'Profilo di $name';
  }

  @override
  String get you => 'Tu';

  @override
  String get copy => 'Copia';

  @override
  String get copied => 'Messaggio copiato.';

  @override
  String get deleteForAll => 'Elimina per tutti';

  @override
  String get report => 'Segnala';

  @override
  String get deleteForAllTitle => 'Eliminare il messaggio per tutti?';

  @override
  String get deleteForAllBody =>
      'Tutti vedranno «Questo messaggio è stato eliminato». L’operazione è definitiva.';

  @override
  String get cancel => 'Annulla';

  @override
  String get delete => 'Elimina';

  @override
  String get requestDeleted => 'Richiesta di messaggio eliminata.';

  @override
  String wantsToMessage(String name) {
    return '$name vuole scriverti. Se accetti, potrete chattare e vedrà quando hai letto.';
  }

  @override
  String get accept => 'Accetta';

  @override
  String get removePhoto => 'Rimuovi foto';

  @override
  String get addPhoto => 'Aggiungi foto';

  @override
  String get writeMessage => 'Scrivi un messaggio';

  @override
  String get send => 'Invia';

  @override
  String get messages => 'Messaggi';

  @override
  String get chats => 'Chat';

  @override
  String get requests => 'Richieste';

  @override
  String requestsCount(int count) {
    return 'Richieste ($count)';
  }

  @override
  String get noChats =>
      'Non hai ancora chat. Puoi scrivere ai tuoi match e compagni.';

  @override
  String get findPeople => 'Trova persone';

  @override
  String get oldRequestsNote =>
      'Le vecchie richieste restano qui. I messaggi diretti ora sono solo per match e compagni; non arrivano nuove richieste.';

  @override
  String get noRequests => 'Nessuna richiesta di messaggio in sospeso.';

  @override
  String get backToChats => 'Torna alle chat';

  @override
  String get callRequests => 'Richieste di chiamate vocali';

  @override
  String noPendingWithActive(int count) {
    return 'Nessuna richiesta in sospeso · $count attive';
  }

  @override
  String pendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count richieste in attesa',
      one: '1 richiesta in attesa',
    );
    return '$_temp0';
  }

  @override
  String get pending => 'In attesa';

  @override
  String get activeTab => 'Attive';

  @override
  String get requestsOwnersOnly =>
      'Solo il proprietario e gli amministratori vedono le richieste.';

  @override
  String get goBack => 'Torna indietro';

  @override
  String noPendingFor(String group) {
    return 'Nessuna richiesta. Quelle dei membri di $group compariranno qui.';
  }

  @override
  String get noActive => 'Questo gruppo non ha concesso chiamate vocali.';

  @override
  String get refresh => 'Aggiorna';

  @override
  String get grantHint =>
      'Con il permesso concesso, la persona può chiamare tutti i suoi match e compagni. Le chiamate non vengono registrate; se lascia il gruppo, il permesso termina.';

  @override
  String get granted => 'Chiamate vocali attivate.';

  @override
  String get turnedOff => 'Chiamate vocali disattivate.';

  @override
  String theirNote(String note) {
    return 'Nota: $note';
  }

  @override
  String get turnOff => 'Disattiva';

  @override
  String get turnOn => 'Attiva';

  @override
  String get rankOnlyGrant =>
      'Il grado è pari o superiore al tuo: puoi solo approvare questa richiesta.';

  @override
  String get rankCannotRevoke =>
      'Il grado è pari o superiore al tuo: non puoi disattivarlo.';

  @override
  String get declineRequest => 'Rifiuta richiesta';

  @override
  String get turnOffCalls => 'Disattiva chiamate vocali';

  @override
  String get declineHint =>
      'Vedrà il motivo e potrà richiederlo dopo 7 giorni.';

  @override
  String get revokeHint =>
      'Una chiamata in corso termina subito. Vedrà il motivo e potrà richiederlo dopo 7 giorni.';

  @override
  String get reason => 'Motivo';

  @override
  String get reasonMin3 => 'Il motivo deve avere almeno 3 caratteri.';

  @override
  String get yesterday => 'Ieri';

  @override
  String get sendMessage => 'Invia messaggio';

  @override
  String get groupChatMembersOnly => 'Solo i membri del gruppo vedono la chat.';

  @override
  String get callVerifying => 'Verifica della crittografia…';

  @override
  String get callSecure => 'Chiamata sicura';

  @override
  String get callSecureDetail =>
      'Crittografia end-to-end. I codici di sicurezza dei due telefoni coincidono: nessuno si è intromesso.';

  @override
  String get callCheckFailed =>
      'Impossibile verificare la crittografia: i codici di sicurezza non coincidono. Chiudi e richiama.';

  @override
  String get showSecurityCode => 'Mostra codice di sicurezza';

  @override
  String get callOngoingTitle => 'Chiamata vocale in corso';

  @override
  String get callOngoingText => 'Crittografia end-to-end. Tocca per tornare.';
}
