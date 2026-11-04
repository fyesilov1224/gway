import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/admin_events.dart';
import 'admin_shell.dart';
import 'providers.dart';
import 'routes.dart';

/// The groups league (docs/ARCHITECTURE.md §3d, Gruplar Ligi): a month's leagues, a league's table, and taking a group
/// out of an open season.
class AdminLeaguesScreen extends ConsumerStatefulWidget {
  const AdminLeaguesScreen({super.key});

  @override
  ConsumerState<AdminLeaguesScreen> createState() => _AdminLeaguesScreenState();
}

class _AdminLeaguesScreenState extends ConsumerState<AdminLeaguesScreen> {
  static final _thisMonth = DateTime(DateTime.now().year, DateTime.now().month);

  DateTime _month = _thisMonth;
  AdminLeague? _league;

  List<DateTime> get _months => [for (var i = 0; i < 6; i++) DateTime(_thisMonth.year, _thisMonth.month - i)];

  String _name(AdminLeague l) => '${turkishProvinces[l.province - 1]} · ${l.categoryName}';

  void _snack(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  void _refresh() => ref
    ..invalidate(adminLeaguesProvider)
    ..invalidate(adminLeagueTableProvider);

  Future<void> _exclude(AdminLeagueRow row) async {
    final reason = await showDialog<String>(context: context, builder: (_) => _ReasonDialog(groupName: row.groupName));
    if (reason == null || !mounted) return;
    final result = await ref.read(adminEventsRepositoryProvider).excludeFromLeague(_month, row.groupId, reason: reason);
    if (!mounted) return;
    _snack(switch (result) {
      Ok() => '${row.groupName} bu ayın liginden çıkarıldı. İşlem kayda geçti.',
      Err(:final failure) => failure.userMessage,
    });
    _refresh();
  }

  Future<void> _restore(AdminLeagueExclusion x) async {
    final result = await ref.read(adminEventsRepositoryProvider).restoreToLeague(_month, x.groupId);
    if (!mounted) return;
    _snack(switch (result) {
      Ok() => '${x.groupName} lige geri alındı.',
      Err(:final failure) => failure.userMessage,
    });
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final secondary = textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary);
    final canExclude = ref.watch(myStaffRoleProvider).value?.canSuspend ?? false;
    final leagues = ref.watch(adminLeaguesProvider(_month));
    final selected = _league;

    return AdminPage(
      title: 'Ligler',
      subtitle: 'Aynı il ve kategorideki grupların aylık sıralaması. Kurala aykırı bir grubu (ör. sahte katılım) '
          'sezon kapanmadan ligden çıkarabilirsin.',
      actions: [GwButton(label: 'Yenile', icon: Icons.refresh, variant: GwButtonVariant.secondary, onPressed: _refresh)],
      children: [
        Wrap(
          spacing: GwSpacing.xs,
          runSpacing: GwSpacing.xs,
          children: [
            for (final m in _months)
              ChoiceChip(
                label: Text(formatMonthYear(m)),
                selected: _month == m,
                onSelected: (_) => setState(() {
                  _month = m;
                  _league = null;
                }),
              ),
          ],
        ),
        const SizedBox(height: GwSpacing.md),
        GwPanel(
          title: 'Ligler',
          subtitle: switch (leagues.value) {
            final v? when v.finalized => '${formatMonthYear(v.month)} sezonu kapandı; sonuçlar kesin.',
            _ => 'Sezon sürüyor; puanlar organizasyonlar bittikçe güncellenir.',
          },
          padding: EdgeInsets.zero,
          child: switch (leagues) {
            AsyncData(:final value) when value.leagues.isEmpty => Padding(
                padding: const EdgeInsets.symmetric(vertical: GwSpacing.xl),
                child: GwEmptyState(
                  icon: Icons.emoji_events_outlined,
                  message: 'Bu ay puan alan grup yok.',
                  actionLabel: 'Yenile',
                  onAction: _refresh,
                ),
              ),
            AsyncData(:final value) => Column(
                children: [
                  for (final l in value.leagues)
                    ListTile(
                      selected: selected?.category == l.category && selected?.province == l.province,
                      leading: const Icon(Icons.emoji_events_outlined),
                      title: Text(_name(l)),
                      subtitle: Text('${formatCount(l.groups)} grup · lider ${l.leaderName} (${formatCount(l.leaderPoints)} puan)'),
                      trailing: l.excluded > 0 ? GwBadge('${l.excluded} çıkarılan', tone: GwBadgeTone.danger) : null,
                      onTap: () => setState(() => _league = l),
                    ),
                ],
              ),
            AsyncError(:final error) => Padding(
                padding: const EdgeInsets.all(GwSpacing.lg),
                child: GwErrorState(message: userMessageOf(error), onRetry: _refresh),
              ),
            _ => const Padding(padding: EdgeInsets.all(GwSpacing.lg), child: GwSkeleton(height: GwSpacing.xl)),
          },
        ),
        if (selected != null) ...[
          const SizedBox(height: GwSpacing.md),
          switch (ref.watch(adminLeagueTableProvider((month: _month, category: selected.category, province: selected.province)))) {
            AsyncData(:final value) => GwPanel(
                title: _name(selected),
                subtitle: '${formatMonthYear(_month)} sıralaması',
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final r in value.rows)
                      ListTile(
                        leading: Text('${r.rank}.', style: textTheme.titleMedium),
                        title: Text('${r.groupName} (@${r.groupHandle})'),
                        subtitle: Text(r.breakdown, style: secondary),
                        onTap: () => context.go(AdminRoutes.group(r.groupId)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${formatCount(r.points)} puan', style: textTheme.labelLarge),
                            if (canExclude && !value.finalized) ...[
                              const SizedBox(width: GwSpacing.sm),
                              GwButton(label: 'Ligden çıkar', variant: GwButtonVariant.secondary, onPressed: () => _exclude(r)),
                            ],
                          ],
                        ),
                      ),
                    if (value.exclusions.isNotEmpty) ...[
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(GwSpacing.lg, GwSpacing.sm, GwSpacing.lg, 0),
                        child: Text('Ligden çıkarılanlar', style: textTheme.titleSmall),
                      ),
                      for (final x in value.exclusions)
                        ListTile(
                          leading: const Icon(Icons.block, color: GwColors.error),
                          title: Text('${x.groupName} (@${x.groupHandle})'),
                          subtitle: Text(
                            '${x.reason} · ${x.by == null ? '' : '@${x.by} · '}${formatDateTime(x.createdAt.toLocal())}',
                            style: secondary,
                          ),
                          trailing: canExclude && !value.finalized
                              ? GwButton(label: 'Geri al', variant: GwButtonVariant.text, onPressed: () => _restore(x))
                              : null,
                        ),
                    ],
                  ],
                ),
              ),
            AsyncError(:final error) => GwErrorState(message: userMessageOf(error), onRetry: _refresh),
            _ => const GwSkeleton(height: GwSpacing.xxl * 2),
          },
        ],
      ],
    );
  }
}

class _ReasonDialog extends StatefulWidget {
  const _ReasonDialog({required this.groupName});

  final String groupName;

  @override
  State<_ReasonDialog> createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<_ReasonDialog> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ok = _reason.text.trim().length >= 3;
    return AlertDialog(
      title: Text('${widget.groupName} ligden çıkarılsın mı?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Grup bu ayın sıralamasında görünmez. Sezon kapanana kadar geri alınabilir; işlem kayda geçer.'),
          const SizedBox(height: GwSpacing.sm),
          TextField(
            controller: _reason,
            autofocus: true,
            maxLength: 500,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(labelText: 'Gerekçe', hintText: 'Ör. Sahte katılım kaydı'),
          ),
        ],
      ),
      actions: [
        GwButton(label: 'Vazgeç', variant: GwButtonVariant.text, onPressed: () => Navigator.of(context).pop()),
        GwButton(label: 'Ligden çıkar', onPressed: ok ? () => Navigator.of(context).pop(_reason.text.trim()) : null),
      ],
    );
  }
}
