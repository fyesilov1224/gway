import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/admin_billing.dart';
import '../domain/admin_group.dart';
import 'billing_screen.dart';
import 'providers.dart';

/// The group's plan and its whole timeline. Platform admins give the group a plan, cancel all of its
/// time or one slice here; every reason is kept (docs/ARCHITECTURE.md §7, Yönetici işlemleri).
class GroupPlanPanel extends ConsumerWidget {
  const GroupPlanPanel({super.key, required this.detail});

  final AdminGroupDetail detail;

  void _refresh(WidgetRef ref) => ref
    ..invalidate(groupDetailProvider(detail.group.id))
    ..invalidate(subscriptionSearchProvider)
    ..invalidate(orderSearchProvider)
    ..invalidate(billingStatsProvider)
    ..invalidate(adminPlansProvider);

  void _say(BuildContext context, Result<void> result, String done) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(switch (result) {
          Ok() => done,
          Err(:final failure) => failure.userMessage,
        }),
      ));

  Future<void> _grant(BuildContext context, WidgetRef ref) async {
    final plans = await ref.read(adminPlansProvider.future);
    if (!context.mounted) return;
    final request = await showDialog<GrantGroupPlanRequest>(
      context: context,
      builder: (_) => GrantGroupPlanDialog(plans: [for (final p in plans) if (p.slug != 'free') p], currentSlug: detail.plan.slug),
    );
    if (request == null || !context.mounted) return;
    final result = await ref
        .read(adminBillingRepositoryProvider)
        .grantGroupPlan(detail.group.id, slug: request.plan.slug, days: request.days, reason: request.reason);
    if (!context.mounted) return;
    _refresh(ref);
    _say(context, result, '${detail.group.name} için ${request.days} gün ${request.plan.name} tanımlandı.');
  }

  Future<void> _cancelAll(BuildContext context, WidgetRef ref) async {
    final request = await showDialog<({String reason, bool refunded})>(
      context: context,
      builder: (_) => const CancelPlanDialog(
        title: 'Paketi iptal et',
        message: 'Grubun süren ve sıradaki bütün paket süresi hemen biter; grup Ücretsiz pakete döner. '
            'İade, ödeme sağlayıcısının panelinden ayrıca yapılır.',
      ),
    );
    if (request == null || !context.mounted) return;
    final result = await ref
        .read(adminBillingRepositoryProvider)
        .cancelGroupPlan(detail.group.id, reason: request.reason, refunded: request.refunded);
    if (!context.mounted) return;
    _refresh(ref);
    _say(context, result, 'Grubun paketi iptal edildi.');
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref, AdminSubscription s) async {
    final request = await showDialog<({String reason, bool refunded})>(
      context: context,
      builder: (_) => const CancelPlanDialog(
        title: 'Aboneliği iptal et',
        message: 'Süren dönem hemen biter, sıradaki dönem başlamaz. Grup başka bir dönemi yoksa Ücretsiz pakete döner. '
            'İade, ödeme sağlayıcısının panelinden ayrıca yapılır.',
      ),
    );
    if (request == null || !context.mounted) return;
    final result = await ref
        .read(adminBillingRepositoryProvider)
        .cancelSubscription(s.id, reason: request.reason, refunded: request.refunded);
    if (!context.mounted) return;
    _refresh(ref);
    _say(context, result, 'Abonelik iptal edildi.');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final secondary = textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary);
    final canManage = ref.watch(myStaffRoleProvider).value?.canManageBilling ?? false;
    final now = DateTime.now();
    final plan = detail.plan;

    final hasLive = detail.subscriptions.any((s) => s.isLive(now));

    return GxPanel(
      title: 'Paket',
      subtitle: '${detail.group.memberCount} / ${formatCount(plan.maxMembers)} üye',
      trailing: GxBadge(plan.name, tone: plan.slug == 'free' ? GxBadgeTone.neutral : GxBadgeTone.primary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (canManage)
            Wrap(
              spacing: GxSpacing.xs,
              runSpacing: GxSpacing.xs,
              children: [
                GxButton(label: 'Paket tanımla', icon: Icons.workspace_premium_outlined, onPressed: () => _grant(context, ref)),
                if (hasLive)
                  GxButton(
                    label: 'Paketi iptal et',
                    icon: Icons.block,
                    variant: GxButtonVariant.secondary,
                    onPressed: () => _cancelAll(context, ref),
                  ),
              ],
            ),
          if (canManage) const SizedBox(height: GxSpacing.sm),
          if (detail.subscriptions.isEmpty)
            Text('Bu grubun hiç paketi olmadı; Ücretsiz paketi kullanıyor.', style: secondary)
          else
            for (final (i, s) in detail.subscriptions.indexed) ...[
              if (i > 0) const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: GxSpacing.xs),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(planAndPeriod(s.planName, s.period), style: textTheme.labelLarge),
                          Text('${formatDateTr(s.startsAt)} – ${formatDateTr(s.endsAt)} · ${sliceSource(s)}', style: secondary),
                          if (s.cancelNote case final note?) Text('İptal gerekçesi: $note', style: secondary),
                        ],
                      ),
                    ),
                    const SizedBox(width: GxSpacing.sm),
                    _SliceBadge(subscription: s, now: now),
                    if (canManage && s.isLive(now))
                      TextButton(onPressed: () => _cancel(context, ref, s), child: const Text('İptal et')),
                  ],
                ),
              ),
            ],
        ],
      ),
    );
  }
}

/// Price and provider of a bought slice; who gave it and why otherwise.
String sliceSource(AdminSubscription s) => switch ((s.amountMinor, s.currency)) {
      (final amount?, final currency?) => '${formatMoney(amount, currency)} · ${providerLabels[s.provider] ?? s.provider}',
      _ => 'Tanımlandı${s.grantedByUsername == null ? '' : ' (@${s.grantedByUsername})'}: ${s.grantReason}',
    };

class _SliceBadge extends StatelessWidget {
  const _SliceBadge({required this.subscription, required this.now});

  final AdminSubscription subscription;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final s = subscription;
    if (s.orderStatus == AdminOrderStatus.refunded) return const GxBadge('İade edildi', dot: true);
    return switch (s.cancelReason) {
      'upgraded' => const GxBadge('Yükseltildi', dot: true),
      'admin' => const GxBadge('İptal edildi', tone: GxBadgeTone.danger, dot: true),
      _ when s.isCurrent(now) => const GxBadge('Aktif', tone: GxBadgeTone.primary, dot: true),
      _ when s.startsAt.isAfter(now) => const GxBadge('Sırada', tone: GxBadgeTone.info, dot: true),
      _ => const GxBadge('Bitti', dot: true),
    };
  }
}

/// Reason and "refunded" for ending paid time early; a group's plan and a person's package use it alike.
class CancelPlanDialog extends StatefulWidget {
  const CancelPlanDialog({super.key, required this.title, required this.message});

  final String title;
  final String message;

  @override
  State<CancelPlanDialog> createState() => _CancelPlanDialogState();
}

class _CancelPlanDialogState extends State<CancelPlanDialog> {
  final _form = GlobalKey<FormState>();
  final _reason = TextEditingController();
  bool _refunded = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  void _confirm() {
    if (!_form.currentState!.validate()) return;
    Navigator.of(context).pop((reason: _reason.text.trim(), refunded: _refunded));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: GxRadius.xlAll),
      title: Text(widget.title),
      content: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.message),
              const SizedBox(height: GxSpacing.md),
              TextFormField(
                controller: _reason,
                maxLength: 500,
                minLines: 2,
                maxLines: 4,
                validator: (v) => (v ?? '').trim().length < 3 ? 'Bir gerekçe yaz.' : null,
                decoration: const InputDecoration(labelText: 'Gerekçe', alignLabelWithHint: true),
              ),
              CheckboxListTile(
                value: _refunded,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('Ödeme iade edildi'),
                subtitle: const Text('Sipariş "iade edildi" olarak işaretlenir ve gelirden düşülür.'),
                onChanged: (v) => setState(() => _refunded = v ?? false),
              ),
            ],
          ),
        ),
      ),
      actions: [
        GxButton(label: 'Vazgeç', variant: GxButtonVariant.text, onPressed: () => Navigator.of(context).pop()),
        GxButton(label: 'İptal et', onPressed: _confirm),
      ],
    );
  }
}

typedef GrantGroupPlanRequest = ({AdminPlan plan, int days, String reason});

/// Plan, days and reason for giving a group a plan. A higher plan starts now and carries the remaining
/// time over; the same or a lower one follows the time the group already has.
class GrantGroupPlanDialog extends StatefulWidget {
  const GrantGroupPlanDialog({super.key, required this.plans, required this.currentSlug});

  /// Plans an admin can give (the free plan is not one).
  final List<AdminPlan> plans;
  final String currentSlug;

  @override
  State<GrantGroupPlanDialog> createState() => _GrantGroupPlanDialogState();
}

class _GrantGroupPlanDialogState extends State<GrantGroupPlanDialog> {
  final _form = GlobalKey<FormState>();
  final _days = TextEditingController(text: '30');
  final _reason = TextEditingController();
  late AdminPlan _plan = widget.plans.firstWhere((p) => p.slug != widget.currentSlug, orElse: () => widget.plans.last);

  @override
  void dispose() {
    _days.dispose();
    _reason.dispose();
    super.dispose();
  }

  void _confirm() {
    if (!_form.currentState!.validate()) return;
    Navigator.of(context).pop((plan: _plan, days: int.parse(_days.text.trim()), reason: _reason.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.plans.where((p) => p.slug == widget.currentSlug).firstOrNull;
    final upgrade = _plan.tier > (current?.tier ?? 0);
    return AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: GxRadius.xlAll),
      title: const Text('Paket tanımla'),
      content: SizedBox(
        width: GxLayout.formMaxWidth,
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<AdminPlan>(
                  initialValue: _plan,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Paket'),
                  items: [
                    for (final p in widget.plans)
                      DropdownMenuItem(value: p, child: Text('${p.name} · ${formatCount(p.maxMembers)} üye')),
                  ],
                  onChanged: (p) => setState(() => _plan = p ?? _plan),
                ),
                const SizedBox(height: GxSpacing.xs),
                Text(
                  upgrade
                      ? 'Üst paket hemen başlar; grubun kalan süresi yeni pakete aktarılır.'
                      : 'Grubun mevcut süresi bitince başlar.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary),
                ),
                const SizedBox(height: GxSpacing.sm),
                TextFormField(
                  controller: _days,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Gün (1–365)'),
                  validator: (v) => switch (int.tryParse((v ?? '').trim())) {
                    final d? when d >= 1 && d <= 365 => null,
                    _ => '1 ile 365 arasında bir gün sayısı yaz.',
                  },
                ),
                const SizedBox(height: GxSpacing.sm),
                TextFormField(
                  controller: _reason,
                  maxLength: 500,
                  minLines: 2,
                  maxLines: 4,
                  validator: (v) => (v ?? '').trim().length < 3 ? 'Bir açıklama yaz.' : null,
                  decoration: const InputDecoration(labelText: 'Açıklama', helperText: 'Gerekçe kayda geçer.', alignLabelWithHint: true),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        GxButton(label: 'Vazgeç', variant: GxButtonVariant.text, onPressed: () => Navigator.of(context).pop()),
        GxButton(label: 'Tanımla', onPressed: _confirm),
      ],
    );
  }
}
