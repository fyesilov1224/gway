// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'live_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class LiveL10nUk extends LiveL10n {
  LiveL10nUk([String locale = 'uk']) : super(locale);

  @override
  String get commentRate =>
      'Забагато коментарів за короткий час. Зачекайте й спробуйте ще раз.';

  @override
  String get mutedListenOnly =>
      'Вас заглушено в цій групі — можна лише слухати.';

  @override
  String get cannotComment => 'Зараз не можна коментувати цю трансляцію.';

  @override
  String get roleHost => 'Ведучий';

  @override
  String get roleSpeaker => 'Спікер';

  @override
  String get roleListener => 'Слухач';

  @override
  String get startLive => 'Почати трансляцію';

  @override
  String hostedBy(String name) {
    return 'Веде $name';
  }

  @override
  String get join => 'Приєднатися';

  @override
  String upcomingAt(String date) {
    return 'Незабаром · $date';
  }

  @override
  String get scheduledCanceled => 'Заплановану трансляцію скасовано.';

  @override
  String get cancel => 'Скасувати';

  @override
  String get start => 'Почати';

  @override
  String get reminderRemoved => 'Нагадування видалено.';

  @override
  String get reminderSet => 'Повідомимо, коли трансляція почнеться.';

  @override
  String get reminding => 'Нагадування ввімкнено';

  @override
  String get remind => 'Нагадати';

  @override
  String get schedule5min =>
      'Трансляцію можна запланувати щонайменше через 5 хвилин.';

  @override
  String get scheduled =>
      'Трансляцію заплановано. Учасники можуть увімкнути нагадування.';

  @override
  String get liveBroadcast => 'Трансляція';

  @override
  String get liveIntro =>
      'Учасники заходять в аудіокімнату; говорять ті, кого ви запросили на сцену.';

  @override
  String get title => 'Назва';

  @override
  String get titleExample => 'Наприклад: план недільного походу';

  @override
  String get titleMin3 => 'Назва — щонайменше 3 символи.';

  @override
  String get now => 'Зараз';

  @override
  String get scheduleIt => 'Запланувати';

  @override
  String minutesLeft(int count) {
    return 'Залишилося хвилин трансляцій цього місяця: $count.';
  }

  @override
  String get minutesUsedUp =>
      'Час трансляцій на цей місяць закінчився. Підвищте тариф, щоб отримати більше.';

  @override
  String get startTheLive => 'Почати трансляцію';

  @override
  String get liveNow => 'Зараз в ефірі';

  @override
  String trayLabel(String group, String title) {
    return '$group в ефірі: $title';
  }

  @override
  String youAreLive(String title) {
    return 'Ви в ефірі: $title. Натисніть, щоб повернутися.';
  }

  @override
  String get connecting => 'Підключення до трансляції…';

  @override
  String get inBroadcast => 'Ви в ефірі · натисніть, щоб повернутися';

  @override
  String get micMutedByMod => 'Ведучий вимкнув ваш мікрофон';

  @override
  String get micOff => 'Вимкнути мікрофон';

  @override
  String get micOn => 'Увімкнути мікрофон';

  @override
  String startsOn(String date) {
    return 'Трансляція почнеться $date.';
  }

  @override
  String get ended => 'Трансляцію завершено.';

  @override
  String get notFound =>
      'Трансляцію не знайдено. Можливо, треба бути учасником групи.';

  @override
  String get goBack => 'Назад';

  @override
  String get onStageNow => 'Ви на сцені. Увімкніть мікрофон, щоб говорити.';

  @override
  String get nowListener => 'Тепер ви слухач.';

  @override
  String get leaveBroadcast => 'Залишити трансляцію';

  @override
  String get leaveHostBody =>
      'Можна завершити трансляцію для всіх. Якщо просто вийти, вона завершиться сама за 2 хвилини.';

  @override
  String get justLeave => 'Просто вийти';

  @override
  String get endBroadcast => 'Завершити трансляцію';

  @override
  String get inviteToStage => 'Запросити на сцену';

  @override
  String get removeFromStage => 'Прибрати зі сцени';

  @override
  String get muteMic => 'Вимкнути мікрофон';

  @override
  String get unmuteMic => 'Увімкнути мікрофон';

  @override
  String get kick => 'Видалити з трансляції';

  @override
  String kickBody(String name) {
    return '$name більше не зможе зайти на цю трансляцію.';
  }

  @override
  String get cancelAction => 'Скасувати';

  @override
  String get remove => 'Видалити';

  @override
  String get raisedHands => 'Підняті руки';

  @override
  String get commentDeleted => 'Коментар видалено.';

  @override
  String get thanksForJoining =>
      'Трансляцію завершено. Дякуємо, що були з нами.';

  @override
  String get youWereKicked => 'Вас видалили з цієї трансляції.';

  @override
  String get connectFailedShort => 'Не вдалося підключитися до трансляції.';

  @override
  String handsRaised(int count) {
    return 'Підняли руку: $count';
  }

  @override
  String get onStage => 'На сцені';

  @override
  String listeners(int count) {
    return 'Слухачі · $count';
  }

  @override
  String get noListeners => 'Слухачів поки немає.';

  @override
  String get minimize => 'Згорнути й залишитися в ефірі';

  @override
  String peopleCount(int count) {
    return 'Людей: $count';
  }

  @override
  String get broadcastOptions => 'Дії з трансляцією';

  @override
  String get endForAll => 'Завершити для всіх';

  @override
  String get handRaised =>
      'Ви підняли руку. Ведучий може запросити вас на сцену.';

  @override
  String get you => 'Ви';

  @override
  String get speaking => 'говорить';

  @override
  String get micOffState => 'мікрофон вимкнено';

  @override
  String get handUp => 'підняв(-ла) руку';

  @override
  String get sendReaction => 'Надіслати реакцію';

  @override
  String get leave => 'Вийти';

  @override
  String get leaveStage => 'Піти зі сцени';

  @override
  String get reactions => 'Реакції';

  @override
  String get comments => 'Коментарі';

  @override
  String get raiseHand => 'Підняти руку';

  @override
  String get lowerHand => 'Опустити руку';

  @override
  String get report => 'Поскаржитися';

  @override
  String get deleteComment => 'Видалити коментар';

  @override
  String get firstComment => 'Напишіть перший коментар.';

  @override
  String get writeComment => 'Напишіть коментар…';

  @override
  String get send => 'Надіслати';

  @override
  String get connectFailed =>
      'Не вдалося підключитися до трансляції. Перевірте з’єднання й спробуйте ще раз.';

  @override
  String get participant => 'Учасник';

  @override
  String get micNeedsManager =>
      'Увімкнути мікрофон може лише ведучий трансляції.';

  @override
  String get micFailed => 'Не вдалося ввімкнути мікрофон. Перевірте дозвіл.';

  @override
  String get connectionLost =>
      'Зв’язок з ефіром перервався. Торкніться, щоб перепідключитися.';

  @override
  String get micAfterEncryption =>
      'Встановлюється захищене з’єднання; мікрофон увімкнеться за мить.';

  @override
  String get encrypting => 'Встановлюється захищене з’єднання…';

  @override
  String get verifying => 'Перевірка шифрування…';

  @override
  String get liveSecure => 'Захищений ефір';

  @override
  String get liveSecureDetail =>
      'Наскрізне шифрування. Усі в кімнаті мають один ключ; ніхто, навіть сервер, не може підслухати.';

  @override
  String get liveCheckFailed =>
      'Шифрування не підтверджено: не всі в кімнаті мають один ключ. Вийдіть з ефіру й увійдіть знову.';

  @override
  String get liveUnconfirmed =>
      'Хтось на сцені має стару версію застосунку; його звук не можна зашифрувати, тому він не відтворюється.';

  @override
  String get peerUnencrypted =>
      'Спікер зі старою версією надсилає незашифрований звук, він не відтворюється. Йому треба оновити застосунок.';

  @override
  String get e2ee => 'Наскрізне шифрування';

  @override
  String get showSecurityCode => 'Показати код безпеки';

  @override
  String get codeMatchHint => 'Цей код однаковий на екранах усіх у кімнаті.';

  @override
  String e2eeCode(String code) {
    return 'Наскрізне шифрування. Код безпеки $code';
  }

  @override
  String get liveOngoingTitle => 'Ви в прямому ефірі';

  @override
  String get liveOngoingText =>
      'Наскрізне шифрування. Торкніться, щоб повернутися.';
}
