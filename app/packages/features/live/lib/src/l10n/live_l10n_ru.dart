// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'live_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class LiveL10nRu extends LiveL10n {
  LiveL10nRu([String locale = 'ru']) : super(locale);

  @override
  String get commentRate =>
      'Слишком много комментариев за короткое время. Подождите и повторите.';

  @override
  String get mutedListenOnly =>
      'Вас заглушили в этой группе — можно только слушать.';

  @override
  String get cannotComment => 'Сейчас нельзя комментировать этот эфир.';

  @override
  String get roleHost => 'Ведущий';

  @override
  String get roleSpeaker => 'Спикер';

  @override
  String get roleListener => 'Слушатель';

  @override
  String get startLive => 'Начать эфир';

  @override
  String hostedBy(String name) {
    return 'Ведёт $name';
  }

  @override
  String get join => 'Присоединиться';

  @override
  String upcomingAt(String date) {
    return 'Скоро · $date';
  }

  @override
  String get scheduledCanceled => 'Запланированный эфир отменён.';

  @override
  String get cancel => 'Отменить';

  @override
  String get start => 'Начать';

  @override
  String get reminderRemoved => 'Напоминание удалено.';

  @override
  String get reminderSet => 'Сообщим, когда эфир начнётся.';

  @override
  String get reminding => 'Напоминание включено';

  @override
  String get remind => 'Напомнить';

  @override
  String get schedule5min => 'Эфир можно запланировать минимум через 5 минут.';

  @override
  String get scheduled =>
      'Эфир запланирован. Участники могут включить напоминание.';

  @override
  String get liveBroadcast => 'Прямой эфир';

  @override
  String get liveIntro =>
      'Участники заходят в аудиокомнату; говорят те, кого вы пригласили на сцену.';

  @override
  String get title => 'Название';

  @override
  String get titleExample => 'Например: план воскресного похода';

  @override
  String get titleMin3 => 'Название — не менее 3 символов.';

  @override
  String get now => 'Сейчас';

  @override
  String get scheduleIt => 'Запланировать';

  @override
  String minutesLeft(int count) {
    return 'Осталось минут эфира в этом месяце: $count.';
  }

  @override
  String get minutesUsedUp =>
      'Время эфира на этот месяц закончилось. Повысьте тариф, чтобы получить больше.';

  @override
  String get startTheLive => 'Начать эфир';

  @override
  String get liveNow => 'Сейчас в эфире';

  @override
  String trayLabel(String group, String title) {
    return '$group в эфире: $title';
  }

  @override
  String youAreLive(String title) {
    return 'Вы в эфире: $title. Нажмите, чтобы вернуться.';
  }

  @override
  String get connecting => 'Подключение к эфиру…';

  @override
  String get inBroadcast => 'Вы в эфире · нажмите, чтобы вернуться';

  @override
  String get micMutedByMod => 'Ведущий выключил ваш микрофон';

  @override
  String get micOff => 'Выключить микрофон';

  @override
  String get micOn => 'Включить микрофон';

  @override
  String startsOn(String date) {
    return 'Эфир начнётся $date.';
  }

  @override
  String get ended => 'Эфир завершён.';

  @override
  String get notFound =>
      'Эфир не найден. Возможно, нужно быть участником группы.';

  @override
  String get goBack => 'Назад';

  @override
  String get onStageNow => 'Вы на сцене. Включите микрофон, чтобы говорить.';

  @override
  String get nowListener => 'Теперь вы слушатель.';

  @override
  String get leaveBroadcast => 'Покинуть эфир';

  @override
  String get leaveHostBody =>
      'Можно завершить эфир для всех. Если просто выйти, он закончится сам через 2 минуты.';

  @override
  String get justLeave => 'Просто выйти';

  @override
  String get endBroadcast => 'Завершить эфир';

  @override
  String get inviteToStage => 'Пригласить на сцену';

  @override
  String get removeFromStage => 'Убрать со сцены';

  @override
  String get muteMic => 'Выключить микрофон';

  @override
  String get unmuteMic => 'Включить микрофон';

  @override
  String get kick => 'Удалить из эфира';

  @override
  String kickBody(String name) {
    return '$name больше не сможет зайти в этот эфир.';
  }

  @override
  String get cancelAction => 'Отмена';

  @override
  String get remove => 'Удалить';

  @override
  String get raisedHands => 'Поднятые руки';

  @override
  String get commentDeleted => 'Комментарий удалён.';

  @override
  String get thanksForJoining => 'Эфир завершён. Спасибо, что были с нами.';

  @override
  String get youWereKicked => 'Вас удалили из этого эфира.';

  @override
  String get connectFailedShort => 'Не удалось подключиться к эфиру.';

  @override
  String handsRaised(int count) {
    return 'Подняли руку: $count';
  }

  @override
  String get onStage => 'На сцене';

  @override
  String listeners(int count) {
    return 'Слушатели · $count';
  }

  @override
  String get noListeners => 'Слушателей пока нет.';

  @override
  String get minimize => 'Свернуть и остаться в эфире';

  @override
  String peopleCount(int count) {
    return 'Человек: $count';
  }

  @override
  String get broadcastOptions => 'Действия с эфиром';

  @override
  String get endForAll => 'Завершить для всех';

  @override
  String get handRaised =>
      'Вы подняли руку. Ведущий может пригласить вас на сцену.';

  @override
  String get you => 'Вы';

  @override
  String get speaking => 'говорит';

  @override
  String get micOffState => 'микрофон выключен';

  @override
  String get handUp => 'поднял(а) руку';

  @override
  String get sendReaction => 'Отправить реакцию';

  @override
  String get leave => 'Выйти';

  @override
  String get leaveStage => 'Уйти со сцены';

  @override
  String get reactions => 'Реакции';

  @override
  String get comments => 'Комментарии';

  @override
  String get raiseHand => 'Поднять руку';

  @override
  String get lowerHand => 'Опустить руку';

  @override
  String get report => 'Пожаловаться';

  @override
  String get deleteComment => 'Удалить комментарий';

  @override
  String get firstComment => 'Напишите первый комментарий.';

  @override
  String get writeComment => 'Напишите комментарий…';

  @override
  String get send => 'Отправить';

  @override
  String get connectFailed =>
      'Не удалось подключиться к эфиру. Проверьте соединение и повторите попытку.';

  @override
  String get participant => 'Участник';

  @override
  String get micNeedsManager => 'Включить микрофон может только ведущий эфира.';

  @override
  String get micFailed => 'Не удалось включить микрофон. Проверьте разрешение.';
}
