// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'matching_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class MatchingL10nTr extends MatchingL10n {
  MatchingL10nTr([String locale = 'tr']) : super(locale);

  @override
  String get unsupportedImage =>
      'Yalnızca JPEG, PNG ya da WebP fotoğraf yüklenebilir.';

  @override
  String get modeFriend => 'Arkadaş';

  @override
  String get modeDating => 'Sevgili';

  @override
  String get genderWoman => 'Kadın';

  @override
  String get genderMan => 'Erkek';

  @override
  String get genderNonbinary => 'İkili olmayan';

  @override
  String get adultsOnly => 'Eşleşme 18 yaşından büyükler içindir.';

  @override
  String get pickMode => 'Arkadaş ya da Sevgili modlarından en az birini seç.';

  @override
  String get pickInterest => 'Sevgili modu için kimi aradığını seç.';

  @override
  String get ageRangeInvalid => 'Yaş aralığı hatalı.';

  @override
  String sharedGroup(String group) {
    return 'Ortak grup: $group';
  }

  @override
  String sharedGroupsMore(String group, int count) {
    return 'Ortak: $group ve $count grup daha';
  }

  @override
  String get pkgReveal => 'Eşleşmelerim';

  @override
  String get pkgRevealText =>
      'Kiminle eşleştiğini gör: ad, fotoğraflar ve profil.';

  @override
  String get pkgChat => 'Eşleşme Sohbeti';

  @override
  String get pkgChatText =>
      'Eşleştiklerine yaz. Eşleşmelerini görmeyi de içerir.';

  @override
  String get pkgAdmirers => 'Seni Beğenenler';

  @override
  String get pkgAdmirersText =>
      'Seni kimlerin beğendiğini gör, beğenerek anında eşleş.';

  @override
  String get pkgUnlimited => 'Sınırsız Beğeni';

  @override
  String get pkgUnlimitedText =>
      'Günlük beğeni sınırı kalkar; geri al ve filtreler de açılır.';

  @override
  String get pkgSuper => 'Süper Beğeni';

  @override
  String get pkgSuperText =>
      'Günde 5 süper beğeni; seni süper beğendiğin kişi destesinde ilk görür.';

  @override
  String get pkgBoost => 'Öne Çık';

  @override
  String get pkgBoostText =>
      'Günde bir kez 30 dakika ortak gruplarındaki destelerin en başında görün.';

  @override
  String get pkgTeammates => 'Ekip Arkadaşı';

  @override
  String get pkgTeammatesText =>
      'Ekip arkadaşı isteği gönder ve ekip arkadaşlarınla yazış.';

  @override
  String get pkgAll => 'Hepsi Bir Arada';

  @override
  String get pkgAllText =>
      'Bütün paketler tek pakette, ayrı ayrı almaktan çok daha uygun.';

  @override
  String get superLikedYou => 'Seni süper beğendi';

  @override
  String get options => 'Seçenekler';

  @override
  String get fullProfile => 'Profilin tamamı';

  @override
  String get stampLike => 'BEĞEN';

  @override
  String get stampPass => 'GEÇ';

  @override
  String get stampSuper => 'SÜPER';

  @override
  String photoOf(String name, int number) {
    return '$name, fotoğraf $number';
  }

  @override
  String get about => 'Hakkında';

  @override
  String get interests => 'İlgi alanları';

  @override
  String get sharedGroupsTitle => 'Ortak gruplarınız';

  @override
  String get createProfileTitle => 'Eşleşme profili oluştur';

  @override
  String get myProfile => 'Eşleşme profilim';

  @override
  String get birthDateLabel => 'Doğum tarihin';

  @override
  String get pickBasics => 'Doğum tarihini, cinsiyetini ve ilini seç.';

  @override
  String get confirmAgeConsent =>
      'Devam etmek için 18 yaşından büyük olduğunu onayla ve açık rıza ver.';

  @override
  String profileReady(int min) {
    return 'Profilin hazır. Şimdi en az $min fotoğraf ekle.';
  }

  @override
  String get saved => 'Kaydedildi.';

  @override
  String get pickBirthDate => 'Doğum tarihi seç';

  @override
  String ageNote(int age) {
    return '$age yaş · kartında yalnızca yaşın görünür';
  }

  @override
  String get gender => 'Cinsiyet';

  @override
  String get province => 'İl';

  @override
  String get aboutHint => 'Kendinden bahset';

  @override
  String get jobOptional => 'Meslek (isteğe bağlı)';

  @override
  String get educationOptional => 'Eğitim (isteğe bağlı)';

  @override
  String get interestsFromProfile => 'İlgi alanların sosyal profilinden gelir.';

  @override
  String get lookingFor => 'Ne arıyorsun?';

  @override
  String get friendHint => 'Birlikte etkinliğe gidecek, sohbet edecek insanlar';

  @override
  String get datingHint => 'Romantik bir ilişki';

  @override
  String get whoLookingFor => 'Kimi arıyorsun?';

  @override
  String ageRange(int min, int max) {
    return 'Yaş aralığı: $min–$max';
  }

  @override
  String get consentTitle => 'Onay';

  @override
  String get iam18 => '18 yaşından büyüğüm.';

  @override
  String get consentText =>
      'Eşleşme için cinsiyetimin, aradığım kişinin, doğum tarihimin, ilimin ve fotoğraflarımın işlenmesine ve ortak gruplarımdaki eşleşmeyi açmış kişilere gösterilmesine açık rıza veriyorum. Rızamı istediğim an eşleşme verilerimi silerek geri alabilirim.';

  @override
  String get createProfile => 'Profilimi oluştur';

  @override
  String get save => 'Kaydet';

  @override
  String get photos => 'Fotoğraflar';

  @override
  String photosMin(int min) {
    return 'Kartının görünmesi için en az $min fotoğraf ekle. İlki kapaktır.';
  }

  @override
  String photosMax(int max) {
    return 'En fazla $max fotoğraf. İlki kapaktır; değiştirmek için bir fotoğrafa dokun.';
  }

  @override
  String get addPhoto => 'Fotoğraf ekle';

  @override
  String get cover => 'Kapak';

  @override
  String get removePhoto => 'Fotoğrafı kaldır';

  @override
  String get pauseProfile => 'Profilimi duraklat';

  @override
  String get pauseHint =>
      'Kimse seni görmez ve yeni kart gelmez; eşleşmelerin ve sohbetlerin kalır.';

  @override
  String get deleteData => 'Eşleşme verilerimi sil';

  @override
  String get deleteDataHint =>
      'Profil, fotoğraflar ve beğeniler silinir; eşleşmelerin biter. Açık rızan geri alınmış olur.';

  @override
  String get deleteDataTitle => 'Eşleşme verilerini sil';

  @override
  String get deleteDataBody =>
      'Eşleşme profilin, fotoğrafların ve beğenilerin kalıcı olarak silinir; tüm eşleşmelerin biter. Bu geri alınamaz.';

  @override
  String get delete => 'Sil';

  @override
  String get dataDeleted => 'Eşleşme verilerin silindi.';

  @override
  String get itsAMatch => 'Eşleştiniz!';

  @override
  String bothLiked(String name) {
    return 'Sen ve $name birbirinizi beğendiniz.';
  }

  @override
  String get keepSwiping => 'Kaydırmaya devam et';

  @override
  String get sendMessage => 'Mesaj gönder';

  @override
  String get reportProfile => 'Profili şikayet et';

  @override
  String get reportPhoto => 'Bu fotoğrafı şikayet et';

  @override
  String get block => 'Engelle';

  @override
  String get blockHint => 'Birbirinizi hiçbir yerde görmezsiniz.';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get newMatch => 'Biriyle eşleştin!';

  @override
  String tapToSee(String date) {
    return 'Kim olduğunu görmek için dokun · $date';
  }

  @override
  String get revealReason =>
      'Biriyle eşleştin! Kim olduğunu görmek için Eşleşmelerim paketini al.';

  @override
  String get keepFriend => 'Yalnızca arkadaş kal';

  @override
  String get keepDating => 'Yalnızca sevgili kal';

  @override
  String keepFriendBody(String name) {
    return '$name ile sevgili eşleşmeniz ikiniz için de biter; arkadaş olarak eşleşmeniz ve sohbetiniz sürer.';
  }

  @override
  String keepDatingBody(String name) {
    return '$name ile arkadaş eşleşmeniz ikiniz için de biter; sevgili olarak eşleşmeniz ve sohbetiniz sürer.';
  }

  @override
  String get keptFriend => 'Artık yalnızca arkadaş olarak eşleşiksiniz.';

  @override
  String get keptDating => 'Artık yalnızca sevgili olarak eşleşiksiniz.';

  @override
  String get continueAction => 'Devam et';

  @override
  String get endMatch => 'Eşleşmeyi bitir';

  @override
  String endMatchBody(String name) {
    return '$name ile eşleşmen biter, sohbetiniz ikiniz için de kapanır. Bu geri alınamaz.';
  }

  @override
  String get end => 'Bitir';

  @override
  String get matchEnded => 'Eşleşme bitti.';

  @override
  String get noMatches =>
      'Henüz eşleşmen yok. Birbirinizi beğendiğiniz kişiler burada görünür.';

  @override
  String get backToDiscover => 'Keşfetmeye dön';

  @override
  String get report => 'Şikayet et';

  @override
  String get matching => 'Eşleşme';

  @override
  String get admirers => 'Seni beğenenler';

  @override
  String get packages => 'Paketler';

  @override
  String get more => 'Diğer';

  @override
  String get filtersLocked =>
      'Yaş, il ve ilgi alanına göre filtrelemek Sınırsız Beğeni paketiyle açılır.';

  @override
  String get filters => 'Filtreler';

  @override
  String get suspended =>
      'Eşleşme profilin platform ekibi tarafından kapatıldı. Ayrıntılar için Destek\'e yazabilirsin.';

  @override
  String addPhotosToStart(int min) {
    return 'Kartının görünmesi ve keşfetmeye başlaman için en az $min fotoğraf ekle.';
  }

  @override
  String get paused =>
      'Profilin duraklatıldı; kimse seni görmüyor. Eşleşmelerin ve sohbetlerin duruyor.';

  @override
  String get likesOut =>
      'Bugünkü ücretsiz beğenilerin bitti. Sınırsız Beğeni ile istediğin kadar beğen.';

  @override
  String get supersOut => 'Bugünkü süper beğenilerin bitti. Yarın yenilenir.';

  @override
  String get superUsed =>
      'Bugünkü süper beğenini kullandın. Süper Beğeni paketiyle her gün 5 tane.';

  @override
  String get rewindLocked =>
      'Yanlışlıkla geçtiğin kişiyi geri getirmek Sınırsız Beğeni paketiyle açılır.';

  @override
  String rewoundTo(String mode) {
    return 'Son geçtiğin kişi $mode destesine geri döndü.';
  }

  @override
  String boostReason(int minutes) {
    return 'Öne çıkınca $minutes dakika boyunca destelerin en başında görünürsün.';
  }

  @override
  String boosting(int minutes) {
    return 'Öne çıkıyorsun. $minutes dakika kaldı.';
  }

  @override
  String get boostUsed =>
      'Bugünkü öne çıkma hakkını kullandın. Yarın yenilenir.';

  @override
  String get boost => 'Öne çık';

  @override
  String boostBody(int minutes) {
    return '$minutes dakika boyunca ortak gruplarındaki kişilerin destesinde en başta görünürsün. Günde bir kez kullanılır.';
  }

  @override
  String boosted(int minutes) {
    return 'Öne çıktın! $minutes dakika boyunca en baştasın.';
  }

  @override
  String get deckEmpty =>
      'Şimdilik gösterecek kimse kalmadı. Yeni gruplara katıldıkça ve insanlar eşleşmeyi açtıkça burası dolar.';

  @override
  String get deckEmptyFiltered =>
      'Filtrelerine uyan kimse kalmadı. Filtreleri genişletmeyi dene.';

  @override
  String get refresh => 'Yenile';

  @override
  String get clearFilters => 'Filtreleri temizle';

  @override
  String allowanceUnlimited(int supers) {
    return 'Sınırsız beğeni · $supers süper beğeni hakkın var.';
  }

  @override
  String get allowanceOut => 'Bugünkü beğenilerin bitti; yarın yenilenir.';

  @override
  String allowance(int likes, int supers) {
    return 'Bugün $likes beğeni ve $supers süper beğeni hakkın var.';
  }

  @override
  String get undo => 'Geri al';

  @override
  String get pass => 'Geç';

  @override
  String get superLike => 'Süper beğen';

  @override
  String get like => 'Beğen';

  @override
  String get introTitle => 'Ortak gruplarından yeni insanlarla tanış';

  @override
  String get intro1 =>
      'Yalnızca üye olduğun ya da takip ettiğin gruplardaki, eşleşmeyi açmış kişileri görürsün.';

  @override
  String get intro2 =>
      'Kartı sağa kaydır beğen, sola kaydır geç, yukarı kaydır süper beğen.';

  @override
  String get intro3 =>
      'İkiniz de birbirinizi beğenince eşleşirsiniz. Eşleştiğin kişiye Eşleşme Sohbeti paketiyle yazarsın.';

  @override
  String get intro4 =>
      'Arkadaş ve Sevgili ayrı modlardır; istediğini ya da ikisini seçersin.';

  @override
  String get intro5 =>
      'Profilin yalnızca eşleşmeyi açanlara görünür. İstediğin an duraklatır ya da tamamen silersin.';

  @override
  String get createMyProfile => 'Eşleşme profilimi oluştur';

  @override
  String seePackageOf(String package) {
    return '$package paketini incele';
  }

  @override
  String get allPackages => 'Tüm paketler';

  @override
  String get packagesTitle => 'Eşleşme paketleri';

  @override
  String get packagesIntro =>
      'Profil açmak ve kaydırmak ücretsiz. Her özellik ayrı bir pakettir; yalnızca istediğini al.';

  @override
  String get adminAllOpen => 'Yönetici olarak tüm paketler açık';

  @override
  String openUntil(String date) {
    return '$date tarihine kadar açık';
  }

  @override
  String ageFilter(int min, int max) {
    return 'Yaş: $min – $max';
  }

  @override
  String get allProvinces => 'Tüm iller';

  @override
  String get interest => 'İlgi alanı';

  @override
  String get all => 'Hepsi';

  @override
  String get apply => 'Uygula';

  @override
  String get clear => 'Temizle';

  @override
  String get noAdmirers =>
      'Şimdilik bekleyen beğeni yok. Kaydırmaya devam et; seni beğenenler burada görünür.';

  @override
  String get backToSwiping => 'Kaydırmaya dön';

  @override
  String get likeAndMatch => 'Beğen ve eşleş';

  @override
  String get noPendingLikes => 'Henüz bekleyen beğeni yok';

  @override
  String likedYouCount(int count) {
    return '$count kişi seni beğendi';
  }

  @override
  String get admirersPitch =>
      'Seni Beğenenler paketiyle kim olduklarını gör, beğenerek anında eşleş.';

  @override
  String get seePackage => 'Paketi incele';
}
