import '../domain/billing.dart';

/// Route paths owned by the billing feature (under the group's page).
abstract final class BillingRoutes {
  static String plan(String handle) => '/g/$handle/plan';

  static String checkout(String handle, String planSlug, PlanPeriod period) =>
      Uri(path: '/g/$handle/plan/checkout', queryParameters: {'plan': planSlug, 'period': period.code}).toString();

  /// Checkout of a personal plan (Eşleşme Premium).
  static String personalCheckout(String slug, PlanPeriod period) =>
      Uri(path: '/premium/$slug/checkout', queryParameters: {'period': period.code}).toString();
}
