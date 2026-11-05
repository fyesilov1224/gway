import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n.dart';
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
      title: identityL10n.deletionPendingTitle,
      subtitle: date == null
          ? identityL10n.deletionRequested
          : identityL10n.deletionScheduled(formatDate(date)),
      children: [
        if (_error != null) ...[GwFormMessage(_error!), const SizedBox(height: GwSpacing.md)],
        GwButton(label: identityL10n.undoDeletion, onPressed: _restore, isLoading: _saving, expand: true),
        const SizedBox(height: GwSpacing.sm),
        GwButton(
          label: identityL10n.signOut,
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
      title: banned ? identityL10n.bannedTitle : identityL10n.suspendedTitle,
      subtitle: until == null
          ? identityL10n.bannedBody
          : identityL10n.suspendedBody(formatDateTime(until)),
      children: [
        if (account?.suspensionReason case final reason?) ...[
          GwFormMessage(banned ? identityL10n.banReason(reason) : identityL10n.suspensionReason(reason)),
          const SizedBox(height: GwSpacing.md),
        ],
        if (!banned) ...[
          GwButton(
            label: identityL10n.retry,
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
          label: identityL10n.signOut,
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
      appBar: AppBar(title: Text(identityL10n.deleteAccount)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(GwSpacing.page),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: GwLayout.formMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(identityL10n.beforeDeleting, style: textTheme.titleLarge),
                  const SizedBox(height: GwSpacing.md),
                  for (final line in [
                    identityL10n.deletionHidesNow,
                    identityL10n.deletionGraceRestore(AccountRetention.graceDays),
                    identityL10n.deletionAfterGrace,
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
                    title: Text(identityL10n.deletionUnderstood),
                  ),
                  const SizedBox(height: GwSpacing.md),
                  if (_error != null) ...[GwFormMessage(_error!), const SizedBox(height: GwSpacing.md)],
                  GwButton(
                    label: identityL10n.deleteMyAccount,
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
