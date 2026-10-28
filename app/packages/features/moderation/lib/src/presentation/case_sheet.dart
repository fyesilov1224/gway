import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/moderation.dart';
import 'providers.dart';

/// Opens a discipline case about [subjectName] (docs/ARCHITECTURE.md §3e); true when opened.
/// [canMute] offers the emergency mute; [reportId] links the case to the reports of a target.
Future<bool> showCaseSheet(
  BuildContext context, {
  required String groupId,
  required String subjectId,
  required String subjectName,
  bool canMute = false,
  String? reportId,
}) async =>
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _CaseSheet(groupId: groupId, subjectId: subjectId, subjectName: subjectName, canMute: canMute, reportId: reportId),
    ) ??
    false;

class _CaseSheet extends ConsumerStatefulWidget {
  const _CaseSheet({required this.groupId, required this.subjectId, required this.subjectName, required this.canMute, this.reportId});

  final String groupId;
  final String subjectId;
  final String subjectName;
  final bool canMute;
  final String? reportId;

  @override
  ConsumerState<_CaseSheet> createState() => _CaseSheetState();
}

class _CaseSheetState extends ConsumerState<_CaseSheet> {
  final _form = GlobalKey<FormState>();
  final _reason = TextEditingController();
  SanctionType _sanction = SanctionType.warning;
  int? _days;
  bool _muteNow = false;
  IllegalCategory? _illegal;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  void _pick(SanctionType type) => setState(() {
        _sanction = type;
        _days = type.durations.firstOrNull;
        if (type != SanctionType.ban) _illegal = null;
      });

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ref.read(moderationRepositoryProvider).openCase(
          widget.groupId,
          CaseForm(
            subjectId: widget.subjectId,
            sanction: _sanction,
            durationDays: _days,
            reason: _reason.text,
            reportId: widget.reportId,
            muteNow: _muteNow,
            illegalCategory: _illegal,
          ),
        );
    if (!mounted) return;
    switch (result) {
      case Ok():
        ref.invalidate(groupModerationProvider(widget.groupId));
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop(true);
        messenger.showSnackBar(const SnackBar(content: Text('Dosya açıldı. Kurul 72 saat içinde oy verecek.')));
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
    final durations = _sanction.durations;
    return Padding(
      padding: EdgeInsets.fromLTRB(GxSpacing.page, 0, GxSpacing.page, GxSpacing.lg + MediaQuery.viewInsetsOf(context).bottom),
      child: Form(
        key: _form,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text('Disiplin dosyası aç', style: textTheme.titleLarge),
            const SizedBox(height: GxSpacing.xxs),
            Text(
              '${widget.subjectName} hakkında. Önerdiğin yaptırımı disiplin kurulu 72 saat içinde oylar.',
              style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary),
            ),
            const SizedBox(height: GxSpacing.md),
            Text('Önerilen yaptırım', style: textTheme.labelLarge),
            const SizedBox(height: GxSpacing.xs),
            Wrap(
              spacing: GxSpacing.xs,
              runSpacing: GxSpacing.xs,
              children: [
                for (final s in SanctionType.values)
                  ChoiceChip(label: Text(s.label), selected: _sanction == s, onSelected: (_) => _pick(s)),
              ],
            ),
            if (durations.isNotEmpty) ...[
              const SizedBox(height: GxSpacing.md),
              Text('Süre', style: textTheme.labelLarge),
              const SizedBox(height: GxSpacing.xs),
              Wrap(
                spacing: GxSpacing.xs,
                runSpacing: GxSpacing.xs,
                children: [
                  for (final d in durations)
                    ChoiceChip(
                      label: Text(d == null ? 'Kalıcı' : '$d gün'),
                      selected: _days == d,
                      onSelected: (_) => setState(() => _days = d),
                    ),
                ],
              ),
            ],
            if (_sanction == SanctionType.ban) ...[
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _illegal != null,
                onChanged: (v) => setState(() => _illegal = v ? IllegalCategory.values.first : null),
                title: const Text('Yasa dışı faaliyet'),
                subtitle: const Text(
                  'Kurul onaylarsa dosya platform ekibine gider ve hesap incelemeye kadar askıya alınır. Bu işaret sonradan değişmez.',
                ),
              ),
              if (_illegal != null)
                Wrap(
                  spacing: GxSpacing.xs,
                  runSpacing: GxSpacing.xs,
                  children: [
                    for (final c in IllegalCategory.values)
                      ChoiceChip(label: Text(c.label), selected: _illegal == c, onSelected: (_) => setState(() => _illegal = c)),
                  ],
                ),
            ],
            const SizedBox(height: GxSpacing.md),
            TextFormField(
              controller: _reason,
              maxLength: 1000,
              minLines: 2,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Gerekçe', hintText: 'Ne oldu? Kurul bu metne bakarak oy verecek.'),
              validator: (v) => (v ?? '').trim().length < 10 ? 'Gerekçe en az 10 karakter olmalı.' : null,
            ),
            if (widget.canMute)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _muteNow,
                onChanged: (v) => setState(() => _muteNow = v),
                title: const Text('Hemen sustur (24 saat)'),
                subtitle: const Text('Kurul karar verene kadar yorum yazamaz, canlı yayında konuşamaz.'),
              ),
            if (_error != null) ...[const SizedBox(height: GxSpacing.sm), GxFormMessage(_error!)],
            const SizedBox(height: GxSpacing.md),
            GxButton(label: 'Dosyayı aç', icon: Icons.gavel_outlined, isLoading: _busy, expand: true, onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
