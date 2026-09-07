import 'package:flutter/material.dart';

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

  /// Number of stars required to unlock this world.
  final int requiredStars;

  int get primaryColorHex => backgroundColor.toARGB32();
  int get secondaryColorHex => accentColor.toARGB32();
  int get requiredStarsToUnlock => requiredStars;
}

/// All available world themes.
class WorldThemes {
  WorldThemes._();

  static const List<WorldTheme> all = [
    WorldTheme(
      id: 'forest',
      name: 'Enchanted Forest',
      description: 'A magical forest full of friendly animals',
      backgroundColor: Color(0xFF2D5A27),
      accentColor: Color(0xFF8BC34A),
      emoji: '🌲',
      letters: ['A', 'B', 'C', 'D'],
      requiredStars: 0,
    ),
    WorldTheme(
      id: 'farm',
      name: 'Sunny Farm',
      description: 'A cheerful farm with animals and crops',
      backgroundColor: Color(0xFF8D6E63),
      accentColor: Color(0xFFFFEB3B),
      emoji: '🌾',
      letters: ['E', 'F', 'G', 'H'],
      requiredStars: 5,
    ),
    WorldTheme(
      id: 'playground',
      name: 'Rainbow Playground',
      description: 'A colorful playground with fun toys',
      backgroundColor: Color(0xFF42A5F5),
      accentColor: Color(0xFFFF7043),
      emoji: '🎡',
      letters: ['I', 'J', 'K', 'L'],
      requiredStars: 10,
    ),
    WorldTheme(
      id: 'home',
      name: 'Cozy Home',
      description: 'A warm and cozy home to explore',
      backgroundColor: Color(0xFFFF8A65),
      accentColor: Color(0xFFFFCC02),
      emoji: '🏠',
      letters: ['M', 'N', 'O', 'P'],
      requiredStars: 15,
    ),
    WorldTheme(
      id: 'ocean',
      name: 'Deep Ocean',
      description: 'An underwater world of amazing sea creatures',
      backgroundColor: Color(0xFF0277BD),
      accentColor: Color(0xFF00E5FF),
      emoji: '🌊',
      letters: ['Q', 'R', 'S', 'T', 'U'],
      requiredStars: 20,
    ),
    WorldTheme(
      id: 'space',
      name: 'Outer Space',
      description: 'Blast off to the stars and planets',
      backgroundColor: Color(0xFF1A237E),
      accentColor: Color(0xFFE040FB),
      emoji: '🚀',
      letters: ['V', 'W', 'X', 'Y', 'Z'],
      requiredStars: 25,
    ),
  ];

  /// Get a world theme by ID.
  static WorldTheme getTheme(String id) {
    return all.firstWhere(
      (t) => t.id == id,
      orElse: () => all.first,
    );
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
