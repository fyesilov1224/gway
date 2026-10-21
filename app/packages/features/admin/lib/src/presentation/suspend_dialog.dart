import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

typedef SuspendRequest = ({String reason, DateTime? until});

enum SuspendDuration {
  day('1 gün', Duration(days: 1)),
  week('7 gün', Duration(days: 7)),
  month('30 gün', Duration(days: 30)),
  indefinite('Süresiz', null);

  const SuspendDuration(this.label, this.duration);

  final String label;
  final Duration? duration;
}

/// Asks for a reason (required) and, unless [withDuration] is false, a
/// duration. Null when cancelled. Defaults describe suspending a user; also
/// used for content removal.
Future<SuspendRequest?> showSuspendDialog(
  BuildContext context, {
  String title = 'Kullanıcıyı askıya al',
  String description = 'Kullanıcı askı süresince giriş yapamaz ve profili gizlenir. Gerekçe kullanıcıya gösterilir.',
  bool withDuration = true,
  String confirmLabel = 'Askıya al',
}) =>
    showDialog<SuspendRequest>(
      context: context,
      builder: (_) =>
          SuspendDialog(title: title, description: description, withDuration: withDuration, confirmLabel: confirmLabel),
    );

class SuspendDialog extends StatefulWidget {
  const SuspendDialog({
    super.key,
    required this.title,
    required this.description,
    this.withDuration = true,
    this.confirmLabel = 'Askıya al',
  });

  final String title;
  final String description;
  final bool withDuration;
  final String confirmLabel;

  static const maxReasonLength = 500;

  @override
  State<SuspendDialog> createState() => _SuspendDialogState();
}

class _SuspendDialogState extends State<SuspendDialog> {
  final _form = GlobalKey<FormState>();
  final _reason = TextEditingController();
  SuspendDuration _duration = SuspendDuration.week;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  void _confirm() {
    if (!_form.currentState!.validate()) return;
    final d = widget.withDuration ? _duration.duration : null;
    Navigator.of(context).pop<SuspendRequest>(
      (reason: _reason.text.trim(), until: d == null ? null : DateTime.now().add(d)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: GxRadius.xlAll),
      title: Text(widget.title),
      content: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.description),
              const SizedBox(height: GxSpacing.md),
              TextFormField(
                controller: _reason,
                maxLength: SuspendDialog.maxReasonLength,
                minLines: 2,
                maxLines: 4,
                validator: (v) => (v ?? '').trim().isEmpty ? 'Bir gerekçe yaz.' : null,
                decoration: const InputDecoration(labelText: 'Gerekçe', alignLabelWithHint: true),
              ),
              if (widget.withDuration) ...[
                const SizedBox(height: GxSpacing.sm),
                Wrap(
                  spacing: GxSpacing.xs,
                  runSpacing: GxSpacing.xs,
                  children: [
                    for (final d in SuspendDuration.values)
                      ChoiceChip(
                        label: Text(d.label),
                        selected: _duration == d,
                        onSelected: (_) => setState(() => _duration = d),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        GxButton(label: 'Vazgeç', variant: GxButtonVariant.text, onPressed: () => Navigator.of(context).pop()),
        GxButton(label: widget.confirmLabel, onPressed: _confirm),
      ],
    );
  }
}
