import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Colours of one tactile surface: a wooden or candy-coloured slab with a
/// rim, a bevel underneath and a glossy top edge.
@immutable
class WoodToneColors {
  const WoodToneColors({
    required this.top,
    required this.bottom,
    required this.rim,
    required this.bevel,
    required this.highlight,
    required this.ink,
    this.grain = false,
  });

  /// Builds candy colours from one base colour and its darker shade.
  factory WoodToneColors.fromColor(Color base, Color shade) {
    return WoodToneColors(
      top: Color.lerp(base, const Color(0xFFFFFFFF), 0.18)!,
      bottom: base,
      rim: shade,
      bevel: Color.lerp(shade, const Color(0xFF000000), 0.3)!,
      highlight: Color.lerp(base, const Color(0xFFFFFFFF), 0.65)!,
      ink: const Color(0xFFFFFFFF),
    );
  }

  /// Face gradient, top to bottom.
  final Color top;
  final Color bottom;

  /// Outline around the face.
  final Color rim;

  /// The darker slab visible below the face, which gives it thickness.
  final Color bevel;

  /// Gloss along the top inner edge.
  final Color highlight;

  /// Text and icon colour that reads on this surface.
  final Color ink;

  /// Whether to paint wood grain on the face.
  final bool grain;
}

/// The surface finishes used across the app.
enum WoodTone {
  /// Pale, polished wood: the default button and panel.
  light,

  /// Dark walnut: plaques, headers, tab bars.
  dark,

  /// Candy colours for primary actions and feedback.
  green,
  orange,
  blue,
  purple,
  red,
  gold;

  WoodToneColors get colors => switch (this) {
    WoodTone.light => WoodColors.lightWood,
    WoodTone.dark => WoodColors.darkWood,
    WoodTone.green => WoodColors.candyGreen,
    WoodTone.orange => WoodColors.candyOrange,
    WoodTone.blue => WoodColors.candyBlue,
    WoodTone.purple => WoodColors.candyPurple,
    WoodTone.red => WoodColors.candyRed,
    WoodTone.gold => WoodColors.candyGold,
  };
}

/// Palette for the wooden, block-puzzle look of the app.
abstract final class WoodColors {
  /// Dark brown text on light wood and parchment.
  static const Color ink = Color(0xFF5C2C0C);

  /// Secondary text on light wood and parchment.
  static const Color inkSoft = Color(0xFF8C6040);

  /// Pale parchment used inside panels for lists and fields.
  static const Color parchment = Color(0xFFFFF3DC);
  static const Color parchmentEdge = Color(0xFFE8C99A);

  /// Golden title fill, top to bottom, and its outline.
  static const Color goldTop = Color(0xFFFFE27A);
  static const Color goldBottom = Color(0xFFFFB02E);
  static const Color goldOutline = Color(0xFF6B3312);

  /// Recessed board cells.
  static const Color cellDark = Color(0xFF6E3B1E);
  static const Color cellLine = Color(0xFF4A2410);

  /// Green callout pills ("1.04% completed").
  static const Color pill = Color(0xFF34B37E);
  static const Color pillShade = Color(0xFF1F8458);

  static const WoodToneColors lightWood = WoodToneColors(
    top: Color(0xFFF7DAA2),
    bottom: Color(0xFFE2B06A),
    rim: Color(0xFFB06A2C),
    bevel: Color(0xFF7E4516),
    highlight: Color(0xFFFFF1C9),
    ink: ink,
    grain: true,
  );

  static const WoodToneColors darkWood = WoodToneColors(
    top: Color(0xFF8E4B23),
    bottom: Color(0xFF6A3415),
    rim: Color(0xFF4A200A),
    bevel: Color(0xFF2E1204),
    highlight: Color(0xFFB77645),
    ink: Color(0xFFFFE3A8),
    grain: true,
  );

  static const WoodToneColors candyGreen = WoodToneColors(
    top: Color(0xFF6BDB8F),
    bottom: Color(0xFF32AE5C),
    rim: Color(0xFF1F7C41),
    bevel: Color(0xFF145A2E),
    highlight: Color(0xFFC2F7D2),
    ink: Color(0xFFFFFFFF),
  );

  static const WoodToneColors candyOrange = WoodToneColors(
    top: Color(0xFFFFB859),
    bottom: Color(0xFFF2811E),
    rim: Color(0xFFB8570D),
    bevel: Color(0xFF8A3F06),
    highlight: Color(0xFFFFE2AC),
    ink: Color(0xFFFFFFFF),
  );

  static const WoodToneColors candyBlue = WoodToneColors(
    top: Color(0xFF7DB0FF),
    bottom: Color(0xFF4677E3),
    rim: Color(0xFF2C51AA),
    bevel: Color(0xFF1C3677),
    highlight: Color(0xFFD4E4FF),
    ink: Color(0xFFFFFFFF),
  );

  static const WoodToneColors candyPurple = WoodToneColors(
    top: Color(0xFFD29AF7),
    bottom: Color(0xFFA15BE0),
    rim: Color(0xFF6D35A6),
    bevel: Color(0xFF4B2275),
    highlight: Color(0xFFF0DDFF),
    ink: Color(0xFFFFFFFF),
  );

  static const WoodToneColors candyRed = WoodToneColors(
    top: Color(0xFFFF9A90),
    bottom: Color(0xFFEF5A50),
    rim: Color(0xFFB23A36),
    bevel: Color(0xFF7F2522),
    highlight: Color(0xFFFFDAD6),
    ink: Color(0xFFFFFFFF),
  );

  static const WoodToneColors candyGold = WoodToneColors(
    top: Color(0xFFFFE680),
    bottom: Color(0xFFFFBC2E),
    rim: Color(0xFFC07F0B),
    bevel: Color(0xFF8C5A04),
    highlight: Color(0xFFFFF7CF),
    ink: Color(0xFF6B3312),
  );

  /// Candy block colours used, in order, for letters in titles and grids.
  static const List<WoodToneColors> blockCycle = [
    candyGreen,
    WoodToneColors(
      top: Color(0xFF4FD1CB),
      bottom: Color(0xFF1FA7A6),
      rim: Color(0xFF137676),
      bevel: Color(0xFF0C5454),
      highlight: Color(0xFFC6F5F2),
      ink: Color(0xFFFFFFFF),
    ),
    candyBlue,
    candyPurple,
    candyOrange,
    candyRed,
  ];
}
