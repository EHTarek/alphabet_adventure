import 'package:flutter/material.dart';

import 'package:alphabet_adventure/ui/core/app_fonts.dart';
import 'package:alphabet_adventure/ui/core/wood/wood_palette.dart';

/// Chunky title lettering: a gradient fill inside a thick dark outline with a
/// drop edge, like the "CRUSH" in a block-puzzle logo.
///
/// The outline is a [RichText] behind the fill [Text], so `find.text` still
/// matches exactly one widget.
class WoodTitle extends StatelessWidget {
  const WoodTitle(
    this.text, {
    super.key,
    this.fontSize = 34,
    this.fill = const [WoodColors.goldTop, WoodColors.goldBottom],
    this.outline = WoodColors.goldOutline,
    this.outlineWidth,
    this.textAlign = TextAlign.center,
    this.letterSpacing = 1,
    this.maxLines,
  });

  final String text;
  final double fontSize;

  /// Fill gradient, top to bottom.
  final List<Color> fill;
  final Color outline;
  final double? outlineWidth;
  final TextAlign textAlign;
  final double letterSpacing;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final strokeWidth = outlineWidth ?? fontSize * 0.16;
    final base = AppFonts.fredoka(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: letterSpacing,
      height: 1.1,
    );
    return Padding(
      padding: EdgeInsets.all(strokeWidth / 2),
      child: Stack(
        children: [
          ExcludeSemantics(
            child: RichText(
              textAlign: textAlign,
              maxLines: maxLines,
              text: TextSpan(
                text: text,
                style: base.copyWith(
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = strokeWidth
                    ..strokeJoin = StrokeJoin.round
                    ..color = outline,
                  shadows: [
                    Shadow(color: outline, offset: Offset(0, fontSize * 0.09)),
                    Shadow(
                      color: const Color(0x55000000),
                      offset: Offset(0, fontSize * 0.14),
                      blurRadius: fontSize * 0.12,
                    ),
                  ],
                ),
              ),
            ),
          ),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: fill,
            ).createShader(bounds),
            child: Text(
              text,
              textAlign: textAlign,
              maxLines: maxLines,
              style: base.copyWith(color: fill.last),
            ),
          ),
        ],
      ),
    );
  }
}

/// Text styles for the wooden look.
abstract final class WoodText {
  /// Bold italic label, as on wooden menu buttons.
  static TextStyle button({
    double fontSize = 24,
    Color color = WoodColors.ink,
  }) {
    return AppFonts.fredoka(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.italic,
      color: color,
      letterSpacing: 0.3,
    );
  }

  /// Heading on light wood or parchment.
  static TextStyle heading({
    double fontSize = 20,
    Color color = WoodColors.ink,
  }) {
    return AppFonts.fredoka(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      color: color,
    );
  }

  /// Body text on light wood or parchment.
  static TextStyle body({
    double fontSize = 16,
    Color color = WoodColors.ink,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return AppFonts.fredoka(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: 1.3,
    );
  }

  /// White text with a dark edge, readable straight on the wooden background.
  static TextStyle onBackground({
    double fontSize = 18,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    return AppFonts.fredoka(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: const Color(0xFFFFFFFF),
      shadows: const [
        Shadow(color: Color(0xAA4A200A), offset: Offset(0, 2), blurRadius: 3),
      ],
    );
  }
}
