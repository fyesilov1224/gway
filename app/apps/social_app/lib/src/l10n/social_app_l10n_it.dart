// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'social_app_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class SocialAppL10nIt extends SocialAppL10n {
  SocialAppL10nIt([String locale = 'it']) : super(locale);

  @override
  String get posts => 'Post';

  @override
  String get newPost => 'Nuovo post';

  @override
  String get noOwnPosts =>
      'Non hai ancora condiviso post. Condividi la tua prima foto o il tuo primo video.';

  @override
  String get noPosts => 'Ancora nessun post.';

  @override
  String get shareFirstOwn => 'Condividi il tuo primo post';

  @override
  String get groupFirstPost => 'Pubblica tu il primo post nel feed del gruppo.';

  @override
  String get groupNoPosts => 'In questo gruppo non ci sono ancora post.';

  @override
  String get shareFirstGroup => 'Condividi il primo post';

  @override
  String get groupNotFound => 'Gruppo non trovato.';

  @override
  String get memoriesEmpty =>
      'Nessun ricordo condiviso per ora. I partecipanti possono aggiungere qui le loro foto.';

  @override
  String get plan => 'Piano';

  @override
  String get payment => 'Pagamento';

  @override
  String get onlyOwnerBilling =>
      'Solo il proprietario del gruppo può gestire i piani.';

  @override
  String get backToGroup => 'Torna al gruppo';

  @override
  String get writeSupportAboutGroup =>
      'Scrivi al team della piattaforma su questo gruppo';

  @override
  String get search => 'Cerca';

  @override
  String get notifications => 'Notifiche';

  @override
  String get goodNight => 'Buonanotte';

  @override
  String get goodMorning => 'Buongiorno';

  @override
  String get goodAfternoon => 'Buon pomeriggio';

  @override
  String get goodEvening => 'Buonasera';

  @override
  String greetingName(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String get tabToday => 'Oggi';

  @override
  String get tabGroups => 'Gruppi';

  @override
  String get tabCalendar => 'Calendario';

  @override
  String get tabMe => 'Io';

  @override
  String get tonightSay => 'Libero? Dillo e crea un tavolo';

  @override
  String get tonightTableSet => 'Il tuo tavolo è pronto';

  @override
  String get tonightInvited => 'Sei invitato a un tavolo';

  @override
  String tonightFreeWithYou(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count persone sono libere come te',
      one: '1 persona è libera come te',
    );
    return '$_temp0';
  }

  @override
  String get tonightFreeUntil => 'Sei libero · fino alle 4:00';

  @override
  String tonightFreeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count persone sono libere stasera',
      one: '1 persona è libera stasera',
    );
    return '$_temp0';
  }

  @override
  String get upcomingNone => 'I piani dei tuoi gruppi';

  @override
  String upcomingMine(int count, int mine) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count piani',
      one: '1 piano',
    );
    return '$_temp0 · $mine partecipazioni';
  }

  @override
  String upcomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count piani',
      one: '1 piano',
    );
    return '$_temp0, 60 giorni';
  }

  @override
  String get forToday => 'Per oggi';

  @override
  String get tonight => 'Stasera';

  @override
  String get upcoming => 'In arrivo';

  @override
  String get share => 'Condividi';

  @override
  String get post => 'Post';

  @override
  String get postHint => 'Fino a 10 foto o video';

  @override
  String get story => 'Storia';

  @override
  String get storyHint => 'Visibile per 24 ore';

  @override
  String get group => 'Gruppo';

  @override
  String get groupHint => 'Crea la tua community';

  @override
  String get create => 'Crea';

  @override
  String get messages => 'Messaggi';

  @override
  String get matching => 'Match';

  @override
  String get myGroups => 'I miei gruppi';

  @override
  String get pageNotFound =>
      'Pagina non trovata. Il link potrebbe essere vecchio o errato.';

  @override
  String get backHome => 'Torna alla home';

  @override
  String get groupsLeague => 'Lega dei gruppi';

  @override
  String get exploreOnMap => 'Esplora sulla mappa';

  @override
  String get yearMenu =>
      'Riepilogo dell\'anno, la mia mappa di esplorazione e le persone conosciute';

  @override
  String get yearSummary => 'Riepilogo dell\'anno';

  @override
  String get yearSummaryHint =>
      'Gli incontri di quest\'anno, in una card da condividere';

  @override
  String get explorationMap => 'La mia mappa di esplorazione';

  @override
  String get explorationMapHint =>
      'Province degli eventi a cui hai partecipato';

  @override
  String get metPeople => 'Persone conosciute';

  @override
  String get metPeopleHint =>
      'Persone con cui hai fatto una stretta di mano agli eventi';

  @override
  String get findTeammates => 'Trova compagni di squadra';

  @override
  String get saved => 'Salvati';

  @override
  String get gateError =>
      'Impossibile caricare i tuoi dati. Controlla la connessione e riprova.';

  @override
  String get searchPeople => 'Cerca persone';

  @override
  String get clearSearch => 'Cancella ricerca';

  @override
  String get settings => 'Impostazioni';

  @override
  String get editProfile => 'Modifica profilo';

  @override
  String get teammatePrefs => 'Preferenze compagni di squadra';

  @override
  String get matchProfile => 'Profilo match';

  @override
  String get voiceCalls => 'Chiamate vocali';

  @override
  String get blockedAccounts => 'Account bloccati';

  @override
  String get storyArchive => 'Archivio storie';

  @override
  String get notificationPrefs => 'Preferenze di notifica';

  @override
  String get mySanctions => 'Le mie sanzioni di gruppo';

  @override
  String get userGuide => 'Guida utente';

  @override
  String get supportFeedback => 'Assistenza e feedback';

  @override
  String newReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nuove risposte',
      one: '1 nuova risposta',
    );
    return '$_temp0';
  }

  @override
  String get twoFactor => 'Verifica in due passaggi';

  @override
  String get legalDocuments => 'Documenti legali';

  @override
  String get deleteAccount => 'Elimina account';

  @override
  String get signOut => 'Esci';

  @override
  String get nowPrivate => 'Il tuo account ora è privato.';

  @override
  String get nowPublic =>
      'Il tuo account ora è pubblico; le richieste in sospeso sono state approvate.';

  @override
  String get privateAccount => 'Account privato';

  @override
  String get privateAccountHint =>
      'Se attivo, solo i follower che approvi vedono i tuoi post e le tue storie.';

  @override
  String get groupsNowPublic =>
      'Ora i tuoi gruppi sono visibili a tutti sul tuo profilo.';

  @override
  String get groupsNowMembers =>
      'Ora i tuoi gruppi sono visibili solo ai membri dello stesso gruppo.';

  @override
  String get showGroups => 'Mostra i miei gruppi nel profilo';

  @override
  String get showGroupsHint =>
      'Se disattivato, solo i membri di un gruppo vedono che ne fai parte; gli amministratori di altri gruppi no.';

  @override
  String get language => 'Lingua';
}
