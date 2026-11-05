// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'events_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class EventsL10nIt extends EventsL10n {
  EventsL10nIt([String locale = 'it']) : super(locale);

  @override
  String get pollSingle =>
      'In questo sondaggio puoi scegliere una sola opzione.';

  @override
  String get pollOptionGone =>
      'Questa opzione non esiste più. Aggiorna la pagina.';

  @override
  String get reviewWindow =>
      'I partecipanti possono valutare l\'evento fino a 30 giorni dopo la fine.';

  @override
  String get greeterNeedsAttendance =>
      'Per accogliere, devi aver partecipato a un evento del gruppo.';

  @override
  String get note80 => 'La nota può avere fino a 80 caratteri.';

  @override
  String get pollClosed => 'Questo sondaggio è chiuso o non puoi votare.';

  @override
  String get cover5mb => 'L\'immagine di copertina può arrivare a 5 MB.';

  @override
  String get imagesOnly =>
      'Si possono caricare solo immagini JPEG, PNG o WebP.';

  @override
  String get claimNotAllowed =>
      'Non puoi segnalare questa attività ora: è terminata o non sei nel gruppo.';

  @override
  String get claimApprovedLocked =>
      'Una segnalazione approvata non può essere ritirata.';

  @override
  String get claimDuplicate => 'Hai già segnalato questa attività.';

  @override
  String get repeatsWeekly => 'Si ripete ogni settimana';

  @override
  String get repeatsBiweekly => 'Si ripete ogni due settimane';

  @override
  String surprisePlace(String place) {
    return 'Luogo a sorpresa · $place';
  }

  @override
  String get goalPersonal => 'Obiettivo personale';

  @override
  String get goalPersonalHint => 'Ogni membro raggiunge il proprio numero.';

  @override
  String get goalGroup => 'Obiettivo di gruppo';

  @override
  String get goalGroupHint =>
      'I contributi di tutti si sommano in un unico contatore.';

  @override
  String get goalTeam => 'Obiettivo di squadra';

  @override
  String get goalTeamHint =>
      'Gli amministratori formano le squadre; ogni squadra ha un contatore comune.';

  @override
  String get goalTask => 'Attività approvata';

  @override
  String get goalTaskHint =>
      'Un membro dice «Fatto» e un amministratore approva.';

  @override
  String unitAttended(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'partecipazioni',
      one: 'partecipazione',
    );
    return '$_temp0';
  }

  @override
  String unitOrganized(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'eventi organizzati',
      one: 'evento organizzato',
    );
    return '$_temp0';
  }

  @override
  String unitMemories(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ricordi',
      one: 'ricordo',
    );
    return '$_temp0';
  }

  @override
  String get claimPending => 'In attesa di approvazione';

  @override
  String get claimApproved => 'Approvato';

  @override
  String get claimRejected => 'Non approvato';

  @override
  String get notClaimedYet => 'Non ancora segnalato';

  @override
  String get whenAny => 'Sempre';

  @override
  String get whenToday => 'Oggi';

  @override
  String get whenWeek => 'Entro 7 giorni';

  @override
  String get viewDay => 'Giorno';

  @override
  String get viewWeek => 'Settimana';

  @override
  String get viewMonth => 'Mese';

  @override
  String countAttended(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count partecipazioni',
      one: '1 partecipazione',
    );
    return '$_temp0';
  }

  @override
  String countOrganized(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count eventi organizzati',
      one: '1 evento organizzato',
    );
    return '$_temp0';
  }

  @override
  String countMemories(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ricordi',
      one: '1 ricordo',
    );
    return '$_temp0';
  }

  @override
  String countReviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recensioni',
      one: '1 recensione',
    );
    return '$_temp0';
  }

  @override
  String countWelcomed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nuovi arrivati accolti',
      one: '1 nuovo arrivato accolto',
    );
    return '$_temp0';
  }

  @override
  String countHandshakes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count strette di mano',
      one: '1 stretta di mano',
    );
    return '$_temp0';
  }

  @override
  String countHeld(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count eventi',
      one: '1 evento',
    );
    return '$_temp0';
  }

  @override
  String countGoodReviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recensioni positive',
      one: '1 recensione positiva',
    );
    return '$_temp0';
  }

  @override
  String leagueStanding(String month, int groups, int rank, int points) {
    return '$month: $rank° su $groups gruppi, $points punti.';
  }

  @override
  String goingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count partecipanti',
      one: '1 partecipante',
    );
    return '$_temp0';
  }

  @override
  String goingOfCapacity(int count, int capacity) {
    return '$count / $capacity partecipanti';
  }

  @override
  String firstEventOfYear(String title) {
    return 'Primo evento dell\'anno: $title';
  }

  @override
  String firstEventOfYearOn(String title, String date) {
    return 'Primo evento dell\'anno: $title · $date';
  }

  @override
  String get myCalendar => 'Il mio calendario';

  @override
  String get groupCalendar => 'Calendario del gruppo';

  @override
  String get previous => 'Precedente';

  @override
  String get next => 'Successivo';

  @override
  String get today => 'Oggi';

  @override
  String get groupsEvents => 'Eventi dei miei gruppi';

  @override
  String get showNotJoined => 'Mostra anche quelli a cui non partecipi';

  @override
  String get noJoinedInRange =>
      'Non partecipi a eventi in queste date. Puoi guardare anche quelli dei tuoi gruppi.';

  @override
  String get noEventsInRange => 'Nessun evento in queste date.';

  @override
  String get showGroupsEvents => 'Mostra gli eventi dei miei gruppi';

  @override
  String get backToToday => 'Torna a oggi';

  @override
  String get noEventsDay => 'Nessun evento in questo giorno.';

  @override
  String get contributions => 'Contributo alla community';

  @override
  String get howBadges => 'Come si ottengono i badge?';

  @override
  String get badgesEmpty =>
      'Quando partecipi a un evento, qui compaiono il tuo contributo e il primo badge.';

  @override
  String get badgesRules =>
      'I badge contano solo ciò che fai davvero: eventi a cui partecipi e che organizzi, ricordi condivisi e recensioni. Mi piace e follower non contano. Le partecipazioni segnate «non venuto» dall’organizzatore non contano. Nessuno viene classificato.';

  @override
  String get categoryFan => 'Appassionato di categoria';

  @override
  String get pastEvents => 'Eventi passati';

  @override
  String get noPastEvents => 'Questo gruppo non ha ancora eventi passati.';

  @override
  String get refresh => 'Aggiorna';

  @override
  String get canceled => 'Annullato';

  @override
  String get olderEvents => 'Eventi meno recenti';

  @override
  String get completed => 'Completato';

  @override
  String get ended => 'Terminato';

  @override
  String teamName(String name) {
    return 'Squadra: $name';
  }

  @override
  String get teamNotice =>
      'Quando vieni aggiunto a una squadra, qui compaiono i tuoi progressi.';

  @override
  String get goals => 'Obiettivi';

  @override
  String get createGoal => 'Crea obiettivo';

  @override
  String get goalsEmpty =>
      'Per esempio «4 escursioni questo mese» o «50 partecipazioni insieme»: crea il primo obiettivo.';

  @override
  String get claimSent =>
      'La tua segnalazione è stata inviata all\'amministratore.';

  @override
  String get goal => 'Obiettivo';

  @override
  String get goalCountsRule =>
      'Contano solo gli eventi di questo gruppo nel periodo; le partecipazioni segnate «non venuto» non contano.';

  @override
  String get withdrawClaim => 'Ritira segnalazione';

  @override
  String get claimWithdrawn => 'La tua segnalazione è stata ritirata.';

  @override
  String get done => 'Fatto';

  @override
  String get teams => 'Squadre';

  @override
  String get createTeam => 'Crea squadra';

  @override
  String get noTeams => 'Ancora nessuna squadra.';

  @override
  String deleteTeam(String name) {
    return 'Elimina la squadra $name';
  }

  @override
  String get teamDeleted => 'Squadra eliminata.';

  @override
  String pendingClaims(int count) {
    return 'Segnalazioni in attesa ($count)';
  }

  @override
  String get claimRejectedToast => 'Segnalazione non approvata.';

  @override
  String get decline => 'Rifiuta';

  @override
  String get approve => 'Approva';

  @override
  String taskDone(String name) {
    return '$name ha completato l\'attività.';
  }

  @override
  String completions(int count) {
    return 'Completato da ($count)';
  }

  @override
  String get noCompletions =>
      'Nessuno l\'ha ancora completato. Chi lo completa riceve il badge di questo obiettivo sul profilo.';

  @override
  String get goalCanceled => 'Obiettivo annullato.';

  @override
  String get cancelGoal => 'Annulla l\'obiettivo';

  @override
  String teamCreated(String name) {
    return 'Squadra «$name» creata.';
  }

  @override
  String get teamNameLabel => 'Nome della squadra';

  @override
  String get createTheTeam => 'Crea la squadra';

  @override
  String createTeamWith(int count) {
    return 'Crea la squadra ($count persone)';
  }

  @override
  String get goalCreated => 'Obiettivo creato.';

  @override
  String get title => 'Titolo';

  @override
  String get goalTitleExample => 'Es. Escursioni di ottobre';

  @override
  String get taskTitleExample => 'Es. Spiegare il percorso a un nuovo membro';

  @override
  String get titleMin3 => 'Il titolo deve avere almeno 3 caratteri.';

  @override
  String get descriptionOptional => 'Descrizione (facoltativa)';

  @override
  String get targetNumber => 'Numero obiettivo';

  @override
  String get target1to1000 => 'Inserisci un numero da 1 a 1000.';

  @override
  String get period => 'Periodo';

  @override
  String periodRange(String from, String to) {
    return '$from – $to (massimo 92 giorni)';
  }

  @override
  String get createTheGoal => 'Crea l\'obiettivo';

  @override
  String get iDidTask => 'Ho fatto l\'attività';

  @override
  String get whatDidYouDo => 'Cosa hai fatto? (facoltativo)';

  @override
  String get whatDidYouDoHint =>
      'L\'amministratore approva dopo aver letto questa nota.';

  @override
  String get cancel => 'Annulla';

  @override
  String get send => 'Invia';

  @override
  String get handshake => 'Stretta di mano';

  @override
  String get handshakeHint =>
      'Scansionate i vostri codici; finite entrambi in «Persone conosciute».';

  @override
  String get open => 'Apri';

  @override
  String handshakeAt(String title) {
    return 'Stretta di mano · $title';
  }

  @override
  String get myCode => 'Il mio codice';

  @override
  String get scan => 'Scansiona';

  @override
  String get yourHandshakeCode => 'Il tuo codice stretta di mano';

  @override
  String get codeHint =>
      'L\'altra persona scansiona questo codice nella scheda «Scansiona» o lo digita. Il codice cambia ogni pochi minuti; una foto non funzionerà dopo.';

  @override
  String get cameraFailed =>
      'Impossibile aprire la fotocamera. Consenti l’accesso nelle impostazioni o scrivi il codice qui sotto.';

  @override
  String get scanHint =>
      'Inquadra il codice QR dell\'altra persona o digita il suo codice.';

  @override
  String get typeCodeHint =>
      'Digita il codice di 6 caratteri sullo schermo dell\'altra persona.';

  @override
  String get code => 'Codice';

  @override
  String get alreadyMet => 'Vi conoscete già';

  @override
  String get metNow => 'Vi siete conosciuti!';

  @override
  String personWithUsername(String name, String username) {
    return '$name (@$username)';
  }

  @override
  String get ok => 'OK';

  @override
  String get metPeople => 'Persone conosciute';

  @override
  String get metEmpty =>
      'Quando stringi la mano a qualcuno a un evento, compare qui. La stretta di mano si apre nella pagina dell\'evento.';

  @override
  String get goToCalendar => 'Vai al mio calendario';

  @override
  String get metPrivacy =>
      'Lo vedi solo tu. Il tuo profilo mostra solo il numero di strette di mano.';

  @override
  String metRow(String username, String event, String date) {
    return '@$username · $event · $date';
  }

  @override
  String get howPoints => 'Come si calcolano i punti?';

  @override
  String get leagueIntro =>
      'I gruppi della stessa categoria e provincia gareggiano ogni mese. Contano gli eventi conclusi nel mese.';

  @override
  String get ruleAttendance => 'Partecipazione: 1 punto';

  @override
  String get ruleAttendanceHint =>
      'Ogni persona presente; fino a 30 per evento.';

  @override
  String get ruleHeld => 'Evento: 5 punti';

  @override
  String get ruleHeldHint =>
      'Ogni evento a cui sono venute almeno 3 persone oltre all\'organizzatore.';

  @override
  String get ruleWelcome => 'Accoglienza: 3 punti';

  @override
  String get ruleWelcomeHint => 'Accogliere chi viene per la prima volta.';

  @override
  String get ruleReview => 'Recensione positiva: 1 punto';

  @override
  String get ruleReviewHint => 'Ogni recensione da 4 o 5 stelle.';

  @override
  String get leagueRulesNote =>
      'Chi è segnato «non venuto» non conta. I risultati diventano definitivi 8 giorni dopo la fine del mese; i membri dei primi tre gruppi vengono avvisati.';

  @override
  String get groupsLeague => 'Lega dei gruppi';

  @override
  String get category => 'Categoria';

  @override
  String get province => 'Provincia';

  @override
  String get month => 'Mese';

  @override
  String seasonClosed(String month) {
    return 'La stagione di $month è chiusa; la classifica è definitiva.';
  }

  @override
  String get seasonRunning =>
      'La stagione è in corso. I punti si aggiornano al termine degli eventi; risultati definitivi 8 giorni dopo la fine del mese.';

  @override
  String leagueEmpty(String province) {
    return 'Nessun gruppo della lega $province ha ancora punti questo mese.';
  }

  @override
  String points(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count punti',
      one: '1 punto',
    );
    return '$_temp0';
  }

  @override
  String rank(int rank) {
    return '$rank°';
  }

  @override
  String leagueName(String province, String category) {
    return '$province · Lega $category';
  }

  @override
  String get noPointsYet =>
      'Ancora nessun punto questo mese. Eventi conclusi, presenze e accoglienze danno punti.';

  @override
  String get mapAttribution =>
      '© Stadia Maps © OpenMapTiles © collaboratori di OpenStreetMap';

  @override
  String get map => 'Mappa';

  @override
  String get mapView => 'Vista mappa';

  @override
  String get listView => 'Vista elenco';

  @override
  String get all => 'Tutti';

  @override
  String get wholeArea => 'Tutta l\'area';

  @override
  String km(int km) {
    return '$km km';
  }

  @override
  String get mapLoadFailed => 'Impossibile caricare i dati della mappa.';

  @override
  String get retry => 'Riprova';

  @override
  String get noFilterResults => 'Nessun risultato con questi filtri.';

  @override
  String get clearFilters => 'Cancella filtri';

  @override
  String get noNearby => 'Nessun evento in arrivo o gruppo in quest\'area.';

  @override
  String get zoomOut => 'Riduci zoom';

  @override
  String get openEvent => 'Apri evento';

  @override
  String memberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membri',
      one: '1 membro',
    );
    return '$_temp0';
  }

  @override
  String get noVisible =>
      'Nessun evento in arrivo o gruppo nell\'area visibile.';

  @override
  String get backToMap => 'Torna alla mappa';

  @override
  String upcomingCount(int count) {
    return 'Eventi in arrivo ($count)';
  }

  @override
  String get directions => 'Indicazioni';

  @override
  String get meetingPointOptional => 'Punto di ritrovo (facoltativo)';

  @override
  String get meetingPointHint =>
      'Sceglilo sulla mappa; l\'evento comparirà sulla mappa.';

  @override
  String pointPicked(String lat, String lng) {
    return 'Selezionato · $lat, $lng';
  }

  @override
  String get removeMeetingPoint => 'Rimuovi punto di ritrovo';

  @override
  String get meetingPoint => 'Punto di ritrovo';

  @override
  String get pickHint => 'Ingrandisci e tocca il punto di ritrovo.';

  @override
  String get pickAgainHint => 'Tocca altrove per spostare il punto.';

  @override
  String get pickThisPoint => 'Scegli questo punto';

  @override
  String get mapUnavailable => 'La mappa non è disponibile al momento.';
}
