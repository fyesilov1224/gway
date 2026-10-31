import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/group.dart';
import 'providers.dart';
import 'routes.dart';
import 'widgets.dart';

/// Shares [url] and tells the user when it was copied instead.
Future<void> shareWithMessage(BuildContext context, String url, {String? text}) async {
  final shared = await shareLink(url, text: text);
  if (!shared && context.mounted) showGroupMessage(context, 'Bağlantı kopyalandı.');
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
        text: '${widget.group.name} grubuna GWAY\'de katıl:',
      );

  Future<void> _revoke(InviteLink link) async {
    final ok = await confirmAction(
      context,
      title: 'Bağlantı iptal edilsin mi?',
      message: 'Bu bağlantıyla artık kimse katılamaz. Katılmış olanlar üye olarak kalır.',
      confirmLabel: 'İptal et',
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
          Text('Davet bağlantısı', style: textTheme.titleMedium),
          const SizedBox(height: GwSpacing.xxs),
          Text(
            'WhatsApp ya da Instagram\'da paylaş. Bağlantıyı açan kişi katılım tipine bakılmadan doğrudan üye olur.',
            style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary),
          ),
          const SizedBox(height: GwSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: GwButton(label: 'Bağlantı oluştur', icon: Icons.add_link, onPressed: _create),
          ),
          switch (ref.watch(inviteLinksProvider(widget.group.id))) {
            AsyncData(:final value) => Column(
                children: [
                  for (final link in value.where((l) => l.isValidAt(now)))
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.link),
                      title: Text('${formatDateTr(link.expiresAt)} tarihine kadar'),
                      subtitle: Text(link.maxUses == null
                          ? '${link.useCount} kişi katıldı'
                          : '${link.useCount} / ${link.maxUses} kişi katıldı'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(tooltip: 'Paylaş', icon: const Icon(Icons.share_outlined), onPressed: () => _share(link)),
                          IconButton(
                            tooltip: 'İptal et',
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
            Text('Yeni davet bağlantısı', style: textTheme.titleLarge),
            const SizedBox(height: GwSpacing.md),
            Text('Geçerlilik süresi', style: textTheme.titleSmall),
            const SizedBox(height: GwSpacing.xs),
            Wrap(
              spacing: GwSpacing.xs,
              runSpacing: GwSpacing.xs,
              children: [
                for (final days in InviteLink.durations)
                  ChoiceChip(label: Text('$days gün'), selected: _days == days, onSelected: (_) => setState(() => _days = days)),
              ],
            ),
            const SizedBox(height: GwSpacing.md),
            Text('Kaç kişi katılabilir?', style: textTheme.titleSmall),
            const SizedBox(height: GwSpacing.xs),
            Wrap(
              spacing: GwSpacing.xs,
              runSpacing: GwSpacing.xs,
              children: [
                for (final limit in InviteLink.useLimits)
                  ChoiceChip(
                    label: Text(limit == null ? 'Sınırsız' : '$limit kişi'),
                    selected: _maxUses == limit,
                    onSelected: (_) => setState(() => _maxUses = limit),
                  ),
              ],
            ),
            if (_error != null) ...[const SizedBox(height: GwSpacing.sm), GwFormMessage(_error!)],
            const SizedBox(height: GwSpacing.lg),
            GwButton(label: 'Oluştur ve paylaş', isLoading: _saving, onPressed: _save),
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
      appBar: AppBar(title: const Text('Davet')),
      body: switch (ref.watch(invitePreviewProvider(widget.code))) {
        AsyncData(:final value) when value == null || !value.valid => GwEmptyState(
            icon: Icons.link_off,
            message: 'Bu davet bağlantısı artık geçerli değil. Grubun yöneticisinden yeni bir bağlantı isteyebilirsin.',
            actionLabel: value == null ? 'Grupları keşfet' : 'Grubu gör',
            onAction: () => context.go(value == null ? GroupRoutes.discover : GroupRoutes.group(value.handle)),
          ),
        AsyncData(value: final preview?) => ListView(
            padding: const EdgeInsets.only(bottom: GwSpacing.xl),
            children: [
              GwHeroCard(
                name: preview.name,
                subtitle: '@${preview.handle}',
                shape: GwAvatarShape.group,
                coverUrl: preview.coverUrl,
                avatarUrl: preview.logoUrl,
                coverIcon: categoryIcon(preview.categorySlug),
                children: [
                  Text('Bu gruba davet edildin.', style: textTheme.titleMedium),
                  if (preview.about.isNotEmpty) Text(preview.about, style: textTheme.bodyLarge),
                  GroupMeta(icon: Icons.people_outline, text: memberCountLabel(preview.memberCount)),
                  if (_error != null) GwFormMessage(_error!),
                  GwButton(label: 'Gruba katıl', icon: Icons.group_add_outlined, isLoading: _joining, onPressed: _join),
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
