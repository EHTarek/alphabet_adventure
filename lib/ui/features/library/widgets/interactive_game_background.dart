import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:alphabet_adventure/data/services/audio_service.dart';
import 'package:alphabet_adventure/ui/core/wood/wood.dart';

/// A joyful, interactive game background for kids.
///
/// Transparent over the app-wide blossom scene, with a burst of blossom petals
/// and golden sparkles whenever kids tap on empty background areas.
class InteractiveGameBackground extends StatefulWidget {
  final Widget child;

  const InteractiveGameBackground({super.key, required this.child});

  @override
  State<InteractiveGameBackground> createState() =>
      _InteractiveGameBackgroundState();
}

class _InteractiveGameBackgroundState extends State<InteractiveGameBackground>
    with SingleTickerProviderStateMixin {
  static const _burstMilliseconds = 900;

  /// Petal pinks from the blossom scene, plus warm gold for the sparkles.
  static const _petalColors = [
    Color(0xFFFFC2D4),
    Color(0xFFFF9EBB),
    Color(0xFFFFE0EA),
  ];
  static const _sparkleColors = [WoodColors.goldTop, WoodColors.goldBottom];

  late final AnimationController _particleClock;
  final List<_TapParticleGroup> _particleGroups = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _particleClock = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
  }

  @override
  void dispose() {
    _particleClock.dispose();
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
          particles: List.generate(10, (i) {
            final angle = (i * (2 * pi / 10)) + (_random.nextDouble() * 0.4);
            final speed = 40.0 + _random.nextDouble() * 60.0;
            final isSparkle = i.isOdd;
            final palette = isSparkle ? _sparkleColors : _petalColors;
            return _Particle(
              velocity: Offset(cos(angle) * speed, sin(angle) * speed),
              color: palette[_random.nextInt(palette.length)],
              size: isSparkle
                  ? 16.0 + _random.nextDouble() * 10.0
                  : 15.0 + _random.nextDouble() * 8.0,
              isSparkle: isSparkle,
              spin: (_random.nextDouble() - 0.5) * 6,
              rotation: _random.nextDouble() * 2 * pi,
            );
          }),
        ),
      );
    });
    // The clock only runs while a burst is on screen.
    if (!_particleClock.isAnimating) _particleClock.repeat();
  }

  void _pruneOldParticles() {
    final now = DateTime.now();
    _particleGroups.removeWhere(
      (g) => now.difference(g.createdAt).inMilliseconds > _burstMilliseconds,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Transparent tap detector: the app-wide blossom scene shows through.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: _handleBackgroundTap,
          ),
        ),

        // 2. Child Content Layer
        Positioned.fill(child: widget.child),

        // 3. Interactive Tap Particle Rendering Layer (Visual Only, No Touch Blocking)
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _particleClock,
              builder: (context, child) {
                _pruneOldParticles();
                if (_particleGroups.isEmpty) {
                  if (_particleClock.isAnimating) {
                    // Stop ticking once the last burst has faded out.
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && _particleGroups.isEmpty) {
                        _particleClock.stop();
                      }
                    });
                  }
                  return const SizedBox.shrink();
                }
                return CustomPaint(
                  painter: _TapParticlePainter(
                    groups: _particleGroups,
                    currentTime: DateTime.now(),
                    duration: _burstMilliseconds,
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
  final bool isSparkle;

  /// Turns per burst, so petals tumble as they fly.
  final double spin;
  final double rotation;

  _Particle({
    required this.velocity,
    required this.color,
    required this.size,
    required this.isSparkle,
    required this.spin,
    required this.rotation,
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
  final int duration;

  _TapParticlePainter({
    required this.groups,
    required this.currentTime,
    required this.duration,
  });

  static const _petalEdge = Color(0xFFE0708F);

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..style = PaintingStyle.fill;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    for (final group in groups) {
      final elapsed =
          currentTime.difference(group.createdAt).inMilliseconds / duration;
      if (elapsed >= 1.0) continue;

      final opacity = (1.0 - elapsed).clamp(0.0, 1.0);
      final scale = 0.4 + (0.6 * (1.0 - pow(1.0 - elapsed, 2)));

      for (final p in group.particles) {
        // Petals drift down a little as they slow, like falling blossom.
        final currentPos =
            group.origin +
            (p.velocity * elapsed) +
            Offset(0, p.isSparkle ? 0 : 24 * elapsed * elapsed);

        canvas.save();
        canvas.translate(currentPos.dx, currentPos.dy);
        canvas.rotate(p.rotation + p.spin * elapsed);
        canvas.scale(scale);

        if (p.isSparkle) {
          final path = _sparklePath(p.size);
          stroke
            ..strokeWidth = 2.5
            ..color = WoodColors.goldOutline.withValues(alpha: opacity * 0.9);
          fill.color = p.color.withValues(alpha: opacity);
          canvas
            ..drawPath(path, stroke)
            ..drawPath(path, fill);
        } else {
          final path = _petalPath(p.size);
          stroke
            ..strokeWidth = 1.5
            ..color = _petalEdge.withValues(alpha: opacity * 0.8);
          fill.color = p.color.withValues(alpha: opacity * 0.95);
          canvas
            ..drawPath(path, fill)
            ..drawPath(path, stroke);
        }
        canvas.restore();
      }
    }
  }

  /// A four-pointed twinkle.
  Path _sparklePath(double size) {
    final half = size / 2;
    final waist = size * 0.1;
    return Path()
      ..moveTo(0, -half)
      ..lineTo(waist, -waist)
      ..lineTo(half, 0)
      ..lineTo(waist, waist)
      ..lineTo(0, half)
      ..lineTo(-waist, waist)
      ..lineTo(-half, 0)
      ..lineTo(-waist, -waist)
      ..close();
  }

  /// A cherry-blossom petal: rounded, with a notch at its tip.
  Path _petalPath(double size) {
    final w = size * 0.42;
    final h = size / 2;
    return Path()
      ..moveTo(0, h)
      ..cubicTo(-w * 1.3, h * 0.3, -w, -h, -w * 0.3, -h)
      ..lineTo(0, -h * 0.7)
      ..lineTo(w * 0.3, -h)
      ..cubicTo(w, -h, w * 1.3, h * 0.3, 0, h)
      ..close();
  }

  @override
  bool shouldRepaint(covariant _TapParticlePainter oldDelegate) => true;
}
