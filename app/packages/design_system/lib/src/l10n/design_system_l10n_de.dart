// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'design_system_l10n.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class DesignSystemL10nDe extends DesignSystemL10n {
  DesignSystemL10nDe([String locale = 'de']) : super(locale);

  @override
  String loadingLabel(String label) {
    return '$label, wird geladen';
  }

  @override
  String get previous => 'Zurück';

  @override
  String get next => 'Weiter';

  @override
  String get coverPhoto => 'Titelbild';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get liveBroadcast => 'Livestream';

  @override
  String get liveBadge => 'LIVE';
}
