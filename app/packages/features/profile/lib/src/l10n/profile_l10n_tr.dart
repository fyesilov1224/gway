// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'profile_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class ProfileL10nTr extends ProfileL10n {
  ProfileL10nTr([String locale = 'tr']) : super(locale);

  @override
  String get unsupportedImage =>
      'Bu dosya türü desteklenmiyor. JPEG, PNG veya WebP seç.';

  @override
  String get usernameTaken => 'Bu kullanıcı adı alınmış. Başka bir tane dene.';

  @override
  String get checkInput => 'Girdiğin bilgileri kontrol et.';

  @override
  String get usernameReserved =>
      'Bu kullanıcı adı kullanılamaz. Başka bir tane dene.';

  @override
  String get usernameCooldown =>
      'Kullanıcı adını 30 günde yalnızca bir kez değiştirebilirsin.';

  @override
  String get maxInterests10 => 'En fazla 10 ilgi alanı seçebilirsin.';

  @override
  String get levelBeginner => 'Başlangıç';

  @override
  String get levelBeginnerHint => 'Yeni başlıyorum';

  @override
  String get levelIntermediate => 'Orta';

  @override
  String get levelIntermediateHint => 'Düzenli yapıyorum';

  @override
  String get levelAdvanced => 'İleri';

  @override
  String get levelAdvancedHint => 'Deneyimliyim';

  @override
  String get slotWeekdayMorning => 'Hafta içi sabah';

  @override
  String get slotWeekdayNoon => 'Hafta içi öğle';

  @override
  String get slotWeekdayEvening => 'Hafta içi akşam';

  @override
  String get slotWeekendMorning => 'Hafta sonu sabah';

  @override
  String get slotWeekendAfternoon => 'Hafta sonu öğleden sonra';

  @override
  String get slotWeekendEvening => 'Hafta sonu akşam';

  @override
  String get partMorning => 'Sabah';

  @override
  String get partNoon => 'Öğle';

  @override
  String get partEvening => 'Akşam';

  @override
  String get goalFun => 'Eğlenmek';

  @override
  String get goalFitness => 'Formda kalmak';

  @override
  String get goalCompetition => 'Yarışmaya hazırlanmak';

  @override
  String get goalLearning => 'Yeni şeyler öğrenmek';

  @override
  String get goalMentoring => 'Deneyimimi paylaşmak';

  @override
  String get goalSocial => 'Yeni insanlarla tanışmak';

  @override
  String get freqMonthly => 'Ayda birkaç kez';

  @override
  String get freqWeekly => 'Haftada bir';

  @override
  String get freqFewWeekly => 'Haftada 2–3';

  @override
  String get freqDaily => 'Neredeyse her gün';

  @override
  String get sizePair => 'Birebir';

  @override
  String get sizeSmall => 'Küçük grup (3–6)';

  @override
  String get sizeLarge => 'Kalabalık grup';

  @override
  String get looking => 'Ekip arıyor';

  @override
  String lookingWithLevel(String level) {
    return 'Ekip arıyor · $level seviye';
  }

  @override
  String reasonActivities(String list) {
    return 'Aynı aktivite: $list';
  }

  @override
  String reasonInterests(String list) {
    return 'Ortak ilgi: $list';
  }

  @override
  String get reasonProvince => 'Aynı ildesiniz';

  @override
  String reasonGroup(String group) {
    return 'Ortak grup: $group';
  }

  @override
  String reasonGroups(int count) {
    return '$count ortak grup';
  }

  @override
  String reasonLevel(String level) {
    return 'Aynı seviye: $level';
  }

  @override
  String reasonTimes(String list) {
    return 'Uygun zaman: $list';
  }

  @override
  String reasonGoals(String list) {
    return 'Ortak hedef: $list';
  }

  @override
  String get reasonFrequency => 'Aynı sıklıkta buluşmak istiyorsunuz';

  @override
  String get hasVehicle => 'Aracı var';

  @override
  String get hasEquipment => 'Kendi ekipmanı var';

  @override
  String get usernameRequired => 'Bir kullanıcı adı seç.';

  @override
  String usernameMin(int min) {
    return 'Kullanıcı adı en az $min karakter olmalı.';
  }

  @override
  String usernameMax(int max) {
    return 'Kullanıcı adı en fazla $max karakter olabilir.';
  }

  @override
  String get usernameChars =>
      'Yalnızca a-z, 0-9, alt çizgi (_) ve nokta (.) kullanabilirsin.';

  @override
  String get usernameDots => 'Kullanıcı adı nokta ile başlayamaz veya bitemez.';

  @override
  String get usernameDoubleDot => 'Art arda iki nokta kullanılamaz.';

  @override
  String get nameRequired => 'Adını gir.';

  @override
  String nameMax(int max) {
    return 'Ad en fazla $max karakter olabilir.';
  }

  @override
  String get editProfile => 'Profili düzenle';

  @override
  String get save => 'Kaydet';

  @override
  String get profileInfo => 'Profil bilgileri';

  @override
  String get profileInfoHint => 'Bu bilgiler profilinde herkese görünür.';

  @override
  String get yourName => 'Adın';

  @override
  String get usernameEvery30 =>
      'Kullanıcı adını 30 günde bir değiştirebilirsin.';

  @override
  String usernameLockedUntil(String date) {
    return '$date tarihinden sonra değiştirebilirsin.';
  }

  @override
  String get about => 'Hakkında';

  @override
  String get aboutHint => 'Kendinden, sevdiğin aktivitelerden bahset.';

  @override
  String get interests => 'İlgi alanları';

  @override
  String interestsMax(int max) {
    return 'En fazla $max tane seçebilirsin.';
  }

  @override
  String get cancel => 'Vazgeç';

  @override
  String get saveChanges => 'Değişiklikleri kaydet';

  @override
  String get remove => 'Kaldır';

  @override
  String get removeCover => 'Kapak fotoğrafını kaldır';

  @override
  String get addCover => 'Kapak ekle';

  @override
  String get changeCover => 'Kapağı değiştir';

  @override
  String get changeAvatar => 'Profil fotoğrafını değiştir';

  @override
  String get photos => 'Profil ve kapak fotoğrafı';

  @override
  String get photosHint => 'JPEG, PNG veya WebP · en fazla 5 MB';

  @override
  String get addAvatar => 'Profil fotoğrafı ekle';

  @override
  String get removeAvatar => 'Profil fotoğrafını kaldır';

  @override
  String get followers => 'Takipçiler';

  @override
  String get following => 'Takip edilenler';

  @override
  String get privateLists =>
      'Bu hesap gizli. Listelerini görmek için hesabı takip etmelisin.';

  @override
  String get backToProfile => 'Profile dön';

  @override
  String get noFollowers => 'Henüz takipçi yok.';

  @override
  String get noFollowing => 'Henüz kimse takip edilmiyor.';

  @override
  String get refresh => 'Yenile';

  @override
  String get removeFollower => 'Takipçiyi çıkar';

  @override
  String removeFollowerBody(String username) {
    return '$username takipçilerinden çıkarılsın mı? Bu kişiye bildirilmez.';
  }

  @override
  String get removeAction => 'Çıkar';

  @override
  String get friends => 'Arkadaşsınız';

  @override
  String get followRequests => 'Takip istekleri';

  @override
  String get noFollowRequests =>
      'Bekleyen takip isteğin yok. Gizli hesaplar istekleri burada onaylar.';

  @override
  String get approve => 'Onayla';

  @override
  String get delete => 'Sil';

  @override
  String get blockedAccounts => 'Engellenen hesaplar';

  @override
  String get noBlocked =>
      'Engellediğin bir hesap yok. Bir profilin menüsünden engelleyebilirsin.';

  @override
  String get unblock => 'Engeli kaldır';

  @override
  String get onboardWho => 'Seni tanıyalım';

  @override
  String get onboardWhoHint =>
      'Profilinde görünecek adını ve kullanıcı adını seç.';

  @override
  String get onboardPhoto => 'Profil fotoğrafı';

  @override
  String get onboardPhotoHint =>
      'Grupların seni tanısın. İstersen sonra da ekleyebilirsin.';

  @override
  String get onboardInterests => 'İlgi alanların';

  @override
  String onboardInterestsHint(int max) {
    return 'Sana uygun grupları önerebilmemiz için en fazla $max tane seç.';
  }

  @override
  String get back => 'Geri';

  @override
  String stepOf(int step, int total) {
    return 'Adım $step / $total';
  }

  @override
  String get signOut => 'Çıkış yap';

  @override
  String get skipForNow => 'Şimdilik atla';

  @override
  String get continueAction => 'Devam et';

  @override
  String get finish => 'Bitir';

  @override
  String get usernameHelper => 'Küçük harf, rakam, _ ve . kullanabilirsin.';

  @override
  String get avatarPreview => 'Profil fotoğrafı önizlemesi';

  @override
  String get choosePhoto => 'Fotoğraf seç';

  @override
  String get chooseAnotherPhoto => 'Başka fotoğraf seç';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Ayarlar';

  @override
  String get profileNotFound =>
      'Bu profil bulunamadı ya da artık görünür değil.';

  @override
  String get backToMyProfile => 'Profilime dön';

  @override
  String suspendedUntil(String date) {
    return 'Bu hesap $date tarihine kadar askıya alındı.';
  }

  @override
  String get followsYou => 'Seni takip ediyor';

  @override
  String get yourTeammate => 'Ekip arkadaşın';

  @override
  String joined(String date) {
    return 'Katılım: $date';
  }

  @override
  String followRequestsPending(int count) {
    return '$count takip isteği onay bekliyor.';
  }

  @override
  String get review => 'İncele';

  @override
  String teammateRequestsPending(int count) {
    return '$count ekip arkadaşlığı isteği seni bekliyor.';
  }

  @override
  String get youBlocked => 'Bu hesabı engelledin';

  @override
  String get youBlockedHint =>
      'Engeli kaldırırsan birbirinizin paylaşımlarını yeniden görebilirsiniz.';

  @override
  String get privateAccount => 'Bu hesap gizli';

  @override
  String get privateAccountHint =>
      'Fotoğraflarını, videolarını ve hikayelerini görmek için bu hesabı takip et.';

  @override
  String get addInterestsNudge =>
      'İlgi alanlarını ekle, sana uygun grupları ve ekip arkadaşlarını bulalım.';

  @override
  String get add => 'Ekle';

  @override
  String blockTitle(String username) {
    return '$username engellensin mi?';
  }

  @override
  String get blockBody =>
      'Profilini, gönderilerini ve hikayelerini göremez, seni bulamaz ve sana yazamaz. Takipleşmeniz sona erer. Engellediğin bildirilmez.';

  @override
  String get block => 'Engelle';

  @override
  String get becomeTeammates => 'Ekip arkadaşı ol';

  @override
  String nowTeammates(String name) {
    return '$name ile artık ekip arkadaşısınız.';
  }

  @override
  String get acceptTeammate => 'Ekip arkadaşlığı isteğini kabul et';

  @override
  String get requestWithdrawn => 'İstek geri çekildi.';

  @override
  String get withdrawTeammate => 'Ekip arkadaşlığı isteğini geri çek';

  @override
  String get teammateEnded => 'Ekip arkadaşlığı bitti.';

  @override
  String get endTeammate => 'Ekip arkadaşlığını bitir';

  @override
  String get moreOptions => 'Diğer seçenekler';

  @override
  String get linkCopied => 'Profil bağlantısı kopyalandı.';

  @override
  String get copyLink => 'Profil bağlantısını kopyala';

  @override
  String get removedFromFollowers => 'Takipçilerinden çıkarıldı.';

  @override
  String get removeFromFollowers => 'Takipçilerimden çıkar';

  @override
  String get report => 'Şikayet et';

  @override
  String get unblocked => 'Engel kaldırıldı.';

  @override
  String get statPosts => 'Gönderi';

  @override
  String get statFollowers => 'Takipçi';

  @override
  String get statFollowing => 'Takip';

  @override
  String withdrawFollowBody(String username) {
    return '$username için gönderdiğin takip isteğini geri almak istiyor musun?';
  }

  @override
  String unfollowBody(String username) {
    return '$username takibini bırakmak istiyor musun?';
  }

  @override
  String unfollowPrivateBody(String username) {
    return '$username takibini bırakmak istiyor musun? Hesap gizli olduğu için gönderilerini görmek için yeniden istek göndermen gerekir.';
  }

  @override
  String get withdrawRequest => 'İsteği geri al';

  @override
  String get unfollow => 'Takibi bırak';

  @override
  String get followBack => 'Geri takip et';

  @override
  String get follow => 'Takip et';

  @override
  String get requestSent => 'İstek gönderildi';

  @override
  String get followingState => 'Takiptesin';

  @override
  String noAccountMatch(String query) {
    return '\"$query\" ile eşleşen bir hesap bulunamadı.';
  }

  @override
  String get clearSearch => 'Aramayı temizle';

  @override
  String get searchHint => 'Kişi ya da etiket aramak için yazmaya başla.';

  @override
  String get refreshSuggestions => 'Önerileri yenile';

  @override
  String get suggestionsForYou => 'Senin için öneriler';

  @override
  String mutualFollows(int count) {
    return 'Takip ettiğin $count kişi takip ediyor';
  }

  @override
  String get popularAccount => 'Popüler hesap';

  @override
  String get seePackage => 'Paketi incele';

  @override
  String requestSentNotify(String name) {
    return 'İstek gönderildi. $name kabul edince haber vereceğiz.';
  }

  @override
  String becomeTeammatesWith(String name) {
    return '$name ile ekip arkadaşı ol';
  }

  @override
  String get shortMessage => 'Kısa bir mesaj (isteğe bağlı)';

  @override
  String get shortMessageHint => 'Cumartesi sabahı Belgrad Ormanı?';

  @override
  String get sendRequest => 'İstek gönder';

  @override
  String get findTeammates => 'Ekip arkadaşı bul';

  @override
  String get myTeammatePrefs => 'Ekip arkadaşı tercihlerim';

  @override
  String get tabSuggestions => 'Öneriler';

  @override
  String get tabRequests => 'İstekler';

  @override
  String tabRequestsCount(int count) {
    return 'İstekler ($count)';
  }

  @override
  String get tabMyTeam => 'Ekibim';

  @override
  String get findYourTeammate => 'Ekip arkadaşını bul';

  @override
  String waitingForYou(int count) {
    return '$count kişi seninle ekip arkadaşı olmak istiyor';
  }

  @override
  String get teammatesLocked =>
      'Önerileri görmek, istek gönderip kabul etmek ve ekip arkadaşlarınla yazışmak Ekip Arkadaşı paketiyle açılır.';

  @override
  String get beVisible => 'Sen de görün';

  @override
  String get beVisibleBody =>
      '\"Ekip arıyorum\"u açarsan seninle aynı şeyleri sevenler sana istek gönderebilir.';

  @override
  String get setPrefs => 'Tercihlerimi ayarla';

  @override
  String get nowPublicSuggest =>
      'Hesabın artık herkese açık; önerilerde görünebilirsin.';

  @override
  String get privateHidden => 'Hesabın gizli, önerilerde görünmüyorsun';

  @override
  String get privateHiddenBody =>
      'Gizli hesaplar ekip arkadaşı önerilerinde çıkmaz. Hesabını herkese açarsan bekleyen takip istekleri de onaylanır.';

  @override
  String get makePublic => 'Hesabımı herkese aç';

  @override
  String get noSuggestions =>
      'Şimdilik sana uyan biri yok. İlgi alanlarını ve tercihlerini doldurursan öneriler artar.';

  @override
  String quoted(String text) {
    return '\"$text\"';
  }

  @override
  String get whySuggested => 'Neden önerildi';

  @override
  String get noPendingTeammate => 'Bekleyen ekip arkadaşlığı isteği yok.';

  @override
  String get seeSuggestions => 'Önerilere bak';

  @override
  String get incoming => 'Sana gelenler';

  @override
  String get accept => 'Kabul et';

  @override
  String get decline => 'Reddet';

  @override
  String get requestDeclined => 'İstek reddedildi.';

  @override
  String get outgoing => 'Gönderdiklerin';

  @override
  String get awaitingReply => 'Yanıt bekleniyor';

  @override
  String get withdraw => 'Geri çek';

  @override
  String get noTeammates =>
      'Henüz ekip arkadaşın yok. Önerilerden birine istek göndererek başla.';

  @override
  String optionsFor(String name) {
    return '$name için seçenekler';
  }

  @override
  String get teammatePrefs => 'Ekip arkadaşı tercihleri';

  @override
  String get prefsSavedVisible =>
      'Tercihlerin kaydedildi. Artık önerilerde görünürsün.';

  @override
  String get prefsSaved => 'Tercihlerin kaydedildi.';

  @override
  String get whatToDo => 'Ne yapmak istiyorsun?';

  @override
  String activitiesHint(int max) {
    return 'Ekip arkadaşı aradığın aktiviteler. En fazla $max tane.';
  }

  @override
  String get yourLevel => 'Seviyen';

  @override
  String get yourGoals => 'Hedeflerin';

  @override
  String get multipleChoice => 'Birden fazla seçebilirsin.';

  @override
  String get howOften => 'Ne sıklıkla buluşmak istersin?';

  @override
  String get whenFree => 'Ne zaman uygunsun?';

  @override
  String get whenFreeHint => 'Uygun olduğun zamanlara dokun.';

  @override
  String get whatTeam => 'Nasıl bir ekip istersin?';

  @override
  String get whichProvince => 'Hangi ildesin?';

  @override
  String get provinceHint =>
      'Yalnızca eşleştirme için kullanılır, profilinde görünmez.';

  @override
  String get province => 'İl';

  @override
  String get ratherNotSay => 'Belirtmek istemiyorum';

  @override
  String get extras => 'Ek bilgiler';

  @override
  String get iHaveVehicle => 'Aracım var';

  @override
  String get iHaveVehicleHint => 'Ulaşımda yol arkadaşlığı yapabilirim.';

  @override
  String get iHaveEquipment => 'Kendi ekipmanım var';

  @override
  String get iHaveEquipmentHint =>
      'Bisiklet, çadır, raket gibi malzemem hazır.';

  @override
  String get describeYourself => 'Kendini anlat';

  @override
  String get describeHint => 'Önerilerde adının altında görünür.';

  @override
  String get describeExample =>
      'Hafta sonu sabah yürüyüşü için arkadaş arıyorum.';

  @override
  String get willAppear => 'Önerilerde görüneceksin.';

  @override
  String get notAppearing => 'Şu an önerilerde görünmüyorsun.';

  @override
  String get lookingForTeam => 'Ekip arıyorum';

  @override
  String get lookingOn =>
      'Önerilerde görünürsün; sana ekip arkadaşlığı isteği gönderilebilir.';

  @override
  String get lookingOff =>
      'Açarsan seninle aynı şeyleri sevenler seni bulur. Gizli hesaplar önerilerde görünmez.';

  @override
  String prefsComplete(int percent) {
    return 'Tercihlerin %$percent tamam';
  }

  @override
  String get prefsCompleteHint =>
      'Ne kadar çok doldurursan önerilerin o kadar isabetli olur.';

  @override
  String get weekday => 'Hafta içi';

  @override
  String get weekend => 'Hafta sonu';

  @override
  String get username => 'Kullanıcı adı';

  @override
  String get available => 'Kullanılabilir';

  @override
  String get taken => 'Alınmış';

  @override
  String blockedUser(String username) {
    return '$username engellendi.';
  }
}
