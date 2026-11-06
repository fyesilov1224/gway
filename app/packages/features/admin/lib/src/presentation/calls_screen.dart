import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/admin_calls.dart';
import 'admin_shell.dart';
import 'providers.dart';
import 'routes.dart';
import 'widgets.dart';

// docs/ARCHITECTURE.md §8c, Admin: Sesli görüşme sekmesi. Every request and permission with the group it went to and who
// decided; the platform team opens, declines and closes beside the groups. Calls themselves are never shown.

const _reasonMin = 3;
const _reasonMax = 500;

/// "3 gün", "5 saat", "12 dakika": how long ago.
String _since(DateTime at) {
  final d = DateTime.now().difference(at);
  if (d.inDays >= 1) return '${d.inDays} gün';
  if (d.inHours >= 1) return '${d.inHours} saat';
  return '${d.inMinutes < 1 ? 1 : d.inMinutes} dakika';
}

/// "3 gündür bekliyor", "5 saattir bekliyor", "12 dakikadır bekliyor".
String _waiting(DateTime at) {
  final d = DateTime.now().difference(at);
  if (d.inDays >= 1) return '${d.inDays} gündür bekliyor';
  if (d.inHours >= 1) return '${d.inHours} saattir bekliyor';
  return '${d.inMinutes < 1 ? 1 : d.inMinutes} dakikadır bekliyor';
}

GwBadgeTone _tone(AdminCallPermissionStatus s) => switch (s) {
      AdminCallPermissionStatus.requested => GwBadgeTone.warning,
      AdminCallPermissionStatus.active => GwBadgeTone.success,
      AdminCallPermissionStatus.declined => GwBadgeTone.neutral,
      AdminCallPermissionStatus.revoked => GwBadgeTone.danger,
    };

/// The decision the platform team can take on a permission in [status] (null: never asked).
enum _Decision {
  open('Aç', 'Sesli görüşme açıldı.'),
  reopen('Yeniden aç', 'Sesli görüşme yeniden açıldı.'),
  decline('Reddet', 'Talep reddedildi.'),
  close('Kapat', 'Sesli görüşme kapatıldı.');

  const _Decision(this.label, this.done);

  final String label;
  final String done;

  bool get opens => this == open || this == reopen;

  static List<_Decision> forStatus(AdminCallPermissionStatus? status) => switch (status) {
        null => const [open],
        AdminCallPermissionStatus.requested => const [open, decline],
        AdminCallPermissionStatus.active => const [close],
        AdminCallPermissionStatus.declined || AdminCallPermissionStatus.revoked => const [reopen],
      };
}

/// Asks for the reason of a decline or close (3–500, the person sees it). Null when cancelled.
Future<String?> _askReason(BuildContext context, {required _Decision decision, required String name}) => showDialog<String>(
      context: context,
      builder: (_) => _ReasonDialog(decision: decision, name: name),
    );

class _ReasonDialog extends StatefulWidget {
  const _ReasonDialog({required this.decision, required this.name});

  final _Decision decision;
  final String name;

  @override
  State<_ReasonDialog> createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<_ReasonDialog> {
  final _form = GlobalKey<FormState>();
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  void _confirm() {
    if (_form.currentState!.validate()) Navigator.of(context).pop(_reason.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final declining = widget.decision == _Decision.decline;
    return AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: GwRadius.xlAll),
      title: Text(declining ? 'Talebi reddet' : 'Sesli görüşmeyi kapat'),
      content: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(declining
                  ? '${widget.name} talebinin reddedildiğini ve gerekçeyi görür; 7 gün sonra yeniden talep edebilir.'
                  : '${widget.name} artık arama yapamaz ve aranamaz; süren görüşmesi hemen biter. Gerekçeyi görür, '
                      '7 gün sonra yeniden talep edebilir.'),
              const SizedBox(height: GwSpacing.md),
              TextFormField(
                controller: _reason,
                autofocus: true,
                maxLength: _reasonMax,
                minLines: 2,
                maxLines: 4,
                validator: (v) =>
                    (v ?? '').trim().length < _reasonMin ? 'Gerekçe en az $_reasonMin karakter olmalı.' : null,
                decoration: const InputDecoration(labelText: 'Gerekçe', alignLabelWithHint: true),
              ),
            ],
          ),
        ),
      ),
      actions: [
        GwButton(label: 'Vazgeç', variant: GwButtonVariant.text, onPressed: () => Navigator.of(context).pop()),
        GwButton(label: widget.decision.label, onPressed: _confirm),
      ],
    );
  }
}

/// Runs [decision] for a person: asks the reason when needed, refreshes the lists. Null when cancelled; otherwise the
/// sentence to show. [onBusy] wraps only the request, not the dialog.
Future<String?> _decide(
  BuildContext context,
  WidgetRef ref, {
  required String userId,
  required String name,
  required _Decision decision,
  required ValueChanged<bool> onBusy,
}) async {
  String? reason;
  if (!decision.opens) {
    reason = await _askReason(context, decision: decision, name: name);
    if (reason == null) return null;
  }
  onBusy(true);
  final result =
      await ref.read(adminCallsRepositoryProvider).setPermission(userId, active: decision.opens, reason: reason);
  onBusy(false);
  ref
    ..invalidate(callPermissionsProvider)
    ..invalidate(callUserProvider(userId));
  return switch (result) {
    Ok() => decision.done,
    Err(:final failure) => failure.userMessage,
  };
}

void _snack(BuildContext context, String message) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

// ---------------------------------------------------------------------------

class AdminCallsScreen extends ConsumerStatefulWidget {
  const AdminCallsScreen({super.key});

  @override
  ConsumerState<AdminCallsScreen> createState() => _AdminCallsScreenState();
}

class _AdminCallsScreenState extends ConsumerState<AdminCallsScreen> {
  final _search = TextEditingController();
  Timer? _debounce;
  String _query = '';
  AdminCallPermissionStatus? _status = AdminCallPermissionStatus.requested;
  int _page = 1;

  AdminCallQuery get _key => (status: _status, query: _query, page: _page);

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
        _page = 1;
      });
    });
  }

  void _setStatus(AdminCallPermissionStatus? status) => setState(() {
        _status = status;
        _page = 1;
      });

  void _clear() {
    _search.clear();
    _debounce?.cancel();
    setState(() {
      _query = '';
      _page = 1;
    });
  }

  Future<void> _grant() async {
    final message = await showDialog<String>(context: context, builder: (_) => const _GrantDialog());
    if (message != null && mounted) _snack(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(callPermissionsProvider(_key));
    final canAct = ref.watch(myStaffRoleProvider).value?.canManageCalls ?? false;
    final summary = result.value?.summary;
    return AdminPage(
      title: 'Sesli görüşme',
      subtitle: 'Kimin sesli görüşme yetkisi var, kim hangi grubun bekleme alanında, kararı kim verdi. Talepleri '
          'açar, reddeder, yetkileri kapatırsın. Görüşmeler kaydedilmez; kimin kimi aradığı burada görünmez.',
      actions: [
        if (canAct) GwButton(label: 'Kişiye aç', icon: Icons.person_add_alt_1_outlined, onPressed: _grant),
        GwButton(
          label: 'Yenile',
          icon: Icons.refresh,
          variant: GwButtonVariant.secondary,
          onPressed: () => ref.invalidate(callPermissionsProvider),
        ),
      ],
      children: [
        StatCardRow(
          cards: [
            for (final (status, icon) in [
              (AdminCallPermissionStatus.requested, Icons.hourglass_top_outlined),
              (AdminCallPermissionStatus.active, Icons.call_outlined),
              (AdminCallPermissionStatus.declined, Icons.do_not_disturb_on_outlined),
              (AdminCallPermissionStatus.revoked, Icons.phone_disabled_outlined),
            ])
              StatCard(
                label: status.label,
                value: summary?.count(status),
                icon: icon,
                tone: _tone(status),
                selected: _status == status,
                onTap: () => _setStatus(status),
              ),
          ],
        ),
        const SizedBox(height: GwSpacing.md),
        StatCardRow(
          wideColumns: 3,
          cards: [
            StatCard(
              label: 'En uzun bekleyen talep',
              value: summary == null ? null : 0,
              valueText: summary == null
                  ? null
                  : switch (summary.oldestRequestAt) {
                      final at? => _since(at),
                      null => 'Yok',
                    },
              icon: Icons.schedule,
              tone: GwBadgeTone.warning,
              onTap: () => _setStatus(AdminCallPermissionStatus.requested),
            ),
            StatCard(
              label: 'Son 24 saatte görüşme',
              value: summary?.calls24h,
              icon: Icons.ring_volume_outlined,
              tone: GwBadgeTone.primary,
            ),
            StatCard(
              label: 'Son 24 saatte dakika',
              value: summary?.minutes24h,
              icon: Icons.timer_outlined,
              tone: GwBadgeTone.info,
            ),
          ],
        ),
        const SizedBox(height: GwSpacing.lg),
        GwPanel(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListToolbar<AdminCallPermissionStatus>(
                controller: _search,
                hint: 'Ad, @kullanıcı adı veya grup adıyla ara',
                query: _query,
                filters: [for (final s in AdminCallPermissionStatus.values) (s, s.label)],
                selected: _status,
                onSearchChanged: _onSearchChanged,
                onFilterChanged: _setStatus,
                onClear: _clear,
              ),
              const Divider(),
              switch (result) {
                AsyncData(:final value) when value.items.isEmpty => Padding(
                    padding: const EdgeInsets.symmetric(vertical: GwSpacing.xl),
                    child: _query.isNotEmpty
                        ? GwEmptyState(
                            icon: Icons.search_off,
                            message: 'Aramana uygun kişi bulunamadı.',
                            actionLabel: 'Aramayı temizle',
                            onAction: _clear,
                          )
                        : GwEmptyState(
                            icon: Icons.call_outlined,
                            message: _status == AdminCallPermissionStatus.requested
                                ? 'Bekleyen talep yok.'
                                : 'Bu listede kimse yok.',
                            actionLabel: 'Tümünü göster',
                            onAction: () => _setStatus(null),
                          ),
                  ),
                AsyncData(:final value) => _PermissionTable(
                    page: value,
                    canAct: canAct,
                    onPage: (p) => setState(() => _page = p),
                  ),
                AsyncError(:final error) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: GwSpacing.xl),
                    child: GwErrorState(
                      message: userMessageOf(error),
                      onRetry: () => ref.invalidate(callPermissionsProvider(_key)),
                    ),
                  ),
                _ => const _TableSkeleton(),
              },
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

/// Column flex values of the wide table: person, state, group, request, decision, actions.
const _columns = [4, 2, 3, 2, 3, 4];

class _PermissionTable extends StatelessWidget {
  const _PermissionTable({required this.page, required this.canAct, required this.onPage});

  final AdminCallPermissionsPage page;
  final bool canAct;
  final ValueChanged<int> onPage;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final (from, to) = page.range;
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= GwLayout.contentMaxWidth;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (wide) ...[
              Container(
                color: GwColors.surface,
                padding: const EdgeInsets.symmetric(horizontal: GwSpacing.lg, vertical: GwSpacing.sm),
                child: Row(
                  children: [
                    for (final (i, label) in ['KİŞİ', 'DURUM', 'GRUP', 'TALEP', 'KARAR', ''].indexed)
                      Expanded(
                        flex: _columns[i],
                        child: Text(
                          label,
                          style: textTheme.labelMedium?.copyWith(color: GwColors.textSecondary, letterSpacing: 0.6),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(),
            ],
            for (final p in page.items) ...[
              _PermissionRow(permission: p, wide: wide, canAct: canAct),
              const Divider(),
            ],
            PageFooter(
              from: from,
              to: to,
              total: page.total,
              noun: 'kişi',
              page: page.page,
              pageCount: page.pageCount,
              onPage: onPage,
            ),
          ],
        );
      },
    );
  }
}

/// The group cell: its name (to the group's panel page) with a suspended tag, or "Platform ekibi".
class _GroupCell extends StatelessWidget {
  const _GroupCell({required this.permission});

  final AdminCallPermission permission;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final group = permission.group;
    if (group == null) {
      return Text('Platform ekibi', style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary));
    }
    return Wrap(
      spacing: GwSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        InkWell(
          onTap: () => context.go(AdminRoutes.group(group.id)),
          child: Text(
            group.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(color: GwColors.secondary),
          ),
        ),
        if (group.suspended) const GwBadge('Askıda', tone: GwBadgeTone.danger),
      ],
    );
  }
}

/// "Grup sahibi · Ayşe" with the date; "Kendiliğinden" when the person left the group.
String? _decisionText(AdminCallPermission p) {
  final by = p.decidedBy;
  final at = p.decidedAt;
  if (by == null || at == null) return null;
  final who = switch (by.kind) {
    AdminCallDeciderKind.system => 'Gruptan ayrıldı',
    _ => '${by.kind.label}${by.displayName == null ? '' : ' · ${by.displayName}'}',
  };
  return '$who\n${formatDateTime(at)}';
}

class _PermissionRow extends ConsumerStatefulWidget {
  const _PermissionRow({required this.permission, required this.wide, required this.canAct});

  final AdminCallPermission permission;
  final bool wide;
  final bool canAct;

  @override
  ConsumerState<_PermissionRow> createState() => _PermissionRowState();
}

class _PermissionRowState extends ConsumerState<_PermissionRow> {
  bool _busy = false;

  Future<void> _run(_Decision decision) async {
    final p = widget.permission;
    final message = await _decide(
      context,
      ref,
      userId: p.userId,
      name: p.displayName,
      decision: decision,
      onBusy: (busy) {
        if (mounted) setState(() => _busy = busy);
      },
    );
    if (message != null && mounted) _snack(context, message);
  }

  void _openDetail() => showDialog<void>(
        context: context,
        builder: (_) => CallPermissionDetailDialog(userId: widget.permission.userId),
      );

  @override
  Widget build(BuildContext context) {
    final p = widget.permission;
    final textTheme = Theme.of(context).textTheme;
    final secondary = textTheme.bodySmall?.copyWith(color: GwColors.textSecondary);
    final waiting = p.status == AdminCallPermissionStatus.requested ? p.requestedAt : null;

    final identity = Row(
      children: [
        GwAvatar(name: p.displayName, shape: GwAvatarShape.user, imageUrl: ref.watch(avatarUrlProvider(p.avatarPath))),
        const SizedBox(width: GwSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.displayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.labelLarge),
              Text('@${p.username}', maxLines: 1, overflow: TextOverflow.ellipsis, style: secondary),
              if (p.note case final note? when p.status == AdminCallPermissionStatus.requested)
                Text('“$note”', maxLines: 2, overflow: TextOverflow.ellipsis, style: secondary?.copyWith(fontStyle: FontStyle.italic)),
            ],
          ),
        ),
      ],
    );
    final request = p.requestedAt == null
        ? Text('—', style: secondary)
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(formatDateTime(p.requestedAt!), style: textTheme.bodySmall),
              if (waiting != null)
                Text(_waiting(waiting), style: textTheme.bodySmall?.copyWith(color: GwColors.warning)),
            ],
          );
    final decision = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_decisionText(p) ?? '—', style: textTheme.bodySmall),
        if (p.reason case final reason? when p.status != AdminCallPermissionStatus.active)
          Text('Gerekçe: $reason', maxLines: 2, overflow: TextOverflow.ellipsis, style: secondary),
      ],
    );
    final actions = Wrap(
      spacing: GwSpacing.xs,
      runSpacing: GwSpacing.xs,
      alignment: widget.wide ? WrapAlignment.end : WrapAlignment.start,
      children: [
        if (widget.canAct)
          for (final d in _Decision.forStatus(p.status))
            GwButton(
              label: d.label,
              variant: d.opens ? GwButtonVariant.primary : GwButtonVariant.secondary,
              isLoading: _busy && d == _Decision.forStatus(p.status).first,
              onPressed: _busy ? null : () => _run(d),
            ),
        IconButton(tooltip: 'Ayrıntı ve geçmiş', icon: const Icon(Icons.history), onPressed: _openDetail),
      ],
    );
    final status = GwBadge(p.status.label, tone: _tone(p.status), dot: true);

    return InkWell(
      onTap: _openDetail,
      hoverColor: GwColors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: GwSpacing.lg, vertical: GwSpacing.sm),
        child: widget.wide
            ? Row(
                children: [
                  Expanded(flex: _columns[0], child: identity),
                  Expanded(flex: _columns[1], child: Align(alignment: Alignment.centerLeft, child: status)),
                  Expanded(flex: _columns[2], child: _GroupCell(permission: p)),
                  Expanded(flex: _columns[3], child: request),
                  Expanded(flex: _columns[4], child: decision),
                  Expanded(flex: _columns[5], child: actions),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [Expanded(child: identity), status]),
                  const SizedBox(height: GwSpacing.xs),
                  Row(
                    children: [
                      Text('Grup: ', style: secondary),
                      Flexible(child: _GroupCell(permission: p)),
                    ],
                  ),
                  if (p.requestedAt != null) ...[const SizedBox(height: GwSpacing.xxs), request],
                  if (_decisionText(p) != null) ...[const SizedBox(height: GwSpacing.xxs), decision],
                  const SizedBox(height: GwSpacing.xs),
                  actions,
                ],
              ),
      ),
    );
  }
}

class _TableSkeleton extends StatelessWidget {
  const _TableSkeleton();

  @override
  Widget build(BuildContext context) => Column(
        children: [
          for (var i = 0; i < 6; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: GwSpacing.lg, vertical: GwSpacing.sm),
              child: Row(
                children: [
                  GwSkeleton.circle(size: GwAvatarSize.md.dimension),
                  const SizedBox(width: GwSpacing.sm),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GwSkeleton(width: GwSpacing.xxl * 3, height: GwSpacing.md),
                        SizedBox(height: GwSpacing.xs),
                        GwSkeleton(width: GwSpacing.xxl * 2, height: GwSpacing.sm),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
}

// ---------------------------------------------------------------------------

/// Opens voice calls for someone who never asked, by username. Pops with the sentence to show.
class _GrantDialog extends ConsumerStatefulWidget {
  const _GrantDialog();

  @override
  ConsumerState<_GrantDialog> createState() => _GrantDialogState();
}

class _GrantDialogState extends ConsumerState<_GrantDialog> {
  final _form = GlobalKey<FormState>();
  final _username = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ref.read(adminCallsRepositoryProvider).grant(_username.text.trim());
    if (!mounted) return;
    switch (result) {
      case Ok():
        ref.invalidate(callPermissionsProvider);
        Navigator.of(context).pop('Sesli görüşme açıldı.');
      case Err(:final failure):
        setState(() {
          _busy = false;
          _error = failure.userMessage;
        });
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: GwRadius.xlAll),
        title: const Text('Kişiye sesli görüşme aç'),
        content: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Talep etmemiş birine doğrudan açılır. Yetki bir gruba bağlı olmaz; kişi gruptan ayrılsa da '
                  'sürer. Kişiye bildirim gider.'),
              const SizedBox(height: GwSpacing.md),
              TextFormField(
                controller: _username,
                autofocus: true,
                onFieldSubmitted: (_) => _busy ? null : _confirm(),
                validator: (v) => (v ?? '').trim().replaceFirst('@', '').isEmpty ? 'Kullanıcı adını yaz.' : null,
                decoration: const InputDecoration(labelText: 'Kullanıcı adı', prefixText: '@'),
              ),
              if (_error case final error?) ...[const SizedBox(height: GwSpacing.sm), GwFormMessage(error)],
            ],
          ),
        ),
        actions: [
          GwButton(label: 'Vazgeç', variant: GwButtonVariant.text, onPressed: () => Navigator.of(context).pop()),
          GwButton(label: 'Aç', isLoading: _busy, onPressed: _busy ? null : _confirm),
        ],
      );
}

// ---------------------------------------------------------------------------

/// A person's permission in full and its history of decisions.
class CallPermissionDetailDialog extends ConsumerWidget {
  const CallPermissionDetailDialog({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Dialog(
        shape: const RoundedRectangleBorder(borderRadius: GwRadius.xlAll),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: GwLayout.formMaxWidth),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(GwSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Sesli görüşme yetkisi', style: Theme.of(context).textTheme.titleLarge)),
                    IconButton(
                      tooltip: 'Kapat',
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: GwSpacing.sm),
                CallPermissionDetail(userId: userId, showProfileLink: true),
              ],
            ),
          ),
        ),
      );
}

/// The permission card (status, group, request, decision, actions) and the history; on the user page too.
class CallPermissionDetail extends ConsumerStatefulWidget {
  const CallPermissionDetail({super.key, required this.userId, this.showProfileLink = false});

  final String userId;
  final bool showProfileLink;

  @override
  ConsumerState<CallPermissionDetail> createState() => _CallPermissionDetailState();
}

class _CallPermissionDetailState extends ConsumerState<CallPermissionDetail> {
  bool _busy = false;

  Future<void> _run(String name, _Decision decision) async {
    final message = await _decide(
      context,
      ref,
      userId: widget.userId,
      name: name,
      decision: decision,
      onBusy: (busy) {
        if (mounted) setState(() => _busy = busy);
      },
    );
    if (message != null && mounted) _snack(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final canAct = ref.watch(myStaffRoleProvider).value?.canManageCalls ?? false;
    final textTheme = Theme.of(context).textTheme;
    final secondary = textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary);
    return switch (ref.watch(callUserProvider(widget.userId))) {
      AsyncData(:final value) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.showProfileLink)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  icon: const Icon(Icons.person_outline),
                  label: Text('${value.displayName} (@${value.username})'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go(AdminRoutes.user(value.userId));
                  },
                ),
              ),
            ..._facts(context, value.permission, secondary),
            if (canAct) ...[
              const SizedBox(height: GwSpacing.md),
              Wrap(
                spacing: GwSpacing.xs,
                runSpacing: GwSpacing.xs,
                children: [
                  for (final d in _Decision.forStatus(value.permission?.status))
                    GwButton(
                      label: d.label,
                      variant: d.opens ? GwButtonVariant.primary : GwButtonVariant.secondary,
                      isLoading: _busy && d == _Decision.forStatus(value.permission?.status).first,
                      onPressed: _busy ? null : () => _run(value.displayName, d),
                    ),
                ],
              ),
            ],
            const SizedBox(height: GwSpacing.lg),
            Text('Geçmiş', style: textTheme.titleMedium),
            const SizedBox(height: GwSpacing.xs),
            if (value.history.isEmpty)
              Text('Henüz karar verilmedi.', style: secondary)
            else
              for (final e in value.history) _HistoryLine(event: e),
          ],
        ),
      AsyncError(:final error) => GwErrorState(
          message: userMessageOf(error),
          onRetry: () => ref.invalidate(callUserProvider(widget.userId)),
        ),
      _ => const GwSkeleton(height: GwSpacing.xxl * 2),
    };
  }

  List<Widget> _facts(BuildContext context, AdminCallPermission? p, TextStyle? secondary) {
    if (p == null) {
      return [
        const Align(alignment: Alignment.centerLeft, child: GwBadge('Talep etmedi', dot: true)),
        const SizedBox(height: GwSpacing.xs),
        Text('Bu kişi sesli görüşme yetkisi istemedi. Kişiye doğrudan açabilirsin.', style: secondary),
      ];
    }
    final decision = _decisionText(p)?.replaceAll('\n', ', ');
    return [
      Align(alignment: Alignment.centerLeft, child: GwBadge(p.status.label, tone: _tone(p.status), dot: true)),
      const SizedBox(height: GwSpacing.sm),
      _Fact(label: 'Grup', child: _GroupCell(permission: p)),
      if (p.note case final note?) _Fact(label: 'Kişinin notu', text: '“$note”'),
      if (p.requestedAt case final at?)
        _Fact(
          label: 'Talep',
          text: p.status == AdminCallPermissionStatus.requested
              ? '${formatDateTime(at)} (${_waiting(at)})'
              : formatDateTime(at),
        ),
      if (decision != null) _Fact(label: 'Karar', text: decision),
      if (p.reason case final reason? when p.status != AdminCallPermissionStatus.active) _Fact(label: 'Gerekçe', text: reason),
      if (p.group?.suspended ?? false)
        const _Fact(label: 'Not', text: 'Grup askıda olduğu için bu yetki şu an geçmiyor.'),
    ];
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, this.text, this.child});

  final String label;
  final String? text;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: GwSpacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: GwSpacing.xxl * 2 + GwSpacing.md,
            child: Text(label, style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
          ),
          Expanded(child: child ?? Text(text ?? '—', style: textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _HistoryLine extends StatelessWidget {
  const _HistoryLine({required this.event});

  final AdminCallEvent event;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final secondary = textTheme.bodySmall?.copyWith(color: GwColors.textSecondary);
    final who = [
      event.byStaff ? 'Platform ekibi' : 'Grup yöneticisi',
      ?event.actorDisplayName,
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: GwSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            switch (event.action) {
              'call_permission.granted' => Icons.check_circle_outline,
              'call_permission.declined' => Icons.do_not_disturb_on_outlined,
              _ => Icons.phone_disabled_outlined,
            },
            size: GwSpacing.lg,
            color: GwColors.textSecondary,
          ),
          const SizedBox(width: GwSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.label, style: textTheme.labelLarge),
                Text('${formatDateTime(event.at)} · $who', style: secondary),
                if (event.groupName case final group?) Text('Grup: $group', style: secondary),
                if (event.reason case final reason?) Text('Gerekçe: $reason', style: secondary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The voice call card on a user's page (docs/ARCHITECTURE.md §8c, Admin). Their calls are not shown.
class UserCallPermissionPanel extends StatelessWidget {
  const UserCallPermissionPanel({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) => GwPanel(title: 'Sesli görüşme', child: CallPermissionDetail(userId: userId));
}
