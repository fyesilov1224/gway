import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/radius.dart';

/// Placeholder block shown while content loads. Pulses gently unless the
/// platform asks for reduced motion.
class GwSkeleton extends StatefulWidget {
  const GwSkeleton({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = GwRadius.smAll,
  });

  /// Circle placeholder, e.g. for a user avatar.
  const GwSkeleton.circle({super.key, required double size})
      : width = size,
        height = size,
        borderRadius = const BorderRadius.all(Radius.circular(9999));

  final double? width;
  final double height;
  final BorderRadius borderRadius;

  @override
  State<GwSkeleton> createState() => _GwSkeletonState();
}

class _GwSkeletonState extends State<GwSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Color.lerp(
              GwColors.surfaceMuted,
              GwColors.border,
              _controller.value,
            ),
            borderRadius: widget.borderRadius,
          ),
        ),
      ),
    );
  }
}
