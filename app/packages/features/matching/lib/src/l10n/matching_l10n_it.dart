// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'matching_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class MatchingL10nIt extends MatchingL10n {
  MatchingL10nIt([String locale = 'it']) : super(locale);

  @override
  String get unsupportedImage =>
      'Si possono caricare solo foto JPEG, PNG o WebP.';

  @override
  String get modeFriend => 'Amicizia';

  @override
  String get modeDating => 'Incontri';

  @override
  String get genderWoman => 'Donna';

  @override
  String get genderMan => 'Uomo';

  @override
  String get genderNonbinary => 'Non binario';

  @override
  String get adultsOnly => 'Il match è riservato ai maggiori di 18 anni.';

  @override
  String get pickMode => 'Scegli almeno una modalità: Amicizia o Incontri.';

  @override
  String get pickInterest => 'Scegli chi cerchi per gli Incontri.';

  @override
  String get ageRangeInvalid => 'L\'intervallo di età non è valido.';

  @override
  String sharedGroup(String group) {
    return 'Gruppo in comune: $group';
  }

  @override
  String sharedGroupsMore(String group, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In comune: $group e altri $count gruppi',
      one: 'In comune: $group e un altro gruppo',
    );
    return '$_temp0';
  }

  @override
  String get pkgReveal => 'I miei match';

  @override
  String get pkgRevealText =>
      'Scopri con chi hai fatto match: nome, foto e profilo.';

  @override
  String get pkgChat => 'Chat match';

  @override
  String get pkgChatText =>
      'Scrivi ai tuoi match. Include la visualizzazione dei match.';

  @override
  String get pkgAdmirers => 'Chi ti ha messo like';

  @override
  String get pkgAdmirersText =>
      'Scopri chi ti ha messo like e fai match subito ricambiando.';

  @override
  String get pkgUnlimited => 'Like illimitati';

  @override
  String get pkgUnlimitedText =>
      'Nessun limite giornaliero; annulla e filtri inclusi.';

  @override
  String get pkgSuper => 'Super Like';

  @override
  String get pkgSuperText =>
      '5 Super Like al giorno; la persona ti vede per primo nel suo mazzo.';

  @override
  String get pkgBoost => 'Boost';

  @override
  String get pkgBoostText =>
      'Una volta al giorno, in cima ai mazzi dei gruppi in comune per 30 minuti.';

  @override
  String get pkgTeammates => 'Compagno di squadra';

  @override
  String get pkgTeammatesText =>
      'Invia richieste di squadra e chatta con i tuoi compagni.';

  @override
  String get pkgAll => 'Tutto in uno';

  @override
  String get pkgAllText =>
      'Tutti i piani in uno, molto più conveniente che separati.';

  @override
  String get superLikedYou => 'Ti ha messo un Super Like';

  @override
  String get options => 'Opzioni';

  @override
  String get fullProfile => 'Profilo completo';

  @override
  String get stampLike => 'LIKE';

  @override
  String get stampPass => 'NO';

  @override
  String get stampSuper => 'SUPER';

  @override
  String photoOf(String name, int number) {
    return '$name, foto $number';
  }

  @override
  String get about => 'Su di me';

  @override
  String get interests => 'Interessi';

  @override
  String get sharedGroupsTitle => 'Gruppi in comune';

  @override
  String get createProfileTitle => 'Crea profilo match';

  @override
  String get myProfile => 'Il mio profilo match';

  @override
  String get birthDateLabel => 'La tua data di nascita';

  @override
  String get pickBasics => 'Scegli data di nascita, genere e provincia.';

  @override
  String get confirmAgeConsent =>
      'Per continuare, conferma di avere più di 18 anni e dai il consenso esplicito.';

  @override
  String profileReady(int min) {
    return 'Il profilo è pronto. Ora aggiungi almeno $min foto.';
  }

  @override
  String get saved => 'Salvato.';

  @override
  String get pickBirthDate => 'Scegli data di nascita';

  @override
  String ageNote(int age) {
    return '$age anni · la tua scheda mostra solo l’età';
  }

  @override
  String get gender => 'Genere';

  @override
  String get province => 'Provincia';

  @override
  String get aboutHint => 'Parlaci di te';

  @override
  String get jobOptional => 'Professione (facoltativa)';

  @override
  String get educationOptional => 'Istruzione (facoltativa)';

  @override
  String get interestsFromProfile =>
      'I tuoi interessi vengono dal profilo social.';

  @override
  String get lookingFor => 'Cosa cerchi?';

  @override
  String get friendHint => 'Persone con cui andare agli eventi e chiacchierare';

  @override
  String get datingHint => 'Una relazione romantica';

  @override
  String get whoLookingFor => 'Chi cerchi?';

  @override
  String ageRange(int min, int max) {
    return 'Fascia di età: $min–$max';
  }

  @override
  String get consentTitle => 'Consenso';

  @override
  String get iam18 => 'Ho più di 18 anni.';

  @override
  String get consentText =>
      'Per il match, do il consenso esplicito al trattamento del mio genere, di chi cerco, della mia data di nascita, della mia provincia e delle mie foto, e alla loro visualizzazione da parte delle persone dei miei gruppi in comune che hanno attivato il match. Posso revocare il consenso in qualsiasi momento eliminando i miei dati di match.';

  @override
  String get createProfile => 'Crea il mio profilo';

  @override
  String get save => 'Salva';

  @override
  String get photos => 'Foto';

  @override
  String photosMin(int min) {
    return 'Aggiungi almeno $min foto perché la scheda compaia. La prima è la copertina.';
  }

  @override
  String photosMax(int max) {
    return 'Fino a $max foto. La prima è la copertina; tocca una foto per cambiarla.';
  }

  @override
  String get addPhoto => 'Aggiungi foto';

  @override
  String get cover => 'Copertina';

  @override
  String get removePhoto => 'Rimuovi foto';

  @override
  String get pauseProfile => 'Metti in pausa il profilo';

  @override
  String get pauseHint =>
      'Nessuno ti vede e non arrivano nuove schede; match e chat restano.';

  @override
  String get deleteData => 'Elimina i miei dati di match';

  @override
  String get deleteDataHint =>
      'Profilo, foto e like vengono eliminati; i match terminano. Il consenso è revocato.';

  @override
  String get deleteDataTitle => 'Elimina dati di match';

  @override
  String get deleteDataBody =>
      'Profilo match, foto e like vengono eliminati per sempre e tutti i match terminano. L’operazione è definitiva.';

  @override
  String get delete => 'Elimina';

  @override
  String get dataDeleted => 'I tuoi dati di match sono stati eliminati.';

  @override
  String get itsAMatch => 'È un match!';

  @override
  String bothLiked(String name) {
    return 'Tu e $name vi siete piaciuti.';
  }

  @override
  String get keepSwiping => 'Continua a scorrere';

  @override
  String get sendMessage => 'Invia messaggio';

  @override
  String get reportProfile => 'Segnala profilo';

  @override
  String get reportPhoto => 'Segnala questa foto';

  @override
  String get block => 'Blocca';

  @override
  String get blockHint => 'Non vi vedrete più da nessuna parte.';

  @override
  String get cancel => 'Annulla';

  @override
  String get newMatch => 'Hai fatto match con qualcuno!';

  @override
  String tapToSee(String date) {
    return 'Tocca per scoprire chi è · $date';
  }

  @override
  String get revealReason =>
      'Hai un match! Prendi il piano I miei match per scoprire chi è.';

  @override
  String get keepFriend => 'Restare solo amici';

  @override
  String get keepDating => 'Restare solo negli incontri';

  @override
  String keepFriendBody(String name) {
    return 'Il match negli incontri con $name termina per entrambi; quello di amicizia e la chat restano.';
  }

  @override
  String keepDatingBody(String name) {
    return 'Il match di amicizia con $name termina per entrambi; quello negli incontri e la chat restano.';
  }

  @override
  String get keptFriend => 'Ora siete in match solo come amici.';

  @override
  String get keptDating => 'Ora siete in match solo negli incontri.';

  @override
  String get continueAction => 'Continua';

  @override
  String get endMatch => 'Termina match';

  @override
  String endMatchBody(String name) {
    return 'Il match con $name termina e la chat si chiude per entrambi. L’operazione è definitiva.';
  }

  @override
  String get end => 'Termina';

  @override
  String get matchEnded => 'Il match è terminato.';

  @override
  String get noMatches =>
      'Ancora nessun match. Qui compaiono i like reciproci.';

  @override
  String get backToDiscover => 'Torna a scoprire';

  @override
  String get report => 'Segnala';

  @override
  String get matching => 'Match';

  @override
  String get admirers => 'Chi ti ha messo like';

  @override
  String get packages => 'Piani';

  @override
  String get more => 'Altro';

  @override
  String get filtersLocked =>
      'I filtri per età, provincia e interesse sono inclusi nel piano Like illimitati.';

  @override
  String get filters => 'Filtri';

  @override
  String get suspended =>
      'Il team della piattaforma ha chiuso il tuo profilo match. Scrivi al Supporto per i dettagli.';

  @override
  String addPhotosToStart(int min) {
    return 'Aggiungi almeno $min foto per mostrare la scheda e iniziare a scoprire.';
  }

  @override
  String get paused =>
      'Il profilo è in pausa; nessuno ti vede. Match e chat restano.';

  @override
  String get likesOut =>
      'Hai finito i like gratuiti di oggi. Con Like illimitati puoi metterne quanti vuoi.';

  @override
  String get supersOut =>
      'Hai finito i Super Like di oggi. Domani si rinnovano.';

  @override
  String get superUsed =>
      'Hai usato il Super Like di oggi. 5 al giorno con il piano Super Like.';

  @override
  String get rewindLocked =>
      'Recuperare chi hai saltato per errore è incluso in Like illimitati.';

  @override
  String rewoundTo(String mode) {
    return 'L\'ultima persona saltata è tornata nel mazzo $mode.';
  }

  @override
  String boostReason(int minutes) {
    return 'Con un Boost compari in cima ai mazzi per $minutes minuti.';
  }

  @override
  String boosting(int minutes) {
    return 'Sei in Boost. Mancano $minutes minuti.';
  }

  @override
  String get boostUsed => 'Hai usato il Boost di oggi. Domani si rinnova.';

  @override
  String get boost => 'Boost';

  @override
  String boostBody(int minutes) {
    return 'Per $minutes minuti compari per primo nei mazzi dei gruppi in comune. Una volta al giorno.';
  }

  @override
  String boosted(int minutes) {
    return 'Boost attivato! Sei in cima per $minutes minuti.';
  }

  @override
  String get deckEmpty =>
      'Per ora non c’è nessun altro. Si riempirà man mano che entri nei gruppi e altri attivano il match.';

  @override
  String get deckEmptyFiltered =>
      'Nessuno corrisponde più ai filtri. Prova ad ampliarli.';

  @override
  String get refresh => 'Aggiorna';

  @override
  String get clearFilters => 'Azzera filtri';

  @override
  String allowanceUnlimited(int supers) {
    return 'Like illimitati · $supers Super Like rimasti.';
  }

  @override
  String get allowanceOut => 'Hai finito i like di oggi; domani si rinnovano.';

  @override
  String allowance(int likes, int supers) {
    return 'Oggi ti restano $likes like e $supers Super Like.';
  }

  @override
  String get undo => 'Annulla';

  @override
  String get pass => 'Passa';

  @override
  String get superLike => 'Super Like';

  @override
  String get like => 'Mi piace';

  @override
  String get introTitle => 'Conosci persone nuove dai gruppi in comune';

  @override
  String get intro1 =>
      'Vedi solo persone che hanno attivato il match nei gruppi di cui fai parte o che segui.';

  @override
  String get intro2 =>
      'Scorri a destra per mettere like, a sinistra per passare, in alto per un Super Like.';

  @override
  String get intro3 =>
      'Se vi piacete a vicenda, è match. Scrivi al tuo match con il piano Chat match.';

  @override
  String get intro4 =>
      'Amicizia e Incontri sono modalità separate; scegline una o entrambe.';

  @override
  String get intro5 =>
      'Il profilo è visibile solo a chi ha attivato il match. Mettilo in pausa o eliminalo quando vuoi.';

  @override
  String get createMyProfile => 'Crea il mio profilo match';

  @override
  String seePackageOf(String package) {
    return 'Vedi il piano $package';
  }

  @override
  String get allPackages => 'Tutti i piani';

  @override
  String get packagesTitle => 'Piani match';

  @override
  String get packagesIntro =>
      'Creare il profilo e scorrere è gratis. Ogni funzione è un piano a sé; prendi solo ciò che vuoi.';

  @override
  String get adminAllOpen => 'Come amministratore hai tutti i piani attivi';

  @override
  String openUntil(String date) {
    return 'Attivo fino al $date';
  }

  @override
  String ageFilter(int min, int max) {
    return 'Età: $min – $max';
  }

  @override
  String get allProvinces => 'Tutte le province';

  @override
  String get interest => 'Interesse';

  @override
  String get all => 'Tutti';

  @override
  String get apply => 'Applica';

  @override
  String get clear => 'Azzera';

  @override
  String get noAdmirers =>
      'Per ora nessun like in attesa. Continua a scorrere; qui comparirà chi ti mette like.';

  @override
  String get backToSwiping => 'Torna a scorrere';

  @override
  String get likeAndMatch => 'Metti like e fai match';

  @override
  String get noPendingLikes => 'Ancora nessun like in attesa';

  @override
  String likedYouCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count persone ti hanno messo like',
      one: '1 persona ti ha messo like',
    );
    return '$_temp0';
  }

  @override
  String get admirersPitch =>
      'Con il piano Chi ti ha messo like scopri chi sono e fai match subito.';

  @override
  String get seePackage => 'Vedi il piano';
}
