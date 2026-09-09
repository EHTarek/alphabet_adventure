import 'package:flutter/material.dart';

import 'package:alphabet_adventure/ui/core/animations/bounce_animation.dart';
import 'package:alphabet_adventure/ui/core/app_colors.dart';

/// Top bar star counter widget showing total stars with bounce and glow effects.
class StarCounter extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const StarCounter({
    super.key,
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BounceAnimation(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.accentYellowDark, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentYellow.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star_rounded,
              color: AppColors.accentYellowDark,
              size: 28,
            ),
            const SizedBox(width: 6),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
