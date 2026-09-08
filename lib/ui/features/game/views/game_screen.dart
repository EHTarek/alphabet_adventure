import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:alphabet_adventure/data/repositories/progress_repository.dart';
import 'package:alphabet_adventure/domain/engines/lesson_controller.dart';
import 'package:alphabet_adventure/domain/engines/question_engine.dart';
import 'package:alphabet_adventure/ui/core/animations/bounce_animation.dart';
import 'package:alphabet_adventure/ui/core/animations/celebration_animation.dart';
import 'package:alphabet_adventure/ui/core/app_colors.dart';
import 'package:alphabet_adventure/ui/core/app_fonts.dart';
import 'package:alphabet_adventure/ui/core/widgets/star_counter.dart';
import 'package:alphabet_adventure/ui/features/game/views/letter_intro_view.dart';
import 'package:alphabet_adventure/ui/features/game/views/object_hunt_view.dart';
import 'package:alphabet_adventure/ui/features/game/views/review_challenge_view.dart';
import 'package:alphabet_adventure/ui/features/game/views/sound_match_view.dart';
import 'package:alphabet_adventure/ui/features/game/views/word_builder_view.dart';
import 'package:alphabet_adventure/ui/features/game/views/word_match_view.dart';

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'No lesson selected',
                style: AppFonts.fredoka(fontSize: 20),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/world_map'),
                child: const Text('Back to Map'),
              ),
            ],
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
      backgroundColor: AppColors.bgSky,
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE8F7FF), Color(0xFFFFFDF5)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top HUD: Exit button, Phase Progress Dots, Star Counter
                _buildTopHUD(context, controller, progressRepo.totalStars),
                const SizedBox(height: 8),
                // Main Interactive Game View based on phase
                Expanded(
                  child: _buildPhaseView(controller),
                ),
              ],
            ),
          ),
          // Encouraging Feedback Overlay
          if (controller.feedbackStatus == AnswerFeedbackStatus.correct)
            _buildSuccessOverlay(controller.feedbackMessage),
          if (controller.feedbackStatus == AnswerFeedbackStatus.tryAgain)
            _buildTryAgainOverlay(controller.feedbackMessage),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back / Home Button
          BounceAnimation(
            onTap: () => _confirmExit(context),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Icon(
                Icons.home_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Letter Badge
          if (letter != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withValues(alpha: 0.3),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Text(
                '${letter.uppercase}${letter.lowercase}',
                style: AppFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          const Spacer(),
          // Phase Progress Step Dots (5 steps)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(LessonPhase.values.length, (index) {
              final isPassed = index < currentPhaseIndex;
              final isCurrent = index == currentPhaseIndex;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isCurrent ? 24 : 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isPassed
                      ? AppColors.accentGreen
                      : (isCurrent ? AppColors.accentYellowDark : Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(6),
                ),
              );
            }),
          ),
          const Spacer(),
          // Star Counter
          StarCounter(count: totalStars),
        ],
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
        return const Center(child: CircularProgressIndicator());

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
        return const Center(child: CircularProgressIndicator());

      case LessonPhase.review:
        if (controller.currentQuestion != null) {
          return ReviewChallengeView(
            question: controller.currentQuestion!,
            controller: controller,
          );
        }
        return const Center(child: CircularProgressIndicator());

      case LessonPhase.celebration:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSuccessOverlay(String? message) {
    return Positioned.fill(
      child: CelebrationAnimation(
        isPlaying: true,
        child: Container(
          color: Colors.black.withValues(alpha: 0.15),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: AppColors.success, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.4),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.stars_rounded,
                    size: 64,
                    color: AppColors.accentYellowDark,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message ?? 'Awesome!',
                    style: AppFonts.fredoka(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTryAgainOverlay(String? message) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.1),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.tryAgain, width: 3.5),
            ),
            child: Text(
              message ?? 'Try again!',
              style: AppFonts.fredoka(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.tryAgain,
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
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Go Back to Map?',
          textAlign: TextAlign.center,
          style: AppFonts.fredoka(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to pause your letter adventure?',
          textAlign: TextAlign.center,
          style: AppFonts.fredoka(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Keep Playing', style: AppFonts.fredoka(fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.go('/world_map');
            },
            child: Text('Back to Map', style: AppFonts.fredoka(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
