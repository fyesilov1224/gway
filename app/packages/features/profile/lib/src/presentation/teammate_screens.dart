import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/social.dart';
import '../domain/teammates.dart';
import 'routes.dart';
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
      action: SnackBarAction(label: 'Paketi incele', onPressed: () => ref.read(packageOpenerProvider)(context, 'matching_teammates')),
    ));
    return;
  }
  _snack(context, switch (result) {
    Ok(value: TeammateRelation.teammates) => '${person.displayName} ile artık ekip arkadaşısınız.',
    Ok() => 'İstek gönderildi. ${person.displayName} kabul edince haber vereceğiz.',
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
        title: Text('${widget.name} ile ekip arkadaşı ol'),
        content: TextField(
          controller: _controller,
          maxLength: 200,
          maxLines: 3,
          minLines: 2,
          decoration: const InputDecoration(labelText: 'Kısa bir mesaj (isteğe bağlı)', hintText: 'Cumartesi sabahı Belgrad Ormanı?'),
        ),
        actions: [
          GwButton(label: 'Vazgeç', variant: GwButtonVariant.text, onPressed: () => Navigator.of(context).pop()),
          GwButton(label: 'İstek gönder', onPressed: () => Navigator.of(context).pop(_controller.text)),
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
          title: const Text('Ekip arkadaşı bul'),
          actions: [
            IconButton(
              tooltip: 'Ekip arkadaşı tercihlerim',
              icon: const Icon(Icons.tune),
              onPressed: () => context.push(ProfileRoutes.teammateSettings),
            ),
          ],
          bottom: TabBar(tabs: [
            const Tab(text: 'Öneriler'),
            Tab(text: incoming == 0 ? 'İstekler' : 'İstekler ($incoming)'),
            const Tab(text: 'Ekibim'),
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
      appBar: AppBar(title: const Text('Ekip arkadaşı bul')),
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
                    waiting == 0 ? 'Ekip arkadaşını bul' : '$waiting kişi seninle ekip arkadaşı olmak istiyor',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall,
                  ),
                  const SizedBox(height: GwSpacing.xs),
                  Text(
                    'Önerileri görmek, istek gönderip kabul etmek ve ekip arkadaşlarınla yazışmak Ekip Arkadaşı paketiyle açılır.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary),
                  ),
                  const SizedBox(height: GwSpacing.md),
                  GwButton(
                    label: 'Paketi incele',
                    icon: Icons.workspace_premium_outlined,
                    onPressed: () => ref.read(packageOpenerProvider)(context, 'matching_teammates'),
                  ),
                  const SizedBox(height: GwSpacing.xs),
                  GwButton(
                    label: 'Ekip arkadaşı tercihlerim',
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
          Text('Sen de görün', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: GwSpacing.xxs),
          const Text('"Ekip arıyorum"u açarsan seninle aynı şeyleri sevenler sana istek gönderebilir.'),
          const SizedBox(height: GwSpacing.sm),
          GwButton(
            label: 'Tercihlerimi ayarla',
            variant: GwButtonVariant.secondary,
            onPressed: () => context.push(ProfileRoutes.teammateSettings),
          ),
        ],
      ),
    );
  }
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
            const SizedBox(height: GwSpacing.lg),
            GwEmptyState(
              icon: Icons.diversity_3_outlined,
              message: 'Şimdilik sana uyan biri yok. İlgi alanlarını ve tercihlerini doldurursan öneriler artar.',
              actionLabel: 'Tercihlerimi ayarla',
              onAction: () => context.push(ProfileRoutes.teammateSettings),
            ),
          ]),
        AsyncData(:final value) => ListView(
            padding: const EdgeInsets.only(top: GwSpacing.md),
            children: [
              const _LookingPrompt(),
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
            trailing: GwButton(label: 'İstek gönder', onPressed: () => sendTeammateRequest(context, ref, s.person)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(GwSpacing.md, 0, GwSpacing.md, GwSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (s.note.isNotEmpty) ...[
                  Text('"${s.note}"', style: textTheme.bodyMedium),
                  const SizedBox(height: GwSpacing.xs),
                ],
                Text('Neden önerildi', style: textTheme.labelMedium?.copyWith(color: GwColors.textSecondary)),
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
              message: 'Bekleyen ekip arkadaşlığı isteği yok.',
              actionLabel: 'Önerilere bak',
              onAction: () => DefaultTabController.of(context).animateTo(0),
            ),
          ]),
        AsyncData(:final value) => ListView(
            children: [
              if (value.incoming.isNotEmpty) heading('Sana gelenler'),
              for (final r in value.incoming) ...[
                PersonRow(
                  person: r.person,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GwButton(
                        label: 'Kabul et',
                        onPressed: () => runTeammateAction(
                            context, ref, (t) => t.accept(r.person.id), '${r.person.displayName} ile artık ekip arkadaşısınız.'),
                      ),
                      IconButton(
                        tooltip: 'Reddet',
                        icon: const Icon(Icons.close),
                        onPressed: () => runTeammateAction(context, ref, (t) => t.decline(r.person.id), 'İstek reddedildi.'),
                      ),
                    ],
                  ),
                ),
                if (r.message.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        GwSpacing.md + GwAvatarSize.md.dimension + GwSpacing.sm, 0, GwSpacing.md, GwSpacing.sm),
                    child: Text('"${r.message}"', style: textTheme.bodyMedium),
                  ),
              ],
              if (value.outgoing.isNotEmpty) heading('Gönderdiklerin'),
              for (final r in value.outgoing)
                PersonRow(
                  person: r.person,
                  subtitle: 'Yanıt bekleniyor',
                  trailing: GwButton(
                    label: 'Geri çek',
                    variant: GwButtonVariant.secondary,
                    onPressed: () => runTeammateAction(context, ref, (t) => t.remove(r.person.id), 'İstek geri çekildi.'),
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
              message: 'Henüz ekip arkadaşın yok. Önerilerden birine istek göndererek başla.',
              actionLabel: 'Önerilere bak',
              onAction: () => DefaultTabController.of(context).animateTo(0),
            ),
          ]),
        AsyncData(:final value) => ListView(
            children: [
              for (final p in value.teammates)
                PersonRow(
                  person: p,
                  trailing: PopupMenuButton<void>(
                    tooltip: '${p.displayName} için seçenekler',
                    icon: const Icon(Icons.more_horiz),
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        onTap: () => runTeammateAction(context, ref, (t) => t.remove(p.id), 'Ekip arkadaşlığı bitti.'),
                        child: const Text('Ekip arkadaşlığını bitir'),
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
      appBar: AppBar(title: const Text('Ekip arkadaşı tercihleri')),
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
        _snack(context, _looking ? 'Tercihlerin kaydedildi. Artık önerilerde görünürsün.' : 'Tercihlerin kaydedildi.');
        await Navigator.of(context).maybePop();
      case Err(:final failure):
        _snack(context, failure.userMessage);
    }
  }

  void _toggle<T>(Set<T> set, T value, bool on) => setState(() => on ? set.add(value) : set.remove(value));

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final categories = ref.watch(categoriesProvider).value ?? const <Category>[];
    final answered = _draft.answered;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(GwSpacing.page),
            children: [
              _VisibilityCard(looking: _looking, onChanged: (v) => setState(() => _looking = v)),
              const SizedBox(height: GwSpacing.md),
              _Completeness(answered: answered),
              _Section(
                icon: Icons.sports_handball_outlined,
                title: 'Ne yapmak istiyorsun?',
                help: 'Ekip arkadaşı aradığın aktiviteler. En fazla ${TeammatePreferences.maxActivities} tane.',
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
                title: 'Seviyen',
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
                title: 'Hedeflerin',
                help: 'Birden fazla seçebilirsin.',
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
                title: 'Ne sıklıkla buluşmak istersin?',
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
                title: 'Ne zaman uygunsun?',
                help: 'Uygun olduğun zamanlara dokun.',
                child: _AvailabilityGrid(selected: _slots, onToggle: (s) => _toggle(_slots, s, !_slots.contains(s))),
              ),
              _Section(
                icon: Icons.groups_2_outlined,
                title: 'Nasıl bir ekip istersin?',
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
                title: 'Hangi ildesin?',
                help: 'Yalnızca eşleştirme için kullanılır, profilinde görünmez.',
                child: DropdownButtonFormField<int?>(
                  initialValue: _province,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'İl', prefixIcon: Icon(Icons.lock_outline_rounded)),
                  items: [
                    const DropdownMenuItem<int?>(child: Text('Belirtmek istemiyorum')),
                    for (var i = 0; i < turkishProvinces.length; i++)
                      DropdownMenuItem<int?>(value: i + 1, child: Text(turkishProvinces[i])),
                  ],
                  onChanged: (v) => setState(() => _province = v),
                ),
              ),
              _Section(
                icon: Icons.backpack_outlined,
                title: 'Ek bilgiler',
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: const Icon(Icons.directions_car_outlined),
                      title: const Text('Aracım var'),
                      subtitle: const Text('Ulaşımda yol arkadaşlığı yapabilirim.'),
                      value: _vehicle,
                      onChanged: (v) => setState(() => _vehicle = v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: const Icon(Icons.handyman_outlined),
                      title: const Text('Kendi ekipmanım var'),
                      subtitle: const Text('Bisiklet, çadır, raket gibi malzemem hazır.'),
                      value: _equipment,
                      onChanged: (v) => setState(() => _equipment = v),
                    ),
                  ],
                ),
              ),
              _Section(
                icon: Icons.edit_note_rounded,
                title: 'Kendini anlat',
                help: 'Önerilerde adının altında görünür.',
                child: TextField(
                  controller: _note,
                  maxLength: TeammatePreferences.noteMaxLength,
                  minLines: 2,
                  maxLines: 3,
                  decoration: const InputDecoration(hintText: 'Hafta sonu sabah yürüyüşü için arkadaş arıyorum.'),
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
                      _looking ? 'Önerilerde görüneceksin.' : 'Şu an önerilerde görünmüyorsun.',
                      style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: GwSpacing.sm),
                  GwButton(label: 'Kaydet', icon: Icons.check_rounded, isLoading: _saving, onPressed: _saving ? null : _save),
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
                Text('Ekip arıyorum', style: textTheme.titleMedium),
                Text(
                  looking
                      ? 'Önerilerde görünürsün; sana ekip arkadaşlığı isteği gönderilebilir.'
                      : 'Açarsan seninle aynı şeyleri sevenler seni bulur. Gizli hesaplar önerilerde görünmez.',
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
            Expanded(child: Text('Tercihlerin %${(ratio * 100).round()} tamam', style: textTheme.labelLarge)),
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
          'Ne kadar çok doldurursan önerilerin o kadar isabetli olur.',
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
                    padding: const EdgeInsets.only(left: GwSpacing.xs),
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
                  padding: const EdgeInsets.only(left: GwSpacing.xs),
                  child: Text(p, textAlign: TextAlign.center, style: textTheme.labelMedium?.copyWith(color: GwColors.textSecondary)),
                ),
              ),
          ],
        ),
        row('Hafta içi', false),
        row('Hafta sonu', true),
      ],
    );
  }
}
