import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'matching_l10n_ar.dart';
import 'matching_l10n_az.dart';
import 'matching_l10n_de.dart';
import 'matching_l10n_en.dart';
import 'matching_l10n_es.dart';
import 'matching_l10n_fr.dart';
import 'matching_l10n_it.dart';
import 'matching_l10n_nl.dart';
import 'matching_l10n_pt.dart';
import 'matching_l10n_ru.dart';
import 'matching_l10n_tr.dart';
import 'matching_l10n_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of MatchingL10n
/// returned by `MatchingL10n.of(context)`.
///
/// Applications need to include `MatchingL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/matching_l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: MatchingL10n.localizationsDelegates,
///   supportedLocales: MatchingL10n.supportedLocales,
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
/// be consistent with the languages listed in the MatchingL10n.supportedLocales
/// property.
abstract class MatchingL10n {
  MatchingL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static MatchingL10n of(BuildContext context) {
    return Localizations.of<MatchingL10n>(context, MatchingL10n)!;
  }

  static const LocalizationsDelegate<MatchingL10n> delegate =
      _MatchingL10nDelegate();

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
  /// **'Yalnızca JPEG, PNG ya da WebP fotoğraf yüklenebilir.'**
  String get unsupportedImage;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Arkadaş'**
  String get modeFriend;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sevgili'**
  String get modeDating;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kadın'**
  String get genderWoman;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Erkek'**
  String get genderMan;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İkili olmayan'**
  String get genderNonbinary;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Eşleşme 18 yaşından büyükler içindir.'**
  String get adultsOnly;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Arkadaş ya da Sevgili modlarından en az birini seç.'**
  String get pickMode;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sevgili modu için kimi aradığını seç.'**
  String get pickInterest;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yaş aralığı hatalı.'**
  String get ageRangeInvalid;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ortak grup: {group}'**
  String sharedGroup(String group);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ortak: {group} ve {count} grup daha'**
  String sharedGroupsMore(String group, int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Eşleşmelerim'**
  String get pkgReveal;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kiminle eşleştiğini gör: ad, fotoğraflar ve profil.'**
  String get pkgRevealText;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Eşleşme Sohbeti'**
  String get pkgChat;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Eşleştiklerine yaz. Eşleşmelerini görmeyi de içerir.'**
  String get pkgChatText;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Seni Beğenenler'**
  String get pkgAdmirers;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Seni kimlerin beğendiğini gör, beğenerek anında eşleş.'**
  String get pkgAdmirersText;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sınırsız Beğeni'**
  String get pkgUnlimited;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Günlük beğeni sınırı kalkar; geri al ve filtreler de açılır.'**
  String get pkgUnlimitedText;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Süper Beğeni'**
  String get pkgSuper;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Günde 5 süper beğeni; seni süper beğendiğin kişi destesinde ilk görür.'**
  String get pkgSuperText;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Öne Çık'**
  String get pkgBoost;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Günde bir kez 30 dakika ortak gruplarındaki destelerin en başında görün.'**
  String get pkgBoostText;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ekip Arkadaşı'**
  String get pkgTeammates;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ekip arkadaşı isteği gönder ve ekip arkadaşlarınla yazış.'**
  String get pkgTeammatesText;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hepsi Bir Arada'**
  String get pkgAll;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bütün paketler tek pakette, ayrı ayrı almaktan çok daha uygun.'**
  String get pkgAllText;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Seni süper beğendi'**
  String get superLikedYou;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Seçenekler'**
  String get options;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Profilin tamamı'**
  String get fullProfile;

  ///
  ///
  /// In tr, this message translates to:
  /// **'BEĞEN'**
  String get stampLike;

  ///
  ///
  /// In tr, this message translates to:
  /// **'GEÇ'**
  String get stampPass;

  ///
  ///
  /// In tr, this message translates to:
  /// **'SÜPER'**
  String get stampSuper;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{name}, fotoğraf {number}'**
  String photoOf(String name, int number);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hakkında'**
  String get about;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İlgi alanları'**
  String get interests;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ortak gruplarınız'**
  String get sharedGroupsTitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Eşleşme profili oluştur'**
  String get createProfileTitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Eşleşme profilim'**
  String get myProfile;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Doğum tarihin'**
  String get birthDateLabel;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Doğum tarihini, cinsiyetini ve ilini seç.'**
  String get pickBasics;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Devam etmek için 18 yaşından büyük olduğunu onayla ve açık rıza ver.'**
  String get confirmAgeConsent;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Profilin hazır. Şimdi en az {min} fotoğraf ekle.'**
  String profileReady(int min);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kaydedildi.'**
  String get saved;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Doğum tarihi seç'**
  String get pickBirthDate;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{age} yaş · kartında yalnızca yaşın görünür'**
  String ageNote(int age);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Cinsiyet'**
  String get gender;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İl'**
  String get province;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kendinden bahset'**
  String get aboutHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Meslek (isteğe bağlı)'**
  String get jobOptional;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Eğitim (isteğe bağlı)'**
  String get educationOptional;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İlgi alanların sosyal profilinden gelir.'**
  String get interestsFromProfile;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ne arıyorsun?'**
  String get lookingFor;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Birlikte etkinliğe gidecek, sohbet edecek insanlar'**
  String get friendHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Romantik bir ilişki'**
  String get datingHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kimi arıyorsun?'**
  String get whoLookingFor;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yaş aralığı: {min}–{max}'**
  String ageRange(int min, int max);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Onay'**
  String get consentTitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'18 yaşından büyüğüm.'**
  String get iam18;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Eşleşme için cinsiyetimin, aradığım kişinin, doğum tarihimin, ilimin ve fotoğraflarımın işlenmesine ve ortak gruplarımdaki eşleşmeyi açmış kişilere gösterilmesine açık rıza veriyorum. Rızamı istediğim an eşleşme verilerimi silerek geri alabilirim.'**
  String get consentText;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Profilimi oluştur'**
  String get createProfile;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraflar'**
  String get photos;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kartının görünmesi için en az {min} fotoğraf ekle. İlki kapaktır.'**
  String photosMin(int min);

  ///
  ///
  /// In tr, this message translates to:
  /// **'En fazla {max} fotoğraf. İlki kapaktır; değiştirmek için bir fotoğrafa dokun.'**
  String photosMax(int max);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf ekle'**
  String get addPhoto;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kapak'**
  String get cover;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Fotoğrafı kaldır'**
  String get removePhoto;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Profilimi duraklat'**
  String get pauseProfile;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kimse seni görmez ve yeni kart gelmez; eşleşmelerin ve sohbetlerin kalır.'**
  String get pauseHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Eşleşme verilerimi sil'**
  String get deleteData;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Profil, fotoğraflar ve beğeniler silinir; eşleşmelerin biter. Açık rızan geri alınmış olur.'**
  String get deleteDataHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Eşleşme verilerini sil'**
  String get deleteDataTitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Eşleşme profilin, fotoğrafların ve beğenilerin kalıcı olarak silinir; tüm eşleşmelerin biter. Bu geri alınamaz.'**
  String get deleteDataBody;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Eşleşme verilerin silindi.'**
  String get dataDeleted;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Eşleştiniz!'**
  String get itsAMatch;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sen ve {name} birbirinizi beğendiniz.'**
  String bothLiked(String name);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kaydırmaya devam et'**
  String get keepSwiping;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Mesaj gönder'**
  String get sendMessage;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Profili şikayet et'**
  String get reportProfile;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu fotoğrafı şikayet et'**
  String get reportPhoto;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Engelle'**
  String get block;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Birbirinizi hiçbir yerde görmezsiniz.'**
  String get blockHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get cancel;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Biriyle eşleştin!'**
  String get newMatch;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kim olduğunu görmek için dokun · {date}'**
  String tapToSee(String date);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Biriyle eşleştin! Kim olduğunu görmek için Eşleşmelerim paketini al.'**
  String get revealReason;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca arkadaş kal'**
  String get keepFriend;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca sevgili kal'**
  String get keepDating;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{name} ile sevgili eşleşmeniz ikiniz için de biter; arkadaş olarak eşleşmeniz ve sohbetiniz sürer.'**
  String keepFriendBody(String name);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{name} ile arkadaş eşleşmeniz ikiniz için de biter; sevgili olarak eşleşmeniz ve sohbetiniz sürer.'**
  String keepDatingBody(String name);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Artık yalnızca arkadaş olarak eşleşiksiniz.'**
  String get keptFriend;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Artık yalnızca sevgili olarak eşleşiksiniz.'**
  String get keptDating;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Devam et'**
  String get continueAction;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Eşleşmeyi bitir'**
  String get endMatch;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{name} ile eşleşmen biter, sohbetiniz ikiniz için de kapanır. Bu geri alınamaz.'**
  String endMatchBody(String name);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bitir'**
  String get end;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Eşleşme bitti.'**
  String get matchEnded;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Henüz eşleşmen yok. Birbirinizi beğendiğiniz kişiler burada görünür.'**
  String get noMatches;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Keşfetmeye dön'**
  String get backToDiscover;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şikayet et'**
  String get report;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Eşleşme'**
  String get matching;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Seni beğenenler'**
  String get admirers;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Paketler'**
  String get packages;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Diğer'**
  String get more;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yaş, il ve ilgi alanına göre filtrelemek Sınırsız Beğeni paketiyle açılır.'**
  String get filtersLocked;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Filtreler'**
  String get filters;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Eşleşme profilin platform ekibi tarafından kapatıldı. Ayrıntılar için Destek\'e yazabilirsin.'**
  String get suspended;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kartının görünmesi ve keşfetmeye başlaman için en az {min} fotoğraf ekle.'**
  String addPhotosToStart(int min);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Profilin duraklatıldı; kimse seni görmüyor. Eşleşmelerin ve sohbetlerin duruyor.'**
  String get paused;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bugünkü ücretsiz beğenilerin bitti. Sınırsız Beğeni ile istediğin kadar beğen.'**
  String get likesOut;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bugünkü süper beğenilerin bitti. Yarın yenilenir.'**
  String get supersOut;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bugünkü süper beğenini kullandın. Süper Beğeni paketiyle her gün 5 tane.'**
  String get superUsed;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yanlışlıkla geçtiğin kişiyi geri getirmek Sınırsız Beğeni paketiyle açılır.'**
  String get rewindLocked;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Son geçtiğin kişi {mode} destesine geri döndü.'**
  String rewoundTo(String mode);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Öne çıkınca {minutes} dakika boyunca destelerin en başında görünürsün.'**
  String boostReason(int minutes);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Öne çıkıyorsun. {minutes} dakika kaldı.'**
  String boosting(int minutes);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bugünkü öne çıkma hakkını kullandın. Yarın yenilenir.'**
  String get boostUsed;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Öne çık'**
  String get boost;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{minutes} dakika boyunca ortak gruplarındaki kişilerin destesinde en başta görünürsün. Günde bir kez kullanılır.'**
  String boostBody(int minutes);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Öne çıktın! {minutes} dakika boyunca en baştasın.'**
  String boosted(int minutes);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şimdilik gösterecek kimse kalmadı. Yeni gruplara katıldıkça ve insanlar eşleşmeyi açtıkça burası dolar.'**
  String get deckEmpty;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Filtrelerine uyan kimse kalmadı. Filtreleri genişletmeyi dene.'**
  String get deckEmptyFiltered;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yenile'**
  String get refresh;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Filtreleri temizle'**
  String get clearFilters;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sınırsız beğeni · {supers} süper beğeni hakkın var.'**
  String allowanceUnlimited(int supers);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bugünkü beğenilerin bitti; yarın yenilenir.'**
  String get allowanceOut;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bugün {likes} beğeni ve {supers} süper beğeni hakkın var.'**
  String allowance(int likes, int supers);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Geri al'**
  String get undo;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Geç'**
  String get pass;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Süper beğen'**
  String get superLike;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Beğen'**
  String get like;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ortak gruplarından yeni insanlarla tanış'**
  String get introTitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca üye olduğun ya da takip ettiğin gruplardaki, eşleşmeyi açmış kişileri görürsün.'**
  String get intro1;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kartı sağa kaydır beğen, sola kaydır geç, yukarı kaydır süper beğen.'**
  String get intro2;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İkiniz de birbirinizi beğenince eşleşirsiniz. Eşleştiğin kişiye Eşleşme Sohbeti paketiyle yazarsın.'**
  String get intro3;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Arkadaş ve Sevgili ayrı modlardır; istediğini ya da ikisini seçersin.'**
  String get intro4;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Profilin yalnızca eşleşmeyi açanlara görünür. İstediğin an duraklatır ya da tamamen silersin.'**
  String get intro5;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Eşleşme profilimi oluştur'**
  String get createMyProfile;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{package} paketini incele'**
  String seePackageOf(String package);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Tüm paketler'**
  String get allPackages;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Eşleşme paketleri'**
  String get packagesTitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Profil açmak ve kaydırmak ücretsiz. Her özellik ayrı bir pakettir; yalnızca istediğini al.'**
  String get packagesIntro;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yönetici olarak tüm paketler açık'**
  String get adminAllOpen;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{date} tarihine kadar açık'**
  String openUntil(String date);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yaş: {min} – {max}'**
  String ageFilter(int min, int max);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Tüm iller'**
  String get allProvinces;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İlgi alanı'**
  String get interest;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hepsi'**
  String get all;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Uygula'**
  String get apply;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Temizle'**
  String get clear;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şimdilik bekleyen beğeni yok. Kaydırmaya devam et; seni beğenenler burada görünür.'**
  String get noAdmirers;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kaydırmaya dön'**
  String get backToSwiping;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Beğen ve eşleş'**
  String get likeAndMatch;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Henüz bekleyen beğeni yok'**
  String get noPendingLikes;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} kişi seni beğendi'**
  String likedYouCount(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Seni Beğenenler paketiyle kim olduklarını gör, beğenerek anında eşleş.'**
  String get admirersPitch;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Paketi incele'**
  String get seePackage;
}

class _MatchingL10nDelegate extends LocalizationsDelegate<MatchingL10n> {
  const _MatchingL10nDelegate();

  @override
  Future<MatchingL10n> load(Locale locale) {
    return SynchronousFuture<MatchingL10n>(lookupMatchingL10n(locale));
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
  bool shouldReload(_MatchingL10nDelegate old) => false;
}

MatchingL10n lookupMatchingL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return MatchingL10nAr();
    case 'az':
      return MatchingL10nAz();
    case 'de':
      return MatchingL10nDe();
    case 'en':
      return MatchingL10nEn();
    case 'es':
      return MatchingL10nEs();
    case 'fr':
      return MatchingL10nFr();
    case 'it':
      return MatchingL10nIt();
    case 'nl':
      return MatchingL10nNl();
    case 'pt':
      return MatchingL10nPt();
    case 'ru':
      return MatchingL10nRu();
    case 'tr':
      return MatchingL10nTr();
    case 'uk':
      return MatchingL10nUk();
  }

  throw FlutterError(
    'MatchingL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
