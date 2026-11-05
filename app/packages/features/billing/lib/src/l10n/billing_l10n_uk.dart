// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'billing_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class BillingL10nUk extends BillingL10n {
  BillingL10nUk([String locale = 'uk']) : super(locale);

  @override
  String get monthly => 'На місяць';

  @override
  String get yearly => 'На рік';

  @override
  String get perMonth => 'міс.';

  @override
  String get perYear => 'рік';

  @override
  String get notOnDevice => 'Недоступно на цьому пристрої.';

  @override
  String get goBack => 'Назад';

  @override
  String get payment => 'Оплата';

  @override
  String get planUnavailable => 'Зараз цей тариф придбати не можна.';

  @override
  String get backToPlans => 'До тарифів';

  @override
  String get paymentPageFailed =>
      'Не вдалося відкрити сторінку оплати. Спробуйте ще раз.';

  @override
  String get billingDetails => 'Платіжні дані';

  @override
  String get billingDetailsHint => 'Рахунок оформлюється на ці дані.';

  @override
  String get firstName => 'Ім’я';

  @override
  String get lastName => 'Прізвище';

  @override
  String fieldRequired(String field) {
    return 'Поле «$field» обов’язкове.';
  }

  @override
  String get phone => 'Телефон';

  @override
  String get phoneInvalid => 'Введіть правильний номер телефону.';

  @override
  String get address => 'Адреса';

  @override
  String get addressRequired => 'Введіть адресу для рахунку.';

  @override
  String get city => 'Місто';

  @override
  String get cityRequired => 'Введіть місто.';

  @override
  String get country => 'Країна';

  @override
  String get countryRequired => 'Введіть країну.';

  @override
  String get termsBefore => 'Я прочитав(-ла) і приймаю: ';

  @override
  String get termsAfter => '.';

  @override
  String get acceptTerms => 'Щоб продовжити, прийміть договір.';

  @override
  String get billingDataUse =>
      'Платіжні дані використовуються лише для оплати, рахунку й зберігання за законом.';

  @override
  String payAmount(String amount) {
    return 'До оплати · $amount';
  }

  @override
  String get orderSummary => 'Підсумок замовлення';

  @override
  String planPeriod(String plan, String period) {
    return 'Тариф «$plan» · $period';
  }

  @override
  String get start => 'Початок';

  @override
  String get whenConfirmed => 'Після підтвердження оплати';

  @override
  String get endEstimated => 'Закінчення (приблизно)';

  @override
  String get carriedOver => 'Перенесений строк';

  @override
  String about(String value) {
    return 'близько $value';
  }

  @override
  String get total => 'Разом';

  @override
  String assuranceTry(String provider) {
    return 'Оплату безпечно приймає $provider у турецьких лірах. Дані картки не передаються GWAY. Разовий платіж без автоподовження.';
  }

  @override
  String assuranceUsd(String provider) {
    return 'Оплату безпечно приймає $provider у доларах США. Дані картки не передаються GWAY. Разовий платіж без автоподовження.';
  }

  @override
  String get overLimit =>
      'Учасників більше за ліміт тарифу. Нові не зможуть вступити, доки число не стане нижчим.';

  @override
  String get atLimit =>
      'Група досягла ліміту учасників тарифу. Нових прийняти не можна.';

  @override
  String membersOfMax(String count, String max) {
    return 'Учасники: $count / $max';
  }

  @override
  String get plan => 'Тариф';

  @override
  String get getPlan => 'Вибрати тариф';

  @override
  String get upgradePlan => 'Підвищити тариф';

  @override
  String planEnds(String date) {
    return 'Тариф закінчиться $date. Потім група повернеться на безкоштовний.';
  }

  @override
  String get paymentReceivedPersonal => 'Оплату отримано. Тариф підключено.';

  @override
  String get planStatus => 'Статус тарифу';

  @override
  String get notActive => 'Тариф не підключено до вашого акаунта.';

  @override
  String activeUntil(String date) {
    return 'Тариф діє до $date.';
  }

  @override
  String get buy => 'Купити';

  @override
  String get extend => 'Продовжити';

  @override
  String get oneTime => 'Разовий платіж, без автоподовження.';

  @override
  String newPeriodAfter(String date) {
    return 'Новий строк почнеться після $date.';
  }

  @override
  String get salesClosed => 'Продаж тарифу зараз закрито. Спробуйте пізніше.';

  @override
  String continueAmount(String amount) {
    return 'Продовжити · $amount';
  }

  @override
  String get personalOnly => 'Тариф лише для вас і не впливає на тариф групи.';

  @override
  String saving(int percent) {
    return 'Вигода $percent%';
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
  String get productUnavailable => 'Зараз цей продукт придбати не можна.';

  @override
  String get personalProduct => 'Особистий продукт';

  @override
  String offerPeriod(String plan, String period) {
    return '$plan · $period';
  }

  @override
  String get groupReady => 'Група готова';

  @override
  String get freeStartBuy =>
      'Група почала з безкоштовного тарифу. Якщо потрібно більше учасників, заходів чи хвилин ефіру, виберіть тариф нижче.';

  @override
  String get freeStartView =>
      'Група почала з безкоштовного тарифу. Ліміти тарифів — нижче.';

  @override
  String get continueFree => 'Продовжити безкоштовно';

  @override
  String get goToGroup => 'До групи';

  @override
  String get paymentReceivedGroup => 'Оплату отримано. Тариф активний.';

  @override
  String get membersOnly => 'Тариф групи бачать лише її учасники.';

  @override
  String get currentPlan => 'Поточний тариф';

  @override
  String get onFree => 'Група на безкоштовному тарифі.';

  @override
  String periodEnds(String date) {
    return 'Поточний строк закінчується $date.';
  }

  @override
  String get overLimitLong =>
      'Учасників більше за ліміт. Нікого не виключать, але нові не вступлять, доки число не стане нижчим.';

  @override
  String get atLimitLong =>
      'Група досягла ліміту. Щоб приймати нових, перейдіть на більший тариф.';

  @override
  String get upcomingPeriods => 'Наступні періоди';

  @override
  String get plans => 'Тарифи';

  @override
  String get yearlyDeal => 'На рік · 2 місяці безкоштовно';

  @override
  String paymentNoteTry(String provider) {
    return 'Оплата через $provider у турецьких лірах, залежно від країни. Без автоподовження.';
  }

  @override
  String paymentNoteUsd(String provider) {
    return 'Оплата через $provider у доларах США, залежно від країни. Без автоподовження.';
  }

  @override
  String get paymentsOff => 'Зараз оплата недоступна. Спробуйте пізніше.';

  @override
  String get notNow => 'Поки недоступно';

  @override
  String get choose => 'Вибрати';

  @override
  String get upgrade => 'Підвищити';

  @override
  String get renew => 'Продовжити';

  @override
  String get switchTo => 'Перейти на цей тариф';

  @override
  String get paidOverYear =>
      'Тариф оплачено більше ніж на рік уперед. Поки можна лише підвищити.';

  @override
  String startsNowCredit(String credit, String date) {
    return 'Почнеться одразу; додасться близько $credit залишку строку. Закінчення: $date.';
  }

  @override
  String startsNow(String date) {
    return 'Почнеться одразу. Закінчення: $date.';
  }

  @override
  String startsAfterCurrent(String date) {
    return 'Почнеться $date, після поточного строку.';
  }

  @override
  String startsWhenEnds(String date) {
    return 'Почнеться $date, коли закінчиться поточний строк.';
  }

  @override
  String get confirmPending =>
      'Підтвердження оплати ще не надійшло. Якщо гроші списано, тариф увімкнеться за кілька хвилин — оновіть сторінку пізніше.';

  @override
  String get confirming => 'Підтверджуємо оплату. Це займе кілька секунд.';

  @override
  String get paymentFailed =>
      'Оплата не пройшла. Повторіть або скористайтеся іншою карткою.';

  @override
  String get refunded => 'Цей платіж повернуто.';

  @override
  String get members => 'Учасники';

  @override
  String membersSemantics(int count, int max) {
    return 'Учасників: $count, ліміт $max';
  }

  @override
  String limitMembers(String count) {
    return 'Учасники: $count';
  }

  @override
  String limitEvents(String count) {
    return 'Заходи: $count / міс.';
  }

  @override
  String limitLive(String count) {
    return 'Ефір: $count хв / міс.';
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
      'Переклад має інформаційний характер. Юридичну силу має турецький оригінал договору — саме його ви приймаєте.';

  @override
  String get showOriginal => 'Показати турецький оригінал';

  @override
  String get showTranslation => 'Показати переклад';

  @override
  String get planNameFree => 'Безкоштовний';

  @override
  String get planNameStarter => 'Стартовий';

  @override
  String get planNameCommunity => 'Спільнота';
}
