import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jovial_svg/jovial_svg.dart';

import '../l10n.dart';
import 'chess_board.dart';

/// The piece sets on offer, each with a license that allows a closed-source app (docs/ARCHITECTURE.md §3i, lisanslar).
enum PieceStyle {
  classic('classic'),
  celtic('celtic'),
  spatial('spatial'),
  fantasy('fantasy'),
  modern('chessnut'),
  warm('rhosgfx');

  const PieceStyle(this.folder);

  /// Folder under assets/pieces.
  final String folder;

  String get label => switch (this) {
        classic => gamesL10n.piecesClassic,
        celtic => gamesL10n.piecesCeltic,
        spatial => gamesL10n.piecesSpatial,
        fantasy => gamesL10n.piecesFantasy,
        modern => gamesL10n.piecesModern,
        warm => gamesL10n.piecesWarm,
      };
}

extension BoardThemeLabel on GwBoardTheme {
  String get label => switch (this) {
        GwBoardTheme.wood => gamesL10n.boardWood,
        GwBoardTheme.green => gamesL10n.boardGreen,
        GwBoardTheme.blue => gamesL10n.boardBlue,
        GwBoardTheme.slate => gamesL10n.boardSlate,
        GwBoardTheme.lilac => gamesL10n.boardLilac,
      };
}

typedef ChessAppearance = ({GwBoardTheme board, PieceStyle pieces});

/// The person's board and pieces, kept on the device (the app's shared preferences).
class ChessAppearanceNotifier extends Notifier<ChessAppearance> {
  static const _boardKey = 'chess.board';
  static const _piecesKey = 'chess.pieces';

  @override
  ChessAppearance build() {
    final prefs = ref.watch(languagePreferencesProvider);
    final board = GwBoardTheme.values.where((t) => t.name == prefs?.getString(_boardKey)).firstOrNull ?? GwBoardTheme.wood;
    final pieces = PieceStyle.values.where((p) => p.name == prefs?.getString(_piecesKey)).firstOrNull ?? PieceStyle.classic;
    return (board: board, pieces: pieces);
  }

  void setBoard(GwBoardTheme board) {
    state = (board: board, pieces: state.pieces);
    ref.read(languagePreferencesProvider)?.setString(_boardKey, board.name);
  }

  void setPieces(PieceStyle pieces) {
    state = (board: state.board, pieces: pieces);
    ref.read(languagePreferencesProvider)?.setString(_piecesKey, pieces.name);
  }
}

final chessAppearanceProvider = NotifierProvider<ChessAppearanceNotifier, ChessAppearance>(ChessAppearanceNotifier.new);

/// The drawings of one piece set, loaded once per set.
final pieceSetProvider = FutureProvider.family<PieceSet, PieceStyle>((ref, style) => loadPieceSet(rootBundle, style.folder));

/// The chosen set (loading it on first use).
final currentPieceSetProvider = FutureProvider<PieceSet>((ref) => ref.watch(pieceSetProvider(ref.watch(chessAppearanceProvider).pieces).future));

/// Choose the board colors and the pieces; the preview shows the choice at once.
Future<void> showAppearanceSheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _AppearanceSheet(),
    );

class _AppearanceSheet extends ConsumerWidget {
  const _AppearanceSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final appearance = ref.watch(chessAppearanceProvider);
    final notifier = ref.read(chessAppearanceProvider.notifier);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(GwSpacing.lg, 0, GwSpacing.lg, GwSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(gamesL10n.appearance, style: textTheme.titleLarge),
            const SizedBox(height: GwSpacing.md),
            Text(gamesL10n.boardTheme, style: textTheme.titleSmall),
            const SizedBox(height: GwSpacing.xs),
            Wrap(
              spacing: GwSpacing.sm,
              runSpacing: GwSpacing.sm,
              children: [
                for (final t in GwBoardTheme.values)
                  _Choice(
                    selected: appearance.board == t,
                    label: t.label,
                    onTap: () => notifier.setBoard(t),
                    child: _MiniBoard(theme: t, style: appearance.pieces),
                  ),
              ],
            ),
            const SizedBox(height: GwSpacing.lg),
            Text(gamesL10n.pieceSet, style: textTheme.titleSmall),
            const SizedBox(height: GwSpacing.xs),
            Wrap(
              spacing: GwSpacing.sm,
              runSpacing: GwSpacing.sm,
              children: [
                for (final p in PieceStyle.values)
                  _Choice(
                    selected: appearance.pieces == p,
                    label: p.label,
                    onTap: () => notifier.setPieces(p),
                    child: _MiniBoard(theme: appearance.board, style: p),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({required this.selected, required this.label, required this.onTap, required this.child});

  final bool selected;
  final String label;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: GwRadius.mdAll,
          child: Container(
            padding: const EdgeInsets.all(GwSpacing.xxs),
            decoration: BoxDecoration(
              borderRadius: GwRadius.mdAll,
              border: Border.all(color: selected ? GwColors.primary : GwColors.border, width: selected ? GwBorders.ringWidth : 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                child,
                const SizedBox(height: GwSpacing.xxs),
                Text(label, style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
        ),
      );
}

/// Two squares with a knight and a queen: enough to judge colors and pieces.
class _MiniBoard extends ConsumerWidget {
  const _MiniBoard({required this.theme, required this.style});

  final GwBoardTheme theme;
  final PieceStyle style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pieces = ref.watch(pieceSetProvider(style)).value;
    const size = GwSpacing.xl + GwSpacing.xs;
    Widget square(Color color, String? piece) => Container(
          width: size,
          height: size,
          color: color,
          child: piece == null || pieces == null ? null : ScalableImageWidget(si: pieces[piece]!),
        );
    return ClipRRect(
      borderRadius: GwRadius.smAll,
      child: Row(mainAxisSize: MainAxisSize.min, children: [square(theme.light, 'wN'), square(theme.dark, 'bQ')]),
    );
  }
}
