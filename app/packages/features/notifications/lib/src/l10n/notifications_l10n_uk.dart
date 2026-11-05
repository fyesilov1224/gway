// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'notifications_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class NotificationsL10nUk extends NotificationsL10n {
  NotificationsL10nUk([String locale = 'uk']) : super(locale);

  @override
  String get actLike => 'вподобав(-ла) ваш допис.';

  @override
  String actComment(String text) {
    return 'прокоментував(-ла): $text';
  }

  @override
  String actReply(String text) {
    return 'відповів(-ла) на ваш коментар: $text';
  }

  @override
  String actCommentLike(String text) {
    return 'вподобав(-ла) ваш коментар: $text';
  }

  @override
  String get actMentionPost => 'згадав(-ла) вас у дописі.';

  @override
  String actMentionComment(String text) {
    return 'згадав(-ла) вас у коментарі: $text';
  }

  @override
  String get actFollow => 'підписався(-лася) на вас.';

  @override
  String get actFollowRequest => 'хоче підписатися на вас.';

  @override
  String get actFollowAccepted => 'прийняв(-ла) ваш запит на підписку.';

  @override
  String actLiveScheduled(String title) {
    return 'запланував(-ла) трансляцію: $title';
  }

  @override
  String actLiveScheduledAt(String date, String title) {
    return 'запланував(-ла) трансляцію на $date: $title';
  }

  @override
  String actLiveStarted(String title) {
    return 'почав(-ла) трансляцію: $title';
  }

  @override
  String actEventPromoted(String title) {
    return 'Звільнилося місце на «$title» — тепер ви берете участь.';
  }

  @override
  String actEventUpdated(String title) {
    return 'змінив(-ла) час або місце «$title».';
  }

  @override
  String actEventCanceled(String title) {
    return 'скасував(-ла) «$title».';
  }

  @override
  String actReminderTomorrow(String title) {
    return '«$title» почнеться завтра. Прийдете? Підтвердьте.';
  }

  @override
  String actReminderHour(String title) {
    return '«$title» почнеться протягом години.';
  }

  @override
  String actCaseVote(String group) {
    return 'відкрив(-ла) дисциплінарну справу в групі «$group»; потрібен ваш голос.';
  }

  @override
  String get actMuted =>
      'обмежила вам коментарі. Натисніть, щоб дізнатися більше чи оскаржити.';

  @override
  String get actKicked =>
      'виключила вас із групи. Натисніть, щоб дізнатися більше чи оскаржити.';

  @override
  String get actBanned =>
      'заблокувала вас у групі. Натисніть, щоб дізнатися більше чи оскаржити.';

  @override
  String get actWarned =>
      'винесла вам попередження. Натисніть, щоб дізнатися більше чи оскаржити.';

  @override
  String actAppealSubmitted(String group) {
    return 'оскаржив(-ла) санкцію в групі «$group».';
  }

  @override
  String get actAppealDecided => 'розглянула вашу апеляцію.';

  @override
  String actEventApproved(String title) {
    return 'схвалив(-ла) ваш запит на участь у «$title».';
  }

  @override
  String actEventDeclined(String title) {
    return 'не зміг(-ла) прийняти ваш запит на «$title».';
  }

  @override
  String actEventReview(String title) {
    return 'Як минула «$title»? Оцініть і поділіться спогадами.';
  }

  @override
  String actGoalCompleted(String title) {
    return 'Ви виконали «$title»! Значок уже в профілі.';
  }

  @override
  String get actTeammateRequest => 'хоче стати вашим напарником.';

  @override
  String get actTeammateAccepted => 'прийняв(-ла) ваш запит у напарники.';

  @override
  String get actMatchCreated => 'Дізнайтеся, хто це, у розділі «Мої пари».';

  @override
  String get actSuperLiked =>
      'надіслав(-ла) вам суперлайк! Він(вона) першим(-ою) у вашій стрічці.';

  @override
  String actWelcomeRequested(String title) {
    return 'уперше йде на «$title» і хоче, щоб його зустріли.';
  }

  @override
  String actWelcomeMatched(String title) {
    return 'зустріне вас на «$title». Перегляньте нотатку про зустріч.';
  }

  @override
  String actWelcomeReleased(String title) {
    return 'більше не зможе зустріти вас на «$title»; шукаємо іншого.';
  }

  @override
  String actWelcomeWithdrawn(String title) {
    return 'відкликав(-ла) запит на зустріч на «$title».';
  }

  @override
  String get actLeagueResult =>
      'увійшла до трійки лідерів ліги минулого місяця! Таблиця — на сторінці групи.';

  @override
  String actWelcomeThanked(String title) {
    return 'подякував(-ла) вам за зустріч на «$title».';
  }

  @override
  String get actTableInvite => 'збирає столик сьогодні ввечері й запрошує вас.';

  @override
  String get actTableReady =>
      'приєднався(-лася) — столик зібрано. Домовтеся про місце й час у чаті.';

  @override
  String actVenueRevealed(String title) {
    return '«$title»: натисніть, щоб дізнатися, куди йти.';
  }

  @override
  String actHandshake(String title) {
    return 'потиснув(-ла) вам руку на «$title».';
  }

  @override
  String get actCallMissed => 'телефонував(-ла) вам — ви не відповіли.';

  @override
  String get actCallGranted =>
      '— доступ відкрито. Телефонуйте своїм парам із чату.';

  @override
  String get actCallDeclined =>
      '— запит поки не схвалено. Натисніть, щоб дізнатися більше.';

  @override
  String get actCallRevoked =>
      '— доступ закрито. Натисніть, щоб дізнатися більше.';

  @override
  String actSeriesLimit(String title) {
    return '— наступна дата «$title» не відкрилася: місячний ліміт групи вичерпано. Вона відкриється в новому місяці або після підвищення тарифу.';
  }

  @override
  String get leadNewMatch => 'У вас нова пара!';

  @override
  String get leadSeries => 'Повторювана подія';

  @override
  String get leadVenue => 'Місце-сюрприз відкрито';

  @override
  String get leadCalls => 'Голосові дзвінки';

  @override
  String get periodToday => 'Сьогодні';

  @override
  String get periodWeek => 'Цього тижня';

  @override
  String get periodEarlier => 'Раніше';

  @override
  String get agoNow => 'щойно';

  @override
  String agoMinutes(int n) {
    return '$n хв';
  }

  @override
  String agoHours(int n) {
    return '$n год';
  }

  @override
  String agoDays(int n) {
    return '$n д';
  }

  @override
  String get join => 'Приєднатися';

  @override
  String get see => 'Переглянути';

  @override
  String get prefsTitle => 'Налаштування сповіщень';

  @override
  String get messages => 'Повідомлення';

  @override
  String get directMessages => 'Особисті повідомлення';

  @override
  String get directMessagesHint =>
      'При новому особистому повідомленні, зі звуком навіть коли застосунок закритий';

  @override
  String get groupMessages => 'Повідомлення груп';

  @override
  String get groupMessagesHint =>
      'При повідомленнях у чатах груп і столика, зі звуком навіть коли застосунок закритий';

  @override
  String get events => 'Події';

  @override
  String get remindDay => 'Нагадати за день';

  @override
  String get remindDayHint => 'Якщо ваша подія почнеться завтра';

  @override
  String get remindHour => 'Нагадати за годину';

  @override
  String get remindHourHint => 'Якщо ваша подія почнеться протягом години';

  @override
  String get changes => 'Зміни та скасування';

  @override
  String get changesHint => 'При зміні часу чи місця або скасуванні події';

  @override
  String get reviewRequests => 'Запити на відгук';

  @override
  String get reviewRequestsHint => 'Запитати «Як минуло?» після події';

  @override
  String get live => 'Трансляції';

  @override
  String get liveAlerts => 'Заплановані й розпочаті трансляції';

  @override
  String get liveAlertsHint =>
      'Коли група планує або починає трансляцію, зі звуком, якщо застосунок відкритий';

  @override
  String get matching => 'Знайомства';

  @override
  String get newMatches => 'Нові пари';

  @override
  String get newMatchesHint => 'При взаємній симпатії';

  @override
  String get alwaysSent =>
      'Результат запитів, перехід зі списку очікування й санкції групи стосуються вас безпосередньо, тож про них повідомляємо завжди.';

  @override
  String get notifications => 'Сповіщення';

  @override
  String get empty => 'Тут з’являться вподобання, коментарі й нові підписники.';

  @override
  String get refresh => 'Оновити';

  @override
  String get followRequests => 'Запити на підписку';

  @override
  String andOthers(String name, int count) {
    return '$name та ще $count';
  }

  @override
  String get delete => 'Видалити';

  @override
  String get actChessChallenge => 'запрошує вас зіграти в шахи.';

  @override
  String actChessTeamInvite(String group) {
    return 'від імені $group запросив(-ла) вашу групу на командний шаховий матч.';
  }

  @override
  String actChessTeamAccepted(String group) {
    return 'прийняв(-ла) командний матч від імені $group. Розставте гравців.';
  }

  @override
  String actChessTeamDeclined(String group) {
    return 'відхилив(-ла) командний матч від імені $group.';
  }

  @override
  String actChessTeamStart(String group) {
    return 'Командний матч проти $group почався. До дошки!';
  }

  @override
  String get leadTeamMatch => 'Командний матч';

  @override
  String get actChessArenaStart =>
      'Турнір, на який ви записалися, почався. Відкрийте його, і вас одразу підберуть.';

  @override
  String get actChessArenaMedal =>
      'Ви увійшли до трійки найкращих! Медаль — у вашому шаховому профілі.';

  @override
  String get leadArena => 'Шаховий турнір';
}
