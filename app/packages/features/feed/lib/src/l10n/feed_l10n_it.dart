// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'feed_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class FeedL10nIt extends FeedL10n {
  FeedL10nIt([String locale = 'it']) : super(locale);

  @override
  String get commentsOff => 'I commenti sono disattivati per questo post.';

  @override
  String get commentNotAllowed =>
      'Al momento non puoi commentare questo post. Puoi reagire con un’emoji.';

  @override
  String get blocked => 'Non puoi interagire con questo account.';

  @override
  String get commentRate =>
      'Hai commentato molto in poco tempo. Aspetta un po’ e riprova.';

  @override
  String get muted =>
      'Sei silenziato in questo gruppo e al momento non puoi commentare.';

  @override
  String get likeRate =>
      'Hai messo molti “mi piace” in poco tempo. Aspetta un po’ e riprova.';

  @override
  String get replyGone => 'Il commento a cui rispondi non esiste più.';

  @override
  String get storyRate => 'Oggi hai condiviso molte storie. Riprova domani.';

  @override
  String get highlightLimit => 'Puoi creare fino a 100 storie in evidenza.';

  @override
  String get highlightFull =>
      'Una storia in evidenza può contenere fino a 100 storie.';

  @override
  String get duplicate => 'Questa azione è già stata eseguita.';

  @override
  String get fileTooLarge =>
      'Il file è troppo grande. Le foto possono arrivare a 10 MB, i video a 50 MB.';

  @override
  String get unsupportedMedia =>
      'Si possono condividere solo foto JPEG, PNG, WebP e video MP4, MOV.';

  @override
  String get commentLength => 'Il commento deve avere da 1 a 2.200 caratteri.';

  @override
  String get highlightTitleLength =>
      'Il titolo deve avere da 1 a 30 caratteri.';

  @override
  String get pickStory => 'Scegli almeno una storia.';

  @override
  String get aspectOriginal => 'Originale';

  @override
  String get agoNow => 'ora';

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
    return '$n g';
  }

  @override
  String agoWeeks(int n) {
    return '$n sett.';
  }

  @override
  String get photoLimit => 'Le foto possono arrivare a 10 MB.';

  @override
  String get videoSizeLimit => 'I video possono arrivare a 50 MB.';

  @override
  String get videoLengthLimit => 'I video possono durare fino a 60 secondi.';

  @override
  String get captionLimit => 'La didascalia può avere fino a 2.200 caratteri.';

  @override
  String get hashtagLimit => 'Un post può avere fino a 30 hashtag.';

  @override
  String get mediaCount => 'Un post può avere da 1 a 10 foto o video.';

  @override
  String get comments => 'Commenti';

  @override
  String get noCommentsEmojiOnly =>
      'Ancora nessun commento. Puoi reagire con un’emoji.';

  @override
  String get noCommentsFirst => 'Ancora nessun commento. Scrivi tu il primo.';

  @override
  String get goBack => 'Torna indietro';

  @override
  String get writeComment => 'Scrivi un commento';

  @override
  String replyingTo(String username) {
    return 'Rispondi a $username';
  }

  @override
  String get cancelReply => 'Annulla risposta';

  @override
  String get addComment => 'Aggiungi un commento…';

  @override
  String get share => 'Condividi';

  @override
  String get deleteCommentTitle => 'Eliminare il commento?';

  @override
  String get deleteCommentBody =>
      'Il commento e le risposte vengono eliminati definitivamente.';

  @override
  String get cancel => 'Annulla';

  @override
  String get delete => 'Elimina';

  @override
  String likeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mi piace',
      one: '1 mi piace',
    );
    return '$_temp0';
  }

  @override
  String commentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count commenti',
      one: '1 commento',
    );
    return '$_temp0';
  }

  @override
  String get reply => 'Rispondi';

  @override
  String get report => 'Segnala';

  @override
  String get unlike => 'Non mi piace più';

  @override
  String get likeComment => 'Mi piace il commento';

  @override
  String get cantComment =>
      'Al momento non puoi commentare questo post. Puoi reagire con un’emoji.';

  @override
  String get tooManyMedia => 'Un post può avere fino a 10 foto o video.';

  @override
  String get cantOpenFile =>
      'Impossibile aprire il file selezionato. Prova un’altra foto o un altro video.';

  @override
  String get preparingPhotos => 'Preparazione delle foto…';

  @override
  String get photosFailed =>
      'Impossibile preparare le foto. Prova con un’altra.';

  @override
  String uploading(int done, int total) {
    return 'Caricamento: $done/$total';
  }

  @override
  String get sharing => 'Condivisione…';

  @override
  String get postShared => 'Il tuo post è stato condiviso.';

  @override
  String get newPost => 'Nuovo post';

  @override
  String get memoryNotice =>
      'Questo post comparirà anche tra i ricordi dell\'evento. Condividi solo le tue foto e persone che hanno dato il consenso.';

  @override
  String get pickMediaHint => 'Scegli fino a 10 foto o video da condividere.';

  @override
  String get pickFromGallery => 'Scegli dalla galleria';

  @override
  String get cropHint =>
      'Allarga con due dita per lo zoom e trascina per inquadrare. Il formato vale per tutte le foto.';

  @override
  String get caption => 'Didascalia';

  @override
  String get captionHint =>
      'Scrivi qualcosa… Puoi aggiungere #hashtag e @nomiutente.';

  @override
  String get postAs => 'Pubblica come';

  @override
  String get myProfile => 'Il mio profilo';

  @override
  String groupOption(String name) {
    return '$name (gruppo)';
  }

  @override
  String get turnOffComments => 'Disattiva i commenti';

  @override
  String get hideLikes => 'Nascondi il numero di mi piace';

  @override
  String get onlyYouSee => 'Solo tu vedi il numero.';

  @override
  String mediaN(int n) {
    return 'Media $n';
  }

  @override
  String seconds(int n) {
    return '▶ $n s';
  }

  @override
  String get removeMedia => 'Rimuovi';

  @override
  String get cantShare => 'Non condivisibile';

  @override
  String get addMedia => 'Aggiungi media';

  @override
  String get editPost => 'Modifica post';

  @override
  String get save => 'Salva';

  @override
  String get noEditPermission =>
      'Non hai il permesso di modificare questo post.';

  @override
  String get photoToCrop => 'Foto da ritagliare';

  @override
  String get stories => 'Storie';

  @override
  String get feed => 'Feed';

  @override
  String get feedHint => 'Dai tuoi gruppi e dalle persone che segui';

  @override
  String get feedEmpty =>
      'Il tuo feed è vuoto. Qui compaiono i post di persone e gruppi che segui.';

  @override
  String get explore => 'Esplora';

  @override
  String get searchHint => 'Cerca persone o #hashtag';

  @override
  String get clear => 'Cancella';

  @override
  String get exploreEmpty => 'Niente di nuovo da esplorare. Riprova tra poco.';

  @override
  String get refresh => 'Aggiorna';

  @override
  String get accounts => 'Account';

  @override
  String get hashtags => 'Hashtag';

  @override
  String noTagMatch(String query) {
    return 'Nessun hashtag inizia con «$query».';
  }

  @override
  String get clearSearch => 'Cancella ricerca';

  @override
  String postCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count post',
      one: '1 post',
    );
    return '$_temp0';
  }

  @override
  String noTagPosts(String tag) {
    return 'Non ci sono post visibili con #$tag.';
  }

  @override
  String get backToExplore => 'Torna a Esplora';

  @override
  String get saved => 'Salvati';

  @override
  String get savedEmpty => 'I post salvati compaiono qui e li vedi solo tu.';

  @override
  String get post => 'Post';

  @override
  String get postGone =>
      'Questo post è stato eliminato o non hai il permesso di vederlo.';

  @override
  String get backToFeed => 'Torna al feed';

  @override
  String get unmute => 'Attiva audio';

  @override
  String get mute => 'Disattiva audio';

  @override
  String get addedToSaved => 'Aggiunto ai salvati.';

  @override
  String get linkCopied => 'Link del post copiato.';

  @override
  String get deletePostTitle => 'Eliminare il post?';

  @override
  String get deletePostBody =>
      'Il post viene eliminato definitivamente con foto, video e commenti.';

  @override
  String get postDeleted => 'Post eliminato.';

  @override
  String get likesHidden => 'Solo tu vedi il numero di mi piace.';

  @override
  String memoryOf(String title) {
    return 'Ricordo · $title';
  }

  @override
  String get deletedAccount => 'Account eliminato';

  @override
  String get groupPost => 'Post di gruppo';

  @override
  String get edited => 'modificato';

  @override
  String get moreOptions => 'Altre opzioni';

  @override
  String get copyLink => 'Copia link';

  @override
  String get edit => 'Modifica';

  @override
  String get like => 'Mi piace';

  @override
  String get commentAction => 'Commenta';

  @override
  String get unsave => 'Rimuovi dai salvati';

  @override
  String reactionLabel(String emoji, int count) {
    return 'Reazione $emoji, $count';
  }

  @override
  String get more => 'altro';

  @override
  String postWithCaption(String caption) {
    return 'Post: $caption';
  }

  @override
  String get showMore => 'Mostra altro';

  @override
  String get addStory => 'Aggiungi storia';

  @override
  String get yourStory => 'La tua storia';

  @override
  String get noStoriesLeft => 'Non ci sono altre storie da vedere qui.';

  @override
  String get close => 'Chiudi';

  @override
  String get removeFromHighlight => 'Rimuovi dall\'evidenza';

  @override
  String get removedFromHighlight => 'Rimosso dall\'evidenza.';

  @override
  String get addToHighlights => 'Aggiungi in evidenza';

  @override
  String get deleteStory => 'Elimina storia';

  @override
  String get storyDeleted => 'Storia eliminata.';

  @override
  String get options => 'Opzioni';

  @override
  String get viewers => 'Visualizzazioni';

  @override
  String get noViewers =>
      'Nessuno l’ha ancora vista. Le visualizzazioni compaiono qui e le vedi solo tu.';

  @override
  String viewedBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vista da $count persone',
      one: 'Vista da 1 persona',
    );
    return '$_temp0';
  }

  @override
  String get storyPhotoFailed =>
      'Impossibile preparare la foto. Prova con un’altra.';

  @override
  String get storyShared =>
      'La tua storia è condivisa. Resta visibile per 24 ore.';

  @override
  String get newStory => 'Nuova storia';

  @override
  String get addToStory => 'Aggiungi alla tua storia';

  @override
  String get storyPickHint =>
      'Scegli una foto o un video fino a 60 secondi per la tua storia.';

  @override
  String get pickAnother => 'Scegli altro';

  @override
  String get newHighlight => 'Nuova storia in evidenza';

  @override
  String highlightCreated(String title) {
    return '«$title» creata.';
  }

  @override
  String storyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count storie',
      one: '1 storia',
    );
    return '$_temp0';
  }

  @override
  String addedToHighlight(String title) {
    return 'Aggiunto a «$title».';
  }

  @override
  String get highlightTitle => 'Titolo della storia in evidenza';

  @override
  String get highlightExample => 'Es. Campeggio 2026';

  @override
  String get addHighlight => 'Aggiungi in evidenza';

  @override
  String get renameHighlight => 'Rinomina';

  @override
  String get deleteHighlight => 'Elimina storia in evidenza';

  @override
  String get staysInArchive => 'Le storie restano nel tuo archivio.';

  @override
  String get storyArchive => 'Archivio storie';

  @override
  String storiesSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count storie selezionate',
      one: '1 storia selezionata',
    );
    return '$_temp0';
  }

  @override
  String get feature => 'Metti in evidenza';

  @override
  String get archiveEmpty =>
      'Le storie che condividi restano qui dopo 24 ore, visibili solo a te.';

  @override
  String get shareStory => 'Condividi una storia';

  @override
  String get archiveHint =>
      'Seleziona le storie per creare una storia in evidenza o aggiungerle.';

  @override
  String storyOn(String date) {
    return 'Storia, $date';
  }

  @override
  String get live => 'Online';
}
