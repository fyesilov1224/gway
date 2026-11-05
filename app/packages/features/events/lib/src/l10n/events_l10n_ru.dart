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

  @override
  String get pollClosedShort => 'Закрыт';

  @override
  String closesAt(String date) {
    return 'Закрытие: $date';
  }

  @override
  String get multipleAllowed => 'Несколько вариантов';

  @override
  String get anonymousVote => 'Анонимное голосование';

  @override
  String votersCount(int count) {
    return 'Проголосовали: $count';
  }

  @override
  String get pollOptions => 'Действия с опросом';

  @override
  String get pollClosedToast => 'Опрос закрыт.';

  @override
  String get pollDeleted => 'Опрос удалён.';

  @override
  String get closePoll => 'Закрыть опрос';

  @override
  String get deletePoll => 'Удалить опрос';

  @override
  String get vote => 'Голосовать';

  @override
  String get voteSaved => 'Ваш голос учтён.';

  @override
  String get voters => 'Проголосовавшие';

  @override
  String peopleCount(int count) {
    return 'Человек: $count';
  }

  @override
  String get polls => 'Опросы';

  @override
  String get openPoll => 'Создать опрос';

  @override
  String get pollsEmpty =>
      'Задайте участникам вопрос, например: в какой день встретимся?';

  @override
  String get pollOpened => 'Опрос создан.';

  @override
  String get question => 'Вопрос';

  @override
  String get questionExample => 'Например: в какой день встретимся?';

  @override
  String get questionMin3 => 'Вопрос — не менее 3 символов.';

  @override
  String optionN(int n) {
    return 'Вариант $n';
  }

  @override
  String get removeOption => 'Удалить вариант';

  @override
  String get optionRequired => 'Заполните вариант или удалите его.';

  @override
  String get addOption => 'Добавить вариант';

  @override
  String get allowMultiple => 'Разрешить несколько вариантов';

  @override
  String get anonymousHint => 'Никто не видит, кто за что голосовал.';

  @override
  String get noEndTime => 'Без срока';

  @override
  String get add => 'Добавить';

  @override
  String get removeEndTime => 'Убрать срок';

  @override
  String get startPoll => 'Создать опрос';

  @override
  String get cardFooter => 'gway · найди своё сообщество';

  @override
  String myYear(int year) {
    return 'Мой $year';
  }

  @override
  String get statAttended => 'мероприятий посетил(а)';

  @override
  String get statHours => 'часов вместе';

  @override
  String get statOneGroup => 'группа';

  @override
  String get statGroups => 'разных групп';

  @override
  String get statProvinces => 'разных провинций';

  @override
  String get statOrganized => 'мероприятий организовал(а)';

  @override
  String get statWelcomed => 'новичков встретил(а)';

  @override
  String get statMemories => 'воспоминаний';

  @override
  String get favorites => 'Любимое';

  @override
  String get topGroup => 'Группа, с которой я был(а) чаще всего';

  @override
  String topGroupLine(String group, int count) {
    return '$group · встреч: $count';
  }

  @override
  String get iWasThere => 'Я тоже там был(а)';

  @override
  String get firstWithGroup => 'Моё первое мероприятие с этой группой.';

  @override
  String nthWithGroup(int n) {
    return 'Моё $n-е мероприятие с этой группой.';
  }

  @override
  String get shareFailed =>
      'На этом устройстве поделиться не получилось. Сделайте скриншот карточки.';

  @override
  String get share => 'Поделиться';

  @override
  String yearSummaryTitle(int year) {
    return 'Мои итоги $year';
  }

  @override
  String get yearEmpty =>
      'В этом году вы ещё не были на мероприятиях. Итоги появятся после первой встречи.';

  @override
  String yearShareText(int year) {
    return 'Мой $year в GWAY';
  }

  @override
  String mapSemantics(int count) {
    return 'Карта Турции: открыто провинций — $count';
  }

  @override
  String get explorationMap => 'Моя карта открытий';

  @override
  String get statExplored => 'провинций открыто';

  @override
  String get statMetAt => 'мероприятий';

  @override
  String get recentExplored => 'Недавние открытия';

  @override
  String get explorationEmpty =>
      'Здесь отмечаются провинции посещённых мероприятий. Карта оживёт после первой встречи.';

  @override
  String get findOnMap => 'Найти мероприятия на карте';

  @override
  String explorationShareText(int count) {
    return 'Я открыл(а) провинций в GWAY: $count';
  }

  @override
  String get exploredProvinces => 'Открытые провинции';

  @override
  String get explorationPrivacy =>
      'Это видите только вы. Учитываются мероприятия, где вас не отметили «не пришёл».';

  @override
  String get tonightVisible =>
      'Участники общих групп увидят, что вы свободны сегодня вечером. Отключится само в 4:00.';

  @override
  String get joinedTable => 'Вы присоединились к столику.';

  @override
  String get declinedInvite => 'Вы отклонили приглашение.';

  @override
  String get yourStatus => 'Ваш статус';

  @override
  String get visibleUntil4 => 'Вас видно до 4:00';

  @override
  String get notVisible => 'Сейчас вас не видно';

  @override
  String get youreFree => 'Вы свободны';

  @override
  String get tonightIntro =>
      'Если свободны, пусть это увидят участники общих групп — вместе можно собрать столик.';

  @override
  String get imFreeTonight => 'Я свободен(-на) сегодня вечером';

  @override
  String get noLongerFree => 'Вы больше не отмечены как свободный(-ая).';

  @override
  String get turnOffStatus => 'Отключить статус';

  @override
  String get leftTable => 'Вы покинули столик.';

  @override
  String get smallTable => 'Столик';

  @override
  String get smallTableHint =>
      'Пригласите нескольких свободных — чат столика откроется, когда соберутся трое.';

  @override
  String get setUpTable => 'Собрать столик';

  @override
  String tableInvitesSent(int count) {
    return 'Приглашения отправлены ($count). Чат откроется, когда соберутся трое.';
  }

  @override
  String needMorePeople(int min, int now) {
    return 'Для столика нужно ещё минимум $min свободных из общих групп (сейчас $now). Когда кто-то освободится, соберите столик здесь.';
  }

  @override
  String freeFromGroups(int count) {
    return 'Свободны сегодня из ваших групп: $count';
  }

  @override
  String get chipCoffee => 'Кофе';

  @override
  String get chipWalk => 'Прогулка';

  @override
  String get chipFood => 'Еда';

  @override
  String get chipCinema => 'Кино';

  @override
  String get tonightSheetHint =>
      'Видят только участники общих групп. Статус отключится сам в 4:00.';

  @override
  String get whatToDo => 'Чем хотите заняться? (необязательно)';

  @override
  String get whatToDoHint => 'например, кофе, прогулка';

  @override
  String get imFree => 'Я свободен(-на)';

  @override
  String get yourTable => 'Ваш столик';

  @override
  String joinedCount(int count) {
    return 'Присоединились: $count';
  }

  @override
  String waitingCount(int count) {
    return 'Ожидаем: $count';
  }

  @override
  String get settingUp => 'Собирается';

  @override
  String get chatOpen => 'Чат открыт';

  @override
  String get tableChat => 'Чат столика';

  @override
  String chatOpensWhen(int count) {
    return 'Чат откроется, когда присоединятся ещё $count. Место и время выберете там вместе.';
  }

  @override
  String get leaveTable => 'Покинуть столик';

  @override
  String tableInviteTitle(String name) {
    return '$name собирает столик и приглашает вас.';
  }

  @override
  String tableInviteStatus(int joined, int pending) {
    return 'Присоединились: $joined · ожидаем: $pending. Чат откроется, когда соберутся трое.';
  }

  @override
  String get join => 'Присоединиться';

  @override
  String get notTonight => 'Не сегодня';

  @override
  String get tonight => 'Сегодня вечером';

  @override
  String get freeTonight => 'Свободны сегодня вечером';

  @override
  String get sharedGroupsOnly => 'Только участники общих групп';

  @override
  String get nobodyFree => 'Сейчас никто из общих групп не свободен.';

  @override
  String get howItWorks => 'Как это работает?';

  @override
  String get howStep1 =>
      'Нажмите «Я свободен(-на) сегодня» и, если хотите, напишите, чем заняться.';

  @override
  String get howStep2 => 'Участники общих групп видят вас, а вы — свободных.';

  @override
  String get howStep3 =>
      'Соберите столик: чат откроется на трёх участниках, там и выберете место и время.';

  @override
  String get upcoming => 'Скоро';

  @override
  String get calendar => 'Календарь';

  @override
  String get noUpcomingJoined => 'Вы не участвуете в ближайших мероприятиях.';

  @override
  String get showAll => 'Показать все';

  @override
  String get noUpcoming60 =>
      'В ближайшие 60 дней у ваших групп нет мероприятий.';

  @override
  String get findGroup => 'Найти группу';

  @override
  String filterAll(int count) {
    return 'Все · $count';
  }

  @override
  String filterMine(int count) {
    return 'Мои · $count';
  }

  @override
  String get tomorrow => 'Завтра';

  @override
  String get going => 'Вы идёте';

  @override
  String get waitlisted => 'В листе ожидания';

  @override
  String get awaitingApproval => 'Ожидает одобрения';

  @override
  String get full => 'Мест нет';

  @override
  String goingOfCapacityShort(int count, int capacity) {
    return 'Участников: $count/$capacity';
  }

  @override
  String get startingSoon => 'Скоро начнётся';

  @override
  String get next6Hours => 'Ближайшие 6 часов';

  @override
  String get wantWelcome => 'Хочу, чтобы меня встретили';

  @override
  String get wantWelcomeHint =>
      'Волонтёр из группы встретит вас у входа — вы не придёте один(одна).';

  @override
  String get noteForGreeter => 'Заметка, чтобы вас узнали (необязательно)';

  @override
  String get noteForGreeterHint => 'Например: красная куртка, синий рюкзак';

  @override
  String get sendRequest => 'Отправить запрос';

  @override
  String get welcomeRequestSent =>
      'Запрос отправлен встречающим. Сообщим, когда кто-то возьмётся.';

  @override
  String get editMeetingNote => 'Изменить заметку о встрече';

  @override
  String welcomePerson(String name) {
    return 'Встретить $name';
  }

  @override
  String describedAs(String note) {
    return 'Как себя описал(а): $note';
  }

  @override
  String get whereMeet => 'Где встретитесь?';

  @override
  String get whereMeetHint => 'Например: у кафе на входе, 8:45';

  @override
  String get save => 'Сохранить';

  @override
  String get iWillWelcome => 'Я встречу';

  @override
  String get noteUpdated => 'Заметка о встрече обновлена.';

  @override
  String youWillWelcome(String name) {
    return 'Вы встречаете $name; заметку о встрече уже видно.';
  }

  @override
  String get stopWelcoming => 'Отказаться от встречи';

  @override
  String stopWelcomingBody(String name) {
    return 'Для $name будет найден другой встречающий, и ему(ей) сообщат.';
  }

  @override
  String get release => 'Отказаться';

  @override
  String get releasedWelcome => 'Вы отказались; ищем другого встречающего.';

  @override
  String get firstTime => 'Идёте впервые?';

  @override
  String greetersAvailable(int count) {
    return 'В группе встречающих: $count. Один из них встретит вас у входа и познакомит с группой.';
  }

  @override
  String get youWelcomed => 'Вы встречаете';

  @override
  String meetingAt(String note) {
    return 'Встреча: $note';
  }

  @override
  String get thankedYou => 'Поблагодарил(а) вас';

  @override
  String optionsFor(String name) {
    return 'Действия для $name';
  }

  @override
  String waitingWelcome(int count) {
    return 'Ждут встречи ($count)';
  }

  @override
  String matchedCount(int count) {
    return 'Встречающий найден для: $count';
  }

  @override
  String get firstTimer => 'Впервые';

  @override
  String get max3Welcomes =>
      'На одном мероприятии можно встретить до 3 человек.';

  @override
  String get greeterJoinHint =>
      'Вы встречающий. Запишитесь на мероприятие, чтобы встречать новичков.';

  @override
  String get lookingGreeter => 'Ищем встречающего';

  @override
  String get lookingGreeterHint =>
      'Мы сообщили встречающим. Придёт уведомление, когда кто-то возьмётся.';

  @override
  String yourNote(String note) {
    return 'Ваша заметка: $note';
  }

  @override
  String get welcomeWithdrawn => 'Запрос отозван.';

  @override
  String get withdrawRequest => 'Отозвать запрос';

  @override
  String get greetedBy => 'Вас встретил(а)';

  @override
  String get willGreet => 'Вас встретит';

  @override
  String get thank => 'Поблагодарить';

  @override
  String thankReceived(String name) {
    return '$name получил(а) вашу благодарность.';
  }

  @override
  String get thanked => 'Вы поблагодарили.';

  @override
  String get cancelWelcome => 'Отменить встречу';

  @override
  String get nowGreeter =>
      'Теперь вы встречающий. Сообщим, когда новичок попросит его встретить.';

  @override
  String get noLongerGreeter => 'Вы больше не встречающий.';

  @override
  String get welcomeSection => 'Встреча новичков';

  @override
  String greetersCount(int count) {
    return 'Встречающих: $count';
  }

  @override
  String get greeterIntro =>
      'Новички могут попросить встречу на странице мероприятия. Став встречающим, вы получите уведомление, встретите у входа и познакомите с группой.';

  @override
  String greeterMemberHint(int count) {
    return 'В группе встречающих: $count. На первом мероприятии нажмите «Хочу, чтобы меня встретили».';
  }

  @override
  String greeterVisitorHint(int count) {
    return 'В группе встречающих: $count — на первое мероприятие вы не пойдёте один(одна), вас встретят у входа.';
  }

  @override
  String get becomeGreeter => 'Стать встречающим';

  @override
  String quoted(String text) {
    return '«$text»';
  }

  @override
  String seatsGoing(int count) {
    return 'Идут: $count';
  }

  @override
  String seatsOf(int count, int capacity) {
    return 'Человек: $count / $capacity';
  }

  @override
  String seatsOfWaiting(int count, int capacity, int waiting) {
    return 'Человек: $count / $capacity · ждут: $waiting';
  }

  @override
  String summaryAttended(int count) {
    return 'Было: $count';
  }

  @override
  String summaryRating(String avg, int count) {
    return '$avg ★ (отзывов: $count)';
  }

  @override
  String waitlistPlace(int place) {
    return 'Лист ожидания · №$place';
  }

  @override
  String get eventCanceled => 'Мероприятие отменено.';

  @override
  String eventCanceledBecause(String reason) {
    return 'Мероприятие отменено: $reason';
  }

  @override
  String reviewBy(String name, int stars) {
    return '$name, звёзд: $stars';
  }

  @override
  String get conflicting => 'Пересекается';

  @override
  String get events => 'Мероприятия';

  @override
  String get create => 'Создать';

  @override
  String eventsLeft(int count) {
    return 'Осталось мероприятий в этом месяце: $count.';
  }

  @override
  String get eventsLimitReached =>
      'Лимит мероприятий на этот месяц исчерпан. Повысьте тариф, чтобы получить больше.';

  @override
  String groupRating(String avg, int count) {
    return '$avg · отзывов о мероприятиях: $count';
  }

  @override
  String get howWasIt => 'Как прошло?';

  @override
  String get howWasItHint =>
      'Оцените мероприятие, на котором были; все видят только среднюю оценку.';

  @override
  String titleOnDate(String title, String date) {
    return '$title · $date';
  }

  @override
  String get eventsEmpty =>
      'Поход, концерт или встреча — создайте первое мероприятие.';

  @override
  String get requestSent =>
      'Запрос отправлен. Сообщим, когда организатор примет решение.';

  @override
  String get attendanceSaved => 'Вы записаны. Напомним перед началом.';

  @override
  String waitlistJoined(int place) {
    return 'Вы в листе ожидания (№$place). Сообщим, когда освободится место.';
  }

  @override
  String get conflictTitle => 'У вас другое мероприятие в это же время';

  @override
  String conflictLine(String title, String date) {
    return '• $title · $date';
  }

  @override
  String get conflictOne =>
      'Если не сможете пойти, откажитесь и уступите место другому.';

  @override
  String get conflictMany =>
      'Если не сможете пойти, откажитесь и уступите места другим.';

  @override
  String get keepBoth => 'Оставить оба';

  @override
  String get leaveOther => 'Отказаться от другого';

  @override
  String get leaveOthers => 'Отказаться от других';

  @override
  String get leftOther =>
      'Вы отказались от другого мероприятия; место освободилось.';

  @override
  String get leftOthers => 'Вы отказались от других мероприятий.';

  @override
  String approvedPerson(String name) {
    return '$name теперь участвует.';
  }

  @override
  String declinedPerson(String name) {
    return 'Запрос отклонён; $name уведомлен(а).';
  }

  @override
  String get calendarFailed =>
      'Не удалось открыть файл календаря. Повторите попытку.';

  @override
  String get stopSeriesTitle => 'Остановить повторение?';

  @override
  String get stopSeriesBody =>
      'Новые даты не откроются. Уже открытые останутся; их можно отменить по одной.';

  @override
  String get stop => 'Остановить';

  @override
  String get seriesStopped => 'Повторение остановлено.';

  @override
  String get eventCanceledToast => 'Мероприятие отменено.';

  @override
  String get eventNotFound => 'Мероприятие не найдено или больше не видно.';

  @override
  String get goBack => 'Назад';

  @override
  String joinGroupFirst(String name) {
    return 'Вступить в «$name»';
  }

  @override
  String get sendJoinRequest => 'Отправить запрос на участие';

  @override
  String get joinWaitlist => 'Встать в лист ожидания';

  @override
  String get leaveEvent => 'Отказаться';

  @override
  String get leaveWaitlist => 'Выйти из листа ожидания';

  @override
  String get requestWithdrawn => 'Запрос отозван.';

  @override
  String get attendanceRemoved => 'Вы отказались от участия.';

  @override
  String eventShareText(String title) {
    return '$title · присоединяйтесь в GWAY:';
  }

  @override
  String get eventLinkCopied => 'Ссылка на мероприятие скопирована.';

  @override
  String get report => 'Пожаловаться';

  @override
  String get eventOptions => 'Действия с мероприятием';

  @override
  String get edit => 'Изменить';

  @override
  String get cancelThisDate => 'Отменить эту дату';

  @override
  String get stopRepeat => 'Остановить повторение';

  @override
  String get startedOrEnded => 'Началось или завершилось';

  @override
  String seriesUntil(String label, String date) {
    return '$label · до $date';
  }

  @override
  String get addToCalendar => 'Добавить в календарь';

  @override
  String fee(String fee) {
    return 'Стоимость участия: $fee';
  }

  @override
  String get feeNotice =>
      'Оплата идёт организатору; GWAY платежи не принимает.';

  @override
  String get areYouComing => 'Вы придёте?';

  @override
  String get areYouComingHint =>
      'Если не сможете, уступите место листу ожидания.';

  @override
  String get yesComing => 'Да, приду';

  @override
  String get confirmThanks =>
      'Спасибо, мы сообщили организатору, что вы придёте.';

  @override
  String get cantCome => 'Не смогу';

  @override
  String get spotFreed => 'Вы отказались; место освободилось.';

  @override
  String get confirmedComing => 'Вы подтвердили участие.';

  @override
  String get otherEventSameTime => 'В это время у вас другое мероприятие';

  @override
  String get needsApproval => 'Участие с одобрения';

  @override
  String get requirements => 'Условия участия';

  @override
  String get equipment => 'Нужное снаряжение';

  @override
  String joinRequestsCount(int count) {
    return 'Запросы на участие ($count)';
  }

  @override
  String get attendees => 'Участники';

  @override
  String confirmedOf(int going, int confirmed) {
    return 'Подтвердили: $confirmed из $going.';
  }

  @override
  String confirmedName(String name) {
    return '$name · подтвердил(а)';
  }

  @override
  String get shareWasThere => 'Поделиться карточкой «Я тоже там был(а)»';

  @override
  String get howDidItGo => 'Как всё прошло?';

  @override
  String reviewsCount(int count) {
    return 'Отзывы ($count)';
  }

  @override
  String get reviewNotesPrivate => 'Заметки видят только организаторы.';

  @override
  String get attendanceCheck => 'Отметка присутствия';

  @override
  String get attendanceCheckHint =>
      'Отметьте неявившихся: в вклад и значки идут только пришедшие. Доступно 7 дней после окончания.';

  @override
  String markedCame(String name) {
    return '$name: отмечен(а) как пришедший(-ая).';
  }

  @override
  String markedMissed(String name) {
    return '$name: отмечен(а) как не пришедший(-ая).';
  }

  @override
  String get didntCome => 'Не пришёл';

  @override
  String get came => 'Пришёл';

  @override
  String get memories => 'Воспоминания';

  @override
  String get shareMemory => 'Поделиться воспоминанием';

  @override
  String get eventPolls => 'Опросы мероприятия';

  @override
  String get noEditPermission =>
      'У вас нет прав на редактирование мероприятия.';

  @override
  String get editEvent => 'Редактировать мероприятие';

  @override
  String get newEvent => 'Новое мероприятие';

  @override
  String get addCover => 'Добавить обложку';

  @override
  String get titleExample => 'Например: прогулка по лесу';

  @override
  String get starts => 'Начало';

  @override
  String get endsOptional => 'Окончание (необязательно)';

  @override
  String get notSpecified => 'Не указано';

  @override
  String get removeEnd => 'Убрать окончание';

  @override
  String get repeat => 'Повтор';

  @override
  String get noRepeat => 'Без повтора';

  @override
  String get weekly => 'Каждую неделю';

  @override
  String get biweekly => 'Раз в две недели';

  @override
  String get lastDateOptional => 'Последняя дата (необязательно)';

  @override
  String get untilYouStop => 'Пока не остановите';

  @override
  String get removeLastDate => 'Убрать последнюю дату';

  @override
  String get repeatHint =>
      'Следующие даты открываются сами за 4 недели, и каждая учитывается в месячном лимите.';

  @override
  String get surpriseVenue => 'Место-сюрприз';

  @override
  String get surpriseHint =>
      'Место откроется только участникам — в выбранное вами время до начала.';

  @override
  String get hintPublic => 'Подсказка (видят все)';

  @override
  String get place => 'Место';

  @override
  String get hintExample => 'Например: у моря, на азиатском берегу';

  @override
  String get placeExample => 'Например: вход в парк или онлайн';

  @override
  String get writeHint => 'Напишите подсказку.';

  @override
  String get writePlace => 'Укажите место.';

  @override
  String get realVenue => 'Настоящее место (видят только участники)';

  @override
  String get realVenueExample => 'Например: у театра';

  @override
  String get writeRealVenue => 'Укажите настоящее место.';

  @override
  String get whenReveal => 'Когда открыть?';

  @override
  String hoursBefore(int count) {
    return 'За $count ч';
  }

  @override
  String get linkOptional => 'Ссылка на карту или онлайн (необязательно)';

  @override
  String get httpsRequired => 'Ссылка должна начинаться с https://.';

  @override
  String get description => 'Описание';

  @override
  String get capacity => 'Мест (пусто = без ограничений)';

  @override
  String get capacityHint =>
      'Когда места кончатся, новые попадут в лист ожидания.';

  @override
  String get capacityRange => 'Мест должно быть от 1 до 10 000.';

  @override
  String get requirementsOptional => 'Условия участия (необязательно)';

  @override
  String get requirementsExample => 'Например: опыт походов от 10 км';

  @override
  String get equipmentOptional => 'Нужное снаряжение (необязательно)';

  @override
  String get equipmentExample => 'Например: шлем, вода, дождевик';

  @override
  String get equipmentHint => 'Через запятую; до 10 пунктов.';

  @override
  String get equipmentLimit => 'До 10 пунктов, каждый до 60 символов.';

  @override
  String get approvalRequired => 'Участие с одобрения';

  @override
  String get approvalHint => 'Желающие отправляют запрос, а вы одобряете.';

  @override
  String get feeOptional => 'Стоимость участия (необязательно)';

  @override
  String get feeInfoOnly => 'Только для информации; GWAY платежи не принимает.';

  @override
  String get amount => 'Сумма';

  @override
  String get amountExample => 'Например, 150';

  @override
  String get validAmount => 'Введите корректную сумму.';

  @override
  String get paymentNote => 'Примечание к оплате';

  @override
  String get paymentNoteExample => 'Например: наличными на месте';

  @override
  String get createEvent => 'Создать мероприятие';

  @override
  String get rateEvent => 'Оценить мероприятие';

  @override
  String get yourReview => 'Ваш отзыв';

  @override
  String starsLabel(int count) {
    return 'Звёзд: $count';
  }

  @override
  String get noteToOrganizers => 'Заметка организаторам (необязательно)';

  @override
  String get noteToOrganizersHint =>
      'Заметку видят только организаторы; остальные — лишь среднюю оценку.';

  @override
  String get reviewDeleted => 'Ваш отзыв удалён.';

  @override
  String get delete => 'Удалить';

  @override
  String get reviewSaved => 'Спасибо, отзыв сохранён.';

  @override
  String get groupNext => 'Ближайшие мероприятия группы';

  @override
  String sameDayOthers(int count) {
    return 'В этот день в вашей провинции ещё $count мероприятий той же категории. Выберите другой день, чтобы участникам не пришлось выбирать.';
  }

  @override
  String get cancelEvent => 'Отменить мероприятие';

  @override
  String get cancelEventBody =>
      'Участники и лист ожидания получат уведомление. Отменить это нельзя.';

  @override
  String get reason => 'Причина';

  @override
  String get cancelAction => 'Отменить';

  @override
  String hint(String hint) {
    return 'Подсказка: $hint';
  }

  @override
  String hintRevealAt(String hint, String when) {
    return 'Подсказка: $hint · Участникам откроется $when.';
  }

  @override
  String get venueRevealed =>
      'Место открыто участникам. Запишитесь, чтобы увидеть.';

  @override
  String venueRevealAt(String when) {
    return 'Место откроется участникам $when.';
  }

  @override
  String get currencyTry => '₺ TRY';

  @override
  String get badgeFirstStep => 'Первый шаг';

  @override
  String get badgeFirstStepText => 'Посетите первое мероприятие.';

  @override
  String get badgeRegular => 'Завсегдатай';

  @override
  String get badgeRegularText => 'Посетите 10 мероприятий.';

  @override
  String get badgeCompanion => 'Попутчик';

  @override
  String get badgeCompanionText => 'Посетите 25 мероприятий.';

  @override
  String get badgeExplorer => 'Исследователь';

  @override
  String get badgeExplorerText => 'Посетите мероприятия 3 разных групп.';

  @override
  String get badgeOrganizer => 'Организатор';

  @override
  String get badgeOrganizerText =>
      'Организуйте мероприятие, где будет хотя бы 2 человека.';

  @override
  String get badgeMasterOrganizer => 'Мастер-организатор';

  @override
  String get badgeMasterOrganizerText =>
      'Организуйте 10 мероприятий, где будет хотя бы 2 человека.';

  @override
  String get badgeStoryteller => 'Хранитель воспоминаний';

  @override
  String get badgeStorytellerText =>
      'Добавьте 5 воспоминаний к посещённым мероприятиям.';

  @override
  String get badgeFeedback => 'Отзывчивый';

  @override
  String get badgeFeedbackText => 'Оцените 5 посещённых мероприятий.';

  @override
  String get badgeDoorOpener => 'Открывающий двери';

  @override
  String get badgeDoorOpenerText => 'Встретьте новичка на мероприятии.';

  @override
  String get badgeHost => 'Хозяин';

  @override
  String get badgeHostText => 'Встретьте 5 новичков.';

  @override
  String get badgeCommunityHeart => 'Сердце сообщества';

  @override
  String get badgeCommunityHeartText => 'Встретьте 20 новичков.';

  @override
  String get badgeFriendly => 'Общительный';

  @override
  String get badgeFriendlyText =>
      'Обменяйтесь рукопожатием с 5 людьми на мероприятиях.';

  @override
  String get badgeSocialButterfly => 'Душа компании';

  @override
  String get badgeSocialButterflyText =>
      'Обменяйтесь рукопожатием с 25 людьми на мероприятиях.';

  @override
  String get badgeCategory => 'Любитель категории';

  @override
  String get badgeCategoryText => 'Посетите 5 мероприятий одной категории.';

  @override
  String badgeCategoryOf(String category) {
    return 'Любитель: $category';
  }

  @override
  String badgeCategoryOfText(String category) {
    return 'Посетил(а) 5 мероприятий категории «$category».';
  }

  @override
  String badgeGoal(String goal) {
    return 'Цель: $goal';
  }

  @override
  String badgeGoalText(String group) {
    return 'Выполнил(а) цель группы «$group».';
  }
}
