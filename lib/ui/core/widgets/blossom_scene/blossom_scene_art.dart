import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import 'package:alphabet_adventure/ui/core/widgets/blossom_scene/scene_particles.dart';

/// Every static picture in the blossom scene, painted procedurally once per
/// scene size and rasterised to GPU images.
///
/// Per frame the scene then only transforms a handful of textured quads,
/// which keeps it cheap no matter how much detail the art has. All rects are
/// in scene (logical pixel) coordinates.
class BlossomSceneArt {
  BlossomSceneArt._({
    required this.size,
    required this.devicePixelRatio,
    required this.background,
    required this.backgroundRect,
    required this.light,
    required this.lightRect,
    required this.tree,
    required this.treeShadow,
    required this.treeRect,
    required this.treePivot,
    required this.frontBranch,
    required this.frontBranchShadow,
    required this.frontBranchRect,
    required this.frontBranchPivot,
    required this.sprites,
    required this.spriteScale,
    required this.canopyPoints,
  });

  /// Fixed seed so a rebuilt scene (after a resize) looks the same.
  static const int _seed = 20260915;

  /// How far layers are painted past the screen edges so parallax travel and
  /// perspective rotation never reveal an edge.
  static const double bleed = 28;

  /// Logical size of one sprite atlas cell, and the particle half-length a
  /// sprite is painted at inside it.
  static const double spriteCell = 36;
  static const double spriteRadius = 11;
  static const int _petalTones = 3;
  static const int _leafTones = 2;

  final Size size;
  final double devicePixelRatio;

  final ui.Image background;
  final Rect backgroundRect;
  final ui.Image light;
  final Rect lightRect;

  final ui.Image tree;
  final ui.Image treeShadow;
  final Rect treeRect;

  /// Where the main tree's limbs enter the scene; it rotates about this point.
  final Offset treePivot;

  final ui.Image frontBranch;
  final ui.Image frontBranchShadow;
  final Rect frontBranchRect;
  final Offset frontBranchPivot;

  final ui.Image sprites;
  final double spriteScale;

  /// Blossom cluster centres that falling petals can detach from.
  final List<Offset> canopyPoints;

  static BlossomSceneArt build(Size size, double devicePixelRatio) {
    final random = math.Random(_seed);
    final w = size.width;
    final h = size.height;
    // Tree proportions follow the width on phones but stop growing on wide,
    // short layouts so the canopy never swallows the screen.
    final unit = math.min(w, h * 0.55);

    final backgroundRect = Rect.fromLTWH(
      -bleed,
      -bleed,
      w + bleed * 2,
      h + bleed * 2,
    );
    final background = _rasterize(
      backgroundRect,
      math.min(devicePixelRatio, 1.5),
      (canvas) => _paintWood(canvas, backgroundRect, random),
    );
    final light = _rasterize(
      backgroundRect,
      0.35,
      (canvas) => _paintLight(canvas, backgroundRect),
    );

    // Main tree: two limbs entering from the left edge.
    final treeGrower = _BranchGrower(random, flowerRadius: unit * 0.03);
    final treePivot = Offset(0, h * 0.17);
    treeGrower
      ..grow(
        Offset(-bleed, h * 0.13),
        -0.32,
        unit * 0.3,
        unit * 0.055,
        4,
        baseAngle: -0.2,
      )
      ..grow(
        Offset(-bleed, h * 0.23),
        0.14,
        unit * 0.22,
        unit * 0.04,
        3,
        baseAngle: 0.2,
      );

    // Front branch: a lighter sprig reaching in from the top-right corner.
    final frontGrower = _BranchGrower(random, flowerRadius: unit * 0.036);
    final frontBranchPivot = Offset(w, h * 0.02);
    frontGrower.grow(
      Offset(w + bleed, h * 0.02),
      math.pi - 0.5,
      unit * 0.2,
      unit * 0.034,
      3,
      baseAngle: math.pi - 0.55,
    );

    final scale = math.min(devicePixelRatio, 2.5);
    final limit = Rect.fromLTRB(
      -bleed - 12,
      -bleed - 12,
      w + bleed + 12,
      h * 0.7,
    );

    final treeRect = treeGrower.bounds().inflate(30).intersect(limit);
    final tree = _rasterize(treeRect, scale, treeGrower.paint);
    final frontBranchRect = frontGrower.bounds().inflate(40).intersect(limit);
    final frontBranch = _rasterize(frontBranchRect, scale, frontGrower.paint);

    final sprites = _paintSprites(math.min(devicePixelRatio, 3.0));

    return BlossomSceneArt._(
      size: size,
      devicePixelRatio: devicePixelRatio,
      background: background,
      backgroundRect: backgroundRect,
      light: light,
      lightRect: backgroundRect,
      tree: tree,
      treeShadow: _shadowOf(tree, 6 * scale),
      treeRect: treeRect,
      treePivot: treePivot,
      frontBranch: frontBranch,
      frontBranchShadow: _shadowOf(frontBranch, 10 * scale),
      frontBranchRect: frontBranchRect,
      frontBranchPivot: frontBranchPivot,
      sprites: sprites.image,
      spriteScale: sprites.scale,
      canopyPoints: [
        ...treeGrower.clusters,
        ...frontGrower.clusters,
      ].where((p) => p.dx > 0 && p.dx < w && p.dy > 0).toList(growable: false),
    );
  }

  /// Source rect in [sprites] for a particle of this kind.
  Rect spriteSource(SceneParticle particle, {required bool back}) {
    final kindRow = particle.isLeaf
        ? _petalTones + particle.tone
        : particle.tone;
    final row = kindRow * 2 + (back ? 1 : 0);
    final column = switch (particle.band) {
      SceneDepthBand.mid => 0,
      SceneDepthBand.far => 1,
      SceneDepthBand.near => 2,
    };
    final cell = spriteCell * spriteScale;
    return Rect.fromLTWH(column * cell, row * cell, cell, cell);
  }

  void dispose() {
    background.dispose();
    light.dispose();
    tree.dispose();
    treeShadow.dispose();
    frontBranch.dispose();
    frontBranchShadow.dispose();
    sprites.dispose();
  }

  // ---------------------------------------------------------------------------
  // Rasterisation helpers
  // ---------------------------------------------------------------------------

  static ui.Image _rasterize(
    Rect rect,
    double scale,
    void Function(Canvas canvas) paint,
  ) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)
      ..scale(scale)
      ..translate(-rect.left, -rect.top);
    paint(canvas);
    final picture = recorder.endRecording();
    final image = picture.toImageSync(
      math.max(1, (rect.width * scale).ceil()),
      math.max(1, (rect.height * scale).ceil()),
    );
    picture.dispose();
    return image;
  }

  /// A soft, warm-dark silhouette of [source] to cast onto the wood.
  static ui.Image _shadowOf(ui.Image source, double sigma) {
    final recorder = ui.PictureRecorder();
    Canvas(recorder).drawImage(
      source,
      Offset.zero,
      Paint()
        ..colorFilter = const ColorFilter.mode(
          Color(0xFF2B1206),
          BlendMode.srcIn,
        )
        ..imageFilter = ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
    );
    final picture = recorder.endRecording();
    final image = picture.toImageSync(source.width, source.height);
    picture.dispose();
    return image;
  }

  // ---------------------------------------------------------------------------
  // Wood
  // ---------------------------------------------------------------------------

  static void _paintWood(Canvas canvas, Rect rect, math.Random random) {
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          rect.topCenter,
          rect.bottomCenter,
          const [Color(0xFFD59C5F), Color(0xFFC88C50), Color(0xFFB77A42)],
          const [0, 0.55, 1],
        ),
    );

    // Long vertical grain, each fibre wandering slightly.
    final grainCount = (rect.width / 5).round();
    final grain = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < grainCount; i++) {
      final x0 =
          rect.left + rect.width * (i + random.nextDouble()) / grainCount;
      final amplitude = 1 + random.nextDouble() * 5;
      final frequency = 0.003 + random.nextDouble() * 0.008;
      final phase = random.nextDouble() * math.pi * 2;
      final lightFibre = random.nextDouble() < 0.25;
      grain
        ..strokeWidth = 0.5 + random.nextDouble() * 1.8
        ..color =
            (lightFibre ? const Color(0xFFF0C48E) : const Color(0xFF7C4722))
                .withValues(
                  alpha:
                      0.03 + random.nextDouble() * (lightFibre ? 0.06 : 0.09),
                );
      final path = Path()..moveTo(x0 + math.sin(phase) * amplitude, rect.top);
      for (var y = rect.top + 14; y <= rect.bottom + 14; y += 14) {
        path.lineTo(
          x0 +
              math.sin(y * frequency + phase) * amplitude +
              math.sin(y * frequency * 2.7 + phase * 1.3) * amplitude * 0.35,
          y,
        );
      }
      canvas.drawPath(path, grain);
    }

    // A few soft cathedral figures, like the heart of a sawn board.
    final figure = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0xFF7C4722).withValues(alpha: 0.05);
    for (var k = 0; k < 3; k++) {
      final centre = Offset(
        rect.left + rect.width * (0.2 + 0.3 * k + random.nextDouble() * 0.1),
        rect.top + rect.height * (0.3 + random.nextDouble() * 0.5),
      );
      for (var ring = 1; ring <= 6; ring++) {
        canvas.drawOval(
          Rect.fromCenter(
            center: centre.translate(0, ring * 6.0),
            width: 8.0 + ring * 9,
            height: 60.0 + ring * 55,
          ),
          figure,
        );
      }
    }

    // Warm light pooling at the top-left, darker edges and bottom.
    canvas
      ..drawRect(
        rect,
        Paint()
          ..shader = ui.Gradient.radial(
            Offset(rect.left + rect.width * 0.2, rect.top + rect.height * 0.08),
            rect.height * 0.75,
            const [Color(0x40FFE3B0), Color(0x00FFE3B0)],
          ),
      )
      ..drawRect(
        rect,
        Paint()
          ..shader = ui.Gradient.radial(
            rect.center,
            math.max(rect.width, rect.height) * 0.72,
            const [Color(0x00000000), Color(0x00000000), Color(0x38301404)],
            const [0, 0.6, 1],
          ),
      );
  }

  /// Soft diagonal sunbeams, painted at low resolution since they are blurry.
  static void _paintLight(Canvas canvas, Rect rect) {
    final w = rect.width;
    final h = rect.height;
    const beams = [(0.02, 0.10, 90.0), (0.22, 0.16, 55.0), (0.40, 0.08, 120.0)];
    for (final (startX, alpha, width) in beams) {
      final start = Offset(rect.left + w * startX, rect.top - h * 0.05);
      final end = start + Offset(h * 0.55, h * 0.95);
      final direction = (end - start) / (end - start).distance;
      final normal = Offset(-direction.dy, direction.dx) * (width / 2);
      final path = Path()
        ..addPolygon([
          start + normal * 0.6,
          end + normal * 1.6,
          end - normal * 1.6,
          start - normal * 0.6,
        ], true);
      canvas.drawPath(
        path,
        Paint()
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22)
          ..shader = ui.Gradient.linear(start, end, [
            const Color(0xFFFFF4DC).withValues(alpha: alpha),
            const Color(0x00FFF4DC),
          ]),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Particle sprites
  // ---------------------------------------------------------------------------

  /// Rows: each petal tone front/back, then each leaf tone front/back.
  /// Columns: sharp (mid), soft (far), out of focus (near). Blur radii are in
  /// sprite space; far sprites are drawn smaller, near ones larger.
  static ({ui.Image image, double scale}) _paintSprites(double scale) {
    const blurs = [0.0, 2.0, 1.8];
    const rows = (_petalTones + _leafTones) * 2;
    final rect = Rect.fromLTWH(
      0,
      0,
      spriteCell * blurs.length,
      spriteCell * rows,
    );
    final image = _rasterize(rect, scale, (canvas) {
      for (var row = 0; row < rows; row++) {
        final kindRow = row ~/ 2;
        final back = row.isOdd;
        for (var column = 0; column < blurs.length; column++) {
          canvas
            ..save()
            ..translate(
              column * spriteCell + spriteCell / 2,
              row * spriteCell + spriteCell / 2,
            );
          final blur = blurs[column] == 0
              ? null
              : MaskFilter.blur(BlurStyle.normal, blurs[column]);
          if (kindRow < _petalTones) {
            _paintPetalSprite(canvas, kindRow, back: back, blur: blur);
          } else {
            _paintLeafSprite(
              canvas,
              kindRow - _petalTones,
              back: back,
              blur: blur,
            );
          }
          canvas.restore();
        }
      }
    });
    return (image: image, scale: scale);
  }

  static void _paintPetalSprite(
    Canvas canvas,
    int tone, {
    required bool back,
    MaskFilter? blur,
  }) {
    const r = spriteRadius;
    const fronts = [
      (Color(0xFFF08DB2), Color(0xFFFFEFF4)),
      (Color(0xFFE9759F), Color(0xFFFDD8E4)),
      (Color(0xFFF6A9C4), Color(0xFFFFF8FA)),
    ];
    final (baseColor, tipColor) = fronts[tone];
    final path = _petalPath(r);
    canvas.drawPath(
      path,
      Paint()
        ..maskFilter = blur
        ..shader = ui.Gradient.linear(
          const Offset(0, r),
          const Offset(0, -r),
          back
              ? [
                  Color.lerp(baseColor, const Color(0xFFFFFFFF), 0.45)!,
                  const Color(0xFFFFFFFF),
                ]
              : [baseColor, tipColor],
        ),
    );
    if (blur == null) {
      canvas.drawLine(
        const Offset(0, r * 0.85),
        const Offset(0, -r * 0.55),
        Paint()
          ..strokeWidth = 0.5
          ..color = baseColor.withValues(alpha: back ? 0.35 : 0.2),
      );
    }
  }

  static void _paintLeafSprite(
    Canvas canvas,
    int tone, {
    required bool back,
    MaskFilter? blur,
  }) {
    const r = spriteRadius;
    const tones = [
      (Color(0xFF6FA83E), Color(0xFFB4D86B), Color(0xFF4F7F2A)),
      (Color(0xFFB9A043), Color(0xFFE1D27F), Color(0xFF8C7429)),
    ];
    final (base, tip, rib) = tones[tone];
    canvas.drawPath(
      _leafPath(r),
      Paint()
        ..maskFilter = blur
        ..shader = ui.Gradient.linear(
          const Offset(0, r),
          const Offset(0, -r),
          back
              ? [
                  Color.lerp(base, const Color(0xFFFFFFFF), 0.3)!,
                  Color.lerp(tip, const Color(0xFFFFFFFF), 0.3)!,
                ]
              : [base, tip],
        ),
    );
    if (blur == null) {
      canvas.drawLine(
        const Offset(0, r * 0.95),
        const Offset(0, -r * 0.8),
        Paint()
          ..strokeWidth = 0.7
          ..color = rib.withValues(alpha: back ? 0.35 : 0.6),
      );
    }
  }

  /// A cherry petal pointing up, notched at the tip, [r] from centre to tip.
  static Path _petalPath(double r) {
    return Path()
      ..moveTo(0, r)
      ..cubicTo(-r * 0.75, r * 0.55, -r * 0.8, -r * 0.55, -r * 0.28, -r * 0.95)
      ..quadraticBezierTo(-r * 0.1, -r * 1.0, 0, -r * 0.8)
      ..quadraticBezierTo(r * 0.1, -r * 1.0, r * 0.28, -r * 0.95)
      ..cubicTo(r * 0.8, -r * 0.55, r * 0.75, r * 0.55, 0, r)
      ..close();
  }

  static Path _leafPath(double r) {
    return Path()
      ..moveTo(0, r)
      ..cubicTo(-r * 0.62, r * 0.35, -r * 0.5, -r * 0.6, 0, -r)
      ..cubicTo(r * 0.5, -r * 0.6, r * 0.62, r * 0.35, 0, r)
      ..close();
  }
}

// -----------------------------------------------------------------------------
// Procedural cherry-blossom branches
// -----------------------------------------------------------------------------

class _Segment {
  const _Segment(
    this.start,
    this.control,
    this.end,
    this.startWidth,
    this.endWidth,
  );

  final Offset start;
  final Offset control;
  final Offset end;
  final double startWidth;
  final double endWidth;

  Offset at(double t) {
    final u = 1 - t;
    return start * (u * u) + control * (2 * u * t) + end * (t * t);
  }

  Offset normalAt(double t) {
    final d = (control - start) * (2 * (1 - t)) + (end - control) * (2 * t);
    final length = d.distance;
    if (length < 1e-6) return const Offset(0, -1);
    return Offset(-d.dy / length, d.dx / length);
  }

  double widthAt(double t) => startWidth + (endWidth - startWidth) * t;
}

class _Flower {
  const _Flower({
    required this.center,
    required this.radius,
    required this.rotation,
    required this.squash,
    required this.tone,
    required this.isBud,
  });

  final Offset center;
  final double radius;
  final double rotation;

  /// Vertical scale that makes a flower look turned away from the viewer.
  final double squash;
  final int tone;
  final bool isBud;
}

class _Leaf {
  const _Leaf(this.center, this.length, this.rotation);

  final Offset center;
  final double length;
  final double rotation;
}

/// Grows a zig-zagging cherry branch with blossom clusters, then paints it.
class _BranchGrower {
  _BranchGrower(this.random, {required this.flowerRadius});

  final math.Random random;
  final double flowerRadius;
  final List<_Segment> segments = [];
  final List<_Flower> flowers = [];
  final List<_Leaf> leaves = [];
  final List<Offset> clusters = [];

  static const _light = Offset(-0.6, -0.8);

  /// Grows a limb from [from] heading [angle] (radians, screen space). Every
  /// sub-branch stays within about 70 degrees of [baseAngle] so the branch
  /// keeps its overall direction.
  void grow(
    Offset from,
    double angle,
    double length,
    double width,
    int depth, {
    required double baseAngle,
  }) {
    final heading = angle.clamp(baseAngle - 1.25, baseAngle + 1.25);
    final direction = Offset(math.cos(heading), math.sin(heading));
    final to = from + direction * length;
    final bend = (random.nextDouble() - 0.5) * length * 0.35;
    final control =
        Offset.lerp(from, to, 0.5)! +
        Offset(-direction.dy, direction.dx) * bend;
    final endWidth = width * 0.62;
    final segment = _Segment(from, control, to, width, endWidth);
    segments.add(segment);

    if (depth <= 0 || endWidth < 1.4) {
      _cluster(to, 3 + random.nextInt(4));
      return;
    }

    // Thin twigs carry blossoms along their length, not just at the tip.
    if (width < flowerRadius * 0.9) {
      for (final t in const [0.45, 0.85]) {
        if (random.nextDouble() < 0.6) {
          _cluster(segment.at(t), 1 + random.nextInt(3));
        }
      }
    }

    grow(
      to,
      heading + (random.nextDouble() - 0.5) * 0.6,
      length * 0.78,
      endWidth,
      depth - 1,
      baseAngle: baseAngle,
    );

    final sideBranches = random.nextDouble() < 0.7 ? 1 : 2;
    for (var i = 0; i < sideBranches; i++) {
      // Favour branches that droop into view over ones that leave the screen.
      final side = random.nextDouble() < 0.62 ? 1.0 : -1.0;
      final towardsScreen = math.cos(baseAngle) >= 0 ? side : -side;
      grow(
        segment.at(0.55 + random.nextDouble() * 0.4),
        heading + towardsScreen * (0.45 + random.nextDouble() * 0.5),
        length * (0.5 + random.nextDouble() * 0.2),
        endWidth * 0.75,
        depth - 1 - (random.nextDouble() < 0.4 ? 1 : 0),
        baseAngle: baseAngle,
      );
    }
  }

  void _cluster(Offset at, int count) {
    clusters.add(at);
    for (var i = 0; i < count; i++) {
      final angle = random.nextDouble() * math.pi * 2;
      final distance = random.nextDouble() * flowerRadius * 1.6;
      flowers.add(
        _Flower(
          center: at + Offset(math.cos(angle), math.sin(angle)) * distance,
          radius: flowerRadius * (0.7 + random.nextDouble() * 0.45),
          rotation: random.nextDouble() * math.pi * 2,
          squash: 0.72 + random.nextDouble() * 0.28,
          tone: random.nextInt(3),
          isBud: random.nextDouble() < 0.18,
        ),
      );
    }
    if (random.nextDouble() < 0.3) {
      final angle = random.nextDouble() * math.pi * 2;
      leaves.add(
        _Leaf(
          at + Offset(math.cos(angle), math.sin(angle)) * flowerRadius * 1.4,
          flowerRadius * 0.9,
          angle + math.pi / 2,
        ),
      );
    }
  }

  Rect bounds() {
    var rect = Rect.fromPoints(segments.first.start, segments.first.end);
    for (final s in segments) {
      final pad = s.startWidth;
      rect = rect
          .expandToInclude(Rect.fromCircle(center: s.start, radius: pad))
          .expandToInclude(Rect.fromCircle(center: s.control, radius: pad))
          .expandToInclude(Rect.fromCircle(center: s.end, radius: pad));
    }
    for (final f in flowers) {
      rect = rect.expandToInclude(
        Rect.fromCircle(center: f.center, radius: f.radius * 1.2),
      );
    }
    return rect;
  }

  void paint(Canvas canvas) {
    _paintBark(canvas);
    for (final leaf in leaves) {
      _paintLeaf(canvas, leaf);
    }
    _paintFlowerShadows(canvas);
    for (final flower in flowers.where((f) => f.isBud)) {
      _paintBud(canvas, flower);
    }
    for (final flower in flowers.where((f) => !f.isBud)) {
      _paintFlower(canvas, flower);
    }
  }

  void _paintBark(Canvas canvas) {
    const steps = 10;
    final fill = Paint()..color = const Color(0xFF5B3326);
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF3A1F17);
    final highlight = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF93604A).withValues(alpha: 0.7);
    final ridge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = const Color(0xFF3A1F17).withValues(alpha: 0.35);

    final outlines = <Path>[];
    for (final s in segments) {
      final left = <Offset>[];
      final right = <Offset>[];
      for (var i = 0; i <= steps; i++) {
        final t = i / steps;
        final p = s.at(t);
        final n = s.normalAt(t) * (s.widthAt(t) / 2);
        left.add(p + n);
        right.add(p - n);
      }
      outlines.add(Path()..addPolygon([...left, ...right.reversed], true));
    }

    for (var i = 0; i < segments.length; i++) {
      canvas.drawPath(outlines[i], edge);
    }
    for (var i = 0; i < segments.length; i++) {
      final s = segments[i];
      canvas
        ..drawPath(outlines[i], fill)
        ..drawCircle(s.start, s.startWidth / 2, fill)
        ..drawCircle(s.end, s.endWidth / 2, fill);
    }

    for (final s in segments) {
      // A lit ribbon along the side facing the light.
      final towardsLight =
          s.normalAt(0.5).dx * _light.dx + s.normalAt(0.5).dy * _light.dy >= 0
          ? 1.0
          : -1.0;
      final lit = Path();
      final ridges = [Path(), Path()];
      final ridgeOffsets = [
        (random.nextDouble() - 0.5) * 0.5,
        (random.nextDouble() - 0.5) * 0.5,
      ];
      for (var i = 0; i <= steps; i++) {
        final t = i / steps;
        final p = s.at(t);
        final n = s.normalAt(t);
        final halfWidth = s.widthAt(t) / 2;
        final litPoint = p + n * (towardsLight * halfWidth * 0.45);
        i == 0
            ? lit.moveTo(litPoint.dx, litPoint.dy)
            : lit.lineTo(litPoint.dx, litPoint.dy);
        for (var r = 0; r < 2; r++) {
          final ridgePoint = p + n * (ridgeOffsets[r] * halfWidth * 2);
          i == 0
              ? ridges[r].moveTo(ridgePoint.dx, ridgePoint.dy)
              : ridges[r].lineTo(ridgePoint.dx, ridgePoint.dy);
        }
      }
      highlight.strokeWidth = (s.startWidth + s.endWidth) * 0.12;
      canvas.drawPath(lit, highlight);
      if (s.startWidth > 6) {
        for (final path in ridges) {
          canvas.drawPath(path, ridge);
        }
      }
    }
  }

  void _paintLeaf(Canvas canvas, _Leaf leaf) {
    final r = leaf.length;
    canvas
      ..save()
      ..translate(leaf.center.dx, leaf.center.dy)
      ..rotate(leaf.rotation)
      ..drawPath(
        BlossomSceneArt._leafPath(r),
        Paint()
          ..shader = ui.Gradient.linear(Offset(0, r), Offset(0, -r), const [
            Color(0xFF5E9A35),
            Color(0xFFA9D36A),
          ]),
      )
      ..drawLine(
        Offset(0, r * 0.9),
        Offset(0, -r * 0.7),
        Paint()
          ..strokeWidth = r * 0.06
          ..color = const Color(0xFF3F6E22).withValues(alpha: 0.6),
      )
      ..restore();
  }

  /// One blurred layer of soft contact shadows, so blossoms sit above the bark.
  void _paintFlowerShadows(Canvas canvas) {
    final shadow = Paint()..color = const Color(0x66401818);
    canvas.saveLayer(
      null,
      Paint()
        ..imageFilter = ui.ImageFilter.blur(
          sigmaX: flowerRadius * 0.3,
          sigmaY: flowerRadius * 0.3,
        ),
    );
    for (final f in flowers) {
      canvas.drawCircle(
        f.center + Offset(f.radius * 0.15, f.radius * 0.3),
        f.radius * (f.isBud ? 0.45 : 0.85),
        shadow,
      );
    }
    canvas.restore();
  }

  static const _blossomTones = [
    [Color(0xFFE56B97), Color(0xFFF7B6CC), Color(0xFFFFF0F5)],
    [Color(0xFFDD5A8A), Color(0xFFF4A3BF), Color(0xFFFFE3EC)],
    [Color(0xFFEA86A8), Color(0xFFFAC7D7), Color(0xFFFFF7FA)],
  ];

  void _paintFlower(Canvas canvas, _Flower f) {
    final r = f.radius;
    final tones = _blossomTones[f.tone];
    final petal = BlossomSceneArt._petalPath(
      r * 0.5,
    ).shift(Offset(0, -r * 0.5));
    final petalPaint = Paint()
      ..shader = ui.Gradient.radial(Offset.zero, r, tones, const [0, 0.38, 1]);
    final petalEdge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.035
      ..color = tones[0].withValues(alpha: 0.35);

    canvas
      ..save()
      ..translate(f.center.dx, f.center.dy)
      ..rotate(f.rotation)
      ..scale(1, f.squash);
    for (var i = 0; i < 5; i++) {
      canvas
        ..drawPath(petal, petalPaint)
        ..drawPath(petal, petalEdge)
        ..rotate(math.pi * 2 / 5);
    }

    // Deep pink heart with a ring of stamens.
    canvas.drawCircle(
      Offset.zero,
      r * 0.2,
      Paint()..color = const Color(0xFFCC3F6E),
    );
    final filament = Paint()
      ..strokeWidth = r * 0.035
      ..color = const Color(0xFFC23766);
    final anther = Paint()..color = const Color(0xFFF6CF6E);
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi * 2 / 8 + 0.2;
      final tip =
          Offset(math.cos(angle), math.sin(angle)) *
          (r * (0.38 + (i % 2) * 0.08));
      canvas
        ..drawLine(Offset.zero, tip, filament)
        ..drawCircle(tip, r * 0.055, anther);
    }
    canvas.restore();
  }

  void _paintBud(Canvas canvas, _Flower f) {
    final r = f.radius * 0.45;
    canvas
      ..save()
      ..translate(f.center.dx, f.center.dy)
      ..rotate(f.rotation)
      ..drawOval(
        Rect.fromCenter(center: Offset.zero, width: r * 1.3, height: r * 1.9),
        Paint()
          ..shader = ui.Gradient.radial(
            Offset(-r * 0.2, -r * 0.4),
            r * 1.2,
            const [Color(0xFFF7A1BF), Color(0xFFD9477A)],
          ),
      )
      ..drawPath(
        Path()
          ..moveTo(-r * 0.5, r * 0.6)
          ..quadraticBezierTo(0, r * 0.2, r * 0.5, r * 0.6)
          ..lineTo(0, r * 1.3)
          ..close(),
        Paint()..color = const Color(0xFF6B2E2A),
      )
      ..restore();
  }
}
