import 'dart:math';

import 'package:flutter/material.dart';

import 'package:alphabet_adventure/ui/core/animations/bounce_animation.dart';
import 'package:alphabet_adventure/ui/core/app_colors.dart';
import 'package:alphabet_adventure/ui/core/wood/wood.dart';

/// Mascot expression/mood states.
enum MascotMood { idle, happy, cheering, thinking, speaking }

/// Animated Pip the Parrot mascot with custom speech bubble and interactive animations.
class MascotWidget extends StatefulWidget {
  final MascotMood mood;
  final String? speechBubbleText;
  final VoidCallback? onTap;
  final double size;
  final bool showSpeechBubble;

  const MascotWidget({
    super.key,
    this.mood = MascotMood.idle,
    this.speechBubbleText,
    this.onTap,
    this.size = 120.0,
    this.showSpeechBubble = true,
  });

  @override
  State<MascotWidget> createState() => _MascotWidgetState();
}

class _MascotWidgetState extends State<MascotWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The bubble belongs to Pip, so tapping it counts as tapping Pip; this
    // also keeps taps in the gap from falling through to what lies beneath.
    return BounceAnimation(
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showSpeechBubble && widget.speechBubbleText != null)
            _buildSpeechBubble(widget.speechBubbleText!),
          const SizedBox(height: 6),
          AnimatedBuilder(
            animation: _floatController,
            builder: (context, child) {
              final floatOffset = sin(_floatController.value * pi) * 6.0;
              final tiltAngle = sin(_floatController.value * pi) * 0.05;

              return Transform.translate(
                offset: Offset(0, floatOffset),
                child: Transform.rotate(
                  angle: widget.mood == MascotMood.cheering
                      ? tiltAngle * 3
                      : tiltAngle,
                  child: _buildPipTheParrot(widget.size),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSpeechBubble(String text) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 240),
      child: CustomPaint(
        painter: const _SpeechBubblePainter(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            18,
            9,
            18,
            8 + _SpeechBubblePainter.depth + _SpeechBubblePainter.tailHeight,
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: WoodText.heading(fontSize: 17),
          ),
        ),
      ),
    );
  }

  Widget _buildPipTheParrot(double size) {
    // Rich vectorized representation of Pip the Parrot
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFF4ECDC4), Color(0xFF1B998B)],
          center: Alignment(-0.2, -0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B998B).withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Feather crest / hat
          Positioned(
            top: size * 0.08,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: size * 0.14,
                  height: size * 0.22,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(size * 0.1),
                  ),
                ),
                Container(
                  width: size * 0.16,
                  height: size * 0.28,
                  decoration: BoxDecoration(
                    color: AppColors.accentYellow,
                    borderRadius: BorderRadius.circular(size * 0.1),
                  ),
                ),
                Container(
                  width: size * 0.14,
                  height: size * 0.22,
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen,
                    borderRadius: BorderRadius.circular(size * 0.1),
                  ),
                ),
              ],
            ),
          ),
          // Big expressive eyes
          Positioned(
            top: size * 0.35,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildEye(size * 0.26),
                SizedBox(width: size * 0.08),
                _buildEye(size * 0.26),
              ],
            ),
          ),
          // Cheerful beak
          Positioned(
            top: size * 0.52,
            child: Container(
              width: size * 0.28,
              height: size * 0.22,
              decoration: BoxDecoration(
                color: AppColors.accentOrange,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(size * 0.14),
                  bottomRight: Radius.circular(size * 0.14),
                  topLeft: Radius.circular(size * 0.04),
                  topRight: Radius.circular(size * 0.04),
                ),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
          // Rosy cheeks
          Positioned(
            top: size * 0.56,
            left: size * 0.12,
            child: Container(
              width: size * 0.14,
              height: size * 0.1,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(size * 0.07),
              ),
            ),
          ),
          Positioned(
            top: size * 0.56,
            right: size * 0.12,
            child: Container(
              width: size * 0.14,
              height: size * 0.1,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(size * 0.07),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEye(double eyeSize) {
    return Container(
      width: eyeSize,
      height: eyeSize,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: eyeSize * 0.6,
          height: eyeSize * 0.6,
          decoration: const BoxDecoration(
            color: AppColors.textDark,
            shape: BoxShape.circle,
          ),
          child: Align(
            alignment: const Alignment(0.4, -0.4),
            child: Container(
              width: eyeSize * 0.2,
              height: eyeSize * 0.2,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A parchment callout on a wooden rim, with a bevel underneath and a tail
/// pointing down at the mascot.
class _SpeechBubblePainter extends CustomPainter {
  const _SpeechBubblePainter();

  static const double depth = 4;
  static const double tailHeight = 10;
  static const double _tailWidth = 20;
  static const double _radius = 18;
  static const double _rimWidth = 3;

  /// The bubble outline: a rounded body with the tail at its bottom centre.
  Path _outline(Size size) {
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height - depth - tailHeight),
      const Radius.circular(_radius),
    );
    final centre = size.width / 2;
    final tail = Path()
      ..moveTo(centre - _tailWidth / 2, body.bottom - 2)
      ..lineTo(centre + _tailWidth / 2, body.bottom - 2)
      ..lineTo(centre + 2, body.bottom + tailHeight)
      ..quadraticBezierTo(
        centre,
        body.bottom + tailHeight + 2,
        centre - 2,
        body.bottom + tailHeight,
      )
      ..close();
    return Path.combine(PathOperation.union, Path()..addRRect(body), tail);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final outline = _outline(size);
    canvas
      ..drawPath(
        outline.shift(const Offset(0, depth + 2)),
        Paint()
          ..color = const Color(0x33000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      )
      // Bevel under the rim gives the bubble some thickness.
      ..drawPath(
        outline.shift(const Offset(0, depth)),
        Paint()..color = WoodColors.lightWood.bevel,
      )
      ..drawPath(
        outline,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFAEE), WoodColors.parchment],
          ).createShader(outline.getBounds()),
      )
      ..drawPath(
        outline,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _rimWidth
          ..strokeJoin = StrokeJoin.round
          ..color = WoodColors.lightWood.rim,
      );
  }

  @override
  bool shouldRepaint(_SpeechBubblePainter oldDelegate) => false;
}
