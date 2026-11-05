// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'design_system_l10n.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class DesignSystemL10nFr extends DesignSystemL10n {
  DesignSystemL10nFr([String locale = 'fr']) : super(locale);

  @override
  String loadingLabel(String label) {
    return '$label, chargement';
  }

  @override
  String get previous => 'Précédents';

  @override
  String get next => 'Suivants';

  @override
  String get coverPhoto => 'Photo de couverture';

  @override
  String get retry => 'Réessayer';

  @override
  String get liveBroadcast => 'Diffusion en direct';

  @override
  String get liveBadge => 'DIRECT';
}
