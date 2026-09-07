import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:alphabet_adventure/ui/core/animations/bounce_animation.dart';
import 'package:alphabet_adventure/ui/core/app_colors.dart';

/// 3D tactile, bubbly animated letter widget with realistic bevel shadows and glowing outline.
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
    return BounceAnimation(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor.withValues(alpha: 0.95),
              primaryColor,
              shadowColor,
            ],
          ),
          border: Border.all(
            color: isSelected ? AppColors.accentYellow : Colors.white,
            width: isSelected ? 4 : 3,
          ),
          boxShadow: [
            // 3D bottom bevel shadow
            BoxShadow(
              color: shadowColor.withValues(alpha: 0.6),
              offset: Offset(0, size * 0.08),
              blurRadius: 0,
            ),
            // Soft ambient drop shadow
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              offset: Offset(0, size * 0.12),
              blurRadius: size * 0.12,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Top highlight for 3D gloss
            Positioned(
              top: size * 0.08,
              left: size * 0.12,
              right: size * 0.12,
              child: Container(
                height: size * 0.22,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(size * 0.2),
                ),
              ),
            ),
            // Letter text glyph
            Text(
              letter,
              style: GoogleFonts.fredoka(
                fontSize: size * 0.55,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    offset: const Offset(0, 3),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            // Sparkle icon if enabled
            if (showSparkle)
              Positioned(
                top: size * 0.08,
                right: size * 0.08,
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.accentYellow,
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
