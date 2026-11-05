// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'groups_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class GroupsL10nNl extends GroupsL10n {
  GroupsL10nNl([String locale = 'nl']) : super(locale);

  @override
  String get unsupportedImage =>
      'Dit bestandstype wordt niet ondersteund. Kies JPEG, PNG of WebP.';

  @override
  String get joinOpen => 'Vrij lidmaatschap';

  @override
  String get joinOpenHint => 'Iedereen kan direct lid worden.';

  @override
  String get joinRequest => 'Lidmaatschap op verzoek';

  @override
  String get joinRequestHint => 'Beheerders keuren verzoeken goed.';

  @override
  String get joinInvite => 'Alleen op uitnodiging';

  @override
  String get joinInviteHint => 'Alleen uitgenodigde mensen kunnen lid worden.';

  @override
  String get roleOwner => 'Groepseigenaar';

  @override
  String get roleAdmin => 'Beheerder';

  @override
  String get roleDiscipline => 'Tuchtcommissie';

  @override
  String get roleModerator => 'Moderator';

  @override
  String get roleMember => 'Lid';

  @override
  String get handleMin => 'Het groepsadres moet minstens 3 tekens hebben.';

  @override
  String get handleChars =>
      'Gebruik alleen kleine letters, cijfers, underscores en punten.';

  @override
  String get handleDots =>
      'Mag niet met een punt beginnen of eindigen en geen twee punten achter elkaar bevatten.';

  @override
  String get nameMin => 'De groepsnaam moet minstens 3 tekens hebben.';

  @override
  String nameMax(int max) {
    return 'De groepsnaam mag maximaal $max tekens hebben.';
  }

  @override
  String get httpsOnly => 'Voer een adres in dat met https:// begint.';

  @override
  String get createGroup => 'Groep maken';

  @override
  String get groupInfo => 'Groepsgegevens';

  @override
  String get groupInfoHint =>
      'Logo, omslag, regels en links kun je toevoegen nadat je de groep hebt gemaakt.';

  @override
  String get groupName => 'Groepsnaam';

  @override
  String get about => 'Over de groep';

  @override
  String get aboutHint => 'Wat doet jullie groep en wie kan meedoen?';

  @override
  String get joining => 'Lidmaatschap';

  @override
  String get changeLater => 'Je kunt dit later wijzigen.';

  @override
  String get createTheGroup => 'Groep maken';

  @override
  String get editGroup => 'Groep bewerken';

  @override
  String get noEditPermission => 'Je mag deze groep niet bewerken.';

  @override
  String get backToGroup => 'Terug naar groep';

  @override
  String get save => 'Opslaan';

  @override
  String get logoAndCover => 'Logo en omslag';

  @override
  String get imageHint => 'JPEG, PNG of WebP · max. 5 MB';

  @override
  String get logo => 'Logo';

  @override
  String get cover => 'Omslag';

  @override
  String groupHandle(String handle) {
    return 'Groepsadres: $handle';
  }

  @override
  String get rules => 'Regels';

  @override
  String get rulesHint => 'Wat je van leden verwacht, één regel per lijn.';

  @override
  String get links => 'Links';

  @override
  String linksHint(int max) {
    return 'Website en sociale media. Maximaal $max.';
  }

  @override
  String get enterLabel => 'Voer een label in.';

  @override
  String get label => 'Label';

  @override
  String get address => 'Adres';

  @override
  String get removeLink => 'Link verwijderen';

  @override
  String get addLink => 'Link toevoegen';

  @override
  String get cancel => 'Annuleren';

  @override
  String get saveChanges => 'Wijzigingen opslaan';

  @override
  String get deleteGroup => 'Groep verwijderen';

  @override
  String get deleteGroupBody =>
      'De groep, lidmaatschappen, rollen, verzoeken en uitnodigingen worden definitief verwijderd. De resterende pakketduur wordt niet terugbetaald.';

  @override
  String deleteGroupNamed(String name) {
    return '$name verwijderen';
  }

  @override
  String changeImage(String label) {
    return '$label wijzigen';
  }

  @override
  String addImage(String label) {
    return '$label toevoegen';
  }

  @override
  String get remove => 'Verwijderen';

  @override
  String get deleteForever => 'Groep definitief verwijderen';

  @override
  String deleteConfirm(String handle) {
    return 'Dit kan niet ongedaan worden gemaakt. Typ ter bevestiging het groepsadres: $handle';
  }

  @override
  String get delete => 'Verwijderen';

  @override
  String get group => 'Groep';

  @override
  String get share => 'Delen';

  @override
  String shareText(String name) {
    return 'Bekijk $name op GWAY:';
  }

  @override
  String get moreOptions => 'Meer opties';

  @override
  String get leaveGroup => 'Groep verlaten';

  @override
  String get groupNotFound =>
      'Deze groep is niet gevonden of niet meer zichtbaar.';

  @override
  String get backToGroups => 'Terug naar groepen';

  @override
  String leaveConfirm(String name) {
    return '$name verlaten? Als je een rol in de groep hebt, wordt die ook verwijderd.';
  }

  @override
  String get leave => 'Verlaten';

  @override
  String leftGroup(String name) {
    return 'Je hebt $name verlaten.';
  }

  @override
  String get suspendedNotice =>
      'Het platformteam heeft deze groep geschorst. Tijdens de schorsing zien alleen leden hem.';

  @override
  String founded(String date) {
    return 'Opgericht in $date';
  }

  @override
  String joinRequestsPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count verzoeken wachten op goedkeuring.',
      one: '1 verzoek wacht op goedkeuring.',
    );
    return '$_temp0';
  }

  @override
  String get review => 'Bekijken';

  @override
  String get requestSent => 'Je verzoek is verstuurd.';

  @override
  String get youAreMember => 'Je bent lid';

  @override
  String get join => 'Lid worden';

  @override
  String joined(String name) {
    return 'Je bent lid geworden van $name.';
  }

  @override
  String get sendJoinRequest => 'Lidmaatschap aanvragen';

  @override
  String get requestSentShort => 'Aangevraagd';

  @override
  String get withdrawRequest => 'Verzoek intrekken';

  @override
  String get withdrawConfirm => 'Je verzoek intrekken?';

  @override
  String get undo => 'Intrekken';

  @override
  String get requestWithdrawn => 'Je verzoek is ingetrokken.';

  @override
  String get decline => 'Weigeren';

  @override
  String get inviteDeclined => 'Uitnodiging geweigerd.';

  @override
  String get acceptInvite => 'Uitnodiging accepteren';

  @override
  String followOn(String name) {
    return 'Berichten van $name verschijnen in je feed.';
  }

  @override
  String get followOff => 'Je volgt de groep niet meer.';

  @override
  String get following => 'Volgend';

  @override
  String get follow => 'Volgen';

  @override
  String get managementTeam => 'Beheerteam';

  @override
  String allMembers(int count) {
    return 'Alle leden ($count)';
  }

  @override
  String get groups => 'Groepen';

  @override
  String get discover => 'Ontdekken';

  @override
  String get myGroups => 'Mijn groepen';

  @override
  String get plans => 'Pakketten';

  @override
  String get searchHint => 'Zoeken op groepsnaam of adres';

  @override
  String get clearSearch => 'Zoekopdracht wissen';

  @override
  String get all => 'Alle';

  @override
  String get noMatch => 'Geen groepen gevonden voor je zoekopdracht.';

  @override
  String get clearFilters => 'Filters wissen';

  @override
  String get noGroupsYet => 'Er zijn nog geen groepen. Start de eerste.';

  @override
  String get showMore => 'Meer tonen';

  @override
  String get notJoinedYet => 'Je bent nog geen lid van een groep.';

  @override
  String get discoverGroups => 'Groepen ontdekken';

  @override
  String get plansHint =>
      'Groepseigenaren kopen pakketten. Start je groep en kies een pakket.';

  @override
  String get yourInvitations => 'Je uitnodigingen';

  @override
  String get invitationsHint => 'Deze groepen hebben je uitgenodigd.';

  @override
  String invitedBy(String name) {
    return 'Uitgenodigd door $name';
  }

  @override
  String get linkCopied => 'Link gekopieerd.';

  @override
  String inviteShareText(String name) {
    return 'Word lid van $name op GWAY:';
  }

  @override
  String get revokeLinkTitle => 'Link intrekken?';

  @override
  String get revokeLinkBody =>
      'Met deze link kan niemand meer lid worden. Wie al lid is, blijft lid.';

  @override
  String get revoke => 'Intrekken';

  @override
  String get inviteLink => 'Uitnodigingslink';

  @override
  String get inviteLinkHint =>
      'Deel hem via WhatsApp of Instagram. Wie de link opent, wordt direct lid, ongeacht het type lidmaatschap.';

  @override
  String get createLink => 'Link maken';

  @override
  String validUntil(String date) {
    return 'Tot $date';
  }

  @override
  String peopleJoined(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensen lid geworden',
      one: '1 persoon lid geworden',
    );
    return '$_temp0';
  }

  @override
  String peopleJoinedOf(int count, int max) {
    return '$count / $max lid geworden';
  }

  @override
  String get newInviteLink => 'Nieuwe uitnodigingslink';

  @override
  String get validity => 'Geldig voor';

  @override
  String days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dagen',
      one: '1 dag',
    );
    return '$_temp0';
  }

  @override
  String get howMany => 'Hoeveel mensen kunnen lid worden?';

  @override
  String get unlimited => 'Onbeperkt';

  @override
  String people(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensen',
      one: '1 persoon',
    );
    return '$_temp0';
  }

  @override
  String get createAndShare => 'Maken en delen';

  @override
  String get invitation => 'Uitnodiging';

  @override
  String get linkInvalid =>
      'Deze uitnodigingslink is niet meer geldig. Vraag de beheerder om een nieuwe.';

  @override
  String get seeGroup => 'Groep bekijken';

  @override
  String get invitedToGroup => 'Je bent uitgenodigd voor deze groep.';

  @override
  String get joinGroup => 'Lid worden';

  @override
  String get members => 'Leden';

  @override
  String get requests => 'Verzoeken';

  @override
  String get invitations => 'Uitnodigingen';

  @override
  String get roles => 'Rollen';

  @override
  String get openCase => 'Tuchtzaak openen';

  @override
  String get report => 'Melden';

  @override
  String membersVisibility(int shown, int total) {
    return 'Alleen leden zien de volledige ledenlijst. Hier: het beheerteam en $shown mensen die hun groepen openbaar tonen; de groep heeft in totaal $total leden.';
  }

  @override
  String optionsFor(String name) {
    return 'Opties voor $name';
  }

  @override
  String get transferOwnership => 'Eigendom overdragen';

  @override
  String transferBody(String group, String person) {
    return 'Het eigendom van $group gaat naar $person. Je blijft gewoon lid en dit kan niet ongedaan worden gemaakt.';
  }

  @override
  String get transfer => 'Overdragen';

  @override
  String transferred(String name) {
    return 'Eigendom overgedragen aan $name.';
  }

  @override
  String get hintAdmin =>
      'Bewerkt de groep en beheert verzoeken en uitnodigingen.';

  @override
  String get hintDiscipline =>
      'Beoordeelt klachtenzaken en beslist over sancties.';

  @override
  String get hintModerator => 'Controleert inhoud en reacties.';

  @override
  String personJoined(String name) {
    return '$name is lid geworden.';
  }

  @override
  String get requestDeclined => 'Verzoek geweigerd.';

  @override
  String get noPendingRequests => 'Geen openstaande verzoeken.';

  @override
  String get refresh => 'Vernieuwen';

  @override
  String get approve => 'Goedkeuren';

  @override
  String get inviteSent => 'Uitnodiging verstuurd.';

  @override
  String get inviteByUsername => 'Uitnodigen via gebruikersnaam';

  @override
  String get invite => 'Uitnodigen';

  @override
  String get noPendingInvites => 'Geen openstaande uitnodigingen.';

  @override
  String memberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count leden',
      one: '1 lid',
    );
    return '$_temp0';
  }

  @override
  String get suspended => 'Geschorst';

  @override
  String get groupsSection => 'Groepen';

  @override
  String get groupsOwnHint =>
      'Alleen leden van dezelfde groep zien je groepen. Je kunt ze openbaar maken in Instellingen.';

  @override
  String get groupsOtherHint =>
      'Alleen gedeelde groepen en groepen die diegene beheert worden getoond.';

  @override
  String get noGroupsToShow => 'Geen groepen om te tonen.';

  @override
  String get handleTaken => 'Dit groepsadres is al bezet. Probeer een ander.';

  @override
  String get groupAddress => 'Groepsadres';

  @override
  String get groupAddressHint =>
      'Het adres van je groepspagina. Dit kan later niet worden gewijzigd.';

  @override
  String get available => 'Beschikbaar';

  @override
  String get taken => 'Bezet';

  @override
  String get notSpecified => 'Niet opgegeven';

  @override
  String get provinceOptional => 'Provincie (optioneel)';

  @override
  String get provinceHint =>
      'De groep verschijnt op de kaart in deze provincie.';

  @override
  String get chooseCategory => 'Kies een categorie.';

  @override
  String get category => 'Categorie';
}
