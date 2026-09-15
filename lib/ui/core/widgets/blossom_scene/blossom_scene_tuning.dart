import 'dart:math' as math;

/// Motion limits for the blossom parallax scene.
///
/// Every value that decides how far or how fast something moves lives here, so
/// the scene is tuned in one place. The limits are deliberately small: the
/// scene sits behind a children's learning UI and should feel alive and
/// premium, never seasick or distracting.
abstract final class BlossomSceneTuning {
  // ---------------------------------------------------------------------------
  // Tilt input
  // ---------------------------------------------------------------------------

  /// Left/right device roll that drives the parallax to ~76% of its travel.
  /// Larger tilts ease towards, but never pass, full travel.
  static const double rollRange = 22 * math.pi / 180;

  /// Forward/back pitch, measured from the angle the device is usually held
  /// at, that drives the parallax to ~76% of its travel.
  static const double pitchRange = 18 * math.pi / 180;

  /// How quickly the forward/back resting angle follows the way the child
  /// holds the device. Left/right roll has no resting angle: it is the true
  /// angle from gravity.
  static const double pitchNeutralSeconds = 3.0;

  /// How strongly the accelerometer pulls the gyroscope estimate back to
  /// gravity. Longer means smoother but slower to cancel gyroscope drift.
  static const double accelCorrectionSeconds = 0.6;

  /// Low-pass time used when the device has no gyroscope.
  static const double accelOnlySmoothingSeconds = 0.12;

  /// Normalised tilt below this is treated as hand tremor and ignored.
  static const double tiltDeadZone = 0.025;

  /// Smoothing time of the on-screen tilt (critically damped, no overshoot).
  static const double tiltSmoothingSeconds = 0.22;

  /// Amplitude of the slow camera drift used when no motion sensor reports,
  /// so the depth still reads on emulators, desktops and tablets without one.
  static const double idleDrift = 0.12;

  // ---------------------------------------------------------------------------
  // Shake and turn response
  //
  // Shaking or turning the device "shakes the tree": more petals let go of the
  // canopy, everything falls and tumbles faster, and petals are flung against
  // the shake. Agitation is normalised to [0, 1], so these limits hold however
  // hard the device is shaken.
  // ---------------------------------------------------------------------------

  /// Turn rate (rad/s) below which a hand holding the device is ignored, and
  /// the extra turn rate that reaches full agitation.
  static const double agitationTurnFloor = 0.35;
  static const double agitationTurnRange = 3.0;

  /// Acceleration beyond gravity (m/s²) below which motion is ignored, and
  /// the extra acceleration that reaches full agitation.
  static const double agitationShakeFloor = 1.2;
  static const double agitationShakeRange = 9.0;

  /// Agitation reacts almost instantly and settles slowly, like a tree that
  /// keeps shedding for a moment after it is shaken.
  static const double agitationRiseSeconds = 0.06;
  static const double agitationSettleSeconds = 1.6;

  /// Extra particles, per depth band, that only fall while agitated.
  static const int farBurstParticles = 8;
  static const int midBurstParticles = 18;
  static const int nearBurstParticles = 4;

  /// How many dormant burst particles per second let go at full agitation.
  static const double burstReleasePerSecond = 26;

  /// Multipliers reached at full agitation.
  static const double agitatedFallBoost = 0.8;
  static const double agitatedSwayBoost = 0.9;
  static const double agitatedTumbleBoost = 1.2;
  static const double agitatedWindBoost = 0.3;
  static const double agitatedSwayLimitBoost = 0.6;

  /// Sideways fling, in logical pixels per second, at full lateral shake.
  static const double shakeFling = 140;

  /// Sideways slide, in logical pixels per second, towards a fully lowered
  /// edge: petals drift downhill when the device is tilted.
  static const double tiltSlide = 28;

  // ---------------------------------------------------------------------------
  // Parallax travel at full tilt, in logical pixels.
  //
  // Layers behind the UI plane slide towards the lowered edge; layers in front
  // of it slide the opposite way. That opposite-direction movement is what
  // makes the depth read.
  // ---------------------------------------------------------------------------

  static const double backgroundTravel = 12;
  static const double lightTravel = 7;
  static const double farParticleTravel = 8;
  static const double treeTravel = 4;
  static const double midParticleTravel = -3;
  static const double frontBranchTravel = -15;
  static const double nearParticleTravel = -24;

  /// Vertical travel relative to horizontal travel.
  static const double verticalTravelFactor = 0.7;

  // ---------------------------------------------------------------------------
  // Perspective rotation, in radians at full tilt.
  // ---------------------------------------------------------------------------

  static const double perspective = 0.0012;
  static const double treeMaxYaw = 0.12;
  static const double treeMaxPitch = 0.07;
  static const double frontBranchMaxYaw = 0.08;
  static const double frontBranchMaxPitch = 0.05;

  // ---------------------------------------------------------------------------
  // Breeze and sway
  // ---------------------------------------------------------------------------

  /// Resting breeze strength that sway is measured against.
  static const double breezeRest = 0.28;

  /// Seconds a gust takes to cross from the left edge to the right edge.
  static const double gustCrossingSeconds = 0.5;

  static const double gustIntervalMin = 7;
  static const double gustIntervalMax = 15;
  static const double gustDurationMin = 2.2;
  static const double gustDurationMax = 3.6;
  static const double gustStrengthMin = 0.22;
  static const double gustStrengthMax = 0.5;

  /// Heavy main tree: slow, well damped, barely moves.
  static const double treeSwayMax = 0.018;
  static const double treeSwayHz = 0.45;
  static const double treeSwayDamping = 0.4;

  /// Light front branch: quicker and springier, so it moves independently.
  static const double frontBranchSwayMax = 0.05;
  static const double frontBranchSwayHz = 0.9;
  static const double frontBranchSwayDamping = 0.2;

  // ---------------------------------------------------------------------------
  // Particles
  // ---------------------------------------------------------------------------

  static const int farParticles = 10;
  static const int midParticles = 16;
  static const int nearParticles = 5;

  /// Share of each depth band that are leaves instead of petals.
  static const double leafShare = 0.2;

  /// Sideways drift, in logical pixels per second, of a mid-depth particle in
  /// a full-strength breeze.
  static const double windDrift = 60;

  /// Largest simulation step. Longer frames (a resumed app, a dropped frame)
  /// are clamped so nothing jumps.
  static const double maxStepSeconds = 1 / 20;
}
