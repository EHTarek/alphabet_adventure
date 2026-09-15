import 'package:flutter/material.dart';

import 'package:alphabet_adventure/domain/engines/lesson_controller.dart';
import 'package:alphabet_adventure/domain/engines/question_engine.dart';
import 'package:alphabet_adventure/ui/features/game/widgets/game_wood_widgets.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Prompt Header
          GamePromptPanel(
            prompt: question.prompt,
            hintRevealed: controller.hintRevealed,
            onReplay: () => controller.replayAudio(),
            onHint: () => controller.requestHint(),
          ),
          if (controller.hintRevealed) ...[
            const SizedBox(height: 10),
            GameHintNote(text: question.hintText),
          ],
          const SizedBox(height: 12),
          // Interactive Objects on a board
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
