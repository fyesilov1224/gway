// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'messaging_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Azerbaijani (`az`).
class MessagingL10nAz extends MessagingL10n {
  MessagingL10nAz([String locale = 'az']) : super(locale);

  @override
  String get groupInvalid => 'Talebi üzvü olduğun qrupa göndərə bilərsən.';

  @override
  String get permissionExists => 'Talebin artıq alınıb və ya yetkin açıqdır.';

  @override
  String get permissionCooldown =>
      'Yeni talebi son qərardan 7 gün sonra göndərə bilərsən.';

  @override
  String noteTooLong(int max) {
    return 'Qeyd ən çox $max simvol ola bilər.';
  }

  @override
  String get requestForbidden => 'Talep hazırda göndərilə bilmir.';

  @override
  String get unsupportedImage =>
      'Bu fayl növü dəstəklənmir. JPEG, PNG və ya WebP seç.';

  @override
  String get voiceCallHandle => 'GWAY səsli zəng';

  @override
  String get incomingCalls => 'Gələn zənglər';

  @override
  String get missedCalls => 'Buraxılmış zənglər';

  @override
  String get answer => 'Cavab ver';

  @override
  String get decline => 'Rədd et';

  @override
  String get noAnswer => 'Cavab verilmədi';

  @override
  String get missedCall => 'Buraxılmış zəng';

  @override
  String get callDeclined => 'Zəng rədd edildi';

  @override
  String get youDeclined => 'Zəngi rədd etdin';

  @override
  String get callNotAllowed => 'Zəng artıq mümkün deyil';

  @override
  String get callCanceled => 'Zəng ləğv edildi';

  @override
  String get timeLimit => '60 dəqiqə doldu, zəng bitdi';

  @override
  String get endedNotAllowed => 'Zəng bitdi: səsli zəng artıq mümkün deyil';

  @override
  String get callEnded => 'Zəng bitdi';

  @override
  String get messageDeleted => 'Mesaj silindi';

  @override
  String get photo => 'Şəkil';

  @override
  String get tonightTable => 'Bu axşamın masası';

  @override
  String get blockRequestPending =>
      'Cavab vermək üçün əvvəlcə mesaj istəyini qəbul et.';

  @override
  String get blockDeclined => 'Bu şəxs mesaj istəyini qəbul etmədi.';

  @override
  String get blockMuted =>
      'Bu qrupda səsin bağlandığı üçün hazırda yaza bilməzsən.';

  @override
  String get blockAdminsOnly => 'Bu söhbətdə yalnız idarəçilər yaza bilər.';

  @override
  String get blockTableClosed =>
      'Masa bağlandı; mesajları oxuya bilərsən, amma yeni mesaj yazmaq olmur.';

  @override
  String get blockBlocked => 'Blok olduğu üçün bu söhbətə yazmaq olmur.';

  @override
  String get blockMatchEnded => 'Uyğunluq bitdiyi üçün bu söhbət bağlandı.';

  @override
  String get blockMatchLocked =>
      'Uyğunlaşdığın şəxsə yazmaq üçün Uyğunluq Söhbəti paketi lazımdır. Mesajları oxumaq pulsuzdur.';

  @override
  String get blockTeammateLocked =>
      'Komanda yoldaşına yazmaq üçün Komanda Yoldaşı paketi lazımdır. Mesajları oxumaq pulsuzdur.';

  @override
  String get blockNotAllowed =>
      'Şəxsi mesaj artıq yalnız uyğunlaşanlar və komanda yoldaşları üçündür. Köhnə mesajlarını oxuya bilərsən.';

  @override
  String get blockOther => 'Bu söhbətə hazırda yaza bilməzsən.';

  @override
  String get hiddenUser => 'GWAY istifadəçisi';

  @override
  String get voiceCalls => 'Səsli zəng';

  @override
  String get voiceCallsHeadline =>
      'Uyğunlaşdığın insanlarla və komanda yoldaşlarınla səsli danış';

  @override
  String voiceCallsIntro(int minutes) {
    return 'Səsli zəng uyğunlaşdığın insanlara və komanda yoldaşlarına şəxsi söhbətdən zəng etməyə imkan verir. Hamıya açıq deyil: üzvü olduğun qrupdan talep edirsən, qrupun sahibi və ya İdarəçisi açır. Zənglər yazılmır və dinlənilmir; bir zəng ən çox $minutes dəqiqə çəkir.';
  }

  @override
  String get status => 'Status';

  @override
  String get notRequested => 'Talep edilmədi';

  @override
  String get underReview => 'Baxılır';

  @override
  String get statusOn => 'Açıq';

  @override
  String get statusOff => 'Bağlı';

  @override
  String get notRequestedYet => 'Hələ talep etməmisən.';

  @override
  String requestedFrom(String group) {
    return 'Talebin $group idarəçilərinə çatdı. Qərar veriləndə bildiriş gələcək.';
  }

  @override
  String get requestedFromGroup =>
      'Talebin qrupun idarəçilərinə çatdı. Qərar veriləndə bildiriş gələcək.';

  @override
  String activeFrom(String group) {
    return 'Səsli zəngin açıqdır ($group). Uyğunlaşdığın insanlara və komanda yoldaşlarına söhbətin üstündəki telefon simvolu ilə zəng edə bilərsən; qarşı tərəfin də yetkisi açıq olmalıdır.';
  }

  @override
  String get active =>
      'Səsli zəngin açıqdır. Uyğunlaşdığın insanlara və komanda yoldaşlarına söhbətin üstündəki telefon simvolu ilə zəng edə bilərsən; qarşı tərəfin də yetkisi açıq olmalıdır.';

  @override
  String get declined => 'Talebin hələlik qəbul edilmədi.';

  @override
  String get revokedLeftGroup =>
      'Yetkini verən qrupdan çıxdığın üçün səsli zəngin bağlandı. Başqa qrupundan yenidən talep edə bilərsən.';

  @override
  String get revoked => 'Səsli zəngin bağlandı.';

  @override
  String reasonLine(String reason) {
    return 'Səbəb: $reason';
  }

  @override
  String yourNote(String note) {
    return 'Qeydin: $note';
  }

  @override
  String waitUntil(String date) {
    return '$date tarixindən sonra yenidən talep edə bilərsən.';
  }

  @override
  String get requestSent => 'Talebin göndərildi.';

  @override
  String get joinGroupFirst =>
      'Səsli zəngi qrupların sahibləri və İdarəçiləri açır. Talep edə bilmək üçün əvvəlcə bir qrupa qoşul.';

  @override
  String get requestToGroup => 'Talebin gedəcəyi qrup';

  @override
  String get noteOptional => 'Qeyd (istəyə bağlı)';

  @override
  String get noteHint => 'Niyə səsli zəng istədiyini qısaca yaza bilərsən.';

  @override
  String get request => 'Talep et';

  @override
  String get lockScreenCalls => 'Kilid ekranında gələn zəng';

  @override
  String get lockScreenHint =>
      'Telefonun kilidli olanda zənglərin tam ekranda çalması üçün GWAY-ə icazə ver.';

  @override
  String get allow => 'İcazəni aç';

  @override
  String get callInfoFailed => 'Zəng məlumatı alınmadı. Bağlantını yoxla.';

  @override
  String get tapEndToHangUp => 'Zəngi bitirmək üçün Bitir-ə toxun.';

  @override
  String get callNotFound => 'Bu zəng tapılmadı.';

  @override
  String get close => 'Bağla';

  @override
  String callLimitNote(int minutes) {
    return 'Zəng ən çox $minutes dəqiqə çəkir və yazılmır.';
  }

  @override
  String get audioFailed =>
      'Səsə qoşulmaq olmadı. Bağlantını yoxla və yenidən cəhd et.';

  @override
  String get reconnect => 'Yenidən qoşul';

  @override
  String get incoming => 'sənə zəng edir…';

  @override
  String get calling => 'Zəng edilir…';

  @override
  String get connecting => 'Qoşulur…';

  @override
  String get answerCall => 'Cavab ver';

  @override
  String get mute => 'Səssizə al';

  @override
  String get unmute => 'Səsi aç';

  @override
  String get end => 'Bitir';

  @override
  String get speaker => 'Dinamik';

  @override
  String get peerUnencrypted =>
      'Qarşındakının tətbiqi köhnədir, səs şifrəsiz gəlir və çalınmır. Tətbiqi yeniləməsini istə.';

  @override
  String get encrypting => 'Şifrəli bağlantı qurulur…';

  @override
  String e2eeCode(String code) {
    return 'Ucdan-uca şifrəli. Təhlükəsizlik kodu $code';
  }

  @override
  String get e2ee => 'Ucdan-uca şifrəli';

  @override
  String get codeMatchHint =>
      'Bu kod qarşındakının ekranındakı ilə eynidirsə, zəngi heç kim dinləyə bilməz.';

  @override
  String get micFailed => 'Mikrofon açılmadı. Mikrofon icazəsini yoxla.';

  @override
  String get chatNotFound => 'Bu söhbət tapılmadı və ya artıq görə bilmirsən.';

  @override
  String get backToMessages => 'Mesajlara qayıt';

  @override
  String get cantCallNow => 'Hazırda zəng etmək olmur.';

  @override
  String get voiceCall => 'Səsli zəng';

  @override
  String get groupChatAdminsOnly => 'Qrup söhbəti · yalnız idarəçilər yazır';

  @override
  String get groupChat => 'Qrup söhbəti';

  @override
  String smallTableMembers(int count) {
    return 'Kiçik masa · $count nəfər';
  }

  @override
  String get adminsOnlyOn =>
      'Artıq bu söhbətə yalnız qrup sahibi və idarəçilər yaza bilər.';

  @override
  String get adminsOnlyOff =>
      'Artıq qrupun bütün üzvləri bu söhbətə yaza bilər.';

  @override
  String get chatSettings => 'Söhbət ayarları';

  @override
  String get adminsOnlyToggle => 'Yalnız idarəçilər yazsın';

  @override
  String get sendingPhoto => '📷 Şəkil göndərilir…';

  @override
  String get requestPendingNote =>
      'Mesaj istəyin göndərildi. Qəbul edilənə qədər oxunub-oxunmadığını görə bilməzsən.';

  @override
  String get groupChatEmpty =>
      'Qrup söhbətində hələ mesaj yoxdur. İlk mesajı sən yaz.';

  @override
  String get chatEmpty => 'Hələ mesaj yoxdur. İlk mesajı sən yaz.';

  @override
  String get startWriting => 'Yazmağa başla';

  @override
  String get sending => 'Göndərilir…';

  @override
  String get seen => 'Görüldü';

  @override
  String get sent => 'Göndərildi';

  @override
  String get seePackage => 'Paketə bax';

  @override
  String get today => 'Bu gün';

  @override
  String get messageRemoved => 'Bu mesaj götürüldü.';

  @override
  String get thisMessageDeleted => 'Bu mesaj silindi.';

  @override
  String get messageOptions => 'Mesaj seçimləri';

  @override
  String profileOf(String name) {
    return '$name profili';
  }

  @override
  String get you => 'Sən';

  @override
  String get copy => 'Kopyala';

  @override
  String get copied => 'Mesaj kopyalandı.';

  @override
  String get deleteForAll => 'Hamıdan sil';

  @override
  String get report => 'Şikayət et';

  @override
  String get deleteForAllTitle => 'Mesaj hamıdan silinsin?';

  @override
  String get deleteForAllBody =>
      'Mesaj söhbətdəki hamı üçün \"Bu mesaj silindi\" kimi görünür. Bu geri qaytarılmır.';

  @override
  String get cancel => 'İmtina et';

  @override
  String get delete => 'Sil';

  @override
  String get requestDeleted => 'Mesaj istəyi silindi.';

  @override
  String wantsToMessage(String name) {
    return '$name sənə mesaj göndərmək istəyir. Qəbul etsən, yazışa bilərsiniz və mesajları oxuduğunu görə bilər.';
  }

  @override
  String get accept => 'Qəbul et';

  @override
  String get removePhoto => 'Şəkli sil';

  @override
  String get addPhoto => 'Şəkil əlavə et';

  @override
  String get writeMessage => 'Mesaj yaz';

  @override
  String get send => 'Göndər';

  @override
  String get messages => 'Mesajlar';

  @override
  String get chats => 'Söhbətlər';

  @override
  String get requests => 'İstəklər';

  @override
  String requestsCount(int count) {
    return 'İstəklər ($count)';
  }

  @override
  String get noChats =>
      'Hələ söhbətin yoxdur. Uyğunlaşdığın insanlara və komanda yoldaşlarına yaza bilərsən.';

  @override
  String get findPeople => 'İnsan tap';

  @override
  String get oldRequestsNote =>
      'Köhnə mesaj istəkləri burada qalır. Şəxsi mesaj artıq yalnız uyğunlaşanlar və komanda yoldaşları üçündür; yeni istək gəlmir.';

  @override
  String get noRequests => 'Gözləyən mesaj istəyin yoxdur.';

  @override
  String get backToChats => 'Söhbətlərə qayıt';

  @override
  String get callRequests => 'Səsli zəng talepləri';

  @override
  String noPendingWithActive(int count) {
    return 'Gözləyən talep yoxdur · $count açıq yetki';
  }

  @override
  String pendingCount(int count) {
    return '$count talep gözləyir';
  }

  @override
  String get pending => 'Gözləyən';

  @override
  String get activeTab => 'Açıq';

  @override
  String get requestsOwnersOnly =>
      'Səsli zəng taleplərini qrup sahibi və İdarəçilər görür.';

  @override
  String get goBack => 'Geri qayıt';

  @override
  String noPendingFor(String group) {
    return 'Gözləyən talep yoxdur. $group üzvləri talep edəndə burada görünür.';
  }

  @override
  String get noActive => 'Bu qrupun açdığı səsli zəng yetkisi yoxdur.';

  @override
  String get refresh => 'Yenilə';

  @override
  String get grantHint =>
      'Açdığın yetki ilə şəxs uyğunlaşdığı və komanda yoldaşı olduğu hər kəsə səsli zəng edə bilər. Zənglər yazılmır; şəxs qrupdan çıxsa, yetki bağlanır.';

  @override
  String get granted => 'Səsli zəng açıldı.';

  @override
  String get turnedOff => 'Səsli zəng bağlandı.';

  @override
  String theirNote(String note) {
    return 'Qeydi: $note';
  }

  @override
  String get turnOff => 'Bağla';

  @override
  String get turnOn => 'Aç';

  @override
  String get rankOnlyGrant =>
      'Rütbəsi səninkinə bərabər və ya yüksək olduğu üçün bu talebi yalnız aça bilərsən.';

  @override
  String get rankCannotRevoke =>
      'Rütbəsi səninkinə bərabər və ya yüksək olduğu üçün bu yetkini bağlaya bilməzsən.';

  @override
  String get declineRequest => 'Talebi rədd et';

  @override
  String get turnOffCalls => 'Səsli zəngi bağla';

  @override
  String get declineHint =>
      'Şəxs səbəbi görür və 7 gün sonra yenidən talep edə bilər.';

  @override
  String get revokeHint =>
      'Şəxsin davam edən zəngi dərhal bitir. Səbəbi görür və 7 gün sonra yenidən talep edə bilər.';

  @override
  String get reason => 'Səbəb';

  @override
  String get reasonMin3 => 'Səbəb ən azı 3 simvol olmalıdır.';

  @override
  String get yesterday => 'Dünən';

  @override
  String get sendMessage => 'Mesaj göndər';

  @override
  String get groupChatMembersOnly =>
      'Qrup söhbətini yalnız qrupun üzvləri görə bilər.';

  @override
  String get callVerifying => 'Şifrələmə yoxlanılır…';

  @override
  String get callSecure => 'Təhlükəsiz zəng';

  @override
  String get callSecureDetail =>
      'Uçdan-uca şifrələnib. Hər iki telefonun təhlükəsizlik kodu uyğun gəldi, araya heç kim girmədi.';

  @override
  String get callCheckFailed =>
      'Şifrələmə təsdiqlənmədi: telefonların təhlükəsizlik kodu uyğun gəlmir. Zəngi bitirib yenidən zəng et.';

  @override
  String get showSecurityCode => 'Təhlükəsizlik kodunu göstər';
}
