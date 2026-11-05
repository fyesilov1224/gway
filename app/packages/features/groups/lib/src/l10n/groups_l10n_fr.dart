// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'groups_l10n.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class GroupsL10nFr extends GroupsL10n {
  GroupsL10nFr([String locale = 'fr']) : super(locale);

  @override
  String get unsupportedImage =>
      'Ce type de fichier n\'est pas pris en charge. Choisis JPEG, PNG ou WebP.';

  @override
  String get joinOpen => 'Adhésion libre';

  @override
  String get joinOpenHint => 'Tout le monde peut rejoindre directement.';

  @override
  String get joinRequest => 'Adhésion sur demande';

  @override
  String get joinRequestHint => 'Les admins valident les demandes.';

  @override
  String get joinInvite => 'Sur invitation';

  @override
  String get joinInviteHint =>
      'Seules les personnes invitées peuvent rejoindre.';

  @override
  String get roleOwner => 'Propriétaire du groupe';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleDiscipline => 'Comité de discipline';

  @override
  String get roleModerator => 'Modérateur';

  @override
  String get roleMember => 'Membre';

  @override
  String get handleMin =>
      'L\'adresse du groupe doit contenir au moins 3 caractères.';

  @override
  String get handleChars =>
      'Utilise uniquement des minuscules, des chiffres, des tirets bas et des points.';

  @override
  String get handleDots =>
      'Ne peut pas commencer ni finir par un point, ni en contenir deux à la suite.';

  @override
  String get nameMin => 'Le nom du groupe doit contenir au moins 3 caractères.';

  @override
  String nameMax(int max) {
    return 'Le nom du groupe peut contenir au maximum $max caractères.';
  }

  @override
  String get httpsOnly => 'Saisis une adresse qui commence par https://.';

  @override
  String get createGroup => 'Créer un groupe';

  @override
  String get groupInfo => 'Informations du groupe';

  @override
  String get groupInfoHint =>
      'Tu pourras ajouter logo, couverture, règles et liens après avoir créé le groupe.';

  @override
  String get groupName => 'Nom du groupe';

  @override
  String get about => 'Présentation';

  @override
  String get aboutHint => 'Que fait votre groupe et qui peut le rejoindre ?';

  @override
  String get joining => 'Adhésion';

  @override
  String get changeLater => 'Tu pourras le modifier plus tard.';

  @override
  String get createTheGroup => 'Créer le groupe';

  @override
  String get editGroup => 'Modifier le groupe';

  @override
  String get noEditPermission => 'Tu n\'as pas le droit de modifier ce groupe.';

  @override
  String get backToGroup => 'Retour au groupe';

  @override
  String get save => 'Enregistrer';

  @override
  String get logoAndCover => 'Logo et couverture';

  @override
  String get imageHint => 'JPEG, PNG ou WebP · jusqu\'à 5 Mo';

  @override
  String get logo => 'Logo';

  @override
  String get cover => 'Couverture';

  @override
  String groupHandle(String handle) {
    return 'Adresse du groupe : $handle';
  }

  @override
  String get rules => 'Règles';

  @override
  String get rulesHint => 'Ce que tu attends des membres, une règle par ligne.';

  @override
  String get links => 'Liens';

  @override
  String linksHint(int max) {
    return 'Site web et réseaux sociaux. Jusqu\'à $max.';
  }

  @override
  String get enterLabel => 'Saisis un libellé.';

  @override
  String get label => 'Libellé';

  @override
  String get address => 'Adresse';

  @override
  String get removeLink => 'Supprimer le lien';

  @override
  String get addLink => 'Ajouter un lien';

  @override
  String get cancel => 'Annuler';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get deleteGroup => 'Supprimer le groupe';

  @override
  String get deleteGroupBody =>
      'Le groupe, les adhésions, rôles, demandes et invitations sont supprimés définitivement. La durée restante de la formule n’est pas remboursée.';

  @override
  String deleteGroupNamed(String name) {
    return 'Supprimer $name';
  }

  @override
  String changeImage(String label) {
    return 'Changer : $label';
  }

  @override
  String addImage(String label) {
    return 'Ajouter : $label';
  }

  @override
  String get remove => 'Supprimer';

  @override
  String get deleteForever => 'Supprimer définitivement le groupe';

  @override
  String deleteConfirm(String handle) {
    return 'Cette action est irréversible. Pour confirmer, saisis l\'adresse du groupe : $handle';
  }

  @override
  String get delete => 'Supprimer';

  @override
  String get group => 'Groupe';

  @override
  String get share => 'Partager';

  @override
  String shareText(String name) {
    return 'Découvre $name sur GWAY :';
  }

  @override
  String get moreOptions => 'Plus d\'options';

  @override
  String get leaveGroup => 'Quitter le groupe';

  @override
  String get groupNotFound =>
      'Ce groupe est introuvable ou n\'est plus visible.';

  @override
  String get backToGroups => 'Retour aux groupes';

  @override
  String leaveConfirm(String name) {
    return 'Quitter $name ? Si tu as un rôle dans le groupe, il sera aussi retiré.';
  }

  @override
  String get leave => 'Quitter';

  @override
  String leftGroup(String name) {
    return 'Tu as quitté $name.';
  }

  @override
  String get suspendedNotice =>
      'L\'équipe de la plateforme a suspendu ce groupe. Pendant la suspension, seuls les membres le voient.';

  @override
  String founded(String date) {
    return 'Créé en $date';
  }

  @override
  String joinRequestsPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count demandes d\'adhésion attendent une validation.',
      one: '1 demande d\'adhésion attend une validation.',
    );
    return '$_temp0';
  }

  @override
  String get review => 'Voir';

  @override
  String get requestSent => 'Ta demande d\'adhésion a été envoyée.';

  @override
  String get youAreMember => 'Tu es membre';

  @override
  String get join => 'Rejoindre';

  @override
  String joined(String name) {
    return 'Tu as rejoint $name.';
  }

  @override
  String get sendJoinRequest => 'Demander à rejoindre';

  @override
  String get requestSentShort => 'Demande envoyée';

  @override
  String get withdrawRequest => 'Retirer la demande';

  @override
  String get withdrawConfirm => 'Retirer ta demande d\'adhésion ?';

  @override
  String get undo => 'Retirer';

  @override
  String get requestWithdrawn => 'Ta demande d\'adhésion a été retirée.';

  @override
  String get decline => 'Refuser';

  @override
  String get inviteDeclined => 'Invitation refusée.';

  @override
  String get acceptInvite => 'Accepter l\'invitation';

  @override
  String followOn(String name) {
    return 'Les publications de $name apparaîtront dans ton fil.';
  }

  @override
  String get followOff => 'Tu ne suis plus le groupe.';

  @override
  String get following => 'Abonné(e)';

  @override
  String get follow => 'S\'abonner';

  @override
  String get managementTeam => 'Équipe d\'administration';

  @override
  String allMembers(int count) {
    return 'Tous les membres ($count)';
  }

  @override
  String get groups => 'Groupes';

  @override
  String get discover => 'Découvrir';

  @override
  String get myGroups => 'Mes groupes';

  @override
  String get plans => 'Formules';

  @override
  String get searchHint => 'Rechercher par nom ou adresse du groupe';

  @override
  String get clearSearch => 'Effacer la recherche';

  @override
  String get all => 'Tous';

  @override
  String get noMatch => 'Aucun groupe ne correspond à ta recherche.';

  @override
  String get clearFilters => 'Effacer les filtres';

  @override
  String get noGroupsYet => 'Il n\'y a pas encore de groupe. Crée le premier.';

  @override
  String get showMore => 'Afficher plus';

  @override
  String get notJoinedYet => 'Tu n\'as encore rejoint aucun groupe.';

  @override
  String get discoverGroups => 'Découvrir des groupes';

  @override
  String get plansHint =>
      'Les formules sont achetées par les propriétaires. Crée ton groupe et choisis une formule.';

  @override
  String get yourInvitations => 'Tes invitations';

  @override
  String get invitationsHint => 'Ces groupes t\'ont invité(e) à les rejoindre.';

  @override
  String invitedBy(String name) {
    return 'Invitation de $name';
  }

  @override
  String get linkCopied => 'Lien copié.';

  @override
  String inviteShareText(String name) {
    return 'Rejoins $name sur GWAY :';
  }

  @override
  String get revokeLinkTitle => 'Révoquer le lien ?';

  @override
  String get revokeLinkBody =>
      'Plus personne ne pourra rejoindre avec ce lien. Ceux qui l\'ont déjà fait restent membres.';

  @override
  String get revoke => 'Révoquer';

  @override
  String get inviteLink => 'Lien d\'invitation';

  @override
  String get inviteLinkHint =>
      'Partage-le sur WhatsApp ou Instagram. Toute personne qui ouvre le lien devient membre directement, quel que soit le type d\'adhésion.';

  @override
  String get createLink => 'Créer un lien';

  @override
  String validUntil(String date) {
    return 'Jusqu\'au $date';
  }

  @override
  String peopleJoined(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnes ont rejoint',
      one: '1 personne a rejoint',
    );
    return '$_temp0';
  }

  @override
  String peopleJoinedOf(int count, int max) {
    return '$count / $max inscrits';
  }

  @override
  String get newInviteLink => 'Nouveau lien d\'invitation';

  @override
  String get validity => 'Validité';

  @override
  String days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours',
      one: '1 jour',
    );
    return '$_temp0';
  }

  @override
  String get howMany => 'Combien de personnes peuvent rejoindre ?';

  @override
  String get unlimited => 'Illimité';

  @override
  String people(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnes',
      one: '1 personne',
    );
    return '$_temp0';
  }

  @override
  String get createAndShare => 'Créer et partager';

  @override
  String get invitation => 'Invitation';

  @override
  String get linkInvalid =>
      'Ce lien d\'invitation n\'est plus valide. Tu peux en demander un nouveau à l\'admin du groupe.';

  @override
  String get seeGroup => 'Voir le groupe';

  @override
  String get invitedToGroup => 'Tu as été invité(e) dans ce groupe.';

  @override
  String get joinGroup => 'Rejoindre le groupe';

  @override
  String get members => 'Membres';

  @override
  String get requests => 'Demandes';

  @override
  String get invitations => 'Invitations';

  @override
  String get roles => 'Rôles';

  @override
  String get openCase => 'Ouvrir un dossier disciplinaire';

  @override
  String get report => 'Signaler';

  @override
  String membersVisibility(int shown, int total) {
    return 'Seuls les membres voient la liste complète. Ici : l\'équipe d\'administration et $shown personnes qui affichent leurs groupes ; le groupe compte $total membres au total.';
  }

  @override
  String optionsFor(String name) {
    return 'Options pour $name';
  }

  @override
  String get transferOwnership => 'Transférer la propriété';

  @override
  String transferBody(String group, String person) {
    return 'La propriété de $group passera à $person. Tu resteras simple membre et cette action est irréversible.';
  }

  @override
  String get transfer => 'Transférer';

  @override
  String transferred(String name) {
    return 'Propriété transférée à $name.';
  }

  @override
  String get hintAdmin =>
      'Modifie le groupe et gère les demandes d\'adhésion et les invitations.';

  @override
  String get hintDiscipline =>
      'Examine les dossiers de plainte et décide des sanctions.';

  @override
  String get hintModerator => 'Contrôle les contenus et les commentaires.';

  @override
  String personJoined(String name) {
    return '$name a rejoint le groupe.';
  }

  @override
  String get requestDeclined => 'Demande refusée.';

  @override
  String get noPendingRequests => 'Aucune demande d\'adhésion en attente.';

  @override
  String get refresh => 'Actualiser';

  @override
  String get approve => 'Accepter';

  @override
  String get inviteSent => 'Invitation envoyée.';

  @override
  String get inviteByUsername => 'Inviter par nom d\'utilisateur';

  @override
  String get invite => 'Inviter';

  @override
  String get noPendingInvites => 'Aucune invitation en attente.';

  @override
  String memberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membres',
      one: '1 membre',
    );
    return '$_temp0';
  }

  @override
  String get suspended => 'Suspendu';

  @override
  String get groupsSection => 'Groupes';

  @override
  String get groupsOwnHint =>
      'Seuls les membres du même groupe voient tes groupes. Tu peux les rendre publics dans les paramètres.';

  @override
  String get groupsOtherHint =>
      'Seuls vos groupes communs et ceux qu\'elle administre sont affichés.';

  @override
  String get noGroupsToShow => 'Aucun groupe à afficher.';

  @override
  String get handleTaken =>
      'Cette adresse de groupe est déjà prise. Essaie-en une autre.';

  @override
  String get groupAddress => 'Adresse du groupe';

  @override
  String get groupAddressHint =>
      'L\'adresse de la page du groupe. Elle ne pourra pas être modifiée.';

  @override
  String get available => 'Disponible';

  @override
  String get taken => 'Déjà pris';

  @override
  String get notSpecified => 'Non précisé';

  @override
  String get provinceOptional => 'Province (facultatif)';

  @override
  String get provinceHint =>
      'Le groupe apparaît dans cette province sur la carte.';

  @override
  String get chooseCategory => 'Choisis une catégorie.';

  @override
  String get category => 'Catégorie';
}
