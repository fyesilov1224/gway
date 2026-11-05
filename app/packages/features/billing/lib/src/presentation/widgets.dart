import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../domain/billing.dart';
import '../l10n.dart';

const _iconSize = GwSpacing.md + GwSpacing.xxs;

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
    final (background, foreground) = danger ? (GwColors.errorSoft, GwColors.error) : (GwColors.primarySoft, GwColors.primary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: GwSpacing.sm, vertical: GwSpacing.xs),
      decoration: BoxDecoration(color: background, borderRadius: GwRadius.mdAll),
      child: Row(
        children: [
          Icon(icon, color: foreground, size: _iconSize),
          const SizedBox(width: GwSpacing.xs),
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
            Expanded(child: Text(billingL10n.members, style: textTheme.labelLarge)),
            Text(
              '${formatCount(plan.memberCount)} / ${formatCount(plan.plan.maxMembers)}',
              style: textTheme.labelLarge?.copyWith(color: plan.isFull ? GwColors.error : GwColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: GwSpacing.xs),
        Semantics(
          label: billingL10n.membersSemantics(plan.memberCount, plan.plan.maxMembers),
          child: ClipRRect(
            borderRadius: GwRadius.smAll,
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: GwSpacing.xs,
              backgroundColor: GwColors.surfaceMuted,
              color: plan.isFull ? GwColors.error : GwColors.primary,
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
        _LimitRow(icon: Icons.people_outline, text: billingL10n.limitMembers(formatCount(plan.maxMembers))),
        _LimitRow(icon: Icons.event_outlined, text: billingL10n.limitEvents(formatCount(plan.monthlyEvents))),
        _LimitRow(icon: Icons.mic_none, text: billingL10n.limitLive(formatCount(plan.monthlyLiveMinutes))),
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
      padding: const EdgeInsets.symmetric(vertical: GwSpacing.xxs),
      child: Row(
        children: [
          Icon(icon, size: _iconSize, color: GwColors.textSecondary),
          const SizedBox(width: GwSpacing.xs),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

/// "Başlangıç paketi · 12 Kasım 2026'ya kadar" style status line.
String planStatusLine(GroupPlan plan) {
  final until = plan.paidUntil;
  if (plan.plan.isFree || until == null) return billingL10n.planName(plan.plan.name);
  return billingL10n.planUntil(plan.plan.name, formatDate(until));
}

/// "3,6 gün" for an upgrade's carried-over time.
String creditLabel(Duration credit) {
  final days = credit.inSeconds / Duration.secondsPerDay;
  final text = days >= 10 ? formatCount(days.round()) : NumberFormat('0.0', currentAppLanguage.code).format(days);
  return billingL10n.creditDays(text);
}

const planIcon = Icons.workspace_premium_outlined;
