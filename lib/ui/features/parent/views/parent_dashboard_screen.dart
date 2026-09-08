import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:alphabet_adventure/data/repositories/content_repository.dart';
import 'package:alphabet_adventure/data/repositories/progress_repository.dart';
import 'package:alphabet_adventure/domain/models/mastery_level.dart';
import 'package:alphabet_adventure/ui/core/app_colors.dart';
import 'package:alphabet_adventure/ui/core/app_fonts.dart';
import 'package:alphabet_adventure/ui/features/parent/widgets/parental_gate_dialog.dart';

/// Parent dashboard displaying letter mastery heatmap, learning stats, and privacy assurance (PRS Section 14).
class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  bool _isUnlocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final passed = await ParentalGateDialog.verify(context);
      if (passed) {
        if (mounted) {
          setState(() {
            _isUnlocked = true;
          });
        }
      } else {
        if (mounted) {
          context.pop();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isUnlocked) {
      return const Scaffold(
        backgroundColor: AppColors.bgSky,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final progressRepo = context.watch<ProgressRepository>();
    final contentRepo = context.watch<ContentRepository>();
    final profile = progressRepo.activeProfile;
    final allLetters = contentRepo.getAllLetters();
    final reviewLetters = progressRepo.getLettersNeedingReview(contentRepo);

    return Scaffold(
      backgroundColor: AppColors.bgSky,
      appBar: AppBar(
        title: Text(
          'Parent Dashboard',
          style: AppFonts.fredoka(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
                        child: const Icon(
                          Icons.face_rounded,
                          size: 38,
                          color: AppColors.secondaryDark,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile?.name ?? 'Child Profile',
                              style: AppFonts.fredoka(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              'Age ${profile?.age ?? 5} • ${profile?.currentStreak ?? 0} Day Streak',
                              style: AppFonts.fredoka(
                                fontSize: 15,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 28),
                  // Metric stats counters
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetric(
                        label: 'Mastered',
                        value: '${progressRepo.masteredLetterCount} / 26',
                        color: AppColors.accentGreen,
                      ),
                      _buildMetric(
                        label: 'Total Stars',
                        value: '${progressRepo.totalStars}',
                        color: AppColors.accentYellowDark,
                      ),
                      _buildMetric(
                        label: 'Stickers',
                        value: '${profile?.unlockedStickerIds.length ?? 0}',
                        color: AppColors.accentPurple,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Letter Mastery Heatmap Header
            Text(
              'Alphabet Mastery Heatmap (A–Z)',
              style: AppFonts.fredoka(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            // A-Z Grid
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: allLetters.map((letter) {
                  final progress = progressRepo.getProgress(letter.char);
                  final mastery = progress.masteryLevel;

                  final color = switch (mastery) {
                    MasteryLevel.unlocked => AppColors.masteryUnlocked,
                    MasteryLevel.introduced => AppColors.masteryIntroduced,
                    MasteryLevel.practicing => AppColors.masteryPracticing,
                    MasteryLevel.mastered => AppColors.masteryMastered,
                    MasteryLevel.superStar => AppColors.masterySuperStar,
                  };

                  return Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        letter.char,
                        style: AppFonts.fredoka(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            // Mastery Legend
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                _buildLegendItem('Unlocked', AppColors.masteryUnlocked),
                _buildLegendItem('Introduced', AppColors.masteryIntroduced),
                _buildLegendItem('Practicing', AppColors.masteryPracticing),
                _buildLegendItem('Mastered', AppColors.masteryMastered),
                _buildLegendItem('Super Star', AppColors.masterySuperStar),
              ],
            ),
            if (reviewLetters.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Letters Recommended for Review',
                style: AppFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accentYellow.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accentYellowDark, width: 2),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.accentYellowDark,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${reviewLetters.length == 1 ? 'Letter' : 'Letters'} '
                        '${reviewLetters.map((l) => l.char).join(", ")} will '
                        'benefit from a quick practice session today!',
                        style: AppFonts.fredoka(
                          fontSize: 16,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 28),
            // COPPA & Privacy Assurance Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.secondary, width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_rounded, color: AppColors.secondaryDark, size: 36),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '100% Privacy & Child Safe',
                          style: AppFonts.fredoka(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'No personal data or advertisements. Fully compliant with COPPA and GDPR-K guidelines.',
                          style: AppFonts.fredoka(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: AppFonts.fredoka(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppFonts.fredoka(
            fontSize: 14,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppFonts.fredoka(
            fontSize: 13,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
