// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'design_system_l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class DesignSystemL10nEn extends DesignSystemL10n {
  DesignSystemL10nEn([String locale = 'en']) : super(locale);

  @override
  String loadingLabel(String label) {
    return '$label, loading';
  }

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get coverPhoto => 'Cover photo';

  @override
  String get retry => 'Try again';

  @override
  String get liveBroadcast => 'Live broadcast';

  @override
  String get liveBadge => 'LIVE';
}
