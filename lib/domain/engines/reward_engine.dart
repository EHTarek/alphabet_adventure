import 'package:alphabet_adventure/data/models/child_profile.dart';

/// Reward engine managing stars, streak rewards, and badge unlocks per PRS Section 19.
class RewardEngine {
  const RewardEngine();

  /// Calculates stars earned for an activity/lesson (1 to 3 stars, minimum 1 upon completion).
  ///
  /// Non-punitive design: completing a lesson always awards at least 1 star.
  int calculateStars({
    required int totalQuestions,
    required int correctAnswers,
    required int hintsUsed,
  }) {
    if (totalQuestions == 0) return 1;

    final accuracy = correctAnswers / totalQuestions;

    if (accuracy >= 0.90 && hintsUsed <= 1) {
      return 3;
    } else if (accuracy >= 0.70 && hintsUsed <= 2) {
      return 2;
    } else {
      return 1;
    }
  }

  /// Evaluates if any new achievements/stickers should be unlocked based on updated profile stats.
  List<AchievementReward> checkAchievements({
    required ChildProfile profile,
    required Map<String, dynamic> context,
  }) {
    final newAchievements = <AchievementReward>[];
    final unlockedIds = profile.unlockedStickerIds.toSet();

    // 1. First Letter Completed
    if (profile.totalStars >= 1 && !unlockedIds.contains('first_letter')) {
      newAchievements.add(const AchievementReward(
        id: 'first_letter',
        title: 'Alphabet Pioneer',
        description: 'Completed your very first letter lesson!',
        iconAsset: 'assets/images/ui/badge_pioneer.png',
        type: AchievementType.sticker,
      ));
    }

    // 2. 5 Letters Mastered
    final masteredCount = (context['masteredLetterCount'] as int?) ?? 0;
    if (masteredCount >= 5 && !unlockedIds.contains('master_5')) {
      newAchievements.add(const AchievementReward(
        id: 'master_5',
        title: 'Word Scout',
        description: 'Mastered 5 alphabet letters!',
        iconAsset: 'assets/images/ui/badge_scout.png',
        type: AchievementType.badge,
      ));
    }

    // 3. 10 Letters Mastered
    if (masteredCount >= 10 && !unlockedIds.contains('master_10')) {
      newAchievements.add(const AchievementReward(
        id: 'master_10',
        title: 'Letter Wizard',
        description: 'Mastered 10 alphabet letters!',
        iconAsset: 'assets/images/ui/badge_wizard.png',
        type: AchievementType.badge,
      ));
    }

    // 4. All 26 Letters Mastered
    if (masteredCount >= 26 && !unlockedIds.contains('master_all_26')) {
      newAchievements.add(const AchievementReward(
        id: 'master_all_26',
        title: 'Alphabet Master',
        description: 'Mastered all 26 letters of the alphabet!',
        iconAsset: 'assets/images/ui/badge_master.png',
        type: AchievementType.trophy,
      ));
    }

    // 5. 50 Stars Club
    if (profile.totalStars >= 50 && !unlockedIds.contains('stars_50')) {
      newAchievements.add(const AchievementReward(
        id: 'stars_50',
        title: 'Star Collector',
        description: 'Collected 50 shining stars!',
        iconAsset: 'assets/images/ui/badge_star_50.png',
        type: AchievementType.badge,
      ));
    }

    // 6. 3-Day Streak
    if (profile.currentStreak >= 3 && !unlockedIds.contains('streak_3')) {
      newAchievements.add(const AchievementReward(
        id: 'streak_3',
        title: 'Daily Explorer',
        description: 'Played 3 days in a row!',
        iconAsset: 'assets/images/ui/badge_streak_3.png',
        type: AchievementType.badge,
      ));
    }

    // 7. Perfect Challenge (3 stars without hints)
    final isPerfectSession = (context['isPerfectSession'] as bool?) ?? false;
    if (isPerfectSession && !unlockedIds.contains('perfect_score')) {
      newAchievements.add(const AchievementReward(
        id: 'perfect_score',
        title: 'Eagle Eye',
        description: 'Finished a lesson with 100% accuracy and no hints!',
        iconAsset: 'assets/images/ui/badge_perfect.png',
        type: AchievementType.sticker,
      ));
    }

    return newAchievements;
  }
}

/// Type of achievement reward.
enum AchievementType {
  sticker,
  badge,
  trophy,
}

/// An unlockable achievement or sticker reward.
class AchievementReward {
  final String id;
  final String title;
  final String description;
  final String iconAsset;
  final AchievementType type;

  const AchievementReward({
    required this.id,
    required this.title,
    required this.description,
    required this.iconAsset,
    required this.type,
  });
}
