// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'billing_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class BillingL10nRu extends BillingL10n {
  BillingL10nRu([String locale = 'ru']) : super(locale);

  @override
  String get monthly => 'На месяц';

  @override
  String get yearly => 'На год';

  @override
  String get perMonth => 'мес.';

  @override
  String get perYear => 'год';

  @override
  String get notOnDevice => 'Недоступно на этом устройстве.';

  @override
  String get goBack => 'Назад';

  @override
  String get payment => 'Оплата';

  @override
  String get planUnavailable => 'Сейчас этот тариф купить нельзя.';

  @override
  String get backToPlans => 'К тарифам';

  @override
  String get paymentPageFailed =>
      'Не удалось открыть страницу оплаты. Попробуйте ещё раз.';

  @override
  String get billingDetails => 'Платёжные данные';

  @override
  String get billingDetailsHint => 'Счёт оформляется на эти данные.';

  @override
  String get firstName => 'Имя';

  @override
  String get lastName => 'Фамилия';

  @override
  String fieldRequired(String field) {
    return 'Поле «$field» обязательно.';
  }

  @override
  String get phone => 'Телефон';

  @override
  String get phoneInvalid => 'Введите правильный номер телефона.';

  @override
  String get address => 'Адрес';

  @override
  String get addressRequired => 'Введите адрес для счёта.';

  @override
  String get city => 'Город';

  @override
  String get cityRequired => 'Введите город.';

  @override
  String get country => 'Страна';

  @override
  String get countryRequired => 'Введите страну.';

  @override
  String get termsBefore => 'Я прочитал(а) и принимаю: ';

  @override
  String get termsAfter => '.';

  @override
  String get acceptTerms => 'Чтобы продолжить, примите договор.';

  @override
  String get billingDataUse =>
      'Платёжные данные используются только для оплаты, выставления счёта и хранения по закону.';

  @override
  String payAmount(String amount) {
    return 'К оплате · $amount';
  }

  @override
  String get orderSummary => 'Сводка заказа';

  @override
  String planPeriod(String plan, String period) {
    return 'Тариф «$plan» · $period';
  }

  @override
  String get start => 'Начало';

  @override
  String get whenConfirmed => 'После подтверждения оплаты';

  @override
  String get endEstimated => 'Окончание (примерно)';

  @override
  String get carriedOver => 'Перенесённый срок';

  @override
  String about(String value) {
    return 'около $value';
  }

  @override
  String get total => 'Итого';

  @override
  String assuranceTry(String provider) {
    return 'Оплату безопасно принимает $provider в турецких лирах. Данные карты не передаются GWAY. Разовый платёж без автопродления.';
  }

  @override
  String assuranceUsd(String provider) {
    return 'Оплату безопасно принимает $provider в долларах США. Данные карты не передаются GWAY. Разовый платёж без автопродления.';
  }

  @override
  String get overLimit =>
      'Участников больше лимита тарифа. Новые не смогут вступить, пока число не станет ниже.';

  @override
  String get atLimit =>
      'Группа достигла лимита участников тарифа. Новых принять нельзя.';

  @override
  String membersOfMax(String count, String max) {
    return 'Участники: $count / $max';
  }

  @override
  String get plan => 'Тариф';

  @override
  String get getPlan => 'Выбрать тариф';

  @override
  String get upgradePlan => 'Повысить тариф';

  @override
  String planEnds(String date) {
    return 'Тариф закончится $date. Затем группа вернётся на бесплатный.';
  }

  @override
  String get paymentReceivedPersonal => 'Оплата получена. Тариф подключён.';

  @override
  String get planStatus => 'Статус тарифа';

  @override
  String get notActive => 'Тариф не подключён к вашему аккаунту.';

  @override
  String activeUntil(String date) {
    return 'Тариф действует до $date.';
  }

  @override
  String get buy => 'Купить';

  @override
  String get extend => 'Продлить';

  @override
  String get oneTime => 'Разовый платёж, без автопродления.';

  @override
  String newPeriodAfter(String date) {
    return 'Новый срок начнётся после $date.';
  }

  @override
  String get salesClosed => 'Продажа тарифа сейчас закрыта. Попробуйте позже.';

  @override
  String continueAmount(String amount) {
    return 'Продолжить · $amount';
  }

  @override
  String get personalOnly =>
      'Тариф только для вас и не влияет на тариф группы.';

  @override
  String saving(int percent) {
    return 'Выгода $percent%';
  }

  @override
  String untilDate(String date) {
    return 'До $date';
  }

  @override
  String pricePer(String price, String unit) {
    return '$price / $unit';
  }

  @override
  String get productUnavailable => 'Сейчас этот продукт купить нельзя.';

  @override
  String get personalProduct => 'Личный продукт';

  @override
  String offerPeriod(String plan, String period) {
    return '$plan · $period';
  }

  @override
  String get groupReady => 'Группа готова';

  @override
  String get freeStartBuy =>
      'Группа начала с бесплатного тарифа. Если нужно больше участников, мероприятий или минут эфира, выберите тариф ниже.';

  @override
  String get freeStartView =>
      'Группа начала с бесплатного тарифа. Лимиты тарифов — ниже.';

  @override
  String get continueFree => 'Продолжить бесплатно';

  @override
  String get goToGroup => 'В группу';

  @override
  String get paymentReceivedGroup => 'Оплата получена. Тариф активен.';

  @override
  String get membersOnly => 'Тариф группы видят только её участники.';

  @override
  String get currentPlan => 'Текущий тариф';

  @override
  String get onFree => 'Группа на бесплатном тарифе.';

  @override
  String periodEnds(String date) {
    return 'Текущий срок заканчивается $date.';
  }

  @override
  String get overLimitLong =>
      'Участников больше лимита. Никого не исключат, но новые не вступят, пока число не станет ниже.';

  @override
  String get atLimitLong =>
      'Группа достигла лимита. Чтобы принимать новых, перейдите на тариф побольше.';

  @override
  String get upcomingPeriods => 'Следующие периоды';

  @override
  String get plans => 'Тарифы';

  @override
  String get yearlyDeal => 'На год · 2 месяца бесплатно';

  @override
  String paymentNoteTry(String provider) {
    return 'Оплата через $provider в турецких лирах, в зависимости от страны. Без автопродления.';
  }

  @override
  String paymentNoteUsd(String provider) {
    return 'Оплата через $provider в долларах США, в зависимости от страны. Без автопродления.';
  }

  @override
  String get paymentsOff => 'Сейчас оплата недоступна. Попробуйте позже.';

  @override
  String get notNow => 'Пока недоступно';

  @override
  String get choose => 'Выбрать';

  @override
  String get upgrade => 'Повысить';

  @override
  String get renew => 'Продлить';

  @override
  String get switchTo => 'Перейти на этот тариф';

  @override
  String get paidOverYear =>
      'Тариф оплачен больше чем на год вперёд. Пока можно только повысить его.';

  @override
  String startsNowCredit(String credit, String date) {
    return 'Начнётся сразу; добавится около $credit оставшегося срока. Окончание: $date.';
  }

  @override
  String startsNow(String date) {
    return 'Начнётся сразу. Окончание: $date.';
  }

  @override
  String startsAfterCurrent(String date) {
    return 'Начнётся $date, после текущего срока.';
  }

  @override
  String startsWhenEnds(String date) {
    return 'Начнётся $date, когда закончится текущий срок.';
  }

  @override
  String get confirmPending =>
      'Подтверждение оплаты ещё не пришло. Если деньги списаны, тариф включится через несколько минут — обновите страницу позже.';

  @override
  String get confirming => 'Подтверждаем оплату. Это займёт несколько секунд.';

  @override
  String get paymentFailed =>
      'Оплата не прошла. Повторите или используйте другую карту.';

  @override
  String get refunded => 'Этот платёж возвращён.';

  @override
  String get members => 'Участники';

  @override
  String membersSemantics(int count, int max) {
    return 'Участников: $count, лимит $max';
  }

  @override
  String limitMembers(String count) {
    return 'Участники: $count';
  }

  @override
  String limitEvents(String count) {
    return 'Мероприятия: $count / мес.';
  }

  @override
  String limitLive(String count) {
    return 'Эфир: $count мин / мес.';
  }

  @override
  String planName(String plan) {
    return 'Тариф «$plan»';
  }

  @override
  String planUntil(String plan, String date) {
    return 'Тариф «$plan» · до $date';
  }

  @override
  String creditDays(String days) {
    return '$days дн.';
  }

  @override
  String get termsTranslationNote =>
      'Перевод носит информационный характер. Юридическую силу имеет турецкий оригинал договора — именно его вы принимаете.';

  @override
  String get showOriginal => 'Показать турецкий оригинал';

  @override
  String get showTranslation => 'Показать перевод';
}
