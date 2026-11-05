// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'live_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class LiveL10nIt extends LiveL10n {
  LiveL10nIt([String locale = 'it']) : super(locale);

  @override
  String get commentRate =>
      'Hai commentato molto in poco tempo. Aspetta un po’ e riprova.';

  @override
  String get mutedListenOnly =>
      'Sei silenziato in questo gruppo e puoi solo ascoltare.';

  @override
  String get cannotComment => 'Al momento non puoi commentare questa diretta.';

  @override
  String get roleHost => 'Conduttore';

  @override
  String get roleSpeaker => 'Relatore';

  @override
  String get roleListener => 'Ascoltatore';

  @override
  String get startLive => 'Avvia diretta';

  @override
  String hostedBy(String name) {
    return 'Conduce $name';
  }

  @override
  String get join => 'Partecipa';

  @override
  String upcomingAt(String date) {
    return 'In arrivo · $date';
  }

  @override
  String get scheduledCanceled => 'Diretta programmata annullata.';

  @override
  String get cancel => 'Annulla';

  @override
  String get start => 'Avvia';

  @override
  String get reminderRemoved => 'Promemoria rimosso.';

  @override
  String get reminderSet => 'Ti avviseremo quando inizia.';

  @override
  String get reminding => 'Promemoria attivo';

  @override
  String get remind => 'Ricordami';

  @override
  String get schedule5min =>
      'Una diretta programmata deve iniziare tra almeno 5 minuti.';

  @override
  String get scheduled =>
      'Diretta programmata. I membri possono chiedere un promemoria.';

  @override
  String get liveBroadcast => 'Diretta';

  @override
  String get liveIntro =>
      'I membri entrano nella stanza audio; parla chi porti sul palco.';

  @override
  String get title => 'Titolo';

  @override
  String get titleExample => 'Es. Organizzare l’escursione di domenica';

  @override
  String get titleMin3 => 'Il titolo deve avere almeno 3 caratteri.';

  @override
  String get now => 'Ora';

  @override
  String get scheduleIt => 'Programma';

  @override
  String minutesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ti restano $count minuti di diretta questo mese.',
      one: 'Ti resta 1 minuto di diretta questo mese.',
    );
    return '$_temp0';
  }

  @override
  String get minutesUsedUp =>
      'Il tempo di diretta del mese è esaurito. Passa a un piano superiore per averne di più.';

  @override
  String get startTheLive => 'Avvia la diretta';

  @override
  String get liveNow => 'In diretta ora';

  @override
  String trayLabel(String group, String title) {
    return '$group è in diretta: $title';
  }

  @override
  String youAreLive(String title) {
    return 'Sei in diretta: $title. Tocca per tornare.';
  }

  @override
  String get connecting => 'Connessione alla diretta…';

  @override
  String get inBroadcast => 'Sei in diretta · tocca per tornare';

  @override
  String get micMutedByMod => 'Un responsabile ha spento il tuo microfono';

  @override
  String get micOff => 'Spegni microfono';

  @override
  String get micOn => 'Accendi microfono';

  @override
  String startsOn(String date) {
    return 'Questa diretta inizia il $date.';
  }

  @override
  String get ended => 'Questa diretta è terminata.';

  @override
  String get notFound =>
      'Diretta non trovata. Forse devi essere membro del gruppo.';

  @override
  String get goBack => 'Torna indietro';

  @override
  String get onStageNow => 'Sei sul palco. Accendi il microfono per parlare.';

  @override
  String get nowListener => 'Ora sei un ascoltatore.';

  @override
  String get leaveBroadcast => 'Esci dalla diretta';

  @override
  String get leaveHostBody =>
      'Puoi terminarla per tutti. Se esci soltanto, finisce da sola dopo 2 minuti.';

  @override
  String get justLeave => 'Esci soltanto';

  @override
  String get endBroadcast => 'Termina la diretta';

  @override
  String get inviteToStage => 'Porta sul palco';

  @override
  String get removeFromStage => 'Togli dal palco';

  @override
  String get muteMic => 'Spegni il microfono';

  @override
  String get unmuteMic => 'Riaccendi il microfono';

  @override
  String get kick => 'Rimuovi dalla diretta';

  @override
  String kickBody(String name) {
    return '$name non potrà più entrare in questa diretta.';
  }

  @override
  String get cancelAction => 'Annulla';

  @override
  String get remove => 'Rimuovi';

  @override
  String get raisedHands => 'Mani alzate';

  @override
  String get commentDeleted => 'Commento eliminato.';

  @override
  String get thanksForJoining =>
      'La diretta è terminata. Grazie di aver partecipato.';

  @override
  String get youWereKicked => 'Sei stato rimosso da questa diretta.';

  @override
  String get connectFailedShort => 'Impossibile connettersi alla diretta.';

  @override
  String handsRaised(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mani alzate',
      one: '1 mano alzata',
    );
    return '$_temp0';
  }

  @override
  String get onStage => 'Sul palco';

  @override
  String listeners(int count) {
    return 'Ascoltatori · $count';
  }

  @override
  String get noListeners => 'Ancora nessun ascoltatore.';

  @override
  String get minimize => 'Riduci e resta in diretta';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count persone',
      one: '1 persona',
    );
    return '$_temp0';
  }

  @override
  String get broadcastOptions => 'Opzioni della diretta';

  @override
  String get endForAll => 'Termina per tutti';

  @override
  String get handRaised =>
      'Hai alzato la mano. Il conduttore può portarti sul palco.';

  @override
  String get you => 'Tu';

  @override
  String get speaking => 'sta parlando';

  @override
  String get micOffState => 'microfono spento';

  @override
  String get handUp => 'mano alzata';

  @override
  String get sendReaction => 'Invia una reazione';

  @override
  String get leave => 'Esci';

  @override
  String get leaveStage => 'Scendi dal palco';

  @override
  String get reactions => 'Reazioni';

  @override
  String get comments => 'Commenti';

  @override
  String get raiseHand => 'Alza la mano';

  @override
  String get lowerHand => 'Abbassa la mano';

  @override
  String get report => 'Segnala';

  @override
  String get deleteComment => 'Elimina commento';

  @override
  String get firstComment => 'Scrivi tu il primo commento.';

  @override
  String get writeComment => 'Scrivi un commento…';

  @override
  String get send => 'Invia';

  @override
  String get connectFailed =>
      'Impossibile connettersi alla diretta. Controlla la connessione e riprova.';

  @override
  String get participant => 'Partecipante';

  @override
  String get micNeedsManager =>
      'Solo un responsabile della diretta può accendere il tuo microfono.';

  @override
  String get micFailed =>
      'Impossibile accendere il microfono. Controlla il permesso del microfono.';
}
