// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'games_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class GamesL10nRu extends GamesL10n {
  GamesL10nRu([String locale = 'ru']) : super(locale);

  @override
  String get chess => 'Шахматы';

  @override
  String get bullet => 'Пуля';

  @override
  String get blitz => 'Блиц';

  @override
  String get rapid => 'Рапид';

  @override
  String get white => 'Белые';

  @override
  String get black => 'Чёрные';

  @override
  String get colorRandom => 'Случайно';

  @override
  String get endCheckmate => 'Мат';

  @override
  String get endResign => 'Сдача';

  @override
  String get endTimeout => 'Время вышло';

  @override
  String get endTimeoutDraw =>
      'Время вышло, у соперника нет матующего материала';

  @override
  String get endStalemate => 'Пат';

  @override
  String get endInsufficient => 'Недостаточно материала';

  @override
  String get endFiftyMoves => 'Правило 50 ходов';

  @override
  String get endRepetition => 'Троекратное повторение';

  @override
  String get endAgreement => 'Ничья по соглашению';

  @override
  String get endAborted => 'Отменена';

  @override
  String get boardLabel => 'Шахматная доска';

  @override
  String get promoteTo => 'Превратить пешку в';

  @override
  String get queen => 'Ферзь';

  @override
  String get rook => 'Ладья';

  @override
  String get bishop => 'Слон';

  @override
  String get knight => 'Конь';

  @override
  String get medalGold => 'Золотая медаль';

  @override
  String get medalSilver => 'Серебряная медаль';

  @override
  String get medalBronze => 'Бронзовая медаль';

  @override
  String get youWon => 'Вы выиграли';

  @override
  String get youLost => 'Вы проиграли';

  @override
  String get draw => 'Ничья';

  @override
  String get inProgress => 'Идёт';

  @override
  String get whiteWon => 'Белые выиграли';

  @override
  String get blackWon => 'Чёрные выиграли';

  @override
  String get rated => 'На рейтинг';

  @override
  String get casual => 'Без рейтинга';

  @override
  String get ratedHint => 'Результат изменит ваш рейтинг Эло.';

  @override
  String get flipBoard => 'Перевернуть доску';

  @override
  String get cancel => 'Отмена';

  @override
  String get resign => 'Сдаться';

  @override
  String get resignTitle => 'Сдать партию?';

  @override
  String get resignBody =>
      'Соперник победит; в рейтинговой партии ваш Эло снизится.';

  @override
  String get abort => 'Отменить';

  @override
  String get offerDraw => 'Ничья?';

  @override
  String get drawOffered => 'Предложено';

  @override
  String get drawOfferReceived => 'Соперник предлагает ничью.';

  @override
  String get accept => 'Принять';

  @override
  String get decline => 'Отклонить';

  @override
  String get rematch => 'Реванш';

  @override
  String get rematchSent => 'Запрос на реванш отправлен.';

  @override
  String get newGame => 'Новая партия';

  @override
  String newRating(String category, int rating) {
    return 'Ваш рейтинг ($category): $rating';
  }

  @override
  String get deletedPlayer => 'Удалённый аккаунт';

  @override
  String get firstMove => 'Первый ход: 30 с';

  @override
  String get noMovesYet => 'Ходов пока нет. Начинают белые.';

  @override
  String get watching => 'Вы наблюдаете';

  @override
  String get quickGame => 'Быстрая игра';

  @override
  String get quickGameHint =>
      'Выберите контроль и играйте с соперником вашего уровня.';

  @override
  String get searching => 'Ищем соперника…';

  @override
  String waitedSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ожидание: $count секунды',
      many: 'Ожидание: $count секунд',
      few: 'Ожидание: $count секунды',
      one: 'Ожидание: $count секунда',
    );
    return '$_temp0';
  }

  @override
  String get chessProfile => 'Шахматный профиль';

  @override
  String get recentGames => 'Последние партии';

  @override
  String get noGamesMine => 'Партий пока нет. Сыграйте первую.';

  @override
  String get noGamesTheirs => 'Партий пока нет. Пригласите на первую.';

  @override
  String get playNow => 'Играть';

  @override
  String get challenge => 'Пригласить';

  @override
  String get noFlag => 'Флаг не выбран';

  @override
  String get chooseFlag => 'Выберите флаг';

  @override
  String get chooseFlagHint =>
      'Он отображается рядом с вашим именем в рейтинге.';

  @override
  String get searchCountry => 'Поиск страны';

  @override
  String get flagSaved => 'Флаг сохранён.';

  @override
  String get pickFlagPrompt => 'Выберите флаг для рейтинга.';

  @override
  String get suspendedNotice => 'Шахматы для этого человека сейчас закрыты.';

  @override
  String get notPlayed => 'Не играл';

  @override
  String gamesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count партии',
      many: '$count партий',
      few: '$count партии',
      one: '$count партия',
    );
    return '$_temp0';
  }

  @override
  String rankShort(int rank) {
    return '$rank-е место';
  }

  @override
  String get leaderboard => 'Рейтинг';

  @override
  String leaderboardEmpty(int count) {
    return 'Сыграйте $count рейтинговых партий в этой категории, чтобы попасть в рейтинг.';
  }

  @override
  String record(int wins, int draws, int losses) {
    return '$winsВ · $drawsН · $lossesП';
  }

  @override
  String get seeAll => 'Смотреть все';

  @override
  String get invitations => 'Приглашения';

  @override
  String invitesYou(String what) {
    return 'Приглашает вас на партию: $what';
  }

  @override
  String wantsRematch(String what) {
    return 'Хочет реванш: $what';
  }

  @override
  String waitingFor(String what) {
    return 'Ждём ответа: $what';
  }

  @override
  String get withdraw => 'Отозвать';

  @override
  String get gameInProgress => 'У вас идёт партия';

  @override
  String get resume => 'Продолжить';

  @override
  String get challengeFriend => 'Пригласить друга';

  @override
  String get challengeSent =>
      'Приглашение отправлено. Партия начнётся, когда его примут.';

  @override
  String get challengeTitle => 'Пригласить на партию';

  @override
  String get changePerson => 'Изменить';

  @override
  String get searchPerson => 'Имя пользователя или имя';

  @override
  String get timeControl => 'Контроль времени';

  @override
  String get yourColor => 'Ваш цвет';

  @override
  String get sendChallenge => 'Отправить приглашение';

  @override
  String get teamMatch => 'Командный матч';

  @override
  String get teamMatches => 'Командные матчи';

  @override
  String get teamMatchesHint =>
      'Шахматные матчи ваших групп; результат меняет Эло группы.';

  @override
  String get noTeamMatches =>
      'Командных матчей пока нет. Пригласите другую группу от имени своей.';

  @override
  String get newTeamMatch => 'Устроить матч';

  @override
  String get newTeamMatchHint =>
      'Когда другая группа согласится, обе расставят игроков.';

  @override
  String get yourGroup => 'Ваша группа';

  @override
  String get opponentGroup => 'Группа-соперник';

  @override
  String get searchGroup => 'Название или имя группы';

  @override
  String get startsAt => 'Начало';

  @override
  String get sendTeamInvite => 'Пригласить группу';

  @override
  String get boards => 'Доски';

  @override
  String get boardsShort => 'досок';

  @override
  String boardsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count доски',
      many: '$count досок',
      few: '$count доски',
      one: '$count доска',
    );
    return '$_temp0';
  }

  @override
  String groupElo(int rating) {
    return 'Эло группы $rating';
  }

  @override
  String get versus => 'VS';

  @override
  String get versusShort => '–';

  @override
  String get teamInvited => 'Ждёт ответа';

  @override
  String get teamAccepted => 'Принят';

  @override
  String get teamDeclined => 'Отклонён';

  @override
  String get teamCanceled => 'Отменён';

  @override
  String get teamLive => 'Идёт';

  @override
  String get teamFinished => 'Завершён';

  @override
  String teamInviteReceived(String group) {
    return '$group приглашает вашу группу на командный матч.';
  }

  @override
  String get teamAcceptedDone => 'Матч принят. Теперь расставьте игроков.';

  @override
  String get teamDeclinedDone => 'Приглашение отклонено.';

  @override
  String get teamCanceledDone => 'Матч отменён.';

  @override
  String get callOff => 'Отменить матч';

  @override
  String get lineupHint => 'Пустая на старте доска засчитывается сопернику.';

  @override
  String get lineupSheetHint =>
      'Нажимайте на участников, чтобы расставить их по порядку; первая доска — для сильнейшего.';

  @override
  String editLineup(String group) {
    return 'Состав: $group';
  }

  @override
  String get saveLineup => 'Сохранить состав';

  @override
  String get emptyBoard => 'Пусто';

  @override
  String ratingGames(int rating, int games) {
    return 'Эло $rating · партий: $games';
  }

  @override
  String get groupsTab => 'Группы';

  @override
  String get groupLeaderboardEmpty =>
      'Пока ни одна группа не сыграла командный матч. Станьте первыми.';

  @override
  String get backToChess => 'К шахматам';

  @override
  String get arena => 'Турнир';

  @override
  String get tournaments => 'Турниры';

  @override
  String get tournamentsHint =>
      'Еженедельные и ежемесячные арены; тройка лучших получает медали.';

  @override
  String get weeklyArena => 'Еженедельная арена';

  @override
  String get monthlyArena => 'Ежемесячная арена';

  @override
  String get arenaRules =>
      'Арена: играйте сколько угодно партий до конца. Победа — 2 очка, ничья — 1; после двух побед подряд очки удваиваются, пока серия не прервётся. Партии, начатые до конца, засчитываются.';

  @override
  String get arenaLiveNow => 'Идёт сейчас';

  @override
  String get arenaUpcoming => 'Скоро';

  @override
  String get arenaFinished => 'Завершённые';

  @override
  String get registered => 'Вы записаны';

  @override
  String get arenaRegister => 'Записаться';

  @override
  String get arenaRegistered =>
      'Вы записаны. На старте придёт уведомление, и вас сразу подберут.';

  @override
  String get arenaJoin => 'Участвовать';

  @override
  String get arenaResume => 'Продолжить игру';

  @override
  String get arenaPause => 'Пауза';

  @override
  String get arenaWaiting =>
      'Ждём соперника: партия откроется сама, когда освободится игрок с близким счётом.';

  @override
  String get backToGame => 'Вернуться к партии';

  @override
  String get backToArena => 'К турниру';

  @override
  String get backToTeamMatch => 'К командному матчу';

  @override
  String arenaStartsIn(String time) {
    return 'Начало через $time';
  }

  @override
  String arenaEndsIn(String time) {
    return 'Осталось $time';
  }

  @override
  String get arenaLastGames => 'Время вышло, доигрываются последние партии';

  @override
  String arenaFinishedAt(String time) {
    return 'Завершён · $time';
  }

  @override
  String hoursMinutes(int hours, int minutes) {
    return '$hours ч $minutes мин';
  }

  @override
  String minutesLong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count минуты',
      many: '$count минут',
      few: '$count минуты',
      one: '$count минута',
    );
    return '$_temp0';
  }

  @override
  String playersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count игрока',
      many: '$count игроков',
      few: '$count игрока',
      one: '$count игрок',
    );
    return '$_temp0';
  }

  @override
  String myArenaScore(int points, int games) {
    return 'Очки: $points · партий: $games';
  }

  @override
  String get onFire => 'Серия: следующий результат — двойные очки';

  @override
  String get standings => 'Таблица';

  @override
  String get arenaEmpty => 'Пока никого нет. Будьте первым.';

  @override
  String performance(int value) {
    return 'Перформанс $value';
  }

  @override
  String get playingNow => 'играет';

  @override
  String get arenaMedals => 'Турнирные медали';

  @override
  String medalsSummary(int gold, int silver, int bronze) {
    return 'Медали: золото $gold, серебро $silver, бронза $bronze';
  }

  @override
  String get firstMoveTeam => 'Первый ход: 5 мин';

  @override
  String get games => 'Игры';

  @override
  String get gamesIntro =>
      'Играйте со своим сообществом: быстрые партии, турниры и матчи между группами.';

  @override
  String get chessCardText =>
      'Рейтинг Эло, еженедельные и ежемесячные турниры, командные матчи между группами и медали.';

  @override
  String get playChess => 'Играть в шахматы';

  @override
  String blitzRating(int rating) {
    return 'Блиц $rating';
  }

  @override
  String nextArena(String time) {
    return 'Следующий турнир: $time';
  }

  @override
  String invitesWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count приглашения ждут',
      many: '$count приглашений ждут',
      few: '$count приглашения ждут',
      one: '$count приглашение ждёт',
    );
    return '$_temp0';
  }

  @override
  String get playOnline => 'Играть онлайн';

  @override
  String findOpponent(String tc) {
    return 'Найти соперника · $tc';
  }

  @override
  String get challengeFriendHint => 'Выберите время и цвет';

  @override
  String get leaderboardHint => 'Рейтинг Эло и медали';

  @override
  String openTeamMatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count открытого матча',
      many: '$count открытых матчей',
      few: '$count открытых матча',
      one: '$count открытый матч',
    );
    return '$_temp0';
  }

  @override
  String get appearance => 'Доска и фигуры';

  @override
  String get boardTheme => 'Доска';

  @override
  String get pieceSet => 'Фигуры';

  @override
  String get boardWood => 'Дерево';

  @override
  String get boardGreen => 'Зелёная';

  @override
  String get boardBlue => 'Синяя';

  @override
  String get boardSlate => 'Серая';

  @override
  String get boardLilac => 'Сиреневая GWAY';

  @override
  String get piecesClassic => 'Классика';

  @override
  String get piecesCeltic => 'Кельтские';

  @override
  String get piecesSpatial => 'Космос';

  @override
  String get piecesFantasy => 'Фэнтези';

  @override
  String get piecesModern => 'Модерн';

  @override
  String get piecesWarm => 'Тёплые';

  @override
  String get firstPosition => 'Начало';

  @override
  String get previousMove => 'Предыдущий ход';

  @override
  String get nextMove => 'Следующий ход';

  @override
  String get lastPosition => 'Текущая позиция';

  @override
  String get backToLive => 'К текущей';

  @override
  String pointsShort(int points) {
    return '$points очк.';
  }

  @override
  String mindColorWord(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'red_m': 'красный',
      'red_f': 'красная',
      'red_n': 'красное',
      'blue_m': 'синий',
      'blue_f': 'синяя',
      'blue_n': 'синее',
      'green_m': 'зелёный',
      'green_f': 'зелёная',
      'green_n': 'зелёное',
      'yellow_m': 'жёлтый',
      'yellow_f': 'жёлтая',
      'yellow_n': 'жёлтое',
      'purple_m': 'фиолетовый',
      'purple_f': 'фиолетовая',
      'purple_n': 'фиолетовое',
      'orange_m': 'оранжевый',
      'orange_f': 'оранжевая',
      'orange_n': 'оранжевое',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String mindPatternWord(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'solid_m': 'сплошной',
      'solid_f': 'сплошная',
      'solid_n': 'сплошное',
      'striped_m': 'полосатый',
      'striped_f': 'полосатая',
      'striped_n': 'полосатое',
      'dotted_m': 'крапчатый',
      'dotted_f': 'крапчатая',
      'dotted_n': 'крапчатое',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String mindShapeWord(String shape) {
    String _temp0 = intl.Intl.selectLogic(shape, {
      'circle': 'круг',
      'square': 'квадрат',
      'triangle': 'треугольник',
      'star': 'звезда',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String mindShapeGender(String shape) {
    String _temp0 = intl.Intl.selectLogic(shape, {
      'circle': 'm',
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
  String get mindDuel => 'Дуэль разума';

  @override
  String get mindCardText =>
      'Живая дуэль: счёт, внимание, память и реакция. Рейтинг Эло, таблицы и медали.';

  @override
  String get mindPlay => 'Начать дуэль';

  @override
  String mindBestRating(int rating, int length) {
    return 'Эло $rating · вопросов: $length';
  }

  @override
  String mindQuestions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count вопроса',
      many: '$count вопросов',
      few: '$count вопроса',
      one: '$count вопрос',
    );
    return '$_temp0';
  }

  @override
  String get mindHowMany => 'Сколько вопросов?';

  @override
  String mindRatingAt(int count) {
    return 'Ваш рейтинг (вопросов: $count)';
  }

  @override
  String get mindFindOpponent => 'Найти соперника';

  @override
  String get mindSuspended => 'Сейчас вы не можете играть.';

  @override
  String get mindActive => 'У вас идёт дуэль';

  @override
  String get mindProfile => 'Профиль дуэлей';

  @override
  String get mindHowTo => 'Как играть';

  @override
  String get mindRecent => 'Последние дуэли';

  @override
  String get mindNoMatchesMine => 'Дуэлей пока нет. Найдите первого соперника.';

  @override
  String get mindNoMatchesTheirs => 'Дуэлей пока нет. Вызовите первым.';

  @override
  String mindLeaderboardEmpty(int count) {
    return 'Сыграйте рейтинговых дуэлей этой длины: $count, чтобы попасть в таблицу.';
  }

  @override
  String get mindChallengeTitle => 'Вызвать на дуэль';

  @override
  String get mindChallengeSent =>
      'Вызов отправлен. Дуэль начнётся, когда его примут.';

  @override
  String get mindKindMath => 'Счёт';

  @override
  String get mindKindAttention => 'Внимание';

  @override
  String get mindKindMemory => 'Память';

  @override
  String get mindKindReflex => 'Реакция';

  @override
  String get mindKindMathHint =>
      'Четыре действия с учётом порядка. Выберите верный ответ.';

  @override
  String get mindKindAttentionHint =>
      'Не смотрите на цвет текста — выберите описанную фигуру.';

  @override
  String get mindKindMemoryHint =>
      'Запомните цветные буквы и цифры по порядку и с цветом.';

  @override
  String get mindKindReflexHint =>
      'Нажмите на цель, как только она появится. Раньше времени или мимо — минус очки.';

  @override
  String get mindScoringHint =>
      'Верные и быстрые ответы приносят больше очков. Побеждает больший итог.';

  @override
  String get mindYou => 'Вы';

  @override
  String get mindOpponent => 'Соперник';

  @override
  String mindProgress(String who, int done, int total) {
    return '$who: $done/$total вопросов';
  }

  @override
  String mindQuestionOf(int n, int total) {
    return '$n/$total';
  }

  @override
  String get mindGetReady => 'Приготовьтесь';

  @override
  String get mindYouFinished => 'Вы закончили!';

  @override
  String mindOpponentAt(int done, int total) {
    return 'Соперник на $done/$total. Итог — когда он закончит.';
  }

  @override
  String get mindMathPrompt => 'Каков результат?';

  @override
  String get mindAttentionPrompt => 'Выберите описанную фигуру';

  @override
  String get mindMemoryLook => 'Запомните порядок и цвета';

  @override
  String get mindMemoryPick => 'Выберите в том же порядке и цвете';

  @override
  String mindCharLabel(String char, String color) {
    return '$color $char';
  }

  @override
  String get mindUndo => 'Отменить';

  @override
  String get mindReflexTarget => 'Цель';

  @override
  String get mindReflexWait => 'Ждите…';

  @override
  String get mindReflexTap => 'Жмите!';

  @override
  String mindRight(int points) {
    return 'Верно · +$points';
  }

  @override
  String mindPartly(int points) {
    return 'Частично верно · +$points';
  }

  @override
  String get mindWrong => 'Неверно';

  @override
  String mindWrongPenalty(int points) {
    return 'Неверно · −$points';
  }

  @override
  String mindTooEarly(int points) {
    return 'Слишком рано · −$points';
  }

  @override
  String get mindResignTitle => 'Сдаться?';

  @override
  String get mindResignBody =>
      'Победа достанется сопернику; в рейтинговой дуэли ваш Эло снизится.';

  @override
  String get mindFinished => 'Дуэль окончена';

  @override
  String get mindEndCompleted => 'Все вопросы отвечены';

  @override
  String get mindEndTime => 'Время вышло';

  @override
  String mindNewRating(int rating) {
    return 'Новый рейтинг $rating';
  }

  @override
  String get mindNewDuel => 'Новая дуэль';

  @override
  String get mindBackHome => 'К дуэлям';

  @override
  String get mindTeamMatches => 'Групповые дуэли';

  @override
  String get mindTeamMatchesHint =>
      'Дуэли ваших групп с другими; итог меняет дуэльный Эло группы.';

  @override
  String get mindNoTeamMatches =>
      'Групповых дуэлей пока нет. Вызовите другую группу от имени своей.';

  @override
  String get mindNewTeamMatch => 'Устроить групповую дуэль';

  @override
  String get mindNewTeamHint =>
      'Когда другая группа примет вызов, обе расставят игроков. В начале двое на каждом месте играют дуэль одновременно.';

  @override
  String get mindTeamMatch => 'Групповая дуэль';

  @override
  String get mindSeats => 'Места';

  @override
  String mindSeatsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count места',
      many: '$count мест',
      few: '$count места',
      one: '$count место',
    );
    return '$_temp0';
  }

  @override
  String get mindLineupHint =>
      'Пустое на старте место засчитывается сопернику. Первого вопроса ждут 5 минут.';

  @override
  String get mindGroupLeaderboardEmpty =>
      'Ни одна группа ещё не играла дуэль. Пусть ваша устроит первую.';
}
