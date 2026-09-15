import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:alphabet_adventure/data/models/letter_data.dart';
import 'package:alphabet_adventure/data/models/word_data.dart';
import 'package:alphabet_adventure/data/repositories/content_repository.dart';
import 'package:alphabet_adventure/data/services/audio_service.dart';
import 'package:alphabet_adventure/ui/core/widgets/animated_letter.dart';
import 'package:alphabet_adventure/ui/core/widgets/interactive_object.dart';
import 'package:alphabet_adventure/ui/core/widgets/letter_example_overlay.dart';
import 'package:alphabet_adventure/ui/core/widgets/mascot_widget.dart';
import 'package:alphabet_adventure/ui/core/wood/wood.dart';
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
  static const double _gridSidePadding = 16;
  static const double _gridSpacing = 16;
  static const double _letterMaxExtent = 120;

  /// Leaves room under the last row for the mascot and its bubble.
  static const double _gridBottomPadding = 140;

  late final TabController _tabController;

  /// Shows the "Tap any letter!" hint until the first letter tap.
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Same column count a max-extent delegate of 120 would pick; knowing
        // it lets neighbouring blocks, across and down, differ in colour.
        final columns =
            ((constraints.maxWidth - _gridSidePadding * 2) /
                    (_letterMaxExtent + _gridSpacing))
                .ceil()
                .clamp(1, 12);

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(
            _gridSidePadding,
            10,
            _gridSidePadding,
            _gridBottomPadding,
          ),
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: 1.0,
            crossAxisSpacing: _gridSpacing,
            mainAxisSpacing: _gridSpacing,
          ),
          itemCount: letters.length,
          itemBuilder: (context, index) {
            final letter = letters[index];
            final char = isUppercase ? letter.uppercase : letter.lowercase;

            // A box of candy blocks: colours step one along each row and two
            // down each column, so no two touching blocks share a colour.
            final row = index ~/ columns;
            final column = index % columns;
            final cycle = WoodColors.blockCycle;
            final colors = cycle[(row * 2 + column) % cycle.length];

            return AnimatedLetter(
              letter: char,
              size: 100,
              primaryColor: colors.bottom,
              shadowColor: colors.rim,
              onTap: () {
                // The child has found the letters, so drop the "Tap any letter!" hint.
                if (_showMascotBubble) {
                  setState(() => _showMascotBubble = false);
                }
                if (isUppercase) {
                  audioService.playLetterName(letter.char);
                } else {
                  audioService.playPhonicsSound(letter.char);
                }
                // Then show a real object that starts with the letter.
                showLetterExampleOverlay(
                  context,
                  letter,
                  lowercase: !isUppercase,
                );
              },
            );
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
      padding: const EdgeInsets.fromLTRB(
        _gridSidePadding,
        10,
        _gridSidePadding,
        _gridBottomPadding,
      ),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 160,
        childAspectRatio: 0.8,
        crossAxisSpacing: _gridSpacing,
        mainAxisSpacing: _gridSpacing,
      ),
      itemCount: words.length,
      itemBuilder: (context, index) {
        final word = words[index];

        return InteractiveObject(
          word: word,
          size: 140,
          // The overlay says the word once it has popped in.
          onTap: () => showWordExampleOverlay(context, word),
        );
      },
    );
  }
}
