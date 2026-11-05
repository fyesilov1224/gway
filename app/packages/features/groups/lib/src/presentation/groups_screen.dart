import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/group.dart';
import '../l10n.dart';
import 'providers.dart';
import 'routes.dart';
import 'widgets.dart';

enum _Tab { discover, mine, packages }

/// Discover groups (search, category filter) and the user's own groups.
/// Pending invitations are shown above both. With [packages], a third tab
/// lists the groups the user owns with their package.
class GroupsScreen extends ConsumerStatefulWidget {
  const GroupsScreen({super.key, this.actions = const [], this.packages});

  /// Extra app bar actions the app supplies (e.g. the map), before "Grup oluştur".
  final List<Widget> actions;

  /// The package summary of an owned group (billing, supplied by the app).
  final Widget Function(BuildContext context, Group group)? packages;

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
        title: Text(groupsL10n.groups),
        actions: [
          ...widget.actions,
          Padding(
            padding: const EdgeInsets.only(right: GwSpacing.sm),
            child: GwButton(label: groupsL10n.createGroup, icon: Icons.add, onPressed: () => context.push(GroupRoutes.create)),
          ),
        ],
      ),
      body: GwReadingColumn(
        child: RefreshIndicator(
          onRefresh: () async {
            ref
              ..invalidate(discoverGroupsProvider)
              ..invalidate(userGroupsProvider)
              ..invalidate(myInvitationsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.only(bottom: GwSpacing.xl),
            children: [
              const _InvitationsPanel(),
              Padding(
                padding: const EdgeInsets.fromLTRB(GwSpacing.md, GwSpacing.md, GwSpacing.md, GwSpacing.xs),
                child: SegmentedButton<_Tab>(
                  showSelectedIcon: false,
                  // Labels only, on one line: three segments with icons wrap on a phone at large text sizes.
                  segments: [
                    ButtonSegment(value: _Tab.discover, label: _segmentLabel(groupsL10n.discover)),
                    ButtonSegment(value: _Tab.mine, label: _segmentLabel(groupsL10n.myGroups)),
                    if (widget.packages != null) ButtonSegment(value: _Tab.packages, label: _segmentLabel(groupsL10n.plans)),
                  ],
                  selected: {_tab},
                  onSelectionChanged: (s) => setState(() => _tab = s.first),
                ),
              ),
              if (_tab == _Tab.discover)
                ..._discover()
              else if (userId != null)
                switch ((_tab, widget.packages)) {
                  (_Tab.packages, final packages?) => _OwnedPackages(userId: userId, packages: packages),
                  _ => _MyGroups(userId: userId, onDiscover: () => setState(() => _tab = _Tab.discover)),
                },
            ],
          ),
        ),
      ),
    );
  }

  static Widget _segmentLabel(String text) =>
      FittedBox(fit: BoxFit.scaleDown, child: Text(text, maxLines: 1, softWrap: false));

  List<Widget> _discover() {
    final key = (query: _query, category: _category, limit: _limit);
    final result = ref.watch(discoverGroupsProvider(key));
    final categories = ref.watch(categoriesProvider).value ?? const <Category>[];
    final filtered = _query.isNotEmpty || _category != null;

    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(GwSpacing.md, GwSpacing.sm, GwSpacing.md, GwSpacing.xs),
        child: TextField(
          controller: _search,
          onChanged: _onSearchChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: groupsL10n.searchHint,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(tooltip: groupsL10n.clearSearch, icon: const Icon(Icons.close), onPressed: _clearFilters),
          ),
        ),
      ),
      GwChipRail(
        children: [
          for (final (slug, name) in [(null, groupsL10n.all), for (final c in categories) (c.slug, c.name)])
            ChoiceChip(
              avatar: slug == null ? null : Icon(categoryIcon(slug), size: GwSpacing.md + GwSpacing.xxs),
              label: Text(name),
              selected: _category == slug,
              showCheckmark: false,
              onSelected: (_) => setState(() {
                _category = slug;
                _limit = GroupsScreen.pageSize;
              }),
            ),
        ],
      ),
      const SizedBox(height: GwSpacing.xs),
      switch (result) {
        AsyncData(:final value) when value.isEmpty => Padding(
            padding: const EdgeInsets.symmetric(vertical: GwSpacing.xl),
            child: filtered
                ? GwEmptyState(
                    icon: Icons.search_off,
                    message: groupsL10n.noMatch,
                    actionLabel: groupsL10n.clearFilters,
                    onAction: _clearFilters,
                  )
                : GwEmptyState(
                    icon: Icons.groups_2_outlined,
                    message: groupsL10n.noGroupsYet,
                    actionLabel: groupsL10n.createGroup,
                    onAction: () => context.push(GroupRoutes.create),
                  ),
          ),
        AsyncData(:final value) => Column(
            children: [
              for (final g in value) GroupTile(group: g),
              if (value.length >= _limit)
                Padding(
                  padding: const EdgeInsets.all(GwSpacing.md),
                  child: GwButton(
                    label: groupsL10n.showMore,
                    variant: GwButtonVariant.secondary,
                    onPressed: () => setState(() => _limit += GroupsScreen.pageSize),
                  ),
                ),
            ],
          ),
        AsyncError(:final error) => Padding(
            padding: const EdgeInsets.symmetric(vertical: GwSpacing.xl),
            child: GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(discoverGroupsProvider(key))),
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
          padding: const EdgeInsets.symmetric(vertical: GwSpacing.xl),
          child: GwEmptyState(
            icon: Icons.groups_outlined,
            message: groupsL10n.notJoinedYet,
            actionLabel: groupsL10n.discoverGroups,
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
          padding: const EdgeInsets.symmetric(vertical: GwSpacing.xl),
          child: GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(userGroupsProvider(userId))),
        ),
      _ => const GroupListSkeleton(),
    };
  }
}

/// The groups the user owns, each with its package. Only the owner buys packages.
class _OwnedPackages extends ConsumerWidget {
  const _OwnedPackages({required this.userId, required this.packages});

  final String userId;
  final Widget Function(BuildContext context, Group group) packages;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(userGroupsProvider(userId))) {
      AsyncData(:final value) => switch ([for (final g in value) if (g.ownerId == userId) g]) {
          [] => Padding(
              padding: const EdgeInsets.symmetric(vertical: GwSpacing.xl),
              child: GwEmptyState(
                icon: Icons.workspace_premium_outlined,
                message: groupsL10n.plansHint,
                actionLabel: groupsL10n.createGroup,
                onAction: () => context.push(GroupRoutes.create),
              ),
            ),
          final owned => Column(
              children: [
                for (final g in owned) ...[
                  GroupTile(group: g),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(GwSpacing.page, 0, GwSpacing.page, GwSpacing.md),
                    child: packages(context, g),
                  ),
                ],
              ],
            ),
        },
      AsyncError(:final error) => Padding(
          padding: const EdgeInsets.symmetric(vertical: GwSpacing.xl),
          child: GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(userGroupsProvider(userId))),
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
      padding: const EdgeInsets.fromLTRB(GwSpacing.md, GwSpacing.md, GwSpacing.md, 0),
      child: GwPanel(
        title: groupsL10n.yourInvitations,
        subtitle: groupsL10n.invitationsHint,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, inv) in invitations.indexed) ...[
              if (i > 0) const Divider(),
              Padding(
                padding: const EdgeInsets.all(GwSpacing.md),
                child: Wrap(
                  spacing: GwSpacing.sm,
                  runSpacing: GwSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => context.push(GroupRoutes.group(inv.group.handle)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GwAvatar(name: inv.group.name, shape: GwAvatarShape.group, imageUrl: inv.group.logoUrl),
                          const SizedBox(width: GwSpacing.sm),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(inv.group.name, style: textTheme.labelLarge),
                                Text(
                                  inv.invitedBy == null ? formatDate(inv.createdAt) : groupsL10n.invitedBy(inv.invitedBy!),
                                  style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Wrap(
                      spacing: GwSpacing.xs,
                      children: [
                        GwButton(
                          label: groupsL10n.decline,
                          variant: GwButtonVariant.text,
                          onPressed: _busy == null ? () => _answer(inv, accept: false) : null,
                        ),
                        GwButton(
                          label: groupsL10n.join,
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
              Padding(padding: const EdgeInsets.fromLTRB(GwSpacing.md, 0, GwSpacing.md, GwSpacing.md), child: GwFormMessage(_error!)),
          ],
        ),
      ),
    );
  }
}
