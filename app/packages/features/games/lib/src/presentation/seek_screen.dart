import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/chess.dart';
import '../l10n.dart';
import 'providers.dart';
import 'routes.dart';
import 'widgets.dart';

/// Looking for an opponent at one time control (docs/ARCHITECTURE.md §3i, Eşleşme ve davet). The seek is
/// refreshed every 5 seconds, which also widens the rating range; leaving the screen drops it.
class ChessSeekScreen extends ConsumerStatefulWidget {
  const ChessSeekScreen({super.key, required this.timeControl});

  final TimeControl timeControl;

  @override
  ConsumerState<ChessSeekScreen> createState() => _ChessSeekScreenState();
}

class _ChessSeekScreenState extends ConsumerState<ChessSeekScreen> with SingleTickerProviderStateMixin {
  late final ChessRepository _repo = ref.read(chessRepositoryProvider);
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  final _started = DateTime.now();
  StreamSubscription<String>? _matches;
  Timer? _beat;
  bool _done = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _matches = _repo.seekMatches().listen(_open);
    unawaited(_start());
  }

  Future<void> _start() async {
    switch (await _repo.seek(widget.timeControl)) {
      case Ok(value: final game?):
        _open(game);
      case Ok():
        _beat = Timer.periodic(const Duration(seconds: 5), (_) async {
          if (await _repo.heartbeat() case Ok(value: final game?)) _open(game);
          if (mounted) setState(() {});
        });
      case Err(:final failure):
        if (mounted) setState(() => _error = failure.userMessage);
    }
  }

  void _open(String game) {
    if (_done || !mounted) return;
    _done = true;
    _beat?.cancel();
    context.pushReplacement(ChessRoutes.game(game));
  }

  @override
  void dispose() {
    _beat?.cancel();
    _matches?.cancel();
    _pulse.dispose();
    if (!_done) unawaited(_repo.cancelSeek());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tc = widget.timeControl;
    final waited = DateTime.now().difference(_started).inSeconds;
    return Scaffold(
      appBar: AppBar(title: Text(gamesL10n.quickGame)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(GwSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_error case final error?) ...[
                GwErrorState(message: error, onRetry: () {
                  setState(() => _error = null);
                  unawaited(_start());
                }),
              ] else ...[
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (_, _) => Container(
                    width: GwSpacing.xxl * 2,
                    height: GwSpacing.xxl * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: GwColors.primarySoft,
                      border: Border.all(
                        color: GwColors.primary.withValues(alpha: 1 - _pulse.value),
                        width: GwBorders.ringWidth + GwSpacing.sm * _pulse.value,
                      ),
                    ),
                    child: Icon(chessCategoryIcon(tc.category), size: GwSpacing.xl, color: GwColors.primary),
                  ),
                ),
                const SizedBox(height: GwSpacing.lg),
                Text(gamesL10n.searching, style: textTheme.titleLarge),
                const SizedBox(height: GwSpacing.xs),
                Text('${tc.label} · ${tc.category.label} · ${gamesL10n.rated}',
                    style: textTheme.bodyLarge?.copyWith(color: GwColors.textSecondary)),
                const SizedBox(height: GwSpacing.xxs),
                Text(gamesL10n.waitedSeconds(waited), style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
                const SizedBox(height: GwSpacing.lg),
                GwButton(label: gamesL10n.cancel, variant: GwButtonVariant.secondary, onPressed: () => context.pop()),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
