import 'package:flutter/material.dart';

import 'package:alphabet_adventure/domain/engines/lesson_controller.dart';
import 'package:alphabet_adventure/domain/engines/question_engine.dart';
import 'package:alphabet_adventure/ui/core/wood/wood.dart';
import 'package:alphabet_adventure/ui/features/game/views/letter_hunt_view.dart';
import 'package:alphabet_adventure/ui/features/game/views/object_hunt_view.dart';
import 'package:alphabet_adventure/ui/features/game/views/sound_match_view.dart';
import 'package:alphabet_adventure/ui/features/game/views/word_builder_view.dart';
import 'package:alphabet_adventure/ui/features/game/views/word_match_view.dart';
import 'package:alphabet_adventure/ui/features/game/widgets/game_wood_widgets.dart';

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
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 2),
            child: GamePopIn(
              trigger: controller.currentCombo,
              child: WoodPill(
                label: '${controller.currentCombo} IN A ROW!',
                colors: WoodColors.candyGold,
                fontSize: 18,
                leading: const Icon(
                  Icons.local_fire_department_rounded,
                  color: Color(0xFFEF5A50),
                  size: 26,
                  shadows: [
                    Shadow(color: Color(0xFF8C5A04), offset: Offset(0, 1.5)),
                  ],
                ),
              ),
            ),
          ),
        // Active Sub-Question View
        Expanded(
          child: switch (question) {
            LetterHuntQuestion q => LetterHuntView(
              question: q,
              controller: controller,
            ),
            ObjectHuntQuestion q => ObjectHuntView(
              question: q,
              controller: controller,
            ),
            SoundMatchQuestion q => SoundMatchView(
              question: q,
              controller: controller,
            ),
            WordMatchQuestion q => WordMatchView(
              question: q,
              controller: controller,
            ),
            WordBuilderQuestion q => WordBuilderView(
              question: q,
              controller: controller,
            ),
            _ => const Center(
              child: CircularProgressIndicator(color: WoodColors.goldBottom),
            ),
          },
        ),
      ],
    );
  }
}
