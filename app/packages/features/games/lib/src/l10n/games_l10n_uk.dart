// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'games_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class GamesL10nUk extends GamesL10n {
  GamesL10nUk([String locale = 'uk']) : super(locale);

  @override
  String get chess => 'Шахи';

  @override
  String get bullet => 'Куля';

  @override
  String get blitz => 'Бліц';

  @override
  String get rapid => 'Рапід';

  @override
  String get white => 'Білі';

  @override
  String get black => 'Чорні';

  @override
  String get colorRandom => 'Випадково';

  @override
  String get endCheckmate => 'Мат';

  @override
  String get endResign => 'Здача';

  @override
  String get endTimeout => 'Час вийшов';

  @override
  String get endTimeoutDraw => 'Час вийшов, суперник не може поставити мат';

  @override
  String get endStalemate => 'Пат';

  @override
  String get endInsufficient => 'Недостатньо матеріалу';

  @override
  String get endFiftyMoves => 'Правило 50 ходів';

  @override
  String get endRepetition => 'Триразове повторення';

  @override
  String get endAgreement => 'Нічия за згодою';

  @override
  String get endAborted => 'Скасовано';

  @override
  String get boardLabel => 'Шахова дошка';

  @override
  String get promoteTo => 'Перетворити пішака на';

  @override
  String get queen => 'Ферзь';

  @override
  String get rook => 'Тура';

  @override
  String get bishop => 'Слон';

  @override
  String get knight => 'Кінь';

  @override
  String get medalGold => 'Золота медаль';

  @override
  String get medalSilver => 'Срібна медаль';

  @override
  String get medalBronze => 'Бронзова медаль';

  @override
  String get youWon => 'Ви виграли';

  @override
  String get youLost => 'Ви програли';

  @override
  String get draw => 'Нічия';

  @override
  String get inProgress => 'Триває';

  @override
  String get whiteWon => 'Білі виграли';

  @override
  String get blackWon => 'Чорні виграли';

  @override
  String get rated => 'Рейтингова';

  @override
  String get casual => 'Без рейтингу';

  @override
  String get ratedHint => 'Результат змінить ваш рейтинг Ело.';

  @override
  String get flipBoard => 'Перевернути дошку';

  @override
  String get cancel => 'Скасувати';

  @override
  String get resign => 'Здатися';

  @override
  String get resignTitle => 'Здати партію?';

  @override
  String get resignBody =>
      'Суперник переможе; у рейтинговій партії ваш Ело знизиться.';

  @override
  String get abort => 'Скасувати';

  @override
  String get offerDraw => 'Нічия?';

  @override
  String get drawOffered => 'Запропоновано';

  @override
  String get drawOfferReceived => 'Суперник пропонує нічию.';

  @override
  String get accept => 'Прийняти';

  @override
  String get decline => 'Відхилити';

  @override
  String get rematch => 'Реванш';

  @override
  String get rematchSent => 'Запит на реванш надіслано.';

  @override
  String get newGame => 'Нова партія';

  @override
  String newRating(String category, int rating) {
    return 'Ваш рейтинг ($category): $rating';
  }

  @override
  String get deletedPlayer => 'Видалений акаунт';

  @override
  String get firstMove => 'Перший хід: 30 с';

  @override
  String get noMovesYet => 'Ходів поки немає. Починають білі.';

  @override
  String get watching => 'Ви спостерігаєте';

  @override
  String get quickGame => 'Швидка гра';

  @override
  String get quickGameHint =>
      'Оберіть контроль і грайте із суперником вашого рівня.';

  @override
  String get searching => 'Шукаємо суперника…';

  @override
  String waitedSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Очікування: $count секунди',
      many: 'Очікування: $count секунд',
      few: 'Очікування: $count секунди',
      one: 'Очікування: $count секунда',
    );
    return '$_temp0';
  }

  @override
  String get chessProfile => 'Шаховий профіль';

  @override
  String get recentGames => 'Останні партії';

  @override
  String get noGamesMine => 'Партій поки немає. Зіграйте першу.';

  @override
  String get noGamesTheirs => 'Партій поки немає. Запросіть на першу.';

  @override
  String get playNow => 'Грати';

  @override
  String get challenge => 'Запросити';

  @override
  String get noFlag => 'Прапор не вибрано';

  @override
  String get chooseFlag => 'Оберіть прапор';

  @override
  String get chooseFlagHint => 'Він показується біля вашого імені в рейтингу.';

  @override
  String get searchCountry => 'Пошук країни';

  @override
  String get flagSaved => 'Прапор збережено.';

  @override
  String get pickFlagPrompt => 'Оберіть прапор для рейтингу.';

  @override
  String get suspendedNotice => 'Шахи для цієї людини зараз закриті.';

  @override
  String get notPlayed => 'Не грав';

  @override
  String gamesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count партії',
      many: '$count партій',
      few: '$count партії',
      one: '$count партія',
    );
    return '$_temp0';
  }

  @override
  String rankShort(int rank) {
    return '$rank-е місце';
  }

  @override
  String get leaderboard => 'Рейтинг';

  @override
  String record(int wins, int draws, int losses) {
    return '$winsВ · $drawsН · $lossesП';
  }

  @override
  String get seeAll => 'Переглянути все';

  @override
  String get invitations => 'Запрошення';

  @override
  String invitesYou(String what) {
    return 'Запрошує вас на партію: $what';
  }

  @override
  String wantsRematch(String what) {
    return 'Хоче реванш: $what';
  }

  @override
  String waitingFor(String what) {
    return 'Очікуємо відповіді: $what';
  }

  @override
  String get withdraw => 'Відкликати';

  @override
  String get gameInProgress => 'У вас триває партія';

  @override
  String get resume => 'Продовжити';

  @override
  String get challengeFriend => 'Запросити друга';

  @override
  String get challengeSent =>
      'Запрошення надіслано. Партія почнеться, коли його приймуть.';

  @override
  String get challengeTitle => 'Запросити на партію';

  @override
  String get changePerson => 'Змінити';

  @override
  String get searchPerson => 'Ім\'я користувача або ім\'я';

  @override
  String get timeControl => 'Контроль часу';

  @override
  String get yourColor => 'Ваш колір';

  @override
  String get sendChallenge => 'Надіслати запрошення';

  @override
  String get teamMatch => 'Командний матч';

  @override
  String get teamMatches => 'Командні матчі';

  @override
  String get teamMatchesHint =>
      'Шахові матчі ваших груп; результат змінює Ело групи.';

  @override
  String get noTeamMatches =>
      'Командних матчів поки немає. Запросіть іншу групу від імені своєї.';

  @override
  String get newTeamMatch => 'Влаштувати матч';

  @override
  String get newTeamMatchHint =>
      'Коли інша група погодиться, обидві розставлять гравців.';

  @override
  String get yourGroup => 'Ваша група';

  @override
  String get opponentGroup => 'Група-суперник';

  @override
  String get searchGroup => 'Назва або ім’я групи';

  @override
  String get startsAt => 'Початок';

  @override
  String get sendTeamInvite => 'Запросити групу';

  @override
  String get boards => 'Дошки';

  @override
  String get boardsShort => 'дошок';

  @override
  String boardsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дошки',
      many: '$count дошок',
      few: '$count дошки',
      one: '$count дошка',
    );
    return '$_temp0';
  }

  @override
  String groupElo(int rating) {
    return 'Ело групи $rating';
  }

  @override
  String get versus => 'VS';

  @override
  String get versusShort => '–';

  @override
  String get teamInvited => 'Очікує відповіді';

  @override
  String get teamAccepted => 'Прийнято';

  @override
  String get teamDeclined => 'Відхилено';

  @override
  String get teamCanceled => 'Скасовано';

  @override
  String get teamLive => 'Триває';

  @override
  String get teamFinished => 'Завершено';

  @override
  String teamInviteReceived(String group) {
    return '$group запрошує вашу групу на командний матч.';
  }

  @override
  String get teamAcceptedDone => 'Матч прийнято. Тепер розставте гравців.';

  @override
  String get teamDeclinedDone => 'Запрошення відхилено.';

  @override
  String get teamCanceledDone => 'Матч скасовано.';

  @override
  String get callOff => 'Скасувати матч';

  @override
  String get lineupHint => 'Порожня на старті дошка зараховується суперникові.';

  @override
  String get lineupSheetHint =>
      'Торкайтеся учасників, щоб розставити їх по черзі; перша дошка — для найсильнішого.';

  @override
  String editLineup(String group) {
    return 'Склад: $group';
  }

  @override
  String get saveLineup => 'Зберегти склад';

  @override
  String get emptyBoard => 'Порожньо';

  @override
  String ratingGames(int rating, int games) {
    return 'Ело $rating · партій: $games';
  }

  @override
  String get groupsTab => 'Групи';

  @override
  String get groupLeaderboardEmpty =>
      'Жодна група ще не зіграла командний матч. Станьте першими.';

  @override
  String get backToChess => 'До шахів';

  @override
  String get arena => 'Турнір';

  @override
  String get tournaments => 'Турніри';

  @override
  String get tournamentsHint =>
      'Щотижневі та щомісячні арени; трійка найкращих отримує медалі.';

  @override
  String get weeklyArena => 'Щотижнева арена';

  @override
  String get monthlyArena => 'Щомісячна арена';

  @override
  String get arenaRules =>
      'Арена: грайте скільки завгодно партій до кінця. Перемога — 2 очки, нічия — 1; після двох перемог поспіль очки подвоюються, доки серія не перерветься. Партії, почати до кінця, зараховуються.';

  @override
  String get arenaLiveNow => 'Триває зараз';

  @override
  String get arenaUpcoming => 'Незабаром';

  @override
  String get arenaFinished => 'Завершені';

  @override
  String get registered => 'Ви записані';

  @override
  String get arenaRegister => 'Записатися';

  @override
  String get arenaRegistered =>
      'Ви записані. На старті надійде сповіщення, і вас одразу підберуть.';

  @override
  String get arenaJoin => 'Долучитися';

  @override
  String get arenaResume => 'Продовжити гру';

  @override
  String get arenaPause => 'Пауза';

  @override
  String get arenaWaiting =>
      'Чекаємо суперника: партія відкриється сама, коли звільниться гравець із близьким рахунком.';

  @override
  String get backToGame => 'Повернутися до партії';

  @override
  String get backToArena => 'До турніру';

  @override
  String get backToTeamMatch => 'До командного матчу';

  @override
  String arenaStartsIn(String time) {
    return 'Початок через $time';
  }

  @override
  String arenaEndsIn(String time) {
    return 'Лишилося $time';
  }

  @override
  String get arenaLastGames => 'Час вийшов, догравають останні партії';

  @override
  String arenaFinishedAt(String time) {
    return 'Завершено · $time';
  }

  @override
  String hoursMinutes(int hours, int minutes) {
    return '$hours год $minutes хв';
  }

  @override
  String minutesLong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count хвилини',
      many: '$count хвилин',
      few: '$count хвилини',
      one: '$count хвилина',
    );
    return '$_temp0';
  }

  @override
  String playersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count гравця',
      many: '$count гравців',
      few: '$count гравці',
      one: '$count гравець',
    );
    return '$_temp0';
  }

  @override
  String myArenaScore(int points, int games) {
    return 'Очки: $points · партій: $games';
  }

  @override
  String get onFire => 'Серія: наступний результат — подвійні очки';

  @override
  String get standings => 'Таблиця';

  @override
  String get arenaEmpty => 'Поки нікого немає. Будьте першим.';

  @override
  String performance(int value) {
    return 'Перформанс $value';
  }

  @override
  String get playingNow => 'грає';

  @override
  String get arenaMedals => 'Турнірні медалі';

  @override
  String medalsSummary(int gold, int silver, int bronze) {
    return 'Медалі: золото $gold, срібло $silver, бронза $bronze';
  }

  @override
  String get firstMoveTeam => 'Перший хід: 5 хв';

  @override
  String get games => 'Ігри';

  @override
  String get gamesIntro =>
      'Грайте зі своєю спільнотою: швидкі партії, турніри та матчі між групами.';

  @override
  String get chessCardText =>
      'Рейтинг Ело, щотижневі та щомісячні турніри, командні матчі між групами й медалі.';

  @override
  String get playChess => 'Грати в шахи';

  @override
  String blitzRating(int rating) {
    return 'Бліц $rating';
  }

  @override
  String nextArena(String time) {
    return 'Наступний турнір: $time';
  }

  @override
  String invitesWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count запрошення чекають',
      many: '$count запрошень чекають',
      few: '$count запрошення чекають',
      one: '$count запрошення чекає',
    );
    return '$_temp0';
  }

  @override
  String get playOnline => 'Грати онлайн';

  @override
  String findOpponent(String tc) {
    return 'Знайти суперника · $tc';
  }

  @override
  String get challengeFriendHint => 'Оберіть час і колір';

  @override
  String get leaderboardHint => 'Рейтинг Ело й медалі';

  @override
  String openTeamMatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count відкритого матчу',
      many: '$count відкритих матчів',
      few: '$count відкриті матчі',
      one: '$count відкритий матч',
    );
    return '$_temp0';
  }

  @override
  String get appearance => 'Дошка й фігури';

  @override
  String get boardTheme => 'Дошка';

  @override
  String get pieceSet => 'Фігури';

  @override
  String get boardWood => 'Дерево';

  @override
  String get boardGreen => 'Зелена';

  @override
  String get boardBlue => 'Синя';

  @override
  String get boardSlate => 'Сіра';

  @override
  String get boardLilac => 'Бузкова GWAY';

  @override
  String get piecesClassic => 'Класика';

  @override
  String get piecesCeltic => 'Кельтські';

  @override
  String get piecesSpatial => 'Космос';

  @override
  String get piecesFantasy => 'Фентезі';

  @override
  String get piecesModern => 'Модерн';

  @override
  String get piecesWarm => 'Теплі';

  @override
  String get firstPosition => 'Початок';

  @override
  String get previousMove => 'Попередній хід';

  @override
  String get nextMove => 'Наступний хід';

  @override
  String get lastPosition => 'Поточна позиція';

  @override
  String get backToLive => 'До поточної';

  @override
  String pointsShort(int points) {
    return '$points оч.';
  }

  @override
  String mindColorWord(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'red_m': 'червоний',
      'red_f': 'червона',
      'red_n': 'червоне',
      'blue_m': 'синій',
      'blue_f': 'синя',
      'blue_n': 'синє',
      'green_m': 'зелений',
      'green_f': 'зелена',
      'green_n': 'зелене',
      'yellow_m': 'жовтий',
      'yellow_f': 'жовта',
      'yellow_n': 'жовте',
      'purple_m': 'фіолетовий',
      'purple_f': 'фіолетова',
      'purple_n': 'фіолетове',
      'orange_m': 'помаранчевий',
      'orange_f': 'помаранчева',
      'orange_n': 'помаранчеве',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String mindPatternWord(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'solid_m': 'суцільний',
      'solid_f': 'суцільна',
      'solid_n': 'суцільне',
      'striped_m': 'смугастий',
      'striped_f': 'смугаста',
      'striped_n': 'смугасте',
      'dotted_m': 'цятчастий',
      'dotted_f': 'цятчаста',
      'dotted_n': 'цятчасте',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String mindShapeWord(String shape) {
    String _temp0 = intl.Intl.selectLogic(shape, {
      'circle': 'коло',
      'square': 'квадрат',
      'triangle': 'трикутник',
      'star': 'зірка',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String mindShapeGender(String shape) {
    String _temp0 = intl.Intl.selectLogic(shape, {
      'circle': 'n',
      'square': 'm',
      'triangle': 'm',
      'star': 'f',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String mindFigure(String color, String pattern, String shape) {
    return '$color $pattern $shape';
  }

  @override
  String get mindDuel => 'Дуель розуму';

  @override
  String get mindCardText =>
      'Жива дуель: рахунок, увага, пам’ять і реакція. Рейтинг Ело, таблиці й медалі.';

  @override
  String get mindPlay => 'Почати дуель';

  @override
  String mindBestRating(int rating, int length) {
    return 'Ело $rating · запитань: $length';
  }

  @override
  String mindQuestions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count запитання',
      many: '$count запитань',
      few: '$count запитання',
      one: '$count запитання',
    );
    return '$_temp0';
  }

  @override
  String get mindHowMany => 'Скільки запитань?';

  @override
  String mindRatingAt(int count) {
    return 'Ваш рейтинг (запитань: $count)';
  }

  @override
  String get mindFindOpponent => 'Знайти суперника';

  @override
  String get mindSuspended => 'Зараз ви не можете грати.';

  @override
  String get mindActive => 'У вас триває дуель';

  @override
  String get mindProfile => 'Профіль дуелей';

  @override
  String get mindHowTo => 'Як грати';

  @override
  String get mindRecent => 'Останні дуелі';

  @override
  String get mindNoMatchesMine =>
      'Дуелей поки немає. Знайдіть першого суперника.';

  @override
  String get mindNoMatchesTheirs => 'Дуелей поки немає. Викличте першим.';

  @override
  String mindLeaderboardEmpty(int count) {
    return 'Зіграйте рейтингових дуелей цієї довжини: $count, щоб потрапити до таблиці.';
  }

  @override
  String get mindChallengeTitle => 'Викликати на дуель';

  @override
  String get mindChallengeSent =>
      'Виклик надіслано. Дуель почнеться, коли його приймуть.';

  @override
  String get mindKindMath => 'Рахунок';

  @override
  String get mindKindAttention => 'Увага';

  @override
  String get mindKindMemory => 'Пам’ять';

  @override
  String get mindKindReflex => 'Реакція';

  @override
  String get mindKindMathHint =>
      'Чотири дії з урахуванням порядку. Оберіть правильну відповідь.';

  @override
  String get mindKindAttentionHint =>
      'Не зважайте на колір тексту — оберіть описану фігуру.';

  @override
  String get mindKindMemoryHint =>
      'Запам’ятайте кольорові літери й цифри за порядком і кольором.';

  @override
  String get mindKindReflexHint =>
      'Торкніться цілі, щойно вона з’явиться. Зарано або повз — мінус бали.';

  @override
  String get mindScoringHint =>
      'Правильні й швидкі відповіді дають більше балів. Перемагає більша сума.';

  @override
  String get mindYou => 'Ви';

  @override
  String get mindOpponent => 'Суперник';

  @override
  String mindProgress(String who, int done, int total) {
    return '$who: $done/$total запитань';
  }

  @override
  String mindQuestionOf(int n, int total) {
    return '$n/$total';
  }

  @override
  String get mindGetReady => 'Приготуйтеся';

  @override
  String get mindYouFinished => 'Ви закінчили!';

  @override
  String mindOpponentAt(int done, int total) {
    return 'Суперник на $done/$total. Підсумок — коли він закінчить.';
  }

  @override
  String get mindMathPrompt => 'Який результат?';

  @override
  String get mindAttentionPrompt => 'Оберіть описану фігуру';

  @override
  String get mindMemoryLook => 'Запам’ятайте порядок і кольори';

  @override
  String get mindMemoryPick => 'Оберіть у тому ж порядку й кольорі';

  @override
  String mindCharLabel(String char, String color) {
    return '$color $char';
  }

  @override
  String get mindUndo => 'Скасувати';

  @override
  String get mindReflexTarget => 'Ціль';

  @override
  String get mindReflexWait => 'Чекайте…';

  @override
  String get mindReflexTap => 'Тисніть!';

  @override
  String mindRight(int points) {
    return 'Правильно · +$points';
  }

  @override
  String mindPartly(int points) {
    return 'Частково правильно · +$points';
  }

  @override
  String get mindWrong => 'Неправильно';

  @override
  String mindWrongPenalty(int points) {
    return 'Неправильно · −$points';
  }

  @override
  String mindTooEarly(int points) {
    return 'Зарано · −$points';
  }

  @override
  String get mindResignTitle => 'Здатися?';

  @override
  String get mindResignBody =>
      'Перемога дістанеться суперникові; у рейтинговій дуелі ваш Ело знизиться.';

  @override
  String get mindFinished => 'Дуель завершено';

  @override
  String get mindEndCompleted => 'Усі запитання відповіли';

  @override
  String get mindEndTime => 'Час вийшов';

  @override
  String mindNewRating(int rating) {
    return 'Новий рейтинг $rating';
  }

  @override
  String get mindNewDuel => 'Нова дуель';

  @override
  String get mindBackHome => 'До дуелей';

  @override
  String get mindTeamMatches => 'Групові дуелі';

  @override
  String get mindTeamMatchesHint =>
      'Дуелі ваших груп з іншими; підсумок змінює дуельний Ело групи.';

  @override
  String get mindNoTeamMatches =>
      'Групових дуелей поки немає. Викличте іншу групу від імені своєї.';

  @override
  String get mindNewTeamMatch => 'Влаштувати групову дуель';

  @override
  String get mindNewTeamHint =>
      'Коли інша група прийме виклик, обидві розставлять гравців. На старті двоє на кожному місці грають дуель одночасно.';

  @override
  String get mindTeamMatch => 'Групова дуель';

  @override
  String get mindSeats => 'Місця';

  @override
  String mindSeatsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count місця',
      many: '$count місць',
      few: '$count місця',
      one: '$count місце',
    );
    return '$_temp0';
  }

  @override
  String get mindLineupHint =>
      'Порожнє на старті місце зараховується суперникові. Першого запитання чекають 5 хвилин.';

  @override
  String get mindGroupLeaderboardEmpty =>
      'Жодна група ще не грала дуель. Нехай ваша влаштує першу.';

  @override
  String get mindTournaments => 'Турніри';

  @override
  String get mindTournamentsHint =>
      'Щотижня в суботу о 21:00 (10 запитань), щомісяця в останню суботу о 19:00 (20 запитань); трійці найкращих — медалі.';

  @override
  String get mindNoTournaments => 'Найближчих турнірів немає.';

  @override
  String get piecesPro => 'Про';

  @override
  String get piecesPaper => 'Папір';

  @override
  String get levelTitle => 'Обери свій рівень';

  @override
  String get levelBody =>
      'Рейтинг почнеться з обраного рівня й за перші партії швидко наблизиться до твоєї справжньої сили.';

  @override
  String get levelPrompt =>
      'Обирається один раз, до першої рейтингової партії.';

  @override
  String get levelNew => 'Новачок';

  @override
  String get levelNewHint => 'Вчуся, як ходять фігури.';

  @override
  String get levelBeginner => 'Початківець';

  @override
  String get levelBeginnerHint => 'Знаю правила й іноді граю.';

  @override
  String get levelIntermediate => 'Середній';

  @override
  String get levelIntermediateHint => 'Граю регулярно й знаю базову тактику.';

  @override
  String get levelAdvanced => 'Просунутий';

  @override
  String get levelAdvancedHint => 'Добре знаю дебюти й ендшпілі.';

  @override
  String get levelMaster => 'Експерт';

  @override
  String get levelMasterHint => 'Граю в турнірах.';

  @override
  String get levelNote => 'Після рейтингової партії рівень змінити не можна.';

  @override
  String levelSaved(int rating) {
    return 'Рівень збережено: ти починаєш з $rating.';
  }

  @override
  String get leaderboardNoGames =>
      'У цій категорії ще немає рейтингових партій. Зіграй першу.';

  @override
  String get leaderboardSettling =>
      'Рейтинги встановлюються в перших партіях; лідери скоро з’являться тут.';

  @override
  String get provisionalPlayers => 'Рейтинг встановлюється';

  @override
  String get provisionalPlayersHint =>
      'Попередній рейтинг (?); потрапить до таблиці за кілька партій.';

  @override
  String get provisionalShort => 'Попередній';

  @override
  String get yourPlace => 'Твоє місце';

  @override
  String get columnPlayer => 'Гравець';

  @override
  String get column30Days => '30 днів';

  @override
  String get columnRating => 'Рейтинг';

  @override
  String winRate(int percent) {
    return '$percent% очок';
  }

  @override
  String peakRating(int rating) {
    return 'Макс. $rating';
  }

  @override
  String get ratingSystemNote =>
      'Рейтинг рахується за системою Glicko-2. «?» означає, що рейтинг ще попередній.';
}
