import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/calls.dart';
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
          title: Text('Sesli görüşme talepleri', style: Theme.of(context).textTheme.labelLarge),
          subtitle: Text(pending == 0 ? 'Bekleyen talep yok · ${desk.active.length} açık yetki' : '$pending talep bekliyor'),
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
        title: const Text('Sesli görüşme talepleri'),
        bottom: const TabBar(
          tabs: [
            Tab(text: 'Bekleyen'),
            Tab(text: 'Açık'),
          ],
        ),
      ),
      body: GwReadingColumn(
        child: switch (ref.watch(groupCallDeskProvider(groupId))) {
          AsyncData(value: null) => GwEmptyState(
            icon: Icons.lock_outline,
            message: 'Sesli görüşme taleplerini grup sahibi ve Yöneticiler görür.',
            actionLabel: 'Geri dön',
            onAction: () => Navigator.of(context).maybePop(),
          ),
          AsyncData(value: final GroupCallDesk desk) => TabBarView(
            children: [
              _List(
                groupId: groupId,
                desk: desk,
                items: desk.pending,
                empty: 'Bekleyen talep yok. $groupName üyeleri talep edince burada görünür.',
              ),
              _List(groupId: groupId, desk: desk, items: desk.active, empty: 'Bu grubun açtığı sesli görüşme yetkisi yok.'),
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
        actionLabel: 'Yenile',
        onAction: () => ref.invalidate(groupCallDeskProvider(groupId)),
      );
    }
    return RefreshIndicator(
      onRefresh: () => ref.refresh(groupCallDeskProvider(groupId).future),
      child: ListView(
        padding: const EdgeInsets.all(GwSpacing.page),
        children: [
          Text(
            'Açtığın yetkiyle kişi eşleştiği ve ekip arkadaşı olduğu herkesi sesli arayabilir. Görüşmeler kaydedilmez; '
            'kişi gruptan ayrılırsa yetki kapanır.',
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
        messenger.showSnackBar(SnackBar(content: Text(active ? 'Sesli görüşme açıldı.' : 'Sesli görüşme kapatıldı.')));
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
                    Text(['@${item.username}', if (at != null) formatDateTimeTr(at)].join(' · '), style: secondary),
                  ],
                ),
              ),
            ],
          ),
          if (item.note case final note? when pending) ...[const SizedBox(height: GwSpacing.xs), Text('Notu: $note')],
          const SizedBox(height: GwSpacing.sm),
          Wrap(
            spacing: GwSpacing.xs,
            runSpacing: GwSpacing.xs,
            alignment: WrapAlignment.end,
            children: [
              if (widget.canClose)
                GwButton(
                  label: pending ? 'Reddet' : 'Kapat',
                  variant: GwButtonVariant.secondary,
                  onPressed: _busy ? null : () => _decide(active: false),
                ),
              if (pending) GwButton(label: 'Aç', icon: Icons.call_outlined, isLoading: _busy, onPressed: () => _decide(active: true)),
            ],
          ),
          if (!widget.canClose)
            Padding(
              padding: const EdgeInsets.only(top: GwSpacing.xs),
              child: Text(
                pending
                    ? 'Rütbesi seninkine eşit ya da yüksek olduğu için bu talebi yalnızca açabilirsin.'
                    : 'Rütbesi seninkine eşit ya da yüksek olduğu için bu yetkiyi kapatamazsın.',
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
          Text(widget.pending ? 'Talebi reddet' : 'Sesli görüşmeyi kapat', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: GwSpacing.xxs),
          Text(
            widget.pending
                ? 'Kişi gerekçeyi görür ve 7 gün sonra yeniden talep edebilir.'
                : 'Kişinin süren görüşmesi hemen biter. Gerekçeyi görür ve 7 gün sonra yeniden talep edebilir.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary),
          ),
          const SizedBox(height: GwSpacing.md),
          TextFormField(
            controller: _reason,
            maxLength: 500,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Gerekçe'),
            validator: (v) => (v ?? '').trim().length < 3 ? 'Gerekçe en az 3 karakter olmalı.' : null,
          ),
          const SizedBox(height: GwSpacing.sm),
          GwButton(
            label: widget.pending ? 'Reddet' : 'Kapat',
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
