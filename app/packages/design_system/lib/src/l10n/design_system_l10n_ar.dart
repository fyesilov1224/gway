// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'design_system_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class DesignSystemL10nAr extends DesignSystemL10n {
  DesignSystemL10nAr([String locale = 'ar']) : super(locale);

  @override
  String loadingLabel(String label) {
    return '$label، جارٍ التحميل';
  }

  @override
  String get previous => 'السابق';

  @override
  String get next => 'التالي';

  @override
  String get coverPhoto => 'صورة الغلاف';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get liveBroadcast => 'بث مباشر';

  @override
  String get liveBadge => 'مباشر';
}
