import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/chess.dart';
import '../domain/countries.dart';
import '../l10n.dart';
import 'providers.dart';
import 'widgets.dart';

/// Picks the flag shown next to the person in chess; saves it and refreshes their card.
Future<void> showCountryPicker(BuildContext context, WidgetRef ref, {String? current}) async {
  final code = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _CountryPicker(current: current),
  );
  if (code == null || !context.mounted) return;
  final result = await ref.read(chessRepositoryProvider).setCountry(code);
  if (!context.mounted) return;
  final me = ref.read(currentUserIdProvider);
  if (me != null) ref.invalidate(chessProfileProvider(me));
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(switch (result) {
      Ok() => gamesL10n.flagSaved,
      Err(:final failure) => failure.userMessage,
    }),
  ));
}

/// Whether the person still has to pick a starting level: no rating row in any category yet.
bool needsChessLevel(ChessProfile? profile) => profile != null && profile.ratings.isEmpty;

/// Before the first rated game: asks once for the starting level (docs/ARCHITECTURE.md §3i, Puan). True when the
/// person may go on (a level is set, or none was needed); false when they closed the sheet.
Future<bool> ensureChessLevel(BuildContext context, WidgetRef ref) async {
  final me = ref.read(currentUserIdProvider);
  if (me == null) return false;
  final profile = await ref.read(chessProfileProvider(me).future).then<ChessProfile?>((p) => p, onError: (_) => null);
  if (!needsChessLevel(profile) || !context.mounted) return true;
  return showLevelPicker(context, ref);
}

/// The five starting levels; saves the choice and refreshes the person's card. True when saved.
Future<bool> showLevelPicker(BuildContext context, WidgetRef ref) async {
  final rating = await showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _LevelPicker(),
  );
  if (rating == null || !context.mounted) return false;
  final result = await ref.read(chessRepositoryProvider).setLevel(rating);
  if (!context.mounted) return false;
  final me = ref.read(currentUserIdProvider);
  if (me != null) ref.invalidate(chessProfileProvider(me));
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(switch (result) {
      Ok() => gamesL10n.levelSaved(rating),
      Err(:final failure) => failure.userMessage,
    }),
  ));
  return result is Ok;
}

class _LevelPicker extends StatelessWidget {
  const _LevelPicker();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final levels = [
      (400, Icons.child_care_rounded, gamesL10n.levelNew, gamesL10n.levelNewHint),
      (800, Icons.school_outlined, gamesL10n.levelBeginner, gamesL10n.levelBeginnerHint),
      (1200, Icons.trending_up_rounded, gamesL10n.levelIntermediate, gamesL10n.levelIntermediateHint),
      (1600, Icons.workspace_premium_outlined, gamesL10n.levelAdvanced, gamesL10n.levelAdvancedHint),
      (2000, Icons.military_tech_outlined, gamesL10n.levelMaster, gamesL10n.levelMasterHint),
    ];
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(GwSpacing.lg, 0, GwSpacing.lg, GwSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(gamesL10n.levelTitle, style: textTheme.titleLarge),
            const SizedBox(height: GwSpacing.xxs),
            Text(gamesL10n.levelBody, style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
            const SizedBox(height: GwSpacing.md),
            for (final (rating, icon, title, hint) in levels)
              Padding(
                padding: const EdgeInsets.only(bottom: GwSpacing.xs),
                child: GwCard(
                  radius: GwRadius.lgAll,
                  onTap: () => Navigator.of(context).pop(rating),
                  padding: const EdgeInsets.all(GwSpacing.sm),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(GwSpacing.xs),
                        decoration: const BoxDecoration(color: GwColors.primarySoft, borderRadius: GwRadius.mdAll),
                        child: Icon(icon, color: GwColors.primary),
                      ),
                      const SizedBox(width: GwSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                            Text(hint, style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
                          ],
                        ),
                      ),
                      const SizedBox(width: GwSpacing.sm),
                      Text('$rating', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, fontFeatures: const [FontFeature.tabularFigures()])),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: GwSpacing.xs),
            Text(gamesL10n.levelNote, style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _CountryPicker extends StatefulWidget {
  const _CountryPicker({this.current});

  final String? current;

  @override
  State<_CountryPicker> createState() => _CountryPickerState();
}

class _CountryPickerState extends State<_CountryPicker> {
  String _query = '';

  /// Search ignores case and accents (İ/i, Ç/c).
  static String _fold(String s) => s
      .toLowerCase()
      .replaceAll('ı', 'i')
      .replaceAll('i̇', 'i')
      .replaceAll(RegExp('[çć]'), 'c')
      .replaceAll(RegExp('[ğ]'), 'g')
      .replaceAll(RegExp('[öó]'), 'o')
      .replaceAll(RegExp('[şś]'), 's')
      .replaceAll(RegExp('[üú]'), 'u')
      .replaceAll(RegExp('[éèê]'), 'e')
      .replaceAll(RegExp('[áàâã]'), 'a');

  @override
  Widget build(BuildContext context) {
    final suggested = defaultCountry();
    final q = _fold(_query.trim());
    final codes = [
      suggested,
      for (final c in [...countryCodes]..sort((a, b) => countryName(a).compareTo(countryName(b))))
        if (c != suggested) c,
    ].where((c) => q.isEmpty || _fold(countryName(c)).contains(q) || c.toLowerCase() == q).toList();
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.8,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(GwSpacing.lg, 0, GwSpacing.lg, GwSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(gamesL10n.chooseFlag, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: GwSpacing.xxs),
                Text(gamesL10n.chooseFlagHint, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
                const SizedBox(height: GwSpacing.sm),
                TextField(
                  autofocus: false,
                  decoration: InputDecoration(prefixIcon: const Icon(Icons.search_rounded), hintText: gamesL10n.searchCountry),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: codes.length,
              itemBuilder: (context, i) {
                final c = codes[i];
                return ListTile(
                  leading: ChessFlag(c, height: GwSpacing.md),
                  title: Text(countryName(c)),
                  trailing: c == widget.current ? const Icon(Icons.check_rounded, color: GwColors.primary) : null,
                  onTap: () => Navigator.of(context).pop(c),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Invites someone to a game: who (unless given), time control, rated or casual, and color.
/// Returns true once the invitation is sent.
Future<bool> showChallengeSheet(BuildContext context, {ChessPlayer? opponent}) async =>
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _ChallengeSheet(opponent: opponent),
    ) ??
    false;

class _ChallengeSheet extends ConsumerStatefulWidget {
  const _ChallengeSheet({this.opponent});

  final ChessPlayer? opponent;

  @override
  ConsumerState<_ChallengeSheet> createState() => _ChallengeSheetState();
}

class _ChallengeSheetState extends ConsumerState<_ChallengeSheet> {
  late ChessPlayer? _opponent = widget.opponent;
  TimeControl _tc = TimeControl.standard;
  bool _rated = true;
  ColorChoice _color = ColorChoice.random;
  bool _sending = false;
  String? _error;
  List<ChessPlayer> _results = const [];
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _search(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final result = await ref.read(chessRepositoryProvider).searchPlayers(q);
      if (!mounted) return;
      setState(() => _results = switch (result) {
            Ok(:final value) => value,
            Err() => const [],
          });
    });
  }

  Future<void> _send() async {
    final opponent = _opponent;
    if (opponent == null) return;
    if (_rated && !await ensureChessLevel(context, ref)) return;
    if (!mounted) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    final result = await ref.read(chessRepositoryProvider).challenge(opponent.userId, _tc, rated: _rated, color: _color);
    if (!mounted) return;
    switch (result) {
      case Ok():
        ref.invalidate(challengesProvider);
        Navigator.of(context).pop(true);
      case Err(:final failure):
        setState(() {
          _sending = false;
          _error = failure.userMessage;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final opponent = _opponent;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(GwSpacing.lg, 0, GwSpacing.lg, GwSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(gamesL10n.challengeTitle, style: textTheme.titleLarge),
              const SizedBox(height: GwSpacing.md),
              if (opponent != null)
                ChessPlayerLine(
                  player: opponent,
                  trailing: widget.opponent == null
                      ? IconButton(
                          tooltip: gamesL10n.changePerson,
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => setState(() => _opponent = null),
                        )
                      : null,
                )
              else ...[
                TextField(
                  autofocus: true,
                  decoration: InputDecoration(prefixIcon: const Icon(Icons.search_rounded), hintText: gamesL10n.searchPerson),
                  onChanged: _search,
                ),
                for (final p in _results)
                  Padding(
                    padding: const EdgeInsets.only(top: GwSpacing.xs),
                    child: ChessPlayerLine(player: p, onTap: () => setState(() => _opponent = p)),
                  ),
              ],
              const SizedBox(height: GwSpacing.lg),
              Text(gamesL10n.timeControl, style: textTheme.titleSmall),
              const SizedBox(height: GwSpacing.xs),
              Wrap(
                spacing: GwSpacing.xs,
                runSpacing: GwSpacing.xs,
                children: [
                  for (final tc in TimeControl.catalog)
                    ChoiceChip(
                      label: Text('${tc.label} · ${tc.category.label}'),
                      selected: tc == _tc,
                      onSelected: (_) => setState(() => _tc = tc),
                    ),
                ],
              ),
              const SizedBox(height: GwSpacing.md),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(gamesL10n.rated),
                subtitle: Text(gamesL10n.ratedHint),
                value: _rated,
                onChanged: (v) => setState(() => _rated = v),
              ),
              const SizedBox(height: GwSpacing.xs),
              Text(gamesL10n.yourColor, style: textTheme.titleSmall),
              const SizedBox(height: GwSpacing.xs),
              SegmentedButton<ColorChoice>(
                segments: [for (final c in ColorChoice.values) ButtonSegment(value: c, label: Text(c.label))],
                selected: {_color},
                onSelectionChanged: (s) => setState(() => _color = s.first),
              ),
              if (_error case final error?) ...[
                const SizedBox(height: GwSpacing.md),
                GwFormMessage(error),
              ],
              const SizedBox(height: GwSpacing.lg),
              GwButton(
                label: gamesL10n.sendChallenge,
                icon: Icons.send_rounded,
                expand: true,
                isLoading: _sending,
                onPressed: opponent == null ? null : _send,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
