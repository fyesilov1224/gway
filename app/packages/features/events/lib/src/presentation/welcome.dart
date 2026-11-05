import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/events.dart';
import '../l10n.dart';
import 'event_screens.dart';
import 'providers.dart';

/// Welcome on the event page (docs/ARCHITECTURE.md §3d, Karşılama): a first-timer asks to be greeted,
/// a going greeter takes them with a meeting note, and the first-timer thanks them afterwards.
class EventWelcomeSection extends ConsumerStatefulWidget {
  const EventWelcomeSection({super.key, required this.event, required this.links});

  final GroupEvent event;
  final EventLinks links;

  @override
  ConsumerState<EventWelcomeSection> createState() => _EventWelcomeSectionState();
}

class _EventWelcomeSectionState extends ConsumerState<EventWelcomeSection> {
  bool _busy = false;

  String get _id => widget.event.id;

  Future<void> _run(Future<Result<void>> Function(EventsRepository repo) action, String done) async {
    setState(() => _busy = true);
    final result = await action(ref.read(eventsRepositoryProvider));
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(switch (result) {
        Ok() => done,
        Err(:final failure) => failure.userMessage,
      }),
    ));
    ref.invalidate(eventWelcomeProvider(_id));
  }

  Future<void> _request() async {
    final note = await showDialog<String>(
      context: context,
      builder: (_) => _NoteDialog(
        title: eventsL10n.wantWelcome,
        message: eventsL10n.wantWelcomeHint,
        label: eventsL10n.noteForGreeter,
        hint: eventsL10n.noteForGreeterHint,
        minLength: 0,
        action: eventsL10n.sendRequest,
      ),
    );
    if (note == null) return;
    await _run(
      (r) => r.requestWelcome(_id, note: note.isEmpty ? null : note),
      eventsL10n.welcomeRequestSent,
    );
  }

  Future<void> _take(WelcomeEntry entry, {bool edit = false}) async {
    final note = await showDialog<String>(
      context: context,
      builder: (_) => _NoteDialog(
        title: edit ? eventsL10n.editMeetingNote : eventsL10n.welcomePerson(entry.person.displayName),
        message: entry.note == null ? null : eventsL10n.describedAs(entry.note!),
        label: eventsL10n.whereMeet,
        hint: eventsL10n.whereMeetHint,
        initial: entry.greeterNote,
        minLength: 3,
        action: edit ? eventsL10n.save : eventsL10n.iWillWelcome,
      ),
    );
    if (note == null) return;
    await _run(
      (r) => r.takeWelcome(_id, entry.person.id, note),
      edit ? eventsL10n.noteUpdated : eventsL10n.youWillWelcome(entry.person.displayName),
    );
  }

  Future<void> _release(WelcomeEntry entry) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(eventsL10n.stopWelcoming),
        content: Text(eventsL10n.stopWelcomingBody(entry.person.displayName)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(eventsL10n.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(eventsL10n.release)),
        ],
      ),
    );
    if (ok != true) return;
    await _run((r) => r.releaseWelcome(_id, entry.person.id), eventsL10n.releasedWelcome);
  }

  @override
  Widget build(BuildContext context) {
    final w = ref.watch(eventWelcomeProvider(_id)).value;
    if (w == null) return const SizedBox.shrink();
    final open = widget.event.isOpen(DateTime.now());
    final textTheme = Theme.of(context).textTheme;
    final secondary = textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary);

    final children = <Widget>[
      if (w.mine case final mine?) ..._mine(mine, open, textTheme, secondary),
      if (w.mine == null && w.canRequest && w.greeters > 0) ...[
        Text(eventsL10n.firstTime, style: textTheme.titleMedium),
        const SizedBox(height: GwSpacing.xxs),
        Text(
          eventsL10n.greetersAvailable(w.greeters),
          style: secondary,
        ),
        const SizedBox(height: GwSpacing.sm),
        GwButton(label: eventsL10n.wantWelcome, icon: Icons.waving_hand_outlined, isLoading: _busy, onPressed: _request),
      ],
      if (w.taken.isNotEmpty) ...[
        Text(eventsL10n.youWelcomed, style: textTheme.titleMedium),
        const SizedBox(height: GwSpacing.xs),
        for (final t in w.taken)
          _PersonRow(
            entry: t,
            links: widget.links,
            subtitle: [
              if (t.note case final note?) 'Tarif: $note',
              if (t.greeterNote case final note?) eventsL10n.meetingAt(note),
              if (t.thanked) eventsL10n.thankedYou,
            ].join(' · '),
            trailing: open
                ? PopupMenuButton<String>(
                    tooltip: eventsL10n.optionsFor(t.person.displayName),
                    enabled: !_busy,
                    onSelected: (a) => a == 'edit' ? _take(t, edit: true) : _release(t),
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'edit', child: Text(eventsL10n.editMeetingNote)),
                      PopupMenuItem(value: 'release', child: Text(eventsL10n.stopWelcoming)),
                    ],
                  )
                : null,
          ),
      ],
      if (w.open case final waiting? when waiting.isNotEmpty && open) ...[
        if (w.taken.isNotEmpty) const SizedBox(height: GwSpacing.sm),
        Text(eventsL10n.waitingWelcome(waiting.length), style: textTheme.titleMedium),
        if (!w.greeting && w.matched != null)
          Text(eventsL10n.matchedCount(w.matched!), style: secondary),
        const SizedBox(height: GwSpacing.xs),
        for (final entry in waiting)
          _PersonRow(
            entry: entry,
            links: widget.links,
            subtitle: entry.note ?? eventsL10n.firstTimer,
            trailing: w.greeting
                ? GwButton(
                    label: eventsL10n.iWillWelcome,
                    variant: GwButtonVariant.secondary,
                    onPressed: _busy || w.taken.length >= 3 ? null : () => _take(entry),
                  )
                : null,
          ),
        if (w.greeting && w.taken.length >= 3)
          Text(eventsL10n.max3Welcomes, style: secondary),
      ],
      if (w.isGreeter && !w.greeting && open && w.mine == null)
        Text(eventsL10n.greeterJoinHint, style: secondary),
    ];
    if (children.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: GwSpacing.lg),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(GwSpacing.md),
        decoration: const BoxDecoration(color: GwColors.primarySoft, borderRadius: GwRadius.lgAll),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      ),
    );
  }

  List<Widget> _mine(MyWelcome mine, bool open, TextTheme textTheme, TextStyle? secondary) {
    final greeter = mine.greeter;
    if (greeter == null) {
      return [
        Text(eventsL10n.lookingGreeter, style: textTheme.titleMedium),
        const SizedBox(height: GwSpacing.xxs),
        Text(eventsL10n.lookingGreeterHint, style: secondary),
        if (mine.note case final note?) Text(eventsL10n.yourNote(note), style: secondary),
        if (open) ...[
          const SizedBox(height: GwSpacing.xs),
          TextButton(
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            onPressed: _busy ? null : () => _run((r) => r.withdrawWelcome(_id), eventsL10n.welcomeWithdrawn),
            child: Text(eventsL10n.withdrawRequest),
          ),
        ],
      ];
    }
    return [
      Text(mine.thanked || mine.canThank ? eventsL10n.greetedBy : eventsL10n.willGreet, style: textTheme.titleMedium),
      const SizedBox(height: GwSpacing.xs),
      _PersonRow(
        entry: WelcomeEntry(person: greeter),
        links: widget.links,
        subtitle: mine.greeterNote == null ? atName(greeter.username) : eventsL10n.meetingAt(mine.greeterNote!),
      ),
      if (mine.canThank) ...[
        const SizedBox(height: GwSpacing.xs),
        GwButton(
          label: eventsL10n.thank,
          icon: Icons.favorite_border_rounded,
          isLoading: _busy,
          onPressed: () => _run((r) => r.thankGreeter(_id), eventsL10n.thankReceived(greeter.displayName)),
        ),
      ] else if (mine.thanked)
        Text(eventsL10n.thanked, style: secondary)
      else if (open)
        TextButton(
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          onPressed: _busy ? null : () => _run((r) => r.withdrawWelcome(_id), eventsL10n.welcomeWithdrawn),
          child: Text(eventsL10n.cancelWelcome),
        ),
    ];
  }
}

class _PersonRow extends StatelessWidget {
  const _PersonRow({required this.entry, required this.links, required this.subtitle, this.trailing});

  final WelcomeEntry entry;
  final EventLinks links;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final p = entry.person;
    return Padding(
      padding: const EdgeInsets.only(bottom: GwSpacing.xs),
      child: Row(
        children: [
          InkWell(
            customBorder: const CircleBorder(),
            onTap: () => links.openProfile(context, p.username),
            child: GwAvatar(name: p.displayName, imageUrl: p.avatarUrl, shape: GwAvatarShape.user, size: GwAvatarSize.sm),
          ),
          const SizedBox(width: GwSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.displayName, style: textTheme.labelLarge, overflow: TextOverflow.ellipsis),
                if (subtitle.isNotEmpty)
                  Text(subtitle, style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Asks for a short note: how to recognize the first-timer, or where to meet.
class _NoteDialog extends StatefulWidget {
  const _NoteDialog({
    required this.title,
    required this.label,
    required this.hint,
    required this.minLength,
    required this.action,
    this.message,
    this.initial,
  });

  final String title;
  final String? message;
  final String label;
  final String hint;
  final String? initial;
  final int minLength;
  final String action;

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  late final _text = TextEditingController(text: widget.initial ?? '');

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final length = _text.text.trim().length;
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.message case final message?) ...[Text(message), const SizedBox(height: GwSpacing.sm)],
          TextField(
            controller: _text,
            autofocus: true,
            maxLength: 200,
            minLines: 1,
            maxLines: 3,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(labelText: widget.label, hintText: widget.hint),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(eventsL10n.cancel)),
        TextButton(
          onPressed: length < widget.minLength ? null : () => Navigator.pop(context, _text.text.trim()),
          child: Text(widget.action),
        ),
      ],
    );
  }
}

/// The group page's welcome card: how many greeters there are, and "Karşılayıcı ol" for those who may.
class GroupWelcomeSection extends ConsumerStatefulWidget {
  const GroupWelcomeSection({super.key, required this.groupId, required this.isMember});

  final String groupId;
  final bool isMember;

  @override
  ConsumerState<GroupWelcomeSection> createState() => _GroupWelcomeSectionState();
}

class _GroupWelcomeSectionState extends ConsumerState<GroupWelcomeSection> {
  bool _busy = false;

  Future<void> _set(bool greeter) async {
    setState(() => _busy = true);
    final result = await ref.read(eventsRepositoryProvider).setGreeter(widget.groupId, greeter: greeter);
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(switch (result) {
        Ok() => greeter
            ? eventsL10n.nowGreeter
            : eventsL10n.noLongerGreeter,
        Err(:final failure) => failure.userMessage,
      }),
    ));
    ref.invalidate(groupWelcomeProvider(widget.groupId));
  }

  @override
  Widget build(BuildContext context) {
    final w = ref.watch(groupWelcomeProvider(widget.groupId)).value;
    if (w == null || (w.greeters == 0 && !w.canGreet)) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;
    final count = w.greeters;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GwSpacing.page, vertical: GwSpacing.sm),
      child: GwCard(
        padding: const EdgeInsets.all(GwSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.waving_hand_outlined, color: GwColors.primary),
                const SizedBox(width: GwSpacing.sm),
                Expanded(child: Text(eventsL10n.welcomeSection, style: textTheme.titleMedium)),
                if (w.greeters > 0) GwBadge(eventsL10n.greetersCount(count), tone: GwBadgeTone.primary),
              ],
            ),
            const SizedBox(height: GwSpacing.xs),
            Text(
              switch ((w.canGreet, w.greeters)) {
                (true, _) => eventsL10n.greeterIntro,
                (false, _) when widget.isMember => eventsL10n.greeterMemberHint(count),
                _ => eventsL10n.greeterVisitorHint(count),
              },
              style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary),
            ),
            if (w.canGreet || w.isGreeter)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(eventsL10n.becomeGreeter),
                value: w.isGreeter,
                onChanged: _busy ? null : _set,
              ),
          ],
        ),
      ),
    );
  }
}
