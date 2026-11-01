import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/admin_moderation.dart';
import '../domain/admin_user.dart';
import 'admin_shell.dart';
import 'matching_screen.dart';
import 'providers.dart';
import 'routes.dart';
import 'suspend_dialog.dart';
import 'widgets.dart';

enum _View { reports, appeals, referrals }

/// Reports across the platform, the appeals the platform decides and the illegal-activity referrals of the group
/// boards (docs/ARCHITECTURE.md §3e, Admin and Yasa dışı faaliyet).
class AdminReportsScreen extends ConsumerStatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  ConsumerState<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends ConsumerState<AdminReportsScreen> {
  _View _view = _View.reports;
  AdminReportScope? _scope;
  AdminReportStatus? _status = AdminReportStatus.open;
  AdminAppealStatus? _appealStatus = AdminAppealStatus.pending;
  AdminReferralStatus? _referralStatus = AdminReferralStatus.pending;
  int _page = 1;

  void _done(Result<void> result, String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(switch (result) {
        Ok() => message,
        Err(:final failure) => failure.userMessage,
      }),
    ));
    _refresh();
  }

  void _refresh() => ref
    ..invalidate(adminReportSearchProvider)
    ..invalidate(adminAppealSearchProvider)
    ..invalidate(adminReferralSearchProvider);

  Future<void> _review(AdminReport r, {required bool actioned}) async {
    final result = await ref.read(adminModerationRepositoryProvider).review(r.id, actioned: actioned);
    _done(result, actioned ? 'Şikayet işlem yapıldı olarak kapatıldı.' : 'Şikayet reddedildi.');
  }

  Future<void> _decide(AdminAppeal a, {required bool overturn}) async {
    final request = await showSuspendDialog(
      context,
      title: overturn ? 'Yaptırımı kaldır' : 'Yaptırım sürsün',
      description: 'Kararın kişiye bildirilir. Gerekçe kayda geçer.',
      withDuration: false,
      confirmLabel: overturn ? 'Kaldır' : 'Onayla',
    );
    if (request == null || !mounted) return;
    final result = await ref.read(adminModerationRepositoryProvider).decideAppeal(a.id, overturn: overturn, note: request.reason);
    _done(result, overturn ? 'Yaptırım kaldırıldı.' : 'İtiraz reddedildi; yaptırım sürüyor.');
  }

  Future<void> _decideReferral(AdminReferral r) async {
    final outcome = await showDialog<AdminReferralOutcome>(context: context, builder: (_) => _ReferralDecisionDialog(referral: r));
    if (outcome == null || !mounted) return;
    _done(
      const Ok(null),
      outcome.banned
          ? 'Hesap kapatıldı. ${outcome.canceledPlans} paket dilimi iadesiz iptal edildi, ${outcome.suspendedGroups} grup askıya alındı.'
          : 'Kişi temize çıktı; hesap askısı kalktı.',
    );
  }

  Future<void> _authoritiesNotified(AdminReferral r) async {
    final request = await showSuspendDialog(
      context,
      title: 'Kolluğa bildirildi',
      description: 'Başvurduğun yeri ve evrak numarasını yaz. Not kayda geçer ve sonradan değişmez.',
      withDuration: false,
      confirmLabel: 'Kaydet',
    );
    if (request == null || !mounted) return;
    final result = await ref.read(adminModerationRepositoryProvider).markAuthoritiesNotified(r.id, note: request.reason);
    _done(result, 'Kolluk bildirimi kaydedildi.');
  }

  Widget _chips<T>(List<(T, String)> options, T? selected, ValueChanged<T?> onChanged, {String allLabel = 'Tümü'}) => Wrap(
        spacing: GwSpacing.xs,
        runSpacing: GwSpacing.xs,
        children: [
          ChoiceChip(label: Text(allLabel), selected: selected == null, onSelected: (_) => onChanged(null)),
          for (final (value, label) in options)
            ChoiceChip(label: Text(label), selected: selected == value, onSelected: (_) => onChanged(value)),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(myStaffRoleProvider).value;
    final canAct = role?.canSuspend ?? false;
    return AdminPage(
      title: 'Şikayetler',
      subtitle: 'Platform genelindeki şikayetler, sahibin taraf olduğu dosyaların itirazları ve yasa dışı faaliyet bildirimleri.',
      actions: [
        GwButton(label: 'Yenile', icon: Icons.refresh, variant: GwButtonVariant.secondary, onPressed: _refresh),
      ],
      children: [
        GwPanel(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(GwSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SegmentedButton<_View>(
                      segments: const [
                        ButtonSegment(value: _View.reports, label: Text('Şikayetler'), icon: Icon(Icons.flag_outlined)),
                        ButtonSegment(value: _View.appeals, label: Text('İtirazlar'), icon: Icon(Icons.record_voice_over_outlined)),
                        ButtonSegment(value: _View.referrals, label: Text('Yasa dışı'), icon: Icon(Icons.policy_outlined)),
                      ],
                      selected: {_view},
                      onSelectionChanged: (v) => setState(() {
                        _view = v.single;
                        _page = 1;
                      }),
                    ),
                    const SizedBox(height: GwSpacing.sm),
                    if (_view == _View.reports) ...[
                      _chips([for (final s in AdminReportStatus.values) (s, s.label)], _status, (s) => setState(() {
                            _status = s;
                            _page = 1;
                          })),
                      const SizedBox(height: GwSpacing.xs),
                      _chips([for (final s in AdminReportScope.values) (s, s.label)], _scope, (s) => setState(() {
                            _scope = s;
                            _page = 1;
                          }), allLabel: 'Her kapsam'),
                    ] else if (_view == _View.appeals)
                      _chips([for (final s in AdminAppealStatus.values) (s, s.label)], _appealStatus, (s) => setState(() {
                            _appealStatus = s;
                            _page = 1;
                          }))
                    else
                      _chips([for (final s in AdminReferralStatus.values) (s, s.label)], _referralStatus, (s) => setState(() {
                            _referralStatus = s;
                            _page = 1;
                          })),
                  ],
                ),
              ),
              const Divider(),
              if (_view == _View.reports)
                _ReportList(
                  search: (scope: _scope, status: _status, page: _page),
                  canAct: canAct,
                  onPage: (p) => setState(() => _page = p),
                  onReview: _review,
                )
              else if (_view == _View.appeals)
                _AppealList(
                  search: (status: _appealStatus, page: _page),
                  canAct: canAct,
                  onPage: (p) => setState(() => _page = p),
                  onDecide: _decide,
                )
              else
                _ReferralList(
                  search: (status: _referralStatus, page: _page),
                  // Only a platform admin decides: a ban cancels paid plans without refund.
                  canDecide: role == StaffRole.admin,
                  onPage: (p) => setState(() => _page = p),
                  onDecide: _decideReferral,
                  onAuthoritiesNotified: _authoritiesNotified,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget _loading() => const Padding(
      padding: EdgeInsets.all(GwSpacing.lg),
      child: Column(children: [GwSkeleton(height: GwSpacing.xl), SizedBox(height: GwSpacing.md), GwSkeleton(height: GwSpacing.xl)]),
    );

class _ReportList extends ConsumerWidget {
  const _ReportList({required this.search, required this.canAct, required this.onPage, required this.onReview});

  final AdminReportSearch search;
  final bool canAct;
  final ValueChanged<int> onPage;
  final Future<void> Function(AdminReport report, {required bool actioned}) onReview;

  @override
  Widget build(BuildContext context, WidgetRef ref) => switch (ref.watch(adminReportSearchProvider(search))) {
        AsyncData(:final value) when value.items.isEmpty => Padding(
            padding: const EdgeInsets.symmetric(vertical: GwSpacing.xl),
            child: GwEmptyState(
              icon: Icons.verified_user_outlined,
              message: 'Bu filtrede şikayet yok.',
              actionLabel: 'Yenile',
              onAction: () => ref.invalidate(adminReportSearchProvider(search)),
            ),
          ),
        AsyncData(:final value) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final r in value.items) ...[_ReportRow(report: r, canAct: canAct, onReview: onReview), const Divider()],
              PageFooter(
                from: value.range.$1,
                to: value.range.$2,
                total: value.total,
                noun: 'şikayet',
                page: value.page,
                pageCount: value.pageCount,
                onPage: onPage,
              ),
            ],
          ),
        AsyncError(:final error) => Padding(
            padding: const EdgeInsets.symmetric(vertical: GwSpacing.xl),
            child: GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(adminReportSearchProvider(search))),
          ),
        _ => _loading(),
      };
}

class _ReportRow extends StatelessWidget {
  const _ReportRow({required this.report, required this.canAct, required this.onReview});

  final AdminReport report;
  final bool canAct;
  final Future<void> Function(AdminReport report, {required bool actioned}) onReview;

  /// Where the platform team acts on the target with its own tools.
  String? get _location => switch (report) {
        AdminReport(postId: final post?) => AdminRoutes.post(post),
        AdminReport(targetType: 'user', subjectId: final user?) => AdminRoutes.user(user),
        AdminReport(groupId: final group?) => AdminRoutes.group(group),
        AdminReport(subjectId: final user?) => AdminRoutes.user(user),
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final r = report;
    final textTheme = Theme.of(context).textTheme;
    final secondary = textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary);
    final location = _location;
    final meta = [
      r.groupName == null ? 'Platform' : '${r.groupName} (@${r.groupHandle})',
      if (r.reporterUsername != null) 'Şikayet eden @${r.reporterUsername}',
      if (r.subjectUsername != null) 'Hedef @${r.subjectUsername}',
      formatDateTimeTr(r.createdAt),
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GwSpacing.lg, vertical: GwSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: GwSpacing.xs,
            runSpacing: GwSpacing.xs,
            children: [
              GwBadge(r.targetLabel, tone: GwBadgeTone.info),
              GwBadge(r.reasonLabel, tone: GwBadgeTone.warning),
              if (r.status == AdminReportStatus.open && r.openCount > 1) GwBadge('${r.openCount} açık şikayet', tone: GwBadgeTone.danger),
              if (r.status != AdminReportStatus.open) GwBadge(r.status.label),
            ],
          ),
          const SizedBox(height: GwSpacing.xs),
          if (r.targetType == 'message')
            Text('Mesaj içeriği gizlilik gereği gösterilmez; karar şikayet gerekçesine göre verilir.', style: secondary)
          else if (r.excerpt.isNotEmpty)
            Text(r.excerpt, maxLines: 3, overflow: TextOverflow.ellipsis, style: textTheme.bodyLarge),
          if (r.note case final note?) Text('“$note”', style: secondary?.copyWith(fontStyle: FontStyle.italic)),
          Text(meta, style: secondary),
          const SizedBox(height: GwSpacing.xs),
          Wrap(
            spacing: GwSpacing.xs,
            runSpacing: GwSpacing.xs,
            children: [
              if (canAct && r.status == AdminReportStatus.open && r.targetType == 'message')
                _RemoveMessageButton(report: r, onRemoved: () => onReview(r, actioned: true)),
              if (r.targetType == 'match_photo')
                GwButton(
                  label: 'Fotoğrafı gör',
                  icon: Icons.image_outlined,
                  variant: GwButtonVariant.text,
                  onPressed: () => showDialog<void>(context: context, builder: (_) => MatchPhotoDialog(path: r.excerpt)),
                ),
              if (canAct && r.status == AdminReportStatus.open && r.targetType == 'match_photo')
                GwButton(
                  label: 'Fotoğrafı kaldır',
                  icon: Icons.hide_image_outlined,
                  variant: GwButtonVariant.text,
                  onPressed: () async {
                    if (await removeMatchPhoto(context, r.targetId) && context.mounted) await onReview(r, actioned: true);
                  },
                ),
              if (canAct && r.status == AdminReportStatus.open && r.targetType == 'match_profile')
                GwButton(
                  label: 'Eşleşme profilini kapat',
                  icon: Icons.block,
                  variant: GwButtonVariant.text,
                  onPressed: () async {
                    if (await suspendMatchProfile(context, r.targetId) && context.mounted) await onReview(r, actioned: true);
                  },
                ),
              if (location != null)
                GwButton(label: 'Görüntüle', icon: Icons.open_in_new, variant: GwButtonVariant.text, onPressed: () => context.go(location)),
              if (canAct && r.status == AdminReportStatus.open) ...[
                GwButton(label: 'Reddet', variant: GwButtonVariant.secondary, onPressed: () => onReview(r, actioned: false)),
                GwButton(label: 'İşlem yapıldı', icon: Icons.check, onPressed: () => onReview(r, actioned: true)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}


/// Removes a reported message without showing it: the platform team never reads private messages.
class _RemoveMessageButton extends ConsumerStatefulWidget {
  const _RemoveMessageButton({required this.report, required this.onRemoved});

  final AdminReport report;
  final Future<void> Function() onRemoved;

  @override
  ConsumerState<_RemoveMessageButton> createState() => _RemoveMessageButtonState();
}

class _RemoveMessageButtonState extends ConsumerState<_RemoveMessageButton> {
  bool _removing = false;

  Future<void> _remove() async {
    final request = await showSuspendDialog(
      context,
      title: 'Mesajı kaldır',
      description: 'Mesaj sohbette "Bu mesaj kaldırıldı" olarak görünür ve şikayet kapanır. Gerekçe kayda geçer.',
      withDuration: false,
      confirmLabel: 'Kaldır',
    );
    if (request == null || !mounted) return;
    setState(() => _removing = true);
    final result = await ref.read(adminModerationRepositoryProvider).removeMessage(widget.report.targetId, reason: request.reason);
    if (!mounted) return;
    setState(() => _removing = false);
    switch (result) {
      case Ok():
        await widget.onRemoved();
      case Err(:final failure):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.userMessage)));
    }
  }

  @override
  Widget build(BuildContext context) => GwButton(
        label: 'Mesajı kaldır',
        icon: Icons.delete_outline,
        variant: GwButtonVariant.text,
        isLoading: _removing,
        onPressed: _remove,
      );
}

class _AppealList extends ConsumerWidget {
  const _AppealList({required this.search, required this.canAct, required this.onPage, required this.onDecide});

  final AdminAppealSearch search;
  final bool canAct;
  final ValueChanged<int> onPage;
  final Future<void> Function(AdminAppeal appeal, {required bool overturn}) onDecide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final secondary = textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary);
    return switch (ref.watch(adminAppealSearchProvider(search))) {
      AsyncData(:final value) when value.items.isEmpty => Padding(
          padding: const EdgeInsets.symmetric(vertical: GwSpacing.xl),
          child: GwEmptyState(
            icon: Icons.record_voice_over_outlined,
            message: 'Bu filtrede itiraz yok. Sahibin taraf olduğu dosyaların itirazları buraya düşer.',
            actionLabel: 'Yenile',
            onAction: () => ref.invalidate(adminAppealSearchProvider(search)),
          ),
        ),
      AsyncData(:final value) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final a in value.items) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: GwSpacing.lg, vertical: GwSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: GwSpacing.xs,
                      children: [
                        GwBadge(a.sanctionLabel, tone: GwBadgeTone.danger),
                        GwBadge(a.status.label, tone: a.status == AdminAppealStatus.pending ? GwBadgeTone.warning : GwBadgeTone.neutral),
                      ],
                    ),
                    const SizedBox(height: GwSpacing.xs),
                    Text('@${a.username ?? 'silinmiş hesap'} · ${a.groupName} (@${a.groupHandle})', style: textTheme.labelLarge),
                    Text('Kurulun gerekçesi: ${a.caseReason}', style: secondary),
                    const SizedBox(height: GwSpacing.xxs),
                    Text('İtiraz: ${a.body}', style: textTheme.bodyLarge),
                    if (a.decisionNote case final note?) Text('Karar notu: $note', style: secondary),
                    Text(formatDateTimeTr(a.createdAt), style: secondary),
                    const SizedBox(height: GwSpacing.xs),
                    Wrap(
                      spacing: GwSpacing.xs,
                      runSpacing: GwSpacing.xs,
                      children: [
                        GwButton(
                          label: 'Kullanıcı',
                          icon: Icons.open_in_new,
                          variant: GwButtonVariant.text,
                          onPressed: () => context.go(AdminRoutes.user(a.userId)),
                        ),
                        if (canAct && a.status == AdminAppealStatus.pending) ...[
                          GwButton(label: 'Sürsün', variant: GwButtonVariant.secondary, onPressed: () => onDecide(a, overturn: false)),
                          GwButton(label: 'Yaptırımı kaldır', onPressed: () => onDecide(a, overturn: true)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
            ],
            PageFooter(
              from: value.range.$1,
              to: value.range.$2,
              total: value.total,
              noun: 'itiraz',
              page: value.page,
              pageCount: value.pageCount,
              onPage: onPage,
            ),
          ],
        ),
      AsyncError(:final error) => Padding(
          padding: const EdgeInsets.symmetric(vertical: GwSpacing.xl),
          child: GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(adminAppealSearchProvider(search))),
        ),
      _ => _loading(),
    };
  }
}

class _ReferralList extends ConsumerWidget {
  const _ReferralList({
    required this.search,
    required this.canDecide,
    required this.onPage,
    required this.onDecide,
    required this.onAuthoritiesNotified,
  });

  final AdminReferralSearch search;
  final bool canDecide;
  final ValueChanged<int> onPage;
  final Future<void> Function(AdminReferral referral) onDecide;
  final Future<void> Function(AdminReferral referral) onAuthoritiesNotified;

  @override
  Widget build(BuildContext context, WidgetRef ref) => switch (ref.watch(adminReferralSearchProvider(search))) {
        AsyncData(:final value) when value.items.isEmpty => Padding(
            padding: const EdgeInsets.symmetric(vertical: GwSpacing.xl),
            child: GwEmptyState(
              icon: Icons.policy_outlined,
              message: 'Bu filtrede bildirim yok. Kurulun onayladığı yasa dışı faaliyet dosyaları buraya düşer.',
              actionLabel: 'Yenile',
              onAction: () => ref.invalidate(adminReferralSearchProvider(search)),
            ),
          ),
        AsyncData(:final value) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final r in value.items) ...[
                _ReferralRow(referral: r, canDecide: canDecide, onDecide: onDecide, onAuthoritiesNotified: onAuthoritiesNotified),
                const Divider(),
              ],
              PageFooter(
                from: value.range.$1,
                to: value.range.$2,
                total: value.total,
                noun: 'bildirim',
                page: value.page,
                pageCount: value.pageCount,
                onPage: onPage,
              ),
            ],
          ),
        AsyncError(:final error) => Padding(
            padding: const EdgeInsets.symmetric(vertical: GwSpacing.xl),
            child: GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(adminReferralSearchProvider(search))),
          ),
        _ => _loading(),
      };
}

class _ReferralRow extends StatelessWidget {
  const _ReferralRow({required this.referral, required this.canDecide, required this.onDecide, required this.onAuthoritiesNotified});

  final AdminReferral referral;
  final bool canDecide;
  final Future<void> Function(AdminReferral referral) onDecide;
  final Future<void> Function(AdminReferral referral) onAuthoritiesNotified;

  @override
  Widget build(BuildContext context) {
    final r = referral;
    final textTheme = Theme.of(context).textTheme;
    final secondary = textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary);
    final decision = switch (r.status) {
      AdminReferralStatus.pending => null,
      AdminReferralStatus.banned => r.banUntil == null ? 'Kalıcı ban' : 'Ban, ${formatDateTimeTr(r.banUntil!)} tarihine kadar',
      AdminReferralStatus.cleared => 'Temize çıktı',
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GwSpacing.lg, vertical: GwSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: GwSpacing.xs,
            runSpacing: GwSpacing.xs,
            children: [
              GwBadge(r.categoryLabel, tone: GwBadgeTone.danger),
              GwBadge(r.status.label, tone: r.status == AdminReferralStatus.pending ? GwBadgeTone.warning : GwBadgeTone.neutral),
              if (r.lawEnforcement != LawEnforcementState.none)
                GwBadge(r.lawEnforcement.label, tone: r.lawEnforcement == LawEnforcementState.toNotify ? GwBadgeTone.warning : GwBadgeTone.info),
            ],
          ),
          const SizedBox(height: GwSpacing.xs),
          Text('@${r.subjectUsername ?? 'silinmiş hesap'} · ${r.groupName}', style: textTheme.labelLarge),
          Text('Kurulun gerekçesi: ${r.reason}', style: textTheme.bodyLarge),
          if (r.evidence.isNotEmpty) ...[
            const SizedBox(height: GwSpacing.xs),
            Text('Kanıt (${r.evidence.length})', style: textTheme.labelMedium),
            for (final e in r.evidence)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: GwSpacing.xxs),
                padding: const EdgeInsets.all(GwSpacing.sm),
                decoration: const BoxDecoration(
                  color: GwColors.surface,
                  borderRadius: GwRadius.mdAll,
                  border: Border.fromBorderSide(GwBorders.hairline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      [e.targetLabel, if (e.reportedAt != null) formatDateTimeTr(e.reportedAt!)].join(' · '),
                      style: textTheme.labelSmall?.copyWith(color: GwColors.textSecondary),
                    ),
                    if (e.excerpt.isNotEmpty) SelectableText(e.excerpt, style: textTheme.bodyMedium),
                    if (e.note case final note?) Text('“$note”', style: secondary?.copyWith(fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
          ],
          const SizedBox(height: GwSpacing.xxs),
          if (decision != null) Text('Karar: $decision${r.decisionNote == null ? '' : ' · ${r.decisionNote}'}', style: secondary),
          if (r.authoritiesNote case final note?)
            Text('Kolluk: $note${r.authoritiesNotifiedAt == null ? '' : ' · ${formatDateTimeTr(r.authoritiesNotifiedAt!)}'}', style: secondary),
          Text(formatDateTimeTr(r.createdAt), style: secondary),
          const SizedBox(height: GwSpacing.xs),
          Wrap(
            spacing: GwSpacing.xs,
            runSpacing: GwSpacing.xs,
            children: [
              GwButton(
                label: 'Kullanıcı',
                icon: Icons.open_in_new,
                variant: GwButtonVariant.text,
                onPressed: () => context.go(AdminRoutes.user(r.subjectId)),
              ),
              if (r.groupId case final group?)
                GwButton(label: 'Grup', icon: Icons.open_in_new, variant: GwButtonVariant.text, onPressed: () => context.go(AdminRoutes.group(group))),
              if (canDecide && r.status == AdminReferralStatus.pending)
                GwButton(label: 'Karar ver', icon: Icons.gavel_outlined, onPressed: () => onDecide(r)),
              if (canDecide && r.lawEnforcement == LawEnforcementState.toNotify)
                GwButton(
                  label: 'Kolluğa bildirildi',
                  icon: Icons.local_police_outlined,
                  variant: GwButtonVariant.secondary,
                  onPressed: () => onAuthoritiesNotified(r),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Ban (for a while or for good) or clear; a ban ends the person's paid plans without refund and suspends their groups.
class _ReferralDecisionDialog extends ConsumerStatefulWidget {
  const _ReferralDecisionDialog({required this.referral});

  final AdminReferral referral;

  @override
  ConsumerState<_ReferralDecisionDialog> createState() => _ReferralDecisionDialogState();
}

class _ReferralDecisionDialogState extends ConsumerState<_ReferralDecisionDialog> {
  static const _durations = <int?>[30, 90, 365, 1825, null];

  final _note = TextEditingController();
  bool _ban = true;
  int? _days;
  bool _lawEnforcement = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_note.text.trim().length < 3) {
      setState(() => _error = 'Karar notu en az 3 karakter olmalı.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ref.read(adminModerationRepositoryProvider).decideReferral(
          widget.referral.id,
          ban: _ban,
          banDays: _ban ? _days : null,
          lawEnforcement: _lawEnforcement,
          note: _note.text.trim(),
        );
    if (!mounted) return;
    switch (result) {
      case Ok(:final value):
        Navigator.of(context).pop(value);
      case Err(:final failure):
        setState(() {
          _busy = false;
          _error = failure.userMessage;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final secondary = textTheme.bodySmall?.copyWith(color: GwColors.textSecondary);
    return AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: GwRadius.xlAll),
      title: Text('@${widget.referral.subjectUsername ?? 'silinmiş hesap'} hakkında karar'),
      content: SizedBox(
        width: GwLayout.formMaxWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('Banla'), icon: Icon(Icons.block)),
                  ButtonSegment(value: false, label: Text('Temize çıkar'), icon: Icon(Icons.verified_outlined)),
                ],
                selected: {_ban},
                onSelectionChanged: (v) => setState(() => _ban = v.single),
              ),
              const SizedBox(height: GwSpacing.sm),
              if (_ban) ...[
                Wrap(
                  spacing: GwSpacing.xs,
                  runSpacing: GwSpacing.xs,
                  children: [
                    for (final d in _durations)
                      ChoiceChip(
                        label: Text(d == null ? 'Kalıcı' : '$d gün'),
                        selected: _days == d,
                        onSelected: (_) => setState(() => _days = d),
                      ),
                  ],
                ),
                const SizedBox(height: GwSpacing.xs),
                Text(
                  'Hesap bu süreyle kapanır. Kişisel paketleri iadesiz iptal edilir; sahibi olduğu gruplar askıya alınır ve paketleri iadesiz iptal edilir.',
                  style: secondary,
                ),
              ] else
                Text('Hesap askısı kalkar. Grup banı kurulun kararıdır, sürer; kişi itiraz edebilir.', style: secondary),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _lawEnforcement,
                onChanged: (v) => setState(() => _lawEnforcement = v),
                title: const Text('Kolluğa bildirilecek'),
                subtitle: const Text('Bildirimi yaptıktan sonra "Kolluğa bildirildi" ile kaydedersin.'),
              ),
              TextField(
                controller: _note,
                maxLength: 1000,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Karar notu', hintText: 'Kararın gerekçesi; kayda geçer.'),
              ),
              if (_error != null) GwFormMessage(_error!),
            ],
          ),
        ),
      ),
      actions: [
        GwButton(label: 'Vazgeç', variant: GwButtonVariant.text, onPressed: _busy ? null : () => Navigator.of(context).pop()),
        GwButton(label: _ban ? 'Banla' : 'Temize çıkar', isLoading: _busy, onPressed: _submit),
      ],
    );
  }
}
