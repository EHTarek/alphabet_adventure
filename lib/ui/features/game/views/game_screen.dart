import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:alphabet_adventure/data/repositories/progress_repository.dart';
import 'package:alphabet_adventure/domain/engines/lesson_controller.dart';
import 'package:alphabet_adventure/domain/engines/question_engine.dart';
import 'package:alphabet_adventure/ui/core/animations/celebration_animation.dart';
import 'package:alphabet_adventure/ui/core/widgets/star_counter.dart';
import 'package:alphabet_adventure/ui/core/wood/wood.dart';
import 'package:alphabet_adventure/ui/features/game/views/letter_intro_view.dart';
import 'package:alphabet_adventure/ui/features/game/views/object_hunt_view.dart';
import 'package:alphabet_adventure/ui/features/game/views/review_challenge_view.dart';
import 'package:alphabet_adventure/ui/features/game/views/sound_match_view.dart';
import 'package:alphabet_adventure/ui/features/game/views/word_builder_view.dart';
import 'package:alphabet_adventure/ui/features/game/views/word_match_view.dart';
import 'package:alphabet_adventure/ui/features/game/widgets/game_wood_widgets.dart';

/// Main game viewport shell hosting the 5 lesson phases with top HUD and feedback overlays.
class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LessonController>();
    final lesson = controller.currentLesson;
    final progressRepo = context.watch<ProgressRepository>();

    if (lesson == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: WoodPanel(
              radius: 28,
              depth: 8,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'No lesson selected',
                    textAlign: TextAlign.center,
                    style: WoodText.heading(fontSize: 22),
                  ),
                  const SizedBox(height: 18),
                  WoodButton(
                    tone: WoodTone.green,
                    height: 60,
                    onPressed: () => context.go('/world_map'),
                    child: Text(
                      'Back to Map',
                      style: WoodText.button(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Check if lesson reached celebration phase -> go to complete screen
    if (controller.currentPhase == LessonPhase.celebration) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/lesson_complete');
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Top HUD: Exit button, Phase Progress, Star Counter
                _buildTopHUD(context, controller, progressRepo.totalStars),
                const SizedBox(height: 4),
                // Main Interactive Game View based on phase
                Expanded(child: _buildPhaseView(controller)),
              ],
            ),
          ),
          // Encouraging Feedback Overlay
          if (controller.feedbackStatus == AnswerFeedbackStatus.correct)
            _buildSuccessOverlay(context, controller.feedbackMessage),
          if (controller.feedbackStatus == AnswerFeedbackStatus.tryAgain)
            _buildTryAgainOverlay(context, controller.feedbackMessage),
        ],
      ),
    );
  }

  Widget _buildTopHUD(
    BuildContext context,
    LessonController controller,
    int totalStars,
  ) {
    final letter = controller.currentLesson?.letter;
    final currentPhaseIndex = controller.currentPhase.index;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: WoodPanel(
        tone: WoodTone.dark,
        radius: 24,
        depth: 6,
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: Row(
          children: [
            // Back / Home Button
            WoodIconButton(
              icon: Icons.home_rounded,
              size: 48,
              iconSize: 30,
              tooltip: 'Exit lesson',
              onPressed: () => _confirmExit(context),
            ),
            const SizedBox(width: 8),
            // Letter Badge
            if (letter != null) ...[
              CandyBlock(
                colors: WoodColors.candyGold,
                size: 42,
                letter: '${letter.uppercase}${letter.lowercase}',
              ),
              const SizedBox(width: 10),
            ],
            // Phase Progress: one recessed cell per phase, filled with candy
            Expanded(child: _PhaseProgress(currentIndex: currentPhaseIndex)),
            const SizedBox(width: 10),
            // Star Counter
            StarCounter(count: totalStars),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseView(LessonController controller) {
    switch (controller.currentPhase) {
      case LessonPhase.introduction:
        return LetterIntroView(
          letter: controller.currentLesson!.letter,
          onContinue: () => controller.advancePhase(),
        );

      case LessonPhase.objectHunt:
        if (controller.currentQuestion is ObjectHuntQuestion) {
          return ObjectHuntView(
            question: controller.currentQuestion as ObjectHuntQuestion,
            controller: controller,
          );
        }
        return const _PhaseLoading();

      case LessonPhase.miniGame:
        if (controller.currentQuestion is WordBuilderQuestion) {
          return WordBuilderView(
            question: controller.currentQuestion as WordBuilderQuestion,
            controller: controller,
          );
        } else if (controller.currentQuestion is WordMatchQuestion) {
          return WordMatchView(
            question: controller.currentQuestion as WordMatchQuestion,
            controller: controller,
          );
        } else if (controller.currentQuestion is SoundMatchQuestion) {
          return SoundMatchView(
            question: controller.currentQuestion as SoundMatchQuestion,
            controller: controller,
          );
        }
        return const _PhaseLoading();

      case LessonPhase.review:
        if (controller.currentQuestion != null) {
          return ReviewChallengeView(
            question: controller.currentQuestion!,
            controller: controller,
          );
        }
        return const _PhaseLoading();

      case LessonPhase.celebration:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSuccessOverlay(BuildContext context, String? message) {
    return Positioned.fill(
      child: CelebrationAnimation(
        isPlaying: true,
        child: Container(
          color: Colors.black.withValues(alpha: 0.22),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: GamePopIn(
              trigger: message ?? '',
              from: 0.4,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 56),
                    child: WoodPanel(
                      tone: WoodTone.dark,
                      radius: 28,
                      depth: 8,
                      padding: const EdgeInsets.fromLTRB(28, 44, 28, 20),
                      child: WoodTitle(
                        message ?? 'Awesome!',
                        fontSize: 32,
                        maxLines: 2,
                      ),
                    ),
                  ),
                  const _StarBurst(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTryAgainOverlay(BuildContext context, String? message) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.1),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        // Sits low so the picked answer, now orange, stays in view.
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: 28),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GamePopIn(
              trigger: message ?? '',
              from: 0.6,
              child: WoodPanel(
                tone: WoodTone.orange,
                radius: 28,
                depth: 7,
                padding: const EdgeInsets.fromLTRB(20, 14, 24, 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.replay_rounded, size: 34),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        message ?? 'Try again!',
                        textAlign: TextAlign.center,
                        style:
                            WoodText.heading(
                              fontSize: 22,
                              color: Colors.white,
                            ).copyWith(
                              shadows: const [
                                Shadow(
                                  color: Color(0xFF8A3F06),
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => WoodDialog(
        title: 'Go Back to Map?',
        onClose: () => Navigator.pop(dialogContext),
        content: Text(
          'Are you sure you want to pause your letter adventure?',
          textAlign: TextAlign.center,
          style: WoodText.body(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          WoodButton(
            height: 58,
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Keep Playing', style: WoodText.button(fontSize: 20)),
          ),
          WoodButton(
            tone: WoodTone.orange,
            height: 58,
            onPressed: () {
              Navigator.pop(dialogContext);
              context.go('/world_map');
            },
            child: Text(
              'Back to Map',
              style: WoodText.button(fontSize: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// One recessed cell per lesson phase: done phases hold a green candy piece,
/// the current one a golden piece, upcoming ones stay hollow.
class _PhaseProgress extends StatelessWidget {
  const _PhaseProgress({required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final phases = LessonPhase.values.length;
    return Semantics(
      label: 'Step ${currentIndex + 1} of $phases',
      excludeSemantics: true,
      child: Container(
        height: 30,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: WoodColors.cellLine,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: List.generate(phases, (index) {
            final isPassed = index < currentIndex;
            final isCurrent = index == currentIndex;
            final tone = isPassed
                ? WoodColors.candyGreen
                : (isCurrent ? WoodColors.candyGold : null);
            return Expanded(
              flex: isCurrent ? 3 : 2,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.only(left: index == 0 ? 0 : 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: tone?.rim ?? WoodColors.cellDark,
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: tone == null
                          ? const [Color(0xFF4A2410), Color(0xFF63341A)]
                          : [tone.highlight, tone.top, tone.bottom],
                      stops: tone == null ? null : const [0, 0.25, 1],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// Three golden stars fanned over the success plaque.
class _StarBurst extends StatelessWidget {
  const _StarBurst();

  @override
  Widget build(BuildContext context) {
    // A golden star inside a thick walnut outline, like the title lettering.
    Widget star(double size) => SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.translate(
            offset: Offset(0, size * 0.06),
            child: Icon(
              Icons.star_rounded,
              size: size,
              color: WoodColors.goldOutline,
            ),
          ),
          Icon(Icons.star_rounded, size: size, color: WoodColors.goldOutline),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [WoodColors.goldTop, WoodColors.goldBottom],
            ).createShader(bounds),
            child: Icon(Icons.star_rounded, size: size * 0.78),
          ),
        ],
      ),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Transform.rotate(angle: -0.25, child: star(70)),
        Transform.translate(offset: const Offset(0, -14), child: star(100)),
        Transform.rotate(angle: 0.25, child: star(70)),
      ],
    );
  }
}

/// Shown while the next question loads.
class _PhaseLoading extends StatelessWidget {
  const _PhaseLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: WoodColors.goldBottom),
    );
  }
}
