// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'messaging_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class MessagingL10nUk extends MessagingL10n {
  MessagingL10nUk([String locale = 'uk']) : super(locale);

  @override
  String get groupInvalid =>
      'Запит можна надіслати лише до групи, де ви є учасником.';

  @override
  String get permissionExists => 'Запит уже отримано, або доступ уже відкрито.';

  @override
  String get permissionCooldown =>
      'Новий запит можна надіслати через 7 днів після рішення.';

  @override
  String noteTooLong(int max) {
    return 'Нотатка — до $max символів.';
  }

  @override
  String get requestForbidden => 'Зараз запит надіслати не можна.';

  @override
  String get unsupportedImage =>
      'Цей тип файлу не підтримується. Виберіть JPEG, PNG або WebP.';

  @override
  String get voiceCallHandle => 'Голосовий дзвінок GWAY';

  @override
  String get incomingCalls => 'Вхідні дзвінки';

  @override
  String get missedCalls => 'Пропущені дзвінки';

  @override
  String get answer => 'Відповісти';

  @override
  String get decline => 'Відхилити';

  @override
  String get noAnswer => 'Немає відповіді';

  @override
  String get missedCall => 'Пропущений дзвінок';

  @override
  String get callDeclined => 'Дзвінок відхилено';

  @override
  String get youDeclined => 'Ви відхилили дзвінок';

  @override
  String get callNotAllowed => 'Дзвінок більше неможливий';

  @override
  String get callCanceled => 'Дзвінок скасовано';

  @override
  String get timeLimit => '60 хвилин минуло — дзвінок завершено';

  @override
  String get endedNotAllowed =>
      'Дзвінок завершено: голосові дзвінки більше недоступні';

  @override
  String get callEnded => 'Дзвінок завершено';

  @override
  String get messageDeleted => 'Повідомлення видалено';

  @override
  String get photo => 'Фото';

  @override
  String get tonightTable => 'Столик на сьогодні';

  @override
  String get blockRequestPending => 'Спершу прийміть запит на листування.';

  @override
  String get blockDeclined => 'Ця людина не прийняла ваш запит.';

  @override
  String get blockMuted => 'Вас заглушено в цій групі — писати зараз не можна.';

  @override
  String get blockAdminsOnly => 'У цьому чаті пишуть лише адміністратори.';

  @override
  String get blockTableClosed =>
      'Столик закрито: читати можна, писати не можна.';

  @override
  String get blockBlocked => 'Писати не можна через блокування.';

  @override
  String get blockMatchEnded => 'Чат закрито, бо пару скасовано.';

  @override
  String get blockMatchLocked =>
      'Щоб написати парі, потрібен тариф «Чат пари». Читати повідомлення безкоштовно.';

  @override
  String get blockTeammateLocked =>
      'Щоб написати напарнику, потрібен тариф «Напарник». Читати безкоштовно.';

  @override
  String get blockNotAllowed =>
      'Особисті повідомлення тепер лише для пар і напарників. Старі повідомлення можна читати.';

  @override
  String get blockOther => 'Зараз писати в цей чат не можна.';

  @override
  String get hiddenUser => 'Користувач GWAY';

  @override
  String get voiceCalls => 'Голосові дзвінки';

  @override
  String get voiceCallsHeadline => 'Говоріть голосом із парами й напарниками';

  @override
  String voiceCallsIntro(int minutes) {
    return 'Голосові дзвінки дають змогу телефонувати парам і напарникам з особистого чату. Вони доступні не всім: ви запитуєте їх у своїй групі, а власник чи адміністратор вмикає. Дзвінки не записуються й не прослуховуються; дзвінок триває до $minutes хвилин.';
  }

  @override
  String get status => 'Статус';

  @override
  String get notRequested => 'Не запитано';

  @override
  String get underReview => 'На розгляді';

  @override
  String get statusOn => 'Увімкнено';

  @override
  String get statusOff => 'Вимкнено';

  @override
  String get notRequestedYet => 'Ви ще не надсилали запит.';

  @override
  String requestedFrom(String group) {
    return 'Запит отримали адміністратори «$group». Ви отримаєте сповіщення про рішення.';
  }

  @override
  String get requestedFromGroup =>
      'Запит отримали адміністратори групи. Ви отримаєте сповіщення про рішення.';

  @override
  String activeFrom(String group) {
    return 'Дзвінки ввімкнено ($group). Телефонуйте парам і напарникам через значок телефону вгорі чату; у співрозмовника теж має бути доступ.';
  }

  @override
  String get active =>
      'Дзвінки ввімкнено. Телефонуйте парам і напарникам через значок телефону вгорі чату; у співрозмовника теж має бути доступ.';

  @override
  String get declined => 'Запит поки не схвалено.';

  @override
  String get revokedLeftGroup =>
      'Дзвінки вимкнено: ви залишили групу, що їх надала. Можна запитати знову в іншій групі.';

  @override
  String get revoked => 'Дзвінки вимкнено.';

  @override
  String reasonLine(String reason) {
    return 'Причина: $reason';
  }

  @override
  String yourNote(String note) {
    return 'Ваша нотатка: $note';
  }

  @override
  String waitUntil(String date) {
    return 'Повторний запит — після $date.';
  }

  @override
  String get requestSent => 'Запит надіслано.';

  @override
  String get joinGroupFirst =>
      'Дзвінки вмикають власники й адміністратори груп. Спершу вступіть до групи.';

  @override
  String get requestToGroup => 'Група для запиту';

  @override
  String get noteOptional => 'Нотатка (необов’язково)';

  @override
  String get noteHint => 'Коротко поясніть, навіщо вам дзвінки.';

  @override
  String get request => 'Запитати';

  @override
  String get lockScreenCalls => 'Дзвінки на екрані блокування';

  @override
  String get lockScreenHint =>
      'Дозвольте GWAY показувати дзвінок на весь екран, коли телефон заблоковано.';

  @override
  String get allow => 'Дозволити';

  @override
  String get callInfoFailed =>
      'Не вдалося завантажити дзвінок. Перевірте з’єднання.';

  @override
  String get tapEndToHangUp => 'Натисніть «Завершити», щоб закінчити.';

  @override
  String get callNotFound => 'Дзвінок не знайдено.';

  @override
  String get close => 'Закрити';

  @override
  String callLimitNote(int minutes) {
    return 'Дзвінок триває до $minutes хвилин і не записується.';
  }

  @override
  String get audioFailed =>
      'Не вдалося підключити звук. Перевірте з’єднання й спробуйте ще раз.';

  @override
  String get reconnect => 'Підключитися знову';

  @override
  String get incoming => 'телефонує вам…';

  @override
  String get calling => 'Виклик…';

  @override
  String get connecting => 'Підключення…';

  @override
  String get answerCall => 'Відповісти';

  @override
  String get mute => 'Вимкнути звук';

  @override
  String get unmute => 'Увімкнути звук';

  @override
  String get end => 'Завершити';

  @override
  String get speaker => 'Динамік';

  @override
  String get peerUnencrypted =>
      'У співрозмовника стара версія: звук не зашифровано, тож він не відтворюється. Попросіть оновити застосунок.';

  @override
  String get encrypting => 'Встановлюється захищене з’єднання…';

  @override
  String e2eeCode(String code) {
    return 'Наскрізне шифрування. Код безпеки $code';
  }

  @override
  String get e2ee => 'Наскрізне шифрування';

  @override
  String get codeMatchHint =>
      'Якщо код збігається з кодом у співрозмовника, розмову ніхто не підслухає.';

  @override
  String get micFailed => 'Не вдалося ввімкнути мікрофон. Перевірте дозвіл.';

  @override
  String get chatNotFound => 'Чат не знайдено або він більше вам недоступний.';

  @override
  String get backToMessages => 'Повернутися до повідомлень';

  @override
  String get cantCallNow => 'Зараз зателефонувати не можна.';

  @override
  String get voiceCall => 'Голосовий дзвінок';

  @override
  String get groupChatAdminsOnly => 'Чат групи · пишуть лише адміністратори';

  @override
  String get groupChat => 'Чат групи';

  @override
  String smallTableMembers(int count) {
    return 'Столик · людей: $count';
  }

  @override
  String get adminsOnlyOn =>
      'Тепер у цей чат пишуть лише власник і адміністратори.';

  @override
  String get adminsOnlyOff => 'Тепер у цей чат можуть писати всі учасники.';

  @override
  String get chatSettings => 'Налаштування чату';

  @override
  String get adminsOnlyToggle => 'Пишуть лише адміністратори';

  @override
  String get sendingPhoto => '📷 Надсилання фото…';

  @override
  String get requestPendingNote =>
      'Запит надіслано. Поки його не приймуть, не видно, чи прочитано.';

  @override
  String get groupChatEmpty =>
      'У чаті групи ще немає повідомлень. Напишіть першим.';

  @override
  String get chatEmpty => 'Повідомлень поки немає. Напишіть першим.';

  @override
  String get startWriting => 'Почати писати';

  @override
  String get sending => 'Надсилання…';

  @override
  String get seen => 'Переглянуто';

  @override
  String get sent => 'Надіслано';

  @override
  String get seePackage => 'Переглянути тариф';

  @override
  String get today => 'Сьогодні';

  @override
  String get messageRemoved => 'Повідомлення видалено модератором.';

  @override
  String get thisMessageDeleted => 'Це повідомлення видалено.';

  @override
  String get messageOptions => 'Дії з повідомленням';

  @override
  String profileOf(String name) {
    return 'Профіль: $name';
  }

  @override
  String get you => 'Ви';

  @override
  String get copy => 'Копіювати';

  @override
  String get copied => 'Повідомлення скопійовано.';

  @override
  String get deleteForAll => 'Видалити для всіх';

  @override
  String get report => 'Поскаржитися';

  @override
  String get deleteForAllTitle => 'Видалити повідомлення для всіх?';

  @override
  String get deleteForAllBody =>
      'Усі побачать «Це повідомлення видалено». Скасувати не можна.';

  @override
  String get cancel => 'Скасувати';

  @override
  String get delete => 'Видалити';

  @override
  String get requestDeleted => 'Запит видалено.';

  @override
  String wantsToMessage(String name) {
    return '$name хоче вам написати. Якщо приймете, зможете листуватися, і співрозмовник бачитиме, що ви прочитали.';
  }

  @override
  String get accept => 'Прийняти';

  @override
  String get removePhoto => 'Прибрати фото';

  @override
  String get addPhoto => 'Додати фото';

  @override
  String get writeMessage => 'Напишіть повідомлення';

  @override
  String get send => 'Надіслати';

  @override
  String get messages => 'Повідомлення';

  @override
  String get chats => 'Чати';

  @override
  String get requests => 'Запити';

  @override
  String requestsCount(int count) {
    return 'Запити ($count)';
  }

  @override
  String get noChats => 'Чатів поки немає. Можна писати парам і напарникам.';

  @override
  String get findPeople => 'Знайти людей';

  @override
  String get oldRequestsNote =>
      'Старі запити залишаються тут. Особисті повідомлення тепер лише для пар і напарників — нових запитів не буде.';

  @override
  String get noRequests => 'Запитів немає.';

  @override
  String get backToChats => 'Повернутися до чатів';

  @override
  String get callRequests => 'Запити на дзвінки';

  @override
  String noPendingWithActive(int count) {
    return 'Запитів немає · активних: $count';
  }

  @override
  String pendingCount(int count) {
    return 'Чекають відповіді: $count';
  }

  @override
  String get pending => 'Очікують';

  @override
  String get activeTab => 'Активні';

  @override
  String get requestsOwnersOnly =>
      'Запити бачать лише власник і адміністратори.';

  @override
  String get goBack => 'Назад';

  @override
  String noPendingFor(String group) {
    return 'Запитів немає. Запити учасників «$group» з’являться тут.';
  }

  @override
  String get noActive => 'Ця група не надавала доступу до дзвінків.';

  @override
  String get refresh => 'Оновити';

  @override
  String get grantHint =>
      'З цим доступом людина може телефонувати всім своїм парам і напарникам. Дзвінки не записуються; після виходу з групи доступ закривається.';

  @override
  String get granted => 'Дзвінки ввімкнено.';

  @override
  String get turnedOff => 'Дзвінки вимкнено.';

  @override
  String theirNote(String note) {
    return 'Нотатка: $note';
  }

  @override
  String get turnOff => 'Вимкнути';

  @override
  String get turnOn => 'Увімкнути';

  @override
  String get rankOnlyGrant =>
      'Ранг дорівнює вашому або вищий — запит можна лише схвалити.';

  @override
  String get rankCannotRevoke =>
      'Ранг дорівнює вашому або вищий — вимкнути не можна.';

  @override
  String get declineRequest => 'Відхилити запит';

  @override
  String get turnOffCalls => 'Вимкнути дзвінки';

  @override
  String get declineHint =>
      'Людина побачить причину й зможе запитати знову через 7 днів.';

  @override
  String get revokeHint =>
      'Поточний дзвінок одразу завершиться. Людина побачить причину й зможе запитати знову через 7 днів.';

  @override
  String get reason => 'Причина';

  @override
  String get reasonMin3 => 'Причина — щонайменше 3 символи.';

  @override
  String get yesterday => 'Учора';

  @override
  String get sendMessage => 'Написати';

  @override
  String get groupChatMembersOnly => 'Чат групи бачать лише її учасники.';

  @override
  String get callVerifying => 'Перевірка шифрування…';

  @override
  String get callSecure => 'Захищений дзвінок';

  @override
  String get callSecureDetail =>
      'Наскрізне шифрування. Коди безпеки обох телефонів збіглися, сторонніх немає.';

  @override
  String get callCheckFailed =>
      'Шифрування не підтверджено: коди безпеки телефонів не збігаються. Завершіть дзвінок і зателефонуйте знову.';

  @override
  String get showSecurityCode => 'Показати код безпеки';
}
