// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'feed_l10n.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class FeedL10nDe extends FeedL10n {
  FeedL10nDe([String locale = 'de']) : super(locale);

  @override
  String get commentsOff => 'Kommentare sind für diesen Beitrag deaktiviert.';

  @override
  String get commentNotAllowed =>
      'Dieser Beitrag kann gerade nicht kommentiert werden. Du kannst mit einem Emoji reagieren.';

  @override
  String get blocked => 'Du kannst mit diesem Konto nicht interagieren.';

  @override
  String get commentRate =>
      'Du hast in kurzer Zeit sehr viel kommentiert. Warte etwas und versuche es erneut.';

  @override
  String get muted =>
      'Du bist in dieser Gruppe stummgeschaltet und kannst gerade nicht kommentieren.';

  @override
  String get likeRate =>
      'Du hast in kurzer Zeit sehr viel geliked. Warte etwas und versuche es erneut.';

  @override
  String get replyGone =>
      'Der Kommentar, auf den du antwortest, existiert nicht mehr.';

  @override
  String get storyRate =>
      'Du hast heute sehr viele Storys geteilt. Versuche es morgen erneut.';

  @override
  String get highlightLimit => 'Du kannst bis zu 100 Highlights erstellen.';

  @override
  String get highlightFull => 'Ein Highlight kann bis zu 100 Storys enthalten.';

  @override
  String get duplicate => 'Das wurde bereits erledigt.';

  @override
  String get fileTooLarge =>
      'Die Datei ist zu groß. Fotos dürfen bis 10 MB, Videos bis 50 MB groß sein.';

  @override
  String get unsupportedMedia =>
      'Nur JPEG-, PNG-, WebP-Fotos und MP4-, MOV-Videos können geteilt werden.';

  @override
  String get commentLength => 'Ein Kommentar muss 1–2.200 Zeichen lang sein.';

  @override
  String get highlightTitleLength => 'Der Titel muss 1–30 Zeichen lang sein.';

  @override
  String get pickStory => 'Wähle mindestens eine Story.';

  @override
  String get aspectOriginal => 'Original';

  @override
  String get agoNow => 'jetzt';

  @override
  String agoMinutes(int n) {
    return '$n Min.';
  }

  @override
  String agoHours(int n) {
    return '$n Std.';
  }

  @override
  String agoDays(int n) {
    return '$n T.';
  }

  @override
  String agoWeeks(int n) {
    return '$n Wo.';
  }

  @override
  String get photoLimit => 'Fotos dürfen bis 10 MB groß sein.';

  @override
  String get videoSizeLimit => 'Videos dürfen bis 50 MB groß sein.';

  @override
  String get videoLengthLimit => 'Videos dürfen bis 60 Sekunden lang sein.';

  @override
  String get captionLimit =>
      'Die Beschreibung darf bis zu 2.200 Zeichen lang sein.';

  @override
  String get hashtagLimit => 'Ein Beitrag darf bis zu 30 Hashtags enthalten.';

  @override
  String get mediaCount => 'Ein Beitrag kann 1–10 Fotos oder Videos enthalten.';

  @override
  String get comments => 'Kommentare';

  @override
  String get noCommentsEmojiOnly =>
      'Noch keine Kommentare. Du kannst mit einem Emoji reagieren.';

  @override
  String get noCommentsFirst => 'Noch keine Kommentare. Schreib den ersten.';

  @override
  String get goBack => 'Zurück';

  @override
  String get writeComment => 'Kommentar schreiben';

  @override
  String replyingTo(String username) {
    return 'Antwort an $username';
  }

  @override
  String get cancelReply => 'Antwort abbrechen';

  @override
  String get addComment => 'Kommentar hinzufügen…';

  @override
  String get share => 'Teilen';

  @override
  String get deleteCommentTitle => 'Kommentar löschen?';

  @override
  String get deleteCommentBody =>
      'Der Kommentar und seine Antworten werden endgültig gelöscht.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String likeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Likes',
      one: '1 Like',
    );
    return '$_temp0';
  }

  @override
  String commentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Kommentare',
      one: '1 Kommentar',
    );
    return '$_temp0';
  }

  @override
  String get reply => 'Antworten';

  @override
  String get report => 'Melden';

  @override
  String get unlike => 'Gefällt mir nicht mehr';

  @override
  String get likeComment => 'Kommentar liken';

  @override
  String get cantComment =>
      'Du kannst diesen Beitrag gerade nicht kommentieren. Du kannst mit einem Emoji reagieren.';

  @override
  String get tooManyMedia =>
      'Ein Beitrag kann bis zu 10 Fotos oder Videos enthalten.';

  @override
  String get cantOpenFile =>
      'Die ausgewählte Datei konnte nicht geöffnet werden. Versuche ein anderes Foto oder Video.';

  @override
  String get preparingPhotos => 'Fotos werden vorbereitet…';

  @override
  String get photosFailed =>
      'Die Fotos konnten nicht vorbereitet werden. Versuche ein anderes.';

  @override
  String uploading(int done, int total) {
    return 'Wird hochgeladen: $done/$total';
  }

  @override
  String get sharing => 'Wird geteilt…';

  @override
  String get postShared => 'Dein Beitrag wurde geteilt.';

  @override
  String get newPost => 'Neuer Beitrag';

  @override
  String get memoryNotice =>
      'Dieser Beitrag erscheint auch bei den Erinnerungen des Events. Teile nur eigene Fotos und Personen, die zugestimmt haben.';

  @override
  String get pickMediaHint => 'Wähle bis zu 10 Fotos oder Videos zum Teilen.';

  @override
  String get pickFromGallery => 'Aus Galerie wählen';

  @override
  String get cropHint =>
      'Mit zwei Fingern zoomen, zum Zuschneiden ziehen. Das Format gilt für alle Fotos.';

  @override
  String get caption => 'Beschreibung';

  @override
  String get captionHint =>
      'Schreib etwas … Du kannst #Hashtags und @Benutzernamen hinzufügen.';

  @override
  String get postAs => 'Teilen als';

  @override
  String get myProfile => 'Mein Profil';

  @override
  String groupOption(String name) {
    return '$name (Gruppe)';
  }

  @override
  String get turnOffComments => 'Kommentare deaktivieren';

  @override
  String get hideLikes => 'Anzahl der Likes ausblenden';

  @override
  String get onlyYouSee => 'Nur du siehst die Zahl.';

  @override
  String mediaN(int n) {
    return 'Medium $n';
  }

  @override
  String seconds(int n) {
    return '▶ $n s';
  }

  @override
  String get removeMedia => 'Entfernen';

  @override
  String get cantShare => 'Kann nicht geteilt werden';

  @override
  String get addMedia => 'Medien hinzufügen';

  @override
  String get editPost => 'Beitrag bearbeiten';

  @override
  String get save => 'Speichern';

  @override
  String get noEditPermission => 'Du darfst diesen Beitrag nicht bearbeiten.';

  @override
  String get photoToCrop => 'Zu beschneidendes Foto';

  @override
  String get stories => 'Storys';

  @override
  String get feed => 'Feed';

  @override
  String get feedHint => 'Von deinen Gruppen und Leuten, denen du folgst';

  @override
  String get feedEmpty =>
      'Dein Feed ist leer. Hier erscheinen Beiträge von Leuten und Gruppen, denen du folgst.';

  @override
  String get explore => 'Entdecken';

  @override
  String get searchHint => 'Personen oder #Hashtags suchen';

  @override
  String get clear => 'Löschen';

  @override
  String get exploreEmpty =>
      'Gerade gibt es nichts Neues. Schau später noch mal vorbei.';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get accounts => 'Konten';

  @override
  String get hashtags => 'Hashtags';

  @override
  String noTagMatch(String query) {
    return 'Keine Hashtags beginnen mit „$query“.';
  }

  @override
  String get clearSearch => 'Suche löschen';

  @override
  String postCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Beiträge',
      one: '1 Beitrag',
    );
    return '$_temp0';
  }

  @override
  String noTagPosts(String tag) {
    return 'Es gibt keine sichtbaren Beiträge mit #$tag.';
  }

  @override
  String get backToExplore => 'Zurück zu Entdecken';

  @override
  String get saved => 'Gespeichert';

  @override
  String get savedEmpty =>
      'Gespeicherte Beiträge erscheinen hier und sind nur für dich sichtbar.';

  @override
  String get post => 'Beitrag';

  @override
  String get postGone =>
      'Dieser Beitrag wurde gelöscht oder du darfst ihn nicht sehen.';

  @override
  String get backToFeed => 'Zurück zum Feed';

  @override
  String get unmute => 'Ton an';

  @override
  String get mute => 'Ton aus';

  @override
  String get addedToSaved => 'Zu Gespeichert hinzugefügt.';

  @override
  String get linkCopied => 'Beitragslink kopiert.';

  @override
  String get deletePostTitle => 'Beitrag löschen?';

  @override
  String get deletePostBody =>
      'Der Beitrag wird mit Fotos, Videos und Kommentaren endgültig gelöscht.';

  @override
  String get postDeleted => 'Beitrag gelöscht.';

  @override
  String get likesHidden => 'Nur du siehst die Anzahl der Likes.';

  @override
  String memoryOf(String title) {
    return 'Erinnerung · $title';
  }

  @override
  String get deletedAccount => 'Gelöschtes Konto';

  @override
  String get groupPost => 'Gruppenbeitrag';

  @override
  String get edited => 'bearbeitet';

  @override
  String get moreOptions => 'Weitere Optionen';

  @override
  String get copyLink => 'Link kopieren';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get like => 'Gefällt mir';

  @override
  String get commentAction => 'Kommentieren';

  @override
  String get unsave => 'Aus Gespeichert entfernen';

  @override
  String reactionLabel(String emoji, int count) {
    return '$emoji-Reaktion, $count';
  }

  @override
  String get more => 'mehr';

  @override
  String postWithCaption(String caption) {
    return 'Beitrag: $caption';
  }

  @override
  String get showMore => 'Mehr anzeigen';

  @override
  String get addStory => 'Story hinzufügen';

  @override
  String get yourStory => 'Deine Story';

  @override
  String get noStoriesLeft => 'Hier gibt es keine Storys mehr für dich.';

  @override
  String get close => 'Schließen';

  @override
  String get removeFromHighlight => 'Aus Highlight entfernen';

  @override
  String get removedFromHighlight => 'Aus Highlight entfernt.';

  @override
  String get addToHighlights => 'Zu Highlights hinzufügen';

  @override
  String get deleteStory => 'Story löschen';

  @override
  String get storyDeleted => 'Story gelöscht.';

  @override
  String get options => 'Optionen';

  @override
  String get viewers => 'Zuschauer';

  @override
  String get noViewers =>
      'Noch niemand hat sie gesehen. Zuschauer erscheinen hier, nur für dich sichtbar.';

  @override
  String viewedBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Von $count Personen gesehen',
      one: 'Von 1 Person gesehen',
    );
    return '$_temp0';
  }

  @override
  String get storyPhotoFailed =>
      'Das Foto konnte nicht vorbereitet werden. Versuche ein anderes.';

  @override
  String get storyShared =>
      'Deine Story ist geteilt. Sie ist 24 Stunden sichtbar.';

  @override
  String get newStory => 'Neue Story';

  @override
  String get addToStory => 'Zu deiner Story hinzufügen';

  @override
  String get storyPickHint =>
      'Wähle ein Foto oder ein Video bis 60 Sekunden für deine Story.';

  @override
  String get pickAnother => 'Andere wählen';

  @override
  String get newHighlight => 'Neues Highlight';

  @override
  String highlightCreated(String title) {
    return '„$title“ erstellt.';
  }

  @override
  String storyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Storys',
      one: '1 Story',
    );
    return '$_temp0';
  }

  @override
  String addedToHighlight(String title) {
    return 'Zu „$title“ hinzugefügt.';
  }

  @override
  String get highlightTitle => 'Titel des Highlights';

  @override
  String get highlightExample => 'Z. B. Camping 2026';

  @override
  String get addHighlight => 'Highlight hinzufügen';

  @override
  String get renameHighlight => 'Umbenennen';

  @override
  String get deleteHighlight => 'Highlight löschen';

  @override
  String get staysInArchive => 'Die Storys bleiben in deinem Archiv.';

  @override
  String get storyArchive => 'Story-Archiv';

  @override
  String storiesSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Storys ausgewählt',
      one: '1 Story ausgewählt',
    );
    return '$_temp0';
  }

  @override
  String get feature => 'Hervorheben';

  @override
  String get archiveEmpty =>
      'Geteilte Storys werden nach 24 Stunden hier aufbewahrt, nur für dich sichtbar.';

  @override
  String get shareStory => 'Story teilen';

  @override
  String get archiveHint =>
      'Wähle Storys, um ein Highlight zu erstellen oder zu ergänzen.';

  @override
  String storyOn(String date) {
    return 'Story, $date';
  }

  @override
  String get live => 'Online';
}
