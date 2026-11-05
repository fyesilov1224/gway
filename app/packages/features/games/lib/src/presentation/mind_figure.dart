import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../domain/mind.dart';
import '../l10n.dart';

/// The words for a figure in the app language, e.g. "kırmızı çizgili yuvarlak" (docs/ARCHITECTURE.md §3j, Dikkat).
/// Gendered languages agree the color and pattern with the shape.
String describeFigure(MindFigure f) {
  final gender = gamesL10n.mindShapeGender(f.shape.name);
  return gamesL10n.mindFigure(
    gamesL10n.mindColorWord('${f.color}_$gender'),
    gamesL10n.mindPatternWord('${f.pattern.name}_$gender'),
    gamesL10n.mindShapeWord(f.shape.name),
  );
}

/// A drawn shape in one of the six figure colors, filled solid, striped or dotted.
class MindFigureView extends StatelessWidget {
  const MindFigureView({super.key, required this.figure, this.size = GwSpacing.xxl, this.label = true});

  final MindFigure figure;
  final double size;

  /// Read the figure's words to screen readers.
  final bool label;

  @override
  Widget build(BuildContext context) {
    final painted = SizedBox.square(dimension: size, child: CustomPaint(painter: _FigurePainter(figure)));
    return label ? Semantics(label: describeFigure(figure), child: painted) : ExcludeSemantics(child: painted);
  }
}

class _FigurePainter extends CustomPainter {
  _FigurePainter(this.figure);

  final MindFigure figure;

  Path _shape(Size size) {
    final s = size.shortestSide;
    final c = size.center(Offset.zero);
    final r = s * 0.42;
    switch (figure.shape) {
      case MindShape.circle:
        return Path()..addOval(Rect.fromCircle(center: c, radius: r));
      case MindShape.square:
        return Path()..addRRect(RRect.fromRectAndRadius(Rect.fromCircle(center: c, radius: r * 0.88), Radius.circular(s * 0.06)));
      case MindShape.triangle:
        final h = r * 1.9;
        final top = c.dy - h * 0.55;
        return Path()
          ..moveTo(c.dx, top)
          ..lineTo(c.dx + r * 1.05, top + h)
          ..lineTo(c.dx - r * 1.05, top + h)
          ..close();
      case MindShape.star:
        final path = Path();
        for (var i = 0; i < 10; i++) {
          final radius = i.isEven ? r * 1.08 : r * 0.46;
          final angle = -math.pi / 2 + i * math.pi / 5;
          final p = c + Offset(math.cos(angle), math.sin(angle)) * radius;
          i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
        }
        return path..close();
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final color = GwMindColor.parse(figure.color).color;
    final s = size.shortestSide;
    final shape = _shape(size);
    final outline = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.06
      ..strokeJoin = StrokeJoin.round;
    switch (figure.pattern) {
      case MindPattern.solid:
        canvas.drawPath(shape, Paint()..color = color);
      case MindPattern.striped:
        canvas
          ..save()
          ..clipPath(shape)
          ..drawPath(shape, Paint()..color = GwColors.background);
        final stripe = Paint()
          ..color = color
          ..strokeWidth = s * 0.075;
        for (var x = -s; x < s * 2; x += s * 0.19) {
          canvas.drawLine(Offset(x, s), Offset(x + s, 0), stripe);
        }
        canvas.restore();
      case MindPattern.dotted:
        canvas
          ..save()
          ..clipPath(shape)
          ..drawPath(shape, Paint()..color = GwColors.background);
        final dot = Paint()..color = color;
        final step = s * 0.17;
        for (var y = step / 2; y < s; y += step) {
          for (var x = step / 2; x < s; x += step) {
            canvas.drawCircle(Offset(x, y), s * 0.045, dot);
          }
        }
        canvas.restore();
    }
    canvas.drawPath(shape, outline);
  }

  @override
  bool shouldRepaint(_FigurePainter old) => old.figure != figure;
}

/// A letter or digit in its color on a quiet tile; [hidden] shows "?" instead.
class MindCharTile extends StatelessWidget {
  const MindCharTile({super.key, required this.char, this.hidden = false, this.size = GwSpacing.xxl, this.outline});

  final MindChar? char;
  final bool hidden;
  final double size;

  /// A colored frame, e.g. right or wrong after the answer.
  final Color? outline;

  @override
  Widget build(BuildContext context) {
    final c = char;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: GwColors.surface,
        borderRadius: GwRadius.mdAll,
        border: Border.all(color: outline ?? GwColors.border, width: outline == null ? 1 : GwBorders.ringWidth),
      ),
      child: Text(
        hidden || c == null ? '?' : c.char,
        style: textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: hidden || c == null ? GwColors.textSecondary : GwMindColor.parse(c.color).color,
          height: 1,
        ),
      ),
    );
  }
}
