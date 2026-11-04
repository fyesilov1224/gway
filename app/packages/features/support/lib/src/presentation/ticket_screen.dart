import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/support.dart';
import 'providers.dart';
import 'widgets.dart';

/// One message and its conversation with the platform team; opening it marks replies read.
class TicketScreen extends ConsumerStatefulWidget {
  const TicketScreen({super.key, required this.ticketId, this.pickImage});

  final String ticketId;
  final PickImage? pickImage;

  @override
  ConsumerState<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends ConsumerState<TicketScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(supportRepositoryProvider).markRead(widget.ticketId);
      if (mounted) ref.invalidate(myTicketsProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final thread = ref.watch(supportThreadProvider(widget.ticketId));
    return Scaffold(
      appBar: AppBar(title: const Text('Mesaj')),
      body: switch (thread) {
        AsyncData(:final value) => _Thread(thread: value, pickImage: widget.pickImage),
        AsyncError(error: NotFoundFailure()) => GwEmptyState(
            icon: Icons.search_off,
            message: 'Bu mesaj bulunamadı.',
            actionLabel: 'Geri dön',
            onAction: () => Navigator.of(context).maybePop(),
          ),
        AsyncError(:final error) => GwErrorState(
            message: userMessageOf(error),
            onRetry: () => ref.invalidate(supportThreadProvider(widget.ticketId)),
          ),
        _ => const Padding(padding: EdgeInsets.all(GwSpacing.page), child: GwSkeleton(height: GwSpacing.xxl * 3)),
      },
    );
  }
}

class _Thread extends StatelessWidget {
  const _Thread({required this.thread, required this.pickImage});

  final SupportThread thread;
  final PickImage? pickImage;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final t = thread.ticket;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: GwSpacing.md, horizontal: GwSpacing.page),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: GwLayout.contentMaxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          SupportKindIcon(t.kind),
                          const SizedBox(width: GwSpacing.sm),
                          Expanded(child: Text(t.subject, style: textTheme.titleLarge)),
                        ],
                      ),
                      const SizedBox(height: GwSpacing.xs),
                      Wrap(
                        spacing: GwSpacing.xs,
                        runSpacing: GwSpacing.xs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          GwBadge(t.kind.label, tone: t.kind.tone),
                          SupportStatusBadge(t.status),
                          if (t.groupName != null) GwBadge(t.groupName!),
                          Text(formatDateTime(t.createdAt),
                              style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: GwSpacing.lg),
                      for (final m in thread.messages) _Bubble(message: m),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        t.isClosed
            ? const Padding(
                padding: EdgeInsets.all(GwSpacing.md),
                child: GwFormMessage('Bu mesaj kapatıldı. Devam etmek için yeni bir mesaj aç.', kind: GwFormMessageKind.info),
              )
            : _Composer(ticketId: t.id, pickImage: pickImage),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final SupportMessage message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final staff = message.fromStaff;
    return Align(
      alignment: staff ? Alignment.centerLeft : Alignment.centerRight,
      child: FractionallySizedBox(
        widthFactor: 0.85,
        alignment: staff ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: GwSpacing.sm),
          padding: const EdgeInsets.all(GwSpacing.sm),
          decoration: BoxDecoration(
            color: staff ? GwColors.background : GwColors.primarySoft,
            borderRadius: GwRadius.lgAll,
            border: staff ? const Border.fromBorderSide(GwBorders.hairline) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                staff ? 'GWAY Ekibi' : 'Sen',
                style: textTheme.labelMedium?.copyWith(color: staff ? GwColors.primary : GwColors.textSecondary),
              ),
              const SizedBox(height: GwSpacing.xxs),
              SelectableText(message.body, style: textTheme.bodyLarge),
              if (message.attachments.isNotEmpty) ...[
                const SizedBox(height: GwSpacing.xs),
                Wrap(
                  spacing: GwSpacing.xs,
                  runSpacing: GwSpacing.xs,
                  children: [for (final path in message.attachments) AttachmentThumbnail(path: path)],
                ),
              ],
              const SizedBox(height: GwSpacing.xxs),
              Text(formatDateTime(message.createdAt), style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Composer extends ConsumerStatefulWidget {
  const _Composer({required this.ticketId, required this.pickImage});

  final String ticketId;
  final PickImage? pickImage;

  @override
  ConsumerState<_Composer> createState() => _ComposerState();
}

class _ComposerState extends ConsumerState<_Composer> {
  final _text = TextEditingController();
  final _images = <ImageUpload>[];
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _addImage() async {
    final image = await (widget.pickImage ?? () => pickGalleryImage(maxWidth: 1600))();
    if (image != null && mounted) setState(() => _images.add(image));
  }

  Future<void> _send() async {
    final body = _text.text.trim();
    if (body.isEmpty) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    final result = await ref.read(supportRepositoryProvider).reply(widget.ticketId, body, images: List.of(_images));
    if (!mounted) return;
    setState(() {
      _sending = false;
      if (result case Err(:final failure)) {
        _error = failure.userMessage;
      } else {
        _text.clear();
        _images.clear();
      }
    });
    ref
      ..invalidate(supportThreadProvider(widget.ticketId))
      ..invalidate(myTicketsProvider);
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: GwColors.background, border: Border(top: GwBorders.hairline)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(GwSpacing.sm),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: GwLayout.contentMaxWidth),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_error != null) ...[GwFormMessage(_error!), const SizedBox(height: GwSpacing.xs)],
                  if (_images.isNotEmpty) ...[
                    ImageAttachments(images: _images, onAdd: _addImage, onRemove: (i) => setState(() => _images.removeAt(i))),
                    const SizedBox(height: GwSpacing.xs),
                  ],
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (_images.length < SupportRules.maxImages)
                        IconButton(
                          tooltip: 'Ekran görüntüsü ekle',
                          icon: const Icon(Icons.add_photo_alternate_outlined),
                          onPressed: _sending ? null : _addImage,
                        ),
                      Expanded(
                        child: TextField(
                          controller: _text,
                          minLines: 1,
                          maxLines: 5,
                          maxLength: SupportRules.bodyMax,
                          decoration: const InputDecoration(hintText: 'Yanıt yaz', counterText: ''),
                        ),
                      ),
                      const SizedBox(width: GwSpacing.xs),
                      IconButton.filled(
                        tooltip: 'Gönder',
                        icon: _sending
                            ? const SizedBox.square(
                                dimension: GwSpacing.md,
                                child: CircularProgressIndicator(strokeWidth: 2, color: GwColors.onPrimary),
                              )
                            : const Icon(Icons.send),
                        onPressed: _sending ? null : _send,
                      ),
                    ],
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
