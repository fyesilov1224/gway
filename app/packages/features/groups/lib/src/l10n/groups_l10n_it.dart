// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'groups_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class GroupsL10nIt extends GroupsL10n {
  GroupsL10nIt([String locale = 'it']) : super(locale);

  @override
  String get unsupportedImage =>
      'Questo tipo di file non è supportato. Scegli JPEG, PNG o WebP.';

  @override
  String get joinOpen => 'Iscrizione libera';

  @override
  String get joinOpenHint => 'Chiunque può unirsi direttamente.';

  @override
  String get joinRequest => 'Iscrizione su richiesta';

  @override
  String get joinRequestHint => 'Gli amministratori approvano le richieste.';

  @override
  String get joinInvite => 'Solo su invito';

  @override
  String get joinInviteHint => 'Possono unirsi solo le persone invitate.';

  @override
  String get roleOwner => 'Proprietario del gruppo';

  @override
  String get roleAdmin => 'Amministratore';

  @override
  String get roleDiscipline => 'Commissione disciplinare';

  @override
  String get roleModerator => 'Moderatore';

  @override
  String get roleMember => 'Membro';

  @override
  String get handleMin =>
      'L\'indirizzo del gruppo deve avere almeno 3 caratteri.';

  @override
  String get handleChars =>
      'Usa solo lettere minuscole, numeri, trattini bassi e punti.';

  @override
  String get handleDots =>
      'Non può iniziare o finire con un punto né averne due di seguito.';

  @override
  String get nameMin => 'Il nome del gruppo deve avere almeno 3 caratteri.';

  @override
  String nameMax(int max) {
    return 'Il nome del gruppo può avere al massimo $max caratteri.';
  }

  @override
  String get httpsOnly => 'Inserisci un indirizzo che inizi con https://.';

  @override
  String get createGroup => 'Crea gruppo';

  @override
  String get groupInfo => 'Dati del gruppo';

  @override
  String get groupInfoHint =>
      'Potrai aggiungere logo, copertina, regole e link dopo aver creato il gruppo.';

  @override
  String get groupName => 'Nome del gruppo';

  @override
  String get about => 'Descrizione';

  @override
  String get aboutHint => 'Cosa fa il vostro gruppo e chi può unirsi?';

  @override
  String get joining => 'Iscrizione';

  @override
  String get changeLater => 'Potrai cambiarlo in seguito.';

  @override
  String get createTheGroup => 'Crea il gruppo';

  @override
  String get editGroup => 'Modifica gruppo';

  @override
  String get noEditPermission =>
      'Non hai il permesso di modificare questo gruppo.';

  @override
  String get backToGroup => 'Torna al gruppo';

  @override
  String get save => 'Salva';

  @override
  String get logoAndCover => 'Logo e copertina';

  @override
  String get imageHint => 'JPEG, PNG o WebP · fino a 5 MB';

  @override
  String get logo => 'Logo';

  @override
  String get cover => 'Copertina';

  @override
  String groupHandle(String handle) {
    return 'Indirizzo del gruppo: @$handle';
  }

  @override
  String get rules => 'Regole';

  @override
  String get rulesHint => 'Cosa ti aspetti dai membri, una regola per riga.';

  @override
  String get links => 'Link';

  @override
  String linksHint(int max) {
    return 'Sito web e social. Fino a $max.';
  }

  @override
  String get enterLabel => 'Inserisci un\'etichetta.';

  @override
  String get label => 'Etichetta';

  @override
  String get address => 'Indirizzo';

  @override
  String get removeLink => 'Rimuovi link';

  @override
  String get addLink => 'Aggiungi link';

  @override
  String get cancel => 'Annulla';

  @override
  String get saveChanges => 'Salva modifiche';

  @override
  String get deleteGroup => 'Elimina gruppo';

  @override
  String get deleteGroupBody =>
      'Gruppo, iscrizioni, ruoli, richieste e inviti vengono eliminati definitivamente. Il periodo residuo del piano non viene rimborsato.';

  @override
  String deleteGroupNamed(String name) {
    return 'Elimina $name';
  }

  @override
  String changeImage(String label) {
    return 'Cambia $label';
  }

  @override
  String addImage(String label) {
    return 'Aggiungi $label';
  }

  @override
  String get remove => 'Rimuovi';

  @override
  String get deleteForever => 'Elimina definitivamente il gruppo';

  @override
  String deleteConfirm(String handle) {
    return 'L\'operazione è irreversibile. Per confermare, scrivi l\'indirizzo del gruppo: $handle';
  }

  @override
  String get delete => 'Elimina';

  @override
  String get group => 'Gruppo';

  @override
  String get share => 'Condividi';

  @override
  String shareText(String name) {
    return 'Dai un’occhiata a $name su GWAY:';
  }

  @override
  String get moreOptions => 'Altre opzioni';

  @override
  String get leaveGroup => 'Lascia il gruppo';

  @override
  String get groupNotFound =>
      'Questo gruppo non è stato trovato o non è più visibile.';

  @override
  String get backToGroups => 'Torna ai gruppi';

  @override
  String leaveConfirm(String name) {
    return 'Lasciare $name? Se hai un ruolo nel gruppo, verrà rimosso anche quello.';
  }

  @override
  String get leave => 'Esci';

  @override
  String leftGroup(String name) {
    return 'Hai lasciato $name.';
  }

  @override
  String get suspendedNotice =>
      'Il team della piattaforma ha sospeso questo gruppo. Durante la sospensione lo vedono solo i membri.';

  @override
  String founded(String date) {
    return 'Fondato a $date';
  }

  @override
  String joinRequestsPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count richieste attendono approvazione.',
      one: '1 richiesta attende approvazione.',
    );
    return '$_temp0';
  }

  @override
  String get review => 'Rivedi';

  @override
  String get requestSent => 'La tua richiesta è stata inviata.';

  @override
  String get youAreMember => 'Sei membro';

  @override
  String get join => 'Unisciti';

  @override
  String joined(String name) {
    return 'Ti sei unito a $name.';
  }

  @override
  String get sendJoinRequest => 'Chiedi di unirti';

  @override
  String get requestSentShort => 'Richiesta inviata';

  @override
  String get withdrawRequest => 'Ritira richiesta';

  @override
  String get withdrawConfirm => 'Ritirare la richiesta?';

  @override
  String get undo => 'Ritira';

  @override
  String get requestWithdrawn => 'La tua richiesta è stata ritirata.';

  @override
  String get decline => 'Rifiuta';

  @override
  String get inviteDeclined => 'Invito rifiutato.';

  @override
  String get acceptInvite => 'Accetta invito';

  @override
  String followOn(String name) {
    return 'I post di $name compariranno nel tuo feed.';
  }

  @override
  String get followOff => 'Non segui più il gruppo.';

  @override
  String get following => 'Segui già';

  @override
  String get follow => 'Segui';

  @override
  String get managementTeam => 'Team di gestione';

  @override
  String allMembers(int count) {
    return 'Tutti i membri ($count)';
  }

  @override
  String get groups => 'Gruppi';

  @override
  String get discover => 'Scopri';

  @override
  String get myGroups => 'I miei gruppi';

  @override
  String get plans => 'Piani';

  @override
  String get searchHint => 'Cerca per nome o indirizzo del gruppo';

  @override
  String get clearSearch => 'Cancella ricerca';

  @override
  String get all => 'Tutti';

  @override
  String get noMatch => 'Nessun gruppo corrisponde alla ricerca.';

  @override
  String get clearFilters => 'Cancella filtri';

  @override
  String get noGroupsYet => 'Non ci sono ancora gruppi. Crea il primo.';

  @override
  String get showMore => 'Mostra altro';

  @override
  String get notJoinedYet => 'Non ti sei ancora unito a nessun gruppo.';

  @override
  String get discoverGroups => 'Scopri gruppi';

  @override
  String get plansHint =>
      'I piani li acquistano i proprietari. Crea il tuo gruppo e scegli un piano.';

  @override
  String get yourInvitations => 'I tuoi inviti';

  @override
  String get invitationsHint => 'Questi gruppi ti hanno invitato.';

  @override
  String invitedBy(String name) {
    return 'Invitato da $name';
  }

  @override
  String get linkCopied => 'Link copiato.';

  @override
  String inviteShareText(String name) {
    return 'Unisciti a $name su GWAY:';
  }

  @override
  String get revokeLinkTitle => 'Revocare il link?';

  @override
  String get revokeLinkBody =>
      'Nessuno potrà più unirsi con questo link. Chi si è già unito resta membro.';

  @override
  String get revoke => 'Revoca';

  @override
  String get inviteLink => 'Link d\'invito';

  @override
  String get inviteLinkHint =>
      'Condividilo su WhatsApp o Instagram. Chi apre il link entra direttamente, qualunque sia il tipo d\'iscrizione.';

  @override
  String get createLink => 'Crea link';

  @override
  String validUntil(String date) {
    return 'Fino al $date';
  }

  @override
  String peopleJoined(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count persone si sono unite',
      one: '1 persona si è unita',
    );
    return '$_temp0';
  }

  @override
  String peopleJoinedOf(int count, int max) {
    return '$count / $max iscritti';
  }

  @override
  String get newInviteLink => 'Nuovo link d\'invito';

  @override
  String get validity => 'Validità';

  @override
  String days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giorni',
      one: '1 giorno',
    );
    return '$_temp0';
  }

  @override
  String get howMany => 'Quante persone possono unirsi?';

  @override
  String get unlimited => 'Illimitato';

  @override
  String people(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count persone',
      one: '1 persona',
    );
    return '$_temp0';
  }

  @override
  String get createAndShare => 'Crea e condividi';

  @override
  String get invitation => 'Invito';

  @override
  String get linkInvalid =>
      'Questo link d\'invito non è più valido. Puoi chiederne uno nuovo all\'amministratore del gruppo.';

  @override
  String get seeGroup => 'Vedi gruppo';

  @override
  String get invitedToGroup => 'Sei stato invitato in questo gruppo.';

  @override
  String get joinGroup => 'Unisciti al gruppo';

  @override
  String get members => 'Membri';

  @override
  String get requests => 'Richieste';

  @override
  String get invitations => 'Inviti';

  @override
  String get roles => 'Ruoli';

  @override
  String get openCase => 'Apri un caso disciplinare';

  @override
  String get report => 'Segnala';

  @override
  String membersVisibility(int shown, int total) {
    return 'Solo i membri vedono l\'elenco completo. Qui: il team di gestione e $shown persone che mostrano i loro gruppi; il gruppo ha $total membri in totale.';
  }

  @override
  String optionsFor(String name) {
    return 'Opzioni per $name';
  }

  @override
  String get transferOwnership => 'Trasferisci la proprietà';

  @override
  String transferBody(String group, String person) {
    return 'La proprietà di $group passerà a $person. Resterai membro normale e non potrai annullare.';
  }

  @override
  String get transfer => 'Trasferisci';

  @override
  String transferred(String name) {
    return 'Proprietà trasferita a $name.';
  }

  @override
  String get hintAdmin => 'Modifica il gruppo e gestisce richieste e inviti.';

  @override
  String get hintDiscipline =>
      'Esamina i casi di segnalazione e decide le sanzioni.';

  @override
  String get hintModerator => 'Controlla contenuti e commenti.';

  @override
  String personJoined(String name) {
    return '$name si è unito al gruppo.';
  }

  @override
  String get requestDeclined => 'Richiesta rifiutata.';

  @override
  String get noPendingRequests => 'Nessuna richiesta in sospeso.';

  @override
  String get refresh => 'Aggiorna';

  @override
  String get approve => 'Approva';

  @override
  String get inviteSent => 'Invito inviato.';

  @override
  String get inviteByUsername => 'Invita per nome utente';

  @override
  String get invite => 'Invita';

  @override
  String get noPendingInvites => 'Nessun invito in sospeso.';

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
  String get suspended => 'Sospeso';

  @override
  String get groupsSection => 'Gruppi';

  @override
  String get groupsOwnHint =>
      'Solo i membri dello stesso gruppo vedono i tuoi gruppi. Puoi renderli pubblici nelle Impostazioni.';

  @override
  String get groupsOtherHint =>
      'Sono mostrati solo i gruppi in comune e quelli che gestisce.';

  @override
  String get noGroupsToShow => 'Nessun gruppo da mostrare.';

  @override
  String get handleTaken => 'Questo indirizzo è già in uso. Provane un altro.';

  @override
  String get groupAddress => 'Indirizzo del gruppo';

  @override
  String get groupAddressHint =>
      'L\'indirizzo della pagina del gruppo. Non potrà essere cambiato.';

  @override
  String get available => 'Disponibile';

  @override
  String get taken => 'Già in uso';

  @override
  String get notSpecified => 'Non specificato';

  @override
  String get provinceOptional => 'Provincia (facoltativa)';

  @override
  String get provinceHint =>
      'Il gruppo compare in questa provincia sulla mappa.';

  @override
  String get chooseCategory => 'Scegli una categoria.';

  @override
  String get category => 'Categoria';
}
