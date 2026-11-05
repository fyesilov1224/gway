// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'social_app_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class SocialAppL10nTr extends SocialAppL10n {
  SocialAppL10nTr([String locale = 'tr']) : super(locale);

  @override
  String get posts => 'Gönderiler';

  @override
  String get newPost => 'Yeni gönderi';

  @override
  String get noOwnPosts =>
      'Henüz gönderi paylaşmadın. İlk fotoğrafını ya da videonu paylaş.';

  @override
  String get noPosts => 'Henüz gönderi yok.';

  @override
  String get shareFirstOwn => 'İlk gönderini paylaş';

  @override
  String get groupFirstPost => 'Grubun akışına ilk gönderiyi sen paylaş.';

  @override
  String get groupNoPosts => 'Bu grupta henüz gönderi yok.';

  @override
  String get shareFirstGroup => 'İlk gönderiyi paylaş';

  @override
  String get groupNotFound => 'Grup bulunamadı.';

  @override
  String get memoriesEmpty =>
      'Henüz anı paylaşılmadı. Katılanlar fotoğraflarını buraya ekleyebilir.';

  @override
  String get plan => 'Paket';

  @override
  String get payment => 'Ödeme';

  @override
  String get onlyOwnerBilling =>
      'Paket işlemlerini yalnızca grup sahibi yapabilir.';

  @override
  String get backToGroup => 'Gruba dön';

  @override
  String get writeSupportAboutGroup => 'Bu grupla ilgili platform ekibine yaz';

  @override
  String get search => 'Ara';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get goodNight => 'İyi geceler';

  @override
  String get goodMorning => 'Günaydın';

  @override
  String get goodAfternoon => 'İyi günler';

  @override
  String get goodEvening => 'İyi akşamlar';

  @override
  String greetingName(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String get tabToday => 'Bugün';

  @override
  String get tabGroups => 'Gruplar';

  @override
  String get tabCalendar => 'Takvim';

  @override
  String get tabMe => 'Ben';

  @override
  String get tonightSay => 'Boşsan söyle, masa kur';

  @override
  String get tonightTableSet => 'Masan kuruldu';

  @override
  String get tonightInvited => 'Masaya davetin var';

  @override
  String tonightFreeWithYou(int count) {
    return '$count kişi seninle boş';
  }

  @override
  String get tonightFreeUntil => 'Boşsun · 04:00\'e kadar';

  @override
  String tonightFreeCount(int count) {
    return '$count kişi bu akşam boş';
  }

  @override
  String get upcomingNone => 'Gruplarının planları';

  @override
  String upcomingMine(int count, int mine) {
    return '$count plan · $mine katılım';
  }

  @override
  String upcomingCount(int count) {
    return '$count plan, 60 gün';
  }

  @override
  String get forToday => 'Bugün için';

  @override
  String get tonight => 'Bu akşam';

  @override
  String get upcoming => 'Yaklaşanlar';

  @override
  String get share => 'Paylaş';

  @override
  String get post => 'Gönderi';

  @override
  String get postHint => '10 fotoğraf ya da videoya kadar';

  @override
  String get story => 'Hikâye';

  @override
  String get storyHint => '24 saat görünür';

  @override
  String get group => 'Grup';

  @override
  String get groupHint => 'Kendi topluluğunu kur';

  @override
  String get create => 'Oluştur';

  @override
  String get messages => 'Mesajlar';

  @override
  String get matching => 'Eşleşme';

  @override
  String get myGroups => 'Gruplarım';

  @override
  String get pageNotFound =>
      'Aradığın sayfa bulunamadı. Bağlantı eski ya da hatalı olabilir.';

  @override
  String get backHome => 'Ana sayfaya dön';

  @override
  String get groupsLeague => 'Gruplar Ligi';

  @override
  String get exploreOnMap => 'Haritada keşfet';

  @override
  String get yearMenu => 'Yılın özeti, keşif haritam ve tanıştıklarım';

  @override
  String get yearSummary => 'Yılın özeti';

  @override
  String get yearSummaryHint => 'Bu yılki buluşmaların, paylaşılabilir kart';

  @override
  String get explorationMap => 'Keşif haritam';

  @override
  String get explorationMapHint => 'Katıldığın organizasyonların illeri';

  @override
  String get metPeople => 'Tanıştıklarım';

  @override
  String get metPeopleHint => 'Organizasyonlarda el sıkıştığın kişiler';

  @override
  String get findTeammates => 'Ekip arkadaşı bul';

  @override
  String get saved => 'Kaydedilenler';

  @override
  String get gateError =>
      'Bilgilerin yüklenemedi. Bağlantını kontrol edip tekrar dene.';

  @override
  String get searchPeople => 'Kişi ara';

  @override
  String get clearSearch => 'Aramayı temizle';

  @override
  String get settings => 'Ayarlar';

  @override
  String get editProfile => 'Profili düzenle';

  @override
  String get teammatePrefs => 'Ekip arkadaşı tercihleri';

  @override
  String get matchProfile => 'Eşleşme profili';

  @override
  String get voiceCalls => 'Sesli görüşme';

  @override
  String get blockedAccounts => 'Engellenen hesaplar';

  @override
  String get storyArchive => 'Hikaye arşivi';

  @override
  String get notificationPrefs => 'Bildirim tercihleri';

  @override
  String get mySanctions => 'Grup yaptırımlarım';

  @override
  String get userGuide => 'Kullanma kılavuzu';

  @override
  String get supportFeedback => 'Destek ve geri bildirim';

  @override
  String newReplies(int count) {
    return '$count yeni yanıt';
  }

  @override
  String get twoFactor => 'İki adımlı doğrulama';

  @override
  String get legalDocuments => 'Hukuki metinler';

  @override
  String get deleteAccount => 'Hesabı sil';

  @override
  String get signOut => 'Çıkış yap';

  @override
  String get nowPrivate => 'Hesabın artık gizli.';

  @override
  String get nowPublic =>
      'Hesabın artık herkese açık; bekleyen istekler onaylandı.';

  @override
  String get privateAccount => 'Gizli hesap';

  @override
  String get privateAccountHint =>
      'Açıkken yalnızca onayladığın takipçiler gönderilerini ve hikayelerini görür.';

  @override
  String get groupsNowPublic => 'Grupların artık profilinde herkese görünüyor.';

  @override
  String get groupsNowMembers =>
      'Grupların artık yalnızca aynı gruptaki üyelere görünüyor.';

  @override
  String get showGroups => 'Gruplarımı profilimde göster';

  @override
  String get showGroupsHint =>
      'Kapalıyken bir gruptaki üyeliğini yalnızca o grubun üyeleri görür; başka grupların yöneticileri göremez.';

  @override
  String get language => 'Dil';
}
