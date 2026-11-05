// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'groups_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class GroupsL10nRu extends GroupsL10n {
  GroupsL10nRu([String locale = 'ru']) : super(locale);

  @override
  String get unsupportedImage =>
      'Этот тип файла не поддерживается. Выберите JPEG, PNG или WebP.';

  @override
  String get joinOpen => 'Свободное вступление';

  @override
  String get joinOpenHint => 'Вступить может любой.';

  @override
  String get joinRequest => 'Вступление по заявке';

  @override
  String get joinRequestHint => 'Заявки одобряют администраторы.';

  @override
  String get joinInvite => 'Только по приглашению';

  @override
  String get joinInviteHint => 'Вступить могут только приглашённые.';

  @override
  String get roleOwner => 'Владелец группы';

  @override
  String get roleAdmin => 'Администратор';

  @override
  String get roleDiscipline => 'Дисциплинарный совет';

  @override
  String get roleModerator => 'Модератор';

  @override
  String get roleMember => 'Участник';

  @override
  String get handleMin => 'Адрес группы должен содержать не менее 3 символов.';

  @override
  String get handleChars =>
      'Используйте только строчные буквы, цифры, подчёркивания и точки.';

  @override
  String get handleDots =>
      'Нельзя начинать или заканчивать точкой и ставить две точки подряд.';

  @override
  String get nameMin => 'Название группы должно содержать не менее 3 символов.';

  @override
  String nameMax(int max) {
    return 'Название группы — не более $max символов.';
  }

  @override
  String get httpsOnly => 'Введите адрес, начинающийся с https://.';

  @override
  String get createGroup => 'Создать группу';

  @override
  String get groupInfo => 'Данные группы';

  @override
  String get groupInfoHint =>
      'Логотип, обложку, правила и ссылки можно добавить после создания группы.';

  @override
  String get groupName => 'Название группы';

  @override
  String get about => 'Описание';

  @override
  String get aboutHint => 'Чем занимается группа и кто может вступить?';

  @override
  String get joining => 'Вступление';

  @override
  String get changeLater => 'Это можно изменить позже.';

  @override
  String get createTheGroup => 'Создать группу';

  @override
  String get editGroup => 'Редактировать группу';

  @override
  String get noEditPermission => 'У вас нет прав на редактирование группы.';

  @override
  String get backToGroup => 'Вернуться в группу';

  @override
  String get save => 'Сохранить';

  @override
  String get logoAndCover => 'Логотип и обложка';

  @override
  String get imageHint => 'JPEG, PNG или WebP · до 5 МБ';

  @override
  String get logo => 'Логотип';

  @override
  String get cover => 'Обложка';

  @override
  String groupHandle(String handle) {
    return 'Адрес группы: $handle';
  }

  @override
  String get rules => 'Правила';

  @override
  String get rulesHint => 'Чего вы ждёте от участников — по правилу на строку.';

  @override
  String get links => 'Ссылки';

  @override
  String linksHint(int max) {
    return 'Сайт и соцсети. До $max.';
  }

  @override
  String get enterLabel => 'Введите подпись.';

  @override
  String get label => 'Подпись';

  @override
  String get address => 'Адрес';

  @override
  String get removeLink => 'Удалить ссылку';

  @override
  String get addLink => 'Добавить ссылку';

  @override
  String get cancel => 'Отмена';

  @override
  String get saveChanges => 'Сохранить изменения';

  @override
  String get deleteGroup => 'Удалить группу';

  @override
  String get deleteGroupBody =>
      'Группа, участники, роли, заявки и приглашения удаляются навсегда. Оставшийся срок тарифа не возвращается.';

  @override
  String deleteGroupNamed(String name) {
    return 'Удалить «$name»';
  }

  @override
  String changeImage(String label) {
    return 'Изменить: $label';
  }

  @override
  String addImage(String label) {
    return 'Добавить: $label';
  }

  @override
  String get remove => 'Удалить';

  @override
  String get deleteForever => 'Удалить группу навсегда';

  @override
  String deleteConfirm(String handle) {
    return 'Это действие нельзя отменить. Для подтверждения введите адрес группы: $handle';
  }

  @override
  String get delete => 'Удалить';

  @override
  String get group => 'Группа';

  @override
  String get share => 'Поделиться';

  @override
  String shareText(String name) {
    return 'Загляните в группу $name в GWAY:';
  }

  @override
  String get moreOptions => 'Другие действия';

  @override
  String get leaveGroup => 'Покинуть группу';

  @override
  String get groupNotFound => 'Группа не найдена или больше не видна.';

  @override
  String get backToGroups => 'Вернуться к группам';

  @override
  String leaveConfirm(String name) {
    return 'Покинуть «$name»? Если у вас есть роль в группе, она тоже будет снята.';
  }

  @override
  String get leave => 'Покинуть';

  @override
  String leftGroup(String name) {
    return 'Вы покинули «$name».';
  }

  @override
  String get suspendedNotice =>
      'Команда платформы приостановила группу. Пока действует блокировка, её видят только участники.';

  @override
  String founded(String date) {
    return 'Создана: $date';
  }

  @override
  String joinRequestsPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count заявок ждут одобрения.',
      few: '$count заявки ждут одобрения.',
      one: '$count заявка ждёт одобрения.',
    );
    return '$_temp0';
  }

  @override
  String get review => 'Посмотреть';

  @override
  String get requestSent => 'Заявка отправлена.';

  @override
  String get youAreMember => 'Вы участник';

  @override
  String get join => 'Вступить';

  @override
  String joined(String name) {
    return 'Вы вступили в «$name».';
  }

  @override
  String get sendJoinRequest => 'Подать заявку';

  @override
  String get requestSentShort => 'Заявка отправлена';

  @override
  String get withdrawRequest => 'Отозвать заявку';

  @override
  String get withdrawConfirm => 'Отозвать заявку?';

  @override
  String get undo => 'Отозвать';

  @override
  String get requestWithdrawn => 'Заявка отозвана.';

  @override
  String get decline => 'Отклонить';

  @override
  String get inviteDeclined => 'Приглашение отклонено.';

  @override
  String get acceptInvite => 'Принять приглашение';

  @override
  String followOn(String name) {
    return 'Публикации «$name» появятся в вашей ленте.';
  }

  @override
  String get followOff => 'Вы отписались от группы.';

  @override
  String get following => 'Вы подписаны';

  @override
  String get follow => 'Подписаться';

  @override
  String get managementTeam => 'Команда управления';

  @override
  String allMembers(int count) {
    return 'Все участники ($count)';
  }

  @override
  String get groups => 'Группы';

  @override
  String get discover => 'Обзор';

  @override
  String get myGroups => 'Мои группы';

  @override
  String get plans => 'Тарифы';

  @override
  String get searchHint => 'Поиск по названию или адресу группы';

  @override
  String get clearSearch => 'Очистить поиск';

  @override
  String get all => 'Все';

  @override
  String get noMatch => 'По вашему запросу групп не найдено.';

  @override
  String get clearFilters => 'Сбросить фильтры';

  @override
  String get noGroupsYet => 'Групп пока нет. Создайте первую.';

  @override
  String get showMore => 'Показать ещё';

  @override
  String get notJoinedYet => 'Вы ещё не вступили ни в одну группу.';

  @override
  String get discoverGroups => 'Найти группы';

  @override
  String get plansHint =>
      'Тарифы покупают владельцы групп. Создайте группу и выберите тариф.';

  @override
  String get yourInvitations => 'Ваши приглашения';

  @override
  String get invitationsHint => 'Эти группы пригласили вас вступить.';

  @override
  String invitedBy(String name) {
    return 'Пригласил(а) $name';
  }

  @override
  String get linkCopied => 'Ссылка скопирована.';

  @override
  String inviteShareText(String name) {
    return 'Вступайте в «$name» в GWAY:';
  }

  @override
  String get revokeLinkTitle => 'Отозвать ссылку?';

  @override
  String get revokeLinkBody =>
      'По этой ссылке больше никто не вступит. Уже вступившие останутся участниками.';

  @override
  String get revoke => 'Отозвать';

  @override
  String get inviteLink => 'Ссылка-приглашение';

  @override
  String get inviteLinkHint =>
      'Поделитесь в WhatsApp или Instagram. Открывший ссылку сразу становится участником, независимо от способа вступления.';

  @override
  String get createLink => 'Создать ссылку';

  @override
  String validUntil(String date) {
    return 'До $date';
  }

  @override
  String peopleJoined(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Вступили $count человек',
      few: 'Вступили $count человека',
      one: 'Вступил $count человек',
    );
    return '$_temp0';
  }

  @override
  String peopleJoinedOf(int count, int max) {
    return 'Вступили $count из $max';
  }

  @override
  String get newInviteLink => 'Новая ссылка-приглашение';

  @override
  String get validity => 'Срок действия';

  @override
  String days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дней',
      few: '$count дня',
      one: '$count день',
    );
    return '$_temp0';
  }

  @override
  String get howMany => 'Сколько человек может вступить?';

  @override
  String get unlimited => 'Без ограничений';

  @override
  String people(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count человек',
      few: '$count человека',
      one: '$count человек',
    );
    return '$_temp0';
  }

  @override
  String get createAndShare => 'Создать и поделиться';

  @override
  String get invitation => 'Приглашение';

  @override
  String get linkInvalid =>
      'Эта ссылка-приглашение больше не действует. Попросите новую у администратора группы.';

  @override
  String get seeGroup => 'Открыть группу';

  @override
  String get invitedToGroup => 'Вас пригласили в эту группу.';

  @override
  String get joinGroup => 'Вступить в группу';

  @override
  String get members => 'Участники';

  @override
  String get requests => 'Заявки';

  @override
  String get invitations => 'Приглашения';

  @override
  String get roles => 'Роли';

  @override
  String get openCase => 'Открыть дисциплинарное дело';

  @override
  String get report => 'Пожаловаться';

  @override
  String membersVisibility(int shown, int total) {
    return 'Полный список видят только участники. Здесь: команда управления и $shown человек, открывших свои группы; всего в группе $total участников.';
  }

  @override
  String optionsFor(String name) {
    return 'Действия для $name';
  }

  @override
  String get transferOwnership => 'Передать права владельца';

  @override
  String transferBody(String group, String person) {
    return 'Права владельца «$group» перейдут к $person. Вы останетесь обычным участником, отменить это нельзя.';
  }

  @override
  String get transfer => 'Передать';

  @override
  String transferred(String name) {
    return 'Права владельца переданы $name.';
  }

  @override
  String get hintAdmin =>
      'Редактирует группу, управляет заявками и приглашениями.';

  @override
  String get hintDiscipline =>
      'Рассматривает дела по жалобам и решает о санкциях.';

  @override
  String get hintModerator => 'Проверяет публикации и комментарии.';

  @override
  String personJoined(String name) {
    return '$name вступил(а) в группу.';
  }

  @override
  String get requestDeclined => 'Заявка отклонена.';

  @override
  String get noPendingRequests => 'Заявок нет.';

  @override
  String get refresh => 'Обновить';

  @override
  String get approve => 'Одобрить';

  @override
  String get inviteSent => 'Приглашение отправлено.';

  @override
  String get inviteByUsername => 'Пригласить по имени пользователя';

  @override
  String get invite => 'Пригласить';

  @override
  String get noPendingInvites => 'Приглашений нет.';

  @override
  String memberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count участников',
      few: '$count участника',
      one: '$count участник',
    );
    return '$_temp0';
  }

  @override
  String get suspended => 'Приостановлена';

  @override
  String get groupsSection => 'Группы';

  @override
  String get groupsOwnHint =>
      'Ваши группы видят только участники тех же групп. Открыть их можно в настройках.';

  @override
  String get groupsOtherHint =>
      'Показаны только общие группы и группы, которыми человек управляет.';

  @override
  String get noGroupsToShow => 'Нет групп для показа.';

  @override
  String get handleTaken => 'Этот адрес занят. Попробуйте другой.';

  @override
  String get groupAddress => 'Адрес группы';

  @override
  String get groupAddressHint =>
      'Адрес страницы группы. Его нельзя изменить позже.';

  @override
  String get available => 'Свободен';

  @override
  String get taken => 'Занят';

  @override
  String get notSpecified => 'Не указано';

  @override
  String get provinceOptional => 'Провинция (необязательно)';

  @override
  String get provinceHint => 'Группа отображается в этой провинции на карте.';

  @override
  String get chooseCategory => 'Выберите категорию.';

  @override
  String get category => 'Категория';
}
