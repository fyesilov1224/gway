import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/admin_billing.dart';
import 'providers.dart';

/// PayTR and iyzico setup for platform admins (docs/PAYMENTS.md): whether keys are in, test or live, the
/// addresses to paste into each merchant panel, what is missing, and a check of the keys with the provider.
class PaymentProvidersPanel extends ConsumerWidget {
  const PaymentProvidersPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GwPanel(
      title: 'Ödeme sağlayıcıları',
      subtitle: 'Anahtarlar sunucunun ortam değişkenlerinde durur; burada yalnızca durumları görünür. Kurulum: docs/PAYMENTS.md',
      child: switch (ref.watch(paymentProvidersProvider)) {
        AsyncData(:final value) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, p) in value.indexed) ...[
                if (i > 0) const Divider(height: GwSpacing.xl),
                _ProviderSection(status: p),
              ],
            ],
          ),
        AsyncError(:final error) =>
          GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(paymentProvidersProvider)),
        _ => const GwSkeleton(height: GwSpacing.xxl * 3),
      },
    );
  }
}

class _ProviderSection extends ConsumerStatefulWidget {
  const _ProviderSection({required this.status});

  final PaymentProviderStatus status;

  @override
  ConsumerState<_ProviderSection> createState() => _ProviderSectionState();
}

class _ProviderSectionState extends ConsumerState<_ProviderSection> {
  bool _checking = false;
  ProviderCheck? _check;

  Future<void> _run() async {
    setState(() {
      _checking = true;
      _check = null;
    });
    final result = await ref.read(adminBillingRepositoryProvider).checkProvider(widget.status.provider);
    if (!mounted) return;
    setState(() {
      _checking = false;
      _check = switch (result) {
        Ok(:final value) => value,
        Err(:final failure) => ProviderCheck(connected: false, message: failure.userMessage),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.status;
    final textTheme = Theme.of(context).textTheme;
    final secondary = textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary);
    final check = _check;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: GwSpacing.sm,
          runSpacing: GwSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(providerLabels[p.provider] ?? p.provider, style: textTheme.titleMedium),
            Text(p.market, style: secondary),
            if (!p.configured)
              const GwBadge('Anahtar yok', dot: true)
            else if (p.testMode)
              const GwBadge('Test', tone: GwBadgeTone.info, dot: true)
            else
              const GwBadge('Canlı', tone: GwBadgeTone.primary, dot: true),
          ],
        ),
        for (final a in p.addresses)
          Padding(
            padding: const EdgeInsets.only(top: GwSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.label, style: textTheme.labelLarge),
                      SelectableText(a.url, style: secondary),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Kopyala',
                  icon: const Icon(Icons.copy_outlined),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: a.url));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Adres kopyalandı.')));
                    }
                  },
                ),
              ],
            ),
          ),
        for (final w in p.warnings)
          Padding(
            padding: const EdgeInsets.only(top: GwSpacing.sm),
            child: GwFormMessage(w, kind: GwFormMessageKind.info),
          ),
        if (p.configured) ...[
          const SizedBox(height: GwSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: GwButton(
              label: 'Bağlantıyı dene',
              icon: Icons.wifi_tethering,
              variant: GwButtonVariant.secondary,
              isLoading: _checking,
              onPressed: _run,
            ),
          ),
        ],
        if (check != null)
          Padding(
            padding: const EdgeInsets.only(top: GwSpacing.sm),
            child: GwFormMessage(check.message, kind: check.connected ? GwFormMessageKind.info : GwFormMessageKind.error),
          ),
      ],
    );
  }
}
