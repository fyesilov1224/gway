// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'design_system_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class DesignSystemL10nIt extends DesignSystemL10n {
  DesignSystemL10nIt([String locale = 'it']) : super(locale);

  @override
  String loadingLabel(String label) {
    return '$label, caricamento';
  }

  @override
  String get previous => 'Precedenti';

  @override
  String get next => 'Successivi';

  @override
  String get coverPhoto => 'Foto di copertina';

  @override
  String get retry => 'Riprova';

  @override
  String get liveBroadcast => 'Diretta';

  @override
  String get liveBadge => 'LIVE';
}
