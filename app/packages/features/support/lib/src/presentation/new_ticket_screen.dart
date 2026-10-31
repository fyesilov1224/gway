import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/support.dart';
import 'providers.dart';
import 'routes.dart';
import 'widgets.dart';

Future<ImageUpload?> _pickScreenshot() => pickGalleryImage(maxWidth: 1600);

/// Kind (colored cards), optional managed group, subject, details and screenshots.
class NewTicketScreen extends ConsumerStatefulWidget {
  const NewTicketScreen({super.key, this.groupId, this.pickImage = _pickScreenshot});

  /// Preselected group, when opened from a group page.
  final String? groupId;
  final PickImage pickImage;

  @override
  ConsumerState<NewTicketScreen> createState() => _NewTicketScreenState();
}

class _NewTicketScreenState extends ConsumerState<NewTicketScreen> {
  final _form = GlobalKey<FormState>();
  final _subject = TextEditingController();
  final _body = TextEditingController();
  final _images = <ImageUpload>[];
  SupportKind? _kind;
  late String? _groupId = widget.groupId;
  bool _kindMissing = false;
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _subject.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _addImage() async {
    final image = await widget.pickImage();
    if (image != null && mounted) setState(() => _images.add(image));
  }

  Future<void> _send() async {
    final valid = _form.currentState!.validate();
    setState(() => _kindMissing = _kind == null);
    if (!valid || _kind == null) return;

    setState(() {
      _sending = true;
      _error = null;
    });
    final result = await ref.read(supportRepositoryProvider).create(NewTicket(
          kind: _kind!,
          subject: _subject.text.trim(),
          body: _body.text.trim(),
          groupId: _groupId,
          images: List.of(_images),
        ));
    if (!mounted) return;
    switch (result) {
      case Ok(:final value):
        ref.invalidate(myTicketsProvider);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mesajın platform ekibine iletildi.')));
        context.pushReplacement(SupportRoutes.ticket(value));
      case Err(:final failure):
        setState(() {
          _sending = false;
          _error = failure.userMessage;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final groups = ref.watch(managedGroupsProvider).value ?? const <ManagedGroup>[];
    const gap = SizedBox(height: GwSpacing.md);

    return Scaffold(
      appBar: AppBar(title: const Text('Yeni mesaj')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: GwSpacing.lg, horizontal: GwSpacing.page),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: GwLayout.contentMaxWidth),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Ne hakkında yazıyorsun?', style: textTheme.titleMedium),
                  const SizedBox(height: GwSpacing.sm),
                  for (final kind in SupportKind.values) ...[
                    _KindCard(kind: kind, selected: _kind == kind, onTap: () => setState(() {
                          _kind = kind;
                          _kindMissing = false;
                        })),
                    const SizedBox(height: GwSpacing.xs),
                  ],
                  if (_kindMissing)
                    Text('Bir tür seç.', style: textTheme.bodySmall?.copyWith(color: GwColors.error)),
                  gap,
                  GwPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (groups.isNotEmpty) ...[
                          DropdownButtonFormField<String?>(
                            initialValue: groups.any((g) => g.id == _groupId) ? _groupId : null,
                            decoration: const InputDecoration(labelText: 'İlgili grup (isteğe bağlı)'),
                            items: [
                              const DropdownMenuItem(child: Text('Grupla ilgili değil')),
                              for (final g in groups) DropdownMenuItem(value: g.id, child: Text(g.name)),
                            ],
                            onChanged: (v) => setState(() => _groupId = v),
                          ),
                          gap,
                        ],
                        TextFormField(
                          controller: _subject,
                          maxLength: SupportRules.subjectMax,
                          decoration: const InputDecoration(labelText: 'Konu', counterText: ''),
                          validator: (v) => (v?.trim().length ?? 0) < SupportRules.subjectMin ? 'Kısa bir konu yaz.' : null,
                        ),
                        gap,
                        TextFormField(
                          controller: _body,
                          maxLength: SupportRules.bodyMax,
                          minLines: 5,
                          maxLines: 10,
                          decoration: const InputDecoration(
                            labelText: 'Açıklama',
                            hintText: 'Ne oldu, ne bekliyordun? Ne kadar ayrıntı, o kadar hızlı yardım.',
                            alignLabelWithHint: true,
                          ),
                          validator: (v) => (v?.trim().isEmpty ?? true) ? 'Ne olduğunu kısaca anlat.' : null,
                        ),
                        gap,
                        ImageAttachments(
                          images: _images,
                          onAdd: _sending ? null : _addImage,
                          onRemove: (i) => setState(() => _images.removeAt(i)),
                        ),
                        if (_error != null) ...[gap, GwFormMessage(_error!)],
                        const SizedBox(height: GwSpacing.lg),
                        GwButton(label: 'Gönder', icon: Icons.send_outlined, expand: true, isLoading: _sending, onPressed: _send),
                      ],
                    ),
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

/// Selectable card in the kind's color.
class _KindCard extends StatelessWidget {
  const _KindCard({required this.kind, required this.selected, required this.onTap});

  final SupportKind kind;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? kind.softColor : GwColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: GwRadius.lgAll,
          side: selected ? BorderSide(color: kind.color, width: 1.5) : GwBorders.hairline,
        ),
        child: InkWell(
          borderRadius: GwRadius.lgAll,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(GwSpacing.md),
            child: Row(
              children: [
                SupportKindIcon(kind),
                const SizedBox(width: GwSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(kind.label, style: textTheme.titleMedium),
                      Text(kind.description, style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
                    ],
                  ),
                ),
                if (selected) Icon(Icons.check_circle, color: kind.color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
