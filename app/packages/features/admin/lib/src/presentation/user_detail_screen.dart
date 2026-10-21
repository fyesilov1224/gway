import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/admin_user.dart';
import 'admin_shell.dart';
import 'providers.dart';
import 'routes.dart';
import 'status_chip.dart';
import 'suspend_dialog.dart';
import 'widgets.dart';

const _actionLabels = {
  'user.suspended': ('Hesap askıya alındı', Icons.block),
  'user.unsuspended': ('Askı kaldırıldı', Icons.lock_open_outlined),
  'account.deletion_requested': ('Hesap silme istendi', Icons.delete_outline),
  'account.deletion_cancelled': ('Hesap silme geri alındı', Icons.restore),
};

const _consentLabels = {
  'terms': 'Kullanım Koşulları',
  'privacy_notice': 'KVKK Aydınlatma Metni',
  'explicit_consent': 'Açık Rıza Metni',
};

class UserDetailScreen extends ConsumerStatefulWidget {
  const UserDetailScreen({super.key, required this.userId});

  final String userId;

  @override
  ConsumerState<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends ConsumerState<UserDetailScreen> {
  bool _saving = false;
  String? _error;

  Future<void> _run(Future<Result<void>> Function(AdminUsersRepository repo) action) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final result = await action(ref.read(adminUsersRepositoryProvider));
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (result case Err(:final failure)) _error = failure.userMessage;
    });
    ref
      ..invalidate(userDetailProvider(widget.userId))
      ..invalidate(userSearchProvider)
      ..invalidate(userStatsProvider);
  }

  Future<void> _suspend() async {
    final request = await showSuspendDialog(context);
    if (request == null) return;
    await _run((repo) => repo.suspend(widget.userId, reason: request.reason, until: request.until));
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(userDetailProvider(widget.userId));
    final role = ref.watch(myStaffRoleProvider).value;
    const crumbs = [('Kullanıcılar', AdminRoutes.users)];

    return switch (detail) {
      AsyncData(:final value) => AdminPage(
          breadcrumbs: crumbs,
          title: value.user.title,
          children: _content(value, role),
        ),
      AsyncError(error: NotFoundFailure()) => AdminPage(
          breadcrumbs: crumbs,
          title: 'Bulunamadı',
          children: [
            GxPanel(
              child: GxEmptyState(
                icon: Icons.person_off_outlined,
                message: 'Bu kullanıcı bulunamadı. Hesap kalıcı olarak silinmiş olabilir.',
                actionLabel: 'Kullanıcılara dön',
                onAction: () => context.go(AdminRoutes.users),
              ),
            ),
          ],
        ),
      AsyncError(:final error) => AdminPage(
          breadcrumbs: crumbs,
          children: [
            GxPanel(
              child: GxErrorState(
                message: userMessageOf(error),
                onRetry: () => ref.invalidate(userDetailProvider(widget.userId)),
              ),
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

  List<Widget> _content(AdminUserDetail d, StaffRole? myRole) {
    final u = d.user;
    final canModerate = (myRole?.canSuspend ?? false) && u.staffRole == null;
    final wide = MediaQuery.sizeOf(context).width >= GxLayout.wideBreakpoint;

    final actions = <Widget>[
      if (canModerate && u.status == AdminAccountStatus.suspended)
        GxButton(
          label: 'Askıyı kaldır',
          icon: Icons.lock_open_outlined,
          variant: GxButtonVariant.secondary,
          isLoading: _saving,
          onPressed: () => _run((repo) => repo.unsuspend(u.id)),
        ),
      if (canModerate && u.status == AdminAccountStatus.active)
        GxButton(label: 'Askıya al', icon: Icons.block, isLoading: _saving, onPressed: _suspend),
    ];

    final left = [
      _AccountPanel(detail: d),
      if (d.bio case final bio? when bio.isNotEmpty) ...[
        const SizedBox(height: GxSpacing.lg),
        GxPanel(title: 'Hakkında', child: Text(bio, style: Theme.of(context).textTheme.bodyLarge)),
      ],
    ];
    final right = [
      _ConsentsPanel(consents: d.consents),
      const SizedBox(height: GxSpacing.lg),
      HistoryPanel(
        history: d.history,
        labels: _actionLabels,
        emptyText: 'Bu hesapla ilgili kayıtlı bir işlem yok.',
        userActorLabel: 'Kullanıcının kendisi',
      ),
    ];

    return [
      _HeaderPanel(user: u, actions: actions),
      if (_error != null) ...[const SizedBox(height: GxSpacing.md), GxFormMessage(_error!)],
      if (u.status == AdminAccountStatus.suspended) ...[
        const SizedBox(height: GxSpacing.md),
        DetailBanner(
          tone: GxBadgeTone.danger,
          icon: Icons.block,
          title: u.suspendedUntil == null
              ? 'Hesap süresiz olarak askıda'
              : 'Hesap ${formatDateTimeTr(u.suspendedUntil!)} tarihine kadar askıda',
          body: d.suspensionReason == null ? null : 'Gerekçe: ${d.suspensionReason}',
        ),
      ],
      if (u.status == AdminAccountStatus.pendingDeletion && u.deletionScheduledFor != null) ...[
        const SizedBox(height: GxSpacing.md),
        DetailBanner(
          tone: GxBadgeTone.neutral,
          icon: Icons.schedule,
          title: 'Hesap ${formatDateTr(u.deletionScheduledFor!)} tarihinde kalıcı olarak silinecek',
          body: 'Kullanıcı bu tarihe kadar giriş yapıp silmeyi geri alabilir.',
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
  const _HeaderPanel({required this.user, required this.actions});

  final AdminUserSummary user;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final identity = Row(
      children: [
        GxAvatar(
          name: user.title,
          shape: GxAvatarShape.user,
          size: GxAvatarSize.lg,
          imageUrl: ref.watch(avatarUrlProvider(user.avatarPath)),
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
                children: [
                  Text(user.title, style: textTheme.headlineMedium),
                  StatusBadge(user.status),
                  if (user.staffRole != null) RoleBadge(user.staffRole!),
                ],
              ),
              const SizedBox(height: GxSpacing.xxs),
              Text(
                [if (user.username != null) '@${user.username}', ?user.email].join('  ·  '),
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

class _AccountPanel extends StatelessWidget {
  const _AccountPanel({required this.detail});

  final AdminUserDetail detail;

  @override
  Widget build(BuildContext context) {
    final u = detail.user;
    String date(DateTime? d) => d == null ? '—' : formatDateTimeTr(d);
    final rows = [
      ('Kullanıcı kimliği', u.id),
      ('E-posta', u.email ?? '—'),
      ('Kullanıcı adı', u.username == null ? 'Onboarding tamamlanmadı' : '@${u.username}'),
      ('Kayıt tarihi', date(u.createdAt)),
      ('Son giriş', date(u.lastSignInAt)),
      ('Platform rolü', u.staffRole?.label ?? 'Yok'),
    ];
    return InfoPanel(title: 'Hesap bilgileri', rows: rows);
  }
}

class _ConsentsPanel extends StatelessWidget {
  const _ConsentsPanel({required this.consents});

  final List<AdminConsent> consents;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GxPanel(
      title: 'KVKK onayları',
      child: consents.isEmpty
          ? Text('Kullanıcı henüz hiçbir metni onaylamadı.', style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary))
          : Column(
              children: [
                for (final (i, c) in consents.indexed) ...[
                  if (i > 0) const SizedBox(height: GxSpacing.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle, color: GxColors.primary, size: GxSpacing.md + GxSpacing.xxs),
                      const SizedBox(width: GxSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_consentLabels[c.kind] ?? c.kind, style: textTheme.labelLarge),
                            Text(
                              'Sürüm ${c.version} · ${formatDateTimeTr(c.acceptedAt)}',
                              style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
    );
  }
}
