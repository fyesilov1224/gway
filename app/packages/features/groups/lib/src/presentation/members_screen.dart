import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/group.dart';
import 'group_screen.dart';
import 'invite_links.dart';
import 'providers.dart';
import 'widgets.dart';

/// Opens a discipline case about a member (the moderation feature, through the app).
typedef OpenCase = void Function(BuildContext context, Group group, GroupPerson person, {required bool canMute});

/// A line under a member's name from another feature, e.g. their contributions in the group.
typedef MemberNote = String? Function(WidgetRef ref, Group group, GroupPerson person);

/// Members with their roles. People who manage members also get the
/// pending requests and invitations; the owner manages roles and ownership.
/// Members report each other; reviewers open discipline cases (docs/ARCHITECTURE.md §3e).
class GroupMembersScreen extends ConsumerWidget {
  const GroupMembersScreen({super.key, required this.handle, required this.onOpenProfile, this.onOpenCase, this.memberNote});

  final String handle;
  final OpenProfile onOpenProfile;
  final OpenCase? onOpenCase;
  final MemberNote? memberNote;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(groupByHandleProvider(handle));
    final g = group.value;
    final me = g == null ? null : ref.watch(myMembershipProvider(g.id)).value;

    if (g == null || me == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Üyeler')),
        body: switch (group) {
          AsyncError(:final error) => GwErrorState(
              message: userMessageOf(error),
              onRetry: () => ref.invalidate(groupByHandleProvider(handle)),
            ),
          _ => const GroupListSkeleton(),
        },
      );
    }

    final tabs = [
      (const Tab(text: 'Üyeler'), _MembersTab(group: g, me: me, onOpenProfile: onOpenProfile, onOpenCase: onOpenCase, memberNote: memberNote)),
      if (me.can(GroupPermission.approveMembers)) (const Tab(text: 'İstekler'), _RequestsTab(group: g)),
      if (me.can(GroupPermission.inviteMembers)) (const Tab(text: 'Davetler'), _InvitationsTab(group: g)),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(g.name),
          bottom: tabs.length == 1
              ? null
              : TabBar(isScrollable: false, tabs: [for (final (tab, _) in tabs) tab]),
        ),
        body: GwReadingColumn(
          child: tabs.length == 1 ? tabs.first.$2 : TabBarView(children: [for (final (_, view) in tabs) view]),
        ),
      ),
    );
  }
}

class _MembersTab extends ConsumerWidget {
  const _MembersTab({
    required this.group,
    required this.me,
    required this.onOpenProfile,
    required this.onOpenCase,
    required this.memberNote,
  });

  final Group group;
  final MyMembership me;
  final OpenProfile onOpenProfile;
  final OpenCase? onOpenCase;
  final MemberNote? memberNote;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    final canManageRoles = me.can(GroupPermission.assignRoles);
    final canOpenCase = onOpenCase != null && me.can(GroupPermission.reviewReports) && !group.isSuspended;
    final key = groupKeyOf(group);

    List<PopupMenuEntry<void>> menu(GroupPerson p) => [
          if (canManageRoles)
            PopupMenuItem(
              onTap: () => showModalBottomSheet<void>(
                context: context,
                showDragHandle: true,
                isScrollControlled: true,
                builder: (_) => _RolesSheet(group: group, person: p),
              ),
              child: const Text('Roller'),
            ),
          if (canOpenCase && me.rank > p.rank)
            PopupMenuItem(
              onTap: () => onOpenCase!(context, group, p, canMute: me.can(GroupPermission.muteMembers)),
              child: const Text('Disiplin dosyası aç'),
            ),
          if (me.isMember)
            PopupMenuItem(
              onTap: () => ref.read(reportLauncherProvider)(context, ReportTarget.user(p.userId, groupId: group.id)),
              child: const Text('Şikayet et'),
            ),
        ];

    return switch (ref.watch(groupMembersProvider(key))) {
      AsyncData(:final value) => ListView(
          padding: const EdgeInsets.only(bottom: GwSpacing.xl),
          children: [
            if (!me.isMember)
              Padding(
                padding: const EdgeInsets.fromLTRB(GwSpacing.page, GwSpacing.md, GwSpacing.page, GwSpacing.xs),
                child: Text(
                  'Üye listesinin tamamını grubun üyeleri görür. Burada yönetim ekibi ve gruplarını herkese açan '
                  '${value.length} kişi var; grupta toplam ${group.memberCount} üye var.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: GwColors.textSecondary),
                ),
              ),
            for (final p in value)
              PersonTile(
                person: p,
                subtitle: switch (memberNote?.call(ref, group, p)) {
                  final note? when note.isNotEmpty => '@${p.username} · $note',
                  _ => null,
                },
                onTap: () => onOpenProfile(context, p.username),
                trailing: p.userId != userId && menu(p).isNotEmpty
                    ? PopupMenuButton<void>(
                        tooltip: '${p.displayName} için seçenekler',
                        icon: const Icon(Icons.more_vert),
                        itemBuilder: (_) => menu(p),
                      )
                    : null,
              ),
          ],
        ),
      AsyncError(:final error) => GwErrorState(
          message: userMessageOf(error),
          onRetry: () => ref.invalidate(groupMembersProvider(key)),
        ),
      _ => const GroupListSkeleton(),
    };
  }
}

/// Owner-only: toggle assignable roles and hand over ownership.
class _RolesSheet extends ConsumerStatefulWidget {
  const _RolesSheet({required this.group, required this.person});

  final Group group;
  final GroupPerson person;

  @override
  ConsumerState<_RolesSheet> createState() => _RolesSheetState();
}

class _RolesSheetState extends ConsumerState<_RolesSheet> {
  late final Set<GroupRole> _roles = {...widget.person.roles};
  GroupRole? _busy;
  bool _transferring = false;
  String? _error;

  Future<void> _toggle(GroupRole role, bool on) async {
    setState(() {
      _busy = role;
      _error = null;
    });
    final repo = ref.read(groupsRepositoryProvider);
    final result = on
        ? await repo.assignRole(widget.group.id, widget.person.userId, role)
        : await repo.removeRole(widget.group.id, widget.person.userId, role);
    if (!mounted) return;
    setState(() {
      _busy = null;
      switch (result) {
        case Ok():
          on ? _roles.add(role) : _roles.remove(role);
        case Err(:final failure):
          _error = failure.userMessage;
      }
    });
    ref.invalidate(groupMembersProvider(groupKeyOf(widget.group)));
  }

  Future<void> _transfer() async {
    final confirmed = await confirmAction(
      context,
      title: 'Sahipliği devret',
      message: '${widget.group.name} grubunun sahipliği ${widget.person.displayName} kişisine geçecek. '
          'Sen normal üye olarak kalacaksın ve bu işlemi geri alamazsın.',
      confirmLabel: 'Devret',
    );
    if (!confirmed || !mounted) return;
    setState(() {
      _transferring = true;
      _error = null;
    });
    final result = await ref.read(groupsRepositoryProvider).transferOwnership(widget.group.id, widget.person.userId);
    if (!mounted) return;
    switch (result) {
      case Ok():
        refreshGroup(ref, widget.group);
        Navigator.of(context).pop();
        showGroupMessage(context, 'Sahiplik ${widget.person.displayName} kişisine devredildi.');
      case Err(:final failure):
        setState(() {
          _transferring = false;
          _error = failure.userMessage;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final busy = _busy != null || _transferring;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(GwSpacing.md, 0, GwSpacing.md, GwSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.person.displayName, style: textTheme.titleLarge),
            Text('@${widget.person.username}', style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
            const SizedBox(height: GwSpacing.md),
            Text('Roller', style: textTheme.titleMedium),
            for (final role in GroupRole.assignable)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(role.label),
                subtitle: Text(_roleHint(role)),
                value: _roles.contains(role),
                onChanged: busy ? null : (on) => _toggle(role, on),
                secondary: _busy == role
                    ? const SizedBox.square(dimension: GwSpacing.lg, child: CircularProgressIndicator(strokeWidth: 2))
                    : null,
              ),
            if (_error != null) ...[const SizedBox(height: GwSpacing.sm), GwFormMessage(_error!)],
            const SizedBox(height: GwSpacing.md),
            const Divider(),
            const SizedBox(height: GwSpacing.md),
            GwButton(
              label: 'Sahipliği devret',
              icon: Icons.swap_horiz,
              variant: GwButtonVariant.secondary,
              isLoading: _transferring,
              onPressed: busy ? null : _transfer,
            ),
          ],
        ),
      ),
    );
  }

  static String _roleHint(GroupRole role) => switch (role) {
        GroupRole.admin => 'Grubu düzenler, katılım isteklerini ve davetleri yönetir.',
        GroupRole.discipline => 'Şikayet dosyalarını inceler ve yaptırım kararı verir.',
        GroupRole.moderator => 'İçerikleri ve yorumları denetler.',
        _ => '',
      };
}

class _RequestsTab extends ConsumerStatefulWidget {
  const _RequestsTab({required this.group});

  final Group group;

  @override
  ConsumerState<_RequestsTab> createState() => _RequestsTabState();
}

class _RequestsTabState extends ConsumerState<_RequestsTab> {
  String? _busy;

  Future<void> _answer(GroupPerson person, {required bool approve}) async {
    setState(() => _busy = person.userId);
    final repo = ref.read(groupsRepositoryProvider);
    final result = approve
        ? await repo.approve(widget.group.id, person.userId)
        : await repo.reject(widget.group.id, person.userId);
    if (!mounted) return;
    setState(() => _busy = null);
    switch (result) {
      case Ok():
        refreshGroup(ref, widget.group);
        showGroupMessage(context, approve ? '${person.displayName} gruba katıldı.' : 'İstek reddedildi.');
      case Err(:final failure):
        showGroupMessage(context, failure.userMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.group.id;
    return switch (ref.watch(joinRequestsProvider(id))) {
      AsyncData(:final value) when value.isEmpty => GwEmptyState(
          icon: Icons.how_to_reg_outlined,
          message: 'Bekleyen katılım isteği yok.',
          actionLabel: 'Yenile',
          onAction: () => ref.invalidate(joinRequestsProvider(id)),
        ),
      AsyncData(:final value) => ListView(
          children: [
            for (final p in value)
              PersonTile(
                person: p,
                subtitle: p.since == null ? null : '@${p.username} · ${formatDateTr(p.since!)}',
                trailing: Wrap(
                  spacing: GwSpacing.xxs,
                  children: [
                    IconButton(
                      tooltip: 'Reddet',
                      icon: const Icon(Icons.close),
                      onPressed: _busy == null ? () => _answer(p, approve: false) : null,
                    ),
                    IconButton.filled(
                      tooltip: 'Onayla',
                      icon: _busy == p.userId
                          ? const SizedBox.square(
                              dimension: GwSpacing.md,
                              child: CircularProgressIndicator(strokeWidth: 2, color: GwColors.onPrimary),
                            )
                          : const Icon(Icons.check),
                      onPressed: _busy == null ? () => _answer(p, approve: true) : null,
                    ),
                  ],
                ),
              ),
          ],
        ),
      AsyncError(:final error) => GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(joinRequestsProvider(id))),
      _ => const GroupListSkeleton(),
    };
  }
}

class _InvitationsTab extends ConsumerStatefulWidget {
  const _InvitationsTab({required this.group});

  final Group group;

  @override
  ConsumerState<_InvitationsTab> createState() => _InvitationsTabState();
}

class _InvitationsTabState extends ConsumerState<_InvitationsTab> {
  final _username = TextEditingController();
  bool _sending = false;
  String? _revoking;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    super.dispose();
  }

  Future<void> _invite() async {
    final username = _username.text.trim();
    if (username.isEmpty) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    final result = await ref.read(groupsRepositoryProvider).invite(widget.group.id, username);
    if (!mounted) return;
    setState(() => _sending = false);
    switch (result) {
      case Ok():
        _username.clear();
        ref.invalidate(groupInvitationsProvider(widget.group.id));
        showGroupMessage(context, 'Davet gönderildi.');
      case Err(:final failure):
        setState(() => _error = failure.userMessage);
    }
  }

  Future<void> _revoke(GroupPerson person) async {
    setState(() => _revoking = person.userId);
    final result = await ref.read(groupsRepositoryProvider).revokeInvitation(widget.group.id, person.userId);
    if (!mounted) return;
    setState(() => _revoking = null);
    if (result case Err(:final failure)) showGroupMessage(context, failure.userMessage);
    ref.invalidate(groupInvitationsProvider(widget.group.id));
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.group.id;
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.only(bottom: GwSpacing.xl),
      children: [
        InviteLinksSection(group: widget.group),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(GwSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Kullanıcı adıyla davet et', style: textTheme.titleMedium),
              const SizedBox(height: GwSpacing.xs),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _username,
                      autocorrect: false,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _invite(),
                      decoration: const InputDecoration(hintText: 'kullanici_adi', prefixText: '@'),
                    ),
                  ),
                  const SizedBox(width: GwSpacing.xs),
                  GwButton(label: 'Davet et', isLoading: _sending, onPressed: _invite),
                ],
              ),
              if (_error != null) ...[const SizedBox(height: GwSpacing.xs), GwFormMessage(_error!)],
            ],
          ),
        ),
        const Divider(),
        switch (ref.watch(groupInvitationsProvider(id))) {
          AsyncData(:final value) when value.isEmpty => Padding(
              padding: const EdgeInsets.all(GwSpacing.md),
              child: Text('Bekleyen davet yok.', style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
            ),
          AsyncData(:final value) => Column(
              children: [
                for (final p in value)
                  PersonTile(
                    person: p,
                    subtitle: p.since == null ? null : '@${p.username} · ${formatDateTr(p.since!)}',
                    trailing: GwButton(
                      label: 'Geri al',
                      variant: GwButtonVariant.text,
                      isLoading: _revoking == p.userId,
                      onPressed: _revoking == null ? () => _revoke(p) : null,
                    ),
                  ),
              ],
            ),
          AsyncError(:final error) => Padding(
              padding: const EdgeInsets.all(GwSpacing.md),
              child: GwFormMessage(userMessageOf(error)),
            ),
          _ => const GroupListSkeleton(count: 2),
        },
      ],
    );
  }
}
