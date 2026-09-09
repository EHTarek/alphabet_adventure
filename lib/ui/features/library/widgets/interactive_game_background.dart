import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:alphabet_adventure/data/services/audio_service.dart';
import 'package:alphabet_adventure/ui/core/app_colors.dart';

/// A joyful, interactive game background for kids.
///
/// Features gentle floating clouds & stars, plus an interactive particle burst
/// effect whenever kids tap on empty background areas.
class InteractiveGameBackground extends StatefulWidget {
  final Widget child;

  const InteractiveGameBackground({
    super.key,
    required this.child,
  });

  @override
  State<InteractiveGameBackground> createState() =>
      _InteractiveGameBackgroundState();
}

class _InteractiveGameBackgroundState extends State<InteractiveGameBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ambientController;
  final List<_TapParticleGroup> _particleGroups = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _ambientController.dispose();
    super.dispose();
  }

  void _handleBackgroundTap(TapDownDetails details) {
    final pos = details.localPosition;
    final audio = context.read<AudioService>();
    audio.playHintSound();

    setState(() {
      _particleGroups.add(
        _TapParticleGroup(
          origin: pos,
          createdAt: DateTime.now(),
          particles: List.generate(8, (i) {
            final angle = (i * (2 * pi / 8)) + (_random.nextDouble() * 0.4);
            final speed = 40.0 + _random.nextDouble() * 60.0;
            final color = [
              AppColors.accentYellow,
              AppColors.secondary,
              AppColors.primary,
              AppColors.accentGreen,
              AppColors.accentPurple,
            ][_random.nextInt(5)];
            final isStar = _random.nextBool();
            return _Particle(
              velocity: Offset(cos(angle) * speed, sin(angle) * speed),
              color: color,
              size: 14.0 + _random.nextDouble() * 12.0,
              isStar: isStar,
            );
          }),
        ),
      );
    });
  }

  void _pruneOldParticles() {
    final now = DateTime.now();
    _particleGroups.removeWhere(
      (g) => now.difference(g.createdAt).inMilliseconds > 900,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // 1. Ambient Gradient Background with Tap Detector
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: _handleBackgroundTap,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [
                          const Color(0xFF1E1E2E),
                          const Color(0xFF27293D),
                          Theme.of(context).scaffoldBackgroundColor,
                        ]
                      : [
                          const Color(0xFFE8F7FF), // Soft Sky Blue
                          const Color(0xFFFFF9E6), // Soft Sunshine Cream
                          const Color(0xFFF3EBFF), // Soft Lavender tint
                        ],
                ),
              ),
            ),
          ),
        ),

        // 2. Animated Ambient Floating Clouds & Decorative Icons
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _ambientController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _AmbientGameElementsPainter(
                    progress: _ambientController.value,
                    isDark: isDark,
                  ),
                );
              },
            ),
          ),
        ),

        // 3. Child Content Layer
        Positioned.fill(child: widget.child),

        // 4. Interactive Tap Particle Rendering Layer (Visual Only, No Touch Blocking)
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _ambientController,
              builder: (context, child) {
                _pruneOldParticles();
                if (_particleGroups.isEmpty) {
                  return const SizedBox.shrink();
                }
                return CustomPaint(
                  painter: _TapParticlePainter(
                    groups: _particleGroups,
                    currentTime: DateTime.now(),
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
  final Offset velocity;
  final Color color;
  final double size;
  final bool isStar;

  _Particle({
    required this.velocity,
    required this.color,
    required this.size,
    required this.isStar,
  });
}

class _TapParticleGroup {
  final Offset origin;
  final DateTime createdAt;
  final List<_Particle> particles;

  _TapParticleGroup({
    required this.origin,
    required this.createdAt,
    required this.particles,
  });
}

class _TapParticlePainter extends CustomPainter {
  final List<_TapParticleGroup> groups;
  final DateTime currentTime;

  _TapParticlePainter({
    required this.groups,
    required this.currentTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final group in groups) {
      final elapsed =
          currentTime.difference(group.createdAt).inMilliseconds / 900.0;
      if (elapsed >= 1.0) continue;

      final opacity = (1.0 - elapsed).clamp(0.0, 1.0);
      final scale = 0.4 + (0.6 * (1.0 - pow(1.0 - elapsed, 2)));

      for (final p in group.particles) {
        final currentPos = group.origin + (p.velocity * elapsed);
        final paint = Paint()
          ..color = p.color.withValues(alpha: opacity * 0.9)
          ..style = PaintingStyle.fill;

        canvas.save();
        canvas.translate(currentPos.dx, currentPos.dy);
        canvas.scale(scale);

        if (p.isStar) {
          _drawStar(canvas, p.size, paint);
        } else {
          canvas.drawCircle(Offset.zero, p.size / 2, paint);
          // Highlight shine
          final shinePaint = Paint()
            ..color = Colors.white.withValues(alpha: opacity * 0.8);
          canvas.drawCircle(
            Offset(-p.size * 0.15, -p.size * 0.15),
            p.size * 0.15,
            shinePaint,
          );
        }
        canvas.restore();
      }
    }
  }

  void _drawStar(Canvas canvas, double size, Paint paint) {
    final path = Path();
    final half = size / 2;
    final quarter = size / 4;

    path.moveTo(0, -half);
    path.lineTo(quarter * 0.4, -quarter * 0.4);
    path.lineTo(half, 0);
    path.lineTo(quarter * 0.4, quarter * 0.4);
    path.lineTo(0, half);
    path.lineTo(-quarter * 0.4, quarter * 0.4);
    path.lineTo(-half, 0);
    path.lineTo(-quarter * 0.4, -quarter * 0.4);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TapParticlePainter oldDelegate) => true;
}

class _AmbientGameElementsPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _AmbientGameElementsPainter({
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cloudPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.white).withValues(
        alpha: isDark ? 0.05 : 0.45,
      )
      ..style = PaintingStyle.fill;

    // Drifting decorative clouds
    final cloudOffset1 = (progress * (size.width + 120)) - 60;
    _drawCloud(canvas, Offset(cloudOffset1 % (size.width + 140) - 70, 70), 50, cloudPaint);

    final cloudOffset2 = ((progress + 0.5) * (size.width + 160)) - 80;
    _drawCloud(canvas, Offset(cloudOffset2 % (size.width + 160) - 80, size.height * 0.45), 40, cloudPaint);

    // Floating subtle sparkle stars
    final starPaint = Paint()
      ..color = (isDark ? AppColors.accentYellow : AppColors.accentYellowDark)
          .withValues(alpha: isDark ? 0.15 : 0.25)
      ..style = PaintingStyle.fill;

    _drawTwinkleStar(
      canvas,
      Offset(size.width * 0.85, 110 + sin(progress * 2 * pi) * 8),
      12 + sin(progress * 4 * pi) * 3,
      starPaint,
    );

    _drawTwinkleStar(
      canvas,
      Offset(size.width * 0.12, size.height * 0.65 + cos(progress * 2 * pi) * 10),
      14 + cos(progress * 4 * pi) * 3,
      starPaint,
    );

    _drawTwinkleStar(
      canvas,
      Offset(size.width * 0.9, size.height * 0.8 + sin(progress * 2 * pi + 1) * 8),
      10 + sin(progress * 4 * pi + 1) * 2,
      starPaint,
    );
  }

  void _drawCloud(Canvas canvas, Offset center, double baseRadius, Paint paint) {
    canvas.drawCircle(center, baseRadius, paint);
    canvas.drawCircle(Offset(center.dx - baseRadius * 0.6, center.dy + baseRadius * 0.2), baseRadius * 0.7, paint);
    canvas.drawCircle(Offset(center.dx + baseRadius * 0.7, center.dy + baseRadius * 0.2), baseRadius * 0.8, paint);
  }

  void _drawTwinkleStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    final r = radius;
    final small = radius * 0.25;

    path.moveTo(center.dx, center.dy - r);
    path.quadraticBezierTo(center.dx, center.dy, center.dx + r, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + r);
    path.quadraticBezierTo(center.dx, center.dy, center.dx - r, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - r);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _AmbientGameElementsPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.isDark != isDark;
}
