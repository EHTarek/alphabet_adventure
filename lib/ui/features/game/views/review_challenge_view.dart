import 'package:flutter/material.dart';

import 'package:alphabet_adventure/domain/engines/lesson_controller.dart';
import 'package:alphabet_adventure/domain/engines/question_engine.dart';
import 'package:alphabet_adventure/ui/core/app_colors.dart';
import 'package:alphabet_adventure/ui/core/app_fonts.dart';
import 'package:alphabet_adventure/ui/features/game/views/letter_hunt_view.dart';
import 'package:alphabet_adventure/ui/features/game/views/object_hunt_view.dart';
import 'package:alphabet_adventure/ui/features/game/views/sound_match_view.dart';
import 'package:alphabet_adventure/ui/features/game/views/word_builder_view.dart';
import 'package:alphabet_adventure/ui/features/game/views/word_match_view.dart';

/// Review challenge view hosting dynamic mixed rapid-fire questions (PRS Section 11 & 12).
class ReviewChallengeView extends StatelessWidget {
  final ChallengeQuestion question;
  final LessonController controller;

  const ReviewChallengeView({
    super.key,
    required this.question,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Combo Streak Indicator
        if (controller.currentCombo >= 2)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.accentOrange, AppColors.accentYellow],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentOrange.withValues(alpha: 0.4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 4),
                Text(
                  '${controller.currentCombo} IN A ROW!',
                  style: AppFonts.fredoka(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        // Active Sub-Question View
        Expanded(
          child: switch (question) {
            LetterHuntQuestion q => LetterHuntView(question: q, controller: controller),
            ObjectHuntQuestion q => ObjectHuntView(question: q, controller: controller),
            SoundMatchQuestion q => SoundMatchView(question: q, controller: controller),
            WordMatchQuestion q => WordMatchView(question: q, controller: controller),
            WordBuilderQuestion q => WordBuilderView(question: q, controller: controller),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
      ],
    );
  }
}
