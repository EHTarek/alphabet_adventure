import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:alphabet_adventure/data/models/letter_data.dart';
import 'package:alphabet_adventure/data/models/letter_progress.dart';
import 'package:alphabet_adventure/data/services/audio_service.dart';
import 'package:alphabet_adventure/domain/engines/lesson_controller.dart';
import 'package:alphabet_adventure/domain/models/mastery_level.dart';
import 'package:alphabet_adventure/ui/core/animations/bounce_animation.dart';
import 'package:alphabet_adventure/ui/core/app_colors.dart';
import 'package:alphabet_adventure/ui/core/widgets/mascot_widget.dart';
import 'package:alphabet_adventure/ui/core/widgets/star_counter.dart';
import 'package:alphabet_adventure/ui/features/world_map/view_models/world_map_view_model.dart';

/// World map adventure screen with 6 themed environments and letter trails (PRS Section 8 & 15).
class WorldMapScreen extends StatelessWidget {
  const WorldMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<WorldMapViewModel>();
    final currentWorld = viewModel.currentWorld;
    final letters = viewModel.currentWorldLetters;

    return Scaffold(
      backgroundColor: Color(currentWorld.primaryColorHex).withValues(alpha: 0.1),
      body: Stack(
        children: [
          // Background Gradient based on selected world
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(currentWorld.primaryColorHex).withValues(alpha: 0.25),
                    Color(currentWorld.secondaryColorHex).withValues(alpha: 0.15),
                    AppColors.bgSky,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top App Bar: Profile, World Name, Star Counter, Settings
                _buildTopBar(context, viewModel),
                const SizedBox(height: 8),
                // World Selector Carousel
                _buildWorldSelector(context, viewModel),
                const SizedBox(height: 12),
                // Adventure Trail Letters List
                Expanded(
                  child: _buildLetterTrail(context, viewModel, letters),
                ),
              ],
            ),
          ),
          // Floating Pip Mascot at bottom corner
          Positioned(
            bottom: 16,
            right: 16,
            child: MascotWidget(
              mood: MascotMood.happy,
              size: 80,
              showSpeechBubble: false,
              onTap: () {
                final audio = context.read<AudioService>();
                audio.playMascotEncouragement();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, WorldMapViewModel viewModel) {
    final profile = viewModel.activeProfile;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Profile Avatar Button (switches back to profile selection)
          BounceAnimation(
            onTap: () => context.go('/profile'),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.secondaryDark, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.secondary,
                child: Icon(Icons.face_rounded, color: Colors.white, size: 28),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  profile?.name ?? 'Explorer',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.fredoka(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  viewModel.currentWorld.name,
                  maxLines: 1,
                  style: GoogleFonts.fredoka(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          // Star Counter
          StarCounter(count: viewModel.totalStars),
          const SizedBox(width: 8),
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings_rounded, size: 30, color: AppColors.textDark),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildWorldSelector(BuildContext context, WorldMapViewModel viewModel) {
    final worlds = viewModel.worlds;

    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: worlds.length,
        itemBuilder: (context, index) {
          final world = worlds[index];
          final isSelected = index == viewModel.selectedWorldIndex;
          final isUnlocked = viewModel.isWorldUnlocked(world);

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: BounceAnimation(
              onTap: () {
                if (isUnlocked) {
                  viewModel.selectWorld(index);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Unlock this world with ${world.requiredStarsToUnlock} stars!',
                        style: GoogleFonts.fredoka(),
                      ),
                      backgroundColor: AppColors.tryAgain,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Color(world.primaryColorHex) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? Colors.white
                        : Color(world.primaryColorHex).withValues(alpha: 0.5),
                    width: isSelected ? 3 : 2,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: Color(world.primaryColorHex).withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isUnlocked) ...[
                      const Icon(Icons.lock_rounded, size: 18, color: Colors.grey),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      world.name,
                      style: GoogleFonts.fredoka(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : (isUnlocked ? AppColors.textDark : Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLetterTrail(
    BuildContext context,
    WorldMapViewModel viewModel,
    List<LetterData> letters,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 80),
      itemCount: letters.length,
      itemBuilder: (context, index) {
        final letter = letters[index];
        final progress = viewModel.getLetterProgress(letter.char);
        final isLeftAligned = index % 2 == 0;

        return _buildLetterTrailNode(
          context: context,
          letter: letter,
          progress: progress,
          isLeftAligned: isLeftAligned,
          onTap: () => _onLetterNodeTapped(context, viewModel, letter),
        );
      },
    );
  }

  Widget _buildLetterTrailNode({
    required BuildContext context,
    required LetterData letter,
    required LetterProgress progress,
    required bool isLeftAligned,
    required VoidCallback onTap,
  }) {
    final mastery = progress.masteryLevel;
    final stars = progress.starsEarned;

    final nodeColor = switch (mastery) {
      MasteryLevel.unlocked => AppColors.primary,
      MasteryLevel.introduced => AppColors.secondary,
      MasteryLevel.practicing => AppColors.accentOrange,
      MasteryLevel.mastered => AppColors.accentGreen,
      MasteryLevel.superStar => AppColors.accentYellow,
    };

    final hintWord = letter.words.isNotEmpty ? letter.words.first : letter.char;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment:
            isLeftAligned ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          BounceAnimation(
            onTap: onTap,
            child: Container(
              width: 130,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: nodeColor, width: 3.5),
                boxShadow: [
                  BoxShadow(
                    color: nodeColor.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Large Letter Glyph Circle
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: nodeColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${letter.uppercase}${letter.lowercase}',
                        style: GoogleFonts.fredoka(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Word name hint
                  Text(
                    hintWord,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.fredoka(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Stars Earned Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (starIndex) {
                      final isFilled = starIndex < stars;
                      return Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: isFilled
                            ? AppColors.accentYellowDark
                            : Colors.grey.shade300,
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onLetterNodeTapped(
    BuildContext context,
    WorldMapViewModel viewModel,
    LetterData letter,
  ) {
    final lesson = viewModel.getLessonForLetter(letter);
    final lessonController = context.read<LessonController>();
    lessonController.startLesson(lesson);

    context.push('/game');
  }
}
