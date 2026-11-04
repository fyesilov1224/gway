// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'profile_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Azerbaijani (`az`).
class ProfileL10nAz extends ProfileL10n {
  ProfileL10nAz([String locale = 'az']) : super(locale);

  @override
  String get unsupportedImage =>
      'Bu fayl növü dəstəklənmir. JPEG, PNG və ya WebP seç.';

  @override
  String get usernameTaken =>
      'Bu istifadəçi adı artıq götürülüb. Başqasını yoxla.';

  @override
  String get checkInput => 'Daxil etdiyin məlumatları yoxla.';

  @override
  String get usernameReserved =>
      'Bu istifadəçi adından istifadə etmək olmaz. Başqasını yoxla.';

  @override
  String get usernameCooldown =>
      'İstifadəçi adını 30 gündə yalnız bir dəfə dəyişə bilərsən.';

  @override
  String get maxInterests10 => 'Ən çox 10 maraq sahəsi seçə bilərsən.';

  @override
  String get levelBeginner => 'Başlanğıc';

  @override
  String get levelBeginnerHint => 'Yeni başlayıram';

  @override
  String get levelIntermediate => 'Orta';

  @override
  String get levelIntermediateHint => 'Müntəzəm edirəm';

  @override
  String get levelAdvanced => 'Qabaqcıl';

  @override
  String get levelAdvancedHint => 'Təcrübəliyəm';

  @override
  String get slotWeekdayMorning => 'Həftəiçi səhər';

  @override
  String get slotWeekdayNoon => 'Həftəiçi günorta';

  @override
  String get slotWeekdayEvening => 'Həftəiçi axşam';

  @override
  String get slotWeekendMorning => 'Həftəsonu səhər';

  @override
  String get slotWeekendAfternoon => 'Həftəsonu günortadan sonra';

  @override
  String get slotWeekendEvening => 'Həftəsonu axşam';

  @override
  String get partMorning => 'Səhər';

  @override
  String get partNoon => 'Günorta';

  @override
  String get partEvening => 'Axşam';

  @override
  String get goalFun => 'Əylənmək';

  @override
  String get goalFitness => 'Formada qalmaq';

  @override
  String get goalCompetition => 'Yarışa hazırlaşmaq';

  @override
  String get goalLearning => 'Yeni şeylər öyrənmək';

  @override
  String get goalMentoring => 'Təcrübəmi bölüşmək';

  @override
  String get goalSocial => 'Yeni insanlarla tanış olmaq';

  @override
  String get freqMonthly => 'Ayda bir neçə dəfə';

  @override
  String get freqWeekly => 'Həftədə bir';

  @override
  String get freqFewWeekly => 'Həftədə 2–3';

  @override
  String get freqDaily => 'Demək olar ki, hər gün';

  @override
  String get sizePair => 'Təkbətək';

  @override
  String get sizeSmall => 'Kiçik qrup (3–6)';

  @override
  String get sizeLarge => 'Böyük qrup';

  @override
  String get looking => 'Komanda axtarır';

  @override
  String lookingWithLevel(String level) {
    return 'Komanda axtarır · $level səviyyə';
  }

  @override
  String reasonActivities(String list) {
    return 'Eyni fəaliyyət: $list';
  }

  @override
  String reasonInterests(String list) {
    return 'Ortaq maraq: $list';
  }

  @override
  String get reasonProvince => 'Eyni əyalətdəsiniz';

  @override
  String reasonGroup(String group) {
    return 'Ortaq qrup: $group';
  }

  @override
  String reasonGroups(int count) {
    return '$count ortaq qrup';
  }

  @override
  String reasonLevel(String level) {
    return 'Eyni səviyyə: $level';
  }

  @override
  String reasonTimes(String list) {
    return 'Uyğun vaxt: $list';
  }

  @override
  String reasonGoals(String list) {
    return 'Ortaq hədəf: $list';
  }

  @override
  String get reasonFrequency => 'Eyni tezlikdə görüşmək istəyirsiniz';

  @override
  String get hasVehicle => 'Nəqliyyatı var';

  @override
  String get hasEquipment => 'Öz avadanlığı var';

  @override
  String get usernameRequired => 'İstifadəçi adı seç.';

  @override
  String usernameMin(int min) {
    return 'İstifadəçi adı ən azı $min simvol olmalıdır.';
  }

  @override
  String usernameMax(int max) {
    return 'İstifadəçi adı ən çox $max simvol ola bilər.';
  }

  @override
  String get usernameChars =>
      'Yalnız a-z, 0-9, alt xətt (_) və nöqtə (.) istifadə edə bilərsən.';

  @override
  String get usernameDots =>
      'İstifadəçi adı nöqtə ilə başlaya və ya bitə bilməz.';

  @override
  String get usernameDoubleDot => 'Ardıcıl iki nöqtə istifadə etmək olmaz.';

  @override
  String get nameRequired => 'Adını daxil et.';

  @override
  String nameMax(int max) {
    return 'Ad ən çox $max simvol ola bilər.';
  }

  @override
  String get editProfile => 'Profili redaktə et';

  @override
  String get save => 'Yadda saxla';

  @override
  String get profileInfo => 'Profil məlumatları';

  @override
  String get profileInfoHint => 'Bu məlumatlar profilində hamıya görünür.';

  @override
  String get yourName => 'Adın';

  @override
  String get usernameEvery30 =>
      'İstifadəçi adını 30 gündə bir dəyişə bilərsən.';

  @override
  String usernameLockedUntil(String date) {
    return '$date tarixindən sonra dəyişə bilərsən.';
  }

  @override
  String get about => 'Haqqında';

  @override
  String get aboutHint => 'Özün və sevdiyin fəaliyyətlər haqqında danış.';

  @override
  String get interests => 'Maraq sahələri';

  @override
  String interestsMax(int max) {
    return 'Ən çox $max seçə bilərsən.';
  }

  @override
  String get cancel => 'İmtina et';

  @override
  String get saveChanges => 'Dəyişiklikləri yadda saxla';

  @override
  String get remove => 'Sil';

  @override
  String get removeCover => 'Örtük şəklini sil';

  @override
  String get addCover => 'Örtük əlavə et';

  @override
  String get changeCover => 'Örtüyü dəyiş';

  @override
  String get changeAvatar => 'Profil şəklini dəyiş';

  @override
  String get photos => 'Profil və örtük şəkli';

  @override
  String get photosHint => 'JPEG, PNG və ya WebP · ən çox 5 MB';

  @override
  String get addAvatar => 'Profil şəkli əlavə et';

  @override
  String get removeAvatar => 'Profil şəklini sil';

  @override
  String get followers => 'İzləyicilər';

  @override
  String get following => 'İzlənilənlər';

  @override
  String get privateLists =>
      'Bu hesab gizlidir. Siyahılarını görmək üçün hesabı izləməlisən.';

  @override
  String get backToProfile => 'Profilə qayıt';

  @override
  String get noFollowers => 'Hələ izləyici yoxdur.';

  @override
  String get noFollowing => 'Hələ heç kim izlənilmir.';

  @override
  String get refresh => 'Yenilə';

  @override
  String get removeFollower => 'İzləyicini çıxar';

  @override
  String removeFollowerBody(String username) {
    return '@$username izləyicilərindən çıxarılsın? Bu barədə ona bildiriş getməyəcək.';
  }

  @override
  String get removeAction => 'Çıxar';

  @override
  String get friends => 'Dostsunuz';

  @override
  String get followRequests => 'İzləmə istəkləri';

  @override
  String get noFollowRequests =>
      'Gözləyən izləmə istəyin yoxdur. Gizli hesablar istəkləri burada təsdiqləyir.';

  @override
  String get approve => 'Təsdiqlə';

  @override
  String get delete => 'Sil';

  @override
  String get blockedAccounts => 'Bloklanmış hesablar';

  @override
  String get noBlocked =>
      'Blokladığın hesab yoxdur. Profilin menyusundan bloklaya bilərsən.';

  @override
  String get unblock => 'Bloku götür';

  @override
  String get onboardWho => 'Gəl tanış olaq';

  @override
  String get onboardWhoHint =>
      'Profilində görünəcək adını və istifadəçi adını seç.';

  @override
  String get onboardPhoto => 'Profil şəkli';

  @override
  String get onboardPhotoHint =>
      'Qrupların səni tanısın. İstəsən, sonra da əlavə edə bilərsən.';

  @override
  String get onboardInterests => 'Maraq sahələrin';

  @override
  String onboardInterestsHint(int max) {
    return 'Sənə uyğun qrupları təklif edə bilməyimiz üçün ən çox $max seç.';
  }

  @override
  String get back => 'Geri';

  @override
  String stepOf(int step, int total) {
    return 'Addım $step / $total';
  }

  @override
  String get signOut => 'Çıxış et';

  @override
  String get skipForNow => 'Hələlik keç';

  @override
  String get continueAction => 'Davam et';

  @override
  String get finish => 'Bitir';

  @override
  String get usernameHelper =>
      'Kiçik hərf, rəqəm, _ və . istifadə edə bilərsən.';

  @override
  String get avatarPreview => 'Profil şəklinin önizləməsi';

  @override
  String get choosePhoto => 'Şəkil seç';

  @override
  String get chooseAnotherPhoto => 'Başqa şəkil seç';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Ayarlar';

  @override
  String get profileNotFound => 'Bu profil tapılmadı və ya artıq görünmür.';

  @override
  String get backToMyProfile => 'Profilimə qayıt';

  @override
  String suspendedUntil(String date) {
    return 'Bu hesab $date tarixinə qədər dayandırılıb.';
  }

  @override
  String get followsYou => 'Səni izləyir';

  @override
  String get yourTeammate => 'Komanda yoldaşın';

  @override
  String joined(String date) {
    return 'Qoşulma: $date';
  }

  @override
  String followRequestsPending(int count) {
    return '$count izləmə istəyi təsdiq gözləyir.';
  }

  @override
  String get review => 'Bax';

  @override
  String teammateRequestsPending(int count) {
    return '$count komanda yoldaşlığı istəyi səni gözləyir.';
  }

  @override
  String get youBlocked => 'Bu hesabı bloklamısan';

  @override
  String get youBlockedHint =>
      'Bloku götürsən, bir-birinizin paylaşımlarını yenidən görə bilərsiniz.';

  @override
  String get privateAccount => 'Bu hesab gizlidir';

  @override
  String get privateAccountHint =>
      'Şəkillərini, videolarını və hekayələrini görmək üçün bu hesabı izlə.';

  @override
  String get addInterestsNudge =>
      'Maraq sahələrini əlavə et, sənə uyğun qrupları və komanda yoldaşlarını tapaq.';

  @override
  String get add => 'Əlavə et';

  @override
  String blockTitle(String username) {
    return '@$username bloklansın?';
  }

  @override
  String get blockBody =>
      'Profilini, paylaşımlarını və hekayələrini görə, səni tapa və sənə yaza bilməz. İzləşməniz bitir. Blokladığın barədə ona bildiriş getmir.';

  @override
  String get block => 'Blokla';

  @override
  String get becomeTeammates => 'Komanda yoldaşı ol';

  @override
  String nowTeammates(String name) {
    return '$name ilə artıq komanda yoldaşısınız.';
  }

  @override
  String get acceptTeammate => 'Komanda yoldaşlığı istəyini qəbul et';

  @override
  String get requestWithdrawn => 'İstək geri götürüldü.';

  @override
  String get withdrawTeammate => 'Komanda yoldaşlığı istəyini geri götür';

  @override
  String get teammateEnded => 'Komanda yoldaşlığı bitdi.';

  @override
  String get endTeammate => 'Komanda yoldaşlığını bitir';

  @override
  String get moreOptions => 'Digər seçimlər';

  @override
  String get linkCopied => 'Profil keçidi kopyalandı.';

  @override
  String get copyLink => 'Profil keçidini kopyala';

  @override
  String get removedFromFollowers => 'İzləyicilərindən çıxarıldı.';

  @override
  String get removeFromFollowers => 'İzləyicilərimdən çıxar';

  @override
  String get report => 'Şikayət et';

  @override
  String get unblocked => 'Blok götürüldü.';

  @override
  String get statPosts => 'Paylaşım';

  @override
  String get statFollowers => 'İzləyici';

  @override
  String get statFollowing => 'İzlənilən';

  @override
  String withdrawFollowBody(String username) {
    return '@$username üçün göndərdiyin izləmə istəyini geri götürmək istəyirsən?';
  }

  @override
  String unfollowBody(String username) {
    return '@$username izləməyi dayandırmaq istəyirsən?';
  }

  @override
  String unfollowPrivateBody(String username) {
    return '@$username izləməyi dayandırmaq istəyirsən? Hesab gizli olduğu üçün paylaşımlarını görmək üçün yenidən istək göndərməlisən.';
  }

  @override
  String get withdrawRequest => 'İstəyi geri götür';

  @override
  String get unfollow => 'İzləməni dayandır';

  @override
  String get followBack => 'Qarşılıqlı izlə';

  @override
  String get follow => 'İzlə';

  @override
  String get requestSent => 'İstək göndərildi';

  @override
  String get followingState => 'İzləyirsən';

  @override
  String noAccountMatch(String query) {
    return '\"$query\" ilə uyğun hesab tapılmadı.';
  }

  @override
  String get clearSearch => 'Axtarışı təmizlə';

  @override
  String get searchHint => 'İnsan və ya etiket axtarmaq üçün yazmağa başla.';

  @override
  String get refreshSuggestions => 'Təklifləri yenilə';

  @override
  String get suggestionsForYou => 'Sənin üçün təkliflər';

  @override
  String mutualFollows(int count) {
    return 'İzlədiyin $count nəfər izləyir';
  }

  @override
  String get popularAccount => 'Populyar hesab';

  @override
  String get seePackage => 'Paketə bax';

  @override
  String requestSentNotify(String name) {
    return 'İstək göndərildi. $name qəbul edəndə xəbər verəcəyik.';
  }

  @override
  String becomeTeammatesWith(String name) {
    return '$name ilə komanda yoldaşı ol';
  }

  @override
  String get shortMessage => 'Qısa mesaj (istəyə bağlı)';

  @override
  String get shortMessageHint => 'Şənbə səhəri parkda?';

  @override
  String get sendRequest => 'İstək göndər';

  @override
  String get findTeammates => 'Komanda yoldaşı tap';

  @override
  String get myTeammatePrefs => 'Komanda yoldaşı seçimlərim';

  @override
  String get tabSuggestions => 'Təkliflər';

  @override
  String get tabRequests => 'İstəklər';

  @override
  String tabRequestsCount(int count) {
    return 'İstəklər ($count)';
  }

  @override
  String get tabMyTeam => 'Komandam';

  @override
  String get findYourTeammate => 'Komanda yoldaşını tap';

  @override
  String waitingForYou(int count) {
    return '$count nəfər səninlə komanda yoldaşı olmaq istəyir';
  }

  @override
  String get teammatesLocked =>
      'Təklifləri görmək, istək göndərib qəbul etmək və komanda yoldaşlarınla yazışmaq Komanda Yoldaşı paketi ilə açılır.';

  @override
  String get beVisible => 'Sən də görün';

  @override
  String get beVisibleBody =>
      '\"Komanda axtarıram\"ı açsan, səninlə eyni şeyləri sevənlər sənə istək göndərə bilər.';

  @override
  String get setPrefs => 'Seçimlərimi qur';

  @override
  String get nowPublicSuggest =>
      'Hesabın artıq hamıya açıqdır; təkliflərdə görünə bilərsən.';

  @override
  String get privateHidden => 'Hesabın gizlidir, təkliflərdə görünmürsən';

  @override
  String get privateHiddenBody =>
      'Gizli hesablar komanda yoldaşı təkliflərində çıxmır. Hesabını hamıya açsan, gözləyən izləmə istəkləri də təsdiqlənir.';

  @override
  String get makePublic => 'Hesabımı hamıya aç';

  @override
  String get noSuggestions =>
      'Hələlik sənə uyğun kimsə yoxdur. Maraq sahələrini və seçimlərini doldursan, təkliflər artar.';

  @override
  String quoted(String text) {
    return '\"$text\"';
  }

  @override
  String get whySuggested => 'Niyə təklif edildi';

  @override
  String get noPendingTeammate => 'Gözləyən komanda yoldaşlığı istəyi yoxdur.';

  @override
  String get seeSuggestions => 'Təkliflərə bax';

  @override
  String get incoming => 'Sənə gələnlər';

  @override
  String get accept => 'Qəbul et';

  @override
  String get decline => 'Rədd et';

  @override
  String get requestDeclined => 'İstək rədd edildi.';

  @override
  String get outgoing => 'Göndərdiklərin';

  @override
  String get awaitingReply => 'Cavab gözlənilir';

  @override
  String get withdraw => 'Geri götür';

  @override
  String get noTeammates =>
      'Hələ komanda yoldaşın yoxdur. Təkliflərdən birinə istək göndərərək başla.';

  @override
  String optionsFor(String name) {
    return '$name üçün seçimlər';
  }

  @override
  String get teammatePrefs => 'Komanda yoldaşı seçimləri';

  @override
  String get prefsSavedVisible =>
      'Seçimlərin yadda saxlanıldı. Artıq təkliflərdə görünürsən.';

  @override
  String get prefsSaved => 'Seçimlərin yadda saxlanıldı.';

  @override
  String get whatToDo => 'Nə etmək istəyirsən?';

  @override
  String activitiesHint(int max) {
    return 'Komanda yoldaşı axtardığın fəaliyyətlər. Ən çox $max.';
  }

  @override
  String get yourLevel => 'Səviyyən';

  @override
  String get yourGoals => 'Hədəflərin';

  @override
  String get multipleChoice => 'Bir neçə seçə bilərsən.';

  @override
  String get howOften => 'Nə qədər tez-tez görüşmək istəyirsən?';

  @override
  String get whenFree => 'Nə vaxt uyğunsan?';

  @override
  String get whenFreeHint => 'Uyğun olduğun vaxtlara toxun.';

  @override
  String get whatTeam => 'Necə komanda istəyirsən?';

  @override
  String get whichProvince => 'Hansı əyalətdəsən?';

  @override
  String get provinceHint =>
      'Yalnız uyğunlaşdırma üçün istifadə olunur, profilində görünmür.';

  @override
  String get province => 'Əyalət';

  @override
  String get ratherNotSay => 'Bildirmək istəmirəm';

  @override
  String get extras => 'Əlavə məlumat';

  @override
  String get iHaveVehicle => 'Nəqliyyatım var';

  @override
  String get iHaveVehicleHint => 'Yolda yol yoldaşlığı edə bilərəm.';

  @override
  String get iHaveEquipment => 'Öz avadanlığım var';

  @override
  String get iHaveEquipmentHint =>
      'Velosiped, çadır, raket kimi avadanlığım hazırdır.';

  @override
  String get describeYourself => 'Özünü təqdim et';

  @override
  String get describeHint => 'Təkliflərdə adının altında görünür.';

  @override
  String get describeExample =>
      'Həftəsonu səhər yürüyüşü üçün yoldaş axtarıram.';

  @override
  String get willAppear => 'Təkliflərdə görünəcəksən.';

  @override
  String get notAppearing => 'Hazırda təkliflərdə görünmürsən.';

  @override
  String get lookingForTeam => 'Komanda axtarıram';

  @override
  String get lookingOn =>
      'Təkliflərdə görünürsən; sənə komanda yoldaşlığı istəyi göndərilə bilər.';

  @override
  String get lookingOff =>
      'Açsan, səninlə eyni şeyləri sevənlər səni tapar. Gizli hesablar təkliflərdə görünmür.';

  @override
  String prefsComplete(int percent) {
    return 'Seçimlərin %$percent hazırdır';
  }

  @override
  String get prefsCompleteHint =>
      'Nə qədər çox doldursan, təkliflər o qədər dəqiq olar.';

  @override
  String get weekday => 'Həftəiçi';

  @override
  String get weekend => 'Həftəsonu';

  @override
  String get username => 'İstifadəçi adı';

  @override
  String get available => 'Əlçatandır';

  @override
  String get taken => 'Götürülüb';
}
