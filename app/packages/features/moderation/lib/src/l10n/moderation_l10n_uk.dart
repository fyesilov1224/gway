// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'moderation_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class ModerationL10nUk extends ModerationL10n {
  ModerationL10nUk([String locale = 'uk']) : super(locale);

  @override
  String get ruleRateLimited =>
      'Сьогодні ви надіслали забагато скарг. Спробуйте завтра.';

  @override
  String get ruleTargetInvalid =>
      'Цього вмісту більше немає або він вам недоступний.';

  @override
  String get ruleSelf => 'Не можна поскаржитися на себе чи свій вміст.';

  @override
  String get ruleAppealNotAllowed => 'Це рішення більше не можна оскаржити.';

  @override
  String get ruleDuplicate => 'Ви вже поскаржилися; скарга на розгляді.';

  @override
  String get deletedAccount => 'Видалений акаунт';

  @override
  String get reasonSpam => 'Спам або оману';

  @override
  String get reasonHarassment => 'Домагання або цькування';

  @override
  String get reasonHate => 'Мова ворожнечі';

  @override
  String get reasonViolence => 'Насильство або погрози';

  @override
  String get reasonSexual => 'Сексуальний вміст';

  @override
  String get reasonMisinformation => 'Неправдива інформація';

  @override
  String get reasonOther => 'Інше';

  @override
  String get sanctionWarning => 'Попередження';

  @override
  String get sanctionMute => 'Заглушення';

  @override
  String get sanctionKick => 'Виключення з групи';

  @override
  String get sanctionBan => 'Бан';

  @override
  String get illegalViolence => 'Насильство';

  @override
  String get illegalThreat => 'Погроза';

  @override
  String get illegalInsult => 'Образа';

  @override
  String get illegalHate => 'Мова ворожнечі';

  @override
  String get illegalSexual => 'Сексуальне насильство';

  @override
  String get illegalFraud => 'Шахрайство';

  @override
  String get illegalDrugs => 'Наркотики';

  @override
  String get illegalTerror => 'Тероризм';

  @override
  String get illegalOther => 'Інший злочин';

  @override
  String muteDays(int days) {
    return 'Заглушення, днів: $days';
  }

  @override
  String banDays(int days) {
    return 'Бан, днів: $days';
  }

  @override
  String get permanentBan => 'Безстроковий бан';

  @override
  String get thresholdMajority => 'Проста більшість';

  @override
  String get thresholdMajorityText => 'Більше половини голосів';

  @override
  String get thresholdTwoThirds => 'Дві третини';

  @override
  String get thresholdTwoThirdsText => 'Щонайменше дві третини голосів';

  @override
  String get thresholdUnanimous => 'Одноголосно';

  @override
  String get thresholdUnanimousText => 'Усі голоси';

  @override
  String get targetPost => 'Допис';

  @override
  String get targetComment => 'Коментар';

  @override
  String get targetEvent => 'Захід';

  @override
  String get targetLiveComment => 'Коментар в ефірі';

  @override
  String get targetMessage => 'Повідомлення в чаті групи';

  @override
  String get targetMember => 'Учасник';

  @override
  String get appealPending => 'Очікує рішення';

  @override
  String get appealUpheld => 'Рішення залишено в силі';

  @override
  String get appealOverturned => 'Рішення скасовано';

  @override
  String get banApplied => 'Бан застосовано.';

  @override
  String get banAppliedSuspended =>
      'Бан застосовано. Акаунт призупинено до перевірки платформою.';

  @override
  String get caseOpened =>
      'Справу відкрито. Комісія проголосує протягом 72 годин.';

  @override
  String get openCaseTitle => 'Відкрити дисциплінарну справу';

  @override
  String caseAboutNow(String name) {
    return 'Стосується: $name. Бан застосовується одразу, без голосування комісії.';
  }

  @override
  String caseAboutVote(String name) {
    return 'Стосується: $name. Комісія проголосує за вашою пропозицією протягом 72 годин.';
  }

  @override
  String get proposedSanction => 'Запропонований захід';

  @override
  String get duration => 'Строк';

  @override
  String get permanent => 'Безстроково';

  @override
  String get permanentLower => 'безстроково';

  @override
  String days(int days) {
    return 'Днів: $days';
  }

  @override
  String get applyNow => 'Застосувати одразу, без голосування';

  @override
  String get applyNowHint =>
      'Бан без очікування комісії. Людина може оскаржити протягом 7 днів.';

  @override
  String get illegalActivity => 'Незаконна діяльність';

  @override
  String get illegalHintNow =>
      'Після бану справа йде команді платформи, а акаунт призупиняється до перевірки. Цю позначку не можна змінити.';

  @override
  String get illegalHintVote =>
      'Якщо комісія схвалить, справа піде команді платформи, а акаунт призупиниться до перевірки. Цю позначку не можна змінити.';

  @override
  String get reason => 'Причина';

  @override
  String get reasonHintNow =>
      'Що сталося? Цей текст побачать людина й той, хто розгляне апеляцію.';

  @override
  String get reasonHintVote => 'Що сталося? Комісія проголосує за цим текстом.';

  @override
  String get reasonMin10 => 'Причина — щонайменше 10 символів.';

  @override
  String get muteNow => 'Заглушити зараз (24 години)';

  @override
  String get muteNowHint =>
      'До рішення комісії людина не зможе коментувати й говорити в ефірі.';

  @override
  String get ban => 'Забанити';

  @override
  String get openCase => 'Відкрити справу';

  @override
  String leftDays(int days) {
    return '$days дн.';
  }

  @override
  String leftDaysHours(int days, int hours) {
    return '$days дн. $hours год';
  }

  @override
  String leftHours(int hours) {
    return '$hours год';
  }

  @override
  String get leftFewMinutes => 'кілька хвилин';

  @override
  String minChars(int min) {
    return 'Напишіть щонайменше $min символів.';
  }

  @override
  String get cancel => 'Скасувати';

  @override
  String get threshold => 'Поріг рішення комісії';

  @override
  String thresholdChanged(String threshold) {
    return 'Поріг тепер — «$threshold». Діє для нових справ.';
  }

  @override
  String moderationOf(String group) {
    return 'Модерація · $group';
  }

  @override
  String get reports => 'Скарги';

  @override
  String reportsCount(int count) {
    return 'Скарги ($count)';
  }

  @override
  String get cases => 'Справи';

  @override
  String casesCount(int count) {
    return 'Справи ($count)';
  }

  @override
  String get sanctions => 'Заходи';

  @override
  String sanctionsCount(int count) {
    return 'Заходи ($count)';
  }

  @override
  String get moderationTeamOnly =>
      'Модерацію групи бачать лише власник і команда модерації.';

  @override
  String get goBack => 'Назад';

  @override
  String get noReports =>
      'Відкритих скарг немає. Скарги учасників з’являться тут.';

  @override
  String get refresh => 'Оновити';

  @override
  String get removeContent => 'Видалити вміст';

  @override
  String get remove => 'Видалити';

  @override
  String get contentRemoved => 'Вміст видалено.';

  @override
  String reportCount(int count) {
    return 'Скарг: $count';
  }

  @override
  String get view => 'Відкрити';

  @override
  String get reportDismissed => 'Скаргу відхилено.';

  @override
  String get dismiss => 'Відхилити';

  @override
  String get openCaseShort => 'Відкрити справу';

  @override
  String get rankOnlyDismiss =>
      'Ранг цієї людини не нижчий за ваш — можна лише відхилити.';

  @override
  String get noCases =>
      'Дисциплінарних справ поки немає. Їх відкривають зі скарги або сторінки учасників.';

  @override
  String get voteApproved =>
      'Голос враховано. Комісія схвалила захід — його застосовано.';

  @override
  String get voteRejected => 'Голос враховано. Комісія відхилила захід.';

  @override
  String get voteSaved => 'Голос враховано. Його можна змінити до рішення.';

  @override
  String get statusVoting => 'Голосування';

  @override
  String get statusApproved => 'Схвалено';

  @override
  String get statusRejected => 'Відхилено';

  @override
  String proposed(String sanction) {
    return 'Запропоновано: $sanction';
  }

  @override
  String get directBan => 'Бан без голосування';

  @override
  String illegalLabel(String category) {
    return 'Незаконна діяльність: $category';
  }

  @override
  String tally(int approvals, int rejections, int voters) {
    return 'За: $approvals · проти: $rejections · голосуючих: $voters';
  }

  @override
  String votingEndsIn(String time) {
    return 'Голосування закінчиться через $time';
  }

  @override
  String bannedBy(String name) {
    return 'Забанив(-ла): $name';
  }

  @override
  String openedBy(String name) {
    return 'Відкрив(-ла): $name';
  }

  @override
  String get approve => 'Схвалити';

  @override
  String get reject => 'Відхилити';

  @override
  String get noSanctions =>
      'Заходів поки немає. Тут з’являться схвалені заходи й апеляції.';

  @override
  String get liftSanction => 'Скасувати захід';

  @override
  String get keepSanction => 'Залишити захід';

  @override
  String get noteToPerson => 'Нотатка для людини (необов’язково)';

  @override
  String get liftedNotified => 'Захід скасовано; людину повідомлено.';

  @override
  String get appealRejectedNotified =>
      'Апеляцію відхилено; людину повідомлено.';

  @override
  String get lifted => 'Скасовано';

  @override
  String get interimMute => 'Термінове заглушення';

  @override
  String get running => 'Діє';

  @override
  String get applied => 'Застосовано';

  @override
  String get interimUntilDecision =>
      'Термінове заглушення · до рішення комісії';

  @override
  String until(String date) {
    return 'до $date';
  }

  @override
  String appealLine(String status) {
    return 'Апеляція · $status';
  }

  @override
  String noteLine(String note) {
    return 'Нотатка: $note';
  }

  @override
  String get ownerParty =>
      'Власник — сторона справи, тому апеляцію розглядає команда платформи.';

  @override
  String get keep => 'Залишити';

  @override
  String casesAwaitingVote(int count) {
    return 'Чекають вашого голосу: $count';
  }

  @override
  String appealsCount(int count) {
    return 'Апеляцій: $count';
  }

  @override
  String get moderation => 'Модерація';

  @override
  String get noWork => 'Нічого не чекає';

  @override
  String get mySanctions => 'Мої обмеження';

  @override
  String get noMySanctions =>
      'У жодній групі у вас немає обмежень. Дякуємо, що дотримуєтеся правил.';

  @override
  String get interimEnded => 'Термінове заглушення завершено';

  @override
  String interimLatest(String date) {
    return 'Термінове заглушення · до рішення комісії, не пізніше $date';
  }

  @override
  String untilCap(String date) {
    return 'До $date';
  }

  @override
  String get ended => 'Завершено';

  @override
  String get appeal => 'Оскаржити';

  @override
  String get appealHint => 'Чому ви вважаєте це несправедливим?';

  @override
  String get send => 'Надіслати';

  @override
  String get appealSent =>
      'Апеляцію надіслано. Ви отримаєте сповіщення про рішення.';

  @override
  String reasonLine(String reason) {
    return 'Причина: $reason';
  }

  @override
  String yourAppealLine(String status) {
    return 'Ваша апеляція · $status';
  }

  @override
  String get appealOnce => 'Рішення можна оскаржити один раз протягом 7 днів.';

  @override
  String get reportPost => 'Поскаржитися на допис';

  @override
  String get reportComment => 'Поскаржитися на коментар';

  @override
  String get reportEvent => 'Поскаржитися на захід';

  @override
  String get reportMessage => 'Поскаржитися на повідомлення';

  @override
  String get reportMatchProfile => 'Поскаржитися на профіль знайомств';

  @override
  String get reportPhoto => 'Поскаржитися на фото';

  @override
  String get reportUser => 'Поскаржитися на користувача';

  @override
  String get reportReceived =>
      'Скаргу отримано. Ми розглянемо її й ужиємо заходів; ваше ім’я не покажуть тому, на кого ви поскаржилися.';

  @override
  String get whyReport => 'Чому ви скаржитеся?';

  @override
  String get detailsOptional => 'Подробиці (необов’язково)';

  @override
  String get detailsHint => 'Коротко опишіть, що сталося.';

  @override
  String get report => 'Поскаржитися';
}
