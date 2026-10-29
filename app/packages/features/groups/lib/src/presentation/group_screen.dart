import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/group.dart';
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
        titleSpacing: Navigator.canPop(context) ? 0 : GxSpacing.md,
        title: g == null
            ? const Text('Grup')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(g.name, style: textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(memberCountLabel(g.memberCount), style: textTheme.labelMedium?.copyWith(color: GxColors.textSecondary)),
                ],
              ),
        actions: [
          if (g != null && !g.isSuspended)
            IconButton(
              tooltip: 'Paylaş',
              icon: const Icon(Icons.share_outlined),
              onPressed: () => shareWithMessage(context, ref.read(shareLinksProvider).group(g.handle),
                  text: '${g.name} grubuna GrupX\'te göz at:'),
            ),
          if (g != null && me != null && me.isMember && g.ownerId != userId)
            PopupMenuButton<void>(
              tooltip: 'Diğer seçenekler',
              itemBuilder: (_) => [
                PopupMenuItem(onTap: () => _leave(context, ref, g), child: const Text('Gruptan ayrıl')),
              ],
            ),
          const SizedBox(width: GxSpacing.xs),
        ],
      ),
      body: GxReadingColumn(
        child: switch (group) {
          AsyncData(:final value) => _GroupBody(group: value, onOpenProfile: onOpenProfile, sections: sections, contentSections: contentSections),
          AsyncError(error: NotFoundFailure()) => GxEmptyState(
              icon: Icons.group_off_outlined,
              message: 'Bu grup bulunamadı ya da artık görünür değil.',
              actionLabel: 'Gruplara dön',
              onAction: () => context.go(GroupRoutes.discover),
            ),
          AsyncError(:final error) => GxErrorState(
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
    title: 'Gruptan ayrıl',
    message: '${group.name} grubundan ayrılmak istiyor musun? Grupta bir rolün varsa o da kaldırılır.',
    confirmLabel: 'Ayrıl',
  );
  if (!confirmed || !context.mounted) return;
  final result = await ref.read(groupsRepositoryProvider).leave(group.id);
  if (!context.mounted) return;
  switch (result) {
    case Ok():
      refreshGroup(ref, group);
      showGroupMessage(context, '${group.name} grubundan ayrıldın.');
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
        padding: const EdgeInsets.only(bottom: GxSpacing.xl),
        children: [
          GxHeroCard(
            name: group.name,
            subtitle: '@${group.handle}',
            shape: GxAvatarShape.group,
            coverUrl: group.coverUrl,
            avatarUrl: group.logoUrl,
            coverIcon: categoryIcon(group.categorySlug),
            children: [
              if (group.isSuspended)
                const _Notice(
                  icon: Icons.block,
                  danger: true,
                  text: 'Bu grup platform ekibi tarafından askıya alındı. Askı sürerken grup yalnızca üyelerine görünür.',
                ),
              if (group.about.isNotEmpty) Text(group.about, style: textTheme.bodyLarge),
              Wrap(
                spacing: GxSpacing.md,
                runSpacing: GxSpacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (category != null) GxTag(icon: categoryIcon(group.categorySlug), label: category, tone: GxTone.of(group.categorySlug)),
                  if (group.provinceName case final province?) GroupMeta(icon: Icons.place_outlined, text: province),
                  GroupMeta(icon: joinPolicyIcon(group.joinPolicy), text: group.joinPolicy.label),
                  InkWell(
                    onTap: () => context.push(GroupRoutes.members(group.handle)),
                    child: GroupMeta(icon: Icons.people_outline, text: memberCountLabel(group.memberCount)),
                  ),
                  GroupMeta(icon: Icons.calendar_month_outlined, text: 'Kuruluş: ${formatMonthYearTr(group.createdAt)}'),
                ],
              ),
              // No action until the membership is known, so it never flickers.
              if (membership != null)
                Wrap(
                  spacing: GxSpacing.xs,
                  runSpacing: GxSpacing.xs,
                  children: [
                    _JoinAction(group: group, me: membership),
                    if (!membership.isMember && !group.isSuspended) _FollowAction(group: group, me: membership),
                  ],
                ),
              if (requests > 0)
                _Notice(
                  icon: Icons.how_to_reg_outlined,
                  text: '$requests katılım isteği onay bekliyor.',
                  actionLabel: 'İncele',
                  onAction: () => context.push(GroupRoutes.members(group.handle)),
                ),
            ],
          ),
          if (membership != null && sections.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(GxSpacing.page, GxSpacing.sm, GxSpacing.page, 0),
              child: GxCard(
                padding: const EdgeInsets.fromLTRB(GxSpacing.md, 0, GxSpacing.md, GxSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [for (final section in sections) section(context, group, membership)],
                ),
              ),
            ),
          if (group.rules.isNotEmpty) _Section(title: 'Kurallar', child: Text(group.rules, style: textTheme.bodyLarge)),
          if (group.links.isNotEmpty)
            _Section(
              title: 'Bağlantılar',
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
        final message = value == JoinOutcome.requested ? 'Katılım isteğin gönderildi.' : success;
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
    final outlined = OutlinedButton.styleFrom(foregroundColor: GxColors.textPrimary);
    const iconSize = GxSpacing.md + GxSpacing.xxs;

    Widget edit() => OutlinedButton.icon(
          onPressed: () => context.push(GroupRoutes.edit(group.handle)),
          icon: const Icon(Icons.edit_outlined, size: iconSize),
          label: const Text('Grubu düzenle'),
          style: outlined,
        );

    final leave = OutlinedButton.icon(
      onPressed: _busy ? null : () => _leave(context, ref, group),
      icon: const Icon(Icons.check, size: iconSize),
      label: const Text('Üyesin'),
      style: outlined,
    );

    return switch (state) {
      JoinState.owner => edit(),
      JoinState.member => me.can(GroupPermission.edit) ? edit() : leave,
      JoinState.suspended => me.isMember && group.ownerId != ref.watch(currentUserIdProvider) ? leave : const SizedBox.shrink(),
      JoinState.canJoin => GxButton(
          label: 'Katıl',
          isLoading: _busy,
          onPressed: () => _run((r) => r.join(group.id), success: '${group.name} grubuna katıldın.'),
        ),
      JoinState.canRequest => GxButton(
          label: 'Katılma isteği gönder',
          isLoading: _busy,
          onPressed: () => _run((r) => r.join(group.id)),
        ),
      JoinState.requested => GxButton(
          label: 'İstek gönderildi',
          icon: Icons.schedule,
          variant: GxButtonVariant.secondary,
          isLoading: _busy,
          onPressed: () => _confirmThen(
            'İsteği geri al',
            'Katılım isteğini geri almak istiyor musun?',
            'Geri al',
            () => _run((r) => r.cancelRequest(group.id), success: 'Katılım isteğin geri alındı.'),
          ),
        ),
      JoinState.invited => Wrap(
          spacing: GxSpacing.xs,
          runSpacing: GxSpacing.xs,
          alignment: WrapAlignment.end,
          children: [
            GxButton(
              label: 'Reddet',
              variant: GxButtonVariant.text,
              onPressed: _busy ? null : () => _run((r) => r.declineInvitation(group.id), success: 'Davet reddedildi.'),
            ),
            GxButton(
              label: 'Daveti kabul et',
              isLoading: _busy,
              onPressed: () => _run((r) => r.join(group.id), success: '${group.name} grubuna katıldın.'),
            ),
          ],
        ),
      JoinState.inviteOnly => const GxBadge('Davetle katılım'),
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
      Ok() => follow ? '${widget.group.name} gönderileri akışında görünecek.' : 'Grubu takip etmeyi bıraktın.',
      Err(:final failure) => failure.userMessage,
    });
  }

  @override
  Widget build(BuildContext context) => GxButton(
        label: widget.me.isFollowing ? 'Takiptesin' : 'Takip et',
        variant: GxButtonVariant.secondary,
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
      title: 'Yönetim ekibi',
      trailing: TextButton(
        onPressed: () => context.push(GroupRoutes.members(group.handle)),
        child: Text('Tüm üyeler (${group.memberCount})'),
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
            padding: const EdgeInsets.symmetric(horizontal: GxSpacing.md),
            child: GxFormMessage(userMessageOf(error)),
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
        padding: const EdgeInsets.symmetric(horizontal: GxSpacing.md, vertical: GxSpacing.sm),
        child: Row(
          children: [
            GxAvatar(name: person.displayName, shape: GxAvatarShape.user, imageUrl: person.avatarUrl),
            const SizedBox(width: GxSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(person.displayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.labelLarge),
                  Text(
                    subtitle ?? '@${person.username}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary),
                  ),
                  if (person.titles.isNotEmpty) ...[
                    const SizedBox(height: GxSpacing.xxs),
                    Wrap(
                      spacing: GxSpacing.xxs,
                      runSpacing: GxSpacing.xxs,
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
      padding: const EdgeInsets.fromLTRB(GxSpacing.page, GxSpacing.sm, GxSpacing.page, 0),
      child: GxCard(
        padding: const EdgeInsets.symmetric(vertical: GxSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(left: GxSpacing.md, right: trailing == null ? GxSpacing.md : GxSpacing.xs),
              child: Row(
                children: [
                  Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
                  ?trailing,
                ],
              ),
            ),
            const SizedBox(height: GxSpacing.xs),
            padChild ? Padding(padding: const EdgeInsets.symmetric(horizontal: GxSpacing.md), child: child) : child,
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
      borderRadius: GxRadius.smAll,
      onTap: () => launchUrl(Uri.parse(link.url), mode: LaunchMode.externalApplication),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: GxSpacing.minTouchTarget),
        child: Row(
          children: [
            const Icon(Icons.link, size: GxSpacing.md + GxSpacing.xxs, color: GxColors.secondary),
            const SizedBox(width: GxSpacing.xs),
            Flexible(
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(text: link.label, style: textTheme.labelLarge?.copyWith(color: GxColors.secondary)),
                  TextSpan(text: '  ${Uri.tryParse(link.url)?.host ?? ''}', style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary)),
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
    final (background, foreground) = danger ? (GxColors.errorSoft, GxColors.error) : (GxColors.primarySoft, GxColors.primary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: GxSpacing.sm, vertical: GxSpacing.xs),
      decoration: BoxDecoration(color: background, borderRadius: GxRadius.mdAll),
      child: Row(
        children: [
          Icon(icon, color: foreground, size: GxSpacing.md + GxSpacing.xxs),
          const SizedBox(width: GxSpacing.xs),
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
      children: const [GxHeroCardSkeleton(shape: GxAvatarShape.group)],
    );
  }
}
