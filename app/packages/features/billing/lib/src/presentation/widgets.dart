import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../domain/billing.dart';

const _iconSize = GxSpacing.md + GxSpacing.xxs;

/// Soft, tinted one-line message with an optional action.
class PlanNotice extends StatelessWidget {
  const PlanNotice({super.key, required this.icon, required this.text, this.danger = false, this.actionLabel, this.onAction});

  final IconData icon;
  final String text;
  final bool danger;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = danger ? (GxColors.errorSoft, GxColors.error) : (GxColors.primarySoft, GxColors.primary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: GxSpacing.sm, vertical: GxSpacing.xs),
      decoration: BoxDecoration(color: background, borderRadius: GxRadius.mdAll),
      child: Row(
        children: [
          Icon(icon, color: foreground, size: _iconSize),
          const SizedBox(width: GxSpacing.xs),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
          if (actionLabel != null) TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

/// Members used against the plan's limit.
class MemberUsage extends StatelessWidget {
  const MemberUsage({super.key, required this.plan});

  final GroupPlan plan;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ratio = (plan.memberCount / plan.plan.maxMembers).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text('Üyeler', style: textTheme.labelLarge)),
            Text(
              '${formatCount(plan.memberCount)} / ${formatCount(plan.plan.maxMembers)}',
              style: textTheme.labelLarge?.copyWith(color: plan.isFull ? GxColors.error : GxColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: GxSpacing.xs),
        Semantics(
          label: '${plan.memberCount} üye, limit ${plan.plan.maxMembers}',
          child: ClipRRect(
            borderRadius: GxRadius.smAll,
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: GxSpacing.xs,
              backgroundColor: GxColors.surfaceMuted,
              color: plan.isFull ? GxColors.error : GxColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

/// The three limits of a plan, one per line.
class PlanLimits extends StatelessWidget {
  const PlanLimits({super.key, required this.plan});

  final Plan plan;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LimitRow(icon: Icons.people_outline, text: '${formatCount(plan.maxMembers)} üye'),
        _LimitRow(icon: Icons.event_outlined, text: '${formatCount(plan.monthlyEvents)} organizasyon / ay'),
        _LimitRow(icon: Icons.mic_none, text: '${formatCount(plan.monthlyLiveMinutes)} dk canlı yayın / ay'),
      ],
    );
  }
}

class _LimitRow extends StatelessWidget {
  const _LimitRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: GxSpacing.xxs),
      child: Row(
        children: [
          Icon(icon, size: _iconSize, color: GxColors.textSecondary),
          const SizedBox(width: GxSpacing.xs),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

/// "Başlangıç paketi · 12 Kasım 2026'ya kadar" style status line.
String planStatusLine(GroupPlan plan) {
  final until = plan.paidUntil;
  if (plan.plan.isFree || until == null) return '${plan.plan.name} paket';
  return '${plan.plan.name} paketi · ${formatDateTr(until)} tarihine kadar';
}

/// "3,6 gün" for an upgrade's carried-over time.
String creditLabel(Duration credit) {
  final days = credit.inSeconds / Duration.secondsPerDay;
  final text = days >= 10 ? days.round().toString() : days.toStringAsFixed(1).replaceAll('.', ',');
  return '$text gün';
}

const planIcon = Icons.workspace_premium_outlined;
