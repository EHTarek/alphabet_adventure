import 'package:flutter/material.dart';

import 'package:alphabet_adventure/ui/core/animations/bounce_animation.dart';
import 'package:alphabet_adventure/ui/core/app_colors.dart';
import 'package:alphabet_adventure/ui/core/wood/wood.dart';

/// A glossy candy block carrying a letter, squishing when tapped.
///
/// Fits within a [size] by [size] square, bevel included.
class AnimatedLetter extends StatelessWidget {
  final String letter;
  final double size;
  final Color primaryColor;
  final Color shadowColor;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool showSparkle;

  const AnimatedLetter({
    super.key,
    required this.letter,
    this.size = 120.0,
    this.primaryColor = AppColors.primary,
    this.shadowColor = AppColors.primaryDark,
    this.onTap,
    this.isSelected = false,
    this.showSparkle = false,
  });

  @override
  Widget build(BuildContext context) {
    final blockSize = size / 1.1;
    return BounceAnimation(
      playTapSound: false,
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            if (isSelected)
              // A golden glow marks the selected block.
              Container(
                width: blockSize * 1.04,
                height: blockSize * 1.04,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(blockSize * 0.3),
                  boxShadow: [
                    BoxShadow(
                      color: WoodColors.goldTop.withValues(alpha: 0.9),
                      blurRadius: size * 0.12,
                      spreadRadius: size * 0.04,
                    ),
                  ],
                ),
              ),
            CandyBlock(
              colors: WoodToneColors.fromColor(primaryColor, shadowColor),
              size: blockSize,
              letter: letter,
            ),
            if (showSparkle)
              Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: WoodColors.goldTop,
                  size: size * 0.22,
                  shadows: const [
                    Shadow(
                      color: WoodColors.goldOutline,
                      offset: Offset(0, 1.5),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
