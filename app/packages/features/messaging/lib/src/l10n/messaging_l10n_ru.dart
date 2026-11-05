// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'messaging_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class MessagingL10nRu extends MessagingL10n {
  MessagingL10nRu([String locale = 'ru']) : super(locale);

  @override
  String get groupInvalid =>
      'Запрос можно отправить только в группу, где вы состоите.';

  @override
  String get permissionExists => 'Запрос уже получен, или доступ уже открыт.';

  @override
  String get permissionCooldown =>
      'Новый запрос можно отправить через 7 дней после решения.';

  @override
  String noteTooLong(int max) {
    return 'Заметка — до $max символов.';
  }

  @override
  String get requestForbidden => 'Сейчас запрос отправить нельзя.';

  @override
  String get unsupportedImage =>
      'Этот тип файла не поддерживается. Выберите JPEG, PNG или WebP.';

  @override
  String get voiceCallHandle => 'Голосовой звонок GWAY';

  @override
  String get incomingCalls => 'Входящие звонки';

  @override
  String get missedCalls => 'Пропущенные звонки';

  @override
  String get answer => 'Ответить';

  @override
  String get decline => 'Отклонить';

  @override
  String get noAnswer => 'Нет ответа';

  @override
  String get missedCall => 'Пропущенный звонок';

  @override
  String get callDeclined => 'Звонок отклонён';

  @override
  String get youDeclined => 'Вы отклонили звонок';

  @override
  String get callNotAllowed => 'Звонок больше невозможен';

  @override
  String get callCanceled => 'Звонок отменён';

  @override
  String get timeLimit => '60 минут истекли — звонок завершён';

  @override
  String get endedNotAllowed =>
      'Звонок завершён: голосовые звонки больше недоступны';

  @override
  String get callEnded => 'Звонок завершён';

  @override
  String get messageDeleted => 'Сообщение удалено';

  @override
  String get photo => 'Фото';

  @override
  String get tonightTable => 'Столик на сегодня';

  @override
  String get blockRequestPending => 'Сначала примите запрос на переписку.';

  @override
  String get blockDeclined => 'Этот человек не принял ваш запрос.';

  @override
  String get blockMuted =>
      'Вас заглушили в этой группе — писать сейчас нельзя.';

  @override
  String get blockAdminsOnly => 'В этом чате пишут только администраторы.';

  @override
  String get blockTableClosed => 'Столик закрыт: читать можно, писать нельзя.';

  @override
  String get blockBlocked => 'Писать нельзя из-за блокировки.';

  @override
  String get blockMatchEnded => 'Чат закрыт, потому что пара распалась.';

  @override
  String get blockMatchLocked =>
      'Чтобы написать паре, нужен тариф «Чат пары». Читать сообщения можно бесплатно.';

  @override
  String get blockTeammateLocked =>
      'Чтобы написать напарнику, нужен тариф «Напарник». Читать бесплатно.';

  @override
  String get blockNotAllowed =>
      'Личные сообщения теперь только для пар и напарников. Старые сообщения можно читать.';

  @override
  String get blockOther => 'Сейчас писать в этот чат нельзя.';

  @override
  String get hiddenUser => 'Пользователь GWAY';

  @override
  String get voiceCalls => 'Голосовые звонки';

  @override
  String get voiceCallsHeadline => 'Говорите голосом с парами и напарниками';

  @override
  String voiceCallsIntro(int minutes) {
    return 'Голосовые звонки позволяют звонить парам и напарникам из личного чата. Они доступны не всем: вы запрашиваете их в своей группе, а владелец или администратор включает. Звонки не записываются и не прослушиваются; звонок длится до $minutes минут.';
  }

  @override
  String get status => 'Статус';

  @override
  String get notRequested => 'Не запрошено';

  @override
  String get underReview => 'На рассмотрении';

  @override
  String get statusOn => 'Включено';

  @override
  String get statusOff => 'Выключено';

  @override
  String get notRequestedYet => 'Вы ещё не отправляли запрос.';

  @override
  String requestedFrom(String group) {
    return 'Запрос получили администраторы «$group». Вы получите уведомление о решении.';
  }

  @override
  String get requestedFromGroup =>
      'Запрос получили администраторы группы. Вы получите уведомление о решении.';

  @override
  String activeFrom(String group) {
    return 'Звонки включены ($group). Звоните парам и напарникам через значок телефона вверху чата; у собеседника тоже должен быть доступ.';
  }

  @override
  String get active =>
      'Звонки включены. Звоните парам и напарникам через значок телефона вверху чата; у собеседника тоже должен быть доступ.';

  @override
  String get declined => 'Запрос пока не одобрен.';

  @override
  String get revokedLeftGroup =>
      'Звонки отключены: вы покинули группу, которая их выдала. Можно запросить снова в другой группе.';

  @override
  String get revoked => 'Звонки отключены.';

  @override
  String reasonLine(String reason) {
    return 'Причина: $reason';
  }

  @override
  String yourNote(String note) {
    return 'Ваша заметка: $note';
  }

  @override
  String waitUntil(String date) {
    return 'Повторный запрос — после $date.';
  }

  @override
  String get requestSent => 'Запрос отправлен.';

  @override
  String get joinGroupFirst =>
      'Звонки включают владельцы и администраторы групп. Сначала вступите в группу.';

  @override
  String get requestToGroup => 'Группа для запроса';

  @override
  String get noteOptional => 'Заметка (необязательно)';

  @override
  String get noteHint => 'Кратко объясните, зачем вам звонки.';

  @override
  String get request => 'Запросить';

  @override
  String get lockScreenCalls => 'Звонки на экране блокировки';

  @override
  String get lockScreenHint =>
      'Разрешите GWAY показывать звонок на весь экран, когда телефон заблокирован.';

  @override
  String get allow => 'Разрешить';

  @override
  String get callInfoFailed =>
      'Не удалось загрузить звонок. Проверьте соединение.';

  @override
  String get tapEndToHangUp => 'Нажмите «Завершить», чтобы закончить.';

  @override
  String get callNotFound => 'Звонок не найден.';

  @override
  String get close => 'Закрыть';

  @override
  String callLimitNote(int minutes) {
    return 'Звонок длится до $minutes минут и не записывается.';
  }

  @override
  String get audioFailed =>
      'Не удалось подключить звук. Проверьте соединение и повторите.';

  @override
  String get reconnect => 'Подключиться снова';

  @override
  String get incoming => 'звонит вам…';

  @override
  String get calling => 'Вызов…';

  @override
  String get connecting => 'Подключение…';

  @override
  String get answerCall => 'Ответить';

  @override
  String get mute => 'Выключить звук';

  @override
  String get unmute => 'Включить звук';

  @override
  String get end => 'Завершить';

  @override
  String get speaker => 'Динамик';

  @override
  String get peerUnencrypted =>
      'У собеседника старая версия: звук не зашифрован и не воспроизводится. Попросите обновить приложение.';

  @override
  String get encrypting => 'Устанавливается защищённое соединение…';

  @override
  String e2eeCode(String code) {
    return 'Сквозное шифрование. Код безопасности $code';
  }

  @override
  String get e2ee => 'Сквозное шифрование';

  @override
  String get codeMatchHint =>
      'Если код совпадает с кодом у собеседника, разговор никто не подслушает.';

  @override
  String get micFailed => 'Не удалось включить микрофон. Проверьте разрешение.';

  @override
  String get chatNotFound => 'Чат не найден или больше вам недоступен.';

  @override
  String get backToMessages => 'Вернуться к сообщениям';

  @override
  String get cantCallNow => 'Сейчас позвонить нельзя.';

  @override
  String get voiceCall => 'Голосовой звонок';

  @override
  String get groupChatAdminsOnly => 'Чат группы · пишут только администраторы';

  @override
  String get groupChat => 'Чат группы';

  @override
  String smallTableMembers(int count) {
    return 'Столик · человек: $count';
  }

  @override
  String get adminsOnlyOn =>
      'Теперь в этот чат пишут только владелец и администраторы.';

  @override
  String get adminsOnlyOff => 'Теперь в этот чат могут писать все участники.';

  @override
  String get chatSettings => 'Настройки чата';

  @override
  String get adminsOnlyToggle => 'Пишут только администраторы';

  @override
  String get sendingPhoto => '📷 Отправка фото…';

  @override
  String get requestPendingNote =>
      'Запрос отправлен. Пока его не примут, не видно, прочитан ли он.';

  @override
  String get groupChatEmpty =>
      'В чате группы пока нет сообщений. Напишите первым.';

  @override
  String get chatEmpty => 'Сообщений пока нет. Напишите первым.';

  @override
  String get startWriting => 'Начать писать';

  @override
  String get sending => 'Отправка…';

  @override
  String get seen => 'Просмотрено';

  @override
  String get sent => 'Отправлено';

  @override
  String get seePackage => 'Посмотреть тариф';

  @override
  String get today => 'Сегодня';

  @override
  String get messageRemoved => 'Сообщение удалено модератором.';

  @override
  String get thisMessageDeleted => 'Это сообщение удалено.';

  @override
  String get messageOptions => 'Действия с сообщением';

  @override
  String profileOf(String name) {
    return 'Профиль: $name';
  }

  @override
  String get you => 'Вы';

  @override
  String get copy => 'Копировать';

  @override
  String get copied => 'Сообщение скопировано.';

  @override
  String get deleteForAll => 'Удалить у всех';

  @override
  String get report => 'Пожаловаться';

  @override
  String get deleteForAllTitle => 'Удалить сообщение у всех?';

  @override
  String get deleteForAllBody =>
      'Все увидят «Это сообщение удалено». Отменить нельзя.';

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get requestDeleted => 'Запрос удалён.';

  @override
  String wantsToMessage(String name) {
    return '$name хочет вам написать. Если примете, сможете переписываться, и собеседник увидит, что вы прочитали.';
  }

  @override
  String get accept => 'Принять';

  @override
  String get removePhoto => 'Убрать фото';

  @override
  String get addPhoto => 'Добавить фото';

  @override
  String get writeMessage => 'Напишите сообщение';

  @override
  String get send => 'Отправить';

  @override
  String get messages => 'Сообщения';

  @override
  String get chats => 'Чаты';

  @override
  String get requests => 'Запросы';

  @override
  String requestsCount(int count) {
    return 'Запросы ($count)';
  }

  @override
  String get noChats => 'Чатов пока нет. Можно писать парам и напарникам.';

  @override
  String get findPeople => 'Найти людей';

  @override
  String get oldRequestsNote =>
      'Старые запросы остаются здесь. Личные сообщения теперь только для пар и напарников — новых запросов не будет.';

  @override
  String get noRequests => 'Запросов нет.';

  @override
  String get backToChats => 'Вернуться к чатам';

  @override
  String get callRequests => 'Запросы на звонки';

  @override
  String noPendingWithActive(int count) {
    return 'Запросов нет · активных: $count';
  }

  @override
  String pendingCount(int count) {
    return 'Ждут ответа: $count';
  }

  @override
  String get pending => 'Ожидают';

  @override
  String get activeTab => 'Активные';

  @override
  String get requestsOwnersOnly =>
      'Запросы видят только владелец и администраторы.';

  @override
  String get goBack => 'Назад';

  @override
  String noPendingFor(String group) {
    return 'Запросов нет. Запросы участников «$group» появятся здесь.';
  }

  @override
  String get noActive => 'Эта группа не выдавала доступ к звонкам.';

  @override
  String get refresh => 'Обновить';

  @override
  String get grantHint =>
      'С этим доступом человек может звонить всем своим парам и напарникам. Звонки не записываются; при выходе из группы доступ закрывается.';

  @override
  String get granted => 'Звонки включены.';

  @override
  String get turnedOff => 'Звонки отключены.';

  @override
  String theirNote(String note) {
    return 'Заметка: $note';
  }

  @override
  String get turnOff => 'Отключить';

  @override
  String get turnOn => 'Включить';

  @override
  String get rankOnlyGrant =>
      'Ранг равен вашему или выше — запрос можно только одобрить.';

  @override
  String get rankCannotRevoke =>
      'Ранг равен вашему или выше — отключить нельзя.';

  @override
  String get declineRequest => 'Отклонить запрос';

  @override
  String get turnOffCalls => 'Отключить звонки';

  @override
  String get declineHint =>
      'Человек увидит причину и сможет запросить снова через 7 дней.';

  @override
  String get revokeHint =>
      'Текущий звонок сразу завершится. Человек увидит причину и сможет запросить снова через 7 дней.';

  @override
  String get reason => 'Причина';

  @override
  String get reasonMin3 => 'Причина — не менее 3 символов.';

  @override
  String get yesterday => 'Вчера';

  @override
  String get sendMessage => 'Написать';

  @override
  String get groupChatMembersOnly => 'Чат группы видят только её участники.';

  @override
  String get callVerifying => 'Проверка шифрования…';

  @override
  String get callSecure => 'Защищённый звонок';

  @override
  String get callSecureDetail =>
      'Сквозное шифрование. Коды безопасности обоих телефонов совпали, посторонних нет.';

  @override
  String get callCheckFailed =>
      'Шифрование не подтверждено: коды безопасности телефонов не совпадают. Завершите звонок и позвоните снова.';

  @override
  String get showSecurityCode => 'Показать код безопасности';

  @override
  String get callOngoingTitle => 'Идёт голосовой звонок';

  @override
  String get callOngoingText =>
      'Сквозное шифрование. Нажмите, чтобы вернуться.';
}
