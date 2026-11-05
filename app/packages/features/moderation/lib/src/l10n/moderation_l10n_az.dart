// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'moderation_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Azerbaijani (`az`).
class ModerationL10nAz extends ModerationL10n {
  ModerationL10nAz([String locale = 'az']) : super(locale);

  @override
  String get ruleRateLimited =>
      'Bu gün çox şikayət göndərdin. Sabah yenidən cəhd edə bilərsən.';

  @override
  String get ruleTargetInvalid =>
      'Bu məzmun artıq yoxdur və ya onu görə bilmirsən.';

  @override
  String get ruleSelf => 'Özündən və ya öz məzmunundan şikayət edə bilməzsən.';

  @override
  String get ruleAppealNotAllowed => 'Bu sanksiyaya artıq etiraz edilə bilməz.';

  @override
  String get ruleDuplicate => 'Bunu artıq bildirmisən; baxılır.';

  @override
  String get deletedAccount => 'Silinmiş hesab';

  @override
  String get reasonSpam => 'Spam və ya yanıltıcı';

  @override
  String get reasonHarassment => 'Təqib və ya zorbalıq';

  @override
  String get reasonHate => 'Nifrət nitqi';

  @override
  String get reasonViolence => 'Zorakılıq və ya təhdid';

  @override
  String get reasonSexual => 'Cinsi məzmun';

  @override
  String get reasonMisinformation => 'Yanlış məlumat';

  @override
  String get reasonOther => 'Digər';

  @override
  String get sanctionWarning => 'Xəbərdarlıq';

  @override
  String get sanctionMute => 'Səssizləşdirmə';

  @override
  String get sanctionKick => 'Qrupdan çıxarma';

  @override
  String get sanctionBan => 'Ban';

  @override
  String get illegalViolence => 'Zorakılıq';

  @override
  String get illegalThreat => 'Təhdid';

  @override
  String get illegalInsult => 'Təhqir';

  @override
  String get illegalHate => 'Nifrət nitqi';

  @override
  String get illegalSexual => 'Cinsi istismar';

  @override
  String get illegalFraud => 'Fırıldaqçılıq';

  @override
  String get illegalDrugs => 'Narkotik';

  @override
  String get illegalTerror => 'Terror';

  @override
  String get illegalOther => 'Başqa cinayət';

  @override
  String muteDays(int days) {
    return '$days günlük səssizləşdirmə';
  }

  @override
  String banDays(int days) {
    return '$days günlük ban';
  }

  @override
  String get permanentBan => 'Daimi ban';

  @override
  String get thresholdMajority => 'Sadə çoxluq';

  @override
  String get thresholdMajorityText => 'Səslərin yarısından çoxu';

  @override
  String get thresholdTwoThirds => 'Üçdə iki';

  @override
  String get thresholdTwoThirdsText => 'Səslərin ən azı üçdə ikisi';

  @override
  String get thresholdUnanimous => 'Yekdillik';

  @override
  String get thresholdUnanimousText => 'Bütün səslər';

  @override
  String get targetPost => 'Paylaşım';

  @override
  String get targetComment => 'Şərh';

  @override
  String get targetEvent => 'Tədbir';

  @override
  String get targetLiveComment => 'Canlı yayım şərhi';

  @override
  String get targetMessage => 'Qrup söhbəti mesajı';

  @override
  String get targetMember => 'Üzv';

  @override
  String get appealPending => 'Qərar gözləyir';

  @override
  String get appealUpheld => 'Sanksiya davam edir';

  @override
  String get appealOverturned => 'Sanksiya götürüldü';

  @override
  String get banApplied => 'Ban tətbiq edildi.';

  @override
  String get banAppliedSuspended =>
      'Ban tətbiq edildi. Şəxsin hesabı platforma baxana qədər dayandırıldı.';

  @override
  String get caseOpened => 'Dosyə açıldı. Şura 72 saat ərzində səs verəcək.';

  @override
  String get openCaseTitle => 'İntizam dosyəsi aç';

  @override
  String caseAboutNow(String name) {
    return '$name haqqında. Ban şura səsverməsi olmadan dərhal tətbiq olunur.';
  }

  @override
  String caseAboutVote(String name) {
    return '$name haqqında. Təklif etdiyin sanksiyanı intizam şurası 72 saat ərzində səsə qoyur.';
  }

  @override
  String get proposedSanction => 'Təklif olunan sanksiya';

  @override
  String get duration => 'Müddət';

  @override
  String get permanent => 'Daimi';

  @override
  String get permanentLower => 'daimi';

  @override
  String days(int days) {
    return '$days gün';
  }

  @override
  String get applyNow => 'Səsverməsiz, dərhal tətbiq et';

  @override
  String get applyNowHint =>
      'Şuranın qərarını gözləmədən banlayır. Şəxs 7 gün ərzində etiraz edə bilər.';

  @override
  String get illegalActivity => 'Qanunsuz fəaliyyət';

  @override
  String get illegalHintNow =>
      'Ban tətbiq olunanda dosyə platforma komandasına gedir və hesab baxılana qədər dayandırılır. Bu işarə sonradan dəyişmir.';

  @override
  String get illegalHintVote =>
      'Şura təsdiqləsə, dosyə platforma komandasına gedir və hesab baxılana qədər dayandırılır. Bu işarə sonradan dəyişmir.';

  @override
  String get reason => 'Səbəb';

  @override
  String get reasonHintNow =>
      'Nə oldu? Şəxs və etirazı araşdıran bu mətni görür.';

  @override
  String get reasonHintVote => 'Nə oldu? Şura bu mətnə baxaraq səs verəcək.';

  @override
  String get reasonMin10 => 'Səbəb ən azı 10 simvol olmalıdır.';

  @override
  String get muteNow => 'Dərhal səssizləşdir (24 saat)';

  @override
  String get muteNowHint =>
      'Şura qərar verənə qədər şərh yaza, canlı yayımda danışa bilməz.';

  @override
  String get ban => 'Banla';

  @override
  String get openCase => 'Dosyəni aç';

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
  String get leftFewMinutes => 'bir neçə dəqiqə';

  @override
  String minChars(int min) {
    return 'Ən azı $min simvol yaz.';
  }

  @override
  String get cancel => 'İmtina et';

  @override
  String get threshold => 'Şuranın qərar həddi';

  @override
  String thresholdChanged(String threshold) {
    return 'Qərar həddi \"$threshold\" oldu. Yeni dosyələrdə keçərlidir.';
  }

  @override
  String moderationOf(String group) {
    return 'Moderasiya · $group';
  }

  @override
  String get reports => 'Şikayətlər';

  @override
  String reportsCount(int count) {
    return 'Şikayətlər ($count)';
  }

  @override
  String get cases => 'Dosyələr';

  @override
  String casesCount(int count) {
    return 'Dosyələr ($count)';
  }

  @override
  String get sanctions => 'Sanksiyalar';

  @override
  String sanctionsCount(int count) {
    return 'Sanksiyalar ($count)';
  }

  @override
  String get moderationTeamOnly =>
      'Bu qrupun moderasiyasını yalnız qrup sahibi və moderasiya komandası görür.';

  @override
  String get goBack => 'Geri qayıt';

  @override
  String get noReports =>
      'Açıq şikayət yoxdur. Üzvlərin şikayətləri burada toplanır.';

  @override
  String get refresh => 'Yenilə';

  @override
  String get removeContent => 'Məzmunu götür';

  @override
  String get remove => 'Götür';

  @override
  String get contentRemoved => 'Məzmun götürüldü.';

  @override
  String reportCount(int count) {
    return '$count şikayət';
  }

  @override
  String get view => 'Bax';

  @override
  String get reportDismissed => 'Şikayət rədd edildi.';

  @override
  String get dismiss => 'Rədd et';

  @override
  String get openCaseShort => 'Dosyə aç';

  @override
  String get rankOnlyDismiss =>
      'Bu şəxsin rütbəsi səninkindən aşağı olmadığı üçün yalnız rədd edə bilərsən.';

  @override
  String get noCases =>
      'Hələ intizam dosyəsi yoxdur. Dosyələr şikayətdən və ya üzvlər səhifəsindən açılır.';

  @override
  String get voteApproved =>
      'Səsin qeydə alındı. Şura sanksiyanı təsdiqlədi; sanksiya tətbiq edildi.';

  @override
  String get voteRejected => 'Səsin qeydə alındı. Şura sanksiyanı rədd etdi.';

  @override
  String get voteSaved =>
      'Səsin qeydə alındı. Qərar çıxana qədər dəyişə bilərsən.';

  @override
  String get statusVoting => 'Səsvermədə';

  @override
  String get statusApproved => 'Təsdiqləndi';

  @override
  String get statusRejected => 'Rədd edildi';

  @override
  String proposed(String sanction) {
    return 'Təklif: $sanction';
  }

  @override
  String get directBan => 'Səsverməsiz ban';

  @override
  String illegalLabel(String category) {
    return 'Qanunsuz fəaliyyət: $category';
  }

  @override
  String tally(int approvals, int rejections, int voters) {
    return '$approvals təsdiq · $rejections rədd · $voters səs haqqı';
  }

  @override
  String votingEndsIn(String time) {
    return 'Səsvermə $time sonra bitir';
  }

  @override
  String bannedBy(String name) {
    return 'Banlayan: $name';
  }

  @override
  String openedBy(String name) {
    return 'Dosyəni açan: $name';
  }

  @override
  String get approve => 'Təsdiqlə';

  @override
  String get reject => 'Rədd et';

  @override
  String get noSanctions =>
      'Hələ sanksiya yoxdur. Şuranın təsdiqlədiyi sanksiyalar və etirazlar burada görünür.';

  @override
  String get liftSanction => 'Sanksiyanı götür';

  @override
  String get keepSanction => 'Sanksiya davam etsin';

  @override
  String get noteToPerson => 'Şəxsə qeydin (istəyə bağlı)';

  @override
  String get liftedNotified => 'Sanksiya götürüldü; şəxsə bildirildi.';

  @override
  String get appealRejectedNotified => 'Etiraz rədd edildi; şəxsə bildirildi.';

  @override
  String get lifted => 'Götürüldü';

  @override
  String get interimMute => 'Təcili səssizləşdirmə';

  @override
  String get running => 'Davam edir';

  @override
  String get applied => 'Tətbiq edildi';

  @override
  String get interimUntilDecision =>
      'Təcili səssizləşdirmə · şura qərarına qədər';

  @override
  String until(String date) {
    return '$date tarixinədək';
  }

  @override
  String appealLine(String status) {
    return 'Etiraz · $status';
  }

  @override
  String noteLine(String note) {
    return 'Qeyd: $note';
  }

  @override
  String get ownerParty =>
      'Sahib bu dosyədə tərəf olduğu üçün etiraza platforma komandası baxır.';

  @override
  String get keep => 'Davam etsin';

  @override
  String casesAwaitingVote(int count) {
    return '$count dosyə səsini gözləyir';
  }

  @override
  String appealsCount(int count) {
    return '$count etiraz';
  }

  @override
  String get moderation => 'Moderasiya';

  @override
  String get noWork => 'Gözləyən iş yoxdur';

  @override
  String get mySanctions => 'Sanksiyalarım';

  @override
  String get noMySanctions =>
      'Heç bir qrupda sanksiyan yoxdur. İcma qaydalarına əməl etdiyin üçün təşəkkürlər.';

  @override
  String get interimEnded => 'Təcili səssizləşdirmə bitdi';

  @override
  String interimLatest(String date) {
    return 'Təcili səssizləşdirmə · şura qərarına qədər, ən gec $date';
  }

  @override
  String untilCap(String date) {
    return '$date tarixinədək';
  }

  @override
  String get ended => 'Bitdi';

  @override
  String get appeal => 'Etiraz et';

  @override
  String get appealHint => 'Niyə haqsız olduğunu düşünürsən?';

  @override
  String get send => 'Göndər';

  @override
  String get appealSent =>
      'Etirazın göndərildi. Qərar veriləndə bildiriş alacaqsan.';

  @override
  String reasonLine(String reason) {
    return 'Səbəb: $reason';
  }

  @override
  String yourAppealLine(String status) {
    return 'Etirazın · $status';
  }

  @override
  String get appealOnce =>
      'Bu qərara 7 gün ərzində bir dəfə etiraz edə bilərsən.';

  @override
  String get reportPost => 'Paylaşımdan şikayət et';

  @override
  String get reportComment => 'Şərhdən şikayət et';

  @override
  String get reportEvent => 'Tədbirdən şikayət et';

  @override
  String get reportMessage => 'Mesajdan şikayət et';

  @override
  String get reportMatchProfile => 'Uyğunluq profilindən şikayət et';

  @override
  String get reportPhoto => 'Şəkildən şikayət et';

  @override
  String get reportUser => 'İstifadəçidən şikayət et';

  @override
  String get reportReceived =>
      'Şikayətin alındı. Baxıb lazım olanı edəcəyik; kimliyin şikayət edilən şəxsə göstərilmir.';

  @override
  String get whyReport => 'Niyə şikayət edirsən?';

  @override
  String get detailsOptional => 'İzah (istəyə bağlı)';

  @override
  String get detailsHint => 'Nə olduğunu qısaca danış.';

  @override
  String get report => 'Şikayət et';
}
