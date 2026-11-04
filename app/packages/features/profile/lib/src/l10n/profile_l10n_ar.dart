// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'profile_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class ProfileL10nAr extends ProfileL10n {
  ProfileL10nAr([String locale = 'ar']) : super(locale);

  @override
  String get unsupportedImage =>
      'نوع الملف غير مدعوم. اختر JPEG أو PNG أو WebP.';

  @override
  String get usernameTaken => 'اسم المستخدم هذا مأخوذ. جرّب اسمًا آخر.';

  @override
  String get checkInput => 'تحقّق من البيانات التي أدخلتها.';

  @override
  String get usernameReserved =>
      'لا يمكن استخدام اسم المستخدم هذا. جرّب اسمًا آخر.';

  @override
  String get usernameCooldown =>
      'يمكنك تغيير اسم المستخدم مرة واحدة فقط كل 30 يومًا.';

  @override
  String get maxInterests10 => 'يمكنك اختيار 10 اهتمامات كحدّ أقصى.';

  @override
  String get levelBeginner => 'مبتدئ';

  @override
  String get levelBeginnerHint => 'بدأت للتو';

  @override
  String get levelIntermediate => 'متوسط';

  @override
  String get levelIntermediateHint => 'أمارسه بانتظام';

  @override
  String get levelAdvanced => 'متقدّم';

  @override
  String get levelAdvancedHint => 'لديّ خبرة';

  @override
  String get slotWeekdayMorning => 'صباح أيام الأسبوع';

  @override
  String get slotWeekdayNoon => 'ظهر أيام الأسبوع';

  @override
  String get slotWeekdayEvening => 'مساء أيام الأسبوع';

  @override
  String get slotWeekendMorning => 'صباح عطلة نهاية الأسبوع';

  @override
  String get slotWeekendAfternoon => 'بعد ظهر عطلة نهاية الأسبوع';

  @override
  String get slotWeekendEvening => 'مساء عطلة نهاية الأسبوع';

  @override
  String get partMorning => 'صباحًا';

  @override
  String get partNoon => 'ظهرًا';

  @override
  String get partEvening => 'مساءً';

  @override
  String get goalFun => 'الاستمتاع';

  @override
  String get goalFitness => 'الحفاظ على اللياقة';

  @override
  String get goalCompetition => 'الاستعداد للمنافسات';

  @override
  String get goalLearning => 'تعلّم أشياء جديدة';

  @override
  String get goalMentoring => 'مشاركة خبرتي';

  @override
  String get goalSocial => 'التعرّف إلى أشخاص جدد';

  @override
  String get freqMonthly => 'بضع مرات في الشهر';

  @override
  String get freqWeekly => 'مرة في الأسبوع';

  @override
  String get freqFewWeekly => '2–3 مرات في الأسبوع';

  @override
  String get freqDaily => 'كل يوم تقريبًا';

  @override
  String get sizePair => 'ثنائي';

  @override
  String get sizeSmall => 'مجموعة صغيرة (3–6)';

  @override
  String get sizeLarge => 'مجموعة كبيرة';

  @override
  String get looking => 'يبحث عن فريق';

  @override
  String lookingWithLevel(String level) {
    return 'يبحث عن فريق · $level';
  }

  @override
  String reasonActivities(String list) {
    return 'النشاط نفسه: $list';
  }

  @override
  String reasonInterests(String list) {
    return 'اهتمامات مشتركة: $list';
  }

  @override
  String get reasonProvince => 'أنتما في المحافظة نفسها';

  @override
  String reasonGroup(String group) {
    return 'مجموعة مشتركة: $group';
  }

  @override
  String reasonGroups(int count) {
    return '$count مجموعات مشتركة';
  }

  @override
  String reasonLevel(String level) {
    return 'المستوى نفسه: $level';
  }

  @override
  String reasonTimes(String list) {
    return 'وقت مناسب: $list';
  }

  @override
  String reasonGoals(String list) {
    return 'أهداف مشتركة: $list';
  }

  @override
  String get reasonFrequency => 'تريدان اللقاء بالوتيرة نفسها';

  @override
  String get hasVehicle => 'لديه مركبة';

  @override
  String get hasEquipment => 'لديه معدّاته الخاصة';

  @override
  String get usernameRequired => 'اختر اسم مستخدم.';

  @override
  String usernameMin(int min) {
    return 'يجب أن يتكوّن اسم المستخدم من $min أحرف على الأقل.';
  }

  @override
  String usernameMax(int max) {
    return 'يمكن أن يتكوّن اسم المستخدم من $max حرفًا كحدّ أقصى.';
  }

  @override
  String get usernameChars =>
      'استخدم فقط a–z و0–9 والشرطة السفلية (_) والنقطة (.).';

  @override
  String get usernameDots => 'لا يمكن أن يبدأ اسم المستخدم أو ينتهي بنقطة.';

  @override
  String get usernameDoubleDot => 'لا يمكن استخدام نقطتين متتاليتين.';

  @override
  String get nameRequired => 'أدخل اسمك.';

  @override
  String nameMax(int max) {
    return 'يمكن أن يتكوّن الاسم من $max حرفًا كحدّ أقصى.';
  }

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get save => 'حفظ';

  @override
  String get profileInfo => 'بيانات الملف الشخصي';

  @override
  String get profileInfoHint => 'تظهر هذه البيانات للجميع في ملفك الشخصي.';

  @override
  String get yourName => 'اسمك';

  @override
  String get usernameEvery30 => 'يمكنك تغيير اسم المستخدم مرة كل 30 يومًا.';

  @override
  String usernameLockedUntil(String date) {
    return 'يمكنك تغييره بعد $date.';
  }

  @override
  String get about => 'نبذة';

  @override
  String get aboutHint => 'تحدّث عن نفسك والأنشطة التي تحبّها.';

  @override
  String get interests => 'الاهتمامات';

  @override
  String interestsMax(int max) {
    return 'يمكنك اختيار $max كحدّ أقصى.';
  }

  @override
  String get cancel => 'إلغاء';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get remove => 'إزالة';

  @override
  String get removeCover => 'إزالة صورة الغلاف';

  @override
  String get addCover => 'إضافة غلاف';

  @override
  String get changeCover => 'تغيير الغلاف';

  @override
  String get changeAvatar => 'تغيير صورة الملف الشخصي';

  @override
  String get photos => 'صورة الملف الشخصي والغلاف';

  @override
  String get photosHint => 'JPEG أو PNG أو WebP · حتى 5 ميغابايت';

  @override
  String get addAvatar => 'إضافة صورة الملف الشخصي';

  @override
  String get removeAvatar => 'إزالة صورة الملف الشخصي';

  @override
  String get followers => 'المتابِعون';

  @override
  String get following => 'المتابَعون';

  @override
  String get privateLists => 'هذا الحساب خاص. تابِعه لرؤية قوائمه.';

  @override
  String get backToProfile => 'العودة إلى الملف الشخصي';

  @override
  String get noFollowers => 'لا يوجد متابِعون بعد.';

  @override
  String get noFollowing => 'لا يتابع أحدًا بعد.';

  @override
  String get refresh => 'تحديث';

  @override
  String get removeFollower => 'إزالة المتابِع';

  @override
  String removeFollowerBody(String username) {
    return 'إزالة ‎@$username من متابِعيك؟ لن يُبلَّغ بذلك.';
  }

  @override
  String get removeAction => 'إزالة';

  @override
  String get friends => 'أنتما صديقان';

  @override
  String get followRequests => 'طلبات المتابعة';

  @override
  String get noFollowRequests =>
      'لا توجد طلبات متابعة معلّقة. تعتمد الحسابات الخاصة الطلبات هنا.';

  @override
  String get approve => 'موافقة';

  @override
  String get delete => 'حذف';

  @override
  String get blockedAccounts => 'الحسابات المحظورة';

  @override
  String get noBlocked => 'لم تحظر أحدًا. يمكنك الحظر من قائمة أي ملف شخصي.';

  @override
  String get unblock => 'إلغاء الحظر';

  @override
  String get onboardWho => 'لنتعرّف إليك';

  @override
  String get onboardWhoHint =>
      'اختر الاسم واسم المستخدم اللذين سيظهران في ملفك الشخصي.';

  @override
  String get onboardPhoto => 'صورة الملف الشخصي';

  @override
  String get onboardPhotoHint =>
      'لتتعرّف إليك مجموعاتك. يمكنك إضافتها لاحقًا أيضًا.';

  @override
  String get onboardInterests => 'اهتماماتك';

  @override
  String onboardInterestsHint(int max) {
    return 'اختر $max كحدّ أقصى لنقترح عليك مجموعات تناسبك.';
  }

  @override
  String get back => 'رجوع';

  @override
  String stepOf(int step, int total) {
    return 'الخطوة $step من $total';
  }

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get skipForNow => 'تخطَّ الآن';

  @override
  String get continueAction => 'متابعة';

  @override
  String get finish => 'إنهاء';

  @override
  String get usernameHelper => 'استخدم أحرفًا صغيرة وأرقامًا و_ و.';

  @override
  String get avatarPreview => 'معاينة صورة الملف الشخصي';

  @override
  String get choosePhoto => 'اختر صورة';

  @override
  String get chooseAnotherPhoto => 'اختر صورة أخرى';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get settings => 'الإعدادات';

  @override
  String get profileNotFound =>
      'لم يُعثر على هذا الملف الشخصي أو لم يعد ظاهرًا.';

  @override
  String get backToMyProfile => 'العودة إلى ملفي الشخصي';

  @override
  String suspendedUntil(String date) {
    return 'هذا الحساب معلّق حتى $date.';
  }

  @override
  String get followsYou => 'يتابعك';

  @override
  String get yourTeammate => 'زميلك في الفريق';

  @override
  String joined(String date) {
    return 'انضمّ في $date';
  }

  @override
  String followRequestsPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طلب متابعة بانتظار الموافقة.',
      few: '$count طلبات متابعة بانتظار الموافقة.',
      two: 'طلبا متابعة بانتظار الموافقة.',
      one: 'طلب متابعة واحد بانتظار الموافقة.',
    );
    return '$_temp0';
  }

  @override
  String get review => 'مراجعة';

  @override
  String teammateRequestsPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طلب زمالة فريق بانتظارك.',
      few: '$count طلبات زمالة فريق بانتظارك.',
      two: 'طلبا زمالة فريق بانتظارك.',
      one: 'طلب زمالة فريق واحد بانتظارك.',
    );
    return '$_temp0';
  }

  @override
  String get youBlocked => 'لقد حظرت هذا الحساب';

  @override
  String get youBlockedHint =>
      'إذا ألغيت الحظر، فسيرى كلٌّ منكما منشورات الآخر مجددًا.';

  @override
  String get privateAccount => 'هذا الحساب خاص';

  @override
  String get privateAccountHint => 'تابِع هذا الحساب لرؤية صوره ومقاطعه وقصصه.';

  @override
  String get addInterestsNudge => 'أضف اهتماماتك وسنجد لك مجموعات وزملاء فريق.';

  @override
  String get add => 'إضافة';

  @override
  String blockTitle(String username) {
    return 'حظر ‎@$username؟';
  }

  @override
  String get blockBody =>
      'لن يرى ملفك الشخصي ومنشوراتك وقصصك، ولن يعثر عليك أو يراسلك. ستنتهي المتابعة بينكما. لن يُبلَّغ بأنك حظرته.';

  @override
  String get block => 'حظر';

  @override
  String get becomeTeammates => 'كونا زميلَي فريق';

  @override
  String nowTeammates(String name) {
    return 'أصبحتما أنت و$name زميلَي فريق.';
  }

  @override
  String get acceptTeammate => 'قبول طلب الزمالة';

  @override
  String get requestWithdrawn => 'تم سحب الطلب.';

  @override
  String get withdrawTeammate => 'سحب طلب الزمالة';

  @override
  String get teammateEnded => 'انتهت الزمالة.';

  @override
  String get endTeammate => 'إنهاء الزمالة';

  @override
  String get moreOptions => 'خيارات أخرى';

  @override
  String get linkCopied => 'تم نسخ رابط الملف الشخصي.';

  @override
  String get copyLink => 'نسخ رابط الملف الشخصي';

  @override
  String get removedFromFollowers => 'تمت إزالته من متابِعيك.';

  @override
  String get removeFromFollowers => 'إزالة من متابِعيّ';

  @override
  String get report => 'إبلاغ';

  @override
  String get unblocked => 'تم إلغاء الحظر.';

  @override
  String get statPosts => 'منشورات';

  @override
  String get statFollowers => 'متابِعون';

  @override
  String get statFollowing => 'يتابع';

  @override
  String withdrawFollowBody(String username) {
    return 'هل تريد سحب طلب متابعة ‎@$username؟';
  }

  @override
  String unfollowBody(String username) {
    return 'إلغاء متابعة ‎@$username؟';
  }

  @override
  String unfollowPrivateBody(String username) {
    return 'إلغاء متابعة ‎@$username؟ الحساب خاص، لذا ستحتاج إلى إرسال طلب جديد لرؤية منشوراته.';
  }

  @override
  String get withdrawRequest => 'سحب الطلب';

  @override
  String get unfollow => 'إلغاء المتابعة';

  @override
  String get followBack => 'متابعة بالمثل';

  @override
  String get follow => 'متابعة';

  @override
  String get requestSent => 'تم إرسال الطلب';

  @override
  String get followingState => 'تتابعه';

  @override
  String noAccountMatch(String query) {
    return 'لا توجد حسابات تطابق «$query».';
  }

  @override
  String get clearSearch => 'مسح البحث';

  @override
  String get searchHint => 'ابدأ الكتابة للبحث عن أشخاص أو وسوم.';

  @override
  String get refreshSuggestions => 'تحديث الاقتراحات';

  @override
  String get suggestionsForYou => 'مقترحات لك';

  @override
  String mutualFollows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'يتابعه $count شخصًا ممن تتابعهم',
      few: 'يتابعه $count أشخاص ممن تتابعهم',
      two: 'يتابعه شخصان ممن تتابعهم',
      one: 'يتابعه شخص واحد ممن تتابعهم',
    );
    return '$_temp0';
  }

  @override
  String get popularAccount => 'حساب شائع';

  @override
  String get seePackage => 'عرض الباقة';

  @override
  String requestSentNotify(String name) {
    return 'تم إرسال الطلب. سنُعلمك عندما يقبل $name.';
  }

  @override
  String becomeTeammatesWith(String name) {
    return 'كن زميل فريق لـ$name';
  }

  @override
  String get shortMessage => 'رسالة قصيرة (اختيارية)';

  @override
  String get shortMessageHint => 'صباح السبت في الحديقة؟';

  @override
  String get sendRequest => 'إرسال الطلب';

  @override
  String get findTeammates => 'ابحث عن زملاء فريق';

  @override
  String get myTeammatePrefs => 'تفضيلاتي لزملاء الفريق';

  @override
  String get tabSuggestions => 'الاقتراحات';

  @override
  String get tabRequests => 'الطلبات';

  @override
  String tabRequestsCount(int count) {
    return 'الطلبات ($count)';
  }

  @override
  String get tabMyTeam => 'فريقي';

  @override
  String get findYourTeammate => 'اعثر على زميل فريقك';

  @override
  String waitingForYou(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count شخصًا يريدون أن يكونوا زملاء فريقك',
      few: '$count أشخاص يريدون أن يكونوا زملاء فريقك',
      two: 'شخصان يريدان أن يكونا زميلَي فريقك',
      one: 'شخص واحد يريد أن يكون زميل فريقك',
    );
    return '$_temp0';
  }

  @override
  String get teammatesLocked =>
      'تُفتح الاقتراحات وإرسال الطلبات وقبولها ومراسلة زملاء الفريق مع باقة زميل الفريق.';

  @override
  String get beVisible => 'اظهر أنت أيضًا';

  @override
  String get beVisibleBody =>
      'فعّل «أبحث عن فريق» ليتمكّن من يحبّون ما تحبّ من إرسال طلبات إليك.';

  @override
  String get setPrefs => 'ضبط تفضيلاتي';

  @override
  String get nowPublicSuggest =>
      'أصبح حسابك عامًا، ويمكن أن تظهر في الاقتراحات.';

  @override
  String get privateHidden => 'حسابك خاص، ولا تظهر في الاقتراحات';

  @override
  String get privateHiddenBody =>
      'لا تظهر الحسابات الخاصة في اقتراحات زملاء الفريق. إذا جعلت حسابك عامًا، فستتم الموافقة أيضًا على طلبات المتابعة المعلّقة.';

  @override
  String get makePublic => 'اجعل حسابي عامًا';

  @override
  String get noSuggestions =>
      'لا يوجد من يناسبك حاليًا. أكمل اهتماماتك وتفضيلاتك لتحصل على اقتراحات أكثر.';

  @override
  String quoted(String text) {
    return '«$text»';
  }

  @override
  String get whySuggested => 'سبب الاقتراح';

  @override
  String get noPendingTeammate => 'لا توجد طلبات زمالة معلّقة.';

  @override
  String get seeSuggestions => 'عرض الاقتراحات';

  @override
  String get incoming => 'الواردة';

  @override
  String get accept => 'قبول';

  @override
  String get decline => 'رفض';

  @override
  String get requestDeclined => 'تم رفض الطلب.';

  @override
  String get outgoing => 'المُرسلة';

  @override
  String get awaitingReply => 'بانتظار الرد';

  @override
  String get withdraw => 'سحب';

  @override
  String get noTeammates =>
      'ليس لديك زملاء فريق بعد. ابدأ بإرسال طلب إلى أحد المقترحين.';

  @override
  String optionsFor(String name) {
    return 'خيارات لـ$name';
  }

  @override
  String get teammatePrefs => 'تفضيلات زملاء الفريق';

  @override
  String get prefsSavedVisible => 'تم حفظ التفضيلات. ستظهر الآن في الاقتراحات.';

  @override
  String get prefsSaved => 'تم حفظ التفضيلات.';

  @override
  String get whatToDo => 'ماذا تريد أن تفعل؟';

  @override
  String activitiesHint(int max) {
    return 'الأنشطة التي تبحث فيها عن زملاء فريق. حتى $max.';
  }

  @override
  String get yourLevel => 'مستواك';

  @override
  String get yourGoals => 'أهدافك';

  @override
  String get multipleChoice => 'يمكنك اختيار أكثر من واحد.';

  @override
  String get howOften => 'كم مرة تريد اللقاء؟';

  @override
  String get whenFree => 'متى تكون متفرّغًا؟';

  @override
  String get whenFreeHint => 'انقر على الأوقات التي تناسبك.';

  @override
  String get whatTeam => 'أي نوع من الفرق تريد؟';

  @override
  String get whichProvince => 'في أي محافظة أنت؟';

  @override
  String get provinceHint => 'تُستخدم للمطابقة فقط ولا تظهر في ملفك الشخصي.';

  @override
  String get province => 'المحافظة';

  @override
  String get ratherNotSay => 'أفضّل عدم الإفصاح';

  @override
  String get extras => 'معلومات إضافية';

  @override
  String get iHaveVehicle => 'لديّ مركبة';

  @override
  String get iHaveVehicleHint => 'يمكنني توصيل الآخرين.';

  @override
  String get iHaveEquipment => 'لديّ معدّاتي الخاصة';

  @override
  String get iHaveEquipmentHint =>
      'دراجتي وخيمتي ومضربي وغيرها من المعدّات جاهزة.';

  @override
  String get describeYourself => 'صف نفسك';

  @override
  String get describeHint => 'يظهر تحت اسمك في الاقتراحات.';

  @override
  String get describeExample => 'أبحث عن رفيق للمشي صباح عطلة نهاية الأسبوع.';

  @override
  String get willAppear => 'ستظهر في الاقتراحات.';

  @override
  String get notAppearing => 'لا تظهر في الاقتراحات حاليًا.';

  @override
  String get lookingForTeam => 'أبحث عن فريق';

  @override
  String get lookingOn => 'تظهر في الاقتراحات، ويمكن إرسال طلبات زمالة إليك.';

  @override
  String get lookingOff =>
      'فعّله وسيعثر عليك من يحبّون ما تحبّ. لا تظهر الحسابات الخاصة في الاقتراحات.';

  @override
  String prefsComplete(int percent) {
    return 'اكتملت التفضيلات بنسبة $percent٪';
  }

  @override
  String get prefsCompleteHint => 'كلما أكملت أكثر كانت الاقتراحات أدق.';

  @override
  String get weekday => 'أيام الأسبوع';

  @override
  String get weekend => 'عطلة نهاية الأسبوع';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get available => 'متاح';

  @override
  String get taken => 'مأخوذ';
}
