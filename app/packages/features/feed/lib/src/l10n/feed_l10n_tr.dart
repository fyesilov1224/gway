// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'feed_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class FeedL10nTr extends FeedL10n {
  FeedL10nTr([String locale = 'tr']) : super(locale);

  @override
  String get commentsOff => 'Bu gönderide yorumlar kapalı.';

  @override
  String get commentNotAllowed =>
      'Bu paylaşıma şu anda yorum yazılamıyor. Emojiyle tepki bırakabilirsin.';

  @override
  String get blocked => 'Bu hesapla etkileşime geçemezsin.';

  @override
  String get commentRate =>
      'Kısa sürede çok fazla yorum yazdın. Biraz bekleyip tekrar dene.';

  @override
  String get muted => 'Bu grupta susturulduğun için şu anda yorum yazamazsın.';

  @override
  String get likeRate =>
      'Kısa sürede çok fazla beğeni yaptın. Biraz bekleyip tekrar dene.';

  @override
  String get replyGone => 'Yanıt verdiğin yorum artık yok.';

  @override
  String get storyRate =>
      'Bugün çok fazla hikaye paylaştın. Yarın tekrar dene.';

  @override
  String get highlightLimit => 'En fazla 100 öne çıkan oluşturabilirsin.';

  @override
  String get highlightFull => 'Bir öne çıkanda en fazla 100 hikaye olabilir.';

  @override
  String get duplicate => 'Bu işlem zaten yapılmış.';

  @override
  String get fileTooLarge =>
      'Dosya çok büyük. Fotoğraflar en fazla 10 MB, videolar 50 MB olabilir.';

  @override
  String get unsupportedMedia =>
      'Yalnızca JPEG, PNG, WebP fotoğraf ve MP4, MOV video paylaşılabilir.';

  @override
  String get commentLength => 'Yorum 1–2.200 karakter olmalı.';

  @override
  String get highlightTitleLength => 'Başlık 1–30 karakter olmalı.';

  @override
  String get pickStory => 'En az bir hikaye seç.';

  @override
  String get aspectOriginal => 'Orijinal';

  @override
  String get agoNow => 'şimdi';

  @override
  String agoMinutes(int n) {
    return '$n dk';
  }

  @override
  String agoHours(int n) {
    return '$n sa';
  }

  @override
  String agoDays(int n) {
    return '$n g';
  }

  @override
  String agoWeeks(int n) {
    return '$n hf';
  }

  @override
  String get photoLimit => 'Fotoğraflar en fazla 10 MB olabilir.';

  @override
  String get videoSizeLimit => 'Videolar en fazla 50 MB olabilir.';

  @override
  String get videoLengthLimit => 'Videolar en fazla 60 saniye olabilir.';

  @override
  String get captionLimit => 'Açıklama en fazla 2.200 karakter olabilir.';

  @override
  String get hashtagLimit => 'Bir gönderide en fazla 30 etiket kullanılabilir.';

  @override
  String get mediaCount => 'Bir gönderide 1–10 fotoğraf ya da video olabilir.';

  @override
  String get comments => 'Yorumlar';

  @override
  String get noCommentsEmojiOnly =>
      'Henüz yorum yok. Bu paylaşıma emojiyle tepki bırakabilirsin.';

  @override
  String get noCommentsFirst => 'Henüz yorum yok. İlk yorumu sen yaz.';

  @override
  String get goBack => 'Geri dön';

  @override
  String get writeComment => 'Yorum yaz';

  @override
  String replyingTo(String username) {
    return '@$username kullanıcısına yanıt veriyorsun';
  }

  @override
  String get cancelReply => 'Yanıtı iptal et';

  @override
  String get addComment => 'Yorum ekle…';

  @override
  String get share => 'Paylaş';

  @override
  String get deleteCommentTitle => 'Yorum silinsin mi?';

  @override
  String get deleteCommentBody => 'Yorum ve yanıtları kalıcı olarak silinir.';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get delete => 'Sil';

  @override
  String likeCount(int count) {
    return '$count beğenme';
  }

  @override
  String commentCount(int count) {
    return '$count yorum';
  }

  @override
  String get reply => 'Yanıtla';

  @override
  String get report => 'Şikayet et';

  @override
  String get unlike => 'Beğenmekten vazgeç';

  @override
  String get likeComment => 'Yorumu beğen';

  @override
  String get cantComment =>
      'Bu paylaşıma şu anda yorum yazamazsın. Emojiyle tepki bırakabilirsin.';

  @override
  String get tooManyMedia =>
      'Bir gönderide en fazla 10 fotoğraf ya da video olabilir.';

  @override
  String get cantOpenFile =>
      'Seçilen dosya açılamadı. Başka bir fotoğraf ya da video dene.';

  @override
  String get preparingPhotos => 'Fotoğraflar hazırlanıyor…';

  @override
  String get photosFailed =>
      'Fotoğraflar hazırlanamadı. Başka bir fotoğraf dene.';

  @override
  String uploading(int done, int total) {
    return 'Yükleniyor: $done/$total';
  }

  @override
  String get sharing => 'Paylaşılıyor…';

  @override
  String get postShared => 'Gönderin paylaşıldı.';

  @override
  String get newPost => 'Yeni gönderi';

  @override
  String get memoryNotice =>
      'Bu gönderi organizasyonun anıları arasında da görünecek. Yalnızca kendi fotoğraflarını ve izin aldığın kişileri paylaş.';

  @override
  String get pickMediaHint =>
      'Paylaşmak için 10 taneye kadar fotoğraf ya da video seç.';

  @override
  String get pickFromGallery => 'Galeriden seç';

  @override
  String get cropHint =>
      'Yakınlaştırmak için iki parmakla aç, kadrajlamak için sürükle. Oran tüm fotoğraflara uygulanır.';

  @override
  String get caption => 'Açıklama';

  @override
  String get captionHint =>
      'Bir şeyler yaz… #etiket ve @kullanıcıadı ekleyebilirsin.';

  @override
  String get postAs => 'Kim adına paylaşılsın?';

  @override
  String get myProfile => 'Kendi profilim';

  @override
  String groupOption(String name) {
    return '$name (grup)';
  }

  @override
  String get turnOffComments => 'Yorumları kapat';

  @override
  String get hideLikes => 'Beğeni sayısını gizle';

  @override
  String get onlyYouSee => 'Sayıyı yalnızca sen görürsün.';

  @override
  String mediaN(int n) {
    return '$n. medya';
  }

  @override
  String seconds(int n) {
    return '▶ $n sn';
  }

  @override
  String get removeMedia => 'Çıkar';

  @override
  String get cantShare => 'Paylaşılamaz';

  @override
  String get addMedia => 'Medya ekle';

  @override
  String get editPost => 'Gönderiyi düzenle';

  @override
  String get save => 'Kaydet';

  @override
  String get noEditPermission => 'Bu gönderiyi düzenleme yetkin yok.';

  @override
  String get photoToCrop => 'Kırpılacak fotoğraf';

  @override
  String get stories => 'Hikâyeler';

  @override
  String get feed => 'Akış';

  @override
  String get feedHint => 'Gruplarından ve takip ettiklerinden';

  @override
  String get feedEmpty =>
      'Akışın boş. Takip ettiğin kişilerin ve grupların gönderileri burada görünür.';

  @override
  String get explore => 'Keşfet';

  @override
  String get searchHint => 'Kişi ya da #etiket ara';

  @override
  String get clear => 'Temizle';

  @override
  String get exploreEmpty =>
      'Keşfedilecek yeni gönderi yok. Biraz sonra tekrar bak.';

  @override
  String get refresh => 'Yenile';

  @override
  String get accounts => 'Hesaplar';

  @override
  String get hashtags => 'Etiketler';

  @override
  String noTagMatch(String query) {
    return '\"$query\" ile başlayan bir etiket bulunamadı.';
  }

  @override
  String get clearSearch => 'Aramayı temizle';

  @override
  String postCount(int count) {
    return '$count gönderi';
  }

  @override
  String noTagPosts(String tag) {
    return '#$tag etiketiyle görebileceğin bir gönderi yok.';
  }

  @override
  String get backToExplore => 'Keşfete dön';

  @override
  String get saved => 'Kaydedilenler';

  @override
  String get savedEmpty =>
      'Kaydettiğin gönderiler burada yalnızca sana görünür.';

  @override
  String get post => 'Gönderi';

  @override
  String get postGone => 'Bu gönderi silinmiş ya da görme iznin yok.';

  @override
  String get backToFeed => 'Akışa dön';

  @override
  String get unmute => 'Sesi aç';

  @override
  String get mute => 'Sesi kapat';

  @override
  String get addedToSaved => 'Kaydedilenlere eklendi.';

  @override
  String get linkCopied => 'Gönderi bağlantısı kopyalandı.';

  @override
  String get deletePostTitle => 'Gönderi silinsin mi?';

  @override
  String get deletePostBody =>
      'Gönderi, fotoğrafları, videoları ve yorumlarıyla birlikte kalıcı olarak silinir.';

  @override
  String get postDeleted => 'Gönderi silindi.';

  @override
  String get likesHidden => 'Beğeni sayısı yalnızca sana görünür.';

  @override
  String memoryOf(String title) {
    return 'Anı · $title';
  }

  @override
  String get deletedAccount => 'Silinmiş hesap';

  @override
  String get groupPost => 'Grup gönderisi';

  @override
  String get edited => 'düzenlendi';

  @override
  String get moreOptions => 'Diğer seçenekler';

  @override
  String get copyLink => 'Bağlantıyı kopyala';

  @override
  String get edit => 'Düzenle';

  @override
  String get like => 'Beğen';

  @override
  String get commentAction => 'Yorum yap';

  @override
  String get unsave => 'Kaydedilenlerden çıkar';

  @override
  String reactionLabel(String emoji, int count) {
    return '$emoji tepkisi, $count';
  }

  @override
  String get more => 'devamı';

  @override
  String postWithCaption(String caption) {
    return 'Gönderi: $caption';
  }

  @override
  String get showMore => 'Daha fazla göster';

  @override
  String get addStory => 'Hikâye ekle';

  @override
  String get yourStory => 'Hikâyen';

  @override
  String get noStoriesLeft => 'Burada görebileceğin bir hikaye kalmadı.';

  @override
  String get close => 'Kapat';

  @override
  String get removeFromHighlight => 'Öne çıkandan çıkar';

  @override
  String get removedFromHighlight => 'Öne çıkandan çıkarıldı.';

  @override
  String get addToHighlights => 'Öne çıkanlara ekle';

  @override
  String get deleteStory => 'Hikayeyi sil';

  @override
  String get storyDeleted => 'Hikaye silindi.';

  @override
  String get options => 'Seçenekler';

  @override
  String get viewers => 'Görenler';

  @override
  String get noViewers =>
      'Henüz kimse görmedi. Görenler burada yalnızca sana görünür.';

  @override
  String viewedBy(int count) {
    return '$count kişi gördü';
  }

  @override
  String get storyPhotoFailed =>
      'Fotoğraf hazırlanamadı. Başka bir fotoğraf dene.';

  @override
  String get storyShared => 'Hikayen paylaşıldı. 24 saat görünür.';

  @override
  String get newStory => 'Yeni hikaye';

  @override
  String get addToStory => 'Hikayene ekle';

  @override
  String get storyPickHint =>
      'Hikayen için bir fotoğraf ya da 60 saniyeye kadar video seç.';

  @override
  String get pickAnother => 'Başka seç';

  @override
  String get newHighlight => 'Yeni öne çıkan';

  @override
  String highlightCreated(String title) {
    return '\"$title\" oluşturuldu.';
  }

  @override
  String storyCount(int count) {
    return '$count hikaye';
  }

  @override
  String addedToHighlight(String title) {
    return '\"$title\" öne çıkanına eklendi.';
  }

  @override
  String get highlightTitle => 'Öne çıkan başlığı';

  @override
  String get highlightExample => 'Ör. Kamp 2026';

  @override
  String get addHighlight => 'Öne çıkan ekle';

  @override
  String get renameHighlight => 'Başlığı değiştir';

  @override
  String get deleteHighlight => 'Öne çıkanı sil';

  @override
  String get staysInArchive => 'Hikayeler arşivinde kalır.';

  @override
  String get storyArchive => 'Hikaye arşivi';

  @override
  String storiesSelected(int count) {
    return '$count hikaye seçildi';
  }

  @override
  String get feature => 'Öne çıkar';

  @override
  String get archiveEmpty =>
      'Paylaştığın hikayeler 24 saat sonra burada, yalnızca sana görünür şekilde saklanır.';

  @override
  String get shareStory => 'Hikaye paylaş';

  @override
  String get archiveHint =>
      'Öne çıkan oluşturmak ya da var olana eklemek için hikayeleri seç.';

  @override
  String storyOn(String date) {
    return 'Hikaye, $date';
  }

  @override
  String get live => 'Yayında';
}
