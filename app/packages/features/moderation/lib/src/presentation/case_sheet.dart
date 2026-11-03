import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/moderation.dart';
import 'providers.dart';

/// Opens a discipline case about [subjectName] (docs/ARCHITECTURE.md §3e); true when opened.
/// [canMute] offers the emergency mute; [canBan] a ban without the board's vote; [reportId] links the case to the
/// reports of a target.
Future<bool> showCaseSheet(
  BuildContext context, {
  required String groupId,
  required String subjectId,
  required String subjectName,
  bool canMute = false,
  bool canBan = false,
  String? reportId,
}) async =>
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _CaseSheet(
        groupId: groupId,
        subjectId: subjectId,
        subjectName: subjectName,
        canMute: canMute,
        canBan: canBan,
        reportId: reportId,
      ),
    ) ??
    false;

class _CaseSheet extends ConsumerStatefulWidget {
  const _CaseSheet({
    required this.groupId,
    required this.subjectId,
    required this.subjectName,
    required this.canMute,
    required this.canBan,
    this.reportId,
  });

  final String groupId;
  final String subjectId;
  final String subjectName;
  final bool canMute;
  final bool canBan;
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
  bool _direct = false;
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
        if (type != SanctionType.ban) {
          _illegal = null;
          _direct = false;
        }
      });

  bool get _now => _direct && _sanction == SanctionType.ban;

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
            muteNow: _muteNow && !_now,
            illegalCategory: _illegal,
            direct: _now,
          ),
        );
    if (!mounted) return;
    switch (result) {
      case Ok():
        ref.invalidate(groupModerationProvider(widget.groupId));
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop(true);
        messenger.showSnackBar(SnackBar(
          content: Text(_now
              ? _illegal == null
                  ? 'Ban uygulandı.'
                  : 'Ban uygulandı. Kişinin hesabı platform incelemesine kadar askıya alındı.'
              : 'Dosya açıldı. Kurul 72 saat içinde oy verecek.'),
        ));
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
      padding: EdgeInsets.fromLTRB(GwSpacing.page, 0, GwSpacing.page, GwSpacing.lg + MediaQuery.viewInsetsOf(context).bottom),
      child: Form(
        key: _form,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text('Disiplin dosyası aç', style: textTheme.titleLarge),
            const SizedBox(height: GwSpacing.xxs),
            Text(
              _now
                  ? '${widget.subjectName} hakkında. Ban kurul oylaması olmadan hemen uygulanır.'
                  : '${widget.subjectName} hakkında. Önerdiğin yaptırımı disiplin kurulu 72 saat içinde oylar.',
              style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary),
            ),
            const SizedBox(height: GwSpacing.md),
            Text('Önerilen yaptırım', style: textTheme.labelLarge),
            const SizedBox(height: GwSpacing.xs),
            Wrap(
              spacing: GwSpacing.xs,
              runSpacing: GwSpacing.xs,
              children: [
                for (final s in SanctionType.values)
                  ChoiceChip(label: Text(s.label), selected: _sanction == s, onSelected: (_) => _pick(s)),
              ],
            ),
            if (durations.isNotEmpty) ...[
              const SizedBox(height: GwSpacing.md),
              Text('Süre', style: textTheme.labelLarge),
              const SizedBox(height: GwSpacing.xs),
              Wrap(
                spacing: GwSpacing.xs,
                runSpacing: GwSpacing.xs,
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
              if (widget.canBan)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _direct,
                  onChanged: (v) => setState(() => _direct = v),
                  title: const Text('Oylamasız, hemen uygula'),
                  subtitle: const Text('Kurulun kararını beklemeden banlar. Kişi 7 gün içinde itiraz edebilir.'),
                ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _illegal != null,
                onChanged: (v) => setState(() => _illegal = v ? IllegalCategory.values.first : null),
                title: const Text('Yasa dışı faaliyet'),
                subtitle: Text(
                  '${_now ? 'Ban uygulanınca' : 'Kurul onaylarsa'} dosya platform ekibine gider ve hesap incelemeye kadar askıya '
                  'alınır. Bu işaret sonradan değişmez.',
                ),
              ),
              if (_illegal != null)
                Wrap(
                  spacing: GwSpacing.xs,
                  runSpacing: GwSpacing.xs,
                  children: [
                    for (final c in IllegalCategory.values)
                      ChoiceChip(label: Text(c.label), selected: _illegal == c, onSelected: (_) => setState(() => _illegal = c)),
                  ],
                ),
            ],
            const SizedBox(height: GwSpacing.md),
            TextFormField(
              controller: _reason,
              maxLength: 1000,
              minLines: 2,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Gerekçe',
                hintText: _now ? 'Ne oldu? Kişi ve itirazı inceleyen bu metni görür.' : 'Ne oldu? Kurul bu metne bakarak oy verecek.',
              ),
              validator: (v) => (v ?? '').trim().length < 10 ? 'Gerekçe en az 10 karakter olmalı.' : null,
            ),
            if (widget.canMute && !_now)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _muteNow,
                onChanged: (v) => setState(() => _muteNow = v),
                title: const Text('Hemen sustur (24 saat)'),
                subtitle: const Text('Kurul karar verene kadar yorum yazamaz, canlı yayında konuşamaz.'),
              ),
            if (_error != null) ...[const SizedBox(height: GwSpacing.sm), GwFormMessage(_error!)],
            const SizedBox(height: GwSpacing.md),
            GwButton(
              label: _now ? 'Banla' : 'Dosyayı aç',
              icon: _now ? Icons.block : Icons.gavel_outlined,
              isLoading: _busy,
              expand: true,
              onPressed: _submit,
            ),

          ],
        ),
      ),
    );
  }
}
