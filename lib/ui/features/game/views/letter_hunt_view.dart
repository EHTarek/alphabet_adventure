import 'package:flutter/material.dart';

import 'package:alphabet_adventure/domain/engines/lesson_controller.dart';
import 'package:alphabet_adventure/domain/engines/question_engine.dart';
import 'package:alphabet_adventure/ui/core/app_colors.dart';
import 'package:alphabet_adventure/ui/core/app_fonts.dart';
import 'package:alphabet_adventure/ui/core/widgets/animated_letter.dart';
import 'package:alphabet_adventure/ui/core/widgets/audio_replay_button.dart';

/// Letter Hunt mini-game view: Find the target letter among multiple floating letters.
class LetterHuntView extends StatelessWidget {
  final LetterHuntQuestion question;
  final LessonController controller;

  const LetterHuntView({
    super.key,
    required this.question,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppColors.primary,
      AppColors.secondaryDark,
      AppColors.accentOrange,
      AppColors.accentPurple,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          // Prompt Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.secondaryDark, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              children: [
                AudioReplayButton(
                  size: 44,
                  onTap: () => controller.replayAudio(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.prompt,
                    style: AppFonts.fredoka(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                // Hint Button
                IconButton(
                  icon: Icon(
                    Icons.lightbulb_rounded,
                    color: controller.hintRevealed
                        ? AppColors.accentYellowDark
                        : Colors.grey.shade400,
                    size: 32,
                  ),
                  tooltip: 'Get a Hint',
                  onPressed: () => controller.requestHint(),
                ),
              ],
            ),
          ),
          if (controller.hintRevealed) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accentYellow.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.accentYellowDark, width: 1.5),
              ),
              child: Text(
                question.hintText,
                style: AppFonts.fredoka(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ],
          const Spacer(),
          // 4 Letter Choices Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.1,
            ),
            itemCount: question.options.length,
            itemBuilder: (context, index) {
              final letterOption = question.options[index];
              final isTarget = index == question.correctIndex;
              final color = colors[index % colors.length];

              return Center(
                child: AnimatedLetter(
                  letter: letterOption,
                  size: 110,
                  primaryColor: color,
                  shadowColor: color.withValues(alpha: 0.8),
                  showSparkle: controller.hintRevealed && isTarget,
                  onTap: controller.isProcessing
                      ? null
                      : () => controller.submitAnswer(index),
                ),
              );
            },
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
