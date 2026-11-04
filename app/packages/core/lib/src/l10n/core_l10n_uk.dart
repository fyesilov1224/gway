// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'core_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class CoreL10nUk extends CoreL10n {
  CoreL10nUk([String locale = 'uk']) : super(locale);

  @override
  String get networkFailure =>
      'Не вдалося підключитися. Перевірте з’єднання з інтернетом і спробуйте ще раз.';

  @override
  String get unauthorizedFailure => 'Сеанс завершився. Увійдіть знову.';

  @override
  String get forbiddenFailure => 'У вас немає дозволу на цю дію.';

  @override
  String get notFoundFailure => 'Ми не знайшли те, що ви шукаєте.';

  @override
  String get rateLimitedFailure =>
      'Забагато спроб. Зачекайте трохи й спробуйте ще раз.';

  @override
  String get unexpectedFailure => 'Щось пішло не так. Спробуйте ще раз.';

  @override
  String get storageTooLarge => 'Файл завеликий. Можна завантажити до 5 МБ.';

  @override
  String get storageUnsupportedType =>
      'Цей тип файлу не підтримується. Виберіть JPEG, PNG або WebP.';

  @override
  String get categoryMusic => 'Музика';

  @override
  String get categoryHiking => 'Походи';

  @override
  String get categoryRunning => 'Біг';

  @override
  String get categoryCycling => 'Велоспорт';

  @override
  String get categoryNature => 'Природа';

  @override
  String get categorySports => 'Спорт';

  @override
  String get categoryArt => 'Мистецтво';

  @override
  String get categoryPhotography => 'Фотографія';

  @override
  String get categoryDance => 'Танці';

  @override
  String get categoryBooks => 'Книги';

  @override
  String get categoryGames => 'Ігри';

  @override
  String get categoryTravel => 'Подорожі';

  @override
  String get categoryFood => 'Їжа';

  @override
  String get categoryTechnology => 'Технології';

  @override
  String get categoryVolunteering => 'Волонтерство';

  @override
  String get categoryMotorcycle => 'Мотоцикли';

  @override
  String get categoryCamping => 'Кемпінг';

  @override
  String get categoryChess => 'Шахи';
}
