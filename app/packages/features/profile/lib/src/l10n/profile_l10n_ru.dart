// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'profile_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class ProfileL10nRu extends ProfileL10n {
  ProfileL10nRu([String locale = 'ru']) : super(locale);

  @override
  String get unsupportedImage =>
      'Этот тип файла не поддерживается. Выберите JPEG, PNG или WebP.';

  @override
  String get usernameTaken => 'Это имя пользователя занято. Попробуйте другое.';

  @override
  String get checkInput => 'Проверьте введённые данные.';

  @override
  String get usernameReserved =>
      'Это имя пользователя нельзя использовать. Попробуйте другое.';

  @override
  String get usernameCooldown =>
      'Имя пользователя можно менять только раз в 30 дней.';

  @override
  String get maxInterests10 => 'Можно выбрать до 10 интересов.';

  @override
  String get levelBeginner => 'Начинающий';

  @override
  String get levelBeginnerHint => 'Только начинаю';

  @override
  String get levelIntermediate => 'Средний';

  @override
  String get levelIntermediateHint => 'Занимаюсь регулярно';

  @override
  String get levelAdvanced => 'Продвинутый';

  @override
  String get levelAdvancedHint => 'У меня большой опыт';

  @override
  String get slotWeekdayMorning => 'Будни, утро';

  @override
  String get slotWeekdayNoon => 'Будни, день';

  @override
  String get slotWeekdayEvening => 'Будни, вечер';

  @override
  String get slotWeekendMorning => 'Выходные, утро';

  @override
  String get slotWeekendAfternoon => 'Выходные, день';

  @override
  String get slotWeekendEvening => 'Выходные, вечер';

  @override
  String get partMorning => 'Утро';

  @override
  String get partNoon => 'День';

  @override
  String get partEvening => 'Вечер';

  @override
  String get goalFun => 'Развлечься';

  @override
  String get goalFitness => 'Быть в форме';

  @override
  String get goalCompetition => 'Готовиться к соревнованиям';

  @override
  String get goalLearning => 'Узнавать новое';

  @override
  String get goalMentoring => 'Делиться опытом';

  @override
  String get goalSocial => 'Знакомиться с новыми людьми';

  @override
  String get freqMonthly => 'Несколько раз в месяц';

  @override
  String get freqWeekly => 'Раз в неделю';

  @override
  String get freqFewWeekly => '2–3 раза в неделю';

  @override
  String get freqDaily => 'Почти каждый день';

  @override
  String get sizePair => 'Вдвоём';

  @override
  String get sizeSmall => 'Небольшая группа (3–6)';

  @override
  String get sizeLarge => 'Большая группа';

  @override
  String get looking => 'Ищет команду';

  @override
  String lookingWithLevel(String level) {
    return 'Ищет команду · $level';
  }

  @override
  String reasonActivities(String list) {
    return 'Общее занятие: $list';
  }

  @override
  String reasonInterests(String list) {
    return 'Общие интересы: $list';
  }

  @override
  String get reasonProvince => 'Вы в одной провинции';

  @override
  String reasonGroup(String group) {
    return 'Общая группа: $group';
  }

  @override
  String reasonGroups(int count) {
    return 'Общих групп: $count';
  }

  @override
  String reasonLevel(String level) {
    return 'Одинаковый уровень: $level';
  }

  @override
  String reasonTimes(String list) {
    return 'Удобное время: $list';
  }

  @override
  String reasonGoals(String list) {
    return 'Общие цели: $list';
  }

  @override
  String get reasonFrequency => 'Вы хотите встречаться одинаково часто';

  @override
  String get hasVehicle => 'Есть транспорт';

  @override
  String get hasEquipment => 'Есть своё снаряжение';

  @override
  String get usernameRequired => 'Выберите имя пользователя.';

  @override
  String usernameMin(int min) {
    return 'Имя пользователя должно содержать не менее $min символов.';
  }

  @override
  String usernameMax(int max) {
    return 'Имя пользователя может содержать не более $max символов.';
  }

  @override
  String get usernameChars =>
      'Используйте только a–z, 0–9, подчёркивание (_) и точку (.).';

  @override
  String get usernameDots =>
      'Имя пользователя не может начинаться или заканчиваться точкой.';

  @override
  String get usernameDoubleDot => 'Нельзя ставить две точки подряд.';

  @override
  String get nameRequired => 'Введите имя.';

  @override
  String nameMax(int max) {
    return 'Имя может содержать не более $max символов.';
  }

  @override
  String get editProfile => 'Редактировать профиль';

  @override
  String get save => 'Сохранить';

  @override
  String get profileInfo => 'Данные профиля';

  @override
  String get profileInfoHint => 'Эти данные видны всем в вашем профиле.';

  @override
  String get yourName => 'Ваше имя';

  @override
  String get usernameEvery30 => 'Имя пользователя можно менять раз в 30 дней.';

  @override
  String usernameLockedUntil(String date) {
    return 'Изменить можно после $date.';
  }

  @override
  String get about => 'О себе';

  @override
  String get aboutHint => 'Расскажите о себе и любимых занятиях.';

  @override
  String get interests => 'Интересы';

  @override
  String interestsMax(int max) {
    return 'Можно выбрать до $max.';
  }

  @override
  String get cancel => 'Отмена';

  @override
  String get saveChanges => 'Сохранить изменения';

  @override
  String get remove => 'Удалить';

  @override
  String get removeCover => 'Удалить обложку';

  @override
  String get addCover => 'Добавить обложку';

  @override
  String get changeCover => 'Изменить обложку';

  @override
  String get changeAvatar => 'Изменить фото профиля';

  @override
  String get photos => 'Фото профиля и обложка';

  @override
  String get photosHint => 'JPEG, PNG или WebP · до 5 МБ';

  @override
  String get addAvatar => 'Добавить фото профиля';

  @override
  String get removeAvatar => 'Удалить фото профиля';

  @override
  String get followers => 'Подписчики';

  @override
  String get following => 'Подписки';

  @override
  String get privateLists =>
      'Это закрытый аккаунт. Подпишитесь, чтобы видеть его списки.';

  @override
  String get backToProfile => 'Вернуться в профиль';

  @override
  String get noFollowers => 'Подписчиков пока нет.';

  @override
  String get noFollowing => 'Пока ни на кого не подписан.';

  @override
  String get refresh => 'Обновить';

  @override
  String get removeFollower => 'Удалить подписчика';

  @override
  String removeFollowerBody(String username) {
    return 'Удалить $username из подписчиков? Человек не получит уведомления.';
  }

  @override
  String get removeAction => 'Удалить';

  @override
  String get friends => 'Вы друзья';

  @override
  String get followRequests => 'Запросы на подписку';

  @override
  String get noFollowRequests =>
      'Ожидающих запросов нет. Закрытые аккаунты одобряют запросы здесь.';

  @override
  String get approve => 'Одобрить';

  @override
  String get delete => 'Удалить';

  @override
  String get blockedAccounts => 'Заблокированные аккаунты';

  @override
  String get noBlocked =>
      'Вы никого не заблокировали. Заблокировать можно в меню профиля.';

  @override
  String get unblock => 'Разблокировать';

  @override
  String get onboardWho => 'Давайте познакомимся';

  @override
  String get onboardWhoHint => 'Выберите имя и имя пользователя для профиля.';

  @override
  String get onboardPhoto => 'Фото профиля';

  @override
  String get onboardPhotoHint =>
      'Чтобы группы вас узнавали. Можно добавить и позже.';

  @override
  String get onboardInterests => 'Ваши интересы';

  @override
  String onboardInterestsHint(int max) {
    return 'Выберите до $max, чтобы мы подобрали вам группы.';
  }

  @override
  String get back => 'Назад';

  @override
  String stepOf(int step, int total) {
    return 'Шаг $step из $total';
  }

  @override
  String get signOut => 'Выйти';

  @override
  String get skipForNow => 'Пропустить пока';

  @override
  String get continueAction => 'Продолжить';

  @override
  String get finish => 'Готово';

  @override
  String get usernameHelper => 'Используйте строчные буквы, цифры, _ и .';

  @override
  String get avatarPreview => 'Предпросмотр фото профиля';

  @override
  String get choosePhoto => 'Выбрать фото';

  @override
  String get chooseAnotherPhoto => 'Выбрать другое фото';

  @override
  String get profile => 'Профиль';

  @override
  String get settings => 'Настройки';

  @override
  String get profileNotFound => 'Профиль не найден или больше не виден.';

  @override
  String get backToMyProfile => 'Вернуться в мой профиль';

  @override
  String suspendedUntil(String date) {
    return 'Этот аккаунт заблокирован до $date.';
  }

  @override
  String get followsYou => 'Подписан(а) на вас';

  @override
  String get yourTeammate => 'Ваш напарник';

  @override
  String joined(String date) {
    return 'С нами с $date';
  }

  @override
  String followRequestsPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count запросов на подписку ждут одобрения.',
      few: '$count запроса на подписку ждут одобрения.',
      one: '$count запрос на подписку ждёт одобрения.',
    );
    return '$_temp0';
  }

  @override
  String get review => 'Посмотреть';

  @override
  String teammateRequestsPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Вас ждут $count запросов в напарники.',
      few: 'Вас ждут $count запроса в напарники.',
      one: 'Вас ждёт $count запрос в напарники.',
    );
    return '$_temp0';
  }

  @override
  String get youBlocked => 'Вы заблокировали этот аккаунт';

  @override
  String get youBlockedHint =>
      'Если разблокировать, вы снова увидите публикации друг друга.';

  @override
  String get privateAccount => 'Это закрытый аккаунт';

  @override
  String get privateAccountHint =>
      'Подпишитесь, чтобы видеть фото, видео и истории.';

  @override
  String get addInterestsNudge =>
      'Добавьте интересы — мы подберём группы и напарников.';

  @override
  String get add => 'Добавить';

  @override
  String blockTitle(String username) {
    return 'Заблокировать $username?';
  }

  @override
  String get blockBody =>
      'Человек не увидит ваш профиль, публикации и истории, не найдёт вас и не сможет написать. Взаимные подписки прекратятся. О блокировке он не узнает.';

  @override
  String get block => 'Заблокировать';

  @override
  String get becomeTeammates => 'Стать напарниками';

  @override
  String nowTeammates(String name) {
    return 'Теперь вы с $name напарники.';
  }

  @override
  String get acceptTeammate => 'Принять запрос в напарники';

  @override
  String get requestWithdrawn => 'Запрос отозван.';

  @override
  String get withdrawTeammate => 'Отозвать запрос в напарники';

  @override
  String get teammateEnded => 'Вы больше не напарники.';

  @override
  String get endTeammate => 'Перестать быть напарниками';

  @override
  String get moreOptions => 'Другие действия';

  @override
  String get linkCopied => 'Ссылка на профиль скопирована.';

  @override
  String get copyLink => 'Скопировать ссылку на профиль';

  @override
  String get removedFromFollowers => 'Удалён(а) из подписчиков.';

  @override
  String get removeFromFollowers => 'Удалить из подписчиков';

  @override
  String get report => 'Пожаловаться';

  @override
  String get unblocked => 'Разблокировано.';

  @override
  String get statPosts => 'Публикации';

  @override
  String get statFollowers => 'Подписчики';

  @override
  String get statFollowing => 'Подписки';

  @override
  String withdrawFollowBody(String username) {
    return 'Отозвать запрос на подписку на $username?';
  }

  @override
  String unfollowBody(String username) {
    return 'Отписаться от $username?';
  }

  @override
  String unfollowPrivateBody(String username) {
    return 'Отписаться от $username? Аккаунт закрытый: чтобы снова видеть публикации, придётся отправить новый запрос.';
  }

  @override
  String get withdrawRequest => 'Отозвать запрос';

  @override
  String get unfollow => 'Отписаться';

  @override
  String get followBack => 'Подписаться в ответ';

  @override
  String get follow => 'Подписаться';

  @override
  String get requestSent => 'Запрос отправлен';

  @override
  String get followingState => 'Вы подписаны';

  @override
  String noAccountMatch(String query) {
    return 'По запросу «$query» аккаунтов не найдено.';
  }

  @override
  String get clearSearch => 'Очистить поиск';

  @override
  String get searchHint => 'Начните вводить, чтобы найти людей или теги.';

  @override
  String get refreshSuggestions => 'Обновить рекомендации';

  @override
  String get suggestionsForYou => 'Рекомендации для вас';

  @override
  String mutualFollows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Подписаны $count человек из ваших подписок',
      few: 'Подписаны $count человека из ваших подписок',
      one: 'Подписан $count человек из ваших подписок',
    );
    return '$_temp0';
  }

  @override
  String get popularAccount => 'Популярный аккаунт';

  @override
  String get seePackage => 'Посмотреть тариф';

  @override
  String requestSentNotify(String name) {
    return 'Запрос отправлен. Сообщим, когда $name примет его.';
  }

  @override
  String becomeTeammatesWith(String name) {
    return 'Стать напарником $name';
  }

  @override
  String get shortMessage => 'Короткое сообщение (необязательно)';

  @override
  String get shortMessageHint => 'В субботу утром в парке?';

  @override
  String get sendRequest => 'Отправить запрос';

  @override
  String get findTeammates => 'Найти напарников';

  @override
  String get myTeammatePrefs => 'Мои настройки поиска напарников';

  @override
  String get tabSuggestions => 'Рекомендации';

  @override
  String get tabRequests => 'Запросы';

  @override
  String tabRequestsCount(int count) {
    return 'Запросы ($count)';
  }

  @override
  String get tabMyTeam => 'Моя команда';

  @override
  String get findYourTeammate => 'Найдите напарника';

  @override
  String waitingForYou(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count человек хотят стать вашими напарниками',
      few: '$count человека хотят стать вашими напарниками',
      one: '$count человек хочет стать вашим напарником',
    );
    return '$_temp0';
  }

  @override
  String get teammatesLocked =>
      'Рекомендации, отправка и принятие запросов и переписка с напарниками доступны в тарифе «Напарник».';

  @override
  String get beVisible => 'Станьте заметнее';

  @override
  String get beVisibleBody =>
      'Включите «Ищу команду», и люди со схожими интересами смогут отправлять вам запросы.';

  @override
  String get setPrefs => 'Настроить предпочтения';

  @override
  String get nowPublicSuggest =>
      'Теперь ваш аккаунт открытый — вы можете появляться в рекомендациях.';

  @override
  String get privateHidden => 'Ваш аккаунт закрытый — вас нет в рекомендациях';

  @override
  String get privateHiddenBody =>
      'Закрытые аккаунты не попадают в рекомендации напарников. Если открыть аккаунт, ожидающие запросы на подписку тоже будут одобрены.';

  @override
  String get makePublic => 'Открыть аккаунт';

  @override
  String get noSuggestions =>
      'Пока подходящих людей нет. Заполните интересы и предпочтения — рекомендаций станет больше.';

  @override
  String quoted(String text) {
    return '«$text»';
  }

  @override
  String get whySuggested => 'Почему рекомендовано';

  @override
  String get noPendingTeammate => 'Ожидающих запросов в напарники нет.';

  @override
  String get seeSuggestions => 'Смотреть рекомендации';

  @override
  String get incoming => 'Входящие';

  @override
  String get accept => 'Принять';

  @override
  String get decline => 'Отклонить';

  @override
  String get requestDeclined => 'Запрос отклонён.';

  @override
  String get outgoing => 'Отправленные';

  @override
  String get awaitingReply => 'Ожидает ответа';

  @override
  String get withdraw => 'Отозвать';

  @override
  String get noTeammates =>
      'У вас пока нет напарников. Начните с запроса кому-нибудь из рекомендаций.';

  @override
  String optionsFor(String name) {
    return 'Действия для $name';
  }

  @override
  String get teammatePrefs => 'Настройки поиска напарников';

  @override
  String get prefsSavedVisible =>
      'Предпочтения сохранены. Теперь вы появляетесь в рекомендациях.';

  @override
  String get prefsSaved => 'Предпочтения сохранены.';

  @override
  String get whatToDo => 'Чем хотите заниматься?';

  @override
  String activitiesHint(int max) {
    return 'Занятия, для которых вы ищете напарников. До $max.';
  }

  @override
  String get yourLevel => 'Ваш уровень';

  @override
  String get yourGoals => 'Ваши цели';

  @override
  String get multipleChoice => 'Можно выбрать несколько.';

  @override
  String get howOften => 'Как часто хотите встречаться?';

  @override
  String get whenFree => 'Когда вы свободны?';

  @override
  String get whenFreeHint => 'Отметьте удобное время.';

  @override
  String get whatTeam => 'Какую команду хотите?';

  @override
  String get whichProvince => 'В какой вы провинции?';

  @override
  String get provinceHint =>
      'Используется только для подбора и не видна в профиле.';

  @override
  String get province => 'Провинция';

  @override
  String get ratherNotSay => 'Не хочу указывать';

  @override
  String get extras => 'Дополнительно';

  @override
  String get iHaveVehicle => 'У меня есть транспорт';

  @override
  String get iHaveVehicleHint => 'Могу подвезти.';

  @override
  String get iHaveEquipment => 'У меня своё снаряжение';

  @override
  String get iHaveEquipmentHint =>
      'Велосипед, палатка, ракетка или другое снаряжение — есть.';

  @override
  String get describeYourself => 'Расскажите о себе';

  @override
  String get describeHint => 'Показывается под вашим именем в рекомендациях.';

  @override
  String get describeExample =>
      'Ищу компанию для утренних прогулок по выходным.';

  @override
  String get willAppear => 'Вы появитесь в рекомендациях.';

  @override
  String get notAppearing => 'Сейчас вас нет в рекомендациях.';

  @override
  String get lookingForTeam => 'Ищу команду';

  @override
  String get lookingOn =>
      'Вы в рекомендациях — вам могут отправлять запросы в напарники.';

  @override
  String get lookingOff =>
      'Включите — и вас найдут люди со схожими интересами. Закрытые аккаунты не попадают в рекомендации.';

  @override
  String prefsComplete(int percent) {
    return 'Предпочтения заполнены на $percent%';
  }

  @override
  String get prefsCompleteHint =>
      'Чем больше заполните, тем точнее рекомендации.';

  @override
  String get weekday => 'Будни';

  @override
  String get weekend => 'Выходные';

  @override
  String get username => 'Имя пользователя';

  @override
  String get available => 'Свободно';

  @override
  String get taken => 'Занято';

  @override
  String blockedUser(String username) {
    return '$username заблокирован(а).';
  }
}
