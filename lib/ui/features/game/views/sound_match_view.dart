import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:alphabet_adventure/domain/engines/lesson_controller.dart';
import 'package:alphabet_adventure/domain/engines/question_engine.dart';
import 'package:alphabet_adventure/ui/core/app_colors.dart';
import 'package:alphabet_adventure/ui/core/widgets/animated_letter.dart';
import 'package:alphabet_adventure/ui/core/widgets/audio_replay_button.dart';

/// Sound Match mini-game view: Listen to phonics sound and identify the matching letter.
class SoundMatchView extends StatelessWidget {
  final SoundMatchQuestion question;
  final LessonController controller;

  const SoundMatchView({
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
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          // Prompt Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.secondaryDark, width: 2.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Listen to the sound and choose the letter!',
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
                  onPressed: () => controller.requestHint(),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Giant Central Listening Button
          Column(
            children: [
              AudioReplayButton(
                size: 96,
                backgroundColor: AppColors.accentPurple,
                onTap: () => controller.replayAudio(),
              ),
              const SizedBox(height: 12),
              Text(
                'Tap to hear sound',
                style: GoogleFonts.fredoka(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentPurple,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Letter Options Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(question.options.length, (index) {
              final letterOption = question.options[index];
              final isTarget = index == question.correctIndex;
              final color = colors[index % colors.length];

              return AnimatedLetter(
                letter: '${letterOption.uppercase}${letterOption.lowercase}',
                size: 96,
                primaryColor: color,
                shadowColor: color.withValues(alpha: 0.8),
                showSparkle: controller.hintRevealed && isTarget,
                onTap: controller.isProcessing
                    ? null
                    : () => controller.submitAnswer(index),
              );
            }),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
