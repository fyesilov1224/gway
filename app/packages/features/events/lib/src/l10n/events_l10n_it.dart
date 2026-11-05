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

  @override
  String get pollClosedShort => 'Chiuso';

  @override
  String closesAt(String date) {
    return 'Chiude: $date';
  }

  @override
  String get multipleAllowed => 'Scelta multipla';

  @override
  String get anonymousVote => 'Voto anonimo';

  @override
  String votersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count voti',
      one: '1 voto',
    );
    return '$_temp0';
  }

  @override
  String get pollOptions => 'Opzioni del sondaggio';

  @override
  String get pollClosedToast => 'Sondaggio chiuso.';

  @override
  String get pollDeleted => 'Sondaggio eliminato.';

  @override
  String get closePoll => 'Chiudi sondaggio';

  @override
  String get deletePoll => 'Elimina sondaggio';

  @override
  String get vote => 'Vota';

  @override
  String get voteSaved => 'Il tuo voto è stato salvato.';

  @override
  String get voters => 'Votanti';

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
  String get polls => 'Sondaggi';

  @override
  String get openPoll => 'Crea sondaggio';

  @override
  String get pollsEmpty =>
      'Fai una domanda ai membri, per esempio: che giorno ci vediamo?';

  @override
  String get pollOpened => 'Sondaggio creato.';

  @override
  String get question => 'Domanda';

  @override
  String get questionExample => 'Es. Che giorno ci vediamo?';

  @override
  String get questionMin3 => 'La domanda deve avere almeno 3 caratteri.';

  @override
  String optionN(int n) {
    return 'Opzione $n';
  }

  @override
  String get removeOption => 'Rimuovi l\'opzione';

  @override
  String get optionRequired => 'Compila l\'opzione o rimuovila.';

  @override
  String get addOption => 'Aggiungi opzione';

  @override
  String get allowMultiple => 'Consenti più scelte';

  @override
  String get anonymousHint => 'Nessuno vede chi ha votato cosa.';

  @override
  String get noEndTime => 'Nessuna scadenza';

  @override
  String get add => 'Aggiungi';

  @override
  String get removeEndTime => 'Rimuovi scadenza';

  @override
  String get startPoll => 'Crea il sondaggio';

  @override
  String get cardFooter => 'gway · trova la tua community';

  @override
  String myYear(int year) {
    return 'Il mio $year';
  }

  @override
  String get statAttended => 'eventi a cui ho partecipato';

  @override
  String get statHours => 'ore insieme';

  @override
  String get statOneGroup => 'gruppo incontrato';

  @override
  String get statGroups => 'gruppi diversi incontrati';

  @override
  String get statProvinces => 'province diverse';

  @override
  String get statOrganized => 'eventi organizzati';

  @override
  String get statWelcomed => 'nuovi arrivati accolti';

  @override
  String get statMemories => 'ricordi condivisi';

  @override
  String get favorites => 'I miei preferiti';

  @override
  String get topGroup => 'Il gruppo con cui sono stato di più';

  @override
  String topGroupLine(String group, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count incontri',
      one: '1 incontro',
    );
    return '$group · $_temp0';
  }

  @override
  String get iWasThere => 'C\'ero anch\'io';

  @override
  String get firstWithGroup => 'Il mio primo evento con questo gruppo.';

  @override
  String nthWithGroup(int n) {
    return 'Il mio $n° evento con questo gruppo.';
  }

  @override
  String get shareFailed =>
      'Impossibile condividere su questo dispositivo. Fai uno screenshot della card e condividilo.';

  @override
  String get share => 'Condividi';

  @override
  String yearSummaryTitle(int year) {
    return 'Il mio $year in sintesi';
  }

  @override
  String get yearEmpty =>
      'Quest\'anno non hai ancora partecipato a eventi. Il riepilogo comparirà qui dopo il primo incontro.';

  @override
  String yearShareText(int year) {
    return 'Il mio $year su GWAY';
  }

  @override
  String mapSemantics(int count) {
    return 'Mappa della Turchia: $count province esplorate';
  }

  @override
  String get explorationMap => 'La mia mappa di esplorazione';

  @override
  String get statExplored => 'province esplorate';

  @override
  String get statMetAt => 'eventi in cui ci siamo visti';

  @override
  String get recentExplored => 'Scoperte recenti';

  @override
  String get explorationEmpty =>
      'Qui si accendono le province dei tuoi eventi. La mappa si colora dopo il primo incontro.';

  @override
  String get findOnMap => 'Trova eventi sulla mappa';

  @override
  String explorationShareText(int count) {
    return 'Ho esplorato $count province su GWAY';
  }

  @override
  String get exploredProvinces => 'Province esplorate';

  @override
  String get explorationPrivacy =>
      'Lo vedi solo tu. Contano gli eventi a cui hai partecipato senza segnalazione «non venuto».';

  @override
  String get tonightVisible =>
      'Chi è nei tuoi gruppi vedrà che sei libero stasera. Si disattiva da solo alle 4:00.';

  @override
  String get joinedTable => 'Ti sei unito al tavolo.';

  @override
  String get declinedInvite => 'Hai rifiutato l\'invito.';

  @override
  String get yourStatus => 'Il tuo stato';

  @override
  String get visibleUntil4 => 'Sei visibile fino alle 4:00';

  @override
  String get notVisible => 'Al momento non sei visibile';

  @override
  String get youreFree => 'Sei libero';

  @override
  String get tonightIntro =>
      'Se sei libero, fallo sapere ai tuoi gruppi; potrete creare insieme un piccolo tavolo.';

  @override
  String get imFreeTonight => 'Sono libero stasera';

  @override
  String get noLongerFree => 'Non risulti più libero.';

  @override
  String get turnOffStatus => 'Disattiva stato';

  @override
  String get leftTable => 'Hai lasciato il tavolo.';

  @override
  String get smallTable => 'Piccolo tavolo';

  @override
  String get smallTableHint =>
      'Invita alcune persone libere; la chat del tavolo si apre quando siete in tre.';

  @override
  String get setUpTable => 'Crea un piccolo tavolo';

  @override
  String tableInvitesSent(int count) {
    return 'Inviti inviati a $count persone. La chat si apre quando siete in tre.';
  }

  @override
  String needMorePeople(int min, int now) {
    return 'Per un piccolo tavolo servono almeno altre $min persone libere dei tuoi gruppi (ora $now). Appena qualcuno è libero, potrai crearlo qui.';
  }

  @override
  String freeFromGroups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count persone dei tuoi gruppi sono libere stasera',
      one: '1 persona dei tuoi gruppi è libera stasera',
    );
    return '$_temp0';
  }

  @override
  String get chipCoffee => 'Caffè';

  @override
  String get chipWalk => 'Passeggiata';

  @override
  String get chipFood => 'Cena';

  @override
  String get chipCinema => 'Cinema';

  @override
  String get tonightSheetHint =>
      'Lo vedono solo le persone dei tuoi gruppi. Il tuo stato si disattiva alle 4:00.';

  @override
  String get whatToDo => 'Cosa ti va di fare? (facoltativo)';

  @override
  String get whatToDoHint => 'es. caffè, passeggiata';

  @override
  String get imFree => 'Sono libero';

  @override
  String get yourTable => 'Il tuo tavolo';

  @override
  String joinedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count si sono uniti',
      one: '1 si è unito',
    );
    return '$_temp0';
  }

  @override
  String waitingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count in attesa',
      one: '1 in attesa',
    );
    return '$_temp0';
  }

  @override
  String get settingUp => 'In preparazione';

  @override
  String get chatOpen => 'Chat aperta';

  @override
  String get tableChat => 'Chat del tavolo';

  @override
  String chatOpensWhen(int count) {
    return 'La chat si apre quando si uniscono altre $count persone. Lì scegliete insieme luogo e ora.';
  }

  @override
  String get leaveTable => 'Lascia il tavolo';

  @override
  String tableInviteTitle(String name) {
    return '$name ha creato un piccolo tavolo e ti invita.';
  }

  @override
  String tableInviteStatus(int joined, int pending) {
    return '$joined uniti · $pending in attesa. La chat si apre in tre.';
  }

  @override
  String get join => 'Partecipa';

  @override
  String get notTonight => 'Stasera no';

  @override
  String get tonight => 'Stasera';

  @override
  String get freeTonight => 'Liberi stasera';

  @override
  String get sharedGroupsOnly => 'Solo persone dei tuoi gruppi';

  @override
  String get nobodyFree => 'Al momento nessuno dei tuoi gruppi è libero.';

  @override
  String get howItWorks => 'Come funziona?';

  @override
  String get howStep1 =>
      'Di’ «Sono libero stasera» e, se vuoi, scrivi cosa ti va di fare.';

  @override
  String get howStep2 =>
      'Le persone dei tuoi gruppi ti vedono e tu vedi chi è libero.';

  @override
  String get howStep3 =>
      'Crea un piccolo tavolo; la chat si apre in tre e lì scegliete luogo e ora.';

  @override
  String get upcoming => 'In arrivo';

  @override
  String get calendar => 'Calendario';

  @override
  String get noUpcomingJoined => 'Non partecipi a eventi in arrivo.';

  @override
  String get showAll => 'Mostra tutto';

  @override
  String get noUpcoming60 =>
      'I tuoi gruppi non hanno eventi nei prossimi 60 giorni.';

  @override
  String get findGroup => 'Trova un gruppo';

  @override
  String filterAll(int count) {
    return 'Tutti · $count';
  }

  @override
  String filterMine(int count) {
    return 'I miei · $count';
  }

  @override
  String get tomorrow => 'Domani';

  @override
  String get going => 'Partecipi';

  @override
  String get waitlisted => 'In lista d\'attesa';

  @override
  String get awaitingApproval => 'In attesa di approvazione';

  @override
  String get full => 'Al completo';

  @override
  String goingOfCapacityShort(int count, int capacity) {
    return '$count/$capacity partecipanti';
  }

  @override
  String get startingSoon => 'Inizia a breve';

  @override
  String get next6Hours => 'Prossime 6 ore';

  @override
  String get wantWelcome => 'Vorrei essere accolto';

  @override
  String get wantWelcomeHint =>
      'Un membro volontario del gruppo ti accoglie all’ingresso: non andrai da solo.';

  @override
  String get noteForGreeter => 'Una nota per riconoscerti (facoltativa)';

  @override
  String get noteForGreeterHint => 'Es. Giacca rossa, zaino blu';

  @override
  String get sendRequest => 'Invia richiesta';

  @override
  String get welcomeRequestSent =>
      'La richiesta è stata inviata agli accoglienti. Ti avviseremo quando qualcuno la prenderà.';

  @override
  String get editMeetingNote => 'Modifica nota di ritrovo';

  @override
  String welcomePerson(String name) {
    return 'Accogli $name';
  }

  @override
  String describedAs(String note) {
    return 'Si è descritto così: $note';
  }

  @override
  String get whereMeet => 'Dove vi incontrerete?';

  @override
  String get whereMeetHint => 'Es. Davanti al bar all\'ingresso, 8:45';

  @override
  String get save => 'Salva';

  @override
  String get iWillWelcome => 'Lo accolgo io';

  @override
  String get noteUpdated => 'Nota di ritrovo aggiornata.';

  @override
  String youWillWelcome(String name) {
    return 'Accoglierai $name; ha visto la nota di ritrovo.';
  }

  @override
  String get stopWelcoming => 'Smetti di accogliere';

  @override
  String stopWelcomingBody(String name) {
    return 'Cercheremo un altro accogliente per $name e lo avviseremo.';
  }

  @override
  String get release => 'Lascia';

  @override
  String get releasedWelcome =>
      'Hai smesso di accogliere; stiamo cercando un nuovo accogliente.';

  @override
  String get firstTime => 'È la prima volta?';

  @override
  String greetersAvailable(int count) {
    return 'Questo gruppo ha $count accoglienti. Uno di loro può accoglierti e presentarti al gruppo.';
  }

  @override
  String get youWelcomed => 'Persone che accogli';

  @override
  String meetingAt(String note) {
    return 'Ritrovo: $note';
  }

  @override
  String get thankedYou => 'Ti ha ringraziato';

  @override
  String optionsFor(String name) {
    return 'Opzioni per $name';
  }

  @override
  String waitingWelcome(int count) {
    return 'In attesa di accoglienza ($count)';
  }

  @override
  String matchedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count persone hanno un accogliente.',
      one: '1 persona ha un accogliente.',
    );
    return '$_temp0';
  }

  @override
  String get firstTimer => 'Prima volta';

  @override
  String get max3Welcomes => 'Puoi accogliere fino a 3 persone per evento.';

  @override
  String get greeterJoinHint =>
      'Sei un accogliente. Partecipa all’evento per accogliere chi viene per la prima volta.';

  @override
  String get lookingGreeter => 'Cerchiamo un accogliente';

  @override
  String get lookingGreeterHint =>
      'Abbiamo avvisato gli accoglienti. Riceverai una notifica quando qualcuno accetterà.';

  @override
  String yourNote(String note) {
    return 'La tua nota: $note';
  }

  @override
  String get welcomeWithdrawn => 'La tua richiesta è stata ritirata.';

  @override
  String get withdrawRequest => 'Ritira richiesta';

  @override
  String get greetedBy => 'Accolto da';

  @override
  String get willGreet => 'Ti accoglierà';

  @override
  String get thank => 'Ringrazia';

  @override
  String thankReceived(String name) {
    return '$name ha ricevuto il tuo grazie.';
  }

  @override
  String get thanked => 'Hai ringraziato.';

  @override
  String get cancelWelcome => 'Annulla l\'accoglienza';

  @override
  String get nowGreeter =>
      'Ora sei un accogliente. Ti avviseremo quando un nuovo arrivato chiederà di essere accolto.';

  @override
  String get noLongerGreeter => 'Non sei più un accogliente.';

  @override
  String get welcomeSection => 'Accoglienza';

  @override
  String greetersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count accoglienti',
      one: '1 accogliente',
    );
    return '$_temp0';
  }

  @override
  String get greeterIntro =>
      'Chi viene per la prima volta può chiedere di essere accolto dalla pagina dell\'evento. Se diventi accogliente, sarai avvisato; lo accogli all\'ingresso e lo presenti al gruppo.';

  @override
  String greeterMemberHint(int count) {
    return 'Questo gruppo ha $count accoglienti. Al tuo primo evento tocca «Vorrei essere accolto».';
  }

  @override
  String greeterVisitorHint(int count) {
    return 'Questo gruppo ha $count accoglienti: non andrai da solo al primo evento, qualcuno ti accoglierà all’ingresso.';
  }

  @override
  String get becomeGreeter => 'Diventa accogliente';

  @override
  String quoted(String text) {
    return '«$text»';
  }

  @override
  String seatsGoing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count persone partecipano',
      one: '1 persona partecipa',
    );
    return '$_temp0';
  }

  @override
  String seatsOf(int count, int capacity) {
    return '$count / $capacity persone';
  }

  @override
  String seatsOfWaiting(int count, int capacity, int waiting) {
    return '$count / $capacity persone · $waiting in attesa';
  }

  @override
  String summaryAttended(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count persone hanno partecipato',
      one: '1 persona ha partecipato',
    );
    return '$_temp0';
  }

  @override
  String summaryRating(String avg, int count) {
    return '$avg ★ ($count recensioni)';
  }

  @override
  String waitlistPlace(int place) {
    return 'Lista d\'attesa · n. $place';
  }

  @override
  String get eventCanceled => 'Questo evento è stato annullato.';

  @override
  String eventCanceledBecause(String reason) {
    return 'Questo evento è stato annullato: $reason';
  }

  @override
  String reviewBy(String name, int stars) {
    return '$name, $stars stelle';
  }

  @override
  String get conflicting => 'Sovrapposto';

  @override
  String get events => 'Eventi';

  @override
  String get create => 'Crea';

  @override
  String eventsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ti restano $count eventi questo mese.',
      one: 'Ti resta 1 evento questo mese.',
    );
    return '$_temp0';
  }

  @override
  String get eventsLimitReached =>
      'Il limite di eventi del mese è stato raggiunto. Passa a un piano superiore per averne di più.';

  @override
  String groupRating(String avg, int count) {
    return '$avg · $count recensioni dei suoi eventi';
  }

  @override
  String get howWasIt => 'Com\'è andata?';

  @override
  String get howWasItHint =>
      'Valuta l\'evento a cui hai partecipato; tutti vedono solo la media.';

  @override
  String titleOnDate(String title, String date) {
    return '$title · $date';
  }

  @override
  String get eventsEmpty =>
      'Un\'escursione, un concerto o un incontro: crea il primo evento.';

  @override
  String get requestSent =>
      'La richiesta è stata inviata. Ti avviseremo quando l\'organizzatore deciderà.';

  @override
  String get attendanceSaved =>
      'Sei iscritto. Te lo ricorderemo prima dell\'inizio.';

  @override
  String waitlistJoined(int place) {
    return 'Sei in lista d\'attesa (n. $place). Ti avviseremo quando si libera un posto.';
  }

  @override
  String get conflictTitle => 'Hai un altro evento alla stessa ora';

  @override
  String conflictLine(String title, String date) {
    return '• $title · $date';
  }

  @override
  String get conflictOne =>
      'Se non puoi andare, rinuncia e lascia il posto a qualcun altro.';

  @override
  String get conflictMany =>
      'Se non puoi andare, rinuncia e lascia i posti ad altri.';

  @override
  String get keepBoth => 'Tienili entrambi';

  @override
  String get leaveOther => 'Lascia l\'altro';

  @override
  String get leaveOthers => 'Lascia gli altri';

  @override
  String get leftOther =>
      'Hai lasciato l\'altro evento; il tuo posto è libero.';

  @override
  String get leftOthers => 'Hai lasciato gli altri eventi.';

  @override
  String approvedPerson(String name) {
    return '$name ora partecipa.';
  }

  @override
  String declinedPerson(String name) {
    return 'Richiesta rifiutata; $name è stato avvisato.';
  }

  @override
  String get calendarFailed =>
      'Impossibile aprire il file del calendario. Riprova.';

  @override
  String get stopSeriesTitle => 'Interrompere la ripetizione?';

  @override
  String get stopSeriesBody =>
      'Non si aprono nuove date. Quelle già aperte restano; puoi annullarle una per una.';

  @override
  String get stop => 'Interrompi';

  @override
  String get seriesStopped => 'Ripetizione interrotta.';

  @override
  String get eventCanceledToast => 'Evento annullato.';

  @override
  String get eventNotFound =>
      'Questo evento non è stato trovato o non è più visibile.';

  @override
  String get goBack => 'Torna indietro';

  @override
  String joinGroupFirst(String name) {
    return 'Unisciti a $name';
  }

  @override
  String get sendJoinRequest => 'Chiedi di partecipare';

  @override
  String get joinWaitlist => 'Entra in lista d\'attesa';

  @override
  String get leaveEvent => 'Rinuncia';

  @override
  String get leaveWaitlist => 'Esci dalla lista d\'attesa';

  @override
  String get requestWithdrawn => 'La tua richiesta è stata ritirata.';

  @override
  String get attendanceRemoved => 'La tua partecipazione è stata annullata.';

  @override
  String eventShareText(String title) {
    return '$title · partecipa su GWAY:';
  }

  @override
  String get eventLinkCopied => 'Link dell\'evento copiato.';

  @override
  String get report => 'Segnala';

  @override
  String get eventOptions => 'Opzioni dell\'evento';

  @override
  String get edit => 'Modifica';

  @override
  String get cancelThisDate => 'Annulla questa data';

  @override
  String get stopRepeat => 'Interrompi la ripetizione';

  @override
  String get startedOrEnded => 'Iniziato o terminato';

  @override
  String seriesUntil(String label, String date) {
    return '$label · fino al $date';
  }

  @override
  String get addToCalendar => 'Aggiungi al calendario';

  @override
  String fee(String fee) {
    return 'Quota: $fee';
  }

  @override
  String get feeNotice =>
      'Si paga all\'organizzatore; GWAY non riceve pagamenti.';

  @override
  String get areYouComing => 'Vieni?';

  @override
  String get areYouComingHint =>
      'Se non puoi venire, lascia il posto alla lista d\'attesa.';

  @override
  String get yesComing => 'Sì, vengo';

  @override
  String get confirmThanks =>
      'Grazie, abbiamo avvisato l\'organizzatore che verrai.';

  @override
  String get cantCome => 'Non posso venire';

  @override
  String get spotFreed =>
      'La tua partecipazione è annullata; il posto è libero.';

  @override
  String get confirmedComing => 'Hai confermato che verrai.';

  @override
  String get otherEventSameTime => 'Hai un altro evento a quest\'ora';

  @override
  String get needsApproval => 'Partecipazione su approvazione';

  @override
  String get requirements => 'Requisiti';

  @override
  String get equipment => 'Attrezzatura necessaria';

  @override
  String joinRequestsCount(int count) {
    return 'Richieste ($count)';
  }

  @override
  String get attendees => 'Partecipanti';

  @override
  String confirmedOf(int going, int confirmed) {
    return '$confirmed partecipanti su $going hanno confermato.';
  }

  @override
  String confirmedName(String name) {
    return '$name · confermato';
  }

  @override
  String get shareWasThere => 'Condividi la card «C’ero anch’io»';

  @override
  String get howDidItGo => 'Com\'è andata?';

  @override
  String reviewsCount(int count) {
    return 'Recensioni ($count)';
  }

  @override
  String get reviewNotesPrivate => 'Solo gli organizzatori vedono le note.';

  @override
  String get attendanceCheck => 'Presenze';

  @override
  String get attendanceCheckHint =>
      'Segna chi non è venuto; contano solo i presenti per contributi e badge. Aperto 7 giorni dopo la fine.';

  @override
  String markedCame(String name) {
    return '$name segnato come presente.';
  }

  @override
  String markedMissed(String name) {
    return '$name segnato come assente.';
  }

  @override
  String get didntCome => 'Non venuto';

  @override
  String get came => 'Presente';

  @override
  String get memories => 'Ricordi';

  @override
  String get shareMemory => 'Condividi un ricordo';

  @override
  String get eventPolls => 'Sondaggi dell\'evento';

  @override
  String get noEditPermission =>
      'Non hai il permesso di modificare questo evento.';

  @override
  String get editEvent => 'Modifica evento';

  @override
  String get newEvent => 'Nuovo evento';

  @override
  String get addCover => 'Aggiungi immagine di copertina';

  @override
  String get titleExample => 'Es. Escursione nel bosco';

  @override
  String get starts => 'Inizio';

  @override
  String get endsOptional => 'Fine (facoltativa)';

  @override
  String get notSpecified => 'Non specificato';

  @override
  String get removeEnd => 'Rimuovi fine';

  @override
  String get repeat => 'Ripeti';

  @override
  String get noRepeat => 'Nessuna ripetizione';

  @override
  String get weekly => 'Ogni settimana';

  @override
  String get biweekly => 'Ogni due settimane';

  @override
  String get lastDateOptional => 'Ultima data (facoltativa)';

  @override
  String get untilYouStop => 'Finché non interrompi';

  @override
  String get removeLastDate => 'Rimuovi l\'ultima data';

  @override
  String get repeatHint =>
      'Le date successive si aprono da sole 4 settimane prima e ognuna conta nel limite mensile.';

  @override
  String get surpriseVenue => 'Luogo a sorpresa';

  @override
  String get surpriseHint =>
      'Il luogo viene rivelato solo ai partecipanti, all\'ora che scegli prima dell\'inizio.';

  @override
  String get hintPublic => 'Indizio (lo vedono tutti)';

  @override
  String get place => 'Luogo';

  @override
  String get hintExample => 'Es. In riva al mare, sul lato asiatico';

  @override
  String get placeExample => 'Es. Ingresso del parco o Online';

  @override
  String get writeHint => 'Scrivi un indizio.';

  @override
  String get writePlace => 'Inserisci il luogo.';

  @override
  String get realVenue => 'Luogo reale (solo partecipanti)';

  @override
  String get realVenueExample => 'Es. Davanti al teatro';

  @override
  String get writeRealVenue => 'Inserisci il luogo reale.';

  @override
  String get whenReveal => 'Quando rivelarlo?';

  @override
  String hoursBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ore prima',
      one: '1 ora prima',
    );
    return '$_temp0';
  }

  @override
  String get linkOptional => 'Link a mappa o online (facoltativo)';

  @override
  String get httpsRequired => 'Il link deve iniziare con https://.';

  @override
  String get description => 'Descrizione';

  @override
  String get capacity => 'Capienza (vuoto = illimitata)';

  @override
  String get capacityHint =>
      'Una volta pieno, i nuovi finiscono in lista d\'attesa.';

  @override
  String get capacityRange => 'La capienza deve essere da 1 a 10.000.';

  @override
  String get requirementsOptional => 'Requisiti (facoltativi)';

  @override
  String get requirementsExample => 'Es. Almeno 10 km di esperienza';

  @override
  String get equipmentOptional => 'Attrezzatura necessaria (facoltativa)';

  @override
  String get equipmentExample => 'Es. Casco, Acqua, Impermeabile';

  @override
  String get equipmentHint => 'Separa con virgole; fino a 10 voci.';

  @override
  String get equipmentLimit =>
      'Fino a 10 voci, ciascuna di 60 caratteri al massimo.';

  @override
  String get approvalRequired => 'Partecipazione su approvazione';

  @override
  String get approvalHint =>
      'Chi vuole partecipare invia una richiesta; tu la approvi.';

  @override
  String get feeOptional => 'Quota (facoltativa)';

  @override
  String get feeInfoOnly =>
      'Solo a titolo informativo; GWAY non riceve pagamenti.';

  @override
  String get amount => 'Importo';

  @override
  String get amountExample => 'Es. 150';

  @override
  String get validAmount => 'Inserisci un importo valido.';

  @override
  String get paymentNote => 'Nota di pagamento';

  @override
  String get paymentNoteExample => 'Es. In contanti sul posto';

  @override
  String get createEvent => 'Crea evento';

  @override
  String get rateEvent => 'Valuta l\'evento';

  @override
  String get yourReview => 'La tua recensione';

  @override
  String starsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stelle',
      one: '1 stella',
    );
    return '$_temp0';
  }

  @override
  String get noteToOrganizers => 'Nota per gli organizzatori (facoltativa)';

  @override
  String get noteToOrganizersHint =>
      'Solo gli organizzatori vedono la tua nota; gli altri vedono solo la media.';

  @override
  String get reviewDeleted => 'La tua recensione è stata eliminata.';

  @override
  String get delete => 'Elimina';

  @override
  String get reviewSaved => 'Grazie, la tua recensione è stata salvata.';

  @override
  String get groupNext => 'Prossimi eventi del gruppo';

  @override
  String sameDayOthers(int count) {
    return 'In questa data ci sono altri $count eventi della stessa categoria nella tua provincia. Scegli un altro giorno se non vuoi far scegliere i membri.';
  }

  @override
  String get cancelEvent => 'Annulla l\'evento';

  @override
  String get cancelEventBody =>
      'Partecipanti e lista d\'attesa vengono avvisati. L\'annullamento è definitivo.';

  @override
  String get reason => 'Motivo';

  @override
  String get cancelAction => 'Annulla';

  @override
  String hint(String hint) {
    return 'Indizio: $hint';
  }

  @override
  String hintRevealAt(String hint, String when) {
    return 'Indizio: $hint · Sarà rivelato ai partecipanti il $when.';
  }

  @override
  String get venueRevealed =>
      'Il luogo è stato rivelato ai partecipanti. Partecipa per vederlo.';

  @override
  String venueRevealAt(String when) {
    return 'Il luogo sarà rivelato ai partecipanti il $when.';
  }

  @override
  String get currencyTry => '₺ TRY';
}
