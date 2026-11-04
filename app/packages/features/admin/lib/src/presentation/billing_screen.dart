import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/admin_billing.dart';
import '../domain/admin_user.dart';
import 'admin_shell.dart';
import 'payment_providers_panel.dart';
import 'providers.dart';
import 'routes.dart';
import 'widgets.dart';

/// Order status badge; a pending order older than an hour shows as abandoned.
class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.status, this.abandoned = false});

  final AdminOrderStatus status;
  final bool abandoned;

  @override
  Widget build(BuildContext context) => abandoned
      ? const GwBadge('Yarım kaldı', dot: true)
      : GwBadge(
          status.label,
          dot: true,
          tone: switch (status) {
            AdminOrderStatus.paid => GwBadgeTone.primary,
            AdminOrderStatus.pending => GwBadgeTone.info,
            AdminOrderStatus.failed => GwBadgeTone.danger,
            AdminOrderStatus.refunded => GwBadgeTone.neutral,
          },
        );
}

/// "Pro · Aylık".
/// A granted slice has no period; it shows the plan alone.
String planAndPeriod(String plan, String? period) => period == null ? plan : '$plan · ${planPeriodLabels[period] ?? period}';

enum _Tab { orders, subscriptions }

/// Revenue (admins), orders and running subscriptions (docs/ARCHITECTURE.md §7).
class AdminBillingScreen extends ConsumerStatefulWidget {
  const AdminBillingScreen({super.key});

  @override
  ConsumerState<AdminBillingScreen> createState() => _AdminBillingScreenState();
}

class _AdminBillingScreenState extends ConsumerState<AdminBillingScreen> {
  _Tab _tab = _Tab.orders;

  @override
  Widget build(BuildContext context) {
    final canManage = ref.watch(myStaffRoleProvider).value?.canManageBilling ?? false;

    return AdminPage(
      title: 'Abonelikler',
      subtitle: 'Grupların paket ödemeleri ve süren abonelikleri.',
      actions: [
        GwButton(
          label: 'Yenile',
          icon: Icons.refresh,
          variant: GwButtonVariant.secondary,
          onPressed: () => ref
            ..invalidate(billingStatsProvider)
            ..invalidate(paymentProvidersProvider)
            ..invalidate(orderSearchProvider)
            ..invalidate(subscriptionSearchProvider),
        ),
      ],
      children: [
        if (canManage) ...[
          const PaymentProvidersPanel(),
          const SizedBox(height: GwSpacing.lg),
          const _Revenue(),
          const SizedBox(height: GwSpacing.lg),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: SegmentedButton<_Tab>(
            segments: const [
              ButtonSegment(value: _Tab.orders, label: Text('Ödemeler'), icon: Icon(Icons.receipt_long_outlined)),
              ButtonSegment(value: _Tab.subscriptions, label: Text('Abonelikler'), icon: Icon(Icons.event_repeat_outlined)),
            ],
            selected: {_tab},
            showSelectedIcon: false,
            onSelectionChanged: (s) => setState(() => _tab = s.first),
          ),
        ),
        const SizedBox(height: GwSpacing.md),
        switch (_tab) {
          _Tab.orders => const _Orders(),
          _Tab.subscriptions => const _Subscriptions(),
        },
      ],
    );
  }
}

class _Revenue extends ConsumerWidget {
  const _Revenue();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(billingStatsProvider);
    final s = stats.value;
    String? revenue(String currency) => s == null
        ? null
        : formatMoney(s.revenueThisMonth.where((m) => m.currency == currency).fold(0, (sum, m) => sum + m.amountMinor), currency);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StatCardRow(
          cards: [
            StatCard(label: 'Bu ay gelir (TL)', value: null, valueText: revenue('TRY'), icon: Icons.payments_outlined, tone: GwBadgeTone.primary),
            StatCard(label: 'Bu ay gelir (USD)', value: null, valueText: revenue('USD'), icon: Icons.attach_money, tone: GwBadgeTone.info),
            StatCard(label: 'Aktif abonelik', value: s?.activeSubscriptions, icon: Icons.workspace_premium_outlined, tone: GwBadgeTone.primary),
            StatCard(label: 'Bekleyen ödeme', value: s?.pendingOrders, icon: Icons.hourglass_top, tone: GwBadgeTone.neutral),
          ],
        ),
        const SizedBox(height: GwSpacing.lg),
        GwPanel(
          title: 'Aylık gelir',
          subtitle: 'Son 12 ay, ödenen siparişler (iadeler hariç). Ay, Türkiye saatine göredir.',
          padding: EdgeInsets.zero,
          child: switch (stats) {
            AsyncData(:final value) => _RevenueTable(months: value.months),
            AsyncError(:final error) => Padding(
                padding: const EdgeInsets.all(GwSpacing.lg),
                child: GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(billingStatsProvider)),
              ),
            _ => const Padding(padding: EdgeInsets.all(GwSpacing.lg), child: GwSkeleton(height: GwSpacing.xxl * 3)),
          },
        ),
      ],
    );
  }
}

class _RevenueTable extends StatelessWidget {
  const _RevenueTable({required this.months});

  final List<AdminRevenueMonth> months;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final header = textTheme.labelMedium?.copyWith(color: GwColors.textSecondary, letterSpacing: 0.6);
    Widget row(List<Widget> cells, {Color? color}) => Container(
          color: color,
          padding: const EdgeInsets.symmetric(horizontal: GwSpacing.lg, vertical: GwSpacing.sm),
          child: Row(children: [for (final c in cells) Expanded(child: c)]),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        row([Text('AY', style: header), Text('TL', style: header), Text('USD', style: header), Text('ÖDEME', style: header)],
            color: GwColors.surface),
        for (final m in months) ...[
          const Divider(),
          row([
            Text(formatMonthYear(m.month), style: textTheme.bodyMedium),
            Text(formatMoney(m.amountIn('TRY'), 'TRY'), style: textTheme.bodyMedium),
            Text(formatMoney(m.amountIn('USD'), 'USD'), style: textTheme.bodyMedium),
            Text('${m.paidOrders}', style: textTheme.bodyMedium),
          ]),
        ],
      ],
    );
  }
}

/// Search box with a debounce, shared by both lists.
mixin _Search<T extends StatefulWidget> on State<T> {
  final search = TextEditingController();
  Timer? _debounce;
  String query = '';
  int page = 1;

  void onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => setState(() {
          query = value.trim();
          page = 1;
        }));
  }

  void clearSearch() {
    search.clear();
    _debounce?.cancel();
    setState(() {
      query = '';
      page = 1;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    search.dispose();
    super.dispose();
  }
}

class _Orders extends ConsumerStatefulWidget {
  const _Orders();

  @override
  ConsumerState<_Orders> createState() => _OrdersState();
}

class _OrdersState extends ConsumerState<_Orders> with _Search {
  AdminOrderStatus? _status;

  void _clear() {
    _status = null;
    clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    final key = (query: query, status: _status, page: page);
    final result = ref.watch(orderSearchProvider(key));
    final filtered = query.isNotEmpty || _status != null;

    return GwPanel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListToolbar<AdminOrderStatus>(
            controller: search,
            hint: 'Grup adı veya adresi ile ara',
            query: query,
            filters: [for (final s in AdminOrderStatus.values) (s, s.label)],
            selected: _status,
            onSearchChanged: onSearchChanged,
            onFilterChanged: (s) => setState(() {
              _status = s;
              page = 1;
            }),
            onClear: _clear,
          ),
          const Divider(),
          _paged(
            result,
            empty: filtered
                ? GwEmptyState(
                    icon: Icons.search_off,
                    message: 'Aramana ve filtrene uygun ödeme bulunamadı.',
                    actionLabel: 'Filtreleri temizle',
                    onAction: _clear,
                  )
                : GwEmptyState(
                    icon: Icons.receipt_long_outlined,
                    message: 'Henüz paket ödemesi yapılmadı.',
                    actionLabel: 'Yenile',
                    onAction: () => ref.invalidate(orderSearchProvider(key)),
                  ),
            onRetry: () => ref.invalidate(orderSearchProvider(key)),
            noun: 'ödeme',
            onPage: (p) => setState(() => page = p),
            row: (order) => _OrderRow(order: order),
          ),
        ],
      ),
    );
  }
}

class _Subscriptions extends ConsumerStatefulWidget {
  const _Subscriptions();

  @override
  ConsumerState<_Subscriptions> createState() => _SubscriptionsState();
}

class _SubscriptionsState extends ConsumerState<_Subscriptions> with _Search {
  @override
  Widget build(BuildContext context) {
    final key = (query: query, page: page);
    final result = ref.watch(subscriptionSearchProvider(key));

    return GwPanel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListToolbar<void>(
            controller: search,
            hint: 'Grup adı veya adresi ile ara',
            query: query,
            filters: const [],
            selected: null,
            onSearchChanged: onSearchChanged,
            onFilterChanged: (_) {},
            onClear: clearSearch,
          ),
          const Divider(),
          _paged(
            result,
            empty: query.isNotEmpty
                ? GwEmptyState(
                    icon: Icons.search_off,
                    message: 'Aramana uygun abonelik bulunamadı.',
                    actionLabel: 'Aramayı temizle',
                    onAction: clearSearch,
                  )
                : GwEmptyState(
                    icon: Icons.event_repeat_outlined,
                    message: 'Şu anda süren ya da sırada bekleyen abonelik yok.',
                    actionLabel: 'Yenile',
                    onAction: () => ref.invalidate(subscriptionSearchProvider(key)),
                  ),
            onRetry: () => ref.invalidate(subscriptionSearchProvider(key)),
            noun: 'abonelik',
            onPage: (p) => setState(() => page = p),
            row: (s) => _SubscriptionRow(subscription: s),
          ),
        ],
      ),
    );
  }
}

Widget _paged<T>(
  AsyncValue<PagedList<T>> result, {
  required Widget empty,
  required VoidCallback onRetry,
  required String noun,
  required ValueChanged<int> onPage,
  required Widget Function(T item) row,
}) =>
    switch (result) {
      AsyncData(:final value) when value.items.isEmpty =>
        Padding(padding: const EdgeInsets.symmetric(vertical: GwSpacing.xl), child: empty),
      AsyncData(:final value) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final item in value.items) ...[row(item), const Divider()],
            PageFooter(
              from: value.range.$1,
              to: value.range.$2,
              total: value.total,
              noun: noun,
              page: value.page,
              pageCount: value.pageCount,
              onPage: onPage,
            ),
          ],
        ),
      AsyncError(:final error) => Padding(
          padding: const EdgeInsets.symmetric(vertical: GwSpacing.xl),
          child: GwErrorState(message: userMessageOf(error), onRetry: onRetry),
        ),
      _ => const Padding(
          padding: EdgeInsets.all(GwSpacing.lg),
          child: Column(
            children: [
              GwSkeleton(height: GwSpacing.xl),
              SizedBox(height: GwSpacing.md),
              GwSkeleton(height: GwSpacing.xl),
              SizedBox(height: GwSpacing.md),
              GwSkeleton(height: GwSpacing.xl),
            ],
          ),
        ),
    };

/// Group, a detail line, an amount and a badge; wraps on narrow widths.
class _ListRow extends StatelessWidget {
  const _ListRow({required this.title, required this.subtitle, required this.amount, required this.badge, this.onTap});

  final String title;
  final String subtitle;
  final String amount;
  final Widget badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      hoverColor: GwColors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: GwSpacing.lg, vertical: GwSpacing.sm),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.labelLarge),
                  Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(width: GwSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(amount, style: textTheme.labelLarge),
                const SizedBox(height: GwSpacing.xxs),
                badge,
              ],
            ),
            if (onTap != null) ...[
              const SizedBox(width: GwSpacing.xs),
              const Icon(Icons.chevron_right, color: GwColors.textSecondary, size: GwSpacing.lg),
            ],
          ],
        ),
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order});

  final AdminOrder order;

  @override
  Widget build(BuildContext context) {
    final buyer = order.buyerUsername == null ? 'silinmiş hesap' : '@${order.buyerUsername}';
    final reason = order.status == AdminOrderStatus.failed && order.failureReason != null ? ' · ${order.failureReason}' : '';
    return _ListRow(
      title: order.groupName == null ? '${order.planName} · $buyer' : '${order.groupName} (@${order.groupHandle})',
      subtitle: '${planAndPeriod(order.planName, order.period)} · ${providerLabels[order.provider] ?? order.provider}'
          '${order.country == null ? '' : ' (${order.country})'} · $buyer · ${formatDateTime(order.paidAt ?? order.createdAt)}$reason',
      amount: formatMoney(order.amountMinor, order.currency),
      badge: OrderStatusBadge(status: order.status, abandoned: order.isAbandoned(DateTime.now())),
      onTap: order.groupId == null ? null : () => context.go(AdminRoutes.group(order.groupId!)),
    );
  }
}

class _SubscriptionRow extends StatelessWidget {
  const _SubscriptionRow({required this.subscription});

  final AdminSubscription subscription;

  @override
  Widget build(BuildContext context) {
    final s = subscription;
    return _ListRow(
      title: '${s.groupName} (@${s.groupHandle})',
      subtitle: '${planAndPeriod(s.planName, s.period)} · ${formatDate(s.startsAt)} – ${formatDate(s.endsAt)}',
      amount: switch ((s.amountMinor, s.currency)) {
        (final amount?, final currency?) => formatMoney(amount, currency),
        _ => 'Tanımlandı',
      },
      badge: s.isCurrent(DateTime.now())
          ? const GwBadge('Aktif', tone: GwBadgeTone.primary, dot: true)
          : const GwBadge('Sırada', tone: GwBadgeTone.info, dot: true),
      onTap: () => context.go(AdminRoutes.group(s.groupId)),
    );
  }
}
