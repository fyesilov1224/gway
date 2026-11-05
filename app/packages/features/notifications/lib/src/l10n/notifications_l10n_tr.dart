// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'notifications_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class NotificationsL10nTr extends NotificationsL10n {
  NotificationsL10nTr([String locale = 'tr']) : super(locale);

  @override
  String get actLike => 'gönderini beğendi.';

  @override
  String actComment(String text) {
    return 'yorum yaptı: $text';
  }

  @override
  String actReply(String text) {
    return 'yorumuna yanıt verdi: $text';
  }

  @override
  String actCommentLike(String text) {
    return 'yorumunu beğendi: $text';
  }

  @override
  String get actMentionPost => 'bir gönderide senden bahsetti.';

  @override
  String actMentionComment(String text) {
    return 'bir yorumda senden bahsetti: $text';
  }

  @override
  String get actFollow => 'seni takip etmeye başladı.';

  @override
  String get actFollowRequest => 'seni takip etmek istiyor.';

  @override
  String get actFollowAccepted => 'takip isteğini kabul etti.';

  @override
  String actLiveScheduled(String title) {
    return 'canlı yayın planladı: $title';
  }

  @override
  String actLiveScheduledAt(String date, String title) {
    return '$date için canlı yayın planladı: $title';
  }

  @override
  String actLiveStarted(String title) {
    return 'canlı yayına başladı: $title';
  }

  @override
  String actEventPromoted(String title) {
    return '\"$title\" için yer açıldı, artık katılıyorsun.';
  }

  @override
  String actEventUpdated(String title) {
    return '\"$title\" organizasyonunun zamanını ya da yerini değiştirdi.';
  }

  @override
  String actEventCanceled(String title) {
    return '\"$title\" organizasyonunu iptal etti.';
  }

  @override
  String actReminderTomorrow(String title) {
    return '\"$title\" yarın başlıyor. Geliyor musun? Teyit et.';
  }

  @override
  String actReminderHour(String title) {
    return '\"$title\" 1 saat içinde başlıyor.';
  }

  @override
  String actCaseVote(String group) {
    return '$group grubunda bir disiplin dosyası açtı; oyunu bekliyor.';
  }

  @override
  String get actMuted =>
      'grubunda susturuldun. Ayrıntılar ve itiraz için dokun.';

  @override
  String get actKicked =>
      'grubundan çıkarıldın. Ayrıntılar ve itiraz için dokun.';

  @override
  String get actBanned =>
      'grubundan uzaklaştırıldın. Ayrıntılar ve itiraz için dokun.';

  @override
  String get actWarned =>
      'grubu sana uyarı verdi. Ayrıntılar ve itiraz için dokun.';

  @override
  String actAppealSubmitted(String group) {
    return '$group grubundaki yaptırıma itiraz etti.';
  }

  @override
  String get actAppealDecided => 'grubu itirazını karara bağladı.';

  @override
  String actEventApproved(String title) {
    return '\"$title\" için katılım isteğini onayladı.';
  }

  @override
  String actEventDeclined(String title) {
    return '\"$title\" için katılım isteğini kabul edemedi.';
  }

  @override
  String actEventReview(String title) {
    return '\"$title\" nasıldı? Değerlendir, anılarını paylaş.';
  }

  @override
  String actGoalCompleted(String title) {
    return '\"$title\" hedefini tamamladın! Rozetin profilinde.';
  }

  @override
  String get actTeammateRequest => 'seninle ekip arkadaşı olmak istiyor.';

  @override
  String get actTeammateAccepted => 'ekip arkadaşlığı isteğini kabul etti.';

  @override
  String get actMatchCreated => 'Kim olduğunu Eşleşmelerim\'de gör.';

  @override
  String get actSuperLiked => 'seni süper beğendi! Destende ilk o görünüyor.';

  @override
  String actWelcomeRequested(String title) {
    return '\"$title\" organizasyonuna ilk kez geliyor ve karşılanmak istiyor.';
  }

  @override
  String actWelcomeMatched(String title) {
    return '\"$title\" organizasyonunda seni karşılayacak. Buluşma notunu gör.';
  }

  @override
  String actWelcomeReleased(String title) {
    return '\"$title\" için karşılamayı bıraktı; yeni bir karşılayıcı aranıyor.';
  }

  @override
  String actWelcomeWithdrawn(String title) {
    return '\"$title\" için karşılama isteğini geri çekti.';
  }

  @override
  String get actLeagueResult =>
      'geçen ayın liginde ilk üçe girdi! Sıralamayı ve derecesini grup sayfasında gör.';

  @override
  String actWelcomeThanked(String title) {
    return '\"$title\" organizasyonunda onu karşıladığın için teşekkür etti.';
  }

  @override
  String get actTableInvite =>
      'bu akşam küçük bir masa kurdu ve seni de çağırıyor.';

  @override
  String get actTableReady =>
      'masaya katıldı; masa kuruldu. Yeri ve saati sohbette konuşun.';

  @override
  String actVenueRevealed(String title) {
    return '\"$title\": nereye gideceğini görmek için dokun.';
  }

  @override
  String actHandshake(String title) {
    return '\"$title\" organizasyonunda seninle el sıkıştı.';
  }

  @override
  String get actCallMissed => 'seni aradı, açamadın.';

  @override
  String get actCallGranted =>
      'yetkin açıldı. Eşleştiğin kişileri sohbetten arayabilirsin.';

  @override
  String get actCallDeclined =>
      'talebin şimdilik kabul edilmedi. Ayrıntılar için dokun.';

  @override
  String get actCallRevoked => 'yetkin kapatıldı. Ayrıntılar için dokun.';

  @override
  String actSeriesLimit(String title) {
    return '\"$title\" için sonraki tarih açılamadı: grubun bu ayki organizasyon hakkı doldu. Yeni ay başlayınca ya da paket yükselince açılır.';
  }

  @override
  String get leadNewMatch => 'Yeni bir eşleşmen var!';

  @override
  String get leadSeries => 'Tekrarlayan organizasyon';

  @override
  String get leadVenue => 'Sürpriz mekan açıklandı';

  @override
  String get leadCalls => 'Sesli görüşme';

  @override
  String get periodToday => 'Bugün';

  @override
  String get periodWeek => 'Bu hafta';

  @override
  String get periodEarlier => 'Daha önce';

  @override
  String get agoNow => 'şimdi';

  @override
  String agoMinutes(int n) {
    return '$n dk';
  }

  @override
  String agoHours(int n) {
    return '$n sa';
  }

  @override
  String agoDays(int n) {
    return '$n g';
  }

  @override
  String get join => 'Katıl';

  @override
  String get see => 'Gör';

  @override
  String get prefsTitle => 'Bildirim tercihleri';

  @override
  String get messages => 'Mesajlar';

  @override
  String get directMessages => 'Kişisel mesajlar';

  @override
  String get directMessagesHint =>
      'Birebir sohbetlerine mesaj gelince, uygulama kapalıyken de sesli';

  @override
  String get groupMessages => 'Grup mesajları';

  @override
  String get groupMessagesHint =>
      'Grup sohbetlerine ve bu akşamın masasına mesaj gelince, uygulama kapalıyken de sesli';

  @override
  String get events => 'Organizasyonlar';

  @override
  String get remindDay => '1 gün önce hatırlat';

  @override
  String get remindDayHint => 'Katıldığın organizasyon yarın başlıyorsa';

  @override
  String get remindHour => '1 saat önce hatırlat';

  @override
  String get remindHourHint =>
      'Katıldığın organizasyon 1 saat içinde başlıyorsa';

  @override
  String get changes => 'Değişiklik ve iptaller';

  @override
  String get changesHint =>
      'Zaman ya da yer değişince ya da organizasyon iptal edilince';

  @override
  String get reviewRequests => 'Değerlendirme istekleri';

  @override
  String get reviewRequestsHint =>
      'Katıldığın organizasyon bitince \"Nasıldı?\" diye sor';

  @override
  String get live => 'Canlı yayınlar';

  @override
  String get liveAlerts => 'Planlanan ve başlayan yayınlar';

  @override
  String get liveAlertsHint =>
      'Grubunda yayın planlanınca ve başlayınca, uygulama açıksa sesli uyarıyla';

  @override
  String get matching => 'Eşleşme';

  @override
  String get newMatches => 'Yeni eşleşmeler';

  @override
  String get newMatchesHint => 'Biriyle karşılıklı beğenince';

  @override
  String get alwaysSent =>
      'Katılım isteğinin sonucu, bekleme listesinden yükselmen ve grup yaptırımları seni doğrudan ilgilendirdiği için her zaman bildirilir.';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get empty => 'Beğeniler, yorumlar ve yeni takipçiler burada görünür.';

  @override
  String get refresh => 'Yenile';

  @override
  String get followRequests => 'Takip istekleri';

  @override
  String andOthers(String name, int count) {
    return '$name ve $count kişi daha';
  }

  @override
  String get delete => 'Sil';

  @override
  String get actChessChallenge => 'seni satranç oynamaya davet etti.';

  @override
  String actChessTeamInvite(String group) {
    return '$group grubu adına grubunu satranç takım maçına davet etti.';
  }

  @override
  String actChessTeamAccepted(String group) {
    return '$group grubu adına takım maçı davetini kabul etti. Tahtalara oyuncularını diz.';
  }

  @override
  String actChessTeamDeclined(String group) {
    return '$group grubu adına takım maçı davetini reddetti.';
  }

  @override
  String actChessTeamStart(String group) {
    return '$group grubuna karşı takım maçı başladı. Tahtana geç!';
  }

  @override
  String get leadTeamMatch => 'Takım maçı';

  @override
  String get actChessArenaStart =>
      'Katıldığın turnuva başladı. Açınca hemen eşleşirsin.';

  @override
  String get actChessArenaMedal =>
      'Turnuvayı ilk üçte bitirdin! Madalyan satranç profilinde.';

  @override
  String get leadArena => 'Satranç turnuvası';

  @override
  String get actMindChallenge => 'seni Zihin Düellosu\'na davet etti.';
}
