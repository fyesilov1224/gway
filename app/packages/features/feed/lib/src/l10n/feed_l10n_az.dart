// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'feed_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Azerbaijani (`az`).
class FeedL10nAz extends FeedL10n {
  FeedL10nAz([String locale = 'az']) : super(locale);

  @override
  String get commentsOff => 'Bu paylaşımda şərhlər bağlıdır.';

  @override
  String get commentNotAllowed =>
      'Bu paylaşıma hazırda şərh yazmaq olmur. Emoji ilə reaksiya bildirə bilərsən.';

  @override
  String get blocked => 'Bu hesabla əlaqəyə girə bilməzsən.';

  @override
  String get commentRate =>
      'Qısa müddətdə çox şərh yazdın. Bir az gözlə və yenidən cəhd et.';

  @override
  String get muted =>
      'Bu qrupda səsin bağlandığı üçün hazırda şərh yaza bilməzsən.';

  @override
  String get likeRate =>
      'Qısa müddətdə çox bəyəndin. Bir az gözlə və yenidən cəhd et.';

  @override
  String get replyGone => 'Cavab verdiyin şərh artıq yoxdur.';

  @override
  String get storyRate => 'Bu gün çox hekayə paylaşdın. Sabah yenidən cəhd et.';

  @override
  String get highlightLimit => 'Ən çox 100 seçilmiş yarada bilərsən.';

  @override
  String get highlightFull => 'Bir seçilmişdə ən çox 100 hekayə ola bilər.';

  @override
  String get duplicate => 'Bu əməliyyat artıq edilib.';

  @override
  String get fileTooLarge =>
      'Fayl çox böyükdür. Şəkillər ən çox 10 MB, videolar 50 MB ola bilər.';

  @override
  String get unsupportedMedia =>
      'Yalnız JPEG, PNG, WebP şəkil və MP4, MOV video paylaşmaq olar.';

  @override
  String get commentLength => 'Şərh 1–2.200 simvol olmalıdır.';

  @override
  String get highlightTitleLength => 'Başlıq 1–30 simvol olmalıdır.';

  @override
  String get pickStory => 'Ən azı bir hekayə seç.';

  @override
  String get aspectOriginal => 'Orijinal';

  @override
  String get agoNow => 'indi';

  @override
  String agoMinutes(int n) {
    return '$n dəq';
  }

  @override
  String agoHours(int n) {
    return '$n saat';
  }

  @override
  String agoDays(int n) {
    return '$n gün';
  }

  @override
  String agoWeeks(int n) {
    return '$n həftə';
  }

  @override
  String get photoLimit => 'Şəkillər ən çox 10 MB ola bilər.';

  @override
  String get videoSizeLimit => 'Videolar ən çox 50 MB ola bilər.';

  @override
  String get videoLengthLimit => 'Videolar ən çox 60 saniyə ola bilər.';

  @override
  String get captionLimit => 'Açıqlama ən çox 2.200 simvol ola bilər.';

  @override
  String get hashtagLimit => 'Bir paylaşımda ən çox 30 etiket ola bilər.';

  @override
  String get mediaCount => 'Bir paylaşımda 1–10 şəkil və ya video ola bilər.';

  @override
  String get comments => 'Şərhlər';

  @override
  String get noCommentsEmojiOnly =>
      'Hələ şərh yoxdur. Emoji ilə reaksiya bildirə bilərsən.';

  @override
  String get noCommentsFirst => 'Hələ şərh yoxdur. İlk şərhi sən yaz.';

  @override
  String get goBack => 'Geri qayıt';

  @override
  String get writeComment => 'Şərh yaz';

  @override
  String replyingTo(String username) {
    return '$username istifadəçisinə cavab verirsən';
  }

  @override
  String get cancelReply => 'Cavabı ləğv et';

  @override
  String get addComment => 'Şərh əlavə et…';

  @override
  String get share => 'Paylaş';

  @override
  String get deleteCommentTitle => 'Şərh silinsin?';

  @override
  String get deleteCommentBody => 'Şərh və cavabları həmişəlik silinir.';

  @override
  String get cancel => 'İmtina et';

  @override
  String get delete => 'Sil';

  @override
  String likeCount(int count) {
    return '$count bəyənmə';
  }

  @override
  String commentCount(int count) {
    return '$count şərh';
  }

  @override
  String get reply => 'Cavab ver';

  @override
  String get report => 'Şikayət et';

  @override
  String get unlike => 'Bəyənməni geri al';

  @override
  String get likeComment => 'Şərhi bəyən';

  @override
  String get cantComment =>
      'Bu paylaşıma hazırda şərh yaza bilməzsən. Emoji ilə reaksiya bildirə bilərsən.';

  @override
  String get tooManyMedia =>
      'Bir paylaşımda ən çox 10 şəkil və ya video ola bilər.';

  @override
  String get cantOpenFile =>
      'Seçilən fayl açılmadı. Başqa şəkil və ya video yoxla.';

  @override
  String get preparingPhotos => 'Şəkillər hazırlanır…';

  @override
  String get photosFailed => 'Şəkillər hazırlanmadı. Başqa şəkil yoxla.';

  @override
  String uploading(int done, int total) {
    return 'Yüklənir: $done/$total';
  }

  @override
  String get sharing => 'Paylaşılır…';

  @override
  String get postShared => 'Paylaşımın edildi.';

  @override
  String get newPost => 'Yeni paylaşım';

  @override
  String get memoryNotice =>
      'Bu paylaşım tədbirin xatirələri arasında da görünəcək. Yalnız öz şəkillərini və icazə aldığın insanları paylaş.';

  @override
  String get pickMediaHint =>
      'Paylaşmaq üçün 10-a qədər şəkil və ya video seç.';

  @override
  String get pickFromGallery => 'Qalereyadan seç';

  @override
  String get cropHint =>
      'Yaxınlaşdırmaq üçün iki barmaqla aç, kadrlamaq üçün sürüşdür. Nisbət bütün şəkillərə tətbiq olunur.';

  @override
  String get caption => 'Açıqlama';

  @override
  String get captionHint =>
      'Nəsə yaz… #etiket və @istifadəçiadı əlavə edə bilərsən.';

  @override
  String get postAs => 'Kimin adından paylaşılsın?';

  @override
  String get myProfile => 'Öz profilim';

  @override
  String groupOption(String name) {
    return '$name (qrup)';
  }

  @override
  String get turnOffComments => 'Şərhləri bağla';

  @override
  String get hideLikes => 'Bəyənmə sayını gizlət';

  @override
  String get onlyYouSee => 'Sayı yalnız sənə görünür.';

  @override
  String mediaN(int n) {
    return '$n. media';
  }

  @override
  String seconds(int n) {
    return '▶ $n san';
  }

  @override
  String get removeMedia => 'Çıxar';

  @override
  String get cantShare => 'Paylaşmaq olmaz';

  @override
  String get addMedia => 'Media əlavə et';

  @override
  String get editPost => 'Paylaşımı redaktə et';

  @override
  String get save => 'Yadda saxla';

  @override
  String get noEditPermission => 'Bu paylaşımı redaktə etmək icazən yoxdur.';

  @override
  String get photoToCrop => 'Kəsiləcək şəkil';

  @override
  String get stories => 'Hekayələr';

  @override
  String get feed => 'Lent';

  @override
  String get feedHint => 'Qruplarından və izlədiklərindən';

  @override
  String get feedEmpty =>
      'Lentin boşdur. İzlədiyin insanların və qrupların paylaşımları burada görünür.';

  @override
  String get explore => 'Kəşf et';

  @override
  String get searchHint => 'İnsan və ya #etiket axtar';

  @override
  String get clear => 'Təmizlə';

  @override
  String get exploreEmpty =>
      'Kəşf ediləcək yeni paylaşım yoxdur. Bir az sonra yenidən bax.';

  @override
  String get refresh => 'Yenilə';

  @override
  String get accounts => 'Hesablar';

  @override
  String get hashtags => 'Etiketlər';

  @override
  String noTagMatch(String query) {
    return '\"$query\" ilə başlayan etiket tapılmadı.';
  }

  @override
  String get clearSearch => 'Axtarışı təmizlə';

  @override
  String postCount(int count) {
    return '$count paylaşım';
  }

  @override
  String noTagPosts(String tag) {
    return '#$tag etiketi ilə görə biləcəyin paylaşım yoxdur.';
  }

  @override
  String get backToExplore => 'Kəşfə qayıt';

  @override
  String get saved => 'Saxlanılanlar';

  @override
  String get savedEmpty => 'Saxladığın paylaşımlar burada yalnız sənə görünür.';

  @override
  String get post => 'Paylaşım';

  @override
  String get postGone => 'Bu paylaşım silinib və ya görmək icazən yoxdur.';

  @override
  String get backToFeed => 'Lentə qayıt';

  @override
  String get unmute => 'Səsi aç';

  @override
  String get mute => 'Səsi bağla';

  @override
  String get addedToSaved => 'Saxlanılanlara əlavə edildi.';

  @override
  String get linkCopied => 'Paylaşım keçidi kopyalandı.';

  @override
  String get deletePostTitle => 'Paylaşım silinsin?';

  @override
  String get deletePostBody =>
      'Paylaşım şəkilləri, videoları və şərhləri ilə birlikdə həmişəlik silinir.';

  @override
  String get postDeleted => 'Paylaşım silindi.';

  @override
  String get likesHidden => 'Bəyənmə sayını yalnız sən görürsən.';

  @override
  String memoryOf(String title) {
    return 'Xatirə · $title';
  }

  @override
  String get deletedAccount => 'Silinmiş hesab';

  @override
  String get groupPost => 'Qrup paylaşımı';

  @override
  String get edited => 'redaktə edildi';

  @override
  String get moreOptions => 'Digər seçimlər';

  @override
  String get copyLink => 'Keçidi kopyala';

  @override
  String get edit => 'Redaktə et';

  @override
  String get like => 'Bəyən';

  @override
  String get commentAction => 'Şərh yaz';

  @override
  String get unsave => 'Saxlanılanlardan çıxar';

  @override
  String reactionLabel(String emoji, int count) {
    return '$emoji reaksiyası, $count';
  }

  @override
  String get more => 'davamı';

  @override
  String postWithCaption(String caption) {
    return 'Paylaşım: $caption';
  }

  @override
  String get showMore => 'Daha çox göstər';

  @override
  String get addStory => 'Hekayə əlavə et';

  @override
  String get yourStory => 'Hekayən';

  @override
  String get noStoriesLeft => 'Burada görə biləcəyin hekayə qalmayıb.';

  @override
  String get close => 'Bağla';

  @override
  String get removeFromHighlight => 'Seçilmişdən çıxar';

  @override
  String get removedFromHighlight => 'Seçilmişdən çıxarıldı.';

  @override
  String get addToHighlights => 'Seçilmişlərə əlavə et';

  @override
  String get deleteStory => 'Hekayəni sil';

  @override
  String get storyDeleted => 'Hekayə silindi.';

  @override
  String get options => 'Seçimlər';

  @override
  String get viewers => 'Baxanlar';

  @override
  String get noViewers =>
      'Hələ heç kim baxmayıb. Baxanlar burada yalnız sənə görünür.';

  @override
  String viewedBy(int count) {
    return '$count nəfər baxdı';
  }

  @override
  String get storyPhotoFailed => 'Şəkil hazırlanmadı. Başqa şəkil yoxla.';

  @override
  String get storyShared => 'Hekayən paylaşıldı. 24 saat görünür.';

  @override
  String get newStory => 'Yeni hekayə';

  @override
  String get addToStory => 'Hekayənə əlavə et';

  @override
  String get storyPickHint =>
      'Hekayən üçün şəkil və ya 60 saniyəyə qədər video seç.';

  @override
  String get pickAnother => 'Başqa seç';

  @override
  String get newHighlight => 'Yeni seçilmiş';

  @override
  String highlightCreated(String title) {
    return '\"$title\" yaradıldı.';
  }

  @override
  String storyCount(int count) {
    return '$count hekayə';
  }

  @override
  String addedToHighlight(String title) {
    return '\"$title\" seçilmişinə əlavə edildi.';
  }

  @override
  String get highlightTitle => 'Seçilmiş başlığı';

  @override
  String get highlightExample => 'Məs. Düşərgə 2026';

  @override
  String get addHighlight => 'Seçilmiş əlavə et';

  @override
  String get renameHighlight => 'Başlığı dəyiş';

  @override
  String get deleteHighlight => 'Seçilmişi sil';

  @override
  String get staysInArchive => 'Hekayələr arxivində qalır.';

  @override
  String get storyArchive => 'Hekayə arxivi';

  @override
  String storiesSelected(int count) {
    return '$count hekayə seçildi';
  }

  @override
  String get feature => 'Seç';

  @override
  String get archiveEmpty =>
      'Paylaşdığın hekayələr 24 saatdan sonra burada, yalnız sənə görünən şəkildə saxlanılır.';

  @override
  String get shareStory => 'Hekayə paylaş';

  @override
  String get archiveHint =>
      'Seçilmiş yaratmaq və ya mövcuda əlavə etmək üçün hekayələri seç.';

  @override
  String storyOn(String date) {
    return 'Hekayə, $date';
  }

  @override
  String get live => 'Yayımdadır';
}
