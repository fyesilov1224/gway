import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/admin_group.dart';
import 'admin_shell.dart';
import 'providers.dart';
import 'routes.dart';
import 'widgets.dart';

const joinPolicyLabels = {'open': 'Serbest', 'request': 'İstekle', 'invite': 'Davetle'};

const groupRoleLabels = {
  'owner': 'Grup Sahibi',
  'admin': 'Yönetici',
  'discipline': 'Disiplin Kurulu',
  'moderator': 'Moderatör',
};

class GroupStatusBadge extends StatelessWidget {
  const GroupStatusBadge(this.status, {super.key});

  final AdminGroupStatus status;

  @override
  Widget build(BuildContext context) => GwBadge(
        status.label,
        tone: status == AdminGroupStatus.active ? GwBadgeTone.primary : GwBadgeTone.danger,
        dot: true,
      );
}

/// Summary counters, search, status filter and a paginated group table.
class AdminGroupsScreen extends ConsumerStatefulWidget {
  const AdminGroupsScreen({super.key});

  @override
  ConsumerState<AdminGroupsScreen> createState() => _AdminGroupsScreenState();
}

class _AdminGroupsScreenState extends ConsumerState<AdminGroupsScreen> {
  final _search = TextEditingController();
  Timer? _debounce;
  String _query = '';
  AdminGroupStatus? _status;
  int _page = 1;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      setState(() {
        _query = value.trim();
        _page = 1;
      });
    });
  }

  void _setStatus(AdminGroupStatus? status) => setState(() {
        _status = status;
        _page = 1;
      });

  void _clearFilters() {
    _search.clear();
    _debounce?.cancel();
    setState(() {
      _query = '';
      _status = null;
      _page = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final key = (query: _query, status: _status, page: _page);
    final result = ref.watch(groupSearchProvider(key));
    final stats = ref.watch(groupStatsProvider).value;
    final filtered = _query.isNotEmpty || _status != null;

    return AdminPage(
      title: 'Gruplar',
      subtitle: 'Platformdaki grupları görüntüle, ara ve gerekirse askıya al.',
      actions: [
        GwButton(
          label: 'Yenile',
          icon: Icons.refresh,
          variant: GwButtonVariant.secondary,
          onPressed: () => ref
            ..invalidate(groupStatsProvider)
            ..invalidate(groupSearchProvider),
        ),
      ],
      children: [
        StatCardRow(
          cards: [
            for (final (status, label, value, icon, tone) in [
              (null, 'Toplam grup', stats?.total, Icons.groups_2_outlined, GwBadgeTone.info),
              (AdminGroupStatus.active, 'Aktif', stats?.active, Icons.check_circle_outline, GwBadgeTone.primary),
              (AdminGroupStatus.suspended, 'Askıda', stats?.suspended, Icons.block, GwBadgeTone.danger),
            ])
              StatCard(
                label: label,
                value: value,
                icon: icon,
                tone: tone,
                selected: _status == status,
                onTap: () => _setStatus(status),
              ),
          ],
        ),
        const SizedBox(height: GwSpacing.lg),
        GwPanel(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListToolbar<AdminGroupStatus>(
                controller: _search,
                hint: 'Grup adı veya adresi ile ara',
                query: _query,
                filters: [for (final s in AdminGroupStatus.values) (s, s.label)],
                selected: _status,
                onSearchChanged: _onSearchChanged,
                onFilterChanged: _setStatus,
                onClear: _clearFilters,
              ),
              const Divider(),
              switch (result) {
                AsyncData(:final value) when value.items.isEmpty => Padding(
                    padding: const EdgeInsets.symmetric(vertical: GwSpacing.xl),
                    child: filtered
                        ? GwEmptyState(
                            icon: Icons.search_off,
                            message: 'Aramana ve filtrene uygun grup bulunamadı.',
                            actionLabel: 'Filtreleri temizle',
                            onAction: _clearFilters,
                          )
                        : GwEmptyState(
                            icon: Icons.groups_2_outlined,
                            message: 'Henüz oluşturulmuş grup yok.',
                            actionLabel: 'Yenile',
                            onAction: () => ref.invalidate(groupSearchProvider(key)),
                          ),
                  ),
                AsyncData(:final value) => _GroupTable(page: value, onPage: (p) => setState(() => _page = p)),
                AsyncError(:final error) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: GwSpacing.xl),
                    child: GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(groupSearchProvider(key))),
                  ),
                _ => const Padding(
                    padding: EdgeInsets.all(GwSpacing.lg),
                    child: Column(
                      children: [
                        GwSkeleton(height: GwSpacing.xl),
                        SizedBox(height: GwSpacing.md),
                        GwSkeleton(height: GwSpacing.xl),
                        SizedBox(height: GwSpacing.md),
                        GwSkeleton(height: GwSpacing.xl),
                      ],
                    ),
                  ),
              },
            ],
          ),
        ),
      ],
    );
  }
}

/// Column flex values of the wide table.
const _columns = [4, 3, 2, 1, 2, 2];

class _GroupTable extends StatelessWidget {
  const _GroupTable({required this.page, required this.onPage});

  final GroupPage page;
  final ValueChanged<int> onPage;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final (from, to) = page.range;
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= GwLayout.contentMaxWidth;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (wide) ...[
              Container(
                color: GwColors.surface,
                padding: const EdgeInsets.symmetric(horizontal: GwSpacing.lg, vertical: GwSpacing.sm),
                child: Row(
                  children: [
                    for (final (i, label) in ['GRUP', 'SAHİBİ', 'KATEGORİ', 'ÜYE', 'DURUM', 'KURULUŞ'].indexed)
                      Expanded(
                        flex: _columns[i],
                        child: Text(
                          label,
                          style: textTheme.labelMedium?.copyWith(color: GwColors.textSecondary, letterSpacing: 0.6),
                        ),
                      ),
                    const SizedBox(width: GwSpacing.lg),
                  ],
                ),
              ),
              const Divider(),
            ],
            for (final group in page.items) ...[
              _GroupRow(group: group, wide: wide),
              const Divider(),
            ],
            PageFooter(
              from: from,
              to: to,
              total: page.total,
              noun: 'grup',
              page: page.page,
              pageCount: page.pageCount,
              onPage: onPage,
            ),
          ],
        );
      },
    );
  }
}

class _GroupRow extends ConsumerWidget {
  const _GroupRow({required this.group, required this.wide});

  final AdminGroupSummary group;
  final bool wide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final secondary = textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary);
    final categories = {for (final c in ref.watch(categoriesProvider).value ?? const <Category>[]) c.slug: c.name};
    final owner = group.ownerUsername == null ? '—' : '@${group.ownerUsername}';
    final identity = Row(
      children: [
        GwAvatar(name: group.name, shape: GwAvatarShape.group, imageUrl: ref.watch(groupLogoUrlProvider(group.logoPath))),
        const SizedBox(width: GwSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(group.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.labelLarge),
              Text('@${group.handle}', maxLines: 1, overflow: TextOverflow.ellipsis, style: secondary),
              if (!wide) Text('$owner · ${group.memberCount} üye', maxLines: 1, overflow: TextOverflow.ellipsis, style: secondary),
            ],
          ),
        ),
      ],
    );

    return InkWell(
      onTap: () => context.go(AdminRoutes.group(group.id)),
      hoverColor: GwColors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: GwSpacing.lg, vertical: GwSpacing.sm),
        child: wide
            ? Row(
                children: [
                  Expanded(flex: _columns[0], child: identity),
                  Expanded(flex: _columns[1], child: Text(owner, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.bodyMedium)),
                  Expanded(flex: _columns[2], child: Text(categories[group.categorySlug] ?? group.categorySlug, style: secondary)),
                  Expanded(flex: _columns[3], child: Text('${group.memberCount}', style: textTheme.bodyMedium)),
                  Expanded(flex: _columns[4], child: Align(alignment: Alignment.centerLeft, child: GroupStatusBadge(group.status))),
                  Expanded(flex: _columns[5], child: Text(formatDate(group.createdAt), style: secondary)),
                  const Icon(Icons.chevron_right, color: GwColors.textSecondary, size: GwSpacing.lg),
                ],
              )
            : Row(
                children: [
                  Expanded(child: identity),
                  const SizedBox(width: GwSpacing.sm),
                  GroupStatusBadge(group.status),
                ],
              ),
      ),
    );
  }
}
