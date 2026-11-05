import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'messaging_l10n_ar.dart';
import 'messaging_l10n_az.dart';
import 'messaging_l10n_de.dart';
import 'messaging_l10n_en.dart';
import 'messaging_l10n_es.dart';
import 'messaging_l10n_fr.dart';
import 'messaging_l10n_it.dart';
import 'messaging_l10n_nl.dart';
import 'messaging_l10n_pt.dart';
import 'messaging_l10n_ru.dart';
import 'messaging_l10n_tr.dart';
import 'messaging_l10n_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of MessagingL10n
/// returned by `MessagingL10n.of(context)`.
///
/// Applications need to include `MessagingL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/messaging_l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: MessagingL10n.localizationsDelegates,
///   supportedLocales: MessagingL10n.supportedLocales,
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
/// be consistent with the languages listed in the MessagingL10n.supportedLocales
/// property.
abstract class MessagingL10n {
  MessagingL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static MessagingL10n of(BuildContext context) {
    return Localizations.of<MessagingL10n>(context, MessagingL10n)!;
  }

  static const LocalizationsDelegate<MessagingL10n> delegate =
      _MessagingL10nDelegate();

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
  /// **'Talebi üyesi olduğun bir gruba gönderebilirsin.'**
  String get groupInvalid;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Talebin zaten alındı ya da yetkin açık.'**
  String get permissionExists;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yeni bir talebi son karardan 7 gün sonra gönderebilirsin.'**
  String get permissionCooldown;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Not en fazla {max} karakter olabilir.'**
  String noteTooLong(int max);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Talep şu anda gönderilemiyor.'**
  String get requestForbidden;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu dosya türü desteklenmiyor. JPEG, PNG veya WebP seç.'**
  String get unsupportedImage;

  ///
  ///
  /// In tr, this message translates to:
  /// **'GWAY sesli arama'**
  String get voiceCallHandle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gelen aramalar'**
  String get incomingCalls;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Cevapsız aramalar'**
  String get missedCalls;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Cevapla'**
  String get answer;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Reddet'**
  String get decline;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Cevap verilmedi'**
  String get noAnswer;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Cevapsız arama'**
  String get missedCall;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Arama reddedildi'**
  String get callDeclined;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Aramayı reddettin'**
  String get youDeclined;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Arama artık mümkün değil'**
  String get callNotAllowed;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Arama iptal edildi'**
  String get callCanceled;

  ///
  ///
  /// In tr, this message translates to:
  /// **'60 dakika doldu, görüşme bitti'**
  String get timeLimit;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Görüşme sona erdi: sesli görüşme artık mümkün değil'**
  String get endedNotAllowed;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Görüşme bitti'**
  String get callEnded;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Mesaj silindi'**
  String get messageDeleted;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf'**
  String get photo;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu akşamın masası'**
  String get tonightTable;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yanıt vermek için önce mesaj isteğini kabul et.'**
  String get blockRequestPending;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu kişi mesaj isteğini kabul etmedi.'**
  String get blockDeclined;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu grupta susturulduğun için şu anda yazamazsın.'**
  String get blockMuted;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu sohbette yalnızca yöneticiler yazabilir.'**
  String get blockAdminsOnly;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Masa kapandı; mesajları okuyabilirsin ama yeni mesaj yazılamaz.'**
  String get blockTableClosed;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Engel olduğu için bu sohbete yazılamıyor.'**
  String get blockBlocked;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Eşleşme bittiği için bu sohbet kapandı.'**
  String get blockMatchEnded;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Eşleştiğin kişiye yazmak için Eşleşme Sohbeti paketi gerekir. Mesajları okumak ücretsiz.'**
  String get blockMatchLocked;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ekip arkadaşına yazmak için Ekip Arkadaşı paketi gerekir. Mesajları okumak ücretsiz.'**
  String get blockTeammateLocked;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Özel mesaj artık yalnızca eşleşenler ve ekip arkadaşları içindir. Eski mesajlarını okuyabilirsin.'**
  String get blockNotAllowed;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu sohbete şu anda yazamazsın.'**
  String get blockOther;

  ///
  ///
  /// In tr, this message translates to:
  /// **'GWAY kullanıcısı'**
  String get hiddenUser;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sesli görüşme'**
  String get voiceCalls;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Eşleştiğin kişilerle ve ekip arkadaşlarınla sesli konuş'**
  String get voiceCallsHeadline;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sesli görüşme, eşleştiğin kişileri ve ekip arkadaşlarını özel sohbetten aramanı sağlar. Herkese açık değildir: üyesi olduğun bir gruptan talep edersin, grubun sahibi ya da Yöneticisi açar. Görüşmeler kaydedilmez ve dinlenemez; bir görüşme en fazla {minutes} dakika sürer.'**
  String voiceCallsIntro(int minutes);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Durum'**
  String get status;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Talep edilmedi'**
  String get notRequested;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İnceleniyor'**
  String get underReview;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Açık'**
  String get statusOn;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kapalı'**
  String get statusOff;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Henüz talep etmedin.'**
  String get notRequestedYet;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Talebin {group} yöneticilerine ulaştı. Karar verilince bildirim gelir.'**
  String requestedFrom(String group);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Talebin grubun yöneticilerine ulaştı. Karar verilince bildirim gelir.'**
  String get requestedFromGroup;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sesli görüşmen açık ({group}). Eşleştiğin kişileri ve ekip arkadaşlarını sohbetin üstündeki telefon simgesiyle arayabilirsin; karşı tarafın da yetkisi açık olmalı.'**
  String activeFrom(String group);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sesli görüşmen açık. Eşleştiğin kişileri ve ekip arkadaşlarını sohbetin üstündeki telefon simgesiyle arayabilirsin; karşı tarafın da yetkisi açık olmalı.'**
  String get active;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Talebin şimdilik kabul edilmedi.'**
  String get declined;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yetkiyi veren gruptan ayrıldığın için sesli görüşmen kapandı. Başka bir grubundan yeniden talep edebilirsin.'**
  String get revokedLeftGroup;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sesli görüşmen kapatıldı.'**
  String get revoked;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gerekçe: {reason}'**
  String reasonLine(String reason);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Notun: {note}'**
  String yourNote(String note);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{date} sonrasında yeniden talep edebilirsin.'**
  String waitUntil(String date);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Talebin gönderildi.'**
  String get requestSent;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sesli görüşmeyi grupların sahipleri ve Yöneticileri açar. Talep edebilmek için önce bir gruba katıl.'**
  String get joinGroupFirst;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Talebin gideceği grup'**
  String get requestToGroup;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Not (isteğe bağlı)'**
  String get noteOptional;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Neden sesli görüşme istediğini kısaca yazabilirsin.'**
  String get noteHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Talep et'**
  String get request;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kilit ekranında gelen arama'**
  String get lockScreenCalls;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Telefonun kilitliyken aramaların tam ekran çalması için GWAY\'e izin ver.'**
  String get lockScreenHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İzni aç'**
  String get allow;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Görüşme bilgisi alınamadı. Bağlantını kontrol et.'**
  String get callInfoFailed;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Görüşmeyi bitirmek için Bitir\'e dokun.'**
  String get tapEndToHangUp;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu görüşme bulunamadı.'**
  String get callNotFound;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get close;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Görüşme en fazla {minutes} dakika sürer ve kaydedilmez.'**
  String callLimitNote(int minutes);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sese bağlanılamadı. Bağlantını kontrol edip tekrar dene.'**
  String get audioFailed;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Tekrar bağlan'**
  String get reconnect;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Seni sesli arıyor…'**
  String get incoming;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Aranıyor…'**
  String get calling;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bağlanıyor…'**
  String get connecting;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Cevapla'**
  String get answerCall;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sessize al'**
  String get mute;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sesi aç'**
  String get unmute;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bitir'**
  String get end;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hoparlör'**
  String get speaker;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Karşındakinin uygulaması eski, sesi şifresiz geliyor ve çalınmıyor. Uygulamasını güncellemesini iste.'**
  String get peerUnencrypted;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şifreli bağlantı kuruluyor…'**
  String get encrypting;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Uçtan uca şifreli. Güvenlik kodu {code}'**
  String e2eeCode(String code);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Uçtan uca şifreli'**
  String get e2ee;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu kod karşındakinin ekranındakiyle aynıysa görüşmeyi kimse dinleyemez.'**
  String get codeMatchHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Mikrofon açılamadı. Mikrofon iznini kontrol et.'**
  String get micFailed;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu sohbet bulunamadı ya da artık göremiyorsun.'**
  String get chatNotFound;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Mesajlara dön'**
  String get backToMessages;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şu anda arama yapılamıyor.'**
  String get cantCallNow;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sesli ara'**
  String get voiceCall;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grup sohbeti · yalnızca yöneticiler yazar'**
  String get groupChatAdminsOnly;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grup sohbeti'**
  String get groupChat;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Küçük masa · {count} kişi'**
  String smallTableMembers(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Artık bu sohbete yalnızca grup sahibi ve yöneticiler yazabilir.'**
  String get adminsOnlyOn;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Artık grubun tüm üyeleri bu sohbete yazabilir.'**
  String get adminsOnlyOff;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sohbet ayarları'**
  String get chatSettings;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca yöneticiler yazsın'**
  String get adminsOnlyToggle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'📷 Fotoğraf gönderiliyor…'**
  String get sendingPhoto;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Mesaj isteğin iletildi. Kabul edilene kadar okunup okunmadığını göremezsin.'**
  String get requestPendingNote;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grup sohbetinde henüz mesaj yok. İlk mesajı sen yaz.'**
  String get groupChatEmpty;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Henüz mesaj yok. İlk mesajı sen yaz.'**
  String get chatEmpty;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yazmaya başla'**
  String get startWriting;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gönderiliyor…'**
  String get sending;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Görüldü'**
  String get seen;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gönderildi'**
  String get sent;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Paketi incele'**
  String get seePackage;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get today;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu mesaj kaldırıldı.'**
  String get messageRemoved;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu mesaj silindi.'**
  String get thisMessageDeleted;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Mesaj seçenekleri'**
  String get messageOptions;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{name} profili'**
  String profileOf(String name);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sen'**
  String get you;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kopyala'**
  String get copy;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Mesaj kopyalandı.'**
  String get copied;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Herkesten sil'**
  String get deleteForAll;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şikayet et'**
  String get report;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Mesaj herkesten silinsin mi?'**
  String get deleteForAllTitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Mesaj sohbetteki herkes için \"Bu mesaj silindi\" olarak görünür. Bu işlem geri alınamaz.'**
  String get deleteForAllBody;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get cancel;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Mesaj isteği silindi.'**
  String get requestDeleted;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{name} sana mesaj göndermek istiyor. Kabul edersen yazışabilirsiniz ve mesajları okuduğunu görebilir.'**
  String wantsToMessage(String name);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kabul et'**
  String get accept;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Fotoğrafı kaldır'**
  String get removePhoto;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf ekle'**
  String get addPhoto;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Mesaj yaz'**
  String get writeMessage;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gönder'**
  String get send;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Mesajlar'**
  String get messages;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sohbetler'**
  String get chats;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İstekler'**
  String get requests;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İstekler ({count})'**
  String requestsCount(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Henüz bir sohbetin yok. Eşleştiğin kişilere ve ekip arkadaşlarına yazabilirsin.'**
  String get noChats;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kişi bul'**
  String get findPeople;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Eski mesaj istekleri burada durur. Özel mesaj artık yalnızca eşleşenler ve ekip arkadaşları içindir; yeni istek gelmez.'**
  String get oldRequestsNote;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bekleyen mesaj isteğin yok.'**
  String get noRequests;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sohbetlere dön'**
  String get backToChats;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sesli görüşme talepleri'**
  String get callRequests;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bekleyen talep yok · {count} açık yetki'**
  String noPendingWithActive(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} talep bekliyor'**
  String pendingCount(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bekleyen'**
  String get pending;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Açık'**
  String get activeTab;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sesli görüşme taleplerini grup sahibi ve Yöneticiler görür.'**
  String get requestsOwnersOnly;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Geri dön'**
  String get goBack;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bekleyen talep yok. {group} üyeleri talep edince burada görünür.'**
  String noPendingFor(String group);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu grubun açtığı sesli görüşme yetkisi yok.'**
  String get noActive;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yenile'**
  String get refresh;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Açtığın yetkiyle kişi eşleştiği ve ekip arkadaşı olduğu herkesi sesli arayabilir. Görüşmeler kaydedilmez; kişi gruptan ayrılırsa yetki kapanır.'**
  String get grantHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sesli görüşme açıldı.'**
  String get granted;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sesli görüşme kapatıldı.'**
  String get turnedOff;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Notu: {note}'**
  String theirNote(String note);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get turnOff;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Aç'**
  String get turnOn;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Rütbesi seninkine eşit ya da yüksek olduğu için bu talebi yalnızca açabilirsin.'**
  String get rankOnlyGrant;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Rütbesi seninkine eşit ya da yüksek olduğu için bu yetkiyi kapatamazsın.'**
  String get rankCannotRevoke;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Talebi reddet'**
  String get declineRequest;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sesli görüşmeyi kapat'**
  String get turnOffCalls;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kişi gerekçeyi görür ve 7 gün sonra yeniden talep edebilir.'**
  String get declineHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kişinin süren görüşmesi hemen biter. Gerekçeyi görür ve 7 gün sonra yeniden talep edebilir.'**
  String get revokeHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gerekçe'**
  String get reason;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gerekçe en az 3 karakter olmalı.'**
  String get reasonMin3;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Dün'**
  String get yesterday;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Mesaj gönder'**
  String get sendMessage;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grup sohbetini yalnızca grubun üyeleri görebilir.'**
  String get groupChatMembersOnly;
}

class _MessagingL10nDelegate extends LocalizationsDelegate<MessagingL10n> {
  const _MessagingL10nDelegate();

  @override
  Future<MessagingL10n> load(Locale locale) {
    return SynchronousFuture<MessagingL10n>(lookupMessagingL10n(locale));
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
  bool shouldReload(_MessagingL10nDelegate old) => false;
}

MessagingL10n lookupMessagingL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return MessagingL10nAr();
    case 'az':
      return MessagingL10nAz();
    case 'de':
      return MessagingL10nDe();
    case 'en':
      return MessagingL10nEn();
    case 'es':
      return MessagingL10nEs();
    case 'fr':
      return MessagingL10nFr();
    case 'it':
      return MessagingL10nIt();
    case 'nl':
      return MessagingL10nNl();
    case 'pt':
      return MessagingL10nPt();
    case 'ru':
      return MessagingL10nRu();
    case 'tr':
      return MessagingL10nTr();
    case 'uk':
      return MessagingL10nUk();
  }

  throw FlutterError(
    'MessagingL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
