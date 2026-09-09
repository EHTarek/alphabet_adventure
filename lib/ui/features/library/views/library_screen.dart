import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:alphabet_adventure/data/models/letter_data.dart';
import 'package:alphabet_adventure/data/models/word_data.dart';
import 'package:alphabet_adventure/data/repositories/content_repository.dart';
import 'package:alphabet_adventure/data/services/audio_service.dart';
import 'package:alphabet_adventure/ui/core/app_colors.dart';
import 'package:alphabet_adventure/ui/core/app_fonts.dart';
import 'package:alphabet_adventure/ui/core/widgets/animated_letter.dart';
import 'package:alphabet_adventure/ui/core/widgets/interactive_object.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final contentRepo = context.read<ContentRepository>();
    final audioService = context.read<AudioService>();
    final letters = contentRepo.getAllLetters();
    final words = contentRepo.getAllWords();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Library',
            style: AppFonts.fredoka(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            labelStyle: AppFonts.fredoka(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: AppFonts.fredoka(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            indicatorColor: AppColors.primary,
            indicatorWeight: 4,
            tabs: const [
              Tab(text: 'A-Z'),
              Tab(text: 'a-z'),
              Tab(text: 'Words'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLetterGrid(context, letters, audioService, isUppercase: true),
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
    );
  }

  Widget _buildLetterGrid(
    BuildContext context,
    List<LetterData> letters,
    AudioService audioService, {
    required bool isUppercase,
  }) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
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

        // Alternate colors for a playful look
        final color = [
          AppColors.primary,
          AppColors.secondary,
          AppColors.accentOrange,
          AppColors.accentGreen,
        ][index % 4];

        return AnimatedLetter(
          letter: char,
          size: 100, // Adjust size slightly if needed for the grid
          primaryColor: color,
          shadowColor: color.withValues(alpha: 0.7),
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
      padding: const EdgeInsets.all(16),
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
          size: 140, // Match typical size
          onTap: () {
            audioService.playWordPronunciation(word.wordId);
          },
        );
      },
    );
  }
}
