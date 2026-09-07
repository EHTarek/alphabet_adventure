import 'package:alphabet_adventure/data/content/alphabet_content.dart';
import 'package:alphabet_adventure/data/models/letter_data.dart';

/// The types of challenges that can appear in a lesson.
enum ChallengeType {
  /// Find a specific letter in the scene.
  findLetter,

  /// Find an object that starts with a given letter.
  findObject,

  /// Match a phonics sound to the correct letter.
  soundMatch,

  /// Match a word to its starting letter.
  wordMatch,

  /// Build a word by arranging letters in order.
  wordBuilder,

  /// A review question mixing previously learned content.
  review,
}

/// Defines a single challenge within a lesson.
class ChallengeData {
  const ChallengeData({
    required this.type,
    required this.targetLetter,
    this.targetWord,
    this.options = const [],
    this.instruction,
  });

  /// The type of challenge.
  final ChallengeType type;

  /// The letter being tested.
  final String targetLetter;

  /// The target word (for word-based challenges).
  final String? targetWord;

  /// Available options/choices for the challenge.
  final List<String> options;

  /// Spoken instruction for the child.
  final String? instruction;
}

/// Defines a complete lesson for one letter (PRS Section 27).
class LessonData {
  const LessonData({
    required this.lessonId,
    required this.targetLetter,
    required this.introductionWord,
    required this.challenges,
    required this.vocabulary,
    this.worldTheme = 'playground',
    this.requiredStars = 0,
  });

  /// Unique identifier for this lesson.
  final String lessonId;

  String get id => lessonId;

  /// The primary letter being taught.
  final String targetLetter;

  /// Full LetterData associated with this lesson.
  LetterData get letter =>
      AlphabetContent.getLetterData(targetLetter) ??
      AlphabetContent.letters.first;

  /// The word used during the introduction phase.
  final String introductionWord;

  /// Ordered list of challenges in this lesson.
  final List<ChallengeData> challenges;

  /// Vocabulary words used in this lesson.
  final List<String> vocabulary;

  /// The world theme for the 3D/visual environment.
  final String worldTheme;

  /// Stars required to unlock this lesson (0 = always unlocked).
  final int requiredStars;

  /// Total number of challenges.
  int get totalChallenges => challenges.length;
}
