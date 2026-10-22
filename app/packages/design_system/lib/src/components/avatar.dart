import 'package:flutter/material.dart';

import '../tokens/radius.dart';
import '../tokens/tones.dart';

enum GxAvatarSize {
  sm(32),
  md(40),
  lg(64),
  xl(96),
  xxl(128);

  const GxAvatarSize(this.dimension);

  final double dimension;
}

/// Users are shown as circles, groups as rounded squares.
enum GxAvatarShape { user, group }

class GxAvatar extends StatelessWidget {
  const GxAvatar({
    super.key,
    required this.name,
    required this.shape,
    this.imageUrl,
    this.size = GxAvatarSize.md,
    this.tone,
  });

  /// Used for initials and the semantic label.
  final String name;
  final GxAvatarShape shape;
  final String? imageUrl;
  final GxAvatarSize size;

  /// Background and initials color without an image; defaults to the name's tone.
  final GxTone? tone;

  @override
  Widget build(BuildContext context) {
    final dimension = size.dimension;
    final url = imageUrl;
    final palette = tone ?? GxTone.of(name);
    final fallback = _Initials(name: name, dimension: dimension, color: palette.strong);

    final decoration = switch (shape) {
      GxAvatarShape.user => ShapeDecoration(
          color: palette.soft,
          shape: const CircleBorder(),
        ),
      GxAvatarShape.group => ShapeDecoration(
          color: palette.soft,
          shape: RoundedRectangleBorder(
            // Scales with size so small and large group avatars look alike.
            borderRadius: BorderRadius.circular(
              dimension * GxRadius.lg / GxAvatarSize.lg.dimension,
            ),
          ),
        ),
    };

    return Semantics(
      image: true,
      label: name,
      child: Container(
        width: dimension,
        height: dimension,
        clipBehavior: Clip.antiAlias,
        decoration: decoration,
        child: url == null
            ? fallback
            : Image.network(
                url,
                fit: BoxFit.cover,
                excludeFromSemantics: true,
                errorBuilder: (_, _, _) => fallback,
              ),
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.name, required this.dimension, required this.color});

  final String name;
  final double dimension;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelLarge?.copyWith(
          color: color,
          fontSize: dimension * 0.4,
          height: 1,
        );
    return Center(
      child: ExcludeSemantics(
        child: Text(
          initialsOf(name),
          style: style,
          textScaler: TextScaler.noScaling,
        ),
      ),
    );
  }
}

/// Up to two uppercase initials using Turkish casing rules.
@visibleForTesting
String initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  final letters = parts.take(2).map((p) => _upperTr(p.characters.first));
  return letters.join();
}

String _upperTr(String char) => switch (char) {
      'i' => 'İ',
      'ı' => 'I',
      _ => char.toUpperCase(),
    };
