// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'notifications_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Azerbaijani (`az`).
class NotificationsL10nAz extends NotificationsL10n {
  NotificationsL10nAz([String locale = 'az']) : super(locale);

  @override
  String get actLike => 'paylaşımını bəyəndi.';

  @override
  String actComment(String text) {
    return 'şərh yazdı: $text';
  }

  @override
  String actReply(String text) {
    return 'şərhinə cavab verdi: $text';
  }

  @override
  String actCommentLike(String text) {
    return 'şərhini bəyəndi: $text';
  }

  @override
  String get actMentionPost => 'bir paylaşımda səndən bəhs etdi.';

  @override
  String actMentionComment(String text) {
    return 'bir şərhdə səndən bəhs etdi: $text';
  }

  @override
  String get actFollow => 'səni izləməyə başladı.';

  @override
  String get actFollowRequest => 'səni izləmək istəyir.';

  @override
  String get actFollowAccepted => 'izləmə istəyini qəbul etdi.';

  @override
  String actLiveScheduled(String title) {
    return 'canlı yayım planladı: $title';
  }

  @override
  String actLiveScheduledAt(String date, String title) {
    return '$date üçün canlı yayım planladı: $title';
  }

  @override
  String actLiveStarted(String title) {
    return 'canlı yayına başladı: $title';
  }

  @override
  String actEventPromoted(String title) {
    return '\"$title\" üçün yer açıldı, artıq qatılırsan.';
  }

  @override
  String actEventUpdated(String title) {
    return '\"$title\" tədbirinin vaxtını və ya yerini dəyişdi.';
  }

  @override
  String actEventCanceled(String title) {
    return '\"$title\" tədbirini ləğv etdi.';
  }

  @override
  String actReminderTomorrow(String title) {
    return '\"$title\" sabah başlayır. Gəlirsən? Təsdiqlə.';
  }

  @override
  String actReminderHour(String title) {
    return '\"$title\" 1 saat ərzində başlayır.';
  }

  @override
  String actCaseVote(String group) {
    return '$group qrupunda intizam işi açdı; səsini gözləyir.';
  }

  @override
  String get actMuted =>
      'qrupunda səsin bağlandı. Təfərrüat və etiraz üçün toxun.';

  @override
  String get actKicked =>
      'qrupundan çıxarıldın. Təfərrüat və etiraz üçün toxun.';

  @override
  String get actBanned =>
      'qrupundan uzaqlaşdırıldın. Təfərrüat və etiraz üçün toxun.';

  @override
  String get actWarned =>
      'qrupu sənə xəbərdarlıq etdi. Təfərrüat və etiraz üçün toxun.';

  @override
  String actAppealSubmitted(String group) {
    return '$group qrupundakı sanksiyaya etiraz etdi.';
  }

  @override
  String get actAppealDecided => 'qrupu etirazını qərara bağladı.';

  @override
  String actEventApproved(String title) {
    return '\"$title\" üçün qatılma istəyini təsdiqlədi.';
  }

  @override
  String actEventDeclined(String title) {
    return '\"$title\" üçün qatılma istəyini qəbul edə bilmədi.';
  }

  @override
  String actEventReview(String title) {
    return '\"$title\" necə idi? Qiymətləndir, xatirələrini paylaş.';
  }

  @override
  String actGoalCompleted(String title) {
    return '\"$title\" hədəfini tamamladın! Nişanın profilindədir.';
  }

  @override
  String get actTeammateRequest => 'səninlə komanda yoldaşı olmaq istəyir.';

  @override
  String get actTeammateAccepted => 'komanda yoldaşlığı istəyini qəbul etdi.';

  @override
  String get actMatchCreated => 'Kim olduğunu Uyğunluqlarımda gör.';

  @override
  String get actSuperLiked => 'səni super bəyəndi! Destəndə ilk o görünür.';

  @override
  String actWelcomeRequested(String title) {
    return '\"$title\" tədbirinə ilk dəfə gəlir və qarşılanmaq istəyir.';
  }

  @override
  String actWelcomeMatched(String title) {
    return '\"$title\" tədbirində səni qarşılayacaq. Görüş qeydinə bax.';
  }

  @override
  String actWelcomeReleased(String title) {
    return '\"$title\" üçün qarşılamağı buraxdı; yeni qarşılayıcı axtarılır.';
  }

  @override
  String actWelcomeWithdrawn(String title) {
    return '\"$title\" üçün qarşılanma istəyini geri götürdü.';
  }

  @override
  String get actLeagueResult =>
      'keçən ayın liqasında ilk üçə düşdü! Sıralamanı qrup səhifəsində gör.';

  @override
  String actWelcomeThanked(String title) {
    return '\"$title\" tədbirində onu qarşıladığın üçün təşəkkür etdi.';
  }

  @override
  String get actTableInvite => 'bu axşam kiçik masa qurdu və səni də çağırır.';

  @override
  String get actTableReady =>
      'masaya qoşuldu; masa quruldu. Yeri və saatı söhbətdə danışın.';

  @override
  String actVenueRevealed(String title) {
    return '\"$title\": hara gedəcəyini görmək üçün toxun.';
  }

  @override
  String actHandshake(String title) {
    return '\"$title\" tədbirində səninlə əl sıxışdı.';
  }

  @override
  String get actCallMissed => 'sənə zəng etdi, aça bilmədin.';

  @override
  String get actCallGranted =>
      'yetkin açıldı. Uyğunlaşdığın insanlara söhbətdən zəng edə bilərsən.';

  @override
  String get actCallDeclined =>
      'talebin hələlik qəbul edilmədi. Təfərrüat üçün toxun.';

  @override
  String get actCallRevoked => 'yetkin bağlandı. Təfərrüat üçün toxun.';

  @override
  String actSeriesLimit(String title) {
    return '\"$title\" üçün növbəti tarix açılmadı: qrupun bu ayki tədbir haqqı doldu. Yeni ay başlayanda və ya paket yüksələndə açılır.';
  }

  @override
  String get leadNewMatch => 'Yeni uyğunluğun var!';

  @override
  String get leadSeries => 'Təkrarlanan tədbir';

  @override
  String get leadVenue => 'Sürpriz məkan açıqlandı';

  @override
  String get leadCalls => 'Səsli zəng';

  @override
  String get periodToday => 'Bu gün';

  @override
  String get periodWeek => 'Bu həftə';

  @override
  String get periodEarlier => 'Daha əvvəl';

  @override
  String get agoNow => 'indi';

  @override
  String agoMinutes(int n) {
    return '$n dəq';
  }

  @override
  String agoHours(int n) {
    return '$n saat';
  }

  @override
  String agoDays(int n) {
    return '$n gün';
  }

  @override
  String get join => 'Qoşul';

  @override
  String get see => 'Bax';

  @override
  String get prefsTitle => 'Bildiriş seçimləri';

  @override
  String get messages => 'Mesajlar';

  @override
  String get directMessages => 'Şəxsi mesajlar';

  @override
  String get directMessagesHint =>
      'Birəbir söhbətlərə mesaj gələndə, tətbiq bağlı olanda da səsli';

  @override
  String get groupMessages => 'Qrup mesajları';

  @override
  String get groupMessagesHint =>
      'Qrup söhbətlərinə və bu axşamın masasına mesaj gələndə, tətbiq bağlı olanda da səsli';

  @override
  String get events => 'Tədbirlər';

  @override
  String get remindDay => '1 gün əvvəl xatırlat';

  @override
  String get remindDayHint => 'Qatıldığın tədbir sabah başlayırsa';

  @override
  String get remindHour => '1 saat əvvəl xatırlat';

  @override
  String get remindHourHint => 'Qatıldığın tədbir 1 saat ərzində başlayırsa';

  @override
  String get changes => 'Dəyişikliklər və ləğvlər';

  @override
  String get changesHint =>
      'Vaxt və ya yer dəyişəndə, yaxud tədbir ləğv ediləndə';

  @override
  String get reviewRequests => 'Qiymətləndirmə istəkləri';

  @override
  String get reviewRequestsHint =>
      'Qatıldığın tədbir bitəndə \"Necə idi?\" soruş';

  @override
  String get live => 'Canlı yayımlar';

  @override
  String get liveAlerts => 'Planlanan və başlayan yayımlar';

  @override
  String get liveAlertsHint =>
      'Qrupunda yayım planlananda və başlayanda, tətbiq açıqdırsa səsli xəbərdarlıqla';

  @override
  String get matching => 'Uyğunlaşma';

  @override
  String get newMatches => 'Yeni uyğunluqlar';

  @override
  String get newMatchesHint => 'Biri ilə qarşılıqlı bəyənəndə';

  @override
  String get alwaysSent =>
      'Qatılma istəyinin nəticəsi, gözləmə siyahısından yüksəlməyin və qrup sanksiyaları səni birbaşa maraqlandırdığı üçün həmişə bildirilir.';

  @override
  String get notifications => 'Bildirişlər';

  @override
  String get empty => 'Bəyənmələr, şərhlər və yeni izləyicilər burada görünür.';

  @override
  String get refresh => 'Yenilə';

  @override
  String get followRequests => 'İzləmə istəkləri';

  @override
  String andOthers(String name, int count) {
    return '$name və daha $count nəfər';
  }

  @override
  String get delete => 'Sil';

  @override
  String get actChessChallenge => 'səni şahmat oynamağa dəvət etdi.';

  @override
  String actChessTeamInvite(String group) {
    return '$group qrupu adına qrupunu şahmat komanda matçına dəvət etdi.';
  }

  @override
  String actChessTeamAccepted(String group) {
    return '$group qrupu adına komanda matçı dəvətini qəbul etdi. Oyunçularını düz.';
  }

  @override
  String actChessTeamDeclined(String group) {
    return '$group qrupu adına komanda matçı dəvətini rədd etdi.';
  }

  @override
  String actChessTeamStart(String group) {
    return '$group qrupuna qarşı komanda matçı başladı. Taxtana keç!';
  }

  @override
  String get leadTeamMatch => 'Komanda matçı';

  @override
  String get actChessArenaStart =>
      'Qoşulduğun turnir başladı. Açan kimi dərhal cütləşəcəksən.';

  @override
  String get actChessArenaMedal =>
      'Turniri ilk üçlükdə bitirdin! Medalın şahmat profilindədir.';

  @override
  String get leadArena => 'Şahmat turniri';
}
