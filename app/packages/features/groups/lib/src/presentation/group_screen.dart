import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/group.dart';
import '../l10n.dart';
import 'invite_links.dart';
import 'providers.dart';
import 'routes.dart';
import 'widgets.dart';

/// Opens a user's profile; supplied by the app so features stay independent.
typedef OpenProfile = void Function(BuildContext context, String username);

/// A section another feature adds to the group page (e.g. the plan card), wired by the app.
typedef GroupSectionBuilder = Widget Function(BuildContext context, Group group, MyMembership me);

/// A group's profile page: cover, logo, introduction, rules, links and team.
class GroupScreen extends ConsumerWidget {
  const GroupScreen({
    super.key,
    required this.handle,
    required this.onOpenProfile,
    this.sections = const [],
    this.contentSections = const [],
  });

  final String handle;
  final OpenProfile onOpenProfile;
  final List<GroupSectionBuilder> sections;

  /// Shown below the team, e.g. the group's posts.
  final List<GroupSectionBuilder> contentSections;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(groupByHandleProvider(handle));
    final textTheme = Theme.of(context).textTheme;
    final g = group.value;
    final me = g == null ? null : ref.watch(myMembershipProvider(g.id)).value;
    final userId = ref.watch(currentUserIdProvider);

    return Scaffold(
      appBar: AppBar(
        // Opened from a link there is no back button, so the title keeps its padding.
        titleSpacing: Navigator.canPop(context) ? 0 : GwSpacing.md,
        title: g == null
            ? Text(groupsL10n.group)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(g.name, style: textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(memberCountLabel(g.memberCount), style: textTheme.labelMedium?.copyWith(color: GwColors.textSecondary)),
                ],
              ),
        actions: [
          if (g != null && !g.isSuspended)
            IconButton(
              tooltip: groupsL10n.share,
              icon: const Icon(Icons.share_outlined),
              onPressed: () => shareWithMessage(context, ref.read(shareLinksProvider).group(g.handle),
                  text: groupsL10n.shareText(g.name)),
            ),
          if (g != null && me != null && me.isMember && g.ownerId != userId)
            PopupMenuButton<void>(
              tooltip: groupsL10n.moreOptions,
              itemBuilder: (_) => [
                PopupMenuItem(onTap: () => _leave(context, ref, g), child: Text(groupsL10n.leaveGroup)),
              ],
            ),
          const SizedBox(width: GwSpacing.xs),
        ],
      ),
      body: GwReadingColumn(
        child: switch (group) {
          AsyncData(:final value) => _GroupBody(group: value, onOpenProfile: onOpenProfile, sections: sections, contentSections: contentSections),
          AsyncError(error: NotFoundFailure()) => GwEmptyState(
              icon: Icons.group_off_outlined,
              message: groupsL10n.groupNotFound,
              actionLabel: groupsL10n.backToGroups,
              onAction: () => context.go(GroupRoutes.discover),
            ),
          AsyncError(:final error) => GwErrorState(
              message: userMessageOf(error),
              onRetry: () => ref.invalidate(groupByHandleProvider(handle)),
            ),
          _ => const _GroupSkeleton(),
        },
      ),
    );
  }
}

Future<void> _leave(BuildContext context, WidgetRef ref, Group group) async {
  final confirmed = await confirmAction(
    context,
    title: groupsL10n.leaveGroup,
    message: groupsL10n.leaveConfirm(group.name),
    confirmLabel: groupsL10n.leave,
  );
  if (!confirmed || !context.mounted) return;
  final result = await ref.read(groupsRepositoryProvider).leave(group.id);
  if (!context.mounted) return;
  switch (result) {
    case Ok():
      refreshGroup(ref, group);
      showGroupMessage(context, groupsL10n.leftGroup(group.name));
    case Err(:final failure):
      showGroupMessage(context, failure.userMessage);
  }
}

class _GroupBody extends ConsumerWidget {
  const _GroupBody({required this.group, required this.onOpenProfile, required this.sections, required this.contentSections});

  final Group group;
  final OpenProfile onOpenProfile;
  final List<GroupSectionBuilder> sections;
  final List<GroupSectionBuilder> contentSections;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final membership = ref.watch(myMembershipProvider(group.id)).value;
    final me = membership ?? const MyMembership();
    final category = categoryNames(ref)[group.categorySlug];
    final requests = me.can(GroupPermission.approveMembers) ? ref.watch(joinRequestsProvider(group.id)).value?.length ?? 0 : 0;

    return RefreshIndicator(
      onRefresh: () async => refreshGroup(ref, group),
      child: ListView(
        padding: const EdgeInsets.only(bottom: GwSpacing.xl),
        children: [
          GwHeroCard(
            name: group.name,
            subtitle: atName(group.handle),
            shape: GwAvatarShape.group,
            coverUrl: group.coverUrl,
            avatarUrl: group.logoUrl,
            coverIcon: categoryIcon(group.categorySlug),
            children: [
              if (group.isSuspended)
                _Notice(
                  icon: Icons.block,
                  danger: true,
                  text: groupsL10n.suspendedNotice,
                ),
              if (group.about.isNotEmpty) Text(group.about, style: textTheme.bodyLarge),
              Wrap(
                spacing: GwSpacing.md,
                runSpacing: GwSpacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (category != null) GwTag(icon: categoryIcon(group.categorySlug), label: category, tone: GwTone.of(group.categorySlug)),
                  if (group.provinceName case final province?) GroupMeta(icon: Icons.place_outlined, text: province),
                  GroupMeta(icon: joinPolicyIcon(group.joinPolicy), text: group.joinPolicy.label),
                  InkWell(
                    onTap: () => context.push(GroupRoutes.members(group.handle)),
                    child: GroupMeta(icon: Icons.people_outline, text: memberCountLabel(group.memberCount)),
                  ),
                  GroupMeta(icon: Icons.calendar_month_outlined, text: groupsL10n.founded(formatMonthYear(group.createdAt))),
                ],
              ),
              // No action until the membership is known, so it never flickers.
              if (membership != null)
                Wrap(
                  spacing: GwSpacing.xs,
                  runSpacing: GwSpacing.xs,
                  children: [
                    _JoinAction(group: group, me: membership),
                    if (!membership.isMember && !group.isSuspended) _FollowAction(group: group, me: membership),
                  ],
                ),
              if (requests > 0)
                _Notice(
                  icon: Icons.how_to_reg_outlined,
                  text: groupsL10n.joinRequestsPending(requests),
                  actionLabel: groupsL10n.review,
                  onAction: () => context.push(GroupRoutes.members(group.handle)),
                ),
            ],
          ),
          if (membership != null && sections.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(GwSpacing.page, GwSpacing.sm, GwSpacing.page, 0),
              child: GwCard(
                padding: const EdgeInsets.fromLTRB(GwSpacing.md, 0, GwSpacing.md, GwSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [for (final section in sections) section(context, group, membership)],
                ),
              ),
            ),
          if (group.rules.isNotEmpty) _Section(title: groupsL10n.rules, child: Text(group.rules, style: textTheme.bodyLarge)),
          if (group.links.isNotEmpty)
            _Section(
              title: groupsL10n.links,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [for (final link in group.links) _LinkRow(link: link)],
              ),
            ),
          _TeamSection(group: group, onOpenProfile: onOpenProfile),
          if (membership != null)
            for (final section in contentSections) section(context, group, membership),
        ],
      ),
    );
  }
}

/// The main button: join, request, answer an invitation, edit, or leave.
class _JoinAction extends ConsumerStatefulWidget {
  const _JoinAction({required this.group, required this.me});

  final Group group;
  final MyMembership me;

  @override
  ConsumerState<_JoinAction> createState() => _JoinActionState();
}

class _JoinActionState extends ConsumerState<_JoinAction> {
  bool _busy = false;

  Future<void> _run(Future<Result<Object?>> Function(GroupsRepository repo) action, {String? success}) async {
    setState(() => _busy = true);
    final result = await action(ref.read(groupsRepositoryProvider));
    if (!mounted) return;
    setState(() => _busy = false);
    switch (result) {
      case Ok(:final value):
        refreshGroup(ref, widget.group);
        final message = value == JoinOutcome.requested ? groupsL10n.requestSent : success;
        if (message != null) showGroupMessage(context, message);
      case Err(:final failure):
        showGroupMessage(context, failure.userMessage);
    }
  }

  Future<void> _confirmThen(String title, String message, String label, Future<void> Function() action) async {
    if (await confirmAction(context, title: title, message: message, confirmLabel: label) && mounted) await action();
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final me = widget.me;
    final state = joinStateOf(group, me, userId: ref.watch(currentUserIdProvider));
    final outlined = OutlinedButton.styleFrom(foregroundColor: GwColors.textPrimary);
    const iconSize = GwSpacing.md + GwSpacing.xxs;

    Widget edit() => OutlinedButton.icon(
          onPressed: () => context.push(GroupRoutes.edit(group.handle)),
          icon: const Icon(Icons.edit_outlined, size: iconSize),
          label: Text(groupsL10n.editGroup),
          style: outlined,
        );

    final leave = OutlinedButton.icon(
      onPressed: _busy ? null : () => _leave(context, ref, group),
      icon: const Icon(Icons.check, size: iconSize),
      label: Text(groupsL10n.youAreMember),
      style: outlined,
    );

    return switch (state) {
      JoinState.owner => edit(),
      JoinState.member => me.can(GroupPermission.edit) ? edit() : leave,
      JoinState.suspended => me.isMember && group.ownerId != ref.watch(currentUserIdProvider) ? leave : const SizedBox.shrink(),
      JoinState.canJoin => GwButton(
          label: groupsL10n.join,
          isLoading: _busy,
          onPressed: () => _run((r) => r.join(group.id), success: groupsL10n.joined(group.name)),
        ),
      JoinState.canRequest => GwButton(
          label: groupsL10n.sendJoinRequest,
          isLoading: _busy,
          onPressed: () => _run((r) => r.join(group.id)),
        ),
      JoinState.requested => GwButton(
          label: groupsL10n.requestSentShort,
          icon: Icons.schedule,
          variant: GwButtonVariant.secondary,
          isLoading: _busy,
          onPressed: () => _confirmThen(
            groupsL10n.withdrawRequest,
            groupsL10n.withdrawConfirm,
            groupsL10n.undo,
            () => _run((r) => r.cancelRequest(group.id), success: groupsL10n.requestWithdrawn),
          ),
        ),
      JoinState.invited => Wrap(
          spacing: GwSpacing.xs,
          runSpacing: GwSpacing.xs,
          alignment: WrapAlignment.end,
          children: [
            GwButton(
              label: groupsL10n.decline,
              variant: GwButtonVariant.text,
              onPressed: _busy ? null : () => _run((r) => r.declineInvitation(group.id), success: groupsL10n.inviteDeclined),
            ),
            GwButton(
              label: groupsL10n.acceptInvite,
              isLoading: _busy,
              onPressed: () => _run((r) => r.join(group.id), success: groupsL10n.joined(group.name)),
            ),
          ],
        ),
      JoinState.inviteOnly => GwBadge(groupsL10n.joinInvite),
    };
  }
}

/// Following brings the group's posts to the feed without joining.
class _FollowAction extends ConsumerStatefulWidget {
  const _FollowAction({required this.group, required this.me});

  final Group group;
  final MyMembership me;

  @override
  ConsumerState<_FollowAction> createState() => _FollowActionState();
}

class _FollowActionState extends ConsumerState<_FollowAction> {
  bool _busy = false;

  Future<void> _toggle() async {
    final follow = !widget.me.isFollowing;
    setState(() => _busy = true);
    final result = await ref.read(groupsRepositoryProvider).setFollowing(widget.group.id, follow);
    if (!mounted) return;
    setState(() => _busy = false);
    ref.invalidate(myMembershipProvider(widget.group.id));
    showGroupMessage(context, switch (result) {
      Ok() => follow ? groupsL10n.followOn(widget.group.name) : groupsL10n.followOff,
      Err(:final failure) => failure.userMessage,
    });
  }

  @override
  Widget build(BuildContext context) => GwButton(
        label: widget.me.isFollowing ? groupsL10n.following : groupsL10n.follow,
        variant: GwButtonVariant.secondary,
        isLoading: _busy,
        onPressed: _toggle,
      );
}

class _TeamSection extends ConsumerWidget {
  const _TeamSection({required this.group, required this.onOpenProfile});

  final Group group;
  final OpenProfile onOpenProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(groupMembersProvider(groupKeyOf(group)));
    return _Section(
      title: groupsL10n.managementTeam,
      trailing: TextButton(
        onPressed: () => context.push(GroupRoutes.members(group.handle)),
        child: Text(groupsL10n.allMembers(group.memberCount)),
      ),
      padChild: false,
      child: switch (members) {
        AsyncData(:final value) => Column(
            children: [
              for (final p in value.where((p) => p.titles.isNotEmpty))
                PersonTile(person: p, onTap: () => onOpenProfile(context, p.username)),
            ],
          ),
        AsyncError(:final error) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: GwSpacing.md),
            child: GwFormMessage(userMessageOf(error)),
          ),
        _ => const GroupListSkeleton(count: 1),
      },
    );
  }
}

/// A person in group lists: avatar, name, username and role badges.
class PersonTile extends StatelessWidget {
  const PersonTile({super.key, required this.person, this.onTap, this.subtitle, this.trailing});

  final GroupPerson person;
  final VoidCallback? onTap;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: GwSpacing.md, vertical: GwSpacing.sm),
        child: Row(
          children: [
            GwAvatar(name: person.displayName, shape: GwAvatarShape.user, imageUrl: person.avatarUrl),
            const SizedBox(width: GwSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(person.displayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.labelLarge),
                  Text(
                    subtitle ?? atName(person.username),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary),
                  ),
                  if (person.titles.isNotEmpty) ...[
                    const SizedBox(height: GwSpacing.xxs),
                    Wrap(
                      spacing: GwSpacing.xxs,
                      runSpacing: GwSpacing.xxs,
                      children: [for (final r in person.titles) GroupRoleBadge(r)],
                    ),
                  ],
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

/// A titled white card below the hero (rules, links, team).
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.trailing, this.padChild = true});

  final String title;
  final Widget child;
  final Widget? trailing;
  final bool padChild;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(GwSpacing.page, GwSpacing.sm, GwSpacing.page, 0),
      child: GwCard(
        padding: const EdgeInsets.symmetric(vertical: GwSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.only(start: GwSpacing.md, end: trailing == null ? GwSpacing.md : GwSpacing.xs),
              child: Row(
                children: [
                  Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
                  ?trailing,
                ],
              ),
            ),
            const SizedBox(height: GwSpacing.xs),
            padChild ? Padding(padding: const EdgeInsets.symmetric(horizontal: GwSpacing.md), child: child) : child,
          ],
        ),
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.link});

  final GroupLink link;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      borderRadius: GwRadius.smAll,
      onTap: () => launchUrl(Uri.parse(link.url), mode: LaunchMode.externalApplication),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: GwSpacing.minTouchTarget),
        child: Row(
          children: [
            const Icon(Icons.link, size: GwSpacing.md + GwSpacing.xxs, color: GwColors.secondary),
            const SizedBox(width: GwSpacing.xs),
            Flexible(
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(text: link.label, style: textTheme.labelLarge?.copyWith(color: GwColors.secondary)),
                  TextSpan(text: '  ${Uri.tryParse(link.url)?.host ?? ''}', style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
                ]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text, this.danger = false, this.actionLabel, this.onAction});

  final IconData icon;
  final String text;
  final bool danger;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = danger ? (GwColors.errorSoft, GwColors.error) : (GwColors.primarySoft, GwColors.primary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: GwSpacing.sm, vertical: GwSpacing.xs),
      decoration: BoxDecoration(color: background, borderRadius: GwRadius.mdAll),
      child: Row(
        children: [
          Icon(icon, color: foreground, size: GwSpacing.md + GwSpacing.xxs),
          const SizedBox(width: GwSpacing.xs),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
          if (actionLabel != null) TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

class _GroupSkeleton extends StatelessWidget {
  const _GroupSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: const [GwHeroCardSkeleton(shape: GwAvatarShape.group)],
    );
  }
}
