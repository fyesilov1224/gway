// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'design_system_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class DesignSystemL10nEs extends DesignSystemL10n {
  DesignSystemL10nEs([String locale = 'es']) : super(locale);

  @override
  String loadingLabel(String label) {
    return '$label, cargando';
  }

  @override
  String get previous => 'Anteriores';

  @override
  String get next => 'Siguientes';

  @override
  String get coverPhoto => 'Foto de portada';

  @override
  String get retry => 'Reintentar';

  @override
  String get liveBroadcast => 'Transmisión en directo';

  @override
  String get liveBadge => 'EN VIVO';
}
