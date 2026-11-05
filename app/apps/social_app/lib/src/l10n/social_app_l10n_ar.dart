// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'social_app_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class SocialAppL10nAr extends SocialAppL10n {
  SocialAppL10nAr([String locale = 'ar']) : super(locale);

  @override
  String get posts => 'المنشورات';

  @override
  String get newPost => 'منشور جديد';

  @override
  String get noOwnPosts => 'لم تشارك أي منشور بعد. شارك أول صورة أو فيديو.';

  @override
  String get noPosts => 'لا توجد منشورات بعد.';

  @override
  String get shareFirstOwn => 'شارك أول منشور لك';

  @override
  String get groupFirstPost => 'كن أول من ينشر في موجز المجموعة.';

  @override
  String get groupNoPosts => 'لا توجد منشورات في هذه المجموعة بعد.';

  @override
  String get shareFirstGroup => 'انشر أول منشور';

  @override
  String get groupNotFound => 'المجموعة غير موجودة.';

  @override
  String get memoriesEmpty =>
      'لم تُشارك أي ذكريات بعد. يمكن للحضور إضافة صورهم هنا.';

  @override
  String get plan => 'الباقة';

  @override
  String get payment => 'الدفع';

  @override
  String get onlyOwnerBilling => 'يمكن لمالك المجموعة فقط إدارة الباقات.';

  @override
  String get backToGroup => 'العودة إلى المجموعة';

  @override
  String get writeSupportAboutGroup => 'راسل فريق المنصة بشأن هذه المجموعة';

  @override
  String get search => 'بحث';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get goodNight => 'تصبح على خير';

  @override
  String get goodMorning => 'صباح الخير';

  @override
  String get goodAfternoon => 'طاب يومك';

  @override
  String get goodEvening => 'مساء الخير';

  @override
  String greetingName(String greeting, String name) {
    return '$greeting يا $name';
  }

  @override
  String get tabToday => 'اليوم';

  @override
  String get tabGroups => 'المجموعات';

  @override
  String get tabCalendar => 'التقويم';

  @override
  String get tabMe => 'أنا';

  @override
  String get tonightSay => 'متفرّغ؟ أخبرنا وأنشئ طاولة';

  @override
  String get tonightTableSet => 'طاولتك جاهزة';

  @override
  String get tonightInvited => 'لديك دعوة إلى طاولة';

  @override
  String tonightFreeWithYou(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count شخصًا متفرّغًا مثلك',
      few: '$count أشخاص متفرّغون مثلك',
      two: 'شخصان متفرّغان مثلك',
      one: 'شخص واحد متفرّغ مثلك',
    );
    return '$_temp0';
  }

  @override
  String get tonightFreeUntil => 'أنت متفرّغ · حتى 4:00 صباحًا';

  @override
  String tonightFreeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count شخصًا متفرّغًا الليلة',
      few: '$count أشخاص متفرّغون الليلة',
      two: 'شخصان متفرّغان الليلة',
      one: 'شخص واحد متفرّغ الليلة',
    );
    return '$_temp0';
  }

  @override
  String get upcomingNone => 'خطط مجموعاتك';

  @override
  String upcomingMine(int count, int mine) {
    return '$count خطط · $mine مشاركة';
  }

  @override
  String upcomingCount(int count) {
    return '$count خطط، 60 يومًا';
  }

  @override
  String get forToday => 'لليوم';

  @override
  String get tonight => 'الليلة';

  @override
  String get upcoming => 'القادمة';

  @override
  String get share => 'مشاركة';

  @override
  String get post => 'منشور';

  @override
  String get postHint => 'حتى 10 صور أو مقاطع فيديو';

  @override
  String get story => 'قصة';

  @override
  String get storyHint => 'تظهر لمدة 24 ساعة';

  @override
  String get group => 'مجموعة';

  @override
  String get groupHint => 'أنشئ مجتمعك الخاص';

  @override
  String get create => 'إنشاء';

  @override
  String get messages => 'الرسائل';

  @override
  String get matching => 'التوافق';

  @override
  String get myGroups => 'مجموعاتي';

  @override
  String get pageNotFound =>
      'لم نعثر على هذه الصفحة. ربما الرابط قديم أو خاطئ.';

  @override
  String get backHome => 'العودة إلى الرئيسية';

  @override
  String get groupsLeague => 'دوري المجموعات';

  @override
  String get exploreOnMap => 'استكشف على الخريطة';

  @override
  String get yearMenu => 'ملخّص العام وخريطة استكشافي ومن تعرّفت إليهم';

  @override
  String get yearSummary => 'ملخّص العام';

  @override
  String get yearSummaryHint => 'لقاءاتك هذا العام في بطاقة قابلة للمشاركة';

  @override
  String get explorationMap => 'خريطة استكشافي';

  @override
  String get explorationMapHint => 'محافظات الفعاليات التي حضرتها';

  @override
  String get metPeople => 'من تعرّفت إليهم';

  @override
  String get metPeopleHint => 'الأشخاص الذين صافحتهم في الفعاليات';

  @override
  String get findTeammates => 'ابحث عن زملاء فريق';

  @override
  String get saved => 'المحفوظات';

  @override
  String get gateError =>
      'تعذّر تحميل بياناتك. تحقّق من الاتصال وحاول مرة أخرى.';

  @override
  String get searchPeople => 'ابحث عن أشخاص';

  @override
  String get clearSearch => 'مسح البحث';

  @override
  String get settings => 'الإعدادات';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get teammatePrefs => 'تفضيلات زملاء الفريق';

  @override
  String get matchProfile => 'ملف التوافق';

  @override
  String get voiceCalls => 'المكالمات الصوتية';

  @override
  String get blockedAccounts => 'الحسابات المحظورة';

  @override
  String get storyArchive => 'أرشيف القصص';

  @override
  String get notificationPrefs => 'تفضيلات الإشعارات';

  @override
  String get mySanctions => 'عقوباتي في المجموعات';

  @override
  String get userGuide => 'دليل الاستخدام';

  @override
  String get supportFeedback => 'الدعم والملاحظات';

  @override
  String newReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ردًا جديدًا',
      few: '$count ردود جديدة',
      two: 'ردّان جديدان',
      one: 'رد جديد',
    );
    return '$_temp0';
  }

  @override
  String get twoFactor => 'التحقّق بخطوتين';

  @override
  String get legalDocuments => 'المستندات القانونية';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get nowPrivate => 'أصبح حسابك خاصًا الآن.';

  @override
  String get nowPublic =>
      'أصبح حسابك عامًا الآن، وتمت الموافقة على الطلبات المعلّقة.';

  @override
  String get privateAccount => 'حساب خاص';

  @override
  String get privateAccountHint =>
      'عند التفعيل، لا يرى منشوراتك وقصصك إلا المتابعون الذين توافق عليهم.';

  @override
  String get groupsNowPublic => 'أصبحت مجموعاتك ظاهرة للجميع في ملفك الشخصي.';

  @override
  String get groupsNowMembers =>
      'أصبحت مجموعاتك ظاهرة فقط لأعضاء المجموعة نفسها.';

  @override
  String get showGroups => 'إظهار مجموعاتي في ملفي الشخصي';

  @override
  String get showGroupsHint =>
      'عند الإيقاف، لا يرى عضويتك في مجموعة إلا أعضاؤها، ولا يراها مديرو المجموعات الأخرى.';

  @override
  String get language => 'اللغة';

  @override
  String get games => 'الألعاب';

  @override
  String get chessHint => 'مباريات سريعة، تحدَّ أصدقاءك واصعد في ترتيب Elo.';
}
