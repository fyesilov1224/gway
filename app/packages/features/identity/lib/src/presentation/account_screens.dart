import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_layout.dart';
import 'providers.dart';

/// Shown instead of the app while a deletion request is pending.
class DeletionPendingScreen extends ConsumerStatefulWidget {
  const DeletionPendingScreen({super.key});

  @override
  ConsumerState<DeletionPendingScreen> createState() => _DeletionPendingScreenState();
}

class _DeletionPendingScreenState extends ConsumerState<DeletionPendingScreen> {
  bool _saving = false;
  String? _error;

  Future<void> _restore() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final result = await ref.read(accountRepositoryProvider).cancelDeletion();
    if (!mounted) return;
    switch (result) {
      case Ok():
        ref.invalidate(accountStateProvider);
      case Err(:final failure):
        setState(() {
          _saving = false;
          _error = failure.userMessage;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = ref.watch(accountStateProvider).value?.deletionScheduledFor;
    return AuthLayout(
      title: 'Hesabın silinmek üzere',
      subtitle: date == null
          ? 'Hesap silme isteğin alındı.'
          : 'Hesabın ve tüm verilerin ${formatDateTr(date)} tarihinde kalıcı olarak silinecek. '
              'O zamana kadar fikrini değiştirebilirsin.',
      children: [
        if (_error != null) ...[GxFormMessage(_error!), const SizedBox(height: GxSpacing.md)],
        GxButton(label: 'Silmeyi geri al', onPressed: _restore, isLoading: _saving, expand: true),
        const SizedBox(height: GxSpacing.sm),
        GxButton(
          label: 'Çıkış yap',
          variant: GxButtonVariant.text,
          onPressed: _saving ? null : () => ref.read(authRepositoryProvider).signOut(),
        ),
      ],
    );
  }
}

/// Shown when a still-valid session belongs to a suspended account.
class SuspendedScreen extends ConsumerWidget {
  const SuspendedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountStateProvider).value;
    final until = account?.suspendedUntil;
    return AuthLayout(
      title: 'Hesabın askıya alındı',
      subtitle: until == null
          ? 'Hesabın platform ekibi tarafından süresiz olarak askıya alındı.'
          : 'Hesabın ${formatDateTimeTr(until)} tarihine kadar askıya alındı.',
      children: [
        if (account?.suspensionReason case final reason?) ...[
          GxFormMessage('Gerekçe: $reason', kind: GxFormMessageKind.info),
          const SizedBox(height: GxSpacing.md),
        ],
        GxButton(
          label: 'Çıkış yap',
          onPressed: () => ref.read(authRepositoryProvider).signOut(),
          expand: true,
        ),
      ],
    );
  }
}

/// Explains the 30-day grace period and requests deletion.
class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  bool _understood = false;
  bool _saving = false;
  String? _error;

  Future<void> _delete() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final result = await ref.read(accountRepositoryProvider).requestDeletion();
    if (!mounted) return;
    switch (result) {
      case Ok():
        // The router moves to the deletion pending screen.
        ref.invalidate(accountStateProvider);
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
    return Scaffold(
      appBar: AppBar(title: const Text('Hesabı sil')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(GxSpacing.page),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: GxLayout.formMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Hesabını silmeden önce', style: textTheme.titleLarge),
                  const SizedBox(height: GxSpacing.md),
                  for (final line in const [
                    'Profilin hemen gizlenir; kimse seni bulamaz.',
                    '${AccountRetention.graceDays} gün içinde giriş yapıp silmeyi geri alabilirsin.',
                    'Bu sürenin sonunda profilin, fotoğrafların ve tüm verilerin kalıcı olarak silinir.',
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: GxSpacing.sm),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: GxSpacing.xxs),
                            child: Icon(Icons.check_circle_outline, size: GxSpacing.md + GxSpacing.xxs),
                          ),
                          const SizedBox(width: GxSpacing.xs),
                          Expanded(child: Text(line, style: textTheme.bodyLarge)),
                        ],
                      ),
                    ),
                  CheckboxListTile(
                    value: _understood,
                    onChanged: _saving ? null : (v) => setState(() => _understood = v ?? false),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text('Anladım, hesabımı silmek istiyorum.'),
                  ),
                  const SizedBox(height: GxSpacing.md),
                  if (_error != null) ...[GxFormMessage(_error!), const SizedBox(height: GxSpacing.md)],
                  GxButton(
                    label: 'Hesabımı sil',
                    onPressed: _understood ? _delete : null,
                    isLoading: _saving,
                    expand: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

abstract final class AccountRetention {
  /// Must match the backend (AccountService.DeletionGraceDays).
  static const graceDays = 30;
}
