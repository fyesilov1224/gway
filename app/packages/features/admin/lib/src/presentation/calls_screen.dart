import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/admin_calls.dart';
import 'admin_shell.dart';
import 'providers.dart';
import 'routes.dart';
import 'suspend_dialog.dart';
import 'widgets.dart';

/// Opens voice calls for a person, or declines / closes them with a reason (docs/ARCHITECTURE.md §8c).
/// Null when nothing changed; otherwise the sentence to show. [onBusy] wraps only the request, not the reason dialog.
Future<String?> decideCallPermission(
  BuildContext context,
  WidgetRef ref,
  String userId,
  String name, {
  required bool open,
  required ValueChanged<bool> onBusy,
  bool declining = false,
}) async {
  String? reason;
  if (!open) {
    final request = await showSuspendDialog(
      context,
      title: declining ? 'Talebi reddet' : 'Sesli görüşmeyi kapat',
      description: declining
          ? '$name talebinin reddedildiğini ve gerekçeyi görür; 7 gün sonra yeniden talep edebilir.'
          : '$name artık arama yapamaz ve aranamaz; süren görüşmesi hemen biter. Gerekçeyi görür.',
      withDuration: false,
      confirmLabel: declining ? 'Reddet' : 'Kapat',
    );
    if (request == null) return null;
    reason = request.reason;
  }
  onBusy(true);
  final result = await ref.read(adminCallsRepositoryProvider).setPermission(userId, active: open, reason: reason);
  onBusy(false);
  ref
    ..invalidate(callPermissionsProvider)
    ..invalidate(userCallPermissionProvider(userId));
  return switch (result) {
    Ok() => open ? 'Sesli görüşme açıldı.' : (declining ? 'Talep reddedildi.' : 'Sesli görüşme kapatıldı.'),
    Err(:final failure) => failure.userMessage,
  };
}

class AdminCallsScreen extends ConsumerStatefulWidget {
  const AdminCallsScreen({super.key});

  @override
  ConsumerState<AdminCallsScreen> createState() => _AdminCallsScreenState();
}

class _AdminCallsScreenState extends ConsumerState<AdminCallsScreen> {
  AdminCallPermissionStatus _tab = AdminCallPermissionStatus.requested;
  final _busy = <String>{};

  Future<void> _decide(AdminCallPermission p, {required bool open}) async {
    final message = await decideCallPermission(
      context,
      ref,
      p.userId,
      p.displayName,
      open: open,
      declining: p.status == AdminCallPermissionStatus.requested,
      onBusy: (busy) {
        if (mounted) setState(() => busy ? _busy.add(p.userId) : _busy.remove(p.userId));
      },
    );
    if (!mounted) return;
    if (message != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(callPermissionsProvider(_tab));
    final canAct = ref.watch(myStaffRoleProvider).value?.canManageCalls ?? false;
    final page = result.value;
    return AdminPage(
      title: 'Sesli görüşme',
      subtitle:
          'Kimin eşleştiği kişilerle sesli görüşebileceğine karar verirsin. Görüşmeler kaydedilmez; kimin kimi '
          'aradığı burada görünmez.',
      actions: [
        GwButton(
          label: 'Yenile',
          icon: Icons.refresh,
          variant: GwButtonVariant.secondary,
          onPressed: () => ref.invalidate(callPermissionsProvider),
        ),
      ],
      children: [
        StatCardRow(
          wideColumns: 2,
          cards: [
            StatCard(
              label: 'Son 24 saatte görüşme',
              value: page?.calls24h,
              icon: Icons.call_outlined,
              tone: GwBadgeTone.primary,
            ),
            StatCard(
              label: 'Son 24 saatte dakika',
              value: page?.minutes24h,
              icon: Icons.timer_outlined,
              tone: GwBadgeTone.info,
            ),
          ],
        ),
        const SizedBox(height: GwSpacing.lg),
        GwPanel(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(GwSpacing.md),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SegmentedButton<AdminCallPermissionStatus>(
                    segments: [
                      for (final t in AdminCallPermissionStatus.values) ButtonSegment(value: t, label: Text(t.label)),
                    ],
                    selected: {_tab},
                    onSelectionChanged: (s) => setState(() => _tab = s.first),
                  ),
                ),
              ),
              const Divider(),
              switch (result) {
                AsyncData(:final value) when value.items.isEmpty => Padding(
                  padding: const EdgeInsets.symmetric(vertical: GwSpacing.xl),
                  child: GwEmptyState(
                    icon: Icons.call_outlined,
                    message: _tab == AdminCallPermissionStatus.requested
                        ? 'Bekleyen talep yok.'
                        : 'Bu listede kimse yok.',
                    actionLabel: 'Yenile',
                    onAction: () => ref.invalidate(callPermissionsProvider),
                  ),
                ),
                AsyncData(:final value) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final p in value.items) ...[
                      _PermissionRow(
                        permission: p,
                        canAct: canAct,
                        busy: _busy.contains(p.userId),
                        onDecide: (open) => _decide(p, open: open),
                      ),
                      const Divider(),
                    ],
                  ],
                ),
                AsyncError(:final error) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: GwSpacing.xl),
                  child: GwErrorState(
                    message: userMessageOf(error),
                    onRetry: () => ref.invalidate(callPermissionsProvider),
                  ),
                ),
                _ => const Padding(
                  padding: EdgeInsets.all(GwSpacing.md),
                  child: GwSkeleton(height: GwSpacing.xxl * 2),
                ),
              },
            ],
          ),
        ),
      ],
    );
  }
}

class _PermissionRow extends ConsumerWidget {
  const _PermissionRow({required this.permission, required this.canAct, required this.busy, required this.onDecide});

  final AdminCallPermission permission;
  final bool canAct;
  final bool busy;
  final ValueChanged<bool> onDecide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = permission;
    final textTheme = Theme.of(context).textTheme;
    final secondary = textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary);
    final when = p.status == AdminCallPermissionStatus.requested ? p.requestedAt : p.decidedAt;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GwSpacing.lg, vertical: GwSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GwAvatar(
            name: p.displayName,
            shape: GwAvatarShape.user,
            imageUrl: ref.watch(avatarUrlProvider(p.avatarPath)),
          ),
          const SizedBox(width: GwSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => context.go(AdminRoutes.user(p.userId)),
                  child: Text('${p.displayName} (@${p.username})', style: textTheme.titleSmall),
                ),
                if (when != null) Text(formatDateTimeTr(when), style: secondary),
                if (p.note case final note? when p.status == AdminCallPermissionStatus.requested)
                  Text('“$note”', style: secondary?.copyWith(fontStyle: FontStyle.italic)),
                if (p.reason case final reason? when p.status != AdminCallPermissionStatus.active)
                  Text('Gerekçe: $reason', style: secondary),
                if (canAct) ...[
                  const SizedBox(height: GwSpacing.xs),
                  Wrap(
                    spacing: GwSpacing.xs,
                    runSpacing: GwSpacing.xs,
                    children: [
                      if (p.status != AdminCallPermissionStatus.active)
                        GwButton(label: 'Aç', icon: Icons.check, isLoading: busy, onPressed: () => onDecide(true)),
                      if (p.status == AdminCallPermissionStatus.requested)
                        GwButton(
                          label: 'Reddet',
                          variant: GwButtonVariant.secondary,
                          onPressed: busy ? null : () => onDecide(false),
                        ),
                      if (p.status == AdminCallPermissionStatus.active)
                        GwButton(
                          label: 'Kapat',
                          variant: GwButtonVariant.secondary,
                          isLoading: busy,
                          onPressed: () => onDecide(false),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The person's voice call permission on their user page, with the switch (docs/ARCHITECTURE.md §8c).
/// Their calls are not shown.
class UserCallPermissionPanel extends ConsumerStatefulWidget {
  const UserCallPermissionPanel({super.key, required this.userId, required this.name});

  final String userId;
  final String name;

  @override
  ConsumerState<UserCallPermissionPanel> createState() => _UserCallPermissionPanelState();
}

class _UserCallPermissionPanelState extends ConsumerState<UserCallPermissionPanel> {
  bool _busy = false;

  Future<void> _set(bool open) async {
    final message = await decideCallPermission(
      context,
      ref,
      widget.userId,
      widget.name,
      open: open,
      onBusy: (busy) {
        if (mounted) setState(() => _busy = busy);
      },
    );
    if (!mounted) return;
    if (message != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final canAct = ref.watch(myStaffRoleProvider).value?.canManageCalls ?? false;
    final secondary = Theme.of(context).textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary);
    return GwPanel(
      title: 'Sesli görüşme',
      child: switch (ref.watch(userCallPermissionProvider(widget.userId))) {
        AsyncData(:final value) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Sesli görüşme yetkisi'),
              subtitle: Text(switch (value?.status) {
                null => 'Talep etmedi',
                AdminCallPermissionStatus.requested => 'Talep bekliyor',
                final status => status.label,
              }),
              value: value?.status == AdminCallPermissionStatus.active,
              onChanged: canAct && !_busy ? _set : null,
            ),
            if (value?.reason case final reason? when value?.status != AdminCallPermissionStatus.active)
              Text('Gerekçe: $reason', style: secondary),
          ],
        ),
        AsyncError(:final error) => GwErrorState(
          message: userMessageOf(error),
          onRetry: () => ref.invalidate(userCallPermissionProvider(widget.userId)),
        ),
        _ => const GwSkeleton(height: GwSpacing.xxl),
      },
    );
  }
}
