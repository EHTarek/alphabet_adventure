import 'dart:math' as math;

import 'package:alphabet_adventure/ui/core/widgets/blossom_scene/blossom_scene_tuning.dart';

/// A gentle breeze with occasional rounded micro-gusts.
///
/// The steady breeze is a sum of slow, unrelated sine waves, so it never
/// visibly repeats. Every [BlossomSceneTuning.gustIntervalMin] to
/// [BlossomSceneTuning.gustIntervalMax] seconds a gust swells in and fades out
/// on a raised-cosine envelope, with no sharp edges. Air moves left to right,
/// so a gust reaches the right side of the screen a moment after the left.
class SceneBreeze {
  SceneBreeze(this._random) : _nextGustAt = 3 + _random.nextDouble() * 3;

  final math.Random _random;

  double _time = 0;
  double _nextGustAt;
  double _gustStart = -1000;
  double _gustDuration = 1;
  double _gustStrength = 0;

  /// Seconds since the breeze started.
  double get time => _time;

  void advance(double dt) {
    _time += dt;
    if (_time < _nextGustAt) return;
    _gustStart = _time;
    _gustDuration = _range(
      BlossomSceneTuning.gustDurationMin,
      BlossomSceneTuning.gustDurationMax,
    );
    _gustStrength = _range(
      BlossomSceneTuning.gustStrengthMin,
      BlossomSceneTuning.gustStrengthMax,
    );
    _nextGustAt =
        _time +
        _gustDuration +
        _range(
          BlossomSceneTuning.gustIntervalMin,
          BlossomSceneTuning.gustIntervalMax,
        );
  }

  /// Total wind strength in [0, 1] at horizontal position [nx] (0 is the left
  /// edge, 1 the right edge).
  double at(double nx) {
    final t = _localTime(nx);
    final steady =
        BlossomSceneTuning.breezeRest +
        0.10 * math.sin(t * 0.31) +
        0.06 * math.sin(t * 0.73 + 1.7) +
        0.03 * math.sin(t * 1.9 + 0.6);
    return (steady + _gust(t)).clamp(0.0, 1.0);
  }

  /// Only the gust part of the wind at [nx], in [0, 1].
  double gustAt(double nx) => _gust(_localTime(nx));

  double _localTime(double nx) {
    return _time - nx.clamp(-0.5, 1.5) * BlossomSceneTuning.gustCrossingSeconds;
  }

  double _gust(double t) {
    final u = (t - _gustStart) / _gustDuration;
    if (u <= 0 || u >= 1) return 0;
    const attack = 0.35;
    const release = 0.55;
    final double envelope;
    if (u < attack) {
      envelope = 0.5 - 0.5 * math.cos(math.pi * u / attack);
    } else if (u < release) {
      envelope = 1;
    } else {
      envelope = 0.5 + 0.5 * math.cos(math.pi * (u - release) / (1 - release));
    }
    return _gustStrength * envelope;
  }

  double _range(double min, double max) {
    return min + _random.nextDouble() * (max - min);
  }
}
