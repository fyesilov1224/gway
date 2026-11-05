// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'live_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Azerbaijani (`az`).
class LiveL10nAz extends LiveL10n {
  LiveL10nAz([String locale = 'az']) : super(locale);

  @override
  String get commentRate =>
      'Qısa müddətdə çox şərh yazdın. Bir az gözlə və yenidən cəhd et.';

  @override
  String get mutedListenOnly =>
      'Bu qrupda səsin bağlandığı üçün yayımda yalnız dinləyə bilərsən.';

  @override
  String get cannotComment => 'Bu yayıma hazırda şərh yaza bilməzsən.';

  @override
  String get roleHost => 'Aparıcı';

  @override
  String get roleSpeaker => 'Danışan';

  @override
  String get roleListener => 'Dinləyici';

  @override
  String get startLive => 'Yayım başlat';

  @override
  String hostedBy(String name) {
    return '$name aparır';
  }

  @override
  String get join => 'Qoşul';

  @override
  String upcomingAt(String date) {
    return 'Yaxınlaşır · $date';
  }

  @override
  String get scheduledCanceled => 'Planlı yayım ləğv edildi.';

  @override
  String get cancel => 'Ləğv';

  @override
  String get start => 'Başlat';

  @override
  String get reminderRemoved => 'Xatırlatma silindi.';

  @override
  String get reminderSet => 'Yayım başlayanda xəbər verəcəyik.';

  @override
  String get reminding => 'Xatırladılacaq';

  @override
  String get remind => 'Xatırlat';

  @override
  String get schedule5min => 'Planlı yayım ən azı 5 dəqiqə sonraya olmalıdır.';

  @override
  String get scheduled => 'Yayım planlandı. Üzvlər xatırlatma istəyə bilər.';

  @override
  String get liveBroadcast => 'Canlı yayım';

  @override
  String get liveIntro =>
      'Qrup üzvləri səsli otağa qoşulur; səhnəyə çıxardıqların danışır.';

  @override
  String get title => 'Başlıq';

  @override
  String get titleExample => 'Məs. Bazar yürüyüşü planı';

  @override
  String get titleMin3 => 'Başlıq ən azı 3 simvol olmalıdır.';

  @override
  String get now => 'İndi';

  @override
  String get scheduleIt => 'Planla';

  @override
  String minutesLeft(int count) {
    return 'Bu ay qalan canlı yayım vaxtın: $count dəqiqə.';
  }

  @override
  String get minutesUsedUp =>
      'Bu ayın canlı yayım vaxtı bitdi. Daha çoxu üçün paketini yüksəldə bilərsən.';

  @override
  String get startTheLive => 'Yayımı başlat';

  @override
  String get liveNow => 'İndi canlı';

  @override
  String trayLabel(String group, String title) {
    return '$group canlı yayımdadır: $title';
  }

  @override
  String youAreLive(String title) {
    return 'Canlı yayımdasan: $title. Yayıma qayıtmaq üçün toxun.';
  }

  @override
  String get connecting => 'Yayıma qoşulur…';

  @override
  String get inBroadcast => 'Yayımdasan · qayıtmaq üçün toxun';

  @override
  String get micMutedByMod => 'Mikrofonunu idarəçi bağladı';

  @override
  String get micOff => 'Mikrofonu bağla';

  @override
  String get micOn => 'Mikrofonu aç';

  @override
  String startsOn(String date) {
    return 'Bu yayım $date tarixində başlayacaq.';
  }

  @override
  String get ended => 'Bu yayım bitdi.';

  @override
  String get notFound => 'Bu yayım tapılmadı. Qrupun üzvü olmalı ola bilərsən.';

  @override
  String get goBack => 'Geri qayıt';

  @override
  String get onStageNow =>
      'Səhnəyə çıxarıldın. Mikrofonunu açaraq danışa bilərsən.';

  @override
  String get nowListener => 'Artıq dinləyicisən.';

  @override
  String get leaveBroadcast => 'Yayımdan çıx';

  @override
  String get leaveHostBody =>
      'Yayımı hamı üçün bitirə bilərsən. Yalnız çıxsan, yayım 2 dəqiqə sonra öz-özünə bitir.';

  @override
  String get justLeave => 'Yalnız çıx';

  @override
  String get endBroadcast => 'Yayımı bitir';

  @override
  String get inviteToStage => 'Səhnəyə çıxar';

  @override
  String get removeFromStage => 'Səhnədən endir';

  @override
  String get muteMic => 'Mikrofonunu bağla';

  @override
  String get unmuteMic => 'Mikrofonunu aç';

  @override
  String get kick => 'Yayımdan çıxar';

  @override
  String kickBody(String name) {
    return '$name bu yayıma bir daha girə bilməz.';
  }

  @override
  String get cancelAction => 'İmtina et';

  @override
  String get remove => 'Çıxar';

  @override
  String get raisedHands => 'Əl qaldıranlar';

  @override
  String get commentDeleted => 'Şərh silindi.';

  @override
  String get thanksForJoining => 'Yayım bitdi. Qatıldığın üçün təşəkkürlər.';

  @override
  String get youWereKicked => 'Bu yayımdan çıxarıldın.';

  @override
  String get connectFailedShort => 'Yayıma qoşulmaq olmadı.';

  @override
  String handsRaised(int count) {
    return '$count nəfər əl qaldırdı';
  }

  @override
  String get onStage => 'Səhnədə';

  @override
  String listeners(int count) {
    return 'Dinləyicilər · $count';
  }

  @override
  String get noListeners => 'Hələ dinləyici yoxdur.';

  @override
  String get minimize => 'Kiçilt, yayımda qal';

  @override
  String peopleCount(int count) {
    return '$count nəfər';
  }

  @override
  String get broadcastOptions => 'Yayım seçimləri';

  @override
  String get endForAll => 'Yayımı hamı üçün bitir';

  @override
  String get handRaised =>
      'Əlini qaldırdın. Aparıcı səni səhnəyə çıxara bilər.';

  @override
  String get you => 'Sən';

  @override
  String get speaking => 'danışır';

  @override
  String get micOffState => 'mikrofon bağlıdır';

  @override
  String get handUp => 'əl qaldırdı';

  @override
  String get sendReaction => 'Reaksiya göndər';

  @override
  String get leave => 'Çıx';

  @override
  String get leaveStage => 'Səhnədən en';

  @override
  String get reactions => 'Reaksiyalar';

  @override
  String get comments => 'Şərhlər';

  @override
  String get raiseHand => 'Əl qaldır';

  @override
  String get lowerHand => 'Əlini endir';

  @override
  String get report => 'Şikayət et';

  @override
  String get deleteComment => 'Şərhi sil';

  @override
  String get firstComment => 'İlk şərhi sən yaz.';

  @override
  String get writeComment => 'Şərh yaz…';

  @override
  String get send => 'Göndər';

  @override
  String get connectFailed =>
      'Yayıma qoşulmaq olmadı. Bağlantını yoxla və yenidən cəhd et.';

  @override
  String get participant => 'İştirakçı';

  @override
  String get micNeedsManager => 'Mikrofonunu yalnız yayım idarəçisi aça bilər.';

  @override
  String get micFailed => 'Mikrofon açılmadı. Mikrofon icazəsini yoxla.';

  @override
  String get connectionLost =>
      'Yayımla bağlantın kəsildi. Yenidən qoşulmaq üçün toxun.';

  @override
  String get micAfterEncryption =>
      'Şifrəli bağlantı qurulur; mikrofonun bir azdan açılacaq.';

  @override
  String get encrypting => 'Şifrəli bağlantı qurulur…';

  @override
  String get verifying => 'Şifrələmə yoxlanılır…';

  @override
  String get liveSecure => 'Təhlükəsiz yayım';

  @override
  String get liveSecureDetail =>
      'Uçdan-uca şifrələnib. Otaqdakı hər kəs eyni açardan istifadə edir; səsi server daxil heç kim dinləyə bilməz.';

  @override
  String get liveCheckFailed =>
      'Şifrələmə təsdiqlənmədi: otaqdakı hər kəs eyni açardan istifadə etmir. Yayımdan çıxıb yenidən daxil ol.';

  @override
  String get liveUnconfirmed =>
      'Səhnədəki biri köhnə tətbiq versiyasından istifadə edir; səsi şifrələnə bilmədiyi üçün səslənmir.';

  @override
  String get peerUnencrypted =>
      'Köhnə versiyadakı bir danışanın səsi şifrəsiz gəlir və səslənmir. Tətbiqini yeniləməlidir.';

  @override
  String get e2ee => 'Uçdan-uca şifrəli';

  @override
  String get showSecurityCode => 'Təhlükəsizlik kodunu göstər';

  @override
  String get codeMatchHint => 'Bu kod otaqdakı hər kəsin ekranında eynidir.';

  @override
  String e2eeCode(String code) {
    return 'Uçdan-uca şifrəli. Təhlükəsizlik kodu $code';
  }

  @override
  String get liveOngoingTitle => 'Canlı yayımdasan';

  @override
  String get liveOngoingText => 'Uçdan-uca şifrəli. Qayıtmaq üçün toxun.';
}
