import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/social.dart';
import '../domain/teammates.dart';
import '../l10n.dart';
import 'providers.dart';
import 'routes.dart';
import 'social_providers.dart';
import 'social_widgets.dart';
import 'teammate_providers.dart';

void _snack(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

/// Runs a teammate action, reports the outcome and reloads the lists.
Future<void> runTeammateAction(
  BuildContext context,
  WidgetRef ref,
  Future<Result<Object?>> Function(TeammatesRepository r) action,
  String done,
) async {
  final result = await action(ref.read(teammatesRepositoryProvider));
  if (!context.mounted) return;
  _snack(context, switch (result) {
    Ok() => done,
    Err(:final failure) => failure.userMessage,
  });
  refreshTeammates(ref);
}

/// Asks for an optional short message and sends the request.
Future<void> sendTeammateRequest(BuildContext context, WidgetRef ref, PersonSummary person) async {
  final message = await showDialog<String>(context: context, builder: (_) => _RequestDialog(name: person.displayName));
  if (message == null || !context.mounted) return;
  final result = await ref.read(teammatesRepositoryProvider).request(person.id, message: message);
  if (!context.mounted) return;
  if (result case Err(failure: RuleFailure(code: 'profile.teammate_package_required') && final failure)) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(failure.userMessage),
      action: SnackBarAction(label: profileL10n.seePackage, onPressed: () => ref.read(packageOpenerProvider)(context, 'matching_teammates')),
    ));
    return;
  }
  _snack(context, switch (result) {
    Ok(value: TeammateRelation.teammates) => profileL10n.nowTeammates(person.displayName),
    Ok() => profileL10n.requestSentNotify(person.displayName),
    Err(:final failure) => failure.userMessage,
  });
  refreshTeammates(ref);
}

class _RequestDialog extends StatefulWidget {
  const _RequestDialog({required this.name});

  final String name;

  @override
  State<_RequestDialog> createState() => _RequestDialogState();
}

class _RequestDialogState extends State<_RequestDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: GwRadius.xlAll),
        title: Text(profileL10n.becomeTeammatesWith(widget.name)),
        content: TextField(
          controller: _controller,
          maxLength: 200,
          maxLines: 3,
          minLines: 2,
          decoration: InputDecoration(labelText: profileL10n.shortMessage, hintText: profileL10n.shortMessageHint),
        ),
        actions: [
          GwButton(label: profileL10n.cancel, variant: GwButtonVariant.text, onPressed: () => Navigator.of(context).pop()),
          GwButton(label: profileL10n.sendRequest, onPressed: () => Navigator.of(context).pop(_controller.text)),
        ],
      );
}

/// Öneriler / İstekler / Ekip arkadaşlarım.
class TeammatesScreen extends ConsumerWidget {
  const TeammatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mine = ref.watch(myTeammatesProvider).value;
    if (mine?.locked ?? false) return _Locked(waiting: mine!.waiting);
    final incoming = mine?.incoming.length ?? 0;
    // Rebuilt once the requests arrive, so pending requests open first.
    return DefaultTabController(
      key: ValueKey(incoming > 0),
      length: 3,
      initialIndex: incoming > 0 ? 1 : 0,
      child: Scaffold(
        appBar: AppBar(
          title: Text(profileL10n.findTeammates),
          actions: [
            IconButton(
              tooltip: profileL10n.myTeammatePrefs,
              icon: const Icon(Icons.tune),
              onPressed: () => context.push(ProfileRoutes.teammateSettings),
            ),
          ],
          bottom: TabBar(tabs: [
            Tab(text: profileL10n.tabSuggestions),
            Tab(text: incoming == 0 ? profileL10n.tabRequests : profileL10n.tabRequestsCount(incoming)),
            Tab(text: profileL10n.tabMyTeam),
          ]),
        ),
        body: const GwReadingColumn(child: TabBarView(children: [_Suggestions(), _Requests(), _Teammates()])),
      ),
    );
  }
}

/// The section without the Ekip Arkadaşı package: what it opens and how many requests wait.
class _Locked extends ConsumerWidget {
  const _Locked({required this.waiting});

  final int waiting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(profileL10n.findTeammates)),
      body: GwReadingColumn(
        maxWidth: GwLayout.formMaxWidth,
        child: ListView(
          padding: const EdgeInsets.all(GwSpacing.page),
          children: [
            GwCard(
              padding: const EdgeInsets.all(GwSpacing.lg),
              child: Column(
                children: [
                  const Icon(Icons.groups_2_outlined, size: GwSpacing.xxl, color: GwColors.primary),
                  const SizedBox(height: GwSpacing.sm),
                  Text(
                    waiting == 0 ? profileL10n.findYourTeammate : profileL10n.waitingForYou(waiting),
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall,
                  ),
                  const SizedBox(height: GwSpacing.xs),
                  Text(
                    profileL10n.teammatesLocked,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary),
                  ),
                  const SizedBox(height: GwSpacing.md),
                  GwButton(
                    label: profileL10n.seePackage,
                    icon: Icons.workspace_premium_outlined,
                    onPressed: () => ref.read(packageOpenerProvider)(context, 'matching_teammates'),
                  ),
                  const SizedBox(height: GwSpacing.xs),
                  GwButton(
                    label: profileL10n.myTeammatePrefs,
                    variant: GwButtonVariant.text,
                    onPressed: () => context.push(ProfileRoutes.teammateSettings),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Invites the user to turn "Ekip arıyorum" on, so others can find and ask them.
class _LookingPrompt extends ConsumerWidget {
  const _LookingPrompt();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(teammatePreferencesProvider).value;
    if (prefs == null || prefs.looking) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(GwSpacing.md, 0, GwSpacing.md, GwSpacing.md),
      padding: const EdgeInsets.all(GwSpacing.md),
      decoration: const BoxDecoration(color: GwColors.primarySoft, borderRadius: GwRadius.lgAll),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(profileL10n.beVisible, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: GwSpacing.xxs),
          Text(profileL10n.beVisibleBody),
          const SizedBox(height: GwSpacing.sm),
          GwButton(
            label: profileL10n.setPrefs,
            variant: GwButtonVariant.secondary,
            onPressed: () => context.push(ProfileRoutes.teammateSettings),
          ),
        ],
      ),
    );
  }
}

/// Private accounts never show in suggestions (docs/ARCHITECTURE.md §3c), so "Ekip arıyorum" alone is not enough.
class _PrivateAccountNotice extends ConsumerStatefulWidget {
  const _PrivateAccountNotice({required this.looking, this.margin = EdgeInsets.zero});

  final bool looking;
  final EdgeInsetsGeometry margin;

  @override
  ConsumerState<_PrivateAccountNotice> createState() => _PrivateAccountNoticeState();
}

class _PrivateAccountNoticeState extends ConsumerState<_PrivateAccountNotice> {
  bool _busy = false;

  Future<void> _makePublic() async {
    setState(() => _busy = true);
    final result = await ref.read(socialRepositoryProvider).setPrivate(false);
    if (!mounted) return;
    setState(() => _busy = false);
    ref.invalidate(myProfileProvider);
    final me = ref.read(currentUserIdProvider);
    if (me != null) refreshRelationship(ref, me);
    refreshTeammates(ref);
    _snack(context, switch (result) {
      Ok() => profileL10n.nowPublicSuggest,
      Err(:final failure) => failure.userMessage,
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPrivate = ref.watch(myProfileProvider).value?.isPrivate ?? false;
    if (!widget.looking || !isPrivate) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: widget.margin,
      padding: const EdgeInsets.all(GwSpacing.md),
      decoration: BoxDecoration(
        color: GwColors.warningSoft,
        borderRadius: GwRadius.lgAll,
        border: Border.all(color: GwColors.warning),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lock_outline_rounded, color: GwColors.warning),
              const SizedBox(width: GwSpacing.xs),
              Expanded(child: Text(profileL10n.privateHidden, style: textTheme.titleSmall)),
            ],
          ),
          const SizedBox(height: GwSpacing.xxs),
          Text(
            profileL10n.privateHiddenBody,
            style: textTheme.bodySmall?.copyWith(color: GwColors.textPrimary),
          ),
          const SizedBox(height: GwSpacing.sm),
          GwButton(
            label: profileL10n.makePublic,
            icon: Icons.lock_open_rounded,
            variant: GwButtonVariant.secondary,
            isLoading: _busy,
            onPressed: _busy ? null : _makePublic,
          ),
        ],
      ),
    );
  }
}

/// The notice on the suggestions tab, from the saved preferences.
class _OwnPrivateNotice extends ConsumerWidget {
  const _OwnPrivateNotice();

  @override
  Widget build(BuildContext context, WidgetRef ref) => _PrivateAccountNotice(
        looking: ref.watch(teammatePreferencesProvider).value?.looking ?? false,
        margin: const EdgeInsets.fromLTRB(GwSpacing.md, 0, GwSpacing.md, GwSpacing.md),
      );
}

class _Suggestions extends ConsumerWidget {
  const _Suggestions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = ref.watch(teammateSuggestionsProvider);
    return RefreshIndicator(
      onRefresh: () async => refreshTeammates(ref),
      child: switch (suggestions) {
        AsyncData(:final value) when value.isEmpty => ListView(children: [
            const _LookingPrompt(),
              const _OwnPrivateNotice(),
            const SizedBox(height: GwSpacing.lg),
            GwEmptyState(
              icon: Icons.diversity_3_outlined,
              message: profileL10n.noSuggestions,
              actionLabel: profileL10n.setPrefs,
              onAction: () => context.push(ProfileRoutes.teammateSettings),
            ),
          ]),
        AsyncData(:final value) => ListView(
            padding: const EdgeInsets.only(top: GwSpacing.md),
            children: [
              const _LookingPrompt(),
              const _OwnPrivateNotice(),
              for (final s in value) _SuggestionCard(suggestion: s),
            ],
          ),
        AsyncError(:final error) => GwErrorState(message: userMessageOf(error), onRetry: () => refreshTeammates(ref)),
        _ => const ListSkeleton(),
      },
    );
  }
}

class _SuggestionCard extends ConsumerWidget {
  const _SuggestionCard({required this.suggestion});

  final TeammateSuggestion suggestion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final s = suggestion;
    return Container(
      margin: const EdgeInsets.fromLTRB(GwSpacing.md, 0, GwSpacing.md, GwSpacing.sm),
      decoration: const BoxDecoration(
        borderRadius: GwRadius.lgAll,
        border: Border.fromBorderSide(BorderSide(color: GwColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PersonRow(
            person: s.person,
            subtitle: s.level == null ? s.person.displayName : '${s.person.displayName} · ${s.level!.label} seviye',
            trailing: GwButton(label: profileL10n.sendRequest, onPressed: () => sendTeammateRequest(context, ref, s.person)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(GwSpacing.md, 0, GwSpacing.md, GwSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (s.note.isNotEmpty) ...[
                  Text(profileL10n.quoted(s.note), style: textTheme.bodyMedium),
                  const SizedBox(height: GwSpacing.xs),
                ],
                Text(profileL10n.whySuggested, style: textTheme.labelMedium?.copyWith(color: GwColors.textSecondary)),
                const SizedBox(height: GwSpacing.xxs),
                for (final reason in s.reasons)
                  Padding(
                    padding: const EdgeInsets.only(bottom: GwSpacing.xxs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline, size: GwSpacing.md, color: GwColors.primary),
                        const SizedBox(width: GwSpacing.xs),
                        Expanded(child: Text(reason, style: textTheme.bodyMedium)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Requests extends ConsumerWidget {
  const _Requests();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mine = ref.watch(myTeammatesProvider);
    final textTheme = Theme.of(context).textTheme;
    Widget heading(String text) => Padding(
          padding: const EdgeInsets.fromLTRB(GwSpacing.md, GwSpacing.md, GwSpacing.md, GwSpacing.xs),
          child: Text(text, style: textTheme.titleSmall),
        );
    return RefreshIndicator(
      onRefresh: () async => refreshTeammates(ref),
      child: switch (mine) {
        AsyncData(:final value) when value.incoming.isEmpty && value.outgoing.isEmpty => ListView(children: [
            const SizedBox(height: GwSpacing.xxl),
            GwEmptyState(
              icon: Icons.mark_email_unread_outlined,
              message: profileL10n.noPendingTeammate,
              actionLabel: profileL10n.seeSuggestions,
              onAction: () => DefaultTabController.of(context).animateTo(0),
            ),
          ]),
        AsyncData(:final value) => ListView(
            children: [
              if (value.incoming.isNotEmpty) heading(profileL10n.incoming),
              for (final r in value.incoming) ...[
                PersonRow(
                  person: r.person,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GwButton(
                        label: profileL10n.accept,
                        onPressed: () => runTeammateAction(
                            context, ref, (t) => t.accept(r.person.id), profileL10n.nowTeammates(r.person.displayName)),
                      ),
                      IconButton(
                        tooltip: profileL10n.decline,
                        icon: const Icon(Icons.close),
                        onPressed: () => runTeammateAction(context, ref, (t) => t.decline(r.person.id), profileL10n.requestDeclined),
                      ),
                    ],
                  ),
                ),
                if (r.message.isNotEmpty)
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                        GwSpacing.md + GwAvatarSize.md.dimension + GwSpacing.sm, 0, GwSpacing.md, GwSpacing.sm),
                    child: Text(profileL10n.quoted(r.message), style: textTheme.bodyMedium),
                  ),
              ],
              if (value.outgoing.isNotEmpty) heading(profileL10n.outgoing),
              for (final r in value.outgoing)
                PersonRow(
                  person: r.person,
                  subtitle: profileL10n.awaitingReply,
                  trailing: GwButton(
                    label: profileL10n.withdraw,
                    variant: GwButtonVariant.secondary,
                    onPressed: () => runTeammateAction(context, ref, (t) => t.remove(r.person.id), profileL10n.requestWithdrawn),
                  ),
                ),
            ],
          ),
        AsyncError(:final error) => GwErrorState(message: userMessageOf(error), onRetry: () => refreshTeammates(ref)),
        _ => const ListSkeleton(),
      },
    );
  }
}

class _Teammates extends ConsumerWidget {
  const _Teammates();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mine = ref.watch(myTeammatesProvider);
    return RefreshIndicator(
      onRefresh: () async => refreshTeammates(ref),
      child: switch (mine) {
        AsyncData(:final value) when value.teammates.isEmpty => ListView(children: [
            const SizedBox(height: GwSpacing.xxl),
            GwEmptyState(
              icon: Icons.groups_2_outlined,
              message: profileL10n.noTeammates,
              actionLabel: profileL10n.seeSuggestions,
              onAction: () => DefaultTabController.of(context).animateTo(0),
            ),
          ]),
        AsyncData(:final value) => ListView(
            children: [
              for (final p in value.teammates)
                PersonRow(
                  person: p,
                  trailing: PopupMenuButton<void>(
                    tooltip: profileL10n.optionsFor(p.displayName),
                    icon: const Icon(Icons.more_horiz),
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        onTap: () => runTeammateAction(context, ref, (t) => t.remove(p.id), profileL10n.teammateEnded),
                        child: Text(profileL10n.endTeammate),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        AsyncError(:final error) => GwErrorState(message: userMessageOf(error), onRetry: () => refreshTeammates(ref)),
        _ => const ListSkeleton(),
      },
    );
  }
}

/// "Ekip arıyorum", level, free times, province (matching only) and a short note.
class TeammateSettingsScreen extends ConsumerWidget {
  const TeammateSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(teammatePreferencesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(profileL10n.teammatePrefs)),
      body: GwReadingColumn(
        child: switch (prefs) {
          AsyncData(:final value) => _SettingsForm(initial: value),
          AsyncError(:final error) =>
            GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(teammatePreferencesProvider)),
          _ => const ListSkeleton(),
        },
      ),
    );
  }
}

class _SettingsForm extends ConsumerStatefulWidget {
  const _SettingsForm({required this.initial});

  final TeammatePreferences initial;

  @override
  ConsumerState<_SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends ConsumerState<_SettingsForm> {
  late bool _looking = widget.initial.looking;
  late TeammateLevel? _level = widget.initial.level;
  late final Set<TeammateSlot> _slots = {...widget.initial.availability};
  late int? _province = widget.initial.province;
  late final _note = TextEditingController(text: widget.initial.note)..addListener(() => setState(() {}));
  late final Set<String> _activities = {...widget.initial.activities};
  late final Set<TeammateGoal> _goals = {...widget.initial.goals};
  late TeammateFrequency? _frequency = widget.initial.frequency;
  late final Set<TeammateGroupSize> _sizes = {...widget.initial.groupSizes};
  late bool _vehicle = widget.initial.hasVehicle;
  late bool _equipment = widget.initial.hasEquipment;
  bool _saving = false;

  TeammatePreferences get _draft => TeammatePreferences(
        looking: _looking,
        level: _level,
        availability: _slots,
        province: _province,
        note: _note.text,
        activities: _activities,
        goals: _goals,
        frequency: _frequency,
        groupSizes: _sizes,
        hasVehicle: _vehicle,
        hasEquipment: _equipment,
      );

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final result = await ref.read(teammatesRepositoryProvider).savePreferences(_draft);
    if (!mounted) return;
    setState(() => _saving = false);
    switch (result) {
      case Ok():
        refreshTeammates(ref);
        _snack(context, _looking && !_isPrivate ? profileL10n.prefsSavedVisible : profileL10n.prefsSaved);
        await Navigator.of(context).maybePop();
      case Err(:final failure):
        _snack(context, failure.userMessage);
    }
  }

  bool get _isPrivate => ref.read(myProfileProvider).value?.isPrivate ?? false;

  void _toggle<T>(Set<T> set, T value, bool on) => setState(() => on ? set.add(value) : set.remove(value));

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final categories = ref.watch(categoriesProvider).value ?? const <Category>[];
    final answered = _draft.answered;
    ref.watch(myProfileProvider);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(GwSpacing.page),
            children: [
              _VisibilityCard(looking: _looking, onChanged: (v) => setState(() => _looking = v)),
              _PrivateAccountNotice(looking: _looking, margin: const EdgeInsets.only(top: GwSpacing.sm)),
              const SizedBox(height: GwSpacing.md),
              _Completeness(answered: answered),
              _Section(
                icon: Icons.sports_handball_outlined,
                title: profileL10n.whatToDo,
                help: profileL10n.activitiesHint(TeammatePreferences.maxActivities),
                trailing: '${_activities.length}/${TeammatePreferences.maxActivities}',
                child: Wrap(
                  spacing: GwSpacing.xs,
                  runSpacing: GwSpacing.xs,
                  children: [
                    for (final c in categories)
                      FilterChip(
                        avatar: Icon(categoryIcon(c.slug), size: GwSpacing.md + GwSpacing.xxs),
                        label: Text(c.name),
                        selected: _activities.contains(c.slug),
                        onSelected: _activities.contains(c.slug) || _activities.length < TeammatePreferences.maxActivities
                            ? (on) => _toggle(_activities, c.slug, on)
                            : null,
                      ),
                  ],
                ),
              ),
              _Section(
                icon: Icons.trending_up_rounded,
                title: profileL10n.yourLevel,
                child: Row(
                  children: [
                    for (final (i, l) in TeammateLevel.values.indexed) ...[
                      if (i > 0) const SizedBox(width: GwSpacing.xs),
                      Expanded(
                        child: _OptionTile(
                          title: l.label,
                          subtitle: l.hint,
                          selected: _level == l,
                          onTap: () => setState(() => _level = _level == l ? null : l),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _Section(
                icon: Icons.flag_outlined,
                title: profileL10n.yourGoals,
                help: profileL10n.multipleChoice,
                child: Wrap(
                  spacing: GwSpacing.xs,
                  runSpacing: GwSpacing.xs,
                  children: [
                    for (final g in TeammateGoal.values)
                      FilterChip(label: Text(g.label), selected: _goals.contains(g), onSelected: (on) => _toggle(_goals, g, on)),
                  ],
                ),
              ),
              _Section(
                icon: Icons.repeat_rounded,
                title: profileL10n.howOften,
                child: Wrap(
                  spacing: GwSpacing.xs,
                  runSpacing: GwSpacing.xs,
                  children: [
                    for (final f in TeammateFrequency.values)
                      ChoiceChip(
                        label: Text(f.label),
                        selected: _frequency == f,
                        onSelected: (on) => setState(() => _frequency = on ? f : null),
                      ),
                  ],
                ),
              ),
              _Section(
                icon: Icons.event_available_outlined,
                title: profileL10n.whenFree,
                help: profileL10n.whenFreeHint,
                child: _AvailabilityGrid(selected: _slots, onToggle: (s) => _toggle(_slots, s, !_slots.contains(s))),
              ),
              _Section(
                icon: Icons.groups_2_outlined,
                title: profileL10n.whatTeam,
                child: Wrap(
                  spacing: GwSpacing.xs,
                  runSpacing: GwSpacing.xs,
                  children: [
                    for (final s in TeammateGroupSize.values)
                      FilterChip(label: Text(s.label), selected: _sizes.contains(s), onSelected: (on) => _toggle(_sizes, s, on)),
                  ],
                ),
              ),
              _Section(
                icon: Icons.location_on_outlined,
                title: profileL10n.whichProvince,
                help: profileL10n.provinceHint,
                child: DropdownButtonFormField<int?>(
                  initialValue: _province,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: profileL10n.province, prefixIcon: const Icon(Icons.lock_outline_rounded)),
                  items: [
                    DropdownMenuItem<int?>(child: Text(profileL10n.ratherNotSay)),
                    for (var i = 0; i < turkishProvinces.length; i++)
                      DropdownMenuItem<int?>(value: i + 1, child: Text(turkishProvinces[i])),
                  ],
                  onChanged: (v) => setState(() => _province = v),
                ),
              ),
              _Section(
                icon: Icons.backpack_outlined,
                title: profileL10n.extras,
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: const Icon(Icons.directions_car_outlined),
                      title: Text(profileL10n.iHaveVehicle),
                      subtitle: Text(profileL10n.iHaveVehicleHint),
                      value: _vehicle,
                      onChanged: (v) => setState(() => _vehicle = v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: const Icon(Icons.handyman_outlined),
                      title: Text(profileL10n.iHaveEquipment),
                      subtitle: Text(profileL10n.iHaveEquipmentHint),
                      value: _equipment,
                      onChanged: (v) => setState(() => _equipment = v),
                    ),
                  ],
                ),
              ),
              _Section(
                icon: Icons.edit_note_rounded,
                title: profileL10n.describeYourself,
                help: profileL10n.describeHint,
                child: TextField(
                  controller: _note,
                  maxLength: TeammatePreferences.noteMaxLength,
                  minLines: 2,
                  maxLines: 3,
                  decoration: InputDecoration(hintText: profileL10n.describeExample),
                ),
              ),
            ],
          ),
        ),
        DecoratedBox(
          decoration: const BoxDecoration(color: GwColors.background, border: Border(top: GwBorders.hairline)),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(GwSpacing.page, GwSpacing.sm, GwSpacing.page, GwSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _looking && !_isPrivate ? profileL10n.willAppear : profileL10n.notAppearing,
                      style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: GwSpacing.sm),
                  GwButton(label: profileL10n.save, icon: Icons.check_rounded, isLoading: _saving, onPressed: _saving ? null : _save),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// "Ekip arıyorum": whether the person shows in suggestions.
class _VisibilityCard extends StatelessWidget {
  const _VisibilityCard({required this.looking, required this.onChanged});

  final bool looking;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(GwSpacing.md),
      decoration: BoxDecoration(
        color: looking ? GwColors.primarySoft : GwColors.background,
        borderRadius: GwRadius.lgAll,
        border: Border.all(color: looking ? GwColors.primary : GwColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: GwSpacing.xxl,
            height: GwSpacing.xxl,
            decoration: BoxDecoration(color: looking ? GwColors.primary : GwColors.surfaceMuted, shape: BoxShape.circle),
            child: Icon(Icons.person_search_outlined, color: looking ? GwColors.onPrimary : GwColors.textSecondary),
          ),
          const SizedBox(width: GwSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profileL10n.lookingForTeam, style: textTheme.titleMedium),
                Text(
                  looking
                      ? profileL10n.lookingOn
                      : profileL10n.lookingOff,
                  style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary),
                ),
              ],
            ),
          ),
          Switch(value: looking, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// How much of the preferences is filled in.
class _Completeness extends StatelessWidget {
  const _Completeness({required this.answered});

  final int answered;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ratio = answered / TeammatePreferences.sections;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(profileL10n.prefsComplete((ratio * 100).round()), style: textTheme.labelLarge)),
            Text('$answered/${TeammatePreferences.sections}', style: textTheme.labelLarge?.copyWith(color: GwColors.textSecondary)),
          ],
        ),
        const SizedBox(height: GwSpacing.xs),
        ClipRRect(
          borderRadius: GwRadius.smAll,
          child: LinearProgressIndicator(value: ratio, minHeight: GwSpacing.xs, backgroundColor: GwColors.surfaceMuted),
        ),
        const SizedBox(height: GwSpacing.xxs),
        Text(
          profileL10n.prefsCompleteHint,
          style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary),
        ),
      ],
    );
  }
}

/// One titled card of the preferences.
class _Section extends StatelessWidget {
  const _Section({required this.icon, required this.title, required this.child, this.help, this.trailing});

  final IconData icon;
  final String title;
  final String? help;
  final String? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: GwSpacing.md),
      child: GwCard(
        padding: const EdgeInsets.all(GwSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: GwColors.primary, size: GwSpacing.lg - GwSpacing.xxs),
                const SizedBox(width: GwSpacing.xs),
                Expanded(child: Text(title, style: textTheme.titleSmall)),
                if (trailing != null) Text(trailing!, style: textTheme.labelMedium?.copyWith(color: GwColors.textSecondary)),
              ],
            ),
            if (help != null)
              Padding(
                padding: const EdgeInsets.only(top: GwSpacing.xxs),
                child: Text(help!, style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
              ),
            const SizedBox(height: GwSpacing.sm),
            child,
          ],
        ),
      ),
    );
  }
}

/// A selectable card with a title and a short description.
class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.title, required this.subtitle, required this.selected, required this.onTap});

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: GwRadius.mdAll,
        child: Container(
          constraints: const BoxConstraints(minHeight: GwSpacing.xxl + GwSpacing.md),
          padding: const EdgeInsets.all(GwSpacing.sm),
          decoration: BoxDecoration(
            color: selected ? GwColors.primarySoft : GwColors.surface,
            borderRadius: GwRadius.mdAll,
            border: Border.all(color: selected ? GwColors.primary : GwColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: textTheme.titleSmall?.copyWith(color: selected ? GwColors.primary : null)),
              Text(subtitle, style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Weekday and weekend by morning, noon and evening; a tap toggles a slot.
class _AvailabilityGrid extends StatelessWidget {
  const _AvailabilityGrid({required this.selected, required this.onToggle});

  final Set<TeammateSlot> selected;
  final ValueChanged<TeammateSlot> onToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final parts = [for (final s in TeammateSlot.values) if (!s.weekend) s.part];
    Widget row(String label, bool weekend) => Padding(
          padding: const EdgeInsets.only(top: GwSpacing.xs),
          child: Row(
            children: [
              SizedBox(width: GwSpacing.xxl + GwSpacing.lg, child: Text(label, style: textTheme.labelLarge)),
              for (final slot in TeammateSlot.values.where((s) => s.weekend == weekend))
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: GwSpacing.xs),
                    child: Semantics(
                      button: true,
                      selected: selected.contains(slot),
                      label: slot.label,
                      child: InkWell(
                        onTap: () => onToggle(slot),
                        borderRadius: GwRadius.mdAll,
                        child: Container(
                          height: GwSpacing.minTouchTarget,
                          decoration: BoxDecoration(
                            color: selected.contains(slot) ? GwColors.primary : GwColors.surface,
                            borderRadius: GwRadius.mdAll,
                            border: Border.all(color: selected.contains(slot) ? GwColors.primary : GwColors.border),
                          ),
                          child: Icon(
                            selected.contains(slot) ? Icons.check_rounded : Icons.add_rounded,
                            color: selected.contains(slot) ? GwColors.onPrimary : GwColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: GwSpacing.xxl + GwSpacing.lg),
            for (final p in parts)
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: GwSpacing.xs),
                  child: Text(p, textAlign: TextAlign.center, style: textTheme.labelMedium?.copyWith(color: GwColors.textSecondary)),
                ),
              ),
          ],
        ),
        row(profileL10n.weekday, false),
        row(profileL10n.weekend, true),
      ],
    );
  }
}
