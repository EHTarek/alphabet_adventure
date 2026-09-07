import 'dart:math';

import 'package:flutter/material.dart';

import 'package:alphabet_adventure/ui/core/app_colors.dart';

/// Full-screen or localized particle burst celebration animation.
class CelebrationAnimation extends StatefulWidget {
  final Widget? child;
  final bool isPlaying;
  final VoidCallback? onComplete;

  const CelebrationAnimation({
    super.key,
    this.child,
    this.isPlaying = true,
    this.onComplete,
  });

  @override
  State<CelebrationAnimation> createState() => _CelebrationAnimationState();
}

class _CelebrationAnimationState extends State<CelebrationAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    if (widget.isPlaying) {
      _spawnParticles();
      _controller.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(CelebrationAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _spawnParticles();
      _controller.forward(from: 0);
    }
  }

  void _spawnParticles() {
    _particles.clear();
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accentYellow,
      AppColors.accentGreen,
      AppColors.accentPurple,
      AppColors.accentOrange,
    ];

    for (int i = 0; i < 45; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 150.0 + _random.nextDouble() * 300.0;
      final size = 8.0 + _random.nextDouble() * 12.0;
      final color = colors[_random.nextInt(colors.length)];
      final isStar = _random.nextBool();

      _particles.add(_Particle(
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 150.0, // initial upward lift
        color: color,
        size: size,
        isStar: isStar,
        rotationSpeed: (_random.nextDouble() - 0.5) * 8.0,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.child != null) widget.child!,
        if (widget.isPlaying)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _CelebrationPainter(
                      progress: _controller.value,
                      particles: _particles,
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _Particle {
  final double vx;
  final double vy;
  final Color color;
  final double size;
  final bool isStar;
  final double rotationSpeed;

  _Particle({
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.isStar,
    required this.rotationSpeed,
  });
}

class _CelebrationPainter extends CustomPainter {
  final double progress;
  final List<_Particle> particles;

  _CelebrationPainter({
    required this.progress,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final opacity = (1.0 - progress).clamp(0.0, 1.0);
    final gravity = 400.0; // downward acceleration

    for (final p in particles) {
      final t = progress * 1.8;
      final x = center.dx + p.vx * t;
      final y = center.dy + p.vy * t + 0.5 * gravity * t * t;

      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotationSpeed * progress * pi);

      if (p.isStar) {
        _drawStar(canvas, paint, p.size);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.7),
            const Radius.circular(2),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, Paint paint, double size) {
    final path = Path();
    final double innerRadius = size * 0.4;
    final double outerRadius = size;

    for (int i = 0; i < 5; i++) {
      final outerAngle = (i * 72 - 90) * pi / 180;
      final innerAngle = ((i * 72 + 36) - 90) * pi / 180;

      final ox = cos(outerAngle) * outerRadius;
      final oy = sin(outerAngle) * outerRadius;
      final ix = cos(innerAngle) * innerRadius;
      final iy = sin(innerAngle) * innerRadius;

      if (i == 0) {
        path.moveTo(ox, oy);
      } else {
        path.lineTo(ox, oy);
      }
      path.lineTo(ix, iy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CelebrationPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
