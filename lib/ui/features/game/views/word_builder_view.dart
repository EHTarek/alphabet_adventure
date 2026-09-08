import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:alphabet_adventure/domain/engines/lesson_controller.dart';
import 'package:alphabet_adventure/domain/engines/question_engine.dart';
import 'package:alphabet_adventure/ui/core/animations/bounce_animation.dart';
import 'package:alphabet_adventure/ui/core/app_colors.dart';
import 'package:alphabet_adventure/ui/core/widgets/animated_letter.dart';
import 'package:alphabet_adventure/ui/core/widgets/audio_replay_button.dart';
import 'package:alphabet_adventure/ui/core/widgets/interactive_object.dart';

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

  @override
  Widget build(BuildContext context) {
    final targetLength = widget.question.targetLetters.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          // Prompt Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.secondaryDark, width: 2.5),
            ),
            child: Row(
              children: [
                AudioReplayButton(
                  size: 44,
                  onTap: () => widget.controller.replayAudio(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.question.prompt,
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
                    color: widget.controller.hintRevealed
                        ? AppColors.accentYellowDark
                        : Colors.grey.shade400,
                    size: 32,
                  ),
                  tooltip: 'Get a Hint',
                  onPressed: () => widget.controller.requestHint(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Word Picture Preview
          InteractiveObject(
            word: widget.question.targetWord,
            size: 100,
            showLabel: false,
          ),
          const SizedBox(height: 16),
          // Target Letter Slots. Wrap long words across multiple rows on phones.
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: List.generate(targetLength, (index) {
              final isFilled = index < _assembledLetters.length;
              final letter = isFilled ? _assembledLetters[index] : '';

              return BounceAnimation(
                onTap: isFilled ? () => _onSlotRemoved(index) : null,
                child: Container(
                  width: 54,
                  height: 64,
                  decoration: BoxDecoration(
                    color: isFilled ? AppColors.accentGreen : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isFilled
                          ? AppColors.accentGreenDark
                          : AppColors.secondaryDark,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      letter,
                      style: GoogleFonts.fredoka(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isFilled ? Colors.white : AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const Spacer(),
          // Available Letter Pool
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: List.generate(_availablePool.length, (index) {
              final letter = _availablePool[index];
              return AnimatedLetter(
                letter: letter,
                size: 64,
                primaryColor: AppColors.primary,
                shadowColor: AppColors.primaryDark,
                onTap: () => _onLetterSelected(letter, index),
              );
            }),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
