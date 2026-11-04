import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'identity_l10n_ar.dart';
import 'identity_l10n_az.dart';
import 'identity_l10n_de.dart';
import 'identity_l10n_en.dart';
import 'identity_l10n_es.dart';
import 'identity_l10n_fr.dart';
import 'identity_l10n_it.dart';
import 'identity_l10n_nl.dart';
import 'identity_l10n_pt.dart';
import 'identity_l10n_ru.dart';
import 'identity_l10n_tr.dart';
import 'identity_l10n_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of IdentityL10n
/// returned by `IdentityL10n.of(context)`.
///
/// Applications need to include `IdentityL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/identity_l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: IdentityL10n.localizationsDelegates,
///   supportedLocales: IdentityL10n.supportedLocales,
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
/// be consistent with the languages listed in the IdentityL10n.supportedLocales
/// property.
abstract class IdentityL10n {
  IdentityL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static IdentityL10n of(BuildContext context) {
    return Localizations.of<IdentityL10n>(context, IdentityL10n)!;
  }

  static const LocalizationsDelegate<IdentityL10n> delegate =
      _IdentityL10nDelegate();

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
  /// **'E-posta adresi veya şifre hatalı.'**
  String get authInvalidCredentials;

  ///
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresini henüz doğrulamadın. Gelen kutunu kontrol et.'**
  String get authEmailNotConfirmed;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu e-posta adresiyle zaten bir hesap var. Giriş yapmayı dene.'**
  String get authEmailExists;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şifre en az 8 karakter olmalı ve büyük harf, küçük harf ve rakam içermeli.'**
  String get authWeakPassword;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifren eskisinden farklı olmalı.'**
  String get authSamePassword;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir e-posta adresi gir.'**
  String get authInvalidEmail;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hesabın askıya alındığı için giriş yapamazsın.'**
  String get authUserBanned;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu giriş yöntemi şu anda kullanılamıyor.'**
  String get authProviderDisabled;

  ///
  ///
  /// In tr, this message translates to:
  /// **'GWAY\'i kullanmak için en az {age} yaşında olmalısın.'**
  String ageMinimum(int age);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hesabın silinmek üzere'**
  String get deletionPendingTitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hesap silme isteğin alındı.'**
  String get deletionRequested;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hesabın ve tüm verilerin {date} tarihinde kalıcı olarak silinecek. O zamana kadar fikrini değiştirebilirsin.'**
  String deletionScheduled(String date);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Silmeyi geri al'**
  String get undoDeletion;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yap'**
  String get signOut;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hesabın kalıcı olarak kapatıldı'**
  String get bannedTitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hesabın askıya alındı'**
  String get suspendedTitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hesabın platform ekibi tarafından kalıcı olarak kapatıldı. Profilin artık kimseye görünmüyor.'**
  String get bannedBody;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hesabın {date} tarihine kadar askıya alındı. Bu süre boyunca uygulamayı kullanamazsın; profilinde askıda olduğun görünür.'**
  String suspendedBody(String date);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ban gerekçesi: {reason}'**
  String banReason(String reason);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Askı gerekçesi: {reason}'**
  String suspensionReason(String reason);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Tekrar dene'**
  String get retry;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hesabı sil'**
  String get deleteAccount;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hesabını silmeden önce'**
  String get beforeDeleting;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Profilin hemen gizlenir; kimse seni bulamaz.'**
  String get deletionHidesNow;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{days} gün içinde giriş yapıp silmeyi geri alabilirsin.'**
  String deletionGraceRestore(int days);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu sürenin sonunda profilin, fotoğrafların ve tüm verilerin kalıcı olarak silinir.'**
  String get deletionAfterGrace;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Anladım, hesabımı silmek istiyorum.'**
  String get deletionUnderstood;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hesabımı sil'**
  String get deleteMyAccount;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Topluluğun seni bekliyor.'**
  String get heroTitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yürüyüşten müziğe, koşudan sanata; grubunu bul, birlikte plan yap, aynı anda orada ol.'**
  String get heroBody;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gruplara katıl ya da kendi topluluğunu kur'**
  String get heroPointGroups;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Organizasyonları takvimine ekle, ekip arkadaşı bul'**
  String get heroPointEvents;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Grubunla canlı sesli sohbetlerde buluş'**
  String get heroPointLive;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi göster'**
  String get showPassword;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi gizle'**
  String get hidePassword;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Giriş yap'**
  String get signIn;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gruplarına ve arkadaşlarına kaldığın yerden devam et.'**
  String get signInSubtitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get email;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get password;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şifremi unuttum'**
  String get forgotPassword;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Google ile devam et'**
  String get continueWithGoogle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Apple ile devam et'**
  String get continueWithApple;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hesabın yok mu? Kayıt ol'**
  String get noAccountSignUp;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kayıt ol'**
  String get signUp;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Gruplarını bul, organizasyonlara katıl, yeni insanlarla tanış.'**
  String get signUpSubtitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şifre (tekrar)'**
  String get passwordRepeat;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şifreler eşleşmiyor.'**
  String get passwordsDontMatch;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Zaten hesabın var mı? Giriş yap'**
  String get haveAccountSignIn;

  ///
  ///
  /// In tr, this message translates to:
  /// **'E-postanı kontrol et'**
  String get checkEmailTitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{email} adresine bir doğrulama bağlantısı gönderdik. Bağlantıya tıkladıktan sonra giriş yapabilirsin.'**
  String checkEmailBody(String email);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bağlantıyı yeniden gönderdik.'**
  String get linkResent;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Girişe dön'**
  String get backToSignIn;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bağlantıyı tekrar gönder'**
  String get resendLink;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şifreni sıfırla'**
  String get resetPasswordTitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresini gir, sana şifre sıfırlama bağlantısı gönderelim.'**
  String get resetPasswordSubtitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu adrese kayıtlı bir hesap varsa sıfırlama bağlantısını gönderdik.'**
  String get resetLinkSent;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı gönder'**
  String get sendLink;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifre belirle'**
  String get newPasswordTitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifre'**
  String get newPassword;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifre (tekrar)'**
  String get newPasswordRepeat;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi kaydet'**
  String get savePassword;

  ///
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresini gir.'**
  String get enterEmail;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şifre en az 8 karakter olmalı.'**
  String get passwordMin8;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şifre büyük harf, küçük harf ve rakam içermeli.'**
  String get passwordMix;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şifreni gir.'**
  String get enterPassword;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Doğum tarihin'**
  String get birthDateTitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Doğum tarihini seç.'**
  String get chooseBirthDate;

  ///
  ///
  /// In tr, this message translates to:
  /// **'GWAY {age} yaş ve üstündekiler içindir. Doğum tarihin kimseye gösterilmez ve sonradan değiştirilemez.'**
  String birthDateExplain(int age);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Tarih seç'**
  String get chooseDate;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Devam et'**
  String get continueAction;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kullanım Koşulları\'nı okudum ve kabul ediyorum.'**
  String get agreeTerms;

  ///
  ///
  /// In tr, this message translates to:
  /// **'KVKK Aydınlatma Metni\'ni okudum.'**
  String get agreePrivacy;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kişisel verilerimin yurt dışındaki sunucularda işlenmesine açık rıza veriyorum.'**
  String get agreeExplicitConsent;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Topluluk Kuralları, Yaptırımlar ve Yasal İşlemler Sözleşmesi\'ni okudum ve kabul ediyorum.'**
  String get agreeCommunityRules;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Mesafeli Satış Sözleşmesi\'ni okudum ve kabul ediyorum.'**
  String get agreeDistanceSales;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Okudum, onaylıyorum'**
  String get readAndAccept;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Lütfen metnin tamamını okuyup öyle onaylayın.'**
  String get readWholeText;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Devam etmeden önce'**
  String get beforeContinue;

  ///
  ///
  /// In tr, this message translates to:
  /// **'GWAY\'i kullanabilmek için aşağıdaki metinleri okuyup onaylaman gerekiyor.'**
  String get consentIntro;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Metni oku'**
  String get readText;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Onaylamak için metni sonuna kadar oku.'**
  String get readToEnd;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sürüm {version}'**
  String versionLabel(int version);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hukuki metinler'**
  String get legalDocuments;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu metin şu anda yayında değil.'**
  String get documentNotPublished;

  ///
  ///
  /// In tr, this message translates to:
  /// **'GWAY hesabını silme'**
  String get deletionInfoTitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hesabını ve verilerini uygulamadan ya da bu web sitesinden silebilirsin:'**
  String get deletionInfoIntro;

  ///
  ///
  /// In tr, this message translates to:
  /// **'GWAY uygulamasına ya da web sitesine giriş yap.'**
  String get deletionInfoStep1;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ben → Ayarlar → Hesabı sil adımlarını izle.'**
  String get deletionInfoStep2;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Silme isteğini onayla. Profilin hemen gizlenir.'**
  String get deletionInfoStep3;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ne silinir, ne kalır?'**
  String get deletionInfoWhat;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{days} gün içinde giriş yapıp silmeyi geri alabilirsin. Süre dolunca profilin, gönderilerin, fotoğrafların, mesajların, grup üyeliklerin, konum kontrol kayıtların ve doğrulama bilgilerin kalıcı olarak silinir. Yasal saklama yükümlülüğü olan ödeme kayıtları ve kimliksiz işlem kayıtları mevzuatın öngördüğü süre boyunca saklanır. Güvenlik nedeniyle kapatılan hesapların telefon numarası, aynı numarayla yeni hesap açılmasını önlemek için saklanır.'**
  String deletionInfoBody(int days);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Güvenlik doğrulaması'**
  String get securityTitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Güvenlik kontrol ediliyor'**
  String get securityChecking;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Konumunuz, kullandığınız telefon ve VPN tespit edilmiştir. Lütfen bulunduğunuz ülkenin kurallarına uyum sağlayarak güvenli giriş yapın.'**
  String get securityWarning;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Cihazınızda VPN uygulaması tespit edilmiştir. Lütfen bulunduğunuz ülkenin kurallarına uyum sağlayarak güvenli giriş yapın.'**
  String get vpnInstalledWarning;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Güvenlik uyarısı'**
  String get securityWarningTitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Anladım'**
  String get understood;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Parmak izi eklenmedi: işlem iptal edildi ya da bu cihaz zaten kayıtlı.'**
  String get passkeyNotAdded;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Konum iznini daha önce reddettin. Cihaz ayarlarından GWAY için konum iznini açıp tekrar dene.'**
  String get locationDeniedForever;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Konum izni olmadan devam edemezsin.'**
  String get locationRequired;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Cihazının konum servisi kapalı. Açıp tekrar dene.'**
  String get locationServiceOff;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Konumunu doğrulayalım'**
  String get locationTitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hesap güvenliği ve sahte hesapların önlenmesi için GWAY, giriş yaparken ve uygulamayı açtığında konumunu kullanır. Konum izni olmadan uygulama açılmaz.'**
  String get locationBody;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Ayarları aç'**
  String get openSettings;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Konum iznini ver'**
  String get grantLocation;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Aydınlatma metnini oku'**
  String get readPrivacyNotice;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Aydınlatma metni şu anda yüklenemedi.'**
  String get privacyNoticeUnavailable;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Cep telefonu numaranı gir.'**
  String get enterMobileNumber;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Girişlerini hızlandır'**
  String get speedUpTitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sonraki girişlerinde SMS beklemeden parmak izinle ya da Google Authenticator koduyla doğrulama yapabilirsin.'**
  String get speedUpBodyPasskey;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Sonraki girişlerinde SMS beklemeden Google Authenticator koduyla doğrulama yapabilirsin.'**
  String get speedUpBodyTotp;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Parmak izi ekle'**
  String get addFingerprint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Google Authenticator ekle'**
  String get addAuthenticator;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Şimdi değil'**
  String get notNow;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Parmak izi eklendi.'**
  String get fingerprintAdded;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Telefonunu doğrula'**
  String get verifyPhoneTitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bulunduğun ülkenin cep telefonu numarasıyla doğrulama yapabilirsin. Numaran başkalarına gösterilmez.'**
  String get verifyPhoneBody;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Cep telefonu'**
  String get mobilePhone;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kod gönder'**
  String get sendCode;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Doğrula'**
  String get verify;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kodu yeniden gönder ({seconds} sn)'**
  String resendCodeIn(int seconds);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kodu yeniden gönder'**
  String get resendCode;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Numarayı değiştir'**
  String get changeNumber;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Doğrulama iptal edildi ya da bu cihazda kayıtlı parmak izi yok. Başka bir yöntem seçebilirsin.'**
  String get passkeyFailed;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Girişini doğrula'**
  String get verifySignInTitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu cihazın parmak izi, yüz tanıma ya da ekran kilidiyle girişini doğrula.'**
  String get verifyWithPasskey;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Doğrulama uygulamandaki 6 haneli kodu gir.'**
  String get verifyWithTotp;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Güvenliğin için bu girişi doğrulaman gerekiyor. {phone} numarasına bir kod göndereceğiz.'**
  String smsWillSendTo(String phone);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Güvenliğin için bu girişi doğrulaman gerekiyor. Kayıtlı numarana bir kod göndereceğiz.'**
  String get smsWillSendSaved;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Parmak izi'**
  String get methodFingerprint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Uygulama'**
  String get methodApp;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Parmak iziyle doğrula'**
  String get verifyWithFingerprint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Güvenli giriş yapılamadı'**
  String get reviewTitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Hesabın güvenlik incelemesine alındı. İnceleme sonuçlanınca uygulamayı kullanmaya kaldığın yerden devam edebilirsin.'**
  String get reviewBody;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Durumu yenile'**
  String get refreshStatus;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Doğrulama uygulamasını kaldır'**
  String get removeTotpTitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bundan sonra yeni girişlerini yalnızca SMS koduyla doğrulayabilirsin.'**
  String get removeTotpBody;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get cancel;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Kaldır'**
  String get remove;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Doğrulama uygulaması kaldırıldı.'**
  String get totpRemoved;

  ///
  ///
  /// In tr, this message translates to:
  /// **'İki adımlı doğrulama'**
  String get twoFactorTitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Telefon numarası'**
  String get phoneNumber;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Henüz doğrulanmadı'**
  String get notVerifiedYet;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Doğrulama uygulaması'**
  String get authenticatorApp;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Açık. Yeni girişlerini uygulamadaki kodla da doğrulayabilirsin.'**
  String get totpOn;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Google Authenticator gibi bir uygulamayla SMS beklemeden giriş yap.'**
  String get totpOff;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Doğrulama uygulaması ekle'**
  String get addTotp;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Giriş yapman gerekiyor.'**
  String get signInRequired;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{name} kaldırıldı.'**
  String passkeyRemoved(String name);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Parmak izi ve yüz tanıma'**
  String get passkeysTitle;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Girişlerini cihazının parmak izi, yüz tanıma ya da ekran kilidiyle doğrula.'**
  String get passkeysOff;

  ///
  ///
  /// In tr, this message translates to:
  /// **'{count} cihaz kayıtlı. Girişlerde önce bu yöntem sorulur.'**
  String passkeysOn(int count);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Henüz kullanılmadı'**
  String get notUsedYet;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Son kullanım: {date}'**
  String lastUsed(String date);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu cihazda parmak izi ekle'**
  String get addFingerprintHere;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Bu cihaz ya da tarayıcı parmak iziyle girişi desteklemiyor.'**
  String get passkeyUnsupported;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Parmak izi · {date}'**
  String passkeyDefaultName(String date);

  ///
  ///
  /// In tr, this message translates to:
  /// **'Doğrulama uygulaması eklendi.'**
  String get totpAdded;

  ///
  ///
  /// In tr, this message translates to:
  /// **'1. Doğrulama uygulamanda yeni hesap ekle ve bu kodu tara. Aynı telefondaysan \"Uygulamada aç\"a dokun ya da anahtarı elle gir.'**
  String get totpStep1;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Anahtarı kopyala'**
  String get copyKey;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Uygulamada aç'**
  String get openInApp;

  ///
  ///
  /// In tr, this message translates to:
  /// **'2. Uygulamanın gösterdiği 6 haneli kodu gir.'**
  String get totpStep2;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Etkinleştir'**
  String get activate;

  ///
  ///
  /// In tr, this message translates to:
  /// **'6 haneli kod'**
  String get codeHint;

  ///
  ///
  /// In tr, this message translates to:
  /// **'6 haneli kodu gir.'**
  String get enterCode;

  ///
  ///
  /// In tr, this message translates to:
  /// **'SMS ile gelen 6 haneli kodu gir.'**
  String get enterSmsCode;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Uygulamadaki 6 haneli kodu gir.'**
  String get enterAppCode;

  ///
  ///
  /// In tr, this message translates to:
  /// **'Yenile'**
  String get refresh;
}

class _IdentityL10nDelegate extends LocalizationsDelegate<IdentityL10n> {
  const _IdentityL10nDelegate();

  @override
  Future<IdentityL10n> load(Locale locale) {
    return SynchronousFuture<IdentityL10n>(lookupIdentityL10n(locale));
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
  bool shouldReload(_IdentityL10nDelegate old) => false;
}

IdentityL10n lookupIdentityL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return IdentityL10nAr();
    case 'az':
      return IdentityL10nAz();
    case 'de':
      return IdentityL10nDe();
    case 'en':
      return IdentityL10nEn();
    case 'es':
      return IdentityL10nEs();
    case 'fr':
      return IdentityL10nFr();
    case 'it':
      return IdentityL10nIt();
    case 'nl':
      return IdentityL10nNl();
    case 'pt':
      return IdentityL10nPt();
    case 'ru':
      return IdentityL10nRu();
    case 'tr':
      return IdentityL10nTr();
    case 'uk':
      return IdentityL10nUk();
  }

  throw FlutterError(
    'IdentityL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
