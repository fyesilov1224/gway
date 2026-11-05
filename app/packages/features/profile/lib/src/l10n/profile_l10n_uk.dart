// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'profile_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class ProfileL10nUk extends ProfileL10n {
  ProfileL10nUk([String locale = 'uk']) : super(locale);

  @override
  String get unsupportedImage =>
      'Цей тип файлу не підтримується. Виберіть JPEG, PNG або WebP.';

  @override
  String get usernameTaken => 'Це ім’я користувача зайняте. Спробуйте інше.';

  @override
  String get checkInput => 'Перевірте введені дані.';

  @override
  String get usernameReserved =>
      'Це ім’я користувача не можна використати. Спробуйте інше.';

  @override
  String get usernameCooldown =>
      'Ім’я користувача можна змінювати лише раз на 30 днів.';

  @override
  String get maxInterests10 => 'Можна вибрати до 10 інтересів.';

  @override
  String get levelBeginner => 'Початківець';

  @override
  String get levelBeginnerHint => 'Тільки починаю';

  @override
  String get levelIntermediate => 'Середній';

  @override
  String get levelIntermediateHint => 'Займаюся регулярно';

  @override
  String get levelAdvanced => 'Просунутий';

  @override
  String get levelAdvancedHint => 'Маю досвід';

  @override
  String get slotWeekdayMorning => 'Будні, ранок';

  @override
  String get slotWeekdayNoon => 'Будні, день';

  @override
  String get slotWeekdayEvening => 'Будні, вечір';

  @override
  String get slotWeekendMorning => 'Вихідні, ранок';

  @override
  String get slotWeekendAfternoon => 'Вихідні, день';

  @override
  String get slotWeekendEvening => 'Вихідні, вечір';

  @override
  String get partMorning => 'Ранок';

  @override
  String get partNoon => 'День';

  @override
  String get partEvening => 'Вечір';

  @override
  String get goalFun => 'Розважитися';

  @override
  String get goalFitness => 'Бути у формі';

  @override
  String get goalCompetition => 'Готуватися до змагань';

  @override
  String get goalLearning => 'Дізнаватися нове';

  @override
  String get goalMentoring => 'Ділитися досвідом';

  @override
  String get goalSocial => 'Знайомитися з новими людьми';

  @override
  String get freqMonthly => 'Кілька разів на місяць';

  @override
  String get freqWeekly => 'Раз на тиждень';

  @override
  String get freqFewWeekly => '2–3 рази на тиждень';

  @override
  String get freqDaily => 'Майже щодня';

  @override
  String get sizePair => 'Удвох';

  @override
  String get sizeSmall => 'Невелика група (3–6)';

  @override
  String get sizeLarge => 'Велика група';

  @override
  String get looking => 'Шукає команду';

  @override
  String lookingWithLevel(String level) {
    return 'Шукає команду · $level';
  }

  @override
  String reasonActivities(String list) {
    return 'Спільне заняття: $list';
  }

  @override
  String reasonInterests(String list) {
    return 'Спільні інтереси: $list';
  }

  @override
  String get reasonProvince => 'Ви в одній провінції';

  @override
  String reasonGroup(String group) {
    return 'Спільна група: $group';
  }

  @override
  String reasonGroups(int count) {
    return 'Спільних груп: $count';
  }

  @override
  String reasonLevel(String level) {
    return 'Однаковий рівень: $level';
  }

  @override
  String reasonTimes(String list) {
    return 'Зручний час: $list';
  }

  @override
  String reasonGoals(String list) {
    return 'Спільні цілі: $list';
  }

  @override
  String get reasonFrequency => 'Ви хочете зустрічатися однаково часто';

  @override
  String get hasVehicle => 'Має транспорт';

  @override
  String get hasEquipment => 'Має власне спорядження';

  @override
  String get usernameRequired => 'Виберіть ім’я користувача.';

  @override
  String usernameMin(int min) {
    return 'Ім’я користувача має містити щонайменше $min символи.';
  }

  @override
  String usernameMax(int max) {
    return 'Ім’я користувача може містити не більше $max символів.';
  }

  @override
  String get usernameChars =>
      'Використовуйте лише a–z, 0–9, підкреслення (_) і крапку (.).';

  @override
  String get usernameDots =>
      'Ім’я користувача не може починатися чи закінчуватися крапкою.';

  @override
  String get usernameDoubleDot => 'Не можна ставити дві крапки поспіль.';

  @override
  String get nameRequired => 'Введіть ім’я.';

  @override
  String nameMax(int max) {
    return 'Ім’я може містити не більше $max символів.';
  }

  @override
  String get editProfile => 'Редагувати профіль';

  @override
  String get save => 'Зберегти';

  @override
  String get profileInfo => 'Дані профілю';

  @override
  String get profileInfoHint => 'Ці дані бачать усі у вашому профілі.';

  @override
  String get yourName => 'Ваше ім’я';

  @override
  String get usernameEvery30 =>
      'Ім’я користувача можна змінювати раз на 30 днів.';

  @override
  String usernameLockedUntil(String date) {
    return 'Змінити можна після $date.';
  }

  @override
  String get about => 'Про себе';

  @override
  String get aboutHint => 'Розкажіть про себе й улюблені заняття.';

  @override
  String get interests => 'Інтереси';

  @override
  String interestsMax(int max) {
    return 'Можна вибрати до $max.';
  }

  @override
  String get cancel => 'Скасувати';

  @override
  String get saveChanges => 'Зберегти зміни';

  @override
  String get remove => 'Видалити';

  @override
  String get removeCover => 'Видалити обкладинку';

  @override
  String get addCover => 'Додати обкладинку';

  @override
  String get changeCover => 'Змінити обкладинку';

  @override
  String get changeAvatar => 'Змінити фото профілю';

  @override
  String get photos => 'Фото профілю й обкладинка';

  @override
  String get photosHint => 'JPEG, PNG або WebP · до 5 МБ';

  @override
  String get addAvatar => 'Додати фото профілю';

  @override
  String get removeAvatar => 'Видалити фото профілю';

  @override
  String get followers => 'Підписники';

  @override
  String get following => 'Підписки';

  @override
  String get privateLists =>
      'Це закритий обліковий запис. Підпишіться, щоб бачити його списки.';

  @override
  String get backToProfile => 'Повернутися до профілю';

  @override
  String get noFollowers => 'Підписників поки немає.';

  @override
  String get noFollowing => 'Поки ні на кого не підписаний.';

  @override
  String get refresh => 'Оновити';

  @override
  String get removeFollower => 'Видалити підписника';

  @override
  String removeFollowerBody(String username) {
    return 'Видалити $username з підписників? Людина не отримає сповіщення.';
  }

  @override
  String get removeAction => 'Видалити';

  @override
  String get friends => 'Ви друзі';

  @override
  String get followRequests => 'Запити на підписку';

  @override
  String get noFollowRequests =>
      'Запитів, що очікують, немає. Закриті облікові записи схвалюють запити тут.';

  @override
  String get approve => 'Схвалити';

  @override
  String get delete => 'Видалити';

  @override
  String get blockedAccounts => 'Заблоковані облікові записи';

  @override
  String get noBlocked =>
      'Ви нікого не заблокували. Заблокувати можна в меню профілю.';

  @override
  String get unblock => 'Розблокувати';

  @override
  String get onboardWho => 'Давайте познайомимося';

  @override
  String get onboardWhoHint => 'Виберіть ім’я та ім’я користувача для профілю.';

  @override
  String get onboardPhoto => 'Фото профілю';

  @override
  String get onboardPhotoHint =>
      'Щоб групи вас упізнавали. Можна додати й пізніше.';

  @override
  String get onboardInterests => 'Ваші інтереси';

  @override
  String onboardInterestsHint(int max) {
    return 'Виберіть до $max, щоб ми підібрали вам групи.';
  }

  @override
  String get back => 'Назад';

  @override
  String stepOf(int step, int total) {
    return 'Крок $step з $total';
  }

  @override
  String get signOut => 'Вийти';

  @override
  String get skipForNow => 'Пропустити поки';

  @override
  String get continueAction => 'Продовжити';

  @override
  String get finish => 'Готово';

  @override
  String get usernameHelper => 'Використовуйте малі літери, цифри, _ і .';

  @override
  String get avatarPreview => 'Попередній перегляд фото профілю';

  @override
  String get choosePhoto => 'Вибрати фото';

  @override
  String get chooseAnotherPhoto => 'Вибрати інше фото';

  @override
  String get profile => 'Профіль';

  @override
  String get settings => 'Налаштування';

  @override
  String get profileNotFound =>
      'Профіль не знайдено або він більше не видимий.';

  @override
  String get backToMyProfile => 'Повернутися до мого профілю';

  @override
  String suspendedUntil(String date) {
    return 'Цей обліковий запис призупинено до $date.';
  }

  @override
  String get followsYou => 'Стежить за вами';

  @override
  String get yourTeammate => 'Ваш напарник';

  @override
  String joined(String date) {
    return 'З нами з $date';
  }

  @override
  String followRequestsPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count запитів на підписку чекають схвалення.',
      few: '$count запити на підписку чекають схвалення.',
      one: '$count запит на підписку чекає схвалення.',
    );
    return '$_temp0';
  }

  @override
  String get review => 'Переглянути';

  @override
  String teammateRequestsPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'На вас чекають $count запитів у напарники.',
      few: 'На вас чекають $count запити в напарники.',
      one: 'На вас чекає $count запит у напарники.',
    );
    return '$_temp0';
  }

  @override
  String get youBlocked => 'Ви заблокували цей обліковий запис';

  @override
  String get youBlockedHint =>
      'Якщо розблокувати, ви знову бачитимете дописи одне одного.';

  @override
  String get privateAccount => 'Це закритий обліковий запис';

  @override
  String get privateAccountHint =>
      'Підпишіться, щоб бачити фото, відео й історії.';

  @override
  String get addInterestsNudge =>
      'Додайте інтереси — ми підберемо групи й напарників.';

  @override
  String get add => 'Додати';

  @override
  String blockTitle(String username) {
    return 'Заблокувати $username?';
  }

  @override
  String get blockBody =>
      'Людина не бачитиме ваш профіль, дописи й історії, не знайде вас і не зможе написати. Взаємні підписки припиняться. Про блокування вона не дізнається.';

  @override
  String get block => 'Заблокувати';

  @override
  String get becomeTeammates => 'Стати напарниками';

  @override
  String nowTeammates(String name) {
    return 'Тепер ви з $name напарники.';
  }

  @override
  String get acceptTeammate => 'Прийняти запит у напарники';

  @override
  String get requestWithdrawn => 'Запит відкликано.';

  @override
  String get withdrawTeammate => 'Відкликати запит у напарники';

  @override
  String get teammateEnded => 'Ви більше не напарники.';

  @override
  String get endTeammate => 'Перестати бути напарниками';

  @override
  String get moreOptions => 'Інші дії';

  @override
  String get linkCopied => 'Посилання на профіль скопійовано.';

  @override
  String get copyLink => 'Скопіювати посилання на профіль';

  @override
  String get removedFromFollowers => 'Видалено з підписників.';

  @override
  String get removeFromFollowers => 'Видалити з підписників';

  @override
  String get report => 'Поскаржитися';

  @override
  String get unblocked => 'Розблоковано.';

  @override
  String get statPosts => 'Дописи';

  @override
  String get statFollowers => 'Підписники';

  @override
  String get statFollowing => 'Підписки';

  @override
  String withdrawFollowBody(String username) {
    return 'Відкликати запит на підписку на $username?';
  }

  @override
  String unfollowBody(String username) {
    return 'Відписатися від $username?';
  }

  @override
  String unfollowPrivateBody(String username) {
    return 'Відписатися від $username? Обліковий запис закритий: щоб знову бачити дописи, доведеться надіслати новий запит.';
  }

  @override
  String get withdrawRequest => 'Відкликати запит';

  @override
  String get unfollow => 'Відписатися';

  @override
  String get followBack => 'Підписатися у відповідь';

  @override
  String get follow => 'Підписатися';

  @override
  String get requestSent => 'Запит надіслано';

  @override
  String get followingState => 'Ви підписані';

  @override
  String noAccountMatch(String query) {
    return 'За запитом «$query» облікових записів не знайдено.';
  }

  @override
  String get clearSearch => 'Очистити пошук';

  @override
  String get searchHint => 'Почніть вводити, щоб знайти людей або теги.';

  @override
  String get refreshSuggestions => 'Оновити рекомендації';

  @override
  String get suggestionsForYou => 'Рекомендації для вас';

  @override
  String mutualFollows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Підписані $count людей з ваших підписок',
      few: 'Підписані $count людини з ваших підписок',
      one: 'Підписана $count людина з ваших підписок',
    );
    return '$_temp0';
  }

  @override
  String get popularAccount => 'Популярний обліковий запис';

  @override
  String get seePackage => 'Переглянути тариф';

  @override
  String requestSentNotify(String name) {
    return 'Запит надіслано. Повідомимо, коли $name прийме його.';
  }

  @override
  String becomeTeammatesWith(String name) {
    return 'Стати напарником $name';
  }

  @override
  String get shortMessage => 'Коротке повідомлення (необов’язково)';

  @override
  String get shortMessageHint => 'У суботу зранку в парку?';

  @override
  String get sendRequest => 'Надіслати запит';

  @override
  String get findTeammates => 'Знайти напарників';

  @override
  String get myTeammatePrefs => 'Мої налаштування пошуку напарників';

  @override
  String get tabSuggestions => 'Рекомендації';

  @override
  String get tabRequests => 'Запити';

  @override
  String tabRequestsCount(int count) {
    return 'Запити ($count)';
  }

  @override
  String get tabMyTeam => 'Моя команда';

  @override
  String get findYourTeammate => 'Знайдіть напарника';

  @override
  String waitingForYou(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count людей хочуть стати вашими напарниками',
      few: '$count людини хочуть стати вашими напарниками',
      one: '$count людина хоче стати вашим напарником',
    );
    return '$_temp0';
  }

  @override
  String get teammatesLocked =>
      'Рекомендації, надсилання й прийняття запитів і листування з напарниками доступні в тарифі «Напарник».';

  @override
  String get beVisible => 'Станьте помітними';

  @override
  String get beVisibleBody =>
      'Увімкніть «Шукаю команду», і люди зі схожими інтересами зможуть надсилати вам запити.';

  @override
  String get setPrefs => 'Налаштувати вподобання';

  @override
  String get nowPublicSuggest =>
      'Тепер ваш обліковий запис відкритий — ви можете з’являтися в рекомендаціях.';

  @override
  String get privateHidden =>
      'Ваш обліковий запис закритий — вас немає в рекомендаціях';

  @override
  String get privateHiddenBody =>
      'Закриті облікові записи не потрапляють у рекомендації напарників. Якщо відкрити обліковий запис, запити на підписку, що очікують, теж буде схвалено.';

  @override
  String get makePublic => 'Відкрити обліковий запис';

  @override
  String get noSuggestions =>
      'Поки що відповідних людей немає. Заповніть інтереси й уподобання — рекомендацій побільшає.';

  @override
  String quoted(String text) {
    return '«$text»';
  }

  @override
  String get whySuggested => 'Чому рекомендовано';

  @override
  String get noPendingTeammate => 'Запитів у напарники, що очікують, немає.';

  @override
  String get seeSuggestions => 'Переглянути рекомендації';

  @override
  String get incoming => 'Вхідні';

  @override
  String get accept => 'Прийняти';

  @override
  String get decline => 'Відхилити';

  @override
  String get requestDeclined => 'Запит відхилено.';

  @override
  String get outgoing => 'Надіслані';

  @override
  String get awaitingReply => 'Очікує відповіді';

  @override
  String get withdraw => 'Відкликати';

  @override
  String get noTeammates =>
      'У вас поки немає напарників. Почніть із запиту комусь із рекомендацій.';

  @override
  String optionsFor(String name) {
    return 'Дії для $name';
  }

  @override
  String get teammatePrefs => 'Налаштування пошуку напарників';

  @override
  String get prefsSavedVisible =>
      'Уподобання збережено. Тепер ви з’являєтеся в рекомендаціях.';

  @override
  String get prefsSaved => 'Уподобання збережено.';

  @override
  String get whatToDo => 'Чим хочете займатися?';

  @override
  String activitiesHint(int max) {
    return 'Заняття, для яких ви шукаєте напарників. До $max.';
  }

  @override
  String get yourLevel => 'Ваш рівень';

  @override
  String get yourGoals => 'Ваші цілі';

  @override
  String get multipleChoice => 'Можна вибрати кілька.';

  @override
  String get howOften => 'Як часто хочете зустрічатися?';

  @override
  String get whenFree => 'Коли ви вільні?';

  @override
  String get whenFreeHint => 'Позначте зручний час.';

  @override
  String get whatTeam => 'Яку команду хочете?';

  @override
  String get whichProvince => 'У якій ви провінції?';

  @override
  String get provinceHint =>
      'Використовується лише для підбору й не видна в профілі.';

  @override
  String get province => 'Провінція';

  @override
  String get ratherNotSay => 'Не хочу вказувати';

  @override
  String get extras => 'Додатково';

  @override
  String get iHaveVehicle => 'Маю транспорт';

  @override
  String get iHaveVehicleHint => 'Можу підвезти.';

  @override
  String get iHaveEquipment => 'Маю власне спорядження';

  @override
  String get iHaveEquipmentHint =>
      'Велосипед, намет, ракетка чи інше спорядження — є.';

  @override
  String get describeYourself => 'Розкажіть про себе';

  @override
  String get describeHint => 'Показується під вашим ім’ям у рекомендаціях.';

  @override
  String get describeExample =>
      'Шукаю компанію для ранкових прогулянок у вихідні.';

  @override
  String get willAppear => 'Ви з’явитеся в рекомендаціях.';

  @override
  String get notAppearing => 'Зараз вас немає в рекомендаціях.';

  @override
  String get lookingForTeam => 'Шукаю команду';

  @override
  String get lookingOn =>
      'Ви в рекомендаціях — вам можуть надсилати запити в напарники.';

  @override
  String get lookingOff =>
      'Увімкніть — і вас знайдуть люди зі схожими інтересами. Закриті облікові записи не потрапляють у рекомендації.';

  @override
  String prefsComplete(int percent) {
    return 'Уподобання заповнено на $percent%';
  }

  @override
  String get prefsCompleteHint =>
      'Що більше заповните, то точніші рекомендації.';

  @override
  String get weekday => 'Будні';

  @override
  String get weekend => 'Вихідні';

  @override
  String get username => 'Ім’я користувача';

  @override
  String get available => 'Вільне';

  @override
  String get taken => 'Зайняте';

  @override
  String blockedUser(String username) {
    return '$username заблоковано.';
  }
}
