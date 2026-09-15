import 'package:flutter/material.dart';

import 'package:alphabet_adventure/ui/core/app_colors.dart';
import 'package:alphabet_adventure/ui/core/wood/wood.dart';

/// Replayable audio button: a round candy button with a speaker icon that
/// gently pulses and sends out rings to invite a tap.
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
    final size = widget.size;
    final colors = WoodToneColors.fromColor(
      widget.backgroundColor,
      Color.lerp(widget.backgroundColor, Colors.black, 0.28)!,
    );

    final button = WoodButton(
      onPressed: widget.onTap,
      colors: colors,
      width: size,
      height: size,
      radius: size / 2,
      depth: size * 0.09,
      rimWidth: (size * 0.05).clamp(2.0, 4.0),
      padding: EdgeInsets.zero,
      semanticLabel: widget.semanticLabel,
      child: Icon(
        Icons.volume_up_rounded,
        color: widget.iconColor,
        size: size * 0.52,
        shadows: [
          Shadow(
            color: colors.bevel.withValues(alpha: 0.7),
            offset: Offset(0, size * 0.03),
          ),
        ],
      ),
    );

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_pulseController.value);
        return CustomPaint(
          painter: _PulseRingPainter(
            progress: _pulseController.value,
            color: colors.highlight,
            faceHeight: size * 0.91,
          ),
          child: Transform.scale(scale: 1.0 + t * 0.05, child: child),
        );
      },
      child: button,
    );
  }
}

/// A soft ring swelling out from behind the button while it waits.
class _PulseRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double faceHeight;

  const _PulseRingPainter({
    required this.progress,
    required this.color,
    required this.faceHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, faceHeight / 2);
    final radius = size.width / 2 * (1.0 + progress * 0.18);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.05
        ..color = color.withValues(alpha: 0.55 * (1 - progress)),
    );
  }

  @override
  bool shouldRepaint(_PulseRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.faceHeight != faceHeight;
}
