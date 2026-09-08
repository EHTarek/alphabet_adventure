import 'package:flutter/material.dart';

const _allAlphabetLetters = [
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
  'G',
  'H',
  'I',
  'J',
  'K',
  'L',
  'M',
  'N',
  'O',
  'P',
  'Q',
  'R',
  'S',
  'T',
  'U',
  'V',
  'W',
  'X',
  'Y',
  'Z',
];

/// Defines the themed worlds for 3D/visual environments (PRS Section 10).
class WorldTheme {
  const WorldTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.backgroundColor,
    required this.accentColor,
    required this.emoji,
    required this.letters,
    this.difficulty = 1,
    this.requiredStars = 0,
  });

  /// Unique identifier.
  final String id;

  /// Display name.
  final String name;

  /// Short description for the world.
  final String description;

  /// Primary background color.
  final Color backgroundColor;

  /// Accent/highlight color.
  final Color accentColor;

  /// Emoji representation.
  final String emoji;

  /// Letters that use this world theme.
  final List<String> letters;

  /// Learning difficulty for this level, from 1 (easiest) to 6 (hardest).
  final int difficulty;

  /// Number of stars required to unlock this world.
  final int requiredStars;

  int get primaryColorHex => backgroundColor.toARGB32();
  int get secondaryColorHex => accentColor.toARGB32();
  int get requiredStarsToUnlock => requiredStars;
  String get difficultyLabel => switch (difficulty) {
    1 => 'Easy',
    2 => 'Growing',
    3 => 'Practice',
    4 => 'Challenge',
    5 => 'Advanced',
    _ => 'Mastery',
  };
}

/// All available world themes.
class WorldThemes {
  WorldThemes._();

  static const List<WorldTheme> all = [
    WorldTheme(
      id: 'forest',
      name: 'Enchanted Forest',
      description: 'Easy introduction to all 26 letters with friendly animals',
      backgroundColor: Color(0xFF2D5A27),
      accentColor: Color(0xFF8BC34A),
      emoji: '🌲',
      letters: _allAlphabetLetters,
      difficulty: 1,
      requiredStars: 0,
    ),
    WorldTheme(
      id: 'farm',
      name: 'Sunny Farm',
      description: 'Growing practice with all 26 letters and clear word clues',
      backgroundColor: Color(0xFF8D6E63),
      accentColor: Color(0xFFFFEB3B),
      emoji: '🌾',
      letters: _allAlphabetLetters,
      difficulty: 2,
      requiredStars: 5,
    ),
    WorldTheme(
      id: 'playground',
      name: 'Rainbow Playground',
      description: 'Practice all 26 letters with faster mixed challenges',
      backgroundColor: Color(0xFF42A5F5),
      accentColor: Color(0xFFFF7043),
      emoji: '🎡',
      letters: _allAlphabetLetters,
      difficulty: 3,
      requiredStars: 10,
    ),
    WorldTheme(
      id: 'home',
      name: 'Cozy Home',
      description: 'Challenge level with uppercase and lowercase matching',
      backgroundColor: Color(0xFFFF8A65),
      accentColor: Color(0xFFFFCC02),
      emoji: '🏠',
      letters: _allAlphabetLetters,
      difficulty: 4,
      requiredStars: 15,
    ),
    WorldTheme(
      id: 'ocean',
      name: 'Deep Ocean',
      description: 'Advanced sound, word, and review challenges for A-Z',
      backgroundColor: Color(0xFF0277BD),
      accentColor: Color(0xFF00E5FF),
      emoji: '🌊',
      letters: _allAlphabetLetters,
      difficulty: 5,
      requiredStars: 20,
    ),
    WorldTheme(
      id: 'space',
      name: 'Outer Space',
      description: 'Mastery level with the hardest mixed A-Z practice',
      backgroundColor: Color(0xFF1A237E),
      accentColor: Color(0xFFE040FB),
      emoji: '🚀',
      letters: _allAlphabetLetters,
      difficulty: 6,
      requiredStars: 25,
    ),
  ];

  /// Get a world theme by ID.
  static WorldTheme getTheme(String id) {
    return all.firstWhere((t) => t.id == id, orElse: () => all.first);
  }

  /// Get the world theme assigned to a specific letter.
  static WorldTheme getThemeForLetter(String letter) {
    final upper = letter.toUpperCase();
    return all.firstWhere(
      (t) => t.letters.contains(upper),
      orElse: () => all.first,
    );
  }
}
