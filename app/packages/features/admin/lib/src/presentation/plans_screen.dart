import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/admin_billing.dart';
import 'admin_shell.dart';
import 'providers.dart';

const _currencies = ['TRY', 'USD'];
const _periods = ['month', 'year'];

/// The plan catalog with limits and prices; platform admins edit it.
class AdminPlansScreen extends ConsumerWidget {
  const AdminPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(adminPlansProvider);
    final canEdit = ref.watch(myStaffRoleProvider).value?.canManageBilling ?? false;

    return AdminPage(
      title: 'Paketler',
      subtitle: 'Limit değişiklikleri o paketteki tüm gruplara hemen uygulanır; fiyat değişiklikleri yalnızca yeni ödemeleri etkiler.',
      children: [
        switch (plans) {
          AsyncData(:final value) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, plan) in value.indexed) ...[
                  if (i > 0) const SizedBox(height: GwSpacing.md),
                  _PlanPanel(plan: plan, canEdit: canEdit),
                ],
              ],
            ),
          AsyncError(:final error) => GwPanel(
              child: GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(adminPlansProvider)),
            ),
          _ => const Column(
              children: [
                GwSkeleton(height: GwSpacing.xxl * 3, borderRadius: GwRadius.lgAll),
                SizedBox(height: GwSpacing.md),
                GwSkeleton(height: GwSpacing.xxl * 3, borderRadius: GwRadius.lgAll),
              ],
            ),
        },
      ],
    );
  }
}

class _PlanPanel extends ConsumerWidget {
  const _PlanPanel({required this.plan, required this.canEdit});

  final AdminPlan plan;
  final bool canEdit;

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final update = await showDialog<AdminPlanUpdate>(context: context, builder: (_) => _PlanDialog(plan: plan));
    if (update == null || !context.mounted) return;
    final result = await ref.read(adminBillingRepositoryProvider).updatePlan(plan.slug, update);
    if (!context.mounted) return;
    ref.invalidate(adminPlansProvider);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(switch (result) {
        Ok() => '${update.name} paketi güncellendi.',
        Err(:final failure) => failure.userMessage,
      }),
    ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    return GwPanel(
      title: plan.name,
      subtitle: '${plan.activeGroups} grup bu paketi kullanıyor',
      trailing: Wrap(
        spacing: GwSpacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (!plan.isFree)
            plan.isActive
                ? const GwBadge('Satışta', tone: GwBadgeTone.primary, dot: true)
                : const GwBadge('Satışta değil', dot: true),
          if (canEdit)
            GwButton(
              label: 'Düzenle',
              icon: Icons.edit_outlined,
              variant: GwButtonVariant.secondary,
              onPressed: () => _edit(context, ref),
            ),
        ],
      ),
      child: Wrap(
        spacing: GwSpacing.xl,
        runSpacing: GwSpacing.md,
        children: [
          for (final (label, value) in [
            ('Üye', formatCount(plan.maxMembers)),
            ('Organizasyon / ay', formatCount(plan.monthlyEvents)),
            ('Yayın dakikası / ay', formatCount(plan.monthlyLiveMinutes)),
            if (!plan.isFree)
              for (final c in _currencies)
                for (final p in _periods)
                  ('${planPeriodLabels[p]} ($c)', plan.price(c, p) == null ? '—' : formatMoney(plan.price(c, p)!, c)),
          ])
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: textTheme.labelMedium?.copyWith(color: GwColors.textSecondary)),
                Text(value, style: textTheme.titleMedium),
              ],
            ),
        ],
      ),
    );
  }
}

class _PlanDialog extends StatefulWidget {
  const _PlanDialog({required this.plan});

  final AdminPlan plan;

  @override
  State<_PlanDialog> createState() => _PlanDialogState();
}

class _PlanDialogState extends State<_PlanDialog> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.plan.name);
  late final _members = TextEditingController(text: '${widget.plan.maxMembers}');
  late final _events = TextEditingController(text: '${widget.plan.monthlyEvents}');
  late final _minutes = TextEditingController(text: '${widget.plan.monthlyLiveMinutes}');
  late final _prices = {
    for (final c in _currencies)
      for (final p in _periods) (c, p): TextEditingController(text: _major(widget.plan.price(c, p))),
  };
  late bool _active = widget.plan.isActive;

  static String _major(int? minor) =>
      minor == null ? '' : (minor % 100 == 0 ? '${minor ~/ 100}' : (minor / 100).toStringAsFixed(2).replaceAll('.', ','));

  /// `249`, `249,90` or `249.90` → minor units.
  static int? _minor(String text) {
    final value = double.tryParse(text.trim().replaceAll(',', '.'));
    return value == null || value <= 0 ? null : (value * 100).round();
  }

  @override
  void dispose() {
    for (final c in [_name, _members, _events, _minutes, ..._prices.values]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    Navigator.of(context).pop(AdminPlanUpdate(
      name: _name.text.trim(),
      maxMembers: int.parse(_members.text),
      monthlyEvents: int.parse(_events.text),
      monthlyLiveMinutes: int.parse(_minutes.text),
      isActive: widget.plan.isFree || _active,
      prices: [
        for (final MapEntry(key: (c, p), value: controller) in _prices.entries)
          if (!widget.plan.isFree) AdminPlanPrice(currency: c, period: p, amountMinor: _minor(controller.text)!),
      ],
    ));
  }

  Widget _number(TextEditingController controller, String label, {int min = 0}) => TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(labelText: label),
        validator: (v) => (int.tryParse(v ?? '') ?? -1) < min ? 'En az $min olmalı.' : null,
      );

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: GwSpacing.md);
    return AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: GwRadius.xlAll),
      title: Text('${widget.plan.name} paketini düzenle'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: GwLayout.formMaxWidth),
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _name,
                  maxLength: 40,
                  decoration: const InputDecoration(labelText: 'Paket adı', counterText: ''),
                  validator: (v) => (v?.trim().length ?? 0) < 2 ? 'En az 2 karakter.' : null,
                ),
                gap,
                _number(_members, 'Üye limiti', min: 1),
                gap,
                _number(_events, 'Aylık organizasyon'),
                gap,
                _number(_minutes, 'Aylık yayın dakikası'),
                if (!widget.plan.isFree) ...[
                  gap,
                  for (final MapEntry(key: (c, p), value: controller) in _prices.entries) ...[
                    TextFormField(
                      controller: controller,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: '${planPeriodLabels[p]} fiyat', suffixText: c == 'TRY' ? '₺' : r'$'),
                      validator: (v) => _minor(v ?? '') == null ? 'Geçerli bir fiyat gir.' : null,
                    ),
                    gap,
                  ],
                  SwitchListTile(
                    value: _active,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Satışta'),
                    subtitle: const Text('Kapalıyken yeni ödeme alınmaz; mevcut abonelikler süresi bitene kadar devam eder.'),
                    onChanged: (v) => setState(() => _active = v),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        GwButton(label: 'Vazgeç', variant: GwButtonVariant.text, onPressed: () => Navigator.of(context).pop()),
        GwButton(label: 'Kaydet', onPressed: _save),
      ],
    );
  }
}
