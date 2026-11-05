// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'billing_l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class BillingL10nEn extends BillingL10n {
  BillingL10nEn([String locale = 'en']) : super(locale);

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get perMonth => 'month';

  @override
  String get perYear => 'year';

  @override
  String get notOnDevice => 'This isn\'t available on this device.';

  @override
  String get goBack => 'Go back';

  @override
  String get payment => 'Payment';

  @override
  String get planUnavailable => 'This plan can\'t be bought right now.';

  @override
  String get backToPlans => 'Back to plans';

  @override
  String get paymentPageFailed =>
      'Couldn\'t open the payment page. Please try again.';

  @override
  String get billingDetails => 'Billing details';

  @override
  String get billingDetailsHint => 'Your invoice is issued with these details.';

  @override
  String get firstName => 'First name';

  @override
  String get lastName => 'Last name';

  @override
  String fieldRequired(String field) {
    return '$field is required.';
  }

  @override
  String get phone => 'Phone';

  @override
  String get phoneInvalid => 'Enter a valid phone number.';

  @override
  String get address => 'Address';

  @override
  String get addressRequired => 'Enter your billing address.';

  @override
  String get city => 'City';

  @override
  String get cityRequired => 'Enter the city.';

  @override
  String get country => 'Country';

  @override
  String get countryRequired => 'Enter the country.';

  @override
  String get termsBefore => 'I have read and accept the ';

  @override
  String get termsAfter => '.';

  @override
  String get acceptTerms => 'Accept the agreement to continue.';

  @override
  String get billingDataUse =>
      'Your billing details are used only to take the payment, invoice it and meet legal record-keeping duties.';

  @override
  String payAmount(String amount) {
    return 'Continue to payment · $amount';
  }

  @override
  String get orderSummary => 'Order summary';

  @override
  String planPeriod(String plan, String period) {
    return '$plan plan · $period';
  }

  @override
  String get start => 'Starts';

  @override
  String get whenConfirmed => 'When the payment is confirmed';

  @override
  String get endEstimated => 'Ends (estimated)';

  @override
  String get carriedOver => 'Carried-over time';

  @override
  String about(String value) {
    return 'about $value';
  }

  @override
  String get total => 'Total';

  @override
  String assuranceTry(String provider) {
    return 'The payment is taken securely by $provider in Turkish lira. Your card details never reach GWAY. It\'s a one-time payment and doesn\'t renew automatically.';
  }

  @override
  String assuranceUsd(String provider) {
    return 'The payment is taken securely by $provider in US dollars. Your card details never reach GWAY. It\'s a one-time payment and doesn\'t renew automatically.';
  }

  @override
  String get overLimit =>
      'The member count is over the plan\'s limit. No new members can join until it\'s below the limit.';

  @override
  String get atLimit =>
      'The group has reached its plan\'s member limit. No new members can join.';

  @override
  String membersOfMax(String count, String max) {
    return '$count / $max members';
  }

  @override
  String get plan => 'Plan';

  @override
  String get getPlan => 'Get a plan';

  @override
  String get upgradePlan => 'Upgrade plan';

  @override
  String planEnds(String date) {
    return 'Your plan ends on $date. Then the group returns to the Free plan.';
  }

  @override
  String get paymentReceivedPersonal => 'Payment received. Your plan is on.';

  @override
  String get planStatus => 'Plan status';

  @override
  String get notActive => 'This plan isn\'t on for your account.';

  @override
  String activeUntil(String date) {
    return 'Your plan is on until $date.';
  }

  @override
  String get buy => 'Buy';

  @override
  String get extend => 'Extend';

  @override
  String get oneTime => 'One-time payment; it doesn\'t renew automatically.';

  @override
  String newPeriodAfter(String date) {
    return 'The new period starts after $date.';
  }

  @override
  String get salesClosed =>
      'Sales of this plan are closed right now. Please try again later.';

  @override
  String continueAmount(String amount) {
    return 'Continue · $amount';
  }

  @override
  String get personalOnly =>
      'This plan covers only you; it doesn\'t affect your group\'s plan.';

  @override
  String saving(int percent) {
    return 'Save $percent%';
  }

  @override
  String untilDate(String date) {
    return 'Until $date';
  }

  @override
  String pricePer(String price, String unit) {
    return '$price / $unit';
  }

  @override
  String get productUnavailable => 'This product can\'t be bought right now.';

  @override
  String get personalProduct => 'Personal product';

  @override
  String offerPeriod(String plan, String period) {
    return '$plan · $period';
  }

  @override
  String get groupReady => 'Your group is ready';

  @override
  String get freeStartBuy =>
      'Your group started on the Free plan. If you need more members, events or live minutes, choose a plan below.';

  @override
  String get freeStartView =>
      'Your group started on the Free plan. The plans\' limits are below.';

  @override
  String get continueFree => 'Continue with Free';

  @override
  String get goToGroup => 'Go to group';

  @override
  String get paymentReceivedGroup => 'Payment received. Your plan is active.';

  @override
  String get membersOnly => 'Only the group\'s members can see its plan.';

  @override
  String get currentPlan => 'Current plan';

  @override
  String get onFree => 'The group is on the Free plan.';

  @override
  String periodEnds(String date) {
    return 'This period ends on $date.';
  }

  @override
  String get overLimitLong =>
      'The member count is over the plan\'s limit. Nobody is removed, but no new members can join until it\'s below the limit.';

  @override
  String get atLimitLong =>
      'The group has reached its member limit. Switch to a bigger plan to accept new members.';

  @override
  String get upcomingPeriods => 'Upcoming periods';

  @override
  String get plans => 'Plans';

  @override
  String get yearlyDeal => 'Yearly · 2 months free';

  @override
  String paymentNoteTry(String provider) {
    return 'The payment is taken by $provider in Turkish lira, based on your country. No automatic renewal.';
  }

  @override
  String paymentNoteUsd(String provider) {
    return 'The payment is taken by $provider in US dollars, based on your country. No automatic renewal.';
  }

  @override
  String get paymentsOff =>
      'Payments can\'t be taken right now. Please try again later.';

  @override
  String get notNow => 'Not available for now';

  @override
  String get choose => 'Choose';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get renew => 'Extend';

  @override
  String get switchTo => 'Switch to this plan';

  @override
  String get paidOverYear =>
      'Your plan is paid for more than a year ahead. For now you can only upgrade.';

  @override
  String startsNowCredit(String credit, String date) {
    return 'Starts now; about $credit of your remaining time is added. Ends: $date.';
  }

  @override
  String startsNow(String date) {
    return 'Starts now. Ends: $date.';
  }

  @override
  String startsAfterCurrent(String date) {
    return 'Starts on $date, after the current period.';
  }

  @override
  String startsWhenEnds(String date) {
    return 'Starts on $date, when the current period ends.';
  }

  @override
  String get confirmPending =>
      'The payment confirmation hasn\'t arrived yet. If you were charged, your plan activates within a few minutes; you can refresh this page later.';

  @override
  String get confirming =>
      'Confirming your payment. This can take a few seconds.';

  @override
  String get paymentFailed =>
      'The payment couldn\'t be completed. Try again or use another card.';

  @override
  String get refunded => 'This payment was refunded.';

  @override
  String get members => 'Members';

  @override
  String membersSemantics(int count, int max) {
    return '$count members, limit $max';
  }

  @override
  String limitMembers(String count) {
    return '$count members';
  }

  @override
  String limitEvents(String count) {
    return '$count events / month';
  }

  @override
  String limitLive(String count) {
    return '$count live minutes / month';
  }

  @override
  String planName(String plan) {
    return '$plan plan';
  }

  @override
  String planUntil(String plan, String date) {
    return '$plan plan · until $date';
  }

  @override
  String creditDays(String days) {
    return '$days days';
  }
}
