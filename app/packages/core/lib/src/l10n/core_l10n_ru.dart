// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'core_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class CoreL10nRu extends CoreL10n {
  CoreL10nRu([String locale = 'ru']) : super(locale);

  @override
  String get networkFailure =>
      'Не удалось подключиться. Проверьте подключение к интернету и повторите попытку.';

  @override
  String get unauthorizedFailure => 'Сеанс истёк. Войдите снова.';

  @override
  String get forbiddenFailure => 'У вас нет прав на это действие.';

  @override
  String get notFoundFailure => 'Мы не нашли то, что вы ищете.';

  @override
  String get rateLimitedFailure =>
      'Слишком много попыток. Подождите немного и повторите.';

  @override
  String get unexpectedFailure => 'Что-то пошло не так. Повторите попытку.';

  @override
  String get storageTooLarge =>
      'Файл слишком большой. Можно загрузить до 5 МБ.';

  @override
  String get storageUnsupportedType =>
      'Этот тип файла не поддерживается. Выберите JPEG, PNG или WebP.';

  @override
  String get categoryMusic => 'Музыка';

  @override
  String get categoryHiking => 'Походы';

  @override
  String get categoryRunning => 'Бег';

  @override
  String get categoryCycling => 'Велоспорт';

  @override
  String get categoryNature => 'Природа';

  @override
  String get categorySports => 'Спорт';

  @override
  String get categoryArt => 'Искусство';

  @override
  String get categoryPhotography => 'Фотография';

  @override
  String get categoryDance => 'Танцы';

  @override
  String get categoryBooks => 'Книги';

  @override
  String get categoryGames => 'Игры';

  @override
  String get categoryTravel => 'Путешествия';

  @override
  String get categoryFood => 'Еда';

  @override
  String get categoryTechnology => 'Технологии';

  @override
  String get categoryVolunteering => 'Волонтёрство';

  @override
  String get categoryMotorcycle => 'Мотоциклы';

  @override
  String get categoryCamping => 'Кемпинг';

  @override
  String get categoryChess => 'Шахматы';
}
