import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/billing.dart';

/// Reads from Supabase (RLS); offers and checkout go through the C# API,
/// because the market and the price are decided on the server.
class BillingRepositoryImpl implements BillingRepository {
  BillingRepositoryImpl(this._client, this._api);

  final SupabaseClient _client;
  final ApiClient _api;

  static const _planColumns = 'slug, name, tier, max_members, monthly_events, monthly_live_minutes, is_active';

  static Plan _plan(Map<String, dynamic> r, {String slug = 'slug', String name = 'name'}) => Plan(
        slug: r[slug] as String,
        name: r[name] as String,
        tier: r['tier'] as int,
        maxMembers: r['max_members'] as int,
        monthlyEvents: r['monthly_events'] as int,
        monthlyLiveMinutes: r['monthly_live_minutes'] as int,
        isActive: r['is_active'] as bool? ?? true,
      );

  static DateTime? _date(Object? value) => value is String ? DateTime.parse(value) : null;

  Future<Result<T>> _read<T>(Future<T> Function() query) async {
    try {
      return Ok(await query());
    } on Object catch (e) {
      return Err(failureFromSupabase(e));
    }
  }

  @override
  Future<Result<List<Plan>>> plans() => _read(() async {
        final rows = await _client.from('plans').select(_planColumns).order('tier', ascending: true);
        return [for (final r in rows) _plan(r)];
      });

  @override
  Future<Result<GroupPlan?>> groupPlan(String groupId) => _read(() async {
        final rows = await _client.rpc<List<dynamic>>('group_plan', params: {'target_group': groupId});
        if (rows.isEmpty) return null;
        final r = (rows.first as Map).cast<String, dynamic>();
        return GroupPlan(
          plan: _plan(r, slug: 'plan_slug', name: 'plan_name'),
          memberCount: r['member_count'] as int,
          currentPeriodEndsAt: _date(r['current_period_ends_at']),
          paidUntil: _date(r['paid_until']),
        );
      });

  @override
  Future<Result<List<PlanSlice>>> timeline(String groupId) => _read(() async {
        final rows = await _client
            .from('group_subscriptions')
            .select('plan_slug, period, starts_at, ends_at')
            .eq('group_id', groupId)
            .gt('ends_at', DateTime.now().toUtc().toIso8601String())
            .order('starts_at', ascending: true);
        return [
          for (final r in rows)
            if (r['ends_at'] != r['starts_at'])
              PlanSlice(
                planSlug: r['plan_slug'] as String,
                period: r['period'] == null ? null : PlanPeriod.parse(r['period']),
                startsAt: DateTime.parse(r['starts_at'] as String),
                endsAt: DateTime.parse(r['ends_at'] as String),
              ),
        ];
      });

  @override
  Future<Result<SalesTerms>> salesTerms() => _read(() async {
        final r = await _client
            .from('legal_documents')
            .select('version, title, body')
            .eq('kind', 'distance_sales')
            .order('version', ascending: false)
            .limit(1)
            .single();
        return SalesTerms(version: r['version'] as int, title: r['title'] as String, body: r['body'] as String);
      });

  @override
  Future<Result<BillingDetails?>> lastBillingDetails() => _read(() async {
        final id = _client.auth.currentUser?.id;
        if (id == null) return null;
        final r = await _client
            .from('billing_orders')
            .select('billing_details')
            .eq('buyer_id', id)
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();
        final details = r?['billing_details'];
        return details is Map ? BillingDetails.fromJson(details.cast<String, Object?>()) : null;
      });

  @override
  Future<Result<Order>> order(String orderId) => _read(() async {
        final r = await _client.from('billing_orders').select('id, status, plan_slug, personal_plan_slug, period').eq('id', orderId).single();
        return Order(
          id: r['id'] as String,
          status: OrderStatus.parse(r['status']),
          planSlug: (r['plan_slug'] ?? r['personal_plan_slug']) as String,
          period: PlanPeriod.parse(r['period']),
        );
      });

  static Market _market(Object? json) {
    final market = (json! as Map).cast<String, Object?>();
    return Market(
      country: market['country']! as String,
      provider: PaymentProvider.parse(market['provider']),
      currency: market['currency']! as String,
    );
  }

  @override
  Future<Result<PersonalOffer>> personalOffer(String slug) => _api.get('/billing/me/plans/$slug/offer', decode: (json) {
        final j = (json! as Map).cast<String, Object?>();
        return PersonalOffer(
          market: _market(j['market']),
          purchasesEnabled: j['purchasesEnabled']! as bool,
          planSlug: j['planSlug']! as String,
          planName: j['planName']! as String,
          activeUntil: j['activeUntil'] is String ? DateTime.parse(j['activeUntil']! as String) : null,
          salesTermsVersion: j['salesTermsVersion']! as int,
          options: [
            for (final o in (j['options']! as List).cast<Map<String, Object?>>())
              PersonalOption(
                period: PlanPeriod.parse(o['period']),
                amountMinor: o['amountMinor']! as int,
                startsAt: DateTime.parse(o['startsAt']! as String),
                endsAt: DateTime.parse(o['endsAt']! as String),
              ),
          ],
        );
      });

  @override
  Future<Result<Uri>> personalCheckout(String slug, CheckoutRequest request) => _api.post(
        '/billing/me/plans/$slug/orders',
        body: {
          'period': request.period.code,
          'currency': request.currency,
          'salesTermsVersion': request.salesTermsVersion,
          'billing': request.details.toJson(),
        },
        decode: (json) => Uri.parse((json! as Map)['paymentUrl']! as String),
      );

  @override
  Future<Result<Offer>> offer(String groupId) => _api.get('/billing/groups/$groupId/offer', decode: (json) {
        final j = (json! as Map).cast<String, Object?>();
        return Offer(
          market: _market(j['market']),
          purchasesEnabled: j['purchasesEnabled']! as bool,
          currentPlanSlug: j['currentPlanSlug']! as String,
          salesTermsVersion: j['salesTermsVersion']! as int,
          options: [
            for (final o in (j['options']! as List).cast<Map<String, Object?>>())
              PlanOption(
                planSlug: o['planSlug']! as String,
                period: PlanPeriod.parse(o['period']),
                amountMinor: o['amountMinor']! as int,
                change: PlanChange.parse(o['change']),
                startsAt: DateTime.parse(o['startsAt']! as String),
                endsAt: DateTime.parse(o['endsAt']! as String),
                credit: Duration(seconds: o['creditSeconds']! as int),
                available: o['available']! as bool,
              ),
          ],
        );
      });

  @override
  Future<Result<Uri>> checkout(String groupId, CheckoutRequest request) => _api.post(
        '/billing/groups/$groupId/orders',
        body: {
          'planSlug': request.planSlug,
          'period': request.period.code,
          'currency': request.currency,
          'salesTermsVersion': request.salesTermsVersion,
          'billing': request.details.toJson(),
        },
        decode: (json) => Uri.parse((json! as Map)['paymentUrl']! as String),
      );
}
