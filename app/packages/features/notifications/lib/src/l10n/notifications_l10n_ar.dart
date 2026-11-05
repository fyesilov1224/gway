// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'notifications_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class NotificationsL10nAr extends NotificationsL10n {
  NotificationsL10nAr([String locale = 'ar']) : super(locale);

  @override
  String get actLike => 'أُعجب بمنشورك.';

  @override
  String actComment(String text) {
    return 'علّق: $text';
  }

  @override
  String actReply(String text) {
    return 'ردّ على تعليقك: $text';
  }

  @override
  String actCommentLike(String text) {
    return 'أُعجب بتعليقك: $text';
  }

  @override
  String get actMentionPost => 'أشار إليك في منشور.';

  @override
  String actMentionComment(String text) {
    return 'أشار إليك في تعليق: $text';
  }

  @override
  String get actFollow => 'بدأ متابعتك.';

  @override
  String get actFollowRequest => 'يريد متابعتك.';

  @override
  String get actFollowAccepted => 'قبل طلب متابعتك.';

  @override
  String actLiveScheduled(String title) {
    return 'جدول بثًا مباشرًا: $title';
  }

  @override
  String actLiveScheduledAt(String date, String title) {
    return 'جدول بثًا مباشرًا في $date: $title';
  }

  @override
  String actLiveStarted(String title) {
    return 'بدأ بثًا مباشرًا: $title';
  }

  @override
  String actEventPromoted(String title) {
    return 'توفّر مكان في «$title»، وأصبحت من الحضور.';
  }

  @override
  String actEventUpdated(String title) {
    return 'غيّر وقت «$title» أو مكانها.';
  }

  @override
  String actEventCanceled(String title) {
    return 'ألغى «$title».';
  }

  @override
  String actReminderTomorrow(String title) {
    return 'تبدأ «$title» غدًا. هل ستأتي؟ أكّد.';
  }

  @override
  String actReminderHour(String title) {
    return 'تبدأ «$title» خلال ساعة.';
  }

  @override
  String actCaseVote(String group) {
    return 'فتح ملفًا انضباطيًا في $group، وصوتك مطلوب.';
  }

  @override
  String get actMuted => 'كتمك. انقر للتفاصيل أو للاعتراض.';

  @override
  String get actKicked => 'أزالك من المجموعة. انقر للتفاصيل أو للاعتراض.';

  @override
  String get actBanned => 'حظرك من المجموعة. انقر للتفاصيل أو للاعتراض.';

  @override
  String get actWarned => 'وجّه إليك تحذيرًا. انقر للتفاصيل أو للاعتراض.';

  @override
  String actAppealSubmitted(String group) {
    return 'اعترض على عقوبة في $group.';
  }

  @override
  String get actAppealDecided => 'بتّ في اعتراضك.';

  @override
  String actEventApproved(String title) {
    return 'وافق على طلب حضورك «$title».';
  }

  @override
  String actEventDeclined(String title) {
    return 'لم يتمكّن من قبول طلب حضورك «$title».';
  }

  @override
  String actEventReview(String title) {
    return 'كيف كانت «$title»؟ قيّمها وشارك ذكرياتك.';
  }

  @override
  String actGoalCompleted(String title) {
    return 'أنجزت «$title»! شارتك في ملفك الشخصي.';
  }

  @override
  String get actTeammateRequest => 'يريد أن يكون زميل فريقك.';

  @override
  String get actTeammateAccepted => 'قبل طلب الزمالة.';

  @override
  String get actMatchCreated => 'اعرف من هو في «توافقاتي».';

  @override
  String get actSuperLiked =>
      'أرسل إليك إعجابًا خارقًا! يظهر أولًا في مجموعتك.';

  @override
  String actWelcomeRequested(String title) {
    return 'يأتي لأول مرة إلى «$title» ويرغب في الاستقبال.';
  }

  @override
  String actWelcomeMatched(String title) {
    return 'سيستقبلك في «$title». اطّلع على ملاحظة اللقاء.';
  }

  @override
  String actWelcomeReleased(String title) {
    return 'لم يعد بإمكانه استقبالك في «$title»؛ نبحث عن شخص آخر.';
  }

  @override
  String actWelcomeWithdrawn(String title) {
    return 'سحب طلب الاستقبال في «$title».';
  }

  @override
  String get actLeagueResult =>
      'حلّت ضمن المراكز الثلاثة الأولى في دوري الشهر الماضي! شاهد الترتيب في صفحة المجموعة.';

  @override
  String actWelcomeThanked(String title) {
    return 'شكرك لاستقباله في «$title».';
  }

  @override
  String get actTableInvite => 'أنشأ طاولة صغيرة الليلة ويدعوك إليها.';

  @override
  String get actTableReady =>
      'انضم إلى الطاولة وأصبحت جاهزة. اتفقوا على المكان والوقت في المحادثة.';

  @override
  String actVenueRevealed(String title) {
    return '«$title»: انقر لترى إلى أين تذهب.';
  }

  @override
  String actHandshake(String title) {
    return 'صافحك في «$title».';
  }

  @override
  String get actCallMissed => 'اتصل بك ولم تردّ.';

  @override
  String get actCallGranted =>
      '— أصبح لديك الإذن. يمكنك الاتصال بمن توافقت معهم من المحادثة.';

  @override
  String get actCallDeclined =>
      '— لم تتم الموافقة على طلبك حاليًا. انقر للتفاصيل.';

  @override
  String get actCallRevoked => '— تم إيقاف إذنك. انقر للتفاصيل.';

  @override
  String actSeriesLimit(String title) {
    return '— تعذّر فتح الموعد التالي لـ«$title»: بلغت المجموعة حدّها الشهري. سيُفتح مع بداية الشهر الجديد أو بترقية الباقة.';
  }

  @override
  String get leadNewMatch => 'لديك توافق جديد!';

  @override
  String get leadSeries => 'فعالية متكرّرة';

  @override
  String get leadVenue => 'تم الكشف عن المكان المفاجئ';

  @override
  String get leadCalls => 'المكالمات الصوتية';

  @override
  String get periodToday => 'اليوم';

  @override
  String get periodWeek => 'هذا الأسبوع';

  @override
  String get periodEarlier => 'سابقًا';

  @override
  String get agoNow => 'الآن';

  @override
  String agoMinutes(int n) {
    return '$n د';
  }

  @override
  String agoHours(int n) {
    return '$n س';
  }

  @override
  String agoDays(int n) {
    return '$n ي';
  }

  @override
  String get join => 'انضمام';

  @override
  String get see => 'عرض';

  @override
  String get prefsTitle => 'تفضيلات الإشعارات';

  @override
  String get messages => 'الرسائل';

  @override
  String get directMessages => 'الرسائل الخاصة';

  @override
  String get directMessagesHint =>
      'عند وصول رسالة خاصة، مع صوت حتى إن كان التطبيق مغلقًا';

  @override
  String get groupMessages => 'رسائل المجموعات';

  @override
  String get groupMessagesHint =>
      'عند وصول رسائل في محادثات المجموعات وطاولة الليلة، مع صوت حتى إن كان التطبيق مغلقًا';

  @override
  String get events => 'الفعاليات';

  @override
  String get remindDay => 'التذكير قبل يوم';

  @override
  String get remindDayHint => 'إذا كانت فعالية انضممت إليها تبدأ غدًا';

  @override
  String get remindHour => 'التذكير قبل ساعة';

  @override
  String get remindHourHint => 'إذا كانت فعالية انضممت إليها تبدأ خلال ساعة';

  @override
  String get changes => 'التغييرات والإلغاءات';

  @override
  String get changesHint => 'عند تغيّر الوقت أو المكان أو إلغاء فعالية';

  @override
  String get reviewRequests => 'طلبات التقييم';

  @override
  String get reviewRequestsHint => 'السؤال «كيف كانت؟» بعد انتهاء الفعالية';

  @override
  String get live => 'البث المباشر';

  @override
  String get liveAlerts => 'البث المجدول والبادئ';

  @override
  String get liveAlertsHint =>
      'عندما تجدول مجموعتك بثًا أو تبدأه، مع تنبيه صوتي إن كان التطبيق مفتوحًا';

  @override
  String get matching => 'التوافق';

  @override
  String get newMatches => 'التوافقات الجديدة';

  @override
  String get newMatchesHint => 'عند الإعجاب المتبادل';

  @override
  String get alwaysSent =>
      'نتيجة طلبات الحضور والانتقال من قائمة الانتظار وعقوبات المجموعة تعنيك مباشرة، لذا تُرسل دائمًا.';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get empty => 'تظهر هنا الإعجابات والتعليقات والمتابِعون الجدد.';

  @override
  String get refresh => 'تحديث';

  @override
  String get followRequests => 'طلبات المتابعة';

  @override
  String andOthers(String name, int count) {
    return '$name و$count آخرون';
  }

  @override
  String get delete => 'حذف';

  @override
  String get actChessChallenge => 'دعاك للعب الشطرنج.';
}
