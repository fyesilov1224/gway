import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/calls.dart';
import 'call_providers.dart';

/// Settings → Sesli görüşme: ask the platform team for voice calls and see the decision (docs/ARCHITECTURE.md §8c).
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
                  title: 'Eşleştiğin kişilerle sesli konuş',
                  child: Text(
                    'Sesli görüşme, eşleştiğin kişileri özel sohbetten aramanı sağlar. Herkese açık değildir: talep '
                    'edersin, GWAY ekibi açar. Görüşmeler kaydedilmez ve dinlenemez; bir görüşme en fazla '
                    '${CallRules.maxLength.inMinutes} dakika sürer.',
                  ),
                ),
                const SizedBox(height: GwSpacing.md),
                switch (ref.watch(myCallPermissionProvider)) {
                  AsyncData(:final value) => _Status(permission: value),
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
              CallPermissionStatus.requested => 'Talebin GWAY ekibine ulaştı. Karar verilince bildirim gelir.',
              CallPermissionStatus.active => 'Sesli görüşmen açık. Eşleştiğin kişileri sohbetin üstündeki telefon simgesiyle '
                  'arayabilirsin; karşı tarafın da yetkisi açık olmalı.',
              CallPermissionStatus.declined => 'Talebin şimdilik kabul edilmedi.',
              CallPermissionStatus.revoked => 'Sesli görüşmen kapatıldı.',
            },
          ),
          if (p.reason case final reason? when p.status != CallPermissionStatus.active) ...[
            const SizedBox(height: GwSpacing.xs),
            Text('Gerekçe: $reason', style: secondary),
          ],
          if (p.note case final note? when p.status == CallPermissionStatus.requested) ...[
            const SizedBox(height: GwSpacing.xs),
            Text('Notun: $note', style: secondary),
          ],
          if (!mayAsk && waitUntil != null) ...[
            const SizedBox(height: GwSpacing.xs),
            Text('${formatDateTimeTr(waitUntil)} sonrasında yeniden talep edebilirsin.', style: secondary),
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
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    final note = _note.text.trim();
    final result = await ref.read(callsRepositoryProvider).requestPermission(note.isEmpty ? null : note);
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
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          GwButton(label: 'Talep et', icon: Icons.call_outlined, isLoading: _sending, onPressed: _send),
        ],
      );
}
