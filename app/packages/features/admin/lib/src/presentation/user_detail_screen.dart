import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/admin_user.dart';
import 'admin_shell.dart';
import 'providers.dart';
import 'routes.dart';
import 'security_screen.dart';
import 'status_chip.dart';
import 'suspend_dialog.dart';
import 'user_packages_panel.dart';
import 'widgets.dart';

const _actionLabels = {
  'user.suspended': ('Hesap askıya alındı', Icons.block),
  'user.unsuspended': ('Askı kaldırıldı', Icons.lock_open_outlined),
  'account.deletion_requested': ('Hesap silme istendi', Icons.delete_outline),
  'account.deletion_cancelled': ('Hesap silme geri alındı', Icons.restore),
  'security.phone_verified': ('Telefon doğrulandı', Icons.sms_outlined),
  'security.totp_enabled': ('Doğrulama uygulaması eklendi', Icons.phonelink_lock_outlined),
  'security.totp_disabled': ('Doğrulama uygulaması kaldırıldı', Icons.phonelink_erase_outlined),
  'security.restricted': ('Güvenlik incelemesine alındı', Icons.shield_outlined),
  'security.banned': ('Güvenlik nedeniyle otomatik banlandı', Icons.gpp_bad_outlined),
  'security.review_approved': ('Güvenlik incelemesi onaylandı', Icons.verified_user_outlined),
  'security.review_banned': ('Güvenlik incelemesinde banlandı', Icons.gpp_bad_outlined),
};

const _consentLabels = {
  'terms': 'Kullanım Koşulları',
  'privacy_notice': 'KVKK Aydınlatma Metni',
  'explicit_consent': 'Açık Rıza Metni',
  'community_rules': 'Topluluk Kuralları',
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

  /// With an end date: the profile stays visible with a notice; the reason goes only to the user (docs/ARCHITECTURE.md §3a).
  Future<void> _suspend() async {
    final request = await showSuspendDialog(
      context,
      description: 'Kullanıcı askı süresince uygulamayı kullanamaz. Profilinde askıda olduğu ve bitiş tarihi görünür. '
          'Gerekçeyi yalnızca kullanıcı görür; giriş yapınca ve uygulama açıksa hemen.',
      durations: const [SuspendDuration.day, SuspendDuration.week, SuspendDuration.month],
    );
    if (request == null) return;
    await _run((repo) => repo.suspend(widget.userId, reason: request.reason, until: request.until));
  }

  /// Without an end date: the account is hidden everywhere; the user sees the reason when signing in.
  Future<void> _ban() async {
    final request = await showSuspendDialog(
      context,
      title: 'Kullanıcıyı kalıcı banla',
      description: 'Hesap kalıcı olarak kapanır; profili ve içerikleri hiçbir yerde görünmez. '
          'Kullanıcı giriş yapınca gerekçeyi görür. Ban sonradan kaldırılabilir.',
      withDuration: false,
      confirmLabel: 'Kalıcı banla',
    );
    if (request == null) return;
    await _run((repo) => repo.suspend(widget.userId, reason: request.reason, until: null));
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
            GwPanel(
              child: GwEmptyState(
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
            GwPanel(
              child: GwErrorState(
                message: userMessageOf(error),
                onRetry: () => ref.invalidate(userDetailProvider(widget.userId)),
              ),
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

  List<Widget> _content(AdminUserDetail d, StaffRole? myRole) {
    final u = d.user;
    final canModerate = (myRole?.canSuspend ?? false) && u.staffRole == null;
    final wide = MediaQuery.sizeOf(context).width >= GwLayout.wideBreakpoint;

    final actions = <Widget>[
      if (canModerate && u.status == AdminAccountStatus.suspended)
        GwButton(
          label: u.isBanned ? 'Banı kaldır' : 'Askıyı kaldır',
          icon: Icons.lock_open_outlined,
          variant: GwButtonVariant.secondary,
          isLoading: _saving,
          onPressed: () => _run((repo) => repo.unsuspend(u.id)),
        ),
      if (canModerate && u.status == AdminAccountStatus.active) ...[
        GwButton(label: 'Askıya al', icon: Icons.pause_circle_outline, variant: GwButtonVariant.secondary, isLoading: _saving, onPressed: _suspend),
        GwButton(label: 'Kalıcı banla', icon: Icons.block, isLoading: _saving, onPressed: _ban),
      ],
      if (myRole?.code == 'admin' && u.username != null)
        GwButton(
          label: 'Mesaj kayıtları',
          icon: Icons.forum_outlined,
          variant: GwButtonVariant.secondary,
          onPressed: () => context.go(AdminRoutes.messageLogsOf(u.username!)),
        ),
    ];

    final left = [
      _AccountPanel(detail: d),
      const SizedBox(height: GwSpacing.lg),
      InfoPanel(title: 'Topluluk katkısı', rows: [
        ('Katıldığı organizasyon', formatCount(d.contributions.attended)),
        ('Düzenlediği organizasyon', formatCount(d.contributions.organized)),
        ('Anı', formatCount(d.contributions.memories)),
        ('Değerlendirme', formatCount(d.contributions.reviews)),
        ('Gelmedi işareti', formatCount(d.contributions.noShows)),
        ('Karşıladığı ilk kez gelen', formatCount(d.contributions.welcomed)),
      ]),
      const SizedBox(height: GwSpacing.lg),
      InfoPanel(title: 'Ekip arkadaşı', rows: [
        ('Ekip arıyor', d.teammates.looking ? 'Evet' : 'Hayır'),
        ('Ekip arkadaşı', formatCount(d.teammates.teammates)),
        ('Son 24 saatte gönderdiği istek', '${d.teammates.requestsSentToday} / 20'),
        ('Yanıt bekleyen istekleri', formatCount(d.teammates.requestsPending)),
      ]),
      if (d.bio case final bio? when bio.isNotEmpty) ...[
        const SizedBox(height: GwSpacing.lg),
        GwPanel(title: 'Hakkında', child: Text(bio, style: Theme.of(context).textTheme.bodyLarge)),
      ],
    ];
    final right = [
      UserSecurityPanel(userId: u.id),
      const SizedBox(height: GwSpacing.lg),
      UserPackagesPanel(userId: u.id, title: u.title),
      const SizedBox(height: GwSpacing.lg),
      _ConsentsPanel(consents: d.consents),
      const SizedBox(height: GwSpacing.lg),
      HistoryPanel(
        history: d.history,
        labels: _actionLabels,
        emptyText: 'Bu hesapla ilgili kayıtlı bir işlem yok.',
        userActorLabel: 'Kullanıcının kendisi',
      ),
    ];

    return [
      _HeaderPanel(user: u, actions: actions),
      if (_error != null) ...[const SizedBox(height: GwSpacing.md), GwFormMessage(_error!)],
      if (u.status == AdminAccountStatus.suspended) ...[
        const SizedBox(height: GwSpacing.md),
        DetailBanner(
          tone: GwBadgeTone.danger,
          icon: Icons.block,
          title: u.suspendedUntil == null
              ? 'Hesap kalıcı olarak banlı; hiçbir yerde görünmüyor'
              : 'Hesap ${formatDateTimeTr(u.suspendedUntil!)} tarihine kadar askıda; profilinde uyarı görünüyor',
          body: d.suspensionReason == null ? null : 'Gerekçe: ${d.suspensionReason}',
        ),
      ],
      if (u.status == AdminAccountStatus.pendingDeletion && u.deletionScheduledFor != null) ...[
        const SizedBox(height: GwSpacing.md),
        DetailBanner(
          tone: GwBadgeTone.neutral,
          icon: Icons.schedule,
          title: 'Hesap ${formatDateTr(u.deletionScheduledFor!)} tarihinde kalıcı olarak silinecek',
          body: 'Kullanıcı bu tarihe kadar giriş yapıp silmeyi geri alabilir.',
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
  const _HeaderPanel({required this.user, required this.actions});

  final AdminUserSummary user;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final identity = Row(
      children: [
        GwAvatar(
          name: user.title,
          shape: GwAvatarShape.user,
          size: GwAvatarSize.lg,
          imageUrl: ref.watch(avatarUrlProvider(user.avatarPath)),
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
                children: [
                  Text(user.title, style: textTheme.headlineMedium),
                  StatusBadge(user.status, banned: user.isBanned),
                  if (user.staffRole != null) RoleBadge(user.staffRole!),
                ],
              ),
              const SizedBox(height: GwSpacing.xxs),
              Text(
                [if (user.username != null) '@${user.username}', ?user.email].join('  ·  '),
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
    return GwPanel(
      title: 'KVKK onayları',
      child: consents.isEmpty
          ? Text('Kullanıcı henüz hiçbir metni onaylamadı.', style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary))
          : Column(
              children: [
                for (final (i, c) in consents.indexed) ...[
                  if (i > 0) const SizedBox(height: GwSpacing.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle, color: GwColors.primary, size: GwSpacing.md + GwSpacing.xxs),
                      const SizedBox(width: GwSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_consentLabels[c.kind] ?? c.kind, style: textTheme.labelLarge),
                            Text(
                              'Sürüm ${c.version} · ${formatDateTimeTr(c.acceptedAt)}',
                              style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary),
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
