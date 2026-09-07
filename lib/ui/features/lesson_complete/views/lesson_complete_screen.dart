import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:alphabet_adventure/data/repositories/content_repository.dart';
import 'package:alphabet_adventure/data/services/audio_service.dart';
import 'package:alphabet_adventure/domain/engines/lesson_controller.dart';
import 'package:alphabet_adventure/ui/core/animations/bounce_animation.dart';
import 'package:alphabet_adventure/ui/core/animations/celebration_animation.dart';
import 'package:alphabet_adventure/ui/core/app_colors.dart';
import 'package:alphabet_adventure/ui/core/widgets/mascot_widget.dart';

/// Lesson complete celebration screen awarding stars, mastery badges, and stickers (PRS Section 11 & 19).
class LessonCompleteScreen extends StatefulWidget {
  const LessonCompleteScreen({super.key});

  @override
  State<LessonCompleteScreen> createState() => _LessonCompleteScreenState();
}

class _LessonCompleteScreenState extends State<LessonCompleteScreen> {
  int _revealedStars = 0;

  @override
  void initState() {
    super.initState();
    _animateStars();
  }

  Future<void> _animateStars() async {
    final controller = context.read<LessonController>();
    final stars = controller.earnedStars;

    for (int i = 1; i <= stars; i++) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        setState(() {
          _revealedStars = i;
        });
        context.read<AudioService>().playSuccessSound();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LessonController>();
    final lesson = controller.currentLesson;
    final letter = lesson?.letter;
    final masteryResult = controller.masteryResult;
    final achievements = controller.earnedAchievements;

    return Scaffold(
      backgroundColor: AppColors.bgSky,
      body: CelebrationAnimation(
        isPlaying: true,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Text(
                  'LESSON COMPLETE!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You did an awesome job learning letter ${letter?.uppercase ?? ""}!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: 18,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 24),
                // 3 Stars Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final isEarned = index < _revealedStars;
                    return AnimatedScale(
                      scale: isEarned ? 1.25 : 0.9,
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.elasticOut,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          Icons.star_rounded,
                          size: 72,
                          color: isEarned
                              ? AppColors.accentYellowDark
                              : Colors.grey.shade300,
                          shadows: isEarned
                              ? [
                                  Shadow(
                                    color: AppColors.accentYellowDark
                                        .withValues(alpha: 0.8),
                                    blurRadius: 18,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                // Mastery & Level Up Banner
                if (masteryResult != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: masteryResult.leveledUp
                            ? AppColors.accentGreen
                            : AppColors.secondaryDark,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              masteryResult.leveledUp
                                  ? Icons.military_tech_rounded
                                  : Icons.check_circle_rounded,
                              color: masteryResult.leveledUp
                                  ? AppColors.accentYellowDark
                                  : AppColors.accentGreen,
                              size: 32,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              masteryResult.leveledUp
                                  ? 'MASTERY LEVEL UP!'
                                  : 'Letter Mastery Progress',
                              style: GoogleFonts.fredoka(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Mastery: ${masteryResult.newLevel.displayName}',
                          style: GoogleFonts.fredoka(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Unlocked Achievements / Stickers Card
                if (achievements.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.accentYellow.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.accentYellowDark, width: 2.5),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.auto_awesome_rounded,
                              color: AppColors.accentYellowDark,
                              size: 26,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Sticker Unlocked!',
                              style: GoogleFonts.fredoka(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          achievements.first.title,
                          style: GoogleFonts.fredoka(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accentOrange,
                          ),
                        ),
                        Text(
                          achievements.first.description,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.fredoka(
                            fontSize: 14,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                // Cheering Mascot
                const MascotWidget(
                  mood: MascotMood.cheering,
                  speechBubbleText: 'Hooray! You are a superstar explorer!',
                  size: 96,
                ),
                const SizedBox(height: 28),
                // Navigation Buttons
                Row(
                  children: [
                    // Back to Map Button
                    Expanded(
                      child: BounceAnimation(
                        onTap: () => context.go('/world_map'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.primary, width: 3),
                          ),
                          child: Center(
                            child: Text(
                              'World Map',
                              style: GoogleFonts.fredoka(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Next Letter Button
                    Expanded(
                      child: BounceAnimation(
                        onTap: () => _onNextLetter(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.accentGreen, AppColors.accentGreenDark],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentGreenDark.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Next Letter',
                              style: GoogleFonts.fredoka(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onNextLetter(BuildContext context) {
    final controller = context.read<LessonController>();
    final contentRepo = context.read<ContentRepository>();
    final currentChar = controller.currentLesson?.letter.char;

    if (currentChar != null) {
      final allLetters = contentRepo.getAllLetters();
      final currentIndex = allLetters.indexWhere((l) => l.char == currentChar);

      if (currentIndex >= 0 && currentIndex < allLetters.length - 1) {
        final nextLetter = allLetters[currentIndex + 1];
        final nextLesson = contentRepo.getLessonForLetter(nextLetter.char);
        controller.startLesson(nextLesson);
        context.go('/game');
        return;
      }
    }

    context.go('/world_map');
  }
}
