/// Mastery levels for letter/word learning progression (PRS Section 12 & 20).
enum MasteryLevel {
  /// The letter has not been encountered yet.
  unlocked(0, 'Unlocked'),

  /// The letter has been introduced in a lesson.
  introduced(1, 'Introduced'),

  /// The child is actively practicing and developing recognition.
  practicing(2, 'Practicing'),

  /// The child has demonstrated mastery across all activities.
  mastered(3, 'Mastered'),

  /// Super star level: high accuracy, fast recall, continuous streaks.
  superStar(4, 'Super Star');

  const MasteryLevel(this.value, this.displayName);

  /// Numeric value for storage and comparison.
  final int value;

  /// Human-readable name for parent dashboard and celebration screens.
  final String displayName;

  // Compatibility aliases
  static MasteryLevel get notStarted => unlocked;
  static MasteryLevel get developing => practicing;
  static MasteryLevel get learned => mastered;

  /// Create from stored integer value.
  static MasteryLevel fromValue(int value) {
    return MasteryLevel.values.firstWhere(
      (level) => level.value == value,
      orElse: () => MasteryLevel.unlocked,
    );
  }

  /// Whether this level indicates the letter has been at least introduced.
  bool get isStarted => value > 0;

  /// Whether this level indicates the letter is fully mastered or higher.
  bool get isMastered => value >= 3;
}
