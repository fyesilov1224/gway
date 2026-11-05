// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'messaging_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class MessagingL10nAr extends MessagingL10n {
  MessagingL10nAr([String locale = 'ar']) : super(locale);

  @override
  String get groupInvalid => 'يمكنك إرسال الطلب إلى مجموعة أنت عضو فيها فقط.';

  @override
  String get permissionExists => 'تم استلام طلبك بالفعل أو أن إذنك مفعّل.';

  @override
  String get permissionCooldown =>
      'يمكنك إرسال طلب جديد بعد 7 أيام من آخر قرار.';

  @override
  String noteTooLong(int max) {
    return 'يمكن أن تصل الملاحظة إلى $max حرفًا.';
  }

  @override
  String get requestForbidden => 'لا يمكن إرسال الطلب حاليًا.';

  @override
  String get unsupportedImage =>
      'نوع الملف غير مدعوم. اختر JPEG أو PNG أو WebP.';

  @override
  String get voiceCallHandle => 'مكالمة GWAY الصوتية';

  @override
  String get incomingCalls => 'المكالمات الواردة';

  @override
  String get missedCalls => 'المكالمات الفائتة';

  @override
  String get answer => 'ردّ';

  @override
  String get decline => 'رفض';

  @override
  String get noAnswer => 'لا ردّ';

  @override
  String get missedCall => 'مكالمة فائتة';

  @override
  String get callDeclined => 'تم رفض المكالمة';

  @override
  String get youDeclined => 'رفضت المكالمة';

  @override
  String get callNotAllowed => 'لم يعد الاتصال ممكنًا';

  @override
  String get callCanceled => 'أُلغيت المكالمة';

  @override
  String get timeLimit => 'انتهت الدقائق الستون وانتهت المكالمة';

  @override
  String get endedNotAllowed =>
      'انتهت المكالمة: لم تعد المكالمات الصوتية ممكنة';

  @override
  String get callEnded => 'انتهت المكالمة';

  @override
  String get messageDeleted => 'تم حذف الرسالة';

  @override
  String get photo => 'صورة';

  @override
  String get tonightTable => 'طاولة الليلة';

  @override
  String get blockRequestPending => 'اقبل طلب المراسلة قبل الرد.';

  @override
  String get blockDeclined => 'لم يقبل هذا الشخص طلب المراسلة.';

  @override
  String get blockMuted =>
      'تم كتمك في هذه المجموعة، لذا لا يمكنك الكتابة الآن.';

  @override
  String get blockAdminsOnly => 'لا يكتب في هذه المحادثة إلا المشرفون.';

  @override
  String get blockTableClosed =>
      'أُغلقت الطاولة؛ يمكنك قراءة الرسائل دون كتابة رسائل جديدة.';

  @override
  String get blockBlocked => 'لا يمكن الكتابة هنا بسبب الحظر.';

  @override
  String get blockMatchEnded => 'أُغلقت هذه المحادثة لانتهاء التوافق.';

  @override
  String get blockMatchLocked =>
      'تحتاج باقة «محادثة التوافق» لمراسلة من توافقت معه. قراءة الرسائل مجانية.';

  @override
  String get blockTeammateLocked =>
      'تحتاج باقة «زميل الفريق» لمراسلة زميلك. قراءة الرسائل مجانية.';

  @override
  String get blockNotAllowed =>
      'أصبحت الرسائل الخاصة الآن للمتوافقين وزملاء الفريق فقط. يمكنك قراءة رسائلك القديمة.';

  @override
  String get blockOther => 'لا يمكنك الكتابة في هذه المحادثة الآن.';

  @override
  String get hiddenUser => 'مستخدم GWAY';

  @override
  String get voiceCalls => 'المكالمات الصوتية';

  @override
  String get voiceCallsHeadline =>
      'تحدّث صوتيًا مع من توافقت معهم وزملاء فريقك';

  @override
  String voiceCallsIntro(int minutes) {
    return 'تتيح لك المكالمات الصوتية الاتصال بمن توافقت معهم وزملاء فريقك من المحادثة الخاصة. ليست متاحة للجميع: تطلبها من مجموعة أنت عضو فيها، ويفعّلها مالكها أو مشرفها. لا تُسجَّل المكالمات ولا يُستمع إليها؛ وتستمر المكالمة $minutes دقيقة كحدّ أقصى.';
  }

  @override
  String get status => 'الحالة';

  @override
  String get notRequested => 'لم يُطلب';

  @override
  String get underReview => 'قيد المراجعة';

  @override
  String get statusOn => 'مفعّل';

  @override
  String get statusOff => 'متوقّف';

  @override
  String get notRequestedYet => 'لم تطلبه بعد.';

  @override
  String requestedFrom(String group) {
    return 'وصل طلبك إلى مشرفي $group. سيصلك إشعار عند اتخاذ القرار.';
  }

  @override
  String get requestedFromGroup =>
      'وصل طلبك إلى مشرفي المجموعة. سيصلك إشعار عند اتخاذ القرار.';

  @override
  String activeFrom(String group) {
    return 'مكالماتك الصوتية مفعّلة ($group). اتصل بمن توافقت معهم وزملائك عبر رمز الهاتف أعلى المحادثة؛ ويجب أن يكون الإذن مفعّلًا لديهم أيضًا.';
  }

  @override
  String get active =>
      'مكالماتك الصوتية مفعّلة. اتصل بمن توافقت معهم وزملائك عبر رمز الهاتف أعلى المحادثة؛ ويجب أن يكون الإذن مفعّلًا لديهم أيضًا.';

  @override
  String get declined => 'لم تتم الموافقة على طلبك حاليًا.';

  @override
  String get revokedLeftGroup =>
      'توقّفت مكالماتك الصوتية لأنك غادرت المجموعة التي منحتها. يمكنك طلبها مجددًا من مجموعة أخرى.';

  @override
  String get revoked => 'تم إيقاف مكالماتك الصوتية.';

  @override
  String reasonLine(String reason) {
    return 'السبب: $reason';
  }

  @override
  String yourNote(String note) {
    return 'ملاحظتك: $note';
  }

  @override
  String waitUntil(String date) {
    return 'يمكنك الطلب مجددًا بعد $date.';
  }

  @override
  String get requestSent => 'تم إرسال طلبك.';

  @override
  String get joinGroupFirst =>
      'يفعّل مالكو المجموعات ومشرفوها المكالمات الصوتية. انضم إلى مجموعة أولًا لتطلبها.';

  @override
  String get requestToGroup => 'المجموعة التي يُرسل إليها الطلب';

  @override
  String get noteOptional => 'ملاحظة (اختياري)';

  @override
  String get noteHint => 'يمكنك كتابة سبب رغبتك في المكالمات باختصار.';

  @override
  String get request => 'طلب';

  @override
  String get lockScreenCalls => 'المكالمات على شاشة القفل';

  @override
  String get lockScreenHint =>
      'اسمح لـGWAY بالرنين بملء الشاشة عندما يكون هاتفك مقفلًا.';

  @override
  String get allow => 'السماح';

  @override
  String get callInfoFailed => 'تعذّر تحميل المكالمة. تحقّق من اتصالك.';

  @override
  String get tapEndToHangUp => 'انقر «إنهاء» لإغلاق المكالمة.';

  @override
  String get callNotFound => 'لم يُعثر على المكالمة.';

  @override
  String get close => 'إغلاق';

  @override
  String callLimitNote(int minutes) {
    return 'تستمر المكالمة $minutes دقيقة كحدّ أقصى ولا تُسجَّل.';
  }

  @override
  String get audioFailed =>
      'تعذّر توصيل الصوت. تحقّق من اتصالك وحاول مرة أخرى.';

  @override
  String get reconnect => 'إعادة الاتصال';

  @override
  String get incoming => 'يتصل بك…';

  @override
  String get calling => 'جارٍ الاتصال…';

  @override
  String get connecting => 'جارٍ الاتصال…';

  @override
  String get answerCall => 'ردّ';

  @override
  String get mute => 'كتم';

  @override
  String get unmute => 'إلغاء الكتم';

  @override
  String get end => 'إنهاء';

  @override
  String get speaker => 'مكبّر الصوت';

  @override
  String get peerUnencrypted =>
      'تطبيق الطرف الآخر قديم؛ صوته غير مشفّر ولذا لا يُشغَّل. اطلب منه تحديث التطبيق.';

  @override
  String get encrypting => 'جارٍ إنشاء اتصال مشفّر…';

  @override
  String e2eeCode(String code) {
    return 'مشفّر بين الطرفين. رمز الأمان $code';
  }

  @override
  String get e2ee => 'مشفّر بين الطرفين';

  @override
  String get codeMatchHint =>
      'إذا تطابق هذا الرمز مع رمز الطرف الآخر فلا أحد يستطيع التنصّت.';

  @override
  String get micFailed => 'تعذّر تشغيل الميكروفون. تحقّق من إذن الميكروفون.';

  @override
  String get chatNotFound => 'لم يُعثر على المحادثة أو لم تعد تستطيع رؤيتها.';

  @override
  String get backToMessages => 'العودة إلى الرسائل';

  @override
  String get cantCallNow => 'لا يمكن الاتصال الآن.';

  @override
  String get voiceCall => 'مكالمة صوتية';

  @override
  String get groupChatAdminsOnly => 'محادثة المجموعة · يكتب المشرفون فقط';

  @override
  String get groupChat => 'محادثة المجموعة';

  @override
  String smallTableMembers(int count) {
    return 'طاولة صغيرة · $count أشخاص';
  }

  @override
  String get adminsOnlyOn =>
      'لا يكتب في هذه المحادثة الآن إلا المالك والمشرفون.';

  @override
  String get adminsOnlyOff =>
      'يمكن لكل أعضاء المجموعة الكتابة في هذه المحادثة الآن.';

  @override
  String get chatSettings => 'إعدادات المحادثة';

  @override
  String get adminsOnlyToggle => 'يكتب المشرفون فقط';

  @override
  String get sendingPhoto => '📷 جارٍ إرسال الصورة…';

  @override
  String get requestPendingNote =>
      'أُرسل طلب المراسلة. لن ترى إن قُرئ حتى يُقبل.';

  @override
  String get groupChatEmpty =>
      'لا توجد رسائل في محادثة المجموعة بعد. اكتب أول رسالة.';

  @override
  String get chatEmpty => 'لا توجد رسائل بعد. اكتب أول رسالة.';

  @override
  String get startWriting => 'ابدأ الكتابة';

  @override
  String get sending => 'جارٍ الإرسال…';

  @override
  String get seen => 'تمت المشاهدة';

  @override
  String get sent => 'أُرسلت';

  @override
  String get seePackage => 'عرض الباقة';

  @override
  String get today => 'اليوم';

  @override
  String get messageRemoved => 'تمت إزالة هذه الرسالة.';

  @override
  String get thisMessageDeleted => 'تم حذف هذه الرسالة.';

  @override
  String get messageOptions => 'خيارات الرسالة';

  @override
  String profileOf(String name) {
    return 'الملف الشخصي لـ$name';
  }

  @override
  String get you => 'أنت';

  @override
  String get copy => 'نسخ';

  @override
  String get copied => 'تم نسخ الرسالة.';

  @override
  String get deleteForAll => 'حذف للجميع';

  @override
  String get report => 'إبلاغ';

  @override
  String get deleteForAllTitle => 'حذف الرسالة للجميع؟';

  @override
  String get deleteForAllBody =>
      'سيرى الجميع «تم حذف هذه الرسالة». لا يمكن التراجع.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get requestDeleted => 'تم حذف طلب المراسلة.';

  @override
  String wantsToMessage(String name) {
    return 'يريد $name مراسلتك. إن قبلت يمكنكما الدردشة وسيرى متى قرأت الرسائل.';
  }

  @override
  String get accept => 'قبول';

  @override
  String get removePhoto => 'إزالة الصورة';

  @override
  String get addPhoto => 'إضافة صورة';

  @override
  String get writeMessage => 'اكتب رسالة';

  @override
  String get send => 'إرسال';

  @override
  String get messages => 'الرسائل';

  @override
  String get chats => 'المحادثات';

  @override
  String get requests => 'الطلبات';

  @override
  String requestsCount(int count) {
    return 'الطلبات ($count)';
  }

  @override
  String get noChats =>
      'لا توجد محادثات بعد. يمكنك مراسلة من توافقت معهم وزملاء فريقك.';

  @override
  String get findPeople => 'ابحث عن أشخاص';

  @override
  String get oldRequestsNote =>
      'تبقى طلبات المراسلة القديمة هنا. أصبحت الرسائل الخاصة للمتوافقين وزملاء الفريق فقط، ولن تصل طلبات جديدة.';

  @override
  String get noRequests => 'لا توجد طلبات مراسلة معلّقة.';

  @override
  String get backToChats => 'العودة إلى المحادثات';

  @override
  String get callRequests => 'طلبات المكالمات الصوتية';

  @override
  String noPendingWithActive(int count) {
    return 'لا طلبات معلّقة · المفعّلة: $count';
  }

  @override
  String pendingCount(int count) {
    return 'بانتظار الرد: $count';
  }

  @override
  String get pending => 'المعلّقة';

  @override
  String get activeTab => 'المفعّلة';

  @override
  String get requestsOwnersOnly =>
      'لا يرى طلبات المكالمات إلا المالك والمشرفون.';

  @override
  String get goBack => 'رجوع';

  @override
  String noPendingFor(String group) {
    return 'لا طلبات معلّقة. ستظهر هنا طلبات أعضاء $group.';
  }

  @override
  String get noActive => 'لم تمنح هذه المجموعة أي إذن للمكالمات الصوتية.';

  @override
  String get refresh => 'تحديث';

  @override
  String get grantHint =>
      'بهذا الإذن يمكن للشخص الاتصال بكل من توافق معهم وزملائه. لا تُسجَّل المكالمات، وينتهي الإذن إن غادر المجموعة.';

  @override
  String get granted => 'تم تفعيل المكالمات الصوتية.';

  @override
  String get turnedOff => 'تم إيقاف المكالمات الصوتية.';

  @override
  String theirNote(String note) {
    return 'ملاحظته: $note';
  }

  @override
  String get turnOff => 'إيقاف';

  @override
  String get turnOn => 'تفعيل';

  @override
  String get rankOnlyGrant =>
      'رتبته مساوية لرتبتك أو أعلى، لذا يمكنك الموافقة على هذا الطلب فقط.';

  @override
  String get rankCannotRevoke =>
      'رتبته مساوية لرتبتك أو أعلى، لذا لا يمكنك إيقاف هذا الإذن.';

  @override
  String get declineRequest => 'رفض الطلب';

  @override
  String get turnOffCalls => 'إيقاف المكالمات الصوتية';

  @override
  String get declineHint => 'سيرى السبب ويمكنه الطلب مجددًا بعد 7 أيام.';

  @override
  String get revokeHint =>
      'تنتهي المكالمة الجارية فورًا. سيرى السبب ويمكنه الطلب مجددًا بعد 7 أيام.';

  @override
  String get reason => 'السبب';

  @override
  String get reasonMin3 => 'يجب أن يتكوّن السبب من 3 أحرف على الأقل.';

  @override
  String get yesterday => 'أمس';

  @override
  String get sendMessage => 'إرسال رسالة';

  @override
  String get groupChatMembersOnly => 'لا يرى محادثة المجموعة إلا أعضاؤها.';
}
