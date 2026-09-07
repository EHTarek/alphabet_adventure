/// Tracks statistics for a single game/lesson session.
class GameSession {
  GameSession({
    required this.lessonId,
    required this.letter,
    DateTime? startedAt,
  }) : startedAt = startedAt ?? DateTime.now();

  /// The lesson being played.
  final String lessonId;

  /// The target letter for this session.
  final String letter;

  /// When the session started.
  final DateTime startedAt;

  /// When the session ended.
  DateTime? completedAt;

  /// Number of correct answers in this session.
  int correctAnswers = 0;

  /// Number of incorrect answers in this session.
  int incorrectAnswers = 0;

  /// Stars earned in this session.
  int starsEarned = 0;

  /// Words learned in this session.
  List<String> wordsLearned = [];

  /// Number of hints used.
  int hintsUsed = 0;

  /// Number of times audio was replayed.
  int audioReplays = 0;

  /// Whether the session was completed (vs. abandoned).
  bool get isCompleted => completedAt != null;

  /// Total answers given.
  int get totalAnswers => correctAnswers + incorrectAnswers;

  /// Session accuracy as a percentage (0.0–1.0).
  double get accuracy {
    if (totalAnswers == 0) return 0.0;
    return correctAnswers / totalAnswers;
  }

  /// Duration of the session.
  Duration get duration {
    final end = completedAt ?? DateTime.now();
    return end.difference(startedAt);
  }

  /// Mark the session as completed.
  void complete() {
    completedAt = DateTime.now();
  }

  /// Record a correct answer.
  void recordCorrect({String? word}) {
    correctAnswers++;
    if (word != null && !wordsLearned.contains(word)) {
      wordsLearned.add(word);
    }
  }

  /// Record an incorrect answer.
  void recordIncorrect() {
    incorrectAnswers++;
  }

  /// Award a star.
  void awardStar() {
    starsEarned++;
  }

  /// Convert to JSON map for analytics/storage.
  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'letter': letter,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'correctAnswers': correctAnswers,
      'incorrectAnswers': incorrectAnswers,
      'starsEarned': starsEarned,
      'wordsLearned': wordsLearned,
      'hintsUsed': hintsUsed,
      'audioReplays': audioReplays,
    };
  }
}
