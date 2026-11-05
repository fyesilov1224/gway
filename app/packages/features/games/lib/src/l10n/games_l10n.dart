import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'games_l10n_ar.dart';
import 'games_l10n_az.dart';
import 'games_l10n_de.dart';
import 'games_l10n_en.dart';
import 'games_l10n_es.dart';
import 'games_l10n_fr.dart';
import 'games_l10n_it.dart';
import 'games_l10n_nl.dart';
import 'games_l10n_pt.dart';
import 'games_l10n_ru.dart';
import 'games_l10n_tr.dart';
import 'games_l10n_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of GamesL10n
/// returned by `GamesL10n.of(context)`.
///
/// Applications need to include `GamesL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/games_l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: GamesL10n.localizationsDelegates,
///   supportedLocales: GamesL10n.supportedLocales,
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
/// be consistent with the languages listed in the GamesL10n.supportedLocales
/// property.
abstract class GamesL10n {
  GamesL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static GamesL10n of(BuildContext context) {
    return Localizations.of<GamesL10n>(context, GamesL10n)!;
  }

  static const LocalizationsDelegate<GamesL10n> delegate = _GamesL10nDelegate();

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
  /// **'Satranç'**
  String get chess;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bullet'**
  String get bullet;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Blitz'**
  String get blitz;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Rapid'**
  String get rapid;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Beyaz'**
  String get white;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Siyah'**
  String get black;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Rastgele'**
  String get colorRandom;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Mat'**
  String get endCheckmate;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Terk'**
  String get endResign;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Süre bitti'**
  String get endTimeout;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Süre bitti, rakibin mat edecek taşı yok'**
  String get endTimeoutDraw;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Pat'**
  String get endStalemate;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yetersiz materyal'**
  String get endInsufficient;

  ///
  ///
  /// In tr, this message translates to:
  /// **'50 hamle kuralı'**
  String get endFiftyMoves;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Üç kez tekrar'**
  String get endRepetition;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Anlaşmalı beraberlik'**
  String get endAgreement;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İptal edildi'**
  String get endAborted;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Satranç tahtası'**
  String get boardLabel;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Piyon neye dönüşsün?'**
  String get promoteTo;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Vezir'**
  String get queen;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kale'**
  String get rook;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Fil'**
  String get bishop;

  ///
  ///
  /// In tr, this message translates to:
  /// **'At'**
  String get knight;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Altın madalya'**
  String get medalGold;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gümüş madalya'**
  String get medalSilver;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bronz madalya'**
  String get medalBronze;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kazandın'**
  String get youWon;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kaybettin'**
  String get youLost;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Berabere'**
  String get draw;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sürüyor'**
  String get inProgress;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Beyaz kazandı'**
  String get whiteWon;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Siyah kazandı'**
  String get blackWon;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Puanlı'**
  String get rated;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Puansız'**
  String get casual;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sonuç Elo puanını değiştirir.'**
  String get ratedHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Tahtayı çevir'**
  String get flipBoard;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get cancel;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Terk et'**
  String get resign;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Oyunu terk et?'**
  String get resignTitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Rakibin kazanır; puanlı oyunda Elo puanın düşer.'**
  String get resignBody;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İptal et'**
  String get abort;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Berabere?'**
  String get offerDraw;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Teklif edildi'**
  String get drawOffered;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Rakibin beraberlik teklif ediyor.'**
  String get drawOfferReceived;

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
  /// **'Rövanş'**
  String get rematch;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Rövanş isteği gönderildi.'**
  String get rematchSent;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yeni oyun'**
  String get newGame;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{category} puanın: {rating}'**
  String newRating(String category, int rating);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Silinmiş hesap'**
  String get deletedPlayer;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İlk hamle: 30 sn'**
  String get firstMove;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Henüz hamle yok. Beyaz başlar.'**
  String get noMovesYet;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İzliyorsun'**
  String get watching;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hızlı oyun'**
  String get quickGame;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Süreyi seç, sana yakın puanda biriyle eşleş.'**
  String get quickGameHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Rakip aranıyor…'**
  String get searching;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} saniyedir bekliyorsun'**
  String waitedSeconds(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Satranç profili'**
  String get chessProfile;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Son oyunlar'**
  String get recentGames;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Henüz oyunun yok. İlk oyununu oyna.'**
  String get noGamesMine;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Henüz oyunu yok. İlk oyununa sen davet et.'**
  String get noGamesTheirs;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hemen oyna'**
  String get playNow;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Davet et'**
  String get challenge;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bayrak seçilmedi'**
  String get noFlag;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bayrağını seç'**
  String get chooseFlag;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sıralamada adının yanında görünür.'**
  String get chooseFlagHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ülke ara'**
  String get searchCountry;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bayrağın kaydedildi.'**
  String get flagSaved;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sıralamada görünecek bayrağını seç.'**
  String get pickFlagPrompt;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Satranç oynaması şu anda kapalı.'**
  String get suspendedNotice;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Oynanmadı'**
  String get notPlayed;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} oyun'**
  String gamesCount(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{rank}. sırada'**
  String rankShort(int rank);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sıralama'**
  String get leaderboard;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sıralamaya girmek için bu türde {count} puanlı oyun oyna.'**
  String leaderboardEmpty(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{wins}G · {draws}B · {losses}M'**
  String record(int wins, int draws, int losses);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Tümünü gör'**
  String get seeAll;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Davetler'**
  String get invitations;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Seni oyuna davet ediyor: {what}'**
  String invitesYou(String what);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Rövanş istiyor: {what}'**
  String wantsRematch(String what);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yanıt bekleniyor: {what}'**
  String waitingFor(String what);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Geri çek'**
  String get withdraw;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Süren oyunun var'**
  String get gameInProgress;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Devam et'**
  String get resume;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bir arkadaşını davet et'**
  String get challengeFriend;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Davet gönderildi. Kabul edince oyun başlar.'**
  String get challengeSent;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Oyuna davet et'**
  String get challengeTitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kişiyi değiştir'**
  String get changePerson;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı adı ya da isim'**
  String get searchPerson;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Süre'**
  String get timeControl;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Rengin'**
  String get yourColor;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Daveti gönder'**
  String get sendChallenge;
}

class _GamesL10nDelegate extends LocalizationsDelegate<GamesL10n> {
  const _GamesL10nDelegate();

  @override
  Future<GamesL10n> load(Locale locale) {
    return SynchronousFuture<GamesL10n>(lookupGamesL10n(locale));
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
  bool shouldReload(_GamesL10nDelegate old) => false;
}

GamesL10n lookupGamesL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return GamesL10nAr();
    case 'az':
      return GamesL10nAz();
    case 'de':
      return GamesL10nDe();
    case 'en':
      return GamesL10nEn();
    case 'es':
      return GamesL10nEs();
    case 'fr':
      return GamesL10nFr();
    case 'it':
      return GamesL10nIt();
    case 'nl':
      return GamesL10nNl();
    case 'pt':
      return GamesL10nPt();
    case 'ru':
      return GamesL10nRu();
    case 'tr':
      return GamesL10nTr();
    case 'uk':
      return GamesL10nUk();
  }

  throw FlutterError(
    'GamesL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
