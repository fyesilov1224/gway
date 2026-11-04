// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'design_system_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Azerbaijani (`az`).
class DesignSystemL10nAz extends DesignSystemL10n {
  DesignSystemL10nAz([String locale = 'az']) : super(locale);

  @override
  String loadingLabel(String label) {
    return '$label, yüklənir';
  }

  @override
  String get previous => 'Əvvəlkilər';

  @override
  String get next => 'Sonrakılar';

  @override
  String get coverPhoto => 'Örtük şəkli';

  @override
  String get retry => 'Yenidən cəhd et';

  @override
  String get liveBroadcast => 'Canlı yayım';

  @override
  String get liveBadge => 'CANLI';
}
