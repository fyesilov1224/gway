// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'profile_l10n.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class ProfileL10nFr extends ProfileL10n {
  ProfileL10nFr([String locale = 'fr']) : super(locale);

  @override
  String get unsupportedImage =>
      'Ce type de fichier n\'est pas pris en charge. Choisis JPEG, PNG ou WebP.';

  @override
  String get usernameTaken =>
      'Ce nom d\'utilisateur est déjà pris. Essaie-en un autre.';

  @override
  String get checkInput => 'Vérifie les informations saisies.';

  @override
  String get usernameReserved =>
      'Ce nom d\'utilisateur ne peut pas être utilisé. Essaie-en un autre.';

  @override
  String get usernameCooldown =>
      'Tu ne peux changer ton nom d\'utilisateur qu\'une fois tous les 30 jours.';

  @override
  String get maxInterests10 =>
      'Tu peux choisir jusqu\'à 10 centres d\'intérêt.';

  @override
  String get levelBeginner => 'Débutant';

  @override
  String get levelBeginnerHint => 'Je débute';

  @override
  String get levelIntermediate => 'Intermédiaire';

  @override
  String get levelIntermediateHint => 'Je pratique régulièrement';

  @override
  String get levelAdvanced => 'Avancé';

  @override
  String get levelAdvancedHint => 'J\'ai de l\'expérience';

  @override
  String get slotWeekdayMorning => 'En semaine le matin';

  @override
  String get slotWeekdayNoon => 'En semaine le midi';

  @override
  String get slotWeekdayEvening => 'En semaine le soir';

  @override
  String get slotWeekendMorning => 'Le week-end le matin';

  @override
  String get slotWeekendAfternoon => 'Le week-end l\'après-midi';

  @override
  String get slotWeekendEvening => 'Le week-end le soir';

  @override
  String get partMorning => 'Matin';

  @override
  String get partNoon => 'Midi';

  @override
  String get partEvening => 'Soir';

  @override
  String get goalFun => 'S\'amuser';

  @override
  String get goalFitness => 'Rester en forme';

  @override
  String get goalCompetition => 'Me préparer à une compétition';

  @override
  String get goalLearning => 'Apprendre de nouvelles choses';

  @override
  String get goalMentoring => 'Partager mon expérience';

  @override
  String get goalSocial => 'Rencontrer de nouvelles personnes';

  @override
  String get freqMonthly => 'Quelques fois par mois';

  @override
  String get freqWeekly => 'Une fois par semaine';

  @override
  String get freqFewWeekly => '2 à 3 fois par semaine';

  @override
  String get freqDaily => 'Presque tous les jours';

  @override
  String get sizePair => 'En tête-à-tête';

  @override
  String get sizeSmall => 'Petit groupe (3–6)';

  @override
  String get sizeLarge => 'Grand groupe';

  @override
  String get looking => 'Cherche une équipe';

  @override
  String lookingWithLevel(String level) {
    return 'Cherche une équipe · $level';
  }

  @override
  String reasonActivities(String list) {
    return 'Même activité : $list';
  }

  @override
  String reasonInterests(String list) {
    return 'Centres d\'intérêt communs : $list';
  }

  @override
  String get reasonProvince => 'Vous êtes dans la même province';

  @override
  String reasonGroup(String group) {
    return 'Groupe commun : $group';
  }

  @override
  String reasonGroups(int count) {
    return '$count groupes communs';
  }

  @override
  String reasonLevel(String level) {
    return 'Même niveau : $level';
  }

  @override
  String reasonTimes(String list) {
    return 'Disponibles : $list';
  }

  @override
  String reasonGoals(String list) {
    return 'Objectifs communs : $list';
  }

  @override
  String get reasonFrequency => 'Vous voulez vous voir aussi souvent';

  @override
  String get hasVehicle => 'A un véhicule';

  @override
  String get hasEquipment => 'A son propre équipement';

  @override
  String get usernameRequired => 'Choisis un nom d\'utilisateur.';

  @override
  String usernameMin(int min) {
    return 'Le nom d\'utilisateur doit contenir au moins $min caractères.';
  }

  @override
  String usernameMax(int max) {
    return 'Le nom d\'utilisateur peut contenir au maximum $max caractères.';
  }

  @override
  String get usernameChars =>
      'Utilise uniquement a–z, 0–9, le tiret bas (_) et le point (.).';

  @override
  String get usernameDots =>
      'Le nom d\'utilisateur ne peut pas commencer ou finir par un point.';

  @override
  String get usernameDoubleDot =>
      'Deux points d\'affilée ne sont pas autorisés.';

  @override
  String get nameRequired => 'Saisis ton nom.';

  @override
  String nameMax(int max) {
    return 'Le nom peut contenir au maximum $max caractères.';
  }

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get save => 'Enregistrer';

  @override
  String get profileInfo => 'Informations du profil';

  @override
  String get profileInfoHint =>
      'Ces informations sont visibles par tous sur ton profil.';

  @override
  String get yourName => 'Ton nom';

  @override
  String get usernameEvery30 =>
      'Tu peux changer ton nom d\'utilisateur une fois tous les 30 jours.';

  @override
  String usernameLockedUntil(String date) {
    return 'Tu pourras le changer après le $date.';
  }

  @override
  String get about => 'À propos';

  @override
  String get aboutHint => 'Parle de toi et des activités que tu aimes.';

  @override
  String get interests => 'Centres d\'intérêt';

  @override
  String interestsMax(int max) {
    return 'Tu peux en choisir jusqu\'à $max.';
  }

  @override
  String get cancel => 'Annuler';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get remove => 'Supprimer';

  @override
  String get removeCover => 'Supprimer la photo de couverture';

  @override
  String get addCover => 'Ajouter une couverture';

  @override
  String get changeCover => 'Changer la couverture';

  @override
  String get changeAvatar => 'Changer la photo de profil';

  @override
  String get photos => 'Photo de profil et de couverture';

  @override
  String get photosHint => 'JPEG, PNG ou WebP · jusqu\'à 5 Mo';

  @override
  String get addAvatar => 'Ajouter une photo de profil';

  @override
  String get removeAvatar => 'Supprimer la photo de profil';

  @override
  String get followers => 'Abonnés';

  @override
  String get following => 'Abonnements';

  @override
  String get privateLists =>
      'Ce compte est privé. Abonne-toi pour voir ses listes.';

  @override
  String get backToProfile => 'Retour au profil';

  @override
  String get noFollowers => 'Pas encore d\'abonnés.';

  @override
  String get noFollowing => 'Aucun abonnement pour l\'instant.';

  @override
  String get refresh => 'Actualiser';

  @override
  String get removeFollower => 'Retirer l\'abonné';

  @override
  String removeFollowerBody(String username) {
    return 'Retirer @$username de tes abonnés ? La personne ne sera pas prévenue.';
  }

  @override
  String get removeAction => 'Retirer';

  @override
  String get friends => 'Vous êtes amis';

  @override
  String get followRequests => 'Demandes d\'abonnement';

  @override
  String get noFollowRequests =>
      'Aucune demande d\'abonnement en attente. Les comptes privés valident les demandes ici.';

  @override
  String get approve => 'Accepter';

  @override
  String get delete => 'Supprimer';

  @override
  String get blockedAccounts => 'Comptes bloqués';

  @override
  String get noBlocked =>
      'Tu n\'as bloqué personne. Tu peux bloquer depuis le menu d\'un profil.';

  @override
  String get unblock => 'Débloquer';

  @override
  String get onboardWho => 'Faisons connaissance';

  @override
  String get onboardWhoHint =>
      'Choisis le nom et le nom d\'utilisateur affichés sur ton profil.';

  @override
  String get onboardPhoto => 'Photo de profil';

  @override
  String get onboardPhotoHint =>
      'Pour que tes groupes te reconnaissent. Tu peux aussi en ajouter une plus tard.';

  @override
  String get onboardInterests => 'Tes centres d\'intérêt';

  @override
  String onboardInterestsHint(int max) {
    return 'Choisis-en jusqu\'à $max pour que nous te suggérions des groupes adaptés.';
  }

  @override
  String get back => 'Retour';

  @override
  String stepOf(int step, int total) {
    return 'Étape $step sur $total';
  }

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get skipForNow => 'Passer pour l\'instant';

  @override
  String get continueAction => 'Continuer';

  @override
  String get finish => 'Terminer';

  @override
  String get usernameHelper => 'Utilise des minuscules, des chiffres, _ et .';

  @override
  String get avatarPreview => 'Aperçu de la photo de profil';

  @override
  String get choosePhoto => 'Choisir une photo';

  @override
  String get chooseAnotherPhoto => 'Choisir une autre photo';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Paramètres';

  @override
  String get profileNotFound =>
      'Ce profil est introuvable ou n\'est plus visible.';

  @override
  String get backToMyProfile => 'Retour à mon profil';

  @override
  String suspendedUntil(String date) {
    return 'Ce compte est suspendu jusqu\'au $date.';
  }

  @override
  String get followsYou => 'T\'a suivi(e)';

  @override
  String get yourTeammate => 'Ton coéquipier';

  @override
  String joined(String date) {
    return 'Inscrit(e) en $date';
  }

  @override
  String followRequestsPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count demandes d\'abonnement attendent ta validation.',
      one: '1 demande d\'abonnement attend ta validation.',
    );
    return '$_temp0';
  }

  @override
  String get review => 'Voir';

  @override
  String teammateRequestsPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count demandes de coéquipier t\'attendent.',
      one: '1 demande de coéquipier t\'attend.',
    );
    return '$_temp0';
  }

  @override
  String get youBlocked => 'Tu as bloqué ce compte';

  @override
  String get youBlockedHint =>
      'Si tu débloques, vous verrez à nouveau vos publications respectives.';

  @override
  String get privateAccount => 'Ce compte est privé';

  @override
  String get privateAccountHint =>
      'Abonne-toi à ce compte pour voir ses photos, vidéos et stories.';

  @override
  String get addInterestsNudge =>
      'Ajoute tes centres d\'intérêt et nous te trouverons des groupes et des coéquipiers.';

  @override
  String get add => 'Ajouter';

  @override
  String blockTitle(String username) {
    return 'Bloquer @$username ?';
  }

  @override
  String get blockBody =>
      'La personne ne verra plus ton profil, tes publications ni tes stories, ne pourra pas te trouver ni t\'écrire. Vous ne vous suivrez plus. Elle ne sera pas prévenue.';

  @override
  String get block => 'Bloquer';

  @override
  String get becomeTeammates => 'Devenir coéquipiers';

  @override
  String nowTeammates(String name) {
    return '$name et toi êtes maintenant coéquipiers.';
  }

  @override
  String get acceptTeammate => 'Accepter la demande de coéquipier';

  @override
  String get requestWithdrawn => 'Demande retirée.';

  @override
  String get withdrawTeammate => 'Retirer la demande de coéquipier';

  @override
  String get teammateEnded => 'Fin de la relation de coéquipiers.';

  @override
  String get endTeammate => 'Mettre fin à la relation de coéquipiers';

  @override
  String get moreOptions => 'Plus d\'options';

  @override
  String get linkCopied => 'Lien du profil copié.';

  @override
  String get copyLink => 'Copier le lien du profil';

  @override
  String get removedFromFollowers => 'Retiré(e) de tes abonnés.';

  @override
  String get removeFromFollowers => 'Retirer de mes abonnés';

  @override
  String get report => 'Signaler';

  @override
  String get unblocked => 'Débloqué(e).';

  @override
  String get statPosts => 'Publications';

  @override
  String get statFollowers => 'Abonnés';

  @override
  String get statFollowing => 'Abonnements';

  @override
  String withdrawFollowBody(String username) {
    return 'Retirer ta demande d\'abonnement à @$username ?';
  }

  @override
  String unfollowBody(String username) {
    return 'Ne plus suivre @$username ?';
  }

  @override
  String unfollowPrivateBody(String username) {
    return 'Ne plus suivre @$username ? Le compte est privé : tu devras renvoyer une demande pour voir ses publications.';
  }

  @override
  String get withdrawRequest => 'Retirer la demande';

  @override
  String get unfollow => 'Ne plus suivre';

  @override
  String get followBack => 'S\'abonner en retour';

  @override
  String get follow => 'S\'abonner';

  @override
  String get requestSent => 'Demande envoyée';

  @override
  String get followingState => 'Abonné(e)';

  @override
  String noAccountMatch(String query) {
    return 'Aucun compte ne correspond à « $query ».';
  }

  @override
  String get clearSearch => 'Effacer la recherche';

  @override
  String get searchHint =>
      'Commence à écrire pour chercher des personnes ou des tags.';

  @override
  String get refreshSuggestions => 'Actualiser les suggestions';

  @override
  String get suggestionsForYou => 'Suggestions pour toi';

  @override
  String mutualFollows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Suivi par $count personnes que tu suis',
      one: 'Suivi par 1 personne que tu suis',
    );
    return '$_temp0';
  }

  @override
  String get popularAccount => 'Compte populaire';

  @override
  String get seePackage => 'Voir la formule';

  @override
  String requestSentNotify(String name) {
    return 'Demande envoyée. Nous te préviendrons quand $name acceptera.';
  }

  @override
  String becomeTeammatesWith(String name) {
    return 'Devenir coéquipier de $name';
  }

  @override
  String get shortMessage => 'Un petit message (facultatif)';

  @override
  String get shortMessageHint => 'Samedi matin au parc ?';

  @override
  String get sendRequest => 'Envoyer la demande';

  @override
  String get findTeammates => 'Trouver des coéquipiers';

  @override
  String get myTeammatePrefs => 'Mes préférences de coéquipiers';

  @override
  String get tabSuggestions => 'Suggestions';

  @override
  String get tabRequests => 'Demandes';

  @override
  String tabRequestsCount(int count) {
    return 'Demandes ($count)';
  }

  @override
  String get tabMyTeam => 'Mon équipe';

  @override
  String get findYourTeammate => 'Trouve ton coéquipier';

  @override
  String waitingForYou(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnes veulent être tes coéquipiers',
      one: '1 personne veut être ton coéquipier',
    );
    return '$_temp0';
  }

  @override
  String get teammatesLocked =>
      'Voir les suggestions, envoyer et accepter des demandes et écrire à tes coéquipiers : c\'est inclus dans la formule Coéquipier.';

  @override
  String get beVisible => 'Sois visible toi aussi';

  @override
  String get beVisibleBody =>
      'Active « Je cherche une équipe » pour que ceux qui aiment les mêmes choses puissent t\'envoyer des demandes.';

  @override
  String get setPrefs => 'Régler mes préférences';

  @override
  String get nowPublicSuggest =>
      'Ton compte est maintenant public ; tu peux apparaître dans les suggestions.';

  @override
  String get privateHidden =>
      'Ton compte est privé, tu n\'apparais pas dans les suggestions';

  @override
  String get privateHiddenBody =>
      'Les comptes privés n\'apparaissent pas dans les suggestions de coéquipiers. Si tu rends ton compte public, les demandes d\'abonnement en attente sont aussi acceptées.';

  @override
  String get makePublic => 'Rendre mon compte public';

  @override
  String get noSuggestions =>
      'Personne ne correspond pour l\'instant. Remplis tes centres d\'intérêt et tes préférences pour avoir plus de suggestions.';

  @override
  String quoted(String text) {
    return '« $text »';
  }

  @override
  String get whySuggested => 'Pourquoi cette suggestion';

  @override
  String get noPendingTeammate => 'Aucune demande de coéquipier en attente.';

  @override
  String get seeSuggestions => 'Voir les suggestions';

  @override
  String get incoming => 'Reçues';

  @override
  String get accept => 'Accepter';

  @override
  String get decline => 'Refuser';

  @override
  String get requestDeclined => 'Demande refusée.';

  @override
  String get outgoing => 'Envoyées';

  @override
  String get awaitingReply => 'En attente de réponse';

  @override
  String get withdraw => 'Retirer';

  @override
  String get noTeammates =>
      'Tu n\'as pas encore de coéquipiers. Commence par envoyer une demande à une suggestion.';

  @override
  String optionsFor(String name) {
    return 'Options pour $name';
  }

  @override
  String get teammatePrefs => 'Préférences de coéquipiers';

  @override
  String get prefsSavedVisible =>
      'Préférences enregistrées. Tu apparais désormais dans les suggestions.';

  @override
  String get prefsSaved => 'Préférences enregistrées.';

  @override
  String get whatToDo => 'Que veux-tu faire ?';

  @override
  String activitiesHint(int max) {
    return 'Les activités pour lesquelles tu cherches des coéquipiers. Jusqu\'à $max.';
  }

  @override
  String get yourLevel => 'Ton niveau';

  @override
  String get yourGoals => 'Tes objectifs';

  @override
  String get multipleChoice => 'Tu peux en choisir plusieurs.';

  @override
  String get howOften => 'À quelle fréquence veux-tu te retrouver ?';

  @override
  String get whenFree => 'Quand es-tu disponible ?';

  @override
  String get whenFreeHint => 'Touche les moments où tu es disponible.';

  @override
  String get whatTeam => 'Quel type d’équipe veux-tu ?';

  @override
  String get whichProvince => 'Dans quelle province es-tu ?';

  @override
  String get provinceHint =>
      'Utilisée uniquement pour les suggestions, elle n\'apparaît pas sur ton profil.';

  @override
  String get province => 'Province';

  @override
  String get ratherNotSay => 'Je préfère ne pas le dire';

  @override
  String get extras => 'Informations supplémentaires';

  @override
  String get iHaveVehicle => 'J\'ai un véhicule';

  @override
  String get iHaveVehicleHint => 'Je peux faire du covoiturage.';

  @override
  String get iHaveEquipment => 'J\'ai mon propre équipement';

  @override
  String get iHaveEquipmentHint =>
      'Mon vélo, ma tente, ma raquette ou autre matériel est prêt.';

  @override
  String get describeYourself => 'Présente-toi';

  @override
  String get describeHint => 'Affiché sous ton nom dans les suggestions.';

  @override
  String get describeExample =>
      'Je cherche quelqu’un pour marcher le week-end matin.';

  @override
  String get willAppear => 'Tu apparaîtras dans les suggestions.';

  @override
  String get notAppearing =>
      'Tu n\'apparais pas dans les suggestions pour l\'instant.';

  @override
  String get lookingForTeam => 'Je cherche une équipe';

  @override
  String get lookingOn =>
      'Tu apparais dans les suggestions ; on peut t’envoyer des demandes de coéquipier.';

  @override
  String get lookingOff =>
      'Active-le pour que ceux qui aiment les mêmes choses te trouvent. Les comptes privés n\'apparaissent pas dans les suggestions.';

  @override
  String prefsComplete(int percent) {
    return 'Préférences remplies à $percent %';
  }

  @override
  String get prefsCompleteHint =>
      'Plus tu remplis, plus les suggestions sont justes.';

  @override
  String get weekday => 'En semaine';

  @override
  String get weekend => 'Week-end';

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get available => 'Disponible';

  @override
  String get taken => 'Déjà pris';
}
