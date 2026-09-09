import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:alphabet_adventure/data/models/letter_data.dart';
import 'package:alphabet_adventure/data/services/audio_service.dart';
import 'package:alphabet_adventure/ui/core/animations/bounce_animation.dart';
import 'package:alphabet_adventure/ui/core/app_colors.dart';
import 'package:alphabet_adventure/ui/core/app_fonts.dart';
import 'package:alphabet_adventure/ui/core/widgets/animated_letter.dart';
import 'package:alphabet_adventure/ui/core/widgets/audio_replay_button.dart';
import 'package:alphabet_adventure/ui/core/widgets/interactive_object.dart';
import 'package:alphabet_adventure/ui/core/widgets/mascot_widget.dart';

/// Phase 1 view: Interactive Letter Introduction (PRS Section 11 & 13).
class LetterIntroView extends StatelessWidget {
  final LetterData letter;
  final VoidCallback onContinue;

  const LetterIntroView({
    super.key,
    required this.letter,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final audio = context.read<AudioService>();
    final vocabularyWords = letter.vocabularyWords;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          // Mascot speech bubble
          MascotWidget(
            mood: MascotMood.speaking,
            speechBubbleText: 'This is the letter "${letter.uppercase}"! It says ${letter.phonicsSound}!',
            size: 90,
          ),
          const SizedBox(height: 16),
          // Giant 3D Interactive Letter
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedLetter(
                letter: letter.uppercase,
                size: 130,
                primaryColor: AppColors.primary,
                shadowColor: AppColors.primaryDark,
                showSparkle: true,
                onTap: () {
                  audio.playLetterName(letter.char);
                },
              ),
              const SizedBox(width: 16),
              AnimatedLetter(
                letter: letter.lowercase,
                size: 100,
                primaryColor: AppColors.secondaryDark,
                shadowColor: AppColors.secondary,
                onTap: () {
                  audio.playPhonicsSound(letter.char);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Sound preview pill with Audio Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.accentYellowDark, width: 2.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AudioReplayButton(
                  size: 44,
                  onTap: () => audio.playPhonicsSound(letter.char),
                ),
                const SizedBox(width: 12),
                Text(
                  'Sound: ${letter.phonicsSound}',
                  style: AppFonts.fredoka(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Vocabulary Preview header
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Words starting with "${letter.uppercase}":',
                style: AppFonts.fredoka(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
            ),
          ),
          const SizedBox(height: 10),
          // 3 Vocabulary Cards Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: vocabularyWords.take(3).map((word) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InteractiveObject(
                    word: word,
                    size: 96,
                    onTap: () {
                      audio.playWord(word.word);
                    },
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          // Start Hunt Button
          BounceAnimation(
            onTap: onContinue,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accentGreen, AppColors.accentGreenDark],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentGreenDark.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Start Exploring!',
                    style: AppFonts.fredoka(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 28),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
