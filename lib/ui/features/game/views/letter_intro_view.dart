import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:alphabet_adventure/data/models/letter_data.dart';
import 'package:alphabet_adventure/data/services/audio_service.dart';
import 'package:alphabet_adventure/ui/core/widgets/audio_replay_button.dart';
import 'package:alphabet_adventure/ui/core/widgets/interactive_object.dart';
import 'package:alphabet_adventure/ui/core/widgets/letter_example_overlay.dart';
import 'package:alphabet_adventure/ui/core/widgets/mascot_widget.dart';
import 'package:alphabet_adventure/ui/core/wood/wood.dart';
import 'package:alphabet_adventure/ui/features/game/widgets/game_wood_widgets.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Mascot speech bubble
          MascotWidget(
            mood: MascotMood.speaking,
            speechBubbleText:
                'This is the letter "${letter.uppercase}"! It says ${letter.phonicsSound}!',
            size: 90,
          ),
          const SizedBox(height: 12),
          // Giant candy letter blocks on a recessed board
          GameBoard(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GameBoardCell(
                  width: 150,
                  height: 150,
                  radius: 22,
                  child: GameLetterBlock(
                    letter: letter.uppercase,
                    tone: WoodColors.candyBlue,
                    size: 128,
                    sparkle: true,
                    onTap: () {
                      audio.playLetterName(letter.char);
                      showLetterExampleOverlay(context, letter);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                GameBoardCell(
                  width: 118,
                  height: 118,
                  radius: 20,
                  child: GameLetterBlock(
                    letter: letter.lowercase,
                    tone: WoodColors.candyPurple,
                    size: 98,
                    onTap: () {
                      audio.playPhonicsSound(letter.char);
                      showLetterExampleOverlay(
                        context,
                        letter,
                        lowercase: true,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Sound preview pill with Audio Button
          WoodPanel(
            radius: 40,
            depth: 5,
            padding: const EdgeInsets.fromLTRB(8, 6, 22, 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AudioReplayButton(
                  size: 48,
                  onTap: () => audio.playPhonicsSound(letter.char),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    'Sound: ${letter.phonicsSound}',
                    style: WoodText.heading(fontSize: 22),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // Vocabulary preview: header and word cards on a pale wooden tray
          WoodPanel(
            radius: 26,
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
            child: Column(
              children: [
                // Vocabulary Preview header
                Text(
                  'Words starting with "${letter.uppercase}":',
                  textAlign: TextAlign.center,
                  style: WoodText.heading(fontSize: 19),
                ),
                const SizedBox(height: 10),
                // 3 Vocabulary Cards Row
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cardSize = math.min(
                      96.0,
                      constraints.maxWidth / 3 - 8,
                    );
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: vocabularyWords.take(3).map((word) {
                        return Expanded(
                          child: Center(
                            child: InteractiveObject(
                              word: word,
                              size: cardSize,
                              // The overlay says the word once it has popped in.
                              onTap: () =>
                                  showWordExampleOverlay(context, word),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          // Start Hunt Button
          WoodButton(
            tone: WoodTone.green,
            width: double.infinity,
            height: 70,
            radius: 24,
            depth: 8,
            onPressed: onContinue,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Start Exploring!',
                  style: WoodText.button(fontSize: 26, color: Colors.white)
                      .copyWith(
                        shadows: const [
                          Shadow(
                            color: Color(0xFF145A2E),
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, size: 32),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
