// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'events_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Azerbaijani (`az`).
class EventsL10nAz extends EventsL10n {
  EventsL10nAz([String locale = 'az']) : super(locale);

  @override
  String get pollSingle => 'Bu sorğuda yalnız bir variant seçmək olar.';

  @override
  String get pollOptionGone => 'Bu variant artıq yoxdur. Səhifəni yenilə.';

  @override
  String get reviewWindow =>
      'Qiymətləndirmə iştirakçılar üçün tədbir bitdikdən sonra 30 gün açıqdır.';

  @override
  String get greeterNeedsAttendance =>
      'Qarşılayıcı olmaq üçün qrupun bir tədbirinə qatılmış olmalısan.';

  @override
  String get note80 => 'Qeyd ən çox 80 simvol ola bilər.';

  @override
  String get pollClosed => 'Bu sorğu bağlanıb və ya səs verə bilməzsən.';

  @override
  String get cover5mb => 'Örtük şəkli ən çox 5 MB ola bilər.';

  @override
  String get imagesOnly => 'Yalnız JPEG, PNG və ya WebP şəkil yükləmək olar.';

  @override
  String get claimNotAllowed =>
      'Bu tapşırıq barədə hazırda bildiriş etmək olmur; tapşırıq bitib və ya qrupda deyilsən.';

  @override
  String get claimApprovedLocked =>
      'Təsdiqlənmiş bildiriş geri götürülə bilməz.';

  @override
  String get claimDuplicate => 'Bu tapşırığı artıq bildirmisən.';

  @override
  String get repeatsWeekly => 'Hər həftə təkrarlanır';

  @override
  String get repeatsBiweekly => 'İki həftədən bir təkrarlanır';

  @override
  String surprisePlace(String place) {
    return 'Sürpriz məkan · $place';
  }

  @override
  String get goalPersonal => 'Şəxsi hədəf';

  @override
  String get goalPersonalHint => 'Hər üzv öz sayını tamamlayır.';

  @override
  String get goalGroup => 'Qrup hədəfi';

  @override
  String get goalGroupHint => 'Hamının töhfəsi bir sayğacda toplanır.';

  @override
  String get goalTeam => 'Komanda hədəfi';

  @override
  String get goalTeamHint =>
      'İdarəçi komandaları qurur; komandanın ortaq sayğacı olur.';

  @override
  String get goalTask => 'Təsdiqli tapşırıq';

  @override
  String get goalTaskHint => 'Üzv \"Etdim\" deyir, idarəçi təsdiqləyir.';

  @override
  String unitAttended(int count) {
    return 'iştirak';
  }

  @override
  String unitOrganized(int count) {
    return 'təşkilat';
  }

  @override
  String unitMemories(int count) {
    return 'xatirə';
  }

  @override
  String get claimPending => 'Təsdiq gözləyir';

  @override
  String get claimApproved => 'Təsdiqləndi';

  @override
  String get claimRejected => 'Təsdiqlənmədi';

  @override
  String get notClaimedYet => 'Hələ bildirilməyib';

  @override
  String get whenAny => 'Hər zaman';

  @override
  String get whenToday => 'Bu gün';

  @override
  String get whenWeek => '7 gün ərzində';

  @override
  String get viewDay => 'Gün';

  @override
  String get viewWeek => 'Həftə';

  @override
  String get viewMonth => 'Ay';

  @override
  String countAttended(int count) {
    return '$count iştirak';
  }

  @override
  String countOrganized(int count) {
    return '$count təşkilat';
  }

  @override
  String countMemories(int count) {
    return '$count xatirə';
  }

  @override
  String countReviews(int count) {
    return '$count qiymətləndirmə';
  }

  @override
  String countWelcomed(int count) {
    return '$count qarşılama';
  }

  @override
  String countHandshakes(int count) {
    return '$count əl sıxma';
  }

  @override
  String countHeld(int count) {
    return '$count tədbir';
  }

  @override
  String countGoodReviews(int count) {
    return '$count məmnunluq';
  }

  @override
  String leagueStanding(String month, int groups, int rank, int points) {
    return '$month: $groups qrup arasında $rank. yerdə, $points xal.';
  }

  @override
  String goingCount(int count) {
    return '$count iştirakçı';
  }

  @override
  String goingOfCapacity(int count, int capacity) {
    return '$count / $capacity iştirakçı';
  }

  @override
  String firstEventOfYear(String title) {
    return 'İlin ilk tədbiri: $title';
  }

  @override
  String firstEventOfYearOn(String title, String date) {
    return 'İlin ilk tədbiri: $title · $date';
  }

  @override
  String get myCalendar => 'Təqvimim';

  @override
  String get groupCalendar => 'Qrup təqvimi';

  @override
  String get previous => 'Əvvəlki';

  @override
  String get next => 'Sonrakı';

  @override
  String get today => 'Bu gün';

  @override
  String get groupsEvents => 'Qruplarımın tədbirləri';

  @override
  String get showNotJoined => 'Qatılmadıqlarını da göstər';

  @override
  String get noJoinedInRange =>
      'Bu tarixlərdə qatıldığın tədbir yoxdur. Qruplarının tədbirlərinə də baxa bilərsən.';

  @override
  String get noEventsInRange => 'Bu tarixlərdə tədbir yoxdur.';

  @override
  String get showGroupsEvents => 'Qruplarımın tədbirlərini göstər';

  @override
  String get backToToday => 'Bu günə qayıt';

  @override
  String get noEventsDay => 'Bu gündə tədbir yoxdur.';

  @override
  String get contributions => 'İcmaya töhfə';

  @override
  String get howBadges => 'Nişanlar necə qazanılır?';

  @override
  String get badgesEmpty =>
      'Bir tədbirə qatılanda töhfən və ilk nişanın burada görünür.';

  @override
  String get badgesRules =>
      'Nişanlar yalnız həqiqətən etdiklərindən hesablanır: qatıldığın və təşkil etdiyin tədbirlər, paylaşdığın xatirələr və qiymətləndirmələrin. Bəyənmə və izləyici sayı nəzərə alınmır. Təşkilatçının \"gəlmədi\" kimi işarələdiyi iştiraklar sayılmır. Heç kim sıralanmır.';

  @override
  String get categoryFan => 'Kateqoriya həvəskarı';

  @override
  String get pastEvents => 'Keçmiş tədbirlər';

  @override
  String get noPastEvents => 'Bu qrupun hələ keçmiş tədbiri yoxdur.';

  @override
  String get refresh => 'Yenilə';

  @override
  String get canceled => 'Ləğv edildi';

  @override
  String get olderEvents => 'Daha köhnə tədbirlər';

  @override
  String get completed => 'Tamamladın';

  @override
  String get ended => 'Başa çatdı';

  @override
  String teamName(String name) {
    return 'Komanda: $name';
  }

  @override
  String get teamNotice =>
      'Bir komandaya əlavə olunanda irəliləyişin burada görünür.';

  @override
  String get goals => 'Hədəflər';

  @override
  String get createGoal => 'Hədəf yarat';

  @override
  String get goalsEmpty =>
      'Məsələn, \"Bu ay 4 yürüyüşə qatıl\" və ya \"Birlikdə 50 iştirak\"; ilk hədəfi yarat.';

  @override
  String get claimSent => 'Bildirişin idarəçiyə göndərildi.';

  @override
  String get goal => 'Hədəf';

  @override
  String get goalCountsRule =>
      'Yalnız bu qrupun dövr ərzindəki tədbirləri sayılır; \"gəlmədi\" işarələnən iştiraklar sayılmır.';

  @override
  String get withdrawClaim => 'Bildirişi geri götür';

  @override
  String get claimWithdrawn => 'Bildirişin geri götürüldü.';

  @override
  String get done => 'Etdim';

  @override
  String get teams => 'Komandalar';

  @override
  String get createTeam => 'Komanda qur';

  @override
  String get noTeams => 'Hələ komanda yoxdur.';

  @override
  String deleteTeam(String name) {
    return '$name komandasını sil';
  }

  @override
  String get teamDeleted => 'Komanda silindi.';

  @override
  String pendingClaims(int count) {
    return 'Təsdiq gözləyən bildirişlər ($count)';
  }

  @override
  String get claimRejectedToast => 'Bildiriş təsdiqlənmədi.';

  @override
  String get decline => 'Rədd et';

  @override
  String get approve => 'Təsdiqlə';

  @override
  String taskDone(String name) {
    return '$name tapşırığı tamamladı.';
  }

  @override
  String completions(int count) {
    return 'Tamamlayanlar ($count)';
  }

  @override
  String get noCompletions =>
      'Hələ tamamlayan yoxdur. Tamamlayan hər kəs profilində bu hədəfin nişanını alır.';

  @override
  String get goalCanceled => 'Hədəf ləğv edildi.';

  @override
  String get cancelGoal => 'Hədəfi ləğv et';

  @override
  String teamCreated(String name) {
    return '\"$name\" komandası quruldu.';
  }

  @override
  String get teamNameLabel => 'Komanda adı';

  @override
  String get createTheTeam => 'Komandanı qur';

  @override
  String createTeamWith(int count) {
    return 'Komandanı qur ($count nəfər)';
  }

  @override
  String get goalCreated => 'Hədəf yaradıldı.';

  @override
  String get title => 'Başlıq';

  @override
  String get goalTitleExample => 'Məs. Oktyabr yürüyüşləri';

  @override
  String get taskTitleExample => 'Məs. Yeni üzvə marşrutu izah et';

  @override
  String get titleMin3 => 'Başlıq ən azı 3 simvol olmalıdır.';

  @override
  String get descriptionOptional => 'Açıqlama (istəyə bağlı)';

  @override
  String get targetNumber => 'Hədəf sayı';

  @override
  String get target1to1000 => '1–1000 arası rəqəm yaz.';

  @override
  String get period => 'Dövr';

  @override
  String periodRange(String from, String to) {
    return '$from – $to (ən çox 92 gün)';
  }

  @override
  String get createTheGoal => 'Hədəfi yarat';

  @override
  String get iDidTask => 'Tapşırığı etdim';

  @override
  String get whatDidYouDo => 'Nə etdin? (istəyə bağlı)';

  @override
  String get whatDidYouDoHint => 'İdarəçi bu qeydi görərək təsdiqləyir.';

  @override
  String get cancel => 'İmtina et';

  @override
  String get send => 'Göndər';

  @override
  String get handshake => 'Əl sıxma';

  @override
  String get handshakeHint =>
      'Tanış olduğun şəxslə kodlarınızı oxudun; ikiniz də \"Tanış olduqlarım\" siyahısına əlavə olunursunuz.';

  @override
  String get open => 'Aç';

  @override
  String handshakeAt(String title) {
    return 'Əl sıxma · $title';
  }

  @override
  String get myCode => 'Kodum';

  @override
  String get scan => 'Oxut';

  @override
  String get yourHandshakeCode => 'Əl sıxma kodun';

  @override
  String get codeHint =>
      'Qarşındakı bu kodu \"Oxut\" bölməsindən oxutsun və ya yazsın. Kod bir neçə dəqiqədən bir yenilənir; şəkli sonradan işə yaramır.';

  @override
  String get cameraFailed =>
      'Kamera açılmadı. Kamera icazəsini ayarlardan verə və ya kodu aşağıya yaza bilərsən.';

  @override
  String get scanHint =>
      'Qarşındakının QR kodunu kameraya göstər və ya kodunu yaz.';

  @override
  String get typeCodeHint => 'Qarşındakının ekranındakı 6 simvollu kodu yaz.';

  @override
  String get code => 'Kod';

  @override
  String get alreadyMet => 'Siz artıq tanışsınız';

  @override
  String get metNow => 'Tanış oldunuz!';

  @override
  String personWithUsername(String name, String username) {
    return '$name (@$username)';
  }

  @override
  String get ok => 'Oldu';

  @override
  String get metPeople => 'Tanış olduqlarım';

  @override
  String get metEmpty =>
      'Bir tədbirdə kimləsə əl sıxanda burada görünür. Əl sıxma tədbir səhifəsində açılır.';

  @override
  String get goToCalendar => 'Təqvimimə keç';

  @override
  String get metPrivacy =>
      'Yalnız sən görürsən. Profilində yalnız əl sıxma sayın görünür.';

  @override
  String metRow(String username, String event, String date) {
    return '@$username · $event · $date';
  }

  @override
  String get howPoints => 'Xallar necə hesablanır?';

  @override
  String get leagueIntro =>
      'Eyni əyalətdə eyni kateqoriyalı qruplar hər ay yarışır. Ayın bitən tədbirləri sayılır.';

  @override
  String get ruleAttendance => 'İştirak: 1 xal';

  @override
  String get ruleAttendanceHint => 'Gələn hər şəxs; bir tədbirdə ən çox 30.';

  @override
  String get ruleHeld => 'Tədbir: 5 xal';

  @override
  String get ruleHeldHint =>
      'Təşkilatçıdan başqa ən azı 3 nəfərin gəldiyi hər tədbir.';

  @override
  String get ruleWelcome => 'Qarşılama: 3 xal';

  @override
  String get ruleWelcomeHint => 'İlk dəfə gələn birinin qarşılanması.';

  @override
  String get ruleReview => 'Məmnunluq: 1 xal';

  @override
  String get ruleReviewHint => '4 və ya 5 ulduzlu hər qiymətləndirmə.';

  @override
  String get leagueRulesNote =>
      'Gəlmədi işarələnənlər sayılmır. Nəticələr ay bitdikdən 8 gün sonra qəti olur; ilk üçə düşən qrupların üzvlərinə xəbər verilir.';

  @override
  String get groupsLeague => 'Qruplar Liqası';

  @override
  String get category => 'Kateqoriya';

  @override
  String get province => 'Əyalət';

  @override
  String get month => 'Ay';

  @override
  String seasonClosed(String month) {
    return '$month mövsümü bağlandı; sıralama qətidir.';
  }

  @override
  String get seasonRunning =>
      'Mövsüm davam edir. Xallar tədbirlər bitdikcə yenilənir; nəticələr ay bitdikdən 8 gün sonra qəti olur.';

  @override
  String leagueEmpty(String province) {
    return '$province liqasında bu ay hələ xal alan qrup yoxdur.';
  }

  @override
  String points(int count) {
    return '$count xal';
  }

  @override
  String rank(int rank) {
    return '$rank.';
  }

  @override
  String leagueName(String province, String category) {
    return '$province · $category liqası';
  }

  @override
  String get noPointsYet =>
      'Bu ay hələ xal yoxdur. Bitən tədbirlər, gələnlər və qarşılamalar xal gətirir.';

  @override
  String get mapAttribution =>
      '© Stadia Maps © OpenMapTiles © OpenStreetMap iştirakçıları';

  @override
  String get map => 'Xəritə';

  @override
  String get mapView => 'Xəritə görünüşü';

  @override
  String get listView => 'Siyahı görünüşü';

  @override
  String get all => 'Hamısı';

  @override
  String get wholeArea => 'Bütün ərazi';

  @override
  String km(int km) {
    return '$km km';
  }

  @override
  String get mapLoadFailed => 'Xəritə məlumatları yüklənmədi.';

  @override
  String get retry => 'Yenidən cəhd et';

  @override
  String get noFilterResults => 'Bu filtrlərlə heç nə tapılmadı.';

  @override
  String get clearFilters => 'Filtrləri təmizlə';

  @override
  String get noNearby => 'Bu ərazidə yaxınlaşan tədbir və ya qrup yoxdur.';

  @override
  String get zoomOut => 'Uzaqlaşdır';

  @override
  String get openEvent => 'Tədbiri aç';

  @override
  String memberCount(int count) {
    return '$count üzv';
  }

  @override
  String get noVisible =>
      'Görünən ərazidə yaxınlaşan tədbir və ya qrup yoxdur.';

  @override
  String get backToMap => 'Xəritəyə qayıt';

  @override
  String upcomingCount(int count) {
    return 'Yaxınlaşan tədbirlər ($count)';
  }

  @override
  String get directions => 'Yol göstəricisi';

  @override
  String get meetingPointOptional => 'Görüş nöqtəsi (istəyə bağlı)';

  @override
  String get meetingPointHint => 'Xəritədə seç; tədbir xəritədə görünür.';

  @override
  String pointPicked(String lat, String lng) {
    return 'Seçildi · $lat, $lng';
  }

  @override
  String get removeMeetingPoint => 'Görüş nöqtəsini sil';

  @override
  String get meetingPoint => 'Görüş nöqtəsi';

  @override
  String get pickHint => 'Xəritəni yaxınlaşdır və görüş nöqtəsinə toxun.';

  @override
  String get pickAgainHint => 'Nöqtəni dəyişmək üçün başqa yerə toxun.';

  @override
  String get pickThisPoint => 'Bu nöqtəni seç';

  @override
  String get mapUnavailable => 'Xəritə hazırda əlçatan deyil.';
}
