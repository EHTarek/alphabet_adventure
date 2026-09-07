import 'package:flutter/material.dart';

import 'package:alphabet_adventure/ui/core/animations/bounce_animation.dart';
import 'package:alphabet_adventure/ui/core/app_colors.dart';

/// Replayable audio button with pulsing ripple effect to encourage audio interaction.
class AudioReplayButton extends StatefulWidget {
  final VoidCallback onTap;
  final double size;
  final Color backgroundColor;
  final Color iconColor;
  final String? semanticLabel;

  const AudioReplayButton({
    super.key,
    required this.onTap,
    this.size = 64.0,
    this.backgroundColor = AppColors.secondary,
    this.iconColor = Colors.white,
    this.semanticLabel = 'Listen again',
  });

  @override
  State<AudioReplayButton> createState() => _AudioReplayButtonState();
}

class _AudioReplayButtonState extends State<AudioReplayButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: BounceAnimation(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale = 1.0 + (_pulseController.value * 0.05);

            return Transform.scale(
              scale: scale,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.backgroundColor,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: widget.backgroundColor.withValues(alpha: 0.45),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.volume_up_rounded,
                    color: widget.iconColor,
                    size: widget.size * 0.55,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
