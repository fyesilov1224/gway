// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'identity_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class IdentityL10nTr extends IdentityL10n {
  IdentityL10nTr([String locale = 'tr']) : super(locale);

  @override
  String get authInvalidCredentials => 'E-posta adresi veya şifre hatalı.';

  @override
  String get authEmailNotConfirmed =>
      'E-posta adresini henüz doğrulamadın. Gelen kutunu kontrol et.';

  @override
  String get authEmailExists =>
      'Bu e-posta adresiyle zaten bir hesap var. Giriş yapmayı dene.';

  @override
  String get authWeakPassword =>
      'Şifre en az 8 karakter olmalı ve büyük harf, küçük harf ve rakam içermeli.';

  @override
  String get authSamePassword => 'Yeni şifren eskisinden farklı olmalı.';

  @override
  String get authInvalidEmail => 'Geçerli bir e-posta adresi gir.';

  @override
  String get authUserBanned => 'Hesabın askıya alındığı için giriş yapamazsın.';

  @override
  String get authProviderDisabled => 'Bu giriş yöntemi şu anda kullanılamıyor.';

  @override
  String ageMinimum(int age) {
    return 'GWAY\'i kullanmak için en az $age yaşında olmalısın.';
  }

  @override
  String get deletionPendingTitle => 'Hesabın silinmek üzere';

  @override
  String get deletionRequested => 'Hesap silme isteğin alındı.';

  @override
  String deletionScheduled(String date) {
    return 'Hesabın ve tüm verilerin $date tarihinde kalıcı olarak silinecek. O zamana kadar fikrini değiştirebilirsin.';
  }

  @override
  String get undoDeletion => 'Silmeyi geri al';

  @override
  String get signOut => 'Çıkış yap';

  @override
  String get bannedTitle => 'Hesabın kalıcı olarak kapatıldı';

  @override
  String get suspendedTitle => 'Hesabın askıya alındı';

  @override
  String get bannedBody =>
      'Hesabın platform ekibi tarafından kalıcı olarak kapatıldı. Profilin artık kimseye görünmüyor.';

  @override
  String suspendedBody(String date) {
    return 'Hesabın $date tarihine kadar askıya alındı. Bu süre boyunca uygulamayı kullanamazsın; profilinde askıda olduğun görünür.';
  }

  @override
  String banReason(String reason) {
    return 'Ban gerekçesi: $reason';
  }

  @override
  String suspensionReason(String reason) {
    return 'Askı gerekçesi: $reason';
  }

  @override
  String get retry => 'Tekrar dene';

  @override
  String get deleteAccount => 'Hesabı sil';

  @override
  String get beforeDeleting => 'Hesabını silmeden önce';

  @override
  String get deletionHidesNow => 'Profilin hemen gizlenir; kimse seni bulamaz.';

  @override
  String deletionGraceRestore(int days) {
    return '$days gün içinde giriş yapıp silmeyi geri alabilirsin.';
  }

  @override
  String get deletionAfterGrace =>
      'Bu sürenin sonunda profilin, fotoğrafların ve tüm verilerin kalıcı olarak silinir.';

  @override
  String get deletionUnderstood => 'Anladım, hesabımı silmek istiyorum.';

  @override
  String get deleteMyAccount => 'Hesabımı sil';

  @override
  String get heroTitle => 'Topluluğun seni bekliyor.';

  @override
  String get heroBody =>
      'Yürüyüşten müziğe, koşudan sanata; grubunu bul, birlikte plan yap, aynı anda orada ol.';

  @override
  String get heroPointGroups => 'Gruplara katıl ya da kendi topluluğunu kur';

  @override
  String get heroPointEvents =>
      'Organizasyonları takvimine ekle, ekip arkadaşı bul';

  @override
  String get heroPointLive => 'Grubunla canlı sesli sohbetlerde buluş';

  @override
  String get showPassword => 'Şifreyi göster';

  @override
  String get hidePassword => 'Şifreyi gizle';

  @override
  String get signIn => 'Giriş yap';

  @override
  String get signInSubtitle =>
      'Gruplarına ve arkadaşlarına kaldığın yerden devam et.';

  @override
  String get email => 'E-posta';

  @override
  String get password => 'Şifre';

  @override
  String get forgotPassword => 'Şifremi unuttum';

  @override
  String get continueWithGoogle => 'Google ile devam et';

  @override
  String get continueWithApple => 'Apple ile devam et';

  @override
  String get noAccountSignUp => 'Hesabın yok mu? Kayıt ol';

  @override
  String get signUp => 'Kayıt ol';

  @override
  String get signUpSubtitle =>
      'Gruplarını bul, organizasyonlara katıl, yeni insanlarla tanış.';

  @override
  String get passwordRepeat => 'Şifre (tekrar)';

  @override
  String get passwordsDontMatch => 'Şifreler eşleşmiyor.';

  @override
  String get haveAccountSignIn => 'Zaten hesabın var mı? Giriş yap';

  @override
  String get checkEmailTitle => 'E-postanı kontrol et';

  @override
  String checkEmailBody(String email) {
    return '$email adresine bir doğrulama bağlantısı gönderdik. Bağlantıya tıkladıktan sonra giriş yapabilirsin.';
  }

  @override
  String get linkResent => 'Bağlantıyı yeniden gönderdik.';

  @override
  String get backToSignIn => 'Girişe dön';

  @override
  String get resendLink => 'Bağlantıyı tekrar gönder';

  @override
  String get resetPasswordTitle => 'Şifreni sıfırla';

  @override
  String get resetPasswordSubtitle =>
      'E-posta adresini gir, sana şifre sıfırlama bağlantısı gönderelim.';

  @override
  String get resetLinkSent =>
      'Bu adrese kayıtlı bir hesap varsa sıfırlama bağlantısını gönderdik.';

  @override
  String get sendLink => 'Bağlantı gönder';

  @override
  String get newPasswordTitle => 'Yeni şifre belirle';

  @override
  String get newPassword => 'Yeni şifre';

  @override
  String get newPasswordRepeat => 'Yeni şifre (tekrar)';

  @override
  String get savePassword => 'Şifreyi kaydet';

  @override
  String get enterEmail => 'E-posta adresini gir.';

  @override
  String get passwordMin8 => 'Şifre en az 8 karakter olmalı.';

  @override
  String get passwordMix => 'Şifre büyük harf, küçük harf ve rakam içermeli.';

  @override
  String get enterPassword => 'Şifreni gir.';

  @override
  String get birthDateTitle => 'Doğum tarihin';

  @override
  String get chooseBirthDate => 'Doğum tarihini seç.';

  @override
  String birthDateExplain(int age) {
    return 'GWAY $age yaş ve üstündekiler içindir. Doğum tarihin kimseye gösterilmez ve sonradan değiştirilemez.';
  }

  @override
  String get chooseDate => 'Tarih seç';

  @override
  String get continueAction => 'Devam et';

  @override
  String get agreeTerms => 'Kullanım Koşulları\'nı okudum ve kabul ediyorum.';

  @override
  String get agreePrivacy => 'KVKK Aydınlatma Metni\'ni okudum.';

  @override
  String get agreeExplicitConsent =>
      'Kişisel verilerimin yurt dışındaki sunucularda işlenmesine açık rıza veriyorum.';

  @override
  String get agreeCommunityRules =>
      'Topluluk Kuralları, Yaptırımlar ve Yasal İşlemler Sözleşmesi\'ni okudum ve kabul ediyorum.';

  @override
  String get agreeDistanceSales =>
      'Mesafeli Satış Sözleşmesi\'ni okudum ve kabul ediyorum.';

  @override
  String get readAndAccept => 'Okudum, onaylıyorum';

  @override
  String get readWholeText => 'Lütfen metnin tamamını okuyup öyle onaylayın.';

  @override
  String get beforeContinue => 'Devam etmeden önce';

  @override
  String get consentIntro =>
      'GWAY\'i kullanabilmek için aşağıdaki metinleri okuyup onaylaman gerekiyor.';

  @override
  String get readText => 'Metni oku';

  @override
  String get readToEnd => 'Onaylamak için metni sonuna kadar oku.';

  @override
  String versionLabel(int version) {
    return 'Sürüm $version';
  }

  @override
  String get legalDocuments => 'Hukuki metinler';

  @override
  String get documentNotPublished => 'Bu metin şu anda yayında değil.';

  @override
  String get deletionInfoTitle => 'GWAY hesabını silme';

  @override
  String get deletionInfoIntro =>
      'Hesabını ve verilerini uygulamadan ya da bu web sitesinden silebilirsin:';

  @override
  String get deletionInfoStep1 =>
      'GWAY uygulamasına ya da web sitesine giriş yap.';

  @override
  String get deletionInfoStep2 => 'Ben → Ayarlar → Hesabı sil adımlarını izle.';

  @override
  String get deletionInfoStep3 =>
      'Silme isteğini onayla. Profilin hemen gizlenir.';

  @override
  String get deletionInfoWhat => 'Ne silinir, ne kalır?';

  @override
  String deletionInfoBody(int days) {
    return '$days gün içinde giriş yapıp silmeyi geri alabilirsin. Süre dolunca profilin, gönderilerin, fotoğrafların, mesajların, grup üyeliklerin, konum kontrol kayıtların ve doğrulama bilgilerin kalıcı olarak silinir. Yasal saklama yükümlülüğü olan ödeme kayıtları ve kimliksiz işlem kayıtları mevzuatın öngördüğü süre boyunca saklanır. Güvenlik nedeniyle kapatılan hesapların telefon numarası, aynı numarayla yeni hesap açılmasını önlemek için saklanır.';
  }

  @override
  String get securityTitle => 'Güvenlik doğrulaması';

  @override
  String get securityChecking => 'Güvenlik kontrol ediliyor';

  @override
  String get securityWarning =>
      'Konumunuz, kullandığınız telefon ve VPN tespit edilmiştir. Lütfen bulunduğunuz ülkenin kurallarına uyum sağlayarak güvenli giriş yapın.';

  @override
  String get vpnInstalledWarning =>
      'Cihazınızda VPN uygulaması tespit edilmiştir. Lütfen bulunduğunuz ülkenin kurallarına uyum sağlayarak güvenli giriş yapın.';

  @override
  String get securityWarningTitle => 'Güvenlik uyarısı';

  @override
  String get understood => 'Anladım';

  @override
  String get passkeyNotAdded =>
      'Parmak izi eklenmedi: işlem iptal edildi ya da bu cihaz zaten kayıtlı.';

  @override
  String get locationDeniedForever =>
      'Konum iznini daha önce reddettin. Cihaz ayarlarından GWAY için konum iznini açıp tekrar dene.';

  @override
  String get locationRequired => 'Konum izni olmadan devam edemezsin.';

  @override
  String get locationServiceOff =>
      'Cihazının konum servisi kapalı. Açıp tekrar dene.';

  @override
  String get locationTitle => 'Konumunu doğrulayalım';

  @override
  String get locationBody =>
      'Hesap güvenliği ve sahte hesapların önlenmesi için GWAY, giriş yaparken ve uygulamayı açtığında konumunu kullanır. Konum izni olmadan uygulama açılmaz.';

  @override
  String get openSettings => 'Ayarları aç';

  @override
  String get grantLocation => 'Konum iznini ver';

  @override
  String get readPrivacyNotice => 'Aydınlatma metnini oku';

  @override
  String get privacyNoticeUnavailable =>
      'Aydınlatma metni şu anda yüklenemedi.';

  @override
  String get enterMobileNumber => 'Cep telefonu numaranı gir.';

  @override
  String get speedUpTitle => 'Girişlerini hızlandır';

  @override
  String get speedUpBodyPasskey =>
      'Sonraki girişlerinde SMS beklemeden parmak izinle ya da Google Authenticator koduyla doğrulama yapabilirsin.';

  @override
  String get speedUpBodyTotp =>
      'Sonraki girişlerinde SMS beklemeden Google Authenticator koduyla doğrulama yapabilirsin.';

  @override
  String get addFingerprint => 'Parmak izi ekle';

  @override
  String get addAuthenticator => 'Google Authenticator ekle';

  @override
  String get notNow => 'Şimdi değil';

  @override
  String get fingerprintAdded => 'Parmak izi eklendi.';

  @override
  String get verifyPhoneTitle => 'Telefonunu doğrula';

  @override
  String get verifyPhoneBody =>
      'Bulunduğun ülkenin cep telefonu numarasıyla doğrulama yapabilirsin. Numaran başkalarına gösterilmez.';

  @override
  String get mobilePhone => 'Cep telefonu';

  @override
  String get sendCode => 'Kod gönder';

  @override
  String get verify => 'Doğrula';

  @override
  String resendCodeIn(int seconds) {
    return 'Kodu yeniden gönder ($seconds sn)';
  }

  @override
  String get resendCode => 'Kodu yeniden gönder';

  @override
  String get changeNumber => 'Numarayı değiştir';

  @override
  String get passkeyFailed =>
      'Doğrulama iptal edildi ya da bu cihazda kayıtlı parmak izi yok. Başka bir yöntem seçebilirsin.';

  @override
  String get verifySignInTitle => 'Girişini doğrula';

  @override
  String get verifyWithPasskey =>
      'Bu cihazın parmak izi, yüz tanıma ya da ekran kilidiyle girişini doğrula.';

  @override
  String get verifyWithTotp => 'Doğrulama uygulamandaki 6 haneli kodu gir.';

  @override
  String smsWillSendTo(String phone) {
    return 'Güvenliğin için bu girişi doğrulaman gerekiyor. $phone numarasına bir kod göndereceğiz.';
  }

  @override
  String get smsWillSendSaved =>
      'Güvenliğin için bu girişi doğrulaman gerekiyor. Kayıtlı numarana bir kod göndereceğiz.';

  @override
  String get methodFingerprint => 'Parmak izi';

  @override
  String get methodApp => 'Uygulama';

  @override
  String get verifyWithFingerprint => 'Parmak iziyle doğrula';

  @override
  String get reviewTitle => 'Güvenli giriş yapılamadı';

  @override
  String get reviewBody =>
      'Hesabın güvenlik incelemesine alındı. İnceleme sonuçlanınca uygulamayı kullanmaya kaldığın yerden devam edebilirsin.';

  @override
  String get refreshStatus => 'Durumu yenile';

  @override
  String get removeTotpTitle => 'Doğrulama uygulamasını kaldır';

  @override
  String get removeTotpBody =>
      'Bundan sonra yeni girişlerini yalnızca SMS koduyla doğrulayabilirsin.';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get remove => 'Kaldır';

  @override
  String get totpRemoved => 'Doğrulama uygulaması kaldırıldı.';

  @override
  String get twoFactorTitle => 'İki adımlı doğrulama';

  @override
  String get phoneNumber => 'Telefon numarası';

  @override
  String get notVerifiedYet => 'Henüz doğrulanmadı';

  @override
  String get authenticatorApp => 'Doğrulama uygulaması';

  @override
  String get totpOn =>
      'Açık. Yeni girişlerini uygulamadaki kodla da doğrulayabilirsin.';

  @override
  String get totpOff =>
      'Google Authenticator gibi bir uygulamayla SMS beklemeden giriş yap.';

  @override
  String get addTotp => 'Doğrulama uygulaması ekle';

  @override
  String get signInRequired => 'Giriş yapman gerekiyor.';

  @override
  String passkeyRemoved(String name) {
    return '$name kaldırıldı.';
  }

  @override
  String get passkeysTitle => 'Parmak izi ve yüz tanıma';

  @override
  String get passkeysOff =>
      'Girişlerini cihazının parmak izi, yüz tanıma ya da ekran kilidiyle doğrula.';

  @override
  String passkeysOn(int count) {
    return '$count cihaz kayıtlı. Girişlerde önce bu yöntem sorulur.';
  }

  @override
  String get notUsedYet => 'Henüz kullanılmadı';

  @override
  String lastUsed(String date) {
    return 'Son kullanım: $date';
  }

  @override
  String get addFingerprintHere => 'Bu cihazda parmak izi ekle';

  @override
  String get passkeyUnsupported =>
      'Bu cihaz ya da tarayıcı parmak iziyle girişi desteklemiyor.';

  @override
  String passkeyDefaultName(String date) {
    return 'Parmak izi · $date';
  }

  @override
  String get totpAdded => 'Doğrulama uygulaması eklendi.';

  @override
  String get totpStep1 =>
      '1. Doğrulama uygulamanda yeni hesap ekle ve bu kodu tara. Aynı telefondaysan \"Uygulamada aç\"a dokun ya da anahtarı elle gir.';

  @override
  String get copyKey => 'Anahtarı kopyala';

  @override
  String get openInApp => 'Uygulamada aç';

  @override
  String get totpStep2 => '2. Uygulamanın gösterdiği 6 haneli kodu gir.';

  @override
  String get activate => 'Etkinleştir';

  @override
  String get codeHint => '6 haneli kod';

  @override
  String get enterCode => '6 haneli kodu gir.';

  @override
  String get enterSmsCode => 'SMS ile gelen 6 haneli kodu gir.';

  @override
  String get enterAppCode => 'Uygulamadaki 6 haneli kodu gir.';

  @override
  String get refresh => 'Yenile';

  @override
  String get language => 'Dil';

  @override
  String get chooseLanguage => 'Dil seç';

  @override
  String get languageNote =>
      'Menüler, düğmeler, bildirimler ve sözleşmeler bu dilde gösterilir. Gönderiler, yorumlar ve mesajlar yazıldıkları dilde kalır.';

  @override
  String get or => 'veya';
}
