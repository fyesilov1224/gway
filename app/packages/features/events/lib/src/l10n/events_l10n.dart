import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'events_l10n_ar.dart';
import 'events_l10n_az.dart';
import 'events_l10n_de.dart';
import 'events_l10n_en.dart';
import 'events_l10n_es.dart';
import 'events_l10n_fr.dart';
import 'events_l10n_it.dart';
import 'events_l10n_nl.dart';
import 'events_l10n_pt.dart';
import 'events_l10n_ru.dart';
import 'events_l10n_tr.dart';
import 'events_l10n_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of EventsL10n
/// returned by `EventsL10n.of(context)`.
///
/// Applications need to include `EventsL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/events_l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: EventsL10n.localizationsDelegates,
///   supportedLocales: EventsL10n.supportedLocales,
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
/// be consistent with the languages listed in the EventsL10n.supportedLocales
/// property.
abstract class EventsL10n {
  EventsL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static EventsL10n of(BuildContext context) {
    return Localizations.of<EventsL10n>(context, EventsL10n)!;
  }

  static const LocalizationsDelegate<EventsL10n> delegate =
      _EventsL10nDelegate();

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
  /// **'Bu ankette tek seçenek işaretlenebilir.'**
  String get pollSingle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu seçenek artık yok. Sayfayı yenile.'**
  String get pollOptionGone;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Değerlendirme, organizasyona katılanlar için bitişinden sonraki 30 gün açıktır.'**
  String get reviewWindow;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Karşılayıcı olmak için grubun bir organizasyonuna katılmış olmalısın.'**
  String get greeterNeedsAttendance;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Not en fazla 80 karakter olabilir.'**
  String get note80;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu anket kapandı ya da oy veremezsin.'**
  String get pollClosed;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kapak görseli en fazla 5 MB olabilir.'**
  String get cover5mb;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca JPEG, PNG ya da WebP görsel yüklenebilir.'**
  String get imagesOnly;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu göreve şu anda bildirim yapılamaz; görev bitmiş ya da gruptan değilsin.'**
  String get claimNotAllowed;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Onaylanmış bir bildirim geri çekilemez.'**
  String get claimApprovedLocked;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu görevi zaten bildirdin.'**
  String get claimDuplicate;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Her hafta tekrarlanır'**
  String get repeatsWeekly;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İki haftada bir tekrarlanır'**
  String get repeatsBiweekly;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sürpriz mekan · {place}'**
  String surprisePlace(String place);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kişisel hedef'**
  String get goalPersonal;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Her üye kendi sayısını tamamlar.'**
  String get goalPersonalHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grup hedefi'**
  String get goalGroup;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Herkesin katkısı tek sayaçta toplanır.'**
  String get goalGroupHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Takım hedefi'**
  String get goalTeam;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yönetici takımları kurar; takımın ortak sayacı olur.'**
  String get goalTeamHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Onaylı görev'**
  String get goalTask;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Üye \"Yaptım\" der, yönetici onaylar.'**
  String get goalTaskHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'katılım'**
  String unitAttended(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'düzenleme'**
  String unitOrganized(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'anı'**
  String unitMemories(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Onay bekliyor'**
  String get claimPending;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Onaylandı'**
  String get claimApproved;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Onaylanmadı'**
  String get claimRejected;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Henüz bildirilmedi'**
  String get notClaimedYet;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Her zaman'**
  String get whenAny;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get whenToday;

  ///
  ///
  /// In tr, this message translates to:
  /// **'7 gün içinde'**
  String get whenWeek;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gün'**
  String get viewDay;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hafta'**
  String get viewWeek;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ay'**
  String get viewMonth;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} katılım'**
  String countAttended(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} düzenleme'**
  String countOrganized(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} anı'**
  String countMemories(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} değerlendirme'**
  String countReviews(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} karşılama'**
  String countWelcomed(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} el sıkış'**
  String countHandshakes(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} organizasyon'**
  String countHeld(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} memnuniyet'**
  String countGoodReviews(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{month}: {groups} grup arasında {rank}. sırada, {points} puan.'**
  String leagueStanding(String month, int groups, int rank, int points);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} katılımcı'**
  String goingCount(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} / {capacity} katılımcı'**
  String goingOfCapacity(int count, int capacity);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yılın ilk organizasyonu: {title}'**
  String firstEventOfYear(String title);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yılın ilk organizasyonu: {title} · {date}'**
  String firstEventOfYearOn(String title, String date);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Takvimim'**
  String get myCalendar;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grup takvimi'**
  String get groupCalendar;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Önceki'**
  String get previous;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sonraki'**
  String get next;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get today;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gruplarımın organizasyonları'**
  String get groupsEvents;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Katılmadıklarını da göster'**
  String get showNotJoined;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu tarihlerde katıldığın organizasyon yok. Gruplarının organizasyonlarına da bakabilirsin.'**
  String get noJoinedInRange;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu tarihlerde organizasyon yok.'**
  String get noEventsInRange;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gruplarımın organizasyonlarını göster'**
  String get showGroupsEvents;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bugüne dön'**
  String get backToToday;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu günde organizasyon yok.'**
  String get noEventsDay;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Topluluk katkısı'**
  String get contributions;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Rozetler nasıl kazanılır?'**
  String get howBadges;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bir organizasyona katıldığında katkın ve ilk rozetin burada görünür.'**
  String get badgesEmpty;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Rozetler yalnızca gerçekten yaptıklarından hesaplanır: katıldığın ve düzenlediğin organizasyonlar, paylaştığın anılar ve değerlendirmelerin. Beğeni ve takipçi sayısı sayılmaz. Düzenleyenin \"gelmedi\" olarak işaretlediği katılımlar sayılmaz. Kimse sıralanmaz.'**
  String get badgesRules;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kategori tutkunu'**
  String get categoryFan;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş organizasyonlar'**
  String get pastEvents;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu grubun henüz geçmiş bir organizasyonu yok.'**
  String get noPastEvents;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yenile'**
  String get refresh;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İptal edildi'**
  String get canceled;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Daha eski organizasyonlar'**
  String get olderEvents;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Tamamladın'**
  String get completed;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sona erdi'**
  String get ended;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Takım: {name}'**
  String teamName(String name);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bir takıma eklenince ilerlemen burada görünür.'**
  String get teamNotice;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hedefler'**
  String get goals;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hedef oluştur'**
  String get createGoal;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Örneğin \"Bu ay 4 yürüyüşe katıl\" ya da \"Hep birlikte 50 katılım\"; ilk hedefi oluştur.'**
  String get goalsEmpty;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bildirimin yöneticiye iletildi.'**
  String get claimSent;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hedef'**
  String get goal;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca bu grubun dönem içindeki organizasyonları sayılır; \"gelmedi\" işaretlenen katılımlar sayılmaz.'**
  String get goalCountsRule;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bildirimi geri çek'**
  String get withdrawClaim;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bildirimin geri çekildi.'**
  String get claimWithdrawn;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yaptım'**
  String get done;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Takımlar'**
  String get teams;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Takım kur'**
  String get createTeam;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Henüz takım yok.'**
  String get noTeams;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{name} takımını sil'**
  String deleteTeam(String name);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Takım silindi.'**
  String get teamDeleted;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Onay bekleyen bildirimler ({count})'**
  String pendingClaims(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bildirim onaylanmadı.'**
  String get claimRejectedToast;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Reddet'**
  String get decline;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Onayla'**
  String get approve;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{name} görevi tamamladı.'**
  String taskDone(String name);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Tamamlayanlar ({count})'**
  String completions(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Henüz tamamlayan yok. Tamamlayan herkes profilinde bu hedefin rozetini alır.'**
  String get noCompletions;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hedef iptal edildi.'**
  String get goalCanceled;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hedefi iptal et'**
  String get cancelGoal;

  ///
  ///
  /// In tr, this message translates to:
  /// **'\"{name}\" takımı kuruldu.'**
  String teamCreated(String name);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Takım adı'**
  String get teamNameLabel;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Takımı kur'**
  String get createTheTeam;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Takımı kur ({count} kişi)'**
  String createTeamWith(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hedef oluşturuldu.'**
  String get goalCreated;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Başlık'**
  String get title;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ör. Ekim yürüyüşleri'**
  String get goalTitleExample;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ör. Yeni bir üyeye rota anlat'**
  String get taskTitleExample;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Başlık en az 3 karakter olmalı.'**
  String get titleMin3;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Açıklama (isteğe bağlı)'**
  String get descriptionOptional;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hedef sayı'**
  String get targetNumber;

  ///
  ///
  /// In tr, this message translates to:
  /// **'1–1000 arası bir sayı yaz.'**
  String get target1to1000;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Dönem'**
  String get period;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{from} – {to} (en fazla 92 gün)'**
  String periodRange(String from, String to);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hedefi oluştur'**
  String get createTheGoal;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Görevi yaptım'**
  String get iDidTask;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ne yaptın? (isteğe bağlı)'**
  String get whatDidYouDo;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yönetici bu notu görerek onaylar.'**
  String get whatDidYouDoHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get cancel;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gönder'**
  String get send;

  ///
  ///
  /// In tr, this message translates to:
  /// **'El sıkış'**
  String get handshake;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Tanıştığın kişiyle kodlarınızı okutun; ikinizin de \"Tanıştıklarım\" listesine eklenir.'**
  String get handshakeHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Aç'**
  String get open;

  ///
  ///
  /// In tr, this message translates to:
  /// **'El sıkış · {title}'**
  String handshakeAt(String title);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kodum'**
  String get myCode;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Okut'**
  String get scan;

  ///
  ///
  /// In tr, this message translates to:
  /// **'El sıkış kodun'**
  String get yourHandshakeCode;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Karşındaki bu kodu \"Okut\" sekmesinden okutsun ya da yazsın. Kod birkaç dakikada bir kendiliğinden yenilenir; fotoğrafı sonradan işe yaramaz.'**
  String get codeHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kamera açılamadı. Kamera iznini ayarlardan verebilir ya da kodu aşağıya yazabilirsin.'**
  String get cameraFailed;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Karşındakinin QR kodunu kameraya göster ya da kodunu yaz.'**
  String get scanHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Karşındakinin ekranındaki 6 haneli kodu yaz.'**
  String get typeCodeHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kod'**
  String get code;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Zaten tanışıyorsunuz'**
  String get alreadyMet;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Tanıştınız!'**
  String get metNow;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{name} (@{username})'**
  String personWithUsername(String name, String username);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get ok;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Tanıştıklarım'**
  String get metPeople;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bir organizasyonda biriyle el sıkıştığında burada görünür. El sıkış, organizasyon sayfasında açılır.'**
  String get metEmpty;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Takvimime git'**
  String get goToCalendar;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca sen görürsün. Profilinde yalnızca el sıkış sayın görünür.'**
  String get metPrivacy;

  ///
  ///
  /// In tr, this message translates to:
  /// **'@{username} · {event} · {date}'**
  String metRow(String username, String event, String date);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Puanlar nasıl hesaplanır?'**
  String get howPoints;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Aynı ildeki aynı kategoriden gruplar her ay yarışır. Ayın biten organizasyonları sayılır.'**
  String get leagueIntro;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Katılım: 1 puan'**
  String get ruleAttendance;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gelen her kişi; bir organizasyonda en fazla 30.'**
  String get ruleAttendanceHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Organizasyon: 5 puan'**
  String get ruleHeld;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Düzenleyen dışında en az 3 kişinin geldiği her organizasyon.'**
  String get ruleHeldHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Karşılama: 3 puan'**
  String get ruleWelcome;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İlk kez gelen birinin karşılanması.'**
  String get ruleWelcomeHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Memnuniyet: 1 puan'**
  String get ruleReview;

  ///
  ///
  /// In tr, this message translates to:
  /// **'4 ya da 5 yıldızlı her değerlendirme.'**
  String get ruleReviewHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gelmedi işaretlenenler sayılmaz. Sonuçlar ay bittikten 8 gün sonra kesinleşir; ilk üçe giren grupların üyelerine haber verilir.'**
  String get leagueRulesNote;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gruplar Ligi'**
  String get groupsLeague;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kategori'**
  String get category;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İl'**
  String get province;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ay'**
  String get month;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{month} sezonu kapandı; sıralama kesin.'**
  String seasonClosed(String month);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sezon sürüyor. Puanlar organizasyonlar bittikçe güncellenir; sonuçlar ay bittikten 8 gün sonra kesinleşir.'**
  String get seasonRunning;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{province} ligine bu ay henüz puan alan grup yok.'**
  String leagueEmpty(String province);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} puan'**
  String points(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{rank}.'**
  String rank(int rank);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{province} · {category} ligi'**
  String leagueName(String province, String category);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu ay henüz puan yok. Biten organizasyonlar, gelenler ve karşılamalar puan getirir.'**
  String get noPointsYet;

  ///
  ///
  /// In tr, this message translates to:
  /// **'© Stadia Maps © OpenMapTiles © OpenStreetMap katkıcıları'**
  String get mapAttribution;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Harita'**
  String get map;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Harita görünümü'**
  String get mapView;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Liste görünümü'**
  String get listView;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get all;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Tüm alan'**
  String get wholeArea;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{km} km'**
  String km(int km);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Harita bilgileri yüklenemedi.'**
  String get mapLoadFailed;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Tekrar dene'**
  String get retry;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu filtrelerle bir şey bulunamadı.'**
  String get noFilterResults;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Filtreleri temizle'**
  String get clearFilters;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu bölgede yaklaşan organizasyon ya da grup yok.'**
  String get noNearby;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Uzaklaştır'**
  String get zoomOut;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Organizasyonu aç'**
  String get openEvent;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} üye'**
  String memberCount(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Görünen bölgede yaklaşan organizasyon ya da grup yok.'**
  String get noVisible;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Haritaya dön'**
  String get backToMap;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yaklaşan organizasyonlar ({count})'**
  String upcomingCount(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yol tarifi'**
  String get directions;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Buluşma noktası (isteğe bağlı)'**
  String get meetingPointOptional;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Haritada seç; organizasyon haritada görünür.'**
  String get meetingPointHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Seçildi · {lat}, {lng}'**
  String pointPicked(String lat, String lng);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Buluşma noktasını kaldır'**
  String get removeMeetingPoint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Buluşma noktası'**
  String get meetingPoint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Haritayı yakınlaştır ve buluşma noktasına dokun.'**
  String get pickHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Noktayı değiştirmek için başka bir yere dokun.'**
  String get pickAgainHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu noktayı seç'**
  String get pickThisPoint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Harita şu anda kullanılamıyor.'**
  String get mapUnavailable;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kapandı'**
  String get pollClosedShort;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kapanış: {date}'**
  String closesAt(String date);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Birden fazla seçilebilir'**
  String get multipleAllowed;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gizli oylama'**
  String get anonymousVote;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} kişi oy verdi'**
  String votersCount(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Anket seçenekleri'**
  String get pollOptions;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Anket kapatıldı.'**
  String get pollClosedToast;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Anket silindi.'**
  String get pollDeleted;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Anketi kapat'**
  String get closePoll;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Anketi sil'**
  String get deletePoll;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Oy ver'**
  String get vote;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Oyun kaydedildi.'**
  String get voteSaved;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Oy verenler'**
  String get voters;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} kişi'**
  String peopleCount(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Anketler'**
  String get polls;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Anket aç'**
  String get openPoll;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Üyelere bir soru sor; örneğin hangi gün buluşalım?'**
  String get pollsEmpty;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Anket açıldı.'**
  String get pollOpened;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Soru'**
  String get question;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ör. Hangi gün buluşalım?'**
  String get questionExample;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Soru en az 3 karakter olmalı.'**
  String get questionMin3;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{n}. seçenek'**
  String optionN(int n);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Seçeneği kaldır'**
  String get removeOption;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Seçeneği yaz ya da kaldır.'**
  String get optionRequired;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Seçenek ekle'**
  String get addOption;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Birden fazla seçilebilsin'**
  String get allowMultiple;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kimin neye oy verdiği gösterilmez.'**
  String get anonymousHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bitiş zamanı yok'**
  String get noEndTime;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ekle'**
  String get add;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bitiş zamanını kaldır'**
  String get removeEndTime;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Anketi aç'**
  String get startPoll;

  ///
  ///
  /// In tr, this message translates to:
  /// **'gway · topluluğunu bul'**
  String get cardFooter;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{year} yılım'**
  String myYear(int year);

  ///
  ///
  /// In tr, this message translates to:
  /// **'organizasyona katıldım'**
  String get statAttended;

  ///
  ///
  /// In tr, this message translates to:
  /// **'saat birlikteydik'**
  String get statHours;

  ///
  ///
  /// In tr, this message translates to:
  /// **'grupla buluştum'**
  String get statOneGroup;

  ///
  ///
  /// In tr, this message translates to:
  /// **'farklı grupla buluştum'**
  String get statGroups;

  ///
  ///
  /// In tr, this message translates to:
  /// **'farklı ilde'**
  String get statProvinces;

  ///
  ///
  /// In tr, this message translates to:
  /// **'organizasyon düzenledim'**
  String get statOrganized;

  ///
  ///
  /// In tr, this message translates to:
  /// **'kişiyi ilk gelişinde karşıladım'**
  String get statWelcomed;

  ///
  ///
  /// In tr, this message translates to:
  /// **'anı paylaştım'**
  String get statMemories;

  ///
  ///
  /// In tr, this message translates to:
  /// **'En sevdiklerim'**
  String get favorites;

  ///
  ///
  /// In tr, this message translates to:
  /// **'En çok birlikte olduğum grup'**
  String get topGroup;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{group} · {count} buluşma'**
  String topGroupLine(String group, int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ben de oradaydım'**
  String get iWasThere;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu grupla ilk organizasyonum.'**
  String get firstWithGroup;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu grupla {n}. organizasyonum.'**
  String nthWithGroup(int n);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu cihazda paylaşılamadı. Kartın ekran görüntüsünü alıp paylaşabilirsin.'**
  String get shareFailed;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Paylaş'**
  String get share;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{year} özetim'**
  String yearSummaryTitle(int year);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu yıl henüz bir organizasyona katılmadın. İlk buluşmandan sonra özetin burada oluşur.'**
  String get yearEmpty;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{year} yılım GWAY\'de'**
  String yearShareText(int year);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Türkiye haritası: {count} il keşfedildi'**
  String mapSemantics(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Keşif haritam'**
  String get explorationMap;

  ///
  ///
  /// In tr, this message translates to:
  /// **'ili keşfettim'**
  String get statExplored;

  ///
  ///
  /// In tr, this message translates to:
  /// **'organizasyonda buluştum'**
  String get statMetAt;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Son keşiflerim'**
  String get recentExplored;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Katıldığın organizasyonların illeri burada açılır. İlk buluşmandan sonra haritan renklenir.'**
  String get explorationEmpty;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Haritada organizasyon bul'**
  String get findOnMap;

  ///
  ///
  /// In tr, this message translates to:
  /// **'GWAY\'de {count} ili keşfettim'**
  String explorationShareText(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Keşfettiğin iller'**
  String get exploredProvinces;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca sen görürsün. Katıldığın ve \"gelmedi\" işaretlenmediğin organizasyonlar sayılır.'**
  String get explorationPrivacy;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu akşam boş olduğunu ortak gruplarındakiler görecek. 04:00\'te kendiliğinden kapanır.'**
  String get tonightVisible;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Masaya katıldın.'**
  String get joinedTable;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Daveti geri çevirdin.'**
  String get declinedInvite;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Durumun'**
  String get yourStatus;

  ///
  ///
  /// In tr, this message translates to:
  /// **'04:00\'e kadar görünürsün'**
  String get visibleUntil4;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şu an görünmüyorsun'**
  String get notVisible;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Boşsun'**
  String get youreFree;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Boşsan ortak gruplarındakiler görsün; birlikte küçük bir masa kurabilirsiniz.'**
  String get tonightIntro;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu akşam boşum'**
  String get imFreeTonight;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Artık boş görünmüyorsun.'**
  String get noLongerFree;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Durumu kapat'**
  String get turnOffStatus;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Masadan ayrıldın.'**
  String get leftTable;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Küçük masa'**
  String get smallTable;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Boş olanlardan birkaç kişiyi çağır; üç kişi olunca masanın sohbeti açılır.'**
  String get smallTableHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Küçük masa kur'**
  String get setUpTable;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} kişiye davet gönderildi. Üç kişi olunca masanın sohbeti açılır.'**
  String tableInvitesSent(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Küçük masa için ortak gruplarından en az {min} kişinin daha boş olması gerekiyor (şu an {now}). Biri boş olduğunu söyleyince burada masa kurabilirsin.'**
  String needMorePeople(int min, int now);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ortak gruplarından {count} kişi bu akşam boş'**
  String freeFromGroups(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kahve'**
  String get chipCoffee;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kısa yürüyüş'**
  String get chipWalk;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yemek'**
  String get chipFood;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sinema'**
  String get chipCinema;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca ortak gruplarındaki kişiler görür. Durumun 04:00\'te kendiliğinden kapanır.'**
  String get tonightSheetHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ne yapmak istersin? (isteğe bağlı)'**
  String get whatToDo;

  ///
  ///
  /// In tr, this message translates to:
  /// **'ör. kahve, kısa yürüyüş'**
  String get whatToDoHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Boşum'**
  String get imFree;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Masan'**
  String get yourTable;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} kişi katıldı'**
  String joinedCount(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} kişi bekleniyor'**
  String waitingCount(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kuruluyor'**
  String get settingUp;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sohbet açık'**
  String get chatOpen;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Masanın sohbeti'**
  String get tableChat;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sohbet, {count} kişi daha katılınca açılır. Yeri ve saati orada birlikte seçersiniz.'**
  String chatOpensWhen(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Masadan ayrıl'**
  String get leaveTable;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{name} küçük bir masa kurdu ve seni de çağırıyor.'**
  String tableInviteTitle(String name);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{joined} kişi katıldı · {pending} kişi bekleniyor. Üç kişi olunca sohbet açılır.'**
  String tableInviteStatus(int joined, int pending);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Katıl'**
  String get join;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu akşam olmaz'**
  String get notTonight;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu akşam'**
  String get tonight;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu akşam boş olanlar'**
  String get freeTonight;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca ortak gruplarındaki kişiler'**
  String get sharedGroupsOnly;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ortak gruplarından şu an boş olan yok.'**
  String get nobodyFree;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Nasıl işler?'**
  String get howItWorks;

  ///
  ///
  /// In tr, this message translates to:
  /// **'\"Bu akşam boşum\" de; istersen ne yapmak istediğini yaz.'**
  String get howStep1;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ortak gruplarındakiler seni görür, sen de boş olanları görürsün.'**
  String get howStep2;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Küçük masa kur; üç kişi olunca masanın sohbeti açılır, yeri ve saati orada seçersiniz.'**
  String get howStep3;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yaklaşanlar'**
  String get upcoming;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Takvim'**
  String get calendar;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Katıldığın yaklaşan bir organizasyon yok.'**
  String get noUpcomingJoined;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Tümünü göster'**
  String get showAll;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Önümüzdeki 60 günde gruplarının organizasyonu yok.'**
  String get noUpcoming60;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grup bul'**
  String get findGroup;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Tümü · {count}'**
  String filterAll(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Katıldıklarım · {count}'**
  String filterMine(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yarın'**
  String get tomorrow;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Katılıyorsun'**
  String get going;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yedek listede'**
  String get waitlisted;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Onay bekliyor'**
  String get awaitingApproval;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Dolu'**
  String get full;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count}/{capacity} katılımcı'**
  String goingOfCapacityShort(int count, int capacity);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yakında başlıyor'**
  String get startingSoon;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Önümüzdeki 6 saat'**
  String get next6Hours;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Karşılanmak istiyorum'**
  String get wantWelcome;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grubun gönüllü üyelerinden biri seni girişte karşılar; yalnız gitmezsin.'**
  String get wantWelcomeHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Seni tanımaları için bir not (isteğe bağlı)'**
  String get noteForGreeter;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ör. Kırmızı montluyum, mavi çantam var'**
  String get noteForGreeterHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İstek gönder'**
  String get sendRequest;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İsteğin karşılayıcılara iletildi. Biri üstlenince haber vereceğiz.'**
  String get welcomeRequestSent;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Buluşma notunu düzenle'**
  String get editMeetingNote;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{name} kişisini karşıla'**
  String welcomePerson(String name);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kendini şöyle tarif etti: {note}'**
  String describedAs(String note);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Nerede buluşacaksınız?'**
  String get whereMeet;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ör. Girişteki kafenin önü, 08:45'**
  String get whereMeetHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Karşılarım'**
  String get iWillWelcome;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Buluşma notu güncellendi.'**
  String get noteUpdated;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{name} kişisini karşılayacaksın; buluşma notunu gördü.'**
  String youWillWelcome(String name);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Karşılamayı bırak'**
  String get stopWelcoming;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{name} için yeniden karşılayıcı aranacak ve kendisine haber verilecek.'**
  String stopWelcomingBody(String name);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bırak'**
  String get release;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Karşılamayı bıraktın; yeni bir karşılayıcı aranıyor.'**
  String get releasedWelcome;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İlk kez mi geliyorsun?'**
  String get firstTime;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu grupta {count} karşılayıcı var. Biri seni girişte karşılasın, grupla tanıştırsın.'**
  String greetersAvailable(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Karşıladıkların'**
  String get youWelcomed;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Buluşma: {note}'**
  String meetingAt(String note);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sana teşekkür etti'**
  String get thankedYou;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{name} için seçenekler'**
  String optionsFor(String name);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Karşılanmayı bekleyenler ({count})'**
  String waitingWelcome(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} kişi bir karşılayıcıyla eşleşti.'**
  String matchedCount(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'İlk kez geliyor'**
  String get firstTimer;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bir organizasyonda en fazla 3 kişiyi karşılayabilirsin.'**
  String get max3Welcomes;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Karşılayıcısın. İlk kez gelenleri karşılamak için organizasyona katıl.'**
  String get greeterJoinHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Karşılayıcı aranıyor'**
  String get lookingGreeter;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grubun karşılayıcılarına haber verdik. Biri üstlenince bildirim gelecek.'**
  String get lookingGreeterHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Notun: {note}'**
  String yourNote(String note);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Karşılanma isteğin geri çekildi.'**
  String get welcomeWithdrawn;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İsteği geri çek'**
  String get withdrawRequest;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Seni karşılayan'**
  String get greetedBy;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Seni karşılayacak'**
  String get willGreet;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Teşekkür et'**
  String get thank;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{name} teşekkürünü aldı.'**
  String thankReceived(String name);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Teşekkür ettin.'**
  String get thanked;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Karşılanmaktan vazgeç'**
  String get cancelWelcome;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Artık karşılayıcısın. İlk kez gelen biri karşılanmak istediğinde haber vereceğiz.'**
  String get nowGreeter;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Karşılayıcılığı bıraktın.'**
  String get noLongerGreeter;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Karşılama'**
  String get welcomeSection;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} karşılayıcı'**
  String greetersCount(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'İlk kez gelenler organizasyon sayfasından karşılanmak isteyebilir. Karşılayıcı olursan haber alırsın; girişte karşılar, grupla tanıştırırsın.'**
  String get greeterIntro;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu grupta {count} karşılayıcı var. İlk organizasyonunda sayfadan \"Karşılanmak istiyorum\" diyebilirsin.'**
  String greeterMemberHint(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu grupta {count} karşılayıcı var: ilk organizasyonuna yalnız gitmezsin, biri seni girişte karşılar.'**
  String greeterVisitorHint(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Karşılayıcı ol'**
  String get becomeGreeter;

  ///
  ///
  /// In tr, this message translates to:
  /// **'\"{text}\"'**
  String quoted(String text);
}

class _EventsL10nDelegate extends LocalizationsDelegate<EventsL10n> {
  const _EventsL10nDelegate();

  @override
  Future<EventsL10n> load(Locale locale) {
    return SynchronousFuture<EventsL10n>(lookupEventsL10n(locale));
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
  bool shouldReload(_EventsL10nDelegate old) => false;
}

EventsL10n lookupEventsL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return EventsL10nAr();
    case 'az':
      return EventsL10nAz();
    case 'de':
      return EventsL10nDe();
    case 'en':
      return EventsL10nEn();
    case 'es':
      return EventsL10nEs();
    case 'fr':
      return EventsL10nFr();
    case 'it':
      return EventsL10nIt();
    case 'nl':
      return EventsL10nNl();
    case 'pt':
      return EventsL10nPt();
    case 'ru':
      return EventsL10nRu();
    case 'tr':
      return EventsL10nTr();
    case 'uk':
      return EventsL10nUk();
  }

  throw FlutterError(
    'EventsL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
