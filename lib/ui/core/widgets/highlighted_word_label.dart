import 'package:flutter/material.dart';

import 'package:alphabet_adventure/ui/core/app_colors.dart';
import 'package:alphabet_adventure/ui/core/app_fonts.dart';

/// A word with its first letter emphasised in the brand colour, e.g. **A**pple.
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

  @override
  Widget build(BuildContext context) {
    final firstChar = word.isNotEmpty ? word[0] : '';
    final rest = word.length > 1 ? word.substring(1) : '';

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: firstChar.toUpperCase(),
            style: AppFonts.fredoka(
              fontSize: fontSize + 2,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          TextSpan(
            text: rest.toLowerCase(),
            style: AppFonts.fredoka(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}
