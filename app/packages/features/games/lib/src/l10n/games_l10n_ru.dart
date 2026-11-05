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
}
