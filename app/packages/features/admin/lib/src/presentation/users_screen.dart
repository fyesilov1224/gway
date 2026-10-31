import 'dart:async';

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
import 'widgets.dart';

/// Summary counters, search, status filter and a paginated user table.
class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  final _search = TextEditingController();
  Timer? _debounce;
  String _query = '';
  AdminAccountStatus? _status;
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

  void _setStatus(AdminAccountStatus? status) => setState(() {
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
    final result = ref.watch(userSearchProvider(key));
    final filtered = _query.isNotEmpty || _status != null;

    return AdminPage(
      title: 'Kullanıcılar',
      subtitle: 'Platformdaki hesapları görüntüle, ara ve yönet.',
      actions: [
        GwButton(
          label: 'Yenile',
          icon: Icons.refresh,
          variant: GwButtonVariant.secondary,
          onPressed: () => ref
            ..invalidate(userStatsProvider)
            ..invalidate(userSearchProvider),
        ),
      ],
      children: [
        _StatsRow(selected: _status, onSelect: _setStatus),
        const SizedBox(height: GwSpacing.lg),
        GwPanel(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListToolbar<AdminAccountStatus>(
                controller: _search,
                hint: 'E-posta, kullanıcı adı veya ad ile ara',
                query: _query,
                filters: [for (final s in AdminAccountStatus.values) (s, s.label)],
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
                            message: 'Aramana ve filtrene uygun kullanıcı bulunamadı.',
                            actionLabel: 'Filtreleri temizle',
                            onAction: _clearFilters,
                          )
                        : GwEmptyState(
                            icon: Icons.people_outline,
                            message: 'Henüz kayıtlı kullanıcı yok.',
                            actionLabel: 'Yenile',
                            onAction: () => ref.invalidate(userSearchProvider(key)),
                          ),
                  ),
                AsyncData(:final value) => _UserTable(page: value, onPage: (p) => setState(() => _page = p)),
                AsyncError(:final error) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: GwSpacing.xl),
                    child: GwErrorState(
                      message: userMessageOf(error),
                      onRetry: () => ref.invalidate(userSearchProvider(key)),
                    ),
                  ),
                _ => const _TableSkeleton(),
              },
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _StatsRow extends ConsumerWidget {
  const _StatsRow({required this.selected, required this.onSelect});

  final AdminAccountStatus? selected;
  final ValueChanged<AdminAccountStatus?> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(userStatsProvider).value;
    final cards = [
      (null, 'Toplam kullanıcı', stats?.total, Icons.group_outlined, GwBadgeTone.info),
      (AdminAccountStatus.active, 'Aktif', stats?.active, Icons.check_circle_outline, GwBadgeTone.primary),
      (AdminAccountStatus.suspended, 'Askıda', stats?.suspended, Icons.block, GwBadgeTone.danger),
      (AdminAccountStatus.pendingDeletion, 'Silinecek', stats?.pendingDeletion, Icons.schedule, GwBadgeTone.neutral),
    ];
    return StatCardRow(
      cards: [
        for (final (status, label, value, icon, tone) in cards)
          StatCard(
            label: label,
            value: value,
            icon: icon,
            tone: tone,
            selected: selected == status,
            onTap: () => onSelect(status),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------

/// Column flex values of the wide table.
const _columns = [4, 3, 2, 2, 2];

class _UserTable extends StatelessWidget {
  const _UserTable({required this.page, required this.onPage});

  final UserPage page;
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
            if (wide)
              Container(
                color: GwColors.surface,
                padding: const EdgeInsets.symmetric(horizontal: GwSpacing.lg, vertical: GwSpacing.sm),
                child: Row(
                  children: [
                    for (final (i, label) in ['KULLANICI', 'E-POSTA', 'DURUM', 'ROL', 'KAYIT TARİHİ'].indexed)
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
            if (wide) const Divider(),
            for (final user in page.items) ...[
              _UserRow(user: user, wide: wide),
              const Divider(),
            ],
            PageFooter(
              from: from,
              to: to,
              total: page.total,
              noun: 'kullanıcı',
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

class _UserRow extends ConsumerWidget {
  const _UserRow({required this.user, required this.wide});

  final AdminUserSummary user;
  final bool wide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final secondary = textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary);
    final identity = Row(
      children: [
        GwAvatar(name: user.title, shape: GwAvatarShape.user, imageUrl: ref.watch(avatarUrlProvider(user.avatarPath))),
        const SizedBox(width: GwSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.labelLarge),
              Text(
                user.username == null ? 'Profil oluşturulmadı' : '@${user.username}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: secondary,
              ),
              if (!wide && user.email != null)
                Text(user.email!, maxLines: 1, overflow: TextOverflow.ellipsis, style: secondary),
            ],
          ),
        ),
      ],
    );

    return InkWell(
      onTap: () => context.go(AdminRoutes.user(user.id)),
      hoverColor: GwColors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: GwSpacing.lg, vertical: GwSpacing.sm),
        child: wide
            ? Row(
                children: [
                  Expanded(flex: _columns[0], child: identity),
                  Expanded(
                    flex: _columns[1],
                    child: Text(user.email ?? '—', maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.bodyMedium),
                  ),
                  Expanded(flex: _columns[2], child: Align(alignment: Alignment.centerLeft, child: StatusBadge(user.status, banned: user.isBanned))),
                  Expanded(
                    flex: _columns[3],
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: user.staffRole == null ? Text('—', style: secondary) : RoleBadge(user.staffRole!),
                    ),
                  ),
                  Expanded(
                    flex: _columns[4],
                    child: Text(user.createdAt == null ? '—' : formatDateTr(user.createdAt!), style: secondary),
                  ),
                  const Icon(Icons.chevron_right, color: GwColors.textSecondary, size: GwSpacing.lg),
                ],
              )
            : Row(
                children: [
                  Expanded(child: identity),
                  const SizedBox(width: GwSpacing.sm),
                  StatusBadge(user.status, banned: user.isBanned),
                ],
              ),
      ),
    );
  }
}

class _TableSkeleton extends StatelessWidget {
  const _TableSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < 6; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: GwSpacing.lg, vertical: GwSpacing.sm),
            child: Row(
              children: [
                GwSkeleton.circle(size: GwAvatarSize.md.dimension),
                const SizedBox(width: GwSpacing.sm),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GwSkeleton(width: GwSpacing.xxl * 3, height: GwSpacing.md),
                      SizedBox(height: GwSpacing.xs),
                      GwSkeleton(width: GwSpacing.xxl * 2, height: GwSpacing.sm),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
