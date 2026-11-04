import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/admin_user.dart';
import 'admin_shell.dart';
import 'live_refresh.dart';
import 'providers.dart';
import 'routes.dart';
import 'widgets.dart';

/// Everyone with the app open right now, each with a green dot (docs/ARCHITECTURE.md §8b, Canlı kullanıcılar):
/// counts by platform, search, platform filter and a paginated list that refreshes itself every few seconds.
class LiveUsersScreen extends ConsumerStatefulWidget {
  const LiveUsersScreen({super.key});

  @override
  ConsumerState<LiveUsersScreen> createState() => _LiveUsersScreenState();
}

class _LiveUsersScreenState extends ConsumerState<LiveUsersScreen> {
  final _search = TextEditingController();
  Timer? _debounce;
  String _query = '';
  AdminPlatform? _platform;
  int _page = 1;

  /// The last page shown: a refresh or a new search keeps it on screen instead of a skeleton.
  AdminOnlinePage? _shown;

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

  void _setPlatform(AdminPlatform? platform) => setState(() {
        _platform = platform;
        _page = 1;
      });

  void _clearFilters() {
    _search.clear();
    _debounce?.cancel();
    setState(() {
      _query = '';
      _platform = null;
      _page = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final key = (query: _query, platform: _platform, page: _page);
    final result = ref.watch(onlineUsersProvider(key));
    if (result.value case final page?) _shown = page;
    final shown = _shown;
    final filtered = _query.isNotEmpty || _platform != null;

    return AdminPage(
      title: 'Canlı kullanıcılar',
      subtitle: 'Uygulamayı şu anda açık tutan kişiler. Liste ${onlineRefreshInterval.inSeconds} saniyede bir kendiliğinden yenilenir.',
      actions: [
        const _LivePill(),
        GwButton(
          label: 'Yenile',
          icon: Icons.refresh,
          variant: GwButtonVariant.secondary,
          onPressed: () => ref.invalidate(onlineUsersProvider),
        ),
      ],
      children: [
        StatCardRow(
          cards: [
            StatCard(
              label: 'Şu an çevrimiçi',
              value: shown?.online,
              icon: Icons.wifi_tethering,
              tone: GwBadgeTone.success,
              selected: _platform == null,
              onTap: () => _setPlatform(null),
            ),
            for (final p in AdminPlatform.values)
              StatCard(
                label: p.label,
                value: shown?.count(p),
                icon: switch (p) {
                  AdminPlatform.android => Icons.android,
                  AdminPlatform.ios => Icons.phone_iphone,
                  AdminPlatform.web => Icons.language,
                },
                tone: GwBadgeTone.info,
                selected: _platform == p,
                onTap: () => _setPlatform(p),
              ),
          ],
        ),
        const SizedBox(height: GwSpacing.lg),
        GwPanel(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListToolbar<AdminPlatform>(
                controller: _search,
                hint: 'Ad, kullanıcı adı veya e-posta ile ara',
                query: _query,
                filters: [for (final p in AdminPlatform.values) (p, p.label)],
                selected: _platform,
                onSearchChanged: _onSearchChanged,
                onFilterChanged: _setPlatform,
                onClear: _clearFilters,
              ),
              const Divider(),
              switch ((result, shown)) {
                (AsyncError(:final error), null) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: GwSpacing.xl),
                    child: GwErrorState(
                      message: userMessageOf(error),
                      onRetry: () => ref.invalidate(onlineUsersProvider(key)),
                    ),
                  ),
                (_, null) => const _ListSkeleton(),
                (_, final page?) when page.users.items.isEmpty => Padding(
                    padding: const EdgeInsets.symmetric(vertical: GwSpacing.xl),
                    child: filtered
                        ? GwEmptyState(
                            icon: Icons.search_off,
                            message: 'Aramana ve filtrene uygun çevrimiçi kullanıcı yok.',
                            actionLabel: 'Filtreleri temizle',
                            onAction: _clearFilters,
                          )
                        : GwEmptyState(
                            icon: Icons.wifi_tethering_off,
                            message: 'Şu anda uygulamayı kullanan kimse yok.',
                            actionLabel: 'Yenile',
                            onAction: () => ref.invalidate(onlineUsersProvider(key)),
                          ),
                  ),
                (_, final page?) => _OnlineTable(page: page.users, onPage: (p) => setState(() => _page = p)),
              },
            ],
          ),
        ),
      ],
    );
  }
}

/// "Canlı" with a green dot: the list keeps itself up to date.
class _LivePill extends StatelessWidget {
  const _LivePill();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: GwSpacing.sm, vertical: GwSpacing.xs),
        decoration: const BoxDecoration(color: GwColors.successSoft, borderRadius: GwRadius.lgAll),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const OnlineDot(),
            const SizedBox(width: GwSpacing.xs),
            Text('Canlı', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: GwColors.success)),
          ],
        ),
      );
}

/// The green dot in front of someone who is online.
class OnlineDot extends StatelessWidget {
  const OnlineDot({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Çevrimiçi',
        child: Container(
          width: GwSpacing.sm,
          height: GwSpacing.sm,
          decoration: BoxDecoration(
            color: GwColors.success,
            shape: BoxShape.circle,
            border: Border.all(color: GwColors.successSoft, width: GwSpacing.xxs / 2),
          ),
        ),
      );
}

/// "2 sa 5 dk", "12 dk", "40 sn": how long someone has been online.
String formatOnlineFor(Duration d) {
  final s = d.isNegative ? Duration.zero : d;
  if (s.inHours > 0) return '${s.inHours} sa ${s.inMinutes % 60} dk';
  if (s.inMinutes > 0) return '${s.inMinutes} dk';
  return '${s.inSeconds} sn';
}

/// "şimdi", "20 sn önce", "1 dk önce": when the last beat arrived.
String formatLastSeen(Duration d) {
  final s = d.isNegative ? Duration.zero : d;
  if (s.inSeconds < 5) return 'şimdi';
  if (s.inMinutes < 1) return '${s.inSeconds} sn önce';
  return '${s.inMinutes} dk önce';
}

/// Column flex values of the wide table.
const _columns = [4, 3, 2, 2, 2];

class _OnlineTable extends StatelessWidget {
  const _OnlineTable({required this.page, required this.onPage});

  final PagedList<AdminOnlineUser> page;
  final ValueChanged<int> onPage;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final (from, to) = page.range;
    final now = DateTime.now();
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
                    for (final (i, label) in ['KULLANICI', 'E-POSTA', 'PLATFORM', 'ÇEVRİMİÇİ', 'SON SİNYAL'].indexed)
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
            for (final user in page.items) ...[
              _OnlineRow(user: user, wide: wide, now: now),
              const Divider(),
            ],
            PageFooter(
              from: from,
              to: to,
              total: page.total,
              noun: 'kişi',
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

class _OnlineRow extends ConsumerWidget {
  const _OnlineRow({required this.user, required this.wide, required this.now});

  final AdminOnlineUser user;
  final bool wide;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final secondary = textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary);
    final onlineFor = formatOnlineFor(now.difference(user.onlineSince));
    final lastSeen = formatLastSeen(now.difference(user.lastSeenAt));
    final identity = Row(
      children: [
        const OnlineDot(),
        const SizedBox(width: GwSpacing.sm),
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
              if (!wide)
                Text('${user.platform.label} · $onlineFor çevrimiçi', maxLines: 1, overflow: TextOverflow.ellipsis, style: secondary),
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
                  Expanded(
                    flex: _columns[2],
                    child: Align(alignment: Alignment.centerLeft, child: GwBadge(user.platform.label, tone: GwBadgeTone.info)),
                  ),
                  Expanded(flex: _columns[3], child: Text(onlineFor, style: textTheme.bodyMedium)),
                  Expanded(flex: _columns[4], child: Text(lastSeen, style: secondary)),
                  const Icon(Icons.chevron_right, color: GwColors.textSecondary, size: GwSpacing.lg),
                ],
              )
            : Row(
                children: [
                  Expanded(child: identity),
                  const SizedBox(width: GwSpacing.sm),
                  Text(lastSeen, style: secondary),
                ],
              ),
      ),
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) => Column(
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
