import 'package:alphabet_adventure/domain/models/mastery_level.dart';

/// Tracks a child's learning progress for a single letter (PRS Section 17 & 20).
class LetterProgress {
  const LetterProgress({
    required this.letter,
    this.mastery = MasteryLevel.unlocked,
    this.correctAnswers = 0,
    this.incorrectAnswers = 0,
    this.timesReviewed = 0,
    this.starsEarned = 0,
    this.hintsUsed = 0,
    this.sessionCount = 0,
    this.lastPracticed,
    this.wordsLearned = const [],
  });

  /// The letter this progress tracks (e.g., 'A').
  final String letter;

  /// Current mastery level.
  final MasteryLevel mastery;

  MasteryLevel get masteryLevel => mastery;

  /// Total correct answers across all activities.
  final int correctAnswers;

  int get successfulAttempts => correctAnswers;

  /// Total incorrect answers across all activities.
  final int incorrectAnswers;

  int get totalAttempts => correctAnswers + incorrectAnswers;

  /// Number of times this letter has been reviewed.
  final int timesReviewed;

  /// Stars earned for this letter (0 to 3).
  final int starsEarned;

  /// Hints used during practice.
  final int hintsUsed;

  /// Total number of distinct practice sessions.
  final int sessionCount;

  /// When this letter was last practiced.
  final DateTime? lastPracticed;

  /// Words the child has successfully learned for this letter.
  final List<String> wordsLearned;

  /// Accuracy as a percentage (0.0–1.0).
  double get accuracy {
    if (totalAttempts == 0) return 0.0;
    return correctAnswers / totalAttempts;
  }

  /// Adaptive review priority score (PRS Section 18).
  double get reviewPriority {
    final daysSinceReview = lastPracticed != null
        ? DateTime.now().difference(lastPracticed!).inDays.toDouble()
        : 100.0;
    final masteryBonus = mastery.value * 2.0;
    return incorrectAnswers + daysSinceReview - masteryBonus;
  }

  /// Create from JSON map.
  factory LetterProgress.fromJson(Map<String, dynamic> json) {
    return LetterProgress(
      letter: json['letter'] as String,
      mastery: MasteryLevel.fromValue(json['mastery'] as int? ?? 0),
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      incorrectAnswers: json['incorrectAnswers'] as int? ?? 0,
      timesReviewed: json['timesReviewed'] as int? ?? 0,
      starsEarned: json['starsEarned'] as int? ?? 0,
      hintsUsed: json['hintsUsed'] as int? ?? 0,
      sessionCount: json['sessionCount'] as int? ?? 0,
      lastPracticed: json['lastPracticed'] != null
          ? DateTime.parse(json['lastPracticed'] as String)
          : null,
      wordsLearned: (json['wordsLearned'] as List<dynamic>?)
              ?.cast<String>() ??
          const [],
    );
  }

  /// Convert to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'letter': letter,
      'mastery': mastery.value,
      'correctAnswers': correctAnswers,
      'incorrectAnswers': incorrectAnswers,
      'timesReviewed': timesReviewed,
      'starsEarned': starsEarned,
      'hintsUsed': hintsUsed,
      'sessionCount': sessionCount,
      'lastPracticed': lastPracticed?.toIso8601String(),
      'wordsLearned': wordsLearned,
    };
  }

  /// Create a copy with optional overrides.
  LetterProgress copyWith({
    String? letter,
    MasteryLevel? mastery,
    int? correctAnswers,
    int? incorrectAnswers,
    int? timesReviewed,
    int? starsEarned,
    int? hintsUsed,
    int? sessionCount,
    DateTime? lastPracticed,
    List<String>? wordsLearned,
  }) {
    return LetterProgress(
      letter: letter ?? this.letter,
      mastery: mastery ?? this.mastery,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      incorrectAnswers: incorrectAnswers ?? this.incorrectAnswers,
      timesReviewed: timesReviewed ?? this.timesReviewed,
      starsEarned: starsEarned ?? this.starsEarned,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      sessionCount: sessionCount ?? this.sessionCount,
      lastPracticed: lastPracticed ?? this.lastPracticed,
      wordsLearned: wordsLearned ?? this.wordsLearned,
    );
  }
}
