import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:alphabet_adventure/data/models/letter_data.dart';
import 'package:alphabet_adventure/data/models/word_data.dart';
import 'package:alphabet_adventure/data/repositories/content_repository.dart';
import 'package:alphabet_adventure/data/services/audio_service.dart';
import 'package:alphabet_adventure/ui/core/app_colors.dart';
import 'package:alphabet_adventure/ui/core/widgets/animated_letter.dart';
import 'package:alphabet_adventure/ui/core/widgets/interactive_object.dart';
import 'package:alphabet_adventure/ui/core/widgets/mascot_widget.dart';
import 'package:alphabet_adventure/ui/features/library/widgets/game_tab_bar.dart';
import 'package:alphabet_adventure/ui/features/library/widgets/interactive_game_background.dart';
import 'package:alphabet_adventure/ui/features/library/widgets/library_game_app_bar.dart';

/// Interactive, game-focused library screen for kids.
class LibraryScreen extends StatefulWidget {
  final int initialIndex;

  const LibraryScreen({super.key, this.initialIndex = 0});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _showMascotBubble = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialIndex.clamp(0, 2),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contentRepo = context.read<ContentRepository>();
    final audioService = context.read<AudioService>();
    final letters = contentRepo.getAllLetters();
    final words = contentRepo.getAllWords();

    return Scaffold(
      body: InteractiveGameBackground(
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  // 1. Playful 3D Game HUD AppBar
                  LibraryGameAppBar(
                    widget: GameTabBar(controller: _tabController),
                  ),

                  // // 2. Tactile 3D Segmented Game Tabs
                  // GameTabBar(controller: _tabController),
                  const SizedBox(height: 6),

                  // 3. Grid Views for Letters and Words
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildLetterGrid(
                          context,
                          letters,
                          audioService,
                          isUppercase: true,
                        ),
                        _buildLetterGrid(
                          context,
                          letters,
                          audioService,
                          isUppercase: false,
                        ),
                        _buildWordGrid(context, words, audioService),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 4. Floating Pip Mascot at Bottom Corner
            Positioned(
              bottom: 16,
              right: 16,
              child: MascotWidget(
                mood: MascotMood.happy,
                size: 76,
                showSpeechBubble: _showMascotBubble,
                speechBubbleText: 'Tap any letter!',
                onTap: () {
                  setState(() {
                    _showMascotBubble = !_showMascotBubble;
                  });
                  audioService.playMascotEncouragement();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLetterGrid(
    BuildContext context,
    List<LetterData> letters,
    AudioService audioService, {
    required bool isUppercase,
  }) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 92),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 120,
        childAspectRatio: 1.0,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: letters.length,
      itemBuilder: (context, index) {
        final letter = letters[index];
        final char = isUppercase ? letter.uppercase : letter.lowercase;

        // Alternate joyful color palette with 3D bottom bevel colors
        final colorPair = [
          (AppColors.primary, AppColors.primaryDark),
          (AppColors.secondary, AppColors.secondaryDark),
          (AppColors.accentOrange, const Color(0xFFD66D00)),
          (AppColors.accentGreen, AppColors.accentGreenDark),
        ][index % 4];

        return AnimatedLetter(
          letter: char,
          size: 100,
          primaryColor: colorPair.$1,
          shadowColor: colorPair.$2,
          onTap: () {
            if (isUppercase) {
              audioService.playLetterName(letter.char);
            } else {
              audioService.playPhonicsSound(letter.char);
            }
          },
        );
      },
    );
  }

  Widget _buildWordGrid(
    BuildContext context,
    List<WordData> words,
    AudioService audioService,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 92),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 160,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: words.length,
      itemBuilder: (context, index) {
        final word = words[index];

        return InteractiveObject(
          word: word,
          size: 140,
          onTap: () {
            audioService.playWordPronunciation(word.wordId);
          },
        );
      },
    );
  }
}
