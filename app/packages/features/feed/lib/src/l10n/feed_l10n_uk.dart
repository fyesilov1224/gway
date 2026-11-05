// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'feed_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class FeedL10nUk extends FeedL10n {
  FeedL10nUk([String locale = 'uk']) : super(locale);

  @override
  String get commentsOff => 'Коментарі до цього допису вимкнено.';

  @override
  String get commentNotAllowed =>
      'Зараз не можна коментувати цей допис. Можна залишити реакцію-емодзі.';

  @override
  String get blocked => 'Ви не можете взаємодіяти з цим обліковим записом.';

  @override
  String get commentRate =>
      'Забагато коментарів за короткий час. Зачекайте й спробуйте ще раз.';

  @override
  String get muted =>
      'Вас заглушено в цій групі, тому зараз коментувати не можна.';

  @override
  String get likeRate =>
      'Забагато вподобань за короткий час. Зачекайте й спробуйте ще раз.';

  @override
  String get replyGone => 'Коментаря, на який ви відповідаєте, більше немає.';

  @override
  String get storyRate =>
      'Сьогодні ви опублікували забагато історій. Спробуйте завтра.';

  @override
  String get highlightLimit => 'Можна створити до 100 добірок.';

  @override
  String get highlightFull => 'У добірці може бути до 100 історій.';

  @override
  String get duplicate => 'Це вже зроблено.';

  @override
  String get fileTooLarge =>
      'Файл завеликий. Фото — до 10 МБ, відео — до 50 МБ.';

  @override
  String get unsupportedMedia =>
      'Можна публікувати лише фото JPEG, PNG, WebP і відео MP4, MOV.';

  @override
  String get commentLength => 'Коментар має містити від 1 до 2200 символів.';

  @override
  String get highlightTitleLength => 'Назва має містити від 1 до 30 символів.';

  @override
  String get pickStory => 'Виберіть принаймні одну історію.';

  @override
  String get aspectOriginal => 'Оригінал';

  @override
  String get agoNow => 'щойно';

  @override
  String agoMinutes(int n) {
    return '$n хв';
  }

  @override
  String agoHours(int n) {
    return '$n год';
  }

  @override
  String agoDays(int n) {
    return '$n д';
  }

  @override
  String agoWeeks(int n) {
    return '$n тиж';
  }

  @override
  String get photoLimit => 'Фото — до 10 МБ.';

  @override
  String get videoSizeLimit => 'Відео — до 50 МБ.';

  @override
  String get videoLengthLimit => 'Відео — до 60 секунд.';

  @override
  String get captionLimit => 'Підпис — до 2200 символів.';

  @override
  String get hashtagLimit => 'У дописі може бути до 30 хештегів.';

  @override
  String get mediaCount => 'У дописі може бути від 1 до 10 фото чи відео.';

  @override
  String get comments => 'Коментарі';

  @override
  String get noCommentsEmojiOnly =>
      'Коментарів поки немає. Можна залишити реакцію-емодзі.';

  @override
  String get noCommentsFirst => 'Коментарів поки немає. Напишіть першим.';

  @override
  String get goBack => 'Назад';

  @override
  String get writeComment => 'Написати коментар';

  @override
  String replyingTo(String username) {
    return 'Відповідь для $username';
  }

  @override
  String get cancelReply => 'Скасувати відповідь';

  @override
  String get addComment => 'Додайте коментар…';

  @override
  String get share => 'Опублікувати';

  @override
  String get deleteCommentTitle => 'Видалити коментар?';

  @override
  String get deleteCommentBody =>
      'Коментар і відповіді буде видалено назавжди.';

  @override
  String get cancel => 'Скасувати';

  @override
  String get delete => 'Видалити';

  @override
  String likeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count вподобань',
      few: '$count вподобання',
      one: '$count вподобання',
    );
    return '$_temp0';
  }

  @override
  String commentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count коментарів',
      few: '$count коментарі',
      one: '$count коментар',
    );
    return '$_temp0';
  }

  @override
  String get reply => 'Відповісти';

  @override
  String get report => 'Поскаржитися';

  @override
  String get unlike => 'Прибрати вподобання';

  @override
  String get likeComment => 'Вподобати коментар';

  @override
  String get cantComment =>
      'Зараз ви не можете коментувати. Можна залишити реакцію-емодзі.';

  @override
  String get tooManyMedia => 'У дописі може бути до 10 фото чи відео.';

  @override
  String get cantOpenFile =>
      'Не вдалося відкрити файл. Спробуйте інше фото чи відео.';

  @override
  String get preparingPhotos => 'Підготовка фото…';

  @override
  String get photosFailed => 'Не вдалося підготувати фото. Спробуйте інше.';

  @override
  String uploading(int done, int total) {
    return 'Завантаження: $done/$total';
  }

  @override
  String get sharing => 'Публікація…';

  @override
  String get postShared => 'Ваш допис опубліковано.';

  @override
  String get newPost => 'Новий допис';

  @override
  String get memoryNotice =>
      'Цей допис з’явиться й у спогадах події. Публікуйте лише власні фото та людей, які дали згоду.';

  @override
  String get pickMediaHint => 'Виберіть до 10 фото чи відео.';

  @override
  String get pickFromGallery => 'Вибрати з галереї';

  @override
  String get cropHint =>
      'Розведіть пальці для збільшення, перетягуйте для кадрування. Пропорції застосовуються до всіх фото.';

  @override
  String get caption => 'Підпис';

  @override
  String get captionHint => 'Напишіть щось… Можна додати #хештеги й @імена.';

  @override
  String get postAs => 'Опублікувати від імені';

  @override
  String get myProfile => 'Мій профіль';

  @override
  String groupOption(String name) {
    return '$name (група)';
  }

  @override
  String get turnOffComments => 'Вимкнути коментарі';

  @override
  String get hideLikes => 'Приховати кількість вподобань';

  @override
  String get onlyYouSee => 'Число бачите лише ви.';

  @override
  String mediaN(int n) {
    return 'Файл $n';
  }

  @override
  String seconds(int n) {
    return '▶ $n с';
  }

  @override
  String get removeMedia => 'Прибрати';

  @override
  String get cantShare => 'Не можна опублікувати';

  @override
  String get addMedia => 'Додати медіа';

  @override
  String get editPost => 'Редагувати допис';

  @override
  String get save => 'Зберегти';

  @override
  String get noEditPermission => 'У вас немає прав на редагування.';

  @override
  String get photoToCrop => 'Фото для кадрування';

  @override
  String get stories => 'Історії';

  @override
  String get feed => 'Стрічка';

  @override
  String get feedHint => 'Від ваших груп і підписок';

  @override
  String get feedEmpty =>
      'Стрічка порожня. Тут з’являться дописи людей і груп, на які ви підписані.';

  @override
  String get explore => 'Огляд';

  @override
  String get searchHint => 'Пошук людей або #хештегів';

  @override
  String get clear => 'Очистити';

  @override
  String get exploreEmpty => 'Нових дописів поки немає. Загляньте пізніше.';

  @override
  String get refresh => 'Оновити';

  @override
  String get accounts => 'Облікові записи';

  @override
  String get hashtags => 'Хештеги';

  @override
  String noTagMatch(String query) {
    return 'Немає хештегів, що починаються з «$query».';
  }

  @override
  String get clearSearch => 'Очистити пошук';

  @override
  String postCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дописів',
      few: '$count дописи',
      one: '$count допис',
    );
    return '$_temp0';
  }

  @override
  String noTagPosts(String tag) {
    return 'Немає доступних дописів із #$tag.';
  }

  @override
  String get backToExplore => 'Повернутися до огляду';

  @override
  String get saved => 'Збережене';

  @override
  String get savedEmpty =>
      'Збережені дописи з’являться тут — їх бачите лише ви.';

  @override
  String get post => 'Допис';

  @override
  String get postGone => 'Допис видалено або він вам недоступний.';

  @override
  String get backToFeed => 'Повернутися до стрічки';

  @override
  String get unmute => 'Увімкнути звук';

  @override
  String get mute => 'Вимкнути звук';

  @override
  String get addedToSaved => 'Додано до збереженого.';

  @override
  String get linkCopied => 'Посилання на допис скопійовано.';

  @override
  String get deletePostTitle => 'Видалити допис?';

  @override
  String get deletePostBody =>
      'Допис буде видалено назавжди разом із фото, відео й коментарями.';

  @override
  String get postDeleted => 'Допис видалено.';

  @override
  String get likesHidden => 'Кількість вподобань бачите лише ви.';

  @override
  String memoryOf(String title) {
    return 'Спогад · $title';
  }

  @override
  String get deletedAccount => 'Видалений обліковий запис';

  @override
  String get groupPost => 'Допис групи';

  @override
  String get edited => 'змінено';

  @override
  String get moreOptions => 'Інші дії';

  @override
  String get copyLink => 'Копіювати посилання';

  @override
  String get edit => 'Змінити';

  @override
  String get like => 'Подобається';

  @override
  String get commentAction => 'Коментувати';

  @override
  String get unsave => 'Прибрати зі збереженого';

  @override
  String reactionLabel(String emoji, int count) {
    return 'Реакція $emoji, $count';
  }

  @override
  String get more => 'ще';

  @override
  String postWithCaption(String caption) {
    return 'Допис: $caption';
  }

  @override
  String get showMore => 'Показати ще';

  @override
  String get addStory => 'Додати історію';

  @override
  String get yourStory => 'Ваша історія';

  @override
  String get noStoriesLeft => 'Тут більше немає доступних історій.';

  @override
  String get close => 'Закрити';

  @override
  String get removeFromHighlight => 'Прибрати з добірки';

  @override
  String get removedFromHighlight => 'Прибрано з добірки.';

  @override
  String get addToHighlights => 'Додати до добірки';

  @override
  String get deleteStory => 'Видалити історію';

  @override
  String get storyDeleted => 'Історію видалено.';

  @override
  String get options => 'Дії';

  @override
  String get viewers => 'Перегляди';

  @override
  String get noViewers =>
      'Поки ніхто не переглянув. Перегляди з’являться тут — їх бачите лише ви.';

  @override
  String viewedBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Переглянули $count людей',
      few: 'Переглянули $count людини',
      one: 'Переглянула $count людина',
    );
    return '$_temp0';
  }

  @override
  String get storyPhotoFailed => 'Не вдалося підготувати фото. Спробуйте інше.';

  @override
  String get storyShared => 'Історію опубліковано. Її буде видно 24 години.';

  @override
  String get newStory => 'Нова історія';

  @override
  String get addToStory => 'Додати до історії';

  @override
  String get storyPickHint => 'Виберіть фото або відео до 60 секунд.';

  @override
  String get pickAnother => 'Вибрати інше';

  @override
  String get newHighlight => 'Нова добірка';

  @override
  String highlightCreated(String title) {
    return '«$title» створено.';
  }

  @override
  String storyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count історій',
      few: '$count історії',
      one: '$count історія',
    );
    return '$_temp0';
  }

  @override
  String addedToHighlight(String title) {
    return 'Додано до «$title».';
  }

  @override
  String get highlightTitle => 'Назва добірки';

  @override
  String get highlightExample => 'Напр., Похід 2026';

  @override
  String get addHighlight => 'Додати добірку';

  @override
  String get renameHighlight => 'Перейменувати';

  @override
  String get deleteHighlight => 'Видалити добірку';

  @override
  String get staysInArchive => 'Історії залишаться в архіві.';

  @override
  String get storyArchive => 'Архів історій';

  @override
  String storiesSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Вибрано $count історій',
      few: 'Вибрано $count історії',
      one: 'Вибрано $count історію',
    );
    return '$_temp0';
  }

  @override
  String get feature => 'У добірку';

  @override
  String get archiveEmpty =>
      'Через 24 години історії зберігаються тут — їх бачите лише ви.';

  @override
  String get shareStory => 'Опублікувати історію';

  @override
  String get archiveHint =>
      'Виберіть історії, щоб створити добірку або доповнити її.';

  @override
  String storyOn(String date) {
    return 'Історія, $date';
  }

  @override
  String get live => 'Опубліковано';
}
