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
}
