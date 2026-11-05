// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'profile_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class ProfileL10nIt extends ProfileL10n {
  ProfileL10nIt([String locale = 'it']) : super(locale);

  @override
  String get unsupportedImage =>
      'Questo tipo di file non è supportato. Scegli JPEG, PNG o WebP.';

  @override
  String get usernameTaken =>
      'Questo nome utente è già in uso. Provane un altro.';

  @override
  String get checkInput => 'Controlla i dati inseriti.';

  @override
  String get usernameReserved =>
      'Questo nome utente non può essere usato. Provane un altro.';

  @override
  String get usernameCooldown =>
      'Puoi cambiare il nome utente solo una volta ogni 30 giorni.';

  @override
  String get maxInterests10 => 'Puoi scegliere fino a 10 interessi.';

  @override
  String get levelBeginner => 'Principiante';

  @override
  String get levelBeginnerHint => 'Sto iniziando';

  @override
  String get levelIntermediate => 'Intermedio';

  @override
  String get levelIntermediateHint => 'Lo faccio regolarmente';

  @override
  String get levelAdvanced => 'Avanzato';

  @override
  String get levelAdvancedHint => 'Ho esperienza';

  @override
  String get slotWeekdayMorning => 'Mattine infrasettimanali';

  @override
  String get slotWeekdayNoon => 'Mezzogiorno infrasettimanale';

  @override
  String get slotWeekdayEvening => 'Sere infrasettimanali';

  @override
  String get slotWeekendMorning => 'Mattine del weekend';

  @override
  String get slotWeekendAfternoon => 'Pomeriggi del weekend';

  @override
  String get slotWeekendEvening => 'Sere del weekend';

  @override
  String get partMorning => 'Mattina';

  @override
  String get partNoon => 'Pomeriggio';

  @override
  String get partEvening => 'Sera';

  @override
  String get goalFun => 'Divertirmi';

  @override
  String get goalFitness => 'Restare in forma';

  @override
  String get goalCompetition => 'Prepararmi per una gara';

  @override
  String get goalLearning => 'Imparare cose nuove';

  @override
  String get goalMentoring => 'Condividere la mia esperienza';

  @override
  String get goalSocial => 'Conoscere persone nuove';

  @override
  String get freqMonthly => 'Qualche volta al mese';

  @override
  String get freqWeekly => 'Una volta a settimana';

  @override
  String get freqFewWeekly => '2–3 volte a settimana';

  @override
  String get freqDaily => 'Quasi ogni giorno';

  @override
  String get sizePair => 'In due';

  @override
  String get sizeSmall => 'Piccolo gruppo (3–6)';

  @override
  String get sizeLarge => 'Gruppo numeroso';

  @override
  String get looking => 'Cerca una squadra';

  @override
  String lookingWithLevel(String level) {
    return 'Cerca una squadra · $level';
  }

  @override
  String reasonActivities(String list) {
    return 'Stessa attività: $list';
  }

  @override
  String reasonInterests(String list) {
    return 'Interessi comuni: $list';
  }

  @override
  String get reasonProvince => 'Siete nella stessa provincia';

  @override
  String reasonGroup(String group) {
    return 'Gruppo comune: $group';
  }

  @override
  String reasonGroups(int count) {
    return '$count gruppi comuni';
  }

  @override
  String reasonLevel(String level) {
    return 'Stesso livello: $level';
  }

  @override
  String reasonTimes(String list) {
    return 'Disponibili: $list';
  }

  @override
  String reasonGoals(String list) {
    return 'Obiettivi comuni: $list';
  }

  @override
  String get reasonFrequency => 'Volete vedervi con la stessa frequenza';

  @override
  String get hasVehicle => 'Ha un mezzo';

  @override
  String get hasEquipment => 'Ha la sua attrezzatura';

  @override
  String get usernameRequired => 'Scegli un nome utente.';

  @override
  String usernameMin(int min) {
    return 'Il nome utente deve avere almeno $min caratteri.';
  }

  @override
  String usernameMax(int max) {
    return 'Il nome utente può avere al massimo $max caratteri.';
  }

  @override
  String get usernameChars =>
      'Usa solo a–z, 0–9, trattino basso (_) e punto (.).';

  @override
  String get usernameDots =>
      'Il nome utente non può iniziare o finire con un punto.';

  @override
  String get usernameDoubleDot => 'Non puoi usare due punti di seguito.';

  @override
  String get nameRequired => 'Inserisci il tuo nome.';

  @override
  String nameMax(int max) {
    return 'Il nome può avere al massimo $max caratteri.';
  }

  @override
  String get editProfile => 'Modifica profilo';

  @override
  String get save => 'Salva';

  @override
  String get profileInfo => 'Dati del profilo';

  @override
  String get profileInfoHint =>
      'Questi dati sono visibili a tutti sul tuo profilo.';

  @override
  String get yourName => 'Il tuo nome';

  @override
  String get usernameEvery30 =>
      'Puoi cambiare il nome utente una volta ogni 30 giorni.';

  @override
  String usernameLockedUntil(String date) {
    return 'Potrai cambiarlo dopo il $date.';
  }

  @override
  String get about => 'Su di me';

  @override
  String get aboutHint => 'Parla di te e delle attività che ami.';

  @override
  String get interests => 'Interessi';

  @override
  String interestsMax(int max) {
    return 'Puoi sceglierne fino a $max.';
  }

  @override
  String get cancel => 'Annulla';

  @override
  String get saveChanges => 'Salva modifiche';

  @override
  String get remove => 'Rimuovi';

  @override
  String get removeCover => 'Rimuovi foto di copertina';

  @override
  String get addCover => 'Aggiungi copertina';

  @override
  String get changeCover => 'Cambia copertina';

  @override
  String get changeAvatar => 'Cambia foto profilo';

  @override
  String get photos => 'Foto profilo e copertina';

  @override
  String get photosHint => 'JPEG, PNG o WebP · fino a 5 MB';

  @override
  String get addAvatar => 'Aggiungi foto profilo';

  @override
  String get removeAvatar => 'Rimuovi foto profilo';

  @override
  String get followers => 'Follower';

  @override
  String get following => 'Seguiti';

  @override
  String get privateLists =>
      'Questo account è privato. Seguilo per vedere i suoi elenchi.';

  @override
  String get backToProfile => 'Torna al profilo';

  @override
  String get noFollowers => 'Ancora nessun follower.';

  @override
  String get noFollowing => 'Non segue ancora nessuno.';

  @override
  String get refresh => 'Aggiorna';

  @override
  String get removeFollower => 'Rimuovi follower';

  @override
  String removeFollowerBody(String username) {
    return 'Rimuovere $username dai tuoi follower? Non riceverà alcuna notifica.';
  }

  @override
  String get removeAction => 'Rimuovi';

  @override
  String get friends => 'Siete amici';

  @override
  String get followRequests => 'Richieste di follow';

  @override
  String get noFollowRequests =>
      'Nessuna richiesta in sospeso. Gli account privati approvano le richieste qui.';

  @override
  String get approve => 'Approva';

  @override
  String get delete => 'Elimina';

  @override
  String get blockedAccounts => 'Account bloccati';

  @override
  String get noBlocked =>
      'Non hai bloccato nessuno. Puoi bloccare dal menu di un profilo.';

  @override
  String get unblock => 'Sblocca';

  @override
  String get onboardWho => 'Conosciamoci';

  @override
  String get onboardWhoHint =>
      'Scegli il nome e il nome utente mostrati nel tuo profilo.';

  @override
  String get onboardPhoto => 'Foto profilo';

  @override
  String get onboardPhotoHint =>
      'Così i tuoi gruppi ti riconoscono. Puoi aggiungerla anche dopo.';

  @override
  String get onboardInterests => 'I tuoi interessi';

  @override
  String onboardInterestsHint(int max) {
    return 'Scegline fino a $max per ricevere suggerimenti di gruppi adatti a te.';
  }

  @override
  String get back => 'Indietro';

  @override
  String stepOf(int step, int total) {
    return 'Passo $step di $total';
  }

  @override
  String get signOut => 'Esci';

  @override
  String get skipForNow => 'Salta per ora';

  @override
  String get continueAction => 'Continua';

  @override
  String get finish => 'Fine';

  @override
  String get usernameHelper => 'Usa lettere minuscole, numeri, _ e .';

  @override
  String get avatarPreview => 'Anteprima foto profilo';

  @override
  String get choosePhoto => 'Scegli foto';

  @override
  String get chooseAnotherPhoto => 'Scegli un\'altra foto';

  @override
  String get profile => 'Profilo';

  @override
  String get settings => 'Impostazioni';

  @override
  String get profileNotFound =>
      'Questo profilo non è stato trovato o non è più visibile.';

  @override
  String get backToMyProfile => 'Torna al mio profilo';

  @override
  String suspendedUntil(String date) {
    return 'Questo account è sospeso fino al $date.';
  }

  @override
  String get followsYou => 'Ti segue';

  @override
  String get yourTeammate => 'Il tuo compagno di squadra';

  @override
  String joined(String date) {
    return 'Iscritto da $date';
  }

  @override
  String followRequestsPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count richieste di follow attendono approvazione.',
      one: '1 richiesta di follow attende approvazione.',
    );
    return '$_temp0';
  }

  @override
  String get review => 'Rivedi';

  @override
  String teammateRequestsPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count richieste di squadra ti aspettano.',
      one: '1 richiesta di squadra ti aspetta.',
    );
    return '$_temp0';
  }

  @override
  String get youBlocked => 'Hai bloccato questo account';

  @override
  String get youBlockedHint =>
      'Se sblocchi, vedrete di nuovo i post l’uno dell’altro.';

  @override
  String get privateAccount => 'Questo account è privato';

  @override
  String get privateAccountHint =>
      'Segui questo account per vedere foto, video e storie.';

  @override
  String get addInterestsNudge =>
      'Aggiungi i tuoi interessi e ti troveremo gruppi e compagni di squadra.';

  @override
  String get add => 'Aggiungi';

  @override
  String blockTitle(String username) {
    return 'Bloccare $username?';
  }

  @override
  String get blockBody =>
      'Non vedrà il tuo profilo, i post e le storie, non potrà trovarti né scriverti. Smetterete di seguirvi. Non saprà di essere stata bloccata.';

  @override
  String get block => 'Blocca';

  @override
  String get becomeTeammates => 'Diventa compagno di squadra';

  @override
  String nowTeammates(String name) {
    return 'Tu e $name ora siete compagni di squadra.';
  }

  @override
  String get acceptTeammate => 'Accetta la richiesta di squadra';

  @override
  String get requestWithdrawn => 'Richiesta ritirata.';

  @override
  String get withdrawTeammate => 'Ritira la richiesta di squadra';

  @override
  String get teammateEnded => 'Non siete più compagni di squadra.';

  @override
  String get endTeammate => 'Smetti di essere compagni di squadra';

  @override
  String get moreOptions => 'Altre opzioni';

  @override
  String get linkCopied => 'Link del profilo copiato.';

  @override
  String get copyLink => 'Copia link del profilo';

  @override
  String get removedFromFollowers => 'Rimosso dai tuoi follower.';

  @override
  String get removeFromFollowers => 'Rimuovi dai miei follower';

  @override
  String get report => 'Segnala';

  @override
  String get unblocked => 'Sbloccato.';

  @override
  String get statPosts => 'Post';

  @override
  String get statFollowers => 'Follower';

  @override
  String get statFollowing => 'Seguiti';

  @override
  String withdrawFollowBody(String username) {
    return 'Ritirare la richiesta di follow a $username?';
  }

  @override
  String unfollowBody(String username) {
    return 'Smettere di seguire $username?';
  }

  @override
  String unfollowPrivateBody(String username) {
    return 'Smettere di seguire $username? L’account è privato, quindi per vedere i post dovrai inviare di nuovo la richiesta.';
  }

  @override
  String get withdrawRequest => 'Ritira richiesta';

  @override
  String get unfollow => 'Non seguire più';

  @override
  String get followBack => 'Ricambia';

  @override
  String get follow => 'Segui';

  @override
  String get requestSent => 'Richiesta inviata';

  @override
  String get followingState => 'Segui già';

  @override
  String noAccountMatch(String query) {
    return 'Nessun account corrisponde a «$query».';
  }

  @override
  String get clearSearch => 'Cancella ricerca';

  @override
  String get searchHint => 'Inizia a scrivere per cercare persone o tag.';

  @override
  String get refreshSuggestions => 'Aggiorna suggerimenti';

  @override
  String get suggestionsForYou => 'Suggeriti per te';

  @override
  String mutualFollows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Seguito da $count persone che segui',
      one: 'Seguito da 1 persona che segui',
    );
    return '$_temp0';
  }

  @override
  String get popularAccount => 'Account popolare';

  @override
  String get seePackage => 'Vedi il piano';

  @override
  String requestSentNotify(String name) {
    return 'Richiesta inviata. Ti avviseremo quando $name accetterà.';
  }

  @override
  String becomeTeammatesWith(String name) {
    return 'Diventa compagno di squadra di $name';
  }

  @override
  String get shortMessage => 'Un breve messaggio (facoltativo)';

  @override
  String get shortMessageHint => 'Sabato mattina al parco?';

  @override
  String get sendRequest => 'Invia richiesta';

  @override
  String get findTeammates => 'Trova compagni di squadra';

  @override
  String get myTeammatePrefs => 'Le mie preferenze di squadra';

  @override
  String get tabSuggestions => 'Suggerimenti';

  @override
  String get tabRequests => 'Richieste';

  @override
  String tabRequestsCount(int count) {
    return 'Richieste ($count)';
  }

  @override
  String get tabMyTeam => 'La mia squadra';

  @override
  String get findYourTeammate => 'Trova il tuo compagno di squadra';

  @override
  String waitingForYou(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count persone vogliono essere tue compagne di squadra',
      one: '1 persona vuole essere tua compagna di squadra',
    );
    return '$_temp0';
  }

  @override
  String get teammatesLocked =>
      'Vedere i suggerimenti, inviare e accettare richieste e scrivere ai compagni di squadra si sblocca con il piano Compagno di squadra.';

  @override
  String get beVisible => 'Fatti vedere anche tu';

  @override
  String get beVisibleBody =>
      'Attiva «Cerco una squadra» e chi ama le stesse cose potrà inviarti richieste.';

  @override
  String get setPrefs => 'Imposta le mie preferenze';

  @override
  String get nowPublicSuggest =>
      'Il tuo account ora è pubblico; puoi comparire nei suggerimenti.';

  @override
  String get privateHidden =>
      'Il tuo account è privato, non compari nei suggerimenti';

  @override
  String get privateHiddenBody =>
      'Gli account privati non compaiono nei suggerimenti di squadra. Se rendi pubblico l’account, vengono approvate anche le richieste di follow in sospeso.';

  @override
  String get makePublic => 'Rendi pubblico il mio account';

  @override
  String get noSuggestions =>
      'Per ora nessuno corrisponde. Compila interessi e preferenze per ricevere più suggerimenti.';

  @override
  String quoted(String text) {
    return '«$text»';
  }

  @override
  String get whySuggested => 'Perché è suggerito';

  @override
  String get noPendingTeammate => 'Nessuna richiesta di squadra in sospeso.';

  @override
  String get seeSuggestions => 'Vedi suggerimenti';

  @override
  String get incoming => 'Ricevute';

  @override
  String get accept => 'Accetta';

  @override
  String get decline => 'Rifiuta';

  @override
  String get requestDeclined => 'Richiesta rifiutata.';

  @override
  String get outgoing => 'Inviate';

  @override
  String get awaitingReply => 'In attesa di risposta';

  @override
  String get withdraw => 'Ritira';

  @override
  String get noTeammates =>
      'Non hai ancora compagni di squadra. Inizia inviando una richiesta a un suggerimento.';

  @override
  String optionsFor(String name) {
    return 'Opzioni per $name';
  }

  @override
  String get teammatePrefs => 'Preferenze di squadra';

  @override
  String get prefsSavedVisible =>
      'Preferenze salvate. Ora compari nei suggerimenti.';

  @override
  String get prefsSaved => 'Preferenze salvate.';

  @override
  String get whatToDo => 'Cosa vuoi fare?';

  @override
  String activitiesHint(int max) {
    return 'Attività per cui cerchi compagni. Fino a $max.';
  }

  @override
  String get yourLevel => 'Il tuo livello';

  @override
  String get yourGoals => 'I tuoi obiettivi';

  @override
  String get multipleChoice => 'Puoi sceglierne più di uno.';

  @override
  String get howOften => 'Ogni quanto vuoi vederti?';

  @override
  String get whenFree => 'Quando sei libero?';

  @override
  String get whenFreeHint => 'Tocca i momenti in cui sei libero.';

  @override
  String get whatTeam => 'Che tipo di squadra vuoi?';

  @override
  String get whichProvince => 'In quale provincia ti trovi?';

  @override
  String get provinceHint =>
      'Usata solo per i suggerimenti, non compare nel profilo.';

  @override
  String get province => 'Provincia';

  @override
  String get ratherNotSay => 'Preferisco non dirlo';

  @override
  String get extras => 'Altre informazioni';

  @override
  String get iHaveVehicle => 'Ho un mezzo';

  @override
  String get iHaveVehicleHint => 'Posso dare passaggi.';

  @override
  String get iHaveEquipment => 'Ho la mia attrezzatura';

  @override
  String get iHaveEquipmentHint =>
      'Ho bici, tenda, racchetta o altra attrezzatura.';

  @override
  String get describeYourself => 'Descriviti';

  @override
  String get describeHint => 'Compare sotto il tuo nome nei suggerimenti.';

  @override
  String get describeExample =>
      'Cerco qualcuno per camminare nei weekend al mattino.';

  @override
  String get willAppear => 'Comparirai nei suggerimenti.';

  @override
  String get notAppearing => 'Al momento non compari nei suggerimenti.';

  @override
  String get lookingForTeam => 'Cerco una squadra';

  @override
  String get lookingOn =>
      'Compari nei suggerimenti; possono inviarti richieste di squadra.';

  @override
  String get lookingOff =>
      'Attivalo e chi ama le stesse cose ti troverà. Gli account privati non compaiono nei suggerimenti.';

  @override
  String prefsComplete(int percent) {
    return 'Preferenze completate al $percent%';
  }

  @override
  String get prefsCompleteHint =>
      'Più compili, più i suggerimenti sono precisi.';

  @override
  String get weekday => 'Giorni feriali';

  @override
  String get weekend => 'Weekend';

  @override
  String get username => 'Nome utente';

  @override
  String get available => 'Disponibile';

  @override
  String get taken => 'Già in uso';

  @override
  String blockedUser(String username) {
    return '$username è bloccato.';
  }
}
