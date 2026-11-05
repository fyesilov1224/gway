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
}
