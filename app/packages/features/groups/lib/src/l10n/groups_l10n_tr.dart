// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'groups_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class GroupsL10nTr extends GroupsL10n {
  GroupsL10nTr([String locale = 'tr']) : super(locale);

  @override
  String get unsupportedImage =>
      'Bu dosya türü desteklenmiyor. JPEG, PNG veya WebP seç.';

  @override
  String get joinOpen => 'Serbest katılım';

  @override
  String get joinOpenHint => 'Herkes doğrudan katılabilir.';

  @override
  String get joinRequest => 'İstekle katılım';

  @override
  String get joinRequestHint =>
      'Katılım istekleri yöneticiler tarafından onaylanır.';

  @override
  String get joinInvite => 'Davetle katılım';

  @override
  String get joinInviteHint => 'Yalnızca davet edilen kişiler katılabilir.';

  @override
  String get roleOwner => 'Grup Sahibi';

  @override
  String get roleAdmin => 'Yönetici';

  @override
  String get roleDiscipline => 'Disiplin Kurulu';

  @override
  String get roleModerator => 'Moderatör';

  @override
  String get roleMember => 'Üye';

  @override
  String get handleMin => 'Grup adresi en az 3 karakter olmalı.';

  @override
  String get handleChars =>
      'Yalnızca küçük harf, rakam, alt çizgi ve nokta kullanabilirsin.';

  @override
  String get handleDots =>
      'Nokta ile başlayamaz, bitemez ve art arda kullanılamaz.';

  @override
  String get nameMin => 'Grup adı en az 3 karakter olmalı.';

  @override
  String nameMax(int max) {
    return 'Grup adı en fazla $max karakter olabilir.';
  }

  @override
  String get httpsOnly => 'https:// ile başlayan bir adres gir.';

  @override
  String get createGroup => 'Grup oluştur';

  @override
  String get groupInfo => 'Grup bilgileri';

  @override
  String get groupInfoHint =>
      'Logo, kapak, kurallar ve bağlantıları grubu oluşturduktan sonra ekleyebilirsin.';

  @override
  String get groupName => 'Grup adı';

  @override
  String get about => 'Tanıtım';

  @override
  String get aboutHint => 'Grubunuz ne yapar, kimler katılabilir?';

  @override
  String get joining => 'Katılım';

  @override
  String get changeLater => 'Bunu daha sonra değiştirebilirsin.';

  @override
  String get createTheGroup => 'Grubu oluştur';

  @override
  String get editGroup => 'Grubu düzenle';

  @override
  String get noEditPermission => 'Bu grubu düzenleme yetkin yok.';

  @override
  String get backToGroup => 'Gruba dön';

  @override
  String get save => 'Kaydet';

  @override
  String get logoAndCover => 'Logo ve kapak';

  @override
  String get imageHint => 'JPEG, PNG veya WebP · en fazla 5 MB';

  @override
  String get logo => 'Logo';

  @override
  String get cover => 'Kapak';

  @override
  String groupHandle(String handle) {
    return 'Grup adresi: $handle';
  }

  @override
  String get rules => 'Kurallar';

  @override
  String get rulesHint => 'Üyelerden beklentilerin, her satıra bir kural.';

  @override
  String get links => 'Bağlantılar';

  @override
  String linksHint(int max) {
    return 'Web sitesi, sosyal medya hesapları. En fazla $max tane.';
  }

  @override
  String get enterLabel => 'Bir etiket yaz.';

  @override
  String get label => 'Etiket';

  @override
  String get address => 'Adres';

  @override
  String get removeLink => 'Bağlantıyı kaldır';

  @override
  String get addLink => 'Bağlantı ekle';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get saveChanges => 'Değişiklikleri kaydet';

  @override
  String get deleteGroup => 'Grubu sil';

  @override
  String get deleteGroupBody =>
      'Grup, üyelikler, roller, istekler ve davetler kalıcı olarak silinir. Paketin kalan süresi iade edilmez.';

  @override
  String deleteGroupNamed(String name) {
    return '$name grubunu sil';
  }

  @override
  String changeImage(String label) {
    return '$label değiştir';
  }

  @override
  String addImage(String label) {
    return '$label ekle';
  }

  @override
  String get remove => 'Kaldır';

  @override
  String get deleteForever => 'Grubu kalıcı olarak sil';

  @override
  String deleteConfirm(String handle) {
    return 'Bu işlem geri alınamaz. Onaylamak için grup adresini yaz: $handle';
  }

  @override
  String get delete => 'Sil';

  @override
  String get group => 'Grup';

  @override
  String get share => 'Paylaş';

  @override
  String shareText(String name) {
    return '$name grubuna GWAY\'de göz at:';
  }

  @override
  String get moreOptions => 'Diğer seçenekler';

  @override
  String get leaveGroup => 'Gruptan ayrıl';

  @override
  String get groupNotFound => 'Bu grup bulunamadı ya da artık görünür değil.';

  @override
  String get backToGroups => 'Gruplara dön';

  @override
  String leaveConfirm(String name) {
    return '$name grubundan ayrılmak istiyor musun? Grupta bir rolün varsa o da kaldırılır.';
  }

  @override
  String get leave => 'Ayrıl';

  @override
  String leftGroup(String name) {
    return '$name grubundan ayrıldın.';
  }

  @override
  String get suspendedNotice =>
      'Bu grup platform ekibi tarafından askıya alındı. Askı sürerken grup yalnızca üyelerine görünür.';

  @override
  String founded(String date) {
    return 'Kuruluş: $date';
  }

  @override
  String joinRequestsPending(int count) {
    return '$count katılım isteği onay bekliyor.';
  }

  @override
  String get review => 'İncele';

  @override
  String get requestSent => 'Katılım isteğin gönderildi.';

  @override
  String get youAreMember => 'Üyesin';

  @override
  String get join => 'Katıl';

  @override
  String joined(String name) {
    return '$name grubuna katıldın.';
  }

  @override
  String get sendJoinRequest => 'Katılma isteği gönder';

  @override
  String get requestSentShort => 'İstek gönderildi';

  @override
  String get withdrawRequest => 'İsteği geri al';

  @override
  String get withdrawConfirm => 'Katılım isteğini geri almak istiyor musun?';

  @override
  String get undo => 'Geri al';

  @override
  String get requestWithdrawn => 'Katılım isteğin geri alındı.';

  @override
  String get decline => 'Reddet';

  @override
  String get inviteDeclined => 'Davet reddedildi.';

  @override
  String get acceptInvite => 'Daveti kabul et';

  @override
  String followOn(String name) {
    return '$name gönderileri akışında görünecek.';
  }

  @override
  String get followOff => 'Grubu takip etmeyi bıraktın.';

  @override
  String get following => 'Takiptesin';

  @override
  String get follow => 'Takip et';

  @override
  String get managementTeam => 'Yönetim ekibi';

  @override
  String allMembers(int count) {
    return 'Tüm üyeler ($count)';
  }

  @override
  String get groups => 'Gruplar';

  @override
  String get discover => 'Keşfet';

  @override
  String get myGroups => 'Gruplarım';

  @override
  String get plans => 'Paketler';

  @override
  String get searchHint => 'Grup adı veya adresi ile ara';

  @override
  String get clearSearch => 'Aramayı temizle';

  @override
  String get all => 'Tümü';

  @override
  String get noMatch => 'Aramana uygun grup bulunamadı.';

  @override
  String get clearFilters => 'Filtreleri temizle';

  @override
  String get noGroupsYet => 'Henüz hiç grup yok. İlk grubu sen kur.';

  @override
  String get showMore => 'Daha fazla göster';

  @override
  String get notJoinedYet => 'Henüz bir gruba katılmadın.';

  @override
  String get discoverGroups => 'Grupları keşfet';

  @override
  String get plansHint =>
      'Paketleri grup sahipleri alır. Grubunu kurup paketini seçebilirsin.';

  @override
  String get yourInvitations => 'Davetlerin';

  @override
  String get invitationsHint => 'Bu gruplar seni üye olmaya davet etti.';

  @override
  String invitedBy(String name) {
    return '$name davet etti';
  }

  @override
  String get linkCopied => 'Bağlantı kopyalandı.';

  @override
  String inviteShareText(String name) {
    return '$name grubuna GWAY\'de katıl:';
  }

  @override
  String get revokeLinkTitle => 'Bağlantı iptal edilsin mi?';

  @override
  String get revokeLinkBody =>
      'Bu bağlantıyla artık kimse katılamaz. Katılmış olanlar üye olarak kalır.';

  @override
  String get revoke => 'İptal et';

  @override
  String get inviteLink => 'Davet bağlantısı';

  @override
  String get inviteLinkHint =>
      'WhatsApp ya da Instagram\'da paylaş. Bağlantıyı açan kişi katılım tipine bakılmadan doğrudan üye olur.';

  @override
  String get createLink => 'Bağlantı oluştur';

  @override
  String validUntil(String date) {
    return '$date tarihine kadar';
  }

  @override
  String peopleJoined(int count) {
    return '$count kişi katıldı';
  }

  @override
  String peopleJoinedOf(int count, int max) {
    return '$count / $max kişi katıldı';
  }

  @override
  String get newInviteLink => 'Yeni davet bağlantısı';

  @override
  String get validity => 'Geçerlilik süresi';

  @override
  String days(int count) {
    return '$count gün';
  }

  @override
  String get howMany => 'Kaç kişi katılabilir?';

  @override
  String get unlimited => 'Sınırsız';

  @override
  String people(int count) {
    return '$count kişi';
  }

  @override
  String get createAndShare => 'Oluştur ve paylaş';

  @override
  String get invitation => 'Davet';

  @override
  String get linkInvalid =>
      'Bu davet bağlantısı artık geçerli değil. Grubun yöneticisinden yeni bir bağlantı isteyebilirsin.';

  @override
  String get seeGroup => 'Grubu gör';

  @override
  String get invitedToGroup => 'Bu gruba davet edildin.';

  @override
  String get joinGroup => 'Gruba katıl';

  @override
  String get members => 'Üyeler';

  @override
  String get requests => 'İstekler';

  @override
  String get invitations => 'Davetler';

  @override
  String get roles => 'Roller';

  @override
  String get openCase => 'Disiplin dosyası aç';

  @override
  String get report => 'Şikayet et';

  @override
  String membersVisibility(int shown, int total) {
    return 'Üye listesinin tamamını grubun üyeleri görür. Burada yönetim ekibi ve gruplarını herkese açan $shown kişi var; grupta toplam $total üye var.';
  }

  @override
  String optionsFor(String name) {
    return '$name için seçenekler';
  }

  @override
  String get transferOwnership => 'Sahipliği devret';

  @override
  String transferBody(String group, String person) {
    return '$group grubunun sahipliği $person kişisine geçecek. Sen normal üye olarak kalacaksın ve bu işlemi geri alamazsın.';
  }

  @override
  String get transfer => 'Devret';

  @override
  String transferred(String name) {
    return 'Sahiplik $name kişisine devredildi.';
  }

  @override
  String get hintAdmin =>
      'Grubu düzenler, katılım isteklerini ve davetleri yönetir.';

  @override
  String get hintDiscipline =>
      'Şikayet dosyalarını inceler ve yaptırım kararı verir.';

  @override
  String get hintModerator => 'İçerikleri ve yorumları denetler.';

  @override
  String personJoined(String name) {
    return '$name gruba katıldı.';
  }

  @override
  String get requestDeclined => 'İstek reddedildi.';

  @override
  String get noPendingRequests => 'Bekleyen katılım isteği yok.';

  @override
  String get refresh => 'Yenile';

  @override
  String get approve => 'Onayla';

  @override
  String get inviteSent => 'Davet gönderildi.';

  @override
  String get inviteByUsername => 'Kullanıcı adıyla davet et';

  @override
  String get invite => 'Davet et';

  @override
  String get noPendingInvites => 'Bekleyen davet yok.';

  @override
  String memberCount(int count) {
    return '$count üye';
  }

  @override
  String get suspended => 'Askıda';

  @override
  String get groupsSection => 'Gruplar';

  @override
  String get groupsOwnHint =>
      'Gruplarını yalnızca aynı gruptaki üyeler görür. Ayarlar\'dan herkese açabilirsin.';

  @override
  String get groupsOtherHint =>
      'Yalnızca ortak grupların ve yönetim ekibinde olduğu gruplar görünür.';

  @override
  String get noGroupsToShow => 'Gösterilecek grup yok.';

  @override
  String get handleTaken => 'Bu grup adresi alınmış. Başka bir tane dene.';

  @override
  String get groupAddress => 'Grup adresi';

  @override
  String get groupAddressHint =>
      'Grup sayfanın adresi. Sonradan değiştirilemez.';

  @override
  String get available => 'Kullanılabilir';

  @override
  String get taken => 'Alınmış';

  @override
  String get notSpecified => 'Belirtilmedi';

  @override
  String get provinceOptional => 'İl (isteğe bağlı)';

  @override
  String get provinceHint => 'Grup haritada bu ilde görünür.';

  @override
  String get chooseCategory => 'Bir kategori seç.';

  @override
  String get category => 'Kategori';
}
