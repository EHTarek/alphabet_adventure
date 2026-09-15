import 'package:flutter/material.dart';

import 'package:alphabet_adventure/data/models/word_data.dart';
import 'package:alphabet_adventure/ui/core/animations/bounce_animation.dart';
import 'package:alphabet_adventure/ui/core/app_fonts.dart';
import 'package:alphabet_adventure/ui/core/wood/wood.dart';

/// A pale-wood learning tile showing a vocabulary word's picture on a
/// parchment inset, with the word underneath and its initial letter picked
/// out in candy colour.
///
/// Selected tiles turn gold, correct answers green and wrong answers red.
class InteractiveObject extends StatelessWidget {
  final WordData word;
  final VoidCallback? onTap;
  final double size;
  final bool isSelected;
  final bool isCorrect;
  final bool isIncorrect;
  final bool showLabel;

  const InteractiveObject({
    super.key,
    required this.word,
    this.onTap,
    this.size = 140.0,
    this.isSelected = false,
    this.isCorrect = false,
    this.isIncorrect = false,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final WoodToneColors colors;
    if (isCorrect) {
      colors = WoodColors.candyGreen;
    } else if (isIncorrect) {
      colors = WoodColors.candyRed;
    } else if (isSelected) {
      colors = WoodColors.candyGold;
    } else {
      colors = WoodColors.lightWood;
    }
    final initialColor = switch (colors) {
      WoodColors.lightWood => WoodColors.candyOrange.rim,
      WoodColors.candyGold => WoodColors.candyRed.rim,
      _ => colors.ink,
    };

    return BounceAnimation(
      playTapSound: false,
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: showLabel ? size * 1.25 : size,
        // Grids may squeeze the tile below [size]; proportions follow the
        // width it actually gets.
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : size;
            final depth = (width * 0.05).clamp(4.0, 8.0);
            final gap = (width * 0.07).clamp(6.0, 12.0);

            return CustomPaint(
              painter: WoodSurfacePainter(
                colors: colors,
                radius: width * 0.17,
                depth: depth,
                rimWidth: 3,
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(gap, gap, gap, depth + gap * 0.6),
                child: Column(
                  children: [
                    // Object picture on a recessed parchment inset
                    Expanded(
                      child: _PictureInset(word: word, size: width),
                    ),
                    if (showLabel)
                      // Word label with initial letter highlighted
                      SizedBox(
                        height: width * 0.22,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: _WordLabel(
                              word: word.word,
                              fontSize: width * 0.15,
                              color: colors.ink,
                              initialColor: initialColor,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The parchment window framing the word's artwork.
class _PictureInset extends StatelessWidget {
  const _PictureInset({required this.word, required this.size});

  final WordData word;
  final double size;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.11),
        border: Border.all(color: WoodColors.parchmentEdge, width: 2.5),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          // A darker top edge reads as the inset's shadowed lip.
          stops: [0, 0.18, 1],
          colors: [
            Color(0xFFF1DDB6),
            WoodColors.parchment,
            WoodColors.parchment,
          ],
        ),
      ),
      child: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: _buildObjectVisual(word, size * 0.5),
          ),
        ),
      ),
    );
  }

  /// Renders the word's own emoji artwork.
  ///
  /// Every vocabulary entry in [AlphabetContent] carries a distinct emoji, so each
  /// word reads as itself. This replaced a hand-written word-to-[Icons] map that
  /// gave most words one shared placeholder glyph — which made picture questions
  /// unanswerable for a child who cannot read yet — and drew Apple Inc.'s logo for
  /// the word "apple".
  Widget _buildObjectVisual(WordData word, double iconSize) {
    final emoji = word.emoji;

    if (emoji != null && emoji.isNotEmpty) {
      return Text(
        emoji,
        style: TextStyle(fontSize: iconSize, height: 1.15),
        textAlign: TextAlign.center,
      );
    }
    return CandyBlock(
      colors: WoodColors.candyOrange,
      size: iconSize,
      letter: word.word.isNotEmpty ? word.word[0].toUpperCase() : '?',
    );
  }
}

/// The word in the tile's ink, its first letter picked out, e.g. **A**nt.
class _WordLabel extends StatelessWidget {
  const _WordLabel({
    required this.word,
    required this.fontSize,
    required this.color,
    required this.initialColor,
  });

  final String word;
  final double fontSize;
  final Color color;
  final Color initialColor;

  @override
  Widget build(BuildContext context) {
    final firstChar = word.isNotEmpty ? word[0] : '';
    final rest = word.length > 1 ? word.substring(1) : '';

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: firstChar.toUpperCase(),
            style: AppFonts.fredoka(
              fontSize: fontSize * 1.15,
              fontWeight: FontWeight.w700,
              color: initialColor,
            ),
          ),
          TextSpan(
            text: rest.toLowerCase(),
            style: AppFonts.fredoka(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
      maxLines: 1,
      textAlign: TextAlign.center,
    );
  }
}
