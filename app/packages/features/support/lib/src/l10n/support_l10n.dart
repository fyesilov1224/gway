import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'support_l10n_ar.dart';
import 'support_l10n_az.dart';
import 'support_l10n_de.dart';
import 'support_l10n_en.dart';
import 'support_l10n_es.dart';
import 'support_l10n_fr.dart';
import 'support_l10n_it.dart';
import 'support_l10n_nl.dart';
import 'support_l10n_pt.dart';
import 'support_l10n_ru.dart';
import 'support_l10n_tr.dart';
import 'support_l10n_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of SupportL10n
/// returned by `SupportL10n.of(context)`.
///
/// Applications need to include `SupportL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/support_l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: SupportL10n.localizationsDelegates,
///   supportedLocales: SupportL10n.supportedLocales,
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
/// be consistent with the languages listed in the SupportL10n.supportedLocales
/// property.
abstract class SupportL10n {
  SupportL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static SupportL10n of(BuildContext context) {
    return Localizations.of<SupportL10n>(context, SupportL10n)!;
  }

  static const LocalizationsDelegate<SupportL10n> delegate =
      _SupportL10nDelegate();

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
  /// **'Bugün çok fazla mesaj açtın. Yarın tekrar deneyebilir ya da açık mesajlarına yazabilirsin.'**
  String get ruleTicketRate;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kısa sürede çok fazla yanıt yazdın. Biraz bekleyip tekrar dene.'**
  String get ruleReplyRate;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu mesaj kapatıldı. Devam etmek için yeni bir mesaj aç.'**
  String get ticketClosed;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu dosya türü desteklenmiyor. JPEG, PNG veya WebP seç.'**
  String get unsupportedImage;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sorun'**
  String get kindProblem;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bir şey bozuk ya da çalışmıyor.'**
  String get kindProblemText;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Talep'**
  String get kindRequest;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hesabın, grubun ya da ödemen için bir işlem iste.'**
  String get kindRequestText;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İstek'**
  String get kindSuggestion;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yeni bir özellik ya da öneri paylaş.'**
  String get kindSuggestionText;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yeni'**
  String get statusOpen;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İnceleniyor'**
  String get statusInProgress;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Çözüldü'**
  String get statusResolved;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kapatıldı'**
  String get statusClosed;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kullanma kılavuzu'**
  String get guide;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kılavuzda ara: ör. davet bağlantısı, şifre'**
  String get guideSearchHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Aramayı temizle'**
  String get clearSearch;

  ///
  ///
  /// In tr, this message translates to:
  /// **'GWAY\'in her bölümünü adım adım anlatır. Bir bölüm seç ya da yukarıdan ara.'**
  String get guideIntro;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Aradığını bulamadık. Başka bir kelime dene ya da destek ekibine yaz.'**
  String get noHits;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Destek ekibine yaz'**
  String get writeSupport;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} konu bulundu'**
  String hitsFound(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{title}. {summary} {count} konu.'**
  String chapterSemantics(String title, String summary, int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} konu'**
  String topicCount(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu bölüm bulunamadı.'**
  String get chapterNotFound;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kılavuza dön'**
  String get backToGuide;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sorunun çözülmedi mi?'**
  String get notSolved;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Platform ekibine yaz; yanıtı Ayarlar → Destek ve geri bildirim\'de görürsün.'**
  String get notSolvedHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sonraki bölüm'**
  String get nextChapter;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Mesajın platform ekibine iletildi.'**
  String get sent;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yeni mesaj'**
  String get newMessage;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ne hakkında yazıyorsun?'**
  String get aboutWhat;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bir tür seç.'**
  String get pickKind;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İlgili grup (isteğe bağlı)'**
  String get relatedGroup;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grupla ilgili değil'**
  String get noGroup;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Konu'**
  String get subject;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kısa bir konu yaz.'**
  String get subjectRequired;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Açıklama'**
  String get description;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ne oldu, ne bekliyordun? Ne kadar ayrıntı, o kadar hızlı yardım.'**
  String get descriptionHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ne olduğunu kısaca anlat.'**
  String get descriptionRequired;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gönder'**
  String get send;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Destek ve geri bildirim'**
  String get supportTitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bir sorun, talep ya da istek için platform ekibine yazabilirsin.'**
  String get emptyIntro;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Mesajların platform ekibine iletilir; yanıtları ve durumlarını buradan izleyebilirsin.'**
  String get listIntro;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yeni yanıt'**
  String get newReply;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Mesaj'**
  String get message;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu mesaj bulunamadı.'**
  String get notFound;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Geri dön'**
  String get goBack;

  ///
  ///
  /// In tr, this message translates to:
  /// **'GWAY Ekibi'**
  String get team;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sen'**
  String get you;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ekran görüntüsü ekle'**
  String get addScreenshot;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yanıt yaz'**
  String get writeReply;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Görseli kaldır'**
  String get removeImage;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ekran görüntüsü ({count}/{max})'**
  String screenshots(int count, int max);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ekran görüntüsünü büyüt'**
  String get enlargeScreenshot;
}

class _SupportL10nDelegate extends LocalizationsDelegate<SupportL10n> {
  const _SupportL10nDelegate();

  @override
  Future<SupportL10n> load(Locale locale) {
    return SynchronousFuture<SupportL10n>(lookupSupportL10n(locale));
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
  bool shouldReload(_SupportL10nDelegate old) => false;
}

SupportL10n lookupSupportL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return SupportL10nAr();
    case 'az':
      return SupportL10nAz();
    case 'de':
      return SupportL10nDe();
    case 'en':
      return SupportL10nEn();
    case 'es':
      return SupportL10nEs();
    case 'fr':
      return SupportL10nFr();
    case 'it':
      return SupportL10nIt();
    case 'nl':
      return SupportL10nNl();
    case 'pt':
      return SupportL10nPt();
    case 'ru':
      return SupportL10nRu();
    case 'tr':
      return SupportL10nTr();
    case 'uk':
      return SupportL10nUk();
  }

  throw FlutterError(
    'SupportL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
