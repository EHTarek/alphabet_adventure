import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:alphabet_adventure/core/di/locator.dart';
import 'package:alphabet_adventure/data/services/audio_service.dart';
import 'package:alphabet_adventure/ui/core/wood/wood_palette.dart';

/// Paints a tactile slab: soft drop shadow, a darker bevel underneath, a rim,
/// a gradient face with optional wood grain, and gloss along the top edge.
///
/// The painted face is the widget's size minus [depth] at the bottom, where
/// the bevel shows. [press] (0 to 1) sinks the face into the bevel.
class WoodSurfacePainter extends CustomPainter {
  const WoodSurfacePainter({
    required this.colors,
    required this.radius,
    this.depth = 6,
    this.rimWidth = 3,
    this.press = 0,
    this.shadow = true,
  });

  final WoodToneColors colors;
  final double radius;
  final double depth;
  final double rimWidth;
  final double press;
  final bool shadow;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final sink = depth * 0.75 * press;
    final faceHeight = math.max(0.0, size.height - depth);
    final r = Radius.circular(math.min(radius, faceHeight / 2));
    final base = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, depth, size.width, faceHeight),
      r,
    );
    final face = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, sink, size.width, faceHeight),
      r,
    );

    if (shadow) {
      canvas.drawRRect(
        base.shift(Offset(0, 3 - press * 2)),
        Paint()
          ..color = const Color(0x40000000)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 - press * 3),
      );
    }

    canvas
      ..drawRRect(base, Paint()..color = colors.bevel)
      ..drawRRect(face, Paint()..color = colors.rim);

    final inner = face.deflate(rimWidth);
    canvas.drawRRect(
      inner,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.top, colors.bottom],
        ).createShader(inner.outerRect),
    );

    if (colors.grain) _paintGrain(canvas, inner);

    // Gloss: a bright inner edge along the top, fading out by the middle.
    final gloss = inner.deflate(1.5);
    canvas
      ..save()
      ..clipRRect(inner)
      ..drawRRect(
        gloss,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [colors.highlight, colors.highlight.withValues(alpha: 0)],
          ).createShader(gloss.outerRect),
      )
      // A faint darker band at the bottom of the face adds roundness.
      ..drawRect(
        inner.outerRect,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.center,
            end: Alignment.bottomCenter,
            colors: [Color(0x00000000), Color(0x1A000000)],
          ).createShader(inner.outerRect),
      )
      ..restore();
  }

  /// A few long horizontal fibres, placed from the face size so a surface
  /// always shows the same grain.
  void _paintGrain(Canvas canvas, RRect face) {
    final rect = face.outerRect;
    final random = math.Random(rect.width.round() * 31 + rect.height.round());
    final lines = math.max(3, (rect.height / 9).round());
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas
      ..save()
      ..clipRRect(face);
    for (var i = 0; i < lines; i++) {
      final y =
          rect.top +
          rect.height * (i + 0.5 + random.nextDouble() * 0.5) / lines;
      final amplitude = 0.6 + random.nextDouble() * 1.8;
      final frequency = 0.012 + random.nextDouble() * 0.02;
      final phase = random.nextDouble() * math.pi * 2;
      paint
        ..strokeWidth = 0.6 + random.nextDouble() * 1.1
        ..color = colors.bevel.withValues(
          alpha: 0.07 + random.nextDouble() * 0.08,
        );
      final path = Path()..moveTo(rect.left, y);
      for (var x = rect.left + 8; x <= rect.right + 8; x += 8) {
        path.lineTo(x, y + math.sin(x * frequency + phase) * amplitude);
      }
      canvas.drawPath(path, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(WoodSurfacePainter oldDelegate) {
    return oldDelegate.colors != colors ||
        oldDelegate.radius != radius ||
        oldDelegate.depth != depth ||
        oldDelegate.rimWidth != rimWidth ||
        oldDelegate.press != press ||
        oldDelegate.shadow != shadow;
  }
}

/// A static wooden (or candy) slab holding [child]: cards, panels, plaques.
class WoodPanel extends StatelessWidget {
  const WoodPanel({
    super.key,
    required this.child,
    this.tone = WoodTone.light,
    this.colors,
    this.padding = const EdgeInsets.all(16),
    this.radius = 22,
    this.depth = 6,
    this.rimWidth = 3,
    this.width,
    this.height,
  });

  final Widget child;
  final WoodTone tone;

  /// Overrides [tone] with custom colours.
  final WoodToneColors? colors;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double depth;
  final double rimWidth;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final resolved = colors ?? tone.colors;
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: WoodSurfacePainter(
          colors: resolved,
          radius: radius,
          depth: depth,
          rimWidth: rimWidth,
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: depth),
          child: Padding(
            padding: padding,
            child: DefaultTextStyle.merge(
              style: TextStyle(color: resolved.ink),
              child: IconTheme.merge(
                data: IconThemeData(color: resolved.ink),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A pressable slab: the face sinks into its bevel like a real key, with the
/// app's tap sound. Disabled (dimmed) when [onPressed] is null.
class WoodButton extends StatefulWidget {
  const WoodButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.tone = WoodTone.light,
    this.colors,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    this.radius = 20,
    this.depth = 6,
    this.rimWidth = 3,
    this.width,
    this.height,
    this.playTapSound = true,
    this.semanticLabel,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final WoodTone tone;
  final WoodToneColors? colors;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double depth;
  final double rimWidth;
  final double? width;
  final double? height;
  final bool playTapSound;
  final String? semanticLabel;

  @override
  State<WoodButton> createState() => _WoodButtonState();
}

class _WoodButtonState extends State<WoodButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 70),
    reverseDuration: const Duration(milliseconds: 160),
  );

  bool get _enabled => widget.onPressed != null;

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  void _onTapUp(TapUpDetails _) {
    _press.reverse();
    if (widget.playTapSound && locator.isRegistered<AudioService>()) {
      locator<AudioService>().playTap();
    }
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ?? widget.tone.colors;
    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _enabled ? (_) => _press.forward() : null,
        onTapUp: _enabled ? _onTapUp : null,
        onTapCancel: _enabled ? _press.reverse : null,
        child: Opacity(
          opacity: _enabled ? 1 : 0.55,
          child: AnimatedBuilder(
            animation: _press,
            builder: (context, child) {
              final press = Curves.easeOut.transform(_press.value);
              return CustomPaint(
                painter: WoodSurfacePainter(
                  colors: colors,
                  radius: widget.radius,
                  depth: widget.depth,
                  rimWidth: widget.rimWidth,
                  press: press,
                ),
                child: Transform.translate(
                  offset: Offset(0, widget.depth * 0.75 * press),
                  child: child,
                ),
              );
            },
            child: SizedBox(
              width: widget.width,
              height: widget.height,
              child: Padding(
                padding: EdgeInsets.only(bottom: widget.depth),
                child: Padding(
                  padding: widget.padding,
                  child: DefaultTextStyle.merge(
                    style: TextStyle(color: colors.ink),
                    child: IconTheme.merge(
                      data: IconThemeData(color: colors.ink),
                      child: Center(
                        widthFactor: 1,
                        heightFactor: 1,
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A square wooden button holding one icon (settings, back, home, close).
class WoodIconButton extends StatelessWidget {
  const WoodIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tone = WoodTone.light,
    this.size = 52,
    this.iconSize,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final WoodTone tone;
  final double size;
  final double? iconSize;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = WoodButton(
      onPressed: onPressed,
      tone: tone,
      width: size,
      height: size,
      radius: size * 0.3,
      depth: size * 0.1,
      padding: EdgeInsets.zero,
      semanticLabel: tooltip,
      child: Icon(icon, size: iconSize ?? size * 0.5),
    );
    return tooltip == null ? button : Tooltip(message: tooltip, child: button);
  }
}
