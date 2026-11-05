import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'design_system_l10n_ar.dart';
import 'design_system_l10n_az.dart';
import 'design_system_l10n_de.dart';
import 'design_system_l10n_en.dart';
import 'design_system_l10n_es.dart';
import 'design_system_l10n_fr.dart';
import 'design_system_l10n_it.dart';
import 'design_system_l10n_nl.dart';
import 'design_system_l10n_pt.dart';
import 'design_system_l10n_ru.dart';
import 'design_system_l10n_tr.dart';
import 'design_system_l10n_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of DesignSystemL10n
/// returned by `DesignSystemL10n.of(context)`.
///
/// Applications need to include `DesignSystemL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/design_system_l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: DesignSystemL10n.localizationsDelegates,
///   supportedLocales: DesignSystemL10n.supportedLocales,
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
/// be consistent with the languages listed in the DesignSystemL10n.supportedLocales
/// property.
abstract class DesignSystemL10n {
  DesignSystemL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static DesignSystemL10n of(BuildContext context) {
    return Localizations.of<DesignSystemL10n>(context, DesignSystemL10n)!;
  }

  static const LocalizationsDelegate<DesignSystemL10n> delegate =
      _DesignSystemL10nDelegate();

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

  /// Screen reader label of a busy button
  ///
  /// In tr, this message translates to:
  /// **'{label}, yükleniyor'**
  String loadingLabel(String label);

  /// Scroll a chip rail back
  ///
  /// In tr, this message translates to:
  /// **'Öncekiler'**
  String get previous;

  /// Scroll a chip rail forward
  ///
  /// In tr, this message translates to:
  /// **'Sonrakiler'**
  String get next;

  /// Screen reader label of a cover image
  ///
  /// In tr, this message translates to:
  /// **'Kapak fotoğrafı'**
  String get coverPhoto;

  /// Error state action
  ///
  /// In tr, this message translates to:
  /// **'Tekrar dene'**
  String get retry;

  /// Screen reader label of the live badge
  ///
  /// In tr, this message translates to:
  /// **'Canlı yayın'**
  String get liveBroadcast;

  /// Short upper-case live badge text
  ///
  /// In tr, this message translates to:
  /// **'CANLI'**
  String get liveBadge;
}

class _DesignSystemL10nDelegate
    extends LocalizationsDelegate<DesignSystemL10n> {
  const _DesignSystemL10nDelegate();

  @override
  Future<DesignSystemL10n> load(Locale locale) {
    return SynchronousFuture<DesignSystemL10n>(lookupDesignSystemL10n(locale));
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
  bool shouldReload(_DesignSystemL10nDelegate old) => false;
}

DesignSystemL10n lookupDesignSystemL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return DesignSystemL10nAr();
    case 'az':
      return DesignSystemL10nAz();
    case 'de':
      return DesignSystemL10nDe();
    case 'en':
      return DesignSystemL10nEn();
    case 'es':
      return DesignSystemL10nEs();
    case 'fr':
      return DesignSystemL10nFr();
    case 'it':
      return DesignSystemL10nIt();
    case 'nl':
      return DesignSystemL10nNl();
    case 'pt':
      return DesignSystemL10nPt();
    case 'ru':
      return DesignSystemL10nRu();
    case 'tr':
      return DesignSystemL10nTr();
    case 'uk':
      return DesignSystemL10nUk();
  }

  throw FlutterError(
    'DesignSystemL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
