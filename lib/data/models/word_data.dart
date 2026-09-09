/// Represents a vocabulary word with its educational metadata and asset links.
///
/// Each word maps to a letter and contains references to visual/audio assets.
/// This structure follows the 3D asset pipeline specification from PRS Section 26.
class WordData {
  const WordData({
    required this.wordId,
    required this.displayName,
    required this.letter,
    required this.word,
    required this.category,
    this.imageAsset,
    this.modelAsset,
    this.pronunciationAudioAsset,
    this.emoji,
    this.difficulty = 1,
  });

  /// Unique identifier for this word (e.g., 'apple').
  final String wordId;

  /// Human-readable display name (e.g., 'Apple').
  final String displayName;

  /// The letter this word is associated with (e.g., 'A').
  final String letter;

  /// The word in uppercase (e.g., 'APPLE').
  final String word;

  /// Content category (e.g., 'food', 'animal', 'vehicle').
  final String category;

  /// Asset path for 2D image representation.
  final String? imageAsset;

  /// Asset path for 3D model (glTF/GLB) — used when flutter_scene is active.
  final String? modelAsset;

  /// Asset path for word pronunciation audio.
  final String? pronunciationAudioAsset;

  /// Emoji representation for visual fallback.
  final String? emoji;

  /// Difficulty level (1 = easy, 2 = medium, 3 = hard).
  final int difficulty;

  /// The individual letters that make up this word.
  List<String> get letters => word.split('');

  /// Audio pronunciation asset path.
  String get audioPronunciation =>
      pronunciationAudioAsset ?? 'assets/audio/words/$wordId.m4a';

  /// Phonics sound symbol.
  String get phoneticSpelling => '/${letter.toLowerCase()}/';

  @override
  String toString() => 'WordData($wordId)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordData &&
          runtimeType == other.runtimeType &&
          wordId == other.wordId;

  @override
  int get hashCode => wordId.hashCode;
}
