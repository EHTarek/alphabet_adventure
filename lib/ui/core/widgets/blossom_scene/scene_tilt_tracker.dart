import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;
import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'package:alphabet_adventure/ui/core/widgets/blossom_scene/blossom_scene_tuning.dart';

/// Fuses accelerometer and gyroscope samples into the direction of gravity in
/// the device frame.
///
/// The gyroscope turns the estimate smoothly and without lag; the accelerometer
/// slowly pulls it back to true gravity so gyroscope drift never builds up
/// (a complementary filter). Without a gyroscope the accelerometer is simply
/// low-pass filtered.
///
/// Axes follow the Android convention, which sensors_plus also uses on iOS:
/// +x to the right of the screen, +y to its top, +z out of the screen. An
/// upright device reads gravity as (0, +g, 0).
class TiltFusion {
  static const double _standardGravity = 9.81;

  double _gx = 0;
  double _gy = 1;
  double _gz = 0;
  bool _hasSample = false;
  bool _hasGyroscope = false;

  /// Whether any accelerometer sample has arrived.
  bool get hasSample => _hasSample;

  /// Whether gyroscope samples are being fused.
  bool get hasGyroscope => _hasGyroscope;

  /// True left/right tilt in radians: positive when the right edge is lower.
  ///
  /// Independent of how far the device leans forward or back.
  double get roll => math.atan2(-_gx, math.sqrt(_gy * _gy + _gz * _gz));

  /// Forward/back lean in radians: 0 upright, +pi/2 lying face up.
  double get pitch => math.atan2(_gz, _gy);

  /// Unit "up" direction (the accelerometer's gravity reading) in the device
  /// frame.
  double get upX => _gx;
  double get upY => _gy;
  double get upZ => _gz;

  void addAccelerometer(double x, double y, double z, double dt) {
    final magnitude = math.sqrt(x * x + y * y + z * z);
    if (magnitude < 1e-3) return;
    final ax = x / magnitude;
    final ay = y / magnitude;
    final az = z / magnitude;

    if (!_hasSample) {
      _gx = ax;
      _gy = ay;
      _gz = az;
      _hasSample = true;
      return;
    }

    final tau = _hasGyroscope
        ? BlossomSceneTuning.accelCorrectionSeconds
        : BlossomSceneTuning.accelOnlySmoothingSeconds;
    // While the device is being shaken the reading is gravity plus hand
    // motion, so it is trusted less.
    final shake = ((magnitude - _standardGravity).abs() / _standardGravity)
        .clamp(0.0, 1.0);
    final k = (1 - math.exp(-dt / tau)) * (1 - 0.9 * shake);
    _set(_gx + (ax - _gx) * k, _gy + (ay - _gy) * k, _gz + (az - _gz) * k);
  }

  /// [wx], [wy], [wz] are angular rates in rad/s about the device axes.
  void addGyroscope(double wx, double wy, double wz, double dt) {
    _hasGyroscope = true;
    if (!_hasSample) return;
    // A world-fixed vector seen from a rotating device turns the opposite
    // way: dg/dt = -(w x g) = g x w.
    _set(
      _gx + (_gy * wz - _gz * wy) * dt,
      _gy + (_gz * wx - _gx * wz) * dt,
      _gz + (_gx * wy - _gy * wx) * dt,
    );
  }

  void _set(double x, double y, double z) {
    final length = math.sqrt(x * x + y * y + z * z);
    if (length < 1e-6) return;
    _gx = x / length;
    _gy = y / length;
    _gz = z / length;
  }
}

/// One frame of device motion, as the scene consumes it.
@immutable
class SceneMotion {
  const SceneMotion({
    this.tilt = Offset.zero,
    this.agitation = 0,
    this.lateralShake = 0,
  });

  /// Tilt, each axis softly limited to (-1, 1): dx is roll (positive when the
  /// right edge is lower), dy is pitch (positive when leaning back).
  final Offset tilt;

  /// How much the device is being shaken or turned, in [0, 1]. Rises almost
  /// instantly and settles over a second or two.
  final double agitation;

  /// Sideways device acceleration in (-1, 1), positive towards the right edge.
  final double lateralShake;
}

/// Listens to the motion sensors and turns them into a normalised scene tilt.
///
/// Sensors are optional: on platforms or devices without them the streams
/// error, the tracker quietly stops, and [hasSignal] stays false.
class SceneTiltTracker {
  SceneTiltTracker({this.samplingPeriod = SensorInterval.gameInterval});

  final Duration samplingPeriod;
  final TiltFusion fusion = TiltFusion();

  StreamSubscription<AccelerometerEvent>? _accelerometer;
  StreamSubscription<GyroscopeEvent>? _gyroscope;
  final Stopwatch _clock = Stopwatch();
  int _lastAccelerometerMicros = -1;
  int _lastGyroscopeMicros = -1;
  double _pitchNeutral = 0;
  bool _hasPitchNeutral = false;

  // Strongest readings since the last sample, and their smoothed results.
  double _peakAngularSpeed = 0;
  double _peakLinearAcceleration = 0;
  double _lastLateralAcceleration = 0;
  double _agitation = 0;
  double _lateralShake = 0;

  /// Sensor streams that reported an error (no such sensor on this device);
  /// they are not retried on the next [start].
  bool _accelerometerFailed = false;
  bool _gyroscopeFailed = false;

  /// The sensors plugin only has Android and iOS implementations here. On
  /// other hosts (desktop, `flutter test`) listening would report a
  /// MissingPluginException, so the scene uses its idle drift instead.
  static bool get isSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Whether a reading has ever arrived, so [sample] reflects the device.
  bool get hasSignal => fusion.hasSample;

  void start() {
    if (!isSupported) return;
    if (_accelerometer == null && !_accelerometerFailed) {
      _lastAccelerometerMicros = -1;
      _accelerometer = accelerometerEventStream(samplingPeriod: samplingPeriod)
          .listen(
            _onAccelerometer,
            onError: (Object _) {
              _accelerometerFailed = true;
              _accelerometer = null;
            },
            cancelOnError: true,
          );
    }
    if (_gyroscope == null && !_gyroscopeFailed) {
      _lastGyroscopeMicros = -1;
      _gyroscope = gyroscopeEventStream(samplingPeriod: samplingPeriod).listen(
        _onGyroscope,
        onError: (Object _) {
          _gyroscopeFailed = true;
          _gyroscope = null;
        },
        cancelOnError: true,
      );
    }
    _clock.start();
  }

  void stop() {
    _accelerometer?.cancel();
    _gyroscope?.cancel();
    _accelerometer = null;
    _gyroscope = null;
    _clock.stop();
  }

  /// Advances the forward/back resting angle and the agitation envelope by
  /// [dt] seconds and returns this frame's motion.
  SceneMotion sample(double dt) {
    if (!fusion.hasSample) return const SceneMotion();
    final pitch = fusion.pitch;
    if (!_hasPitchNeutral) {
      _pitchNeutral = pitch;
      _hasPitchNeutral = true;
    } else {
      final follow = 1 - math.exp(-dt / BlossomSceneTuning.pitchNeutralSeconds);
      _pitchNeutral += _wrapAngle(pitch - _pitchNeutral) * follow;
    }

    // Turning the device (gyroscope) or jolting it (accelerometer beyond
    // gravity) both count as agitation; a hand holding it still does not.
    final turning =
        ((_peakAngularSpeed - BlossomSceneTuning.agitationTurnFloor) /
                BlossomSceneTuning.agitationTurnRange)
            .clamp(0.0, 1.0);
    final jolting =
        ((_peakLinearAcceleration - BlossomSceneTuning.agitationShakeFloor) /
                BlossomSceneTuning.agitationShakeRange)
            .clamp(0.0, 1.0);
    _peakAngularSpeed = 0;
    _peakLinearAcceleration = 0;
    final raw = math.max(turning, jolting);
    final tau = raw > _agitation
        ? BlossomSceneTuning.agitationRiseSeconds
        : BlossomSceneTuning.agitationSettleSeconds;
    _agitation += (raw - _agitation) * (1 - math.exp(-dt / tau));

    final lateral =
        (_lastLateralAcceleration / BlossomSceneTuning.agitationShakeRange)
            .clamp(-1.0, 1.0);
    _lateralShake += (lateral - _lateralShake) * (1 - math.exp(-dt / 0.08));

    return SceneMotion(
      tilt: Offset(
        _shape(fusion.roll / BlossomSceneTuning.rollRange),
        _shape(
          _wrapAngle(pitch - _pitchNeutral) / BlossomSceneTuning.pitchRange,
        ),
      ),
      agitation: _agitation,
      lateralShake: _lateralShake,
    );
  }

  void _onAccelerometer(AccelerometerEvent event) {
    fusion.addAccelerometer(
      event.x,
      event.y,
      event.z,
      _stepSeconds(
        _lastAccelerometerMicros,
        (m) => _lastAccelerometerMicros = m,
      ),
    );
    // What remains after removing gravity is the hand moving the device.
    const g = 9.81;
    final lx = event.x - fusion.upX * g;
    final ly = event.y - fusion.upY * g;
    final lz = event.z - fusion.upZ * g;
    _peakLinearAcceleration = math.max(
      _peakLinearAcceleration,
      math.sqrt(lx * lx + ly * ly + lz * lz),
    );
    _lastLateralAcceleration = lx;
  }

  void _onGyroscope(GyroscopeEvent event) {
    _peakAngularSpeed = math.max(
      _peakAngularSpeed,
      math.sqrt(event.x * event.x + event.y * event.y + event.z * event.z),
    );
    fusion.addGyroscope(
      event.x,
      event.y,
      event.z,
      _stepSeconds(_lastGyroscopeMicros, (m) => _lastGyroscopeMicros = m),
    );
  }

  double _stepSeconds(int lastMicros, void Function(int) store) {
    final now = _clock.elapsedMicroseconds;
    store(now);
    if (lastMicros < 0) return 0;
    // A long gap (a paused stream) must not become one huge rotation.
    return ((now - lastMicros) / 1e6).clamp(0.0, 0.1);
  }

  /// Dead zone for tremor, then a tanh soft limit so large tilts ease into,
  /// and never pass, the motion limit.
  static double _shape(double value) {
    const deadZone = BlossomSceneTuning.tiltDeadZone;
    final magnitude = value.abs();
    if (magnitude <= deadZone) return 0;
    final v = value.sign * (magnitude - deadZone) / (1 - deadZone);
    final e = math.exp(2 * v.clamp(-10.0, 10.0));
    return (e - 1) / (e + 1);
  }

  static double _wrapAngle(double angle) {
    return math.atan2(math.sin(angle), math.cos(angle));
  }
}
