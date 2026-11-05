import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'billing_l10n_ar.dart';
import 'billing_l10n_az.dart';
import 'billing_l10n_de.dart';
import 'billing_l10n_en.dart';
import 'billing_l10n_es.dart';
import 'billing_l10n_fr.dart';
import 'billing_l10n_it.dart';
import 'billing_l10n_nl.dart';
import 'billing_l10n_pt.dart';
import 'billing_l10n_ru.dart';
import 'billing_l10n_tr.dart';
import 'billing_l10n_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of BillingL10n
/// returned by `BillingL10n.of(context)`.
///
/// Applications need to include `BillingL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/billing_l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: BillingL10n.localizationsDelegates,
///   supportedLocales: BillingL10n.supportedLocales,
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
/// be consistent with the languages listed in the BillingL10n.supportedLocales
/// property.
abstract class BillingL10n {
  BillingL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static BillingL10n of(BuildContext context) {
    return Localizations.of<BillingL10n>(context, BillingL10n)!;
  }

  static const LocalizationsDelegate<BillingL10n> delegate =
      _BillingL10nDelegate();

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
  /// **'Aylık'**
  String get monthly;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yıllık'**
  String get yearly;

  ///
  ///
  /// In tr, this message translates to:
  /// **'ay'**
  String get perMonth;

  ///
  ///
  /// In tr, this message translates to:
  /// **'yıl'**
  String get perYear;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem bu cihazda kullanılamıyor.'**
  String get notOnDevice;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Geri dön'**
  String get goBack;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ödeme'**
  String get payment;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu paket şu anda satın alınamıyor.'**
  String get planUnavailable;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Paketlere dön'**
  String get backToPlans;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ödeme sayfası açılamadı. Lütfen tekrar dene.'**
  String get paymentPageFailed;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Fatura bilgileri'**
  String get billingDetails;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Faturan bu bilgilerle düzenlenir.'**
  String get billingDetailsHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ad'**
  String get firstName;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Soyad'**
  String get lastName;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{field} gerekli.'**
  String fieldRequired(String field);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Telefon'**
  String get phone;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir telefon numarası gir.'**
  String get phoneInvalid;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Adres'**
  String get address;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Fatura adresini gir.'**
  String get addressRequired;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şehir'**
  String get city;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şehri gir.'**
  String get cityRequired;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ülke'**
  String get country;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ülkeyi gir.'**
  String get countryRequired;

  ///
  ///
  /// In tr, this message translates to:
  /// **''**
  String get termsBefore;

  ///
  ///
  /// In tr, this message translates to:
  /// **'\'ni okudum ve kabul ediyorum.'**
  String get termsAfter;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Devam etmek için sözleşmeyi onaylamalısın.'**
  String get acceptTerms;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Fatura bilgilerin yalnızca ödemenin alınması, faturalandırma ve yasal saklama yükümlülükleri için kullanılır.'**
  String get billingDataUse;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ödemeye geç · {amount}'**
  String payAmount(String amount);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sipariş özeti'**
  String get orderSummary;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{plan} paketi · {period}'**
  String planPeriod(String plan, String period);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç'**
  String get start;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ödeme onaylanınca'**
  String get whenConfirmed;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bitiş (tahmini)'**
  String get endEstimated;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Aktarılan süre'**
  String get carriedOver;

  ///
  ///
  /// In tr, this message translates to:
  /// **'yaklaşık {value}'**
  String about(String value);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Toplam'**
  String get total;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ödeme {provider} güvencesiyle Türk lirası olarak alınır. Kart bilgilerin GWAY\'e iletilmez. Tek seferlik ödemedir, otomatik yenilenmez.'**
  String assuranceTry(String provider);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ödeme {provider} güvencesiyle ABD doları olarak alınır. Kart bilgilerin GWAY\'e iletilmez. Tek seferlik ödemedir, otomatik yenilenmez.'**
  String assuranceUsd(String provider);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Üye sayısı paketin limitini aşıyor. Limitin altına inilene kadar yeni üye alınamaz.'**
  String get overLimit;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grup, paketinin üye limitine ulaştı. Yeni üye alınamaz.'**
  String get atLimit;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} / {max} üye'**
  String membersOfMax(String count, String max);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Paket'**
  String get plan;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Paket al'**
  String get getPlan;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Paketi yükselt'**
  String get upgradePlan;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Paketin {date} tarihinde bitiyor. Bitince grup Ücretsiz pakete döner.'**
  String planEnds(String date);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ödeme alındı. Paketin açıldı.'**
  String get paymentReceivedPersonal;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Paket durumu'**
  String get planStatus;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu paket hesabında açık değil.'**
  String get notActive;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Paketin {date} tarihine kadar açık.'**
  String activeUntil(String date);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Satın al'**
  String get buy;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Süreni uzat'**
  String get extend;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Tek seferlik ödeme; otomatik yenilenmez.'**
  String get oneTime;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yeni süre, {date} tarihinden sonra başlar.'**
  String newPeriodAfter(String date);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu paketin satışı şu anda kapalı. Lütfen daha sonra tekrar dene.'**
  String get salesClosed;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Devam et · {amount}'**
  String continueAmount(String amount);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu paket yalnızca seni kapsar; grubunun paketini etkilemez.'**
  String get personalOnly;

  ///
  ///
  /// In tr, this message translates to:
  /// **'%{percent} avantajlı'**
  String saving(int percent);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{date} tarihine kadar'**
  String untilDate(String date);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{price} / {unit}'**
  String pricePer(String price, String unit);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu ürün şu anda satın alınamıyor.'**
  String get productUnavailable;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kişisel ürün'**
  String get personalProduct;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{plan} · {period}'**
  String offerPeriod(String plan, String period);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grubun hazır'**
  String get groupReady;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grubun Ücretsiz paketle başladı. Daha fazla üye, organizasyon ya da yayın dakikası gerekiyorsa aşağıdan bir paket seçebilirsin.'**
  String get freeStartBuy;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grubun Ücretsiz paketle başladı. Paketlerin limitleri aşağıda.'**
  String get freeStartView;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ücretsiz ile devam et'**
  String get continueFree;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gruba git'**
  String get goToGroup;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ödeme alındı. Paketin etkin.'**
  String get paymentReceivedGroup;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grubun paketini yalnızca grubun üyeleri görebilir.'**
  String get membersOnly;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Mevcut paket'**
  String get currentPlan;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grup ücretsiz paketi kullanıyor.'**
  String get onFree;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu dönem {date} tarihinde bitiyor.'**
  String periodEnds(String date);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Üye sayısı paketin limitini aşıyor. Kimse gruptan çıkarılmaz, ama limitin altına inilene kadar yeni üye alınamaz.'**
  String get overLimitLong;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grup üye limitine ulaştı. Yeni üye almak için daha büyük bir pakete geçebilirsin.'**
  String get atLimitLong;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sıradaki dönemler'**
  String get upcomingPeriods;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Paketler'**
  String get plans;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yıllık · 2 ay bedava'**
  String get yearlyDeal;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ödeme {provider} ile Türk lirası olarak alınır; bulunduğun ülkeye göre belirlenir. Otomatik yenileme yoktur.'**
  String paymentNoteTry(String provider);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ödeme {provider} ile ABD doları olarak alınır; bulunduğun ülkeye göre belirlenir. Otomatik yenileme yoktur.'**
  String paymentNoteUsd(String provider);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ödeme şu anda alınamıyor. Lütfen daha sonra tekrar dene.'**
  String get paymentsOff;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şimdilik alınamaz'**
  String get notNow;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Seç'**
  String get choose;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yükselt'**
  String get upgrade;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Süreyi uzat'**
  String get renew;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu pakete geç'**
  String get switchTo;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Paketin bir yıldan uzun süre için ödenmiş. Şimdilik yalnızca üst pakete geçebilirsin.'**
  String get paidOverYear;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hemen başlar; kalan sürenden yaklaşık {credit} eklenir. Bitiş: {date}.'**
  String startsNowCredit(String credit, String date);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hemen başlar. Bitiş: {date}.'**
  String startsNow(String date);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Mevcut dönemin ardından {date} tarihinde başlar.'**
  String startsAfterCurrent(String date);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Mevcut dönem bitince, {date} tarihinde başlar.'**
  String startsWhenEnds(String date);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ödeme onayı henüz gelmedi. Ödemen alındıysa paketin birkaç dakika içinde etkinleşir; bu sayfayı sonra yenileyebilirsin.'**
  String get confirmPending;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ödemen onaylanıyor. Bu birkaç saniye sürebilir.'**
  String get confirming;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ödeme tamamlanamadı. Tekrar deneyebilir ya da başka bir kart kullanabilirsin.'**
  String get paymentFailed;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu ödeme iade edildi.'**
  String get refunded;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Üyeler'**
  String get members;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} üye, limit {max}'**
  String membersSemantics(int count, int max);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} üye'**
  String limitMembers(String count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} organizasyon / ay'**
  String limitEvents(String count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} dk canlı yayın / ay'**
  String limitLive(String count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{plan} paket'**
  String planName(String plan);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{plan} paketi · {date} tarihine kadar'**
  String planUntil(String plan, String date);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{days} gün'**
  String creditDays(String days);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu çeviri bilgi amaçlıdır. Bağlayıcı olan ve onayladığın sözleşme Türkçe asıldır.'**
  String get termsTranslationNote;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Türkçe aslını göster'**
  String get showOriginal;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Çeviriyi göster'**
  String get showTranslation;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ücretsiz'**
  String get planNameFree;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç'**
  String get planNameStarter;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Topluluk'**
  String get planNameCommunity;
}

class _BillingL10nDelegate extends LocalizationsDelegate<BillingL10n> {
  const _BillingL10nDelegate();

  @override
  Future<BillingL10n> load(Locale locale) {
    return SynchronousFuture<BillingL10n>(lookupBillingL10n(locale));
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
  bool shouldReload(_BillingL10nDelegate old) => false;
}

BillingL10n lookupBillingL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return BillingL10nAr();
    case 'az':
      return BillingL10nAz();
    case 'de':
      return BillingL10nDe();
    case 'en':
      return BillingL10nEn();
    case 'es':
      return BillingL10nEs();
    case 'fr':
      return BillingL10nFr();
    case 'it':
      return BillingL10nIt();
    case 'nl':
      return BillingL10nNl();
    case 'pt':
      return BillingL10nPt();
    case 'ru':
      return BillingL10nRu();
    case 'tr':
      return BillingL10nTr();
    case 'uk':
      return BillingL10nUk();
  }

  throw FlutterError(
    'BillingL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
