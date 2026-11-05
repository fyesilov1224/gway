// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'matching_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class MatchingL10nAr extends MatchingL10n {
  MatchingL10nAr([String locale = 'ar']) : super(locale);

  @override
  String get unsupportedImage => 'يمكن رفع صور JPEG أو PNG أو WebP فقط.';

  @override
  String get modeFriend => 'صداقة';

  @override
  String get modeDating => 'مواعدة';

  @override
  String get genderWoman => 'امرأة';

  @override
  String get genderMan => 'رجل';

  @override
  String get genderNonbinary => 'غير ثنائي';

  @override
  String get adultsOnly => 'التوافق متاح لمن تجاوزوا 18 عامًا فقط.';

  @override
  String get pickMode => 'اختر وضعًا واحدًا على الأقل: صداقة أو مواعدة.';

  @override
  String get pickInterest => 'اختر من تبحث عنه في وضع المواعدة.';

  @override
  String get ageRangeInvalid => 'النطاق العمري غير صالح.';

  @override
  String sharedGroup(String group) {
    return 'مجموعة مشتركة: $group';
  }

  @override
  String sharedGroupsMore(String group, int count) {
    return 'مشتركة: $group و$count مجموعات أخرى';
  }

  @override
  String get pkgReveal => 'توافقاتي';

  @override
  String get pkgRevealText => 'اعرف من توافقت معه: الاسم والصور والملف الشخصي.';

  @override
  String get pkgChat => 'محادثة التوافق';

  @override
  String get pkgChatText => 'راسل من توافقت معهم. يشمل رؤية توافقاتك.';

  @override
  String get pkgAdmirers => 'من أعجب بك';

  @override
  String get pkgAdmirersText => 'اعرف من أعجب بك وتوافق فورًا بالإعجاب به.';

  @override
  String get pkgUnlimited => 'إعجابات بلا حدود';

  @override
  String get pkgUnlimitedText =>
      'لا حدّ يوميًا للإعجابات، مع التراجع والفلاتر.';

  @override
  String get pkgSuper => 'إعجاب فائق';

  @override
  String get pkgSuperText =>
      '5 إعجابات فائقة يوميًا؛ يراك الشخص أولًا في مجموعته.';

  @override
  String get pkgBoost => 'تعزيز الظهور';

  @override
  String get pkgBoostText =>
      'مرة يوميًا، اظهر في أعلى المجموعات المشتركة لمدة 30 دقيقة.';

  @override
  String get pkgTeammates => 'زميل الفريق';

  @override
  String get pkgTeammatesText => 'أرسل طلبات زمالة الفريق وراسل زملاءك.';

  @override
  String get pkgAll => 'الكل في واحد';

  @override
  String get pkgAllText =>
      'كل الباقات في باقة واحدة، أوفر بكثير من شرائها منفصلة.';

  @override
  String get superLikedYou => 'أعجب بك إعجابًا فائقًا';

  @override
  String get options => 'خيارات';

  @override
  String get fullProfile => 'الملف الكامل';

  @override
  String get stampLike => 'إعجاب';

  @override
  String get stampPass => 'تخطٍّ';

  @override
  String get stampSuper => 'فائق';

  @override
  String photoOf(String name, int number) {
    return '$name، الصورة $number';
  }

  @override
  String get about => 'نبذة';

  @override
  String get interests => 'الاهتمامات';

  @override
  String get sharedGroupsTitle => 'مجموعاتكما المشتركة';

  @override
  String get createProfileTitle => 'إنشاء ملف التوافق';

  @override
  String get myProfile => 'ملف التوافق الخاص بي';

  @override
  String get birthDateLabel => 'تاريخ ميلادك';

  @override
  String get pickBasics => 'اختر تاريخ ميلادك وجنسك ومحافظتك.';

  @override
  String get confirmAgeConsent =>
      'للمتابعة، أكّد أنك تجاوزت 18 عامًا وامنح موافقتك الصريحة.';

  @override
  String profileReady(int min) {
    return 'ملفك جاهز. أضف الآن $min صور على الأقل.';
  }

  @override
  String get saved => 'تم الحفظ.';

  @override
  String get pickBirthDate => 'اختر تاريخ الميلاد';

  @override
  String ageNote(int age) {
    return '$age عامًا · تظهر بطاقتك عمرك فقط';
  }

  @override
  String get gender => 'الجنس';

  @override
  String get province => 'المحافظة';

  @override
  String get aboutHint => 'تحدّث عن نفسك';

  @override
  String get jobOptional => 'المهنة (اختياري)';

  @override
  String get educationOptional => 'التعليم (اختياري)';

  @override
  String get interestsFromProfile => 'تأتي اهتماماتك من ملفك الاجتماعي.';

  @override
  String get lookingFor => 'ماذا تبحث عنه؟';

  @override
  String get friendHint => 'أشخاص لحضور الفعاليات والدردشة معهم';

  @override
  String get datingHint => 'علاقة عاطفية';

  @override
  String get whoLookingFor => 'من تبحث عنه؟';

  @override
  String ageRange(int min, int max) {
    return 'العمر: $min–$max';
  }

  @override
  String get consentTitle => 'الموافقة';

  @override
  String get iam18 => 'عمري أكثر من 18 عامًا.';

  @override
  String get consentText =>
      'أوافق صراحةً على معالجة جنسي ومن أبحث عنه وتاريخ ميلادي ومحافظتي وصوري لأغراض التوافق، وعلى عرضها لمن فعّلوا التوافق في مجموعاتي المشتركة. يمكنني سحب موافقتي في أي وقت بحذف بيانات التوافق.';

  @override
  String get createProfile => 'إنشاء ملفي';

  @override
  String get save => 'حفظ';

  @override
  String get photos => 'الصور';

  @override
  String photosMin(int min) {
    return 'أضف $min صور على الأقل لتظهر بطاقتك. الأولى هي الغلاف.';
  }

  @override
  String photosMax(int max) {
    return 'حتى $max صور. الأولى هي الغلاف؛ انقر صورة لتغييرها.';
  }

  @override
  String get addPhoto => 'إضافة صورة';

  @override
  String get cover => 'الغلاف';

  @override
  String get removePhoto => 'إزالة الصورة';

  @override
  String get pauseProfile => 'إيقاف ملفي مؤقتًا';

  @override
  String get pauseHint =>
      'لن يراك أحد ولن تصل بطاقات جديدة؛ تبقى توافقاتك ومحادثاتك.';

  @override
  String get deleteData => 'حذف بيانات التوافق';

  @override
  String get deleteDataHint =>
      'يُحذف الملف والصور والإعجابات وتنتهي توافقاتك. وتُعدّ موافقتك مسحوبة.';

  @override
  String get deleteDataTitle => 'حذف بيانات التوافق';

  @override
  String get deleteDataBody =>
      'سيُحذف ملف التوافق وصورك وإعجاباتك نهائيًا وتنتهي كل توافقاتك. لا يمكن التراجع.';

  @override
  String get delete => 'حذف';

  @override
  String get dataDeleted => 'تم حذف بيانات التوافق.';

  @override
  String get itsAMatch => 'لقد توافقتما!';

  @override
  String bothLiked(String name) {
    return 'أنت و$name أعجب كلٌّ منكما بالآخر.';
  }

  @override
  String get keepSwiping => 'تابع التمرير';

  @override
  String get sendMessage => 'إرسال رسالة';

  @override
  String get reportProfile => 'الإبلاغ عن الملف';

  @override
  String get reportPhoto => 'الإبلاغ عن هذه الصورة';

  @override
  String get block => 'حظر';

  @override
  String get blockHint => 'لن يرى أحدكما الآخر في أي مكان.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get newMatch => 'توافقت مع شخص ما!';

  @override
  String tapToSee(String date) {
    return 'انقر لترى من هو · $date';
  }

  @override
  String get revealReason =>
      'توافقت مع شخص ما! احصل على باقة «توافقاتي» لتعرف من هو.';

  @override
  String get keepFriend => 'البقاء أصدقاء فقط';

  @override
  String get keepDating => 'البقاء في المواعدة فقط';

  @override
  String keepFriendBody(String name) {
    return 'ينتهي توافق المواعدة مع $name لكليكما؛ ويستمر توافق الصداقة والمحادثة.';
  }

  @override
  String keepDatingBody(String name) {
    return 'ينتهي توافق الصداقة مع $name لكليكما؛ ويستمر توافق المواعدة والمحادثة.';
  }

  @override
  String get keptFriend => 'أصبحتما متوافقين صداقةً فقط.';

  @override
  String get keptDating => 'أصبحتما متوافقين للمواعدة فقط.';

  @override
  String get continueAction => 'متابعة';

  @override
  String get endMatch => 'إنهاء التوافق';

  @override
  String endMatchBody(String name) {
    return 'ينتهي توافقك مع $name وتُغلق المحادثة لكليكما. لا يمكن التراجع.';
  }

  @override
  String get end => 'إنهاء';

  @override
  String get matchEnded => 'انتهى التوافق.';

  @override
  String get noMatches => 'لا توجد توافقات بعد. تظهر هنا الإعجابات المتبادلة.';

  @override
  String get backToDiscover => 'العودة إلى الاستكشاف';

  @override
  String get report => 'إبلاغ';

  @override
  String get matching => 'التوافق';

  @override
  String get admirers => 'من أعجب بك';

  @override
  String get packages => 'الباقات';

  @override
  String get more => 'المزيد';

  @override
  String get filtersLocked =>
      'التصفية حسب العمر والمحافظة والاهتمام متاحة مع باقة «إعجابات بلا حدود».';

  @override
  String get filters => 'الفلاتر';

  @override
  String get suspended =>
      'أغلق فريق المنصة ملف التوافق الخاص بك. راسل الدعم لمعرفة التفاصيل.';

  @override
  String addPhotosToStart(int min) {
    return 'أضف $min صور على الأقل لإظهار بطاقتك وبدء الاستكشاف.';
  }

  @override
  String get paused =>
      'ملفك متوقّف مؤقتًا؛ لا يراك أحد. تبقى توافقاتك ومحادثاتك.';

  @override
  String get likesOut =>
      'انتهت إعجاباتك المجانية لليوم. أعجب بقدر ما تريد مع «إعجابات بلا حدود».';

  @override
  String get supersOut => 'انتهت إعجاباتك الفائقة لليوم. تتجدد غدًا.';

  @override
  String get superUsed =>
      'استخدمت إعجابك الفائق لليوم. احصل على 5 يوميًا مع باقة «إعجاب فائق».';

  @override
  String get rewindLocked =>
      'استعادة من تخطّيته بالخطأ متاحة مع «إعجابات بلا حدود».';

  @override
  String rewoundTo(String mode) {
    return 'عاد آخر شخص تخطّيته إلى مجموعة $mode.';
  }

  @override
  String boostReason(int minutes) {
    return 'مع تعزيز الظهور تظهر في أعلى المجموعات لمدة $minutes دقيقة.';
  }

  @override
  String boosting(int minutes) {
    return 'ظهورك معزّز. بقيت $minutes دقيقة.';
  }

  @override
  String get boostUsed => 'استخدمت تعزيز اليوم. يتجدد غدًا.';

  @override
  String get boost => 'تعزيز';

  @override
  String boostBody(int minutes) {
    return 'لمدة $minutes دقيقة تظهر أولًا في مجموعات أشخاص مجموعاتك المشتركة. مرة يوميًا.';
  }

  @override
  String boosted(int minutes) {
    return 'تم التعزيز! أنت في الأعلى لمدة $minutes دقيقة.';
  }

  @override
  String get deckEmpty =>
      'لا أحد لعرضه الآن. ستمتلئ مع انضمامك لمجموعات وتفعيل الآخرين للتوافق.';

  @override
  String get deckEmptyFiltered => 'لا أحد يطابق فلاترك. جرّب توسيعها.';

  @override
  String get refresh => 'تحديث';

  @override
  String get clearFilters => 'مسح الفلاتر';

  @override
  String allowanceUnlimited(int supers) {
    return 'إعجابات بلا حدود · متبقٍّ $supers إعجاب فائق.';
  }

  @override
  String get allowanceOut => 'انتهت إعجاباتك لليوم؛ تتجدد غدًا.';

  @override
  String allowance(int likes, int supers) {
    return 'متبقٍّ لك اليوم $likes إعجاب و$supers إعجاب فائق.';
  }

  @override
  String get undo => 'تراجع';

  @override
  String get pass => 'تخطٍّ';

  @override
  String get superLike => 'إعجاب فائق';

  @override
  String get like => 'إعجاب';

  @override
  String get introTitle => 'تعرّف على أشخاص جدد من مجموعاتك المشتركة';

  @override
  String get intro1 =>
      'ترى فقط من فعّلوا التوافق في المجموعات التي أنت عضو فيها أو تتابعها.';

  @override
  String get intro2 =>
      'اسحب يمينًا للإعجاب ويسارًا للتخطي وللأعلى للإعجاب الفائق.';

  @override
  String get intro3 =>
      'عندما يعجب كلٌّ منكما بالآخر تتوافقان. تراسل من توافقت معه بباقة «محادثة التوافق».';

  @override
  String get intro4 =>
      'الصداقة والمواعدة وضعان منفصلان؛ اختر أحدهما أو كليهما.';

  @override
  String get intro5 =>
      'لا يرى ملفك إلا من فعّلوا التوافق. أوقفه مؤقتًا أو احذفه متى شئت.';

  @override
  String get createMyProfile => 'إنشاء ملف التوافق';

  @override
  String seePackageOf(String package) {
    return 'عرض باقة $package';
  }

  @override
  String get allPackages => 'كل الباقات';

  @override
  String get packagesTitle => 'باقات التوافق';

  @override
  String get packagesIntro =>
      'إنشاء الملف والتمرير مجانيان. كل ميزة باقة مستقلة؛ اختر ما تريده فقط.';

  @override
  String get adminAllOpen => 'كل الباقات مفعّلة لك بصفتك مشرفًا';

  @override
  String openUntil(String date) {
    return 'مفعّل حتى $date';
  }

  @override
  String ageFilter(int min, int max) {
    return 'العمر: $min – $max';
  }

  @override
  String get allProvinces => 'كل المحافظات';

  @override
  String get interest => 'الاهتمام';

  @override
  String get all => 'الكل';

  @override
  String get apply => 'تطبيق';

  @override
  String get clear => 'مسح';

  @override
  String get noAdmirers =>
      'لا إعجابات معلّقة حاليًا. تابع التمرير؛ يظهر هنا من يعجب بك.';

  @override
  String get backToSwiping => 'العودة إلى التمرير';

  @override
  String get likeAndMatch => 'أعجب وتوافق';

  @override
  String get noPendingLikes => 'لا إعجابات معلّقة بعد';

  @override
  String likedYouCount(int count) {
    return 'أعجب بك: $count';
  }

  @override
  String get admirersPitch =>
      'مع باقة «من أعجب بك» اعرف من هم وتوافق فورًا بالإعجاب بهم.';

  @override
  String get seePackage => 'عرض الباقة';
}
