// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'social_app_l10n.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class SocialAppL10nFr extends SocialAppL10n {
  SocialAppL10nFr([String locale = 'fr']) : super(locale);

  @override
  String get posts => 'Publications';

  @override
  String get newPost => 'Nouvelle publication';

  @override
  String get noOwnPosts =>
      'Tu n\'as encore rien publié. Partage ta première photo ou vidéo.';

  @override
  String get noPosts => 'Aucune publication pour le moment.';

  @override
  String get shareFirstOwn => 'Partage ta première publication';

  @override
  String get groupFirstPost =>
      'Sois le premier ou la première à publier dans le fil du groupe.';

  @override
  String get groupNoPosts =>
      'Il n\'y a pas encore de publication dans ce groupe.';

  @override
  String get shareFirstGroup => 'Publier en premier';

  @override
  String get groupNotFound => 'Groupe introuvable.';

  @override
  String get memoriesEmpty =>
      'Aucun souvenir partagé pour l\'instant. Les participants peuvent ajouter leurs photos ici.';

  @override
  String get plan => 'Formule';

  @override
  String get payment => 'Paiement';

  @override
  String get onlyOwnerBilling =>
      'Seul le propriétaire du groupe peut gérer les formules.';

  @override
  String get backToGroup => 'Retour au groupe';

  @override
  String get writeSupportAboutGroup =>
      'Écrire à l\'équipe de la plateforme à propos de ce groupe';

  @override
  String get search => 'Rechercher';

  @override
  String get notifications => 'Notifications';

  @override
  String get goodNight => 'Bonne nuit';

  @override
  String get goodMorning => 'Bonjour';

  @override
  String get goodAfternoon => 'Bon après-midi';

  @override
  String get goodEvening => 'Bonsoir';

  @override
  String greetingName(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String get tabToday => 'Aujourd\'hui';

  @override
  String get tabGroups => 'Groupes';

  @override
  String get tabCalendar => 'Agenda';

  @override
  String get tabMe => 'Moi';

  @override
  String get tonightSay => 'Libre ? Dis-le et monte une table';

  @override
  String get tonightTableSet => 'Ta table est prête';

  @override
  String get tonightInvited => 'Tu es invité(e) à une table';

  @override
  String tonightFreeWithYou(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnes sont libres comme toi',
      one: '1 personne est libre comme toi',
    );
    return '$_temp0';
  }

  @override
  String get tonightFreeUntil => 'Tu es libre · jusqu\'à 4 h';

  @override
  String tonightFreeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnes sont libres ce soir',
      one: '1 personne est libre ce soir',
    );
    return '$_temp0';
  }

  @override
  String get upcomingNone => 'Les projets de tes groupes';

  @override
  String upcomingMine(int count, int mine) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count projets',
      one: '1 projet',
    );
    return '$_temp0 · $mine participations';
  }

  @override
  String upcomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count projets',
      one: '1 projet',
    );
    return '$_temp0, 60 jours';
  }

  @override
  String get forToday => 'Pour aujourd\'hui';

  @override
  String get tonight => 'Ce soir';

  @override
  String get upcoming => 'À venir';

  @override
  String get share => 'Partager';

  @override
  String get post => 'Publication';

  @override
  String get postHint => 'Jusqu\'à 10 photos ou vidéos';

  @override
  String get story => 'Story';

  @override
  String get storyHint => 'Visible 24 heures';

  @override
  String get group => 'Groupe';

  @override
  String get groupHint => 'Crée ta propre communauté';

  @override
  String get create => 'Créer';

  @override
  String get messages => 'Messages';

  @override
  String get matching => 'Rencontres';

  @override
  String get myGroups => 'Mes groupes';

  @override
  String get pageNotFound =>
      'Page introuvable. Le lien est peut-être ancien ou erroné.';

  @override
  String get backHome => 'Retour à l\'accueil';

  @override
  String get groupsLeague => 'Ligue des groupes';

  @override
  String get exploreOnMap => 'Explorer sur la carte';

  @override
  String get yearMenu =>
      'Bilan de l\'année, ma carte d\'exploration et mes rencontres';

  @override
  String get yearSummary => 'Bilan de l\'année';

  @override
  String get yearSummaryHint =>
      'Tes rencontres de cette année, en carte à partager';

  @override
  String get explorationMap => 'Ma carte d\'exploration';

  @override
  String get explorationMapHint =>
      'Provinces des événements auxquels tu as participé';

  @override
  String get metPeople => 'Mes rencontres';

  @override
  String get metPeopleHint =>
      'Les personnes à qui tu as serré la main lors d’événements';

  @override
  String get findTeammates => 'Trouver des coéquipiers';

  @override
  String get saved => 'Enregistrés';

  @override
  String get gateError =>
      'Impossible de charger tes informations. Vérifie ta connexion et réessaie.';

  @override
  String get searchPeople => 'Rechercher des personnes';

  @override
  String get clearSearch => 'Effacer la recherche';

  @override
  String get settings => 'Paramètres';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get teammatePrefs => 'Préférences de coéquipiers';

  @override
  String get matchProfile => 'Profil de rencontres';

  @override
  String get voiceCalls => 'Appels vocaux';

  @override
  String get blockedAccounts => 'Comptes bloqués';

  @override
  String get storyArchive => 'Archives des stories';

  @override
  String get notificationPrefs => 'Préférences de notification';

  @override
  String get mySanctions => 'Mes sanctions de groupe';

  @override
  String get userGuide => 'Guide d\'utilisation';

  @override
  String get supportFeedback => 'Assistance et commentaires';

  @override
  String newReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nouvelles réponses',
      one: '1 nouvelle réponse',
    );
    return '$_temp0';
  }

  @override
  String get twoFactor => 'Validation en deux étapes';

  @override
  String get legalDocuments => 'Documents juridiques';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get nowPrivate => 'Ton compte est maintenant privé.';

  @override
  String get nowPublic =>
      'Ton compte est maintenant public ; les demandes en attente ont été acceptées.';

  @override
  String get privateAccount => 'Compte privé';

  @override
  String get privateAccountHint =>
      'Activé, seuls les abonnés que tu acceptes voient tes publications et stories.';

  @override
  String get groupsNowPublic =>
      'Tes groupes sont maintenant visibles par tous sur ton profil.';

  @override
  String get groupsNowMembers =>
      'Tes groupes ne sont plus visibles que par les membres du même groupe.';

  @override
  String get showGroups => 'Afficher mes groupes sur mon profil';

  @override
  String get showGroupsHint =>
      'Désactivé, seuls les membres d\'un groupe voient que tu en fais partie ; les admins d\'autres groupes ne le voient pas.';

  @override
  String get language => 'Langue';

  @override
  String get games => 'Jeux';

  @override
  String get chessHint =>
      'Parties rapides, défis entre amis, grimpe au classement Elo.';

  @override
  String get gamesHint =>
      'Échecs : parties rapides, tournois, matchs par équipes';
}
