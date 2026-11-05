// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'matching_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class MatchingL10nRu extends MatchingL10n {
  MatchingL10nRu([String locale = 'ru']) : super(locale);

  @override
  String get unsupportedImage =>
      'Можно загружать только фото JPEG, PNG или WebP.';

  @override
  String get modeFriend => 'Дружба';

  @override
  String get modeDating => 'Знакомства';

  @override
  String get genderWoman => 'Женщина';

  @override
  String get genderMan => 'Мужчина';

  @override
  String get genderNonbinary => 'Небинарный человек';

  @override
  String get adultsOnly => 'Знакомства — только для тех, кому есть 18.';

  @override
  String get pickMode =>
      'Выберите хотя бы один режим: «Дружба» или «Знакомства».';

  @override
  String get pickInterest => 'Укажите, кого вы ищете в «Знакомствах».';

  @override
  String get ageRangeInvalid => 'Неверный диапазон возраста.';

  @override
  String sharedGroup(String group) {
    return 'Общая группа: $group';
  }

  @override
  String sharedGroupsMore(String group, int count) {
    return 'Общие: $group и ещё групп: $count';
  }

  @override
  String get pkgReveal => 'Мои пары';

  @override
  String get pkgRevealText => 'Узнайте, кто ваша пара: имя, фото и профиль.';

  @override
  String get pkgChat => 'Чат пары';

  @override
  String get pkgChatText => 'Пишите своим парам. Включает просмотр пар.';

  @override
  String get pkgAdmirers => 'Кому вы понравились';

  @override
  String get pkgAdmirersText =>
      'Смотрите, кому вы понравились, и сразу создавайте пару ответным лайком.';

  @override
  String get pkgUnlimited => 'Безлимитные лайки';

  @override
  String get pkgUnlimitedText => 'Без дневного лимита; есть отмена и фильтры.';

  @override
  String get pkgSuper => 'Суперлайк';

  @override
  String get pkgSuperText =>
      '5 суперлайков в день: человек увидит вас первым в своей колоде.';

  @override
  String get pkgBoost => 'Буст';

  @override
  String get pkgBoostText =>
      'Раз в день — 30 минут вверху колод в общих группах.';

  @override
  String get pkgTeammates => 'Напарник';

  @override
  String get pkgTeammatesText =>
      'Отправляйте запросы напарникам и общайтесь с ними.';

  @override
  String get pkgAll => 'Всё в одном';

  @override
  String get pkgAllText =>
      'Все тарифы в одном — гораздо выгоднее, чем по отдельности.';

  @override
  String get superLikedYou => 'Поставил(а) вам суперлайк';

  @override
  String get options => 'Действия';

  @override
  String get fullProfile => 'Весь профиль';

  @override
  String get stampLike => 'ЛАЙК';

  @override
  String get stampPass => 'НЕТ';

  @override
  String get stampSuper => 'СУПЕР';

  @override
  String photoOf(String name, int number) {
    return '$name, фото $number';
  }

  @override
  String get about => 'О себе';

  @override
  String get interests => 'Интересы';

  @override
  String get sharedGroupsTitle => 'Общие группы';

  @override
  String get createProfileTitle => 'Создать профиль знакомств';

  @override
  String get myProfile => 'Мой профиль знакомств';

  @override
  String get birthDateLabel => 'Дата рождения';

  @override
  String get pickBasics => 'Укажите дату рождения, пол и провинцию.';

  @override
  String get confirmAgeConsent =>
      'Чтобы продолжить, подтвердите, что вам есть 18, и дайте явное согласие.';

  @override
  String profileReady(int min) {
    return 'Профиль готов. Теперь добавьте фото (минимум $min).';
  }

  @override
  String get saved => 'Сохранено.';

  @override
  String get pickBirthDate => 'Выбрать дату рождения';

  @override
  String ageNote(int age) {
    return 'Возраст: $age · в карточке видно только возраст';
  }

  @override
  String get gender => 'Пол';

  @override
  String get province => 'Провинция';

  @override
  String get aboutHint => 'Расскажите о себе';

  @override
  String get jobOptional => 'Профессия (необязательно)';

  @override
  String get educationOptional => 'Образование (необязательно)';

  @override
  String get interestsFromProfile =>
      'Интересы берутся из вашего основного профиля.';

  @override
  String get lookingFor => 'Что вы ищете?';

  @override
  String get friendHint =>
      'Люди, с которыми можно ходить на встречи и общаться';

  @override
  String get datingHint => 'Романтические отношения';

  @override
  String get whoLookingFor => 'Кого вы ищете?';

  @override
  String ageRange(int min, int max) {
    return 'Возраст: $min–$max';
  }

  @override
  String get consentTitle => 'Согласие';

  @override
  String get iam18 => 'Мне больше 18 лет.';

  @override
  String get consentText =>
      'Я даю явное согласие на обработку моего пола, того, кого я ищу, даты рождения, провинции и фотографий для знакомств и на их показ людям из общих групп, включившим знакомства. Я могу отозвать согласие в любой момент, удалив данные знакомств.';

  @override
  String get createProfile => 'Создать профиль';

  @override
  String get save => 'Сохранить';

  @override
  String get photos => 'Фото';

  @override
  String photosMin(int min) {
    return 'Добавьте фото (минимум $min), чтобы карточку было видно. Первое — обложка.';
  }

  @override
  String photosMax(int max) {
    return 'До $max фото. Первое — обложка; нажмите на фото, чтобы сменить.';
  }

  @override
  String get addPhoto => 'Добавить фото';

  @override
  String get cover => 'Обложка';

  @override
  String get removePhoto => 'Удалить фото';

  @override
  String get pauseProfile => 'Приостановить профиль';

  @override
  String get pauseHint =>
      'Вас никто не видит, новые карточки не приходят; пары и чаты сохраняются.';

  @override
  String get deleteData => 'Удалить данные знакомств';

  @override
  String get deleteDataHint =>
      'Профиль, фото и лайки удаляются, пары распадаются. Согласие считается отозванным.';

  @override
  String get deleteDataTitle => 'Удалить данные знакомств';

  @override
  String get deleteDataBody =>
      'Профиль знакомств, фото и лайки удалятся навсегда, все пары распадутся. Отменить нельзя.';

  @override
  String get delete => 'Удалить';

  @override
  String get dataDeleted => 'Данные знакомств удалены.';

  @override
  String get itsAMatch => 'У вас пара!';

  @override
  String bothLiked(String name) {
    return 'Вы и $name понравились друг другу.';
  }

  @override
  String get keepSwiping => 'Листать дальше';

  @override
  String get sendMessage => 'Написать';

  @override
  String get reportProfile => 'Пожаловаться на профиль';

  @override
  String get reportPhoto => 'Пожаловаться на фото';

  @override
  String get block => 'Заблокировать';

  @override
  String get blockHint => 'Вы больше нигде не увидите друг друга.';

  @override
  String get cancel => 'Отмена';

  @override
  String get newMatch => 'У вас новая пара!';

  @override
  String tapToSee(String date) {
    return 'Нажмите, чтобы узнать, кто это · $date';
  }

  @override
  String get revealReason =>
      'У вас пара! Подключите тариф «Мои пары», чтобы узнать, кто это.';

  @override
  String get keepFriend => 'Остаться только друзьями';

  @override
  String get keepDating => 'Оставить только знакомства';

  @override
  String keepFriendBody(String name) {
    return 'Пара в «Знакомствах» с $name распадётся для обоих; дружба и чат сохранятся.';
  }

  @override
  String keepDatingBody(String name) {
    return 'Пара в «Дружбе» с $name распадётся для обоих; знакомства и чат сохранятся.';
  }

  @override
  String get keptFriend => 'Теперь вы пара только в «Дружбе».';

  @override
  String get keptDating => 'Теперь вы пара только в «Знакомствах».';

  @override
  String get continueAction => 'Продолжить';

  @override
  String get endMatch => 'Удалить пару';

  @override
  String endMatchBody(String name) {
    return 'Пара с $name распадётся, чат закроется для обоих. Отменить нельзя.';
  }

  @override
  String get end => 'Удалить';

  @override
  String get matchEnded => 'Пара удалена.';

  @override
  String get noMatches => 'Пар пока нет. Здесь появятся взаимные симпатии.';

  @override
  String get backToDiscover => 'Вернуться к поиску';

  @override
  String get report => 'Пожаловаться';

  @override
  String get matching => 'Знакомства';

  @override
  String get admirers => 'Кому вы понравились';

  @override
  String get packages => 'Тарифы';

  @override
  String get more => 'Ещё';

  @override
  String get filtersLocked =>
      'Фильтры по возрасту, провинции и интересам — в тарифе «Безлимитные лайки».';

  @override
  String get filters => 'Фильтры';

  @override
  String get suspended =>
      'Команда платформы закрыла ваш профиль знакомств. Подробности — в поддержке.';

  @override
  String addPhotosToStart(int min) {
    return 'Добавьте фото (минимум $min), чтобы показать карточку и начать поиск.';
  }

  @override
  String get paused =>
      'Профиль приостановлен — вас никто не видит. Пары и чаты сохранены.';

  @override
  String get likesOut =>
      'Бесплатные лайки на сегодня закончились. С «Безлимитными лайками» — без ограничений.';

  @override
  String get supersOut =>
      'Суперлайки на сегодня закончились. Завтра обновятся.';

  @override
  String get superUsed =>
      'Суперлайк на сегодня использован. С тарифом «Суперлайк» — 5 в день.';

  @override
  String get rewindLocked =>
      'Вернуть случайно пропущенного человека можно с «Безлимитными лайками».';

  @override
  String rewoundTo(String mode) {
    return 'Последний пропущенный человек вернулся в колоду «$mode».';
  }

  @override
  String boostReason(int minutes) {
    return 'С бустом вы $minutes мин. наверху колод.';
  }

  @override
  String boosting(int minutes) {
    return 'Буст активен. Осталось $minutes мин.';
  }

  @override
  String get boostUsed => 'Буст на сегодня использован. Завтра обновится.';

  @override
  String get boost => 'Буст';

  @override
  String boostBody(int minutes) {
    return '$minutes мин. вы первым в колодах людей из общих групп. Раз в день.';
  }

  @override
  String boosted(int minutes) {
    return 'Буст включён! Вы наверху $minutes мин.';
  }

  @override
  String get deckEmpty =>
      'Пока никого нет. Появятся, когда вы вступите в группы, а люди включат знакомства.';

  @override
  String get deckEmptyFiltered =>
      'Под фильтры больше никто не подходит. Расширьте их.';

  @override
  String get refresh => 'Обновить';

  @override
  String get clearFilters => 'Сбросить фильтры';

  @override
  String allowanceUnlimited(int supers) {
    return 'Лайки без лимита · суперлайков: $supers.';
  }

  @override
  String get allowanceOut => 'Лайки на сегодня закончились; завтра обновятся.';

  @override
  String allowance(int likes, int supers) {
    return 'Сегодня осталось лайков: $likes, суперлайков: $supers.';
  }

  @override
  String get undo => 'Вернуть';

  @override
  String get pass => 'Пропустить';

  @override
  String get superLike => 'Суперлайк';

  @override
  String get like => 'Нравится';

  @override
  String get introTitle => 'Знакомьтесь с новыми людьми из общих групп';

  @override
  String get intro1 =>
      'Вы видите только тех, кто включил знакомства в группах, где вы состоите или на которые подписаны.';

  @override
  String get intro2 =>
      'Свайп вправо — лайк, влево — пропустить, вверх — суперлайк.';

  @override
  String get intro3 =>
      'Если вы понравились друг другу — вы пара. Писать паре можно с тарифом «Чат пары».';

  @override
  String get intro4 =>
      '«Дружба» и «Знакомства» — разные режимы; выберите один или оба.';

  @override
  String get intro5 =>
      'Профиль видят только те, кто включил знакомства. Его можно приостановить или удалить в любой момент.';

  @override
  String get createMyProfile => 'Создать профиль знакомств';

  @override
  String seePackageOf(String package) {
    return 'Тариф «$package»';
  }

  @override
  String get allPackages => 'Все тарифы';

  @override
  String get packagesTitle => 'Тарифы знакомств';

  @override
  String get packagesIntro =>
      'Профиль и свайпы бесплатны. Каждая функция — отдельный тариф; берите только нужное.';

  @override
  String get adminAllOpen => 'Как администратору вам доступны все тарифы';

  @override
  String openUntil(String date) {
    return 'Действует до $date';
  }

  @override
  String ageFilter(int min, int max) {
    return 'Возраст: $min – $max';
  }

  @override
  String get allProvinces => 'Все провинции';

  @override
  String get interest => 'Интерес';

  @override
  String get all => 'Все';

  @override
  String get apply => 'Применить';

  @override
  String get clear => 'Сбросить';

  @override
  String get noAdmirers =>
      'Пока лайков нет. Листайте дальше — здесь появятся те, кому вы понравились.';

  @override
  String get backToSwiping => 'Вернуться к свайпам';

  @override
  String get likeAndMatch => 'Лайк и пара';

  @override
  String get noPendingLikes => 'Лайков пока нет';

  @override
  String likedYouCount(int count) {
    return 'Вы понравились: $count';
  }

  @override
  String get admirersPitch =>
      'С тарифом «Кому вы понравились» узнайте, кто это, и сразу создавайте пару.';

  @override
  String get seePackage => 'Посмотреть тариф';
}
