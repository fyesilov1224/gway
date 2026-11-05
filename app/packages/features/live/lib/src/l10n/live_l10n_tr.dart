// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'live_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class LiveL10nTr extends LiveL10n {
  LiveL10nTr([String locale = 'tr']) : super(locale);

  @override
  String get commentRate =>
      'Kısa sürede çok fazla yorum yazdın. Biraz bekleyip tekrar dene.';

  @override
  String get mutedListenOnly =>
      'Bu grupta susturulduğun için yayında yalnızca dinleyebilirsin.';

  @override
  String get cannotComment => 'Bu yayına şu anda yorum yazamazsın.';

  @override
  String get roleHost => 'Sunucu';

  @override
  String get roleSpeaker => 'Konuşmacı';

  @override
  String get roleListener => 'Dinleyici';

  @override
  String get startLive => 'Yayın başlat';

  @override
  String hostedBy(String name) {
    return '$name sunuyor';
  }

  @override
  String get join => 'Katıl';

  @override
  String upcomingAt(String date) {
    return 'Yaklaşan · $date';
  }

  @override
  String get scheduledCanceled => 'Planlı yayın iptal edildi.';

  @override
  String get cancel => 'İptal';

  @override
  String get start => 'Başlat';

  @override
  String get reminderRemoved => 'Hatırlatma kaldırıldı.';

  @override
  String get reminderSet => 'Yayın başlayınca haber vereceğiz.';

  @override
  String get reminding => 'Hatırlatılacak';

  @override
  String get remind => 'Hatırlat';

  @override
  String get schedule5min => 'Planlı yayın en az 5 dakika sonraya olmalı.';

  @override
  String get scheduled => 'Yayın planlandı. Üyeler hatırlatma isteyebilir.';

  @override
  String get liveBroadcast => 'Canlı yayın';

  @override
  String get liveIntro =>
      'Grup üyeleri sesli odaya katılır; sahneye aldıkların konuşur.';

  @override
  String get title => 'Başlık';

  @override
  String get titleExample => 'Ör. Pazar yürüyüşü planı';

  @override
  String get titleMin3 => 'Başlık en az 3 karakter olmalı.';

  @override
  String get now => 'Şimdi';

  @override
  String get scheduleIt => 'Planla';

  @override
  String minutesLeft(int count) {
    return 'Bu ay kalan canlı yayın süren: $count dakika.';
  }

  @override
  String get minutesUsedUp =>
      'Bu ayın canlı yayın süresi doldu. Daha fazlası için paketini yükseltebilirsin.';

  @override
  String get startTheLive => 'Yayını başlat';

  @override
  String get liveNow => 'Şimdi canlı';

  @override
  String trayLabel(String group, String title) {
    return '$group canlı yayında: $title';
  }

  @override
  String youAreLive(String title) {
    return 'Canlı yayındasın: $title. Yayına dönmek için dokun.';
  }

  @override
  String get connecting => 'Yayına bağlanılıyor…';

  @override
  String get inBroadcast => 'Yayındasın · dönmek için dokun';

  @override
  String get micMutedByMod => 'Mikrofonunu yönetici kapattı';

  @override
  String get micOff => 'Mikrofonu kapat';

  @override
  String get micOn => 'Mikrofonu aç';

  @override
  String startsOn(String date) {
    return 'Bu yayın $date tarihinde başlayacak.';
  }

  @override
  String get ended => 'Bu yayın sona erdi.';

  @override
  String get notFound =>
      'Bu yayın bulunamadı. Grubun üyesi olman gerekiyor olabilir.';

  @override
  String get goBack => 'Geri dön';

  @override
  String get onStageNow =>
      'Sahneye alındın. Mikrofonunu açarak konuşabilirsin.';

  @override
  String get nowListener => 'Artık dinleyicisin.';

  @override
  String get leaveBroadcast => 'Yayından çık';

  @override
  String get leaveHostBody =>
      'Yayını herkes için bitirebilirsin. Yalnızca ayrılırsan yayın 2 dakika sonra kendiliğinden biter.';

  @override
  String get justLeave => 'Yalnızca ayrıl';

  @override
  String get endBroadcast => 'Yayını bitir';

  @override
  String get inviteToStage => 'Sahneye al';

  @override
  String get removeFromStage => 'Sahneden indir';

  @override
  String get muteMic => 'Mikrofonunu kapat';

  @override
  String get unmuteMic => 'Mikrofonunu aç';

  @override
  String get kick => 'Yayından çıkar';

  @override
  String kickBody(String name) {
    return '$name bu yayına bir daha giremez.';
  }

  @override
  String get cancelAction => 'Vazgeç';

  @override
  String get remove => 'Çıkar';

  @override
  String get raisedHands => 'El kaldıranlar';

  @override
  String get commentDeleted => 'Yorum silindi.';

  @override
  String get thanksForJoining =>
      'Yayın sona erdi. Katıldığın için teşekkürler.';

  @override
  String get youWereKicked => 'Bu yayından çıkarıldın.';

  @override
  String get connectFailedShort => 'Yayına bağlanılamadı.';

  @override
  String handsRaised(int count) {
    return '$count kişi el kaldırdı';
  }

  @override
  String get onStage => 'Sahnede';

  @override
  String listeners(int count) {
    return 'Dinleyiciler · $count';
  }

  @override
  String get noListeners => 'Henüz dinleyici yok.';

  @override
  String get minimize => 'Küçült, yayında kal';

  @override
  String peopleCount(int count) {
    return '$count kişi';
  }

  @override
  String get broadcastOptions => 'Yayın seçenekleri';

  @override
  String get endForAll => 'Yayını herkes için bitir';

  @override
  String get handRaised => 'Elini kaldırdın. Sunucu seni sahneye alabilir.';

  @override
  String get you => 'Sen';

  @override
  String get speaking => 'konuşuyor';

  @override
  String get micOffState => 'mikrofon kapalı';

  @override
  String get handUp => 'el kaldırdı';

  @override
  String get sendReaction => 'Tepki gönder';

  @override
  String get leave => 'Ayrıl';

  @override
  String get leaveStage => 'Sahneden in';

  @override
  String get reactions => 'Tepkiler';

  @override
  String get comments => 'Yorumlar';

  @override
  String get raiseHand => 'El kaldır';

  @override
  String get lowerHand => 'Elini indir';

  @override
  String get report => 'Şikayet et';

  @override
  String get deleteComment => 'Yorumu sil';

  @override
  String get firstComment => 'İlk yorumu sen yaz.';

  @override
  String get writeComment => 'Yorum yaz…';

  @override
  String get send => 'Gönder';

  @override
  String get connectFailed =>
      'Yayına bağlanılamadı. Bağlantını kontrol edip tekrar dene.';

  @override
  String get participant => 'Katılımcı';

  @override
  String get micNeedsManager =>
      'Mikrofonunu yalnızca yayın yöneticisi açabilir.';

  @override
  String get micFailed => 'Mikrofon açılamadı. Mikrofon iznini kontrol et.';

  @override
  String get connectionLost =>
      'Yayınla bağlantın koptu. Tekrar bağlanmak için dokun.';

  @override
  String get micAfterEncryption =>
      'Şifreli bağlantı kuruluyor; mikrofonun birazdan açılacak.';

  @override
  String get encrypting => 'Şifreli bağlantı kuruluyor…';

  @override
  String get verifying => 'Şifreleme doğrulanıyor…';

  @override
  String get liveSecure => 'Güvenli yayın';

  @override
  String get liveSecureDetail =>
      'Uçtan uca şifreli. Odadaki herkes aynı anahtarı kullanıyor; sesi sunucu dahil kimse dinleyemez.';

  @override
  String get liveCheckFailed =>
      'Şifreleme doğrulanamadı: odadaki herkes aynı anahtarı kullanmıyor. Yayından çıkıp yeniden gir.';

  @override
  String get liveUnconfirmed =>
      'Sahnedeki biri eski bir uygulama sürümü kullanıyor; sesi şifrelenemediği için çalınmıyor.';

  @override
  String get peerUnencrypted =>
      'Eski sürümdeki bir konuşmacının sesi şifresiz geliyor ve çalınmıyor. Uygulamasını güncellemesi gerekiyor.';

  @override
  String get e2ee => 'Uçtan uca şifreli';

  @override
  String get showSecurityCode => 'Güvenlik kodunu göster';

  @override
  String get codeMatchHint => 'Bu kod odadaki herkesin ekranında aynıdır.';

  @override
  String e2eeCode(String code) {
    return 'Uçtan uca şifreli. Güvenlik kodu $code';
  }

  @override
  String get liveOngoingTitle => 'Canlı yayındasın';

  @override
  String get liveOngoingText => 'Uçtan uca şifreli. Dönmek için dokun.';
}
