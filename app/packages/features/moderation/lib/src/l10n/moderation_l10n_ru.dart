// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'moderation_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class ModerationL10nRu extends ModerationL10n {
  ModerationL10nRu([String locale = 'ru']) : super(locale);

  @override
  String get ruleRateLimited =>
      'Сегодня вы отправили слишком много жалоб. Попробуйте завтра.';

  @override
  String get ruleTargetInvalid =>
      'Этого контента больше нет или он вам недоступен.';

  @override
  String get ruleSelf => 'Нельзя пожаловаться на себя или свой контент.';

  @override
  String get ruleAppealNotAllowed => 'Это решение больше нельзя обжаловать.';

  @override
  String get ruleDuplicate => 'Вы уже пожаловались; жалоба на рассмотрении.';

  @override
  String get deletedAccount => 'Удалённый аккаунт';

  @override
  String get reasonSpam => 'Спам или обман';

  @override
  String get reasonHarassment => 'Домогательства или травля';

  @override
  String get reasonHate => 'Язык вражды';

  @override
  String get reasonViolence => 'Насилие или угрозы';

  @override
  String get reasonSexual => 'Сексуальный контент';

  @override
  String get reasonMisinformation => 'Ложная информация';

  @override
  String get reasonOther => 'Другое';

  @override
  String get sanctionWarning => 'Предупреждение';

  @override
  String get sanctionMute => 'Заглушение';

  @override
  String get sanctionKick => 'Исключение из группы';

  @override
  String get sanctionBan => 'Бан';

  @override
  String get illegalViolence => 'Насилие';

  @override
  String get illegalThreat => 'Угроза';

  @override
  String get illegalInsult => 'Оскорбление';

  @override
  String get illegalHate => 'Язык вражды';

  @override
  String get illegalSexual => 'Сексуальное насилие';

  @override
  String get illegalFraud => 'Мошенничество';

  @override
  String get illegalDrugs => 'Наркотики';

  @override
  String get illegalTerror => 'Терроризм';

  @override
  String get illegalOther => 'Другое преступление';

  @override
  String muteDays(int days) {
    return 'Заглушение, дней: $days';
  }

  @override
  String banDays(int days) {
    return 'Бан, дней: $days';
  }

  @override
  String get permanentBan => 'Бессрочный бан';

  @override
  String get thresholdMajority => 'Простое большинство';

  @override
  String get thresholdMajorityText => 'Больше половины голосов';

  @override
  String get thresholdTwoThirds => 'Две трети';

  @override
  String get thresholdTwoThirdsText => 'Не менее двух третей голосов';

  @override
  String get thresholdUnanimous => 'Единогласно';

  @override
  String get thresholdUnanimousText => 'Все голоса';

  @override
  String get targetPost => 'Публикация';

  @override
  String get targetComment => 'Комментарий';

  @override
  String get targetEvent => 'Мероприятие';

  @override
  String get targetLiveComment => 'Комментарий в эфире';

  @override
  String get targetMessage => 'Сообщение в чате группы';

  @override
  String get targetMember => 'Участник';

  @override
  String get appealPending => 'Ожидает решения';

  @override
  String get appealUpheld => 'Решение оставлено в силе';

  @override
  String get appealOverturned => 'Решение отменено';

  @override
  String get banApplied => 'Бан применён.';

  @override
  String get banAppliedSuspended =>
      'Бан применён. Аккаунт приостановлен до проверки платформой.';

  @override
  String get caseOpened =>
      'Дело открыто. Комиссия проголосует в течение 72 часов.';

  @override
  String get openCaseTitle => 'Открыть дисциплинарное дело';

  @override
  String caseAboutNow(String name) {
    return 'Касается: $name. Бан применяется сразу, без голосования комиссии.';
  }

  @override
  String caseAboutVote(String name) {
    return 'Касается: $name. Комиссия проголосует по вашему предложению в течение 72 часов.';
  }

  @override
  String get proposedSanction => 'Предлагаемая мера';

  @override
  String get duration => 'Срок';

  @override
  String get permanent => 'Бессрочно';

  @override
  String get permanentLower => 'бессрочно';

  @override
  String days(int days) {
    return 'Дней: $days';
  }

  @override
  String get applyNow => 'Применить сразу, без голосования';

  @override
  String get applyNowHint =>
      'Бан без ожидания комиссии. Человек может обжаловать в течение 7 дней.';

  @override
  String get illegalActivity => 'Незаконная деятельность';

  @override
  String get illegalHintNow =>
      'После бана дело уходит команде платформы, а аккаунт приостанавливается до проверки. Эту отметку нельзя изменить.';

  @override
  String get illegalHintVote =>
      'Если комиссия одобрит, дело уйдёт команде платформы, а аккаунт приостановится до проверки. Эту отметку нельзя изменить.';

  @override
  String get reason => 'Причина';

  @override
  String get reasonHintNow =>
      'Что произошло? Этот текст увидят человек и тот, кто рассмотрит апелляцию.';

  @override
  String get reasonHintVote =>
      'Что произошло? Комиссия проголосует по этому тексту.';

  @override
  String get reasonMin10 => 'Причина — не менее 10 символов.';

  @override
  String get muteNow => 'Заглушить сейчас (24 часа)';

  @override
  String get muteNowHint =>
      'До решения комиссии человек не сможет комментировать и говорить в эфире.';

  @override
  String get ban => 'Забанить';

  @override
  String get openCase => 'Открыть дело';

  @override
  String leftDays(int days) {
    return '$days дн.';
  }

  @override
  String leftDaysHours(int days, int hours) {
    return '$days дн. $hours ч';
  }

  @override
  String leftHours(int hours) {
    return '$hours ч';
  }

  @override
  String get leftFewMinutes => 'несколько минут';

  @override
  String minChars(int min) {
    return 'Напишите не менее $min символов.';
  }

  @override
  String get cancel => 'Отмена';

  @override
  String get threshold => 'Порог решения комиссии';

  @override
  String thresholdChanged(String threshold) {
    return 'Порог теперь — «$threshold». Действует для новых дел.';
  }

  @override
  String moderationOf(String group) {
    return 'Модерация · $group';
  }

  @override
  String get reports => 'Жалобы';

  @override
  String reportsCount(int count) {
    return 'Жалобы ($count)';
  }

  @override
  String get cases => 'Дела';

  @override
  String casesCount(int count) {
    return 'Дела ($count)';
  }

  @override
  String get sanctions => 'Меры';

  @override
  String sanctionsCount(int count) {
    return 'Меры ($count)';
  }

  @override
  String get moderationTeamOnly =>
      'Модерацию группы видят только владелец и команда модерации.';

  @override
  String get goBack => 'Назад';

  @override
  String get noReports =>
      'Открытых жалоб нет. Жалобы участников появятся здесь.';

  @override
  String get refresh => 'Обновить';

  @override
  String get removeContent => 'Удалить контент';

  @override
  String get remove => 'Удалить';

  @override
  String get contentRemoved => 'Контент удалён.';

  @override
  String reportCount(int count) {
    return 'Жалоб: $count';
  }

  @override
  String get view => 'Открыть';

  @override
  String get reportDismissed => 'Жалоба отклонена.';

  @override
  String get dismiss => 'Отклонить';

  @override
  String get openCaseShort => 'Открыть дело';

  @override
  String get rankOnlyDismiss =>
      'Ранг этого человека не ниже вашего — можно только отклонить.';

  @override
  String get noCases =>
      'Дисциплинарных дел пока нет. Их открывают из жалобы или со страницы участников.';

  @override
  String get voteApproved =>
      'Голос учтён. Комиссия одобрила меру — она применена.';

  @override
  String get voteRejected => 'Голос учтён. Комиссия отклонила меру.';

  @override
  String get voteSaved => 'Голос учтён. Его можно изменить до решения.';

  @override
  String get statusVoting => 'Голосование';

  @override
  String get statusApproved => 'Одобрено';

  @override
  String get statusRejected => 'Отклонено';

  @override
  String proposed(String sanction) {
    return 'Предложено: $sanction';
  }

  @override
  String get directBan => 'Бан без голосования';

  @override
  String illegalLabel(String category) {
    return 'Незаконная деятельность: $category';
  }

  @override
  String tally(int approvals, int rejections, int voters) {
    return 'За: $approvals · против: $rejections · голосующих: $voters';
  }

  @override
  String votingEndsIn(String time) {
    return 'Голосование закончится через $time';
  }

  @override
  String bannedBy(String name) {
    return 'Забанил(а): $name';
  }

  @override
  String openedBy(String name) {
    return 'Открыл(а): $name';
  }

  @override
  String get approve => 'Одобрить';

  @override
  String get reject => 'Отклонить';

  @override
  String get noSanctions =>
      'Мер пока нет. Здесь появятся одобренные меры и апелляции.';

  @override
  String get liftSanction => 'Отменить меру';

  @override
  String get keepSanction => 'Оставить меру';

  @override
  String get noteToPerson => 'Заметка для человека (необязательно)';

  @override
  String get liftedNotified => 'Мера отменена; человек уведомлён.';

  @override
  String get appealRejectedNotified =>
      'Апелляция отклонена; человек уведомлён.';

  @override
  String get lifted => 'Отменено';

  @override
  String get interimMute => 'Срочное заглушение';

  @override
  String get running => 'Действует';

  @override
  String get applied => 'Применено';

  @override
  String get interimUntilDecision => 'Срочное заглушение · до решения комиссии';

  @override
  String until(String date) {
    return 'до $date';
  }

  @override
  String appealLine(String status) {
    return 'Апелляция · $status';
  }

  @override
  String noteLine(String note) {
    return 'Заметка: $note';
  }

  @override
  String get ownerParty =>
      'Владелец — сторона дела, поэтому апелляцию рассматривает команда платформы.';

  @override
  String get keep => 'Оставить';

  @override
  String casesAwaitingVote(int count) {
    return 'Ждут вашего голоса: $count';
  }

  @override
  String appealsCount(int count) {
    return 'Апелляций: $count';
  }

  @override
  String get moderation => 'Модерация';

  @override
  String get noWork => 'Ничего не ждёт';

  @override
  String get mySanctions => 'Мои ограничения';

  @override
  String get noMySanctions =>
      'Ни в одной группе у вас нет ограничений. Спасибо, что соблюдаете правила.';

  @override
  String get interimEnded => 'Срочное заглушение завершено';

  @override
  String interimLatest(String date) {
    return 'Срочное заглушение · до решения комиссии, не позднее $date';
  }

  @override
  String untilCap(String date) {
    return 'До $date';
  }

  @override
  String get ended => 'Завершено';

  @override
  String get appeal => 'Обжаловать';

  @override
  String get appealHint => 'Почему вы считаете это несправедливым?';

  @override
  String get send => 'Отправить';

  @override
  String get appealSent =>
      'Апелляция отправлена. Вы получите уведомление о решении.';

  @override
  String reasonLine(String reason) {
    return 'Причина: $reason';
  }

  @override
  String yourAppealLine(String status) {
    return 'Ваша апелляция · $status';
  }

  @override
  String get appealOnce =>
      'Решение можно обжаловать один раз в течение 7 дней.';

  @override
  String get reportPost => 'Пожаловаться на публикацию';

  @override
  String get reportComment => 'Пожаловаться на комментарий';

  @override
  String get reportEvent => 'Пожаловаться на мероприятие';

  @override
  String get reportMessage => 'Пожаловаться на сообщение';

  @override
  String get reportMatchProfile => 'Пожаловаться на профиль знакомств';

  @override
  String get reportPhoto => 'Пожаловаться на фото';

  @override
  String get reportUser => 'Пожаловаться на пользователя';

  @override
  String get reportReceived =>
      'Жалоба получена. Мы рассмотрим её и примем меры; ваше имя не покажут тому, на кого вы пожаловались.';

  @override
  String get whyReport => 'Почему вы жалуетесь?';

  @override
  String get detailsOptional => 'Подробности (необязательно)';

  @override
  String get detailsHint => 'Кратко опишите, что произошло.';

  @override
  String get report => 'Пожаловаться';
}
