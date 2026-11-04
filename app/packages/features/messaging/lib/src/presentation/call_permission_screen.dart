import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/calls.dart';
import 'call_providers.dart';

/// Settings → Sesli görüşme: ask one of the person's groups for voice calls and see the decision (docs/ARCHITECTURE.md §8c).
class CallPermissionScreen extends ConsumerWidget {
  const CallPermissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(title: const Text('Sesli görüşme')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: GwLayout.contentMaxWidth),
            child: ListView(
              padding: const EdgeInsets.all(GwSpacing.page),
              children: [
                GwPanel(
                  title: 'Eşleştiğin kişilerle ve ekip arkadaşlarınla sesli konuş',
                  child: Text(
                    'Sesli görüşme, eşleştiğin kişileri ve ekip arkadaşlarını özel sohbetten aramanı sağlar. Herkese açık değildir: üyesi '
                    'olduğun bir gruptan talep edersin, grubun sahibi ya da Yöneticisi açar. Görüşmeler kaydedilmez ve dinlenemez; bir '
                    'görüşme en fazla ${CallRules.maxLength.inMinutes} dakika sürer.',
                  ),
                ),
                const SizedBox(height: GwSpacing.md),
                switch (ref.watch(myCallPermissionProvider)) {
                  AsyncData(:final value) => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Status(permission: value),
                        if (value.status == CallPermissionStatus.active) const _LockScreenCard(),
                      ],
                    ),
                  AsyncError(:final error) =>
                    GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(myCallPermissionProvider)),
                  _ => const GwSkeleton(height: GwSpacing.xxl * 3),
                },
              ],
            ),
          ),
        ),
      );
}

class _Status extends StatelessWidget {
  const _Status({required this.permission});

  final CallPermission permission;

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary);
    final p = permission;
    final waitUntil = p.canAskAgainAt;
    final mayAsk = switch (p.status) {
      CallPermissionStatus.none => true,
      CallPermissionStatus.declined || CallPermissionStatus.revoked => waitUntil == null || DateTime.now().isAfter(waitUntil),
      _ => false,
    };
    return GwPanel(
      title: 'Durum',
      trailing: GwBadge(switch (p.status) {
        CallPermissionStatus.none => 'Talep edilmedi',
        CallPermissionStatus.requested => 'İnceleniyor',
        CallPermissionStatus.active => 'Açık',
        CallPermissionStatus.declined || CallPermissionStatus.revoked => 'Kapalı',
      }, tone: p.status == CallPermissionStatus.active ? GwBadgeTone.success : GwBadgeTone.neutral),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            switch (p.status) {
              CallPermissionStatus.none => 'Henüz talep etmedin.',
              CallPermissionStatus.requested =>
                'Talebin ${p.groupName ?? 'grubun'} yöneticilerine ulaştı. Karar verilince bildirim gelir.',
              CallPermissionStatus.active => 'Sesli görüşmen açık${p.groupName == null ? '' : ' (${p.groupName})'}. Eşleştiğin kişileri ve '
                  'ekip arkadaşlarını sohbetin üstündeki telefon simgesiyle arayabilirsin; karşı tarafın da yetkisi açık olmalı.',
              CallPermissionStatus.declined => 'Talebin şimdilik kabul edilmedi.',
              CallPermissionStatus.revoked when !p.decidedByPerson =>
                'Yetkiyi veren gruptan ayrıldığın için sesli görüşmen kapandı. Başka bir grubundan yeniden talep edebilirsin.',
              CallPermissionStatus.revoked => 'Sesli görüşmen kapatıldı.',
            },
          ),
          if (p.reason case final reason? when p.status != CallPermissionStatus.active && p.decidedByPerson) ...[
            const SizedBox(height: GwSpacing.xs),
            Text('Gerekçe: $reason', style: secondary),
          ],
          if (p.note case final note? when p.status == CallPermissionStatus.requested) ...[
            const SizedBox(height: GwSpacing.xs),
            Text('Notun: $note', style: secondary),
          ],
          if (!mayAsk && waitUntil != null) ...[
            const SizedBox(height: GwSpacing.xs),
            Text('${formatDateTime(waitUntil)} sonrasında yeniden talep edebilirsin.', style: secondary),
          ],
          if (mayAsk) ...[
            const SizedBox(height: GwSpacing.md),
            const _RequestForm(),
          ],
        ],
      ),
    );
  }
}

class _RequestForm extends ConsumerStatefulWidget {
  const _RequestForm();

  @override
  ConsumerState<_RequestForm> createState() => _RequestFormState();
}

class _RequestFormState extends ConsumerState<_RequestForm> {
  final _note = TextEditingController();
  String? _groupId;
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _send(String groupId) async {
    setState(() {
      _sending = true;
      _error = null;
    });
    final note = _note.text.trim();
    final result = await ref.read(callsRepositoryProvider).requestPermission(groupId, note.isEmpty ? null : note);
    if (!mounted) return;
    setState(() => _sending = false);
    switch (result) {
      case Ok():
        ref.invalidate(myCallPermissionProvider);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Talebin gönderildi.')));
      case Err(:final failure):
        setState(() => _error = failure.userMessage);
    }
  }

  @override
  Widget build(BuildContext context) => switch (ref.watch(myCallGroupsProvider)) {
        AsyncData(:final value) when value.isEmpty => const Text(
            'Sesli görüşmeyi grupların sahipleri ve Yöneticileri açar. Talep edebilmek için önce bir gruba katıl.',
          ),
        AsyncData(:final value) => _form(value),
        AsyncError(:final error) =>
          GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(myCallGroupsProvider)),
        _ => const GwSkeleton(height: GwSpacing.xxl * 2),
      };

  Widget _form(List<CallGroup> groups) {
    final groupId = groups.any((g) => g.id == _groupId) ? _groupId! : groups.first.id;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            initialValue: groupId,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Talebin gideceği grup'),
            items: [for (final g in groups) DropdownMenuItem(value: g.id, child: Text(g.name, overflow: TextOverflow.ellipsis))],
            onChanged: (v) => setState(() => _groupId = v),
          ),
          const SizedBox(height: GwSpacing.sm),
          TextField(
            controller: _note,
            maxLength: CallRules.noteMax,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Not (isteğe bağlı)',
              hintText: 'Neden sesli görüşme istediğini kısaca yazabilirsin.',
            ),
          ),
          if (_error case final error?) ...[GwFormMessage(error), const SizedBox(height: GwSpacing.xs)],
          GwButton(label: 'Talep et', icon: Icons.call_outlined, isLoading: _sending, onPressed: () => _send(groupId)),
        ],
      );
  }
}


/// Android 14+: without the full-screen permission a call only shows as a notification on the lock screen.
class _LockScreenCard extends ConsumerStatefulWidget {
  const _LockScreenCard();

  @override
  ConsumerState<_LockScreenCard> createState() => _LockScreenCardState();
}

class _LockScreenCardState extends ConsumerState<_LockScreenCard> {
  bool? _allowed;
  late final AppLifecycleListener _lifecycle = AppLifecycleListener(onResume: _check);

  Future<void> _check() async {
    final allowed = await ref.read(nativeCallsProvider).canRingOnLockScreen().catchError((Object _) => true);
    if (mounted) setState(() => _allowed = allowed);
  }

  @override
  void initState() {
    super.initState();
    _lifecycle;
    _check();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_allowed ?? true) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: GwSpacing.md),
      child: GwPanel(
        title: 'Kilit ekranında gelen arama',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Telefonun kilitliyken aramaların tam ekran çalması için GWAY'e izin ver."),
            const SizedBox(height: GwSpacing.sm),
            GwButton(
              label: 'İzni aç',
              icon: Icons.phone_in_talk_outlined,
              variant: GwButtonVariant.secondary,
              onPressed: () => ref.read(nativeCallsProvider).openLockScreenSetting(),
            ),
          ],
        ),
      ),
    );
  }
}
