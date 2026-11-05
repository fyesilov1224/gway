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
  'group.invite_link_created': ('Davet bağlantısı oluşturuldu', Icons.add_link),
  'group.invite_link_revoked': ('Davet bağlantısı iptal edildi', Icons.link_off),
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
            GwPanel(
              child: GwEmptyState(
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
            GwPanel(
              child: GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(groupDetailProvider(widget.groupId))),
            ),
          ],
        ),
      _ => const AdminPage(
          breadcrumbs: crumbs,
          children: [
            GwSkeleton(height: GwSpacing.xxl * 2, borderRadius: GwRadius.lgAll),
            SizedBox(height: GwSpacing.lg),
            GwSkeleton(height: GwSpacing.xxl * 5, borderRadius: GwRadius.lgAll),
          ],
        ),
    };
  }

  List<Widget> _content(AdminGroupDetail d, StaffRole? myRole) {
    final g = d.group;
    final canSuspend = myRole?.canSuspend ?? false;
    final wide = MediaQuery.sizeOf(context).width >= GwLayout.wideBreakpoint;
    final categories = {for (final c in ref.watch(categoriesProvider).value ?? const <Category>[]) c.slug: c.name};

    final actions = <Widget>[
      if (canSuspend && g.status == AdminGroupStatus.suspended)
        GwButton(
          label: 'Askıyı kaldır',
          icon: Icons.lock_open_outlined,
          variant: GwButtonVariant.secondary,
          isLoading: _saving,
          onPressed: () => _run((repo) => repo.unsuspend(g.id)),
        ),
      if (canSuspend && g.status == AdminGroupStatus.active)
        GwButton(label: 'Askıya al', icon: Icons.block, isLoading: _saving, onPressed: _suspend),
    ];

    final left = [
      InfoPanel(
        title: 'Grup bilgileri',
        rows: [
          ('Grup kimliği', g.id),
          ('Adres', '@${g.handle}'),
          ('Kategori', categories[g.categorySlug] ?? g.categorySlug),
          ('İl', d.province == null ? 'Belirtilmedi' : turkishProvinces[d.province! - 1]),
          ('Katılım tipi', joinPolicyLabels[g.joinPolicy] ?? g.joinPolicy),
          ('Üye sayısı', '${g.memberCount}'),
          ('Bekleyen istek', '${d.pendingRequests}'),
          ('Bekleyen davet', '${d.pendingInvitations}'),
          ('Kuruluş', formatDateTime(g.createdAt)),
        ],
      ),
      if (d.about.isNotEmpty) ...[
        const SizedBox(height: GwSpacing.lg),
        GwPanel(title: 'Tanıtım', child: Text(d.about, style: Theme.of(context).textTheme.bodyLarge)),
      ],
    ];
    final right = [
      if (myRole?.canSeeBilling ?? false) ...[
        GroupPlanPanel(detail: d),
        const SizedBox(height: GwSpacing.lg),
      ],
      _TeamPanel(team: d.team),
      const SizedBox(height: GwSpacing.lg),
      _InviteLinksPanel(
        links: d.inviteLinks,
        canRevoke: canSuspend,
        busy: _saving,
        onRevoke: (link) => _run((repo) => repo.revokeInviteLink(g.id, link.id)),
      ),
      const SizedBox(height: GwSpacing.lg),
      HistoryPanel(
        history: d.history,
        labels: _actionLabels,
        detailLabels: groupRoleLabels,
        emptyText: 'Bu grupla ilgili kayıtlı bir işlem yok.',
      ),
    ];

    return [
      _HeaderPanel(group: g, actions: actions),
      if (_error != null) ...[const SizedBox(height: GwSpacing.md), GwFormMessage(_error!)],
      if (g.status == AdminGroupStatus.suspended) ...[
        const SizedBox(height: GwSpacing.md),
        DetailBanner(
          tone: GwBadgeTone.danger,
          icon: Icons.block,
          title: d.suspendedAt == null ? 'Grup askıda' : 'Grup ${formatDateTime(d.suspendedAt!)} tarihinden beri askıda',
          body: d.suspensionReason == null ? null : 'Gerekçe: ${d.suspensionReason}',
        ),
      ],
      const SizedBox(height: GwSpacing.lg),
      if (wide)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: Column(children: left)),
            const SizedBox(width: GwSpacing.lg),
            Expanded(flex: 2, child: Column(children: right)),
          ],
        )
      else ...[
        ...left,
        const SizedBox(height: GwSpacing.lg),
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
        GwAvatar(
          name: group.name,
          shape: GwAvatarShape.group,
          size: GwAvatarSize.lg,
          imageUrl: ref.watch(groupLogoUrlProvider(group.logoPath)),
        ),
        const SizedBox(width: GwSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: GwSpacing.xs,
                runSpacing: GwSpacing.xxs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [Text(group.name, style: textTheme.headlineMedium), GroupStatusBadge(group.status)],
              ),
              const SizedBox(height: GwSpacing.xxs),
              Text(
                ['@${group.handle}', if (group.ownerUsername != null) 'Sahibi: @${group.ownerUsername}'].join('  ·  '),
                style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );

    return GwPanel(
      child: LayoutBuilder(
        builder: (context, constraints) => constraints.maxWidth >= GwLayout.contentMaxWidth
            ? Row(
                children: [
                  Expanded(child: identity),
                  if (actions.isNotEmpty) Wrap(spacing: GwSpacing.sm, children: actions),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  identity,
                  if (actions.isNotEmpty) ...[
                    const SizedBox(height: GwSpacing.md),
                    Wrap(spacing: GwSpacing.sm, runSpacing: GwSpacing.sm, children: actions),
                  ],
                ],
              ),
      ),
    );
  }
}

/// Owner and members with assigned roles; opens the user's admin page.
class _InviteLinksPanel extends StatelessWidget {
  const _InviteLinksPanel({required this.links, required this.canRevoke, required this.busy, required this.onRevoke});

  final List<AdminInviteLink> links;
  final bool canRevoke;
  final bool busy;
  final void Function(AdminInviteLink link) onRevoke;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GwPanel(
      title: 'Davet bağlantıları',
      child: links.isEmpty
          ? Text('Bu grubun davet bağlantısı yok.', style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, l) in links.indexed) ...[
                  if (i > 0) const Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${l.useCount}${l.maxUses == null ? '' : ' / ${l.maxUses}'} kişi katıldı',
                              style: textTheme.labelLarge,
                            ),
                            Text(
                              [
                                if (l.createdByUsername != null) '@${l.createdByUsername}',
                                formatDateTime(l.createdAt),
                                l.revokedAt != null
                                    ? 'İptal edildi'
                                    : l.valid
                                        ? '${formatDateTime(l.expiresAt)} tarihine kadar'
                                        : 'Geçersiz',
                              ].join('  ·  '),
                              style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      if (canRevoke && l.valid)
                        GwButton(label: 'İptal et', variant: GwButtonVariant.text, isLoading: busy, onPressed: () => onRevoke(l)),
                    ],
                  ),
                ],
              ],
            ),
    );
  }
}

class _TeamPanel extends ConsumerWidget {
  const _TeamPanel({required this.team});

  final List<AdminGroupTeamMember> team;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    return GwPanel(
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
                padding: const EdgeInsets.symmetric(horizontal: GwSpacing.lg, vertical: GwSpacing.sm),
                child: Row(
                  children: [
                    GwAvatar(
                      name: m.displayName ?? '?',
                      shape: GwAvatarShape.user,
                      imageUrl: ref.watch(avatarUrlProvider(m.avatarPath)),
                    ),
                    const SizedBox(width: GwSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.displayName ?? 'Gizli hesap', style: textTheme.labelLarge),
                          if (m.username != null)
                            Text('@${m.username}', style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
                          const SizedBox(height: GwSpacing.xxs),
                          Wrap(
                            spacing: GwSpacing.xxs,
                            runSpacing: GwSpacing.xxs,
                            children: [
                              for (final r in m.roles)
                                GwBadge(groupRoleLabels[r] ?? r, tone: r == 'owner' ? GwBadgeTone.primary : GwBadgeTone.info),
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
