// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'core_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class CoreL10nAr extends CoreL10n {
  CoreL10nAr([String locale = 'ar']) : super(locale);

  @override
  String get networkFailure =>
      'تعذّر الاتصال. تحقّق من اتصالك بالإنترنت وحاول مرة أخرى.';

  @override
  String get unauthorizedFailure => 'انتهت جلستك. يُرجى تسجيل الدخول مرة أخرى.';

  @override
  String get forbiddenFailure => 'ليست لديك صلاحية للقيام بهذا الإجراء.';

  @override
  String get notFoundFailure => 'لم نعثر على ما تبحث عنه.';

  @override
  String get rateLimitedFailure =>
      'محاولات كثيرة جدًا. انتظر قليلًا ثم حاول مرة أخرى.';

  @override
  String get unexpectedFailure => 'حدث خطأ ما. يُرجى المحاولة مرة أخرى.';

  @override
  String get storageTooLarge =>
      'الملف كبير جدًا. يمكنك رفع ملف حتى 5 ميغابايت.';

  @override
  String get storageUnsupportedType =>
      'نوع الملف غير مدعوم. اختر JPEG أو PNG أو WebP.';

  @override
  String get categoryMusic => 'موسيقى';

  @override
  String get categoryHiking => 'المشي لمسافات طويلة';

  @override
  String get categoryRunning => 'الجري';

  @override
  String get categoryCycling => 'ركوب الدراجات';

  @override
  String get categoryNature => 'الطبيعة';

  @override
  String get categorySports => 'الرياضة';

  @override
  String get categoryArt => 'الفن';

  @override
  String get categoryPhotography => 'التصوير';

  @override
  String get categoryDance => 'الرقص';

  @override
  String get categoryBooks => 'الكتب';

  @override
  String get categoryGames => 'الألعاب';

  @override
  String get categoryTravel => 'السفر';

  @override
  String get categoryFood => 'الطعام';

  @override
  String get categoryTechnology => 'التكنولوجيا';

  @override
  String get categoryVolunteering => 'التطوع';

  @override
  String get categoryMotorcycle => 'الدراجات النارية';

  @override
  String get categoryCamping => 'التخييم';

  @override
  String get categoryChess => 'الشطرنج';
}
