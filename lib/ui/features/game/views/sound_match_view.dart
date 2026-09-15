import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:alphabet_adventure/domain/engines/lesson_controller.dart';
import 'package:alphabet_adventure/domain/engines/question_engine.dart';
import 'package:alphabet_adventure/ui/core/widgets/audio_replay_button.dart';
import 'package:alphabet_adventure/ui/core/wood/wood.dart';
import 'package:alphabet_adventure/ui/features/game/widgets/game_wood_widgets.dart';

/// Sound Match mini-game view: Listen to phonics sound and identify the matching letter.
class SoundMatchView extends StatefulWidget {
  final SoundMatchQuestion question;
  final LessonController controller;

  const SoundMatchView({
    super.key,
    required this.question,
    required this.controller,
  });

  @override
  State<SoundMatchView> createState() => _SoundMatchViewState();
}

class _SoundMatchViewState extends State<SoundMatchView> {
  /// The option the child last tapped, tinted while feedback shows.
  int? _picked;

  @override
  void didUpdateWidget(SoundMatchView oldWidget) {
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
          // Prompt Banner
          GamePromptPanel(
            prompt: 'Listen to the sound and choose the letter!',
            hintRevealed: controller.hintRevealed,
            onHint: () => controller.requestHint(),
          ),
          const SizedBox(height: 20),
          // Giant Central Listening Button
          Column(
            children: [
              AudioReplayButton(
                size: 110,
                backgroundColor: WoodColors.candyPurple.bottom,
                onTap: () => controller.replayAudio(),
              ),
              const SizedBox(height: 14),
              WoodPill(
                label: 'Tap to hear sound',
                colors: WoodColors.candyPurple,
                leading: const Icon(
                  Icons.hearing_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Letter Options on a block board: a row of three, or two by two
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final count = question.options.length;
                final columns = count == 4 ? 2 : count;
                final rows = (count / columns).ceil();
                const gap = 12.0;
                const insetX = 12.0 * 2;
                const insetY = 12.0 * 2 + 7;
                final cell = math
                    .min(
                      (constraints.maxWidth - insetX - gap * (columns - 1)) /
                          columns,
                      (constraints.maxHeight - insetY - gap * (rows - 1)) /
                          rows,
                    )
                    .clamp(60.0, 130.0);

                return Center(
                  child: GameBoard(
                    child: SizedBox(
                      width: cell * columns + gap * (columns - 1),
                      child: Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: List.generate(count, (index) {
                          final letterOption = question.options[index];
                          final isTarget = index == question.correctIndex;
                          final tone =
                              gameFeedbackTone(
                                controller,
                                isPicked: _picked == index,
                              ) ??
                              gameChoiceTones[index % gameChoiceTones.length];

                          return GameBoardCell(
                            width: cell,
                            height: cell,
                            radius: cell * 0.22,
                            highlight: controller.hintRevealed && isTarget,
                            child: GameLetterBlock(
                              letter:
                                  '${letterOption.uppercase}${letterOption.lowercase}',
                              tone: tone,
                              size: cell * 0.82,
                              sparkle: controller.hintRevealed && isTarget,
                              onTap: controller.isProcessing
                                  ? null
                                  : () => _pick(index),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
