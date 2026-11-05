// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'matching_l10n.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class MatchingL10nFr extends MatchingL10n {
  MatchingL10nFr([String locale = 'fr']) : super(locale);

  @override
  String get unsupportedImage =>
      'Seules les photos JPEG, PNG ou WebP peuvent être envoyées.';

  @override
  String get modeFriend => 'Amitié';

  @override
  String get modeDating => 'Rencontres';

  @override
  String get genderWoman => 'Femme';

  @override
  String get genderMan => 'Homme';

  @override
  String get genderNonbinary => 'Non binaire';

  @override
  String get adultsOnly => 'Les rencontres sont réservées aux plus de 18 ans.';

  @override
  String get pickMode => 'Choisis au moins un mode : Amitié ou Rencontres.';

  @override
  String get pickInterest => 'Choisis qui tu recherches pour les Rencontres.';

  @override
  String get ageRangeInvalid => 'La tranche d\'âge n\'est pas valide.';

  @override
  String sharedGroup(String group) {
    return 'Groupe en commun : $group';
  }

  @override
  String sharedGroupsMore(String group, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'En commun : $group et $count autres groupes',
      one: 'En commun : $group et 1 autre groupe',
    );
    return '$_temp0';
  }

  @override
  String get pkgReveal => 'Mes matchs';

  @override
  String get pkgRevealText =>
      'Vois avec qui tu as matché : nom, photos et profil.';

  @override
  String get pkgChat => 'Discussion de match';

  @override
  String get pkgChatText => 'Écris à tes matchs. Inclut la vue de tes matchs.';

  @override
  String get pkgAdmirers => 'Qui te like';

  @override
  String get pkgAdmirersText =>
      'Vois qui t’a liké et matche aussitôt en likant en retour.';

  @override
  String get pkgUnlimited => 'Likes illimités';

  @override
  String get pkgUnlimitedText =>
      'Plus de limite quotidienne ; annuler et filtres inclus.';

  @override
  String get pkgSuper => 'Super Like';

  @override
  String get pkgSuperText =>
      '5 Super Likes par jour ; la personne te voit en premier dans sa pile.';

  @override
  String get pkgBoost => 'Boost';

  @override
  String get pkgBoostText =>
      'Une fois par jour, apparais en tête des piles de tes groupes en commun pendant 30 minutes.';

  @override
  String get pkgTeammates => 'Coéquipier';

  @override
  String get pkgTeammatesText =>
      'Envoie des demandes de coéquipier et discute avec tes coéquipiers.';

  @override
  String get pkgAll => 'Tout-en-un';

  @override
  String get pkgAllText =>
      'Toutes les formules en une, bien moins cher que séparément.';

  @override
  String get superLikedYou => 'T\'a envoyé un Super Like';

  @override
  String get options => 'Options';

  @override
  String get fullProfile => 'Profil complet';

  @override
  String get stampLike => 'LIKE';

  @override
  String get stampPass => 'NON';

  @override
  String get stampSuper => 'SUPER';

  @override
  String photoOf(String name, int number) {
    return '$name, photo $number';
  }

  @override
  String get about => 'À propos';

  @override
  String get interests => 'Centres d\'intérêt';

  @override
  String get sharedGroupsTitle => 'Groupes en commun';

  @override
  String get createProfileTitle => 'Créer un profil de rencontre';

  @override
  String get myProfile => 'Mon profil de rencontre';

  @override
  String get birthDateLabel => 'Ta date de naissance';

  @override
  String get pickBasics =>
      'Choisis ta date de naissance, ton genre et ta province.';

  @override
  String get confirmAgeConsent =>
      'Pour continuer, confirme que tu as plus de 18 ans et donne ton consentement explicite.';

  @override
  String profileReady(int min) {
    return 'Ton profil est prêt. Ajoute maintenant au moins $min photos.';
  }

  @override
  String get saved => 'Enregistré.';

  @override
  String get pickBirthDate => 'Choisir la date de naissance';

  @override
  String ageNote(int age) {
    return '$age ans · ta carte n’affiche que ton âge';
  }

  @override
  String get gender => 'Genre';

  @override
  String get province => 'Province';

  @override
  String get aboutHint => 'Parle de toi';

  @override
  String get jobOptional => 'Métier (facultatif)';

  @override
  String get educationOptional => 'Études (facultatif)';

  @override
  String get interestsFromProfile =>
      'Tes centres d\'intérêt viennent de ton profil social.';

  @override
  String get lookingFor => 'Que recherches-tu ?';

  @override
  String get friendHint => 'Des gens avec qui sortir et discuter';

  @override
  String get datingHint => 'Une relation amoureuse';

  @override
  String get whoLookingFor => 'Qui recherches-tu ?';

  @override
  String ageRange(int min, int max) {
    return 'Tranche d\'âge : $min–$max';
  }

  @override
  String get consentTitle => 'Consentement';

  @override
  String get iam18 => 'J\'ai plus de 18 ans.';

  @override
  String get consentText =>
      'Pour les rencontres, je consens explicitement au traitement de mon genre, de la personne que je recherche, de ma date de naissance, de ma province et de mes photos, ainsi qu\'à leur affichage aux personnes de mes groupes en commun ayant activé les rencontres. Je peux retirer mon consentement à tout moment en supprimant mes données de rencontre.';

  @override
  String get createProfile => 'Créer mon profil';

  @override
  String get save => 'Enregistrer';

  @override
  String get photos => 'Photos';

  @override
  String photosMin(int min) {
    return 'Ajoute au moins $min photos pour que ta carte s’affiche. La première est la couverture.';
  }

  @override
  String photosMax(int max) {
    return 'Jusqu’à $max photos. La première est la couverture ; touche une photo pour la changer.';
  }

  @override
  String get addPhoto => 'Ajouter une photo';

  @override
  String get cover => 'Couverture';

  @override
  String get removePhoto => 'Retirer la photo';

  @override
  String get pauseProfile => 'Mettre mon profil en pause';

  @override
  String get pauseHint =>
      'Personne ne te voit et aucune nouvelle carte n’arrive ; tes matchs et discussions restent.';

  @override
  String get deleteData => 'Supprimer mes données de rencontre';

  @override
  String get deleteDataHint =>
      'Profil, photos et likes sont supprimés ; tes matchs prennent fin. Ton consentement est retiré.';

  @override
  String get deleteDataTitle => 'Supprimer les données de rencontre';

  @override
  String get deleteDataBody =>
      'Ton profil, tes photos et tes likes sont définitivement supprimés ; tous tes matchs prennent fin. C’est irréversible.';

  @override
  String get delete => 'Supprimer';

  @override
  String get dataDeleted => 'Tes données de rencontre ont été supprimées.';

  @override
  String get itsAMatch => 'C\'est un match !';

  @override
  String bothLiked(String name) {
    return '$name et toi vous êtes likés mutuellement.';
  }

  @override
  String get keepSwiping => 'Continuer à swiper';

  @override
  String get sendMessage => 'Envoyer un message';

  @override
  String get reportProfile => 'Signaler le profil';

  @override
  String get reportPhoto => 'Signaler cette photo';

  @override
  String get block => 'Bloquer';

  @override
  String get blockHint => 'Vous ne vous verrez plus nulle part.';

  @override
  String get cancel => 'Annuler';

  @override
  String get newMatch => 'Tu as un match !';

  @override
  String tapToSee(String date) {
    return 'Touche pour voir qui c’est · $date';
  }

  @override
  String get revealReason =>
      'Tu as un match ! Prends la formule Mes matchs pour voir qui c’est.';

  @override
  String get keepFriend => 'Rester amis seulement';

  @override
  String get keepDating => 'Garder seulement les rencontres';

  @override
  String keepFriendBody(String name) {
    return 'Ton match rencontres avec $name prend fin pour vous deux ; le match amitié et la discussion continuent.';
  }

  @override
  String keepDatingBody(String name) {
    return 'Ton match amitié avec $name prend fin pour vous deux ; le match rencontres et la discussion continuent.';
  }

  @override
  String get keptFriend => 'Vous êtes désormais matchés en amitié seulement.';

  @override
  String get keptDating =>
      'Vous êtes désormais matchés en rencontres seulement.';

  @override
  String get continueAction => 'Continuer';

  @override
  String get endMatch => 'Mettre fin au match';

  @override
  String endMatchBody(String name) {
    return 'Ton match avec $name prend fin et la discussion se ferme pour vous deux. C’est irréversible.';
  }

  @override
  String get end => 'Terminer';

  @override
  String get matchEnded => 'Le match est terminé.';

  @override
  String get noMatches =>
      'Pas encore de match. Les personnes avec qui le like est mutuel apparaissent ici.';

  @override
  String get backToDiscover => 'Retour à la découverte';

  @override
  String get report => 'Signaler';

  @override
  String get matching => 'Rencontres';

  @override
  String get admirers => 'Qui te like';

  @override
  String get packages => 'Formules';

  @override
  String get more => 'Plus';

  @override
  String get filtersLocked =>
      'Les filtres par âge, province et centre d\'intérêt sont inclus dans la formule Likes illimités.';

  @override
  String get filters => 'Filtres';

  @override
  String get suspended =>
      'Ton profil de rencontre a été fermé par l’équipe de la plateforme. Écris au Support pour en savoir plus.';

  @override
  String addPhotosToStart(int min) {
    return 'Ajoute au moins $min photos pour afficher ta carte et commencer à découvrir.';
  }

  @override
  String get paused =>
      'Ton profil est en pause ; personne ne te voit. Tes matchs et discussions sont toujours là.';

  @override
  String get likesOut =>
      'Tes likes gratuits du jour sont épuisés. Like autant que tu veux avec Likes illimités.';

  @override
  String get supersOut =>
      'Tes Super Likes du jour sont épuisés. Ils reviennent demain.';

  @override
  String get superUsed =>
      'Tu as utilisé ton Super Like du jour. 5 par jour avec la formule Super Like.';

  @override
  String get rewindLocked =>
      'Faire revenir une personne passée par erreur est inclus dans Likes illimités.';

  @override
  String rewoundTo(String mode) {
    return 'La dernière personne passée est revenue dans la pile $mode.';
  }

  @override
  String boostReason(int minutes) {
    return 'Avec un Boost, tu apparais en tête des piles pendant $minutes minutes.';
  }

  @override
  String boosting(int minutes) {
    return 'Ton Boost est actif. Encore $minutes minutes.';
  }

  @override
  String get boostUsed => 'Tu as utilisé ton Boost du jour. Il revient demain.';

  @override
  String get boost => 'Booster';

  @override
  String boostBody(int minutes) {
    return 'Pendant $minutes minutes, tu apparais en premier dans les piles des personnes de tes groupes en commun. Une fois par jour.';
  }

  @override
  String boosted(int minutes) {
    return 'Boost activé ! Tu es en tête pendant $minutes minutes.';
  }

  @override
  String get deckEmpty =>
      'Plus personne à afficher pour l\'instant. Ça se remplira à mesure que tu rejoins des groupes et que d\'autres activent les rencontres.';

  @override
  String get deckEmptyFiltered =>
      'Plus personne ne correspond à tes filtres. Essaie de les élargir.';

  @override
  String get refresh => 'Actualiser';

  @override
  String get clearFilters => 'Effacer les filtres';

  @override
  String allowanceUnlimited(int supers) {
    return 'Likes illimités · $supers Super Likes restants.';
  }

  @override
  String get allowanceOut =>
      'Tes likes du jour sont épuisés ; ils reviennent demain.';

  @override
  String allowance(int likes, int supers) {
    return 'Aujourd\'hui, il te reste $likes likes et $supers Super Likes.';
  }

  @override
  String get undo => 'Annuler';

  @override
  String get pass => 'Passer';

  @override
  String get superLike => 'Super Like';

  @override
  String get like => 'Liker';

  @override
  String get introTitle =>
      'Rencontre de nouvelles personnes de tes groupes en commun';

  @override
  String get intro1 =>
      'Tu vois seulement les personnes ayant activé les rencontres dans les groupes dont tu es membre ou que tu suis.';

  @override
  String get intro2 =>
      'Swipe à droite pour liker, à gauche pour passer, vers le haut pour un Super Like.';

  @override
  String get intro3 =>
      'Quand vous vous likez mutuellement, c’est un match. Tu écris à ton match avec la formule Discussion de match.';

  @override
  String get intro4 =>
      'Amitié et Rencontres sont des modes distincts ; choisis-en un ou les deux.';

  @override
  String get intro5 =>
      'Ton profil n’est visible que par ceux qui ont activé les rencontres. Mets-le en pause ou supprime-le à tout moment.';

  @override
  String get createMyProfile => 'Créer mon profil de rencontre';

  @override
  String seePackageOf(String package) {
    return 'Voir la formule $package';
  }

  @override
  String get allPackages => 'Toutes les formules';

  @override
  String get packagesTitle => 'Formules de rencontre';

  @override
  String get packagesIntro =>
      'Créer un profil et swiper sont gratuits. Chaque fonction est une formule à part ; prends seulement ce que tu veux.';

  @override
  String get adminAllOpen =>
      'En tant qu’admin, toutes les formules sont actives';

  @override
  String openUntil(String date) {
    return 'Active jusqu\'au $date';
  }

  @override
  String ageFilter(int min, int max) {
    return 'Âge : $min – $max';
  }

  @override
  String get allProvinces => 'Toutes les provinces';

  @override
  String get interest => 'Centre d\'intérêt';

  @override
  String get all => 'Tous';

  @override
  String get apply => 'Appliquer';

  @override
  String get clear => 'Effacer';

  @override
  String get noAdmirers =>
      'Aucun like en attente pour l\'instant. Continue à swiper ; ceux qui te likent apparaîtront ici.';

  @override
  String get backToSwiping => 'Retour aux swipes';

  @override
  String get likeAndMatch => 'Liker et matcher';

  @override
  String get noPendingLikes => 'Aucun like en attente';

  @override
  String likedYouCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnes t’ont liké',
      one: '1 personne t’a liké',
    );
    return '$_temp0';
  }

  @override
  String get admirersPitch =>
      'Avec la formule Qui te like, vois qui c’est et matche aussitôt en likant en retour.';

  @override
  String get seePackage => 'Voir la formule';
}
