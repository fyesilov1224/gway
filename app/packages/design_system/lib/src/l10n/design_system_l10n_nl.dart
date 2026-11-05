// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'design_system_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class DesignSystemL10nNl extends DesignSystemL10n {
  DesignSystemL10nNl([String locale = 'nl']) : super(locale);

  @override
  String loadingLabel(String label) {
    return '$label, wordt geladen';
  }

  @override
  String get previous => 'Vorige';

  @override
  String get next => 'Volgende';

  @override
  String get coverPhoto => 'Omslagfoto';

  @override
  String get retry => 'Opnieuw proberen';

  @override
  String get liveBroadcast => 'Livestream';

  @override
  String get liveBadge => 'LIVE';
}
