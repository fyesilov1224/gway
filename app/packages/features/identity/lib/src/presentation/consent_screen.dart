import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/legal.dart';
import 'auth_layout.dart';
import 'legal_documents_screen.dart';
import 'providers.dart';

String _agreementLabel(LegalKind kind) => switch (kind) {
      LegalKind.terms => "Kullanım Koşulları'nı okudum ve kabul ediyorum.",
      LegalKind.privacyNotice => "KVKK Aydınlatma Metni'ni okudum.",
      LegalKind.explicitConsent =>
        'Kişisel verilerimin yurt dışındaki sunucularda işlenmesine açık rıza veriyorum.',
      LegalKind.communityRules =>
        "Topluluk Kuralları, Yaptırımlar ve Yasal İşlemler Sözleşmesi'ni okudum ve kabul ediyorum.",
      // Accepted at checkout, never pending here.
      LegalKind.distanceSales => "Mesafeli Satış Sözleşmesi'ni okudum ve kabul ediyorum.",
    };

/// Asks for every pending legal document before the app can be used. A box is checked only after its text was
/// read to the end (docs/ARCHITECTURE.md §3a, KVKK).
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
          body: GxErrorState(
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
      title: 'Devam etmeden önce',
      subtitle: 'GrupX\'i kullanabilmek için aşağıdaki metinleri okuyup onaylaman gerekiyor.',
      children: [
        for (final doc in docs) ...[
          _ConsentTile(
            document: doc,
            accepted: _accepted.contains(doc.kind),
            read: _read.contains(doc.kind),
            onRead: () => setState(() => _read.add(doc.kind)),
            onChanged: (value) => setState(
              () => value ? _accepted.add(doc.kind) : _accepted.remove(doc.kind),
            ),
          ),
          const SizedBox(height: GxSpacing.sm),
        ],
        const SizedBox(height: GxSpacing.sm),
        if (_error != null) ...[GxFormMessage(_error!), const SizedBox(height: GxSpacing.md)],
        GxButton(
          label: 'Devam et',
          onPressed: allAccepted ? () => _continue(docs) : null,
          isLoading: _saving,
          expand: true,
        ),
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

class _ConsentTile extends StatelessWidget {
  const _ConsentTile({
    required this.document,
    required this.accepted,
    required this.read,
    required this.onRead,
    required this.onChanged,
  });

  final LegalDocument document;
  final bool accepted;
  final bool read;
  final VoidCallback onRead;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(GxSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(document.title, style: Theme.of(context).textTheme.titleMedium),
                ),
                GxButton(
                  label: 'Metni oku',
                  variant: GxButtonVariant.text,
                  onPressed: () => showLegalDocument(context, document, onReadToEnd: onRead),
                ),
              ],
            ),
            CheckboxListTile(
              value: accepted,
              onChanged: read ? (v) => onChanged(v ?? false) : null,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                _agreementLabel(document.kind),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              subtitle: read
                  ? null
                  : Text(
                      'Onaylamak için metni sonuna kadar oku.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: GxColors.textSecondary),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
