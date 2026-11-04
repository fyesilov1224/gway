// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'groups_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class GroupsL10nAr extends GroupsL10n {
  GroupsL10nAr([String locale = 'ar']) : super(locale);

  @override
  String get unsupportedImage =>
      'نوع الملف غير مدعوم. اختر JPEG أو PNG أو WebP.';

  @override
  String get joinOpen => 'انضمام مفتوح';

  @override
  String get joinOpenHint => 'يمكن لأي شخص الانضمام مباشرة.';

  @override
  String get joinRequest => 'الانضمام بطلب';

  @override
  String get joinRequestHint => 'يوافق المشرفون على طلبات الانضمام.';

  @override
  String get joinInvite => 'بالدعوة فقط';

  @override
  String get joinInviteHint => 'لا يمكن الانضمام إلا للمدعوين.';

  @override
  String get roleOwner => 'مالك المجموعة';

  @override
  String get roleAdmin => 'مشرف';

  @override
  String get roleDiscipline => 'لجنة الانضباط';

  @override
  String get roleModerator => 'مشرف محتوى';

  @override
  String get roleMember => 'عضو';

  @override
  String get handleMin => 'يجب أن يتكوّن عنوان المجموعة من 3 أحرف على الأقل.';

  @override
  String get handleChars =>
      'استخدم أحرفًا صغيرة وأرقامًا وشرطات سفلية ونقاطًا فقط.';

  @override
  String get handleDots =>
      'لا يمكن أن يبدأ أو ينتهي بنقطة أو يحتوي نقطتين متتاليتين.';

  @override
  String get nameMin => 'يجب أن يتكوّن اسم المجموعة من 3 أحرف على الأقل.';

  @override
  String nameMax(int max) {
    return 'يمكن أن يتكوّن اسم المجموعة من $max حرفًا كحدّ أقصى.';
  }

  @override
  String get httpsOnly => 'أدخل عنوانًا يبدأ بـ https://.';

  @override
  String get createGroup => 'إنشاء مجموعة';

  @override
  String get groupInfo => 'بيانات المجموعة';

  @override
  String get groupInfoHint =>
      'يمكنك إضافة الشعار والغلاف والقواعد والروابط بعد إنشاء المجموعة.';

  @override
  String get groupName => 'اسم المجموعة';

  @override
  String get about => 'نبذة';

  @override
  String get aboutHint => 'ماذا تفعل مجموعتكم ومن يمكنه الانضمام؟';

  @override
  String get joining => 'الانضمام';

  @override
  String get changeLater => 'يمكنك تغيير ذلك لاحقًا.';

  @override
  String get createTheGroup => 'إنشاء المجموعة';

  @override
  String get editGroup => 'تعديل المجموعة';

  @override
  String get noEditPermission => 'ليست لديك صلاحية تعديل هذه المجموعة.';

  @override
  String get backToGroup => 'العودة إلى المجموعة';

  @override
  String get save => 'حفظ';

  @override
  String get logoAndCover => 'الشعار والغلاف';

  @override
  String get imageHint => 'JPEG أو PNG أو WebP · حتى 5 ميغابايت';

  @override
  String get logo => 'الشعار';

  @override
  String get cover => 'الغلاف';

  @override
  String groupHandle(String handle) {
    return 'عنوان المجموعة: ‎@$handle';
  }

  @override
  String get rules => 'القواعد';

  @override
  String get rulesHint => 'ما تتوقّعه من الأعضاء، قاعدة في كل سطر.';

  @override
  String get links => 'الروابط';

  @override
  String linksHint(int max) {
    return 'الموقع وحسابات التواصل الاجتماعي. حتى $max.';
  }

  @override
  String get enterLabel => 'أدخل تسمية.';

  @override
  String get label => 'التسمية';

  @override
  String get address => 'العنوان';

  @override
  String get removeLink => 'إزالة الرابط';

  @override
  String get addLink => 'إضافة رابط';

  @override
  String get cancel => 'إلغاء';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get deleteGroup => 'حذف المجموعة';

  @override
  String get deleteGroupBody =>
      'تُحذف المجموعة والعضويات والأدوار والطلبات والدعوات نهائيًا. لا تُستردّ المدة المتبقية من الباقة.';

  @override
  String deleteGroupNamed(String name) {
    return 'حذف $name';
  }

  @override
  String changeImage(String label) {
    return 'تغيير $label';
  }

  @override
  String addImage(String label) {
    return 'إضافة $label';
  }

  @override
  String get remove => 'إزالة';

  @override
  String get deleteForever => 'حذف المجموعة نهائيًا';

  @override
  String deleteConfirm(String handle) {
    return 'لا يمكن التراجع عن ذلك. للتأكيد، اكتب عنوان المجموعة: $handle';
  }

  @override
  String get delete => 'حذف';

  @override
  String get group => 'المجموعة';

  @override
  String get share => 'مشاركة';

  @override
  String shareText(String name) {
    return 'تعرّف إلى $name على GWAY:';
  }

  @override
  String get moreOptions => 'خيارات أخرى';

  @override
  String get leaveGroup => 'مغادرة المجموعة';

  @override
  String get groupNotFound => 'لم يُعثر على هذه المجموعة أو لم تعد ظاهرة.';

  @override
  String get backToGroups => 'العودة إلى المجموعات';

  @override
  String leaveConfirm(String name) {
    return 'هل تريد مغادرة $name؟ إذا كان لديك دور في المجموعة فسيُزال أيضًا.';
  }

  @override
  String get leave => 'مغادرة';

  @override
  String leftGroup(String name) {
    return 'غادرت $name.';
  }

  @override
  String get suspendedNotice =>
      'علّق فريق المنصة هذه المجموعة. لا يراها خلال التعليق إلا أعضاؤها.';

  @override
  String founded(String date) {
    return 'تأسّست في $date';
  }

  @override
  String joinRequestsPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طلب انضمام بانتظار الموافقة.',
      few: '$count طلبات انضمام بانتظار الموافقة.',
      two: 'طلبا انضمام بانتظار الموافقة.',
      one: 'طلب انضمام واحد بانتظار الموافقة.',
    );
    return '$_temp0';
  }

  @override
  String get review => 'مراجعة';

  @override
  String get requestSent => 'تم إرسال طلب انضمامك.';

  @override
  String get youAreMember => 'أنت عضو';

  @override
  String get join => 'انضمام';

  @override
  String joined(String name) {
    return 'انضممت إلى $name.';
  }

  @override
  String get sendJoinRequest => 'طلب الانضمام';

  @override
  String get requestSentShort => 'تم إرسال الطلب';

  @override
  String get withdrawRequest => 'سحب الطلب';

  @override
  String get withdrawConfirm => 'هل تريد سحب طلب الانضمام؟';

  @override
  String get undo => 'سحب';

  @override
  String get requestWithdrawn => 'تم سحب طلب انضمامك.';

  @override
  String get decline => 'رفض';

  @override
  String get inviteDeclined => 'تم رفض الدعوة.';

  @override
  String get acceptInvite => 'قبول الدعوة';

  @override
  String followOn(String name) {
    return 'ستظهر منشورات $name في موجزك.';
  }

  @override
  String get followOff => 'توقّفت عن متابعة المجموعة.';

  @override
  String get following => 'تتابعها';

  @override
  String get follow => 'متابعة';

  @override
  String get managementTeam => 'فريق الإدارة';

  @override
  String allMembers(int count) {
    return 'كل الأعضاء ($count)';
  }

  @override
  String get groups => 'المجموعات';

  @override
  String get discover => 'استكشاف';

  @override
  String get myGroups => 'مجموعاتي';

  @override
  String get plans => 'الباقات';

  @override
  String get searchHint => 'ابحث باسم المجموعة أو عنوانها';

  @override
  String get clearSearch => 'مسح البحث';

  @override
  String get all => 'الكل';

  @override
  String get noMatch => 'لا توجد مجموعات تطابق بحثك.';

  @override
  String get clearFilters => 'مسح عوامل التصفية';

  @override
  String get noGroupsYet => 'لا توجد مجموعات بعد. أنشئ أول مجموعة.';

  @override
  String get showMore => 'عرض المزيد';

  @override
  String get notJoinedYet => 'لم تنضم إلى أي مجموعة بعد.';

  @override
  String get discoverGroups => 'استكشف المجموعات';

  @override
  String get plansHint =>
      'يشتري مالكو المجموعات الباقات. أنشئ مجموعتك واختر باقتها.';

  @override
  String get yourInvitations => 'دعواتك';

  @override
  String get invitationsHint => 'دعتك هذه المجموعات إلى الانضمام.';

  @override
  String invitedBy(String name) {
    return 'دعاك $name';
  }

  @override
  String get linkCopied => 'تم نسخ الرابط.';

  @override
  String inviteShareText(String name) {
    return 'انضم إلى $name على GWAY:';
  }

  @override
  String get revokeLinkTitle => 'إلغاء الرابط؟';

  @override
  String get revokeLinkBody =>
      'لن يتمكّن أحد من الانضمام بهذا الرابط بعد الآن. يبقى من انضمّوا أعضاء.';

  @override
  String get revoke => 'إلغاء';

  @override
  String get inviteLink => 'رابط الدعوة';

  @override
  String get inviteLinkHint =>
      'شاركه على واتساب أو إنستغرام. من يفتح الرابط ينضم مباشرة مهما كان نوع الانضمام.';

  @override
  String get createLink => 'إنشاء رابط';

  @override
  String validUntil(String date) {
    return 'حتى $date';
  }

  @override
  String peopleJoined(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'انضم $count شخصًا',
      few: 'انضم $count أشخاص',
      two: 'انضم شخصان',
      one: 'انضم شخص واحد',
    );
    return '$_temp0';
  }

  @override
  String peopleJoinedOf(int count, int max) {
    return 'انضم $count من $max';
  }

  @override
  String get newInviteLink => 'رابط دعوة جديد';

  @override
  String get validity => 'مدة الصلاحية';

  @override
  String days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count يومًا',
      few: '$count أيام',
      two: 'يومان',
      one: 'يوم واحد',
    );
    return '$_temp0';
  }

  @override
  String get howMany => 'كم شخصًا يمكنه الانضمام؟';

  @override
  String get unlimited => 'غير محدود';

  @override
  String people(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count شخصًا',
      few: '$count أشخاص',
      two: 'شخصان',
      one: 'شخص واحد',
    );
    return '$_temp0';
  }

  @override
  String get createAndShare => 'إنشاء ومشاركة';

  @override
  String get invitation => 'دعوة';

  @override
  String get linkInvalid =>
      'لم يعد رابط الدعوة هذا صالحًا. يمكنك طلب رابط جديد من مشرف المجموعة.';

  @override
  String get seeGroup => 'عرض المجموعة';

  @override
  String get invitedToGroup => 'تمت دعوتك إلى هذه المجموعة.';

  @override
  String get joinGroup => 'الانضمام إلى المجموعة';

  @override
  String get members => 'الأعضاء';

  @override
  String get requests => 'الطلبات';

  @override
  String get invitations => 'الدعوات';

  @override
  String get roles => 'الأدوار';

  @override
  String get openCase => 'فتح ملف انضباطي';

  @override
  String get report => 'إبلاغ';

  @override
  String membersVisibility(int shown, int total) {
    return 'لا يرى قائمة الأعضاء كاملة إلا أعضاء المجموعة. هنا: فريق الإدارة و$shown أشخاص جعلوا مجموعاتهم عامة؛ يبلغ عدد الأعضاء $total عضوًا.';
  }

  @override
  String optionsFor(String name) {
    return 'خيارات لـ$name';
  }

  @override
  String get transferOwnership => 'نقل الملكية';

  @override
  String transferBody(String group, String person) {
    return 'ستنتقل ملكية $group إلى $person. ستبقى عضوًا عاديًا ولا يمكنك التراجع عن ذلك.';
  }

  @override
  String get transfer => 'نقل';

  @override
  String transferred(String name) {
    return 'تم نقل الملكية إلى $name.';
  }

  @override
  String get hintAdmin => 'يعدّل المجموعة ويدير طلبات الانضمام والدعوات.';

  @override
  String get hintDiscipline => 'يراجع ملفات الشكاوى ويقرّر العقوبات.';

  @override
  String get hintModerator => 'يراقب المحتوى والتعليقات.';

  @override
  String personJoined(String name) {
    return 'انضم $name إلى المجموعة.';
  }

  @override
  String get requestDeclined => 'تم رفض الطلب.';

  @override
  String get noPendingRequests => 'لا توجد طلبات انضمام معلّقة.';

  @override
  String get refresh => 'تحديث';

  @override
  String get approve => 'موافقة';

  @override
  String get inviteSent => 'تم إرسال الدعوة.';

  @override
  String get inviteByUsername => 'الدعوة باسم المستخدم';

  @override
  String get invite => 'دعوة';

  @override
  String get noPendingInvites => 'لا توجد دعوات معلّقة.';

  @override
  String memberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عضوًا',
      few: '$count أعضاء',
      two: 'عضوان',
      one: 'عضو واحد',
    );
    return '$_temp0';
  }

  @override
  String get suspended => 'معلّقة';

  @override
  String get groupsSection => 'المجموعات';

  @override
  String get groupsOwnHint =>
      'لا يرى مجموعاتك إلا أعضاء المجموعة نفسها. يمكنك جعلها عامة من الإعدادات.';

  @override
  String get groupsOtherHint =>
      'تظهر فقط المجموعات المشتركة والمجموعات التي يساهم في إدارتها.';

  @override
  String get noGroupsToShow => 'لا توجد مجموعات لعرضها.';

  @override
  String get handleTaken => 'عنوان المجموعة هذا مأخوذ. جرّب عنوانًا آخر.';

  @override
  String get groupAddress => 'عنوان المجموعة';

  @override
  String get groupAddressHint => 'عنوان صفحة مجموعتك. لا يمكن تغييره لاحقًا.';

  @override
  String get available => 'متاح';

  @override
  String get taken => 'مأخوذ';

  @override
  String get notSpecified => 'غير محدّد';

  @override
  String get provinceOptional => 'المحافظة (اختياري)';

  @override
  String get provinceHint => 'تظهر المجموعة في هذه المحافظة على الخريطة.';

  @override
  String get chooseCategory => 'اختر فئة.';

  @override
  String get category => 'الفئة';
}
