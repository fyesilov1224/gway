import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'profile_l10n_ar.dart';
import 'profile_l10n_az.dart';
import 'profile_l10n_de.dart';
import 'profile_l10n_en.dart';
import 'profile_l10n_es.dart';
import 'profile_l10n_fr.dart';
import 'profile_l10n_it.dart';
import 'profile_l10n_nl.dart';
import 'profile_l10n_pt.dart';
import 'profile_l10n_ru.dart';
import 'profile_l10n_tr.dart';
import 'profile_l10n_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of ProfileL10n
/// returned by `ProfileL10n.of(context)`.
///
/// Applications need to include `ProfileL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/profile_l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: ProfileL10n.localizationsDelegates,
///   supportedLocales: ProfileL10n.supportedLocales,
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
/// be consistent with the languages listed in the ProfileL10n.supportedLocales
/// property.
abstract class ProfileL10n {
  ProfileL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static ProfileL10n of(BuildContext context) {
    return Localizations.of<ProfileL10n>(context, ProfileL10n)!;
  }

  static const LocalizationsDelegate<ProfileL10n> delegate =
      _ProfileL10nDelegate();

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
  /// **'Bu dosya türü desteklenmiyor. JPEG, PNG veya WebP seç.'**
  String get unsupportedImage;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu kullanıcı adı alınmış. Başka bir tane dene.'**
  String get usernameTaken;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Girdiğin bilgileri kontrol et.'**
  String get checkInput;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu kullanıcı adı kullanılamaz. Başka bir tane dene.'**
  String get usernameReserved;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı adını 30 günde yalnızca bir kez değiştirebilirsin.'**
  String get usernameCooldown;

  ///
  ///
  /// In tr, this message translates to:
  /// **'En fazla 10 ilgi alanı seçebilirsin.'**
  String get maxInterests10;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç'**
  String get levelBeginner;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yeni başlıyorum'**
  String get levelBeginnerHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Orta'**
  String get levelIntermediate;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Düzenli yapıyorum'**
  String get levelIntermediateHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İleri'**
  String get levelAdvanced;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Deneyimliyim'**
  String get levelAdvancedHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hafta içi sabah'**
  String get slotWeekdayMorning;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hafta içi öğle'**
  String get slotWeekdayNoon;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hafta içi akşam'**
  String get slotWeekdayEvening;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hafta sonu sabah'**
  String get slotWeekendMorning;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hafta sonu öğleden sonra'**
  String get slotWeekendAfternoon;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hafta sonu akşam'**
  String get slotWeekendEvening;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sabah'**
  String get partMorning;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Öğle'**
  String get partNoon;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Akşam'**
  String get partEvening;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Eğlenmek'**
  String get goalFun;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Formda kalmak'**
  String get goalFitness;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yarışmaya hazırlanmak'**
  String get goalCompetition;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yeni şeyler öğrenmek'**
  String get goalLearning;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Deneyimimi paylaşmak'**
  String get goalMentoring;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yeni insanlarla tanışmak'**
  String get goalSocial;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ayda birkaç kez'**
  String get freqMonthly;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Haftada bir'**
  String get freqWeekly;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Haftada 2–3'**
  String get freqFewWeekly;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Neredeyse her gün'**
  String get freqDaily;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Birebir'**
  String get sizePair;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Küçük grup (3–6)'**
  String get sizeSmall;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kalabalık grup'**
  String get sizeLarge;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ekip arıyor'**
  String get looking;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ekip arıyor · {level} seviye'**
  String lookingWithLevel(String level);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Aynı aktivite: {list}'**
  String reasonActivities(String list);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ortak ilgi: {list}'**
  String reasonInterests(String list);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Aynı ildesiniz'**
  String get reasonProvince;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ortak grup: {group}'**
  String reasonGroup(String group);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} ortak grup'**
  String reasonGroups(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Aynı seviye: {level}'**
  String reasonLevel(String level);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Uygun zaman: {list}'**
  String reasonTimes(String list);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ortak hedef: {list}'**
  String reasonGoals(String list);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Aynı sıklıkta buluşmak istiyorsunuz'**
  String get reasonFrequency;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Aracı var'**
  String get hasVehicle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kendi ekipmanı var'**
  String get hasEquipment;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bir kullanıcı adı seç.'**
  String get usernameRequired;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı adı en az {min} karakter olmalı.'**
  String usernameMin(int min);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı adı en fazla {max} karakter olabilir.'**
  String usernameMax(int max);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca a-z, 0-9, alt çizgi (_) ve nokta (.) kullanabilirsin.'**
  String get usernameChars;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı adı nokta ile başlayamaz veya bitemez.'**
  String get usernameDots;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Art arda iki nokta kullanılamaz.'**
  String get usernameDoubleDot;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Adını gir.'**
  String get nameRequired;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ad en fazla {max} karakter olabilir.'**
  String nameMax(int max);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Profili düzenle'**
  String get editProfile;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Profil bilgileri'**
  String get profileInfo;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu bilgiler profilinde herkese görünür.'**
  String get profileInfoHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Adın'**
  String get yourName;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı adını 30 günde bir değiştirebilirsin.'**
  String get usernameEvery30;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{date} tarihinden sonra değiştirebilirsin.'**
  String usernameLockedUntil(String date);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hakkında'**
  String get about;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kendinden, sevdiğin aktivitelerden bahset.'**
  String get aboutHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İlgi alanları'**
  String get interests;

  ///
  ///
  /// In tr, this message translates to:
  /// **'En fazla {max} tane seçebilirsin.'**
  String interestsMax(int max);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get cancel;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Değişiklikleri kaydet'**
  String get saveChanges;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kaldır'**
  String get remove;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kapak fotoğrafını kaldır'**
  String get removeCover;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kapak ekle'**
  String get addCover;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kapağı değiştir'**
  String get changeCover;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Profil fotoğrafını değiştir'**
  String get changeAvatar;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Profil ve kapak fotoğrafı'**
  String get photos;

  ///
  ///
  /// In tr, this message translates to:
  /// **'JPEG, PNG veya WebP · en fazla 5 MB'**
  String get photosHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Profil fotoğrafı ekle'**
  String get addAvatar;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Profil fotoğrafını kaldır'**
  String get removeAvatar;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Takipçiler'**
  String get followers;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Takip edilenler'**
  String get following;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu hesap gizli. Listelerini görmek için hesabı takip etmelisin.'**
  String get privateLists;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Profile dön'**
  String get backToProfile;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Henüz takipçi yok.'**
  String get noFollowers;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Henüz kimse takip edilmiyor.'**
  String get noFollowing;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yenile'**
  String get refresh;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Takipçiyi çıkar'**
  String get removeFollower;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{username} takipçilerinden çıkarılsın mı? Bu kişiye bildirilmez.'**
  String removeFollowerBody(String username);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Çıkar'**
  String get removeAction;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Arkadaşsınız'**
  String get friends;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Takip istekleri'**
  String get followRequests;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bekleyen takip isteğin yok. Gizli hesaplar istekleri burada onaylar.'**
  String get noFollowRequests;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Onayla'**
  String get approve;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Engellenen hesaplar'**
  String get blockedAccounts;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Engellediğin bir hesap yok. Bir profilin menüsünden engelleyebilirsin.'**
  String get noBlocked;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Engeli kaldır'**
  String get unblock;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Seni tanıyalım'**
  String get onboardWho;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Profilinde görünecek adını ve kullanıcı adını seç.'**
  String get onboardWhoHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Profil fotoğrafı'**
  String get onboardPhoto;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grupların seni tanısın. İstersen sonra da ekleyebilirsin.'**
  String get onboardPhotoHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İlgi alanların'**
  String get onboardInterests;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sana uygun grupları önerebilmemiz için en fazla {max} tane seç.'**
  String onboardInterestsHint(int max);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Geri'**
  String get back;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Adım {step} / {total}'**
  String stepOf(int step, int total);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yap'**
  String get signOut;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şimdilik atla'**
  String get skipForNow;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Devam et'**
  String get continueAction;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bitir'**
  String get finish;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Küçük harf, rakam, _ ve . kullanabilirsin.'**
  String get usernameHelper;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Profil fotoğrafı önizlemesi'**
  String get avatarPreview;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf seç'**
  String get choosePhoto;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Başka fotoğraf seç'**
  String get chooseAnotherPhoto;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get profile;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settings;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu profil bulunamadı ya da artık görünür değil.'**
  String get profileNotFound;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Profilime dön'**
  String get backToMyProfile;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu hesap {date} tarihine kadar askıya alındı.'**
  String suspendedUntil(String date);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Seni takip ediyor'**
  String get followsYou;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ekip arkadaşın'**
  String get yourTeammate;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Katılım: {date}'**
  String joined(String date);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} takip isteği onay bekliyor.'**
  String followRequestsPending(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'İncele'**
  String get review;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} ekip arkadaşlığı isteği seni bekliyor.'**
  String teammateRequestsPending(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu hesabı engelledin'**
  String get youBlocked;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Engeli kaldırırsan birbirinizin paylaşımlarını yeniden görebilirsiniz.'**
  String get youBlockedHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu hesap gizli'**
  String get privateAccount;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraflarını, videolarını ve hikayelerini görmek için bu hesabı takip et.'**
  String get privateAccountHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İlgi alanlarını ekle, sana uygun grupları ve ekip arkadaşlarını bulalım.'**
  String get addInterestsNudge;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ekle'**
  String get add;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{username} engellensin mi?'**
  String blockTitle(String username);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Profilini, gönderilerini ve hikayelerini göremez, seni bulamaz ve sana yazamaz. Takipleşmeniz sona erer. Engellediğin bildirilmez.'**
  String get blockBody;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Engelle'**
  String get block;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ekip arkadaşı ol'**
  String get becomeTeammates;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{name} ile artık ekip arkadaşısınız.'**
  String nowTeammates(String name);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ekip arkadaşlığı isteğini kabul et'**
  String get acceptTeammate;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İstek geri çekildi.'**
  String get requestWithdrawn;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ekip arkadaşlığı isteğini geri çek'**
  String get withdrawTeammate;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ekip arkadaşlığı bitti.'**
  String get teammateEnded;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ekip arkadaşlığını bitir'**
  String get endTeammate;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Diğer seçenekler'**
  String get moreOptions;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Profil bağlantısı kopyalandı.'**
  String get linkCopied;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Profil bağlantısını kopyala'**
  String get copyLink;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Takipçilerinden çıkarıldı.'**
  String get removedFromFollowers;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Takipçilerimden çıkar'**
  String get removeFromFollowers;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şikayet et'**
  String get report;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Engel kaldırıldı.'**
  String get unblocked;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gönderi'**
  String get statPosts;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Takipçi'**
  String get statFollowers;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Takip'**
  String get statFollowing;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{username} için gönderdiğin takip isteğini geri almak istiyor musun?'**
  String withdrawFollowBody(String username);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{username} takibini bırakmak istiyor musun?'**
  String unfollowBody(String username);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{username} takibini bırakmak istiyor musun? Hesap gizli olduğu için gönderilerini görmek için yeniden istek göndermen gerekir.'**
  String unfollowPrivateBody(String username);

  ///
  ///
  /// In tr, this message translates to:
  /// **'İsteği geri al'**
  String get withdrawRequest;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Takibi bırak'**
  String get unfollow;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Geri takip et'**
  String get followBack;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Takip et'**
  String get follow;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İstek gönderildi'**
  String get requestSent;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Takiptesin'**
  String get followingState;

  ///
  ///
  /// In tr, this message translates to:
  /// **'\"{query}\" ile eşleşen bir hesap bulunamadı.'**
  String noAccountMatch(String query);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Aramayı temizle'**
  String get clearSearch;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kişi ya da etiket aramak için yazmaya başla.'**
  String get searchHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Önerileri yenile'**
  String get refreshSuggestions;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Senin için öneriler'**
  String get suggestionsForYou;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Takip ettiğin {count} kişi takip ediyor'**
  String mutualFollows(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Popüler hesap'**
  String get popularAccount;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Paketi incele'**
  String get seePackage;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İstek gönderildi. {name} kabul edince haber vereceğiz.'**
  String requestSentNotify(String name);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{name} ile ekip arkadaşı ol'**
  String becomeTeammatesWith(String name);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kısa bir mesaj (isteğe bağlı)'**
  String get shortMessage;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Cumartesi sabahı Belgrad Ormanı?'**
  String get shortMessageHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İstek gönder'**
  String get sendRequest;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ekip arkadaşı bul'**
  String get findTeammates;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ekip arkadaşı tercihlerim'**
  String get myTeammatePrefs;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Öneriler'**
  String get tabSuggestions;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İstekler'**
  String get tabRequests;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İstekler ({count})'**
  String tabRequestsCount(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ekibim'**
  String get tabMyTeam;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ekip arkadaşını bul'**
  String get findYourTeammate;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} kişi seninle ekip arkadaşı olmak istiyor'**
  String waitingForYou(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Önerileri görmek, istek gönderip kabul etmek ve ekip arkadaşlarınla yazışmak Ekip Arkadaşı paketiyle açılır.'**
  String get teammatesLocked;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sen de görün'**
  String get beVisible;

  ///
  ///
  /// In tr, this message translates to:
  /// **'\"Ekip arıyorum\"u açarsan seninle aynı şeyleri sevenler sana istek gönderebilir.'**
  String get beVisibleBody;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Tercihlerimi ayarla'**
  String get setPrefs;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hesabın artık herkese açık; önerilerde görünebilirsin.'**
  String get nowPublicSuggest;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hesabın gizli, önerilerde görünmüyorsun'**
  String get privateHidden;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gizli hesaplar ekip arkadaşı önerilerinde çıkmaz. Hesabını herkese açarsan bekleyen takip istekleri de onaylanır.'**
  String get privateHiddenBody;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hesabımı herkese aç'**
  String get makePublic;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şimdilik sana uyan biri yok. İlgi alanlarını ve tercihlerini doldurursan öneriler artar.'**
  String get noSuggestions;

  ///
  ///
  /// In tr, this message translates to:
  /// **'\"{text}\"'**
  String quoted(String text);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Neden önerildi'**
  String get whySuggested;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bekleyen ekip arkadaşlığı isteği yok.'**
  String get noPendingTeammate;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Önerilere bak'**
  String get seeSuggestions;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sana gelenler'**
  String get incoming;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kabul et'**
  String get accept;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Reddet'**
  String get decline;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İstek reddedildi.'**
  String get requestDeclined;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gönderdiklerin'**
  String get outgoing;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yanıt bekleniyor'**
  String get awaitingReply;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Geri çek'**
  String get withdraw;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Henüz ekip arkadaşın yok. Önerilerden birine istek göndererek başla.'**
  String get noTeammates;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{name} için seçenekler'**
  String optionsFor(String name);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ekip arkadaşı tercihleri'**
  String get teammatePrefs;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Tercihlerin kaydedildi. Artık önerilerde görünürsün.'**
  String get prefsSavedVisible;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Tercihlerin kaydedildi.'**
  String get prefsSaved;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ne yapmak istiyorsun?'**
  String get whatToDo;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ekip arkadaşı aradığın aktiviteler. En fazla {max} tane.'**
  String activitiesHint(int max);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Seviyen'**
  String get yourLevel;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hedeflerin'**
  String get yourGoals;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Birden fazla seçebilirsin.'**
  String get multipleChoice;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ne sıklıkla buluşmak istersin?'**
  String get howOften;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ne zaman uygunsun?'**
  String get whenFree;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Uygun olduğun zamanlara dokun.'**
  String get whenFreeHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Nasıl bir ekip istersin?'**
  String get whatTeam;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hangi ildesin?'**
  String get whichProvince;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca eşleştirme için kullanılır, profilinde görünmez.'**
  String get provinceHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İl'**
  String get province;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Belirtmek istemiyorum'**
  String get ratherNotSay;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ek bilgiler'**
  String get extras;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Aracım var'**
  String get iHaveVehicle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ulaşımda yol arkadaşlığı yapabilirim.'**
  String get iHaveVehicleHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kendi ekipmanım var'**
  String get iHaveEquipment;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bisiklet, çadır, raket gibi malzemem hazır.'**
  String get iHaveEquipmentHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kendini anlat'**
  String get describeYourself;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Önerilerde adının altında görünür.'**
  String get describeHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hafta sonu sabah yürüyüşü için arkadaş arıyorum.'**
  String get describeExample;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Önerilerde görüneceksin.'**
  String get willAppear;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şu an önerilerde görünmüyorsun.'**
  String get notAppearing;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ekip arıyorum'**
  String get lookingForTeam;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Önerilerde görünürsün; sana ekip arkadaşlığı isteği gönderilebilir.'**
  String get lookingOn;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Açarsan seninle aynı şeyleri sevenler seni bulur. Gizli hesaplar önerilerde görünmez.'**
  String get lookingOff;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Tercihlerin %{percent} tamam'**
  String prefsComplete(int percent);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ne kadar çok doldurursan önerilerin o kadar isabetli olur.'**
  String get prefsCompleteHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hafta içi'**
  String get weekday;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hafta sonu'**
  String get weekend;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı adı'**
  String get username;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kullanılabilir'**
  String get available;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Alınmış'**
  String get taken;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{username} engellendi.'**
  String blockedUser(String username);
}

class _ProfileL10nDelegate extends LocalizationsDelegate<ProfileL10n> {
  const _ProfileL10nDelegate();

  @override
  Future<ProfileL10n> load(Locale locale) {
    return SynchronousFuture<ProfileL10n>(lookupProfileL10n(locale));
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
  bool shouldReload(_ProfileL10nDelegate old) => false;
}

ProfileL10n lookupProfileL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return ProfileL10nAr();
    case 'az':
      return ProfileL10nAz();
    case 'de':
      return ProfileL10nDe();
    case 'en':
      return ProfileL10nEn();
    case 'es':
      return ProfileL10nEs();
    case 'fr':
      return ProfileL10nFr();
    case 'it':
      return ProfileL10nIt();
    case 'nl':
      return ProfileL10nNl();
    case 'pt':
      return ProfileL10nPt();
    case 'ru':
      return ProfileL10nRu();
    case 'tr':
      return ProfileL10nTr();
    case 'uk':
      return ProfileL10nUk();
  }

  throw FlutterError(
    'ProfileL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
