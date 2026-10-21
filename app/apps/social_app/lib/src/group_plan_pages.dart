import 'package:billing/billing.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:groups/groups.dart';

/// The plan card on the group page: the owner manages the plan, approvers see a full-group warning.
Widget groupPlanSection(BuildContext context, Group group, MyMembership me) {
  final canManage = me.can(GroupPermission.manageBilling);
  if (!canManage && !me.can(GroupPermission.approveMembers)) return const SizedBox.shrink();
  return GroupPlanCard(
    groupId: group.id,
    canManage: canManage,
    onManage: () => context.push(BillingRoutes.plan(group.handle)),
  );
}

/// Resolves the group of a billing route (billing does not know the groups feature).
class _GroupGate extends ConsumerWidget {
  const _GroupGate({required this.handle, required this.title, required this.builder});

  final String handle;
  final String title;
  final Widget Function(Group group, MyMembership me) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(groupByHandleProvider(handle));
    final me = group.value == null ? null : ref.watch(myMembershipProvider(group.value!.id));
    final error = group.error ?? me?.error;
    if (group.value != null && me?.value != null) return builder(group.value!, me!.value!);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: error == null
          ? const Padding(padding: EdgeInsets.all(GxSpacing.page), child: GxSkeleton(height: GxSpacing.xxl * 4))
          : GxErrorState(
              message: userMessageOf(error),
              onRetry: () => ref.invalidate(groupByHandleProvider(handle)),
            ),
    );
  }
}

class GroupPlanPage extends StatelessWidget {
  const GroupPlanPage({super.key, required this.handle, this.orderId});

  final String handle;
  final String? orderId;

  @override
  Widget build(BuildContext context) => _GroupGate(
        handle: handle,
        title: 'Paket',
        builder: (group, me) => PlanScreen(
          groupId: group.id,
          handle: group.handle,
          groupName: group.name,
          canManage: me.can(GroupPermission.manageBilling),
          orderId: orderId,
        ),
      );
}

class GroupCheckoutPage extends StatelessWidget {
  const GroupCheckoutPage({super.key, required this.handle, required this.planSlug, required this.period});

  final String handle;
  final String planSlug;
  final PlanPeriod period;

  @override
  Widget build(BuildContext context) => _GroupGate(
        handle: handle,
        title: 'Ödeme',
        builder: (group, me) => me.can(GroupPermission.manageBilling)
            ? CheckoutScreen(groupId: group.id, groupName: group.name, planSlug: planSlug, period: period)
            : Scaffold(
                appBar: AppBar(title: const Text('Ödeme')),
                body: GxEmptyState(
                  icon: Icons.lock_outline,
                  message: 'Paket işlemlerini yalnızca grup sahibi yapabilir.',
                  actionLabel: 'Gruba dön',
                  onAction: () => context.go(GroupRoutes.group(group.handle)),
                ),
              ),
      );
}
