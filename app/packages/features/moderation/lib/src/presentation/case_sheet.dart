import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/moderation.dart';
import '../l10n.dart';
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
                  ? moderationL10n.banApplied
                  : moderationL10n.banAppliedSuspended
              : moderationL10n.caseOpened),
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
            Text(moderationL10n.openCaseTitle, style: textTheme.titleLarge),
            const SizedBox(height: GwSpacing.xxs),
            Text(
              _now
                  ? moderationL10n.caseAboutNow(widget.subjectName)
                  : moderationL10n.caseAboutVote(widget.subjectName),
              style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary),
            ),
            const SizedBox(height: GwSpacing.md),
            Text(moderationL10n.proposedSanction, style: textTheme.labelLarge),
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
              Text(moderationL10n.duration, style: textTheme.labelLarge),
              const SizedBox(height: GwSpacing.xs),
              Wrap(
                spacing: GwSpacing.xs,
                runSpacing: GwSpacing.xs,
                children: [
                  for (final d in durations)
                    ChoiceChip(
                      label: Text(d == null ? moderationL10n.permanent : moderationL10n.days(d)),
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
                  title: Text(moderationL10n.applyNow),
                  subtitle: Text(moderationL10n.applyNowHint),
                ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _illegal != null,
                onChanged: (v) => setState(() => _illegal = v ? IllegalCategory.values.first : null),
                title: Text(moderationL10n.illegalActivity),
                subtitle: Text(_now ? moderationL10n.illegalHintNow : moderationL10n.illegalHintVote),
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
                labelText: moderationL10n.reason,
                hintText: _now ? moderationL10n.reasonHintNow : moderationL10n.reasonHintVote,
              ),
              validator: (v) => (v ?? '').trim().length < 10 ? moderationL10n.reasonMin10 : null,
            ),
            if (widget.canMute && !_now)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _muteNow,
                onChanged: (v) => setState(() => _muteNow = v),
                title: Text(moderationL10n.muteNow),
                subtitle: Text(moderationL10n.muteNowHint),
              ),
            if (_error != null) ...[const SizedBox(height: GwSpacing.sm), GwFormMessage(_error!)],
            const SizedBox(height: GwSpacing.md),
            GwButton(
              label: _now ? moderationL10n.ban : moderationL10n.openCase,
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
