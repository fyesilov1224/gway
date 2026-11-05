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

/// Shares [url] and tells the user when it was copied instead.
Future<void> shareWithMessage(BuildContext context, String url, {String? text}) async {
  final shared = await shareLink(url, text: text);
  if (!shared && context.mounted) showGroupMessage(context, groupsL10n.linkCopied);
}

/// Invite links of a group (docs/ARCHITECTURE.md §3b): make, share and revoke. For `members.invite` holders.
class InviteLinksSection extends ConsumerStatefulWidget {
  const InviteLinksSection({super.key, required this.group});

  final Group group;

  @override
  ConsumerState<InviteLinksSection> createState() => _InviteLinksSectionState();
}

class _InviteLinksSectionState extends ConsumerState<InviteLinksSection> {
  String? _revoking;

  Future<void> _create() async {
    final link = await showModalBottomSheet<InviteLink>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _CreateLinkSheet(group: widget.group),
    );
    if (link == null || !mounted) return;
    ref.invalidate(inviteLinksProvider(widget.group.id));
    await _share(link);
  }

  Future<void> _share(InviteLink link) => shareWithMessage(
        context,
        ref.read(shareLinksProvider).invite(link.code),
        text: groupsL10n.inviteShareText(widget.group.name),
      );

  Future<void> _revoke(InviteLink link) async {
    final ok = await confirmAction(
      context,
      title: groupsL10n.revokeLinkTitle,
      message: groupsL10n.revokeLinkBody,
      confirmLabel: groupsL10n.revoke,
    );
    if (!ok || !mounted) return;
    setState(() => _revoking = link.id);
    final result = await ref.read(groupsRepositoryProvider).revokeInviteLink(widget.group.id, link.id);
    if (!mounted) return;
    setState(() => _revoking = null);
    if (result case Err(:final failure)) showGroupMessage(context, failure.userMessage);
    ref.invalidate(inviteLinksProvider(widget.group.id));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.all(GwSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(groupsL10n.inviteLink, style: textTheme.titleMedium),
          const SizedBox(height: GwSpacing.xxs),
          Text(
            groupsL10n.inviteLinkHint,
            style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary),
          ),
          const SizedBox(height: GwSpacing.sm),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: GwButton(label: groupsL10n.createLink, icon: Icons.add_link, onPressed: _create),
          ),
          switch (ref.watch(inviteLinksProvider(widget.group.id))) {
            AsyncData(:final value) => Column(
                children: [
                  for (final link in value.where((l) => l.isValidAt(now)))
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.link),
                      title: Text(groupsL10n.validUntil(formatDate(link.expiresAt))),
                      subtitle: Text(link.maxUses == null
                          ? groupsL10n.peopleJoined(link.useCount)
                          : groupsL10n.peopleJoinedOf(link.useCount, link.maxUses!)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(tooltip: groupsL10n.share, icon: const Icon(Icons.share_outlined), onPressed: () => _share(link)),
                          IconButton(
                            tooltip: groupsL10n.revoke,
                            icon: const Icon(Icons.link_off),
                            onPressed: _revoking == null ? () => _revoke(link) : null,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            AsyncError(:final error) => Padding(
                padding: const EdgeInsets.only(top: GwSpacing.sm),
                child: GwFormMessage(userMessageOf(error)),
              ),
            _ => const GroupListSkeleton(count: 1),
          },
        ],
      ),
    );
  }
}

class _CreateLinkSheet extends ConsumerStatefulWidget {
  const _CreateLinkSheet({required this.group});

  final Group group;

  @override
  ConsumerState<_CreateLinkSheet> createState() => _CreateLinkSheetState();
}

class _CreateLinkSheetState extends ConsumerState<_CreateLinkSheet> {
  int _days = 7;
  int? _maxUses;
  bool _saving = false;
  String? _error;

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final result = await ref.read(groupsRepositoryProvider).createInviteLink(widget.group.id, days: _days, maxUses: _maxUses);
    if (!mounted) return;
    switch (result) {
      case Ok(:final value):
        Navigator.of(context).pop(value);
      case Err(:final failure):
        setState(() {
          _saving = false;
          _error = failure.userMessage;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(GwSpacing.page, 0, GwSpacing.page, GwSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(groupsL10n.newInviteLink, style: textTheme.titleLarge),
            const SizedBox(height: GwSpacing.md),
            Text(groupsL10n.validity, style: textTheme.titleSmall),
            const SizedBox(height: GwSpacing.xs),
            Wrap(
              spacing: GwSpacing.xs,
              runSpacing: GwSpacing.xs,
              children: [
                for (final days in InviteLink.durations)
                  ChoiceChip(label: Text(groupsL10n.days(days)), selected: _days == days, onSelected: (_) => setState(() => _days = days)),
              ],
            ),
            const SizedBox(height: GwSpacing.md),
            Text(groupsL10n.howMany, style: textTheme.titleSmall),
            const SizedBox(height: GwSpacing.xs),
            Wrap(
              spacing: GwSpacing.xs,
              runSpacing: GwSpacing.xs,
              children: [
                for (final limit in InviteLink.useLimits)
                  ChoiceChip(
                    label: Text(limit == null ? groupsL10n.unlimited : groupsL10n.people(limit)),
                    selected: _maxUses == limit,
                    onSelected: (_) => setState(() => _maxUses = limit),
                  ),
              ],
            ),
            if (_error != null) ...[const SizedBox(height: GwSpacing.sm), GwFormMessage(_error!)],
            const SizedBox(height: GwSpacing.lg),
            GwButton(label: groupsL10n.createAndShare, isLoading: _saving, onPressed: _save),
          ],
        ),
      ),
    );
  }
}

/// The page an invite link opens (`/i/<code>`): the group and a join button.
class InviteScreen extends ConsumerStatefulWidget {
  const InviteScreen({super.key, required this.code});

  final String code;

  @override
  ConsumerState<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends ConsumerState<InviteScreen> {
  bool _joining = false;
  String? _error;

  Future<void> _join() async {
    setState(() {
      _joining = true;
      _error = null;
    });
    final result = await ref.read(groupsRepositoryProvider).acceptInvite(widget.code);
    if (!mounted) return;
    switch (result) {
      case Ok(value: final handle):
        ref
          ..invalidate(userGroupsProvider)
          ..invalidate(groupByHandleProvider(handle))
          ..invalidate(myMembershipProvider);
        context.go(GroupRoutes.group(handle));
      case Err(:final failure):
        setState(() {
          _joining = false;
          _error = failure.userMessage;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(groupsL10n.invitation)),
      body: switch (ref.watch(invitePreviewProvider(widget.code))) {
        AsyncData(:final value) when value == null || !value.valid => GwEmptyState(
            icon: Icons.link_off,
            message: groupsL10n.linkInvalid,
            actionLabel: value == null ? groupsL10n.discoverGroups : groupsL10n.seeGroup,
            onAction: () => context.go(value == null ? GroupRoutes.discover : GroupRoutes.group(value.handle)),
          ),
        AsyncData(value: final preview?) => ListView(
            padding: const EdgeInsets.only(bottom: GwSpacing.xl),
            children: [
              GwHeroCard(
                name: preview.name,
                subtitle: atName(preview.handle),
                shape: GwAvatarShape.group,
                coverUrl: preview.coverUrl,
                avatarUrl: preview.logoUrl,
                coverIcon: categoryIcon(preview.categorySlug),
                children: [
                  Text(groupsL10n.invitedToGroup, style: textTheme.titleMedium),
                  if (preview.about.isNotEmpty) Text(preview.about, style: textTheme.bodyLarge),
                  GroupMeta(icon: Icons.people_outline, text: memberCountLabel(preview.memberCount)),
                  if (_error != null) GwFormMessage(_error!),
                  GwButton(label: groupsL10n.joinGroup, icon: Icons.group_add_outlined, isLoading: _joining, onPressed: _join),
                ],
              ),
            ],
          ),
        AsyncError(:final error) => GwErrorState(
            message: userMessageOf(error),
            onRetry: () => ref.invalidate(invitePreviewProvider(widget.code)),
          ),
        _ => const GroupListSkeleton(count: 2),
      },
    );
  }
}
