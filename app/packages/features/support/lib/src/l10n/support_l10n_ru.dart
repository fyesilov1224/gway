// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'support_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class SupportL10nRu extends SupportL10n {
  SupportL10nRu([String locale = 'ru']) : super(locale);

  @override
  String get ruleTicketRate =>
      'Сегодня вы открыли слишком много обращений. Попробуйте завтра или ответьте в открытых.';

  @override
  String get ruleReplyRate =>
      'Слишком много ответов за короткое время. Подождите немного.';

  @override
  String get ticketClosed =>
      'Обращение закрыто. Откройте новое, чтобы продолжить.';

  @override
  String get unsupportedImage =>
      'Этот тип файла не поддерживается. Выберите JPEG, PNG или WebP.';

  @override
  String get kindProblem => 'Проблема';

  @override
  String get kindProblemText => 'Что-то сломалось или не работает.';

  @override
  String get kindRequest => 'Запрос';

  @override
  String get kindRequestText =>
      'Попросите о действии с аккаунтом, группой или оплатой.';

  @override
  String get kindSuggestion => 'Предложение';

  @override
  String get kindSuggestionText => 'Поделитесь идеей или предложением.';

  @override
  String get statusOpen => 'Новое';

  @override
  String get statusInProgress => 'На рассмотрении';

  @override
  String get statusResolved => 'Решено';

  @override
  String get statusClosed => 'Закрыто';

  @override
  String get guide => 'Руководство';

  @override
  String get guideSearchHint => 'Поиск: например, ссылка-приглашение, пароль';

  @override
  String get clearSearch => 'Очистить поиск';

  @override
  String get guideIntro =>
      'Пошагово объясняет каждый раздел GWAY. Выберите главу или воспользуйтесь поиском.';

  @override
  String get noHits =>
      'Ничего не найдено. Попробуйте другое слово или напишите в поддержку.';

  @override
  String get writeSupport => 'Написать в поддержку';

  @override
  String hitsFound(int count) {
    return 'Найдено тем: $count';
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
  String get chapterNotFound => 'Глава не найдена.';

  @override
  String get backToGuide => 'К руководству';

  @override
  String get notSolved => 'Проблема не решена?';

  @override
  String get notSolvedHint =>
      'Напишите команде платформы; ответ появится в разделе «Настройки → Поддержка и отзывы».';

  @override
  String get nextChapter => 'Следующая глава';

  @override
  String get sent => 'Сообщение отправлено команде платформы.';

  @override
  String get newMessage => 'Новое обращение';

  @override
  String get aboutWhat => 'О чём вы пишете?';

  @override
  String get pickKind => 'Выберите тип.';

  @override
  String get relatedGroup => 'Связанная группа (необязательно)';

  @override
  String get noGroup => 'Не про группу';

  @override
  String get subject => 'Тема';

  @override
  String get subjectRequired => 'Напишите короткую тему.';

  @override
  String get description => 'Описание';

  @override
  String get descriptionHint =>
      'Что произошло и чего вы ожидали? Чем подробнее, тем быстрее помощь.';

  @override
  String get descriptionRequired => 'Кратко опишите, что произошло.';

  @override
  String get send => 'Отправить';

  @override
  String get supportTitle => 'Поддержка и отзывы';

  @override
  String get emptyIntro =>
      'Можно написать команде платформы о проблеме, запросе или предложении.';

  @override
  String get listIntro =>
      'Обращения уходят команде платформы; ответы и статус — здесь.';

  @override
  String get newReply => 'Новый ответ';

  @override
  String get message => 'Обращение';

  @override
  String get notFound => 'Обращение не найдено.';

  @override
  String get goBack => 'Назад';

  @override
  String get team => 'Команда GWAY';

  @override
  String get you => 'Вы';

  @override
  String get addScreenshot => 'Добавить скриншот';

  @override
  String get writeReply => 'Напишите ответ';

  @override
  String get removeImage => 'Убрать изображение';

  @override
  String screenshots(int count, int max) {
    return 'Скриншоты ($count/$max)';
  }

  @override
  String get enlargeScreenshot => 'Увеличить скриншот';
}
