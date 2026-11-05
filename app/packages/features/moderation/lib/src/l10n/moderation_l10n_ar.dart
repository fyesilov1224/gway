// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'moderation_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class ModerationL10nAr extends ModerationL10n {
  ModerationL10nAr([String locale = 'ar']) : super(locale);

  @override
  String get ruleRateLimited => 'أرسلت بلاغات كثيرة اليوم. حاول غدًا.';

  @override
  String get ruleTargetInvalid =>
      'لم يعد هذا المحتوى موجودًا أو لا يمكنك رؤيته.';

  @override
  String get ruleSelf => 'لا يمكنك الإبلاغ عن نفسك أو عن محتواك.';

  @override
  String get ruleAppealNotAllowed =>
      'لم يعد بالإمكان الاعتراض على هذه العقوبة.';

  @override
  String get ruleDuplicate => 'سبق أن أبلغت عن هذا؛ وهو قيد المراجعة.';

  @override
  String get deletedAccount => 'حساب محذوف';

  @override
  String get reasonSpam => 'رسائل مزعجة أو مضلّلة';

  @override
  String get reasonHarassment => 'تحرّش أو تنمّر';

  @override
  String get reasonHate => 'خطاب كراهية';

  @override
  String get reasonViolence => 'عنف أو تهديد';

  @override
  String get reasonSexual => 'محتوى جنسي';

  @override
  String get reasonMisinformation => 'معلومات خاطئة';

  @override
  String get reasonOther => 'أخرى';

  @override
  String get sanctionWarning => 'تحذير';

  @override
  String get sanctionMute => 'كتم';

  @override
  String get sanctionKick => 'الإخراج من المجموعة';

  @override
  String get sanctionBan => 'حظر';

  @override
  String get illegalViolence => 'عنف';

  @override
  String get illegalThreat => 'تهديد';

  @override
  String get illegalInsult => 'إهانة';

  @override
  String get illegalHate => 'خطاب كراهية';

  @override
  String get illegalSexual => 'استغلال جنسي';

  @override
  String get illegalFraud => 'احتيال';

  @override
  String get illegalDrugs => 'مخدّرات';

  @override
  String get illegalTerror => 'إرهاب';

  @override
  String get illegalOther => 'جريمة أخرى';

  @override
  String muteDays(int days) {
    return 'كتم لمدة $days يوم';
  }

  @override
  String banDays(int days) {
    return 'حظر لمدة $days يوم';
  }

  @override
  String get permanentBan => 'حظر دائم';

  @override
  String get thresholdMajority => 'أغلبية بسيطة';

  @override
  String get thresholdMajorityText => 'أكثر من نصف الأصوات';

  @override
  String get thresholdTwoThirds => 'الثلثان';

  @override
  String get thresholdTwoThirdsText => 'ثلثا الأصوات على الأقل';

  @override
  String get thresholdUnanimous => 'بالإجماع';

  @override
  String get thresholdUnanimousText => 'كل الأصوات';

  @override
  String get targetPost => 'منشور';

  @override
  String get targetComment => 'تعليق';

  @override
  String get targetEvent => 'فعالية';

  @override
  String get targetLiveComment => 'تعليق في البث المباشر';

  @override
  String get targetMessage => 'رسالة في محادثة المجموعة';

  @override
  String get targetMember => 'عضو';

  @override
  String get appealPending => 'بانتظار القرار';

  @override
  String get appealUpheld => 'العقوبة قائمة';

  @override
  String get appealOverturned => 'رُفعت العقوبة';

  @override
  String get banApplied => 'تم تطبيق الحظر.';

  @override
  String get banAppliedSuspended =>
      'تم تطبيق الحظر. عُلّق حساب الشخص حتى تراجعه المنصة.';

  @override
  String get caseOpened => 'فُتح الملف. ستصوّت اللجنة خلال 72 ساعة.';

  @override
  String get openCaseTitle => 'فتح ملف تأديبي';

  @override
  String caseAboutNow(String name) {
    return 'بخصوص $name. يُطبَّق الحظر فورًا دون تصويت اللجنة.';
  }

  @override
  String caseAboutVote(String name) {
    return 'بخصوص $name. تصوّت اللجنة التأديبية على العقوبة المقترحة خلال 72 ساعة.';
  }

  @override
  String get proposedSanction => 'العقوبة المقترحة';

  @override
  String get duration => 'المدة';

  @override
  String get permanent => 'دائم';

  @override
  String get permanentLower => 'دائم';

  @override
  String days(int days) {
    return '$days يوم';
  }

  @override
  String get applyNow => 'طبّق فورًا دون تصويت';

  @override
  String get applyNowHint =>
      'يحظر دون انتظار اللجنة. يمكن للشخص الاعتراض خلال 7 أيام.';

  @override
  String get illegalActivity => 'نشاط غير قانوني';

  @override
  String get illegalHintNow =>
      'عند تطبيق الحظر يُحال الملف إلى فريق المنصة ويُعلَّق الحساب حتى المراجعة. لا يمكن تغيير هذه العلامة لاحقًا.';

  @override
  String get illegalHintVote =>
      'إذا وافقت اللجنة يُحال الملف إلى فريق المنصة ويُعلَّق الحساب حتى المراجعة. لا يمكن تغيير هذه العلامة لاحقًا.';

  @override
  String get reason => 'السبب';

  @override
  String get reasonHintNow =>
      'ماذا حدث؟ يرى هذا النص الشخص ومن يراجع الاعتراض.';

  @override
  String get reasonHintVote => 'ماذا حدث؟ ستصوّت اللجنة بناءً على هذا النص.';

  @override
  String get reasonMin10 => 'يجب أن يتكوّن السبب من 10 أحرف على الأقل.';

  @override
  String get muteNow => 'اكتم الآن (24 ساعة)';

  @override
  String get muteNowHint =>
      'حتى تقرّر اللجنة لا يمكنه التعليق ولا التحدث في البث المباشر.';

  @override
  String get ban => 'حظر';

  @override
  String get openCase => 'افتح الملف';

  @override
  String leftDays(int days) {
    return '$days يوم';
  }

  @override
  String leftDaysHours(int days, int hours) {
    return '$days يوم و$hours ساعة';
  }

  @override
  String leftHours(int hours) {
    return '$hours ساعة';
  }

  @override
  String get leftFewMinutes => 'بضع دقائق';

  @override
  String minChars(int min) {
    return 'اكتب $min أحرف على الأقل.';
  }

  @override
  String get cancel => 'إلغاء';

  @override
  String get threshold => 'عتبة قرار اللجنة';

  @override
  String thresholdChanged(String threshold) {
    return 'أصبحت العتبة «$threshold». تسري على الملفات الجديدة.';
  }

  @override
  String moderationOf(String group) {
    return 'الإشراف · $group';
  }

  @override
  String get reports => 'البلاغات';

  @override
  String reportsCount(int count) {
    return 'البلاغات ($count)';
  }

  @override
  String get cases => 'الملفات';

  @override
  String casesCount(int count) {
    return 'الملفات ($count)';
  }

  @override
  String get sanctions => 'العقوبات';

  @override
  String sanctionsCount(int count) {
    return 'العقوبات ($count)';
  }

  @override
  String get moderationTeamOnly =>
      'لا يرى الإشراف على هذه المجموعة إلا المالك وفريق الإشراف.';

  @override
  String get goBack => 'رجوع';

  @override
  String get noReports => 'لا بلاغات مفتوحة. تُجمع بلاغات الأعضاء هنا.';

  @override
  String get refresh => 'تحديث';

  @override
  String get removeContent => 'إزالة المحتوى';

  @override
  String get remove => 'إزالة';

  @override
  String get contentRemoved => 'تمت إزالة المحتوى.';

  @override
  String reportCount(int count) {
    return 'البلاغات: $count';
  }

  @override
  String get view => 'عرض';

  @override
  String get reportDismissed => 'تم رفض البلاغ.';

  @override
  String get dismiss => 'رفض';

  @override
  String get openCaseShort => 'فتح ملف';

  @override
  String get rankOnlyDismiss =>
      'رتبة هذا الشخص ليست أدنى من رتبتك، لذا يمكنك الرفض فقط.';

  @override
  String get noCases =>
      'لا ملفات تأديبية بعد. تُفتح الملفات من بلاغ أو من صفحة الأعضاء.';

  @override
  String get voteApproved => 'تم حفظ صوتك. وافقت اللجنة على العقوبة وطُبّقت.';

  @override
  String get voteRejected => 'تم حفظ صوتك. رفضت اللجنة العقوبة.';

  @override
  String get voteSaved => 'تم حفظ صوتك. يمكنك تغييره حتى صدور القرار.';

  @override
  String get statusVoting => 'قيد التصويت';

  @override
  String get statusApproved => 'تمت الموافقة';

  @override
  String get statusRejected => 'مرفوض';

  @override
  String proposed(String sanction) {
    return 'المقترح: $sanction';
  }

  @override
  String get directBan => 'حظر دون تصويت';

  @override
  String illegalLabel(String category) {
    return 'نشاط غير قانوني: $category';
  }

  @override
  String tally(int approvals, int rejections, int voters) {
    return 'مع: $approvals · ضد: $rejections · المصوّتون: $voters';
  }

  @override
  String votingEndsIn(String time) {
    return 'ينتهي التصويت بعد $time';
  }

  @override
  String bannedBy(String name) {
    return 'حظره: $name';
  }

  @override
  String openedBy(String name) {
    return 'فتحه: $name';
  }

  @override
  String get approve => 'موافقة';

  @override
  String get reject => 'رفض';

  @override
  String get noSanctions =>
      'لا عقوبات بعد. تظهر هنا العقوبات المعتمدة والاعتراضات.';

  @override
  String get liftSanction => 'رفع العقوبة';

  @override
  String get keepSanction => 'إبقاء العقوبة';

  @override
  String get noteToPerson => 'ملاحظة للشخص (اختياري)';

  @override
  String get liftedNotified => 'رُفعت العقوبة وأُبلغ الشخص.';

  @override
  String get appealRejectedNotified => 'رُفض الاعتراض وأُبلغ الشخص.';

  @override
  String get lifted => 'مرفوعة';

  @override
  String get interimMute => 'كتم عاجل';

  @override
  String get running => 'سارية';

  @override
  String get applied => 'طُبّقت';

  @override
  String get interimUntilDecision => 'كتم عاجل · حتى قرار اللجنة';

  @override
  String until(String date) {
    return 'حتى $date';
  }

  @override
  String appealLine(String status) {
    return 'اعتراض · $status';
  }

  @override
  String noteLine(String note) {
    return 'ملاحظة: $note';
  }

  @override
  String get ownerParty =>
      'المالك طرف في هذا الملف، لذا يراجع فريق المنصة الاعتراض.';

  @override
  String get keep => 'إبقاء';

  @override
  String casesAwaitingVote(int count) {
    return 'ملفات بانتظار صوتك: $count';
  }

  @override
  String appealsCount(int count) {
    return 'الاعتراضات: $count';
  }

  @override
  String get moderation => 'الإشراف';

  @override
  String get noWork => 'لا شيء معلّق';

  @override
  String get mySanctions => 'عقوباتي';

  @override
  String get noMySanctions =>
      'لا عقوبات عليك في أي مجموعة. شكرًا لالتزامك بقواعد المجتمع.';

  @override
  String get interimEnded => 'انتهى الكتم العاجل';

  @override
  String interimLatest(String date) {
    return 'كتم عاجل · حتى قرار اللجنة، في موعد أقصاه $date';
  }

  @override
  String untilCap(String date) {
    return 'حتى $date';
  }

  @override
  String get ended => 'انتهت';

  @override
  String get appeal => 'اعتراض';

  @override
  String get appealHint => 'لماذا تراه غير عادل؟';

  @override
  String get send => 'إرسال';

  @override
  String get appealSent => 'تم إرسال اعتراضك. سيصلك إشعار عند صدور القرار.';

  @override
  String reasonLine(String reason) {
    return 'السبب: $reason';
  }

  @override
  String yourAppealLine(String status) {
    return 'اعتراضك · $status';
  }

  @override
  String get appealOnce =>
      'يمكنك الاعتراض على هذا القرار مرة واحدة خلال 7 أيام.';

  @override
  String get reportPost => 'الإبلاغ عن المنشور';

  @override
  String get reportComment => 'الإبلاغ عن التعليق';

  @override
  String get reportEvent => 'الإبلاغ عن الفعالية';

  @override
  String get reportMessage => 'الإبلاغ عن الرسالة';

  @override
  String get reportMatchProfile => 'الإبلاغ عن ملف التوافق';

  @override
  String get reportPhoto => 'الإبلاغ عن الصورة';

  @override
  String get reportUser => 'الإبلاغ عن المستخدم';

  @override
  String get reportReceived =>
      'استلمنا بلاغك. سنراجعه ونتخذ اللازم؛ ولن تُعرض هويتك على الشخص المُبلَّغ عنه.';

  @override
  String get whyReport => 'لماذا تُبلغ عن هذا؟';

  @override
  String get detailsOptional => 'تفاصيل (اختياري)';

  @override
  String get detailsHint => 'صف ما حدث باختصار.';

  @override
  String get report => 'إبلاغ';
}
