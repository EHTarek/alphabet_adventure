import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:alphabet_adventure/domain/engines/lesson_controller.dart';
import 'package:alphabet_adventure/domain/engines/question_engine.dart';
import 'package:alphabet_adventure/ui/features/game/widgets/game_wood_widgets.dart';

/// Letter Hunt mini-game view: Find the target letter among multiple floating letters.
class LetterHuntView extends StatefulWidget {
  final LetterHuntQuestion question;
  final LessonController controller;

  const LetterHuntView({
    super.key,
    required this.question,
    required this.controller,
  });

  @override
  State<LetterHuntView> createState() => _LetterHuntViewState();
}

class _LetterHuntViewState extends State<LetterHuntView> {
  /// The option the child last tapped, tinted while feedback shows.
  int? _picked;

  @override
  void didUpdateWidget(LetterHuntView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) _picked = null;
  }

  void _pick(int index) {
    setState(() => _picked = index);
    widget.controller.submitAnswer(index);
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.question;
    final controller = widget.controller;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Prompt Header
          GamePromptPanel(
            prompt: question.prompt,
            fontSize: 20,
            hintRevealed: controller.hintRevealed,
            onReplay: () => controller.replayAudio(),
            onHint: () => controller.requestHint(),
          ),
          if (controller.hintRevealed) ...[
            const SizedBox(height: 10),
            GameHintNote(text: question.hintText),
          ],
          const SizedBox(height: 12),
          // 4 Letter Choices on a block board
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const columns = 2;
                final rows = (question.options.length / columns).ceil();
                const gap = 12.0;
                const boardInset = 12.0 * 2 + 6 + 8;
                final cell = math
                    .min(
                      (constraints.maxWidth - boardInset - gap) / columns,
                      (constraints.maxHeight - boardInset - gap * (rows - 1)) /
                          rows,
                    )
                    .clamp(64.0, 160.0);

                return Center(
                  child: GameBoard(
                    child: Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: List.generate(question.options.length, (index) {
                        final letterOption = question.options[index];
                        final isTarget = index == question.correctIndex;
                        final tone =
                            gameFeedbackTone(
                              controller,
                              isPicked: _picked == index,
                            ) ??
                            gameChoiceTones[index % gameChoiceTones.length];

                        return SizedBox(
                          width: cell,
                          height: cell,
                          child: GameBoardCell(
                            radius: cell * 0.2,
                            highlight: controller.hintRevealed && isTarget,
                            child: GameLetterBlock(
                              letter: letterOption,
                              tone: tone,
                              size: cell * 0.8,
                              sparkle: controller.hintRevealed && isTarget,
                              onTap: controller.isProcessing
                                  ? null
                                  : () => _pick(index),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
