import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:alphabet_adventure/domain/engines/lesson_controller.dart';
import 'package:alphabet_adventure/domain/engines/question_engine.dart';
import 'package:alphabet_adventure/ui/core/animations/bounce_animation.dart';
import 'package:alphabet_adventure/ui/core/widgets/interactive_object.dart';
import 'package:alphabet_adventure/ui/core/wood/wood.dart';
import 'package:alphabet_adventure/ui/features/game/widgets/game_wood_widgets.dart';

/// Word Builder mini-game view: Assemble scrambled letters to spell the target word.
class WordBuilderView extends StatefulWidget {
  final WordBuilderQuestion question;
  final LessonController controller;

  const WordBuilderView({
    super.key,
    required this.question,
    required this.controller,
  });

  @override
  State<WordBuilderView> createState() => _WordBuilderViewState();
}

class _WordBuilderViewState extends State<WordBuilderView> {
  final List<String> _assembledLetters = [];
  late List<String> _availablePool;

  @override
  void initState() {
    super.initState();
    _resetPool();
  }

  @override
  void didUpdateWidget(WordBuilderView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      _resetPool();
    }
  }

  void _resetPool() {
    _assembledLetters.clear();
    _availablePool = List.from(widget.question.scrambledPool);
  }

  void _onLetterSelected(String letter, int poolIndex) {
    if (widget.controller.isProcessing) return;
    if (_assembledLetters.length >= widget.question.targetLetters.length) {
      return;
    }

    setState(() {
      _availablePool.removeAt(poolIndex);
      _assembledLetters.add(letter);
    });

    // Check if fully assembled
    if (_assembledLetters.length == widget.question.targetLetters.length) {
      widget.controller.submitAnswer(_assembledLetters);
    }
  }

  void _onSlotRemoved(int slotIndex) {
    if (widget.controller.isProcessing) return;
    if (slotIndex >= _assembledLetters.length) return;

    setState(() {
      final removed = _assembledLetters.removeAt(slotIndex);
      _availablePool.add(removed);
    });
  }

  /// Candy colour for a letter, stable as it moves between pool and slots.
  WoodToneColors _toneFor(String letter) {
    final code = letter.isEmpty ? 0 : letter.toUpperCase().codeUnitAt(0);
    return WoodColors.blockCycle[code % WoodColors.blockCycle.length];
  }

  @override
  Widget build(BuildContext context) {
    final targetLength = widget.question.targetLetters.length;
    final controller = widget.controller;

    // Scrolls only when a long word and pool outgrow a short screen.
    return LayoutBuilder(
      builder: (context, constraints) {
        final innerWidth = constraints.maxWidth - 32;
        final compact = constraints.maxHeight < 640;
        // Slots grow for short words; long words wrap into even rows.
        const slotGap = 8.0;
        final boardWidth = innerWidth - 20;
        final maxPerRow = math.max(1, ((boardWidth + slotGap) / 58).floor());
        final rows = (targetLength / maxPerRow).ceil();
        final perRow = math.max(1, (targetLength / math.max(1, rows)).ceil());
        final slotWidth = ((boardWidth - slotGap * (perRow - 1)) / perRow)
            .clamp(50.0, 78.0);
        final poolBlock = ((innerWidth - 20 - 10 * 4) / 5).clamp(50.0, 68.0);
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: math.max(0, constraints.maxHeight - 16),
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // Prompt Header
                  GamePromptPanel(
                    prompt: widget.question.prompt,
                    hintRevealed: controller.hintRevealed,
                    onReplay: () => controller.replayAudio(),
                    onHint: () => controller.requestHint(),
                  ),
                  const SizedBox(height: 14),
                  // Word Picture Preview
                  InteractiveObject(
                    word: widget.question.targetWord,
                    size: compact ? 84 : 120,
                    showLabel: false,
                  ),
                  const SizedBox(height: 14),
                  // Target Letter Slots: recessed board cells that candy blocks drop
                  // into. Long words wrap across rows on phones.
                  GameBoard(
                    padding: const EdgeInsets.all(10),
                    child: SizedBox(
                      width: perRow * slotWidth + slotGap * (perRow - 1),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: slotGap,
                        runSpacing: slotGap,
                        children: List.generate(targetLength, (index) {
                          final isFilled = index < _assembledLetters.length;
                          final letter = isFilled
                              ? _assembledLetters[index]
                              : '';
                          final status = controller.feedbackStatus;
                          final tone = switch (status) {
                            AnswerFeedbackStatus.correct =>
                              WoodColors.candyGreen,
                            AnswerFeedbackStatus.tryAgain =>
                              WoodColors.candyOrange,
                            AnswerFeedbackStatus.none => _toneFor(letter),
                          };

                          return BounceAnimation(
                            playTapSound: false,
                            onTap: isFilled
                                ? () => _onSlotRemoved(index)
                                : null,
                            child: GameBoardCell(
                              width: slotWidth,
                              height: slotWidth * 1.14,
                              radius: slotWidth * 0.26,
                              highlight: index == _assembledLetters.length,
                              child: isFilled
                                  ? GamePopIn(
                                      trigger: '$index-$letter',
                                      from: 0.7,
                                      dropFrom: -26,
                                      child: CandyBlock(
                                        colors: tone,
                                        size: slotWidth * 0.8,
                                        letter: letter,
                                      ),
                                    )
                                  : null,
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Available Letter Pool on a pale wooden tray
                  if (_availablePool.isNotEmpty)
                    WoodPanel(
                      radius: 26,
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(10, 14, 10, 14),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: List.generate(_availablePool.length, (index) {
                          final letter = _availablePool[index];
                          return GameLetterBlock(
                            letter: letter,
                            tone: _toneFor(letter),
                            size: poolBlock,
                            onTap: () => _onLetterSelected(letter, index),
                          );
                        }),
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
