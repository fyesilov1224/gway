import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/social.dart';
import '../l10n.dart';
import 'providers.dart';
import 'social_providers.dart';
import 'social_widgets.dart';

/// Followers and following of a user, as tabs. On your own list you can remove followers.
class FollowListsScreen extends ConsumerWidget {
  const FollowListsScreen({super.key, required this.username, this.initial = FollowList.followers});

  final String username;
  final FollowList initial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileByUsernameProvider(username));
    return DefaultTabController(
      length: 2,
      initialIndex: initial.index,
      child: Scaffold(
        appBar: AppBar(
          title: Text(username),
          bottom: TabBar(tabs: [Tab(text: profileL10n.followers), Tab(text: profileL10n.following)]),
        ),
        body: GwReadingColumn(
          child: switch (profile) {
            AsyncData(:final value) => TabBarView(
                children: [
                  _FollowList(userId: value.id, list: FollowList.followers),
                  _FollowList(userId: value.id, list: FollowList.following),
                ],
              ),
            AsyncError(:final error) => GwErrorState(
                message: userMessageOf(error), onRetry: () => ref.invalidate(profileByUsernameProvider(username))),
            _ => const ListSkeleton(),
          },
        ),
      ),
    );
  }
}

class _FollowList extends ConsumerWidget {
  const _FollowList({required this.userId, required this.list});

  final String userId;
  final FollowList list;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final social = ref.watch(profileSocialProvider(userId)).value;
    final isOwn = ref.watch(currentUserIdProvider) == userId;
    if (social != null && !social.canView) {
      return GwEmptyState(
        icon: Icons.lock_outline,
        message: profileL10n.privateLists,
        actionLabel: profileL10n.backToProfile,
        onAction: () => Navigator.of(context).maybePop(),
      );
    }
    final people = ref.watch(followListProvider((userId: userId, list: list)));
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(followListProvider((userId: userId, list: list))),
      child: switch (people) {
        AsyncData(:final value) when value.isEmpty => ListView(children: [
            const SizedBox(height: GwSpacing.xxl),
            GwEmptyState(
              icon: Icons.people_outline,
              message: list == FollowList.followers ? profileL10n.noFollowers : profileL10n.noFollowing,
              actionLabel: profileL10n.refresh,
              onAction: () => ref.invalidate(followListProvider((userId: userId, list: list))),
            ),
          ]),
        AsyncData(:final value) => ListView(
            children: [
              for (final p in value)
                isOwn && list == FollowList.followers ? _OwnFollowerRow(person: p) : PersonFollowRow(person: p),
            ],
          ),
        AsyncError(:final error) => GwErrorState(
            message: userMessageOf(error),
            onRetry: () => ref.invalidate(followListProvider((userId: userId, list: list))),
          ),
        _ => const ListSkeleton(),
      },
    );
  }
}

/// On your own followers list: profileL10n.removeAction removes the follower without telling them.
class _OwnFollowerRow extends ConsumerWidget {
  const _OwnFollowerRow({required this.person});

  final PersonSummary person;

  Future<void> _remove(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: GwRadius.xlAll),
        title: Text(profileL10n.removeFollower),
        content: Text(profileL10n.removeFollowerBody(person.username)),
        actions: [
          GwButton(label: profileL10n.cancel, variant: GwButtonVariant.text, onPressed: () => Navigator.of(context).pop(false)),
          GwButton(label: profileL10n.removeAction, onPressed: () => Navigator.of(context).pop(true)),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final result = await ref.read(socialRepositoryProvider).removeFollower(person.id);
    if (!context.mounted) return;
    if (result case Err(:final failure)) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.userMessage)));
    refreshRelationship(ref, person.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => PersonRow(
        person: person,
        subtitle: person.follow == FollowState.following ? profileL10n.friends : null,
        trailing: GwButton(label: profileL10n.removeAction, variant: GwButtonVariant.secondary, onPressed: () => _remove(context, ref)),
      );
}

/// People who asked to follow the signed-in user's private account.
class FollowRequestsScreen extends ConsumerWidget {
  const FollowRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(followRequestsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(profileL10n.followRequests)),
      body: GwReadingColumn(
        child: switch (requests) {
          AsyncData(:final value) when value.isEmpty => GwEmptyState(
              icon: Icons.person_add_alt,
              message: profileL10n.noFollowRequests,
              actionLabel: profileL10n.refresh,
              onAction: () => ref.invalidate(followRequestsProvider),
            ),
          AsyncData(:final value) => ListView(children: [for (final p in value) _RequestRow(person: p)]),
          AsyncError(:final error) => GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(followRequestsProvider)),
          _ => const ListSkeleton(),
        },
      ),
    );
  }
}

class _RequestRow extends ConsumerStatefulWidget {
  const _RequestRow({required this.person});

  final PersonSummary person;

  @override
  ConsumerState<_RequestRow> createState() => _RequestRowState();
}

class _RequestRowState extends ConsumerState<_RequestRow> {
  bool _busy = false;

  Future<void> _answer(bool accept) async {
    setState(() => _busy = true);
    final repo = ref.read(socialRepositoryProvider);
    final result = accept ? await repo.acceptRequest(widget.person.id) : await repo.rejectRequest(widget.person.id);
    if (!mounted) return;
    setState(() => _busy = false);
    if (result case Err(:final failure)) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.userMessage)));
    refreshRelationship(ref, widget.person.id);
  }

  @override
  Widget build(BuildContext context) => PersonRow(
        person: widget.person,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GwButton(label: profileL10n.approve, isLoading: _busy, onPressed: () => _answer(true)),
            const SizedBox(width: GwSpacing.xs),
            GwButton(label: profileL10n.delete, variant: GwButtonVariant.secondary, onPressed: _busy ? null : () => _answer(false)),
          ],
        ),
      );
}

/// Accounts the signed-in user blocked, with unblocking.
class BlockedAccountsScreen extends ConsumerWidget {
  const BlockedAccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocked = ref.watch(blockedAccountsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(profileL10n.blockedAccounts)),
      body: GwReadingColumn(
        child: switch (blocked) {
          AsyncData(:final value) when value.isEmpty => GwEmptyState(
              icon: Icons.block,
              message: profileL10n.noBlocked,
              actionLabel: profileL10n.refresh,
              onAction: () => ref.invalidate(blockedAccountsProvider),
            ),
          AsyncData(:final value) => ListView(
              children: [
                for (final p in value)
                  PersonRow(
                    person: p,
                    onTap: () {},
                    trailing: GwButton(
                      label: profileL10n.unblock,
                      variant: GwButtonVariant.secondary,
                      onPressed: () async {
                        final result = await ref.read(socialRepositoryProvider).unblock(p.id);
                        if (!context.mounted) return;
                        if (result case Err(:final failure)) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.userMessage)));
                        }
                        refreshRelationship(ref, p.id);
                      },
                    ),
                  ),
              ],
            ),
          AsyncError(:final error) => GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(blockedAccountsProvider)),
          _ => const ListSkeleton(),
        },
      ),
    );
  }
}
