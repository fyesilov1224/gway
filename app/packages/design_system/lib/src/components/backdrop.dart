import 'package:flutter/material.dart';

import '../tokens/colors.dart';

/// The page background: white melting into soft lilac and pink
/// (docs/DESIGN.md §1, Zemin). [GxTheme] puts it behind every page route,
/// so screens never set a background color of their own.
class GxBackdrop extends StatelessWidget {
  const GxBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(fit: StackFit.expand, children: [const _Gradient(), child]);
}

/// Lilac top left, white in the middle, pink at the bottom right, with a
/// pink glow in the top right corner and a lilac one at the bottom left.
class _Gradient extends StatelessWidget {
  const _Gradient();

  static BoxDecoration _glow(Alignment center, double radius, Color color) => BoxDecoration(
        gradient: RadialGradient(center: center, radius: radius, colors: [color, color.withValues(alpha: 0)]),
      );

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [GxColors.backdropLilac, GxColors.background, GxColors.backdropPink],
            stops: [0, 0.55, 1],
          ),
        ),
        child: DecoratedBox(
          decoration: _glow(Alignment.topRight, 1.1, GxColors.backdropPink),
          child: DecoratedBox(decoration: _glow(const Alignment(-1, 0.9), 0.8, GxColors.backdropLilac)),
        ),
      );
}

/// Wraps a platform's page transition so each page carries the backdrop
/// (pages stay opaque while they slide or fade over each other).
class GxBackdropTransitions extends PageTransitionsBuilder {
  const GxBackdropTransitions(this.inner);

  final PageTransitionsBuilder inner;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      inner.buildTransitions(route, context, animation, secondaryAnimation, GxBackdrop(child: child));
}
