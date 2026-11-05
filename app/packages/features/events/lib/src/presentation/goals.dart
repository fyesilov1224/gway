import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/events.dart';
import '../domain/goals.dart';
import '../l10n.dart';
import 'providers.dart';
import 'routes.dart';

void _snack(BuildContext context, String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

/// "21 Ekim – 20 Kasım".
String goalPeriod(Goal g) {
  final from = formatDate(g.startsAt);
  final to = formatDate(g.endsAt);
  return '${from.substring(0, from.lastIndexOf(' '))} – $to';
}

/// A goal in a list: kind, period and the viewer's progress (docs/ARCHITECTURE.md §3d, Hedefler ve görevler).
class GoalCard extends StatelessWidget {
  const GoalCard({super.key, required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context) {
    final g = goal;
    final textTheme = Theme.of(context).textTheme;
    final running = g.isRunning(DateTime.now());
    return InkWell(
      borderRadius: GwRadius.lgAll,
      onTap: () => context.push(EventRoutes.goal(g.id)),
      child: Container(
        padding: const EdgeInsets.all(GwSpacing.sm),
        decoration: const BoxDecoration(
          color: GwColors.background,
          borderRadius: GwRadius.lgAll,
          border: Border.fromBorderSide(GwBorders.hairline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(g.title, style: textTheme.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis)),
                if (g.completed)
                  GwBadge(eventsL10n.completed, tone: GwBadgeTone.success, dot: true)
                else if (g.canceledAt != null)
                  GwBadge(eventsL10n.canceled, tone: GwBadgeTone.danger)
                else if (!running)
                  GwBadge(eventsL10n.ended),
              ],
            ),
            const SizedBox(height: GwSpacing.xxs),
            Text(
              [g.kind.label, if (g.myTeam != null) eventsL10n.teamName(g.myTeam!), goalPeriod(g)].join(' · '),
              style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary),
            ),
            const SizedBox(height: GwSpacing.xs),
            if (g.metric != null) ...[
              ClipRRect(
                borderRadius: GwRadius.smAll,
                child: LinearProgressIndicator(value: g.share, minHeight: GwSpacing.xs, backgroundColor: GwColors.surfaceMuted),
              ),
              const SizedBox(height: GwSpacing.xxs),
            ],
            Text(
              g.kind == GoalKind.team && g.myTeam == null ? eventsL10n.teamNotice : g.progressLabel,
              style: textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// The group's goals on its page; events.manage holders open new ones.
class GroupGoalsSection extends ConsumerWidget {
  const GroupGoalsSection({super.key, required this.groupId, required this.canManage});

  final String groupId;
  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(groupGoalsProvider(groupId)).value;
    if (goals == null || (goals.isEmpty && !canManage)) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GwSpacing.page, vertical: GwSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(eventsL10n.goals, style: textTheme.titleLarge)),
              if (canManage)
                TextButton.icon(
                  onPressed: () => showGoalEditor(context, groupId: groupId),
                  icon: const Icon(Icons.flag_circle_outlined, size: GwSpacing.md + GwSpacing.xxs),
                  label: Text(eventsL10n.createGoal),
                ),
            ],
          ),
          if (goals.isEmpty)
            Text(eventsL10n.goalsEmpty,
                style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary))
          else
            for (final g in goals) ...[GoalCard(goal: g), const SizedBox(height: GwSpacing.xs)],
        ],
      ),
    );
  }
}

/// One goal: progress, teams, the task's "Yaptım", pending claims for managers and who completed it.
class GoalScreen extends ConsumerStatefulWidget {
  const GoalScreen({super.key, required this.goalId});

  final String goalId;

  @override
  ConsumerState<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends ConsumerState<GoalScreen> {
  bool _busy = false;

  Future<void> _run(Future<Result<void>> Function(GoalsRepository r) action, String done, {String? groupId}) async {
    setState(() => _busy = true);
    final result = await action(ref.read(goalsRepositoryProvider));
    if (!mounted) return;
    setState(() => _busy = false);
    _snack(context, switch (result) {
      Ok() => done,
      Err(:final failure) => failure.userMessage,
    });
    ref.invalidate(goalDetailProvider(widget.goalId));
    if (groupId != null) ref.invalidate(groupGoalsProvider(groupId));
  }

  Future<void> _claim(Goal g) async {
    final note = await showDialog<String>(context: context, builder: (_) => const _ClaimDialog());
    if (note == null) return;
    await _run((r) => r.claim(g.id, note: note), eventsL10n.claimSent, groupId: g.group.id);
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(goalDetailProvider(widget.goalId));
    return Scaffold(
      appBar: AppBar(title: Text(detail.value?.goal.group.name ?? eventsL10n.goal)),
      body: GwReadingColumn(
        child: switch (detail) {
          AsyncData(:final value) => _content(value),
          AsyncError(:final error) => GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(goalDetailProvider(widget.goalId))),
          _ => const Padding(padding: EdgeInsets.all(GwSpacing.page), child: GwSkeleton(height: GwSpacing.xxl * 4, borderRadius: GwRadius.lgAll)),
        },
      ),
    );
  }

  Widget _content(GoalDetail d) {
    final g = d.goal;
    final textTheme = Theme.of(context).textTheme;
    final secondary = textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary);
    final running = g.isRunning(DateTime.now());
    Widget person(EventPerson p, {Widget? trailing, String? subtitle}) => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: GwAvatar(name: p.displayName, imageUrl: p.avatarUrl, shape: GwAvatarShape.user, size: GwAvatarSize.sm),
          title: Text(p.displayName),
          subtitle: subtitle == null || subtitle.isEmpty ? null : Text(subtitle),
          trailing: trailing,
        );
    return RefreshIndicator(
      onRefresh: () => ref.refresh(goalDetailProvider(widget.goalId).future),
      child: ListView(
        padding: const EdgeInsets.all(GwSpacing.page),
        children: [
          GoalCard(goal: g),
          if (g.description.isNotEmpty) ...[const SizedBox(height: GwSpacing.sm), Text(g.description, style: textTheme.bodyLarge)],
          const SizedBox(height: GwSpacing.xs),
          Text(g.kind.description, style: secondary),
          if (g.metric != null)
            Text(eventsL10n.goalCountsRule, style: secondary),
          if (g.kind == GoalKind.task && running && !g.completed) ...[
            const SizedBox(height: GwSpacing.md),
            if (g.myClaim == ClaimStatus.pending)
              GwButton(
                label: eventsL10n.withdrawClaim,
                variant: GwButtonVariant.secondary,
                expand: true,
                isLoading: _busy,
                onPressed: () => _run((r) => r.withdrawClaim(g.id), eventsL10n.claimWithdrawn, groupId: g.group.id),
              )
            else
              GwButton(label: eventsL10n.done, icon: Icons.task_alt, expand: true, isLoading: _busy, onPressed: () => _claim(g)),
          ],
          if (g.kind == GoalKind.team) ...[
            const SizedBox(height: GwSpacing.lg),
            Row(
              children: [
                Expanded(child: Text(eventsL10n.teams, style: textTheme.titleMedium)),
                if (g.canManage && running && (d.candidates?.isNotEmpty ?? false))
                  TextButton.icon(
                    onPressed: () => _newTeam(g, d.candidates!),
                    icon: const Icon(Icons.group_add_outlined, size: GwSpacing.md + GwSpacing.xxs),
                    label: Text(eventsL10n.createTeam),
                  ),
              ],
            ),
            if (d.teams.isEmpty) Text(eventsL10n.noTeams, style: secondary),
            for (final t in d.teams)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(t.name, style: textTheme.labelLarge),
                subtitle: Text('${formatCount(t.progress)} / ${formatCount(g.target)} ${g.metric?.unitFor(g.target) ?? ''} · '
                    '${formatList(t.members.map((m) => m.displayName))}'),
                trailing: g.canManage && running
                    ? IconButton(
                        tooltip: eventsL10n.deleteTeam(t.name),
                        icon: const Icon(Icons.delete_outline),
                        onPressed: _busy ? null : () => _run((r) => r.deleteTeam(g.id, t.id), eventsL10n.teamDeleted),
                      )
                    : null,
              ),
          ],
          if (d.claims case final claims? when claims.isNotEmpty) ...[
            const SizedBox(height: GwSpacing.lg),
            Text(eventsL10n.pendingClaims(claims.length), style: textTheme.titleMedium),
            for (final c in claims)
              person(
                c.person,
                subtitle: c.note,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: _busy ? null : () => _run((r) => r.decideClaim(g.id, c.person.id, approve: false), eventsL10n.claimRejectedToast),
                      child: Text(eventsL10n.decline),
                    ),
                    GwButton(
                      label: eventsL10n.approve,
                      onPressed: _busy
                          ? null
                          : () => _run((r) => r.decideClaim(g.id, c.person.id, approve: true), eventsL10n.taskDone(c.person.displayName)),
                    ),
                  ],
                ),
              ),
          ],
          const SizedBox(height: GwSpacing.lg),
          Text(eventsL10n.completions(g.completions), style: textTheme.titleMedium),
          if (d.completers.isEmpty)
            Text(eventsL10n.noCompletions, style: secondary)
          else
            for (final p in d.completers) person(p),
          if (g.canManage && g.canceledAt == null && running) ...[
            const SizedBox(height: GwSpacing.lg),
            TextButton(
              onPressed: _busy ? null : () => _run((r) => r.cancel(g.id), eventsL10n.goalCanceled, groupId: g.group.id),
              child: Text(eventsL10n.cancelGoal, style: const TextStyle(color: GwColors.error)),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _newTeam(Goal g, List<EventPerson> candidates) async {
    final created = await showModalBottomSheet<(String, List<String>)>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _TeamSheet(candidates: candidates),
    );
    if (created == null) return;
    await _run((r) => r.createTeam(g.id, created.$1, created.$2), eventsL10n.teamCreated(created.$1));
  }
}

class _TeamSheet extends StatefulWidget {
  const _TeamSheet({required this.candidates});

  final List<EventPerson> candidates;

  @override
  State<_TeamSheet> createState() => _TeamSheetState();
}

class _TeamSheetState extends State<_TeamSheet> {
  final _name = TextEditingController();
  final _picked = <String>{};

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ready = _name.text.trim().length >= 2 && _picked.isNotEmpty;
    return Padding(
      padding: EdgeInsets.fromLTRB(GwSpacing.page, 0, GwSpacing.page, GwSpacing.lg + MediaQuery.viewInsetsOf(context).bottom),
      child: ListView(
        shrinkWrap: true,
        children: [
          Text(eventsL10n.createTeam, style: Theme.of(context).textTheme.titleLarge),
          TextField(
            controller: _name,
            maxLength: 40,
            decoration: InputDecoration(labelText: eventsL10n.teamNameLabel),
            onChanged: (_) => setState(() {}),
          ),
          for (final p in widget.candidates)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _picked.contains(p.id),
              onChanged: (v) => setState(() => v == true ? _picked.add(p.id) : _picked.remove(p.id)),
              title: Text(p.displayName),
              subtitle: Text(atName(p.username)),
            ),
          const SizedBox(height: GwSpacing.sm),
          GwButton(
            label: _picked.isEmpty ? eventsL10n.createTheTeam : eventsL10n.createTeamWith(_picked.length),
            expand: true,
            onPressed: ready ? () => Navigator.of(context).pop((_name.text.trim(), _picked.toList())) : null,
          ),
        ],
      ),
    );
  }
}

/// The new goal form (docs/ARCHITECTURE.md §3d, Hedefler ve görevler).
Future<void> showGoalEditor(BuildContext context, {required String groupId}) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _GoalEditor(groupId: groupId),
    );

class _GoalEditor extends ConsumerStatefulWidget {
  const _GoalEditor({required this.groupId});

  final String groupId;

  @override
  ConsumerState<_GoalEditor> createState() => _GoalEditorState();
}

class _GoalEditorState extends ConsumerState<_GoalEditor> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _target = TextEditingController(text: '4');
  GoalKind _kind = GoalKind.personal;
  GoalMetric _metric = GoalMetric.attended;
  late final DateTime _startsAt = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  late DateTime _endsAt = _startsAt.add(const Duration(days: 30));
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _target.dispose();
    super.dispose();
  }

  Future<void> _pickEnd() async {
    final day = await showDatePicker(
      context: context,
      initialDate: _endsAt,
      firstDate: _startsAt.add(const Duration(days: 1)),
      lastDate: _startsAt.add(const Duration(days: 92)),
    );
    if (day != null) setState(() => _endsAt = day);
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ref.read(goalsRepositoryProvider).create(
          widget.groupId,
          GoalForm(
            title: _title.text,
            description: _description.text,
            kind: _kind,
            metric: _metric,
            target: int.tryParse(_target.text.trim()),
            startsAt: _startsAt,
            endsAt: _endsAt,
          ),
        );
    if (!mounted) return;
    switch (result) {
      case Ok():
        ref.invalidate(groupGoalsProvider(widget.groupId));
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop();
        messenger.showSnackBar(SnackBar(content: Text(eventsL10n.goalCreated)));
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
    final measured = _kind != GoalKind.task;
    return Padding(
      padding: EdgeInsets.fromLTRB(GwSpacing.page, 0, GwSpacing.page, GwSpacing.lg + MediaQuery.viewInsetsOf(context).bottom),
      child: Form(
        key: _form,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(eventsL10n.createGoal, style: textTheme.titleLarge),
            const SizedBox(height: GwSpacing.sm),
            Wrap(
              spacing: GwSpacing.xs,
              runSpacing: GwSpacing.xs,
              children: [
                for (final k in GoalKind.values) ChoiceChip(label: Text(k.label), selected: _kind == k, onSelected: (_) => setState(() => _kind = k)),
              ],
            ),
            const SizedBox(height: GwSpacing.xxs),
            Text(_kind.description, style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
            const SizedBox(height: GwSpacing.sm),
            TextFormField(
              controller: _title,
              maxLength: 80,
              decoration: InputDecoration(labelText: eventsL10n.title, hintText: measured ? eventsL10n.goalTitleExample : eventsL10n.taskTitleExample),
              validator: (v) => (v ?? '').trim().length < 3 ? eventsL10n.titleMin3 : null,
            ),
            TextFormField(
              controller: _description,
              maxLength: 500,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(labelText: eventsL10n.descriptionOptional),
            ),
            if (measured)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _target,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: eventsL10n.targetNumber),
                      validator: (v) {
                        final n = int.tryParse((v ?? '').trim());
                        return n != null && n >= 1 && n <= 1000 ? null : eventsL10n.target1to1000;
                      },
                    ),
                  ),
                  const SizedBox(width: GwSpacing.sm),
                  DropdownButton<GoalMetric>(
                    value: _metric,
                    items: [for (final m in GoalMetric.values) DropdownMenuItem(value: m, child: Text(m.unitFor(2)))],
                    onChanged: (m) => setState(() => _metric = m ?? _metric),
                  ),
                ],
              ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.date_range_outlined),
              title: Text(eventsL10n.period),
              subtitle: Text(eventsL10n.periodRange(formatDate(_startsAt), formatDate(_endsAt))),
              trailing: const Icon(Icons.edit_calendar_outlined),
              onTap: _pickEnd,
            ),
            if (_error != null) ...[const SizedBox(height: GwSpacing.sm), GwFormMessage(_error!)],
            const SizedBox(height: GwSpacing.md),
            GwButton(label: eventsL10n.createTheGoal, icon: Icons.flag_circle_outlined, isLoading: _busy, expand: true, onPressed: _submit),
          ],
        ),
      ),
    );
  }
}

/// "Görevi yaptım" with an optional note; owns its controller so closing never touches a disposed one.
class _ClaimDialog extends StatefulWidget {
  const _ClaimDialog();

  @override
  State<_ClaimDialog> createState() => _ClaimDialogState();
}

class _ClaimDialogState extends State<_ClaimDialog> {
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(eventsL10n.iDidTask),
        content: TextField(
          controller: _note,
          maxLength: 300,
          maxLines: 3,
          minLines: 1,
          decoration: InputDecoration(labelText: eventsL10n.whatDidYouDo, helperText: eventsL10n.whatDidYouDoHint),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(eventsL10n.cancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(_note.text), child: Text(eventsL10n.send)),
        ],
      );
}
