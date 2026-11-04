import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../l10n.dart';
import '../tokens/borders.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';

/// A row of chips (categories, filters) wider than the screen (docs/DESIGN.md §7, Kayan şerit).
///
/// Scrolls sideways with a finger, a mouse drag or a trackpad. Where more chips lie beyond an edge, that edge fades
/// out and shows an arrow that scrolls by most of a screen, so nothing looks cut off.
class GwChipRail extends StatefulWidget {
  const GwChipRail({super.key, required this.children});

  final List<Widget> children;

  @override
  State<GwChipRail> createState() => _GwChipRailState();
}

class _GwChipRailState extends State<GwChipRail> {
  final _controller = ScrollController();
  bool _canBack = false;
  bool _canForward = false;

  /// Edge fade, and how much of the view an arrow tap scrolls.
  static const _fade = GwSpacing.xxl;
  static const _pageFraction = 0.8;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_update);
    WidgetsBinding.instance.addPostFrameCallback((_) => _update());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _update() {
    if (!mounted || !_controller.hasClients) return;
    final p = _controller.position;
    final back = p.pixels > p.minScrollExtent + 1;
    final forward = p.pixels < p.maxScrollExtent - 1;
    if (back != _canBack || forward != _canForward) {
      setState(() {
        _canBack = back;
        _canForward = forward;
      });
    }
  }

  void _scroll(int direction) {
    final p = _controller.position;
    final target = (p.pixels + direction * p.viewportDimension * _pageFraction).clamp(p.minScrollExtent, p.maxScrollExtent);
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.jumpTo(target);
    } else {
      _controller.animateTo(target, duration: const Duration(milliseconds: 250), curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = ScrollConfiguration(
      // Flutter scrolls with a mouse drag only when asked; on the web this is how a mouse user swipes the row.
      behavior: ScrollConfiguration.of(context).copyWith(dragDevices: PointerDeviceKind.values.toSet()),
      child: NotificationListener<ScrollMetricsNotification>(
        // Chips arrive later or the window is resized: the arrows follow.
        onNotification: (_) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _update());
          return false;
        },
        // A handful of chips: all are built, so screen readers and ensureVisible reach the ones off screen.
        child: SingleChildScrollView(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: GwSpacing.md),
          child: Row(spacing: GwSpacing.xs, children: widget.children),
        ),
      ),
    );

    return SizedBox(
      height: GwSpacing.minTouchTarget + GwSpacing.xs,
      child: Stack(
        children: [
          Positioned.fill(
            child: LayoutBuilder(builder: (context, constraints) {
              final edge = (_fade / constraints.maxWidth).clamp(0.0, 0.5);
              return ShaderMask(
                // Transparency, not a color: the rail sits on the page's gradient backdrop.
                blendMode: BlendMode.dstIn,
                shaderCallback: (rect) => LinearGradient(
                  colors: [
                    _canBack ? Colors.transparent : Colors.black,
                    Colors.black,
                    Colors.black,
                    _canForward ? Colors.transparent : Colors.black,
                  ],
                  stops: [0, edge, 1 - edge, 1],
                ).createShader(rect),
                child: list,
              );
            }),
          ),
          if (_canBack)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: _Arrow(icon: Icons.chevron_left_rounded, tooltip: designSystemL10n.previous, onPressed: () => _scroll(-1)),
            ),
          if (_canForward)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: _Arrow(icon: Icons.chevron_right_rounded, tooltip: designSystemL10n.next, onPressed: () => _scroll(1)),
            ),
        ],
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({required this.icon, required this.tooltip, required this.onPressed});

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Center(
        child: IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          icon: Icon(icon, color: GwColors.textPrimary),
          // A 32 circle; `padded` keeps the touch area at least 48.
          style: IconButton.styleFrom(
            backgroundColor: GwColors.background,
            side: GwBorders.hairline,
            fixedSize: const Size.square(GwSpacing.xl),
            minimumSize: const Size.square(GwSpacing.xl),
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.padded,
          ),
        ),
      );
}
