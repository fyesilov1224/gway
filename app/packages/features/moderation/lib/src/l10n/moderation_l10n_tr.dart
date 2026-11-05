// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'moderation_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class ModerationL10nTr extends ModerationL10n {
  ModerationL10nTr([String locale = 'tr']) : super(locale);

  @override
  String get ruleRateLimited =>
      'Bugün çok fazla şikayet gönderdin. Yarın tekrar deneyebilirsin.';

  @override
  String get ruleTargetInvalid => 'Bu içerik artık yok ya da göremiyorsun.';

  @override
  String get ruleSelf => 'Kendini ya da kendi içeriğini şikayet edemezsin.';

  @override
  String get ruleAppealNotAllowed => 'Bu yaptırıma artık itiraz edilemez.';

  @override
  String get ruleDuplicate => 'Bunu zaten bildirdin; inceleniyor.';

  @override
  String get deletedAccount => 'Silinmiş hesap';

  @override
  String get reasonSpam => 'Spam ya da yanıltıcı';

  @override
  String get reasonHarassment => 'Taciz ya da zorbalık';

  @override
  String get reasonHate => 'Nefret söylemi';

  @override
  String get reasonViolence => 'Şiddet ya da tehdit';

  @override
  String get reasonSexual => 'Cinsel içerik';

  @override
  String get reasonMisinformation => 'Yanlış bilgi';

  @override
  String get reasonOther => 'Diğer';

  @override
  String get sanctionWarning => 'Uyarı';

  @override
  String get sanctionMute => 'Susturma';

  @override
  String get sanctionKick => 'Gruptan çıkarma';

  @override
  String get sanctionBan => 'Ban';

  @override
  String get illegalViolence => 'Şiddet';

  @override
  String get illegalThreat => 'Tehdit';

  @override
  String get illegalInsult => 'Hakaret';

  @override
  String get illegalHate => 'Nefret söylemi';

  @override
  String get illegalSexual => 'Cinsel istismar';

  @override
  String get illegalFraud => 'Dolandırıcılık';

  @override
  String get illegalDrugs => 'Uyuşturucu';

  @override
  String get illegalTerror => 'Terör';

  @override
  String get illegalOther => 'Başka bir suç';

  @override
  String muteDays(int days) {
    return '$days gün susturma';
  }

  @override
  String banDays(int days) {
    return '$days gün ban';
  }

  @override
  String get permanentBan => 'Kalıcı ban';

  @override
  String get thresholdMajority => 'Salt çoğunluk';

  @override
  String get thresholdMajorityText => 'Oyların yarısından fazlası';

  @override
  String get thresholdTwoThirds => 'Üçte iki';

  @override
  String get thresholdTwoThirdsText => 'Oyların en az üçte ikisi';

  @override
  String get thresholdUnanimous => 'Oybirliği';

  @override
  String get thresholdUnanimousText => 'Oyların tamamı';

  @override
  String get targetPost => 'Gönderi';

  @override
  String get targetComment => 'Yorum';

  @override
  String get targetEvent => 'Organizasyon';

  @override
  String get targetLiveComment => 'Canlı yayın yorumu';

  @override
  String get targetMessage => 'Grup sohbeti mesajı';

  @override
  String get targetMember => 'Üye';

  @override
  String get appealPending => 'Karar bekliyor';

  @override
  String get appealUpheld => 'Yaptırım sürüyor';

  @override
  String get appealOverturned => 'Yaptırım kaldırıldı';

  @override
  String get banApplied => 'Ban uygulandı.';

  @override
  String get banAppliedSuspended =>
      'Ban uygulandı. Kişinin hesabı platform incelemesine kadar askıya alındı.';

  @override
  String get caseOpened => 'Dosya açıldı. Kurul 72 saat içinde oy verecek.';

  @override
  String get openCaseTitle => 'Disiplin dosyası aç';

  @override
  String caseAboutNow(String name) {
    return '$name hakkında. Ban kurul oylaması olmadan hemen uygulanır.';
  }

  @override
  String caseAboutVote(String name) {
    return '$name hakkında. Önerdiğin yaptırımı disiplin kurulu 72 saat içinde oylar.';
  }

  @override
  String get proposedSanction => 'Önerilen yaptırım';

  @override
  String get duration => 'Süre';

  @override
  String get permanent => 'Kalıcı';

  @override
  String get permanentLower => 'kalıcı';

  @override
  String days(int days) {
    return '$days gün';
  }

  @override
  String get applyNow => 'Oylamasız, hemen uygula';

  @override
  String get applyNowHint =>
      'Kurulun kararını beklemeden banlar. Kişi 7 gün içinde itiraz edebilir.';

  @override
  String get illegalActivity => 'Yasa dışı faaliyet';

  @override
  String get illegalHintNow =>
      'Ban uygulanınca dosya platform ekibine gider ve hesap incelemeye kadar askıya alınır. Bu işaret sonradan değişmez.';

  @override
  String get illegalHintVote =>
      'Kurul onaylarsa dosya platform ekibine gider ve hesap incelemeye kadar askıya alınır. Bu işaret sonradan değişmez.';

  @override
  String get reason => 'Gerekçe';

  @override
  String get reasonHintNow =>
      'Ne oldu? Kişi ve itirazı inceleyen bu metni görür.';

  @override
  String get reasonHintVote => 'Ne oldu? Kurul bu metne bakarak oy verecek.';

  @override
  String get reasonMin10 => 'Gerekçe en az 10 karakter olmalı.';

  @override
  String get muteNow => 'Hemen sustur (24 saat)';

  @override
  String get muteNowHint =>
      'Kurul karar verene kadar yorum yazamaz, canlı yayında konuşamaz.';

  @override
  String get ban => 'Banla';

  @override
  String get openCase => 'Dosyayı aç';

  @override
  String leftDays(int days) {
    return '$days gün';
  }

  @override
  String leftDaysHours(int days, int hours) {
    return '$days gün $hours saat';
  }

  @override
  String leftHours(int hours) {
    return '$hours saat';
  }

  @override
  String get leftFewMinutes => 'birkaç dakika';

  @override
  String minChars(int min) {
    return 'En az $min karakter yaz.';
  }

  @override
  String get cancel => 'Vazgeç';

  @override
  String get threshold => 'Kurul karar eşiği';

  @override
  String thresholdChanged(String threshold) {
    return 'Karar eşiği \"$threshold\" oldu. Yeni dosyalarda geçerli.';
  }

  @override
  String moderationOf(String group) {
    return 'Moderasyon · $group';
  }

  @override
  String get reports => 'Şikayetler';

  @override
  String reportsCount(int count) {
    return 'Şikayetler ($count)';
  }

  @override
  String get cases => 'Dosyalar';

  @override
  String casesCount(int count) {
    return 'Dosyalar ($count)';
  }

  @override
  String get sanctions => 'Yaptırımlar';

  @override
  String sanctionsCount(int count) {
    return 'Yaptırımlar ($count)';
  }

  @override
  String get moderationTeamOnly =>
      'Bu grubun moderasyonunu yalnızca grup sahibi ve moderasyon ekibi görür.';

  @override
  String get goBack => 'Geri dön';

  @override
  String get noReports =>
      'Açık şikayet yok. Üyelerin şikayetleri burada toplanır.';

  @override
  String get refresh => 'Yenile';

  @override
  String get removeContent => 'İçeriği kaldır';

  @override
  String get remove => 'Kaldır';

  @override
  String get contentRemoved => 'İçerik kaldırıldı.';

  @override
  String reportCount(int count) {
    return '$count şikayet';
  }

  @override
  String get view => 'Görüntüle';

  @override
  String get reportDismissed => 'Şikayet reddedildi.';

  @override
  String get dismiss => 'Reddet';

  @override
  String get openCaseShort => 'Dosya aç';

  @override
  String get rankOnlyDismiss =>
      'Bu kişinin rütbesi seninkinden düşük olmadığı için yalnızca reddedebilirsin.';

  @override
  String get noCases =>
      'Henüz disiplin dosyası yok. Dosyalar bir şikayetten ya da üyeler sayfasından açılır.';

  @override
  String get voteApproved =>
      'Oyun kaydedildi. Kurul yaptırımı onayladı; yaptırım uygulandı.';

  @override
  String get voteRejected => 'Oyun kaydedildi. Kurul yaptırımı reddetti.';

  @override
  String get voteSaved =>
      'Oyun kaydedildi. Karar çıkana kadar değiştirebilirsin.';

  @override
  String get statusVoting => 'Oylamada';

  @override
  String get statusApproved => 'Onaylandı';

  @override
  String get statusRejected => 'Reddedildi';

  @override
  String proposed(String sanction) {
    return 'Önerilen: $sanction';
  }

  @override
  String get directBan => 'Oylamasız ban';

  @override
  String illegalLabel(String category) {
    return 'Yasa dışı faaliyet: $category';
  }

  @override
  String tally(int approvals, int rejections, int voters) {
    return '$approvals onay · $rejections ret · $voters oy hakkı';
  }

  @override
  String votingEndsIn(String time) {
    return 'Oylama $time sonra biter';
  }

  @override
  String bannedBy(String name) {
    return 'Banlayan: $name';
  }

  @override
  String openedBy(String name) {
    return 'Dosyayı açan: $name';
  }

  @override
  String get approve => 'Onayla';

  @override
  String get reject => 'Reddet';

  @override
  String get noSanctions =>
      'Henüz yaptırım yok. Kurulun onayladığı yaptırımlar ve itirazlar burada görünür.';

  @override
  String get liftSanction => 'Yaptırımı kaldır';

  @override
  String get keepSanction => 'Yaptırım sürsün';

  @override
  String get noteToPerson => 'Kişiye notun (isteğe bağlı)';

  @override
  String get liftedNotified => 'Yaptırım kaldırıldı; kişiye bildirildi.';

  @override
  String get appealRejectedNotified => 'İtiraz reddedildi; kişiye bildirildi.';

  @override
  String get lifted => 'Kaldırıldı';

  @override
  String get interimMute => 'Acil susturma';

  @override
  String get running => 'Sürüyor';

  @override
  String get applied => 'Uygulandı';

  @override
  String get interimUntilDecision => 'Acil susturma · kurul kararına kadar';

  @override
  String until(String date) {
    return '$date tarihine kadar';
  }

  @override
  String appealLine(String status) {
    return 'İtiraz · $status';
  }

  @override
  String noteLine(String note) {
    return 'Not: $note';
  }

  @override
  String get ownerParty =>
      'Sahip bu dosyada taraf olduğu için itirazı platform ekibi inceliyor.';

  @override
  String get keep => 'Sürsün';

  @override
  String casesAwaitingVote(int count) {
    return '$count dosya oyunu bekliyor';
  }

  @override
  String appealsCount(int count) {
    return '$count itiraz';
  }

  @override
  String get moderation => 'Moderasyon';

  @override
  String get noWork => 'Bekleyen iş yok';

  @override
  String get mySanctions => 'Yaptırımlarım';

  @override
  String get noMySanctions =>
      'Hiçbir grupta yaptırımın yok. Topluluk kurallarına uyduğun için teşekkürler.';

  @override
  String get interimEnded => 'Acil susturma sona erdi';

  @override
  String interimLatest(String date) {
    return 'Acil susturma · kurul kararına kadar, en geç $date';
  }

  @override
  String untilCap(String date) {
    return '$date tarihine kadar';
  }

  @override
  String get ended => 'Sona erdi';

  @override
  String get appeal => 'İtiraz et';

  @override
  String get appealHint => 'Neden haksız olduğunu düşünüyorsun?';

  @override
  String get send => 'Gönder';

  @override
  String get appealSent =>
      'İtirazın gönderildi. Karar verilince bildirim alacaksın.';

  @override
  String reasonLine(String reason) {
    return 'Gerekçe: $reason';
  }

  @override
  String yourAppealLine(String status) {
    return 'İtirazın · $status';
  }

  @override
  String get appealOnce => 'Bu karara 7 gün içinde bir kez itiraz edebilirsin.';

  @override
  String get reportPost => 'Gönderiyi şikayet et';

  @override
  String get reportComment => 'Yorumu şikayet et';

  @override
  String get reportEvent => 'Organizasyonu şikayet et';

  @override
  String get reportMessage => 'Mesajı şikayet et';

  @override
  String get reportMatchProfile => 'Eşleşme profilini şikayet et';

  @override
  String get reportPhoto => 'Fotoğrafı şikayet et';

  @override
  String get reportUser => 'Kullanıcıyı şikayet et';

  @override
  String get reportReceived =>
      'Şikayetin alındı. İnceleyip gerekeni yapacağız; kimliğin şikayet edilen kişiye gösterilmez.';

  @override
  String get whyReport => 'Neden şikayet ediyorsun?';

  @override
  String get detailsOptional => 'Açıklama (isteğe bağlı)';

  @override
  String get detailsHint => 'Ne olduğunu kısaca anlat.';

  @override
  String get report => 'Şikayet et';
}
