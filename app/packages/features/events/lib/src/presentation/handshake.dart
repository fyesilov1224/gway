import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../domain/events.dart';
import '../domain/handshakes.dart';
import 'providers.dart';
import 'routes.dart';

/// The entry on the event page while handshakes are open (docs/ARCHITECTURE.md §3d, El sıkış).
class HandshakeEntry extends StatelessWidget {
  const HandshakeEntry({super.key, required this.event});

  final GroupEvent event;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: GwSpacing.sm),
      padding: const EdgeInsets.all(GwSpacing.md),
      decoration: const BoxDecoration(color: GwColors.secondarySoft, borderRadius: GwRadius.mdAll),
      child: Row(
        children: [
          const Icon(Icons.handshake_outlined, color: GwColors.secondary),
          const SizedBox(width: GwSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('El sıkış', style: textTheme.titleSmall),
                Text('Tanıştığın kişiyle kodlarınızı okutun; ikinizin de "Tanıştıklarım" listesine eklenir.',
                    style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: GwSpacing.xs),
          GwButton(
            label: 'Aç',
            variant: GwButtonVariant.secondary,
            onPressed: () => context.push(EventRoutes.handshake(event.id), extra: event.title),
          ),
        ],
      ),
    );
  }
}

/// "Kodum" shows a QR code that renews itself; "Okut" reads the other person's code or takes it typed.
class HandshakeScreen extends StatelessWidget {
  const HandshakeScreen({super.key, required this.eventId, this.eventTitle});

  final String eventId;
  final String? eventTitle;

  /// The camera works on phones and in the browser; elsewhere the code is typed.
  static bool get cameraAvailable =>
      kIsWeb || defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS;

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(eventTitle == null ? 'El sıkış' : 'El sıkış · $eventTitle', maxLines: 1, overflow: TextOverflow.ellipsis),
            bottom: const TabBar(tabs: [Tab(text: 'Kodum'), Tab(text: 'Okut')]),
          ),
          body: TabBarView(children: [_MyCode(eventId: eventId), _Scan(eventId: eventId)]),
        ),
      );
}

class _MyCode extends ConsumerStatefulWidget {
  const _MyCode({required this.eventId});

  final String eventId;

  @override
  ConsumerState<_MyCode> createState() => _MyCodeState();
}

class _MyCodeState extends ConsumerState<_MyCode> {
  HandshakeCode? _code;
  String? _error;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    _timer?.cancel();
    final result = await ref.read(eventsRepositoryProvider).handshakeCode(widget.eventId);
    if (!mounted) return;
    setState(() {
      switch (result) {
        case Ok(:final value):
          _code = value;
          _error = null;
        case Err(:final failure):
          _error = failure.userMessage;
      }
    });
    if (_code case final code?) {
      // The server renews a code with under a minute left; ask again just before that.
      final wait = code.expiresAt.difference(DateTime.now()) - const Duration(seconds: 55);
      _timer = Timer(wait.isNegative ? const Duration(seconds: 5) : wait, _load);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final code = _code;
    if (_error != null && code == null) return GwErrorState(message: _error!, onRetry: _load);
    if (code == null) {
      return const Center(child: GwSkeleton(width: GwLayout.storyCardWidth * 0.7, height: GwLayout.storyCardWidth * 0.7));
    }
    return ListView(
      padding: const EdgeInsets.all(GwSpacing.page),
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(GwSpacing.md),
            decoration: const BoxDecoration(
              color: GwColors.background,
              borderRadius: GwRadius.xlAll,
              border: Border.fromBorderSide(GwBorders.hairline),
            ),
            child: QrImageView(
              data: code.qrData(widget.eventId),
              size: GwLayout.storyCardWidth * 0.7,
              eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: GwColors.textPrimary),
              dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: GwColors.textPrimary),
              semanticsLabel: 'El sıkış kodun',
            ),
          ),
        ),
        const SizedBox(height: GwSpacing.md),
        Center(child: SelectableText(code.spaced, style: textTheme.headlineMedium?.copyWith(letterSpacing: GwSpacing.xxs))),
        const SizedBox(height: GwSpacing.xs),
        Text(
          'Karşındaki bu kodu "Okut" sekmesinden okutsun ya da yazsın. Kod birkaç dakikada bir kendiliğinden yenilenir; '
          'fotoğrafı sonradan işe yaramaz.',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary),
        ),
      ],
    );
  }
}

class _Scan extends ConsumerStatefulWidget {
  const _Scan({required this.eventId});

  final String eventId;

  @override
  ConsumerState<_Scan> createState() => _ScanState();
}

class _ScanState extends ConsumerState<_Scan> {
  final _typed = TextEditingController();
  bool _busy = false;

  /// The camera reports the same code many times a second; each code is tried once.
  String? _lastScanned;

  @override
  void dispose() {
    _typed.dispose();
    super.dispose();
  }

  Future<void> _shake(String code) async {
    if (_busy || code.trim().isEmpty) return;
    setState(() => _busy = true);
    final result = await ref.read(eventsRepositoryProvider).shake(widget.eventId, code);
    if (!mounted) return;
    switch (result) {
      case Ok(:final value):
        _typed.clear();
        ref.invalidate(metPeopleProvider);
        await showDialog<void>(context: context, builder: (_) => _MetDialog(result: value));
      case Err(:final failure):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(failure.userMessage)));
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(GwSpacing.page),
      children: [
        if (HandshakeScreen.cameraAvailable) ...[
          ClipRRect(
            borderRadius: GwRadius.xlAll,
            child: AspectRatio(
              aspectRatio: 1,
              child: MobileScanner(
                onDetect: (capture) {
                  final value = capture.barcodes.map((b) => b.rawValue).nonNulls.firstOrNull;
                  if (value == null || value == _lastScanned) return;
                  _lastScanned = value;
                  _shake(value);
                },
                errorBuilder: (context, error) => ColoredBox(
                  color: GwColors.surfaceMuted,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(GwSpacing.lg),
                      child: Text(
                        'Kamera açılamadı. Kamera iznini ayarlardan verebilir ya da kodu aşağıya yazabilirsin.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: GwSpacing.md),
          Text('Karşındakinin QR kodunu kameraya göster ya da kodunu yaz.', style: textTheme.bodyMedium),
        ] else
          Text('Karşındakinin ekranındaki 6 haneli kodu yaz.', style: textTheme.bodyMedium),
        const SizedBox(height: GwSpacing.sm),
        TextField(
          controller: _typed,
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.done,
          maxLength: 7,
          onSubmitted: _shake,
          decoration: const InputDecoration(labelText: 'Kod', hintText: 'ABC 234'),
        ),
        GwButton(label: 'El sıkış', icon: Icons.handshake_outlined, isLoading: _busy, onPressed: () => _shake(_typed.text)),
      ],
    );
  }
}

class _MetDialog extends StatelessWidget {
  const _MetDialog({required this.result});

  final HandshakeResult result;

  @override
  Widget build(BuildContext context) {
    final p = result.person;
    final textTheme = Theme.of(context).textTheme;
    return AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: GwRadius.xlAll),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GwAvatar(name: p.displayName, shape: GwAvatarShape.user, size: GwAvatarSize.lg, imageUrl: p.avatarUrl),
          const SizedBox(height: GwSpacing.sm),
          Text(result.alreadyMet ? 'Zaten tanışıyorsunuz' : 'Tanıştınız!', style: textTheme.titleLarge),
          const SizedBox(height: GwSpacing.xxs),
          Text('${p.displayName} (@${p.username})', textAlign: TextAlign.center, style: textTheme.bodyLarge),
        ],
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Tamam'))],
    );
  }
}

/// "Tanıştıklarım" (`/met`): only the person sees who they met.
class MetPeopleScreen extends ConsumerWidget {
  const MetPeopleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Tanıştıklarım')),
      body: switch (ref.watch(metPeopleProvider)) {
        AsyncData(:final value) when value.isEmpty => GwEmptyState(
            icon: Icons.handshake_outlined,
            message: 'Bir organizasyonda biriyle el sıkıştığında burada görünür. El sıkış, organizasyon sayfasında açılır.',
            actionLabel: 'Takvimime git',
            onAction: () => context.go(EventRoutes.calendar),
          ),
        AsyncData(:final value) => ListView(
            padding: const EdgeInsets.all(GwSpacing.page),
            children: [
              Text('Yalnızca sen görürsün. Profilinde yalnızca el sıkış sayın görünür.',
                  style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
              const SizedBox(height: GwSpacing.sm),
              GwPanel(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (final (i, m) in value.indexed) ...[
                      if (i > 0) const Divider(),
                      ListTile(
                        leading: GwAvatar(name: m.person.displayName, shape: GwAvatarShape.user, imageUrl: m.person.avatarUrl),
                        title: Text(m.person.displayName),
                        subtitle: Text('@${m.person.username} · ${m.eventTitle} · ${formatDate(m.eventStartsAt.toLocal())}',
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        onTap: () => context.push(EventRoutes.event(m.eventId)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        AsyncError(:final error) => GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(metPeopleProvider)),
        _ => const Padding(padding: EdgeInsets.all(GwSpacing.page), child: GwSkeleton(height: GwSpacing.xxl * 4)),
      },
    );
  }
}
