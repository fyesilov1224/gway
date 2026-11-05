// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'support_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class SupportL10nAr extends SupportL10n {
  SupportL10nAr([String locale = 'ar']) : super(locale);

  @override
  String get ruleTicketRate =>
      'فتحت رسائل كثيرة اليوم. حاول غدًا أو اكتب في رسائلك المفتوحة.';

  @override
  String get ruleReplyRate =>
      'كتبت ردودًا كثيرة في وقت قصير. انتظر قليلًا وحاول مجددًا.';

  @override
  String get ticketClosed => 'أُغلقت هذه الرسالة. افتح رسالة جديدة للمتابعة.';

  @override
  String get unsupportedImage =>
      'نوع الملف غير مدعوم. اختر JPEG أو PNG أو WebP.';

  @override
  String get kindProblem => 'مشكلة';

  @override
  String get kindProblemText => 'شيء ما معطّل أو لا يعمل.';

  @override
  String get kindRequest => 'طلب';

  @override
  String get kindRequestText => 'اطلب إجراءً لحسابك أو مجموعتك أو دفعتك.';

  @override
  String get kindSuggestion => 'اقتراح';

  @override
  String get kindSuggestionText => 'شارك فكرة ميزة جديدة أو اقتراحًا.';

  @override
  String get statusOpen => 'جديد';

  @override
  String get statusInProgress => 'قيد المراجعة';

  @override
  String get statusResolved => 'تم الحل';

  @override
  String get statusClosed => 'مغلق';

  @override
  String get guide => 'دليل الاستخدام';

  @override
  String get guideSearchHint => 'ابحث في الدليل: مثل رابط الدعوة، كلمة المرور';

  @override
  String get clearSearch => 'مسح البحث';

  @override
  String get guideIntro =>
      'يشرح كل أقسام GWAY خطوة بخطوة. اختر فصلًا أو ابحث في الأعلى.';

  @override
  String get noHits => 'لم نجد ما تبحث عنه. جرّب كلمة أخرى أو راسل فريق الدعم.';

  @override
  String get writeSupport => 'راسل الدعم';

  @override
  String hitsFound(int count) {
    return 'المواضيع التي وُجدت: $count';
  }

  @override
  String chapterSemantics(String title, String summary, int count) {
    return '$title. $summary المواضيع: $count.';
  }

  @override
  String topicCount(int count) {
    return 'المواضيع: $count';
  }

  @override
  String get chapterNotFound => 'لم يُعثر على هذا الفصل.';

  @override
  String get backToGuide => 'العودة إلى الدليل';

  @override
  String get notSolved => 'ألم تُحلّ مشكلتك؟';

  @override
  String get notSolvedHint =>
      'راسل فريق المنصة؛ سترى الرد في الإعدادات ← الدعم والملاحظات.';

  @override
  String get nextChapter => 'الفصل التالي';

  @override
  String get sent => 'أُرسلت رسالتك إلى فريق المنصة.';

  @override
  String get newMessage => 'رسالة جديدة';

  @override
  String get aboutWhat => 'عمّ تكتب؟';

  @override
  String get pickKind => 'اختر نوعًا.';

  @override
  String get relatedGroup => 'المجموعة المعنية (اختياري)';

  @override
  String get noGroup => 'لا يتعلق بمجموعة';

  @override
  String get subject => 'الموضوع';

  @override
  String get subjectRequired => 'اكتب موضوعًا قصيرًا.';

  @override
  String get description => 'الوصف';

  @override
  String get descriptionHint =>
      'ماذا حدث وماذا كنت تتوقع؟ كلما زادت التفاصيل كانت المساعدة أسرع.';

  @override
  String get descriptionRequired => 'صف ما حدث باختصار.';

  @override
  String get send => 'إرسال';

  @override
  String get supportTitle => 'الدعم والملاحظات';

  @override
  String get emptyIntro =>
      'يمكنك مراسلة فريق المنصة بشأن مشكلة أو طلب أو اقتراح.';

  @override
  String get listIntro =>
      'تصل رسائلك إلى فريق المنصة؛ تابع الردود وحالتها من هنا.';

  @override
  String get newReply => 'رد جديد';

  @override
  String get message => 'رسالة';

  @override
  String get notFound => 'لم يُعثر على هذه الرسالة.';

  @override
  String get goBack => 'رجوع';

  @override
  String get team => 'فريق GWAY';

  @override
  String get you => 'أنت';

  @override
  String get addScreenshot => 'إضافة لقطة شاشة';

  @override
  String get writeReply => 'اكتب ردًا';

  @override
  String get removeImage => 'إزالة الصورة';

  @override
  String screenshots(int count, int max) {
    return 'لقطات الشاشة ($count/$max)';
  }

  @override
  String get enlargeScreenshot => 'تكبير لقطة الشاشة';
}
