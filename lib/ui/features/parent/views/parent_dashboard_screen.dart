import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:alphabet_adventure/data/repositories/content_repository.dart';
import 'package:alphabet_adventure/data/repositories/progress_repository.dart';
import 'package:alphabet_adventure/domain/models/mastery_level.dart';
import 'package:alphabet_adventure/ui/core/app_fonts.dart';
import 'package:alphabet_adventure/ui/core/wood/wood.dart';

/// Parent dashboard displaying letter mastery heatmap, learning stats, and privacy assurance (PRS Section 14).
class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

  /// Candy colour of a letter block at each mastery level.
  static WoodToneColors _masteryColors(MasteryLevel mastery) {
    return switch (mastery) {
      MasteryLevel.unlocked => WoodColors.lightWood,
      MasteryLevel.introduced => WoodColors.candyBlue,
      MasteryLevel.practicing => WoodColors.candyOrange,
      MasteryLevel.mastered => WoodColors.candyGreen,
      MasteryLevel.superStar => WoodColors.candyGold,
    };
  }

  @override
  Widget build(BuildContext context) {
    final progressRepo = context.watch<ProgressRepository>();
    final contentRepo = context.watch<ContentRepository>();
    final profile = progressRepo.activeProfile;
    final allLetters = contentRepo.getAllLetters();
    final reviewLetters = progressRepo.getLettersNeedingReview(contentRepo);
    final navigator = Navigator.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            WoodHeader(
              title: 'Parent Dashboard',
              onBack: navigator.canPop() ? () => navigator.maybePop() : null,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Summary Card
                    WoodPanel(
                      radius: 26,
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const CandyBlock(
                                colors: WoodColors.candyPurple,
                                size: 58,
                                child: Icon(
                                  Icons.face_rounded,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profile?.name ?? 'Child Profile',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: WoodText.heading(fontSize: 24),
                                    ),
                                    Text(
                                      'Age ${profile?.age ?? 5} • ${profile?.currentStreak ?? 0} Day Streak',
                                      style: WoodText.body(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: WoodColors.inkSoft,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          // Metric stats counters
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _MetricPlaque(
                                  label: 'Mastered',
                                  value:
                                      '${progressRepo.masteredLetterCount} / 26',
                                  icon: Icons.emoji_events_rounded,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _MetricPlaque(
                                  label: 'Total Stars',
                                  value: '${progressRepo.totalStars}',
                                  icon: Icons.star_rounded,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _MetricPlaque(
                                  label: 'Stickers',
                                  value:
                                      '${profile?.unlockedStickerIds.length ?? 0}',
                                  icon: Icons.auto_awesome_rounded,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          WoodProgressBar(
                            value: progressRepo.masteredLetterCount / 26,
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Letter Mastery Heatmap
                    _DashboardSection(
                      // A word joiner keeps "(A–Z)" from breaking at the dash.
                      title: 'Alphabet Mastery Heatmap (A–\u2060Z)',
                      icon: Icons.grid_view_rounded,
                      iconColors: WoodColors.candyGreen,
                      children: [
                        // A-Z Grid
                        _LetterBoard(
                          blocks: [
                            for (final letter in allLetters)
                              (
                                letter.char,
                                _masteryColors(
                                  progressRepo
                                      .getProgress(letter.char)
                                      .masteryLevel,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Mastery Legend
                        _ParchmentInset(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Wrap(
                            spacing: 14,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              for (final level in MasteryLevel.values)
                                _buildLegendItem(
                                  _legendLabel(level),
                                  _masteryColors(level),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (reviewLetters.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _DashboardSection(
                        title: 'Letters Recommended for Review',
                        icon: Icons.auto_awesome_rounded,
                        iconColors: WoodColors.candyOrange,
                        children: [
                          _ParchmentInset(
                            child: Column(
                              children: [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    for (final (i, letter)
                                        in reviewLetters.indexed)
                                      ExcludeSemantics(
                                        child: CandyBlock(
                                          colors:
                                              WoodColors.blockCycle[i %
                                                  WoodColors.blockCycle.length],
                                          size: 46,
                                          letter: letter.char,
                                          rotation: (i.isEven ? -1 : 1) * 0.06,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '${reviewLetters.length == 1 ? 'Letter' : 'Letters'} '
                                  '${reviewLetters.map((l) => l.char).join(", ")} will '
                                  'benefit from a quick practice session today!',
                                  textAlign: TextAlign.center,
                                  style: WoodText.body(fontSize: 17),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),
                    // COPPA & Privacy Assurance Card
                    _DashboardSection(
                      title: '100% Privacy & Child Safe',
                      icon: Icons.shield_rounded,
                      iconColors: WoodColors.candyBlue,
                      children: [
                        _ParchmentInset(
                          child: Text(
                            'No personal data or advertisements. Fully compliant with COPPA and GDPR-K guidelines.',
                            style: WoodText.body(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _legendLabel(MasteryLevel level) {
    return switch (level) {
      MasteryLevel.unlocked => 'Unlocked',
      MasteryLevel.introduced => 'Introduced',
      MasteryLevel.practicing => 'Practicing',
      MasteryLevel.mastered => 'Mastered',
      MasteryLevel.superStar => 'Super Star',
    };
  }

  Widget _buildLegendItem(String label, WoodToneColors colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CandyBlock(colors: colors, size: 20),
        const SizedBox(width: 6),
        Text(
          label,
          style: WoodText.body(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// A pale-wood panel with a candy icon block and an ink heading.
class _DashboardSection extends StatelessWidget {
  const _DashboardSection({
    required this.title,
    required this.icon,
    required this.iconColors,
    required this.children,
  });

  final String title;
  final IconData icon;
  final WoodToneColors iconColors;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return WoodPanel(
      radius: 26,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CandyBlock(
                colors: iconColors,
                size: 38,
                child: Icon(icon, size: 24, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title, style: WoodText.heading(fontSize: 20)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _ParchmentInset extends StatelessWidget {
  const _ParchmentInset({
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: WoodColors.parchment,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WoodColors.parchmentEdge, width: 2),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), offset: Offset(0, -1)),
        ],
      ),
      child: child,
    );
  }
}

/// A summary number in golden lettering on a dark walnut plaque.
class _MetricPlaque extends StatelessWidget {
  const _MetricPlaque({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ink = WoodColors.darkWood.ink;
    return WoodPanel(
      tone: WoodTone.dark,
      radius: 16,
      depth: 5,
      padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
      child: Column(
        children: [
          Icon(icon, size: 20, color: WoodColors.goldTop),
          SizedBox(
            height: 36,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: WoodTitle(value, fontSize: 26, maxLines: 1),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: AppFonts.fredoka(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The A–Z letters as candy blocks sitting in a recessed wooden board.
class _LetterBoard extends StatelessWidget {
  const _LetterBoard({required this.blocks});

  /// Each letter with the colours of its block.
  final List<(String, WoodToneColors)> blocks;

  static const double _spacing = 6;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: WoodColors.cellDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WoodColors.cellLine, width: 3),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          // Six across on phones keeps A–Z in tidy rows; wider boards add more.
          final columns = (width / 56).floor().clamp(6, 13);
          final size = ((width - _spacing * (columns - 1)) / columns)
              .floorToDouble();
          return Wrap(
            spacing: _spacing,
            runSpacing: _spacing,
            alignment: WrapAlignment.center,
            children: [
              for (final (char, colors) in blocks)
                CandyBlock(colors: colors, size: size, letter: char),
            ],
          );
        },
      ),
    );
  }
}
