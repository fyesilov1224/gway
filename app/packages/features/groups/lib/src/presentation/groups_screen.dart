import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/group.dart';
import 'providers.dart';
import 'routes.dart';
import 'widgets.dart';

enum _Tab { discover, mine }

/// Discover groups (search, category filter) and the user's own groups.
/// Pending invitations are shown above both.
class GroupsScreen extends ConsumerStatefulWidget {
  const GroupsScreen({super.key, this.actions = const []});

  /// Extra app bar actions the app supplies (e.g. the map), before "Grup oluştur".
  final List<Widget> actions;

  static const pageSize = 30;

  @override
  ConsumerState<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends ConsumerState<GroupsScreen> {
  final _search = TextEditingController();
  Timer? _debounce;
  _Tab _tab = _Tab.discover;
  String _query = '';
  String? _category;
  int _limit = GroupsScreen.pageSize;

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
        _limit = GroupsScreen.pageSize;
      });
    });
  }

  void _clearFilters() {
    _search.clear();
    _debounce?.cancel();
    setState(() {
      _query = '';
      _category = null;
      _limit = GroupsScreen.pageSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserIdProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gruplar'),
        actions: [
          ...widget.actions,
          Padding(
            padding: const EdgeInsets.only(right: GxSpacing.sm),
            child: GxButton(label: 'Grup oluştur', icon: Icons.add, onPressed: () => context.push(GroupRoutes.create)),
          ),
        ],
      ),
      body: GxReadingColumn(
        child: RefreshIndicator(
          onRefresh: () async {
            ref
              ..invalidate(discoverGroupsProvider)
              ..invalidate(userGroupsProvider)
              ..invalidate(myInvitationsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.only(bottom: GxSpacing.xl),
            children: [
              const _InvitationsPanel(),
              Padding(
                padding: const EdgeInsets.fromLTRB(GxSpacing.md, GxSpacing.md, GxSpacing.md, GxSpacing.xs),
                child: SegmentedButton<_Tab>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: _Tab.discover, label: Text('Keşfet'), icon: Icon(Icons.explore_outlined)),
                    ButtonSegment(value: _Tab.mine, label: Text('Gruplarım'), icon: Icon(Icons.groups_outlined)),
                  ],
                  selected: {_tab},
                  onSelectionChanged: (s) => setState(() => _tab = s.first),
                ),
              ),
              if (_tab == _Tab.discover) ..._discover() else if (userId != null) _MyGroups(userId: userId, onDiscover: () => setState(() => _tab = _Tab.discover)),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _discover() {
    final key = (query: _query, category: _category, limit: _limit);
    final result = ref.watch(discoverGroupsProvider(key));
    final categories = ref.watch(categoriesProvider).value ?? const <Category>[];
    final filtered = _query.isNotEmpty || _category != null;

    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(GxSpacing.md, GxSpacing.sm, GxSpacing.md, GxSpacing.xs),
        child: TextField(
          controller: _search,
          onChanged: _onSearchChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Grup adı veya adresi ile ara',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(tooltip: 'Aramayı temizle', icon: const Icon(Icons.close), onPressed: _clearFilters),
          ),
        ),
      ),
      SizedBox(
        height: GxSpacing.minTouchTarget + GxSpacing.xs,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: GxSpacing.md),
          children: [
            for (final (slug, name) in [(null, 'Tümü'), for (final c in categories) (c.slug, c.name)]) ...[
              Center(
                child: ChoiceChip(
                  avatar: slug == null ? null : Icon(categoryIcon(slug), size: GxSpacing.md + GxSpacing.xxs),
                  label: Text(name),
                  selected: _category == slug,
                  showCheckmark: false,
                  onSelected: (_) => setState(() {
                    _category = slug;
                    _limit = GroupsScreen.pageSize;
                  }),
                ),
              ),
              const SizedBox(width: GxSpacing.xs),
            ],
          ],
        ),
      ),
      const SizedBox(height: GxSpacing.xs),
      switch (result) {
        AsyncData(:final value) when value.isEmpty => Padding(
            padding: const EdgeInsets.symmetric(vertical: GxSpacing.xl),
            child: filtered
                ? GxEmptyState(
                    icon: Icons.search_off,
                    message: 'Aramana uygun grup bulunamadı.',
                    actionLabel: 'Filtreleri temizle',
                    onAction: _clearFilters,
                  )
                : GxEmptyState(
                    icon: Icons.groups_2_outlined,
                    message: 'Henüz hiç grup yok. İlk grubu sen kur.',
                    actionLabel: 'Grup oluştur',
                    onAction: () => context.push(GroupRoutes.create),
                  ),
          ),
        AsyncData(:final value) => Column(
            children: [
              for (final g in value) GroupTile(group: g),
              if (value.length >= _limit)
                Padding(
                  padding: const EdgeInsets.all(GxSpacing.md),
                  child: GxButton(
                    label: 'Daha fazla göster',
                    variant: GxButtonVariant.secondary,
                    onPressed: () => setState(() => _limit += GroupsScreen.pageSize),
                  ),
                ),
            ],
          ),
        AsyncError(:final error) => Padding(
            padding: const EdgeInsets.symmetric(vertical: GxSpacing.xl),
            child: GxErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(discoverGroupsProvider(key))),
          ),
        _ => const GroupListSkeleton(),
      },
    ];
  }
}

class _MyGroups extends ConsumerWidget {
  const _MyGroups({required this.userId, required this.onDiscover});

  final String userId;
  final VoidCallback onDiscover;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(userGroupsProvider(userId))) {
      AsyncData(:final value) when value.isEmpty => Padding(
          padding: const EdgeInsets.symmetric(vertical: GxSpacing.xl),
          child: GxEmptyState(
            icon: Icons.groups_outlined,
            message: 'Henüz bir gruba katılmadın.',
            actionLabel: 'Grupları keşfet',
            onAction: onDiscover,
          ),
        ),
      AsyncData(:final value) => Column(
          children: [
            for (final g in value)
              GroupTile(
                group: g,
                trailing: g.ownerId == userId ? const GroupRoleBadge(GroupRole.owner) : null,
              ),
          ],
        ),
      AsyncError(:final error) => Padding(
          padding: const EdgeInsets.symmetric(vertical: GxSpacing.xl),
          child: GxErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(userGroupsProvider(userId))),
        ),
      _ => const GroupListSkeleton(),
    };
  }
}

/// Pending invitations with accept / decline. Hidden when there are none.
class _InvitationsPanel extends ConsumerStatefulWidget {
  const _InvitationsPanel();

  @override
  ConsumerState<_InvitationsPanel> createState() => _InvitationsPanelState();
}

class _InvitationsPanelState extends ConsumerState<_InvitationsPanel> {
  String? _busy;
  String? _error;

  Future<void> _answer(GroupInvitation invitation, {required bool accept}) async {
    setState(() {
      _busy = invitation.group.id;
      _error = null;
    });
    final repo = ref.read(groupsRepositoryProvider);
    final result = accept ? await repo.join(invitation.group.id) : await repo.declineInvitation(invitation.group.id);
    if (!mounted) return;
    setState(() => _busy = null);
    switch (result) {
      case Ok():
        refreshGroup(ref, invitation.group);
        if (accept) unawaited(context.push(GroupRoutes.group(invitation.group.handle)));
      case Err(:final failure):
        setState(() => _error = failure.userMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final invitations = ref.watch(myInvitationsProvider).value ?? const <GroupInvitation>[];
    if (invitations.isEmpty) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(GxSpacing.md, GxSpacing.md, GxSpacing.md, 0),
      child: GxPanel(
        title: 'Davetlerin',
        subtitle: 'Bu gruplar seni üye olmaya davet etti.',
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, inv) in invitations.indexed) ...[
              if (i > 0) const Divider(),
              Padding(
                padding: const EdgeInsets.all(GxSpacing.md),
                child: Wrap(
                  spacing: GxSpacing.sm,
                  runSpacing: GxSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => context.push(GroupRoutes.group(inv.group.handle)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GxAvatar(name: inv.group.name, shape: GxAvatarShape.group, imageUrl: inv.group.logoUrl),
                          const SizedBox(width: GxSpacing.sm),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(inv.group.name, style: textTheme.labelLarge),
                                Text(
                                  inv.invitedBy == null ? formatDateTr(inv.createdAt) : '${inv.invitedBy} davet etti',
                                  style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Wrap(
                      spacing: GxSpacing.xs,
                      children: [
                        GxButton(
                          label: 'Reddet',
                          variant: GxButtonVariant.text,
                          onPressed: _busy == null ? () => _answer(inv, accept: false) : null,
                        ),
                        GxButton(
                          label: 'Katıl',
                          isLoading: _busy == inv.group.id,
                          onPressed: _busy == null ? () => _answer(inv, accept: true) : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            if (_error != null)
              Padding(padding: const EdgeInsets.fromLTRB(GxSpacing.md, 0, GxSpacing.md, GxSpacing.md), child: GxFormMessage(_error!)),
          ],
        ),
      ),
    );
  }
}
