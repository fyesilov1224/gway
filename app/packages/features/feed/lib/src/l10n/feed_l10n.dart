import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'feed_l10n_ar.dart';
import 'feed_l10n_az.dart';
import 'feed_l10n_de.dart';
import 'feed_l10n_en.dart';
import 'feed_l10n_es.dart';
import 'feed_l10n_fr.dart';
import 'feed_l10n_it.dart';
import 'feed_l10n_nl.dart';
import 'feed_l10n_pt.dart';
import 'feed_l10n_ru.dart';
import 'feed_l10n_tr.dart';
import 'feed_l10n_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of FeedL10n
/// returned by `FeedL10n.of(context)`.
///
/// Applications need to include `FeedL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/feed_l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: FeedL10n.localizationsDelegates,
///   supportedLocales: FeedL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the FeedL10n.supportedLocales
/// property.
abstract class FeedL10n {
  FeedL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static FeedL10n of(BuildContext context) {
    return Localizations.of<FeedL10n>(context, FeedL10n)!;
  }

  static const LocalizationsDelegate<FeedL10n> delegate = _FeedL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('az'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('nl'),
    Locale('pt'),
    Locale('ru'),
    Locale('tr'),
    Locale('uk'),
  ];

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu gönderide yorumlar kapalı.'**
  String get commentsOff;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu paylaşıma şu anda yorum yazılamıyor. Emojiyle tepki bırakabilirsin.'**
  String get commentNotAllowed;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu hesapla etkileşime geçemezsin.'**
  String get blocked;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kısa sürede çok fazla yorum yazdın. Biraz bekleyip tekrar dene.'**
  String get commentRate;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu grupta susturulduğun için şu anda yorum yazamazsın.'**
  String get muted;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kısa sürede çok fazla beğeni yaptın. Biraz bekleyip tekrar dene.'**
  String get likeRate;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yanıt verdiğin yorum artık yok.'**
  String get replyGone;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bugün çok fazla hikaye paylaştın. Yarın tekrar dene.'**
  String get storyRate;

  ///
  ///
  /// In tr, this message translates to:
  /// **'En fazla 100 öne çıkan oluşturabilirsin.'**
  String get highlightLimit;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bir öne çıkanda en fazla 100 hikaye olabilir.'**
  String get highlightFull;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem zaten yapılmış.'**
  String get duplicate;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Dosya çok büyük. Fotoğraflar en fazla 10 MB, videolar 50 MB olabilir.'**
  String get fileTooLarge;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca JPEG, PNG, WebP fotoğraf ve MP4, MOV video paylaşılabilir.'**
  String get unsupportedMedia;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yorum 1–2.200 karakter olmalı.'**
  String get commentLength;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Başlık 1–30 karakter olmalı.'**
  String get highlightTitleLength;

  ///
  ///
  /// In tr, this message translates to:
  /// **'En az bir hikaye seç.'**
  String get pickStory;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Orijinal'**
  String get aspectOriginal;

  ///
  ///
  /// In tr, this message translates to:
  /// **'şimdi'**
  String get agoNow;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{n} dk'**
  String agoMinutes(int n);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{n} sa'**
  String agoHours(int n);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{n} g'**
  String agoDays(int n);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{n} hf'**
  String agoWeeks(int n);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraflar en fazla 10 MB olabilir.'**
  String get photoLimit;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Videolar en fazla 50 MB olabilir.'**
  String get videoSizeLimit;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Videolar en fazla 60 saniye olabilir.'**
  String get videoLengthLimit;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Açıklama en fazla 2.200 karakter olabilir.'**
  String get captionLimit;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bir gönderide en fazla 30 etiket kullanılabilir.'**
  String get hashtagLimit;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bir gönderide 1–10 fotoğraf ya da video olabilir.'**
  String get mediaCount;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yorumlar'**
  String get comments;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Henüz yorum yok. Bu paylaşıma emojiyle tepki bırakabilirsin.'**
  String get noCommentsEmojiOnly;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Henüz yorum yok. İlk yorumu sen yaz.'**
  String get noCommentsFirst;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Geri dön'**
  String get goBack;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yorum yaz'**
  String get writeComment;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{username} kullanıcısına yanıt veriyorsun'**
  String replyingTo(String username);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yanıtı iptal et'**
  String get cancelReply;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yorum ekle…'**
  String get addComment;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Paylaş'**
  String get share;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yorum silinsin mi?'**
  String get deleteCommentTitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yorum ve yanıtları kalıcı olarak silinir.'**
  String get deleteCommentBody;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get cancel;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} beğenme'**
  String likeCount(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} yorum'**
  String commentCount(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yanıtla'**
  String get reply;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şikayet et'**
  String get report;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Beğenmekten vazgeç'**
  String get unlike;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yorumu beğen'**
  String get likeComment;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu paylaşıma şu anda yorum yazamazsın. Emojiyle tepki bırakabilirsin.'**
  String get cantComment;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bir gönderide en fazla 10 fotoğraf ya da video olabilir.'**
  String get tooManyMedia;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Seçilen dosya açılamadı. Başka bir fotoğraf ya da video dene.'**
  String get cantOpenFile;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraflar hazırlanıyor…'**
  String get preparingPhotos;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraflar hazırlanamadı. Başka bir fotoğraf dene.'**
  String get photosFailed;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yükleniyor: {done}/{total}'**
  String uploading(int done, int total);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Paylaşılıyor…'**
  String get sharing;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gönderin paylaşıldı.'**
  String get postShared;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yeni gönderi'**
  String get newPost;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu gönderi organizasyonun anıları arasında da görünecek. Yalnızca kendi fotoğraflarını ve izin aldığın kişileri paylaş.'**
  String get memoryNotice;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Paylaşmak için 10 taneye kadar fotoğraf ya da video seç.'**
  String get pickMediaHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Galeriden seç'**
  String get pickFromGallery;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yakınlaştırmak için iki parmakla aç, kadrajlamak için sürükle. Oran tüm fotoğraflara uygulanır.'**
  String get cropHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Açıklama'**
  String get caption;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bir şeyler yaz… #etiket ve @kullanıcıadı ekleyebilirsin.'**
  String get captionHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kim adına paylaşılsın?'**
  String get postAs;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kendi profilim'**
  String get myProfile;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{name} (grup)'**
  String groupOption(String name);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yorumları kapat'**
  String get turnOffComments;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Beğeni sayısını gizle'**
  String get hideLikes;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sayıyı yalnızca sen görürsün.'**
  String get onlyYouSee;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{n}. medya'**
  String mediaN(int n);

  ///
  ///
  /// In tr, this message translates to:
  /// **'▶ {n} sn'**
  String seconds(int n);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Çıkar'**
  String get removeMedia;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Paylaşılamaz'**
  String get cantShare;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Medya ekle'**
  String get addMedia;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gönderiyi düzenle'**
  String get editPost;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu gönderiyi düzenleme yetkin yok.'**
  String get noEditPermission;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kırpılacak fotoğraf'**
  String get photoToCrop;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hikâyeler'**
  String get stories;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Akış'**
  String get feed;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gruplarından ve takip ettiklerinden'**
  String get feedHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Akışın boş. Takip ettiğin kişilerin ve grupların gönderileri burada görünür.'**
  String get feedEmpty;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Keşfet'**
  String get explore;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kişi ya da #etiket ara'**
  String get searchHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Temizle'**
  String get clear;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Keşfedilecek yeni gönderi yok. Biraz sonra tekrar bak.'**
  String get exploreEmpty;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yenile'**
  String get refresh;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hesaplar'**
  String get accounts;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Etiketler'**
  String get hashtags;

  ///
  ///
  /// In tr, this message translates to:
  /// **'\"{query}\" ile başlayan bir etiket bulunamadı.'**
  String noTagMatch(String query);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Aramayı temizle'**
  String get clearSearch;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} gönderi'**
  String postCount(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'#{tag} etiketiyle görebileceğin bir gönderi yok.'**
  String noTagPosts(String tag);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Keşfete dön'**
  String get backToExplore;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilenler'**
  String get saved;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kaydettiğin gönderiler burada yalnızca sana görünür.'**
  String get savedEmpty;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gönderi'**
  String get post;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu gönderi silinmiş ya da görme iznin yok.'**
  String get postGone;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Akışa dön'**
  String get backToFeed;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sesi aç'**
  String get unmute;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sesi kapat'**
  String get mute;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilenlere eklendi.'**
  String get addedToSaved;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gönderi bağlantısı kopyalandı.'**
  String get linkCopied;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gönderi silinsin mi?'**
  String get deletePostTitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gönderi, fotoğrafları, videoları ve yorumlarıyla birlikte kalıcı olarak silinir.'**
  String get deletePostBody;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gönderi silindi.'**
  String get postDeleted;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Beğeni sayısı yalnızca sana görünür.'**
  String get likesHidden;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Anı · {title}'**
  String memoryOf(String title);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Silinmiş hesap'**
  String get deletedAccount;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grup gönderisi'**
  String get groupPost;

  ///
  ///
  /// In tr, this message translates to:
  /// **'düzenlendi'**
  String get edited;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Diğer seçenekler'**
  String get moreOptions;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bağlantıyı kopyala'**
  String get copyLink;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get edit;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Beğen'**
  String get like;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yorum yap'**
  String get commentAction;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilenlerden çıkar'**
  String get unsave;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{emoji} tepkisi, {count}'**
  String reactionLabel(String emoji, int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'devamı'**
  String get more;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gönderi: {caption}'**
  String postWithCaption(String caption);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Daha fazla göster'**
  String get showMore;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hikâye ekle'**
  String get addStory;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hikâyen'**
  String get yourStory;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Burada görebileceğin bir hikaye kalmadı.'**
  String get noStoriesLeft;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get close;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Öne çıkandan çıkar'**
  String get removeFromHighlight;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Öne çıkandan çıkarıldı.'**
  String get removedFromHighlight;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Öne çıkanlara ekle'**
  String get addToHighlights;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hikayeyi sil'**
  String get deleteStory;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hikaye silindi.'**
  String get storyDeleted;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Seçenekler'**
  String get options;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Görenler'**
  String get viewers;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Henüz kimse görmedi. Görenler burada yalnızca sana görünür.'**
  String get noViewers;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} kişi gördü'**
  String viewedBy(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf hazırlanamadı. Başka bir fotoğraf dene.'**
  String get storyPhotoFailed;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hikayen paylaşıldı. 24 saat görünür.'**
  String get storyShared;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yeni hikaye'**
  String get newStory;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hikayene ekle'**
  String get addToStory;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hikayen için bir fotoğraf ya da 60 saniyeye kadar video seç.'**
  String get storyPickHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Başka seç'**
  String get pickAnother;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yeni öne çıkan'**
  String get newHighlight;

  ///
  ///
  /// In tr, this message translates to:
  /// **'\"{title}\" oluşturuldu.'**
  String highlightCreated(String title);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} hikaye'**
  String storyCount(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'\"{title}\" öne çıkanına eklendi.'**
  String addedToHighlight(String title);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Öne çıkan başlığı'**
  String get highlightTitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ör. Kamp 2026'**
  String get highlightExample;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Öne çıkan ekle'**
  String get addHighlight;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Başlığı değiştir'**
  String get renameHighlight;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Öne çıkanı sil'**
  String get deleteHighlight;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hikayeler arşivinde kalır.'**
  String get staysInArchive;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hikaye arşivi'**
  String get storyArchive;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} hikaye seçildi'**
  String storiesSelected(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Öne çıkar'**
  String get feature;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Paylaştığın hikayeler 24 saat sonra burada, yalnızca sana görünür şekilde saklanır.'**
  String get archiveEmpty;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hikaye paylaş'**
  String get shareStory;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Öne çıkan oluşturmak ya da var olana eklemek için hikayeleri seç.'**
  String get archiveHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hikaye, {date}'**
  String storyOn(String date);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yayında'**
  String get live;
}

class _FeedL10nDelegate extends LocalizationsDelegate<FeedL10n> {
  const _FeedL10nDelegate();

  @override
  Future<FeedL10n> load(Locale locale) {
    return SynchronousFuture<FeedL10n>(lookupFeedL10n(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'az',
    'de',
    'en',
    'es',
    'fr',
    'it',
    'nl',
    'pt',
    'ru',
    'tr',
    'uk',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_FeedL10nDelegate old) => false;
}

FeedL10n lookupFeedL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return FeedL10nAr();
    case 'az':
      return FeedL10nAz();
    case 'de':
      return FeedL10nDe();
    case 'en':
      return FeedL10nEn();
    case 'es':
      return FeedL10nEs();
    case 'fr':
      return FeedL10nFr();
    case 'it':
      return FeedL10nIt();
    case 'nl':
      return FeedL10nNl();
    case 'pt':
      return FeedL10nPt();
    case 'ru':
      return FeedL10nRu();
    case 'tr':
      return FeedL10nTr();
    case 'uk':
      return FeedL10nUk();
  }

  throw FlutterError(
    'FeedL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
