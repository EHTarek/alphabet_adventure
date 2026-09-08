import 'package:flutter/material.dart';

import 'package:alphabet_adventure/ui/core/animations/bounce_animation.dart';
import 'package:alphabet_adventure/ui/core/animations/celebration_animation.dart';
import 'package:alphabet_adventure/ui/core/app_colors.dart';
import 'package:alphabet_adventure/ui/core/app_fonts.dart';

/// Full-screen or modal celebration reward animation displaying 1 to 3 animated stars.
class RewardAnimation extends StatefulWidget {
  final int stars;
  final String title;
  final String subtitle;
  final VoidCallback onContinue;

  const RewardAnimation({
    super.key,
    required this.stars,
    this.title = 'Super Star!',
    this.subtitle = 'You finished this challenge!',
    required this.onContinue,
  });

  @override
  State<RewardAnimation> createState() => _RewardAnimationState();
}

class _RewardAnimationState extends State<RewardAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _revealedStars = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _controller.forward();
    _animateStars();
  }

  Future<void> _animateStars() async {
    for (int i = 1; i <= widget.stars; i++) {
      await Future.delayed(const Duration(milliseconds: 350));
      if (mounted) {
        setState(() {
          _revealedStars = i;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CelebrationAnimation(
      isPlaying: true,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: AppColors.accentYellowDark, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: AppFonts.fredoka(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.subtitle,
                textAlign: TextAlign.center,
                style: AppFonts.fredoka(
                  fontSize: 18,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 24),
              // 3 Stars Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  final isEarned = index < _revealedStars;
                  return AnimatedScale(
                    scale: isEarned ? 1.2 : 0.9,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.elasticOut,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        Icons.star_rounded,
                        size: 64,
                        color: isEarned
                            ? AppColors.accentYellow
                            : Colors.grey.shade300,
                        shadows: isEarned
                            ? [
                                Shadow(
                                  color: AppColors.accentYellowDark
                                      .withValues(alpha: 0.8),
                                  blurRadius: 16,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              // Continue Button
              BounceAnimation(
                onTap: widget.onContinue,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDark.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Keep Going!',
                      style: AppFonts.fredoka(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
