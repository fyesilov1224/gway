import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/legal.dart';
import '../l10n.dart';
import 'auth_layout.dart';
import 'legal_documents_screen.dart';
import 'providers.dart';

String _agreementLabel(LegalKind kind) => switch (kind) {
      LegalKind.terms => identityL10n.agreeTerms,
      LegalKind.privacyNotice => identityL10n.agreePrivacy,
      LegalKind.explicitConsent =>
        identityL10n.agreeExplicitConsent,
      LegalKind.communityRules =>
        identityL10n.agreeCommunityRules,
      // Accepted at checkout, never pending here.
      LegalKind.distanceSales => identityL10n.agreeDistanceSales,
    };

/// Asks for every pending legal document before the app can be used. A box is checked only after its text was
/// read to the end; ticking an unread one warns and opens the text (docs/ARCHITECTURE.md §3a, KVKK).
class ConsentScreen extends ConsumerStatefulWidget {
  const ConsentScreen({super.key});

  @override
  ConsumerState<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends ConsumerState<ConsentScreen> {
  final _accepted = <LegalKind>{};
  final _read = <LegalKind>{};
  bool _saving = false;
  String? _error;

  /// Opens the text; its closing button ("Okudum, onaylıyorum") both marks it read and ticks the box.
  Future<void> _open(LegalDocument doc) async {
    final accepted = await showLegalDocument(
      context,
      doc,
      onReadToEnd: () => setState(() => _read.add(doc.kind)),
      acceptLabel: identityL10n.readAndAccept,
    );
    if (accepted == true && mounted) setState(() => _accepted.add(doc.kind));
  }

  void _toggle(LegalDocument doc, bool value) {
    if (!value) return setState(() => _accepted.remove(doc.kind));
    if (_read.contains(doc.kind)) return setState(() => _accepted.add(doc.kind));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(identityL10n.readWholeText)));
    _open(doc);
  }

  Future<void> _continue(List<LegalDocument> docs) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final result = await ref.read(consentRepositoryProvider).accept(docs);
    if (!mounted) return;
    switch (result) {
      case Ok():
        ref.invalidate(pendingConsentsProvider);
      case Err(:final failure):
        setState(() {
          _saving = false;
          _error = failure.userMessage;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pending = ref.watch(pendingConsentsProvider);
    return switch (pending) {
      AsyncData(:final value) => _form(value),
      AsyncError(:final error) => Scaffold(
          body: GwErrorState(
            message: userMessageOf(error),
            onRetry: () => ref.invalidate(pendingConsentsProvider),
          ),
        ),
      _ => const Scaffold(body: Center(child: CircularProgressIndicator())),
    };
  }

  Widget _form(List<LegalDocument> docs) {
    final allAccepted = docs.every((d) => _accepted.contains(d.kind));
    return AuthLayout(
      title: identityL10n.beforeContinue,
      subtitle: identityL10n.consentIntro,
      children: [
        for (final doc in docs) ...[
          _ConsentTile(
            document: doc,
            accepted: _accepted.contains(doc.kind),
            read: _read.contains(doc.kind),
            onOpen: () => _open(doc),
            onChanged: (value) => _toggle(doc, value),
          ),
          const SizedBox(height: GwSpacing.sm),
        ],
        const SizedBox(height: GwSpacing.sm),
        if (_error != null) ...[GwFormMessage(_error!), const SizedBox(height: GwSpacing.md)],
        GwButton(
          label: identityL10n.continueAction,
          onPressed: allAccepted ? () => _continue(docs) : null,
          isLoading: _saving,
          expand: true,
        ),
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

class _ConsentTile extends StatelessWidget {
  const _ConsentTile({
    required this.document,
    required this.accepted,
    required this.read,
    required this.onOpen,
    required this.onChanged,
  });

  final LegalDocument document;
  final bool accepted;
  final bool read;
  final VoidCallback onOpen;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(GwSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(document.title, style: Theme.of(context).textTheme.titleMedium),
                ),
                GwButton(
                  label: identityL10n.readText,
                  variant: GwButtonVariant.text,
                  onPressed: onOpen,
                ),
              ],
            ),
            CheckboxListTile(
              value: accepted,
              onChanged: (v) => onChanged(v ?? false),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                _agreementLabel(document.kind),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              subtitle: read
                  ? null
                  : Text(
                      identityL10n.readToEnd,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: GwColors.textSecondary),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
