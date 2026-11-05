// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'matching_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class MatchingL10nUk extends MatchingL10n {
  MatchingL10nUk([String locale = 'uk']) : super(locale);

  @override
  String get unsupportedImage =>
      'Можна завантажувати лише фото JPEG, PNG або WebP.';

  @override
  String get modeFriend => 'Дружба';

  @override
  String get modeDating => 'Знайомства';

  @override
  String get genderWoman => 'Жінка';

  @override
  String get genderMan => 'Чоловік';

  @override
  String get genderNonbinary => 'Небінарна людина';

  @override
  String get adultsOnly => 'Знайомства — лише для тих, кому є 18.';

  @override
  String get pickMode =>
      'Виберіть хоча б один режим: «Дружба» або «Знайомства».';

  @override
  String get pickInterest => 'Укажіть, кого ви шукаєте в «Знайомствах».';

  @override
  String get ageRangeInvalid => 'Неправильний діапазон віку.';

  @override
  String sharedGroup(String group) {
    return 'Спільна група: $group';
  }

  @override
  String sharedGroupsMore(String group, int count) {
    return 'Спільні: $group і ще груп: $count';
  }

  @override
  String get pkgReveal => 'Мої пари';

  @override
  String get pkgRevealText =>
      'Дізнайтеся, хто ваша пара: ім’я, фото й профіль.';

  @override
  String get pkgChat => 'Чат пари';

  @override
  String get pkgChatText => 'Пишіть своїм парам. Містить перегляд пар.';

  @override
  String get pkgAdmirers => 'Кому ви сподобались';

  @override
  String get pkgAdmirersText =>
      'Дивіться, кому ви сподобались, і одразу створюйте пару взаємним лайком.';

  @override
  String get pkgUnlimited => 'Безлімітні лайки';

  @override
  String get pkgUnlimitedText => 'Без денного ліміту; є скасування й фільтри.';

  @override
  String get pkgSuper => 'Суперлайк';

  @override
  String get pkgSuperText =>
      '5 суперлайків на день: людина побачить вас першим у своїй колоді.';

  @override
  String get pkgBoost => 'Буст';

  @override
  String get pkgBoostText =>
      'Раз на день — 30 хвилин угорі колод у спільних групах.';

  @override
  String get pkgTeammates => 'Напарник';

  @override
  String get pkgTeammatesText =>
      'Надсилайте запити напарникам і спілкуйтеся з ними.';

  @override
  String get pkgAll => 'Усе в одному';

  @override
  String get pkgAllText =>
      'Усі тарифи в одному — значно вигідніше, ніж окремо.';

  @override
  String get superLikedYou => 'Поставив(-ла) вам суперлайк';

  @override
  String get options => 'Дії';

  @override
  String get fullProfile => 'Увесь профіль';

  @override
  String get stampLike => 'ЛАЙК';

  @override
  String get stampPass => 'НІ';

  @override
  String get stampSuper => 'СУПЕР';

  @override
  String photoOf(String name, int number) {
    return '$name, фото $number';
  }

  @override
  String get about => 'Про себе';

  @override
  String get interests => 'Інтереси';

  @override
  String get sharedGroupsTitle => 'Спільні групи';

  @override
  String get createProfileTitle => 'Створити профіль знайомств';

  @override
  String get myProfile => 'Мій профіль знайомств';

  @override
  String get birthDateLabel => 'Дата народження';

  @override
  String get pickBasics => 'Укажіть дату народження, стать і провінцію.';

  @override
  String get confirmAgeConsent =>
      'Щоб продовжити, підтвердьте, що вам є 18, і дайте явну згоду.';

  @override
  String profileReady(int min) {
    return 'Профіль готовий. Тепер додайте фото (щонайменше $min).';
  }

  @override
  String get saved => 'Збережено.';

  @override
  String get pickBirthDate => 'Вибрати дату народження';

  @override
  String ageNote(int age) {
    return 'Вік: $age · у картці видно лише вік';
  }

  @override
  String get gender => 'Стать';

  @override
  String get province => 'Провінція';

  @override
  String get aboutHint => 'Розкажіть про себе';

  @override
  String get jobOptional => 'Професія (необов’язково)';

  @override
  String get educationOptional => 'Освіта (необов’язково)';

  @override
  String get interestsFromProfile =>
      'Інтереси беруться з вашого основного профілю.';

  @override
  String get lookingFor => 'Що ви шукаєте?';

  @override
  String get friendHint =>
      'Люди, з якими можна ходити на зустрічі й спілкуватися';

  @override
  String get datingHint => 'Романтичні стосунки';

  @override
  String get whoLookingFor => 'Кого ви шукаєте?';

  @override
  String ageRange(int min, int max) {
    return 'Вік: $min–$max';
  }

  @override
  String get consentTitle => 'Згода';

  @override
  String get iam18 => 'Мені більше 18 років.';

  @override
  String get consentText =>
      'Я даю явну згоду на обробку моєї статі, того, кого я шукаю, дати народження, провінції та фотографій для знайомств і на їх показ людям зі спільних груп, які ввімкнули знайомства. Я можу відкликати згоду будь-коли, видаливши дані знайомств.';

  @override
  String get createProfile => 'Створити профіль';

  @override
  String get save => 'Зберегти';

  @override
  String get photos => 'Фото';

  @override
  String photosMin(int min) {
    return 'Додайте фото (щонайменше $min), щоб картку було видно. Перше — обкладинка.';
  }

  @override
  String photosMax(int max) {
    return 'До $max фото. Перше — обкладинка; торкніться фото, щоб змінити.';
  }

  @override
  String get addPhoto => 'Додати фото';

  @override
  String get cover => 'Обкладинка';

  @override
  String get removePhoto => 'Видалити фото';

  @override
  String get pauseProfile => 'Призупинити профіль';

  @override
  String get pauseHint =>
      'Вас ніхто не бачить, нові картки не надходять; пари й чати зберігаються.';

  @override
  String get deleteData => 'Видалити дані знайомств';

  @override
  String get deleteDataHint =>
      'Профіль, фото й лайки видаляються, пари скасовуються. Згоду відкликано.';

  @override
  String get deleteDataTitle => 'Видалити дані знайомств';

  @override
  String get deleteDataBody =>
      'Профіль знайомств, фото й лайки буде видалено назавжди, усі пари скасуються. Скасувати не можна.';

  @override
  String get delete => 'Видалити';

  @override
  String get dataDeleted => 'Дані знайомств видалено.';

  @override
  String get itsAMatch => 'У вас пара!';

  @override
  String bothLiked(String name) {
    return 'Ви і $name сподобались одне одному.';
  }

  @override
  String get keepSwiping => 'Гортати далі';

  @override
  String get sendMessage => 'Написати';

  @override
  String get reportProfile => 'Поскаржитися на профіль';

  @override
  String get reportPhoto => 'Поскаржитися на фото';

  @override
  String get block => 'Заблокувати';

  @override
  String get blockHint => 'Ви більше ніде не побачите одне одного.';

  @override
  String get cancel => 'Скасувати';

  @override
  String get newMatch => 'У вас нова пара!';

  @override
  String tapToSee(String date) {
    return 'Торкніться, щоб дізнатися, хто це · $date';
  }

  @override
  String get revealReason =>
      'У вас пара! Підключіть тариф «Мої пари», щоб дізнатися, хто це.';

  @override
  String get keepFriend => 'Залишитися лише друзями';

  @override
  String get keepDating => 'Залишити лише знайомства';

  @override
  String keepFriendBody(String name) {
    return 'Пара в «Знайомствах» з $name скасується для обох; дружба й чат збережуться.';
  }

  @override
  String keepDatingBody(String name) {
    return 'Пара в «Дружбі» з $name скасується для обох; знайомства й чат збережуться.';
  }

  @override
  String get keptFriend => 'Тепер ви пара лише в «Дружбі».';

  @override
  String get keptDating => 'Тепер ви пара лише в «Знайомствах».';

  @override
  String get continueAction => 'Продовжити';

  @override
  String get endMatch => 'Скасувати пару';

  @override
  String endMatchBody(String name) {
    return 'Пару з $name буде скасовано, чат закриється для обох. Скасувати не можна.';
  }

  @override
  String get end => 'Скасувати';

  @override
  String get matchEnded => 'Пару скасовано.';

  @override
  String get noMatches => 'Пар поки немає. Тут з’являться взаємні симпатії.';

  @override
  String get backToDiscover => 'Повернутися до пошуку';

  @override
  String get report => 'Поскаржитися';

  @override
  String get matching => 'Знайомства';

  @override
  String get admirers => 'Кому ви сподобались';

  @override
  String get packages => 'Тарифи';

  @override
  String get more => 'Ще';

  @override
  String get filtersLocked =>
      'Фільтри за віком, провінцією й інтересами — у тарифі «Безлімітні лайки».';

  @override
  String get filters => 'Фільтри';

  @override
  String get suspended =>
      'Команда платформи закрила ваш профіль знайомств. Подробиці — у підтримці.';

  @override
  String addPhotosToStart(int min) {
    return 'Додайте фото (щонайменше $min), щоб показати картку й почати пошук.';
  }

  @override
  String get paused =>
      'Профіль призупинено — вас ніхто не бачить. Пари й чати збережено.';

  @override
  String get likesOut =>
      'Безкоштовні лайки на сьогодні скінчилися. З «Безлімітними лайками» — без обмежень.';

  @override
  String get supersOut =>
      'Суперлайки на сьогодні скінчилися. Завтра оновляться.';

  @override
  String get superUsed =>
      'Суперлайк на сьогодні використано. З тарифом «Суперлайк» — 5 на день.';

  @override
  String get rewindLocked =>
      'Повернути випадково пропущену людину можна з «Безлімітними лайками».';

  @override
  String rewoundTo(String mode) {
    return 'Остання пропущена людина повернулася в колоду «$mode».';
  }

  @override
  String boostReason(int minutes) {
    return 'З бустом ви $minutes хв. угорі колод.';
  }

  @override
  String boosting(int minutes) {
    return 'Буст активний. Залишилося $minutes хв.';
  }

  @override
  String get boostUsed => 'Буст на сьогодні використано. Завтра оновиться.';

  @override
  String get boost => 'Буст';

  @override
  String boostBody(int minutes) {
    return '$minutes хв. ви першим у колодах людей зі спільних груп. Раз на день.';
  }

  @override
  String boosted(int minutes) {
    return 'Буст увімкнено! Ви вгорі $minutes хв.';
  }

  @override
  String get deckEmpty =>
      'Поки нікого немає. З’являться, коли ви вступите до груп, а люди ввімкнуть знайомства.';

  @override
  String get deckEmptyFiltered =>
      'Під фільтри більше ніхто не підходить. Розширте їх.';

  @override
  String get refresh => 'Оновити';

  @override
  String get clearFilters => 'Скинути фільтри';

  @override
  String allowanceUnlimited(int supers) {
    return 'Лайки без ліміту · суперлайків: $supers.';
  }

  @override
  String get allowanceOut => 'Лайки на сьогодні скінчилися; завтра оновляться.';

  @override
  String allowance(int likes, int supers) {
    return 'Сьогодні залишилося лайків: $likes, суперлайків: $supers.';
  }

  @override
  String get undo => 'Повернути';

  @override
  String get pass => 'Пропустити';

  @override
  String get superLike => 'Суперлайк';

  @override
  String get like => 'Подобається';

  @override
  String get introTitle => 'Знайомтеся з новими людьми зі спільних груп';

  @override
  String get intro1 =>
      'Ви бачите лише тих, хто ввімкнув знайомства в групах, де ви є чи на які підписані.';

  @override
  String get intro2 =>
      'Свайп праворуч — лайк, ліворуч — пропустити, вгору — суперлайк.';

  @override
  String get intro3 =>
      'Якщо ви сподобались одне одному — ви пара. Писати парі можна з тарифом «Чат пари».';

  @override
  String get intro4 =>
      '«Дружба» і «Знайомства» — різні режими; виберіть один або обидва.';

  @override
  String get intro5 =>
      'Профіль бачать лише ті, хто ввімкнув знайомства. Його можна призупинити чи видалити будь-коли.';

  @override
  String get createMyProfile => 'Створити профіль знайомств';

  @override
  String seePackageOf(String package) {
    return 'Тариф «$package»';
  }

  @override
  String get allPackages => 'Усі тарифи';

  @override
  String get packagesTitle => 'Тарифи знайомств';

  @override
  String get packagesIntro =>
      'Профіль і свайпи безкоштовні. Кожна функція — окремий тариф; беріть лише потрібне.';

  @override
  String get adminAllOpen => 'Як адміністратору вам доступні всі тарифи';

  @override
  String openUntil(String date) {
    return 'Діє до $date';
  }

  @override
  String ageFilter(int min, int max) {
    return 'Вік: $min – $max';
  }

  @override
  String get allProvinces => 'Усі провінції';

  @override
  String get interest => 'Інтерес';

  @override
  String get all => 'Усі';

  @override
  String get apply => 'Застосувати';

  @override
  String get clear => 'Скинути';

  @override
  String get noAdmirers =>
      'Поки лайків немає. Гортайте далі — тут з’являться ті, кому ви сподобались.';

  @override
  String get backToSwiping => 'Повернутися до свайпів';

  @override
  String get likeAndMatch => 'Лайк і пара';

  @override
  String get noPendingLikes => 'Лайків поки немає';

  @override
  String likedYouCount(int count) {
    return 'Ви сподобались: $count';
  }

  @override
  String get admirersPitch =>
      'З тарифом «Кому ви сподобались» дізнайтеся, хто це, і одразу створюйте пару.';

  @override
  String get seePackage => 'Переглянути тариф';
}
