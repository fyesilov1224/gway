import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'moderation_l10n_ar.dart';
import 'moderation_l10n_az.dart';
import 'moderation_l10n_de.dart';
import 'moderation_l10n_en.dart';
import 'moderation_l10n_es.dart';
import 'moderation_l10n_fr.dart';
import 'moderation_l10n_it.dart';
import 'moderation_l10n_nl.dart';
import 'moderation_l10n_pt.dart';
import 'moderation_l10n_ru.dart';
import 'moderation_l10n_tr.dart';
import 'moderation_l10n_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of ModerationL10n
/// returned by `ModerationL10n.of(context)`.
///
/// Applications need to include `ModerationL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/moderation_l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: ModerationL10n.localizationsDelegates,
///   supportedLocales: ModerationL10n.supportedLocales,
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
/// be consistent with the languages listed in the ModerationL10n.supportedLocales
/// property.
abstract class ModerationL10n {
  ModerationL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static ModerationL10n of(BuildContext context) {
    return Localizations.of<ModerationL10n>(context, ModerationL10n)!;
  }

  static const LocalizationsDelegate<ModerationL10n> delegate =
      _ModerationL10nDelegate();

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
  /// **'Bugün çok fazla şikayet gönderdin. Yarın tekrar deneyebilirsin.'**
  String get ruleRateLimited;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu içerik artık yok ya da göremiyorsun.'**
  String get ruleTargetInvalid;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kendini ya da kendi içeriğini şikayet edemezsin.'**
  String get ruleSelf;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu yaptırıma artık itiraz edilemez.'**
  String get ruleAppealNotAllowed;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bunu zaten bildirdin; inceleniyor.'**
  String get ruleDuplicate;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Silinmiş hesap'**
  String get deletedAccount;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Spam ya da yanıltıcı'**
  String get reasonSpam;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Taciz ya da zorbalık'**
  String get reasonHarassment;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Nefret söylemi'**
  String get reasonHate;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şiddet ya da tehdit'**
  String get reasonViolence;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Cinsel içerik'**
  String get reasonSexual;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yanlış bilgi'**
  String get reasonMisinformation;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Diğer'**
  String get reasonOther;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Uyarı'**
  String get sanctionWarning;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Susturma'**
  String get sanctionMute;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gruptan çıkarma'**
  String get sanctionKick;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ban'**
  String get sanctionBan;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şiddet'**
  String get illegalViolence;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Tehdit'**
  String get illegalThreat;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hakaret'**
  String get illegalInsult;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Nefret söylemi'**
  String get illegalHate;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Cinsel istismar'**
  String get illegalSexual;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Dolandırıcılık'**
  String get illegalFraud;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Uyuşturucu'**
  String get illegalDrugs;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Terör'**
  String get illegalTerror;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Başka bir suç'**
  String get illegalOther;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{days} gün susturma'**
  String muteDays(int days);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{days} gün ban'**
  String banDays(int days);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kalıcı ban'**
  String get permanentBan;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Salt çoğunluk'**
  String get thresholdMajority;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Oyların yarısından fazlası'**
  String get thresholdMajorityText;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Üçte iki'**
  String get thresholdTwoThirds;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Oyların en az üçte ikisi'**
  String get thresholdTwoThirdsText;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Oybirliği'**
  String get thresholdUnanimous;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Oyların tamamı'**
  String get thresholdUnanimousText;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gönderi'**
  String get targetPost;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yorum'**
  String get targetComment;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Organizasyon'**
  String get targetEvent;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Canlı yayın yorumu'**
  String get targetLiveComment;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grup sohbeti mesajı'**
  String get targetMessage;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Üye'**
  String get targetMember;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Karar bekliyor'**
  String get appealPending;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yaptırım sürüyor'**
  String get appealUpheld;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yaptırım kaldırıldı'**
  String get appealOverturned;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ban uygulandı.'**
  String get banApplied;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ban uygulandı. Kişinin hesabı platform incelemesine kadar askıya alındı.'**
  String get banAppliedSuspended;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Dosya açıldı. Kurul 72 saat içinde oy verecek.'**
  String get caseOpened;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Disiplin dosyası aç'**
  String get openCaseTitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{name} hakkında. Ban kurul oylaması olmadan hemen uygulanır.'**
  String caseAboutNow(String name);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{name} hakkında. Önerdiğin yaptırımı disiplin kurulu 72 saat içinde oylar.'**
  String caseAboutVote(String name);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Önerilen yaptırım'**
  String get proposedSanction;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Süre'**
  String get duration;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kalıcı'**
  String get permanent;

  ///
  ///
  /// In tr, this message translates to:
  /// **'kalıcı'**
  String get permanentLower;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{days} gün'**
  String days(int days);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Oylamasız, hemen uygula'**
  String get applyNow;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kurulun kararını beklemeden banlar. Kişi 7 gün içinde itiraz edebilir.'**
  String get applyNowHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yasa dışı faaliyet'**
  String get illegalActivity;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ban uygulanınca dosya platform ekibine gider ve hesap incelemeye kadar askıya alınır. Bu işaret sonradan değişmez.'**
  String get illegalHintNow;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kurul onaylarsa dosya platform ekibine gider ve hesap incelemeye kadar askıya alınır. Bu işaret sonradan değişmez.'**
  String get illegalHintVote;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gerekçe'**
  String get reason;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ne oldu? Kişi ve itirazı inceleyen bu metni görür.'**
  String get reasonHintNow;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ne oldu? Kurul bu metne bakarak oy verecek.'**
  String get reasonHintVote;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gerekçe en az 10 karakter olmalı.'**
  String get reasonMin10;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hemen sustur (24 saat)'**
  String get muteNow;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kurul karar verene kadar yorum yazamaz, canlı yayında konuşamaz.'**
  String get muteNowHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Banla'**
  String get ban;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Dosyayı aç'**
  String get openCase;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{days} gün'**
  String leftDays(int days);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{days} gün {hours} saat'**
  String leftDaysHours(int days, int hours);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{hours} saat'**
  String leftHours(int hours);

  ///
  ///
  /// In tr, this message translates to:
  /// **'birkaç dakika'**
  String get leftFewMinutes;

  ///
  ///
  /// In tr, this message translates to:
  /// **'En az {min} karakter yaz.'**
  String minChars(int min);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get cancel;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kurul karar eşiği'**
  String get threshold;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Karar eşiği \"{threshold}\" oldu. Yeni dosyalarda geçerli.'**
  String thresholdChanged(String threshold);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Moderasyon · {group}'**
  String moderationOf(String group);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şikayetler'**
  String get reports;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şikayetler ({count})'**
  String reportsCount(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Dosyalar'**
  String get cases;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Dosyalar ({count})'**
  String casesCount(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yaptırımlar'**
  String get sanctions;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yaptırımlar ({count})'**
  String sanctionsCount(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu grubun moderasyonunu yalnızca grup sahibi ve moderasyon ekibi görür.'**
  String get moderationTeamOnly;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Geri dön'**
  String get goBack;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Açık şikayet yok. Üyelerin şikayetleri burada toplanır.'**
  String get noReports;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yenile'**
  String get refresh;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İçeriği kaldır'**
  String get removeContent;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kaldır'**
  String get remove;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İçerik kaldırıldı.'**
  String get contentRemoved;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} şikayet'**
  String reportCount(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Görüntüle'**
  String get view;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şikayet reddedildi.'**
  String get reportDismissed;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Reddet'**
  String get dismiss;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Dosya aç'**
  String get openCaseShort;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu kişinin rütbesi seninkinden düşük olmadığı için yalnızca reddedebilirsin.'**
  String get rankOnlyDismiss;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Henüz disiplin dosyası yok. Dosyalar bir şikayetten ya da üyeler sayfasından açılır.'**
  String get noCases;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Oyun kaydedildi. Kurul yaptırımı onayladı; yaptırım uygulandı.'**
  String get voteApproved;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Oyun kaydedildi. Kurul yaptırımı reddetti.'**
  String get voteRejected;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Oyun kaydedildi. Karar çıkana kadar değiştirebilirsin.'**
  String get voteSaved;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Oylamada'**
  String get statusVoting;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Onaylandı'**
  String get statusApproved;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Reddedildi'**
  String get statusRejected;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Önerilen: {sanction}'**
  String proposed(String sanction);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Oylamasız ban'**
  String get directBan;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yasa dışı faaliyet: {category}'**
  String illegalLabel(String category);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{approvals} onay · {rejections} ret · {voters} oy hakkı'**
  String tally(int approvals, int rejections, int voters);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Oylama {time} sonra biter'**
  String votingEndsIn(String time);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Banlayan: {name}'**
  String bannedBy(String name);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Dosyayı açan: {name}'**
  String openedBy(String name);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Onayla'**
  String get approve;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Reddet'**
  String get reject;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Henüz yaptırım yok. Kurulun onayladığı yaptırımlar ve itirazlar burada görünür.'**
  String get noSanctions;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yaptırımı kaldır'**
  String get liftSanction;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yaptırım sürsün'**
  String get keepSanction;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kişiye notun (isteğe bağlı)'**
  String get noteToPerson;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yaptırım kaldırıldı; kişiye bildirildi.'**
  String get liftedNotified;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İtiraz reddedildi; kişiye bildirildi.'**
  String get appealRejectedNotified;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kaldırıldı'**
  String get lifted;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Acil susturma'**
  String get interimMute;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sürüyor'**
  String get running;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Uygulandı'**
  String get applied;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Acil susturma · kurul kararına kadar'**
  String get interimUntilDecision;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{date} tarihine kadar'**
  String until(String date);

  ///
  ///
  /// In tr, this message translates to:
  /// **'İtiraz · {status}'**
  String appealLine(String status);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Not: {note}'**
  String noteLine(String note);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sahip bu dosyada taraf olduğu için itirazı platform ekibi inceliyor.'**
  String get ownerParty;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sürsün'**
  String get keep;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} dosya oyunu bekliyor'**
  String casesAwaitingVote(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} itiraz'**
  String appealsCount(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Moderasyon'**
  String get moderation;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bekleyen iş yok'**
  String get noWork;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yaptırımlarım'**
  String get mySanctions;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hiçbir grupta yaptırımın yok. Topluluk kurallarına uyduğun için teşekkürler.'**
  String get noMySanctions;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Acil susturma sona erdi'**
  String get interimEnded;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Acil susturma · kurul kararına kadar, en geç {date}'**
  String interimLatest(String date);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{date} tarihine kadar'**
  String untilCap(String date);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sona erdi'**
  String get ended;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İtiraz et'**
  String get appeal;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Neden haksız olduğunu düşünüyorsun?'**
  String get appealHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gönder'**
  String get send;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İtirazın gönderildi. Karar verilince bildirim alacaksın.'**
  String get appealSent;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gerekçe: {reason}'**
  String reasonLine(String reason);

  ///
  ///
  /// In tr, this message translates to:
  /// **'İtirazın · {status}'**
  String yourAppealLine(String status);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu karara 7 gün içinde bir kez itiraz edebilirsin.'**
  String get appealOnce;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gönderiyi şikayet et'**
  String get reportPost;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yorumu şikayet et'**
  String get reportComment;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Organizasyonu şikayet et'**
  String get reportEvent;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Mesajı şikayet et'**
  String get reportMessage;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Eşleşme profilini şikayet et'**
  String get reportMatchProfile;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Fotoğrafı şikayet et'**
  String get reportPhoto;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcıyı şikayet et'**
  String get reportUser;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şikayetin alındı. İnceleyip gerekeni yapacağız; kimliğin şikayet edilen kişiye gösterilmez.'**
  String get reportReceived;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Neden şikayet ediyorsun?'**
  String get whyReport;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Açıklama (isteğe bağlı)'**
  String get detailsOptional;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ne olduğunu kısaca anlat.'**
  String get detailsHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şikayet et'**
  String get report;
}

class _ModerationL10nDelegate extends LocalizationsDelegate<ModerationL10n> {
  const _ModerationL10nDelegate();

  @override
  Future<ModerationL10n> load(Locale locale) {
    return SynchronousFuture<ModerationL10n>(lookupModerationL10n(locale));
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
  bool shouldReload(_ModerationL10nDelegate old) => false;
}

ModerationL10n lookupModerationL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return ModerationL10nAr();
    case 'az':
      return ModerationL10nAz();
    case 'de':
      return ModerationL10nDe();
    case 'en':
      return ModerationL10nEn();
    case 'es':
      return ModerationL10nEs();
    case 'fr':
      return ModerationL10nFr();
    case 'it':
      return ModerationL10nIt();
    case 'nl':
      return ModerationL10nNl();
    case 'pt':
      return ModerationL10nPt();
    case 'ru':
      return ModerationL10nRu();
    case 'tr':
      return ModerationL10nTr();
    case 'uk':
      return ModerationL10nUk();
  }

  throw FlutterError(
    'ModerationL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
