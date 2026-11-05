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

  @override
  String get pollClosedShort => 'Bağlandı';

  @override
  String closesAt(String date) {
    return 'Bağlanma: $date';
  }

  @override
  String get multipleAllowed => 'Bir neçə seçim';

  @override
  String get anonymousVote => 'Gizli səsvermə';

  @override
  String votersCount(int count) {
    return '$count nəfər səs verdi';
  }

  @override
  String get pollOptions => 'Sorğu seçimləri';

  @override
  String get pollClosedToast => 'Sorğu bağlandı.';

  @override
  String get pollDeleted => 'Sorğu silindi.';

  @override
  String get closePoll => 'Sorğunu bağla';

  @override
  String get deletePoll => 'Sorğunu sil';

  @override
  String get vote => 'Səs ver';

  @override
  String get voteSaved => 'Səsin qeydə alındı.';

  @override
  String get voters => 'Səs verənlər';

  @override
  String peopleCount(int count) {
    return '$count nəfər';
  }

  @override
  String get polls => 'Sorğular';

  @override
  String get openPoll => 'Sorğu aç';

  @override
  String get pollsEmpty => 'Üzvlərə sual ver; məsələn, hansı gün görüşək?';

  @override
  String get pollOpened => 'Sorğu açıldı.';

  @override
  String get question => 'Sual';

  @override
  String get questionExample => 'Məs. Hansı gün görüşək?';

  @override
  String get questionMin3 => 'Sual ən azı 3 simvol olmalıdır.';

  @override
  String optionN(int n) {
    return '$n. variant';
  }

  @override
  String get removeOption => 'Variantı sil';

  @override
  String get optionRequired => 'Variantı yaz və ya sil.';

  @override
  String get addOption => 'Variant əlavə et';

  @override
  String get allowMultiple => 'Bir neçə seçim olsun';

  @override
  String get anonymousHint => 'Kimin nəyə səs verdiyi göstərilmir.';

  @override
  String get noEndTime => 'Bitmə vaxtı yoxdur';

  @override
  String get add => 'Əlavə et';

  @override
  String get removeEndTime => 'Bitmə vaxtını sil';

  @override
  String get startPoll => 'Sorğunu aç';

  @override
  String get cardFooter => 'gway · icmanı tap';

  @override
  String myYear(int year) {
    return 'Mənim $year';
  }

  @override
  String get statAttended => 'tədbirə qatıldım';

  @override
  String get statHours => 'saat birlikdə idik';

  @override
  String get statOneGroup => 'qrupla görüşdüm';

  @override
  String get statGroups => 'fərqli qrupla görüşdüm';

  @override
  String get statProvinces => 'fərqli əyalətdə';

  @override
  String get statOrganized => 'tədbir təşkil etdim';

  @override
  String get statWelcomed => 'nəfəri ilk gəlişində qarşıladım';

  @override
  String get statMemories => 'xatirə paylaşdım';

  @override
  String get favorites => 'Ən sevdiklərim';

  @override
  String get topGroup => 'Ən çox birlikdə olduğum qrup';

  @override
  String topGroupLine(String group, int count) {
    return '$group · $count görüş';
  }

  @override
  String get iWasThere => 'Mən də orada idim';

  @override
  String get firstWithGroup => 'Bu qrupla ilk tədbirim.';

  @override
  String nthWithGroup(int n) {
    return 'Bu qrupla $n. tədbirim.';
  }

  @override
  String get shareFailed =>
      'Bu cihazda paylaşmaq olmadı. Kartın ekran şəklini çəkib paylaşa bilərsən.';

  @override
  String get share => 'Paylaş';

  @override
  String yearSummaryTitle(int year) {
    return '$year xülasəm';
  }

  @override
  String get yearEmpty =>
      'Bu il hələ tədbirə qatılmamısan. İlk görüşündən sonra xülasən burada yaranır.';

  @override
  String yearShareText(int year) {
    return 'Mənim $year ilim GWAY-də';
  }

  @override
  String mapSemantics(int count) {
    return 'Türkiyə xəritəsi: $count əyalət kəşf edildi';
  }

  @override
  String get explorationMap => 'Kəşf xəritəm';

  @override
  String get statExplored => 'əyaləti kəşf etdim';

  @override
  String get statMetAt => 'tədbirdə görüşdüm';

  @override
  String get recentExplored => 'Son kəşflərim';

  @override
  String get explorationEmpty =>
      'Qatıldığın tədbirlərin əyalətləri burada açılır. İlk görüşündən sonra xəritən rənglənir.';

  @override
  String get findOnMap => 'Xəritədə tədbir tap';

  @override
  String explorationShareText(int count) {
    return 'GWAY-də $count əyaləti kəşf etdim';
  }

  @override
  String get exploredProvinces => 'Kəşf etdiyin əyalətlər';

  @override
  String get explorationPrivacy =>
      'Yalnız sən görürsən. Qatıldığın və \"gəlmədi\" işarələnmədiyin tədbirlər sayılır.';

  @override
  String get tonightVisible =>
      'Bu axşam boş olduğunu ortaq qruplarındakılar görəcək. 04:00-da öz-özünə bağlanır.';

  @override
  String get joinedTable => 'Masaya qoşuldun.';

  @override
  String get declinedInvite => 'Dəvəti rədd etdin.';

  @override
  String get yourStatus => 'Statusun';

  @override
  String get visibleUntil4 => '04:00-a qədər görünürsən';

  @override
  String get notVisible => 'Hazırda görünmürsən';

  @override
  String get youreFree => 'Boşsan';

  @override
  String get tonightIntro =>
      'Boşsansa, ortaq qruplarındakılar görsün; birlikdə kiçik masa qura bilərsiniz.';

  @override
  String get imFreeTonight => 'Bu axşam boşam';

  @override
  String get noLongerFree => 'Artıq boş görünmürsən.';

  @override
  String get turnOffStatus => 'Statusu bağla';

  @override
  String get leftTable => 'Masadan çıxdın.';

  @override
  String get smallTable => 'Kiçik masa';

  @override
  String get smallTableHint =>
      'Boş olanlardan bir neçə nəfəri çağır; üç nəfər olanda masanın söhbəti açılır.';

  @override
  String get setUpTable => 'Kiçik masa qur';

  @override
  String tableInvitesSent(int count) {
    return '$count nəfərə dəvət göndərildi. Üç nəfər olanda masanın söhbəti açılır.';
  }

  @override
  String needMorePeople(int min, int now) {
    return 'Kiçik masa üçün ortaq qruplarından ən azı $min nəfərin də boş olması lazımdır (hazırda $now). Kimsə boş olduğunu deyəndə burada masa qura bilərsən.';
  }

  @override
  String freeFromGroups(int count) {
    return 'Ortaq qruplarından $count nəfər bu axşam boşdur';
  }

  @override
  String get chipCoffee => 'Qəhvə';

  @override
  String get chipWalk => 'Qısa gəzinti';

  @override
  String get chipFood => 'Yemək';

  @override
  String get chipCinema => 'Kino';

  @override
  String get tonightSheetHint =>
      'Yalnız ortaq qruplarındakı insanlar görür. Statusun 04:00-da öz-özünə bağlanır.';

  @override
  String get whatToDo => 'Nə etmək istərdin? (istəyə bağlı)';

  @override
  String get whatToDoHint => 'məs. qəhvə, qısa gəzinti';

  @override
  String get imFree => 'Boşam';

  @override
  String get yourTable => 'Masan';

  @override
  String joinedCount(int count) {
    return '$count nəfər qoşuldu';
  }

  @override
  String waitingCount(int count) {
    return '$count nəfər gözlənilir';
  }

  @override
  String get settingUp => 'Qurulur';

  @override
  String get chatOpen => 'Söhbət açıqdır';

  @override
  String get tableChat => 'Masanın söhbəti';

  @override
  String chatOpensWhen(int count) {
    return 'Söhbət daha $count nəfər qoşulanda açılır. Yeri və saatı orada birlikdə seçirsiniz.';
  }

  @override
  String get leaveTable => 'Masadan çıx';

  @override
  String tableInviteTitle(String name) {
    return '$name kiçik masa qurdu və səni də çağırır.';
  }

  @override
  String tableInviteStatus(int joined, int pending) {
    return '$joined nəfər qoşuldu · $pending nəfər gözlənilir. Üç nəfər olanda söhbət açılır.';
  }

  @override
  String get join => 'Qoşul';

  @override
  String get notTonight => 'Bu axşam olmaz';

  @override
  String get tonight => 'Bu axşam';

  @override
  String get freeTonight => 'Bu axşam boş olanlar';

  @override
  String get sharedGroupsOnly => 'Yalnız ortaq qruplarındakı insanlar';

  @override
  String get nobodyFree => 'Ortaq qruplarından hazırda boş olan yoxdur.';

  @override
  String get howItWorks => 'Necə işləyir?';

  @override
  String get howStep1 =>
      '\"Bu axşam boşam\" de; istəsən, nə etmək istədiyini yaz.';

  @override
  String get howStep2 =>
      'Ortaq qruplarındakılar səni görür, sən də boş olanları görürsən.';

  @override
  String get howStep3 =>
      'Kiçik masa qur; üç nəfər olanda masanın söhbəti açılır, yeri və saatı orada seçirsiniz.';

  @override
  String get upcoming => 'Yaxınlaşanlar';

  @override
  String get calendar => 'Təqvim';

  @override
  String get noUpcomingJoined => 'Qatıldığın yaxınlaşan tədbir yoxdur.';

  @override
  String get showAll => 'Hamısını göstər';

  @override
  String get noUpcoming60 => 'Qarşıdakı 60 gündə qruplarının tədbiri yoxdur.';

  @override
  String get findGroup => 'Qrup tap';

  @override
  String filterAll(int count) {
    return 'Hamısı · $count';
  }

  @override
  String filterMine(int count) {
    return 'Qatıldıqlarım · $count';
  }

  @override
  String get tomorrow => 'Sabah';

  @override
  String get going => 'Qatılırsan';

  @override
  String get waitlisted => 'Ehtiyat siyahıdadır';

  @override
  String get awaitingApproval => 'Təsdiq gözləyir';

  @override
  String get full => 'Doludur';

  @override
  String goingOfCapacityShort(int count, int capacity) {
    return '$count/$capacity iştirakçı';
  }

  @override
  String get startingSoon => 'Tezliklə başlayır';

  @override
  String get next6Hours => 'Qarşıdakı 6 saat';

  @override
  String get wantWelcome => 'Qarşılanmaq istəyirəm';

  @override
  String get wantWelcomeHint =>
      'Qrupun könüllü üzvlərindən biri səni girişdə qarşılayır; tək getmirsən.';

  @override
  String get noteForGreeter => 'Səni tanımaları üçün qeyd (istəyə bağlı)';

  @override
  String get noteForGreeterHint => 'Məs. Qırmızı gödəkcəliyəm, mavi çantam var';

  @override
  String get sendRequest => 'İstək göndər';

  @override
  String get welcomeRequestSent =>
      'İstəyin qarşılayıcılara göndərildi. Biri üzərinə götürəndə xəbər verəcəyik.';

  @override
  String get editMeetingNote => 'Görüş qeydini redaktə et';

  @override
  String welcomePerson(String name) {
    return '$name adlı şəxsi qarşıla';
  }

  @override
  String describedAs(String note) {
    return 'Özünü belə təsvir etdi: $note';
  }

  @override
  String get whereMeet => 'Harada görüşəcəksiniz?';

  @override
  String get whereMeetHint => 'Məs. Girişdəki kafenin önü, 08:45';

  @override
  String get save => 'Yadda saxla';

  @override
  String get iWillWelcome => 'Mən qarşılayaram';

  @override
  String get noteUpdated => 'Görüş qeydi yeniləndi.';

  @override
  String youWillWelcome(String name) {
    return '$name adlı şəxsi qarşılayacaqsan; görüş qeydini gördü.';
  }

  @override
  String get stopWelcoming => 'Qarşılamağı burax';

  @override
  String stopWelcomingBody(String name) {
    return '$name üçün yeni qarşılayıcı axtarılacaq və ona xəbər veriləcək.';
  }

  @override
  String get release => 'Burax';

  @override
  String get releasedWelcome =>
      'Qarşılamağı buraxdın; yeni qarşılayıcı axtarılır.';

  @override
  String get firstTime => 'İlk dəfə gəlirsən?';

  @override
  String greetersAvailable(int count) {
    return 'Bu qrupda $count qarşılayıcı var. Biri səni girişdə qarşılasın, qrupla tanış etsin.';
  }

  @override
  String get youWelcomed => 'Qarşıladıqların';

  @override
  String meetingAt(String note) {
    return 'Görüş: $note';
  }

  @override
  String get thankedYou => 'Sənə təşəkkür etdi';

  @override
  String optionsFor(String name) {
    return '$name üçün seçimlər';
  }

  @override
  String waitingWelcome(int count) {
    return 'Qarşılanmağı gözləyənlər ($count)';
  }

  @override
  String matchedCount(int count) {
    return '$count nəfər qarşılayıcı ilə eşləşdi.';
  }

  @override
  String get firstTimer => 'İlk dəfə gəlir';

  @override
  String get max3Welcomes => 'Bir tədbirdə ən çox 3 nəfəri qarşılaya bilərsən.';

  @override
  String get greeterJoinHint =>
      'Qarşılayıcısan. İlk dəfə gələnləri qarşılamaq üçün tədbirə qatıl.';

  @override
  String get lookingGreeter => 'Qarşılayıcı axtarılır';

  @override
  String get lookingGreeterHint =>
      'Qrupun qarşılayıcılarına xəbər verdik. Biri üzərinə götürəndə bildiriş gələcək.';

  @override
  String yourNote(String note) {
    return 'Qeydin: $note';
  }

  @override
  String get welcomeWithdrawn => 'Qarşılanma istəyin geri götürüldü.';

  @override
  String get withdrawRequest => 'İstəyi geri götür';

  @override
  String get greetedBy => 'Səni qarşılayan';

  @override
  String get willGreet => 'Səni qarşılayacaq';

  @override
  String get thank => 'Təşəkkür et';

  @override
  String thankReceived(String name) {
    return '$name təşəkkürünü aldı.';
  }

  @override
  String get thanked => 'Təşəkkür etdin.';

  @override
  String get cancelWelcome => 'Qarşılanmaqdan imtina et';

  @override
  String get nowGreeter =>
      'Artıq qarşılayıcısan. İlk dəfə gələn biri qarşılanmaq istəyəndə xəbər verəcəyik.';

  @override
  String get noLongerGreeter => 'Qarşılayıcılığı buraxdın.';

  @override
  String get welcomeSection => 'Qarşılama';

  @override
  String greetersCount(int count) {
    return '$count qarşılayıcı';
  }

  @override
  String get greeterIntro =>
      'İlk dəfə gələnlər tədbir səhifəsindən qarşılanmaq istəyə bilər. Qarşılayıcı olsan, xəbər alırsan; girişdə qarşılayır, qrupla tanış edirsən.';

  @override
  String greeterMemberHint(int count) {
    return 'Bu qrupda $count qarşılayıcı var. İlk tədbirində səhifədən \"Qarşılanmaq istəyirəm\" deyə bilərsən.';
  }

  @override
  String greeterVisitorHint(int count) {
    return 'Bu qrupda $count qarşılayıcı var: ilk tədbirinə tək getməyəcəksən, biri səni girişdə qarşılayacaq.';
  }

  @override
  String get becomeGreeter => 'Qarşılayıcı ol';

  @override
  String quoted(String text) {
    return '\"$text\"';
  }

  @override
  String seatsGoing(int count) {
    return '$count nəfər qatılır';
  }

  @override
  String seatsOf(int count, int capacity) {
    return '$count / $capacity nəfər';
  }

  @override
  String seatsOfWaiting(int count, int capacity, int waiting) {
    return '$count / $capacity nəfər · $waiting gözləyir';
  }

  @override
  String summaryAttended(int count) {
    return '$count nəfər qatıldı';
  }

  @override
  String summaryRating(String avg, int count) {
    return '$avg ★ ($count qiymətləndirmə)';
  }

  @override
  String waitlistPlace(int place) {
    return 'Gözləmə siyahısı · $place. sıra';
  }

  @override
  String get eventCanceled => 'Bu tədbir ləğv edildi.';

  @override
  String eventCanceledBecause(String reason) {
    return 'Bu tədbir ləğv edildi: $reason';
  }

  @override
  String reviewBy(String name, int stars) {
    return '$name, $stars ulduz';
  }

  @override
  String get conflicting => 'Üst-üstə düşür';

  @override
  String get events => 'Tədbirlər';

  @override
  String get create => 'Yarat';

  @override
  String eventsLeft(int count) {
    return 'Bu ay $count tədbir haqqın qalıb.';
  }

  @override
  String get eventsLimitReached =>
      'Bu ayın tədbir haqqı doldu. Paketi yüksəldərək artıra bilərsən.';

  @override
  String groupRating(String avg, int count) {
    return '$avg · tədbirlərinə $count qiymətləndirmə';
  }

  @override
  String get howWasIt => 'Necə idi?';

  @override
  String get howWasItHint =>
      'Qatıldığın tədbiri qiymətləndir; hamı yalnız ortalamanı görür.';

  @override
  String titleOnDate(String title, String date) {
    return '$title · $date';
  }

  @override
  String get eventsEmpty => 'Yürüyüş, konsert və ya görüş; ilk tədbiri yarat.';

  @override
  String get requestSent =>
      'Qatılma istəyin göndərildi. İdarəçi qərar verəndə xəbər verəcəyik.';

  @override
  String get attendanceSaved =>
      'Qatılımın qeydə alındı. Başlamazdan əvvəl xatırladacağıq.';

  @override
  String waitlistJoined(int place) {
    return 'Gözləmə siyahısına düşdün ($place. sıra). Yer açılanda xəbər verəcəyik.';
  }

  @override
  String get conflictTitle => 'Eyni saatda başqa tədbirin var';

  @override
  String conflictLine(String title, String date) {
    return '• $title · $date';
  }

  @override
  String get conflictOne =>
      'Gedə bilməyəcəksənsə, ondan imtina edib yerini başqasına verə bilərsən.';

  @override
  String get conflictMany =>
      'Gedə bilməyəcəksənsə, onlardan imtina edib yerini başqalarına verə bilərsən.';

  @override
  String get keepBoth => 'Hər ikisində qalsın';

  @override
  String get leaveOther => 'Digərindən imtina et';

  @override
  String get leaveOthers => 'Digərlərindən imtina et';

  @override
  String get leftOther => 'Digər tədbirdən imtina etdin; yerin boşaldı.';

  @override
  String get leftOthers => 'Digər tədbirlərdən imtina etdin.';

  @override
  String approvedPerson(String name) {
    return '$name iştirakçı oldu.';
  }

  @override
  String declinedPerson(String name) {
    return 'İstək rədd edildi; $name məlumatlandırıldı.';
  }

  @override
  String get calendarFailed => 'Təqvim faylı açılmadı. Yenidən cəhd et.';

  @override
  String get stopSeriesTitle => 'Təkrar dayandırılsın?';

  @override
  String get stopSeriesBody =>
      'Yeni tarix açılmır. Açılmış tarixlər qalır; istəsən, onları bir-bir ləğv edə bilərsən.';

  @override
  String get stop => 'Dayandır';

  @override
  String get seriesStopped => 'Təkrar dayandırıldı.';

  @override
  String get eventCanceledToast => 'Tədbir ləğv edildi.';

  @override
  String get eventNotFound => 'Bu tədbir tapılmadı və ya artıq görünmür.';

  @override
  String get goBack => 'Geri qayıt';

  @override
  String joinGroupFirst(String name) {
    return '$name qrupuna qoşul';
  }

  @override
  String get sendJoinRequest => 'Qatılma istəyi göndər';

  @override
  String get joinWaitlist => 'Gözləmə siyahısına yazıl';

  @override
  String get leaveEvent => 'Qatılmaqdan imtina et';

  @override
  String get leaveWaitlist => 'Gözləmə siyahısından çıx';

  @override
  String get requestWithdrawn => 'Qatılma istəyin geri götürüldü.';

  @override
  String get attendanceRemoved => 'Qatılımın silindi.';

  @override
  String eventShareText(String title) {
    return '$title · GWAY-də qoşul:';
  }

  @override
  String get eventLinkCopied => 'Tədbir keçidi kopyalandı.';

  @override
  String get report => 'Şikayət et';

  @override
  String get eventOptions => 'Tədbir seçimləri';

  @override
  String get edit => 'Redaktə et';

  @override
  String get cancelThisDate => 'Bu tarixi ləğv et';

  @override
  String get stopRepeat => 'Təkrarı dayandır';

  @override
  String get startedOrEnded => 'Başlayıb və ya bitib';

  @override
  String seriesUntil(String label, String date) {
    return '$label · $date tarixinə qədər';
  }

  @override
  String get addToCalendar => 'Təqvimə əlavə et';

  @override
  String fee(String fee) {
    return 'İştirak haqqı: $fee';
  }

  @override
  String get feeNotice => 'Ödəniş tədbir sahibinə edilir; GWAY ödəniş almır.';

  @override
  String get areYouComing => 'Gəlirsən?';

  @override
  String get areYouComingHint =>
      'Gələ bilməyəcəksənsə, yerini gözləmə siyahısındakılara burax.';

  @override
  String get yesComing => 'Bəli, gəlirəm';

  @override
  String get confirmThanks => 'Təşəkkürlər, gələcəyini təşkilatçıya bildirdik.';

  @override
  String get cantCome => 'Gələ bilmirəm';

  @override
  String get spotFreed => 'Qatılımın silindi; yerin boşaldı.';

  @override
  String get confirmedComing => 'Gələcəyini təsdiqlədin.';

  @override
  String get otherEventSameTime => 'Bu saatda başqa tədbirin var';

  @override
  String get needsApproval => 'Qatılım idarəçinin təsdiqi ilə';

  @override
  String get requirements => 'Qatılma şərtləri';

  @override
  String get equipment => 'Lazımi avadanlıq';

  @override
  String joinRequestsCount(int count) {
    return 'Qatılma istəkləri ($count)';
  }

  @override
  String get attendees => 'İştirakçılar';

  @override
  String confirmedOf(int going, int confirmed) {
    return '$going iştirakçıdan $confirmed nəfər gələcəyini təsdiqlədi.';
  }

  @override
  String confirmedName(String name) {
    return '$name · təsdiqlədi';
  }

  @override
  String get shareWasThere => '\"Mən də orada idim\" kartını paylaş';

  @override
  String get howDidItGo => 'Necə keçdi?';

  @override
  String reviewsCount(int count) {
    return 'Qiymətləndirmələr ($count)';
  }

  @override
  String get reviewNotesPrivate =>
      'Qeydləri yalnız tədbiri təşkil edənlər görür.';

  @override
  String get attendanceCheck => 'Yoxlama';

  @override
  String get attendanceCheckHint =>
      'Gəlməyənləri işarələ; töhfəyə və nişanlara yalnız gələnlər sayılır. Bitdikdən sonra 7 gün açıqdır.';

  @override
  String markedCame(String name) {
    return '$name gəldi kimi işarələndi.';
  }

  @override
  String markedMissed(String name) {
    return '$name gəlmədi kimi işarələndi.';
  }

  @override
  String get didntCome => 'Gəlmədi';

  @override
  String get came => 'Gəldi';

  @override
  String get memories => 'Xatirələr';

  @override
  String get shareMemory => 'Xatirə paylaş';

  @override
  String get eventPolls => 'Tədbir sorğuları';

  @override
  String get noEditPermission => 'Bu tədbiri redaktə etmək icazən yoxdur.';

  @override
  String get editEvent => 'Tədbiri redaktə et';

  @override
  String get newEvent => 'Yeni tədbir';

  @override
  String get addCover => 'Örtük şəkli əlavə et';

  @override
  String get titleExample => 'Məs. Meşə yürüyüşü';

  @override
  String get starts => 'Başlanğıc';

  @override
  String get endsOptional => 'Bitmə (istəyə bağlı)';

  @override
  String get notSpecified => 'Göstərilməyib';

  @override
  String get removeEnd => 'Bitməni sil';

  @override
  String get repeat => 'Təkrar';

  @override
  String get noRepeat => 'Təkrar yoxdur';

  @override
  String get weekly => 'Hər həftə';

  @override
  String get biweekly => 'İki həftədən bir';

  @override
  String get lastDateOptional => 'Son tarix (istəyə bağlı)';

  @override
  String get untilYouStop => 'Sən dayandırana qədər';

  @override
  String get removeLastDate => 'Son tarixi sil';

  @override
  String get repeatHint =>
      'Növbəti tarixlər 4 həftə əvvəldən öz-özünə açılır və hər biri aylıq tədbir haqqından düşür.';

  @override
  String get surpriseVenue => 'Sürpriz məkan';

  @override
  String get surpriseHint =>
      'Məkan başlamazdan əvvəl seçdiyin saatda yalnız iştirakçılara açıqlanır.';

  @override
  String get hintPublic => 'İpucu (hamı görür)';

  @override
  String get place => 'Yer';

  @override
  String get hintExample => 'Məs. Kadıköydə, dəniz kənarında';

  @override
  String get placeExample => 'Məs. Park girişi və ya Onlayn';

  @override
  String get writeHint => 'İpucu yaz.';

  @override
  String get writePlace => 'Yeri yaz.';

  @override
  String get realVenue => 'Əsl məkan (yalnız iştirakçılar görür)';

  @override
  String get realVenueExample => 'Məs. Teatrın önü';

  @override
  String get writeRealVenue => 'Əsl məkanı yaz.';

  @override
  String get whenReveal => 'Nə vaxt açıqlansın?';

  @override
  String hoursBefore(int count) {
    return '$count saat əvvəl';
  }

  @override
  String get linkOptional => 'Xəritə və ya onlayn keçid (istəyə bağlı)';

  @override
  String get httpsRequired => 'Keçid https:// ilə başlamalıdır.';

  @override
  String get description => 'Açıqlama';

  @override
  String get capacity => 'Tutum (boş = limitsiz)';

  @override
  String get capacityHint =>
      'Dolanda yeni qatılanlar gözləmə siyahısına düşür.';

  @override
  String get capacityRange => 'Tutum 1–10.000 olmalıdır.';

  @override
  String get requirementsOptional => 'Qatılma şərtləri (istəyə bağlı)';

  @override
  String get requirementsExample => 'Məs. Ən azı 10 km yürüyüş təcrübəsi';

  @override
  String get equipmentOptional => 'Lazımi avadanlıq (istəyə bağlı)';

  @override
  String get equipmentExample => 'Məs. Kaska, Su, Yağmurluq';

  @override
  String get equipmentHint => 'Vergüllə ayır; ən çox 10 maddə.';

  @override
  String get equipmentLimit => 'Ən çox 10 maddə, hər biri ən çox 60 simvol.';

  @override
  String get approvalRequired => 'Qatılım təsdiqlə olsun';

  @override
  String get approvalHint =>
      'Qatılmaq istəyənlər istək göndərir; sən təsdiqləyirsən.';

  @override
  String get feeOptional => 'İştirak haqqı (istəyə bağlı)';

  @override
  String get feeInfoOnly =>
      'Yalnız məlumat üçün göstərilir; GWAY ödəniş almır.';

  @override
  String get amount => 'Məbləğ';

  @override
  String get amountExample => 'Məs. 150';

  @override
  String get validAmount => 'Etibarlı məbləğ yaz.';

  @override
  String get paymentNote => 'Ödəniş qeydi';

  @override
  String get paymentNoteExample => 'Məs. Yerində nağd ödənilir';

  @override
  String get createEvent => 'Tədbiri yarat';

  @override
  String get rateEvent => 'Tədbiri qiymətləndir';

  @override
  String get yourReview => 'Qiymətləndirmən';

  @override
  String starsLabel(int count) {
    return '$count ulduz';
  }

  @override
  String get noteToOrganizers => 'Təşkilatçılara qeydin (istəyə bağlı)';

  @override
  String get noteToOrganizersHint =>
      'Qeydini yalnız təşkilatçılar görür; hamı yalnız ortalamanı görür.';

  @override
  String get reviewDeleted => 'Qiymətləndirmən silindi.';

  @override
  String get delete => 'Sil';

  @override
  String get reviewSaved => 'Təşəkkürlər, qiymətləndirmən yadda saxlanıldı.';

  @override
  String get groupNext => 'Qrupun növbəti tədbirləri';

  @override
  String sameDayOthers(int count) {
    return 'Bu tarixdə əyalətində eyni kateqoriyada daha $count tədbir var. Üzvlərin seçim etməli olmasın deyə istəsən, başqa gün seçə bilərsən.';
  }

  @override
  String get cancelEvent => 'Tədbiri ləğv et';

  @override
  String get cancelEventBody =>
      'İştirakçılara və gözləyənlərə bildiriş gedir. Ləğv geri qaytarılmır.';

  @override
  String get reason => 'Səbəb';

  @override
  String get cancelAction => 'Ləğv et';

  @override
  String hint(String hint) {
    return 'İpucu: $hint';
  }

  @override
  String hintRevealAt(String hint, String when) {
    return 'İpucu: $hint · İştirakçılara $when açıqlanacaq.';
  }

  @override
  String get venueRevealed =>
      'Məkan iştirakçılara açıqlandı. Qatılsan, görərsən.';

  @override
  String venueRevealAt(String when) {
    return 'Məkan $when iştirakçılara açıqlanacaq.';
  }

  @override
  String get currencyTry => '₺ TRY';
}
