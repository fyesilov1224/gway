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
  String leaderboardEmpty(int count) {
    return 'Зіграйте $count рейтингових партій у цій категорії, щоб потрапити до рейтингу.';
  }

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
}
