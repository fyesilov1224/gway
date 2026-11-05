import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'social_app_l10n_ar.dart';
import 'social_app_l10n_az.dart';
import 'social_app_l10n_de.dart';
import 'social_app_l10n_en.dart';
import 'social_app_l10n_es.dart';
import 'social_app_l10n_fr.dart';
import 'social_app_l10n_it.dart';
import 'social_app_l10n_nl.dart';
import 'social_app_l10n_pt.dart';
import 'social_app_l10n_ru.dart';
import 'social_app_l10n_tr.dart';
import 'social_app_l10n_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of SocialAppL10n
/// returned by `SocialAppL10n.of(context)`.
///
/// Applications need to include `SocialAppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/social_app_l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: SocialAppL10n.localizationsDelegates,
///   supportedLocales: SocialAppL10n.supportedLocales,
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
/// be consistent with the languages listed in the SocialAppL10n.supportedLocales
/// property.
abstract class SocialAppL10n {
  SocialAppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static SocialAppL10n of(BuildContext context) {
    return Localizations.of<SocialAppL10n>(context, SocialAppL10n)!;
  }

  static const LocalizationsDelegate<SocialAppL10n> delegate =
      _SocialAppL10nDelegate();

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
  /// **'Gönderiler'**
  String get posts;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yeni gönderi'**
  String get newPost;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Henüz gönderi paylaşmadın. İlk fotoğrafını ya da videonu paylaş.'**
  String get noOwnPosts;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Henüz gönderi yok.'**
  String get noPosts;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İlk gönderini paylaş'**
  String get shareFirstOwn;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grubun akışına ilk gönderiyi sen paylaş.'**
  String get groupFirstPost;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu grupta henüz gönderi yok.'**
  String get groupNoPosts;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İlk gönderiyi paylaş'**
  String get shareFirstGroup;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grup bulunamadı.'**
  String get groupNotFound;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Henüz anı paylaşılmadı. Katılanlar fotoğraflarını buraya ekleyebilir.'**
  String get memoriesEmpty;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Paket'**
  String get plan;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ödeme'**
  String get payment;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Paket işlemlerini yalnızca grup sahibi yapabilir.'**
  String get onlyOwnerBilling;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gruba dön'**
  String get backToGroup;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu grupla ilgili platform ekibine yaz'**
  String get writeSupportAboutGroup;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ara'**
  String get search;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get notifications;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İyi geceler'**
  String get goodNight;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Günaydın'**
  String get goodMorning;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İyi günler'**
  String get goodAfternoon;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İyi akşamlar'**
  String get goodEvening;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{greeting}, {name}'**
  String greetingName(String greeting, String name);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get tabToday;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gruplar'**
  String get tabGroups;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Takvim'**
  String get tabCalendar;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ben'**
  String get tabMe;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Boşsan söyle, masa kur'**
  String get tonightSay;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Masan kuruldu'**
  String get tonightTableSet;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Masaya davetin var'**
  String get tonightInvited;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} kişi seninle boş'**
  String tonightFreeWithYou(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Boşsun · 04:00\'e kadar'**
  String get tonightFreeUntil;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} kişi bu akşam boş'**
  String tonightFreeCount(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gruplarının planları'**
  String get upcomingNone;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} plan · {mine} katılım'**
  String upcomingMine(int count, int mine);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} plan, 60 gün'**
  String upcomingCount(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bugün için'**
  String get forToday;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu akşam'**
  String get tonight;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yaklaşanlar'**
  String get upcoming;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Paylaş'**
  String get share;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gönderi'**
  String get post;

  ///
  ///
  /// In tr, this message translates to:
  /// **'10 fotoğraf ya da videoya kadar'**
  String get postHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hikâye'**
  String get story;

  ///
  ///
  /// In tr, this message translates to:
  /// **'24 saat görünür'**
  String get storyHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grup'**
  String get group;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kendi topluluğunu kur'**
  String get groupHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Oluştur'**
  String get create;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Mesajlar'**
  String get messages;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Eşleşme'**
  String get matching;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gruplarım'**
  String get myGroups;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Aradığın sayfa bulunamadı. Bağlantı eski ya da hatalı olabilir.'**
  String get pageNotFound;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ana sayfaya dön'**
  String get backHome;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gruplar Ligi'**
  String get groupsLeague;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Haritada keşfet'**
  String get exploreOnMap;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yılın özeti, keşif haritam ve tanıştıklarım'**
  String get yearMenu;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yılın özeti'**
  String get yearSummary;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu yılki buluşmaların, paylaşılabilir kart'**
  String get yearSummaryHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Keşif haritam'**
  String get explorationMap;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Katıldığın organizasyonların illeri'**
  String get explorationMapHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Tanıştıklarım'**
  String get metPeople;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Organizasyonlarda el sıkıştığın kişiler'**
  String get metPeopleHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ekip arkadaşı bul'**
  String get findTeammates;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilenler'**
  String get saved;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bilgilerin yüklenemedi. Bağlantını kontrol edip tekrar dene.'**
  String get gateError;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kişi ara'**
  String get searchPeople;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Aramayı temizle'**
  String get clearSearch;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settings;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Profili düzenle'**
  String get editProfile;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ekip arkadaşı tercihleri'**
  String get teammatePrefs;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Eşleşme profili'**
  String get matchProfile;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sesli görüşme'**
  String get voiceCalls;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Engellenen hesaplar'**
  String get blockedAccounts;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hikaye arşivi'**
  String get storyArchive;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bildirim tercihleri'**
  String get notificationPrefs;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grup yaptırımlarım'**
  String get mySanctions;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kullanma kılavuzu'**
  String get userGuide;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Destek ve geri bildirim'**
  String get supportFeedback;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} yeni yanıt'**
  String newReplies(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'İki adımlı doğrulama'**
  String get twoFactor;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hukuki metinler'**
  String get legalDocuments;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hesabı sil'**
  String get deleteAccount;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yap'**
  String get signOut;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hesabın artık gizli.'**
  String get nowPrivate;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hesabın artık herkese açık; bekleyen istekler onaylandı.'**
  String get nowPublic;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gizli hesap'**
  String get privateAccount;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Açıkken yalnızca onayladığın takipçiler gönderilerini ve hikayelerini görür.'**
  String get privateAccountHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grupların artık profilinde herkese görünüyor.'**
  String get groupsNowPublic;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grupların artık yalnızca aynı gruptaki üyelere görünüyor.'**
  String get groupsNowMembers;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gruplarımı profilimde göster'**
  String get showGroups;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kapalıyken bir gruptaki üyeliğini yalnızca o grubun üyeleri görür; başka grupların yöneticileri göremez.'**
  String get showGroupsHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get language;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Oyunlar'**
  String get games;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hızlı oyun, arkadaşını davet et, Elo sıralamasında yüksel.'**
  String get chessHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Satranç: hızlı oyun, turnuvalar, takım maçları'**
  String get gamesHint;
}

class _SocialAppL10nDelegate extends LocalizationsDelegate<SocialAppL10n> {
  const _SocialAppL10nDelegate();

  @override
  Future<SocialAppL10n> load(Locale locale) {
    return SynchronousFuture<SocialAppL10n>(lookupSocialAppL10n(locale));
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
  bool shouldReload(_SocialAppL10nDelegate old) => false;
}

SocialAppL10n lookupSocialAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return SocialAppL10nAr();
    case 'az':
      return SocialAppL10nAz();
    case 'de':
      return SocialAppL10nDe();
    case 'en':
      return SocialAppL10nEn();
    case 'es':
      return SocialAppL10nEs();
    case 'fr':
      return SocialAppL10nFr();
    case 'it':
      return SocialAppL10nIt();
    case 'nl':
      return SocialAppL10nNl();
    case 'pt':
      return SocialAppL10nPt();
    case 'ru':
      return SocialAppL10nRu();
    case 'tr':
      return SocialAppL10nTr();
    case 'uk':
      return SocialAppL10nUk();
  }

  throw FlutterError(
    'SocialAppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
