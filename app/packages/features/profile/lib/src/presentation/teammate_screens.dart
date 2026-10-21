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
        shape: const RoundedRectangleBorder(borderRadius: GxRadius.xlAll),
        title: Text('${widget.name} ile ekip arkadaşı ol'),
        content: TextField(
          controller: _controller,
          maxLength: 200,
          maxLines: 3,
          minLines: 2,
          decoration: const InputDecoration(labelText: 'Kısa bir mesaj (isteğe bağlı)', hintText: 'Cumartesi sabahı Belgrad Ormanı?'),
        ),
        actions: [
          GxButton(label: 'Vazgeç', variant: GxButtonVariant.text, onPressed: () => Navigator.of(context).pop()),
          GxButton(label: 'İstek gönder', onPressed: () => Navigator.of(context).pop(_controller.text)),
        ],
      );
}

/// Öneriler / İstekler / Ekip arkadaşlarım.
class TeammatesScreen extends ConsumerWidget {
  const TeammatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incoming = ref.watch(myTeammatesProvider).value?.incoming.length ?? 0;
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
        body: const GxReadingColumn(child: TabBarView(children: [_Suggestions(), _Requests(), _Teammates()])),
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
      margin: const EdgeInsets.fromLTRB(GxSpacing.md, 0, GxSpacing.md, GxSpacing.md),
      padding: const EdgeInsets.all(GxSpacing.md),
      decoration: const BoxDecoration(color: GxColors.primarySoft, borderRadius: GxRadius.lgAll),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sen de görün', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: GxSpacing.xxs),
          const Text('"Ekip arıyorum"u açarsan seninle aynı şeyleri sevenler sana istek gönderebilir.'),
          const SizedBox(height: GxSpacing.sm),
          GxButton(
            label: 'Tercihlerimi ayarla',
            variant: GxButtonVariant.secondary,
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
            const SizedBox(height: GxSpacing.lg),
            GxEmptyState(
              icon: Icons.diversity_3_outlined,
              message: 'Şimdilik sana uyan biri yok. İlgi alanlarını ve tercihlerini doldurursan öneriler artar.',
              actionLabel: 'Tercihlerimi ayarla',
              onAction: () => context.push(ProfileRoutes.teammateSettings),
            ),
          ]),
        AsyncData(:final value) => ListView(
            padding: const EdgeInsets.only(top: GxSpacing.md),
            children: [
              const _LookingPrompt(),
              for (final s in value) _SuggestionCard(suggestion: s),
            ],
          ),
        AsyncError(:final error) => GxErrorState(message: userMessageOf(error), onRetry: () => refreshTeammates(ref)),
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
      margin: const EdgeInsets.fromLTRB(GxSpacing.md, 0, GxSpacing.md, GxSpacing.sm),
      decoration: const BoxDecoration(
        borderRadius: GxRadius.lgAll,
        border: Border.fromBorderSide(BorderSide(color: GxColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PersonRow(
            person: s.person,
            subtitle: s.level == null ? s.person.displayName : '${s.person.displayName} · ${s.level!.label} seviye',
            trailing: GxButton(label: 'İstek gönder', onPressed: () => sendTeammateRequest(context, ref, s.person)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(GxSpacing.md, 0, GxSpacing.md, GxSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (s.note.isNotEmpty) ...[
                  Text('"${s.note}"', style: textTheme.bodyMedium),
                  const SizedBox(height: GxSpacing.xs),
                ],
                Text('Neden önerildi', style: textTheme.labelMedium?.copyWith(color: GxColors.textSecondary)),
                const SizedBox(height: GxSpacing.xxs),
                for (final reason in s.reasons)
                  Padding(
                    padding: const EdgeInsets.only(bottom: GxSpacing.xxs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline, size: GxSpacing.md, color: GxColors.primary),
                        const SizedBox(width: GxSpacing.xs),
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
          padding: const EdgeInsets.fromLTRB(GxSpacing.md, GxSpacing.md, GxSpacing.md, GxSpacing.xs),
          child: Text(text, style: textTheme.titleSmall),
        );
    return RefreshIndicator(
      onRefresh: () async => refreshTeammates(ref),
      child: switch (mine) {
        AsyncData(:final value) when value.incoming.isEmpty && value.outgoing.isEmpty => ListView(children: [
            const SizedBox(height: GxSpacing.xxl),
            GxEmptyState(
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
                      GxButton(
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
                        GxSpacing.md + GxAvatarSize.md.dimension + GxSpacing.sm, 0, GxSpacing.md, GxSpacing.sm),
                    child: Text('"${r.message}"', style: textTheme.bodyMedium),
                  ),
              ],
              if (value.outgoing.isNotEmpty) heading('Gönderdiklerin'),
              for (final r in value.outgoing)
                PersonRow(
                  person: r.person,
                  subtitle: 'Yanıt bekleniyor',
                  trailing: GxButton(
                    label: 'Geri çek',
                    variant: GxButtonVariant.secondary,
                    onPressed: () => runTeammateAction(context, ref, (t) => t.remove(r.person.id), 'İstek geri çekildi.'),
                  ),
                ),
            ],
          ),
        AsyncError(:final error) => GxErrorState(message: userMessageOf(error), onRetry: () => refreshTeammates(ref)),
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
            const SizedBox(height: GxSpacing.xxl),
            GxEmptyState(
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
        AsyncError(:final error) => GxErrorState(message: userMessageOf(error), onRetry: () => refreshTeammates(ref)),
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
      body: GxReadingColumn(
        child: switch (prefs) {
          AsyncData(:final value) => _SettingsForm(initial: value),
          AsyncError(:final error) =>
            GxErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(teammatePreferencesProvider)),
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
  late final _note = TextEditingController(text: widget.initial.note);
  bool _saving = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final result = await ref.read(teammatesRepositoryProvider).savePreferences(TeammatePreferences(
          looking: _looking,
          level: _level,
          availability: _slots,
          province: _province,
          note: _note.text,
        ));
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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    Widget label(String text, [String? help]) => Padding(
          padding: const EdgeInsets.only(top: GxSpacing.lg, bottom: GxSpacing.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text, style: textTheme.titleSmall),
              if (help != null) Text(help, style: textTheme.bodySmall?.copyWith(color: GxColors.textSecondary)),
            ],
          ),
        );
    return ListView(
      padding: const EdgeInsets.all(GxSpacing.md),
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Ekip arıyorum'),
          subtitle: const Text('Açıkken önerilerde görünürsün ve sana ekip arkadaşlığı isteği gönderilebilir. '
              'Gizli hesaplar önerilerde görünmez.'),
          value: _looking,
          onChanged: (v) => setState(() => _looking = v),
        ),
        label('Seviyen'),
        Wrap(
          spacing: GxSpacing.xs,
          children: [
            for (final l in TeammateLevel.values)
              ChoiceChip(
                label: Text(l.label),
                selected: _level == l,
                onSelected: (selected) => setState(() => _level = selected ? l : null),
              ),
          ],
        ),
        label('Ne zaman uygunsun?'),
        Wrap(
          spacing: GxSpacing.xs,
          runSpacing: GxSpacing.xs,
          children: [
            for (final s in TeammateSlot.values)
              FilterChip(
                label: Text(s.label),
                selected: _slots.contains(s),
                onSelected: (selected) => setState(() => selected ? _slots.add(s) : _slots.remove(s)),
              ),
          ],
        ),
        label('İlin', 'Yalnızca eşleştirme için kullanılır, profilinde görünmez.'),
        DropdownButtonFormField<int?>(
          initialValue: _province,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'İl'),
          items: [
            const DropdownMenuItem<int?>(child: Text('Belirtmek istemiyorum')),
            for (var i = 0; i < turkishProvinces.length; i++)
              DropdownMenuItem<int?>(value: i + 1, child: Text(turkishProvinces[i])),
          ],
          onChanged: (v) => setState(() => _province = v),
        ),
        label('Kısa not'),
        TextField(
          controller: _note,
          maxLength: TeammatePreferences.noteMaxLength,
          maxLines: 2,
          decoration: const InputDecoration(hintText: 'Hafta sonu sabah yürüyüşü için arkadaş arıyorum.'),
        ),
        const SizedBox(height: GxSpacing.md),
        GxButton(label: 'Kaydet', expand: true, isLoading: _saving, onPressed: _saving ? null : _save),
      ],
    );
  }
}
