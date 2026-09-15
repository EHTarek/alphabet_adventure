import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:alphabet_adventure/data/repositories/content_repository.dart';
import 'package:alphabet_adventure/data/services/audio_service.dart';
import 'package:alphabet_adventure/domain/engines/lesson_controller.dart';
import 'package:alphabet_adventure/domain/engines/mastery_engine.dart';
import 'package:alphabet_adventure/domain/engines/reward_engine.dart';
import 'package:alphabet_adventure/domain/models/mastery_level.dart';
import 'package:alphabet_adventure/ui/core/animations/celebration_animation.dart';
import 'package:alphabet_adventure/ui/core/widgets/mascot_widget.dart';
import 'package:alphabet_adventure/ui/core/wood/wood.dart';

/// Lesson complete celebration screen awarding stars, mastery badges, and stickers (PRS Section 11 & 19).
class LessonCompleteScreen extends StatefulWidget {
  const LessonCompleteScreen({super.key});

  @override
  State<LessonCompleteScreen> createState() => _LessonCompleteScreenState();
}

class _LessonCompleteScreenState extends State<LessonCompleteScreen> {
  int _revealedStars = 0;

  /// Edge of the big candy letter block that sits on the result board.
  static const double _letterBlockSize = 116;

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
      body: CelebrationAnimation(
        isPlaying: true,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                // Golden title on a walnut plaque
                WoodPanel(
                  tone: WoodTone.dark,
                  radius: 22,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 6,
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: WoodTitle(
                      'LESSON COMPLETE!',
                      fontSize: 34,
                      maxLines: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Result board with the big letter block riding on top
                Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: _letterBlockSize * 0.62,
                      ),
                      child: WoodPanel(
                        width: double.infinity,
                        radius: 28,
                        depth: 8,
                        padding: const EdgeInsets.fromLTRB(
                          18,
                          _letterBlockSize * 0.58,
                          18,
                          18,
                        ),
                        child: Column(
                          children: [
                            Text(
                              'You did an awesome job learning letter ${letter?.uppercase ?? ""}!',
                              textAlign: TextAlign.center,
                              style: WoodText.heading(fontSize: 19),
                            ),
                            const SizedBox(height: 14),
                            _buildStarsPlaque(),
                            // Mastery & Level Up Banner
                            if (masteryResult != null) ...[
                              const SizedBox(height: 16),
                              _MasterySection(result: masteryResult),
                            ],
                          ],
                        ),
                      ),
                    ),
                    CandyBlock(
                      colors: _letterColors(masteryResult?.newLevel),
                      size: _letterBlockSize,
                      rotation: -0.05,
                      letter: letter == null
                          ? '?'
                          : '${letter.uppercase}${letter.lowercase}',
                    ),
                  ],
                ),
                // Unlocked Achievements / Stickers Card
                if (achievements.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _AchievementsPanel(achievements: achievements),
                ],
                const SizedBox(height: 20),
                // Cheering Mascot
                const MascotWidget(
                  mood: MascotMood.cheering,
                  speechBubbleText: 'Hooray! You are a superstar explorer!',
                  size: 96,
                ),
                const SizedBox(height: 24),
                // Navigation Buttons
                Row(
                  children: [
                    // Back to Map Button
                    Expanded(
                      child: WoodButton(
                        onPressed: () => context.go('/world_map'),
                        height: 66,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: _ButtonLabel(
                          icon: Icons.map_rounded,
                          label: 'World Map',
                          color: WoodColors.ink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Next Letter Button
                    Expanded(
                      child: WoodButton(
                        onPressed: () => _onNextLetter(context),
                        tone: WoodTone.green,
                        height: 66,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: _ButtonLabel(
                          icon: Icons.arrow_forward_rounded,
                          label: 'Next Letter',
                          color: Colors.white,
                          iconAfter: true,
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

  /// The three earned stars, popping in one by one on a walnut plaque.
  Widget _buildStarsPlaque() {
    return WoodPanel(
      tone: WoodTone.dark,
      radius: 24,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          final isEarned = index < _revealedStars;
          return AnimatedScale(
            scale: isEarned ? 1.12 : 0.9,
            duration: const Duration(milliseconds: 350),
            curve: Curves.elasticOut,
            child: Padding(
              padding: EdgeInsets.fromLTRB(4, index == 1 ? 0 : 10, 4, 0),
              child: Icon(
                Icons.star_rounded,
                size: index == 1 ? 72 : 60,
                color: isEarned ? WoodColors.goldTop : WoodColors.cellLine,
                shadows: isEarned
                    ? const [
                        Shadow(
                          color: WoodColors.goldOutline,
                          offset: Offset(0, 3),
                        ),
                        Shadow(color: Color(0x99FFE27A), blurRadius: 16),
                      ]
                    : [
                        Shadow(
                          color: WoodColors.darkWood.highlight.withValues(
                            alpha: 0.45,
                          ),
                          offset: const Offset(0, 1.5),
                        ),
                      ],
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Candy colours for the big letter block, following the new mastery.
  static WoodToneColors _letterColors(MasteryLevel? level) {
    return switch (level) {
      null => WoodColors.candyOrange,
      MasteryLevel.unlocked => WoodColors.candyRed,
      MasteryLevel.introduced => WoodColors.blockCycle[1],
      MasteryLevel.practicing => WoodColors.candyOrange,
      MasteryLevel.mastered => WoodColors.candyGreen,
      MasteryLevel.superStar => WoodColors.candyPurple,
    };
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

/// Mastery headline pill, the new level and a progress bar leading to a
/// Super Star.
class _MasterySection extends StatelessWidget {
  const _MasterySection({required this.result});

  final MasteryEvaluationResult result;

  @override
  Widget build(BuildContext context) {
    final levelCount = MasteryLevel.values.length;
    return Column(
      children: [
        WoodPill(
          label: result.leveledUp
              ? 'MASTERY LEVEL UP!'
              : 'Letter Mastery Progress',
          fontSize: 17,
          leading: Icon(
            result.leveledUp
                ? Icons.military_tech_rounded
                : Icons.check_circle_rounded,
            color: result.leveledUp ? WoodColors.goldTop : Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Mastery: ${result.newLevel.displayName}',
          style: WoodText.heading(fontSize: 17),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: WoodProgressBar(
                // Every level counts as a step, so a first lesson shows
                // progress too.
                value: (result.newLevel.value + 1) / levelCount,
                height: 24,
                fill: result.newLevel == MasteryLevel.superStar
                    ? WoodColors.candyGold
                    : WoodColors.candyGreen,
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: MasteryLevel.superStar.displayName,
              child: const Icon(
                Icons.star_rounded,
                size: 32,
                color: WoodColors.goldBottom,
                shadows: [
                  Shadow(color: WoodColors.goldOutline, offset: Offset(0, 2)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Newly unlocked stickers: a pale wood panel listing each with a gold candy
/// badge.
class _AchievementsPanel extends StatelessWidget {
  const _AchievementsPanel({required this.achievements});

  final List<AchievementReward> achievements;

  @override
  Widget build(BuildContext context) {
    return WoodPanel(
      width: double.infinity,
      radius: 26,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: WoodColors.goldBottom,
                size: 24,
                shadows: [
                  Shadow(color: WoodColors.goldOutline, offset: Offset(0, 1.5)),
                ],
              ),
              const SizedBox(width: 6),
              Text('Sticker Unlocked!', style: WoodText.heading(fontSize: 20)),
            ],
          ),
          for (final achievement in achievements) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const CandyBlock(
                  colors: WoodColors.candyGold,
                  size: 56,
                  rotation: 0.06,
                  child: Icon(
                    Icons.emoji_events_rounded,
                    size: 34,
                    color: WoodColors.goldOutline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement.title,
                        style: WoodText.heading(
                          fontSize: 19,
                          color: WoodColors.candyOrange.bevel,
                        ),
                      ),
                      Text(
                        achievement.description,
                        style: WoodText.body(
                          fontSize: 14,
                          color: WoodColors.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// A button label with an icon, shrinking to fit narrow buttons.
class _ButtonLabel extends StatelessWidget {
  const _ButtonLabel({
    required this.icon,
    required this.label,
    required this.color,
    this.iconAfter = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool iconAfter;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(icon, size: 24, color: color);
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!iconAfter) ...[iconWidget, const SizedBox(width: 6)],
          Text(label, style: WoodText.button(fontSize: 20, color: color)),
          if (iconAfter) ...[const SizedBox(width: 6), iconWidget],
        ],
      ),
    );
  }
}
