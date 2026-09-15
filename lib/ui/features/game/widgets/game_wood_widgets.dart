import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:alphabet_adventure/data/models/word_data.dart';
import 'package:alphabet_adventure/domain/engines/lesson_controller.dart';
import 'package:alphabet_adventure/ui/core/widgets/animated_letter.dart';
import 'package:alphabet_adventure/ui/core/widgets/audio_replay_button.dart';
import 'package:alphabet_adventure/ui/core/widgets/interactive_object.dart';
import 'package:alphabet_adventure/ui/core/wood/wood.dart';

/// Candy colours for answer blocks. Green and orange are left out so they can
/// signal "correct" and "try again" without being mistaken for a choice.
const List<WoodToneColors> gameChoiceTones = [
  WoodColors.candyBlue,
  WoodColors.candyPurple,
  WoodToneColors(
    top: Color(0xFF4FD1CB),
    bottom: Color(0xFF1FA7A6),
    rim: Color(0xFF137676),
    bevel: Color(0xFF0C5454),
    highlight: Color(0xFFC6F5F2),
    ink: Color(0xFFFFFFFF),
  ),
  WoodColors.candyRed,
];

/// The feedback tone for a choice: green or orange while the controller is
/// showing feedback for the choice the child picked, otherwise null.
WoodToneColors? gameFeedbackTone(
  LessonController controller, {
  required bool isPicked,
}) {
  if (!isPicked) return null;
  return switch (controller.feedbackStatus) {
    AnswerFeedbackStatus.correct => WoodColors.candyGreen,
    AnswerFeedbackStatus.tryAgain => WoodColors.candyOrange,
    AnswerFeedbackStatus.none => null,
  };
}

/// The instruction slab at the top of every game phase: a pale wooden panel
/// with an optional listen button, the prompt in walnut ink and a hint button.
class GamePromptPanel extends StatelessWidget {
  const GamePromptPanel({
    super.key,
    required this.prompt,
    required this.hintRevealed,
    required this.onHint,
    this.onReplay,
    this.fontSize = 19,
  });

  final String prompt;
  final bool hintRevealed;
  final VoidCallback onHint;

  /// Shows a listen button in front of the prompt when set.
  final VoidCallback? onReplay;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return WoodPanel(
      radius: 24,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Row(
        children: [
          if (onReplay != null) ...[
            AudioReplayButton(size: 48, onTap: onReplay!),
            const SizedBox(width: 10),
          ] else
            const SizedBox(width: 8),
          Expanded(
            child: Text(prompt, style: WoodText.heading(fontSize: fontSize)),
          ),
          const SizedBox(width: 8),
          GameHintButton(revealed: hintRevealed, onPressed: onHint),
        ],
      ),
    );
  }
}

/// A square wooden lightbulb button that turns golden once the hint shows.
class GameHintButton extends StatelessWidget {
  const GameHintButton({
    super.key,
    required this.revealed,
    required this.onPressed,
  });

  final bool revealed;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return WoodIconButton(
      icon: Icons.lightbulb_rounded,
      tone: revealed ? WoodTone.gold : WoodTone.light,
      size: 48,
      iconSize: 30,
      tooltip: 'Get a Hint',
      onPressed: onPressed,
    );
  }
}

/// The revealed hint: a parchment note tucked under the prompt.
class GameHintNote extends StatelessWidget {
  const GameHintNote({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.6, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
        decoration: BoxDecoration(
          color: WoodColors.parchment,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: WoodColors.parchmentEdge, width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lightbulb_rounded,
              color: WoodColors.goldBottom,
              size: 24,
              shadows: [
                Shadow(color: WoodColors.goldOutline, offset: Offset(0, 1.5)),
              ],
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                style: WoodText.body(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A dark walnut board holding recessed cells, like a block-puzzle grid.
class GameBoard extends StatelessWidget {
  const GameBoard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return WoodPanel(
      tone: WoodTone.dark,
      radius: 26,
      depth: 7,
      padding: padding,
      child: child,
    );
  }
}

/// One recessed board cell: a dark hollow with an inner shadow along its top.
class GameBoardCell extends StatelessWidget {
  const GameBoardCell({
    super.key,
    this.child,
    this.width,
    this.height,
    this.radius = 18,
    this.highlight = false,
  });

  final Widget? child;
  final double? width;
  final double? height;
  final double radius;

  /// Rims the cell in gold, e.g. for the next slot to fill.
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: WoodColors.cellLine,
        border: Border.all(
          color: highlight
              ? WoodColors.goldBottom
              : WoodColors.cellLine.withValues(alpha: 0.9),
          width: 2.5,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(top: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius - 3),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5A2E15), WoodColors.cellDark],
          ),
        ),
        child: child == null ? null : Center(child: child),
      ),
    );
  }
}

/// A tappable candy letter block in [tone], with the hint sparkle and a golden
/// glow while [selected].
class GameLetterBlock extends StatelessWidget {
  const GameLetterBlock({
    super.key,
    required this.letter,
    required this.tone,
    required this.size,
    this.onTap,
    this.selected = false,
    this.sparkle = false,
  });

  final String letter;
  final WoodToneColors tone;
  final double size;
  final VoidCallback? onTap;
  final bool selected;
  final bool sparkle;

  @override
  Widget build(BuildContext context) {
    return AnimatedLetter(
      letter: letter,
      size: size,
      primaryColor: tone.bottom,
      shadowColor: tone.rim,
      isSelected: selected,
      showSparkle: sparkle,
      onTap: onTap,
    );
  }
}

/// Pops [child] in with a little overshoot whenever [trigger] changes.
class GamePopIn extends StatelessWidget {
  const GamePopIn({
    super.key,
    required this.trigger,
    required this.child,
    this.from = 0.5,
    this.dropFrom = 0,
  });

  final Object trigger;
  final Widget child;

  /// Starting scale.
  final double from;

  /// Starting vertical offset, for blocks dropping into place.
  final double dropFrom;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(trigger),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutBack,
      builder: (context, t, child) => Transform.translate(
        offset: Offset(0, dropFrom * (1 - t)),
        child: Transform.scale(scale: from + (1 - from) * t, child: child),
      ),
      child: child,
    );
  }
}

/// Picture answer tiles laid out two by two on a dark board, sized to the
/// space available. The tapped tile turns green or red while feedback shows.
class GameWordChoiceBoard extends StatefulWidget {
  const GameWordChoiceBoard({
    super.key,
    required this.questionId,
    required this.options,
    required this.correctIndex,
    required this.controller,
  });

  final String questionId;
  final List<WordData> options;
  final int correctIndex;
  final LessonController controller;

  @override
  State<GameWordChoiceBoard> createState() => _GameWordChoiceBoardState();
}

class _GameWordChoiceBoardState extends State<GameWordChoiceBoard> {
  int? _picked;

  @override
  void didUpdateWidget(GameWordChoiceBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.questionId != widget.questionId) _picked = null;
  }

  void _pick(int index) {
    setState(() => _picked = index);
    widget.controller.submitAnswer(index);
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final status = controller.feedbackStatus;
    return LayoutBuilder(
      builder: (context, constraints) {
        const columns = 2;
        final rows = (widget.options.length / columns).ceil();
        const gap = 12.0;
        const insetX = 14.0 * 2;
        const insetY = 14.0 * 2 + 7;
        final byWidth = (constraints.maxWidth - insetX - gap) / columns;
        final byHeight =
            (constraints.maxHeight - insetY - gap * (rows - 1)) / rows / 1.25;
        final size = math.min(byWidth, byHeight).clamp(72.0, 170.0);

        return Center(
          child: GameBoard(
            padding: const EdgeInsets.all(14),
            child: SizedBox(
              width: size * columns + gap,
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: gap,
                runSpacing: gap,
                children: List.generate(widget.options.length, (index) {
                  final isTarget = index == widget.correctIndex;
                  final isPicked = _picked == index;
                  return InteractiveObject(
                    word: widget.options[index],
                    size: size,
                    isSelected: controller.hintRevealed && isTarget,
                    isCorrect:
                        isPicked && status == AnswerFeedbackStatus.correct,
                    isIncorrect:
                        isPicked && status == AnswerFeedbackStatus.tryAgain,
                    onTap: controller.isProcessing ? null : () => _pick(index),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}
