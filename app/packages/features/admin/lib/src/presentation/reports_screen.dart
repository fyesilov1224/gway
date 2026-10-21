import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/admin_moderation.dart';
import 'admin_shell.dart';
import 'providers.dart';
import 'routes.dart';
import 'suspend_dialog.dart';
import 'widgets.dart';

enum _View { reports, appeals }

/// Reports across the platform and the appeals the platform decides (docs/ARCHITECTURE.md §3e, Admin).
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
  int _page = 1;

  void _done(Result<void> result, String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(switch (result) {
        Ok() => message,
        Err(:final failure) => failure.userMessage,
      }),
    ));
    ref
      ..invalidate(adminReportSearchProvider)
      ..invalidate(adminAppealSearchProvider);
  }

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

  Widget _chips<T>(List<(T, String)> options, T? selected, ValueChanged<T?> onChanged, {String allLabel = 'Tümü'}) => Wrap(
        spacing: GxSpacing.xs,
        runSpacing: GxSpacing.xs,
        children: [
          ChoiceChip(label: Text(allLabel), selected: selected == null, onSelected: (_) => onChanged(null)),
          for (final (value, label) in options)
            ChoiceChip(label: Text(label), selected: selected == value, onSelected: (_) => onChanged(value)),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final canAct = ref.watch(myStaffRoleProvider).value?.canSuspend ?? false;
    return AdminPage(
      title: 'Şikayetler',
      subtitle: 'Platform genelindeki şikayetler ve sahibin taraf olduğu dosyaların itirazları.',
      actions: [
        GxButton(
          label: 'Yenile',
          icon: Icons.refresh,
          variant: GxButtonVariant.secondary,
          onPressed: () => ref
            ..invalidate(adminReportSearchProvider)
            ..invalidate(adminAppealSearchProvider),
        ),
      ],
      children: [
        GxPanel(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(GxSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SegmentedButton<_View>(
                      segments: const [
                        ButtonSegment(value: _View.reports, label: Text('Şikayetler'), icon: Icon(Icons.flag_outlined)),
                        ButtonSegment(value: _View.appeals, label: Text('İtirazlar'), icon: Icon(Icons.record_voice_over_outlined)),
                      ],
                      selected: {_view},
                      onSelectionChanged: (v) => setState(() {
                        _view = v.single;
                        _page = 1;
                      }),
                    ),
                    const SizedBox(height: GxSpacing.sm),
                    if (_view == _View.reports) ...[
                      _chips([for (final s in AdminReportStatus.values) (s, s.label)], _status, (s) => setState(() {
                            _status = s;
                            _page = 1;
                          })),
                      const SizedBox(height: GxSpacing.xs),
                      _chips([for (final s in AdminReportScope.values) (s, s.label)], _scope, (s) => setState(() {
                            _scope = s;
                            _page = 1;
                          }), allLabel: 'Her kapsam'),
                    ] else
                      _chips([for (final s in AdminAppealStatus.values) (s, s.label)], _appealStatus, (s) => setState(() {
                            _appealStatus = s;
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
              else
                _AppealList(
                  search: (status: _appealStatus, page: _page),
                  canAct: canAct,
                  onPage: (p) => setState(() => _page = p),
                  onDecide: _decide,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget _loading() => const Padding(
      padding: EdgeInsets.all(GxSpacing.lg),
      child: Column(children: [GxSkeleton(height: GxSpacing.xl), SizedBox(height: GxSpacing.md), GxSkeleton(height: GxSpacing.xl)]),
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
            padding: const EdgeInsets.symmetric(vertical: GxSpacing.xl),
            child: GxEmptyState(
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
            padding: const EdgeInsets.symmetric(vertical: GxSpacing.xl),
            child: GxErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(adminReportSearchProvider(search))),
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
    final secondary = textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary);
    final location = _location;
    final meta = [
      r.groupName == null ? 'Platform' : '${r.groupName} (@${r.groupHandle})',
      if (r.reporterUsername != null) 'Şikayet eden @${r.reporterUsername}',
      if (r.subjectUsername != null) 'Hedef @${r.subjectUsername}',
      formatDateTimeTr(r.createdAt),
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GxSpacing.lg, vertical: GxSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: GxSpacing.xs,
            runSpacing: GxSpacing.xs,
            children: [
              GxBadge(r.targetLabel, tone: GxBadgeTone.info),
              GxBadge(r.reasonLabel, tone: GxBadgeTone.warning),
              if (r.status == AdminReportStatus.open && r.openCount > 1) GxBadge('${r.openCount} açık şikayet', tone: GxBadgeTone.danger),
              if (r.status != AdminReportStatus.open) GxBadge(r.status.label),
            ],
          ),
          const SizedBox(height: GxSpacing.xs),
          if (r.excerpt.isNotEmpty) Text(r.excerpt, maxLines: 3, overflow: TextOverflow.ellipsis, style: textTheme.bodyLarge),
          if (r.note case final note?) Text('“$note”', style: secondary?.copyWith(fontStyle: FontStyle.italic)),
          Text(meta, style: secondary),
          const SizedBox(height: GxSpacing.xs),
          Wrap(
            spacing: GxSpacing.xs,
            runSpacing: GxSpacing.xs,
            children: [
              if (location != null)
                GxButton(label: 'Görüntüle', icon: Icons.open_in_new, variant: GxButtonVariant.text, onPressed: () => context.go(location)),
              if (canAct && r.status == AdminReportStatus.open) ...[
                GxButton(label: 'Reddet', variant: GxButtonVariant.secondary, onPressed: () => onReview(r, actioned: false)),
                GxButton(label: 'İşlem yapıldı', icon: Icons.check, onPressed: () => onReview(r, actioned: true)),
              ],
            ],
          ),
        ],
      ),
    );
  }
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
    final secondary = textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary);
    return switch (ref.watch(adminAppealSearchProvider(search))) {
      AsyncData(:final value) when value.items.isEmpty => Padding(
          padding: const EdgeInsets.symmetric(vertical: GxSpacing.xl),
          child: GxEmptyState(
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
                padding: const EdgeInsets.symmetric(horizontal: GxSpacing.lg, vertical: GxSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: GxSpacing.xs,
                      children: [
                        GxBadge(a.sanctionLabel, tone: GxBadgeTone.danger),
                        GxBadge(a.status.label, tone: a.status == AdminAppealStatus.pending ? GxBadgeTone.warning : GxBadgeTone.neutral),
                      ],
                    ),
                    const SizedBox(height: GxSpacing.xs),
                    Text('@${a.username ?? 'silinmiş hesap'} · ${a.groupName} (@${a.groupHandle})', style: textTheme.labelLarge),
                    Text('Kurulun gerekçesi: ${a.caseReason}', style: secondary),
                    const SizedBox(height: GxSpacing.xxs),
                    Text('İtiraz: ${a.body}', style: textTheme.bodyLarge),
                    if (a.decisionNote case final note?) Text('Karar notu: $note', style: secondary),
                    Text(formatDateTimeTr(a.createdAt), style: secondary),
                    const SizedBox(height: GxSpacing.xs),
                    Wrap(
                      spacing: GxSpacing.xs,
                      runSpacing: GxSpacing.xs,
                      children: [
                        GxButton(
                          label: 'Kullanıcı',
                          icon: Icons.open_in_new,
                          variant: GxButtonVariant.text,
                          onPressed: () => context.go(AdminRoutes.user(a.userId)),
                        ),
                        if (canAct && a.status == AdminAppealStatus.pending) ...[
                          GxButton(label: 'Sürsün', variant: GxButtonVariant.secondary, onPressed: () => onDecide(a, overturn: false)),
                          GxButton(label: 'Yaptırımı kaldır', onPressed: () => onDecide(a, overturn: true)),
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
          padding: const EdgeInsets.symmetric(vertical: GxSpacing.xl),
          child: GxErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(adminAppealSearchProvider(search))),
        ),
      _ => _loading(),
    };
  }
}
