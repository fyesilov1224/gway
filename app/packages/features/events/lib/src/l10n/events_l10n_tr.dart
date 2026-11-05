// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'events_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class EventsL10nTr extends EventsL10n {
  EventsL10nTr([String locale = 'tr']) : super(locale);

  @override
  String get pollSingle => 'Bu ankette tek seçenek işaretlenebilir.';

  @override
  String get pollOptionGone => 'Bu seçenek artık yok. Sayfayı yenile.';

  @override
  String get reviewWindow =>
      'Değerlendirme, organizasyona katılanlar için bitişinden sonraki 30 gün açıktır.';

  @override
  String get greeterNeedsAttendance =>
      'Karşılayıcı olmak için grubun bir organizasyonuna katılmış olmalısın.';

  @override
  String get note80 => 'Not en fazla 80 karakter olabilir.';

  @override
  String get pollClosed => 'Bu anket kapandı ya da oy veremezsin.';

  @override
  String get cover5mb => 'Kapak görseli en fazla 5 MB olabilir.';

  @override
  String get imagesOnly => 'Yalnızca JPEG, PNG ya da WebP görsel yüklenebilir.';

  @override
  String get claimNotAllowed =>
      'Bu göreve şu anda bildirim yapılamaz; görev bitmiş ya da gruptan değilsin.';

  @override
  String get claimApprovedLocked => 'Onaylanmış bir bildirim geri çekilemez.';

  @override
  String get claimDuplicate => 'Bu görevi zaten bildirdin.';

  @override
  String get repeatsWeekly => 'Her hafta tekrarlanır';

  @override
  String get repeatsBiweekly => 'İki haftada bir tekrarlanır';

  @override
  String surprisePlace(String place) {
    return 'Sürpriz mekan · $place';
  }

  @override
  String get goalPersonal => 'Kişisel hedef';

  @override
  String get goalPersonalHint => 'Her üye kendi sayısını tamamlar.';

  @override
  String get goalGroup => 'Grup hedefi';

  @override
  String get goalGroupHint => 'Herkesin katkısı tek sayaçta toplanır.';

  @override
  String get goalTeam => 'Takım hedefi';

  @override
  String get goalTeamHint =>
      'Yönetici takımları kurar; takımın ortak sayacı olur.';

  @override
  String get goalTask => 'Onaylı görev';

  @override
  String get goalTaskHint => 'Üye \"Yaptım\" der, yönetici onaylar.';

  @override
  String unitAttended(int count) {
    return 'katılım';
  }

  @override
  String unitOrganized(int count) {
    return 'düzenleme';
  }

  @override
  String unitMemories(int count) {
    return 'anı';
  }

  @override
  String get claimPending => 'Onay bekliyor';

  @override
  String get claimApproved => 'Onaylandı';

  @override
  String get claimRejected => 'Onaylanmadı';

  @override
  String get notClaimedYet => 'Henüz bildirilmedi';

  @override
  String get whenAny => 'Her zaman';

  @override
  String get whenToday => 'Bugün';

  @override
  String get whenWeek => '7 gün içinde';

  @override
  String get viewDay => 'Gün';

  @override
  String get viewWeek => 'Hafta';

  @override
  String get viewMonth => 'Ay';

  @override
  String countAttended(int count) {
    return '$count katılım';
  }

  @override
  String countOrganized(int count) {
    return '$count düzenleme';
  }

  @override
  String countMemories(int count) {
    return '$count anı';
  }

  @override
  String countReviews(int count) {
    return '$count değerlendirme';
  }

  @override
  String countWelcomed(int count) {
    return '$count karşılama';
  }

  @override
  String countHandshakes(int count) {
    return '$count el sıkış';
  }

  @override
  String countHeld(int count) {
    return '$count organizasyon';
  }

  @override
  String countGoodReviews(int count) {
    return '$count memnuniyet';
  }

  @override
  String leagueStanding(String month, int groups, int rank, int points) {
    return '$month: $groups grup arasında $rank. sırada, $points puan.';
  }

  @override
  String goingCount(int count) {
    return '$count katılımcı';
  }

  @override
  String goingOfCapacity(int count, int capacity) {
    return '$count / $capacity katılımcı';
  }

  @override
  String firstEventOfYear(String title) {
    return 'Yılın ilk organizasyonu: $title';
  }

  @override
  String firstEventOfYearOn(String title, String date) {
    return 'Yılın ilk organizasyonu: $title · $date';
  }

  @override
  String get myCalendar => 'Takvimim';

  @override
  String get groupCalendar => 'Grup takvimi';

  @override
  String get previous => 'Önceki';

  @override
  String get next => 'Sonraki';

  @override
  String get today => 'Bugün';

  @override
  String get groupsEvents => 'Gruplarımın organizasyonları';

  @override
  String get showNotJoined => 'Katılmadıklarını da göster';

  @override
  String get noJoinedInRange =>
      'Bu tarihlerde katıldığın organizasyon yok. Gruplarının organizasyonlarına da bakabilirsin.';

  @override
  String get noEventsInRange => 'Bu tarihlerde organizasyon yok.';

  @override
  String get showGroupsEvents => 'Gruplarımın organizasyonlarını göster';

  @override
  String get backToToday => 'Bugüne dön';

  @override
  String get noEventsDay => 'Bu günde organizasyon yok.';

  @override
  String get contributions => 'Topluluk katkısı';

  @override
  String get howBadges => 'Rozetler nasıl kazanılır?';

  @override
  String get badgesEmpty =>
      'Bir organizasyona katıldığında katkın ve ilk rozetin burada görünür.';

  @override
  String get badgesRules =>
      'Rozetler yalnızca gerçekten yaptıklarından hesaplanır: katıldığın ve düzenlediğin organizasyonlar, paylaştığın anılar ve değerlendirmelerin. Beğeni ve takipçi sayısı sayılmaz. Düzenleyenin \"gelmedi\" olarak işaretlediği katılımlar sayılmaz. Kimse sıralanmaz.';

  @override
  String get categoryFan => 'Kategori tutkunu';

  @override
  String get pastEvents => 'Geçmiş organizasyonlar';

  @override
  String get noPastEvents => 'Bu grubun henüz geçmiş bir organizasyonu yok.';

  @override
  String get refresh => 'Yenile';

  @override
  String get canceled => 'İptal edildi';

  @override
  String get olderEvents => 'Daha eski organizasyonlar';

  @override
  String get completed => 'Tamamladın';

  @override
  String get ended => 'Sona erdi';

  @override
  String teamName(String name) {
    return 'Takım: $name';
  }

  @override
  String get teamNotice => 'Bir takıma eklenince ilerlemen burada görünür.';

  @override
  String get goals => 'Hedefler';

  @override
  String get createGoal => 'Hedef oluştur';

  @override
  String get goalsEmpty =>
      'Örneğin \"Bu ay 4 yürüyüşe katıl\" ya da \"Hep birlikte 50 katılım\"; ilk hedefi oluştur.';

  @override
  String get claimSent => 'Bildirimin yöneticiye iletildi.';

  @override
  String get goal => 'Hedef';

  @override
  String get goalCountsRule =>
      'Yalnızca bu grubun dönem içindeki organizasyonları sayılır; \"gelmedi\" işaretlenen katılımlar sayılmaz.';

  @override
  String get withdrawClaim => 'Bildirimi geri çek';

  @override
  String get claimWithdrawn => 'Bildirimin geri çekildi.';

  @override
  String get done => 'Yaptım';

  @override
  String get teams => 'Takımlar';

  @override
  String get createTeam => 'Takım kur';

  @override
  String get noTeams => 'Henüz takım yok.';

  @override
  String deleteTeam(String name) {
    return '$name takımını sil';
  }

  @override
  String get teamDeleted => 'Takım silindi.';

  @override
  String pendingClaims(int count) {
    return 'Onay bekleyen bildirimler ($count)';
  }

  @override
  String get claimRejectedToast => 'Bildirim onaylanmadı.';

  @override
  String get decline => 'Reddet';

  @override
  String get approve => 'Onayla';

  @override
  String taskDone(String name) {
    return '$name görevi tamamladı.';
  }

  @override
  String completions(int count) {
    return 'Tamamlayanlar ($count)';
  }

  @override
  String get noCompletions =>
      'Henüz tamamlayan yok. Tamamlayan herkes profilinde bu hedefin rozetini alır.';

  @override
  String get goalCanceled => 'Hedef iptal edildi.';

  @override
  String get cancelGoal => 'Hedefi iptal et';

  @override
  String teamCreated(String name) {
    return '\"$name\" takımı kuruldu.';
  }

  @override
  String get teamNameLabel => 'Takım adı';

  @override
  String get createTheTeam => 'Takımı kur';

  @override
  String createTeamWith(int count) {
    return 'Takımı kur ($count kişi)';
  }

  @override
  String get goalCreated => 'Hedef oluşturuldu.';

  @override
  String get title => 'Başlık';

  @override
  String get goalTitleExample => 'Ör. Ekim yürüyüşleri';

  @override
  String get taskTitleExample => 'Ör. Yeni bir üyeye rota anlat';

  @override
  String get titleMin3 => 'Başlık en az 3 karakter olmalı.';

  @override
  String get descriptionOptional => 'Açıklama (isteğe bağlı)';

  @override
  String get targetNumber => 'Hedef sayı';

  @override
  String get target1to1000 => '1–1000 arası bir sayı yaz.';

  @override
  String get period => 'Dönem';

  @override
  String periodRange(String from, String to) {
    return '$from – $to (en fazla 92 gün)';
  }

  @override
  String get createTheGoal => 'Hedefi oluştur';

  @override
  String get iDidTask => 'Görevi yaptım';

  @override
  String get whatDidYouDo => 'Ne yaptın? (isteğe bağlı)';

  @override
  String get whatDidYouDoHint => 'Yönetici bu notu görerek onaylar.';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get send => 'Gönder';

  @override
  String get handshake => 'El sıkış';

  @override
  String get handshakeHint =>
      'Tanıştığın kişiyle kodlarınızı okutun; ikinizin de \"Tanıştıklarım\" listesine eklenir.';

  @override
  String get open => 'Aç';

  @override
  String handshakeAt(String title) {
    return 'El sıkış · $title';
  }

  @override
  String get myCode => 'Kodum';

  @override
  String get scan => 'Okut';

  @override
  String get yourHandshakeCode => 'El sıkış kodun';

  @override
  String get codeHint =>
      'Karşındaki bu kodu \"Okut\" sekmesinden okutsun ya da yazsın. Kod birkaç dakikada bir kendiliğinden yenilenir; fotoğrafı sonradan işe yaramaz.';

  @override
  String get cameraFailed =>
      'Kamera açılamadı. Kamera iznini ayarlardan verebilir ya da kodu aşağıya yazabilirsin.';

  @override
  String get scanHint =>
      'Karşındakinin QR kodunu kameraya göster ya da kodunu yaz.';

  @override
  String get typeCodeHint => 'Karşındakinin ekranındaki 6 haneli kodu yaz.';

  @override
  String get code => 'Kod';

  @override
  String get alreadyMet => 'Zaten tanışıyorsunuz';

  @override
  String get metNow => 'Tanıştınız!';

  @override
  String personWithUsername(String name, String username) {
    return '$name (@$username)';
  }

  @override
  String get ok => 'Tamam';

  @override
  String get metPeople => 'Tanıştıklarım';

  @override
  String get metEmpty =>
      'Bir organizasyonda biriyle el sıkıştığında burada görünür. El sıkış, organizasyon sayfasında açılır.';

  @override
  String get goToCalendar => 'Takvimime git';

  @override
  String get metPrivacy =>
      'Yalnızca sen görürsün. Profilinde yalnızca el sıkış sayın görünür.';

  @override
  String metRow(String username, String event, String date) {
    return '@$username · $event · $date';
  }

  @override
  String get howPoints => 'Puanlar nasıl hesaplanır?';

  @override
  String get leagueIntro =>
      'Aynı ildeki aynı kategoriden gruplar her ay yarışır. Ayın biten organizasyonları sayılır.';

  @override
  String get ruleAttendance => 'Katılım: 1 puan';

  @override
  String get ruleAttendanceHint =>
      'Gelen her kişi; bir organizasyonda en fazla 30.';

  @override
  String get ruleHeld => 'Organizasyon: 5 puan';

  @override
  String get ruleHeldHint =>
      'Düzenleyen dışında en az 3 kişinin geldiği her organizasyon.';

  @override
  String get ruleWelcome => 'Karşılama: 3 puan';

  @override
  String get ruleWelcomeHint => 'İlk kez gelen birinin karşılanması.';

  @override
  String get ruleReview => 'Memnuniyet: 1 puan';

  @override
  String get ruleReviewHint => '4 ya da 5 yıldızlı her değerlendirme.';

  @override
  String get leagueRulesNote =>
      'Gelmedi işaretlenenler sayılmaz. Sonuçlar ay bittikten 8 gün sonra kesinleşir; ilk üçe giren grupların üyelerine haber verilir.';

  @override
  String get groupsLeague => 'Gruplar Ligi';

  @override
  String get category => 'Kategori';

  @override
  String get province => 'İl';

  @override
  String get month => 'Ay';

  @override
  String seasonClosed(String month) {
    return '$month sezonu kapandı; sıralama kesin.';
  }

  @override
  String get seasonRunning =>
      'Sezon sürüyor. Puanlar organizasyonlar bittikçe güncellenir; sonuçlar ay bittikten 8 gün sonra kesinleşir.';

  @override
  String leagueEmpty(String province) {
    return '$province ligine bu ay henüz puan alan grup yok.';
  }

  @override
  String points(int count) {
    return '$count puan';
  }

  @override
  String rank(int rank) {
    return '$rank.';
  }

  @override
  String leagueName(String province, String category) {
    return '$province · $category ligi';
  }

  @override
  String get noPointsYet =>
      'Bu ay henüz puan yok. Biten organizasyonlar, gelenler ve karşılamalar puan getirir.';

  @override
  String get mapAttribution =>
      '© Stadia Maps © OpenMapTiles © OpenStreetMap katkıcıları';

  @override
  String get map => 'Harita';

  @override
  String get mapView => 'Harita görünümü';

  @override
  String get listView => 'Liste görünümü';

  @override
  String get all => 'Tümü';

  @override
  String get wholeArea => 'Tüm alan';

  @override
  String km(int km) {
    return '$km km';
  }

  @override
  String get mapLoadFailed => 'Harita bilgileri yüklenemedi.';

  @override
  String get retry => 'Tekrar dene';

  @override
  String get noFilterResults => 'Bu filtrelerle bir şey bulunamadı.';

  @override
  String get clearFilters => 'Filtreleri temizle';

  @override
  String get noNearby => 'Bu bölgede yaklaşan organizasyon ya da grup yok.';

  @override
  String get zoomOut => 'Uzaklaştır';

  @override
  String get openEvent => 'Organizasyonu aç';

  @override
  String memberCount(int count) {
    return '$count üye';
  }

  @override
  String get noVisible =>
      'Görünen bölgede yaklaşan organizasyon ya da grup yok.';

  @override
  String get backToMap => 'Haritaya dön';

  @override
  String upcomingCount(int count) {
    return 'Yaklaşan organizasyonlar ($count)';
  }

  @override
  String get directions => 'Yol tarifi';

  @override
  String get meetingPointOptional => 'Buluşma noktası (isteğe bağlı)';

  @override
  String get meetingPointHint => 'Haritada seç; organizasyon haritada görünür.';

  @override
  String pointPicked(String lat, String lng) {
    return 'Seçildi · $lat, $lng';
  }

  @override
  String get removeMeetingPoint => 'Buluşma noktasını kaldır';

  @override
  String get meetingPoint => 'Buluşma noktası';

  @override
  String get pickHint => 'Haritayı yakınlaştır ve buluşma noktasına dokun.';

  @override
  String get pickAgainHint => 'Noktayı değiştirmek için başka bir yere dokun.';

  @override
  String get pickThisPoint => 'Bu noktayı seç';

  @override
  String get mapUnavailable => 'Harita şu anda kullanılamıyor.';

  @override
  String get pollClosedShort => 'Kapandı';

  @override
  String closesAt(String date) {
    return 'Kapanış: $date';
  }

  @override
  String get multipleAllowed => 'Birden fazla seçilebilir';

  @override
  String get anonymousVote => 'Gizli oylama';

  @override
  String votersCount(int count) {
    return '$count kişi oy verdi';
  }

  @override
  String get pollOptions => 'Anket seçenekleri';

  @override
  String get pollClosedToast => 'Anket kapatıldı.';

  @override
  String get pollDeleted => 'Anket silindi.';

  @override
  String get closePoll => 'Anketi kapat';

  @override
  String get deletePoll => 'Anketi sil';

  @override
  String get vote => 'Oy ver';

  @override
  String get voteSaved => 'Oyun kaydedildi.';

  @override
  String get voters => 'Oy verenler';

  @override
  String peopleCount(int count) {
    return '$count kişi';
  }

  @override
  String get polls => 'Anketler';

  @override
  String get openPoll => 'Anket aç';

  @override
  String get pollsEmpty => 'Üyelere bir soru sor; örneğin hangi gün buluşalım?';

  @override
  String get pollOpened => 'Anket açıldı.';

  @override
  String get question => 'Soru';

  @override
  String get questionExample => 'Ör. Hangi gün buluşalım?';

  @override
  String get questionMin3 => 'Soru en az 3 karakter olmalı.';

  @override
  String optionN(int n) {
    return '$n. seçenek';
  }

  @override
  String get removeOption => 'Seçeneği kaldır';

  @override
  String get optionRequired => 'Seçeneği yaz ya da kaldır.';

  @override
  String get addOption => 'Seçenek ekle';

  @override
  String get allowMultiple => 'Birden fazla seçilebilsin';

  @override
  String get anonymousHint => 'Kimin neye oy verdiği gösterilmez.';

  @override
  String get noEndTime => 'Bitiş zamanı yok';

  @override
  String get add => 'Ekle';

  @override
  String get removeEndTime => 'Bitiş zamanını kaldır';

  @override
  String get startPoll => 'Anketi aç';

  @override
  String get cardFooter => 'gway · topluluğunu bul';

  @override
  String myYear(int year) {
    return '$year yılım';
  }

  @override
  String get statAttended => 'organizasyona katıldım';

  @override
  String get statHours => 'saat birlikteydik';

  @override
  String get statOneGroup => 'grupla buluştum';

  @override
  String get statGroups => 'farklı grupla buluştum';

  @override
  String get statProvinces => 'farklı ilde';

  @override
  String get statOrganized => 'organizasyon düzenledim';

  @override
  String get statWelcomed => 'kişiyi ilk gelişinde karşıladım';

  @override
  String get statMemories => 'anı paylaştım';

  @override
  String get favorites => 'En sevdiklerim';

  @override
  String get topGroup => 'En çok birlikte olduğum grup';

  @override
  String topGroupLine(String group, int count) {
    return '$group · $count buluşma';
  }

  @override
  String get iWasThere => 'Ben de oradaydım';

  @override
  String get firstWithGroup => 'Bu grupla ilk organizasyonum.';

  @override
  String nthWithGroup(int n) {
    return 'Bu grupla $n. organizasyonum.';
  }

  @override
  String get shareFailed =>
      'Bu cihazda paylaşılamadı. Kartın ekran görüntüsünü alıp paylaşabilirsin.';

  @override
  String get share => 'Paylaş';

  @override
  String yearSummaryTitle(int year) {
    return '$year özetim';
  }

  @override
  String get yearEmpty =>
      'Bu yıl henüz bir organizasyona katılmadın. İlk buluşmandan sonra özetin burada oluşur.';

  @override
  String yearShareText(int year) {
    return '$year yılım GWAY\'de';
  }

  @override
  String mapSemantics(int count) {
    return 'Türkiye haritası: $count il keşfedildi';
  }

  @override
  String get explorationMap => 'Keşif haritam';

  @override
  String get statExplored => 'ili keşfettim';

  @override
  String get statMetAt => 'organizasyonda buluştum';

  @override
  String get recentExplored => 'Son keşiflerim';

  @override
  String get explorationEmpty =>
      'Katıldığın organizasyonların illeri burada açılır. İlk buluşmandan sonra haritan renklenir.';

  @override
  String get findOnMap => 'Haritada organizasyon bul';

  @override
  String explorationShareText(int count) {
    return 'GWAY\'de $count ili keşfettim';
  }

  @override
  String get exploredProvinces => 'Keşfettiğin iller';

  @override
  String get explorationPrivacy =>
      'Yalnızca sen görürsün. Katıldığın ve \"gelmedi\" işaretlenmediğin organizasyonlar sayılır.';

  @override
  String get tonightVisible =>
      'Bu akşam boş olduğunu ortak gruplarındakiler görecek. 04:00\'te kendiliğinden kapanır.';

  @override
  String get joinedTable => 'Masaya katıldın.';

  @override
  String get declinedInvite => 'Daveti geri çevirdin.';

  @override
  String get yourStatus => 'Durumun';

  @override
  String get visibleUntil4 => '04:00\'e kadar görünürsün';

  @override
  String get notVisible => 'Şu an görünmüyorsun';

  @override
  String get youreFree => 'Boşsun';

  @override
  String get tonightIntro =>
      'Boşsan ortak gruplarındakiler görsün; birlikte küçük bir masa kurabilirsiniz.';

  @override
  String get imFreeTonight => 'Bu akşam boşum';

  @override
  String get noLongerFree => 'Artık boş görünmüyorsun.';

  @override
  String get turnOffStatus => 'Durumu kapat';

  @override
  String get leftTable => 'Masadan ayrıldın.';

  @override
  String get smallTable => 'Küçük masa';

  @override
  String get smallTableHint =>
      'Boş olanlardan birkaç kişiyi çağır; üç kişi olunca masanın sohbeti açılır.';

  @override
  String get setUpTable => 'Küçük masa kur';

  @override
  String tableInvitesSent(int count) {
    return '$count kişiye davet gönderildi. Üç kişi olunca masanın sohbeti açılır.';
  }

  @override
  String needMorePeople(int min, int now) {
    return 'Küçük masa için ortak gruplarından en az $min kişinin daha boş olması gerekiyor (şu an $now). Biri boş olduğunu söyleyince burada masa kurabilirsin.';
  }

  @override
  String freeFromGroups(int count) {
    return 'Ortak gruplarından $count kişi bu akşam boş';
  }

  @override
  String get chipCoffee => 'Kahve';

  @override
  String get chipWalk => 'Kısa yürüyüş';

  @override
  String get chipFood => 'Yemek';

  @override
  String get chipCinema => 'Sinema';

  @override
  String get tonightSheetHint =>
      'Yalnızca ortak gruplarındaki kişiler görür. Durumun 04:00\'te kendiliğinden kapanır.';

  @override
  String get whatToDo => 'Ne yapmak istersin? (isteğe bağlı)';

  @override
  String get whatToDoHint => 'ör. kahve, kısa yürüyüş';

  @override
  String get imFree => 'Boşum';

  @override
  String get yourTable => 'Masan';

  @override
  String joinedCount(int count) {
    return '$count kişi katıldı';
  }

  @override
  String waitingCount(int count) {
    return '$count kişi bekleniyor';
  }

  @override
  String get settingUp => 'Kuruluyor';

  @override
  String get chatOpen => 'Sohbet açık';

  @override
  String get tableChat => 'Masanın sohbeti';

  @override
  String chatOpensWhen(int count) {
    return 'Sohbet, $count kişi daha katılınca açılır. Yeri ve saati orada birlikte seçersiniz.';
  }

  @override
  String get leaveTable => 'Masadan ayrıl';

  @override
  String tableInviteTitle(String name) {
    return '$name küçük bir masa kurdu ve seni de çağırıyor.';
  }

  @override
  String tableInviteStatus(int joined, int pending) {
    return '$joined kişi katıldı · $pending kişi bekleniyor. Üç kişi olunca sohbet açılır.';
  }

  @override
  String get join => 'Katıl';

  @override
  String get notTonight => 'Bu akşam olmaz';

  @override
  String get tonight => 'Bu akşam';

  @override
  String get freeTonight => 'Bu akşam boş olanlar';

  @override
  String get sharedGroupsOnly => 'Yalnızca ortak gruplarındaki kişiler';

  @override
  String get nobodyFree => 'Ortak gruplarından şu an boş olan yok.';

  @override
  String get howItWorks => 'Nasıl işler?';

  @override
  String get howStep1 =>
      '\"Bu akşam boşum\" de; istersen ne yapmak istediğini yaz.';

  @override
  String get howStep2 =>
      'Ortak gruplarındakiler seni görür, sen de boş olanları görürsün.';

  @override
  String get howStep3 =>
      'Küçük masa kur; üç kişi olunca masanın sohbeti açılır, yeri ve saati orada seçersiniz.';

  @override
  String get upcoming => 'Yaklaşanlar';

  @override
  String get calendar => 'Takvim';

  @override
  String get noUpcomingJoined => 'Katıldığın yaklaşan bir organizasyon yok.';

  @override
  String get showAll => 'Tümünü göster';

  @override
  String get noUpcoming60 =>
      'Önümüzdeki 60 günde gruplarının organizasyonu yok.';

  @override
  String get findGroup => 'Grup bul';

  @override
  String filterAll(int count) {
    return 'Tümü · $count';
  }

  @override
  String filterMine(int count) {
    return 'Katıldıklarım · $count';
  }

  @override
  String get tomorrow => 'Yarın';

  @override
  String get going => 'Katılıyorsun';

  @override
  String get waitlisted => 'Yedek listede';

  @override
  String get awaitingApproval => 'Onay bekliyor';

  @override
  String get full => 'Dolu';

  @override
  String goingOfCapacityShort(int count, int capacity) {
    return '$count/$capacity katılımcı';
  }

  @override
  String get startingSoon => 'Yakında başlıyor';

  @override
  String get next6Hours => 'Önümüzdeki 6 saat';

  @override
  String get wantWelcome => 'Karşılanmak istiyorum';

  @override
  String get wantWelcomeHint =>
      'Grubun gönüllü üyelerinden biri seni girişte karşılar; yalnız gitmezsin.';

  @override
  String get noteForGreeter => 'Seni tanımaları için bir not (isteğe bağlı)';

  @override
  String get noteForGreeterHint => 'Ör. Kırmızı montluyum, mavi çantam var';

  @override
  String get sendRequest => 'İstek gönder';

  @override
  String get welcomeRequestSent =>
      'İsteğin karşılayıcılara iletildi. Biri üstlenince haber vereceğiz.';

  @override
  String get editMeetingNote => 'Buluşma notunu düzenle';

  @override
  String welcomePerson(String name) {
    return '$name kişisini karşıla';
  }

  @override
  String describedAs(String note) {
    return 'Kendini şöyle tarif etti: $note';
  }

  @override
  String get whereMeet => 'Nerede buluşacaksınız?';

  @override
  String get whereMeetHint => 'Ör. Girişteki kafenin önü, 08:45';

  @override
  String get save => 'Kaydet';

  @override
  String get iWillWelcome => 'Karşılarım';

  @override
  String get noteUpdated => 'Buluşma notu güncellendi.';

  @override
  String youWillWelcome(String name) {
    return '$name kişisini karşılayacaksın; buluşma notunu gördü.';
  }

  @override
  String get stopWelcoming => 'Karşılamayı bırak';

  @override
  String stopWelcomingBody(String name) {
    return '$name için yeniden karşılayıcı aranacak ve kendisine haber verilecek.';
  }

  @override
  String get release => 'Bırak';

  @override
  String get releasedWelcome =>
      'Karşılamayı bıraktın; yeni bir karşılayıcı aranıyor.';

  @override
  String get firstTime => 'İlk kez mi geliyorsun?';

  @override
  String greetersAvailable(int count) {
    return 'Bu grupta $count karşılayıcı var. Biri seni girişte karşılasın, grupla tanıştırsın.';
  }

  @override
  String get youWelcomed => 'Karşıladıkların';

  @override
  String meetingAt(String note) {
    return 'Buluşma: $note';
  }

  @override
  String get thankedYou => 'Sana teşekkür etti';

  @override
  String optionsFor(String name) {
    return '$name için seçenekler';
  }

  @override
  String waitingWelcome(int count) {
    return 'Karşılanmayı bekleyenler ($count)';
  }

  @override
  String matchedCount(int count) {
    return '$count kişi bir karşılayıcıyla eşleşti.';
  }

  @override
  String get firstTimer => 'İlk kez geliyor';

  @override
  String get max3Welcomes =>
      'Bir organizasyonda en fazla 3 kişiyi karşılayabilirsin.';

  @override
  String get greeterJoinHint =>
      'Karşılayıcısın. İlk kez gelenleri karşılamak için organizasyona katıl.';

  @override
  String get lookingGreeter => 'Karşılayıcı aranıyor';

  @override
  String get lookingGreeterHint =>
      'Grubun karşılayıcılarına haber verdik. Biri üstlenince bildirim gelecek.';

  @override
  String yourNote(String note) {
    return 'Notun: $note';
  }

  @override
  String get welcomeWithdrawn => 'Karşılanma isteğin geri çekildi.';

  @override
  String get withdrawRequest => 'İsteği geri çek';

  @override
  String get greetedBy => 'Seni karşılayan';

  @override
  String get willGreet => 'Seni karşılayacak';

  @override
  String get thank => 'Teşekkür et';

  @override
  String thankReceived(String name) {
    return '$name teşekkürünü aldı.';
  }

  @override
  String get thanked => 'Teşekkür ettin.';

  @override
  String get cancelWelcome => 'Karşılanmaktan vazgeç';

  @override
  String get nowGreeter =>
      'Artık karşılayıcısın. İlk kez gelen biri karşılanmak istediğinde haber vereceğiz.';

  @override
  String get noLongerGreeter => 'Karşılayıcılığı bıraktın.';

  @override
  String get welcomeSection => 'Karşılama';

  @override
  String greetersCount(int count) {
    return '$count karşılayıcı';
  }

  @override
  String get greeterIntro =>
      'İlk kez gelenler organizasyon sayfasından karşılanmak isteyebilir. Karşılayıcı olursan haber alırsın; girişte karşılar, grupla tanıştırırsın.';

  @override
  String greeterMemberHint(int count) {
    return 'Bu grupta $count karşılayıcı var. İlk organizasyonunda sayfadan \"Karşılanmak istiyorum\" diyebilirsin.';
  }

  @override
  String greeterVisitorHint(int count) {
    return 'Bu grupta $count karşılayıcı var: ilk organizasyonuna yalnız gitmezsin, biri seni girişte karşılar.';
  }

  @override
  String get becomeGreeter => 'Karşılayıcı ol';

  @override
  String quoted(String text) {
    return '\"$text\"';
  }
}
