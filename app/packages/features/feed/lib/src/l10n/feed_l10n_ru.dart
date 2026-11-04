// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'feed_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class FeedL10nRu extends FeedL10n {
  FeedL10nRu([String locale = 'ru']) : super(locale);

  @override
  String get commentsOff => 'Комментарии к этой публикации отключены.';

  @override
  String get commentNotAllowed =>
      'Сейчас нельзя комментировать эту публикацию. Можно оставить реакцию-эмодзи.';

  @override
  String get blocked => 'Вы не можете взаимодействовать с этим аккаунтом.';

  @override
  String get commentRate =>
      'Слишком много комментариев за короткое время. Подождите и повторите.';

  @override
  String get muted =>
      'Вас заглушили в этой группе, поэтому сейчас комментировать нельзя.';

  @override
  String get likeRate =>
      'Слишком много лайков за короткое время. Подождите и повторите.';

  @override
  String get replyGone => 'Комментарий, на который вы отвечаете, удалён.';

  @override
  String get storyRate =>
      'Сегодня вы опубликовали слишком много историй. Попробуйте завтра.';

  @override
  String get highlightLimit => 'Можно создать до 100 актуальных.';

  @override
  String get highlightFull => 'В актуальном может быть до 100 историй.';

  @override
  String get duplicate => 'Это уже сделано.';

  @override
  String get fileTooLarge =>
      'Файл слишком большой. Фото — до 10 МБ, видео — до 50 МБ.';

  @override
  String get unsupportedMedia =>
      'Можно публиковать только фото JPEG, PNG, WebP и видео MP4, MOV.';

  @override
  String get commentLength =>
      'Комментарий должен содержать от 1 до 2200 символов.';

  @override
  String get highlightTitleLength =>
      'Название должно содержать от 1 до 30 символов.';

  @override
  String get pickStory => 'Выберите хотя бы одну историю.';

  @override
  String get aspectOriginal => 'Оригинал';

  @override
  String get agoNow => 'только что';

  @override
  String agoMinutes(int n) {
    return '$n мин';
  }

  @override
  String agoHours(int n) {
    return '$n ч';
  }

  @override
  String agoDays(int n) {
    return '$n д';
  }

  @override
  String agoWeeks(int n) {
    return '$n нед';
  }

  @override
  String get photoLimit => 'Фото — до 10 МБ.';

  @override
  String get videoSizeLimit => 'Видео — до 50 МБ.';

  @override
  String get videoLengthLimit => 'Видео — до 60 секунд.';

  @override
  String get captionLimit => 'Подпись — до 2200 символов.';

  @override
  String get hashtagLimit => 'В публикации может быть до 30 хештегов.';

  @override
  String get mediaCount => 'В публикации может быть от 1 до 10 фото или видео.';

  @override
  String get comments => 'Комментарии';

  @override
  String get noCommentsEmojiOnly =>
      'Комментариев пока нет. Можно оставить реакцию-эмодзи.';

  @override
  String get noCommentsFirst => 'Комментариев пока нет. Напишите первым.';

  @override
  String get goBack => 'Назад';

  @override
  String get writeComment => 'Написать комментарий';

  @override
  String replyingTo(String username) {
    return 'Ответ для @$username';
  }

  @override
  String get cancelReply => 'Отменить ответ';

  @override
  String get addComment => 'Добавьте комментарий…';

  @override
  String get share => 'Опубликовать';

  @override
  String get deleteCommentTitle => 'Удалить комментарий?';

  @override
  String get deleteCommentBody =>
      'Комментарий и ответы будут удалены навсегда.';

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String likeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count лайков',
      few: '$count лайка',
      one: '$count лайк',
    );
    return '$_temp0';
  }

  @override
  String commentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count комментариев',
      few: '$count комментария',
      one: '$count комментарий',
    );
    return '$_temp0';
  }

  @override
  String get reply => 'Ответить';

  @override
  String get report => 'Пожаловаться';

  @override
  String get unlike => 'Убрать лайк';

  @override
  String get likeComment => 'Нравится комментарий';

  @override
  String get cantComment =>
      'Сейчас вы не можете комментировать. Можно оставить реакцию-эмодзи.';

  @override
  String get tooManyMedia => 'В публикации может быть до 10 фото или видео.';

  @override
  String get cantOpenFile =>
      'Не удалось открыть файл. Попробуйте другое фото или видео.';

  @override
  String get preparingPhotos => 'Подготовка фото…';

  @override
  String get photosFailed => 'Не удалось подготовить фото. Попробуйте другое.';

  @override
  String uploading(int done, int total) {
    return 'Загрузка: $done/$total';
  }

  @override
  String get sharing => 'Публикация…';

  @override
  String get postShared => 'Ваша публикация опубликована.';

  @override
  String get newPost => 'Новая публикация';

  @override
  String get memoryNotice =>
      'Эта публикация появится и в воспоминаниях мероприятия. Публикуйте только свои фото и людей, давших согласие.';

  @override
  String get pickMediaHint => 'Выберите до 10 фото или видео.';

  @override
  String get pickFromGallery => 'Выбрать из галереи';

  @override
  String get cropHint =>
      'Разведите пальцы для увеличения, перетаскивайте для кадрирования. Пропорции применяются ко всем фото.';

  @override
  String get caption => 'Подпись';

  @override
  String get captionHint =>
      'Напишите что-нибудь… Можно добавить #хештеги и @имена.';

  @override
  String get postAs => 'Опубликовать от имени';

  @override
  String get myProfile => 'Мой профиль';

  @override
  String groupOption(String name) {
    return '$name (группа)';
  }

  @override
  String get turnOffComments => 'Отключить комментарии';

  @override
  String get hideLikes => 'Скрыть число лайков';

  @override
  String get onlyYouSee => 'Число видите только вы.';

  @override
  String mediaN(int n) {
    return 'Файл $n';
  }

  @override
  String seconds(int n) {
    return '▶ $n с';
  }

  @override
  String get removeMedia => 'Убрать';

  @override
  String get cantShare => 'Нельзя опубликовать';

  @override
  String get addMedia => 'Добавить медиа';

  @override
  String get editPost => 'Редактировать публикацию';

  @override
  String get save => 'Сохранить';

  @override
  String get noEditPermission => 'У вас нет прав на редактирование.';

  @override
  String get photoToCrop => 'Фото для кадрирования';

  @override
  String get stories => 'Истории';

  @override
  String get feed => 'Лента';

  @override
  String get feedHint => 'От ваших групп и подписок';

  @override
  String get feedEmpty =>
      'Лента пуста. Здесь появятся публикации людей и групп, на которые вы подписаны.';

  @override
  String get explore => 'Обзор';

  @override
  String get searchHint => 'Поиск людей или #хештегов';

  @override
  String get clear => 'Очистить';

  @override
  String get exploreEmpty => 'Новых публикаций пока нет. Загляните позже.';

  @override
  String get refresh => 'Обновить';

  @override
  String get accounts => 'Аккаунты';

  @override
  String get hashtags => 'Хештеги';

  @override
  String noTagMatch(String query) {
    return 'Нет хештегов, начинающихся с «$query».';
  }

  @override
  String get clearSearch => 'Очистить поиск';

  @override
  String postCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count публикаций',
      few: '$count публикации',
      one: '$count публикация',
    );
    return '$_temp0';
  }

  @override
  String noTagPosts(String tag) {
    return 'Нет доступных публикаций с #$tag.';
  }

  @override
  String get backToExplore => 'Вернуться в обзор';

  @override
  String get saved => 'Сохранённое';

  @override
  String get savedEmpty =>
      'Сохранённые публикации появятся здесь — их видите только вы.';

  @override
  String get post => 'Публикация';

  @override
  String get postGone => 'Публикация удалена или недоступна вам.';

  @override
  String get backToFeed => 'Вернуться в ленту';

  @override
  String get unmute => 'Включить звук';

  @override
  String get mute => 'Выключить звук';

  @override
  String get addedToSaved => 'Добавлено в сохранённое.';

  @override
  String get linkCopied => 'Ссылка на публикацию скопирована.';

  @override
  String get deletePostTitle => 'Удалить публикацию?';

  @override
  String get deletePostBody =>
      'Публикация будет удалена навсегда вместе с фото, видео и комментариями.';

  @override
  String get postDeleted => 'Публикация удалена.';

  @override
  String get likesHidden => 'Число лайков видите только вы.';

  @override
  String memoryOf(String title) {
    return 'Воспоминание · $title';
  }

  @override
  String get deletedAccount => 'Удалённый аккаунт';

  @override
  String get groupPost => 'Публикация группы';

  @override
  String get edited => 'изменено';

  @override
  String get moreOptions => 'Другие действия';

  @override
  String get copyLink => 'Копировать ссылку';

  @override
  String get edit => 'Изменить';

  @override
  String get like => 'Нравится';

  @override
  String get commentAction => 'Комментировать';

  @override
  String get unsave => 'Удалить из сохранённого';

  @override
  String reactionLabel(String emoji, int count) {
    return 'Реакция $emoji, $count';
  }

  @override
  String get more => 'ещё';

  @override
  String postWithCaption(String caption) {
    return 'Публикация: $caption';
  }

  @override
  String get showMore => 'Показать ещё';

  @override
  String get addStory => 'Добавить историю';

  @override
  String get yourStory => 'Ваша история';

  @override
  String get noStoriesLeft => 'Здесь больше нет доступных историй.';

  @override
  String get close => 'Закрыть';

  @override
  String get removeFromHighlight => 'Убрать из актуального';

  @override
  String get removedFromHighlight => 'Убрано из актуального.';

  @override
  String get addToHighlights => 'Добавить в актуальное';

  @override
  String get deleteStory => 'Удалить историю';

  @override
  String get storyDeleted => 'История удалена.';

  @override
  String get options => 'Действия';

  @override
  String get viewers => 'Просмотры';

  @override
  String get noViewers =>
      'Пока никто не смотрел. Просмотры появятся здесь — их видите только вы.';

  @override
  String viewedBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Просмотрели $count человек',
      few: 'Просмотрели $count человека',
      one: 'Просмотрел $count человек',
    );
    return '$_temp0';
  }

  @override
  String get storyPhotoFailed =>
      'Не удалось подготовить фото. Попробуйте другое.';

  @override
  String get storyShared => 'История опубликована. Она будет видна 24 часа.';

  @override
  String get newStory => 'Новая история';

  @override
  String get addToStory => 'Добавить в историю';

  @override
  String get storyPickHint => 'Выберите фото или видео до 60 секунд.';

  @override
  String get pickAnother => 'Выбрать другое';

  @override
  String get newHighlight => 'Новое актуальное';

  @override
  String highlightCreated(String title) {
    return '«$title» создано.';
  }

  @override
  String storyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count историй',
      few: '$count истории',
      one: '$count история',
    );
    return '$_temp0';
  }

  @override
  String addedToHighlight(String title) {
    return 'Добавлено в «$title».';
  }

  @override
  String get highlightTitle => 'Название актуального';

  @override
  String get highlightExample => 'Например, Поход 2026';

  @override
  String get addHighlight => 'Добавить актуальное';

  @override
  String get renameHighlight => 'Переименовать';

  @override
  String get deleteHighlight => 'Удалить актуальное';

  @override
  String get staysInArchive => 'Истории останутся в архиве.';

  @override
  String get storyArchive => 'Архив историй';

  @override
  String storiesSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Выбрано $count историй',
      few: 'Выбрано $count истории',
      one: 'Выбрана $count история',
    );
    return '$_temp0';
  }

  @override
  String get feature => 'В актуальное';

  @override
  String get archiveEmpty =>
      'Через 24 часа истории сохраняются здесь — их видите только вы.';

  @override
  String get shareStory => 'Опубликовать историю';

  @override
  String get archiveHint =>
      'Выберите истории, чтобы создать актуальное или дополнить его.';

  @override
  String storyOn(String date) {
    return 'История, $date';
  }

  @override
  String get live => 'Опубликована';
}
