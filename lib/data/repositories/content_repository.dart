import 'package:alphabet_adventure/data/content/alphabet_content.dart';
import 'package:alphabet_adventure/data/content/lesson_definitions.dart';
import 'package:alphabet_adventure/data/content/world_themes.dart';
import 'package:alphabet_adventure/data/models/lesson_data.dart';
import 'package:alphabet_adventure/data/models/letter_data.dart';
import 'package:alphabet_adventure/data/models/word_data.dart';

/// Repository for accessing educational content (letters, words, lessons).
class ContentRepository {
  const ContentRepository();

  /// Get all 26 letter definitions.
  List<LetterData> getAllLetters() => AlphabetContent.letters;

  /// Get a specific letter's data.
  LetterData? getLetterData(String letter) =>
      AlphabetContent.getLetterData(letter);

  /// Get all vocabulary words.
  List<WordData> getAllWords() => AlphabetContent.words;

  /// Get words for a specific letter.
  List<WordData> getWordsForLetter(String letter) =>
      AlphabetContent.getWordsForLetter(letter);

  /// Get a word by its ID.
  WordData? getWord(String wordId) => AlphabetContent.getWord(wordId);

  /// Get words by category.
  List<WordData> getWordsByCategory(String category) =>
      AlphabetContent.getWordsByCategory(category);

  /// Get all lesson definitions.
  List<LessonData> getAllLessons() => LessonDefinitions.allLessons;

  /// Get lesson for a specific letter (returns fallback if null).
  LessonData getLessonForLetter(String letter) {
    return LessonDefinitions.getLessonForLetter(letter) ??
        LessonDefinitions.allLessons.first;
  }

  /// Get the world theme for a letter.
  WorldTheme getWorldThemeForLetter(String letter) =>
      WorldThemes.getThemeForLetter(letter);

  /// Get all world themes.
  List<WorldTheme> getAllWorlds() => WorldThemes.all;
  List<WorldTheme> getAllWorldThemes() => WorldThemes.all;

  /// Get letters for a specific world.
  List<LetterData> getLettersForWorld(String worldId) {
    final world = WorldThemes.getTheme(worldId);
    return AlphabetContent.letters
        .where((l) => world.letters.contains(l.char))
        .toList();
  }

  /// Get total number of letters.
  int get totalLetters => 26;

  /// Get total number of vocabulary words.
  int get totalWords => AlphabetContent.words.length;
}
