// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'identity_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Azerbaijani (`az`).
class IdentityL10nAz extends IdentityL10n {
  IdentityL10nAz([String locale = 'az']) : super(locale);

  @override
  String get authInvalidCredentials => 'E-poçt ünvanı və ya şifrə yanlışdır.';

  @override
  String get authEmailNotConfirmed =>
      'E-poçt ünvanını hələ təsdiqləməmisən. Gələnlər qutusunu yoxla.';

  @override
  String get authEmailExists =>
      'Bu e-poçt ünvanı ilə artıq hesab var. Daxil olmağa cəhd et.';

  @override
  String get authWeakPassword =>
      'Şifrə ən azı 8 simvol olmalı və böyük hərf, kiçik hərf və rəqəm daxil etməlidir.';

  @override
  String get authSamePassword => 'Yeni şifrən köhnəsindən fərqli olmalıdır.';

  @override
  String get authInvalidEmail => 'Etibarlı e-poçt ünvanı daxil et.';

  @override
  String get authUserBanned =>
      'Hesabın dayandırıldığı üçün daxil ola bilməzsən.';

  @override
  String get authProviderDisabled => 'Bu giriş üsulu hazırda əlçatan deyil.';

  @override
  String ageMinimum(int age) {
    return 'GWAY-dən istifadə etmək üçün ən azı $age yaşında olmalısan.';
  }

  @override
  String get deletionPendingTitle => 'Hesabın silinmək üzrədir';

  @override
  String get deletionRequested => 'Hesabı silmək istəyin qəbul edildi.';

  @override
  String deletionScheduled(String date) {
    return 'Hesabın və bütün məlumatların $date tarixində həmişəlik silinəcək. O vaxta qədər fikrini dəyişə bilərsən.';
  }

  @override
  String get undoDeletion => 'Silməni ləğv et';

  @override
  String get signOut => 'Çıxış et';

  @override
  String get bannedTitle => 'Hesabın həmişəlik bağlandı';

  @override
  String get suspendedTitle => 'Hesabın dayandırıldı';

  @override
  String get bannedBody =>
      'Hesabın platforma komandası tərəfindən həmişəlik bağlandı. Profilin artıq heç kimə görünmür.';

  @override
  String suspendedBody(String date) {
    return 'Hesabın $date tarixinə qədər dayandırılıb. Bu müddətdə tətbiqdən istifadə edə bilməzsən; profilində dayandırıldığın görünür.';
  }

  @override
  String banReason(String reason) {
    return 'Ban səbəbi: $reason';
  }

  @override
  String suspensionReason(String reason) {
    return 'Dayandırma səbəbi: $reason';
  }

  @override
  String get retry => 'Yenidən cəhd et';

  @override
  String get deleteAccount => 'Hesabı sil';

  @override
  String get beforeDeleting => 'Hesabını silməzdən əvvəl';

  @override
  String get deletionHidesNow =>
      'Profilin dərhal gizlədilir; heç kim səni tapa bilməz.';

  @override
  String deletionGraceRestore(int days) {
    return '$days gün ərzində daxil olub silməni ləğv edə bilərsən.';
  }

  @override
  String get deletionAfterGrace =>
      'Bundan sonra profilin, şəkillərin və bütün məlumatların həmişəlik silinir.';

  @override
  String get deletionUnderstood => 'Başa düşdüm, hesabımı silmək istəyirəm.';

  @override
  String get deleteMyAccount => 'Hesabımı sil';

  @override
  String get heroTitle => 'İcman səni gözləyir.';

  @override
  String get heroBody =>
      'Yürüyüşdən musiqiyə, qaçışdan incəsənətə: qrupunu tap, birlikdə plan qur, eyni anda orada ol.';

  @override
  String get heroPointGroups => 'Qruplara qoşul və ya öz icmanı qur';

  @override
  String get heroPointEvents =>
      'Tədbirləri təqviminə əlavə et, komanda yoldaşı tap';

  @override
  String get heroPointLive => 'Qrupunla canlı səsli söhbətlərdə görüş';

  @override
  String get showPassword => 'Şifrəni göstər';

  @override
  String get hidePassword => 'Şifrəni gizlət';

  @override
  String get signIn => 'Daxil ol';

  @override
  String get signInSubtitle =>
      'Qruplarınla və dostlarınla qaldığın yerdən davam et.';

  @override
  String get email => 'E-poçt';

  @override
  String get password => 'Şifrə';

  @override
  String get forgotPassword => 'Şifrəmi unutdum';

  @override
  String get continueWithGoogle => 'Google ilə davam et';

  @override
  String get continueWithApple => 'Apple ilə davam et';

  @override
  String get noAccountSignUp => 'Hesabın yoxdur? Qeydiyyatdan keç';

  @override
  String get signUp => 'Qeydiyyatdan keç';

  @override
  String get signUpSubtitle =>
      'Qruplarını tap, tədbirlərə qoşul, yeni insanlarla tanış ol.';

  @override
  String get passwordRepeat => 'Şifrə (təkrar)';

  @override
  String get passwordsDontMatch => 'Şifrələr uyğun gəlmir.';

  @override
  String get haveAccountSignIn => 'Artıq hesabın var? Daxil ol';

  @override
  String get checkEmailTitle => 'E-poçtunu yoxla';

  @override
  String checkEmailBody(String email) {
    return '$email ünvanına təsdiq keçidi göndərdik. Keçidə toxunduqdan sonra daxil ola bilərsən.';
  }

  @override
  String get linkResent => 'Keçidi yenidən göndərdik.';

  @override
  String get backToSignIn => 'Girişə qayıt';

  @override
  String get resendLink => 'Keçidi yenidən göndər';

  @override
  String get resetPasswordTitle => 'Şifrəni sıfırla';

  @override
  String get resetPasswordSubtitle =>
      'E-poçt ünvanını daxil et, sənə şifrəni sıfırlamaq üçün keçid göndərək.';

  @override
  String get resetLinkSent =>
      'Bu ünvana bağlı hesab varsa, sıfırlama keçidini göndərdik.';

  @override
  String get sendLink => 'Keçid göndər';

  @override
  String get newPasswordTitle => 'Yeni şifrə təyin et';

  @override
  String get newPassword => 'Yeni şifrə';

  @override
  String get newPasswordRepeat => 'Yeni şifrə (təkrar)';

  @override
  String get savePassword => 'Şifrəni yadda saxla';

  @override
  String get enterEmail => 'E-poçt ünvanını daxil et.';

  @override
  String get passwordMin8 => 'Şifrə ən azı 8 simvol olmalıdır.';

  @override
  String get passwordMix =>
      'Şifrədə böyük hərf, kiçik hərf və rəqəm olmalıdır.';

  @override
  String get enterPassword => 'Şifrəni daxil et.';

  @override
  String get birthDateTitle => 'Doğum tarixin';

  @override
  String get chooseBirthDate => 'Doğum tarixini seç.';

  @override
  String birthDateExplain(int age) {
    return 'GWAY $age yaş və yuxarı insanlar üçündür. Doğum tarixin heç kimə göstərilmir və sonradan dəyişdirilə bilməz.';
  }

  @override
  String get chooseDate => 'Tarix seç';

  @override
  String get continueAction => 'Davam et';

  @override
  String get agreeTerms => 'İstifadə Şərtlərini oxudum və qəbul edirəm.';

  @override
  String get agreePrivacy => 'KVKK Məlumatlandırma Mətnini oxudum.';

  @override
  String get agreeExplicitConsent =>
      'Şəxsi məlumatlarımın Türkiyədən kənardakı serverlərdə emalına açıq razılıq verirəm.';

  @override
  String get agreeCommunityRules =>
      'İcma Qaydaları, Sanksiyalar və Hüquqi Tədbirlər Müqaviləsini oxudum və qəbul edirəm.';

  @override
  String get agreeDistanceSales =>
      'Məsafəli Satış Müqaviləsini oxudum və qəbul edirəm.';

  @override
  String get readAndAccept => 'Oxudum, təsdiq edirəm';

  @override
  String get readWholeText =>
      'Zəhmət olmasa, təsdiqləməzdən əvvəl mətnin hamısını oxu.';

  @override
  String get beforeContinue => 'Davam etməzdən əvvəl';

  @override
  String get consentIntro =>
      'GWAY-dən istifadə etmək üçün aşağıdakı mətnləri oxuyub təsdiqləməlisən.';

  @override
  String get readText => 'Mətni oxu';

  @override
  String get readToEnd => 'Təsdiqləmək üçün mətni sonuna qədər oxu.';

  @override
  String versionLabel(int version) {
    return 'Versiya $version';
  }

  @override
  String get legalDocuments => 'Hüquqi mətnlər';

  @override
  String get documentNotPublished => 'Bu mətn hazırda dərc olunmayıb.';

  @override
  String get deletionInfoTitle => 'GWAY hesabını silmək';

  @override
  String get deletionInfoIntro =>
      'Hesabını və məlumatlarını tətbiqdən və ya bu veb-saytdan silə bilərsən:';

  @override
  String get deletionInfoStep1 => 'GWAY tətbiqinə və ya veb-saytına daxil ol.';

  @override
  String get deletionInfoStep2 =>
      'Mən → Ayarlar → Hesabı sil addımlarını izlə.';

  @override
  String get deletionInfoStep3 =>
      'Silməni təsdiqlə. Profilin dərhal gizlədilir.';

  @override
  String get deletionInfoWhat => 'Nə silinir, nə qalır?';

  @override
  String deletionInfoBody(int days) {
    return '$days gün ərzində daxil olub silməni ləğv edə bilərsən. Müddət bitdikdən sonra profilin, paylaşımların, şəkillərin, mesajların, qrup üzvlüklərin, məkan yoxlama qeydlərin və təsdiq məlumatların həmişəlik silinir. Qanunla saxlanılması tələb olunan ödəniş qeydləri və anonim əməliyyat qeydləri qanunvericiliyin nəzərdə tutduğu müddət ərzində saxlanılır. Təhlükəsizlik səbəbindən bağlanan hesabların telefon nömrəsi eyni nömrə ilə yeni hesab açılmasının qarşısını almaq üçün saxlanılır.';
  }

  @override
  String get securityTitle => 'Təhlükəsizlik yoxlaması';

  @override
  String get securityChecking => 'Təhlükəsizlik yoxlanılır';

  @override
  String get securityWarning =>
      'Məkanınız, istifadə etdiyiniz telefon və VPN aşkar edilib. Zəhmət olmasa, olduğunuz ölkənin qaydalarına əməl edərək təhlükəsiz daxil olun.';

  @override
  String get vpnInstalledWarning =>
      'Cihazınızda VPN tətbiqi aşkar edilib. Zəhmət olmasa, olduğunuz ölkənin qaydalarına əməl edərək təhlükəsiz daxil olun.';

  @override
  String get securityWarningTitle => 'Təhlükəsizlik xəbərdarlığı';

  @override
  String get understood => 'Başa düşdüm';

  @override
  String get passkeyNotAdded =>
      'Barmaq izi əlavə olunmadı: əməliyyat ləğv edildi və ya bu cihaz artıq qeydiyyatdadır.';

  @override
  String get locationDeniedForever =>
      'Məkan icazəsini əvvəllər rədd etmisən. Cihaz ayarlarından GWAY üçün məkan icazəsini aç və yenidən cəhd et.';

  @override
  String get locationRequired => 'Məkan icazəsi olmadan davam edə bilməzsən.';

  @override
  String get locationServiceOff =>
      'Cihazının məkan xidməti söndürülüb. Aç və yenidən cəhd et.';

  @override
  String get locationTitle => 'Məkanını yoxlayaq';

  @override
  String get locationBody =>
      'Hesab təhlükəsizliyi və saxta hesabların qarşısını almaq üçün GWAY daxil olanda və tətbiqi açanda məkanından istifadə edir. Məkan icazəsi olmadan tətbiq açılmır.';

  @override
  String get openSettings => 'Ayarları aç';

  @override
  String get grantLocation => 'Məkan icazəsi ver';

  @override
  String get readPrivacyNotice => 'Məlumatlandırma mətnini oxu';

  @override
  String get privacyNoticeUnavailable =>
      'Məlumatlandırma mətni hazırda yüklənmədi.';

  @override
  String get enterMobileNumber => 'Mobil nömrəni daxil et.';

  @override
  String get speedUpTitle => 'Daha sürətli daxil ol';

  @override
  String get speedUpBodyPasskey =>
      'Növbəti girişlərində SMS gözləmədən barmaq izinlə və ya Google Authenticator kodu ilə təsdiq edə bilərsən.';

  @override
  String get speedUpBodyTotp =>
      'Növbəti girişlərində SMS gözləmədən Google Authenticator kodu ilə təsdiq edə bilərsən.';

  @override
  String get addFingerprint => 'Barmaq izi əlavə et';

  @override
  String get addAuthenticator => 'Google Authenticator əlavə et';

  @override
  String get notNow => 'İndi yox';

  @override
  String get fingerprintAdded => 'Barmaq izi əlavə olundu.';

  @override
  String get verifyPhoneTitle => 'Telefonunu təsdiqlə';

  @override
  String get verifyPhoneBody =>
      'Olduğun ölkənin mobil nömrəsi ilə təsdiq edə bilərsən. Nömrən başqalarına göstərilmir.';

  @override
  String get mobilePhone => 'Mobil telefon';

  @override
  String get sendCode => 'Kod göndər';

  @override
  String get verify => 'Təsdiqlə';

  @override
  String resendCodeIn(int seconds) {
    return 'Kodu yenidən göndər ($seconds san)';
  }

  @override
  String get resendCode => 'Kodu yenidən göndər';

  @override
  String get changeNumber => 'Nömrəni dəyiş';

  @override
  String get passkeyFailed =>
      'Təsdiq ləğv edildi və ya bu cihazda qeydiyyatlı barmaq izi yoxdur. Başqa üsul seçə bilərsən.';

  @override
  String get verifySignInTitle => 'Girişini təsdiqlə';

  @override
  String get verifyWithPasskey =>
      'Bu cihazın barmaq izi, üz tanıma və ya ekran kilidi ilə girişini təsdiqlə.';

  @override
  String get verifyWithTotp =>
      'Doğrulama tətbiqindəki 6 rəqəmli kodu daxil et.';

  @override
  String smsWillSendTo(String phone) {
    return 'Təhlükəsizliyin üçün bu girişi təsdiqləməlisən. $phone nömrəsinə kod göndərəcəyik.';
  }

  @override
  String get smsWillSendSaved =>
      'Təhlükəsizliyin üçün bu girişi təsdiqləməlisən. Qeydiyyatlı nömrənə kod göndərəcəyik.';

  @override
  String get methodFingerprint => 'Barmaq izi';

  @override
  String get methodApp => 'Tətbiq';

  @override
  String get verifyWithFingerprint => 'Barmaq izi ilə təsdiqlə';

  @override
  String get reviewTitle => 'Təhlükəsiz daxil olmaq mümkün olmadı';

  @override
  String get reviewBody =>
      'Hesabın təhlükəsizlik yoxlamasına alındı. Yoxlama başa çatanda tətbiqdən qaldığın yerdən istifadə etməyə davam edə bilərsən.';

  @override
  String get refreshStatus => 'Statusu yenilə';

  @override
  String get removeTotpTitle => 'Doğrulama tətbiqini sil';

  @override
  String get removeTotpBody =>
      'Bundan sonra yeni girişlərini yalnız SMS kodu ilə təsdiqləyə bilərsən.';

  @override
  String get cancel => 'İmtina et';

  @override
  String get remove => 'Sil';

  @override
  String get totpRemoved => 'Doğrulama tətbiqi silindi.';

  @override
  String get twoFactorTitle => 'İki addımlı təsdiq';

  @override
  String get phoneNumber => 'Telefon nömrəsi';

  @override
  String get notVerifiedYet => 'Hələ təsdiqlənməyib';

  @override
  String get authenticatorApp => 'Doğrulama tətbiqi';

  @override
  String get totpOn =>
      'Aktivdir. Yeni girişlərini tətbiqdəki kodla da təsdiqləyə bilərsən.';

  @override
  String get totpOff =>
      'Google Authenticator kimi tətbiqlə SMS gözləmədən daxil ol.';

  @override
  String get addTotp => 'Doğrulama tətbiqi əlavə et';

  @override
  String get signInRequired => 'Daxil olmalısan.';

  @override
  String passkeyRemoved(String name) {
    return '$name silindi.';
  }

  @override
  String get passkeysTitle => 'Barmaq izi və üz tanıma';

  @override
  String get passkeysOff =>
      'Girişlərini cihazının barmaq izi, üz tanıma və ya ekran kilidi ilə təsdiqlə.';

  @override
  String passkeysOn(int count) {
    return '$count cihaz qeydiyyatdadır. Girişlərdə əvvəlcə bu üsul soruşulur.';
  }

  @override
  String get notUsedYet => 'Hələ istifadə olunmayıb';

  @override
  String lastUsed(String date) {
    return 'Son istifadə: $date';
  }

  @override
  String get addFingerprintHere => 'Bu cihazda barmaq izi əlavə et';

  @override
  String get passkeyUnsupported =>
      'Bu cihaz və ya brauzer barmaq izi ilə girişi dəstəkləmir.';

  @override
  String passkeyDefaultName(String date) {
    return 'Barmaq izi · $date';
  }

  @override
  String get totpAdded => 'Doğrulama tətbiqi əlavə olundu.';

  @override
  String get totpStep1 =>
      '1. Doğrulama tətbiqində yeni hesab əlavə et və bu kodu skan et. Eyni telefondasansa, \"Tətbiqdə aç\"a toxun və ya açarı əl ilə daxil et.';

  @override
  String get copyKey => 'Açarı kopyala';

  @override
  String get openInApp => 'Tətbiqdə aç';

  @override
  String get totpStep2 => '2. Tətbiqin göstərdiyi 6 rəqəmli kodu daxil et.';

  @override
  String get activate => 'Aktivləşdir';

  @override
  String get codeHint => '6 rəqəmli kod';

  @override
  String get enterCode => '6 rəqəmli kodu daxil et.';

  @override
  String get enterSmsCode => 'SMS ilə gələn 6 rəqəmli kodu daxil et.';

  @override
  String get enterAppCode => 'Tətbiqdəki 6 rəqəmli kodu daxil et.';

  @override
  String get refresh => 'Yenilə';
}
