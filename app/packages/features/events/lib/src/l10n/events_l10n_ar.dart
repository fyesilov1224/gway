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

  @override
  String get pollClosedShort => 'مغلق';

  @override
  String closesAt(String date) {
    return 'الإغلاق: $date';
  }

  @override
  String get multipleAllowed => 'اختيار متعدد';

  @override
  String get anonymousVote => 'تصويت سري';

  @override
  String votersCount(int count) {
    return 'المصوّتون: $count';
  }

  @override
  String get pollOptions => 'خيارات الاستطلاع';

  @override
  String get pollClosedToast => 'تم إغلاق الاستطلاع.';

  @override
  String get pollDeleted => 'تم حذف الاستطلاع.';

  @override
  String get closePoll => 'إغلاق الاستطلاع';

  @override
  String get deletePoll => 'حذف الاستطلاع';

  @override
  String get vote => 'تصويت';

  @override
  String get voteSaved => 'تم حفظ صوتك.';

  @override
  String get voters => 'المصوّتون';

  @override
  String peopleCount(int count) {
    return 'الأشخاص: $count';
  }

  @override
  String get polls => 'الاستطلاعات';

  @override
  String get openPoll => 'إنشاء استطلاع';

  @override
  String get pollsEmpty => 'اطرح سؤالًا على الأعضاء، مثل: في أي يوم نلتقي؟';

  @override
  String get pollOpened => 'تم إنشاء الاستطلاع.';

  @override
  String get question => 'السؤال';

  @override
  String get questionExample => 'مثال: في أي يوم نلتقي؟';

  @override
  String get questionMin3 => 'يجب أن يتكوّن السؤال من 3 أحرف على الأقل.';

  @override
  String optionN(int n) {
    return 'الخيار $n';
  }

  @override
  String get removeOption => 'إزالة الخيار';

  @override
  String get optionRequired => 'اكتب الخيار أو أزِله.';

  @override
  String get addOption => 'إضافة خيار';

  @override
  String get allowMultiple => 'السماح باختيارات متعددة';

  @override
  String get anonymousHint => 'لا يرى أحد من صوّت لماذا.';

  @override
  String get noEndTime => 'بلا وقت انتهاء';

  @override
  String get add => 'إضافة';

  @override
  String get removeEndTime => 'إزالة وقت الانتهاء';

  @override
  String get startPoll => 'إنشاء الاستطلاع';

  @override
  String get cardFooter => 'gway · اعثر على مجتمعك';

  @override
  String myYear(int year) {
    return 'عامي $year';
  }

  @override
  String get statAttended => 'فعالية حضرتها';

  @override
  String get statHours => 'ساعة معًا';

  @override
  String get statOneGroup => 'مجموعة التقيتها';

  @override
  String get statGroups => 'مجموعات مختلفة';

  @override
  String get statProvinces => 'محافظات مختلفة';

  @override
  String get statOrganized => 'فعالية نظّمتها';

  @override
  String get statWelcomed => 'قادمًا جديدًا استقبلته';

  @override
  String get statMemories => 'ذكرى شاركتها';

  @override
  String get favorites => 'المفضّلة لديّ';

  @override
  String get topGroup => 'المجموعة التي قضيت معها أكثر وقت';

  @override
  String topGroupLine(String group, int count) {
    return '$group · اللقاءات: $count';
  }

  @override
  String get iWasThere => 'كنت هناك';

  @override
  String get firstWithGroup => 'أول فعالية لي مع هذه المجموعة.';

  @override
  String nthWithGroup(int n) {
    return 'فعاليتي رقم $n مع هذه المجموعة.';
  }

  @override
  String get shareFailed =>
      'تعذّرت المشاركة على هذا الجهاز. التقط صورة للبطاقة وشاركها.';

  @override
  String get share => 'مشاركة';

  @override
  String yearSummaryTitle(int year) {
    return 'ملخّص عامي $year';
  }

  @override
  String get yearEmpty =>
      'لم تحضر أي فعالية هذا العام بعد. سيظهر ملخّصك هنا بعد أول لقاء.';

  @override
  String yearShareText(int year) {
    return 'عامي $year على GWAY';
  }

  @override
  String mapSemantics(int count) {
    return 'خريطة تركيا: $count محافظة مستكشفة';
  }

  @override
  String get explorationMap => 'خريطة استكشافي';

  @override
  String get statExplored => 'محافظة استكشفتها';

  @override
  String get statMetAt => 'فعالية التقينا فيها';

  @override
  String get recentExplored => 'آخر استكشافاتي';

  @override
  String get explorationEmpty =>
      'تُضاء هنا محافظات الفعاليات التي تحضرها. تتلوّن خريطتك بعد أول لقاء.';

  @override
  String get findOnMap => 'ابحث عن فعاليات على الخريطة';

  @override
  String explorationShareText(int count) {
    return 'استكشفت $count محافظة على GWAY';
  }

  @override
  String get exploredProvinces => 'المحافظات التي استكشفتها';

  @override
  String get explorationPrivacy =>
      'أنت وحدك ترى ذلك. تُحتسب الفعاليات التي حضرتها ولم تُعلَّم فيها بـ«لم يحضر».';

  @override
  String get tonightVisible =>
      'سيرى أعضاء مجموعاتك المشتركة أنك متفرّغ الليلة. يتوقّف تلقائيًا الساعة 4:00.';

  @override
  String get joinedTable => 'انضممت إلى الطاولة.';

  @override
  String get declinedInvite => 'رفضت الدعوة.';

  @override
  String get yourStatus => 'حالتك';

  @override
  String get visibleUntil4 => 'أنت ظاهر حتى الساعة 4:00';

  @override
  String get notVisible => 'لست ظاهرًا الآن';

  @override
  String get youreFree => 'أنت متفرّغ';

  @override
  String get tonightIntro =>
      'إذا كنت متفرّغًا، دع أعضاء مجموعاتك يعرفون؛ يمكنكم إنشاء طاولة صغيرة معًا.';

  @override
  String get imFreeTonight => 'أنا متفرّغ الليلة';

  @override
  String get noLongerFree => 'لم تعد تظهر متفرّغًا.';

  @override
  String get turnOffStatus => 'إيقاف الحالة';

  @override
  String get leftTable => 'غادرت الطاولة.';

  @override
  String get smallTable => 'طاولة صغيرة';

  @override
  String get smallTableHint =>
      'ادعُ بعض المتفرّغين؛ تُفتح محادثة الطاولة عند وصول ثلاثة أشخاص.';

  @override
  String get setUpTable => 'إنشاء طاولة صغيرة';

  @override
  String tableInvitesSent(int count) {
    return 'أُرسلت الدعوات إلى $count أشخاص. تُفتح المحادثة عند وصول ثلاثة.';
  }

  @override
  String needMorePeople(int min, int now) {
    return 'تحتاج الطاولة الصغيرة إلى $min متفرّغين إضافيين على الأقل من مجموعاتك (الآن $now). عندما يعلن أحدهم أنه متفرّغ يمكنك إنشاؤها هنا.';
  }

  @override
  String freeFromGroups(int count) {
    return 'المتفرّغون الليلة من مجموعاتك: $count';
  }

  @override
  String get chipCoffee => 'قهوة';

  @override
  String get chipWalk => 'مشي قصير';

  @override
  String get chipFood => 'طعام';

  @override
  String get chipCinema => 'سينما';

  @override
  String get tonightSheetHint =>
      'لا يراه إلا أعضاء مجموعاتك المشتركة. تتوقّف حالتك تلقائيًا الساعة 4:00.';

  @override
  String get whatToDo => 'ماذا تحب أن تفعل؟ (اختياري)';

  @override
  String get whatToDoHint => 'مثل: قهوة، مشي قصير';

  @override
  String get imFree => 'أنا متفرّغ';

  @override
  String get yourTable => 'طاولتك';

  @override
  String joinedCount(int count) {
    return 'انضم: $count';
  }

  @override
  String waitingCount(int count) {
    return 'بالانتظار: $count';
  }

  @override
  String get settingUp => 'قيد الإعداد';

  @override
  String get chatOpen => 'المحادثة مفتوحة';

  @override
  String get tableChat => 'محادثة الطاولة';

  @override
  String chatOpensWhen(int count) {
    return 'تُفتح المحادثة عند انضمام $count أشخاص آخرين. تختارون هناك المكان والوقت معًا.';
  }

  @override
  String get leaveTable => 'مغادرة الطاولة';

  @override
  String tableInviteTitle(String name) {
    return 'أنشأ $name طاولة صغيرة ويدعوك إليها.';
  }

  @override
  String tableInviteStatus(int joined, int pending) {
    return 'انضم $joined · بالانتظار $pending. تُفتح المحادثة عند وصول ثلاثة.';
  }

  @override
  String get join => 'انضمام';

  @override
  String get notTonight => 'ليس الليلة';

  @override
  String get tonight => 'الليلة';

  @override
  String get freeTonight => 'المتفرّغون الليلة';

  @override
  String get sharedGroupsOnly => 'أعضاء مجموعاتك المشتركة فقط';

  @override
  String get nobodyFree => 'لا يوجد متفرّغ من مجموعاتك الآن.';

  @override
  String get howItWorks => 'كيف يعمل؟';

  @override
  String get howStep1 => 'قل «أنا متفرّغ الليلة»، واكتب ما تودّ فعله إن شئت.';

  @override
  String get howStep2 => 'يراك أعضاء مجموعاتك وترى أنت المتفرّغين.';

  @override
  String get howStep3 =>
      'أنشئ طاولة صغيرة؛ تُفتح المحادثة عند وصول ثلاثة وتختارون هناك المكان والوقت.';

  @override
  String get upcoming => 'القادمة';

  @override
  String get calendar => 'التقويم';

  @override
  String get noUpcomingJoined => 'لا توجد فعاليات قادمة انضممت إليها.';

  @override
  String get showAll => 'عرض الكل';

  @override
  String get noUpcoming60 =>
      'لا توجد فعاليات لمجموعاتك خلال الأيام الستين القادمة.';

  @override
  String get findGroup => 'ابحث عن مجموعة';

  @override
  String filterAll(int count) {
    return 'الكل · $count';
  }

  @override
  String filterMine(int count) {
    return 'المنضمّ إليها · $count';
  }

  @override
  String get tomorrow => 'غدًا';

  @override
  String get going => 'ستحضر';

  @override
  String get waitlisted => 'على قائمة الانتظار';

  @override
  String get awaitingApproval => 'بانتظار الموافقة';

  @override
  String get full => 'مكتمل';

  @override
  String goingOfCapacityShort(int count, int capacity) {
    return 'المشاركون: $count/$capacity';
  }

  @override
  String get startingSoon => 'يبدأ قريبًا';

  @override
  String get next6Hours => 'الساعات الست القادمة';

  @override
  String get wantWelcome => 'أرغب في أن يستقبلني أحد';

  @override
  String get wantWelcomeHint =>
      'يستقبلك أحد متطوّعي المجموعة عند المدخل؛ فلن تذهب وحدك.';

  @override
  String get noteForGreeter => 'ملاحظة ليتعرّفوا إليك (اختياري)';

  @override
  String get noteForGreeterHint => 'مثال: أرتدي سترة حمراء ومعي حقيبة زرقاء';

  @override
  String get sendRequest => 'إرسال الطلب';

  @override
  String get welcomeRequestSent =>
      'أُرسل طلبك إلى المستقبِلين. سنُعلمك عندما يتولّاه أحدهم.';

  @override
  String get editMeetingNote => 'تعديل ملاحظة اللقاء';

  @override
  String welcomePerson(String name) {
    return 'استقبل $name';
  }

  @override
  String describedAs(String note) {
    return 'وصف نفسه هكذا: $note';
  }

  @override
  String get whereMeet => 'أين ستلتقيان؟';

  @override
  String get whereMeetHint => 'مثال: أمام المقهى عند المدخل، 8:45';

  @override
  String get save => 'حفظ';

  @override
  String get iWillWelcome => 'سأستقبله';

  @override
  String get noteUpdated => 'تم تحديث ملاحظة اللقاء.';

  @override
  String youWillWelcome(String name) {
    return 'ستستقبل $name؛ اطّلع على ملاحظة اللقاء.';
  }

  @override
  String get stopWelcoming => 'التوقّف عن الاستقبال';

  @override
  String stopWelcomingBody(String name) {
    return 'سنبحث عن مستقبِل آخر لـ$name ونُعلمه.';
  }

  @override
  String get release => 'توقّف';

  @override
  String get releasedWelcome => 'توقّفت عن الاستقبال؛ نبحث عن مستقبِل جديد.';

  @override
  String get firstTime => 'هل تأتي لأول مرة؟';

  @override
  String greetersAvailable(int count) {
    return 'في هذه المجموعة $count مستقبِلين. دع أحدهم يستقبلك عند المدخل ويعرّفك بالمجموعة.';
  }

  @override
  String get youWelcomed => 'من تستقبلهم';

  @override
  String meetingAt(String note) {
    return 'اللقاء: $note';
  }

  @override
  String get thankedYou => 'شكرك';

  @override
  String optionsFor(String name) {
    return 'خيارات لـ$name';
  }

  @override
  String waitingWelcome(int count) {
    return 'بانتظار الاستقبال ($count)';
  }

  @override
  String matchedCount(int count) {
    return 'وُجد مستقبِل لـ: $count';
  }

  @override
  String get firstTimer => 'أول مرة';

  @override
  String get max3Welcomes =>
      'يمكنك استقبال 3 أشخاص كحدّ أقصى في الفعالية الواحدة.';

  @override
  String get greeterJoinHint =>
      'أنت مستقبِل. انضم إلى الفعالية لاستقبال القادمين لأول مرة.';

  @override
  String get lookingGreeter => 'جارٍ البحث عن مستقبِل';

  @override
  String get lookingGreeterHint =>
      'أبلغنا مستقبِلي المجموعة. سيصلك إشعار عندما يتولّى أحدهم الأمر.';

  @override
  String yourNote(String note) {
    return 'ملاحظتك: $note';
  }

  @override
  String get welcomeWithdrawn => 'تم سحب طلب الاستقبال.';

  @override
  String get withdrawRequest => 'سحب الطلب';

  @override
  String get greetedBy => 'استقبلك';

  @override
  String get willGreet => 'سيستقبلك';

  @override
  String get thank => 'اشكره';

  @override
  String thankReceived(String name) {
    return 'وصل شكرك إلى $name.';
  }

  @override
  String get thanked => 'شكرته.';

  @override
  String get cancelWelcome => 'إلغاء الاستقبال';

  @override
  String get nowGreeter =>
      'أصبحت مستقبِلًا. سنُعلمك عندما يطلب قادم جديد استقباله.';

  @override
  String get noLongerGreeter => 'لم تعد مستقبِلًا.';

  @override
  String get welcomeSection => 'الترحيب';

  @override
  String greetersCount(int count) {
    return 'المستقبِلون: $count';
  }

  @override
  String get greeterIntro =>
      'يمكن للقادمين لأول مرة طلب الاستقبال من صفحة الفعالية. إذا صرت مستقبِلًا سيصلك إشعار، فتستقبلهم عند المدخل وتعرّفهم بالمجموعة.';

  @override
  String greeterMemberHint(int count) {
    return 'في هذه المجموعة $count مستقبِلين. في أول فعالية لك انقر «أرغب في أن يستقبلني أحد».';
  }

  @override
  String greeterVisitorHint(int count) {
    return 'في هذه المجموعة $count مستقبِلين: لن تذهب وحدك إلى أول فعالية، سيستقبلك أحدهم عند المدخل.';
  }

  @override
  String get becomeGreeter => 'كن مستقبِلًا';

  @override
  String quoted(String text) {
    return '«$text»';
  }

  @override
  String seatsGoing(int count) {
    return 'سيحضر: $count';
  }

  @override
  String seatsOf(int count, int capacity) {
    return 'الأشخاص: $count / $capacity';
  }

  @override
  String seatsOfWaiting(int count, int capacity, int waiting) {
    return 'الأشخاص: $count / $capacity · بالانتظار: $waiting';
  }

  @override
  String summaryAttended(int count) {
    return 'الحضور: $count';
  }

  @override
  String summaryRating(String avg, int count) {
    return '$avg ★ (التقييمات: $count)';
  }

  @override
  String waitlistPlace(int place) {
    return 'قائمة الانتظار · رقم $place';
  }

  @override
  String get eventCanceled => 'أُلغيت هذه الفعالية.';

  @override
  String eventCanceledBecause(String reason) {
    return 'أُلغيت هذه الفعالية: $reason';
  }

  @override
  String reviewBy(String name, int stars) {
    return '$name، $stars نجوم';
  }

  @override
  String get conflicting => 'متعارض';

  @override
  String get events => 'الفعاليات';

  @override
  String get create => 'إنشاء';

  @override
  String eventsLeft(int count) {
    return 'المتبقّي من الفعاليات هذا الشهر: $count.';
  }

  @override
  String get eventsLimitReached =>
      'بلغت حدّ فعاليات هذا الشهر. رقِّ الباقة للحصول على المزيد.';

  @override
  String groupRating(String avg, int count) {
    return '$avg · تقييمات الفعاليات: $count';
  }

  @override
  String get howWasIt => 'كيف كانت؟';

  @override
  String get howWasItHint =>
      'قيّم الفعالية التي حضرتها؛ لا يرى الجميع إلا المتوسط.';

  @override
  String titleOnDate(String title, String date) {
    return '$title · $date';
  }

  @override
  String get eventsEmpty => 'مشي أو حفلة أو لقاء: أنشئ أول فعالية.';

  @override
  String get requestSent => 'أُرسل طلبك. سنُعلمك عندما يقرّر المنظّم.';

  @override
  String get attendanceSaved => 'تم تسجيل حضورك. سنذكّرك قبل البدء.';

  @override
  String waitlistJoined(int place) {
    return 'أنت على قائمة الانتظار (رقم $place). سنُعلمك عند توفّر مكان.';
  }

  @override
  String get conflictTitle => 'لديك فعالية أخرى في الوقت نفسه';

  @override
  String conflictLine(String title, String date) {
    return '• $title · $date';
  }

  @override
  String get conflictOne => 'إذا لم تستطع الذهاب، انسحب واترك مكانك لغيرك.';

  @override
  String get conflictMany => 'إذا لم تستطع الذهاب، انسحب واترك أماكنك لغيرك.';

  @override
  String get keepBoth => 'الإبقاء على الاثنين';

  @override
  String get leaveOther => 'الانسحاب من الأخرى';

  @override
  String get leaveOthers => 'الانسحاب من الأخرى';

  @override
  String get leftOther => 'انسحبت من الفعالية الأخرى؛ وأصبح مكانك متاحًا.';

  @override
  String get leftOthers => 'انسحبت من الفعاليات الأخرى.';

  @override
  String approvedPerson(String name) {
    return 'أصبح $name من الحضور.';
  }

  @override
  String declinedPerson(String name) {
    return 'تم رفض الطلب وإبلاغ $name.';
  }

  @override
  String get calendarFailed => 'تعذّر فتح ملف التقويم. حاول مرة أخرى.';

  @override
  String get stopSeriesTitle => 'إيقاف التكرار؟';

  @override
  String get stopSeriesBody =>
      'لن تُفتح تواريخ جديدة. تبقى التواريخ المفتوحة، ويمكنك إلغاؤها واحدًا تلو الآخر.';

  @override
  String get stop => 'إيقاف';

  @override
  String get seriesStopped => 'تم إيقاف التكرار.';

  @override
  String get eventCanceledToast => 'تم إلغاء الفعالية.';

  @override
  String get eventNotFound => 'لم يُعثر على هذه الفعالية أو لم تعد ظاهرة.';

  @override
  String get goBack => 'رجوع';

  @override
  String joinGroupFirst(String name) {
    return 'انضم إلى $name';
  }

  @override
  String get sendJoinRequest => 'طلب الحضور';

  @override
  String get joinWaitlist => 'الانضمام إلى قائمة الانتظار';

  @override
  String get leaveEvent => 'إلغاء الحضور';

  @override
  String get leaveWaitlist => 'الخروج من قائمة الانتظار';

  @override
  String get requestWithdrawn => 'تم سحب طلبك.';

  @override
  String get attendanceRemoved => 'تمت إزالة حضورك.';

  @override
  String eventShareText(String title) {
    return '$title · انضم على GWAY:';
  }

  @override
  String get eventLinkCopied => 'تم نسخ رابط الفعالية.';

  @override
  String get report => 'إبلاغ';

  @override
  String get eventOptions => 'خيارات الفعالية';

  @override
  String get edit => 'تعديل';

  @override
  String get cancelThisDate => 'إلغاء هذا الموعد';

  @override
  String get stopRepeat => 'إيقاف التكرار';

  @override
  String get startedOrEnded => 'بدأت أو انتهت';

  @override
  String seriesUntil(String label, String date) {
    return '$label · حتى $date';
  }

  @override
  String get addToCalendar => 'إضافة إلى التقويم';

  @override
  String fee(String fee) {
    return 'رسوم المشاركة: $fee';
  }

  @override
  String get feeNotice => 'تُدفع الرسوم للمنظّم، ولا يتلقّى GWAY أي مدفوعات.';

  @override
  String get areYouComing => 'هل ستأتي؟';

  @override
  String get areYouComingHint =>
      'إذا لم تستطع الحضور، اترك مكانك لقائمة الانتظار.';

  @override
  String get yesComing => 'نعم، سآتي';

  @override
  String get confirmThanks => 'شكرًا، أبلغنا المنظّم بأنك ستأتي.';

  @override
  String get cantCome => 'لا أستطيع الحضور';

  @override
  String get spotFreed => 'تمت إزالة حضورك؛ وأصبح مكانك متاحًا.';

  @override
  String get confirmedComing => 'أكّدت حضورك.';

  @override
  String get otherEventSameTime => 'لديك فعالية أخرى في هذا الوقت';

  @override
  String get needsApproval => 'الحضور بموافقة المشرف';

  @override
  String get requirements => 'شروط الحضور';

  @override
  String get equipment => 'المعدّات المطلوبة';

  @override
  String joinRequestsCount(int count) {
    return 'طلبات الحضور ($count)';
  }

  @override
  String get attendees => 'الحضور';

  @override
  String confirmedOf(int going, int confirmed) {
    return 'أكّد $confirmed من أصل $going حضورهم.';
  }

  @override
  String confirmedName(String name) {
    return '$name · أكّد';
  }

  @override
  String get shareWasThere => 'شارك بطاقة «كنت هناك»';

  @override
  String get howDidItGo => 'كيف جرت؟';

  @override
  String reviewsCount(int count) {
    return 'التقييمات ($count)';
  }

  @override
  String get reviewNotesPrivate => 'لا يرى الملاحظات إلا المنظّمون.';

  @override
  String get attendanceCheck => 'الحضور';

  @override
  String get attendanceCheckHint =>
      'علّم من لم يحضروا؛ لا يُحتسب للمساهمات والشارات إلا الحاضرون. متاح 7 أيام بعد الانتهاء.';

  @override
  String markedCame(String name) {
    return 'تم تعليم $name كحاضر.';
  }

  @override
  String markedMissed(String name) {
    return 'تم تعليم $name كغائب.';
  }

  @override
  String get didntCome => 'لم يحضر';

  @override
  String get came => 'حضر';

  @override
  String get memories => 'الذكريات';

  @override
  String get shareMemory => 'شارك ذكرى';

  @override
  String get eventPolls => 'استطلاعات الفعالية';

  @override
  String get noEditPermission => 'ليست لديك صلاحية تعديل هذه الفعالية.';

  @override
  String get editEvent => 'تعديل الفعالية';

  @override
  String get newEvent => 'فعالية جديدة';

  @override
  String get addCover => 'إضافة صورة غلاف';

  @override
  String get titleExample => 'مثال: مشي في الغابة';

  @override
  String get starts => 'البداية';

  @override
  String get endsOptional => 'النهاية (اختياري)';

  @override
  String get notSpecified => 'غير محدّد';

  @override
  String get removeEnd => 'إزالة النهاية';

  @override
  String get repeat => 'التكرار';

  @override
  String get noRepeat => 'بلا تكرار';

  @override
  String get weekly => 'كل أسبوع';

  @override
  String get biweekly => 'كل أسبوعين';

  @override
  String get lastDateOptional => 'آخر موعد (اختياري)';

  @override
  String get untilYouStop => 'حتى توقفه';

  @override
  String get removeLastDate => 'إزالة آخر موعد';

  @override
  String get repeatHint =>
      'تُفتح المواعيد التالية تلقائيًا قبل 4 أسابيع، ويُحتسب كلٌّ منها من الحدّ الشهري.';

  @override
  String get surpriseVenue => 'مكان مفاجئ';

  @override
  String get surpriseHint =>
      'لا يُكشف المكان إلا للحضور، في الوقت الذي تختاره قبل البدء.';

  @override
  String get hintPublic => 'تلميح (يراه الجميع)';

  @override
  String get place => 'المكان';

  @override
  String get hintExample => 'مثال: على البحر، في الجانب الآسيوي';

  @override
  String get placeExample => 'مثال: مدخل الحديقة أو عبر الإنترنت';

  @override
  String get writeHint => 'اكتب تلميحًا.';

  @override
  String get writePlace => 'أدخل المكان.';

  @override
  String get realVenue => 'المكان الحقيقي (للحضور فقط)';

  @override
  String get realVenueExample => 'مثال: أمام المسرح';

  @override
  String get writeRealVenue => 'أدخل المكان الحقيقي.';

  @override
  String get whenReveal => 'متى يُكشف؟';

  @override
  String hoursBefore(int count) {
    return 'قبل $count ساعة';
  }

  @override
  String get linkOptional => 'رابط خريطة أو رابط عبر الإنترنت (اختياري)';

  @override
  String get httpsRequired => 'يجب أن يبدأ الرابط بـ https://.';

  @override
  String get description => 'الوصف';

  @override
  String get capacity => 'السعة (فارغ = غير محدود)';

  @override
  String get capacityHint => 'عند الامتلاء يُضاف الجدد إلى قائمة الانتظار.';

  @override
  String get capacityRange => 'يجب أن تكون السعة من 1 إلى 10000.';

  @override
  String get requirementsOptional => 'شروط الحضور (اختياري)';

  @override
  String get requirementsExample => 'مثال: خبرة مشي 10 كم على الأقل';

  @override
  String get equipmentOptional => 'المعدّات المطلوبة (اختياري)';

  @override
  String get equipmentExample => 'مثال: خوذة، ماء، معطف مطر';

  @override
  String get equipmentHint => 'افصل بفواصل؛ حتى 10 عناصر.';

  @override
  String get equipmentLimit => 'حتى 10 عناصر، كلٌّ منها حتى 60 حرفًا.';

  @override
  String get approvalRequired => 'الحضور بموافقة';

  @override
  String get approvalHint => 'يرسل الراغبون طلبًا وأنت توافق عليه.';

  @override
  String get feeOptional => 'رسوم المشاركة (اختياري)';

  @override
  String get feeInfoOnly => 'للعلم فقط؛ لا يتلقّى GWAY أي مدفوعات.';

  @override
  String get amount => 'المبلغ';

  @override
  String get amountExample => 'مثال: 150';

  @override
  String get validAmount => 'أدخل مبلغًا صالحًا.';

  @override
  String get paymentNote => 'ملاحظة الدفع';

  @override
  String get paymentNoteExample => 'مثال: يُدفع نقدًا في المكان';

  @override
  String get createEvent => 'إنشاء الفعالية';

  @override
  String get rateEvent => 'تقييم الفعالية';

  @override
  String get yourReview => 'تقييمك';

  @override
  String starsLabel(int count) {
    return 'النجوم: $count';
  }

  @override
  String get noteToOrganizers => 'ملاحظة للمنظّمين (اختياري)';

  @override
  String get noteToOrganizersHint =>
      'لا يرى ملاحظتك إلا المنظّمون؛ ويرى الآخرون المتوسط فقط.';

  @override
  String get reviewDeleted => 'تم حذف تقييمك.';

  @override
  String get delete => 'حذف';

  @override
  String get reviewSaved => 'شكرًا، تم حفظ تقييمك.';

  @override
  String get groupNext => 'الفعاليات القادمة للمجموعة';

  @override
  String sameDayOthers(int count) {
    return 'هناك $count فعاليات أخرى من الفئة نفسها في محافظتك في هذا التاريخ. اختر يومًا آخر إن لم ترد أن يضطر أعضاؤك إلى الاختيار.';
  }

  @override
  String get cancelEvent => 'إلغاء الفعالية';

  @override
  String get cancelEventBody =>
      'سيُبلَّغ الحضور وقائمة الانتظار. لا يمكن التراجع عن الإلغاء.';

  @override
  String get reason => 'السبب';

  @override
  String get cancelAction => 'إلغاء';

  @override
  String hint(String hint) {
    return 'تلميح: $hint';
  }

  @override
  String hintRevealAt(String hint, String when) {
    return 'تلميح: $hint · سيُكشف للحضور في $when.';
  }

  @override
  String get venueRevealed => 'كُشف المكان للحضور. انضم لتراه.';

  @override
  String venueRevealAt(String when) {
    return 'سيُكشف المكان للحضور في $when.';
  }

  @override
  String get currencyTry => '₺ TRY';

  @override
  String get badgeFirstStep => 'الخطوة الأولى';

  @override
  String get badgeFirstStepText => 'احضر فعاليتك الأولى.';

  @override
  String get badgeRegular => 'المداوم';

  @override
  String get badgeRegularText => 'احضر 10 فعاليات.';

  @override
  String get badgeCompanion => 'رفيق الدرب';

  @override
  String get badgeCompanionText => 'احضر 25 فعالية.';

  @override
  String get badgeExplorer => 'المستكشف';

  @override
  String get badgeExplorerText => 'احضر فعاليات 3 مجموعات مختلفة.';

  @override
  String get badgeOrganizer => 'المنظِّم';

  @override
  String get badgeOrganizerText => 'نظّم فعالية يحضرها شخصان على الأقل.';

  @override
  String get badgeMasterOrganizer => 'المنظِّم المحترف';

  @override
  String get badgeMasterOrganizerText =>
      'نظّم 10 فعاليات يحضر كلًّا منها شخصان على الأقل.';

  @override
  String get badgeStoryteller => 'جامع الذكريات';

  @override
  String get badgeStorytellerText => 'أضف 5 ذكريات إلى فعاليات حضرتها.';

  @override
  String get badgeFeedback => 'صاحب الرأي';

  @override
  String get badgeFeedbackText => 'قيّم 5 فعاليات حضرتها.';

  @override
  String get badgeDoorOpener => 'فاتح الأبواب';

  @override
  String get badgeDoorOpenerText => 'استقبل شخصًا يحضر للمرة الأولى.';

  @override
  String get badgeHost => 'المضيف';

  @override
  String get badgeHostText => 'استقبل 5 أشخاص يحضرون للمرة الأولى.';

  @override
  String get badgeCommunityHeart => 'قلب المجتمع';

  @override
  String get badgeCommunityHeartText => 'استقبل 20 شخصًا يحضرون للمرة الأولى.';

  @override
  String get badgeFriendly => 'الودود';

  @override
  String get badgeFriendlyText => 'صافح 5 أشخاص في الفعاليات.';

  @override
  String get badgeSocialButterfly => 'الفراشة الاجتماعية';

  @override
  String get badgeSocialButterflyText => 'صافح 25 شخصًا في الفعاليات.';

  @override
  String get badgeCategory => 'محب الفئة';

  @override
  String get badgeCategoryText => 'احضر 5 فعاليات في فئة واحدة.';

  @override
  String badgeCategoryOf(String category) {
    return 'محب $category';
  }

  @override
  String badgeCategoryOfText(String category) {
    return 'حضر 5 فعاليات في فئة $category.';
  }

  @override
  String badgeGoal(String goal) {
    return 'الهدف: $goal';
  }

  @override
  String badgeGoalText(String group) {
    return 'أكمل هدفًا لمجموعة $group.';
  }
}
