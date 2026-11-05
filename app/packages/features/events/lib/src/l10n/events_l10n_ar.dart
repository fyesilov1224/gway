// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'events_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class EventsL10nAr extends EventsL10n {
  EventsL10nAr([String locale = 'ar']) : super(locale);

  @override
  String get pollSingle => 'يمكنك اختيار خيار واحد فقط في هذا الاستطلاع.';

  @override
  String get pollOptionGone => 'لم يعد هذا الخيار موجودًا. حدّث الصفحة.';

  @override
  String get reviewWindow =>
      'يمكن للحضور تقييم الفعالية خلال 30 يومًا من انتهائها.';

  @override
  String get greeterNeedsAttendance =>
      'لتكون مستقبِلًا، يجب أن تكون قد حضرت إحدى فعاليات المجموعة.';

  @override
  String get note80 => 'يمكن أن تصل الملاحظة إلى 80 حرفًا.';

  @override
  String get pollClosed => 'انتهى هذا الاستطلاع أو لا يمكنك التصويت.';

  @override
  String get cover5mb => 'يمكن أن تصل صورة الغلاف إلى 5 ميغابايت.';

  @override
  String get imagesOnly => 'يمكن رفع صور JPEG أو PNG أو WebP فقط.';

  @override
  String get claimNotAllowed =>
      'لا يمكنك الإبلاغ عن هذه المهمة الآن: انتهت أو لست في المجموعة.';

  @override
  String get claimApprovedLocked => 'لا يمكن سحب بلاغ تمت الموافقة عليه.';

  @override
  String get claimDuplicate => 'أبلغت عن هذه المهمة بالفعل.';

  @override
  String get repeatsWeekly => 'تتكرّر كل أسبوع';

  @override
  String get repeatsBiweekly => 'تتكرّر كل أسبوعين';

  @override
  String surprisePlace(String place) {
    return 'مكان مفاجئ · $place';
  }

  @override
  String get goalPersonal => 'هدف شخصي';

  @override
  String get goalPersonalHint => 'يكمل كل عضو عدده الخاص.';

  @override
  String get goalGroup => 'هدف المجموعة';

  @override
  String get goalGroupHint => 'تُجمع مساهمات الجميع في عدّاد واحد.';

  @override
  String get goalTeam => 'هدف الفريق';

  @override
  String get goalTeamHint => 'يشكّل المشرفون الفرق، ولكل فريق عدّاد مشترك.';

  @override
  String get goalTask => 'مهمة بموافقة';

  @override
  String get goalTaskHint => 'يقول العضو «أنجزتها» ويوافق المشرف.';

  @override
  String unitAttended(int count) {
    return 'مشاركة';
  }

  @override
  String unitOrganized(int count) {
    return 'تنظيم';
  }

  @override
  String unitMemories(int count) {
    return 'ذكرى';
  }

  @override
  String get claimPending => 'بانتظار الموافقة';

  @override
  String get claimApproved => 'تمت الموافقة';

  @override
  String get claimRejected => 'لم تتم الموافقة';

  @override
  String get notClaimedYet => 'لم يُبلَّغ بعد';

  @override
  String get whenAny => 'في أي وقت';

  @override
  String get whenToday => 'اليوم';

  @override
  String get whenWeek => 'خلال 7 أيام';

  @override
  String get viewDay => 'يوم';

  @override
  String get viewWeek => 'أسبوع';

  @override
  String get viewMonth => 'شهر';

  @override
  String countAttended(int count) {
    return 'المشاركات: $count';
  }

  @override
  String countOrganized(int count) {
    return 'التنظيمات: $count';
  }

  @override
  String countMemories(int count) {
    return 'الذكريات: $count';
  }

  @override
  String countReviews(int count) {
    return 'التقييمات: $count';
  }

  @override
  String countWelcomed(int count) {
    return 'الترحيبات: $count';
  }

  @override
  String countHandshakes(int count) {
    return 'المصافحات: $count';
  }

  @override
  String countHeld(int count) {
    return 'الفعاليات: $count';
  }

  @override
  String countGoodReviews(int count) {
    return 'التقييمات الإيجابية: $count';
  }

  @override
  String leagueStanding(String month, int groups, int rank, int points) {
    return '$month: المركز $rank من $groups مجموعة، $points نقطة.';
  }

  @override
  String goingCount(int count) {
    return 'المشاركون: $count';
  }

  @override
  String goingOfCapacity(int count, int capacity) {
    return 'المشاركون: $count / $capacity';
  }

  @override
  String firstEventOfYear(String title) {
    return 'أول فعالية في العام: $title';
  }

  @override
  String firstEventOfYearOn(String title, String date) {
    return 'أول فعالية في العام: $title · $date';
  }

  @override
  String get myCalendar => 'تقويمي';

  @override
  String get groupCalendar => 'تقويم المجموعة';

  @override
  String get previous => 'السابق';

  @override
  String get next => 'التالي';

  @override
  String get today => 'اليوم';

  @override
  String get groupsEvents => 'فعاليات مجموعاتي';

  @override
  String get showNotJoined => 'إظهار الفعاليات التي لم تنضم إليها أيضًا';

  @override
  String get noJoinedInRange =>
      'لا توجد فعاليات انضممت إليها في هذه التواريخ. يمكنك رؤية فعاليات مجموعاتك أيضًا.';

  @override
  String get noEventsInRange => 'لا توجد فعاليات في هذه التواريخ.';

  @override
  String get showGroupsEvents => 'إظهار فعاليات مجموعاتي';

  @override
  String get backToToday => 'العودة إلى اليوم';

  @override
  String get noEventsDay => 'لا توجد فعاليات في هذا اليوم.';

  @override
  String get contributions => 'المساهمة في المجتمع';

  @override
  String get howBadges => 'كيف تُكتسب الشارات؟';

  @override
  String get badgesEmpty => 'عندما تحضر فعالية تظهر هنا مساهمتك وشارتك الأولى.';

  @override
  String get badgesRules =>
      'تُحتسب الشارات مما تفعله فعلًا فقط: الفعاليات التي تحضرها وتنظّمها والذكريات التي تشاركها وتقييماتك. لا تُحتسب الإعجابات والمتابِعون. لا تُحتسب المشاركات التي يعلّمها المنظّم بـ«لم يحضر». لا يوجد ترتيب.';

  @override
  String get categoryFan => 'شغوف بالفئة';

  @override
  String get pastEvents => 'الفعاليات السابقة';

  @override
  String get noPastEvents => 'لا توجد فعاليات سابقة لهذه المجموعة بعد.';

  @override
  String get refresh => 'تحديث';

  @override
  String get canceled => 'ملغاة';

  @override
  String get olderEvents => 'فعاليات أقدم';

  @override
  String get completed => 'أنجزت';

  @override
  String get ended => 'انتهى';

  @override
  String teamName(String name) {
    return 'الفريق: $name';
  }

  @override
  String get teamNotice => 'عند إضافتك إلى فريق يظهر تقدّمك هنا.';

  @override
  String get goals => 'الأهداف';

  @override
  String get createGoal => 'إنشاء هدف';

  @override
  String get goalsEmpty =>
      'مثلًا «4 رحلات مشي هذا الشهر» أو «50 مشاركة معًا»: أنشئ الهدف الأول.';

  @override
  String get claimSent => 'أُرسل بلاغك إلى المشرف.';

  @override
  String get goal => 'الهدف';

  @override
  String get goalCountsRule =>
      'تُحتسب فعاليات هذه المجموعة خلال الفترة فقط، ولا تُحتسب المشاركات المعلَّمة بـ«لم يحضر».';

  @override
  String get withdrawClaim => 'سحب البلاغ';

  @override
  String get claimWithdrawn => 'تم سحب بلاغك.';

  @override
  String get done => 'أنجزتها';

  @override
  String get teams => 'الفرق';

  @override
  String get createTeam => 'إنشاء فريق';

  @override
  String get noTeams => 'لا توجد فرق بعد.';

  @override
  String deleteTeam(String name) {
    return 'حذف الفريق $name';
  }

  @override
  String get teamDeleted => 'تم حذف الفريق.';

  @override
  String pendingClaims(int count) {
    return 'بلاغات بانتظار الموافقة ($count)';
  }

  @override
  String get claimRejectedToast => 'لم تتم الموافقة على البلاغ.';

  @override
  String get decline => 'رفض';

  @override
  String get approve => 'موافقة';

  @override
  String taskDone(String name) {
    return 'أنجز $name المهمة.';
  }

  @override
  String completions(int count) {
    return 'المنجزون ($count)';
  }

  @override
  String get noCompletions =>
      'لم يُنجزه أحد بعد. سيحصل كل من يُنجزه على شارة هذا الهدف في ملفه الشخصي.';

  @override
  String get goalCanceled => 'تم إلغاء الهدف.';

  @override
  String get cancelGoal => 'إلغاء الهدف';

  @override
  String teamCreated(String name) {
    return 'تم إنشاء فريق «$name».';
  }

  @override
  String get teamNameLabel => 'اسم الفريق';

  @override
  String get createTheTeam => 'إنشاء الفريق';

  @override
  String createTeamWith(int count) {
    return 'إنشاء الفريق ($count أشخاص)';
  }

  @override
  String get goalCreated => 'تم إنشاء الهدف.';

  @override
  String get title => 'العنوان';

  @override
  String get goalTitleExample => 'مثال: رحلات أكتوبر';

  @override
  String get taskTitleExample => 'مثال: اشرح المسار لعضو جديد';

  @override
  String get titleMin3 => 'يجب أن يتكوّن العنوان من 3 أحرف على الأقل.';

  @override
  String get descriptionOptional => 'الوصف (اختياري)';

  @override
  String get targetNumber => 'العدد المستهدف';

  @override
  String get target1to1000 => 'أدخل رقمًا من 1 إلى 1000.';

  @override
  String get period => 'الفترة';

  @override
  String periodRange(String from, String to) {
    return '$from – $to (92 يومًا كحدّ أقصى)';
  }

  @override
  String get createTheGoal => 'إنشاء الهدف';

  @override
  String get iDidTask => 'أنجزت المهمة';

  @override
  String get whatDidYouDo => 'ماذا فعلت؟ (اختياري)';

  @override
  String get whatDidYouDoHint => 'يوافق المشرف بعد قراءة هذه الملاحظة.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get send => 'إرسال';

  @override
  String get handshake => 'مصافحة';

  @override
  String get handshakeHint =>
      'امسحا رمزيكما؛ يُضاف كلاكما إلى «من تعرّفت إليهم».';

  @override
  String get open => 'فتح';

  @override
  String handshakeAt(String title) {
    return 'مصافحة · $title';
  }

  @override
  String get myCode => 'رمزي';

  @override
  String get scan => 'مسح';

  @override
  String get yourHandshakeCode => 'رمز مصافحتك';

  @override
  String get codeHint =>
      'ليمسح الشخص الآخر هذا الرمز من تبويب «مسح» أو يكتبه. يتجدّد الرمز كل بضع دقائق، ولن تفيد صورته لاحقًا.';

  @override
  String get cameraFailed =>
      'تعذّر فتح الكاميرا. اسمح بالوصول إليها من الإعدادات أو اكتب الرمز أدناه.';

  @override
  String get scanHint => 'وجّه الكاميرا إلى رمز QR للشخص الآخر أو اكتب رمزه.';

  @override
  String get typeCodeHint =>
      'اكتب الرمز المكوّن من 6 خانات الظاهر على شاشة الشخص الآخر.';

  @override
  String get code => 'الرمز';

  @override
  String get alreadyMet => 'أنتما تعرفان بعضكما بالفعل';

  @override
  String get metNow => 'تعارفتما!';

  @override
  String personWithUsername(String name, String username) {
    return '$name (‎@$username)';
  }

  @override
  String get ok => 'حسنًا';

  @override
  String get metPeople => 'من تعرّفت إليهم';

  @override
  String get metEmpty =>
      'عندما تصافح أحدًا في فعالية يظهر هنا. تُفتح المصافحة من صفحة الفعالية.';

  @override
  String get goToCalendar => 'الذهاب إلى تقويمي';

  @override
  String get metPrivacy =>
      'أنت وحدك ترى ذلك. يظهر في ملفك الشخصي عدد المصافحات فقط.';

  @override
  String metRow(String username, String event, String date) {
    return '‎@$username · $event · $date';
  }

  @override
  String get howPoints => 'كيف تُحتسب النقاط؟';

  @override
  String get leagueIntro =>
      'تتنافس مجموعات الفئة نفسها في المحافظة نفسها كل شهر. تُحتسب الفعاليات المنتهية خلال الشهر.';

  @override
  String get ruleAttendance => 'المشاركة: نقطة واحدة';

  @override
  String get ruleAttendanceHint => 'عن كل شخص يحضر؛ 30 كحدّ أقصى في الفعالية.';

  @override
  String get ruleHeld => 'الفعالية: 5 نقاط';

  @override
  String get ruleHeldHint => 'كل فعالية حضرها 3 أشخاص على الأقل غير المنظّم.';

  @override
  String get ruleWelcome => 'الترحيب: 3 نقاط';

  @override
  String get ruleWelcomeHint => 'استقبال شخص يأتي لأول مرة.';

  @override
  String get ruleReview => 'تقييم إيجابي: نقطة واحدة';

  @override
  String get ruleReviewHint => 'كل تقييم بـ4 أو 5 نجوم.';

  @override
  String get leagueRulesNote =>
      'لا يُحتسب من عُلِّم بـ«لم يحضر». تصبح النتائج نهائية بعد 8 أيام من انتهاء الشهر، ويُبلَّغ أعضاء المجموعات الثلاث الأولى.';

  @override
  String get groupsLeague => 'دوري المجموعات';

  @override
  String get category => 'الفئة';

  @override
  String get province => 'المحافظة';

  @override
  String get month => 'الشهر';

  @override
  String seasonClosed(String month) {
    return 'انتهى موسم $month، والترتيب نهائي.';
  }

  @override
  String get seasonRunning =>
      'الموسم جارٍ. تتحدّث النقاط مع انتهاء الفعاليات، وتصبح النتائج نهائية بعد 8 أيام من نهاية الشهر.';

  @override
  String leagueEmpty(String province) {
    return 'لم تحصل أي مجموعة في دوري $province على نقاط هذا الشهر بعد.';
  }

  @override
  String points(int count) {
    return 'النقاط: $count';
  }

  @override
  String rank(int rank) {
    return '$rank.';
  }

  @override
  String leagueName(String province, String category) {
    return '$province · دوري $category';
  }

  @override
  String get noPointsYet =>
      'لا نقاط بعد هذا الشهر. تمنح الفعاليات المنتهية والحضور والترحيب نقاطًا.';

  @override
  String get mapAttribution =>
      '© Stadia Maps © OpenMapTiles © مساهمو OpenStreetMap';

  @override
  String get map => 'الخريطة';

  @override
  String get mapView => 'عرض الخريطة';

  @override
  String get listView => 'عرض القائمة';

  @override
  String get all => 'الكل';

  @override
  String get wholeArea => 'المنطقة كلها';

  @override
  String km(int km) {
    return '$km كم';
  }

  @override
  String get mapLoadFailed => 'تعذّر تحميل بيانات الخريطة.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get noFilterResults => 'لا توجد نتائج بعوامل التصفية هذه.';

  @override
  String get clearFilters => 'مسح عوامل التصفية';

  @override
  String get noNearby => 'لا توجد فعاليات قادمة أو مجموعات في هذه المنطقة.';

  @override
  String get zoomOut => 'تصغير';

  @override
  String get openEvent => 'فتح الفعالية';

  @override
  String memberCount(int count) {
    return 'الأعضاء: $count';
  }

  @override
  String get noVisible =>
      'لا توجد فعاليات قادمة أو مجموعات في المنطقة الظاهرة.';

  @override
  String get backToMap => 'العودة إلى الخريطة';

  @override
  String upcomingCount(int count) {
    return 'الفعاليات القادمة ($count)';
  }

  @override
  String get directions => 'الاتجاهات';

  @override
  String get meetingPointOptional => 'نقطة الالتقاء (اختياري)';

  @override
  String get meetingPointHint => 'اختره على الخريطة لتظهر الفعالية عليها.';

  @override
  String pointPicked(String lat, String lng) {
    return 'تم الاختيار · $lat، $lng';
  }

  @override
  String get removeMeetingPoint => 'إزالة نقطة الالتقاء';

  @override
  String get meetingPoint => 'نقطة الالتقاء';

  @override
  String get pickHint => 'كبّر الخريطة وانقر على نقطة الالتقاء.';

  @override
  String get pickAgainHint => 'انقر في مكان آخر لتغيير النقطة.';

  @override
  String get pickThisPoint => 'اختر هذه النقطة';

  @override
  String get mapUnavailable => 'الخريطة غير متاحة حاليًا.';
}
