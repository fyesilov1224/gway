import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'notifications_l10n_ar.dart';
import 'notifications_l10n_az.dart';
import 'notifications_l10n_de.dart';
import 'notifications_l10n_en.dart';
import 'notifications_l10n_es.dart';
import 'notifications_l10n_fr.dart';
import 'notifications_l10n_it.dart';
import 'notifications_l10n_nl.dart';
import 'notifications_l10n_pt.dart';
import 'notifications_l10n_ru.dart';
import 'notifications_l10n_tr.dart';
import 'notifications_l10n_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of NotificationsL10n
/// returned by `NotificationsL10n.of(context)`.
///
/// Applications need to include `NotificationsL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/notifications_l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: NotificationsL10n.localizationsDelegates,
///   supportedLocales: NotificationsL10n.supportedLocales,
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
/// be consistent with the languages listed in the NotificationsL10n.supportedLocales
/// property.
abstract class NotificationsL10n {
  NotificationsL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static NotificationsL10n of(BuildContext context) {
    return Localizations.of<NotificationsL10n>(context, NotificationsL10n)!;
  }

  static const LocalizationsDelegate<NotificationsL10n> delegate =
      _NotificationsL10nDelegate();

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
  /// **'gönderini beğendi.'**
  String get actLike;

  ///
  ///
  /// In tr, this message translates to:
  /// **'yorum yaptı: {text}'**
  String actComment(String text);

  ///
  ///
  /// In tr, this message translates to:
  /// **'yorumuna yanıt verdi: {text}'**
  String actReply(String text);

  ///
  ///
  /// In tr, this message translates to:
  /// **'yorumunu beğendi: {text}'**
  String actCommentLike(String text);

  ///
  ///
  /// In tr, this message translates to:
  /// **'bir gönderide senden bahsetti.'**
  String get actMentionPost;

  ///
  ///
  /// In tr, this message translates to:
  /// **'bir yorumda senden bahsetti: {text}'**
  String actMentionComment(String text);

  ///
  ///
  /// In tr, this message translates to:
  /// **'seni takip etmeye başladı.'**
  String get actFollow;

  ///
  ///
  /// In tr, this message translates to:
  /// **'seni takip etmek istiyor.'**
  String get actFollowRequest;

  ///
  ///
  /// In tr, this message translates to:
  /// **'takip isteğini kabul etti.'**
  String get actFollowAccepted;

  ///
  ///
  /// In tr, this message translates to:
  /// **'canlı yayın planladı: {title}'**
  String actLiveScheduled(String title);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{date} için canlı yayın planladı: {title}'**
  String actLiveScheduledAt(String date, String title);

  ///
  ///
  /// In tr, this message translates to:
  /// **'canlı yayına başladı: {title}'**
  String actLiveStarted(String title);

  ///
  ///
  /// In tr, this message translates to:
  /// **'\"{title}\" için yer açıldı, artık katılıyorsun.'**
  String actEventPromoted(String title);

  ///
  ///
  /// In tr, this message translates to:
  /// **'\"{title}\" organizasyonunun zamanını ya da yerini değiştirdi.'**
  String actEventUpdated(String title);

  ///
  ///
  /// In tr, this message translates to:
  /// **'\"{title}\" organizasyonunu iptal etti.'**
  String actEventCanceled(String title);

  ///
  ///
  /// In tr, this message translates to:
  /// **'\"{title}\" yarın başlıyor. Geliyor musun? Teyit et.'**
  String actReminderTomorrow(String title);

  ///
  ///
  /// In tr, this message translates to:
  /// **'\"{title}\" 1 saat içinde başlıyor.'**
  String actReminderHour(String title);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{group} grubunda bir disiplin dosyası açtı; oyunu bekliyor.'**
  String actCaseVote(String group);

  ///
  ///
  /// In tr, this message translates to:
  /// **'grubunda susturuldun. Ayrıntılar ve itiraz için dokun.'**
  String get actMuted;

  ///
  ///
  /// In tr, this message translates to:
  /// **'grubundan çıkarıldın. Ayrıntılar ve itiraz için dokun.'**
  String get actKicked;

  ///
  ///
  /// In tr, this message translates to:
  /// **'grubundan uzaklaştırıldın. Ayrıntılar ve itiraz için dokun.'**
  String get actBanned;

  ///
  ///
  /// In tr, this message translates to:
  /// **'grubu sana uyarı verdi. Ayrıntılar ve itiraz için dokun.'**
  String get actWarned;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{group} grubundaki yaptırıma itiraz etti.'**
  String actAppealSubmitted(String group);

  ///
  ///
  /// In tr, this message translates to:
  /// **'grubu itirazını karara bağladı.'**
  String get actAppealDecided;

  ///
  ///
  /// In tr, this message translates to:
  /// **'\"{title}\" için katılım isteğini onayladı.'**
  String actEventApproved(String title);

  ///
  ///
  /// In tr, this message translates to:
  /// **'\"{title}\" için katılım isteğini kabul edemedi.'**
  String actEventDeclined(String title);

  ///
  ///
  /// In tr, this message translates to:
  /// **'\"{title}\" nasıldı? Değerlendir, anılarını paylaş.'**
  String actEventReview(String title);

  ///
  ///
  /// In tr, this message translates to:
  /// **'\"{title}\" hedefini tamamladın! Rozetin profilinde.'**
  String actGoalCompleted(String title);

  ///
  ///
  /// In tr, this message translates to:
  /// **'seninle ekip arkadaşı olmak istiyor.'**
  String get actTeammateRequest;

  ///
  ///
  /// In tr, this message translates to:
  /// **'ekip arkadaşlığı isteğini kabul etti.'**
  String get actTeammateAccepted;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kim olduğunu Eşleşmelerim\'de gör.'**
  String get actMatchCreated;

  ///
  ///
  /// In tr, this message translates to:
  /// **'seni süper beğendi! Destende ilk o görünüyor.'**
  String get actSuperLiked;

  ///
  ///
  /// In tr, this message translates to:
  /// **'\"{title}\" organizasyonuna ilk kez geliyor ve karşılanmak istiyor.'**
  String actWelcomeRequested(String title);

  ///
  ///
  /// In tr, this message translates to:
  /// **'\"{title}\" organizasyonunda seni karşılayacak. Buluşma notunu gör.'**
  String actWelcomeMatched(String title);

  ///
  ///
  /// In tr, this message translates to:
  /// **'\"{title}\" için karşılamayı bıraktı; yeni bir karşılayıcı aranıyor.'**
  String actWelcomeReleased(String title);

  ///
  ///
  /// In tr, this message translates to:
  /// **'\"{title}\" için karşılama isteğini geri çekti.'**
  String actWelcomeWithdrawn(String title);

  ///
  ///
  /// In tr, this message translates to:
  /// **'geçen ayın liginde ilk üçe girdi! Sıralamayı ve derecesini grup sayfasında gör.'**
  String get actLeagueResult;

  ///
  ///
  /// In tr, this message translates to:
  /// **'\"{title}\" organizasyonunda onu karşıladığın için teşekkür etti.'**
  String actWelcomeThanked(String title);

  ///
  ///
  /// In tr, this message translates to:
  /// **'bu akşam küçük bir masa kurdu ve seni de çağırıyor.'**
  String get actTableInvite;

  ///
  ///
  /// In tr, this message translates to:
  /// **'masaya katıldı; masa kuruldu. Yeri ve saati sohbette konuşun.'**
  String get actTableReady;

  ///
  ///
  /// In tr, this message translates to:
  /// **'\"{title}\": nereye gideceğini görmek için dokun.'**
  String actVenueRevealed(String title);

  ///
  ///
  /// In tr, this message translates to:
  /// **'\"{title}\" organizasyonunda seninle el sıkıştı.'**
  String actHandshake(String title);

  ///
  ///
  /// In tr, this message translates to:
  /// **'seni aradı, açamadın.'**
  String get actCallMissed;

  ///
  ///
  /// In tr, this message translates to:
  /// **'yetkin açıldı. Eşleştiğin kişileri sohbetten arayabilirsin.'**
  String get actCallGranted;

  ///
  ///
  /// In tr, this message translates to:
  /// **'talebin şimdilik kabul edilmedi. Ayrıntılar için dokun.'**
  String get actCallDeclined;

  ///
  ///
  /// In tr, this message translates to:
  /// **'yetkin kapatıldı. Ayrıntılar için dokun.'**
  String get actCallRevoked;

  ///
  ///
  /// In tr, this message translates to:
  /// **'\"{title}\" için sonraki tarih açılamadı: grubun bu ayki organizasyon hakkı doldu. Yeni ay başlayınca ya da paket yükselince açılır.'**
  String actSeriesLimit(String title);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yeni bir eşleşmen var!'**
  String get leadNewMatch;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Tekrarlayan organizasyon'**
  String get leadSeries;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sürpriz mekan açıklandı'**
  String get leadVenue;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sesli görüşme'**
  String get leadCalls;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get periodToday;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu hafta'**
  String get periodWeek;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Daha önce'**
  String get periodEarlier;

  ///
  ///
  /// In tr, this message translates to:
  /// **'şimdi'**
  String get agoNow;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{n} dk'**
  String agoMinutes(int n);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{n} sa'**
  String agoHours(int n);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{n} g'**
  String agoDays(int n);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Katıl'**
  String get join;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gör'**
  String get see;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bildirim tercihleri'**
  String get prefsTitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Mesajlar'**
  String get messages;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kişisel mesajlar'**
  String get directMessages;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Birebir sohbetlerine mesaj gelince, uygulama kapalıyken de sesli'**
  String get directMessagesHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grup mesajları'**
  String get groupMessages;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grup sohbetlerine ve bu akşamın masasına mesaj gelince, uygulama kapalıyken de sesli'**
  String get groupMessagesHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Organizasyonlar'**
  String get events;

  ///
  ///
  /// In tr, this message translates to:
  /// **'1 gün önce hatırlat'**
  String get remindDay;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Katıldığın organizasyon yarın başlıyorsa'**
  String get remindDayHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'1 saat önce hatırlat'**
  String get remindHour;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Katıldığın organizasyon 1 saat içinde başlıyorsa'**
  String get remindHourHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Değişiklik ve iptaller'**
  String get changes;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Zaman ya da yer değişince ya da organizasyon iptal edilince'**
  String get changesHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Değerlendirme istekleri'**
  String get reviewRequests;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Katıldığın organizasyon bitince \"Nasıldı?\" diye sor'**
  String get reviewRequestsHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Canlı yayınlar'**
  String get live;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Planlanan ve başlayan yayınlar'**
  String get liveAlerts;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grubunda yayın planlanınca ve başlayınca, uygulama açıksa sesli uyarıyla'**
  String get liveAlertsHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Eşleşme'**
  String get matching;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yeni eşleşmeler'**
  String get newMatches;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Biriyle karşılıklı beğenince'**
  String get newMatchesHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Katılım isteğinin sonucu, bekleme listesinden yükselmen ve grup yaptırımları seni doğrudan ilgilendirdiği için her zaman bildirilir.'**
  String get alwaysSent;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get notifications;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Beğeniler, yorumlar ve yeni takipçiler burada görünür.'**
  String get empty;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yenile'**
  String get refresh;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Takip istekleri'**
  String get followRequests;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{name} ve {count} kişi daha'**
  String andOthers(String name, int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  ///
  ///
  /// In tr, this message translates to:
  /// **'seni satranç oynamaya davet etti.'**
  String get actChessChallenge;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{group} grubu adına grubunu satranç takım maçına davet etti.'**
  String actChessTeamInvite(String group);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{group} grubu adına takım maçı davetini kabul etti. Tahtalara oyuncularını diz.'**
  String actChessTeamAccepted(String group);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{group} grubu adına takım maçı davetini reddetti.'**
  String actChessTeamDeclined(String group);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{group} grubuna karşı takım maçı başladı. Tahtana geç!'**
  String actChessTeamStart(String group);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Takım maçı'**
  String get leadTeamMatch;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Katıldığın turnuva başladı. Açınca hemen eşleşirsin.'**
  String get actChessArenaStart;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Turnuvayı ilk üçte bitirdin! Madalyan satranç profilinde.'**
  String get actChessArenaMedal;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Satranç turnuvası'**
  String get leadArena;

  ///
  ///
  /// In tr, this message translates to:
  /// **'seni Zihin Düellosu\'na davet etti.'**
  String get actMindChallenge;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{group} grubu adına grubunu Zihin Düellosu\'na davet etti.'**
  String actMindTeamInvite(String group);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{group} grubu adına grup düellosu davetini kabul etti. Oyuncularını sırala.'**
  String actMindTeamAccepted(String group);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{group} grubu adına grup düellosu davetini reddetti.'**
  String actMindTeamDeclined(String group);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{group} grubuna karşı grup düellosu başladı. Düellona geç!'**
  String actMindTeamStart(String group);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grup düellosu'**
  String get leadGroupDuel;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Katıldığın düello turnuvası başladı. Açınca hemen eşleşirsin.'**
  String get actMindArenaStart;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Düello turnuvasını ilk üçte bitirdin! Madalyan düello profilinde.'**
  String get actMindArenaMedal;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Düello turnuvası'**
  String get leadDuelArena;
}

class _NotificationsL10nDelegate
    extends LocalizationsDelegate<NotificationsL10n> {
  const _NotificationsL10nDelegate();

  @override
  Future<NotificationsL10n> load(Locale locale) {
    return SynchronousFuture<NotificationsL10n>(
      lookupNotificationsL10n(locale),
    );
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
  bool shouldReload(_NotificationsL10nDelegate old) => false;
}

NotificationsL10n lookupNotificationsL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return NotificationsL10nAr();
    case 'az':
      return NotificationsL10nAz();
    case 'de':
      return NotificationsL10nDe();
    case 'en':
      return NotificationsL10nEn();
    case 'es':
      return NotificationsL10nEs();
    case 'fr':
      return NotificationsL10nFr();
    case 'it':
      return NotificationsL10nIt();
    case 'nl':
      return NotificationsL10nNl();
    case 'pt':
      return NotificationsL10nPt();
    case 'ru':
      return NotificationsL10nRu();
    case 'tr':
      return NotificationsL10nTr();
    case 'uk':
      return NotificationsL10nUk();
  }

  throw FlutterError(
    'NotificationsL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
