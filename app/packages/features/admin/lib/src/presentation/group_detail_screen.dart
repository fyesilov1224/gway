import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/admin_group.dart';
import '../domain/admin_user.dart';
import 'admin_shell.dart';
import 'group_plan_panel.dart';
import 'groups_screen.dart';
import 'providers.dart';
import 'routes.dart';
import 'suspend_dialog.dart';
import 'widgets.dart';

const _actionLabels = {
  'group.created': ('Grup oluşturuldu', Icons.add_circle_outline),
  'group.updated': ('Grup profili düzenlendi', Icons.edit_outlined),
  'group.ownership_transferred': ('Sahiplik devredildi', Icons.swap_horiz),
  'group.role_assigned': ('Rol verildi', Icons.shield_outlined),
  'group.role_removed': ('Rol alındı', Icons.remove_moderator_outlined),
  'group.join_approved': ('Katılım isteği onaylandı', Icons.how_to_reg_outlined),
  'group.join_rejected': ('Katılım isteği reddedildi', Icons.person_off_outlined),
  'group.invitation_sent': ('Davet gönderildi', Icons.mail_outline),
  'group.invitation_revoked': ('Davet geri alındı', Icons.cancel_schedule_send_outlined),
  'group.suspended': ('Grup askıya alındı', Icons.block),
  'group.unsuspended': ('Askı kaldırıldı', Icons.lock_open_outlined),
  'subscription.activated': ('Paket etkinleşti', Icons.workspace_premium_outlined),
  'subscription.canceled': ('Abonelik iptal edildi', Icons.event_busy_outlined),
  'billing.payment_mismatch': ('Ödeme tutarı uyuşmadı', Icons.report_gmailerrorred_outlined),
};

class AdminGroupDetailScreen extends ConsumerStatefulWidget {
  const AdminGroupDetailScreen({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<AdminGroupDetailScreen> createState() => _AdminGroupDetailScreenState();
}

class _AdminGroupDetailScreenState extends ConsumerState<AdminGroupDetailScreen> {
  bool _saving = false;
  String? _error;

  Future<void> _run(Future<Result<void>> Function(AdminGroupsRepository repo) action) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final result = await action(ref.read(adminGroupsRepositoryProvider));
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (result case Err(:final failure)) _error = failure.userMessage;
    });
    ref
      ..invalidate(groupDetailProvider(widget.groupId))
      ..invalidate(groupSearchProvider)
      ..invalidate(groupStatsProvider);
  }

  Future<void> _suspend() async {
    final request = await showSuspendDialog(
      context,
      title: 'Grubu askıya al',
      description: 'Askıdaki grup yalnızca üyelerine görünür; katılım, düzenleme ve diğer işlemler kapanır. '
          'Askı siz kaldırana kadar sürer.',
      withDuration: false,
    );
    if (request == null) return;
    await _run((repo) => repo.suspend(widget.groupId, reason: request.reason));
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(groupDetailProvider(widget.groupId));
    final role = ref.watch(myStaffRoleProvider).value;
    const crumbs = [('Gruplar', AdminRoutes.groups)];

    return switch (detail) {
      AsyncData(:final value) => AdminPage(breadcrumbs: crumbs, title: value.group.name, children: _content(value, role)),
      AsyncError(error: NotFoundFailure()) => AdminPage(
          breadcrumbs: crumbs,
          title: 'Bulunamadı',
          children: [
            GxPanel(
              child: GxEmptyState(
                icon: Icons.group_off_outlined,
                message: 'Bu grup bulunamadı. Sahibi tarafından silinmiş olabilir.',
                actionLabel: 'Gruplara dön',
                onAction: () => context.go(AdminRoutes.groups),
              ),
            ),
          ],
        ),
      AsyncError(:final error) => AdminPage(
          breadcrumbs: crumbs,
          children: [
            GxPanel(
              child: GxErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(groupDetailProvider(widget.groupId))),
            ),
          ],
        ),
      _ => const AdminPage(
          breadcrumbs: crumbs,
          children: [
            GxSkeleton(height: GxSpacing.xxl * 2, borderRadius: GxRadius.lgAll),
            SizedBox(height: GxSpacing.lg),
            GxSkeleton(height: GxSpacing.xxl * 5, borderRadius: GxRadius.lgAll),
          ],
        ),
    };
  }

  List<Widget> _content(AdminGroupDetail d, StaffRole? myRole) {
    final g = d.group;
    final canSuspend = myRole?.canSuspend ?? false;
    final wide = MediaQuery.sizeOf(context).width >= GxLayout.wideBreakpoint;
    final categories = {for (final c in ref.watch(categoriesProvider).value ?? const <Category>[]) c.slug: c.name};

    final actions = <Widget>[
      if (canSuspend && g.status == AdminGroupStatus.suspended)
        GxButton(
          label: 'Askıyı kaldır',
          icon: Icons.lock_open_outlined,
          variant: GxButtonVariant.secondary,
          isLoading: _saving,
          onPressed: () => _run((repo) => repo.unsuspend(g.id)),
        ),
      if (canSuspend && g.status == AdminGroupStatus.active)
        GxButton(label: 'Askıya al', icon: Icons.block, isLoading: _saving, onPressed: _suspend),
    ];

    final left = [
      InfoPanel(
        title: 'Grup bilgileri',
        rows: [
          ('Grup kimliği', g.id),
          ('Adres', '@${g.handle}'),
          ('Kategori', categories[g.categorySlug] ?? g.categorySlug),
          ('Katılım tipi', joinPolicyLabels[g.joinPolicy] ?? g.joinPolicy),
          ('Üye sayısı', '${g.memberCount}'),
          ('Bekleyen istek', '${d.pendingRequests}'),
          ('Bekleyen davet', '${d.pendingInvitations}'),
          ('Kuruluş', formatDateTimeTr(g.createdAt)),
        ],
      ),
      if (d.about.isNotEmpty) ...[
        const SizedBox(height: GxSpacing.lg),
        GxPanel(title: 'Tanıtım', child: Text(d.about, style: Theme.of(context).textTheme.bodyLarge)),
      ],
    ];
    final right = [
      if (myRole?.canSeeBilling ?? false) ...[
        GroupPlanPanel(detail: d),
        const SizedBox(height: GxSpacing.lg),
      ],
      _TeamPanel(team: d.team),
      const SizedBox(height: GxSpacing.lg),
      HistoryPanel(
        history: d.history,
        labels: _actionLabels,
        detailLabels: groupRoleLabels,
        emptyText: 'Bu grupla ilgili kayıtlı bir işlem yok.',
      ),
    ];

    return [
      _HeaderPanel(group: g, actions: actions),
      if (_error != null) ...[const SizedBox(height: GxSpacing.md), GxFormMessage(_error!)],
      if (g.status == AdminGroupStatus.suspended) ...[
        const SizedBox(height: GxSpacing.md),
        DetailBanner(
          tone: GxBadgeTone.danger,
          icon: Icons.block,
          title: d.suspendedAt == null ? 'Grup askıda' : 'Grup ${formatDateTimeTr(d.suspendedAt!)} tarihinden beri askıda',
          body: d.suspensionReason == null ? null : 'Gerekçe: ${d.suspensionReason}',
        ),
      ],
      const SizedBox(height: GxSpacing.lg),
      if (wide)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: Column(children: left)),
            const SizedBox(width: GxSpacing.lg),
            Expanded(flex: 2, child: Column(children: right)),
          ],
        )
      else ...[
        ...left,
        const SizedBox(height: GxSpacing.lg),
        ...right,
      ],
    ];
  }
}

class _HeaderPanel extends ConsumerWidget {
  const _HeaderPanel({required this.group, required this.actions});

  final AdminGroupSummary group;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final identity = Row(
      children: [
        GxAvatar(
          name: group.name,
          shape: GxAvatarShape.group,
          size: GxAvatarSize.lg,
          imageUrl: ref.watch(groupLogoUrlProvider(group.logoPath)),
        ),
        const SizedBox(width: GxSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: GxSpacing.xs,
                runSpacing: GxSpacing.xxs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [Text(group.name, style: textTheme.headlineMedium), GroupStatusBadge(group.status)],
              ),
              const SizedBox(height: GxSpacing.xxs),
              Text(
                ['@${group.handle}', if (group.ownerUsername != null) 'Sahibi: @${group.ownerUsername}'].join('  ·  '),
                style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );

    return GxPanel(
      child: LayoutBuilder(
        builder: (context, constraints) => constraints.maxWidth >= GxLayout.contentMaxWidth
            ? Row(
                children: [
                  Expanded(child: identity),
                  if (actions.isNotEmpty) Wrap(spacing: GxSpacing.sm, children: actions),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  identity,
                  if (actions.isNotEmpty) ...[
                    const SizedBox(height: GxSpacing.md),
                    Wrap(spacing: GxSpacing.sm, runSpacing: GxSpacing.sm, children: actions),
                  ],
                ],
              ),
      ),
    );
  }
}

/// Owner and members with assigned roles; opens the user's admin page.
class _TeamPanel extends ConsumerWidget {
  const _TeamPanel({required this.team});

  final List<AdminGroupTeamMember> team;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    return GxPanel(
      title: 'Yönetim ekibi',
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, m) in team.indexed) ...[
            if (i > 0) const Divider(),
            InkWell(
              onTap: () => context.go(AdminRoutes.user(m.userId)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: GxSpacing.lg, vertical: GxSpacing.sm),
                child: Row(
                  children: [
                    GxAvatar(
                      name: m.displayName ?? '?',
                      shape: GxAvatarShape.user,
                      imageUrl: ref.watch(avatarUrlProvider(m.avatarPath)),
                    ),
                    const SizedBox(width: GxSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.displayName ?? 'Gizli hesap', style: textTheme.labelLarge),
                          if (m.username != null)
                            Text('@${m.username}', style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary)),
                          const SizedBox(height: GxSpacing.xxs),
                          Wrap(
                            spacing: GxSpacing.xxs,
                            runSpacing: GxSpacing.xxs,
                            children: [
                              for (final r in m.roles)
                                GxBadge(groupRoleLabels[r] ?? r, tone: r == 'owner' ? GxBadgeTone.primary : GxBadgeTone.info),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
