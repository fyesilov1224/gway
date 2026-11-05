// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'messaging_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class MessagingL10nTr extends MessagingL10n {
  MessagingL10nTr([String locale = 'tr']) : super(locale);

  @override
  String get groupInvalid => 'Talebi üyesi olduğun bir gruba gönderebilirsin.';

  @override
  String get permissionExists => 'Talebin zaten alındı ya da yetkin açık.';

  @override
  String get permissionCooldown =>
      'Yeni bir talebi son karardan 7 gün sonra gönderebilirsin.';

  @override
  String noteTooLong(int max) {
    return 'Not en fazla $max karakter olabilir.';
  }

  @override
  String get requestForbidden => 'Talep şu anda gönderilemiyor.';

  @override
  String get unsupportedImage =>
      'Bu dosya türü desteklenmiyor. JPEG, PNG veya WebP seç.';

  @override
  String get voiceCallHandle => 'GWAY sesli arama';

  @override
  String get incomingCalls => 'Gelen aramalar';

  @override
  String get missedCalls => 'Cevapsız aramalar';

  @override
  String get answer => 'Cevapla';

  @override
  String get decline => 'Reddet';

  @override
  String get noAnswer => 'Cevap verilmedi';

  @override
  String get missedCall => 'Cevapsız arama';

  @override
  String get callDeclined => 'Arama reddedildi';

  @override
  String get youDeclined => 'Aramayı reddettin';

  @override
  String get callNotAllowed => 'Arama artık mümkün değil';

  @override
  String get callCanceled => 'Arama iptal edildi';

  @override
  String get timeLimit => '60 dakika doldu, görüşme bitti';

  @override
  String get endedNotAllowed =>
      'Görüşme sona erdi: sesli görüşme artık mümkün değil';

  @override
  String get callEnded => 'Görüşme bitti';

  @override
  String get messageDeleted => 'Mesaj silindi';

  @override
  String get photo => 'Fotoğraf';

  @override
  String get tonightTable => 'Bu akşamın masası';

  @override
  String get blockRequestPending =>
      'Yanıt vermek için önce mesaj isteğini kabul et.';

  @override
  String get blockDeclined => 'Bu kişi mesaj isteğini kabul etmedi.';

  @override
  String get blockMuted => 'Bu grupta susturulduğun için şu anda yazamazsın.';

  @override
  String get blockAdminsOnly => 'Bu sohbette yalnızca yöneticiler yazabilir.';

  @override
  String get blockTableClosed =>
      'Masa kapandı; mesajları okuyabilirsin ama yeni mesaj yazılamaz.';

  @override
  String get blockBlocked => 'Engel olduğu için bu sohbete yazılamıyor.';

  @override
  String get blockMatchEnded => 'Eşleşme bittiği için bu sohbet kapandı.';

  @override
  String get blockMatchLocked =>
      'Eşleştiğin kişiye yazmak için Eşleşme Sohbeti paketi gerekir. Mesajları okumak ücretsiz.';

  @override
  String get blockTeammateLocked =>
      'Ekip arkadaşına yazmak için Ekip Arkadaşı paketi gerekir. Mesajları okumak ücretsiz.';

  @override
  String get blockNotAllowed =>
      'Özel mesaj artık yalnızca eşleşenler ve ekip arkadaşları içindir. Eski mesajlarını okuyabilirsin.';

  @override
  String get blockOther => 'Bu sohbete şu anda yazamazsın.';

  @override
  String get hiddenUser => 'GWAY kullanıcısı';

  @override
  String get voiceCalls => 'Sesli görüşme';

  @override
  String get voiceCallsHeadline =>
      'Eşleştiğin kişilerle ve ekip arkadaşlarınla sesli konuş';

  @override
  String voiceCallsIntro(int minutes) {
    return 'Sesli görüşme, eşleştiğin kişileri ve ekip arkadaşlarını özel sohbetten aramanı sağlar. Herkese açık değildir: üyesi olduğun bir gruptan talep edersin, grubun sahibi ya da Yöneticisi açar. Görüşmeler kaydedilmez ve dinlenemez; bir görüşme en fazla $minutes dakika sürer.';
  }

  @override
  String get status => 'Durum';

  @override
  String get notRequested => 'Talep edilmedi';

  @override
  String get underReview => 'İnceleniyor';

  @override
  String get statusOn => 'Açık';

  @override
  String get statusOff => 'Kapalı';

  @override
  String get notRequestedYet => 'Henüz talep etmedin.';

  @override
  String requestedFrom(String group) {
    return 'Talebin $group yöneticilerine ulaştı. Karar verilince bildirim gelir.';
  }

  @override
  String get requestedFromGroup =>
      'Talebin grubun yöneticilerine ulaştı. Karar verilince bildirim gelir.';

  @override
  String activeFrom(String group) {
    return 'Sesli görüşmen açık ($group). Eşleştiğin kişileri ve ekip arkadaşlarını sohbetin üstündeki telefon simgesiyle arayabilirsin; karşı tarafın da yetkisi açık olmalı.';
  }

  @override
  String get active =>
      'Sesli görüşmen açık. Eşleştiğin kişileri ve ekip arkadaşlarını sohbetin üstündeki telefon simgesiyle arayabilirsin; karşı tarafın da yetkisi açık olmalı.';

  @override
  String get declined => 'Talebin şimdilik kabul edilmedi.';

  @override
  String get revokedLeftGroup =>
      'Yetkiyi veren gruptan ayrıldığın için sesli görüşmen kapandı. Başka bir grubundan yeniden talep edebilirsin.';

  @override
  String get revoked => 'Sesli görüşmen kapatıldı.';

  @override
  String reasonLine(String reason) {
    return 'Gerekçe: $reason';
  }

  @override
  String yourNote(String note) {
    return 'Notun: $note';
  }

  @override
  String waitUntil(String date) {
    return '$date sonrasında yeniden talep edebilirsin.';
  }

  @override
  String get requestSent => 'Talebin gönderildi.';

  @override
  String get joinGroupFirst =>
      'Sesli görüşmeyi grupların sahipleri ve Yöneticileri açar. Talep edebilmek için önce bir gruba katıl.';

  @override
  String get requestToGroup => 'Talebin gideceği grup';

  @override
  String get noteOptional => 'Not (isteğe bağlı)';

  @override
  String get noteHint => 'Neden sesli görüşme istediğini kısaca yazabilirsin.';

  @override
  String get request => 'Talep et';

  @override
  String get lockScreenCalls => 'Kilit ekranında gelen arama';

  @override
  String get lockScreenHint =>
      'Telefonun kilitliyken aramaların tam ekran çalması için GWAY\'e izin ver.';

  @override
  String get allow => 'İzni aç';

  @override
  String get callInfoFailed =>
      'Görüşme bilgisi alınamadı. Bağlantını kontrol et.';

  @override
  String get tapEndToHangUp => 'Görüşmeyi bitirmek için Bitir\'e dokun.';

  @override
  String get callNotFound => 'Bu görüşme bulunamadı.';

  @override
  String get close => 'Kapat';

  @override
  String callLimitNote(int minutes) {
    return 'Görüşme en fazla $minutes dakika sürer ve kaydedilmez.';
  }

  @override
  String get audioFailed =>
      'Sese bağlanılamadı. Bağlantını kontrol edip tekrar dene.';

  @override
  String get reconnect => 'Tekrar bağlan';

  @override
  String get incoming => 'Seni sesli arıyor…';

  @override
  String get calling => 'Aranıyor…';

  @override
  String get connecting => 'Bağlanıyor…';

  @override
  String get answerCall => 'Cevapla';

  @override
  String get mute => 'Sessize al';

  @override
  String get unmute => 'Sesi aç';

  @override
  String get end => 'Bitir';

  @override
  String get speaker => 'Hoparlör';

  @override
  String get peerUnencrypted =>
      'Karşındakinin uygulaması eski, sesi şifresiz geliyor ve çalınmıyor. Uygulamasını güncellemesini iste.';

  @override
  String get encrypting => 'Şifreli bağlantı kuruluyor…';

  @override
  String e2eeCode(String code) {
    return 'Uçtan uca şifreli. Güvenlik kodu $code';
  }

  @override
  String get e2ee => 'Uçtan uca şifreli';

  @override
  String get codeMatchHint =>
      'Bu kod karşındakinin ekranındakiyle aynıysa görüşmeyi kimse dinleyemez.';

  @override
  String get micFailed => 'Mikrofon açılamadı. Mikrofon iznini kontrol et.';

  @override
  String get chatNotFound => 'Bu sohbet bulunamadı ya da artık göremiyorsun.';

  @override
  String get backToMessages => 'Mesajlara dön';

  @override
  String get cantCallNow => 'Şu anda arama yapılamıyor.';

  @override
  String get voiceCall => 'Sesli ara';

  @override
  String get groupChatAdminsOnly => 'Grup sohbeti · yalnızca yöneticiler yazar';

  @override
  String get groupChat => 'Grup sohbeti';

  @override
  String smallTableMembers(int count) {
    return 'Küçük masa · $count kişi';
  }

  @override
  String get adminsOnlyOn =>
      'Artık bu sohbete yalnızca grup sahibi ve yöneticiler yazabilir.';

  @override
  String get adminsOnlyOff => 'Artık grubun tüm üyeleri bu sohbete yazabilir.';

  @override
  String get chatSettings => 'Sohbet ayarları';

  @override
  String get adminsOnlyToggle => 'Yalnızca yöneticiler yazsın';

  @override
  String get sendingPhoto => '📷 Fotoğraf gönderiliyor…';

  @override
  String get requestPendingNote =>
      'Mesaj isteğin iletildi. Kabul edilene kadar okunup okunmadığını göremezsin.';

  @override
  String get groupChatEmpty =>
      'Grup sohbetinde henüz mesaj yok. İlk mesajı sen yaz.';

  @override
  String get chatEmpty => 'Henüz mesaj yok. İlk mesajı sen yaz.';

  @override
  String get startWriting => 'Yazmaya başla';

  @override
  String get sending => 'Gönderiliyor…';

  @override
  String get seen => 'Görüldü';

  @override
  String get sent => 'Gönderildi';

  @override
  String get seePackage => 'Paketi incele';

  @override
  String get today => 'Bugün';

  @override
  String get messageRemoved => 'Bu mesaj kaldırıldı.';

  @override
  String get thisMessageDeleted => 'Bu mesaj silindi.';

  @override
  String get messageOptions => 'Mesaj seçenekleri';

  @override
  String profileOf(String name) {
    return '$name profili';
  }

  @override
  String get you => 'Sen';

  @override
  String get copy => 'Kopyala';

  @override
  String get copied => 'Mesaj kopyalandı.';

  @override
  String get deleteForAll => 'Herkesten sil';

  @override
  String get report => 'Şikayet et';

  @override
  String get deleteForAllTitle => 'Mesaj herkesten silinsin mi?';

  @override
  String get deleteForAllBody =>
      'Mesaj sohbetteki herkes için \"Bu mesaj silindi\" olarak görünür. Bu işlem geri alınamaz.';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get delete => 'Sil';

  @override
  String get requestDeleted => 'Mesaj isteği silindi.';

  @override
  String wantsToMessage(String name) {
    return '$name sana mesaj göndermek istiyor. Kabul edersen yazışabilirsiniz ve mesajları okuduğunu görebilir.';
  }

  @override
  String get accept => 'Kabul et';

  @override
  String get removePhoto => 'Fotoğrafı kaldır';

  @override
  String get addPhoto => 'Fotoğraf ekle';

  @override
  String get writeMessage => 'Mesaj yaz';

  @override
  String get send => 'Gönder';

  @override
  String get messages => 'Mesajlar';

  @override
  String get chats => 'Sohbetler';

  @override
  String get requests => 'İstekler';

  @override
  String requestsCount(int count) {
    return 'İstekler ($count)';
  }

  @override
  String get noChats =>
      'Henüz bir sohbetin yok. Eşleştiğin kişilere ve ekip arkadaşlarına yazabilirsin.';

  @override
  String get findPeople => 'Kişi bul';

  @override
  String get oldRequestsNote =>
      'Eski mesaj istekleri burada durur. Özel mesaj artık yalnızca eşleşenler ve ekip arkadaşları içindir; yeni istek gelmez.';

  @override
  String get noRequests => 'Bekleyen mesaj isteğin yok.';

  @override
  String get backToChats => 'Sohbetlere dön';

  @override
  String get callRequests => 'Sesli görüşme talepleri';

  @override
  String noPendingWithActive(int count) {
    return 'Bekleyen talep yok · $count açık yetki';
  }

  @override
  String pendingCount(int count) {
    return '$count talep bekliyor';
  }

  @override
  String get pending => 'Bekleyen';

  @override
  String get activeTab => 'Açık';

  @override
  String get requestsOwnersOnly =>
      'Sesli görüşme taleplerini grup sahibi ve Yöneticiler görür.';

  @override
  String get goBack => 'Geri dön';

  @override
  String noPendingFor(String group) {
    return 'Bekleyen talep yok. $group üyeleri talep edince burada görünür.';
  }

  @override
  String get noActive => 'Bu grubun açtığı sesli görüşme yetkisi yok.';

  @override
  String get refresh => 'Yenile';

  @override
  String get grantHint =>
      'Açtığın yetkiyle kişi eşleştiği ve ekip arkadaşı olduğu herkesi sesli arayabilir. Görüşmeler kaydedilmez; kişi gruptan ayrılırsa yetki kapanır.';

  @override
  String get granted => 'Sesli görüşme açıldı.';

  @override
  String get turnedOff => 'Sesli görüşme kapatıldı.';

  @override
  String theirNote(String note) {
    return 'Notu: $note';
  }

  @override
  String get turnOff => 'Kapat';

  @override
  String get turnOn => 'Aç';

  @override
  String get rankOnlyGrant =>
      'Rütbesi seninkine eşit ya da yüksek olduğu için bu talebi yalnızca açabilirsin.';

  @override
  String get rankCannotRevoke =>
      'Rütbesi seninkine eşit ya da yüksek olduğu için bu yetkiyi kapatamazsın.';

  @override
  String get declineRequest => 'Talebi reddet';

  @override
  String get turnOffCalls => 'Sesli görüşmeyi kapat';

  @override
  String get declineHint =>
      'Kişi gerekçeyi görür ve 7 gün sonra yeniden talep edebilir.';

  @override
  String get revokeHint =>
      'Kişinin süren görüşmesi hemen biter. Gerekçeyi görür ve 7 gün sonra yeniden talep edebilir.';

  @override
  String get reason => 'Gerekçe';

  @override
  String get reasonMin3 => 'Gerekçe en az 3 karakter olmalı.';

  @override
  String get yesterday => 'Dün';

  @override
  String get sendMessage => 'Mesaj gönder';

  @override
  String get groupChatMembersOnly =>
      'Grup sohbetini yalnızca grubun üyeleri görebilir.';
}
