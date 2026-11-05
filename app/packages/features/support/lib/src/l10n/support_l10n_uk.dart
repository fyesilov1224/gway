// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'support_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class SupportL10nUk extends SupportL10n {
  SupportL10nUk([String locale = 'uk']) : super(locale);

  @override
  String get ruleTicketRate =>
      'Сьогодні ви відкрили забагато звернень. Спробуйте завтра або відповідайте у відкритих.';

  @override
  String get ruleReplyRate =>
      'Забагато відповідей за короткий час. Зачекайте трохи.';

  @override
  String get ticketClosed =>
      'Звернення закрито. Відкрийте нове, щоб продовжити.';

  @override
  String get unsupportedImage =>
      'Цей тип файлу не підтримується. Виберіть JPEG, PNG або WebP.';

  @override
  String get kindProblem => 'Проблема';

  @override
  String get kindProblemText => 'Щось зламалося або не працює.';

  @override
  String get kindRequest => 'Запит';

  @override
  String get kindRequestText =>
      'Попросіть про дію з акаунтом, групою чи оплатою.';

  @override
  String get kindSuggestion => 'Пропозиція';

  @override
  String get kindSuggestionText => 'Поділіться ідеєю чи пропозицією.';

  @override
  String get statusOpen => 'Нове';

  @override
  String get statusInProgress => 'На розгляді';

  @override
  String get statusResolved => 'Вирішено';

  @override
  String get statusClosed => 'Закрито';

  @override
  String get guide => 'Посібник';

  @override
  String get guideSearchHint =>
      'Пошук: наприклад, посилання-запрошення, пароль';

  @override
  String get clearSearch => 'Очистити пошук';

  @override
  String get guideIntro =>
      'Покроково пояснює кожен розділ GWAY. Виберіть розділ або скористайтеся пошуком.';

  @override
  String get noHits =>
      'Нічого не знайдено. Спробуйте інше слово або напишіть у підтримку.';

  @override
  String get writeSupport => 'Написати в підтримку';

  @override
  String hitsFound(int count) {
    return 'Знайдено тем: $count';
  }

  @override
  String chapterSemantics(String title, String summary, int count) {
    return '$title. $summary Тем: $count.';
  }

  @override
  String topicCount(int count) {
    return 'Тем: $count';
  }

  @override
  String get chapterNotFound => 'Розділ не знайдено.';

  @override
  String get backToGuide => 'До посібника';

  @override
  String get notSolved => 'Проблему не вирішено?';

  @override
  String get notSolvedHint =>
      'Напишіть команді платформи; відповідь з’явиться в розділі «Налаштування → Підтримка та відгуки».';

  @override
  String get nextChapter => 'Наступний розділ';

  @override
  String get sent => 'Повідомлення надіслано команді платформи.';

  @override
  String get newMessage => 'Нове звернення';

  @override
  String get aboutWhat => 'Про що ви пишете?';

  @override
  String get pickKind => 'Виберіть тип.';

  @override
  String get relatedGroup => 'Пов’язана група (необов’язково)';

  @override
  String get noGroup => 'Не про групу';

  @override
  String get subject => 'Тема';

  @override
  String get subjectRequired => 'Напишіть коротку тему.';

  @override
  String get description => 'Опис';

  @override
  String get descriptionHint =>
      'Що сталося і чого ви очікували? Що детальніше, то швидша допомога.';

  @override
  String get descriptionRequired => 'Коротко опишіть, що сталося.';

  @override
  String get send => 'Надіслати';

  @override
  String get supportTitle => 'Підтримка та відгуки';

  @override
  String get emptyIntro =>
      'Можна написати команді платформи про проблему, запит чи пропозицію.';

  @override
  String get listIntro =>
      'Звернення надходять команді платформи; відповіді й статус — тут.';

  @override
  String get newReply => 'Нова відповідь';

  @override
  String get message => 'Звернення';

  @override
  String get notFound => 'Звернення не знайдено.';

  @override
  String get goBack => 'Назад';

  @override
  String get team => 'Команда GWAY';

  @override
  String get you => 'Ви';

  @override
  String get addScreenshot => 'Додати знімок екрана';

  @override
  String get writeReply => 'Напишіть відповідь';

  @override
  String get removeImage => 'Прибрати зображення';

  @override
  String screenshots(int count, int max) {
    return 'Знімки екрана ($count/$max)';
  }

  @override
  String get enlargeScreenshot => 'Збільшити знімок екрана';
}
