// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'feed_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class FeedL10nAr extends FeedL10n {
  FeedL10nAr([String locale = 'ar']) : super(locale);

  @override
  String get commentsOff => 'التعليقات متوقّفة على هذا المنشور.';

  @override
  String get commentNotAllowed =>
      'لا يمكن التعليق على هذا المنشور حاليًا. يمكنك ترك تفاعل برمز تعبيري.';

  @override
  String get blocked => 'لا يمكنك التفاعل مع هذا الحساب.';

  @override
  String get commentRate =>
      'كتبت تعليقات كثيرة في وقت قصير. انتظر قليلًا ثم حاول مرة أخرى.';

  @override
  String get muted => 'تم كتمك في هذه المجموعة، لذا لا يمكنك التعليق حاليًا.';

  @override
  String get likeRate =>
      'أبديت إعجابات كثيرة في وقت قصير. انتظر قليلًا ثم حاول مرة أخرى.';

  @override
  String get replyGone => 'التعليق الذي ترد عليه لم يعد موجودًا.';

  @override
  String get storyRate => 'شاركت قصصًا كثيرة اليوم. حاول مرة أخرى غدًا.';

  @override
  String get highlightLimit => 'يمكنك إنشاء 100 قصة مميّزة كحدّ أقصى.';

  @override
  String get highlightFull => 'يمكن أن تضم القصة المميّزة 100 قصة كحدّ أقصى.';

  @override
  String get duplicate => 'تم تنفيذ هذا الإجراء بالفعل.';

  @override
  String get fileTooLarge =>
      'الملف كبير جدًا. يمكن أن تصل الصور إلى 10 ميغابايت والفيديو إلى 50 ميغابايت.';

  @override
  String get unsupportedMedia =>
      'يمكن مشاركة صور JPEG وPNG وWebP ومقاطع MP4 وMOV فقط.';

  @override
  String get commentLength => 'يجب أن يتكوّن التعليق من 1 إلى 2200 حرف.';

  @override
  String get highlightTitleLength => 'يجب أن يتكوّن العنوان من 1 إلى 30 حرفًا.';

  @override
  String get pickStory => 'اختر قصة واحدة على الأقل.';

  @override
  String get aspectOriginal => 'الأصلي';

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
  String agoWeeks(int n) {
    return '$n أ';
  }

  @override
  String get photoLimit => 'يمكن أن تصل الصور إلى 10 ميغابايت.';

  @override
  String get videoSizeLimit => 'يمكن أن يصل الفيديو إلى 50 ميغابايت.';

  @override
  String get videoLengthLimit => 'يمكن أن يصل طول الفيديو إلى 60 ثانية.';

  @override
  String get captionLimit => 'يمكن أن يصل الوصف إلى 2200 حرف.';

  @override
  String get hashtagLimit => 'يمكن أن يحتوي المنشور على 30 وسمًا كحدّ أقصى.';

  @override
  String get mediaCount =>
      'يمكن أن يحتوي المنشور على 1 إلى 10 صور أو مقاطع فيديو.';

  @override
  String get comments => 'التعليقات';

  @override
  String get noCommentsEmojiOnly =>
      'لا توجد تعليقات بعد. يمكنك التفاعل برمز تعبيري.';

  @override
  String get noCommentsFirst => 'لا توجد تعليقات بعد. كن أول من يعلّق.';

  @override
  String get goBack => 'رجوع';

  @override
  String get writeComment => 'اكتب تعليقًا';

  @override
  String replyingTo(String username) {
    return 'ردًا على ‎@$username';
  }

  @override
  String get cancelReply => 'إلغاء الرد';

  @override
  String get addComment => 'أضف تعليقًا…';

  @override
  String get share => 'نشر';

  @override
  String get deleteCommentTitle => 'حذف التعليق؟';

  @override
  String get deleteCommentBody => 'يُحذف التعليق وردوده نهائيًا.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String likeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count إعجابًا',
      few: '$count إعجابات',
      two: 'إعجابان',
      one: 'إعجاب واحد',
    );
    return '$_temp0';
  }

  @override
  String commentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تعليقًا',
      few: '$count تعليقات',
      two: 'تعليقان',
      one: 'تعليق واحد',
    );
    return '$_temp0';
  }

  @override
  String get reply => 'رد';

  @override
  String get report => 'إبلاغ';

  @override
  String get unlike => 'إلغاء الإعجاب';

  @override
  String get likeComment => 'الإعجاب بالتعليق';

  @override
  String get cantComment =>
      'لا يمكنك التعليق على هذا المنشور حاليًا. يمكنك ترك تفاعل برمز تعبيري.';

  @override
  String get tooManyMedia =>
      'يمكن أن يحتوي المنشور على 10 صور أو مقاطع فيديو كحدّ أقصى.';

  @override
  String get cantOpenFile => 'تعذّر فتح الملف المحدّد. جرّب صورة أو فيديو آخر.';

  @override
  String get preparingPhotos => 'جارٍ تجهيز الصور…';

  @override
  String get photosFailed => 'تعذّر تجهيز الصور. جرّب صورة أخرى.';

  @override
  String uploading(int done, int total) {
    return 'جارٍ الرفع: $done/$total';
  }

  @override
  String get sharing => 'جارٍ النشر…';

  @override
  String get postShared => 'تم نشر منشورك.';

  @override
  String get newPost => 'منشور جديد';

  @override
  String get memoryNotice =>
      'سيظهر هذا المنشور أيضًا ضمن ذكريات الفعالية. شارك صورك فقط والأشخاص الذين أذنوا بذلك.';

  @override
  String get pickMediaHint => 'اختر حتى 10 صور أو مقاطع فيديو لمشاركتها.';

  @override
  String get pickFromGallery => 'اختر من المعرض';

  @override
  String get cropHint =>
      'باعد بإصبعين للتكبير واسحب لضبط الإطار. تُطبَّق النسبة على كل الصور.';

  @override
  String get caption => 'الوصف';

  @override
  String get captionHint => 'اكتب شيئًا… يمكنك إضافة #وسوم و@أسماء مستخدمين.';

  @override
  String get postAs => 'النشر باسم';

  @override
  String get myProfile => 'ملفي الشخصي';

  @override
  String groupOption(String name) {
    return '$name (مجموعة)';
  }

  @override
  String get turnOffComments => 'إيقاف التعليقات';

  @override
  String get hideLikes => 'إخفاء عدد الإعجابات';

  @override
  String get onlyYouSee => 'أنت وحدك ترى العدد.';

  @override
  String mediaN(int n) {
    return 'الوسائط $n';
  }

  @override
  String seconds(int n) {
    return '▶ $n ث';
  }

  @override
  String get removeMedia => 'إزالة';

  @override
  String get cantShare => 'لا يمكن نشره';

  @override
  String get addMedia => 'إضافة وسائط';

  @override
  String get editPost => 'تعديل المنشور';

  @override
  String get save => 'حفظ';

  @override
  String get noEditPermission => 'ليست لديك صلاحية تعديل هذا المنشور.';

  @override
  String get photoToCrop => 'الصورة المراد قصّها';

  @override
  String get stories => 'القصص';

  @override
  String get feed => 'الموجز';

  @override
  String get feedHint => 'من مجموعاتك ومن تتابعهم';

  @override
  String get feedEmpty => 'موجزك فارغ. تظهر هنا منشورات من تتابعهم ومجموعاتك.';

  @override
  String get explore => 'استكشاف';

  @override
  String get searchHint => 'ابحث عن أشخاص أو #وسوم';

  @override
  String get clear => 'مسح';

  @override
  String get exploreEmpty => 'لا جديد للاستكشاف. عد بعد قليل.';

  @override
  String get refresh => 'تحديث';

  @override
  String get accounts => 'الحسابات';

  @override
  String get hashtags => 'الوسوم';

  @override
  String noTagMatch(String query) {
    return 'لا توجد وسوم تبدأ بـ«$query».';
  }

  @override
  String get clearSearch => 'مسح البحث';

  @override
  String postCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count منشورًا',
      few: '$count منشورات',
      two: 'منشوران',
      one: 'منشور واحد',
    );
    return '$_temp0';
  }

  @override
  String noTagPosts(String tag) {
    return 'لا توجد منشورات يمكنك رؤيتها بالوسم #$tag.';
  }

  @override
  String get backToExplore => 'العودة إلى الاستكشاف';

  @override
  String get saved => 'المحفوظات';

  @override
  String get savedEmpty => 'تظهر هنا المنشورات التي تحفظها، ولا يراها غيرك.';

  @override
  String get post => 'منشور';

  @override
  String get postGone => 'حُذف هذا المنشور أو ليست لديك صلاحية رؤيته.';

  @override
  String get backToFeed => 'العودة إلى الموجز';

  @override
  String get unmute => 'تشغيل الصوت';

  @override
  String get mute => 'كتم الصوت';

  @override
  String get addedToSaved => 'تمت الإضافة إلى المحفوظات.';

  @override
  String get linkCopied => 'تم نسخ رابط المنشور.';

  @override
  String get deletePostTitle => 'حذف المنشور؟';

  @override
  String get deletePostBody =>
      'يُحذف المنشور نهائيًا مع صوره ومقاطعه وتعليقاته.';

  @override
  String get postDeleted => 'تم حذف المنشور.';

  @override
  String get likesHidden => 'أنت وحدك ترى عدد الإعجابات.';

  @override
  String memoryOf(String title) {
    return 'ذكرى · $title';
  }

  @override
  String get deletedAccount => 'حساب محذوف';

  @override
  String get groupPost => 'منشور مجموعة';

  @override
  String get edited => 'معدَّل';

  @override
  String get moreOptions => 'خيارات أخرى';

  @override
  String get copyLink => 'نسخ الرابط';

  @override
  String get edit => 'تعديل';

  @override
  String get like => 'إعجاب';

  @override
  String get commentAction => 'تعليق';

  @override
  String get unsave => 'إزالة من المحفوظات';

  @override
  String reactionLabel(String emoji, int count) {
    return 'تفاعل $emoji، $count';
  }

  @override
  String get more => 'المزيد';

  @override
  String postWithCaption(String caption) {
    return 'منشور: $caption';
  }

  @override
  String get showMore => 'عرض المزيد';

  @override
  String get addStory => 'إضافة قصة';

  @override
  String get yourStory => 'قصتك';

  @override
  String get noStoriesLeft => 'لم تعد هناك قصص يمكنك رؤيتها هنا.';

  @override
  String get close => 'إغلاق';

  @override
  String get removeFromHighlight => 'إزالة من القصص المميّزة';

  @override
  String get removedFromHighlight => 'تمت الإزالة من القصص المميّزة.';

  @override
  String get addToHighlights => 'إضافة إلى القصص المميّزة';

  @override
  String get deleteStory => 'حذف القصة';

  @override
  String get storyDeleted => 'تم حذف القصة.';

  @override
  String get options => 'خيارات';

  @override
  String get viewers => 'المشاهدون';

  @override
  String get noViewers =>
      'لم يشاهدها أحد بعد. يظهر المشاهدون هنا، ولا يراهم غيرك.';

  @override
  String viewedBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'شاهدها $count شخصًا',
      few: 'شاهدها $count أشخاص',
      two: 'شاهدها شخصان',
      one: 'شاهدها شخص واحد',
    );
    return '$_temp0';
  }

  @override
  String get storyPhotoFailed => 'تعذّر تجهيز الصورة. جرّب صورة أخرى.';

  @override
  String get storyShared => 'تم نشر قصتك. تبقى ظاهرة لمدة 24 ساعة.';

  @override
  String get newStory => 'قصة جديدة';

  @override
  String get addToStory => 'أضف إلى قصتك';

  @override
  String get storyPickHint => 'اختر صورة أو فيديو حتى 60 ثانية لقصتك.';

  @override
  String get pickAnother => 'اختر غيرها';

  @override
  String get newHighlight => 'قصة مميّزة جديدة';

  @override
  String highlightCreated(String title) {
    return 'تم إنشاء «$title».';
  }

  @override
  String storyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count قصة',
      few: '$count قصص',
      two: 'قصتان',
      one: 'قصة واحدة',
    );
    return '$_temp0';
  }

  @override
  String addedToHighlight(String title) {
    return 'تمت الإضافة إلى «$title».';
  }

  @override
  String get highlightTitle => 'عنوان القصة المميّزة';

  @override
  String get highlightExample => 'مثال: تخييم 2026';

  @override
  String get addHighlight => 'إضافة قصة مميّزة';

  @override
  String get renameHighlight => 'إعادة التسمية';

  @override
  String get deleteHighlight => 'حذف القصة المميّزة';

  @override
  String get staysInArchive => 'تبقى القصص في أرشيفك.';

  @override
  String get storyArchive => 'أرشيف القصص';

  @override
  String storiesSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم اختيار $count قصة',
      few: 'تم اختيار $count قصص',
      two: 'تم اختيار قصتين',
      one: 'تم اختيار قصة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get feature => 'تمييز';

  @override
  String get archiveEmpty => 'تُحفظ قصصك هنا بعد 24 ساعة، ولا يراها غيرك.';

  @override
  String get shareStory => 'نشر قصة';

  @override
  String get archiveHint =>
      'اختر قصصًا لإنشاء قصة مميّزة أو الإضافة إلى واحدة.';

  @override
  String storyOn(String date) {
    return 'قصة، $date';
  }

  @override
  String get live => 'منشورة';
}
