import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'core_l10n_ar.dart';
import 'core_l10n_az.dart';
import 'core_l10n_de.dart';
import 'core_l10n_en.dart';
import 'core_l10n_es.dart';
import 'core_l10n_fr.dart';
import 'core_l10n_it.dart';
import 'core_l10n_nl.dart';
import 'core_l10n_pt.dart';
import 'core_l10n_ru.dart';
import 'core_l10n_tr.dart';
import 'core_l10n_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of CoreL10n
/// returned by `CoreL10n.of(context)`.
///
/// Applications need to include `CoreL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/core_l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: CoreL10n.localizationsDelegates,
///   supportedLocales: CoreL10n.supportedLocales,
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
/// be consistent with the languages listed in the CoreL10n.supportedLocales
/// property.
abstract class CoreL10n {
  CoreL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static CoreL10n of(BuildContext context) {
    return Localizations.of<CoreL10n>(context, CoreL10n)!;
  }

  static const LocalizationsDelegate<CoreL10n> delegate = _CoreL10nDelegate();

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

  /// No connection or server unreachable
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı kurulamadı. İnternet bağlantını kontrol edip tekrar dene.'**
  String get networkFailure;

  /// Session expired
  ///
  /// In tr, this message translates to:
  /// **'Oturumun sona erdi. Lütfen tekrar giriş yap.'**
  String get unauthorizedFailure;

  /// No permission for the action
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem için yetkin yok.'**
  String get forbiddenFailure;

  /// Content not found
  ///
  /// In tr, this message translates to:
  /// **'Aradığın içerik bulunamadı.'**
  String get notFoundFailure;

  /// Too many attempts
  ///
  /// In tr, this message translates to:
  /// **'Çok fazla deneme yapıldı. Biraz bekleyip tekrar dene.'**
  String get rateLimitedFailure;

  /// Any other error
  ///
  /// In tr, this message translates to:
  /// **'Bir şeyler ters gitti. Lütfen tekrar dene.'**
  String get unexpectedFailure;

  /// Uploaded file over 5 MB
  ///
  /// In tr, this message translates to:
  /// **'Dosya çok büyük. En fazla 5 MB yükleyebilirsin.'**
  String get storageTooLarge;

  /// Uploaded file of an unsupported type
  ///
  /// In tr, this message translates to:
  /// **'Bu dosya türü desteklenmiyor. JPEG, PNG veya WebP seç.'**
  String get storageUnsupportedType;

  /// Category
  ///
  /// In tr, this message translates to:
  /// **'Müzik'**
  String get categoryMusic;

  /// Category
  ///
  /// In tr, this message translates to:
  /// **'Yürüyüş'**
  String get categoryHiking;

  /// Category
  ///
  /// In tr, this message translates to:
  /// **'Koşu'**
  String get categoryRunning;

  /// Category
  ///
  /// In tr, this message translates to:
  /// **'Bisiklet'**
  String get categoryCycling;

  /// Category
  ///
  /// In tr, this message translates to:
  /// **'Doğa'**
  String get categoryNature;

  /// Category
  ///
  /// In tr, this message translates to:
  /// **'Spor'**
  String get categorySports;

  /// Category
  ///
  /// In tr, this message translates to:
  /// **'Sanat'**
  String get categoryArt;

  /// Category
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf'**
  String get categoryPhotography;

  /// Category
  ///
  /// In tr, this message translates to:
  /// **'Dans'**
  String get categoryDance;

  /// Category
  ///
  /// In tr, this message translates to:
  /// **'Kitap'**
  String get categoryBooks;

  /// Category
  ///
  /// In tr, this message translates to:
  /// **'Oyun'**
  String get categoryGames;

  /// Category
  ///
  /// In tr, this message translates to:
  /// **'Seyahat'**
  String get categoryTravel;

  /// Category
  ///
  /// In tr, this message translates to:
  /// **'Yemek'**
  String get categoryFood;

  /// Category
  ///
  /// In tr, this message translates to:
  /// **'Teknoloji'**
  String get categoryTechnology;

  /// Category
  ///
  /// In tr, this message translates to:
  /// **'Gönüllülük'**
  String get categoryVolunteering;

  /// Category
  ///
  /// In tr, this message translates to:
  /// **'Motosiklet'**
  String get categoryMotorcycle;

  /// Category
  ///
  /// In tr, this message translates to:
  /// **'Kamp'**
  String get categoryCamping;

  /// Category
  ///
  /// In tr, this message translates to:
  /// **'Satranç'**
  String get categoryChess;
}

class _CoreL10nDelegate extends LocalizationsDelegate<CoreL10n> {
  const _CoreL10nDelegate();

  @override
  Future<CoreL10n> load(Locale locale) {
    return SynchronousFuture<CoreL10n>(lookupCoreL10n(locale));
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
  bool shouldReload(_CoreL10nDelegate old) => false;
}

CoreL10n lookupCoreL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return CoreL10nAr();
    case 'az':
      return CoreL10nAz();
    case 'de':
      return CoreL10nDe();
    case 'en':
      return CoreL10nEn();
    case 'es':
      return CoreL10nEs();
    case 'fr':
      return CoreL10nFr();
    case 'it':
      return CoreL10nIt();
    case 'nl':
      return CoreL10nNl();
    case 'pt':
      return CoreL10nPt();
    case 'ru':
      return CoreL10nRu();
    case 'tr':
      return CoreL10nTr();
    case 'uk':
      return CoreL10nUk();
  }

  throw FlutterError(
    'CoreL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
