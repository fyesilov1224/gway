// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'feed_l10n.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class FeedL10nFr extends FeedL10n {
  FeedL10nFr([String locale = 'fr']) : super(locale);

  @override
  String get commentsOff =>
      'Les commentaires sont désactivés pour cette publication.';

  @override
  String get commentNotAllowed =>
      'Impossible de commenter cette publication pour le moment. Tu peux réagir avec un emoji.';

  @override
  String get blocked => 'Tu ne peux pas interagir avec ce compte.';

  @override
  String get commentRate =>
      'Tu as beaucoup commenté en peu de temps. Patiente un peu et réessaie.';

  @override
  String get muted =>
      'Tu es mis(e) en sourdine dans ce groupe, tu ne peux pas commenter pour le moment.';

  @override
  String get likeRate =>
      'Tu as aimé beaucoup de publications en peu de temps. Patiente un peu et réessaie.';

  @override
  String get replyGone => 'Le commentaire auquel tu réponds n\'existe plus.';

  @override
  String get storyRate =>
      'Tu as partagé beaucoup de stories aujourd\'hui. Réessaie demain.';

  @override
  String get highlightLimit => 'Tu peux créer jusqu\'à 100 stories à la une.';

  @override
  String get highlightFull =>
      'Une story à la une peut contenir jusqu\'à 100 stories.';

  @override
  String get duplicate => 'Cette action a déjà été effectuée.';

  @override
  String get fileTooLarge =>
      'Le fichier est trop volumineux. Les photos peuvent faire jusqu\'à 10 Mo, les vidéos 50 Mo.';

  @override
  String get unsupportedMedia =>
      'Seules les photos JPEG, PNG, WebP et les vidéos MP4, MOV peuvent être partagées.';

  @override
  String get commentLength =>
      'Un commentaire doit contenir de 1 à 2 200 caractères.';

  @override
  String get highlightTitleLength =>
      'Le titre doit contenir de 1 à 30 caractères.';

  @override
  String get pickStory => 'Choisis au moins une story.';

  @override
  String get aspectOriginal => 'Original';

  @override
  String get agoNow => 'à l\'instant';

  @override
  String agoMinutes(int n) {
    return '$n min';
  }

  @override
  String agoHours(int n) {
    return '$n h';
  }

  @override
  String agoDays(int n) {
    return '$n j';
  }

  @override
  String agoWeeks(int n) {
    return '$n sem.';
  }

  @override
  String get photoLimit => 'Les photos peuvent faire jusqu\'à 10 Mo.';

  @override
  String get videoSizeLimit => 'Les vidéos peuvent faire jusqu\'à 50 Mo.';

  @override
  String get videoLengthLimit =>
      'Les vidéos peuvent durer jusqu\'à 60 secondes.';

  @override
  String get captionLimit =>
      'La légende peut contenir jusqu\'à 2 200 caractères.';

  @override
  String get hashtagLimit =>
      'Une publication peut contenir jusqu\'à 30 hashtags.';

  @override
  String get mediaCount =>
      'Une publication peut contenir de 1 à 10 photos ou vidéos.';

  @override
  String get comments => 'Commentaires';

  @override
  String get noCommentsEmojiOnly =>
      'Pas encore de commentaire. Tu peux réagir avec un emoji.';

  @override
  String get noCommentsFirst =>
      'Pas encore de commentaire. Sois le premier ou la première à commenter.';

  @override
  String get goBack => 'Retour';

  @override
  String get writeComment => 'Écrire un commentaire';

  @override
  String replyingTo(String username) {
    return 'Réponse à @$username';
  }

  @override
  String get cancelReply => 'Annuler la réponse';

  @override
  String get addComment => 'Ajouter un commentaire…';

  @override
  String get share => 'Partager';

  @override
  String get deleteCommentTitle => 'Supprimer le commentaire ?';

  @override
  String get deleteCommentBody =>
      'Le commentaire et ses réponses sont supprimés définitivement.';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String likeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count j\'aime',
      one: '1 j\'aime',
    );
    return '$_temp0';
  }

  @override
  String commentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count commentaires',
      one: '1 commentaire',
    );
    return '$_temp0';
  }

  @override
  String get reply => 'Répondre';

  @override
  String get report => 'Signaler';

  @override
  String get unlike => 'Je n\'aime plus';

  @override
  String get likeComment => 'J\'aime le commentaire';

  @override
  String get cantComment =>
      'Tu ne peux pas commenter cette publication pour le moment. Tu peux réagir avec un emoji.';

  @override
  String get tooManyMedia =>
      'Une publication peut contenir jusqu\'à 10 photos ou vidéos.';

  @override
  String get cantOpenFile =>
      'Le fichier sélectionné n\'a pas pu être ouvert. Essaie une autre photo ou vidéo.';

  @override
  String get preparingPhotos => 'Préparation des photos…';

  @override
  String get photosFailed =>
      'Les photos n\'ont pas pu être préparées. Essaie une autre photo.';

  @override
  String uploading(int done, int total) {
    return 'Importation : $done/$total';
  }

  @override
  String get sharing => 'Publication…';

  @override
  String get postShared => 'Ta publication a été partagée.';

  @override
  String get newPost => 'Nouvelle publication';

  @override
  String get memoryNotice =>
      'Cette publication apparaîtra aussi parmi les souvenirs de l\'événement. Ne partage que tes propres photos et des personnes qui ont donné leur accord.';

  @override
  String get pickMediaHint =>
      'Choisis jusqu\'à 10 photos ou vidéos à partager.';

  @override
  String get pickFromGallery => 'Choisir dans la galerie';

  @override
  String get cropHint =>
      'Écarte deux doigts pour zoomer et fais glisser pour cadrer. Le format s’applique à toutes les photos.';

  @override
  String get caption => 'Légende';

  @override
  String get captionHint =>
      'Écris quelque chose… Tu peux ajouter des #hashtags et des @noms.';

  @override
  String get postAs => 'Publier en tant que';

  @override
  String get myProfile => 'Mon profil';

  @override
  String groupOption(String name) {
    return '$name (groupe)';
  }

  @override
  String get turnOffComments => 'Désactiver les commentaires';

  @override
  String get hideLikes => 'Masquer le nombre de j\'aime';

  @override
  String get onlyYouSee => 'Toi seul(e) vois le nombre.';

  @override
  String mediaN(int n) {
    return 'Média $n';
  }

  @override
  String seconds(int n) {
    return '▶ $n s';
  }

  @override
  String get removeMedia => 'Retirer';

  @override
  String get cantShare => 'Impossible à partager';

  @override
  String get addMedia => 'Ajouter un média';

  @override
  String get editPost => 'Modifier la publication';

  @override
  String get save => 'Enregistrer';

  @override
  String get noEditPermission =>
      'Tu n\'as pas le droit de modifier cette publication.';

  @override
  String get photoToCrop => 'Photo à recadrer';

  @override
  String get stories => 'Stories';

  @override
  String get feed => 'Fil d\'actualité';

  @override
  String get feedHint => 'De tes groupes et des personnes que tu suis';

  @override
  String get feedEmpty =>
      'Ton fil est vide. Les publications des personnes et groupes que tu suis apparaissent ici.';

  @override
  String get explore => 'Explorer';

  @override
  String get searchHint => 'Rechercher des personnes ou des #hashtags';

  @override
  String get clear => 'Effacer';

  @override
  String get exploreEmpty =>
      'Rien de nouveau à explorer. Reviens un peu plus tard.';

  @override
  String get refresh => 'Actualiser';

  @override
  String get accounts => 'Comptes';

  @override
  String get hashtags => 'Hashtags';

  @override
  String noTagMatch(String query) {
    return 'Aucun hashtag ne commence par « $query ».';
  }

  @override
  String get clearSearch => 'Effacer la recherche';

  @override
  String postCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count publications',
      one: '1 publication',
    );
    return '$_temp0';
  }

  @override
  String noTagPosts(String tag) {
    return 'Aucune publication visible avec #$tag.';
  }

  @override
  String get backToExplore => 'Retour à Explorer';

  @override
  String get saved => 'Enregistrés';

  @override
  String get savedEmpty =>
      'Les publications enregistrées apparaissent ici, visibles par toi seul(e).';

  @override
  String get post => 'Publication';

  @override
  String get postGone =>
      'Cette publication a été supprimée ou tu n\'as pas le droit de la voir.';

  @override
  String get backToFeed => 'Retour au fil';

  @override
  String get unmute => 'Activer le son';

  @override
  String get mute => 'Couper le son';

  @override
  String get addedToSaved => 'Ajouté aux enregistrements.';

  @override
  String get linkCopied => 'Lien de la publication copié.';

  @override
  String get deletePostTitle => 'Supprimer la publication ?';

  @override
  String get deletePostBody =>
      'La publication est supprimée définitivement avec ses photos, vidéos et commentaires.';

  @override
  String get postDeleted => 'Publication supprimée.';

  @override
  String get likesHidden => 'Toi seul(e) vois le nombre de j\'aime.';

  @override
  String memoryOf(String title) {
    return 'Souvenir · $title';
  }

  @override
  String get deletedAccount => 'Compte supprimé';

  @override
  String get groupPost => 'Publication de groupe';

  @override
  String get edited => 'modifié';

  @override
  String get moreOptions => 'Plus d\'options';

  @override
  String get copyLink => 'Copier le lien';

  @override
  String get edit => 'Modifier';

  @override
  String get like => 'J\'aime';

  @override
  String get commentAction => 'Commenter';

  @override
  String get unsave => 'Retirer des enregistrements';

  @override
  String reactionLabel(String emoji, int count) {
    return 'Réaction $emoji, $count';
  }

  @override
  String get more => 'plus';

  @override
  String postWithCaption(String caption) {
    return 'Publication : $caption';
  }

  @override
  String get showMore => 'Afficher plus';

  @override
  String get addStory => 'Ajouter une story';

  @override
  String get yourStory => 'Ta story';

  @override
  String get noStoriesLeft => 'Il n\'y a plus de story à voir ici.';

  @override
  String get close => 'Fermer';

  @override
  String get removeFromHighlight => 'Retirer de la story à la une';

  @override
  String get removedFromHighlight => 'Retiré de la story à la une.';

  @override
  String get addToHighlights => 'Ajouter à la une';

  @override
  String get deleteStory => 'Supprimer la story';

  @override
  String get storyDeleted => 'Story supprimée.';

  @override
  String get options => 'Options';

  @override
  String get viewers => 'Vues';

  @override
  String get noViewers =>
      'Personne ne l\'a encore vue. Les vues apparaissent ici, visibles par toi seul(e).';

  @override
  String viewedBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vue par $count personnes',
      one: 'Vue par 1 personne',
    );
    return '$_temp0';
  }

  @override
  String get storyPhotoFailed =>
      'La photo n\'a pas pu être préparée. Essaie une autre photo.';

  @override
  String get storyShared =>
      'Ta story est publiée. Elle reste visible 24 heures.';

  @override
  String get newStory => 'Nouvelle story';

  @override
  String get addToStory => 'Ajouter à ta story';

  @override
  String get storyPickHint =>
      'Choisis une photo ou une vidéo de 60 secondes maximum pour ta story.';

  @override
  String get pickAnother => 'Choisir autre chose';

  @override
  String get newHighlight => 'Nouvelle story à la une';

  @override
  String highlightCreated(String title) {
    return '« $title » créée.';
  }

  @override
  String storyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stories',
      one: '1 story',
    );
    return '$_temp0';
  }

  @override
  String addedToHighlight(String title) {
    return 'Ajouté à « $title ».';
  }

  @override
  String get highlightTitle => 'Titre de la story à la une';

  @override
  String get highlightExample => 'Ex. : Camping 2026';

  @override
  String get addHighlight => 'Ajouter à la une';

  @override
  String get renameHighlight => 'Renommer';

  @override
  String get deleteHighlight => 'Supprimer la story à la une';

  @override
  String get staysInArchive => 'Les stories restent dans tes archives.';

  @override
  String get storyArchive => 'Archives des stories';

  @override
  String storiesSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stories sélectionnées',
      one: '1 story sélectionnée',
    );
    return '$_temp0';
  }

  @override
  String get feature => 'Mettre à la une';

  @override
  String get archiveEmpty =>
      'Tes stories sont conservées ici après 24 heures, visibles par toi seul(e).';

  @override
  String get shareStory => 'Partager une story';

  @override
  String get archiveHint =>
      'Sélectionne des stories pour créer une story à la une ou en compléter une.';

  @override
  String storyOn(String date) {
    return 'Story, $date';
  }

  @override
  String get live => 'En ligne';
}
