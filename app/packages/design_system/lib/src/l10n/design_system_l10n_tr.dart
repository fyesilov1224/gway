// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'design_system_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class DesignSystemL10nTr extends DesignSystemL10n {
  DesignSystemL10nTr([String locale = 'tr']) : super(locale);

  @override
  String loadingLabel(String label) {
    return '$label, yükleniyor';
  }

  @override
  String get previous => 'Öncekiler';

  @override
  String get next => 'Sonrakiler';

  @override
  String get coverPhoto => 'Kapak fotoğrafı';

  @override
  String get retry => 'Tekrar dene';

  @override
  String get liveBroadcast => 'Canlı yayın';

  @override
  String get liveBadge => 'CANLI';
}
