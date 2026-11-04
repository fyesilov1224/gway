// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'social_app_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Azerbaijani (`az`).
class SocialAppL10nAz extends SocialAppL10n {
  SocialAppL10nAz([String locale = 'az']) : super(locale);

  @override
  String get posts => 'Paylaşımlar';

  @override
  String get newPost => 'Yeni paylaşım';

  @override
  String get noOwnPosts =>
      'Hələ paylaşım etməmisən. İlk şəklini və ya videonu paylaş.';

  @override
  String get noPosts => 'Hələ paylaşım yoxdur.';

  @override
  String get shareFirstOwn => 'İlk paylaşımını et';

  @override
  String get groupFirstPost => 'Qrupun lentinə ilk paylaşımı sən et.';

  @override
  String get groupNoPosts => 'Bu qrupda hələ paylaşım yoxdur.';

  @override
  String get shareFirstGroup => 'İlk paylaşımı et';

  @override
  String get groupNotFound => 'Qrup tapılmadı.';

  @override
  String get memoriesEmpty =>
      'Hələ xatirə paylaşılmayıb. İştirakçılar şəkillərini bura əlavə edə bilər.';

  @override
  String get plan => 'Paket';

  @override
  String get payment => 'Ödəniş';

  @override
  String get onlyOwnerBilling =>
      'Paket əməliyyatlarını yalnız qrup sahibi edə bilər.';

  @override
  String get backToGroup => 'Qrupa qayıt';

  @override
  String get writeSupportAboutGroup =>
      'Bu qrupla bağlı platforma komandasına yaz';

  @override
  String get search => 'Axtar';

  @override
  String get notifications => 'Bildirişlər';

  @override
  String get goodNight => 'Gecən xeyrə';

  @override
  String get goodMorning => 'Sabahın xeyir';

  @override
  String get goodAfternoon => 'Günortanız xeyir';

  @override
  String get goodEvening => 'Axşamınız xeyir';

  @override
  String greetingName(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String get tabToday => 'Bu gün';

  @override
  String get tabGroups => 'Qruplar';

  @override
  String get tabCalendar => 'Təqvim';

  @override
  String get tabMe => 'Mən';

  @override
  String get tonightSay => 'Boşsansa de, masa qur';

  @override
  String get tonightTableSet => 'Masan quruldu';

  @override
  String get tonightInvited => 'Masaya dəvətin var';

  @override
  String tonightFreeWithYou(int count) {
    return '$count nəfər səninlə boşdur';
  }

  @override
  String get tonightFreeUntil => 'Boşsan · 04:00-a qədər';

  @override
  String tonightFreeCount(int count) {
    return '$count nəfər bu axşam boşdur';
  }

  @override
  String get upcomingNone => 'Qruplarının planları';

  @override
  String upcomingMine(int count, int mine) {
    return '$count plan · $mine iştirak';
  }

  @override
  String upcomingCount(int count) {
    return '$count plan, 60 gün';
  }

  @override
  String get forToday => 'Bu gün üçün';

  @override
  String get tonight => 'Bu axşam';

  @override
  String get upcoming => 'Yaxınlaşanlar';

  @override
  String get share => 'Paylaş';

  @override
  String get post => 'Paylaşım';

  @override
  String get postHint => '10 şəkil və ya videoya qədər';

  @override
  String get story => 'Hekayə';

  @override
  String get storyHint => '24 saat görünür';

  @override
  String get group => 'Qrup';

  @override
  String get groupHint => 'Öz icmanı qur';

  @override
  String get create => 'Yarat';

  @override
  String get messages => 'Mesajlar';

  @override
  String get matching => 'Uyğunlaşma';

  @override
  String get myGroups => 'Qruplarım';

  @override
  String get pageNotFound =>
      'Axtardığın səhifə tapılmadı. Keçid köhnə və ya səhv ola bilər.';

  @override
  String get backHome => 'Ana səhifəyə qayıt';

  @override
  String get groupsLeague => 'Qruplar Liqası';

  @override
  String get exploreOnMap => 'Xəritədə kəşf et';

  @override
  String get yearMenu => 'İlin xülasəsi, kəşf xəritəm və tanış olduqlarım';

  @override
  String get yearSummary => 'İlin xülasəsi';

  @override
  String get yearSummaryHint => 'Bu ilki görüşlərin, paylaşıla bilən kart';

  @override
  String get explorationMap => 'Kəşf xəritəm';

  @override
  String get explorationMapHint => 'İştirak etdiyin tədbirlərin əyalətləri';

  @override
  String get metPeople => 'Tanış olduqlarım';

  @override
  String get metPeopleHint => 'Tədbirlərdə əl sıxışdığın insanlar';

  @override
  String get findTeammates => 'Komanda yoldaşı tap';

  @override
  String get saved => 'Saxlanılanlar';

  @override
  String get gateError =>
      'Məlumatların yüklənmədi. Bağlantını yoxla və yenidən cəhd et.';

  @override
  String get searchPeople => 'İnsan axtar';

  @override
  String get clearSearch => 'Axtarışı təmizlə';

  @override
  String get settings => 'Ayarlar';

  @override
  String get editProfile => 'Profili redaktə et';

  @override
  String get teammatePrefs => 'Komanda yoldaşı seçimləri';

  @override
  String get matchProfile => 'Uyğunlaşma profili';

  @override
  String get voiceCalls => 'Səsli zəng';

  @override
  String get blockedAccounts => 'Bloklanmış hesablar';

  @override
  String get storyArchive => 'Hekayə arxivi';

  @override
  String get notificationPrefs => 'Bildiriş seçimləri';

  @override
  String get mySanctions => 'Qrup sanksiyalarım';

  @override
  String get userGuide => 'İstifadə təlimatı';

  @override
  String get supportFeedback => 'Dəstək və rəy';

  @override
  String newReplies(int count) {
    return '$count yeni cavab';
  }

  @override
  String get twoFactor => 'İki addımlı təsdiq';

  @override
  String get legalDocuments => 'Hüquqi mətnlər';

  @override
  String get deleteAccount => 'Hesabı sil';

  @override
  String get signOut => 'Çıxış et';

  @override
  String get nowPrivate => 'Hesabın artıq gizlidir.';

  @override
  String get nowPublic =>
      'Hesabın artıq hamıya açıqdır; gözləyən istəklər təsdiqləndi.';

  @override
  String get privateAccount => 'Gizli hesab';

  @override
  String get privateAccountHint =>
      'Açıq olanda paylaşımlarını və hekayələrini yalnız təsdiqlədiyin izləyicilər görür.';

  @override
  String get groupsNowPublic => 'Qrupların artıq profilində hamıya görünür.';

  @override
  String get groupsNowMembers =>
      'Qrupların artıq yalnız eyni qrupdakı üzvlərə görünür.';

  @override
  String get showGroups => 'Qruplarımı profilimdə göstər';

  @override
  String get showGroupsHint =>
      'Bağlı olanda qrupdakı üzvlüyünü yalnız həmin qrupun üzvləri görür; başqa qrupların idarəçiləri görə bilməz.';

  @override
  String get language => 'Dil';
}
