import 'package:core/core.dart';

/// Prepaid billing period (docs/ARCHITECTURE.md §7).
enum PlanPeriod {
  month('month', 'Aylık', 'ay'),
  year('year', 'Yıllık', 'yıl');

  const PlanPeriod(this.code, this.label, this.unit);

  final String code;
  final String label;

  /// Price suffix: "249 ₺ / ay".
  final String unit;

  static PlanPeriod parse(Object? code) => code == 'year' ? year : month;
}

/// A plan of the catalog (`public.plans`) and its limits.
class Plan {
  const Plan({
    required this.slug,
    required this.name,
    required this.tier,
    required this.maxMembers,
    required this.monthlyEvents,
    required this.monthlyLiveMinutes,
    this.isActive = true,
  });

  static const freeSlug = 'free';

  final String slug;
  final String name;
  final int tier;
  final int maxMembers;
  final int monthlyEvents;
  final int monthlyLiveMinutes;
  final bool isActive;

  bool get isFree => slug == freeSlug;
}

/// The plan a group is on right now, with its usage (`public.group_plan`).
class GroupPlan {
  const GroupPlan({
    required this.plan,
    required this.memberCount,
    this.currentPeriodEndsAt,
    this.paidUntil,
  });

  final Plan plan;
  final int memberCount;

  /// End of the slice in effect now; null on the free plan.
  final DateTime? currentPeriodEndsAt;

  /// End of the whole prepaid timeline, renewals included.
  final DateTime? paidUntil;

  static const reminderWindow = Duration(days: 7);

  bool get isFull => memberCount >= plan.maxMembers;

  bool get isOverLimit => memberCount > plan.maxMembers;

  /// The paid time ends within a week and nothing follows it.
  bool renewalDue(DateTime now) => paidUntil != null && paidUntil!.difference(now) <= reminderWindow;
}

/// One paid slice of the group's timeline (owner only, RLS).
class PlanSlice {
  const PlanSlice({required this.planSlug, required this.period, required this.startsAt, required this.endsAt});

  final String planSlug;
  final PlanPeriod period;
  final DateTime startsAt;
  final DateTime endsAt;
}

enum PaymentProvider {
  paytr('paytr', 'PayTR'),
  iyzico('iyzico', 'iyzico');

  const PaymentProvider(this.code, this.label);

  final String code;
  final String label;

  static PaymentProvider parse(Object? code) => code == 'iyzico' ? iyzico : paytr;
}

/// Where the buyer pays, decided by the server from the request's country.
class Market {
  const Market({required this.country, required this.provider, required this.currency});

  final String country;
  final PaymentProvider provider;

  /// `TRY` or `USD`.
  final String currency;
}

enum PlanChange {
  upgrade('upgrade'),
  renewal('renewal'),
  downgrade('downgrade');

  const PlanChange(this.code);

  final String code;

  static PlanChange parse(Object? code) => values.firstWhere((c) => c.code == code, orElse: () => upgrade);
}

/// A purchasable (plan, period) with where it would land on the timeline.
class PlanOption {
  const PlanOption({
    required this.planSlug,
    required this.period,
    required this.amountMinor,
    required this.change,
    required this.startsAt,
    required this.endsAt,
    this.credit = Duration.zero,
    this.available = true,
  });

  final String planSlug;
  final PlanPeriod period;
  final int amountMinor;
  final PlanChange change;
  final DateTime startsAt;
  final DateTime endsAt;

  /// Time carried over from the current plan on an upgrade (estimate).
  final Duration credit;

  /// False when the timeline is already paid far ahead.
  final bool available;
}

class Offer {
  const Offer({
    required this.market,
    required this.purchasesEnabled,
    required this.currentPlanSlug,
    required this.salesTermsVersion,
    required this.options,
  });

  final Market market;

  /// False when the market's payment provider is not configured.
  final bool purchasesEnabled;
  final String currentPlanSlug;
  final int salesTermsVersion;
  final List<PlanOption> options;

  PlanOption? option(String planSlug, PlanPeriod period) {
    for (final o in options) {
      if (o.planSlug == planSlug && o.period == period) return o;
    }
    return null;
  }
}

/// Ön Bilgilendirme Formu ve Mesafeli Satış Sözleşmesi, accepted at checkout.
class SalesTerms {
  const SalesTerms({required this.version, required this.title, required this.body});

  final int version;
  final String title;
  final String body;
}

class BillingDetails {
  const BillingDetails({
    this.firstName = '',
    this.lastName = '',
    this.phone = '',
    this.address = '',
    this.city = '',
    this.country = '',
  });

  factory BillingDetails.fromJson(Map<String, Object?> j) => BillingDetails(
        firstName: j['firstName'] as String? ?? '',
        lastName: j['lastName'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
        address: j['address'] as String? ?? '',
        city: j['city'] as String? ?? '',
        country: j['country'] as String? ?? '',
      );

  final String firstName;
  final String lastName;
  final String phone;
  final String address;
  final String city;
  final String country;

  Map<String, Object?> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'address': address,
        'city': city,
        'country': country,
      };
}

class CheckoutRequest {
  const CheckoutRequest({
    required this.planSlug,
    required this.period,
    required this.currency,
    required this.salesTermsVersion,
    required this.details,
  });

  final String planSlug;
  final PlanPeriod period;
  final String currency;
  final int salesTermsVersion;
  final BillingDetails details;
}

enum OrderStatus {
  pending('pending'),
  paid('paid'),
  failed('failed'),
  refunded('refunded');

  const OrderStatus(this.code);

  final String code;

  static OrderStatus parse(Object? code) => values.firstWhere((s) => s.code == code, orElse: () => pending);
}

class Order {
  const Order({required this.id, required this.status, required this.planSlug, required this.period});

  final String id;
  final OrderStatus status;
  final String planSlug;
  final PlanPeriod period;
}

abstract interface class BillingRepository {
  /// The whole catalog, by tier.
  Future<Result<List<Plan>>> plans();

  /// Null when the user is not a member of the group.
  Future<Result<GroupPlan?>> groupPlan(String groupId);

  /// Current and queued slices (owner).
  Future<Result<List<PlanSlice>>> timeline(String groupId);

  Future<Result<Offer>> offer(String groupId);

  Future<Result<SalesTerms>> salesTerms();

  /// Details of the user's last order, to prefill the form.
  Future<Result<BillingDetails?>> lastBillingDetails();

  /// Opens the order and returns the provider's payment page.
  Future<Result<Uri>> checkout(String groupId, CheckoutRequest request);

  Future<Result<Order>> order(String orderId);
}
