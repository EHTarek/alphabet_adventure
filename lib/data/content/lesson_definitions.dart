import 'package:alphabet_adventure/data/content/alphabet_content.dart';
import 'package:alphabet_adventure/data/content/world_themes.dart';
import 'package:alphabet_adventure/data/models/lesson_data.dart';

/// Generates lesson definitions for all 26 letters.
///
/// Lessons are data-driven as specified in PRS Section 27.
/// Each lesson follows the structure from PRS Section 13:
/// Introduction → Pronunciation → Phonics → Word Example →
/// Exploration → Mini-game → Word Activity → Celebration → Review
class LessonDefinitions {
  LessonDefinitions._();

  /// Generate all lessons for A–Z.
  static List<LessonData> get allLessons {
    return AlphabetContent.letters.map((letterData) {
      final theme = WorldThemes.getThemeForLetter(letterData.letter);
      final words = AlphabetContent.getWordsForLetter(letterData.letter);
      final wordIds = words.map((w) => w.wordId).toList();
      final primaryWord = words.isNotEmpty ? words.first : null;

      // Get distractor letters (2 other letters for multiple-choice)
      final allLetters = AlphabetContent.letters
          .map((l) => l.letter)
          .where((l) => l != letterData.letter)
          .toList()
        ..shuffle();
      final distractorLetters = allLetters.take(2).toList();

      // Get distractor words from other letters
      final distractorWords = AlphabetContent.words
          .where((w) => w.letter != letterData.letter)
          .take(2)
          .map((w) => w.wordId)
          .toList();

      final letterIndex = AlphabetContent.letters.indexOf(letterData);

      return LessonData(
        lessonId: 'lesson_${letterData.letter.toLowerCase()}',
        targetLetter: letterData.letter,
        introductionWord: primaryWord?.wordId ?? '',
        worldTheme: theme.id,
        requiredStars: letterIndex * 2, // progressive unlocking
        vocabulary: wordIds,
        challenges: [
          // Challenge 1: Find the letter
          ChallengeData(
            type: ChallengeType.findLetter,
            targetLetter: letterData.letter,
            options: [
              letterData.letter,
              ...distractorLetters,
            ],
            instruction:
                'Find the letter ${letterData.letter}!',
          ),

          // Challenge 2: Find an object starting with the letter
          if (wordIds.isNotEmpty)
            ChallengeData(
              type: ChallengeType.findObject,
              targetLetter: letterData.letter,
              targetWord: wordIds.first,
              options: [
                ...wordIds.take(2),
                ...distractorWords.take(2),
              ],
              instruction:
                  'Find something that starts with ${letterData.letter}!',
            ),

          // Challenge 3: Sound match
          ChallengeData(
            type: ChallengeType.soundMatch,
            targetLetter: letterData.letter,
            options: [
              letterData.letter,
              ...distractorLetters,
            ],
            instruction:
                'Which letter makes the ${letterData.phonicsSound} sound?',
          ),

          // Challenge 4: Word match (find another object)
          if (wordIds.length > 1)
            ChallengeData(
              type: ChallengeType.wordMatch,
              targetLetter: letterData.letter,
              targetWord: wordIds[1],
              options: [
                wordIds[1],
                ...distractorWords,
              ],
              instruction:
                  'Find another thing that starts with ${letterData.letter}!',
            ),

          // Challenge 5: Word builder (for short words)
          if (primaryWord != null && primaryWord.word.length <= 5)
            ChallengeData(
              type: ChallengeType.wordBuilder,
              targetLetter: letterData.letter,
              targetWord: primaryWord.wordId,
              options: primaryWord.word.split(''),
              instruction:
                  'Can you spell ${primaryWord.displayName}?',
            ),

          // Challenge 6: Review (find the third object)
          if (wordIds.length > 2)
            ChallengeData(
              type: ChallengeType.review,
              targetLetter: letterData.letter,
              targetWord: wordIds[2],
              options: [
                wordIds[2],
                ...distractorWords,
              ],
              instruction:
                  'One more! Find the ${AlphabetContent.getWord(wordIds[2])?.displayName ?? wordIds[2]}!',
            ),
        ],
      );
    }).toList();
  }

  /// Get lesson for a specific letter.
  static LessonData? getLessonForLetter(String letter) {
    final upper = letter.toUpperCase();
    final lessons = allLessons;
    try {
      return lessons.firstWhere((l) => l.targetLetter == upper);
    } catch (_) {
      return null;
    }
  }

  /// Get total number of lessons.
  static int get totalLessons => 26;
}
