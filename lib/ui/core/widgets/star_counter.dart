import 'package:flutter/material.dart';

import 'package:alphabet_adventure/ui/core/animations/bounce_animation.dart';
import 'package:alphabet_adventure/ui/core/app_fonts.dart';
import 'package:alphabet_adventure/ui/core/wood/wood.dart';

/// Top bar star counter: a dark wooden chip with a golden star and the total.
class StarCounter extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const StarCounter({super.key, required this.count, this.onTap});

  @override
  Widget build(BuildContext context) {
    return BounceAnimation(
      onTap: onTap,
      child: WoodPanel(
        tone: WoodTone.dark,
        radius: 24,
        depth: 4,
        rimWidth: 2.5,
        padding: const EdgeInsets.fromLTRB(8, 4, 14, 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star_rounded,
              color: WoodColors.goldTop,
              size: 28,
              shadows: [
                Shadow(
                  color: WoodColors.goldOutline.withValues(alpha: 0.9),
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: AppFonts.fredoka(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: WoodColors.darkWood.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
