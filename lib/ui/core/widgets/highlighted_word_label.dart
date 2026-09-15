import 'package:flutter/material.dart';

import 'package:alphabet_adventure/ui/core/app_fonts.dart';
import 'package:alphabet_adventure/ui/core/wood/wood.dart';

/// A word with its first letter emphasised in a candy colour, e.g. **A**pple,
/// on a small parchment chip.
///
/// Shared by the vocabulary cards and the letter example overlay so the initial
/// always reads the same way to a child who is matching letter to word.
class HighlightedWordLabel extends StatelessWidget {
  final String word;
  final double fontSize;

  const HighlightedWordLabel({
    super.key,
    required this.word,
    this.fontSize = 18,
  });

  static final WoodToneColors _initialColors = WoodColors.candyOrange;

  @override
  Widget build(BuildContext context) {
    final firstChar = word.isNotEmpty ? word[0] : '';
    final rest = word.length > 1 ? word.substring(1) : '';

    // Scales down rather than overflowing a narrow card.
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF9EC), WoodColors.parchment],
          ),
          borderRadius: BorderRadius.circular(fontSize * 0.8),
          border: Border.all(
            color: WoodColors.parchmentEdge,
            width: fontSize >= 24 ? 2.5 : 1.5,
          ),
          boxShadow: const [
            BoxShadow(color: Color(0x334A200A), offset: Offset(0, 2)),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: fontSize * 0.6,
            vertical: fontSize * 0.08,
          ),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: firstChar.toUpperCase(),
                  style: AppFonts.fredoka(
                    fontSize: fontSize + 2,
                    fontWeight: FontWeight.w700,
                    color: _initialColors.bottom,
                    height: 1.15,
                    shadows: [
                      Shadow(
                        color: _initialColors.bevel,
                        offset: Offset(0, fontSize * 0.06),
                      ),
                    ],
                  ),
                ),
                TextSpan(
                  text: rest.toLowerCase(),
                  style: AppFonts.fredoka(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: WoodColors.ink,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
