import '../domain/billing.dart';

/// Route paths owned by the billing feature (under the group's page).
abstract final class BillingRoutes {
  static String plan(String handle) => '/g/$handle/plan';

  static String checkout(String handle, String planSlug, PlanPeriod period) =>
      Uri(path: '/g/$handle/plan/checkout', queryParameters: {'plan': planSlug, 'period': period.code}).toString();
}
