import 'dart:math';

import 'package:flutter/material.dart';

import 'package:alphabet_adventure/ui/core/app_colors.dart';

/// Animated flying star from an origin point to a target destination (e.g. star counter).
class StarFlyAnimation extends StatefulWidget {
  final Offset startOffset;
  final Offset endOffset;
  final VoidCallback onComplete;
  final double size;

  const StarFlyAnimation({
    super.key,
    required this.startOffset,
    required this.endOffset,
    required this.onComplete,
    this.size = 48.0,
  });

  @override
  State<StarFlyAnimation> createState() => _StarFlyAnimationState();
}

class _StarFlyAnimationState extends State<StarFlyAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _curveAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _curveAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curveAnimation,
      builder: (context, child) {
        final t = _curveAnimation.value;

        // Curved quadratic bezier arc
        final midX = (widget.startOffset.dx + widget.endOffset.dx) / 2 - 80;
        final midY = min(widget.startOffset.dy, widget.endOffset.dy) - 100;
        final controlPoint = Offset(midX, midY);

        final x = (1 - t) * (1 - t) * widget.startOffset.dx +
            2 * (1 - t) * t * controlPoint.dx +
            t * t * widget.endOffset.dx;
        final y = (1 - t) * (1 - t) * widget.startOffset.dy +
            2 * (1 - t) * t * controlPoint.dy +
            t * t * widget.endOffset.dy;

        // Scale effect: large at start, shrinking slightly as it approaches counter
        final scale = 1.0 + sin(t * pi) * 0.4;
        final rotation = t * 4 * pi;

        return Positioned(
          left: x - widget.size / 2,
          top: y - widget.size / 2,
          child: Transform.rotate(
            angle: rotation,
            child: Transform.scale(
              scale: scale,
              child: Icon(
                Icons.star_rounded,
                size: widget.size,
                color: AppColors.accentYellow,
                shadows: [
                  Shadow(
                    color: AppColors.accentYellowDark.withValues(alpha: 0.8),
                    blurRadius: 16,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
