import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/admin_matching.dart';
import 'group_plan_panel.dart';
import 'matching_screen.dart';
import 'providers.dart';

/// The person's packages (docs/ARCHITECTURE.md §3g, Kullanıcının paketleri): what runs now with its end, then every
/// earlier slice. Platform admins give a package or cancel one here.
class UserPackagesPanel extends ConsumerWidget {
  const UserPackagesPanel({super.key, required this.userId, required this.title});

  final String userId;

  /// How the person is named in messages.
  final String title;

  void _refresh(WidgetRef ref) => ref
    ..invalidate(userPackagesProvider(userId))
    ..invalidate(matchingPackagesProvider)
    ..invalidate(matchingStatsProvider);

  void _say(BuildContext context, Result<void> result, String done) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(switch (result) {
          Ok() => done,
          Err(:final failure) => failure.userMessage,
        }),
      ));

  Future<void> _grant(BuildContext context, WidgetRef ref) async {
    final packages = await ref.read(matchingPackagesProvider.future);
    if (!context.mounted) return;
    final request = await showGrantPackageDialog(context, packages, askUsername: false);
    if (request == null || !context.mounted) return;
    final result = await ref
        .read(adminMatchingRepositoryProvider)
        .grantUserPackage(userId, slug: request.package.slug, days: request.days, reason: request.reason);
    if (!context.mounted) return;
    _refresh(ref);
    _say(context, result, '$title için ${request.days} gün ${request.package.name} tanımlandı.');
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref, String slug, String name) async {
    final request = await showDialog<({String reason, bool refunded})>(
      context: context,
      builder: (_) => CancelPlanDialog(
        title: '$name paketini iptal et',
        message: 'Bu paketteki süren ve sıradaki bütün süre hemen biter. İade, ödeme sağlayıcısının panelinden ayrıca yapılır.',
      ),
    );
    if (request == null || !context.mounted) return;
    final result = await ref
        .read(adminMatchingRepositoryProvider)
        .cancelUserPackage(userId, slug, reason: request.reason, refunded: request.refunded);
    if (!context.mounted) return;
    _refresh(ref);
    _say(context, result, '$name iptal edildi.');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slices = ref.watch(userPackagesProvider(userId));
    final canManage = ref.watch(myStaffRoleProvider).value?.canManageBilling ?? false;
    final secondary = Theme.of(context).textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary);

    return GwPanel(
      title: 'Paketleri',
      trailing: canManage
          ? GwButton(
              label: 'Paket tanımla',
              icon: Icons.add,
              variant: GwButtonVariant.text,
              onPressed: () => _grant(context, ref),
            )
          : null,
      child: switch (slices) {
        AsyncData(:final value) when value.isEmpty => Text('Bu kişinin hiç paketi olmadı.', style: secondary),
        AsyncData(:final value) => _list(context, ref, value, canManage),
        AsyncError(:final error) =>
          GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(userPackagesProvider(userId))),
        _ => const GwSkeleton(height: GwSpacing.xxl * 2),
      },
    );
  }

  Widget _list(BuildContext context, WidgetRef ref, List<AdminPersonalSubscription> slices, bool canManage) {
    final textTheme = Theme.of(context).textTheme;
    final secondary = textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary);
    final now = DateTime.now();

    // Running and upcoming time, one line per package with its last end.
    final live = <String, ({String name, DateTime until, bool bought, bool granted})>{};
    for (final s in slices.where((s) => s.isLive(now))) {
      final old = live[s.planSlug];
      live[s.planSlug] = (
        name: s.planName,
        until: old == null || s.endsAt.isAfter(old.until) ? s.endsAt : old.until,
        bought: (old?.bought ?? false) || !s.isGrant,
        granted: (old?.granted ?? false) || s.isGrant,
      );
    }
    final past = slices.where((s) => !s.isLive(now)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (live.isEmpty) Text('Şu an süren bir paketi yok.', style: secondary),
        for (final MapEntry(key: slug, value: p) in live.entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: GwSpacing.xs),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, style: textTheme.labelLarge),
                      Text(
                        '${formatDate(p.until)} tarihine kadar · '
                        '${[if (p.bought) 'satın alındı', if (p.granted) 'tanımlandı'].join(' ve ')}',
                        style: secondary,
                      ),
                    ],
                  ),
                ),
                const GwBadge('Aktif', tone: GwBadgeTone.primary, dot: true),
                if (canManage) TextButton(onPressed: () => _cancel(context, ref, slug, p.name), child: const Text('İptal et')),
              ],
            ),
          ),
        if (past.isNotEmpty) ...[
          const Divider(),
          Text('Geçmiş', style: textTheme.labelLarge),
          for (final s in past)
            Padding(
              padding: const EdgeInsets.only(top: GwSpacing.xs),
              child: Text(
                [
                  s.planName,
                  '${formatDate(s.startsAt)} – ${formatDate(s.endsAt)}',
                  if (s.isGrant) 'tanımlandı${s.grantedByUsername == null ? '' : ' (@${s.grantedByUsername})'}: ${s.grantReason}'
                  else if (s.amountMinor != null && s.currency != null) formatMoney(s.amountMinor!, s.currency!),
                  if (s.orderStatus == 'refunded') 'iade edildi' else if (s.canceledAt != null) 'iptal edildi',
                ].join(' · '),
                style: secondary,
              ),
            ),
        ],
      ],
    );
  }
}
