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
          : 'Hesabın ve tüm verilerin ${formatDate(date)} tarihinde kalıcı olarak silinecek. '
              'O zamana kadar fikrini değiştirebilirsin.',
      children: [
        if (_error != null) ...[GwFormMessage(_error!), const SizedBox(height: GwSpacing.md)],
        GwButton(label: 'Silmeyi geri al', onPressed: _restore, isLoading: _saving, expand: true),
        const SizedBox(height: GwSpacing.sm),
        GwButton(
          label: 'Çıkış yap',
          variant: GwButtonVariant.text,
          onPressed: _saving ? null : () => ref.read(authRepositoryProvider).signOut(),
        ),
      ],
    );
  }
}

/// The locked screen of a suspended or banned account: the reason, the end date and a way out
/// (docs/ARCHITECTURE.md §3a). It appears at once when the platform team acts.
class SuspendedScreen extends ConsumerWidget {
  const SuspendedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountStateProvider).value;
    final until = account?.suspendedUntil;
    final banned = account?.isBanned ?? false;
    return AuthLayout(
      title: banned ? 'Hesabın kalıcı olarak kapatıldı' : 'Hesabın askıya alındı',
      subtitle: until == null
          ? 'Hesabın platform ekibi tarafından kalıcı olarak kapatıldı. Profilin artık kimseye görünmüyor.'
          : 'Hesabın ${formatDateTime(until)} tarihine kadar askıya alındı. Bu süre boyunca uygulamayı kullanamazsın; '
              'profilinde askıda olduğun görünür.',
      children: [
        if (account?.suspensionReason case final reason?) ...[
          GwFormMessage(banned ? 'Ban gerekçesi: $reason' : 'Askı gerekçesi: $reason'),
          const SizedBox(height: GwSpacing.md),
        ],
        if (!banned) ...[
          GwButton(
            label: 'Tekrar dene',
            variant: GwButtonVariant.secondary,
            onPressed: () async {
              await refreshAccountSession(() => ref.read(supabaseClientProvider));
              ref.invalidate(accountStateProvider);
            },
            expand: true,
          ),
          const SizedBox(height: GwSpacing.sm),
        ],
        GwButton(
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
            padding: const EdgeInsets.all(GwSpacing.page),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: GwLayout.formMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Hesabını silmeden önce', style: textTheme.titleLarge),
                  const SizedBox(height: GwSpacing.md),
                  for (final line in const [
                    'Profilin hemen gizlenir; kimse seni bulamaz.',
                    '${AccountRetention.graceDays} gün içinde giriş yapıp silmeyi geri alabilirsin.',
                    'Bu sürenin sonunda profilin, fotoğrafların ve tüm verilerin kalıcı olarak silinir.',
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: GwSpacing.sm),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: GwSpacing.xxs),
                            child: Icon(Icons.check_circle_outline, size: GwSpacing.md + GwSpacing.xxs),
                          ),
                          const SizedBox(width: GwSpacing.xs),
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
                  const SizedBox(height: GwSpacing.md),
                  if (_error != null) ...[GwFormMessage(_error!), const SizedBox(height: GwSpacing.md)],
                  GwButton(
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
