// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'groups_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class GroupsL10nUk extends GroupsL10n {
  GroupsL10nUk([String locale = 'uk']) : super(locale);

  @override
  String get unsupportedImage =>
      'Цей тип файлу не підтримується. Виберіть JPEG, PNG або WebP.';

  @override
  String get joinOpen => 'Вільний вступ';

  @override
  String get joinOpenHint => 'Вступити може будь-хто.';

  @override
  String get joinRequest => 'Вступ за заявкою';

  @override
  String get joinRequestHint => 'Заявки схвалюють адміністратори.';

  @override
  String get joinInvite => 'Лише за запрошенням';

  @override
  String get joinInviteHint => 'Вступити можуть лише запрошені.';

  @override
  String get roleOwner => 'Власник групи';

  @override
  String get roleAdmin => 'Адміністратор';

  @override
  String get roleDiscipline => 'Дисциплінарна рада';

  @override
  String get roleModerator => 'Модератор';

  @override
  String get roleMember => 'Учасник';

  @override
  String get handleMin => 'Адреса групи має містити щонайменше 3 символи.';

  @override
  String get handleChars =>
      'Використовуйте лише малі літери, цифри, підкреслення й крапки.';

  @override
  String get handleDots =>
      'Не можна починати чи закінчувати крапкою або ставити дві крапки поспіль.';

  @override
  String get nameMin => 'Назва групи має містити щонайменше 3 символи.';

  @override
  String nameMax(int max) {
    return 'Назва групи — не більше $max символів.';
  }

  @override
  String get httpsOnly => 'Введіть адресу, що починається з https://.';

  @override
  String get createGroup => 'Створити групу';

  @override
  String get groupInfo => 'Дані групи';

  @override
  String get groupInfoHint =>
      'Логотип, обкладинку, правила й посилання можна додати після створення групи.';

  @override
  String get groupName => 'Назва групи';

  @override
  String get about => 'Опис';

  @override
  String get aboutHint => 'Чим займається група і хто може вступити?';

  @override
  String get joining => 'Вступ';

  @override
  String get changeLater => 'Це можна змінити пізніше.';

  @override
  String get createTheGroup => 'Створити групу';

  @override
  String get editGroup => 'Редагувати групу';

  @override
  String get noEditPermission => 'У вас немає прав на редагування групи.';

  @override
  String get backToGroup => 'Повернутися до групи';

  @override
  String get save => 'Зберегти';

  @override
  String get logoAndCover => 'Логотип і обкладинка';

  @override
  String get imageHint => 'JPEG, PNG або WebP · до 5 МБ';

  @override
  String get logo => 'Логотип';

  @override
  String get cover => 'Обкладинка';

  @override
  String groupHandle(String handle) {
    return 'Адреса групи: $handle';
  }

  @override
  String get rules => 'Правила';

  @override
  String get rulesHint =>
      'Чого ви чекаєте від учасників — по правилу на рядок.';

  @override
  String get links => 'Посилання';

  @override
  String linksHint(int max) {
    return 'Сайт і соцмережі. До $max.';
  }

  @override
  String get enterLabel => 'Введіть підпис.';

  @override
  String get label => 'Підпис';

  @override
  String get address => 'Адреса';

  @override
  String get removeLink => 'Видалити посилання';

  @override
  String get addLink => 'Додати посилання';

  @override
  String get cancel => 'Скасувати';

  @override
  String get saveChanges => 'Зберегти зміни';

  @override
  String get deleteGroup => 'Видалити групу';

  @override
  String get deleteGroupBody =>
      'Групу, учасників, ролі, заявки й запрошення буде видалено назавжди. Залишок строку тарифу не повертається.';

  @override
  String deleteGroupNamed(String name) {
    return 'Видалити «$name»';
  }

  @override
  String changeImage(String label) {
    return 'Змінити: $label';
  }

  @override
  String addImage(String label) {
    return 'Додати: $label';
  }

  @override
  String get remove => 'Видалити';

  @override
  String get deleteForever => 'Видалити групу назавжди';

  @override
  String deleteConfirm(String handle) {
    return 'Цю дію не можна скасувати. Для підтвердження введіть адресу групи: $handle';
  }

  @override
  String get delete => 'Видалити';

  @override
  String get group => 'Група';

  @override
  String get share => 'Поділитися';

  @override
  String shareText(String name) {
    return 'Загляньте до групи $name у GWAY:';
  }

  @override
  String get moreOptions => 'Інші дії';

  @override
  String get leaveGroup => 'Вийти з групи';

  @override
  String get groupNotFound => 'Групу не знайдено або вона більше не видима.';

  @override
  String get backToGroups => 'Повернутися до груп';

  @override
  String leaveConfirm(String name) {
    return 'Вийти з «$name»? Якщо у вас є роль у групі, її теж буде знято.';
  }

  @override
  String get leave => 'Вийти';

  @override
  String leftGroup(String name) {
    return 'Ви вийшли з «$name».';
  }

  @override
  String get suspendedNotice =>
      'Команда платформи призупинила групу. Поки діє блокування, її бачать лише учасники.';

  @override
  String founded(String date) {
    return 'Створена: $date';
  }

  @override
  String joinRequestsPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count заявок чекають схвалення.',
      few: '$count заявки чекають схвалення.',
      one: '$count заявка чекає схвалення.',
    );
    return '$_temp0';
  }

  @override
  String get review => 'Переглянути';

  @override
  String get requestSent => 'Заявку надіслано.';

  @override
  String get youAreMember => 'Ви учасник';

  @override
  String get join => 'Вступити';

  @override
  String joined(String name) {
    return 'Ви вступили до «$name».';
  }

  @override
  String get sendJoinRequest => 'Подати заявку';

  @override
  String get requestSentShort => 'Заявку надіслано';

  @override
  String get withdrawRequest => 'Відкликати заявку';

  @override
  String get withdrawConfirm => 'Відкликати заявку?';

  @override
  String get undo => 'Відкликати';

  @override
  String get requestWithdrawn => 'Заявку відкликано.';

  @override
  String get decline => 'Відхилити';

  @override
  String get inviteDeclined => 'Запрошення відхилено.';

  @override
  String get acceptInvite => 'Прийняти запрошення';

  @override
  String followOn(String name) {
    return 'Дописи «$name» з’являться у вашій стрічці.';
  }

  @override
  String get followOff => 'Ви відписалися від групи.';

  @override
  String get following => 'Ви підписані';

  @override
  String get follow => 'Підписатися';

  @override
  String get managementTeam => 'Команда управління';

  @override
  String allMembers(int count) {
    return 'Усі учасники ($count)';
  }

  @override
  String get groups => 'Групи';

  @override
  String get discover => 'Огляд';

  @override
  String get myGroups => 'Мої групи';

  @override
  String get plans => 'Тарифи';

  @override
  String get searchHint => 'Пошук за назвою або адресою групи';

  @override
  String get clearSearch => 'Очистити пошук';

  @override
  String get all => 'Усі';

  @override
  String get noMatch => 'За вашим запитом груп не знайдено.';

  @override
  String get clearFilters => 'Скинути фільтри';

  @override
  String get noGroupsYet => 'Груп поки немає. Створіть першу.';

  @override
  String get showMore => 'Показати ще';

  @override
  String get notJoinedYet => 'Ви ще не вступили до жодної групи.';

  @override
  String get discoverGroups => 'Знайти групи';

  @override
  String get plansHint =>
      'Тарифи купують власники груп. Створіть групу й виберіть тариф.';

  @override
  String get yourInvitations => 'Ваші запрошення';

  @override
  String get invitationsHint => 'Ці групи запросили вас вступити.';

  @override
  String invitedBy(String name) {
    return 'Запросив(-ла) $name';
  }

  @override
  String get linkCopied => 'Посилання скопійовано.';

  @override
  String inviteShareText(String name) {
    return 'Вступайте до «$name» у GWAY:';
  }

  @override
  String get revokeLinkTitle => 'Відкликати посилання?';

  @override
  String get revokeLinkBody =>
      'За цим посиланням більше ніхто не вступить. Ті, хто вже вступив, залишаться учасниками.';

  @override
  String get revoke => 'Відкликати';

  @override
  String get inviteLink => 'Посилання-запрошення';

  @override
  String get inviteLinkHint =>
      'Поділіться у WhatsApp чи Instagram. Хто відкриє посилання, одразу стане учасником, незалежно від способу вступу.';

  @override
  String get createLink => 'Створити посилання';

  @override
  String validUntil(String date) {
    return 'До $date';
  }

  @override
  String peopleJoined(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Вступили $count людей',
      few: 'Вступили $count людини',
      one: 'Вступила $count людина',
    );
    return '$_temp0';
  }

  @override
  String peopleJoinedOf(int count, int max) {
    return 'Вступили $count з $max';
  }

  @override
  String get newInviteLink => 'Нове посилання-запрошення';

  @override
  String get validity => 'Строк дії';

  @override
  String days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count днів',
      few: '$count дні',
      one: '$count день',
    );
    return '$_temp0';
  }

  @override
  String get howMany => 'Скільки людей може вступити?';

  @override
  String get unlimited => 'Без обмежень';

  @override
  String people(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count людей',
      few: '$count людини',
      one: '$count людина',
    );
    return '$_temp0';
  }

  @override
  String get createAndShare => 'Створити й поділитися';

  @override
  String get invitation => 'Запрошення';

  @override
  String get linkInvalid =>
      'Це посилання-запрошення більше не діє. Попросіть нове в адміністратора групи.';

  @override
  String get seeGroup => 'Відкрити групу';

  @override
  String get invitedToGroup => 'Вас запросили до цієї групи.';

  @override
  String get joinGroup => 'Вступити до групи';

  @override
  String get members => 'Учасники';

  @override
  String get requests => 'Заявки';

  @override
  String get invitations => 'Запрошення';

  @override
  String get roles => 'Ролі';

  @override
  String get openCase => 'Відкрити дисциплінарну справу';

  @override
  String get report => 'Поскаржитися';

  @override
  String membersVisibility(int shown, int total) {
    return 'Повний список бачать лише учасники. Тут: команда управління та $shown людей, що відкрили свої групи; усього в групі $total учасників.';
  }

  @override
  String optionsFor(String name) {
    return 'Дії для $name';
  }

  @override
  String get transferOwnership => 'Передати права власника';

  @override
  String transferBody(String group, String person) {
    return 'Права власника «$group» перейдуть до $person. Ви залишитеся звичайним учасником, скасувати це не можна.';
  }

  @override
  String get transfer => 'Передати';

  @override
  String transferred(String name) {
    return 'Права власника передано $name.';
  }

  @override
  String get hintAdmin => 'Редагує групу, керує заявками й запрошеннями.';

  @override
  String get hintDiscipline =>
      'Розглядає справи за скаргами й вирішує щодо санкцій.';

  @override
  String get hintModerator => 'Перевіряє дописи й коментарі.';

  @override
  String personJoined(String name) {
    return '$name вступив(-ла) до групи.';
  }

  @override
  String get requestDeclined => 'Заявку відхилено.';

  @override
  String get noPendingRequests => 'Заявок немає.';

  @override
  String get refresh => 'Оновити';

  @override
  String get approve => 'Схвалити';

  @override
  String get inviteSent => 'Запрошення надіслано.';

  @override
  String get inviteByUsername => 'Запросити за ім’ям користувача';

  @override
  String get invite => 'Запросити';

  @override
  String get noPendingInvites => 'Запрошень немає.';

  @override
  String memberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count учасників',
      few: '$count учасники',
      one: '$count учасник',
    );
    return '$_temp0';
  }

  @override
  String get suspended => 'Призупинена';

  @override
  String get groupsSection => 'Групи';

  @override
  String get groupsOwnHint =>
      'Ваші групи бачать лише учасники тих самих груп. Відкрити їх можна в налаштуваннях.';

  @override
  String get groupsOtherHint =>
      'Показано лише спільні групи й групи, якими людина керує.';

  @override
  String get noGroupsToShow => 'Немає груп для показу.';

  @override
  String get handleTaken => 'Ця адреса зайнята. Спробуйте іншу.';

  @override
  String get groupAddress => 'Адреса групи';

  @override
  String get groupAddressHint =>
      'Адреса сторінки групи. Її не можна змінити пізніше.';

  @override
  String get available => 'Вільна';

  @override
  String get taken => 'Зайнята';

  @override
  String get notSpecified => 'Не вказано';

  @override
  String get provinceOptional => 'Провінція (необов’язково)';

  @override
  String get provinceHint => 'Група відображається в цій провінції на мапі.';

  @override
  String get chooseCategory => 'Виберіть категорію.';

  @override
  String get category => 'Категорія';
}
