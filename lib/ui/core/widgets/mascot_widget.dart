import 'dart:math';

import 'package:flutter/material.dart';

import 'package:alphabet_adventure/ui/core/animations/bounce_animation.dart';
import 'package:alphabet_adventure/ui/core/app_colors.dart';

/// Mascot expression/mood states.
enum MascotMood {
  idle,
  happy,
  cheering,
  thinking,
  speaking,
}

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showSpeechBubble && widget.speechBubbleText != null)
          _buildSpeechBubble(widget.speechBubbleText!),
        const SizedBox(height: 8),
        BounceAnimation(
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _floatController,
            builder: (context, child) {
              final floatOffset = sin(_floatController.value * pi) * 6.0;
              final tiltAngle = sin(_floatController.value * pi) * 0.05;

              return Transform.translate(
                offset: Offset(0, floatOffset),
                child: Transform.rotate(
                  angle: widget.mood == MascotMood.cheering ? tiltAngle * 3 : tiltAngle,
                  child: _buildPipTheParrot(widget.size),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSpeechBubble(String text) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondaryDark, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
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
