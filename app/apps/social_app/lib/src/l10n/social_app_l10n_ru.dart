// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'social_app_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class SocialAppL10nRu extends SocialAppL10n {
  SocialAppL10nRu([String locale = 'ru']) : super(locale);

  @override
  String get posts => 'Публикации';

  @override
  String get newPost => 'Новая публикация';

  @override
  String get noOwnPosts =>
      'Вы ещё ничего не публиковали. Поделитесь первым фото или видео.';

  @override
  String get noPosts => 'Публикаций пока нет.';

  @override
  String get shareFirstOwn => 'Опубликовать первый пост';

  @override
  String get groupFirstPost => 'Опубликуйте первый пост в ленте группы.';

  @override
  String get groupNoPosts => 'В этой группе пока нет публикаций.';

  @override
  String get shareFirstGroup => 'Опубликовать первым';

  @override
  String get groupNotFound => 'Группа не найдена.';

  @override
  String get memoriesEmpty =>
      'Воспоминаний пока нет. Участники могут добавить сюда свои фото.';

  @override
  String get plan => 'Тариф';

  @override
  String get payment => 'Оплата';

  @override
  String get onlyOwnerBilling =>
      'Управлять тарифами может только владелец группы.';

  @override
  String get backToGroup => 'Вернуться в группу';

  @override
  String get writeSupportAboutGroup =>
      'Написать команде платформы об этой группе';

  @override
  String get search => 'Поиск';

  @override
  String get notifications => 'Уведомления';

  @override
  String get goodNight => 'Доброй ночи';

  @override
  String get goodMorning => 'Доброе утро';

  @override
  String get goodAfternoon => 'Добрый день';

  @override
  String get goodEvening => 'Добрый вечер';

  @override
  String greetingName(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String get tabToday => 'Сегодня';

  @override
  String get tabGroups => 'Группы';

  @override
  String get tabCalendar => 'Календарь';

  @override
  String get tabMe => 'Я';

  @override
  String get tonightSay => 'Свободны? Скажите и соберите столик';

  @override
  String get tonightTableSet => 'Ваш столик собран';

  @override
  String get tonightInvited => 'Вас пригласили за столик';

  @override
  String tonightFreeWithYou(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count человек свободны, как и вы',
      few: '$count человека свободны, как и вы',
      one: '$count человек свободен, как и вы',
    );
    return '$_temp0';
  }

  @override
  String get tonightFreeUntil => 'Вы свободны · до 4:00';

  @override
  String tonightFreeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count человек свободны сегодня вечером',
      few: '$count человека свободны сегодня вечером',
      one: '$count человек свободен сегодня вечером',
    );
    return '$_temp0';
  }

  @override
  String get upcomingNone => 'Планы ваших групп';

  @override
  String upcomingMine(int count, int mine) {
    return '$count планов · $mine участий';
  }

  @override
  String upcomingCount(int count) {
    return '$count планов, 60 дней';
  }

  @override
  String get forToday => 'На сегодня';

  @override
  String get tonight => 'Сегодня вечером';

  @override
  String get upcoming => 'Скоро';

  @override
  String get share => 'Поделиться';

  @override
  String get post => 'Публикация';

  @override
  String get postHint => 'До 10 фото или видео';

  @override
  String get story => 'История';

  @override
  String get storyHint => 'Видна 24 часа';

  @override
  String get group => 'Группа';

  @override
  String get groupHint => 'Создайте своё сообщество';

  @override
  String get create => 'Создать';

  @override
  String get messages => 'Сообщения';

  @override
  String get matching => 'Знакомства';

  @override
  String get myGroups => 'Мои группы';

  @override
  String get pageNotFound =>
      'Страница не найдена. Возможно, ссылка устарела или неверна.';

  @override
  String get backHome => 'На главную';

  @override
  String get groupsLeague => 'Лига групп';

  @override
  String get exploreOnMap => 'Смотреть на карте';

  @override
  String get yearMenu => 'Итоги года, моя карта открытий и мои знакомства';

  @override
  String get yearSummary => 'Итоги года';

  @override
  String get yearSummaryHint =>
      'Ваши встречи за этот год — карточка, которой можно поделиться';

  @override
  String get explorationMap => 'Моя карта открытий';

  @override
  String get explorationMapHint =>
      'Провинции мероприятий, в которых вы участвовали';

  @override
  String get metPeople => 'Мои знакомства';

  @override
  String get metPeopleHint =>
      'Люди, с которыми вы обменялись рукопожатием на мероприятиях';

  @override
  String get findTeammates => 'Найти напарников';

  @override
  String get saved => 'Сохранённое';

  @override
  String get gateError =>
      'Не удалось загрузить ваши данные. Проверьте подключение и повторите попытку.';

  @override
  String get searchPeople => 'Поиск людей';

  @override
  String get clearSearch => 'Очистить поиск';

  @override
  String get settings => 'Настройки';

  @override
  String get editProfile => 'Редактировать профиль';

  @override
  String get teammatePrefs => 'Настройки поиска напарников';

  @override
  String get matchProfile => 'Профиль знакомств';

  @override
  String get voiceCalls => 'Голосовые звонки';

  @override
  String get blockedAccounts => 'Заблокированные аккаунты';

  @override
  String get storyArchive => 'Архив историй';

  @override
  String get notificationPrefs => 'Настройки уведомлений';

  @override
  String get mySanctions => 'Мои санкции в группах';

  @override
  String get userGuide => 'Руководство пользователя';

  @override
  String get supportFeedback => 'Поддержка и отзывы';

  @override
  String newReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count новых ответов',
      few: '$count новых ответа',
      one: '$count новый ответ',
    );
    return '$_temp0';
  }

  @override
  String get twoFactor => 'Двухэтапная проверка';

  @override
  String get legalDocuments => 'Юридические документы';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get signOut => 'Выйти';

  @override
  String get nowPrivate => 'Теперь ваш аккаунт закрытый.';

  @override
  String get nowPublic =>
      'Теперь ваш аккаунт открытый; ожидающие запросы одобрены.';

  @override
  String get privateAccount => 'Закрытый аккаунт';

  @override
  String get privateAccountHint =>
      'Если включено, ваши публикации и истории видят только одобренные вами подписчики.';

  @override
  String get groupsNowPublic => 'Теперь ваши группы видны всем в профиле.';

  @override
  String get groupsNowMembers =>
      'Теперь ваши группы видны только участникам тех же групп.';

  @override
  String get showGroups => 'Показывать мои группы в профиле';

  @override
  String get showGroupsHint =>
      'Если выключено, о вашем членстве в группе знают только её участники; администраторы других групп его не видят.';

  @override
  String get language => 'Язык';
}
