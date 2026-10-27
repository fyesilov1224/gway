import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/moderation.dart';
import 'providers.dart';

/// The report sheet (docs/ARCHITECTURE.md §3e); the app provides it as `reportLauncherProvider`.
Future<void> showReportSheet(BuildContext context, ReportTarget target) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _ReportSheet(target: target),
    );

class _ReportSheet extends ConsumerStatefulWidget {
  const _ReportSheet({required this.target});

  final ReportTarget target;

  @override
  ConsumerState<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends ConsumerState<_ReportSheet> {
  final _note = TextEditingController();
  ReportReason? _reason;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  String get _title => switch (widget.target.type) {
        'post' => 'Gönderiyi şikayet et',
        'comment' || 'live_comment' => 'Yorumu şikayet et',
        'event' => 'Organizasyonu şikayet et',
        'message' => 'Mesajı şikayet et',
        'match_profile' => 'Eşleşme profilini şikayet et',
        'match_photo' => 'Fotoğrafı şikayet et',
        _ => 'Kullanıcıyı şikayet et',
      };

  Future<void> _submit() async {
    final reason = _reason;
    if (reason == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ref.read(moderationRepositoryProvider).report(widget.target, reason, note: _note.text);
    if (!mounted) return;
    switch (result) {
      case Ok():
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop();
        messenger.showSnackBar(const SnackBar(content: Text('Şikayetin alındı. İnceleyip gerekeni yapacağız; kimliğin şikayet edilen kişiye gösterilmez.')));
      case Err(:final failure):
        setState(() {
          _busy = false;
          _error = failure.userMessage;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(GxSpacing.page, 0, GxSpacing.page, GxSpacing.lg + MediaQuery.viewInsetsOf(context).bottom),
      child: ListView(
        shrinkWrap: true,
        children: [
          Text(_title, style: textTheme.titleLarge),
          const SizedBox(height: GxSpacing.xxs),
          Text('Neden şikayet ediyorsun?', style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary)),
          const SizedBox(height: GxSpacing.xs),
          RadioGroup<ReportReason>(
            groupValue: _reason,
            onChanged: (r) => setState(() => _reason = r),
            child: Column(
              children: [
                for (final r in ReportReason.values)
                  RadioListTile<ReportReason>(contentPadding: EdgeInsets.zero, value: r, title: Text(r.label)),
              ],
            ),
          ),
          TextField(
            controller: _note,
            maxLength: 500,
            maxLines: 3,
            minLines: 1,
            decoration: const InputDecoration(labelText: 'Açıklama (isteğe bağlı)', hintText: 'Ne olduğunu kısaca anlat.'),
          ),
          if (_error != null) ...[const SizedBox(height: GxSpacing.sm), GxFormMessage(_error!)],
          const SizedBox(height: GxSpacing.md),
          GxButton(
            label: 'Şikayet et',
            icon: Icons.flag_outlined,
            isLoading: _busy,
            expand: true,
            onPressed: _reason == null ? null : _submit,
          ),
        ],
      ),
    );
  }
}
