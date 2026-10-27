import 'package:core/core.dart';

import 'admin_user.dart';

const planPeriodLabels = {'month': 'Aylık', 'year': 'Yıllık'};

const providerLabels = {'paytr': 'PayTR', 'iyzico': 'iyzico'};

class AdminMoney {
  const AdminMoney({required this.currency, required this.amountMinor});

  factory AdminMoney.fromJson(Map<String, Object?> j) =>
      AdminMoney(currency: j['currency']! as String, amountMinor: j['amountMinor']! as int);

  final String currency;
  final int amountMinor;

  @override
  String toString() => formatMoney(amountMinor, currency);
}

List<AdminMoney> _money(Object? json) => [for (final m in (json! as List).cast<Map<String, Object?>>()) AdminMoney.fromJson(m)];

class AdminRevenueMonth {
  const AdminRevenueMonth({required this.month, required this.revenue, required this.paidOrders});

  factory AdminRevenueMonth.fromJson(Map<String, Object?> j) => AdminRevenueMonth(
        month: DateTime.parse(j['month']! as String),
        revenue: _money(j['revenue']),
        paidOrders: j['paidOrders']! as int,
      );

  final DateTime month;
  final List<AdminMoney> revenue;
  final int paidOrders;

  int amountIn(String currency) => revenue.where((m) => m.currency == currency).fold(0, (sum, m) => sum + m.amountMinor);
}

class AdminBillingStats {
  const AdminBillingStats({
    required this.activeSubscriptions,
    required this.paidGroups,
    required this.revenueThisMonth,
    required this.pendingOrders,
    required this.months,
  });

  factory AdminBillingStats.fromJson(Map<String, Object?> j) => AdminBillingStats(
        activeSubscriptions: j['activeSubscriptions']! as int,
        paidGroups: j['paidGroups']! as int,
        revenueThisMonth: _money(j['revenueThisMonth']),
        pendingOrders: j['pendingOrders']! as int,
        months: [for (final m in (j['months']! as List).cast<Map<String, Object?>>()) AdminRevenueMonth.fromJson(m)],
      );

  final int activeSubscriptions;
  final int paidGroups;
  final List<AdminMoney> revenueThisMonth;

  /// Opened in the last hour and not settled yet.
  final int pendingOrders;

  /// Last 12 months, newest first.
  final List<AdminRevenueMonth> months;
}

enum AdminOrderStatus {
  pending('pending', 'Bekliyor'),
  paid('paid', 'Ödendi'),
  failed('failed', 'Başarısız'),
  refunded('refunded', 'İade edildi');

  const AdminOrderStatus(this.code, this.label);

  final String code;
  final String label;

  static AdminOrderStatus parse(Object? code) => values.firstWhere((s) => s.code == code, orElse: () => pending);
}

class AdminOrder {
  const AdminOrder({
    required this.id,
    required this.buyerId,
    required this.planName,
    required this.period,
    required this.provider,
    required this.currency,
    required this.amountMinor,
    required this.status,
    required this.createdAt,
    this.groupId,
    this.groupName,
    this.groupHandle,
    this.buyerUsername,
    this.country,
    this.failureReason,
    this.paidAt,
  });

  factory AdminOrder.fromJson(Map<String, Object?> j) => AdminOrder(
        id: j['id']! as String,
        groupId: j['groupId'] as String?,
        groupName: j['groupName'] as String?,
        groupHandle: j['groupHandle'] as String?,
        buyerId: j['buyerId']! as String,
        buyerUsername: j['buyerUsername'] as String?,
        planName: j['planName']! as String,
        period: j['period']! as String,
        provider: j['provider']! as String,
        country: j['country'] as String?,
        currency: j['currency']! as String,
        amountMinor: j['amountMinor']! as int,
        status: AdminOrderStatus.parse(j['status']),
        failureReason: j['failureReason'] as String?,
        createdAt: DateTime.parse(j['createdAt']! as String),
        paidAt: j['paidAt'] is String ? DateTime.parse(j['paidAt']! as String) : null,
      );

  final String id;

  /// Null once the group was deleted; the order stays as a financial record.
  final String? groupId;

  /// Null for a personal plan (Eşleşme Premium), bought by the buyer for themselves.
  final String? groupName;
  final String? groupHandle;
  final String buyerId;
  final String? buyerUsername;
  final String planName;
  final String period;
  final String provider;
  final String? country;
  final String currency;
  final int amountMinor;
  final AdminOrderStatus status;
  final String? failureReason;
  final DateTime createdAt;
  final DateTime? paidAt;

  static const abandonedAfter = Duration(hours: 1);

  /// Never paid and too old to be in progress.
  bool isAbandoned(DateTime now) => status == AdminOrderStatus.pending && now.difference(createdAt) > abandonedAfter;
}

class AdminSubscription {
  const AdminSubscription({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.groupHandle,
    required this.planName,
    required this.period,
    required this.startsAt,
    required this.endsAt,
    required this.orderId,
    required this.orderStatus,
    required this.provider,
    required this.currency,
    required this.amountMinor,
    this.canceledAt,
    this.cancelReason,
  });

  factory AdminSubscription.fromJson(Map<String, Object?> j) => AdminSubscription(
        id: j['id']! as String,
        groupId: j['groupId']! as String,
        groupName: j['groupName']! as String,
        groupHandle: j['groupHandle']! as String,
        planName: j['planName']! as String,
        period: j['period']! as String,
        startsAt: DateTime.parse(j['startsAt']! as String),
        endsAt: DateTime.parse(j['endsAt']! as String),
        canceledAt: j['canceledAt'] is String ? DateTime.parse(j['canceledAt']! as String) : null,
        cancelReason: j['cancelReason'] as String?,
        orderId: j['orderId']! as String,
        orderStatus: AdminOrderStatus.parse(j['orderStatus']),
        provider: j['provider']! as String,
        currency: j['currency']! as String,
        amountMinor: j['amountMinor']! as int,
      );

  final String id;
  final String groupId;
  final String groupName;
  final String groupHandle;
  final String planName;
  final String period;
  final DateTime startsAt;
  final DateTime endsAt;
  final DateTime? canceledAt;

  /// `upgraded` or `admin`.
  final String? cancelReason;
  final String orderId;
  final AdminOrderStatus orderStatus;
  final String provider;
  final String currency;
  final int amountMinor;

  bool isCurrent(DateTime now) => !startsAt.isAfter(now) && endsAt.isAfter(now);

  /// Can still be cancelled: not cancelled and not over.
  bool isLive(DateTime now) => canceledAt == null && endsAt.isAfter(now);
}

class AdminPlanPrice {
  const AdminPlanPrice({required this.currency, required this.period, required this.amountMinor});

  factory AdminPlanPrice.fromJson(Map<String, Object?> j) => AdminPlanPrice(
        currency: j['currency']! as String,
        period: j['period']! as String,
        amountMinor: j['amountMinor']! as int,
      );

  final String currency;
  final String period;
  final int amountMinor;

  Map<String, Object?> toJson() => {'currency': currency, 'period': period, 'amountMinor': amountMinor};
}

class AdminPlan {
  const AdminPlan({
    required this.slug,
    required this.name,
    required this.tier,
    required this.maxMembers,
    required this.monthlyEvents,
    required this.monthlyLiveMinutes,
    required this.isActive,
    required this.activeGroups,
    required this.prices,
  });

  factory AdminPlan.fromJson(Map<String, Object?> j) => AdminPlan(
        slug: j['slug']! as String,
        name: j['name']! as String,
        tier: j['tier']! as int,
        maxMembers: j['maxMembers']! as int,
        monthlyEvents: j['monthlyEvents']! as int,
        monthlyLiveMinutes: j['monthlyLiveMinutes']! as int,
        isActive: j['isActive']! as bool,
        activeGroups: j['activeGroups']! as int,
        prices: [for (final p in (j['prices']! as List).cast<Map<String, Object?>>()) AdminPlanPrice.fromJson(p)],
      );

  final String slug;
  final String name;
  final int tier;
  final int maxMembers;
  final int monthlyEvents;
  final int monthlyLiveMinutes;
  final bool isActive;

  /// Groups on this plan right now.
  final int activeGroups;
  final List<AdminPlanPrice> prices;

  bool get isFree => slug == 'free';

  int? price(String currency, String period) {
    for (final p in prices) {
      if (p.currency == currency && p.period == period) return p.amountMinor;
    }
    return null;
  }
}

class AdminPlanUpdate {
  const AdminPlanUpdate({
    required this.name,
    required this.maxMembers,
    required this.monthlyEvents,
    required this.monthlyLiveMinutes,
    required this.isActive,
    required this.prices,
  });

  final String name;
  final int maxMembers;
  final int monthlyEvents;
  final int monthlyLiveMinutes;
  final bool isActive;
  final List<AdminPlanPrice> prices;

  Map<String, Object?> toJson() => {
        'name': name,
        'maxMembers': maxMembers,
        'monthlyEvents': monthlyEvents,
        'monthlyLiveMinutes': monthlyLiveMinutes,
        'isActive': isActive,
        'prices': [for (final p in prices) p.toJson()],
      };
}

typedef OrderPage = PagedList<AdminOrder>;

typedef SubscriptionPage = PagedList<AdminSubscription>;

abstract interface class AdminBillingRepository {
  Future<Result<AdminBillingStats>> stats();

  Future<Result<OrderPage>> orders({String? query, AdminOrderStatus? status, String? provider, int page = 1});

  Future<Result<SubscriptionPage>> subscriptions({String? query, int page = 1});

  Future<Result<List<AdminPlan>>> plans();

  Future<Result<void>> updatePlan(String slug, AdminPlanUpdate update);

  Future<Result<void>> cancelSubscription(String id, {required String reason, required bool refunded});
}
