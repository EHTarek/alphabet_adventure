import 'package:flutter/material.dart';

import 'package:alphabet_adventure/domain/engines/lesson_controller.dart';
import 'package:alphabet_adventure/domain/engines/question_engine.dart';
import 'package:alphabet_adventure/ui/features/game/widgets/game_wood_widgets.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          GamePromptPanel(
            prompt: question.prompt,
            hintRevealed: controller.hintRevealed,
            onReplay: controller.replayAudio,
            onHint: controller.requestHint,
          ),
          if (controller.hintRevealed) ...[
            const SizedBox(height: 10),
            GameHintNote(text: question.hintText),
          ],
          const SizedBox(height: 12),
          Expanded(
            child: GameWordChoiceBoard(
              questionId: question.id,
              options: question.options,
              correctIndex: question.correctIndex,
              controller: controller,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
