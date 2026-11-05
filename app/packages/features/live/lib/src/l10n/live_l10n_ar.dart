// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'live_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class LiveL10nAr extends LiveL10n {
  LiveL10nAr([String locale = 'ar']) : super(locale);

  @override
  String get commentRate =>
      'كتبت تعليقات كثيرة في وقت قصير. انتظر قليلًا ثم حاول مرة أخرى.';

  @override
  String get mutedListenOnly =>
      'تم كتمك في هذه المجموعة، لذا يمكنك الاستماع فقط.';

  @override
  String get cannotComment => 'لا يمكنك التعليق على هذا البث حاليًا.';

  @override
  String get roleHost => 'المقدّم';

  @override
  String get roleSpeaker => 'متحدّث';

  @override
  String get roleListener => 'مستمع';

  @override
  String get startLive => 'بدء بث';

  @override
  String hostedBy(String name) {
    return 'يقدّمه $name';
  }

  @override
  String get join => 'انضمام';

  @override
  String upcomingAt(String date) {
    return 'قادم · $date';
  }

  @override
  String get scheduledCanceled => 'تم إلغاء البث المجدول.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get start => 'بدء';

  @override
  String get reminderRemoved => 'تمت إزالة التذكير.';

  @override
  String get reminderSet => 'سنُعلمك عند بدء البث.';

  @override
  String get reminding => 'التذكير مفعّل';

  @override
  String get remind => 'ذكّرني';

  @override
  String get schedule5min => 'يجب أن يبدأ البث المجدول بعد 5 دقائق على الأقل.';

  @override
  String get scheduled => 'تمت جدولة البث. يمكن للأعضاء طلب تذكير.';

  @override
  String get liveBroadcast => 'بث مباشر';

  @override
  String get liveIntro =>
      'ينضم الأعضاء إلى الغرفة الصوتية، ويتحدّث من تدعوهم إلى المنصة.';

  @override
  String get title => 'العنوان';

  @override
  String get titleExample => 'مثال: التخطيط لمشي الأحد';

  @override
  String get titleMin3 => 'يجب أن يتكوّن العنوان من 3 أحرف على الأقل.';

  @override
  String get now => 'الآن';

  @override
  String get scheduleIt => 'جدولة';

  @override
  String minutesLeft(int count) {
    return 'المتبقّي من دقائق البث هذا الشهر: $count.';
  }

  @override
  String get minutesUsedUp =>
      'نفد وقت البث لهذا الشهر. رقِّ باقتك للحصول على المزيد.';

  @override
  String get startTheLive => 'بدء البث';

  @override
  String get liveNow => 'مباشر الآن';

  @override
  String trayLabel(String group, String title) {
    return '$group في بث مباشر: $title';
  }

  @override
  String youAreLive(String title) {
    return 'أنت في بث مباشر: $title. انقر للعودة.';
  }

  @override
  String get connecting => 'جارٍ الاتصال بالبث…';

  @override
  String get inBroadcast => 'أنت في البث · انقر للعودة';

  @override
  String get micMutedByMod => 'أوقف المشرف ميكروفونك';

  @override
  String get micOff => 'إيقاف الميكروفون';

  @override
  String get micOn => 'تشغيل الميكروفون';

  @override
  String startsOn(String date) {
    return 'يبدأ هذا البث في $date.';
  }

  @override
  String get ended => 'انتهى هذا البث.';

  @override
  String get notFound =>
      'لم يُعثر على هذا البث. ربما عليك أن تكون عضوًا في المجموعة.';

  @override
  String get goBack => 'رجوع';

  @override
  String get onStageNow => 'أنت على المنصة. شغّل الميكروفون لتتحدّث.';

  @override
  String get nowListener => 'أصبحت مستمعًا.';

  @override
  String get leaveBroadcast => 'مغادرة البث';

  @override
  String get leaveHostBody =>
      'يمكنك إنهاء البث للجميع. إن غادرت فقط فسينتهي تلقائيًا بعد دقيقتين.';

  @override
  String get justLeave => 'المغادرة فقط';

  @override
  String get endBroadcast => 'إنهاء البث';

  @override
  String get inviteToStage => 'دعوة إلى المنصة';

  @override
  String get removeFromStage => 'إنزال من المنصة';

  @override
  String get muteMic => 'إيقاف ميكروفونه';

  @override
  String get unmuteMic => 'تشغيل ميكروفونه';

  @override
  String get kick => 'إخراج من البث';

  @override
  String kickBody(String name) {
    return 'لن يتمكّن $name من الانضمام إلى هذا البث مجددًا.';
  }

  @override
  String get cancelAction => 'إلغاء';

  @override
  String get remove => 'إخراج';

  @override
  String get raisedHands => 'الأيدي المرفوعة';

  @override
  String get commentDeleted => 'تم حذف التعليق.';

  @override
  String get thanksForJoining => 'انتهى البث. شكرًا لمشاركتك.';

  @override
  String get youWereKicked => 'تم إخراجك من هذا البث.';

  @override
  String get connectFailedShort => 'تعذّر الاتصال بالبث.';

  @override
  String handsRaised(int count) {
    return 'رفع اليد: $count';
  }

  @override
  String get onStage => 'على المنصة';

  @override
  String listeners(int count) {
    return 'المستمعون · $count';
  }

  @override
  String get noListeners => 'لا يوجد مستمعون بعد.';

  @override
  String get minimize => 'تصغير والبقاء في البث';

  @override
  String peopleCount(int count) {
    return 'الأشخاص: $count';
  }

  @override
  String get broadcastOptions => 'خيارات البث';

  @override
  String get endForAll => 'إنهاء للجميع';

  @override
  String get handRaised => 'رفعت يدك. يمكن للمقدّم دعوتك إلى المنصة.';

  @override
  String get you => 'أنت';

  @override
  String get speaking => 'يتحدّث';

  @override
  String get micOffState => 'الميكروفون متوقّف';

  @override
  String get handUp => 'رفع يده';

  @override
  String get sendReaction => 'إرسال تفاعل';

  @override
  String get leave => 'مغادرة';

  @override
  String get leaveStage => 'النزول من المنصة';

  @override
  String get reactions => 'التفاعلات';

  @override
  String get comments => 'التعليقات';

  @override
  String get raiseHand => 'رفع اليد';

  @override
  String get lowerHand => 'إنزال اليد';

  @override
  String get report => 'إبلاغ';

  @override
  String get deleteComment => 'حذف التعليق';

  @override
  String get firstComment => 'كن أول من يعلّق.';

  @override
  String get writeComment => 'اكتب تعليقًا…';

  @override
  String get send => 'إرسال';

  @override
  String get connectFailed =>
      'تعذّر الاتصال بالبث. تحقّق من اتصالك وحاول مرة أخرى.';

  @override
  String get participant => 'مشارك';

  @override
  String get micNeedsManager => 'لا يمكن تشغيل ميكروفونك إلا لمشرف البث.';

  @override
  String get micFailed => 'تعذّر تشغيل الميكروفون. تحقّق من إذن الميكروفون.';

  @override
  String get connectionLost => 'انقطع اتصالك بالبث. اضغط لإعادة الاتصال.';

  @override
  String get micAfterEncryption =>
      'جارٍ إنشاء الاتصال المشفّر؛ سيعمل الميكروفون بعد لحظات.';

  @override
  String get encrypting => 'جارٍ إنشاء اتصال مشفّر…';

  @override
  String get verifying => 'جارٍ التحقق من التشفير…';

  @override
  String get liveSecure => 'بث آمن';

  @override
  String get liveSecureDetail =>
      'مشفّر من طرف إلى طرف. يستخدم الجميع في الغرفة المفتاح نفسه؛ لا يستطيع أحد الاستماع، ولا حتى الخادم.';

  @override
  String get liveCheckFailed =>
      'تعذّر التحقق من التشفير: لا يستخدم الجميع في الغرفة المفتاح نفسه. اخرج من البث وادخل مجددًا.';

  @override
  String get liveUnconfirmed =>
      'أحد المتحدثين يستخدم إصدارًا قديمًا من التطبيق؛ لا يمكن تشفير صوته لذلك لا يُشغَّل.';

  @override
  String get peerUnencrypted =>
      'متحدث يستخدم إصدارًا قديمًا يرسل صوتًا غير مشفّر فلا يُشغَّل. عليه تحديث التطبيق.';

  @override
  String get e2ee => 'مشفّر بين الطرفين';

  @override
  String get showSecurityCode => 'إظهار رمز الأمان';

  @override
  String get codeMatchHint => 'هذا الرمز نفسه على شاشة كل من في الغرفة.';

  @override
  String e2eeCode(String code) {
    return 'مشفّر بين الطرفين. رمز الأمان $code';
  }

  @override
  String get liveOngoingTitle => 'أنت في بث مباشر';

  @override
  String get liveOngoingText => 'مشفّر بين الطرفين. اضغط للعودة.';
}
