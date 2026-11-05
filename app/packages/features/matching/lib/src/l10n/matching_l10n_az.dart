// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'matching_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Azerbaijani (`az`).
class MatchingL10nAz extends MatchingL10n {
  MatchingL10nAz([String locale = 'az']) : super(locale);

  @override
  String get unsupportedImage =>
      'Yalnız JPEG, PNG və ya WebP şəkil yükləmək olar.';

  @override
  String get modeFriend => 'Dost';

  @override
  String get modeDating => 'Sevgili';

  @override
  String get genderWoman => 'Qadın';

  @override
  String get genderMan => 'Kişi';

  @override
  String get genderNonbinary => 'Qeyri-binar';

  @override
  String get adultsOnly => 'Uyğunluq 18 yaşdan böyüklər üçündür.';

  @override
  String get pickMode => 'Dost və ya Sevgili rejimlərindən ən azı birini seç.';

  @override
  String get pickInterest => 'Sevgili rejimi üçün kimi axtardığını seç.';

  @override
  String get ageRangeInvalid => 'Yaş aralığı səhvdir.';

  @override
  String sharedGroup(String group) {
    return 'Ortaq qrup: $group';
  }

  @override
  String sharedGroupsMore(String group, int count) {
    return 'Ortaq: $group və daha $count qrup';
  }

  @override
  String get pkgReveal => 'Uyğunluqlarım';

  @override
  String get pkgRevealText =>
      'Kiminlə uyğunlaşdığını gör: ad, şəkillər və profil.';

  @override
  String get pkgChat => 'Uyğunluq Söhbəti';

  @override
  String get pkgChatText =>
      'Uyğunlaşdıqlarına yaz. Uyğunluqlarını görmək də daxildir.';

  @override
  String get pkgAdmirers => 'Səni Bəyənənlər';

  @override
  String get pkgAdmirersText =>
      'Səni kimlərin bəyəndiyini gör, bəyənərək dərhal uyğunlaş.';

  @override
  String get pkgUnlimited => 'Limitsiz Bəyənmə';

  @override
  String get pkgUnlimitedText =>
      'Gündəlik bəyənmə limiti götürülür; geri al və filtrlər də açılır.';

  @override
  String get pkgSuper => 'Super Bəyənmə';

  @override
  String get pkgSuperText =>
      'Gündə 5 super bəyənmə; super bəyəndiyin şəxs səni destəsində ilk görür.';

  @override
  String get pkgBoost => 'Önə Çıx';

  @override
  String get pkgBoostText =>
      'Gündə bir dəfə 30 dəqiqə ortaq qruplarındakı destələrin ən başında görün.';

  @override
  String get pkgTeammates => 'Komanda Yoldaşı';

  @override
  String get pkgTeammatesText =>
      'Komanda yoldaşı istəyi göndər və komanda yoldaşlarınla yazış.';

  @override
  String get pkgAll => 'Hamısı Bir Yerdə';

  @override
  String get pkgAllText =>
      'Bütün paketlər bir paketdə, ayrı-ayrı almaqdan çox sərfəli.';

  @override
  String get superLikedYou => 'Səni super bəyəndi';

  @override
  String get options => 'Seçimlər';

  @override
  String get fullProfile => 'Profilin tamamı';

  @override
  String get stampLike => 'BƏYƏN';

  @override
  String get stampPass => 'KEÇ';

  @override
  String get stampSuper => 'SUPER';

  @override
  String photoOf(String name, int number) {
    return '$name, şəkil $number';
  }

  @override
  String get about => 'Haqqında';

  @override
  String get interests => 'Maraq sahələri';

  @override
  String get sharedGroupsTitle => 'Ortaq qruplarınız';

  @override
  String get createProfileTitle => 'Uyğunluq profili yarat';

  @override
  String get myProfile => 'Uyğunluq profilim';

  @override
  String get birthDateLabel => 'Doğum tarixin';

  @override
  String get pickBasics => 'Doğum tarixini, cinsini və ilini seç.';

  @override
  String get confirmAgeConsent =>
      'Davam etmək üçün 18 yaşdan böyük olduğunu təsdiqlə və açıq razılıq ver.';

  @override
  String profileReady(int min) {
    return 'Profilin hazırdır. İndi ən azı $min şəkil əlavə et.';
  }

  @override
  String get saved => 'Yadda saxlanıldı.';

  @override
  String get pickBirthDate => 'Doğum tarixini seç';

  @override
  String ageNote(int age) {
    return '$age yaş · kartında yalnız yaşın görünür';
  }

  @override
  String get gender => 'Cins';

  @override
  String get province => 'İl';

  @override
  String get aboutHint => 'Özün haqqında danış';

  @override
  String get jobOptional => 'Peşə (istəyə bağlı)';

  @override
  String get educationOptional => 'Təhsil (istəyə bağlı)';

  @override
  String get interestsFromProfile =>
      'Maraq sahələrin sosial profilindən gəlir.';

  @override
  String get lookingFor => 'Nə axtarırsan?';

  @override
  String get friendHint => 'Birlikdə tədbirə gedəcək, söhbət edəcək insanlar';

  @override
  String get datingHint => 'Romantik münasibət';

  @override
  String get whoLookingFor => 'Kimi axtarırsan?';

  @override
  String ageRange(int min, int max) {
    return 'Yaş aralığı: $min–$max';
  }

  @override
  String get consentTitle => 'Təsdiq';

  @override
  String get iam18 => '18 yaşdan böyüyəm.';

  @override
  String get consentText =>
      'Uyğunluq üçün cinsimin, axtardığım şəxsin, doğum tarixımin, ilimin və şəkillərimin işlənməsinə və ortaq qruplarımda uyğunluğu açmış insanlara göstərilməsinə açıq razılıq verirəm. Razılığımı istədiyim an uyğunluq məlumatlarımı silərək geri ala bilərəm.';

  @override
  String get createProfile => 'Profilimi yarat';

  @override
  String get save => 'Yadda saxla';

  @override
  String get photos => 'Şəkillər';

  @override
  String photosMin(int min) {
    return 'Kartının görünməsi üçün ən azı $min şəkil əlavə et. Birincisi üz qabığıdır.';
  }

  @override
  String photosMax(int max) {
    return 'Ən çox $max şəkil. Birincisi üz qabığıdır; dəyişmək üçün şəklə toxun.';
  }

  @override
  String get addPhoto => 'Şəkil əlavə et';

  @override
  String get cover => 'Üz qabığı';

  @override
  String get removePhoto => 'Şəkli sil';

  @override
  String get pauseProfile => 'Profilimi dayandır';

  @override
  String get pauseHint =>
      'Heç kim səni görmür və yeni kart gəlmir; uyğunluqların və söhbətlərin qalır.';

  @override
  String get deleteData => 'Uyğunluq məlumatlarımı sil';

  @override
  String get deleteDataHint =>
      'Profil, şəkillər və bəyənmələr silinir; uyğunluqların bitir. Açıq razılığın geri alınmış olur.';

  @override
  String get deleteDataTitle => 'Uyğunluq məlumatlarını sil';

  @override
  String get deleteDataBody =>
      'Uyğunluq profilin, şəkillərin və bəyənmələrin həmişəlik silinir; bütün uyğunluqların bitir. Bu geri qaytarılmır.';

  @override
  String get delete => 'Sil';

  @override
  String get dataDeleted => 'Uyğunluq məlumatların silindi.';

  @override
  String get itsAMatch => 'Uyğunlaşdınız!';

  @override
  String bothLiked(String name) {
    return 'Sən və $name bir-birinizi bəyəndiniz.';
  }

  @override
  String get keepSwiping => 'Sürüşdürməyə davam et';

  @override
  String get sendMessage => 'Mesaj göndər';

  @override
  String get reportProfile => 'Profildən şikayət et';

  @override
  String get reportPhoto => 'Bu şəkildən şikayət et';

  @override
  String get block => 'Blokla';

  @override
  String get blockHint => 'Bir-birinizi heç yerdə görməzsiniz.';

  @override
  String get cancel => 'İmtina et';

  @override
  String get newMatch => 'Kiminləsə uyğunlaşdın!';

  @override
  String tapToSee(String date) {
    return 'Kim olduğunu görmək üçün toxun · $date';
  }

  @override
  String get revealReason =>
      'Kiminləsə uyğunlaşdın! Kim olduğunu görmək üçün Uyğunluqlarım paketini al.';

  @override
  String get keepFriend => 'Yalnız dost qal';

  @override
  String get keepDating => 'Yalnız sevgili qal';

  @override
  String keepFriendBody(String name) {
    return '$name ilə sevgili uyğunluğunuz ikiniz üçün də bitir; dost kimi uyğunluğunuz və söhbətiniz davam edir.';
  }

  @override
  String keepDatingBody(String name) {
    return '$name ilə dost uyğunluğunuz ikiniz üçün də bitir; sevgili kimi uyğunluğunuz və söhbətiniz davam edir.';
  }

  @override
  String get keptFriend => 'Artıq yalnız dost kimi uyğunlaşmısınız.';

  @override
  String get keptDating => 'Artıq yalnız sevgili kimi uyğunlaşmısınız.';

  @override
  String get continueAction => 'Davam et';

  @override
  String get endMatch => 'Uyğunluğu bitir';

  @override
  String endMatchBody(String name) {
    return '$name ilə uyğunluğun bitir, söhbətiniz ikiniz üçün də bağlanır. Bu geri qaytarılmır.';
  }

  @override
  String get end => 'Bitir';

  @override
  String get matchEnded => 'Uyğunluq bitdi.';

  @override
  String get noMatches =>
      'Hələ uyğunluğun yoxdur. Bir-birinizi bəyəndiyiniz insanlar burada görünür.';

  @override
  String get backToDiscover => 'Kəşfə qayıt';

  @override
  String get report => 'Şikayət et';

  @override
  String get matching => 'Uyğunluq';

  @override
  String get admirers => 'Səni bəyənənlər';

  @override
  String get packages => 'Paketlər';

  @override
  String get more => 'Digər';

  @override
  String get filtersLocked =>
      'Yaş, il və maraq sahəsinə görə filtr Limitsiz Bəyənmə paketi ilə açılır.';

  @override
  String get filters => 'Filtrlər';

  @override
  String get suspended =>
      'Uyğunluq profilin platforma komandası tərəfindən bağlandı. Ətraflı məlumat üçün Dəstəyə yaza bilərsən.';

  @override
  String addPhotosToStart(int min) {
    return 'Kartının görünməsi və kəşfə başlaman üçün ən azı $min şəkil əlavə et.';
  }

  @override
  String get paused =>
      'Profilin dayandırılıb; heç kim səni görmür. Uyğunluqların və söhbətlərin qalır.';

  @override
  String get likesOut =>
      'Bugünkü pulsuz bəyənmələrin bitdi. Limitsiz Bəyənmə ilə istədiyin qədər bəyən.';

  @override
  String get supersOut => 'Bugünkü super bəyənmələrin bitdi. Sabah yenilənir.';

  @override
  String get superUsed =>
      'Bugünkü super bəyənməni istifadə etdin. Super Bəyənmə paketi ilə hər gün 5 dənə.';

  @override
  String get rewindLocked =>
      'Səhvən keçdiyin şəxsi geri gətirmək Limitsiz Bəyənmə paketi ilə açılır.';

  @override
  String rewoundTo(String mode) {
    return 'Son keçdiyin şəxs $mode destəsinə qayıtdı.';
  }

  @override
  String boostReason(int minutes) {
    return 'Önə çıxanda $minutes dəqiqə destələrin ən başında görünürsən.';
  }

  @override
  String boosting(int minutes) {
    return 'Önə çıxırsan. $minutes dəqiqə qaldı.';
  }

  @override
  String get boostUsed =>
      'Bugünkü önə çıxma haqqını istifadə etdin. Sabah yenilənir.';

  @override
  String get boost => 'Önə çıx';

  @override
  String boostBody(int minutes) {
    return '$minutes dəqiqə ortaq qruplarındakı insanların destəsində ən başda görünürsən. Gündə bir dəfə istifadə olunur.';
  }

  @override
  String boosted(int minutes) {
    return 'Önə çıxdın! $minutes dəqiqə ən başdasan.';
  }

  @override
  String get deckEmpty =>
      'Hələlik göstəriləcək kimsə qalmadı. Yeni qruplara qoşulduqca və insanlar uyğunluğu açdıqca bura dolar.';

  @override
  String get deckEmptyFiltered =>
      'Filtrlərinə uyğun kimsə qalmadı. Filtrləri genişləndirməyi yoxla.';

  @override
  String get refresh => 'Yenilə';

  @override
  String get clearFilters => 'Filtrləri təmizlə';

  @override
  String allowanceUnlimited(int supers) {
    return 'Limitsiz bəyənmə · $supers super bəyənmə haqqın var.';
  }

  @override
  String get allowanceOut => 'Bugünkü bəyənmələrin bitdi; sabah yenilənir.';

  @override
  String allowance(int likes, int supers) {
    return 'Bu gün $likes bəyənmə və $supers super bəyənmə haqqın var.';
  }

  @override
  String get undo => 'Geri al';

  @override
  String get pass => 'Keç';

  @override
  String get superLike => 'Super bəyən';

  @override
  String get like => 'Bəyən';

  @override
  String get introTitle => 'Ortaq qruplarından yeni insanlarla tanış ol';

  @override
  String get intro1 =>
      'Yalnız üzvü olduğun və ya izlədiyin qruplarda uyğunluğu açmış insanları görürsən.';

  @override
  String get intro2 =>
      'Kartı sağa sürüşdür bəyən, sola sürüşdür keç, yuxarı sürüşdür super bəyən.';

  @override
  String get intro3 =>
      'İkiniz də bir-birinizi bəyənəndə uyğunlaşırsınız. Uyğunlaşdığın şəxsə Uyğunluq Söhbəti paketi ilə yazırsan.';

  @override
  String get intro4 =>
      'Dost və Sevgili ayrı rejimlərdir; istədiyini və ya ikisini seçirsən.';

  @override
  String get intro5 =>
      'Profilin yalnız uyğunluğu açanlara görünür. İstədiyin an dayandırır və ya tamamilə silirsən.';

  @override
  String get createMyProfile => 'Uyğunluq profilimi yarat';

  @override
  String seePackageOf(String package) {
    return '$package paketinə bax';
  }

  @override
  String get allPackages => 'Bütün paketlər';

  @override
  String get packagesTitle => 'Uyğunluq paketləri';

  @override
  String get packagesIntro =>
      'Profil açmaq və sürüşdürmək pulsuzdur. Hər xüsusiyyət ayrı paketdir; yalnız istədiyini al.';

  @override
  String get adminAllOpen => 'İdarəçi kimi bütün paketlər açıqdır';

  @override
  String openUntil(String date) {
    return '$date tarixinədək açıqdır';
  }

  @override
  String ageFilter(int min, int max) {
    return 'Yaş: $min – $max';
  }

  @override
  String get allProvinces => 'Bütün illər';

  @override
  String get interest => 'Maraq sahəsi';

  @override
  String get all => 'Hamısı';

  @override
  String get apply => 'Tətbiq et';

  @override
  String get clear => 'Təmizlə';

  @override
  String get noAdmirers =>
      'Hələlik gözləyən bəyənmə yoxdur. Sürüşdürməyə davam et; səni bəyənənlər burada görünür.';

  @override
  String get backToSwiping => 'Sürüşdürməyə qayıt';

  @override
  String get likeAndMatch => 'Bəyən və uyğunlaş';

  @override
  String get noPendingLikes => 'Hələ gözləyən bəyənmə yoxdur';

  @override
  String likedYouCount(int count) {
    return '$count nəfər səni bəyəndi';
  }

  @override
  String get admirersPitch =>
      'Səni Bəyənənlər paketi ilə kim olduqlarını gör, bəyənərək dərhal uyğunlaş.';

  @override
  String get seePackage => 'Paketə bax';
}
