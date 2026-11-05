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
}
