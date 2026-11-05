import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/calls.dart';
import '../l10n.dart';
import 'call_providers.dart';

/// The way into a group's voice call requests, with the waiting count; nothing for those who cannot decide.
class GroupCallRequestsEntry extends ConsumerWidget {
  const GroupCallRequestsEntry({super.key, required this.groupId, required this.onOpen});

  final String groupId;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final desk = ref.watch(groupCallDeskProvider(groupId)).value;
    if (desk == null) return const SizedBox.shrink();
    final pending = desk.pending.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(GwSpacing.page, GwSpacing.sm, GwSpacing.page, 0),
      child: Material(
        color: GwColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: GwRadius.lgAll,
          side: BorderSide(color: GwColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: onOpen,
          leading: const Icon(Icons.call_outlined, color: GwColors.primary),
          title: Text(messagingL10n.callRequests, style: Theme.of(context).textTheme.labelLarge),
          subtitle: Text(pending == 0 ? messagingL10n.noPendingWithActive(desk.active.length) : messagingL10n.pendingCount(pending)),
          trailing: pending > 0 ? GwBadge('$pending', tone: GwBadgeTone.danger) : const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}

/// `/g/<handle>/calls`: the owner and calls.manage holders open, decline and close members' voice calls
/// (docs/ARCHITECTURE.md §8c).
class GroupCallRequestsScreen extends ConsumerWidget {
  const GroupCallRequestsScreen({super.key, required this.groupId, required this.groupName});

  final String groupId;
  final String groupName;

  @override
  Widget build(BuildContext context, WidgetRef ref) => DefaultTabController(
    length: 2,
    child: Scaffold(
      appBar: AppBar(
        title: Text(messagingL10n.callRequests),
        bottom: TabBar(
          tabs: [
            Tab(text: messagingL10n.pending),
            Tab(text: messagingL10n.activeTab),
          ],
        ),
      ),
      body: GwReadingColumn(
        child: switch (ref.watch(groupCallDeskProvider(groupId))) {
          AsyncData(value: null) => GwEmptyState(
            icon: Icons.lock_outline,
            message: messagingL10n.requestsOwnersOnly,
            actionLabel: messagingL10n.goBack,
            onAction: () => Navigator.of(context).maybePop(),
          ),
          AsyncData(value: final GroupCallDesk desk) => TabBarView(
            children: [
              _List(
                groupId: groupId,
                desk: desk,
                items: desk.pending,
                empty: messagingL10n.noPendingFor(groupName),
              ),
              _List(groupId: groupId, desk: desk, items: desk.active, empty: messagingL10n.noActive),
            ],
          ),
          AsyncError(:final error) => GwErrorState(
            message: userMessageOf(error),
            onRetry: () => ref.invalidate(groupCallDeskProvider(groupId)),
          ),
          _ => const Padding(
            padding: EdgeInsets.all(GwSpacing.page),
            child: GwSkeleton(height: GwSpacing.xxl * 3),
          ),
        },
      ),
    ),
  );
}

class _List extends ConsumerWidget {
  const _List({required this.groupId, required this.desk, required this.items, required this.empty});

  final String groupId;
  final GroupCallDesk desk;
  final List<GroupCallRequest> items;
  final String empty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return GwEmptyState(
        icon: Icons.call_outlined,
        message: empty,
        actionLabel: messagingL10n.refresh,
        onAction: () => ref.invalidate(groupCallDeskProvider(groupId)),
      );
    }
    return RefreshIndicator(
      onRefresh: () => ref.refresh(groupCallDeskProvider(groupId).future),
      child: ListView(
        padding: const EdgeInsets.all(GwSpacing.page),
        children: [
          Text(
            messagingL10n.grantHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: GwColors.textSecondary),
          ),
          const SizedBox(height: GwSpacing.md),
          for (final item in items) ...[
            _Card(groupId: groupId, item: item, canClose: desk.rank > item.rank),
            const SizedBox(height: GwSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _Card extends ConsumerStatefulWidget {
  const _Card({required this.groupId, required this.item, required this.canClose});

  final String groupId;
  final GroupCallRequest item;

  /// Declining and closing follow the rank rule.
  final bool canClose;

  @override
  ConsumerState<_Card> createState() => _CardState();
}

class _CardState extends ConsumerState<_Card> {
  bool _busy = false;

  Future<void> _decide({required bool active}) async {
    String? reason;
    if (!active) {
      reason = await _askReason(context, pending: widget.item.status == CallPermissionStatus.requested);
      if (reason == null || !mounted) return;
    }
    setState(() => _busy = true);
    final result = await ref.read(callsRepositoryProvider).decide(widget.groupId, widget.item.userId, active: active, reason: reason);
    if (!mounted) return;
    setState(() => _busy = false);
    final messenger = ScaffoldMessenger.of(context);
    switch (result) {
      case Ok():
        ref.invalidate(groupCallDeskProvider(widget.groupId));
        messenger.showSnackBar(SnackBar(content: Text(active ? messagingL10n.granted : messagingL10n.turnedOff)));
      case Err(:final failure):
        messenger.showSnackBar(SnackBar(content: Text(failure.userMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final secondary = Theme.of(context).textTheme.bodySmall?.copyWith(color: GwColors.textSecondary);
    final pending = item.status == CallPermissionStatus.requested;
    final at = pending ? item.requestedAt : item.decidedAt;
    return GwCard(
      padding: const EdgeInsets.all(GwSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              GwAvatar(name: item.displayName, imageUrl: item.avatarUrl, shape: GwAvatarShape.user, size: GwAvatarSize.sm),
              const SizedBox(width: GwSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.displayName, style: Theme.of(context).textTheme.labelLarge),
                    Text([atName(item.username), if (at != null) formatDateTime(at)].join(' · '), style: secondary),
                  ],
                ),
              ),
            ],
          ),
          if (item.note case final note? when pending) ...[const SizedBox(height: GwSpacing.xs), Text(messagingL10n.theirNote(note))],
          const SizedBox(height: GwSpacing.sm),
          Wrap(
            spacing: GwSpacing.xs,
            runSpacing: GwSpacing.xs,
            alignment: WrapAlignment.end,
            children: [
              if (widget.canClose)
                GwButton(
                  label: pending ? messagingL10n.decline : messagingL10n.turnOff,
                  variant: GwButtonVariant.secondary,
                  onPressed: _busy ? null : () => _decide(active: false),
                ),
              if (pending) GwButton(label: messagingL10n.turnOn, icon: Icons.call_outlined, isLoading: _busy, onPressed: () => _decide(active: true)),
            ],
          ),
          if (!widget.canClose)
            Padding(
              padding: const EdgeInsets.only(top: GwSpacing.xs),
              child: Text(
                pending
                    ? messagingL10n.rankOnlyGrant
                    : messagingL10n.rankCannotRevoke,
                style: secondary,
              ),
            ),
        ],
      ),
    );
  }
}

/// The reason for declining or closing (3–500 characters); null when cancelled.
Future<String?> _askReason(BuildContext context, {required bool pending}) => showModalBottomSheet<String>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  builder: (_) => _ReasonSheet(pending: pending),
);

class _ReasonSheet extends StatefulWidget {
  const _ReasonSheet({required this.pending});

  final bool pending;

  @override
  State<_ReasonSheet> createState() => _ReasonSheetState();
}

class _ReasonSheetState extends State<_ReasonSheet> {
  final _form = GlobalKey<FormState>();
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(GwSpacing.page, 0, GwSpacing.page, GwSpacing.lg + MediaQuery.viewInsetsOf(context).bottom),
    child: Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.pending ? messagingL10n.declineRequest : messagingL10n.turnOffCalls, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: GwSpacing.xxs),
          Text(
            widget.pending
                ? messagingL10n.declineHint
                : messagingL10n.revokeHint,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary),
          ),
          const SizedBox(height: GwSpacing.md),
          TextFormField(
            controller: _reason,
            maxLength: 500,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(labelText: messagingL10n.reason),
            validator: (v) => (v ?? '').trim().length < 3 ? messagingL10n.reasonMin3 : null,
          ),
          const SizedBox(height: GwSpacing.sm),
          GwButton(
            label: widget.pending ? messagingL10n.decline : messagingL10n.turnOff,
            expand: true,
            onPressed: () {
              if (_form.currentState!.validate()) Navigator.of(context).pop(_reason.text.trim());
            },
          ),
        ],
      ),
    ),
  );
}
