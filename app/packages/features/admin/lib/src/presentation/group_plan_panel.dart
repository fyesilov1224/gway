import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/admin_billing.dart';
import '../domain/admin_group.dart';
import 'billing_screen.dart';
import 'providers.dart';

/// The group's plan and its whole timeline; platform admins cancel a slice here.
class GroupPlanPanel extends ConsumerWidget {
  const GroupPlanPanel({super.key, required this.detail});

  final AdminGroupDetail detail;

  Future<void> _cancel(BuildContext context, WidgetRef ref, AdminSubscription s) async {
    final request = await showDialog<({String reason, bool refunded})>(context: context, builder: (_) => const _CancelDialog());
    if (request == null || !context.mounted) return;
    final result = await ref
        .read(adminBillingRepositoryProvider)
        .cancelSubscription(s.id, reason: request.reason, refunded: request.refunded);
    if (!context.mounted) return;
    ref
      ..invalidate(groupDetailProvider(detail.group.id))
      ..invalidate(subscriptionSearchProvider)
      ..invalidate(orderSearchProvider)
      ..invalidate(billingStatsProvider);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(switch (result) {
        Ok() => 'Abonelik iptal edildi.',
        Err(:final failure) => failure.userMessage,
      }),
    ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final secondary = textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary);
    final canManage = ref.watch(myStaffRoleProvider).value?.canManageBilling ?? false;
    final now = DateTime.now();
    final plan = detail.plan;

    return GxPanel(
      title: 'Paket',
      subtitle: '${detail.group.memberCount} / ${formatCount(plan.maxMembers)} üye',
      trailing: GxBadge(plan.name, tone: plan.slug == 'free' ? GxBadgeTone.neutral : GxBadgeTone.primary),
      child: detail.subscriptions.isEmpty
          ? Text('Bu grup hiç paket satın almadı; Ücretsiz paketi kullanıyor.', style: secondary)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                              Text(
                                '${formatDateTr(s.startsAt)} – ${formatDateTr(s.endsAt)} · '
                                '${formatMoney(s.amountMinor, s.currency)} · ${providerLabels[s.provider] ?? s.provider}',
                                style: secondary,
                              ),
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

class _CancelDialog extends StatefulWidget {
  const _CancelDialog();

  @override
  State<_CancelDialog> createState() => _CancelDialogState();
}

class _CancelDialogState extends State<_CancelDialog> {
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
      title: const Text('Aboneliği iptal et'),
      content: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Süren dönem hemen biter, sıradaki dönem başlamaz. Grup başka bir dönemi yoksa Ücretsiz pakete döner. '
                  'İade, ödeme sağlayıcısının panelinden ayrıca yapılır.'),
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
