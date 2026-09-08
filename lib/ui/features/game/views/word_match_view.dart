import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:alphabet_adventure/domain/engines/lesson_controller.dart';
import 'package:alphabet_adventure/domain/engines/question_engine.dart';
import 'package:alphabet_adventure/ui/core/app_colors.dart';
import 'package:alphabet_adventure/ui/core/widgets/audio_replay_button.dart';
import 'package:alphabet_adventure/ui/core/widgets/interactive_object.dart';

/// Word Match mini-game view: match the spoken word to a vocabulary object.
class WordMatchView extends StatelessWidget {
  final WordMatchQuestion question;
  final LessonController controller;

  const WordMatchView({
    super.key,
    required this.question,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.accentPurple, width: 2.5),
            ),
            child: Row(
              children: [
                AudioReplayButton(
                  size: 44,
                  onTap: controller.replayAudio,
                  backgroundColor: AppColors.accentPurple,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.prompt,
                    style: GoogleFonts.fredoka(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.lightbulb_rounded,
                    color: controller.hintRevealed
                        ? AppColors.accentYellowDark
                        : Colors.grey.shade400,
                    size: 32,
                  ),
                  tooltip: 'Get a Hint',
                  onPressed: controller.requestHint,
                ),
              ],
            ),
          ),
          if (controller.hintRevealed) ...[
            const SizedBox(height: 10),
            Text(
              question.hintText,
              style: GoogleFonts.fredoka(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.95,
              ),
              itemCount: question.options.length,
              itemBuilder: (context, index) {
                final option = question.options[index];
                final isTarget = index == question.correctIndex;
                return InteractiveObject(
                  word: option,
                  size: 130,
                  isSelected: controller.hintRevealed && isTarget,
                  onTap: controller.isProcessing
                      ? null
                      : () => controller.submitAnswer(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
