import 'package:alphabet_adventure/data/models/letter_data.dart';
import 'package:alphabet_adventure/domain/models/mastery_level.dart';

/// Engine responsible for calculating mastery level, review priority,
/// and mastery metrics per PRS Sections 12 & 20.
class MasteryEngine {
  const MasteryEngine();

  /// Calculates the updated mastery level based on historical performance.
  ///
  /// Criteria:
  /// - [MasteryLevel.unlocked]: 0 attempts
  /// - [MasteryLevel.introduced]: At least 1 attempt, basic intro completed
  /// - [MasteryLevel.practicing]: Accuracy >= 70% with at least 3 attempts
  /// - [MasteryLevel.mastered]: Accuracy >= 85% across at least 5 attempts, hints used <= 2
  /// - [MasteryLevel.superStar]: Accuracy >= 95% across at least 8 attempts, streak >= 3
  MasteryLevel calculateMasteryLevel({
    required int totalAttempts,
    required int successfulAttempts,
    required int hintsUsed,
    required int currentStreak,
    required int sessionCount,
  }) {
    if (totalAttempts == 0) {
      return MasteryLevel.unlocked;
    }

    final accuracy = totalAttempts > 0 ? (successfulAttempts / totalAttempts) : 0.0;

    if (totalAttempts >= 8 && accuracy >= 0.95 && currentStreak >= 3 && sessionCount >= 2) {
      return MasteryLevel.superStar;
    }

    if (totalAttempts >= 5 && accuracy >= 0.85 && sessionCount >= 2 && hintsUsed <= 3) {
      return MasteryLevel.mastered;
    }

    if (totalAttempts >= 3 && accuracy >= 0.70) {
      return MasteryLevel.practicing;
    }

    return MasteryLevel.introduced;
  }

  /// Calculates an adaptive review priority score (higher = needs review sooner).
  double calculateReviewPriority({
    required MasteryLevel masteryLevel,
    required DateTime? lastPracticedAt,
    required int recentErrors,
    required int totalAttempts,
  }) {
    if (lastPracticedAt == null) {
      return 100.0;
    }

    final hoursSinceLastPractice = DateTime.now().difference(lastPracticedAt).inHours;
    
    double baseScore = switch (masteryLevel) {
      MasteryLevel.unlocked => 50.0,
      MasteryLevel.introduced => 40.0,
      MasteryLevel.practicing => 30.0,
      MasteryLevel.mastered => 15.0,
      MasteryLevel.superStar => 5.0,
    };

    final timeDecay = (hoursSinceLastPractice / 12.0).clamp(0.0, 40.0);
    final errorWeight = (recentErrors * 8.0).clamp(0.0, 30.0);

    return (baseScore + timeDecay + errorWeight).clamp(0.0, 100.0);
  }

  /// Evaluates session results and returns comprehensive mastery update details.
  MasteryEvaluationResult evaluateSession({
    required LetterData letter,
    required int sessionAttempts,
    required int sessionCorrect,
    required int sessionHints,
    required MasteryLevel previousMastery,
    required int historicalAttempts,
    required int historicalCorrect,
    required int historicalHints,
    required int historicalSessions,
    required int currentStreak,
  }) {
    final newTotalAttempts = historicalAttempts + sessionAttempts;
    final newTotalCorrect = historicalCorrect + sessionCorrect;
    final newTotalHints = historicalHints + sessionHints;
    final newSessionCount = historicalSessions + 1;

    final sessionAccuracy = sessionAttempts > 0 ? (sessionCorrect / sessionAttempts) : 0.0;
    final newStreak = sessionAccuracy >= 0.8 ? (currentStreak + 1) : 0;

    final newMastery = calculateMasteryLevel(
      totalAttempts: newTotalAttempts,
      successfulAttempts: newTotalCorrect,
      hintsUsed: newTotalHints,
      currentStreak: newStreak,
      sessionCount: newSessionCount,
    );

    final leveledUp = newMastery.value > previousMastery.value;

    return MasteryEvaluationResult(
      letter: letter,
      previousLevel: previousMastery,
      newLevel: newMastery,
      leveledUp: leveledUp,
      sessionAccuracy: sessionAccuracy,
      totalAccuracy: newTotalAttempts > 0 ? (newTotalCorrect / newTotalAttempts) : 0.0,
      newStreak: newStreak,
    );
  }
}

/// Result of evaluating a completed practice session.
class MasteryEvaluationResult {
  final LetterData letter;
  final MasteryLevel previousLevel;
  final MasteryLevel newLevel;
  final bool leveledUp;
  final double sessionAccuracy;
  final double totalAccuracy;
  final int newStreak;

  const MasteryEvaluationResult({
    required this.letter,
    required this.previousLevel,
    required this.newLevel,
    required this.leveledUp,
    required this.sessionAccuracy,
    required this.totalAccuracy,
    required this.newStreak,
  });
}
