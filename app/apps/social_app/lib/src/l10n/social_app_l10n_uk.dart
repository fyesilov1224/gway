// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'social_app_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class SocialAppL10nUk extends SocialAppL10n {
  SocialAppL10nUk([String locale = 'uk']) : super(locale);

  @override
  String get posts => 'Дописи';

  @override
  String get newPost => 'Новий допис';

  @override
  String get noOwnPosts =>
      'Ви ще нічого не публікували. Поділіться першим фото чи відео.';

  @override
  String get noPosts => 'Дописів поки немає.';

  @override
  String get shareFirstOwn => 'Опублікувати перший допис';

  @override
  String get groupFirstPost => 'Опублікуйте перший допис у стрічці групи.';

  @override
  String get groupNoPosts => 'У цій групі ще немає дописів.';

  @override
  String get shareFirstGroup => 'Опублікувати першим';

  @override
  String get groupNotFound => 'Групу не знайдено.';

  @override
  String get memoriesEmpty =>
      'Спогадів поки немає. Учасники можуть додати сюди свої фото.';

  @override
  String get plan => 'Тариф';

  @override
  String get payment => 'Оплата';

  @override
  String get onlyOwnerBilling => 'Керувати тарифами може лише власник групи.';

  @override
  String get backToGroup => 'Повернутися до групи';

  @override
  String get writeSupportAboutGroup =>
      'Написати команді платформи про цю групу';

  @override
  String get search => 'Пошук';

  @override
  String get notifications => 'Сповіщення';

  @override
  String get goodNight => 'Доброї ночі';

  @override
  String get goodMorning => 'Доброго ранку';

  @override
  String get goodAfternoon => 'Добрий день';

  @override
  String get goodEvening => 'Добрий вечір';

  @override
  String greetingName(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String get tabToday => 'Сьогодні';

  @override
  String get tabGroups => 'Групи';

  @override
  String get tabCalendar => 'Календар';

  @override
  String get tabMe => 'Я';

  @override
  String get tonightSay => 'Вільні? Скажіть і зберіть столик';

  @override
  String get tonightTableSet => 'Ваш столик зібрано';

  @override
  String get tonightInvited => 'Вас запросили до столика';

  @override
  String tonightFreeWithYou(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count людей вільні, як і ви',
      few: '$count людини вільні, як і ви',
      one: '$count людина вільна, як і ви',
    );
    return '$_temp0';
  }

  @override
  String get tonightFreeUntil => 'Ви вільні · до 4:00';

  @override
  String tonightFreeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count людей вільні сьогодні ввечері',
      few: '$count людини вільні сьогодні ввечері',
      one: '$count людина вільна сьогодні ввечері',
    );
    return '$_temp0';
  }

  @override
  String get upcomingNone => 'Плани ваших груп';

  @override
  String upcomingMine(int count, int mine) {
    return '$count планів · $mine участей';
  }

  @override
  String upcomingCount(int count) {
    return '$count планів, 60 днів';
  }

  @override
  String get forToday => 'На сьогодні';

  @override
  String get tonight => 'Сьогодні ввечері';

  @override
  String get upcoming => 'Незабаром';

  @override
  String get share => 'Поділитися';

  @override
  String get post => 'Допис';

  @override
  String get postHint => 'До 10 фото або відео';

  @override
  String get story => 'Історія';

  @override
  String get storyHint => 'Видно 24 години';

  @override
  String get group => 'Група';

  @override
  String get groupHint => 'Створіть власну спільноту';

  @override
  String get create => 'Створити';

  @override
  String get messages => 'Повідомлення';

  @override
  String get matching => 'Знайомства';

  @override
  String get myGroups => 'Мої групи';

  @override
  String get pageNotFound =>
      'Сторінку не знайдено. Можливо, посилання застаріло або неправильне.';

  @override
  String get backHome => 'На головну';

  @override
  String get groupsLeague => 'Ліга груп';

  @override
  String get exploreOnMap => 'Дослідити на мапі';

  @override
  String get yearMenu => 'Підсумки року, моя мапа відкриттів і мої знайомства';

  @override
  String get yearSummary => 'Підсумки року';

  @override
  String get yearSummaryHint =>
      'Ваші зустрічі за цей рік — картка, якою можна поділитися';

  @override
  String get explorationMap => 'Моя мапа відкриттів';

  @override
  String get explorationMapHint => 'Провінції подій, у яких ви брали участь';

  @override
  String get metPeople => 'Мої знайомства';

  @override
  String get metPeopleHint => 'Люди, з якими ви потиснули руки на подіях';

  @override
  String get findTeammates => 'Знайти напарників';

  @override
  String get saved => 'Збережене';

  @override
  String get gateError =>
      'Не вдалося завантажити ваші дані. Перевірте з’єднання й спробуйте ще раз.';

  @override
  String get searchPeople => 'Пошук людей';

  @override
  String get clearSearch => 'Очистити пошук';

  @override
  String get settings => 'Налаштування';

  @override
  String get editProfile => 'Редагувати профіль';

  @override
  String get teammatePrefs => 'Налаштування пошуку напарників';

  @override
  String get matchProfile => 'Профіль знайомств';

  @override
  String get voiceCalls => 'Голосові дзвінки';

  @override
  String get blockedAccounts => 'Заблоковані облікові записи';

  @override
  String get storyArchive => 'Архів історій';

  @override
  String get notificationPrefs => 'Налаштування сповіщень';

  @override
  String get mySanctions => 'Мої санкції в групах';

  @override
  String get userGuide => 'Посібник користувача';

  @override
  String get supportFeedback => 'Підтримка та відгуки';

  @override
  String newReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count нових відповідей',
      few: '$count нові відповіді',
      one: '$count нова відповідь',
    );
    return '$_temp0';
  }

  @override
  String get twoFactor => 'Двоетапна перевірка';

  @override
  String get legalDocuments => 'Юридичні документи';

  @override
  String get deleteAccount => 'Видалити обліковий запис';

  @override
  String get signOut => 'Вийти';

  @override
  String get nowPrivate => 'Тепер ваш обліковий запис закритий.';

  @override
  String get nowPublic =>
      'Тепер ваш обліковий запис відкритий; запити, що очікували, схвалено.';

  @override
  String get privateAccount => 'Закритий обліковий запис';

  @override
  String get privateAccountHint =>
      'Якщо ввімкнено, ваші дописи й історії бачать лише схвалені вами підписники.';

  @override
  String get groupsNowPublic => 'Тепер ваші групи видно всім у профілі.';

  @override
  String get groupsNowMembers =>
      'Тепер ваші групи бачать лише учасники тих самих груп.';

  @override
  String get showGroups => 'Показувати мої групи в профілі';

  @override
  String get showGroupsHint =>
      'Якщо вимкнено, про ваше членство в групі знають лише її учасники; адміністратори інших груп його не бачать.';

  @override
  String get language => 'Мова';
}
