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

  ///
  ///
  /// In tr, this message translates to:
  /// **'Takım maçı'**
  String get teamMatch;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Takım maçları'**
  String get teamMatches;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gruplarının satranç maçları; sonuç grup Elo puanını değiştirir.'**
  String get teamMatchesHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Henüz takım maçı yok. Grubun adına başka bir grubu davet et.'**
  String get noTeamMatches;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Takım maçı düzenle'**
  String get newTeamMatch;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Karşı grubun yöneticisi kabul edince iki grup da tahtalara oyuncularını dizer.'**
  String get newTeamMatchHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grubun'**
  String get yourGroup;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Rakip grup'**
  String get opponentGroup;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grup adı ya da kullanıcı adı'**
  String get searchGroup;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç'**
  String get startsAt;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grubu davet et'**
  String get sendTeamInvite;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Tahtalar'**
  String get boards;

  ///
  ///
  /// In tr, this message translates to:
  /// **'tahta'**
  String get boardsShort;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} tahta'**
  String boardsCount(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grup Elo {rating}'**
  String groupElo(int rating);

  ///
  ///
  /// In tr, this message translates to:
  /// **'VS'**
  String get versus;

  ///
  ///
  /// In tr, this message translates to:
  /// **'–'**
  String get versusShort;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yanıt bekleniyor'**
  String get teamInvited;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kabul edildi'**
  String get teamAccepted;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Reddedildi'**
  String get teamDeclined;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İptal edildi'**
  String get teamCanceled;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Oynanıyor'**
  String get teamLive;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bitti'**
  String get teamFinished;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{group} grubunuzu takım maçına davet ediyor.'**
  String teamInviteReceived(String group);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Maç kabul edildi. Şimdi oyuncularınızı dizin.'**
  String get teamAcceptedDone;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Davet reddedildi.'**
  String get teamDeclinedDone;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Maç iptal edildi.'**
  String get teamCanceledDone;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Maçı iptal et'**
  String get callOff;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Başlangıçta boş kalan tahta rakibe puan olarak yazılır.'**
  String get lineupHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Üyelere dokunarak sırayla tahtalara yerleştir; 1. tahta en güçlü oyuncunundur.'**
  String get lineupSheetHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{group} dizilişi'**
  String editLineup(String group);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Dizilişi kaydet'**
  String get saveLineup;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Boş'**
  String get emptyBoard;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Elo {rating} · {games} oyun'**
  String ratingGames(int rating, int games);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gruplar'**
  String get groupsTab;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Henüz takım maçı oynayan grup yok. İlk maçı grubun düzenlesin.'**
  String get groupLeaderboardEmpty;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Satranca dön'**
  String get backToChess;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Turnuva'**
  String get arena;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Turnuvalar'**
  String get tournaments;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Haftalık ve aylık Arena turnuvaları; ilk üç madalya alır.'**
  String get tournamentsHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Haftalık Arena'**
  String get weeklyArena;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Aylık Arena'**
  String get monthlyArena;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Arena: süre boyunca istediğin kadar oyna. Kazanma 2, beraberlik 1 puan; üst üste iki galibiyetten sonra seri bitene kadar puanlar ikiye katlanır. Bitmeden başlayan oyunlar sayılır.'**
  String get arenaRules;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şimdi oynanıyor'**
  String get arenaLiveNow;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yaklaşan'**
  String get arenaUpcoming;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bitenler'**
  String get arenaFinished;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlısın'**
  String get registered;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kayıt ol'**
  String get arenaRegister;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlısın. Turnuva başlayınca bildirim alırsın; açınca hemen eşleşirsin.'**
  String get arenaRegistered;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Katıl'**
  String get arenaJoin;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Oynamaya devam et'**
  String get arenaResume;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ara ver'**
  String get arenaPause;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Rakip bekleniyor; puanı yakın biri boşalınca oyun kendiliğinden açılır.'**
  String get arenaWaiting;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Oyuna dön'**
  String get backToGame;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Turnuvaya dön'**
  String get backToArena;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Takım maçına dön'**
  String get backToTeamMatch;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{time} sonra başlıyor'**
  String arenaStartsIn(String time);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bitişe {time}'**
  String arenaEndsIn(String time);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Süre doldu; son oyunlar bitiyor'**
  String get arenaLastGames;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bitti · {time}'**
  String arenaFinishedAt(String time);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{hours} sa {minutes} dk'**
  String hoursMinutes(int hours, int minutes);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} dakika'**
  String minutesLong(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} oyuncu'**
  String playersCount(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{points} puan · {games} oyun'**
  String myArenaScore(int points, int games);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Seride: sonraki sonuç iki kat puan'**
  String get onFire;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Puan durumu'**
  String get standings;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Henüz katılan yok. İlk sen katıl.'**
  String get arenaEmpty;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Performans {value}'**
  String performance(int value);

  ///
  ///
  /// In tr, this message translates to:
  /// **'oynuyor'**
  String get playingNow;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Turnuva madalyaları'**
  String get arenaMedals;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Turnuva madalyaları: {gold} altın, {silver} gümüş, {bronze} bronz'**
  String medalsSummary(int gold, int silver, int bronze);

  ///
  ///
  /// In tr, this message translates to:
  /// **'İlk hamle: 5 dk'**
  String get firstMoveTeam;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Oyunlar'**
  String get games;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Topluluğunla oyna: hızlı oyunlar, turnuvalar ve gruplar arası maçlar.'**
  String get gamesIntro;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Elo puanı, haftalık ve aylık turnuvalar, gruplar arası takım maçları ve madalyalar.'**
  String get chessCardText;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Satranç oyna'**
  String get playChess;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Blitz {rating}'**
  String blitzRating(int rating);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sıradaki turnuva: {time}'**
  String nextArena(String time);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} davet bekliyor'**
  String invitesWaiting(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Çevrimiçi oyna'**
  String get playOnline;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Rakip bul · {tc}'**
  String findOpponent(String tc);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Süreyi ve rengi sen seç'**
  String get challengeFriendHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Elo sıralaması ve madalyalar'**
  String get leaderboardHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} açık maç'**
  String openTeamMatches(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Tahta ve taşlar'**
  String get appearance;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Tahta'**
  String get boardTheme;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Taşlar'**
  String get pieceSet;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ahşap'**
  String get boardWood;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yeşil'**
  String get boardGreen;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Mavi'**
  String get boardBlue;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gri'**
  String get boardSlate;

  ///
  ///
  /// In tr, this message translates to:
  /// **'GWAY moru'**
  String get boardLilac;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Klasik'**
  String get piecesClassic;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kelt'**
  String get piecesCeltic;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Uzay'**
  String get piecesSpatial;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Fantastik'**
  String get piecesFantasy;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Modern'**
  String get piecesModern;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sıcak'**
  String get piecesWarm;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç'**
  String get firstPosition;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Önceki hamle'**
  String get previousMove;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sonraki hamle'**
  String get nextMove;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Son konum'**
  String get lastPosition;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Canlıya dön'**
  String get backToLive;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{points} puan'**
  String pointsShort(int points);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{key, select, red_m{kırmızı} red_f{kırmızı} red_n{kırmızı} blue_m{mavi} blue_f{mavi} blue_n{mavi} green_m{yeşil} green_f{yeşil} green_n{yeşil} yellow_m{sarı} yellow_f{sarı} yellow_n{sarı} purple_m{mor} purple_f{mor} purple_n{mor} orange_m{turuncu} orange_f{turuncu} orange_n{turuncu} other{}}'**
  String mindColorWord(String key);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{key, select, solid_m{düz} solid_f{düz} solid_n{düz} striped_m{çizgili} striped_f{çizgili} striped_n{çizgili} dotted_m{noktalı} dotted_f{noktalı} dotted_n{noktalı} other{}}'**
  String mindPatternWord(String key);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{shape, select, circle{yuvarlak} square{kare} triangle{üçgen} star{yıldız} other{}}'**
  String mindShapeWord(String shape);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{shape, select, circle{m} square{m} triangle{m} star{m} other{}}'**
  String mindShapeGender(String shape);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{color} {pattern} {shape}'**
  String mindFigure(String color, String pattern, String shape);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Zihin Düellosu'**
  String get mindDuel;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Matematik, dikkat, hafıza ve refleks sorularında canlı düello. Elo puanı, sıralama ve madalyalar.'**
  String get mindCardText;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Düelloya başla'**
  String get mindPlay;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Elo {rating} · {length} soru'**
  String mindBestRating(int rating, int length);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} soru'**
  String mindQuestions(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kaç soru?'**
  String get mindHowMany;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} soruda puanın'**
  String mindRatingAt(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Rakip bul'**
  String get mindFindOpponent;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Oyun oynaman şu anda kapalı.'**
  String get mindSuspended;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Süren bir düellon var'**
  String get mindActive;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Düello profili'**
  String get mindProfile;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Nasıl oynanır'**
  String get mindHowTo;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Son düellolar'**
  String get mindRecent;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Henüz düellon yok. İlk rakibini bul.'**
  String get mindNoMatchesMine;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Henüz düellosu yok. İlk düellosuna sen davet et.'**
  String get mindNoMatchesTheirs;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Düelloya davet et'**
  String get mindChallengeTitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Davet gönderildi. Kabul edince düello başlar.'**
  String get mindChallengeSent;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Matematik'**
  String get mindKindMath;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Dikkat'**
  String get mindKindAttention;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hafıza'**
  String get mindKindMemory;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Refleks'**
  String get mindKindReflex;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Dört işlem, işlem önceliğiyle. Doğru sonucu seç.'**
  String get mindKindMathHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yazının rengine değil, anlattığı şekle bak.'**
  String get mindKindAttentionHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Renkli harf ve rakamları sırasıyla ve renkleriyle hatırla.'**
  String get mindKindMemoryHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yanan yuvarlaklara aynı sırayla, hızla dokun. Yanlış yuvarlak denemeyi bitirir.'**
  String get mindKindReflexHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Doğru ve hızlı cevap daha çok puan getirir. Toplam puanı yüksek olan kazanır.'**
  String get mindScoringHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sen'**
  String get mindYou;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Rakip'**
  String get mindOpponent;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{who}: {done}/{total} soru'**
  String mindProgress(String who, int done, int total);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{n}/{total}'**
  String mindQuestionOf(int n, int total);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hazır ol'**
  String get mindGetReady;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bitirdin!'**
  String get mindYouFinished;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Rakibin {done}/{total}. soruda. Bitirince sonuç çıkar.'**
  String mindOpponentAt(int done, int total);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sonuç kaç?'**
  String get mindMathPrompt;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yazının anlattığı şekli seç'**
  String get mindAttentionPrompt;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sırayı ve renkleri aklında tut'**
  String get mindMemoryLook;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Aynı sırayla ve renkleriyle seç'**
  String get mindMemoryPick;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{color} {char}'**
  String mindCharLabel(String char, String color);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Geri al'**
  String get mindUndo;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Doğru · +{points}'**
  String mindRight(int points);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kısmen doğru · +{points}'**
  String mindPartly(int points);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yanlış'**
  String get mindWrong;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yanlış · −{points}'**
  String mindWrongPenalty(int points);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Düellodan çekil?'**
  String get mindResignTitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Rakibin kazanır; puanlı düelloda Elo puanın düşer.'**
  String get mindResignBody;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Düello bitti'**
  String get mindFinished;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bütün sorular cevaplandı'**
  String get mindEndCompleted;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Süre doldu'**
  String get mindEndTime;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yeni puanın {rating}'**
  String mindNewRating(int rating);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yeni düello'**
  String get mindNewDuel;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Düello sayfasına dön'**
  String get mindBackHome;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grup düelloları'**
  String get mindTeamMatches;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grubunun başka gruplarla düelloları; sonuç grubun düello Elo puanını değiştirir.'**
  String get mindTeamMatchesHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Henüz grup düellosu yok. Grubun adına başka bir grubu davet et.'**
  String get mindNoTeamMatches;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grup düellosu düzenle'**
  String get mindNewTeamMatch;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Karşı grubun yöneticisi kabul edince iki grup da oyuncularını sıralar. Başlangıçta her sıradaki iki kişi aynı anda düello eder.'**
  String get mindNewTeamHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grup düellosu'**
  String get mindTeamMatch;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sıralar'**
  String get mindSeats;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} sıra'**
  String mindSeatsCount(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Başlangıçta boş kalan sıra rakibe puan olarak yazılır. Grup düellosunda ilk soru için 5 dakika beklenir.'**
  String get mindLineupHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Henüz grup düellosu oynayan grup yok. İlk düelloyu grubun düzenlesin.'**
  String get mindGroupLeaderboardEmpty;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Turnuvalar'**
  String get mindTournaments;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Her cumartesi 21:00 haftalık (10 soru), ayın son cumartesi 19:00 aylık (20 soru); ilk üç madalya alır.'**
  String get mindTournamentsHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yaklaşan turnuva yok.'**
  String get mindNoTournaments;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Pro'**
  String get piecesPro;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kâğıt'**
  String get piecesPaper;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Satranç seviyeni seç'**
  String get levelTitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Puanın seçtiğin seviyeden başlar ve ilk oyunlarında gerçek seviyene hızla oturur.'**
  String get levelBody;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İlk puanlı oyunundan önce bir kez seçilir.'**
  String get levelPrompt;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yeni başlayan'**
  String get levelNew;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Taşların nasıl oynadığını öğreniyorum.'**
  String get levelNewHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç'**
  String get levelBeginner;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kuralları biliyorum, ara sıra oynarım.'**
  String get levelBeginnerHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Orta'**
  String get levelIntermediate;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Düzenli oynarım, temel taktikleri bilirim.'**
  String get levelIntermediateHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İleri'**
  String get levelAdvanced;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Açılış ve oyun sonu bilgim iyi.'**
  String get levelAdvancedHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Usta'**
  String get levelMaster;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Turnuvalarda oynarım.'**
  String get levelMasterHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Puanlı oyun oynadıktan sonra seviye değiştirilemez.'**
  String get levelNote;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Seviyen kaydedildi: {rating} puanla başlıyorsun.'**
  String levelSaved(int rating);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu türde henüz puanlı oyun yok. İlk oyunu sen oyna.'**
  String get leaderboardNoGames;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Puanlar ilk oyunlarda oturuyor; ilk sıralar yakında burada.'**
  String get leaderboardSettling;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Puanı oturan oyuncular'**
  String get provisionalPlayers;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Puan geçici (?); birkaç oyun sonra sıralamaya girer.'**
  String get provisionalPlayersHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Geçici puan'**
  String get provisionalShort;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Senin sıran'**
  String get yourPlace;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Oyuncu'**
  String get columnPlayer;

  ///
  ///
  /// In tr, this message translates to:
  /// **'30 gün'**
  String get column30Days;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Puan'**
  String get columnRating;

  ///
  ///
  /// In tr, this message translates to:
  /// **'%{percent} skor'**
  String winRate(int percent);

  ///
  ///
  /// In tr, this message translates to:
  /// **'En yüksek {rating}'**
  String peakRating(int rating);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Puanlar Glicko-2 sistemiyle hesaplanır. \"?\" işareti puanın henüz oturmadığını gösterir.'**
  String get ratingSystemNote;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Seviye {level}'**
  String mindLevel(int level);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Işıkları izle'**
  String get mindLightsWatch;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Aynı sırayla dokun'**
  String get mindLightsRepeat;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yuvarlak {number}'**
  String mindLightLabel(int number);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Doğru'**
  String get mindStatCorrect;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Soru başına'**
  String get mindStatAverage;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Puan'**
  String get mindStatRating;
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
