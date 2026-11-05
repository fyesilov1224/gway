import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/calls.dart';
import '../l10n.dart';
import 'call_providers.dart';

/// Settings → Sesli görüşme: ask one of the person's groups for voice calls and see the decision (docs/ARCHITECTURE.md §8c).
class CallPermissionScreen extends ConsumerWidget {
  const CallPermissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(title: Text(messagingL10n.voiceCalls)),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: GwLayout.contentMaxWidth),
            child: ListView(
              padding: const EdgeInsets.all(GwSpacing.page),
              children: [
                GwPanel(
                  title: messagingL10n.voiceCallsHeadline,
                  child: Text(
                    messagingL10n.voiceCallsIntro(CallRules.maxLength.inMinutes),
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
      title: messagingL10n.status,
      trailing: GwBadge(switch (p.status) {
        CallPermissionStatus.none => messagingL10n.notRequested,
        CallPermissionStatus.requested => messagingL10n.underReview,
        CallPermissionStatus.active => messagingL10n.statusOn,
        CallPermissionStatus.declined || CallPermissionStatus.revoked => messagingL10n.statusOff,
      }, tone: p.status == CallPermissionStatus.active ? GwBadgeTone.success : GwBadgeTone.neutral),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            switch (p.status) {
              CallPermissionStatus.none => messagingL10n.notRequestedYet,
              CallPermissionStatus.requested =>
                (p.groupName == null ? messagingL10n.requestedFromGroup : messagingL10n.requestedFrom(p.groupName!)),
              CallPermissionStatus.active => (p.groupName == null ? messagingL10n.active : messagingL10n.activeFrom(p.groupName!)),
              CallPermissionStatus.declined => messagingL10n.declined,
              CallPermissionStatus.revoked when !p.decidedByPerson =>
                messagingL10n.revokedLeftGroup,
              CallPermissionStatus.revoked => messagingL10n.revoked,
            },
          ),
          if (p.reason case final reason? when p.status != CallPermissionStatus.active && p.decidedByPerson) ...[
            const SizedBox(height: GwSpacing.xs),
            Text(messagingL10n.reasonLine(reason), style: secondary),
          ],
          if (p.note case final note? when p.status == CallPermissionStatus.requested) ...[
            const SizedBox(height: GwSpacing.xs),
            Text(messagingL10n.yourNote(note), style: secondary),
          ],
          if (!mayAsk && waitUntil != null) ...[
            const SizedBox(height: GwSpacing.xs),
            Text(messagingL10n.waitUntil(formatDateTime(waitUntil)), style: secondary),
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(messagingL10n.requestSent)));
      case Err(:final failure):
        setState(() => _error = failure.userMessage);
    }
  }

  @override
  Widget build(BuildContext context) => switch (ref.watch(myCallGroupsProvider)) {
        AsyncData(:final value) when value.isEmpty => Text(
            messagingL10n.joinGroupFirst,
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
            decoration: InputDecoration(labelText: messagingL10n.requestToGroup),
            items: [for (final g in groups) DropdownMenuItem(value: g.id, child: Text(g.name, overflow: TextOverflow.ellipsis))],
            onChanged: (v) => setState(() => _groupId = v),
          ),
          const SizedBox(height: GwSpacing.sm),
          TextField(
            controller: _note,
            maxLength: CallRules.noteMax,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: messagingL10n.noteOptional,
              hintText: messagingL10n.noteHint,
            ),
          ),
          if (_error case final error?) ...[GwFormMessage(error), const SizedBox(height: GwSpacing.xs)],
          GwButton(label: messagingL10n.request, icon: Icons.call_outlined, isLoading: _sending, onPressed: () => _send(groupId)),
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
        title: messagingL10n.lockScreenCalls,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(messagingL10n.lockScreenHint),
            const SizedBox(height: GwSpacing.sm),
            GwButton(
              label: messagingL10n.allow,
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
