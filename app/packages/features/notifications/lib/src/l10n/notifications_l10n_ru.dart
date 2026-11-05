// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'notifications_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class NotificationsL10nRu extends NotificationsL10n {
  NotificationsL10nRu([String locale = 'ru']) : super(locale);

  @override
  String get actLike => 'нравится ваша публикация.';

  @override
  String actComment(String text) {
    return 'прокомментировал(а): $text';
  }

  @override
  String actReply(String text) {
    return 'ответил(а) на ваш комментарий: $text';
  }

  @override
  String actCommentLike(String text) {
    return 'нравится ваш комментарий: $text';
  }

  @override
  String get actMentionPost => 'упомянул(а) вас в публикации.';

  @override
  String actMentionComment(String text) {
    return 'упомянул(а) вас в комментарии: $text';
  }

  @override
  String get actFollow => 'подписался(-ась) на вас.';

  @override
  String get actFollowRequest => 'хочет подписаться на вас.';

  @override
  String get actFollowAccepted => 'принял(а) ваш запрос на подписку.';

  @override
  String actLiveScheduled(String title) {
    return 'запланировал(а) эфир: $title';
  }

  @override
  String actLiveScheduledAt(String date, String title) {
    return 'запланировал(а) эфир на $date: $title';
  }

  @override
  String actLiveStarted(String title) {
    return 'начал(а) эфир: $title';
  }

  @override
  String actEventPromoted(String title) {
    return 'Освободилось место на «$title» — теперь вы участвуете.';
  }

  @override
  String actEventUpdated(String title) {
    return 'изменил(а) время или место «$title».';
  }

  @override
  String actEventCanceled(String title) {
    return 'отменил(а) «$title».';
  }

  @override
  String actReminderTomorrow(String title) {
    return '«$title» начнётся завтра. Придёте? Подтвердите.';
  }

  @override
  String actReminderHour(String title) {
    return '«$title» начнётся в течение часа.';
  }

  @override
  String actCaseVote(String group) {
    return 'открыл(а) дисциплинарное дело в группе «$group»; нужен ваш голос.';
  }

  @override
  String get actMuted =>
      'ограничила вам комментарии. Нажмите, чтобы узнать подробности или обжаловать.';

  @override
  String get actKicked =>
      'исключила вас из группы. Нажмите, чтобы узнать подробности или обжаловать.';

  @override
  String get actBanned =>
      'заблокировала вас в группе. Нажмите, чтобы узнать подробности или обжаловать.';

  @override
  String get actWarned =>
      'вынесла вам предупреждение. Нажмите, чтобы узнать подробности или обжаловать.';

  @override
  String actAppealSubmitted(String group) {
    return 'обжаловал(а) санкцию в группе «$group».';
  }

  @override
  String get actAppealDecided => 'рассмотрела вашу апелляцию.';

  @override
  String actEventApproved(String title) {
    return 'одобрил(а) ваш запрос на участие в «$title».';
  }

  @override
  String actEventDeclined(String title) {
    return 'не смог(ла) принять ваш запрос на «$title».';
  }

  @override
  String actEventReview(String title) {
    return 'Как прошло «$title»? Оцените и поделитесь воспоминаниями.';
  }

  @override
  String actGoalCompleted(String title) {
    return 'Вы выполнили «$title»! Значок уже в профиле.';
  }

  @override
  String get actTeammateRequest => 'хочет стать вашим напарником.';

  @override
  String get actTeammateAccepted => 'принял(а) ваш запрос в напарники.';

  @override
  String get actMatchCreated => 'Узнайте, кто это, в разделе «Мои пары».';

  @override
  String get actSuperLiked =>
      'отправил(а) вам суперлайк! Он(а) первым(-ой) в вашей ленте.';

  @override
  String actWelcomeRequested(String title) {
    return 'впервые идёт на «$title» и хочет, чтобы его встретили.';
  }

  @override
  String actWelcomeMatched(String title) {
    return 'встретит вас на «$title». Посмотрите заметку о встрече.';
  }

  @override
  String actWelcomeReleased(String title) {
    return 'больше не сможет встретить вас на «$title»; ищем другого.';
  }

  @override
  String actWelcomeWithdrawn(String title) {
    return 'отозвал(а) запрос на встречу на «$title».';
  }

  @override
  String get actLeagueResult =>
      'вошла в тройку лидеров лиги прошлого месяца! Таблица — на странице группы.';

  @override
  String actWelcomeThanked(String title) {
    return 'поблагодарил(а) вас за встречу на «$title».';
  }

  @override
  String get actTableInvite =>
      'собирает столик сегодня вечером и приглашает вас.';

  @override
  String get actTableReady =>
      'присоединился(-ась) — столик собран. Договоритесь о месте и времени в чате.';

  @override
  String actVenueRevealed(String title) {
    return '«$title»: нажмите, чтобы узнать, куда идти.';
  }

  @override
  String actHandshake(String title) {
    return 'обменялся(-ась) с вами рукопожатием на «$title».';
  }

  @override
  String get actCallMissed => 'звонил(а) вам — вы не ответили.';

  @override
  String get actCallGranted => '— доступ открыт. Звоните своим парам из чата.';

  @override
  String get actCallDeclined =>
      '— запрос пока не одобрен. Нажмите, чтобы узнать подробности.';

  @override
  String get actCallRevoked =>
      '— доступ закрыт. Нажмите, чтобы узнать подробности.';

  @override
  String actSeriesLimit(String title) {
    return '— следующая дата «$title» не открылась: месячный лимит группы исчерпан. Она откроется в новом месяце или после повышения тарифа.';
  }

  @override
  String get leadNewMatch => 'У вас новая пара!';

  @override
  String get leadSeries => 'Повторяющееся мероприятие';

  @override
  String get leadVenue => 'Место-сюрприз открыто';

  @override
  String get leadCalls => 'Голосовые звонки';

  @override
  String get periodToday => 'Сегодня';

  @override
  String get periodWeek => 'На этой неделе';

  @override
  String get periodEarlier => 'Ранее';

  @override
  String get agoNow => 'только что';

  @override
  String agoMinutes(int n) {
    return '$n мин';
  }

  @override
  String agoHours(int n) {
    return '$n ч';
  }

  @override
  String agoDays(int n) {
    return '$n д';
  }

  @override
  String get join => 'Присоединиться';

  @override
  String get see => 'Смотреть';

  @override
  String get prefsTitle => 'Настройки уведомлений';

  @override
  String get messages => 'Сообщения';

  @override
  String get directMessages => 'Личные сообщения';

  @override
  String get directMessagesHint =>
      'При новом личном сообщении, со звуком даже при закрытом приложении';

  @override
  String get groupMessages => 'Сообщения групп';

  @override
  String get groupMessagesHint =>
      'При сообщениях в чатах групп и столика, со звуком даже при закрытом приложении';

  @override
  String get events => 'Мероприятия';

  @override
  String get remindDay => 'Напомнить за день';

  @override
  String get remindDayHint => 'Если ваше мероприятие начнётся завтра';

  @override
  String get remindHour => 'Напомнить за час';

  @override
  String get remindHourHint => 'Если ваше мероприятие начнётся в течение часа';

  @override
  String get changes => 'Изменения и отмены';

  @override
  String get changesHint =>
      'При изменении времени или места либо отмене мероприятия';

  @override
  String get reviewRequests => 'Запросы на отзыв';

  @override
  String get reviewRequestsHint => 'Спросить «Как прошло?» после мероприятия';

  @override
  String get live => 'Прямые эфиры';

  @override
  String get liveAlerts => 'Запланированные и начавшиеся эфиры';

  @override
  String get liveAlertsHint =>
      'Когда группа планирует или начинает эфир, со звуком, если приложение открыто';

  @override
  String get matching => 'Знакомства';

  @override
  String get newMatches => 'Новые пары';

  @override
  String get newMatchesHint => 'При взаимной симпатии';

  @override
  String get alwaysSent =>
      'Результат запросов, переход из листа ожидания и санкции группы касаются вас напрямую, поэтому о них уведомляем всегда.';

  @override
  String get notifications => 'Уведомления';

  @override
  String get empty => 'Здесь появятся лайки, комментарии и новые подписчики.';

  @override
  String get refresh => 'Обновить';

  @override
  String get followRequests => 'Запросы на подписку';

  @override
  String andOthers(String name, int count) {
    return '$name и ещё $count';
  }

  @override
  String get delete => 'Удалить';

  @override
  String get actChessChallenge => 'приглашает вас сыграть в шахматы.';
}
