// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'design_system_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class DesignSystemL10nPt extends DesignSystemL10n {
  DesignSystemL10nPt([String locale = 'pt']) : super(locale);

  @override
  String loadingLabel(String label) {
    return '$label, carregando';
  }

  @override
  String get previous => 'Anteriores';

  @override
  String get next => 'Próximos';

  @override
  String get coverPhoto => 'Foto de capa';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get liveBroadcast => 'Transmissão ao vivo';

  @override
  String get liveBadge => 'AO VIVO';
}
