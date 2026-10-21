import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/events.dart';
import 'providers.dart';

void _snack(BuildContext context, String message) =>
    ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text(message)));

/// One poll: pick options to vote, then results as bars. Managers close or delete it.
class PollCard extends ConsumerStatefulWidget {
  const PollCard({super.key, required this.poll, required this.scope, required this.canManage});

  final Poll poll;
  final PollScope scope;
  final bool canManage;

  @override
  ConsumerState<PollCard> createState() => _PollCardState();
}

class _PollCardState extends ConsumerState<PollCard> {
  bool _busy = false;

  /// Pending choices of a multiple-choice poll before "Oy ver".
  late Set<int> _picked = {for (final o in widget.poll.options) if (o.mine) o.id};

  @override
  void didUpdateWidget(covariant PollCard old) {
    super.didUpdateWidget(old);
    if (old.poll != widget.poll) _picked = {for (final o in widget.poll.options) if (o.mine) o.id};
  }

  Future<void> _run(Future<Result<void>> Function(EventsRepository repo) action, {String? done}) async {
    setState(() => _busy = true);
    final result = await action(ref.read(eventsRepositoryProvider));
    if (!mounted) return;
    setState(() => _busy = false);
    switch (result) {
      case Ok():
        if (done != null) _snack(context, done);
      case Err(:final failure):
        _snack(context, failure.userMessage);
    }
    ref.invalidate(pollsProvider(widget.scope));
  }

  void _tap(PollOption o) {
    final poll = widget.poll;
    if (!poll.isOpen || _busy) return;
    if (poll.allowsMultiple) {
      setState(() => _picked.contains(o.id) ? _picked.remove(o.id) : _picked.add(o.id));
    } else {
      _run((r) => r.vote(poll, o.mine ? {} : {o.id}));
    }
  }

  Future<void> _showVoters(PollOption o) => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (context) => _Voters(option: o),
      );

  @override
  Widget build(BuildContext context) {
    final poll = widget.poll;
    final textTheme = Theme.of(context).textTheme;
    final showResults = poll.voted || !poll.isOpen;
    final meta = [
      if (!poll.isOpen) 'Kapandı' else if (poll.closesAt != null) 'Kapanış: ${formatDateTimeTr(poll.closesAt!)}',
      if (poll.allowsMultiple) 'Birden fazla seçilebilir',
      if (poll.isAnonymous) 'Gizli oylama',
      '${formatCount(poll.voters)} kişi oy verdi',
    ].join(' · ');
    final pendingChange = poll.allowsMultiple && !setEquals(_picked, {for (final o in poll.options) if (o.mine) o.id});

    return Container(
      padding: const EdgeInsets.all(GxSpacing.md),
      decoration: const BoxDecoration(
        color: GxColors.surface,
        borderRadius: GxRadius.lgAll,
        border: Border.fromBorderSide(GxBorders.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: GxSpacing.xxs / 2),
                child: Icon(Icons.poll_outlined, color: GxColors.secondary, size: GxSpacing.lg),
              ),
              const SizedBox(width: GxSpacing.xs),
              Expanded(child: Text(poll.question, style: textTheme.titleSmall)),
              if (widget.canManage)
                PopupMenuButton<String>(
                  tooltip: 'Anket seçenekleri',
                  onSelected: (action) => switch (action) {
                    'close' => _run((r) => r.closePoll(poll.id), done: 'Anket kapatıldı.'),
                    _ => _run((r) => r.deletePoll(poll.id), done: 'Anket silindi.'),
                  },
                  itemBuilder: (_) => [
                    if (poll.isOpen) const PopupMenuItem(value: 'close', child: Text('Anketi kapat')),
                    const PopupMenuItem(value: 'delete', child: Text('Anketi sil')),
                  ],
                ),
            ],
          ),
          const SizedBox(height: GxSpacing.xxs),
          Text(meta, style: textTheme.bodySmall?.copyWith(color: GxColors.textSecondary)),
          const SizedBox(height: GxSpacing.sm),
          for (final o in poll.options)
            Padding(
              padding: const EdgeInsets.only(bottom: GxSpacing.xs),
              child: _OptionRow(
                option: o,
                share: poll.share(o),
                showResult: showResults,
                selected: poll.allowsMultiple ? _picked.contains(o.id) : o.mine,
                multiple: poll.allowsMultiple,
                enabled: poll.isOpen && !_busy,
                onTap: () => _tap(o),
                onShowVoters: showResults && !poll.isAnonymous && o.votes > 0 ? () => _showVoters(o) : null,
              ),
            ),
          if (poll.allowsMultiple && poll.isOpen && pendingChange)
            Align(
              alignment: Alignment.centerRight,
              child: GxButton(
                label: 'Oy ver',
                isLoading: _busy,
                onPressed: () => _run((r) => r.vote(poll, _picked), done: 'Oyun kaydedildi.'),
              ),
            ),
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.option,
    required this.share,
    required this.showResult,
    required this.selected,
    required this.multiple,
    required this.enabled,
    required this.onTap,
    required this.onShowVoters,
  });

  final PollOption option;
  final double share;
  final bool showResult;
  final bool selected;
  final bool multiple;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback? onShowVoters;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final percent = '${(share * 100).round()}%';
    return Semantics(
      button: enabled,
      selected: selected,
      label: showResult ? '${option.label}, $percent, ${option.votes} oy' : option.label,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: GxRadius.mdAll,
        onTap: enabled ? onTap : null,
        onLongPress: onShowVoters,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: GxSpacing.minTouchTarget),
          child: Stack(
            children: [
              if (showResult)
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: share,
                      heightFactor: 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: selected ? GxColors.primarySoft : GxColors.surfaceMuted,
                          borderRadius: GxRadius.mdAll,
                        ),
                      ),
                    ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: GxSpacing.sm, vertical: GxSpacing.xs),
                decoration: BoxDecoration(
                  borderRadius: GxRadius.mdAll,
                  border: Border.all(color: selected ? GxColors.primary : GxColors.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      multiple
                          ? (selected ? Icons.check_box : Icons.check_box_outline_blank)
                          : (selected ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                      size: GxSpacing.md + GxSpacing.xxs,
                      color: selected ? GxColors.primary : GxColors.textSecondary,
                    ),
                    const SizedBox(width: GxSpacing.xs),
                    Expanded(child: Text(option.label, style: textTheme.bodyMedium)),
                    if (showResult) ...[
                      const SizedBox(width: GxSpacing.xs),
                      Text(percent, style: textTheme.labelLarge),
                      if (onShowVoters != null) ...[
                        const SizedBox(width: GxSpacing.xxs),
                        IconButton(
                          tooltip: 'Oy verenler',
                          visualDensity: VisualDensity.compact,
                          onPressed: onShowVoters,
                          icon: const Icon(Icons.people_outline, size: GxSpacing.md + GxSpacing.xxs),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Voters extends ConsumerWidget {
  const _Voters({required this.option});

  final PollOption option;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voters = ref.watch(pollVotersProvider(option.id));
    return SafeArea(
      child: switch (voters) {
        AsyncData(:final value) => ListView(
            shrinkWrap: true,
            children: [
              ListTile(title: Text(option.label, style: Theme.of(context).textTheme.titleMedium), subtitle: Text('${value.length} kişi')),
              for (final p in value)
                ListTile(
                  leading: GxAvatar(name: p.displayName, imageUrl: p.avatarUrl, shape: GxAvatarShape.user, size: GxAvatarSize.sm),
                  title: Text(p.displayName),
                  subtitle: Text('@${p.username}'),
                ),
            ],
          ),
        AsyncError(:final error) => Padding(
            padding: const EdgeInsets.all(GxSpacing.lg),
            child: GxErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(pollVotersProvider(option.id))),
          ),
        _ => const Padding(padding: EdgeInsets.all(GxSpacing.lg), child: Center(child: CircularProgressIndicator())),
      },
    );
  }
}

/// A group's (or one event's) polls with an "Anket aç" action for managers.
class PollsSection extends ConsumerWidget {
  const PollsSection({super.key, required this.scope, required this.canManage, this.title = 'Anketler'});

  final PollScope scope;
  final bool canManage;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final polls = ref.watch(pollsProvider(scope)).value ?? const <Poll>[];
    if (polls.isEmpty && !canManage) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GxSpacing.page, vertical: GxSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: textTheme.titleMedium)),
              if (canManage)
                TextButton.icon(
                  onPressed: () => showPollEditor(context, scope: scope),
                  icon: const Icon(Icons.add_chart_outlined, size: GxSpacing.md + GxSpacing.xxs),
                  label: const Text('Anket aç'),
                ),
            ],
          ),
          const SizedBox(height: GxSpacing.xs),
          if (polls.isEmpty)
            Text('Üyelere bir soru sor; örneğin hangi gün buluşalım?',
                style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary))
          else
            for (final p in polls) ...[PollCard(poll: p, scope: scope, canManage: canManage), const SizedBox(height: GxSpacing.sm)],
        ],
      ),
    );
  }
}

Future<void> showPollEditor(BuildContext context, {required PollScope scope}) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _PollEditor(scope: scope),
    );

class _PollEditor extends ConsumerStatefulWidget {
  const _PollEditor({required this.scope});

  final PollScope scope;

  @override
  ConsumerState<_PollEditor> createState() => _PollEditorState();
}

class _PollEditorState extends ConsumerState<_PollEditor> {
  final _form = GlobalKey<FormState>();
  final _question = TextEditingController();
  final _options = [TextEditingController(), TextEditingController()];
  bool _multiple = false;
  bool _anonymous = false;
  DateTime? _closesAt;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _question.dispose();
    for (final c in _options) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickClose() async {
    final now = DateTime.now();
    final day = await showDatePicker(context: context, initialDate: now.add(const Duration(days: 1)), firstDate: now, lastDate: now.add(const Duration(days: 90)));
    if (day == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 20, minute: 0));
    if (time == null) return;
    setState(() => _closesAt = DateTime(day.year, day.month, day.day, time.hour, time.minute));
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ref.read(eventsRepositoryProvider).createPoll(
          widget.scope.groupId,
          PollForm(
            question: _question.text,
            options: [for (final c in _options) c.text],
            allowsMultiple: _multiple,
            isAnonymous: _anonymous,
            closesAt: _closesAt,
            eventId: widget.scope.eventId,
          ),
        );
    if (!mounted) return;
    switch (result) {
      case Ok():
        ref.invalidate(pollsProvider(widget.scope));
        Navigator.of(context).pop();
        _snack(context, 'Anket açıldı.');
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
      child: Form(
        key: _form,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text('Anket aç', style: textTheme.titleLarge),
            const SizedBox(height: GxSpacing.md),
            TextFormField(
              controller: _question,
              maxLength: 200,
              decoration: const InputDecoration(labelText: 'Soru', hintText: 'Ör. Hangi gün buluşalım?'),
              validator: (v) => (v ?? '').trim().length < 3 ? 'Soru en az 3 karakter olmalı.' : null,
            ),
            for (final (i, c) in _options.indexed)
              Padding(
                padding: const EdgeInsets.only(top: GxSpacing.xs),
                child: TextFormField(
                  controller: c,
                  maxLength: 80,
                  decoration: InputDecoration(
                    labelText: '${i + 1}. seçenek',
                    counterText: '',
                    suffixIcon: _options.length > 2
                        ? IconButton(
                            tooltip: 'Seçeneği kaldır',
                            icon: const Icon(Icons.close),
                            onPressed: () => setState(() => _options.removeAt(i).dispose()),
                          )
                        : null,
                  ),
                  validator: (v) => (v ?? '').trim().isEmpty ? 'Seçeneği yaz ya da kaldır.' : null,
                ),
              ),
            if (_options.length < 10)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() => _options.add(TextEditingController())),
                  icon: const Icon(Icons.add),
                  label: const Text('Seçenek ekle'),
                ),
              ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _multiple,
              onChanged: (v) => setState(() => _multiple = v),
              title: const Text('Birden fazla seçilebilsin'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _anonymous,
              onChanged: (v) => setState(() => _anonymous = v),
              title: const Text('Gizli oylama'),
              subtitle: const Text('Kimin neye oy verdiği gösterilmez.'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule),
              title: Text(_closesAt == null ? 'Bitiş zamanı yok' : 'Kapanış: ${formatDateTimeTr(_closesAt!)}'),
              trailing: _closesAt == null
                  ? TextButton(onPressed: _pickClose, child: const Text('Ekle'))
                  : IconButton(tooltip: 'Bitiş zamanını kaldır', icon: const Icon(Icons.close), onPressed: () => setState(() => _closesAt = null)),
            ),
            if (_error != null) ...[const SizedBox(height: GxSpacing.sm), GxFormMessage(_error!)],
            const SizedBox(height: GxSpacing.md),
            GxButton(label: 'Anketi aç', icon: Icons.poll_outlined, isLoading: _busy, expand: true, onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
