import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/events.dart';
import '../domain/tonight.dart';
import '../l10n.dart';
import 'providers.dart';

/// Opens a conversation (the messaging feature lives in the app).
typedef OpenTonightChat = void Function(BuildContext context, String conversationId);

/// The user's evening on the "Bu akşam" page: their status, invitations, their table
/// and who else is free (docs/ARCHITECTURE.md §3d, Bu akşam boşum ve küçük masa).
class TonightCard extends ConsumerStatefulWidget {
  const TonightCard({super.key, required this.openChat});

  final OpenTonightChat openChat;

  @override
  ConsumerState<TonightCard> createState() => _TonightCardState();
}

class _TonightCardState extends ConsumerState<TonightCard> {
  bool _busy = false;

  Future<void> _run(Future<Result<Object?>> Function(EventsRepository repo) action, String Function(Object? value) done) async {
    setState(() => _busy = true);
    final result = await action(ref.read(eventsRepositoryProvider));
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(switch (result) {
        Ok(:final value) => done(value),
        Err(:final failure) => failure.userMessage,
      }),
    ));
    ref
      ..invalidate(tonightProvider)
      ..invalidate(tonightPeopleProvider);
  }

  Future<void> _setFree() async {
    final note = await showDialog<String>(context: context, builder: (_) => const _FreeDialog());
    if (note == null) return;
    await _run((r) => r.setFree(note), (_) => eventsL10n.tonightVisible);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tonight = ref.watch(tonightProvider);
    final t = tonight.value;
    if (t == null) {
      return switch (tonight) {
        AsyncError(:final error) => GwFormMessage(userMessageOf(error)),
        _ => const GwSkeleton(height: GwSpacing.xxl * 3, borderRadius: GwRadius.lgAll),
      };
    }
    final secondary = textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary);
    final note = t.note ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final invite in t.invites)
          Padding(
            padding: const EdgeInsets.only(bottom: GwSpacing.sm),
            child: _InviteBlock(
              invite: invite,
              busy: _busy,
              onAnswer: (accept) => _run(
                (r) => r.answerTable(invite.id, accept: accept),
                (_) => accept ? eventsL10n.joinedTable : eventsL10n.declinedInvite,
              ),
            ),
          ),
        GwCard(
          radius: GwRadius.lgAll,
          padding: const EdgeInsets.all(GwSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const _IconTile(icon: Icons.nights_stay_rounded),
                  const SizedBox(width: GwSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(eventsL10n.yourStatus, style: textTheme.titleMedium),
                        Text(t.isFree ? eventsL10n.visibleUntil4 : eventsL10n.notVisible, style: secondary),
                      ],
                    ),
                  ),
                  if (t.isFree) GwBadge(eventsL10n.youreFree, tone: GwBadgeTone.success, dot: true),
                ],
              ),
              const SizedBox(height: GwSpacing.md),
              if (!t.isFree) ...[
                Text(eventsL10n.tonightIntro, style: secondary),
                const SizedBox(height: GwSpacing.md),
                GwButton(label: eventsL10n.imFreeTonight, icon: Icons.local_cafe_outlined, isLoading: _busy, expand: true, onPressed: _setFree),
              ] else ...[
                if (note.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: GwSpacing.sm, vertical: GwSpacing.xs),
                    decoration: const BoxDecoration(color: GwColors.surfaceMuted, borderRadius: GwRadius.mdAll),
                    child: Row(
                      children: [
                        const Icon(Icons.format_quote_rounded, size: GwSpacing.md + GwSpacing.xxs, color: GwColors.textSecondary),
                        const SizedBox(width: GwSpacing.xs),
                        Expanded(child: Text(eventsL10n.quoted(note), style: textTheme.bodyLarge)),
                      ],
                    ),
                  ),
                if (t.table == null)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      onPressed: _busy ? null : () => _run((r) => r.clearFree(), (_) => eventsL10n.noLongerFree),
                      icon: const Icon(Icons.visibility_off_outlined),
                      label: Text(eventsL10n.turnOffStatus),
                    ),
                  ),
              ],
              const _FreePeople(),
            ],
          ),
        ),
        if (t.table case final table?)
          Padding(
            padding: const EdgeInsets.only(top: GwSpacing.sm),
            child: _TableBlock(
              table: table,
              busy: _busy,
              onOpenChat: (id) => widget.openChat(context, id),
              onLeave: () => _run((r) => r.leaveTable(table.id), (_) => eventsL10n.leftTable),
            ),
          )
        else if (t.isFree)
          Padding(
            padding: const EdgeInsets.only(top: GwSpacing.sm),
            child: GwCard(
              radius: GwRadius.lgAll,
              padding: const EdgeInsets.all(GwSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const _IconTile(icon: Icons.table_restaurant_outlined, tone: GwTone.sky),
                      const SizedBox(width: GwSpacing.sm),
                      Expanded(child: Text(eventsL10n.smallTable, style: textTheme.titleMedium)),
                    ],
                  ),
                  const SizedBox(height: GwSpacing.sm),
                  if (t.canSetTable) ...[
                    Text(eventsL10n.smallTableHint, style: secondary),
                    const SizedBox(height: GwSpacing.md),
                    GwButton(
                      label: eventsL10n.setUpTable,
                      icon: Icons.table_restaurant_outlined,
                      variant: GwButtonVariant.secondary,
                      isLoading: _busy,
                      expand: true,
                      onPressed: () => _run(
                        (r) => r.createTable(),
                        (n) => eventsL10n.tableInvitesSent(n! as int),
                      ),
                    ),
                  ] else
                    Text(
                      eventsL10n.needMorePeople(Tonight.minCandidates, t.candidates),
                      style: secondary,
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// A soft, rounded square behind a section icon.
class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon, this.tone = GwTone.lilac});

  final IconData icon;
  final GwTone tone;

  @override
  Widget build(BuildContext context) => Container(
        width: GwAvatarSize.md.dimension,
        height: GwAvatarSize.md.dimension,
        decoration: BoxDecoration(color: tone.soft, borderRadius: GwRadius.mdAll),
        child: Icon(icon, color: tone.strong),
      );
}

/// Who else is free tonight among the people sharing a group: overlapping faces and a count.
class _FreePeople extends ConsumerWidget {
  const _FreePeople();

  static const _faces = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final people = ref.watch(tonightPeopleProvider).value;
    if (people == null || people.isEmpty) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: GwSpacing.sm),
      child: Row(
        children: [
          _Faces(people: people.take(_faces).toList()),
          const SizedBox(width: GwSpacing.sm),
          Expanded(
            child: Text(
              eventsL10n.freeFromGroups(people.length),
              style: textTheme.labelLarge?.copyWith(color: GwColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

/// The note when saying "boşum"; null when cancelled.
class _FreeDialog extends StatefulWidget {
  const _FreeDialog();

  @override
  State<_FreeDialog> createState() => _FreeDialogState();
}

class _FreeDialogState extends State<_FreeDialog> {
  final _note = TextEditingController();

  static List<String> get _ideas => [eventsL10n.chipCoffee, eventsL10n.chipWalk, eventsL10n.chipFood, eventsL10n.chipCinema];

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: GwRadius.xlAll),
        title: Text(eventsL10n.imFreeTonight),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(eventsL10n.tonightSheetHint),
              const SizedBox(height: GwSpacing.md),
              TextField(
                controller: _note,
                maxLength: 80,
                decoration: InputDecoration(labelText: eventsL10n.whatToDo, hintText: eventsL10n.whatToDoHint),
              ),
              Wrap(
                spacing: GwSpacing.xs,
                runSpacing: GwSpacing.xs,
                children: [
                  for (final idea in _ideas)
                    ActionChip(label: Text(idea), onPressed: () => setState(() => _note.text = idea)),
                ],
              ),
            ],
          ),
        ),
        actions: [
          GwButton(label: eventsL10n.cancel, variant: GwButtonVariant.text, onPressed: () => Navigator.of(context).pop()),
          GwButton(label: eventsL10n.imFree, onPressed: () => Navigator.of(context).pop(_note.text.trim())),
        ],
      );
}

/// Faces overlapping in a row, each ringed in white.
class _Faces extends StatelessWidget {
  const _Faces({required this.people});

  final List<TonightPerson> people;

  static const _size = GwAvatarSize.sm;
  static const _step = GwSpacing.lg;

  @override
  Widget build(BuildContext context) {
    final edge = _size.dimension + GwBorders.ringWidth * 2;
    return SizedBox(
      width: edge + _step * (people.length - 1),
      height: edge,
      child: Stack(
        children: [
          for (final (i, p) in people.indexed)
            PositionedDirectional(
              start: _step * i,
              child: Tooltip(
                message: p.displayName,
                child: Container(
                  padding: const EdgeInsets.all(GwBorders.ringWidth),
                  decoration: const ShapeDecoration(color: GwColors.background, shape: CircleBorder()),
                  child: GwAvatar(name: p.displayName, imageUrl: p.avatarUrl, shape: GwAvatarShape.user, size: _size),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TableBlock extends StatelessWidget {
  const _TableBlock({required this.table, required this.busy, required this.onOpenChat, required this.onLeave});

  final TonightTable table;
  final bool busy;
  final ValueChanged<String> onOpenChat;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final chat = table.conversationId;
    return GwCard(
      radius: GwRadius.lgAll,
      padding: const EdgeInsets.all(GwSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const _IconTile(icon: Icons.table_restaurant_outlined, tone: GwTone.sky),
              const SizedBox(width: GwSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(eventsL10n.yourTable, style: textTheme.titleMedium),
                    Text(
                      [
                        eventsL10n.joinedCount(table.joined.length),
                        if (table.pending > 0) eventsL10n.waitingCount(table.pending),
                      ].join(' · '),
                      style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary),
                    ),
                  ],
                ),
              ),
              GwBadge(chat == null ? eventsL10n.settingUp : eventsL10n.chatOpen, tone: chat == null ? GwBadgeTone.warning : GwBadgeTone.success, dot: true),
            ],
          ),
          const SizedBox(height: GwSpacing.sm),
          Align(alignment: AlignmentDirectional.centerStart, child: _Faces(people: table.joined)),
          const SizedBox(height: GwSpacing.sm),
          if (chat != null)
            GwButton(label: eventsL10n.tableChat, icon: Icons.forum_outlined, expand: true, onPressed: () => onOpenChat(chat))
          else
            Text(eventsL10n.chatOpensWhen(table.missing),
                style: textTheme.bodyMedium),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(onPressed: busy ? null : onLeave, child: Text(eventsL10n.leaveTable)),
          ),
        ],
      ),
    );
  }
}

class _InviteBlock extends StatelessWidget {
  const _InviteBlock({required this.invite, required this.busy, required this.onAnswer});

  final TonightTable invite;
  final bool busy;
  final ValueChanged<bool> onAnswer;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(GwSpacing.md),
      decoration: const BoxDecoration(
        color: GwColors.primarySoft,
        borderRadius: GwRadius.lgAll,
        border: Border.fromBorderSide(GwBorders.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GwAvatar(name: invite.founder.displayName, imageUrl: invite.founder.avatarUrl, shape: GwAvatarShape.user),
              const SizedBox(width: GwSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(eventsL10n.tableInviteTitle(invite.founder.displayName), style: textTheme.titleSmall),
                    const SizedBox(height: GwSpacing.xxs),
                    Text(
                      eventsL10n.tableInviteStatus(invite.joined.length, invite.pending),
                      style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: GwSpacing.sm),
          Wrap(
            spacing: GwSpacing.xs,
            runSpacing: GwSpacing.xs,
            children: [
              GwButton(label: eventsL10n.join, icon: Icons.check, isLoading: busy, onPressed: () => onAnswer(true)),
              GwButton(label: eventsL10n.notTonight, variant: GwButtonVariant.secondary, onPressed: busy ? null : () => onAnswer(false)),
            ],
          ),
        ],
      ),
    );
  }
}

/// "Bu akşam" (from the create sheet): the user's status and table, then the people free tonight
/// who share a group with the user, then how it works.
class TonightScreen extends ConsumerWidget {
  const TonightScreen({super.key, required this.openChat, required this.openProfile});

  final OpenTonightChat openChat;
  final void Function(BuildContext context, String username) openProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final people = ref.watch(tonightPeopleProvider);
    const header = EdgeInsets.fromLTRB(GwSpacing.xxs, GwSpacing.lg, GwSpacing.xxs, GwSpacing.xs);

    return Scaffold(
      appBar: AppBar(title: Text(eventsL10n.tonight)),
      body: GwReadingColumn(
        child: RefreshIndicator(
          onRefresh: () async => ref
            ..invalidate(tonightProvider)
            ..invalidate(tonightPeopleProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(GwSpacing.page, GwSpacing.xs, GwSpacing.page, GwSpacing.xl),
            children: [
              TonightCard(openChat: openChat),
              GwSectionHeader(title: eventsL10n.freeTonight, subtitle: eventsL10n.sharedGroupsOnly, padding: header),
              switch (people) {
                AsyncData(:final value) when value.isEmpty => GwCard(
                    radius: GwRadius.lgAll,
                    child: GwEmptyState(
                      icon: Icons.nights_stay_outlined,
                      message: eventsL10n.nobodyFree,
                      actionLabel: eventsL10n.refresh,
                      onAction: () => ref.invalidate(tonightPeopleProvider),
                    ),
                  ),
                AsyncData(:final value) => GwCard(
                    radius: GwRadius.lgAll,
                    child: Column(
                      children: [
                        for (final (i, p) in value.indexed) ...[
                          if (i > 0) const Divider(height: 1, indent: GwSpacing.md, endIndent: GwSpacing.md),
                          _PersonTile(person: p, onTap: () => openProfile(context, p.username)),
                        ],
                      ],
                    ),
                  ),
                AsyncError(:final error) =>
                  GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(tonightPeopleProvider)),
                _ => const GwSkeleton(height: GwSpacing.xxl * 3, borderRadius: GwRadius.lgAll),
              },
              GwSectionHeader(title: eventsL10n.howItWorks, padding: header),
              const _HowItWorks(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PersonTile extends StatelessWidget {
  const _PersonTile({required this.person, required this.onTap});

  final TonightPerson person;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: GwSpacing.md, vertical: GwSpacing.sm),
        child: Row(
          children: [
            GwAvatar(name: person.displayName, imageUrl: person.avatarUrl, shape: GwAvatarShape.user),
            const SizedBox(width: GwSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(person.displayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.titleSmall),
                  if (person.note.isNotEmpty)
                    Text(eventsL10n.quoted(person.note), maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.bodyMedium),
                  if (person.groups.isNotEmpty)
                    Text(
                      person.groups.join(', '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: GwColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

/// The three steps of an evening, numbered.
class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  static List<String> get _steps => [
    eventsL10n.howStep1,
    eventsL10n.howStep2,
    eventsL10n.howStep3,
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GwCard(
      radius: GwRadius.lgAll,
      padding: const EdgeInsets.all(GwSpacing.md),
      child: Column(
        children: [
          for (final (i, step) in _steps.indexed)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : GwSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: GwSpacing.lg,
                    height: GwSpacing.lg,
                    alignment: Alignment.center,
                    decoration: const ShapeDecoration(color: GwColors.primarySoft, shape: CircleBorder()),
                    child: Text(
                      '${i + 1}',
                      textScaler: TextScaler.noScaling,
                      style: textTheme.labelMedium?.copyWith(color: GwColors.primary, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: GwSpacing.sm),
                  Expanded(child: Text(step, style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
