// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'events_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class EventsL10nRu extends EventsL10n {
  EventsL10nRu([String locale = 'ru']) : super(locale);

  @override
  String get pollSingle => 'В этом опросе можно выбрать только один вариант.';

  @override
  String get pollOptionGone => 'Этого варианта больше нет. Обновите страницу.';

  @override
  String get reviewWindow =>
      'Участники могут оценить мероприятие в течение 30 дней после окончания.';

  @override
  String get greeterNeedsAttendance =>
      'Чтобы встречать новичков, нужно побывать хотя бы на одном мероприятии группы.';

  @override
  String get note80 => 'Заметка — до 80 символов.';

  @override
  String get pollClosed => 'Опрос закрыт или вы не можете голосовать.';

  @override
  String get cover5mb => 'Обложка — до 5 МБ.';

  @override
  String get imagesOnly => 'Можно загрузить только JPEG, PNG или WebP.';

  @override
  String get claimNotAllowed =>
      'Сейчас нельзя отчитаться о задании: оно завершено или вы не в группе.';

  @override
  String get claimApprovedLocked => 'Одобренный отчёт нельзя отозвать.';

  @override
  String get claimDuplicate => 'Вы уже отчитались об этом задании.';

  @override
  String get repeatsWeekly => 'Повторяется каждую неделю';

  @override
  String get repeatsBiweekly => 'Повторяется раз в две недели';

  @override
  String surprisePlace(String place) {
    return 'Место-сюрприз · $place';
  }

  @override
  String get goalPersonal => 'Личная цель';

  @override
  String get goalPersonalHint => 'Каждый участник выполняет свою норму.';

  @override
  String get goalGroup => 'Цель группы';

  @override
  String get goalGroupHint => 'Вклад всех складывается в один счётчик.';

  @override
  String get goalTeam => 'Командная цель';

  @override
  String get goalTeamHint =>
      'Администраторы формируют команды; у каждой общий счётчик.';

  @override
  String get goalTask => 'Задание с подтверждением';

  @override
  String get goalTaskHint =>
      'Участник отмечает «Сделано», администратор подтверждает.';

  @override
  String unitAttended(int count) {
    return 'участий';
  }

  @override
  String unitOrganized(int count) {
    return 'организованных';
  }

  @override
  String unitMemories(int count) {
    return 'воспоминаний';
  }

  @override
  String get claimPending => 'Ожидает подтверждения';

  @override
  String get claimApproved => 'Подтверждено';

  @override
  String get claimRejected => 'Не подтверждено';

  @override
  String get notClaimedYet => 'Ещё не отмечено';

  @override
  String get whenAny => 'Любое время';

  @override
  String get whenToday => 'Сегодня';

  @override
  String get whenWeek => 'В течение 7 дней';

  @override
  String get viewDay => 'День';

  @override
  String get viewWeek => 'Неделя';

  @override
  String get viewMonth => 'Месяц';

  @override
  String countAttended(int count) {
    return 'Участий: $count';
  }

  @override
  String countOrganized(int count) {
    return 'Организовано: $count';
  }

  @override
  String countMemories(int count) {
    return 'Воспоминаний: $count';
  }

  @override
  String countReviews(int count) {
    return 'Отзывов: $count';
  }

  @override
  String countWelcomed(int count) {
    return 'Встречено новичков: $count';
  }

  @override
  String countHandshakes(int count) {
    return 'Рукопожатий: $count';
  }

  @override
  String countHeld(int count) {
    return 'Мероприятий: $count';
  }

  @override
  String countGoodReviews(int count) {
    return 'Хороших отзывов: $count';
  }

  @override
  String leagueStanding(String month, int groups, int rank, int points) {
    return '$month: $rank-е место из $groups групп, очков: $points.';
  }

  @override
  String goingCount(int count) {
    return 'Участников: $count';
  }

  @override
  String goingOfCapacity(int count, int capacity) {
    return 'Участников: $count / $capacity';
  }

  @override
  String firstEventOfYear(String title) {
    return 'Первое мероприятие года: $title';
  }

  @override
  String firstEventOfYearOn(String title, String date) {
    return 'Первое мероприятие года: $title · $date';
  }

  @override
  String get myCalendar => 'Мой календарь';

  @override
  String get groupCalendar => 'Календарь группы';

  @override
  String get previous => 'Назад';

  @override
  String get next => 'Далее';

  @override
  String get today => 'Сегодня';

  @override
  String get groupsEvents => 'Мероприятия моих групп';

  @override
  String get showNotJoined => 'Показывать и те, где вы не участвуете';

  @override
  String get noJoinedInRange =>
      'В эти даты у вас нет мероприятий. Можно посмотреть мероприятия ваших групп.';

  @override
  String get noEventsInRange => 'В эти даты мероприятий нет.';

  @override
  String get showGroupsEvents => 'Показать мероприятия моих групп';

  @override
  String get backToToday => 'Вернуться к сегодня';

  @override
  String get noEventsDay => 'В этот день мероприятий нет.';

  @override
  String get contributions => 'Вклад в сообщество';

  @override
  String get howBadges => 'Как получить значки?';

  @override
  String get badgesEmpty =>
      'Когда вы побываете на мероприятии, здесь появятся ваш вклад и первый значок.';

  @override
  String get badgesRules =>
      'Значки начисляются только за реальные дела: посещённые и организованные мероприятия, воспоминания и отзывы. Лайки и подписчики не учитываются. Не учитываются участия, отмеченные организатором как «не пришёл». Рейтингов нет.';

  @override
  String get categoryFan => 'Фанат категории';

  @override
  String get pastEvents => 'Прошедшие мероприятия';

  @override
  String get noPastEvents => 'У этой группы пока нет прошедших мероприятий.';

  @override
  String get refresh => 'Обновить';

  @override
  String get canceled => 'Отменено';

  @override
  String get olderEvents => 'Более ранние мероприятия';

  @override
  String get completed => 'Выполнено';

  @override
  String get ended => 'Завершено';

  @override
  String teamName(String name) {
    return 'Команда: $name';
  }

  @override
  String get teamNotice =>
      'Когда вас добавят в команду, здесь появится прогресс.';

  @override
  String get goals => 'Цели';

  @override
  String get createGoal => 'Создать цель';

  @override
  String get goalsEmpty =>
      'Например, «4 похода в этом месяце» или «Вместе 50 участий» — создайте первую цель.';

  @override
  String get claimSent => 'Ваш отчёт отправлен администратору.';

  @override
  String get goal => 'Цель';

  @override
  String get goalCountsRule =>
      'Учитываются только мероприятия этой группы за период; участия с отметкой «не пришёл» не считаются.';

  @override
  String get withdrawClaim => 'Отозвать отчёт';

  @override
  String get claimWithdrawn => 'Отчёт отозван.';

  @override
  String get done => 'Сделано';

  @override
  String get teams => 'Команды';

  @override
  String get createTeam => 'Создать команду';

  @override
  String get noTeams => 'Команд пока нет.';

  @override
  String deleteTeam(String name) {
    return 'Удалить команду «$name»';
  }

  @override
  String get teamDeleted => 'Команда удалена.';

  @override
  String pendingClaims(int count) {
    return 'Отчёты на подтверждение ($count)';
  }

  @override
  String get claimRejectedToast => 'Отчёт не подтверждён.';

  @override
  String get decline => 'Отклонить';

  @override
  String get approve => 'Подтвердить';

  @override
  String taskDone(String name) {
    return '$name выполнил(а) задание.';
  }

  @override
  String completions(int count) {
    return 'Выполнили ($count)';
  }

  @override
  String get noCompletions =>
      'Пока никто не выполнил. Каждый, кто выполнит, получит значок этой цели в профиле.';

  @override
  String get goalCanceled => 'Цель отменена.';

  @override
  String get cancelGoal => 'Отменить цель';

  @override
  String teamCreated(String name) {
    return 'Команда «$name» создана.';
  }

  @override
  String get teamNameLabel => 'Название команды';

  @override
  String get createTheTeam => 'Создать команду';

  @override
  String createTeamWith(int count) {
    return 'Создать команду (человек: $count)';
  }

  @override
  String get goalCreated => 'Цель создана.';

  @override
  String get title => 'Название';

  @override
  String get goalTitleExample => 'Например, «Октябрьские походы»';

  @override
  String get taskTitleExample => 'Например, «Показать новичку маршрут»';

  @override
  String get titleMin3 => 'Название — не менее 3 символов.';

  @override
  String get descriptionOptional => 'Описание (необязательно)';

  @override
  String get targetNumber => 'Целевое число';

  @override
  String get target1to1000 => 'Введите число от 1 до 1000.';

  @override
  String get period => 'Период';

  @override
  String periodRange(String from, String to) {
    return '$from – $to (не более 92 дней)';
  }

  @override
  String get createTheGoal => 'Создать цель';

  @override
  String get iDidTask => 'Я выполнил(а) задание';

  @override
  String get whatDidYouDo => 'Что вы сделали? (необязательно)';

  @override
  String get whatDidYouDoHint => 'Администратор подтвердит, прочитав заметку.';

  @override
  String get cancel => 'Отмена';

  @override
  String get send => 'Отправить';

  @override
  String get handshake => 'Рукопожатие';

  @override
  String get handshakeHint =>
      'Отсканируйте коды друг друга — вы оба появитесь в «Моих знакомствах».';

  @override
  String get open => 'Открыть';

  @override
  String handshakeAt(String title) {
    return 'Рукопожатие · $title';
  }

  @override
  String get myCode => 'Мой код';

  @override
  String get scan => 'Сканировать';

  @override
  String get yourHandshakeCode => 'Ваш код рукопожатия';

  @override
  String get codeHint =>
      'Пусть собеседник отсканирует код во вкладке «Сканировать» или введёт его. Код обновляется каждые несколько минут; фото потом не сработает.';

  @override
  String get cameraFailed =>
      'Не удалось открыть камеру. Разрешите доступ в настройках или введите код ниже.';

  @override
  String get scanHint =>
      'Наведите камеру на QR-код собеседника или введите его код.';

  @override
  String get typeCodeHint => 'Введите 6-значный код с экрана собеседника.';

  @override
  String get code => 'Код';

  @override
  String get alreadyMet => 'Вы уже знакомы';

  @override
  String get metNow => 'Вы познакомились!';

  @override
  String personWithUsername(String name, String username) {
    return '$name (@$username)';
  }

  @override
  String get ok => 'Хорошо';

  @override
  String get metPeople => 'Мои знакомства';

  @override
  String get metEmpty =>
      'Когда вы обменяетесь рукопожатием на мероприятии, человек появится здесь. Рукопожатие открывается на странице мероприятия.';

  @override
  String get goToCalendar => 'Открыть календарь';

  @override
  String get metPrivacy =>
      'Это видите только вы. В профиле показано лишь число рукопожатий.';

  @override
  String metRow(String username, String event, String date) {
    return '@$username · $event · $date';
  }

  @override
  String get howPoints => 'Как считаются очки?';

  @override
  String get leagueIntro =>
      'Группы одной категории в одной провинции соревнуются каждый месяц. Учитываются мероприятия, завершённые в этом месяце.';

  @override
  String get ruleAttendance => 'Участие: 1 очко';

  @override
  String get ruleAttendanceHint =>
      'За каждого пришедшего; не более 30 на мероприятие.';

  @override
  String get ruleHeld => 'Мероприятие: 5 очков';

  @override
  String get ruleHeldHint =>
      'Каждое мероприятие, где кроме организатора было не меньше 3 человек.';

  @override
  String get ruleWelcome => 'Встреча новичка: 3 очка';

  @override
  String get ruleWelcomeHint => 'Встретить того, кто пришёл впервые.';

  @override
  String get ruleReview => 'Хороший отзыв: 1 очко';

  @override
  String get ruleReviewHint => 'Каждый отзыв на 4 или 5 звёзд.';

  @override
  String get leagueRulesNote =>
      'Отмеченные «не пришёл» не учитываются. Итоги становятся окончательными через 8 дней после конца месяца; участники тройки лидеров получают уведомление.';

  @override
  String get groupsLeague => 'Лига групп';

  @override
  String get category => 'Категория';

  @override
  String get province => 'Провинция';

  @override
  String get month => 'Месяц';

  @override
  String seasonClosed(String month) {
    return 'Сезон «$month» завершён; таблица окончательная.';
  }

  @override
  String get seasonRunning =>
      'Сезон идёт. Очки обновляются по мере завершения мероприятий; итоги окончательны через 8 дней после конца месяца.';

  @override
  String leagueEmpty(String province) {
    return 'В лиге «$province» в этом месяце пока никто не набрал очков.';
  }

  @override
  String points(int count) {
    return 'Очков: $count';
  }

  @override
  String rank(int rank) {
    return '$rank.';
  }

  @override
  String leagueName(String province, String category) {
    return '$province · Лига «$category»';
  }

  @override
  String get noPointsYet =>
      'В этом месяце очков пока нет. Очки приносят завершённые мероприятия, участия и встречи новичков.';

  @override
  String get mapAttribution =>
      '© Stadia Maps © OpenMapTiles © участники OpenStreetMap';

  @override
  String get map => 'Карта';

  @override
  String get mapView => 'Карта';

  @override
  String get listView => 'Список';

  @override
  String get all => 'Все';

  @override
  String get wholeArea => 'Вся область';

  @override
  String km(int km) {
    return '$km км';
  }

  @override
  String get mapLoadFailed => 'Не удалось загрузить данные карты.';

  @override
  String get retry => 'Повторить';

  @override
  String get noFilterResults => 'По этим фильтрам ничего нет.';

  @override
  String get clearFilters => 'Сбросить фильтры';

  @override
  String get noNearby => 'В этом районе нет ближайших мероприятий и групп.';

  @override
  String get zoomOut => 'Отдалить';

  @override
  String get openEvent => 'Открыть мероприятие';

  @override
  String memberCount(int count) {
    return 'Участников: $count';
  }

  @override
  String get noVisible =>
      'В видимой области нет ближайших мероприятий и групп.';

  @override
  String get backToMap => 'Вернуться к карте';

  @override
  String upcomingCount(int count) {
    return 'Ближайшие мероприятия ($count)';
  }

  @override
  String get directions => 'Маршрут';

  @override
  String get meetingPointOptional => 'Место встречи (необязательно)';

  @override
  String get meetingPointHint =>
      'Выберите на карте — мероприятие появится на ней.';

  @override
  String pointPicked(String lat, String lng) {
    return 'Выбрано · $lat, $lng';
  }

  @override
  String get removeMeetingPoint => 'Удалить место встречи';

  @override
  String get meetingPoint => 'Место встречи';

  @override
  String get pickHint => 'Приблизьте карту и коснитесь места встречи.';

  @override
  String get pickAgainHint => 'Коснитесь другого места, чтобы сменить точку.';

  @override
  String get pickThisPoint => 'Выбрать эту точку';

  @override
  String get mapUnavailable => 'Карта сейчас недоступна.';
}
