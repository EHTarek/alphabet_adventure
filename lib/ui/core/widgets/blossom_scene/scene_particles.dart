import 'dart:math' as math;
import 'dart:ui' show Offset, Size;

import 'package:alphabet_adventure/ui/core/widgets/blossom_scene/blossom_scene_tuning.dart';
import 'package:alphabet_adventure/ui/core/widgets/blossom_scene/scene_breeze.dart';
import 'package:alphabet_adventure/ui/core/widgets/blossom_scene/scene_tilt_tracker.dart';

/// Which layer of the scene a particle is drawn in.
///
/// Far particles fall behind the tree and are softly blurred, mid particles
/// fall between the tree and the front branch and are sharp, near particles
/// fall in front of everything, large and out of focus.
enum SceneDepthBand { far, mid, near }

/// One falling petal or leaf. Fields are mutable because particles are pooled
/// and recycled, so the simulation allocates nothing per frame.
class SceneParticle {
  SceneParticle({
    required this.band,
    required this.isLeaf,
    this.isBurst = false,
  }) : dormant = isBurst;

  final SceneDepthBand band;
  final bool isLeaf;

  /// Burst particles only fall while the device is shaken or turned; the rest
  /// of the time they wait, dormant and invisible.
  final bool isBurst;
  bool dormant;

  /// 0 is the far plane, 1 the nearest.
  double depth = 0;
  double x = 0;
  double y = 0;
  double vx = 0;

  /// Half the particle's length, in logical pixels.
  double size = 0;
  double fallSpeed = 0;
  double swayAmplitude = 0;
  double swayFrequency = 0;
  double phase = 0;

  /// Rotation in the screen plane, in radians.
  double spin = 0;
  double spinSpeed = 0;

  /// Tumble angle about the particle's long axis: cos(flip) is how much of
  /// its face shows, and its sign which side.
  double flip = 0;
  double flipSpeed = 0;

  double age = 0;
  double delay = 0;
  double maxOpacity = 1;
  int tone = 0;

  /// Current opacity: fades in after spawning and out near the bottom.
  double opacityFor(double sceneHeight) {
    if (dormant || delay > 0) return 0;
    final fadeIn = (age / 0.8).clamp(0.0, 1.0);
    final fadeOut = ((sceneHeight - y) / (sceneHeight * 0.12)).clamp(0.0, 1.0);
    return maxOpacity * fadeIn * fadeIn * (3 - 2 * fadeIn) * fadeOut;
  }
}

/// Pooled petals and leaves drifting through the scene.
class SceneParticleSystem {
  SceneParticleSystem(this._random) {
    _fill(
      far,
      SceneDepthBand.far,
      BlossomSceneTuning.farParticles,
      BlossomSceneTuning.farBurstParticles,
    );
    _fill(
      mid,
      SceneDepthBand.mid,
      BlossomSceneTuning.midParticles,
      BlossomSceneTuning.midBurstParticles,
    );
    _fill(
      near,
      SceneDepthBand.near,
      BlossomSceneTuning.nearParticles,
      BlossomSceneTuning.nearBurstParticles,
    );
  }

  final math.Random _random;
  final List<SceneParticle> far = [];
  final List<SceneParticle> mid = [];
  final List<SceneParticle> near = [];

  Size _size = Size.zero;
  List<Offset> _canopy = const [];
  double _agitation = 0;
  double _releaseCredit = 0;

  Iterable<SceneParticle> get all => far.followedBy(mid).followedBy(near);

  /// Sets the scene size and the blossom clusters particles may fall from.
  /// The first call scatters every regular particle across the scene.
  void configure(Size size, List<Offset> canopyPoints) {
    final firstLayout = _size.isEmpty;
    _size = size;
    _canopy = canopyPoints;
    if (!firstLayout || size.isEmpty) return;
    for (final particle in all) {
      if (!particle.isBurst) _spawn(particle, scatter: true);
    }
  }

  /// Shows every regular particle at full opacity, for a still frame when
  /// animations are disabled.
  void settle() {
    for (final particle in all) {
      particle
        ..delay = 0
        ..age = 10;
    }
  }

  void update(double dt, SceneBreeze breeze, SceneMotion motion) {
    if (_size.isEmpty) return;
    _agitation = motion.agitation.clamp(0.0, 1.0);
    _releaseBurst(dt);
    for (final particle in far) {
      _step(particle, dt, breeze, motion);
    }
    for (final particle in mid) {
      _step(particle, dt, breeze, motion);
    }
    for (final particle in near) {
      _step(particle, dt, breeze, motion);
    }
  }

  void _fill(
    List<SceneParticle> into,
    SceneDepthBand band,
    int regular,
    int burst,
  ) {
    final leaves = (regular * BlossomSceneTuning.leafShare).round();
    for (var i = 0; i < regular; i++) {
      into.add(SceneParticle(band: band, isLeaf: i < leaves));
    }
    final burstLeaves = (burst * BlossomSceneTuning.leafShare).round();
    for (var i = 0; i < burst; i++) {
      into.add(
        SceneParticle(band: band, isLeaf: i < burstLeaves, isBurst: true),
      );
    }
  }

  /// Wakes dormant burst particles at a rate that follows agitation, so a
  /// harder shake sheds more petals.
  void _releaseBurst(double dt) {
    if (_agitation < 0.05) {
      _releaseCredit = 0;
      return;
    }
    _releaseCredit +=
        _agitation * BlossomSceneTuning.burstReleasePerSecond * dt;
    while (_releaseCredit >= 1) {
      _releaseCredit -= 1;
      final dormant = _pickDormant();
      if (dormant == null) {
        _releaseCredit = 0;
        return;
      }
      dormant.dormant = false;
      _spawn(dormant, scatter: false);
      dormant.delay = 0;
    }
  }

  SceneParticle? _pickDormant() {
    // Mostly mid-depth, so shed petals visibly leave the painted canopy.
    final roll = _random.nextDouble();
    final preferred = roll < 0.65 ? mid : (roll < 0.9 ? far : near);
    for (final list in [preferred, mid, far, near]) {
      for (final particle in list) {
        if (particle.dormant) return particle;
      }
    }
    return null;
  }

  void _step(
    SceneParticle p,
    double dt,
    SceneBreeze breeze,
    SceneMotion motion,
  ) {
    if (p.dormant) return;
    if (p.delay > 0) {
      p.delay -= dt;
      return;
    }
    p.age += dt;

    final a = _agitation;
    final nx = p.x / _size.width;
    final wind = (breeze.at(nx) + a * BlossomSceneTuning.agitatedWindBoost)
        .clamp(0.0, 1.0);
    final gust = breeze.gustAt(nx);
    final speedScale = 0.6 + 0.8 * p.depth;

    // Light petals pick up the air speed quickly; leaves are heavier and lag.
    final response = p.isLeaf ? 1.6 : 2.6;
    final targetVx =
        (wind * BlossomSceneTuning.windDrift +
            motion.tilt.dx * BlossomSceneTuning.tiltSlide) *
        speedScale;
    p.vx += (targetVx - p.vx) * (1 - math.exp(-dt * response));
    // Shaking flings petals against the device's motion, like loose petals
    // left behind when a branch is jerked. Clamped so nothing shoots away.
    p.vx =
        (p.vx -
                motion.lateralShake *
                    BlossomSceneTuning.shakeFling *
                    speedScale *
                    dt *
                    6)
            .clamp(-220.0, 220.0);

    final flutter = math.sin(p.phase + breeze.time * p.swayFrequency);
    final swayBoost = 1 + a * BlossomSceneTuning.agitatedSwayBoost;
    p.x += (p.vx + flutter * p.swayAmplitude * swayBoost) * dt;

    // Face-on petals catch the air and fall slower; edge-on ones slip
    // through. Gusts briefly hold everything up; agitation shakes them down.
    final broadside = math.cos(p.flip).abs();
    p.y +=
        p.fallSpeed *
        (1.12 - 0.3 * broadside) *
        (1 - 0.35 * gust) *
        (1 + a * BlossomSceneTuning.agitatedFallBoost) *
        dt;

    final tumbleBoost = 1 + a * BlossomSceneTuning.agitatedTumbleBoost;
    p.spin +=
        (p.spinSpeed * tumbleBoost + flutter * 0.6 + gust * p.spinSpeed.sign) *
        dt;
    p.flip += p.flipSpeed * (0.7 + 0.8 * wind) * tumbleBoost * dt;

    final outOfScene =
        p.y > _size.height + p.size * 3 || p.x > _size.width + 60 || p.x < -80;
    if (!outOfScene) return;
    if (p.isBurst && _agitation < 0.05) {
      p.dormant = true;
    } else {
      _spawn(p, scatter: false);
    }
  }

  void _spawn(SceneParticle p, {required bool scatter}) {
    final w = _size.width;
    final h = _size.height;
    final a = _agitation;

    p.depth = switch (p.band) {
      SceneDepthBand.far => _range(0.0, 0.3),
      SceneDepthBand.mid => _range(0.38, 0.7),
      SceneDepthBand.near => _range(0.82, 1.0),
    };
    // Nearer particles look bigger and cross the screen faster.
    final sizeScale = 0.55 + 1.35 * p.depth * p.depth;
    final speedScale = 0.6 + 0.8 * p.depth;

    p
      ..size = (p.isLeaf ? _range(8.5, 11.5) : _range(7, 10)) * sizeScale
      ..fallSpeed = (p.isLeaf ? _range(46, 62) : _range(30, 44)) * speedScale
      ..swayAmplitude =
          (p.isLeaf ? _range(14, 24) : _range(10, 20)) * speedScale
      ..swayFrequency = p.isLeaf ? _range(1.4, 2.2) : _range(1.8, 3.2)
      ..phase = _range(0, 2 * math.pi)
      ..spin = _range(0, 2 * math.pi)
      ..spinSpeed = p.isLeaf ? _range(-0.8, 0.8) : _range(-1.2, 1.2)
      ..flip = _range(0, 2 * math.pi)
      ..flipSpeed = p.isLeaf ? _range(1.2, 2.4) : _range(2.0, 3.8)
      ..tone = _random.nextInt(p.isLeaf ? 2 : 3)
      ..maxOpacity = switch (p.band) {
        SceneDepthBand.far => _range(0.45, 0.6),
        SceneDepthBand.mid => _range(0.82, 0.95),
        SceneDepthBand.near => _range(0.7, 0.85),
      }
      ..vx = 0
      ..age = 0
      // While agitated, fallen petals are replaced almost at once.
      ..delay = scatter ? 0 : _range(0, 1.4) * (1 - 0.85 * a);

    // Mid-depth particles mostly detach from the visible blossoms; the rest
    // drift in from trees above the screen. Shaking sheds more from the
    // canopy. Near particles are too close to belong to the painted canopy.
    final canopyChance = switch (p.band) {
      SceneDepthBand.far => 0.0,
      SceneDepthBand.mid => 0.7 + 0.25 * a,
      SceneDepthBand.near => 0.0,
    };
    if (scatter) {
      p
        ..x = _range(-0.05 * w, 1.05 * w)
        ..y = _range(-0.05 * h, 0.9 * h);
    } else if (_canopy.isNotEmpty && _random.nextDouble() < canopyChance) {
      final origin = _canopy[_random.nextInt(_canopy.length)];
      p
        ..x = origin.dx + _range(-18, 18)
        ..y = origin.dy + _range(-10, 10);
    } else {
      // The breeze blows to the right, so favour the left when entering.
      p
        ..x = _range(-0.1 * w, 0.9 * w)
        ..y = -_range(20, 60) * sizeScale;
    }
  }

  double _range(double min, double max) {
    return min + _random.nextDouble() * (max - min);
  }
}
