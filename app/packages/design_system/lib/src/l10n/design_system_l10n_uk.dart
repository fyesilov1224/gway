// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'design_system_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class DesignSystemL10nUk extends DesignSystemL10n {
  DesignSystemL10nUk([String locale = 'uk']) : super(locale);

  @override
  String loadingLabel(String label) {
    return '$label, завантаження';
  }

  @override
  String get previous => 'Назад';

  @override
  String get next => 'Далі';

  @override
  String get coverPhoto => 'Обкладинка';

  @override
  String get retry => 'Повторити';

  @override
  String get liveBroadcast => 'Пряма трансляція';

  @override
  String get liveBadge => 'НАЖИВО';
}
