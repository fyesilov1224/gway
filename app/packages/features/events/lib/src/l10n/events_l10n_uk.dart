// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'events_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class EventsL10nUk extends EventsL10n {
  EventsL10nUk([String locale = 'uk']) : super(locale);

  @override
  String get pollSingle =>
      'У цьому опитуванні можна вибрати лише один варіант.';

  @override
  String get pollOptionGone => 'Цього варіанта більше немає. Оновіть сторінку.';

  @override
  String get reviewWindow =>
      'Учасники можуть оцінити подію протягом 30 днів після завершення.';

  @override
  String get greeterNeedsAttendance =>
      'Щоб зустрічати новачків, треба побувати хоча б на одній події групи.';

  @override
  String get note80 => 'Нотатка — до 80 символів.';

  @override
  String get pollClosed => 'Опитування закрите або ви не можете голосувати.';

  @override
  String get cover5mb => 'Обкладинка — до 5 МБ.';

  @override
  String get imagesOnly => 'Можна завантажити лише JPEG, PNG або WebP.';

  @override
  String get claimNotAllowed =>
      'Зараз не можна звітувати про завдання: воно завершене або ви не в групі.';

  @override
  String get claimApprovedLocked => 'Схвалений звіт не можна відкликати.';

  @override
  String get claimDuplicate => 'Ви вже звітували про це завдання.';

  @override
  String get repeatsWeekly => 'Повторюється щотижня';

  @override
  String get repeatsBiweekly => 'Повторюється раз на два тижні';

  @override
  String surprisePlace(String place) {
    return 'Місце-сюрприз · $place';
  }

  @override
  String get goalPersonal => 'Особиста мета';

  @override
  String get goalPersonalHint => 'Кожен учасник виконує свою норму.';

  @override
  String get goalGroup => 'Мета групи';

  @override
  String get goalGroupHint => 'Внесок усіх складається в один лічильник.';

  @override
  String get goalTeam => 'Командна мета';

  @override
  String get goalTeamHint =>
      'Адміністратори формують команди; у кожної спільний лічильник.';

  @override
  String get goalTask => 'Завдання з підтвердженням';

  @override
  String get goalTaskHint =>
      'Учасник позначає «Зроблено», адміністратор підтверджує.';

  @override
  String unitAttended(int count) {
    return 'участей';
  }

  @override
  String unitOrganized(int count) {
    return 'організованих';
  }

  @override
  String unitMemories(int count) {
    return 'спогадів';
  }

  @override
  String get claimPending => 'Очікує підтвердження';

  @override
  String get claimApproved => 'Підтверджено';

  @override
  String get claimRejected => 'Не підтверджено';

  @override
  String get notClaimedYet => 'Ще не позначено';

  @override
  String get whenAny => 'Будь-коли';

  @override
  String get whenToday => 'Сьогодні';

  @override
  String get whenWeek => 'Протягом 7 днів';

  @override
  String get viewDay => 'День';

  @override
  String get viewWeek => 'Тиждень';

  @override
  String get viewMonth => 'Місяць';

  @override
  String countAttended(int count) {
    return 'Участей: $count';
  }

  @override
  String countOrganized(int count) {
    return 'Організовано: $count';
  }

  @override
  String countMemories(int count) {
    return 'Спогадів: $count';
  }

  @override
  String countReviews(int count) {
    return 'Відгуків: $count';
  }

  @override
  String countWelcomed(int count) {
    return 'Зустріто новачків: $count';
  }

  @override
  String countHandshakes(int count) {
    return 'Рукостискань: $count';
  }

  @override
  String countHeld(int count) {
    return 'Подій: $count';
  }

  @override
  String countGoodReviews(int count) {
    return 'Добрих відгуків: $count';
  }

  @override
  String leagueStanding(String month, int groups, int rank, int points) {
    return '$month: $rank-е місце з $groups груп, балів: $points.';
  }

  @override
  String goingCount(int count) {
    return 'Учасників: $count';
  }

  @override
  String goingOfCapacity(int count, int capacity) {
    return 'Учасників: $count / $capacity';
  }

  @override
  String firstEventOfYear(String title) {
    return 'Перша подія року: $title';
  }

  @override
  String firstEventOfYearOn(String title, String date) {
    return 'Перша подія року: $title · $date';
  }

  @override
  String get myCalendar => 'Мій календар';

  @override
  String get groupCalendar => 'Календар групи';

  @override
  String get previous => 'Назад';

  @override
  String get next => 'Далі';

  @override
  String get today => 'Сьогодні';

  @override
  String get groupsEvents => 'Події моїх груп';

  @override
  String get showNotJoined => 'Показувати й ті, де ви не берете участі';

  @override
  String get noJoinedInRange =>
      'У ці дати у вас немає подій. Можна переглянути події ваших груп.';

  @override
  String get noEventsInRange => 'У ці дати подій немає.';

  @override
  String get showGroupsEvents => 'Показати події моїх груп';

  @override
  String get backToToday => 'Повернутися до сьогодні';

  @override
  String get noEventsDay => 'Цього дня подій немає.';

  @override
  String get contributions => 'Внесок у спільноту';

  @override
  String get howBadges => 'Як отримати значки?';

  @override
  String get badgesEmpty =>
      'Коли ви відвідаєте подію, тут з’являться ваш внесок і перший значок.';

  @override
  String get badgesRules =>
      'Значки нараховуються лише за реальні справи: відвідані й організовані події, спогади й відгуки. Вподобання й підписники не враховуються. Не враховуються участі, позначені організатором як «не прийшов». Рейтингів немає.';

  @override
  String get categoryFan => 'Фанат категорії';

  @override
  String get pastEvents => 'Минулі події';

  @override
  String get noPastEvents => 'У цієї групи ще немає минулих подій.';

  @override
  String get refresh => 'Оновити';

  @override
  String get canceled => 'Скасовано';

  @override
  String get olderEvents => 'Раніші події';

  @override
  String get completed => 'Виконано';

  @override
  String get ended => 'Завершено';

  @override
  String teamName(String name) {
    return 'Команда: $name';
  }

  @override
  String get teamNotice =>
      'Коли вас додадуть до команди, тут з’явиться прогрес.';

  @override
  String get goals => 'Цілі';

  @override
  String get createGoal => 'Створити мету';

  @override
  String get goalsEmpty =>
      'Наприклад, «4 походи цього місяця» чи «Разом 50 участей» — створіть першу мету.';

  @override
  String get claimSent => 'Ваш звіт надіслано адміністратору.';

  @override
  String get goal => 'Мета';

  @override
  String get goalCountsRule =>
      'Враховуються лише події цієї групи за період; участі з позначкою «не прийшов» не рахуються.';

  @override
  String get withdrawClaim => 'Відкликати звіт';

  @override
  String get claimWithdrawn => 'Звіт відкликано.';

  @override
  String get done => 'Зроблено';

  @override
  String get teams => 'Команди';

  @override
  String get createTeam => 'Створити команду';

  @override
  String get noTeams => 'Команд поки немає.';

  @override
  String deleteTeam(String name) {
    return 'Видалити команду «$name»';
  }

  @override
  String get teamDeleted => 'Команду видалено.';

  @override
  String pendingClaims(int count) {
    return 'Звіти на підтвердження ($count)';
  }

  @override
  String get claimRejectedToast => 'Звіт не підтверджено.';

  @override
  String get decline => 'Відхилити';

  @override
  String get approve => 'Підтвердити';

  @override
  String taskDone(String name) {
    return '$name виконав(-ла) завдання.';
  }

  @override
  String completions(int count) {
    return 'Виконали ($count)';
  }

  @override
  String get noCompletions =>
      'Поки ніхто не виконав. Кожен, хто виконає, отримає значок цієї мети в профілі.';

  @override
  String get goalCanceled => 'Мету скасовано.';

  @override
  String get cancelGoal => 'Скасувати мету';

  @override
  String teamCreated(String name) {
    return 'Команду «$name» створено.';
  }

  @override
  String get teamNameLabel => 'Назва команди';

  @override
  String get createTheTeam => 'Створити команду';

  @override
  String createTeamWith(int count) {
    return 'Створити команду (людей: $count)';
  }

  @override
  String get goalCreated => 'Мету створено.';

  @override
  String get title => 'Назва';

  @override
  String get goalTitleExample => 'Напр., «Жовтневі походи»';

  @override
  String get taskTitleExample => 'Напр., «Показати новачкові маршрут»';

  @override
  String get titleMin3 => 'Назва — щонайменше 3 символи.';

  @override
  String get descriptionOptional => 'Опис (необов’язково)';

  @override
  String get targetNumber => 'Цільове число';

  @override
  String get target1to1000 => 'Введіть число від 1 до 1000.';

  @override
  String get period => 'Період';

  @override
  String periodRange(String from, String to) {
    return '$from – $to (не більше 92 днів)';
  }

  @override
  String get createTheGoal => 'Створити мету';

  @override
  String get iDidTask => 'Я виконав(-ла) завдання';

  @override
  String get whatDidYouDo => 'Що ви зробили? (необов’язково)';

  @override
  String get whatDidYouDoHint =>
      'Адміністратор підтвердить, прочитавши нотатку.';

  @override
  String get cancel => 'Скасувати';

  @override
  String get send => 'Надіслати';

  @override
  String get handshake => 'Рукостискання';

  @override
  String get handshakeHint =>
      'Відскануйте коди одне одного — ви обоє з’явитеся в «Моїх знайомствах».';

  @override
  String get open => 'Відкрити';

  @override
  String handshakeAt(String title) {
    return 'Рукостискання · $title';
  }

  @override
  String get myCode => 'Мій код';

  @override
  String get scan => 'Сканувати';

  @override
  String get yourHandshakeCode => 'Ваш код рукостискання';

  @override
  String get codeHint =>
      'Нехай співрозмовник відсканує код у вкладці «Сканувати» або введе його. Код оновлюється кожні кілька хвилин; фото потім не спрацює.';

  @override
  String get cameraFailed =>
      'Не вдалося відкрити камеру. Дозвольте доступ у налаштуваннях або введіть код нижче.';

  @override
  String get scanHint =>
      'Наведіть камеру на QR-код співрозмовника або введіть його код.';

  @override
  String get typeCodeHint => 'Введіть 6-значний код з екрана співрозмовника.';

  @override
  String get code => 'Код';

  @override
  String get alreadyMet => 'Ви вже знайомі';

  @override
  String get metNow => 'Ви познайомилися!';

  @override
  String personWithUsername(String name, String username) {
    return '$name (@$username)';
  }

  @override
  String get ok => 'Гаразд';

  @override
  String get metPeople => 'Мої знайомства';

  @override
  String get metEmpty =>
      'Коли ви потиснете комусь руку на події, людина з’явиться тут. Рукостискання відкривається на сторінці події.';

  @override
  String get goToCalendar => 'Відкрити календар';

  @override
  String get metPrivacy =>
      'Це бачите лише ви. У профілі показано лише кількість рукостискань.';

  @override
  String metRow(String username, String event, String date) {
    return '@$username · $event · $date';
  }

  @override
  String get howPoints => 'Як рахуються бали?';

  @override
  String get leagueIntro =>
      'Групи однієї категорії в одній провінції змагаються щомісяця. Враховуються події, що завершилися цього місяця.';

  @override
  String get ruleAttendance => 'Участь: 1 бал';

  @override
  String get ruleAttendanceHint =>
      'За кожного, хто прийшов; не більше 30 на подію.';

  @override
  String get ruleHeld => 'Подія: 5 балів';

  @override
  String get ruleHeldHint =>
      'Кожна подія, де окрім організатора було щонайменше 3 людини.';

  @override
  String get ruleWelcome => 'Зустріч новачка: 3 бали';

  @override
  String get ruleWelcomeHint => 'Зустріти того, хто прийшов уперше.';

  @override
  String get ruleReview => 'Добрий відгук: 1 бал';

  @override
  String get ruleReviewHint => 'Кожен відгук на 4 чи 5 зірок.';

  @override
  String get leagueRulesNote =>
      'Позначені «не прийшов» не враховуються. Підсумки остаточні через 8 днів після кінця місяця; учасники трійки лідерів отримують сповіщення.';

  @override
  String get groupsLeague => 'Ліга груп';

  @override
  String get category => 'Категорія';

  @override
  String get province => 'Провінція';

  @override
  String get month => 'Місяць';

  @override
  String seasonClosed(String month) {
    return 'Сезон «$month» завершено; таблиця остаточна.';
  }

  @override
  String get seasonRunning =>
      'Сезон триває. Бали оновлюються з завершенням подій; підсумки остаточні через 8 днів після кінця місяця.';

  @override
  String leagueEmpty(String province) {
    return 'У лізі «$province» цього місяця ще ніхто не набрав балів.';
  }

  @override
  String points(int count) {
    return 'Балів: $count';
  }

  @override
  String rank(int rank) {
    return '$rank.';
  }

  @override
  String leagueName(String province, String category) {
    return '$province · Ліга «$category»';
  }

  @override
  String get noPointsYet =>
      'Цього місяця балів поки немає. Бали дають завершені події, участі й зустрічі новачків.';

  @override
  String get mapAttribution =>
      '© Stadia Maps © OpenMapTiles © учасники OpenStreetMap';

  @override
  String get map => 'Мапа';

  @override
  String get mapView => 'Мапа';

  @override
  String get listView => 'Список';

  @override
  String get all => 'Усі';

  @override
  String get wholeArea => 'Уся область';

  @override
  String km(int km) {
    return '$km км';
  }

  @override
  String get mapLoadFailed => 'Не вдалося завантажити дані мапи.';

  @override
  String get retry => 'Повторити';

  @override
  String get noFilterResults => 'За цими фільтрами нічого немає.';

  @override
  String get clearFilters => 'Скинути фільтри';

  @override
  String get noNearby => 'У цьому районі немає найближчих подій чи груп.';

  @override
  String get zoomOut => 'Віддалити';

  @override
  String get openEvent => 'Відкрити подію';

  @override
  String memberCount(int count) {
    return 'Учасників: $count';
  }

  @override
  String get noVisible => 'У видимій області немає найближчих подій чи груп.';

  @override
  String get backToMap => 'Повернутися до мапи';

  @override
  String upcomingCount(int count) {
    return 'Найближчі події ($count)';
  }

  @override
  String get directions => 'Маршрут';

  @override
  String get meetingPointOptional => 'Місце зустрічі (необов’язково)';

  @override
  String get meetingPointHint => 'Виберіть на мапі — подія з’явиться на ній.';

  @override
  String pointPicked(String lat, String lng) {
    return 'Вибрано · $lat, $lng';
  }

  @override
  String get removeMeetingPoint => 'Видалити місце зустрічі';

  @override
  String get meetingPoint => 'Місце зустрічі';

  @override
  String get pickHint => 'Наблизьте мапу й торкніться місця зустрічі.';

  @override
  String get pickAgainHint => 'Торкніться іншого місця, щоб змінити точку.';

  @override
  String get pickThisPoint => 'Вибрати цю точку';

  @override
  String get mapUnavailable => 'Мапа зараз недоступна.';

  @override
  String get pollClosedShort => 'Закрито';

  @override
  String closesAt(String date) {
    return 'Закриття: $date';
  }

  @override
  String get multipleAllowed => 'Кілька варіантів';

  @override
  String get anonymousVote => 'Анонімне голосування';

  @override
  String votersCount(int count) {
    return 'Проголосували: $count';
  }

  @override
  String get pollOptions => 'Дії з опитуванням';

  @override
  String get pollClosedToast => 'Опитування закрито.';

  @override
  String get pollDeleted => 'Опитування видалено.';

  @override
  String get closePoll => 'Закрити опитування';

  @override
  String get deletePoll => 'Видалити опитування';

  @override
  String get vote => 'Голосувати';

  @override
  String get voteSaved => 'Ваш голос враховано.';

  @override
  String get voters => 'Хто проголосував';

  @override
  String peopleCount(int count) {
    return 'Людей: $count';
  }

  @override
  String get polls => 'Опитування';

  @override
  String get openPoll => 'Створити опитування';

  @override
  String get pollsEmpty =>
      'Поставте учасникам запитання, наприклад: у який день зустрінемося?';

  @override
  String get pollOpened => 'Опитування створено.';

  @override
  String get question => 'Запитання';

  @override
  String get questionExample => 'Напр.: у який день зустрінемося?';

  @override
  String get questionMin3 => 'Запитання — щонайменше 3 символи.';

  @override
  String optionN(int n) {
    return 'Варіант $n';
  }

  @override
  String get removeOption => 'Видалити варіант';

  @override
  String get optionRequired => 'Заповніть варіант або видаліть його.';

  @override
  String get addOption => 'Додати варіант';

  @override
  String get allowMultiple => 'Дозволити кілька варіантів';

  @override
  String get anonymousHint => 'Ніхто не бачить, хто за що голосував.';

  @override
  String get noEndTime => 'Без строку';

  @override
  String get add => 'Додати';

  @override
  String get removeEndTime => 'Прибрати строк';

  @override
  String get startPoll => 'Створити опитування';

  @override
  String get cardFooter => 'gway · знайди свою спільноту';

  @override
  String myYear(int year) {
    return 'Мій $year';
  }

  @override
  String get statAttended => 'подій відвідав(-ла)';

  @override
  String get statHours => 'годин разом';

  @override
  String get statOneGroup => 'група';

  @override
  String get statGroups => 'різних груп';

  @override
  String get statProvinces => 'різних провінцій';

  @override
  String get statOrganized => 'подій організував(-ла)';

  @override
  String get statWelcomed => 'новачків зустрів(-ла)';

  @override
  String get statMemories => 'спогадів';

  @override
  String get favorites => 'Улюблене';

  @override
  String get topGroup => 'Група, з якою я був(-ла) найчастіше';

  @override
  String topGroupLine(String group, int count) {
    return '$group · зустрічей: $count';
  }

  @override
  String get iWasThere => 'Я теж там був(-ла)';

  @override
  String get firstWithGroup => 'Моя перша подія з цією групою.';

  @override
  String nthWithGroup(int n) {
    return 'Моя $n-та подія з цією групою.';
  }

  @override
  String get shareFailed =>
      'На цьому пристрої поділитися не вдалося. Зробіть знімок картки.';

  @override
  String get share => 'Поділитися';

  @override
  String yearSummaryTitle(int year) {
    return 'Мої підсумки $year';
  }

  @override
  String get yearEmpty =>
      'Цього року ви ще не були на подіях. Підсумки з’являться після першої зустрічі.';

  @override
  String yearShareText(int year) {
    return 'Мій $year у GWAY';
  }

  @override
  String mapSemantics(int count) {
    return 'Мапа Туреччини: відкрито провінцій — $count';
  }

  @override
  String get explorationMap => 'Моя мапа відкриттів';

  @override
  String get statExplored => 'провінцій відкрито';

  @override
  String get statMetAt => 'подій';

  @override
  String get recentExplored => 'Нещодавні відкриття';

  @override
  String get explorationEmpty =>
      'Тут позначаються провінції відвіданих подій. Мапа оживе після першої зустрічі.';

  @override
  String get findOnMap => 'Знайти події на мапі';

  @override
  String explorationShareText(int count) {
    return 'Я відкрив(-ла) провінцій у GWAY: $count';
  }

  @override
  String get exploredProvinces => 'Відкриті провінції';

  @override
  String get explorationPrivacy =>
      'Це бачите лише ви. Враховуються події, де вас не позначили «не прийшов».';

  @override
  String get tonightVisible =>
      'Учасники спільних груп побачать, що ви вільні сьогодні ввечері. Вимкнеться саме о 4:00.';

  @override
  String get joinedTable => 'Ви приєдналися до столика.';

  @override
  String get declinedInvite => 'Ви відхилили запрошення.';

  @override
  String get yourStatus => 'Ваш статус';

  @override
  String get visibleUntil4 => 'Вас видно до 4:00';

  @override
  String get notVisible => 'Зараз вас не видно';

  @override
  String get youreFree => 'Ви вільні';

  @override
  String get tonightIntro =>
      'Якщо вільні, нехай це побачать учасники спільних груп — разом можна зібрати столик.';

  @override
  String get imFreeTonight => 'Я вільний(-на) сьогодні ввечері';

  @override
  String get noLongerFree => 'Вас більше не позначено як вільного(-у).';

  @override
  String get turnOffStatus => 'Вимкнути статус';

  @override
  String get leftTable => 'Ви залишили столик.';

  @override
  String get smallTable => 'Столик';

  @override
  String get smallTableHint =>
      'Запросіть кількох вільних — чат столика відкриється, коли зберуться троє.';

  @override
  String get setUpTable => 'Зібрати столик';

  @override
  String tableInvitesSent(int count) {
    return 'Запрошення надіслано ($count). Чат відкриється, коли зберуться троє.';
  }

  @override
  String needMorePeople(int min, int now) {
    return 'Для столика потрібно ще щонайменше $min вільних зі спільних груп (зараз $now). Коли хтось звільниться, зберіть столик тут.';
  }

  @override
  String freeFromGroups(int count) {
    return 'Вільні сьогодні з ваших груп: $count';
  }

  @override
  String get chipCoffee => 'Кава';

  @override
  String get chipWalk => 'Прогулянка';

  @override
  String get chipFood => 'Їжа';

  @override
  String get chipCinema => 'Кіно';

  @override
  String get tonightSheetHint =>
      'Бачать лише учасники спільних груп. Статус вимкнеться сам о 4:00.';

  @override
  String get whatToDo => 'Чим хочете зайнятися? (необов’язково)';

  @override
  String get whatToDoHint => 'наприклад, кава, прогулянка';

  @override
  String get imFree => 'Я вільний(-на)';

  @override
  String get yourTable => 'Ваш столик';

  @override
  String joinedCount(int count) {
    return 'Приєдналися: $count';
  }

  @override
  String waitingCount(int count) {
    return 'Очікуємо: $count';
  }

  @override
  String get settingUp => 'Збирається';

  @override
  String get chatOpen => 'Чат відкрито';

  @override
  String get tableChat => 'Чат столика';

  @override
  String chatOpensWhen(int count) {
    return 'Чат відкриється, коли приєднаються ще $count. Місце й час оберете там разом.';
  }

  @override
  String get leaveTable => 'Залишити столик';

  @override
  String tableInviteTitle(String name) {
    return '$name збирає столик і запрошує вас.';
  }

  @override
  String tableInviteStatus(int joined, int pending) {
    return 'Приєдналися: $joined · очікуємо: $pending. Чат відкриється, коли зберуться троє.';
  }

  @override
  String get join => 'Приєднатися';

  @override
  String get notTonight => 'Не сьогодні';

  @override
  String get tonight => 'Сьогодні ввечері';

  @override
  String get freeTonight => 'Вільні сьогодні ввечері';

  @override
  String get sharedGroupsOnly => 'Лише учасники спільних груп';

  @override
  String get nobodyFree => 'Зараз ніхто зі спільних груп не вільний.';

  @override
  String get howItWorks => 'Як це працює?';

  @override
  String get howStep1 =>
      'Натисніть «Я вільний(-на) сьогодні» й, за бажання, напишіть, чим зайнятися.';

  @override
  String get howStep2 => 'Учасники спільних груп бачать вас, а ви — вільних.';

  @override
  String get howStep3 =>
      'Зберіть столик: чат відкриється на трьох учасниках, там і оберете місце й час.';

  @override
  String get upcoming => 'Незабаром';

  @override
  String get calendar => 'Календар';

  @override
  String get noUpcomingJoined => 'Ви не берете участі в найближчих подіях.';

  @override
  String get showAll => 'Показати все';

  @override
  String get noUpcoming60 => 'Найближчі 60 днів у ваших груп немає подій.';

  @override
  String get findGroup => 'Знайти групу';

  @override
  String filterAll(int count) {
    return 'Усі · $count';
  }

  @override
  String filterMine(int count) {
    return 'Мої · $count';
  }

  @override
  String get tomorrow => 'Завтра';

  @override
  String get going => 'Ви йдете';

  @override
  String get waitlisted => 'У списку очікування';

  @override
  String get awaitingApproval => 'Очікує схвалення';

  @override
  String get full => 'Місць немає';

  @override
  String goingOfCapacityShort(int count, int capacity) {
    return 'Учасників: $count/$capacity';
  }

  @override
  String get startingSoon => 'Незабаром почнеться';

  @override
  String get next6Hours => 'Найближчі 6 годин';

  @override
  String get wantWelcome => 'Хочу, щоб мене зустріли';

  @override
  String get wantWelcomeHint =>
      'Волонтер із групи зустріне вас біля входу — ви не прийдете сам(а).';

  @override
  String get noteForGreeter => 'Нотатка, щоб вас упізнали (необов’язково)';

  @override
  String get noteForGreeterHint => 'Наприклад: червона куртка, синій рюкзак';

  @override
  String get sendRequest => 'Надіслати запит';

  @override
  String get welcomeRequestSent =>
      'Запит надіслано зустрічальникам. Повідомимо, коли хтось візьметься.';

  @override
  String get editMeetingNote => 'Змінити нотатку про зустріч';

  @override
  String welcomePerson(String name) {
    return 'Зустріти $name';
  }

  @override
  String describedAs(String note) {
    return 'Як себе описав(-ла): $note';
  }

  @override
  String get whereMeet => 'Де зустрінетеся?';

  @override
  String get whereMeetHint => 'Наприклад: біля кафе на вході, 8:45';

  @override
  String get save => 'Зберегти';

  @override
  String get iWillWelcome => 'Я зустріну';

  @override
  String get noteUpdated => 'Нотатку про зустріч оновлено.';

  @override
  String youWillWelcome(String name) {
    return 'Ви зустрічаєте $name; нотатку про зустріч уже видно.';
  }

  @override
  String get stopWelcoming => 'Відмовитися від зустрічі';

  @override
  String stopWelcomingBody(String name) {
    return 'Для $name знайдуть іншого зустрічальника й повідомлять.';
  }

  @override
  String get release => 'Відмовитися';

  @override
  String get releasedWelcome =>
      'Ви відмовилися; шукаємо іншого зустрічальника.';

  @override
  String get firstTime => 'Ідете вперше?';

  @override
  String greetersAvailable(int count) {
    return 'У групі зустрічальників: $count. Один із них зустріне вас біля входу й познайомить із групою.';
  }

  @override
  String get youWelcomed => 'Ви зустрічаєте';

  @override
  String meetingAt(String note) {
    return 'Зустріч: $note';
  }

  @override
  String get thankedYou => 'Подякував(-ла) вам';

  @override
  String optionsFor(String name) {
    return 'Дії для $name';
  }

  @override
  String waitingWelcome(int count) {
    return 'Чекають на зустріч ($count)';
  }

  @override
  String matchedCount(int count) {
    return 'Зустрічальника знайдено для: $count';
  }

  @override
  String get firstTimer => 'Уперше';

  @override
  String get max3Welcomes => 'На одній події можна зустріти до 3 людей.';

  @override
  String get greeterJoinHint =>
      'Ви зустрічальник. Запишіться на подію, щоб зустрічати новачків.';

  @override
  String get lookingGreeter => 'Шукаємо зустрічальника';

  @override
  String get lookingGreeterHint =>
      'Ми повідомили зустрічальникам. Прийде сповіщення, коли хтось візьметься.';

  @override
  String yourNote(String note) {
    return 'Ваша нотатка: $note';
  }

  @override
  String get welcomeWithdrawn => 'Запит відкликано.';

  @override
  String get withdrawRequest => 'Відкликати запит';

  @override
  String get greetedBy => 'Вас зустрів(-ла)';

  @override
  String get willGreet => 'Вас зустріне';

  @override
  String get thank => 'Подякувати';

  @override
  String thankReceived(String name) {
    return '$name отримав(-ла) вашу подяку.';
  }

  @override
  String get thanked => 'Ви подякували.';

  @override
  String get cancelWelcome => 'Скасувати зустріч';

  @override
  String get nowGreeter =>
      'Тепер ви зустрічальник. Повідомимо, коли новачок попросить його зустріти.';

  @override
  String get noLongerGreeter => 'Ви більше не зустрічальник.';

  @override
  String get welcomeSection => 'Зустріч новачків';

  @override
  String greetersCount(int count) {
    return 'Зустрічальників: $count';
  }

  @override
  String get greeterIntro =>
      'Новачки можуть попросити зустріч на сторінці події. Ставши зустрічальником, ви отримаєте сповіщення, зустрінете біля входу й познайомите з групою.';

  @override
  String greeterMemberHint(int count) {
    return 'У групі зустрічальників: $count. На першій події натисніть «Хочу, щоб мене зустріли».';
  }

  @override
  String greeterVisitorHint(int count) {
    return 'У групі зустрічальників: $count — на першу подію ви не підете самі, вас зустрінуть біля входу.';
  }

  @override
  String get becomeGreeter => 'Стати зустрічальником';

  @override
  String quoted(String text) {
    return '«$text»';
  }

  @override
  String seatsGoing(int count) {
    return 'Ідуть: $count';
  }

  @override
  String seatsOf(int count, int capacity) {
    return 'Людей: $count / $capacity';
  }

  @override
  String seatsOfWaiting(int count, int capacity, int waiting) {
    return 'Людей: $count / $capacity · чекають: $waiting';
  }

  @override
  String summaryAttended(int count) {
    return 'Було: $count';
  }

  @override
  String summaryRating(String avg, int count) {
    return '$avg ★ (відгуків: $count)';
  }

  @override
  String waitlistPlace(int place) {
    return 'Список очікування · №$place';
  }

  @override
  String get eventCanceled => 'Подію скасовано.';

  @override
  String eventCanceledBecause(String reason) {
    return 'Подію скасовано: $reason';
  }

  @override
  String reviewBy(String name, int stars) {
    return '$name, зірок: $stars';
  }

  @override
  String get conflicting => 'Перетинається';

  @override
  String get events => 'Події';

  @override
  String get create => 'Створити';

  @override
  String eventsLeft(int count) {
    return 'Залишилося подій цього місяця: $count.';
  }

  @override
  String get eventsLimitReached =>
      'Ліміт подій на цей місяць вичерпано. Підвищте тариф, щоб отримати більше.';

  @override
  String groupRating(String avg, int count) {
    return '$avg · відгуків про події: $count';
  }

  @override
  String get howWasIt => 'Як минуло?';

  @override
  String get howWasItHint =>
      'Оцініть подію, на якій були; усі бачать лише середню оцінку.';

  @override
  String titleOnDate(String title, String date) {
    return '$title · $date';
  }

  @override
  String get eventsEmpty => 'Похід, концерт чи зустріч — створіть першу подію.';

  @override
  String get requestSent =>
      'Запит надіслано. Повідомимо, коли організатор вирішить.';

  @override
  String get attendanceSaved => 'Вас записано. Нагадаємо перед початком.';

  @override
  String waitlistJoined(int place) {
    return 'Ви у списку очікування (№$place). Повідомимо, коли звільниться місце.';
  }

  @override
  String get conflictTitle => 'У вас інша подія в цей самий час';

  @override
  String conflictLine(String title, String date) {
    return '• $title · $date';
  }

  @override
  String get conflictOne =>
      'Якщо не зможете піти, відмовтеся й поступіться місцем іншому.';

  @override
  String get conflictMany =>
      'Якщо не зможете піти, відмовтеся й поступіться місцями іншим.';

  @override
  String get keepBoth => 'Залишити обидва';

  @override
  String get leaveOther => 'Відмовитися від іншої';

  @override
  String get leaveOthers => 'Відмовитися від інших';

  @override
  String get leftOther => 'Ви відмовилися від іншої події; місце звільнилося.';

  @override
  String get leftOthers => 'Ви відмовилися від інших подій.';

  @override
  String approvedPerson(String name) {
    return '$name тепер бере участь.';
  }

  @override
  String declinedPerson(String name) {
    return 'Запит відхилено; $name повідомлено.';
  }

  @override
  String get calendarFailed =>
      'Не вдалося відкрити файл календаря. Спробуйте ще раз.';

  @override
  String get stopSeriesTitle => 'Зупинити повторення?';

  @override
  String get stopSeriesBody =>
      'Нові дати не відкриються. Уже відкриті залишаться; їх можна скасувати по одній.';

  @override
  String get stop => 'Зупинити';

  @override
  String get seriesStopped => 'Повторення зупинено.';

  @override
  String get eventCanceledToast => 'Подію скасовано.';

  @override
  String get eventNotFound => 'Подію не знайдено або вона більше не видима.';

  @override
  String get goBack => 'Назад';

  @override
  String joinGroupFirst(String name) {
    return 'Вступити до «$name»';
  }

  @override
  String get sendJoinRequest => 'Надіслати запит на участь';

  @override
  String get joinWaitlist => 'Стати до списку очікування';

  @override
  String get leaveEvent => 'Відмовитися';

  @override
  String get leaveWaitlist => 'Вийти зі списку очікування';

  @override
  String get requestWithdrawn => 'Запит відкликано.';

  @override
  String get attendanceRemoved => 'Ви відмовилися від участі.';

  @override
  String eventShareText(String title) {
    return '$title · приєднуйтеся в GWAY:';
  }

  @override
  String get eventLinkCopied => 'Посилання на подію скопійовано.';

  @override
  String get report => 'Поскаржитися';

  @override
  String get eventOptions => 'Дії з подією';

  @override
  String get edit => 'Змінити';

  @override
  String get cancelThisDate => 'Скасувати цю дату';

  @override
  String get stopRepeat => 'Зупинити повторення';

  @override
  String get startedOrEnded => 'Почалася або завершилася';

  @override
  String seriesUntil(String label, String date) {
    return '$label · до $date';
  }

  @override
  String get addToCalendar => 'Додати до календаря';

  @override
  String fee(String fee) {
    return 'Вартість участі: $fee';
  }

  @override
  String get feeNotice => 'Оплата йде організатору; GWAY платежі не приймає.';

  @override
  String get areYouComing => 'Ви прийдете?';

  @override
  String get areYouComingHint =>
      'Якщо не зможете, поступіться місцем списку очікування.';

  @override
  String get yesComing => 'Так, прийду';

  @override
  String get confirmThanks =>
      'Дякуємо, ми повідомили організатору, що ви прийдете.';

  @override
  String get cantCome => 'Не зможу';

  @override
  String get spotFreed => 'Ви відмовилися; місце звільнилося.';

  @override
  String get confirmedComing => 'Ви підтвердили участь.';

  @override
  String get otherEventSameTime => 'У цей час у вас інша подія';

  @override
  String get needsApproval => 'Участь зі схвалення';

  @override
  String get requirements => 'Умови участі';

  @override
  String get equipment => 'Потрібне спорядження';

  @override
  String joinRequestsCount(int count) {
    return 'Запити на участь ($count)';
  }

  @override
  String get attendees => 'Учасники';

  @override
  String confirmedOf(int going, int confirmed) {
    return 'Підтвердили: $confirmed з $going.';
  }

  @override
  String confirmedName(String name) {
    return '$name · підтвердив(-ла)';
  }

  @override
  String get shareWasThere => 'Поділитися карткою «Я теж там був(-ла)»';

  @override
  String get howDidItGo => 'Як минуло?';

  @override
  String reviewsCount(int count) {
    return 'Відгуки ($count)';
  }

  @override
  String get reviewNotesPrivate => 'Нотатки бачать лише організатори.';

  @override
  String get attendanceCheck => 'Відмітка присутності';

  @override
  String get attendanceCheckHint =>
      'Позначте тих, хто не прийшов: у внесок і значки йдуть лише присутні. Доступно 7 днів після завершення.';

  @override
  String markedCame(String name) {
    return '$name: позначено як присутнього(-ю).';
  }

  @override
  String markedMissed(String name) {
    return '$name: позначено як відсутнього(-ю).';
  }

  @override
  String get didntCome => 'Не прийшов';

  @override
  String get came => 'Прийшов';

  @override
  String get memories => 'Спогади';

  @override
  String get shareMemory => 'Поділитися спогадом';

  @override
  String get eventPolls => 'Опитування події';

  @override
  String get noEditPermission => 'У вас немає прав на редагування події.';

  @override
  String get editEvent => 'Редагувати подію';

  @override
  String get newEvent => 'Нова подія';

  @override
  String get addCover => 'Додати обкладинку';

  @override
  String get titleExample => 'Наприклад: прогулянка лісом';

  @override
  String get starts => 'Початок';

  @override
  String get endsOptional => 'Завершення (необов’язково)';

  @override
  String get notSpecified => 'Не вказано';

  @override
  String get removeEnd => 'Прибрати завершення';

  @override
  String get repeat => 'Повтор';

  @override
  String get noRepeat => 'Без повтору';

  @override
  String get weekly => 'Щотижня';

  @override
  String get biweekly => 'Раз на два тижні';

  @override
  String get lastDateOptional => 'Остання дата (необов’язково)';

  @override
  String get untilYouStop => 'Поки не зупините';

  @override
  String get removeLastDate => 'Прибрати останню дату';

  @override
  String get repeatHint =>
      'Наступні дати відкриваються самі за 4 тижні, і кожна враховується в місячному ліміті.';

  @override
  String get surpriseVenue => 'Місце-сюрприз';

  @override
  String get surpriseHint =>
      'Місце відкриють лише учасникам — у вибраний вами час до початку.';

  @override
  String get hintPublic => 'Підказка (бачать усі)';

  @override
  String get place => 'Місце';

  @override
  String get hintExample => 'Наприклад: біля моря, на азійському березі';

  @override
  String get placeExample => 'Наприклад: вхід до парку або онлайн';

  @override
  String get writeHint => 'Напишіть підказку.';

  @override
  String get writePlace => 'Вкажіть місце.';

  @override
  String get realVenue => 'Справжнє місце (бачать лише учасники)';

  @override
  String get realVenueExample => 'Наприклад: біля театру';

  @override
  String get writeRealVenue => 'Вкажіть справжнє місце.';

  @override
  String get whenReveal => 'Коли відкрити?';

  @override
  String hoursBefore(int count) {
    return 'За $count год';
  }

  @override
  String get linkOptional => 'Посилання на мапу або онлайн (необов’язково)';

  @override
  String get httpsRequired => 'Посилання має починатися з https://.';

  @override
  String get description => 'Опис';

  @override
  String get capacity => 'Місць (порожньо = без обмежень)';

  @override
  String get capacityHint =>
      'Коли місця скінчаться, нові потраплять до списку очікування.';

  @override
  String get capacityRange => 'Місць має бути від 1 до 10 000.';

  @override
  String get requirementsOptional => 'Умови участі (необов’язково)';

  @override
  String get requirementsExample => 'Наприклад: досвід походів від 10 км';

  @override
  String get equipmentOptional => 'Потрібне спорядження (необов’язково)';

  @override
  String get equipmentExample => 'Наприклад: шолом, вода, дощовик';

  @override
  String get equipmentHint => 'Через кому; до 10 пунктів.';

  @override
  String get equipmentLimit => 'До 10 пунктів, кожен до 60 символів.';

  @override
  String get approvalRequired => 'Участь зі схвалення';

  @override
  String get approvalHint => 'Охочі надсилають запит, а ви схвалюєте.';

  @override
  String get feeOptional => 'Вартість участі (необов’язково)';

  @override
  String get feeInfoOnly => 'Лише для інформації; GWAY платежі не приймає.';

  @override
  String get amount => 'Сума';

  @override
  String get amountExample => 'Наприклад, 150';

  @override
  String get validAmount => 'Введіть коректну суму.';

  @override
  String get paymentNote => 'Примітка до оплати';

  @override
  String get paymentNoteExample => 'Наприклад: готівкою на місці';

  @override
  String get createEvent => 'Створити подію';

  @override
  String get rateEvent => 'Оцінити подію';

  @override
  String get yourReview => 'Ваш відгук';

  @override
  String starsLabel(int count) {
    return 'Зірок: $count';
  }

  @override
  String get noteToOrganizers => 'Нотатка організаторам (необов’язково)';

  @override
  String get noteToOrganizersHint =>
      'Нотатку бачать лише організатори; решта — тільки середню оцінку.';

  @override
  String get reviewDeleted => 'Ваш відгук видалено.';

  @override
  String get delete => 'Видалити';

  @override
  String get reviewSaved => 'Дякуємо, відгук збережено.';

  @override
  String get groupNext => 'Найближчі події групи';

  @override
  String sameDayOthers(int count) {
    return 'Цього дня у вашій провінції ще $count подій тієї самої категорії. Виберіть інший день, щоб учасникам не довелося обирати.';
  }

  @override
  String get cancelEvent => 'Скасувати подію';

  @override
  String get cancelEventBody =>
      'Учасники й список очікування отримають сповіщення. Скасувати це не можна.';

  @override
  String get reason => 'Причина';

  @override
  String get cancelAction => 'Скасувати';

  @override
  String hint(String hint) {
    return 'Підказка: $hint';
  }

  @override
  String hintRevealAt(String hint, String when) {
    return 'Підказка: $hint · Учасникам відкриється $when.';
  }

  @override
  String get venueRevealed =>
      'Місце відкрито учасникам. Запишіться, щоб побачити.';

  @override
  String venueRevealAt(String when) {
    return 'Місце відкриється учасникам $when.';
  }

  @override
  String get currencyTry => '₺ TRY';

  @override
  String get badgeFirstStep => 'Перший крок';

  @override
  String get badgeFirstStepText => 'Відвідайте перший захід.';

  @override
  String get badgeRegular => 'Завсідник';

  @override
  String get badgeRegularText => 'Відвідайте 10 заходів.';

  @override
  String get badgeCompanion => 'Попутник';

  @override
  String get badgeCompanionText => 'Відвідайте 25 заходів.';

  @override
  String get badgeExplorer => 'Дослідник';

  @override
  String get badgeExplorerText => 'Відвідайте заходи 3 різних груп.';

  @override
  String get badgeOrganizer => 'Організатор';

  @override
  String get badgeOrganizerText =>
      'Організуйте захід, де буде хоча б 2 людини.';

  @override
  String get badgeMasterOrganizer => 'Майстер-організатор';

  @override
  String get badgeMasterOrganizerText =>
      'Організуйте 10 заходів, де буде хоча б 2 людини.';

  @override
  String get badgeStoryteller => 'Хранитель спогадів';

  @override
  String get badgeStorytellerText =>
      'Додайте 5 спогадів до відвіданих заходів.';

  @override
  String get badgeFeedback => 'Відгукувач';

  @override
  String get badgeFeedbackText => 'Оцініть 5 відвіданих заходів.';

  @override
  String get badgeDoorOpener => 'Той, хто відчиняє двері';

  @override
  String get badgeDoorOpenerText => 'Зустріньте новачка на заході.';

  @override
  String get badgeHost => 'Господар';

  @override
  String get badgeHostText => 'Зустріньте 5 новачків.';

  @override
  String get badgeCommunityHeart => 'Серце спільноти';

  @override
  String get badgeCommunityHeartText => 'Зустріньте 20 новачків.';

  @override
  String get badgeFriendly => 'Товариський';

  @override
  String get badgeFriendlyText =>
      'Обміняйтеся рукостисканням із 5 людьми на заходах.';

  @override
  String get badgeSocialButterfly => 'Душа компанії';

  @override
  String get badgeSocialButterflyText =>
      'Обміняйтеся рукостисканням із 25 людьми на заходах.';

  @override
  String get badgeCategory => 'Шанувальник категорії';

  @override
  String get badgeCategoryText => 'Відвідайте 5 заходів однієї категорії.';

  @override
  String badgeCategoryOf(String category) {
    return 'Шанувальник: $category';
  }

  @override
  String badgeCategoryOfText(String category) {
    return 'Відвідав(-ла) 5 заходів категорії «$category».';
  }

  @override
  String badgeGoal(String goal) {
    return 'Ціль: $goal';
  }

  @override
  String badgeGoalText(String group) {
    return 'Виконав(-ла) ціль групи «$group».';
  }
}
