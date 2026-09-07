import 'package:alphabet_adventure/data/content/alphabet_content.dart';
import 'package:alphabet_adventure/data/models/word_data.dart';

/// Represents a single letter of the alphabet with its educational content.
class LetterData {
  const LetterData({
    required this.letter,
    required this.uppercase,
    required this.lowercase,
    required this.phonicsSound,
    required this.letterAudioAsset,
    required this.phonicsAudioAsset,
    required this.words,
  });

  /// The letter identifier (e.g., 'A').
  final String letter;

  /// Uppercase representation.
  final String uppercase;

  /// Lowercase representation.
  final String lowercase;

  /// Phonics sound description (e.g., '/æ/' for A).
  final String phonicsSound;

  /// Asset path for letter name pronunciation audio.
  final String letterAudioAsset;

  /// Asset path for phonics sound audio.
  final String phonicsAudioAsset;

  /// Associated vocabulary word strings.
  final List<String> words;

  // --- Convenience getters ---
  String get char => letter;
  String get audioLetterName => letterAudioAsset;
  String get audioPhonicsSound => phonicsAudioAsset;
  List<WordData> get vocabularyWords => AlphabetContent.getWordsForLetter(letter);

  @override
  String toString() => 'LetterData($letter)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LetterData &&
          runtimeType == other.runtimeType &&
          letter == other.letter;

  @override
  int get hashCode => letter.hashCode;
}
