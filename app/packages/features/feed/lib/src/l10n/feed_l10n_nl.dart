// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'feed_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class FeedL10nNl extends FeedL10n {
  FeedL10nNl([String locale = 'nl']) : super(locale);

  @override
  String get commentsOff => 'Reacties staan uit voor dit bericht.';

  @override
  String get commentNotAllowed =>
      'Je kunt nu niet op dit bericht reageren. Je kunt wel een emoji achterlaten.';

  @override
  String get blocked => 'Je kunt geen interactie hebben met dit account.';

  @override
  String get commentRate =>
      'Je hebt in korte tijd veel gereageerd. Wacht even en probeer het opnieuw.';

  @override
  String get muted => 'Je bent gedempt in deze groep en kunt nu niet reageren.';

  @override
  String get likeRate =>
      'Je hebt in korte tijd veel geliket. Wacht even en probeer het opnieuw.';

  @override
  String get replyGone => 'De reactie waarop je antwoordt bestaat niet meer.';

  @override
  String get storyRate =>
      'Je hebt vandaag veel verhalen gedeeld. Probeer het morgen opnieuw.';

  @override
  String get highlightLimit => 'Je kunt maximaal 100 hoogtepunten maken.';

  @override
  String get highlightFull =>
      'Een hoogtepunt kan maximaal 100 verhalen bevatten.';

  @override
  String get duplicate => 'Dit is al gedaan.';

  @override
  String get fileTooLarge =>
      'Het bestand is te groot. Foto\'s mogen maximaal 10 MB zijn, video\'s 50 MB.';

  @override
  String get unsupportedMedia =>
      'Alleen JPEG-, PNG-, WebP-foto\'s en MP4-, MOV-video\'s kunnen worden gedeeld.';

  @override
  String get commentLength => 'Een reactie moet 1–2.200 tekens hebben.';

  @override
  String get highlightTitleLength => 'De titel moet 1–30 tekens hebben.';

  @override
  String get pickStory => 'Kies minstens één verhaal.';

  @override
  String get aspectOriginal => 'Origineel';

  @override
  String get agoNow => 'nu';

  @override
  String agoMinutes(int n) {
    return '$n min';
  }

  @override
  String agoHours(int n) {
    return '$n u';
  }

  @override
  String agoDays(int n) {
    return '$n d';
  }

  @override
  String agoWeeks(int n) {
    return '$n w';
  }

  @override
  String get photoLimit => 'Foto\'s mogen maximaal 10 MB zijn.';

  @override
  String get videoSizeLimit => 'Video\'s mogen maximaal 50 MB zijn.';

  @override
  String get videoLengthLimit => 'Video\'s mogen maximaal 60 seconden duren.';

  @override
  String get captionLimit => 'Het bijschrift mag maximaal 2.200 tekens hebben.';

  @override
  String get hashtagLimit => 'Een bericht mag maximaal 30 hashtags hebben.';

  @override
  String get mediaCount => 'Een bericht kan 1–10 foto\'s of video\'s bevatten.';

  @override
  String get comments => 'Reacties';

  @override
  String get noCommentsEmojiOnly =>
      'Nog geen reacties. Je kunt met een emoji reageren.';

  @override
  String get noCommentsFirst => 'Nog geen reacties. Schrijf de eerste.';

  @override
  String get goBack => 'Terug';

  @override
  String get writeComment => 'Reactie schrijven';

  @override
  String replyingTo(String username) {
    return 'Antwoord aan @$username';
  }

  @override
  String get cancelReply => 'Antwoord annuleren';

  @override
  String get addComment => 'Reactie toevoegen…';

  @override
  String get share => 'Delen';

  @override
  String get deleteCommentTitle => 'Reactie verwijderen?';

  @override
  String get deleteCommentBody =>
      'De reactie en de antwoorden worden definitief verwijderd.';

  @override
  String get cancel => 'Annuleren';

  @override
  String get delete => 'Verwijderen';

  @override
  String likeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count likes',
      one: '1 like',
    );
    return '$_temp0';
  }

  @override
  String commentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reacties',
      one: '1 reactie',
    );
    return '$_temp0';
  }

  @override
  String get reply => 'Beantwoorden';

  @override
  String get report => 'Melden';

  @override
  String get unlike => 'Niet meer leuk';

  @override
  String get likeComment => 'Reactie leuk vinden';

  @override
  String get cantComment =>
      'Je kunt nu niet op dit bericht reageren. Je kunt wel een emoji achterlaten.';

  @override
  String get tooManyMedia =>
      'Een bericht kan maximaal 10 foto\'s of video\'s bevatten.';

  @override
  String get cantOpenFile =>
      'Het gekozen bestand kon niet worden geopend. Probeer een andere foto of video.';

  @override
  String get preparingPhotos => 'Foto\'s worden voorbereid…';

  @override
  String get photosFailed =>
      'De foto\'s konden niet worden voorbereid. Probeer een andere foto.';

  @override
  String uploading(int done, int total) {
    return 'Uploaden: $done/$total';
  }

  @override
  String get sharing => 'Delen…';

  @override
  String get postShared => 'Je bericht is gedeeld.';

  @override
  String get newPost => 'Nieuw bericht';

  @override
  String get memoryNotice =>
      'Dit bericht verschijnt ook bij de herinneringen van het evenement. Deel alleen je eigen foto\'s en mensen die toestemming gaven.';

  @override
  String get pickMediaHint => 'Kies tot 10 foto\'s of video\'s om te delen.';

  @override
  String get pickFromGallery => 'Kiezen uit galerij';

  @override
  String get cropHint =>
      'Knijp om te zoomen en sleep om bij te snijden. De verhouding geldt voor alle foto\'s.';

  @override
  String get caption => 'Bijschrift';

  @override
  String get captionHint =>
      'Schrijf iets… Je kunt #hashtags en @gebruikersnamen toevoegen.';

  @override
  String get postAs => 'Plaatsen als';

  @override
  String get myProfile => 'Mijn profiel';

  @override
  String groupOption(String name) {
    return '$name (groep)';
  }

  @override
  String get turnOffComments => 'Reacties uitzetten';

  @override
  String get hideLikes => 'Aantal likes verbergen';

  @override
  String get onlyYouSee => 'Alleen jij ziet het aantal.';

  @override
  String mediaN(int n) {
    return 'Media $n';
  }

  @override
  String seconds(int n) {
    return '▶ $n s';
  }

  @override
  String get removeMedia => 'Verwijderen';

  @override
  String get cantShare => 'Kan niet worden gedeeld';

  @override
  String get addMedia => 'Media toevoegen';

  @override
  String get editPost => 'Bericht bewerken';

  @override
  String get save => 'Opslaan';

  @override
  String get noEditPermission => 'Je mag dit bericht niet bewerken.';

  @override
  String get photoToCrop => 'Foto om bij te snijden';

  @override
  String get stories => 'Verhalen';

  @override
  String get feed => 'Feed';

  @override
  String get feedHint => 'Van je groepen en mensen die je volgt';

  @override
  String get feedEmpty =>
      'Je feed is leeg. Berichten van mensen en groepen die je volgt verschijnen hier.';

  @override
  String get explore => 'Ontdekken';

  @override
  String get searchHint => 'Zoek mensen of #hashtags';

  @override
  String get clear => 'Wissen';

  @override
  String get exploreEmpty => 'Niets nieuws te ontdekken. Kijk later nog eens.';

  @override
  String get refresh => 'Vernieuwen';

  @override
  String get accounts => 'Accounts';

  @override
  String get hashtags => 'Hashtags';

  @override
  String noTagMatch(String query) {
    return 'Geen hashtags beginnen met ‘$query’.';
  }

  @override
  String get clearSearch => 'Zoekopdracht wissen';

  @override
  String postCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count berichten',
      one: '1 bericht',
    );
    return '$_temp0';
  }

  @override
  String noTagPosts(String tag) {
    return 'Er zijn geen zichtbare berichten met #$tag.';
  }

  @override
  String get backToExplore => 'Terug naar Ontdekken';

  @override
  String get saved => 'Opgeslagen';

  @override
  String get savedEmpty =>
      'Opgeslagen berichten verschijnen hier en zijn alleen voor jou zichtbaar.';

  @override
  String get post => 'Bericht';

  @override
  String get postGone => 'Dit bericht is verwijderd of je mag het niet zien.';

  @override
  String get backToFeed => 'Terug naar feed';

  @override
  String get unmute => 'Geluid aan';

  @override
  String get mute => 'Geluid uit';

  @override
  String get addedToSaved => 'Toegevoegd aan opgeslagen.';

  @override
  String get linkCopied => 'Berichtlink gekopieerd.';

  @override
  String get deletePostTitle => 'Bericht verwijderen?';

  @override
  String get deletePostBody =>
      'Het bericht wordt definitief verwijderd, samen met foto\'s, video\'s en reacties.';

  @override
  String get postDeleted => 'Bericht verwijderd.';

  @override
  String get likesHidden => 'Alleen jij ziet het aantal likes.';

  @override
  String memoryOf(String title) {
    return 'Herinnering · $title';
  }

  @override
  String get deletedAccount => 'Verwijderd account';

  @override
  String get groupPost => 'Groepsbericht';

  @override
  String get edited => 'bewerkt';

  @override
  String get moreOptions => 'Meer opties';

  @override
  String get copyLink => 'Link kopiëren';

  @override
  String get edit => 'Bewerken';

  @override
  String get like => 'Vind ik leuk';

  @override
  String get commentAction => 'Reageren';

  @override
  String get unsave => 'Uit opgeslagen verwijderen';

  @override
  String reactionLabel(String emoji, int count) {
    return '$emoji-reactie, $count';
  }

  @override
  String get more => 'meer';

  @override
  String postWithCaption(String caption) {
    return 'Bericht: $caption';
  }

  @override
  String get showMore => 'Meer tonen';

  @override
  String get addStory => 'Verhaal toevoegen';

  @override
  String get yourStory => 'Jouw verhaal';

  @override
  String get noStoriesLeft => 'Er zijn hier geen verhalen meer voor je.';

  @override
  String get close => 'Sluiten';

  @override
  String get removeFromHighlight => 'Uit hoogtepunt verwijderen';

  @override
  String get removedFromHighlight => 'Uit hoogtepunt verwijderd.';

  @override
  String get addToHighlights => 'Toevoegen aan hoogtepunten';

  @override
  String get deleteStory => 'Verhaal verwijderen';

  @override
  String get storyDeleted => 'Verhaal verwijderd.';

  @override
  String get options => 'Opties';

  @override
  String get viewers => 'Kijkers';

  @override
  String get noViewers =>
      'Nog niemand heeft het gezien. Kijkers verschijnen hier, alleen voor jou zichtbaar.';

  @override
  String viewedBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Door $count mensen gezien',
      one: 'Door 1 persoon gezien',
    );
    return '$_temp0';
  }

  @override
  String get storyPhotoFailed =>
      'De foto kon niet worden voorbereid. Probeer een andere.';

  @override
  String get storyShared => 'Je verhaal is gedeeld. Het is 24 uur zichtbaar.';

  @override
  String get newStory => 'Nieuw verhaal';

  @override
  String get addToStory => 'Toevoegen aan je verhaal';

  @override
  String get storyPickHint =>
      'Kies een foto of een video tot 60 seconden voor je verhaal.';

  @override
  String get pickAnother => 'Andere kiezen';

  @override
  String get newHighlight => 'Nieuw hoogtepunt';

  @override
  String highlightCreated(String title) {
    return '‘$title’ gemaakt.';
  }

  @override
  String storyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count verhalen',
      one: '1 verhaal',
    );
    return '$_temp0';
  }

  @override
  String addedToHighlight(String title) {
    return 'Toegevoegd aan ‘$title’.';
  }

  @override
  String get highlightTitle => 'Titel van hoogtepunt';

  @override
  String get highlightExample => 'Bijv. Kamperen 2026';

  @override
  String get addHighlight => 'Hoogtepunt toevoegen';

  @override
  String get renameHighlight => 'Naam wijzigen';

  @override
  String get deleteHighlight => 'Hoogtepunt verwijderen';

  @override
  String get staysInArchive => 'De verhalen blijven in je archief.';

  @override
  String get storyArchive => 'Verhalenarchief';

  @override
  String storiesSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count verhalen geselecteerd',
      one: '1 verhaal geselecteerd',
    );
    return '$_temp0';
  }

  @override
  String get feature => 'Uitlichten';

  @override
  String get archiveEmpty =>
      'Gedeelde verhalen worden na 24 uur hier bewaard, alleen voor jou zichtbaar.';

  @override
  String get shareStory => 'Verhaal delen';

  @override
  String get archiveHint =>
      'Selecteer verhalen om een hoogtepunt te maken of aan te vullen.';

  @override
  String storyOn(String date) {
    return 'Verhaal, $date';
  }

  @override
  String get live => 'Online';
}
