import 'package:flutter/material.dart';

/// Typography for the app, backed by the Fredoka files bundled in `assets/fonts/`.
///
/// The font ships with the app rather than being fetched at runtime, so the app
/// never makes a network request for it. That is what lets the store listing
/// claim the app works offline and declare "no data collected" on Play.
///
/// Only the 400/500/600/700 weights exist as static files; Flutter resolves
/// heavier requests such as [FontWeight.w900] to the closest available face.
class AppFonts {
  const AppFonts._();

  /// The family name declared under `fonts:` in `pubspec.yaml`.
  static const String fredokaFamily = 'Fredoka';

  /// A Fredoka [TextStyle].
  ///
  /// [fontWeight] defaults to [FontWeight.w400] rather than being left null, so
  /// the returned style is fully determined and never picks up a heavier weight
  /// from an enclosing `DefaultTextStyle`. That matches the behaviour of the
  /// `GoogleFonts.fredoka()` calls this replaced, which always named one
  /// specific face.
  static TextStyle fredoka({
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    Color? color,
    Color? backgroundColor,
    double? letterSpacing,
    double? wordSpacing,
    double? height,
    TextDecoration? decoration,
    List<Shadow>? shadows,
  }) {
    return TextStyle(
      fontFamily: fredokaFamily,
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.w400,
      fontStyle: fontStyle,
      color: color,
      backgroundColor: backgroundColor,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      decoration: decoration,
      shadows: shadows,
    );
  }

  /// Applies Fredoka across a whole [TextTheme], defaulting to the ambient one.
  static TextTheme fredokaTextTheme([TextTheme? base]) {
    return (base ?? ThemeData.light().textTheme)
        .apply(fontFamily: fredokaFamily);
  }
}
