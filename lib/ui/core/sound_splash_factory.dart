import 'package:flutter/material.dart';

import 'package:alphabet_adventure/core/di/locator.dart';
import 'package:alphabet_adventure/data/services/audio_service.dart';

/// A custom splash factory that triggers the app tap sound when a button tap
/// is confirmed, skipping if another voice or sound effect is already playing.
class SoundSplashFactory extends InteractiveInkFeatureFactory {
  const SoundSplashFactory();

  @override
  InteractiveInkFeature create({
    required MaterialInkController controller,
    required RenderBox referenceBox,
    required Offset position,
    required Color color,
    required TextDirection textDirection,
    bool containedInkWell = false,
    RectCallback? rectCallback,
    BorderRadius? borderRadius,
    ShapeBorder? customBorder,
    double? radius,
    VoidCallback? onRemoved,
  }) {
    return SoundInkRipple(
      controller: controller,
      referenceBox: referenceBox,
      position: position,
      color: color,
      textDirection: textDirection,
      containedInkWell: containedInkWell,
      rectCallback: rectCallback,
      borderRadius: borderRadius,
      customBorder: customBorder,
      radius: radius,
      onRemoved: onRemoved,
    );
  }
}

/// [InkRipple] subclass that triggers the button tap sound upon tap confirmation.
class SoundInkRipple extends InkRipple {
  SoundInkRipple({
    required super.controller,
    required super.referenceBox,
    required super.position,
    required super.color,
    required super.textDirection,
    super.containedInkWell,
    super.rectCallback,
    super.borderRadius,
    super.customBorder,
    super.radius,
    super.onRemoved,
  });

  @override
  void confirm() {
    if (locator.isRegistered<AudioService>()) {
      locator<AudioService>().playTap();
    }
    super.confirm();
  }
}
