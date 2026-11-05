// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'design_system_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class DesignSystemL10nRu extends DesignSystemL10n {
  DesignSystemL10nRu([String locale = 'ru']) : super(locale);

  @override
  String loadingLabel(String label) {
    return '$label, загрузка';
  }

  @override
  String get previous => 'Назад';

  @override
  String get next => 'Далее';

  @override
  String get coverPhoto => 'Обложка';

  @override
  String get retry => 'Повторить';

  @override
  String get liveBroadcast => 'Прямой эфир';

  @override
  String get liveBadge => 'ЭФИР';
}
