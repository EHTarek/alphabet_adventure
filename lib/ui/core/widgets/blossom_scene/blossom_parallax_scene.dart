import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'package:alphabet_adventure/ui/core/widgets/blossom_scene/blossom_scene_art.dart';
import 'package:alphabet_adventure/ui/core/widgets/blossom_scene/blossom_scene_tuning.dart';
import 'package:alphabet_adventure/ui/core/widgets/blossom_scene/scene_breeze.dart';
import 'package:alphabet_adventure/ui/core/widgets/blossom_scene/scene_particles.dart';
import 'package:alphabet_adventure/ui/core/widgets/blossom_scene/scene_tilt_tracker.dart';

/// A live, layered cherry-blossom scene on warm wood that reacts to how the
/// device is held.
///
/// Layers, back to front: wood, sunbeams, far petals, the main tree (with a
/// perspective rotation and a cast shadow), mid petals, an independently
/// swaying front branch, near out-of-focus petals, then [child]. Layers behind
/// the UI plane slide towards the lowered edge and layers in front slide the
/// other way, so tilting the device reveals depth.
///
/// The scene pauses its ticker and motion sensors whenever it cannot be seen
/// (a covering route, a backgrounded app) and shows a still frame when the
/// platform asks for reduced motion.
class BlossomParallaxScene extends StatefulWidget {
  const BlossomParallaxScene({
    super.key,
    this.child,
    this.dimmed = false,
    this.enableMotionSensors = true,
  });

  /// Content drawn on top of the scene.
  final Widget? child;

  /// Darkens the scene for dark mode so foreground content stays readable.
  final bool dimmed;

  /// Whether to read the accelerometer and gyroscope. When false, or when the
  /// device has no sensors, the camera drifts slowly on its own instead.
  final bool enableMotionSensors;

  @override
  State<BlossomParallaxScene> createState() => _BlossomParallaxSceneState();
}

class _BlossomParallaxSceneState extends State<BlossomParallaxScene>
    with SingleTickerProviderStateMixin {
  final BlossomSceneSimulation _simulation = BlossomSceneSimulation();
  final SceneTiltTracker _tiltTracker = SceneTiltTracker();
  final _FrameNotifier _frame = _FrameNotifier();
  late final Ticker _ticker = createTicker(_onTick);
  late final AppLifecycleListener _lifecycle;

  ValueListenable<TickerModeData>? _tickerMode;
  BlossomSceneArt? _art;
  Duration? _lastElapsed;
  bool _appVisible = true;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onStateChange: (state) {
        _appVisible =
            state == AppLifecycleState.resumed ||
            state == AppLifecycleState.inactive;
        _syncMotion();
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tickerMode = TickerMode.getValuesNotifier(context);
    if (tickerMode != _tickerMode) {
      _tickerMode?.removeListener(_syncMotion);
      _tickerMode = tickerMode..addListener(_syncMotion);
    }
    _reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    _syncMotion();
  }

  @override
  void didUpdateWidget(BlossomParallaxScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enableMotionSensors != widget.enableMotionSensors) {
      _syncMotion();
    }
  }

  @override
  void dispose() {
    _tickerMode?.removeListener(_syncMotion);
    _lifecycle.dispose();
    _tiltTracker.stop();
    _ticker.dispose();
    _frame.dispose();
    _art?.dispose();
    super.dispose();
  }

  /// Runs the ticker and sensors only while the scene can actually be seen.
  void _syncMotion() {
    final visible = _appVisible && (_tickerMode?.value.enabled ?? true);
    final animate = visible && !_reduceMotion;

    if (animate && !_ticker.isActive) {
      _lastElapsed = null;
      _ticker.start();
    } else if (!animate && _ticker.isActive) {
      _ticker.stop();
    }

    if (animate && widget.enableMotionSensors) {
      _tiltTracker.start();
    } else {
      _tiltTracker.stop();
    }

    if (_reduceMotion) {
      _simulation.particles.settle();
      _frame.tick();
    }
  }

  void _onTick(Duration elapsed) {
    final last = _lastElapsed;
    _lastElapsed = elapsed;
    final dt = last == null ? 0.0 : (elapsed - last).inMicroseconds / 1e6;

    final SceneMotion motion;
    if (widget.enableMotionSensors && _tiltTracker.hasSignal) {
      motion = _tiltTracker.sample(dt);
    } else {
      final t = _simulation.time;
      motion = SceneMotion(
        tilt: Offset(
          BlossomSceneTuning.idleDrift * math.sin(t * 0.21),
          BlossomSceneTuning.idleDrift * 0.6 * math.sin(t * 0.17 + 1.1),
        ),
      );
    }

    _simulation.step(dt, motion);
    _frame.tick();
  }

  BlossomSceneArt _artFor(Size size, double devicePixelRatio) {
    final current = _art;
    if (current != null &&
        current.size == size &&
        current.devicePixelRatio == devicePixelRatio) {
      return current;
    }
    final art = BlossomSceneArt.build(size, devicePixelRatio);
    _art = art;
    _simulation.particles.configure(size, art.canopyPoints);
    if (_reduceMotion) _simulation.particles.settle();
    if (current != null) {
      // The previous frame may still reference the old images.
      SchedulerBinding.instance.addPostFrameCallback((_) => current.dispose());
    }
    return art;
  }

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final hasArea = size.isFinite && !size.isEmpty;
        return Stack(
          fit: StackFit.expand,
          children: [
            if (hasArea)
              RepaintBoundary(
                child: CustomPaint(
                  painter: _BlossomScenePainter(
                    art: _artFor(size, devicePixelRatio),
                    simulation: _simulation,
                    dimmed: widget.dimmed,
                    repaint: _frame,
                  ),
                ),
              ),
            if (widget.child != null) widget.child!,
          ],
        );
      },
    );
  }
}

class _FrameNotifier extends ChangeNotifier {
  void tick() => notifyListeners();
}

/// Everything in the scene that moves, advanced once per frame.
///
/// Pure Dart with no widgets, so it can be stepped in tests.
class BlossomSceneSimulation {
  BlossomSceneSimulation({math.Random? random})
    : this._(random ?? math.Random());

  BlossomSceneSimulation._(math.Random random)
    : breeze = SceneBreeze(random),
      particles = SceneParticleSystem(random);

  final SceneBreeze breeze;
  final SceneParticleSystem particles;

  /// Smoothed tilt, each axis in (-1, 1).
  Offset get tilt => Offset(_tiltX.value, _tiltY.value);

  /// Main tree sway, in radians.
  double get treeSway => _treeSway.value;

  /// Front branch sway, in radians.
  double get frontBranchSway => _frontSway.value;

  double get time => breeze.time;

  /// Current shake/turn agitation in [0, 1].
  double get agitation => _agitation;
  double _agitation = 0;

  final _SmoothDamp _tiltX = _SmoothDamp();
  final _SmoothDamp _tiltY = _SmoothDamp();
  final _Spring _treeSway = _Spring();
  final _Spring _frontSway = _Spring();

  void step(double dt, SceneMotion motion) {
    final seconds = dt.clamp(0.0, BlossomSceneTuning.maxStepSeconds);
    if (seconds == 0) return;
    final targetTilt = motion.tilt;
    final a = motion.agitation.clamp(0.0, 1.0);
    _agitation = a;

    const smoothing = BlossomSceneTuning.tiltSmoothingSeconds;
    _tiltX.step(targetTilt.dx.clamp(-1.0, 1.0), smoothing, seconds);
    _tiltY.step(targetTilt.dy.clamp(-1.0, 1.0), smoothing, seconds);

    breeze.advance(seconds);
    final t = breeze.time;

    // The heavy tree and the light front branch feel the same air at
    // different places and moments, and answer at their own natural
    // frequencies, so they never move in lockstep.
    _treeSway.step(
      target:
          (breeze.at(0.2) - BlossomSceneTuning.breezeRest) * 0.03 +
          math.sin(t * 1.7) * 0.002 +
          // A shaken tree trembles.
          math.sin(t * 11.0) * 0.012 * a,
      hz: BlossomSceneTuning.treeSwayHz,
      damping: BlossomSceneTuning.treeSwayDamping,
      limit:
          BlossomSceneTuning.treeSwayMax *
          (1 + a * BlossomSceneTuning.agitatedSwayLimitBoost),
      dt: seconds,
    );
    _frontSway.step(
      target:
          -(breeze.at(0.85) - BlossomSceneTuning.breezeRest) * 0.07 +
          math.sin(t * 2.3 + 0.7) * 0.004 +
          math.sin(t * 13.0 + 0.4) * 0.03 * a -
          motion.lateralShake * 0.03,
      hz: BlossomSceneTuning.frontBranchSwayHz,
      damping: BlossomSceneTuning.frontBranchSwayDamping,
      limit:
          BlossomSceneTuning.frontBranchSwayMax *
          (1 + a * BlossomSceneTuning.agitatedSwayLimitBoost),
      dt: seconds,
    );

    particles.update(seconds, breeze, motion);
  }
}

/// Critically damped smoothing: follows a target without overshoot.
class _SmoothDamp {
  double value = 0;
  double _velocity = 0;

  void step(double target, double smoothTime, double dt) {
    final omega = 2 / smoothTime;
    final x = omega * dt;
    final decay = 1 / (1 + x + 0.48 * x * x + 0.235 * x * x * x);
    final change = value - target;
    final temp = (_velocity + omega * change) * dt;
    _velocity = (_velocity - omega * temp) * decay;
    value = target + (change + temp) * decay;
  }
}

/// A damped spring for organic, slightly springy sway.
class _Spring {
  double value = 0;
  double _velocity = 0;

  void step({
    required double target,
    required double hz,
    required double damping,
    required double limit,
    required double dt,
  }) {
    final omega = 2 * math.pi * hz;
    final acceleration =
        omega * omega * (target - value) - 2 * damping * omega * _velocity;
    _velocity += acceleration * dt;
    value += _velocity * dt;
    if (value.abs() > limit) {
      value = value.clamp(-limit, limit);
      _velocity *= 0.5;
    }
  }
}

class _BlossomScenePainter extends CustomPainter {
  _BlossomScenePainter({
    required this.art,
    required this.simulation,
    required this.dimmed,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final BlossomSceneArt art;
  final BlossomSceneSimulation simulation;
  final bool dimmed;

  final Paint _imagePaint = Paint()..filterQuality = FilterQuality.medium;
  final Paint _fadedPaint = Paint()..filterQuality = FilterQuality.low;
  final Paint _spritePaint = Paint()..filterQuality = FilterQuality.low;
  final Matrix4 _matrix = Matrix4.identity();
  final Matrix4 _perspective = Matrix4.identity()
    ..setEntry(3, 2, BlossomSceneTuning.perspective);

  static const Color _dimColor = Color(0x8C120A06);
  static const Offset _treeShadowOffset = Offset(6, 10);
  static const Offset _frontShadowOffset = Offset(12, 22);

  @override
  void paint(Canvas canvas, Size size) {
    final tilt = simulation.tilt;
    final center = size.center(Offset.zero);
    Offset travel(double amount) => Offset(
      tilt.dx * amount,
      tilt.dy * amount * BlossomSceneTuning.verticalTravelFactor,
    );
    final backgroundTravel = travel(BlossomSceneTuning.backgroundTravel);

    // 1. Wood.
    _drawImage(
      canvas,
      art.background,
      art.backgroundRect.shift(backgroundTravel),
      _imagePaint,
    );

    // 2. Sunbeams, breathing slowly.
    _fadedPaint.color = Color.fromRGBO(
      255,
      255,
      255,
      0.75 + 0.25 * math.sin(simulation.time * 0.35),
    );
    _drawImage(
      canvas,
      art.light,
      art.lightRect.shift(travel(BlossomSceneTuning.lightTravel)),
      _fadedPaint,
    );

    // 3. Far petals.
    _drawParticles(
      canvas,
      simulation.particles.far,
      travel(BlossomSceneTuning.farParticleTravel),
      size,
    );

    // 4. Main tree: shadow on the wood, then the tree in perspective.
    final treeYaw = -tilt.dx * BlossomSceneTuning.treeMaxYaw;
    final treePitch = -tilt.dy * BlossomSceneTuning.treeMaxPitch;
    _drawLayer(
      canvas,
      art.treeShadow,
      art.treeRect,
      center: center,
      travel: backgroundTravel + _treeShadowOffset,
      pivot: art.treePivot,
      yaw: treeYaw,
      pitch: treePitch,
      sway: simulation.treeSway,
      opacity: 0.3,
    );
    _drawLayer(
      canvas,
      art.tree,
      art.treeRect,
      center: center,
      travel: travel(BlossomSceneTuning.treeTravel),
      pivot: art.treePivot,
      yaw: treeYaw,
      pitch: treePitch,
      sway: simulation.treeSway,
    );

    // 5. Mid petals, many of them detaching from the canopy.
    _drawParticles(
      canvas,
      simulation.particles.mid,
      travel(BlossomSceneTuning.midParticleTravel),
      size,
    );

    // 6. Front branch, higher off the wood so its shadow falls further.
    final frontYaw = -tilt.dx * BlossomSceneTuning.frontBranchMaxYaw;
    final frontPitch = -tilt.dy * BlossomSceneTuning.frontBranchMaxPitch;
    _drawLayer(
      canvas,
      art.frontBranchShadow,
      art.frontBranchRect,
      center: center,
      travel: backgroundTravel + _frontShadowOffset,
      pivot: art.frontBranchPivot,
      yaw: frontYaw,
      pitch: frontPitch,
      sway: simulation.frontBranchSway,
      opacity: 0.26,
    );
    _drawLayer(
      canvas,
      art.frontBranch,
      art.frontBranchRect,
      center: center,
      travel: travel(BlossomSceneTuning.frontBranchTravel),
      pivot: art.frontBranchPivot,
      yaw: frontYaw,
      pitch: frontPitch,
      sway: simulation.frontBranchSway,
    );

    // 7. Near, out-of-focus petals.
    _drawParticles(
      canvas,
      simulation.particles.near,
      travel(BlossomSceneTuning.nearParticleTravel),
      size,
    );

    if (dimmed) {
      canvas.drawRect(Offset.zero & size, Paint()..color = _dimColor);
    }
  }

  void _drawImage(
    Canvas canvas,
    ui.Image image,
    Rect destination,
    Paint paint,
  ) {
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      destination,
      paint,
    );
  }

  /// Draws a layer rotated in 3D about [pivot], viewed through a perspective
  /// centred on the screen.
  void _drawLayer(
    Canvas canvas,
    ui.Image image,
    Rect rect, {
    required Offset center,
    required Offset travel,
    required Offset pivot,
    required double yaw,
    required double pitch,
    required double sway,
    double opacity = 1,
  }) {
    _matrix
      ..setIdentity()
      ..translateByDouble(center.dx + travel.dx, center.dy + travel.dy, 0, 1)
      ..multiply(_perspective)
      ..translateByDouble(pivot.dx - center.dx, pivot.dy - center.dy, 0, 1)
      ..rotateY(yaw)
      ..rotateX(pitch)
      ..rotateZ(sway)
      ..translateByDouble(-pivot.dx, -pivot.dy, 0, 1);

    final Paint paint;
    if (opacity < 1) {
      paint = _fadedPaint..color = Color.fromRGBO(255, 255, 255, opacity);
    } else {
      paint = _imagePaint;
    }
    canvas
      ..save()
      ..transform(_matrix.storage);
    _drawImage(canvas, image, rect, paint);
    canvas.restore();
  }

  void _drawParticles(
    Canvas canvas,
    List<SceneParticle> particles,
    Offset travel,
    Size size,
  ) {
    final sprites = art.sprites;
    for (final p in particles) {
      final opacity = p.opacityFor(size.height);
      if (opacity <= 0.01) continue;

      final face = math.cos(p.flip);
      final half =
          BlossomSceneArt.spriteCell /
          2 *
          p.size /
          BlossomSceneArt.spriteRadius;
      _spritePaint.color = Color.fromRGBO(255, 255, 255, opacity);
      canvas
        ..save()
        ..translate(p.x + travel.dx, p.y + travel.dy)
        ..rotate(p.spin)
        // Tumbling: the face narrows to an edge, then shows its paler back.
        ..scale(
          math.max(face.abs(), 0.12),
          0.82 + 0.18 * math.cos(p.flip * 0.5 + p.phase),
        )
        ..drawImageRect(
          sprites,
          art.spriteSource(p, back: face < 0),
          Rect.fromLTRB(-half, -half, half, half),
          _spritePaint,
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_BlossomScenePainter oldDelegate) {
    return oldDelegate.art != art ||
        oldDelegate.simulation != simulation ||
        oldDelegate.dimmed != dimmed;
  }
}
