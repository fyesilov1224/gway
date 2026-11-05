import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'live_l10n_ar.dart';
import 'live_l10n_az.dart';
import 'live_l10n_de.dart';
import 'live_l10n_en.dart';
import 'live_l10n_es.dart';
import 'live_l10n_fr.dart';
import 'live_l10n_it.dart';
import 'live_l10n_nl.dart';
import 'live_l10n_pt.dart';
import 'live_l10n_ru.dart';
import 'live_l10n_tr.dart';
import 'live_l10n_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of LiveL10n
/// returned by `LiveL10n.of(context)`.
///
/// Applications need to include `LiveL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/live_l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: LiveL10n.localizationsDelegates,
///   supportedLocales: LiveL10n.supportedLocales,
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
/// be consistent with the languages listed in the LiveL10n.supportedLocales
/// property.
abstract class LiveL10n {
  LiveL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static LiveL10n of(BuildContext context) {
    return Localizations.of<LiveL10n>(context, LiveL10n)!;
  }

  static const LocalizationsDelegate<LiveL10n> delegate = _LiveL10nDelegate();

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
  /// **'Kısa sürede çok fazla yorum yazdın. Biraz bekleyip tekrar dene.'**
  String get commentRate;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu grupta susturulduğun için yayında yalnızca dinleyebilirsin.'**
  String get mutedListenOnly;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu yayına şu anda yorum yazamazsın.'**
  String get cannotComment;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sunucu'**
  String get roleHost;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Konuşmacı'**
  String get roleSpeaker;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Dinleyici'**
  String get roleListener;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yayın başlat'**
  String get startLive;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{name} sunuyor'**
  String hostedBy(String name);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Katıl'**
  String get join;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yaklaşan · {date}'**
  String upcomingAt(String date);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Planlı yayın iptal edildi.'**
  String get scheduledCanceled;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get cancel;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Başlat'**
  String get start;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hatırlatma kaldırıldı.'**
  String get reminderRemoved;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yayın başlayınca haber vereceğiz.'**
  String get reminderSet;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hatırlatılacak'**
  String get reminding;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hatırlat'**
  String get remind;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Planlı yayın en az 5 dakika sonraya olmalı.'**
  String get schedule5min;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yayın planlandı. Üyeler hatırlatma isteyebilir.'**
  String get scheduled;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Canlı yayın'**
  String get liveBroadcast;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grup üyeleri sesli odaya katılır; sahneye aldıkların konuşur.'**
  String get liveIntro;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Başlık'**
  String get title;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ör. Pazar yürüyüşü planı'**
  String get titleExample;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Başlık en az 3 karakter olmalı.'**
  String get titleMin3;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şimdi'**
  String get now;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Planla'**
  String get scheduleIt;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu ay kalan canlı yayın süren: {count} dakika.'**
  String minutesLeft(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu ayın canlı yayın süresi doldu. Daha fazlası için paketini yükseltebilirsin.'**
  String get minutesUsedUp;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yayını başlat'**
  String get startTheLive;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şimdi canlı'**
  String get liveNow;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{group} canlı yayında: {title}'**
  String trayLabel(String group, String title);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Canlı yayındasın: {title}. Yayına dönmek için dokun.'**
  String youAreLive(String title);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yayına bağlanılıyor…'**
  String get connecting;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yayındasın · dönmek için dokun'**
  String get inBroadcast;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Mikrofonunu yönetici kapattı'**
  String get micMutedByMod;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Mikrofonu kapat'**
  String get micOff;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Mikrofonu aç'**
  String get micOn;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu yayın {date} tarihinde başlayacak.'**
  String startsOn(String date);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu yayın sona erdi.'**
  String get ended;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu yayın bulunamadı. Grubun üyesi olman gerekiyor olabilir.'**
  String get notFound;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Geri dön'**
  String get goBack;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sahneye alındın. Mikrofonunu açarak konuşabilirsin.'**
  String get onStageNow;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Artık dinleyicisin.'**
  String get nowListener;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yayından çık'**
  String get leaveBroadcast;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yayını herkes için bitirebilirsin. Yalnızca ayrılırsan yayın 2 dakika sonra kendiliğinden biter.'**
  String get leaveHostBody;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca ayrıl'**
  String get justLeave;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yayını bitir'**
  String get endBroadcast;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sahneye al'**
  String get inviteToStage;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sahneden indir'**
  String get removeFromStage;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Mikrofonunu kapat'**
  String get muteMic;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Mikrofonunu aç'**
  String get unmuteMic;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yayından çıkar'**
  String get kick;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{name} bu yayına bir daha giremez.'**
  String kickBody(String name);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get cancelAction;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Çıkar'**
  String get remove;

  ///
  ///
  /// In tr, this message translates to:
  /// **'El kaldıranlar'**
  String get raisedHands;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yorum silindi.'**
  String get commentDeleted;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yayın sona erdi. Katıldığın için teşekkürler.'**
  String get thanksForJoining;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu yayından çıkarıldın.'**
  String get youWereKicked;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yayına bağlanılamadı.'**
  String get connectFailedShort;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} kişi el kaldırdı'**
  String handsRaised(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sahnede'**
  String get onStage;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Dinleyiciler · {count}'**
  String listeners(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Henüz dinleyici yok.'**
  String get noListeners;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Küçült, yayında kal'**
  String get minimize;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} kişi'**
  String peopleCount(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yayın seçenekleri'**
  String get broadcastOptions;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yayını herkes için bitir'**
  String get endForAll;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Elini kaldırdın. Sunucu seni sahneye alabilir.'**
  String get handRaised;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sen'**
  String get you;

  ///
  ///
  /// In tr, this message translates to:
  /// **'konuşuyor'**
  String get speaking;

  ///
  ///
  /// In tr, this message translates to:
  /// **'mikrofon kapalı'**
  String get micOffState;

  ///
  ///
  /// In tr, this message translates to:
  /// **'el kaldırdı'**
  String get handUp;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Tepki gönder'**
  String get sendReaction;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ayrıl'**
  String get leave;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sahneden in'**
  String get leaveStage;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Tepkiler'**
  String get reactions;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yorumlar'**
  String get comments;

  ///
  ///
  /// In tr, this message translates to:
  /// **'El kaldır'**
  String get raiseHand;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Elini indir'**
  String get lowerHand;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şikayet et'**
  String get report;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yorumu sil'**
  String get deleteComment;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İlk yorumu sen yaz.'**
  String get firstComment;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yorum yaz…'**
  String get writeComment;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gönder'**
  String get send;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yayına bağlanılamadı. Bağlantını kontrol edip tekrar dene.'**
  String get connectFailed;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Katılımcı'**
  String get participant;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Mikrofonunu yalnızca yayın yöneticisi açabilir.'**
  String get micNeedsManager;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Mikrofon açılamadı. Mikrofon iznini kontrol et.'**
  String get micFailed;
}

class _LiveL10nDelegate extends LocalizationsDelegate<LiveL10n> {
  const _LiveL10nDelegate();

  @override
  Future<LiveL10n> load(Locale locale) {
    return SynchronousFuture<LiveL10n>(lookupLiveL10n(locale));
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
  bool shouldReload(_LiveL10nDelegate old) => false;
}

LiveL10n lookupLiveL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return LiveL10nAr();
    case 'az':
      return LiveL10nAz();
    case 'de':
      return LiveL10nDe();
    case 'en':
      return LiveL10nEn();
    case 'es':
      return LiveL10nEs();
    case 'fr':
      return LiveL10nFr();
    case 'it':
      return LiveL10nIt();
    case 'nl':
      return LiveL10nNl();
    case 'pt':
      return LiveL10nPt();
    case 'ru':
      return LiveL10nRu();
    case 'tr':
      return LiveL10nTr();
    case 'uk':
      return LiveL10nUk();
  }

  throw FlutterError(
    'LiveL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
