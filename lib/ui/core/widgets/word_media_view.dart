import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart' as vm;

import 'package:alphabet_adventure/data/models/word_data.dart';
import 'package:alphabet_adventure/ui/core/app_colors.dart';
import 'package:alphabet_adventure/ui/core/app_fonts.dart';

/// Shows a word's real example: a spinnable 3D object, an animated GIF /
/// picture, or — until an asset is bundled for it — its emoji.
///
/// The choice comes from [WordData.mediaKind]. The 3D stage shows the emoji as
/// a placeholder while the model loads, and falls back to it for good if the
/// model fails to load.
class WordMediaView extends StatelessWidget {
  final WordData word;

  const WordMediaView({super.key, required this.word});

  /// Test seam: widget tests have no GPU to render a scene on, so they swap the
  /// 3D stage for a stand-in. Leave null in the app.
  @visibleForTesting
  static Widget Function(WordData word)? debugModelStageBuilder;

  @override
  Widget build(BuildContext context) {
    switch (word.mediaKind) {
      case WordMediaKind.model:
        final override = debugModelStageBuilder;
        if (override != null) return override(word);
        return _ModelStage(word: word);
      case WordMediaKind.image:
        return _ImageStage(word: word);
      case WordMediaKind.emoji:
        return _EmojiStage(word: word);
    }
  }
}

/// Interactive 3D object rendered with flutter_scene (Impeller / Flutter GPU).
///
/// The object is framed automatically from its bounds, slowly orbits, plays
/// any animation it carries (the fox looks around), and a child can drag to
/// spin it. There is no zoom or pan, so a small hand cannot push it out of
/// frame.
class _ModelStage extends StatefulWidget {
  final WordData word;

  const _ModelStage({required this.word});

  @override
  State<_ModelStage> createState() => _ModelStageState();
}

class _ModelStageState extends State<_ModelStage> {
  /// Idle orbit speed, radians per second.
  static const _autoSpin = 0.6;

  /// Camera elevation above the object's equator, radians.
  static const _pitch = 0.35;

  final Scene _scene = Scene();
  vm.Aabb3? _bounds;
  bool _failed = false;

  /// Extra yaw from the child's drags, on top of the idle spin. Starts at
  /// half a turn so the camera opens on the +Z side, which is the front of a
  /// glTF model.
  double _dragYaw = math.pi;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final asset = widget.word.modelAsset!;
    try {
      await Scene.initializeStaticResources();
      final node = await Node.fromGlbAsset(asset);
      // Clips blend together when played at once, so run just one: the idle
      // loop where the model has one, otherwise its first animation.
      final animations = node.parsedAnimations;
      if (animations.isNotEmpty) {
        final idle = animations.firstWhere(
          (a) => a.name.toLowerCase() == 'idle',
          orElse: () => animations.first,
        );
        node.createAnimationClip(idle)
          ..loop = true
          ..play();
      }
      _scene.add(node);
      // Skinned meshes report no runtime bounds; fall back to the rest pose
      // stored in the file.
      final bounds = _worldBounds(node) ?? await _glbPositionBounds(asset);
      if (!mounted) return;
      setState(() {
        if (bounds == null) {
          _failed = true;
        } else {
          _bounds = bounds;
        }
      });
    } catch (error, stack) {
      debugPrint('3D model failed for ${widget.word.wordId}: $error\n$stack');
      if (mounted) setState(() => _failed = true);
    }
  }

  /// World-space box around every mesh under [node], in the rest pose.
  static vm.Aabb3? _worldBounds(Node node) {
    vm.Aabb3? result;
    void visit(Node n) {
      final local = n.mesh?.localBounds;
      if (local != null) {
        final world = vm.Aabb3.copy(local)..transform(n.globalTransform);
        if (result == null) {
          result = world;
        } else {
          result!.hull(world);
        }
      }
      n.children.forEach(visit);
    }

    visit(node);
    return result;
  }

  static Future<vm.Aabb3?> _glbPositionBounds(String asset) async {
    final data = await rootBundle.load(asset);
    return glbPositionBounds(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
  }

  /// A camera looking at the object's centre from [direction], far enough
  /// back that its bounding sphere fits the vertical field of view.
  Camera _cameraFor(Duration elapsed) {
    final bounds = _bounds!;
    final yaw = _dragYaw + elapsed.inMicroseconds / 1e6 * _autoSpin;
    final direction = vm.Vector3(
      math.sin(yaw) * math.cos(_pitch),
      math.sin(_pitch),
      -math.cos(yaw) * math.cos(_pitch),
    );
    const fov = 45 * math.pi / 180;
    final center = bounds.center;
    final radius = math.max((bounds.max - bounds.min).length * 0.5, 1e-4);
    // The bounding sphere over-estimates most objects, so pull in a little
    // so they fill the stage.
    final distance = radius / math.sin(fov / 2) * 0.9;
    return PerspectiveCamera(
      fovRadiansY: fov,
      position: center + direction * distance,
      target: center,
      fovNear: math.max(distance - radius, distance * 1e-3),
      fovFar: distance + radius * 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) return _EmojiStage(word: widget.word);

    if (_bounds == null) {
      return _EmojiStage(word: widget.word, showLoading: true);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragUpdate: (details) => _dragYaw += details.delta.dx * 0.012,
      child: SizedBox.expand(
        child: _SceneCanvas(scene: _scene, cameraFor: _cameraFor),
      ),
    );
  }
}

/// Paints a [Scene] every frame with the camera from [cameraFor].
class _SceneCanvas extends StatefulWidget {
  final Scene scene;
  final Camera Function(Duration elapsed) cameraFor;

  const _SceneCanvas({required this.scene, required this.cameraFor});

  @override
  State<_SceneCanvas> createState() => _SceneCanvasState();
}

class _SceneCanvasState extends State<_SceneCanvas>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) => setState(() => _elapsed = elapsed))
      ..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ScenePainter(
        scene: widget.scene,
        camera: widget.cameraFor(_elapsed),
        pixelRatio: MediaQuery.devicePixelRatioOf(context),
      ),
    );
  }
}

class _ScenePainter extends CustomPainter {
  final Scene scene;
  final Camera camera;
  final double pixelRatio;

  const _ScenePainter({
    required this.scene,
    required this.camera,
    required this.pixelRatio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    scene.render(
      camera,
      canvas,
      viewport: Offset.zero & size,
      pixelRatio: pixelRatio,
    );
  }

  // The scene animates every frame, so always repaint.
  @override
  bool shouldRepaint(_ScenePainter oldDelegate) => true;
}

/// Animated GIF or still picture. Flutter's [Image] plays GIF frames itself.
class _ImageStage extends StatelessWidget {
  final WordData word;

  const _ImageStage({required this.word});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Image.asset(
        word.imageAsset!,
        fit: BoxFit.contain,
        gaplessPlayback: true,
        semanticLabel: word.displayName,
        errorBuilder: (_, _, _) => _EmojiStage(word: word),
      ),
    );
  }
}

/// The word's emoji, gently floating and tilting so it still feels alive.
class _EmojiStage extends StatelessWidget {
  final WordData word;
  final bool showLoading;

  const _EmojiStage({required this.word, this.showLoading = false});

  @override
  Widget build(BuildContext context) {
    final emoji = word.emoji;
    final glyph = emoji != null && emoji.isNotEmpty
        ? emoji
        : (word.word.isNotEmpty ? word.word[0].toUpperCase() : '?');

    return LayoutBuilder(
      builder: (context, constraints) {
        final fontSize = constraints.biggest.shortestSide * 0.48;
        return Stack(
          alignment: Alignment.center,
          children: [
            Text(
                  glyph,
                  textAlign: TextAlign.center,
                  style: AppFonts.fredoka(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryDark,
                  ),
                )
                .animate()
                .scale(
                  begin: const Offset(0.6, 0.6),
                  end: const Offset(1, 1),
                  duration: 450.ms,
                  curve: Curves.easeOutBack,
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(
                  begin: -8,
                  end: 8,
                  duration: 1500.ms,
                  curve: Curves.easeInOut,
                )
                .rotate(
                  begin: -0.02,
                  end: 0.02,
                  duration: 1500.ms,
                  curve: Curves.easeInOut,
                ),
            if (showLoading)
              const Positioned(
                bottom: 10,
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.secondaryDark,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Union of the POSITION accessor min/max boxes in a GLB — the rest-pose
/// bounds glTF requires every mesh to carry. Null if [bytes] is not a GLB or
/// has no positioned mesh.
@visibleForTesting
vm.Aabb3? glbPositionBounds(Uint8List bytes) {
  final view = ByteData.sublistView(bytes);
  const glbMagic = 0x46546C67;
  if (bytes.length < 20 || view.getUint32(0, Endian.little) != glbMagic) {
    return null;
  }
  final jsonLength = view.getUint32(12, Endian.little);
  final json =
      jsonDecode(utf8.decode(bytes.sublist(20, 20 + jsonLength)))
          as Map<String, dynamic>;
  final accessors = (json['accessors'] as List?) ?? const [];
  vm.Aabb3? result;
  for (final mesh in (json['meshes'] as List?) ?? const []) {
    for (final primitive in (mesh['primitives'] as List?) ?? const []) {
      final index = (primitive['attributes'] as Map?)?['POSITION'] as int?;
      if (index == null) continue;
      final accessor = accessors[index] as Map;
      final min = (accessor['min'] as List?)?.cast<num>();
      final max = (accessor['max'] as List?)?.cast<num>();
      if (min == null || max == null || min.length < 3 || max.length < 3) {
        continue;
      }
      final box = vm.Aabb3.minMax(
        vm.Vector3(min[0].toDouble(), min[1].toDouble(), min[2].toDouble()),
        vm.Vector3(max[0].toDouble(), max[1].toDouble(), max[2].toDouble()),
      );
      if (result == null) {
        result = box;
      } else {
        result.hull(box);
      }
    }
  }
  return result;
}
