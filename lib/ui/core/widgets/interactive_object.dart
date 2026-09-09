import 'package:flutter/material.dart';

import 'package:alphabet_adventure/data/models/word_data.dart';
import 'package:alphabet_adventure/ui/core/animations/bounce_animation.dart';
import 'package:alphabet_adventure/ui/core/app_colors.dart';
import 'package:alphabet_adventure/ui/core/app_fonts.dart';

/// Interactive 3D styled learning object card displaying a vocabulary word, icon, and highlighted initial letter.
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
    Color borderColor = Theme.of(context).cardTheme.color ?? Colors.white;
    Color bgColor = Theme.of(context).cardTheme.color ?? Colors.white;

    if (isCorrect) {
      borderColor = AppColors.success;
      bgColor = AppColors.success.withValues(alpha: 0.15);
    } else if (isIncorrect) {
      borderColor = AppColors.tryAgain;
      bgColor = AppColors.tryAgain.withValues(alpha: 0.15);
    } else if (isSelected) {
      borderColor = AppColors.primary;
      bgColor = AppColors.primaryLight.withValues(alpha: 0.2);
    }

    return BounceAnimation(
      playTapSound: false,
      onTap: onTap,
      child: Container(
        width: size,
        height: showLabel ? size * 1.25 : size,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 3.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Object Icon/Visual representation
            Expanded(
              child: Center(
                child: _buildObjectVisual(word, size * 0.5),
              ),
            ),
            if (showLabel) ...[
              const SizedBox(height: 6),
              // Word label with initial letter highlighted
              _buildHighlightedWord(context, word),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedWord(BuildContext context, WordData word) {
    final firstChar = word.word.isNotEmpty ? word.word[0] : '';
    final rest = word.word.length > 1 ? word.word.substring(1) : '';

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: firstChar.toUpperCase(),
            style: AppFonts.fredoka(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          TextSpan(
            text: rest.toLowerCase(),
            style: AppFonts.fredoka(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
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

    return Container(
      width: iconSize * 1.3,
      height: iconSize * 1.3,
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: emoji != null && emoji.isNotEmpty
            ? Text(
                emoji,
                style: TextStyle(fontSize: iconSize * 0.78),
                textAlign: TextAlign.center,
              )
            : Text(
                word.word.isNotEmpty ? word.word[0].toUpperCase() : '?',
                style: AppFonts.fredoka(
                  fontSize: iconSize * 0.7,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryDark,
                ),
              ),
      ),
    );
  }
}
