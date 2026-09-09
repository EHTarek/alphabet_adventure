import 'package:flutter/material.dart';

import 'package:alphabet_adventure/domain/engines/lesson_controller.dart';
import 'package:alphabet_adventure/domain/engines/question_engine.dart';
import 'package:alphabet_adventure/ui/core/app_colors.dart';
import 'package:alphabet_adventure/ui/core/app_fonts.dart';
import 'package:alphabet_adventure/ui/core/widgets/audio_replay_button.dart';
import 'package:alphabet_adventure/ui/core/widgets/interactive_object.dart';

/// Object Hunt mini-game view: Find the object that starts with target sound/letter.
class ObjectHuntView extends StatelessWidget {
  final ObjectHuntQuestion question;
  final LessonController controller;

  const ObjectHuntView({
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
          // Prompt Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
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
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ],
          const Spacer(),
          // 4 Interactive Objects Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.95,
            ),
            itemCount: question.options.length,
            itemBuilder: (context, index) {
              final wordOption = question.options[index];
              final isTarget = index == question.correctIndex;

              return InteractiveObject(
                word: wordOption,
                size: 130,
                isSelected: controller.hintRevealed && isTarget,
                onTap: controller.isProcessing
                    ? null
                    : () => controller.submitAnswer(index),
              );
            },
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
