import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:alphabet_adventure/data/content/world_themes.dart';
import 'package:alphabet_adventure/data/models/letter_data.dart';
import 'package:alphabet_adventure/data/models/letter_progress.dart';
import 'package:alphabet_adventure/data/services/audio_service.dart';
import 'package:alphabet_adventure/domain/engines/lesson_controller.dart';
import 'package:alphabet_adventure/domain/models/mastery_level.dart';
import 'package:alphabet_adventure/ui/core/app_fonts.dart';
import 'package:alphabet_adventure/ui/core/widgets/mascot_widget.dart';
import 'package:alphabet_adventure/ui/core/widgets/star_counter.dart';
import 'package:alphabet_adventure/ui/core/wood/wood.dart';
import 'package:alphabet_adventure/ui/features/world_map/view_models/world_map_view_model.dart';

/// Layout of the letter trail, shared by [WorldMapScreen._buildLetterTrail]
/// and [_TrailRoutePainter] so the dashed route always meets the tiles.
abstract final class _TrailLayout {
  /// Vertical distance between consecutive letter tiles.
  static const double nodeSpacing = 172;

  /// Offset of the first tile from the top of the trail.
  static const double topOffset = 18;

  /// Distance of a tile from its (alternating) screen edge.
  static const double sideInset = 22;

  /// Width of a letter tile.
  static const double nodeWidth = 136;

  /// Padding above the candy block inside a tile.
  static const double blockTop = 12;

  /// Edge of the candy letter block inside a tile.
  static const double blockSize = 74;

  /// Where the route passes through a tile: the centre of its candy block.
  static const double routeInset = sideInset + nodeWidth / 2;
  static const double firstRouteY = topOffset + blockTop + blockSize / 2;
}

/// World map adventure screen with 6 themed environments and letter trails (PRS Section 8 & 15).
class WorldMapScreen extends StatelessWidget {
  const WorldMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<WorldMapViewModel>();
    final letters = viewModel.currentWorldLetters;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Top App Bar: Profile, World Name, Star Counter, Home
                _buildTopBar(context, viewModel),
                const SizedBox(height: 10),
                // World Selector Carousel
                _buildWorldSelector(context, viewModel),
                const SizedBox(height: 6),
                // Adventure Trail Letters List
                Expanded(child: _buildLetterTrail(context, viewModel, letters)),
              ],
            ),
          ),
          // Floating Pip Mascot at bottom corner
          Positioned(
            bottom: 16,
            right: 16,
            child: MascotWidget(
              mood: MascotMood.happy,
              size: 80,
              showSpeechBubble: false,
              onTap: () {
                final audio = context.read<AudioService>();
                audio.playMascotEncouragement();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, WorldMapViewModel viewModel) {
    final profile = viewModel.activeProfile;
    final world = viewModel.currentWorld;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: WoodPanel(
        radius: 26,
        padding: const EdgeInsets.fromLTRB(10, 9, 8, 9),
        child: Row(
          children: [
            // Profile Avatar Button (switches back to profile selection)
            WoodButton(
              onPressed: () => context.go('/profile'),
              colors: WoodColors.blockCycle[1],
              width: 54,
              height: 54,
              radius: 27,
              depth: 5,
              padding: EdgeInsets.zero,
              semanticLabel: 'Profiles',
              child: const Icon(Icons.face_rounded, size: 32),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    profile?.name ?? 'Explorer',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: WoodText.heading(fontSize: 19),
                  ),
                  Text(
                    world.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: WoodText.body(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ).copyWith(height: 1.15),
                  ),
                  Text(
                    'Level ${world.difficulty}: ${world.difficultyLabel}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: WoodText.body(
                      fontSize: 12,
                      color: WoodColors.inkSoft,
                    ).copyWith(height: 1.15),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            // Star Counter
            StarCounter(count: viewModel.totalStars),
            const SizedBox(width: 8),
            // Home button to return to mode choice menu
            WoodIconButton(
              icon: Icons.home_rounded,
              size: 50,
              tooltip: 'Home',
              onPressed: () => context.go('/'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorldSelector(
    BuildContext context,
    WorldMapViewModel viewModel,
  ) {
    final worlds = viewModel.worlds;

    return SizedBox(
      height: 62,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 2, 12, 0),
        itemCount: worlds.length,
        itemBuilder: (context, index) {
          final world = worlds[index];
          final isSelected = index == viewModel.selectedWorldIndex;
          final isUnlocked = viewModel.isWorldUnlocked(world);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: _WorldChip(
                world: world,
                isSelected: isSelected,
                isUnlocked: isUnlocked,
                onPressed: () {
                  if (isUnlocked) {
                    viewModel.selectWorld(index);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Unlock this world with ${world.requiredStarsToUnlock} stars!',
                          style: AppFonts.fredoka(),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLetterTrail(
    BuildContext context,
    WorldMapViewModel viewModel,
    List<LetterData> letters,
  ) {
    const nodeHeight = _TrailLayout.nodeSpacing;
    final trailHeight = (letters.length * nodeHeight) + 60;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: SizedBox(
        height: trailHeight,
        child: Stack(
          children: [
            Positioned.fill(
              // Own layer, so scrolling does not re-dash the route every frame.
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _TrailRoutePainter(
                    nodeCount: letters.length,
                    nodeSpacing: nodeHeight,
                  ),
                ),
              ),
            ),
            for (var index = 0; index < letters.length; index++)
              Positioned(
                top: _TrailLayout.topOffset + (index * nodeHeight),
                left: index.isEven ? _TrailLayout.sideInset : null,
                right: index.isOdd ? _TrailLayout.sideInset : null,
                child: _buildLetterTrailNode(
                  context: context,
                  letter: letters[index],
                  progress: viewModel.getLetterProgress(letters[index].char),
                  isUnlocked: viewModel.isLetterUnlocked(letters[index]),
                  onTap: () {
                    if (viewModel.isLetterUnlocked(letters[index])) {
                      _onLetterNodeTapped(context, viewModel, letters[index]);
                    } else {
                      _showLockedLessonPreview(
                        context,
                        viewModel,
                        letters[index],
                      );
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLetterTrailNode({
    required BuildContext context,
    required LetterData letter,
    required LetterProgress progress,
    required bool isUnlocked,
    required VoidCallback onTap,
  }) {
    final stars = progress.starsEarned;
    final blockColors = isUnlocked
        ? _masteryBlockColors(progress.masteryLevel)
        : WoodColors.darkWood;
    final hintWord = letter.words.isNotEmpty ? letter.words.first : letter.char;

    return WoodButton(
      onPressed: onTap,
      width: _TrailLayout.nodeWidth,
      radius: 26,
      padding: const EdgeInsets.fromLTRB(8, _TrailLayout.blockTop, 8, 8),
      semanticLabel: 'Letter ${letter.uppercase}',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Candy letter block, coloured by mastery
          Stack(
            clipBehavior: Clip.none,
            children: [
              CandyBlock(
                colors: blockColors,
                size: _TrailLayout.blockSize,
                letter: '${letter.uppercase}${letter.lowercase}',
              ),
              if (!isUnlocked)
                const Positioned(
                  right: -10,
                  top: -8,
                  child: CandyBlock(
                    colors: WoodColors.candyOrange,
                    size: 28,
                    child: Icon(
                      Icons.lock_rounded,
                      size: 17,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          // Word name hint
          Text(
            hintWord,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: WoodText.heading(fontSize: 16),
          ),
          if (!isUnlocked)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_rounded,
                  size: 14,
                  color: WoodColors.inkSoft,
                ),
                const SizedBox(width: 3),
                Text(
                  'Preview',
                  style: WoodText.body(
                    fontSize: 13,
                    color: WoodColors.inkSoft,
                    fontWeight: FontWeight.w600,
                  ).copyWith(height: 1.1),
                ),
              ],
            ),
          const SizedBox(height: 2),
          // Stars Earned Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (starIndex) => _TrailStar(filled: starIndex < stars),
            ),
          ),
        ],
      ),
    );
  }

  /// Candy colours for a letter block at [mastery].
  static WoodToneColors _masteryBlockColors(MasteryLevel mastery) {
    return switch (mastery) {
      MasteryLevel.unlocked => WoodColors.candyRed,
      MasteryLevel.introduced => WoodColors.blockCycle[1],
      MasteryLevel.practicing => WoodColors.candyOrange,
      MasteryLevel.mastered => WoodColors.candyGreen,
      MasteryLevel.superStar => WoodColors.candyGold,
    };
  }

  void _showLockedLessonPreview(
    BuildContext context,
    WorldMapViewModel viewModel,
    LetterData letter,
  ) {
    final world = viewModel.currentWorld;
    final previewWord = letter.words.isNotEmpty
        ? letter.words.first
        : 'letter ${letter.char}';

    showDialog<void>(
      context: context,
      builder: (dialogContext) => WoodDialog(
        title: 'Adventure Preview',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CandyBlock(
                  colors: WoodColors.darkWood,
                  size: 72,
                  letter: '${letter.uppercase}${letter.lowercase}',
                ),
                const Positioned(
                  right: -12,
                  top: -10,
                  child: CandyBlock(
                    colors: WoodColors.candyOrange,
                    size: 32,
                    child: Icon(
                      Icons.lock_rounded,
                      size: 19,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Letter ${letter.uppercase}${letter.lowercase} is waiting in ${world.name}. '
              'You will meet ${previewWord.toUpperCase()} after earning '
              '${world.requiredStarsToUnlock} stars.',
              textAlign: TextAlign.center,
              style: WoodText.body(fontSize: 17).copyWith(height: 1.35),
            ),
          ],
        ),
        actions: [
          WoodButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            tone: WoodTone.green,
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
            child: Text(
              'Keep Exploring',
              style: WoodText.button(fontSize: 21, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _onLetterNodeTapped(
    BuildContext context,
    WorldMapViewModel viewModel,
    LetterData letter,
  ) {
    final lesson = viewModel.getLessonForLetter(letter);
    final lessonController = context.read<LessonController>();
    lessonController.startLesson(lesson);

    context.push('/game');
  }
}

/// A world selector chip: pale wood, candy-coloured from the world when
/// selected, dimmed with a lock while the world is still locked.
class _WorldChip extends StatelessWidget {
  const _WorldChip({
    required this.world,
    required this.isSelected,
    required this.isUnlocked,
    required this.onPressed,
  });

  final WorldTheme world;
  final bool isSelected;
  final bool isUnlocked;
  final VoidCallback onPressed;

  /// Turns a world's (often muted) theme colour into a bright candy tone.
  static WoodToneColors _candyFor(Color color) {
    final hsl = HSLColor.fromColor(color);
    final base = hsl
        .withSaturation(hsl.saturation.clamp(0.55, 0.85))
        .withLightness(hsl.lightness.clamp(0.46, 0.56))
        .toColor();
    final shade = hsl
        .withSaturation(hsl.saturation.clamp(0.55, 0.85))
        .withLightness(0.32)
        .toColor();
    return WoodToneColors.fromColor(base, shade);
  }

  @override
  Widget build(BuildContext context) {
    final colors = isSelected
        ? _candyFor(Color(world.primaryColorHex))
        : WoodColors.lightWood;
    final ink = isUnlocked ? colors.ink : WoodColors.inkSoft;

    return Opacity(
      opacity: isUnlocked ? 1 : 0.72,
      child: WoodButton(
        onPressed: onPressed,
        colors: colors,
        height: 52,
        radius: 20,
        depth: 5,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        semanticLabel: isUnlocked ? null : '${world.name}, locked',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isUnlocked) ...[
              Icon(Icons.lock_rounded, size: 18, color: ink),
              const SizedBox(width: 6),
            ],
            Text(
              world.name,
              style: WoodText.button(fontSize: 17, color: ink).copyWith(
                shadows: isSelected
                    ? [
                        Shadow(
                          color: colors.bevel,
                          offset: const Offset(0, 1.5),
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One star under a letter tile: golden when earned, carved into the wood
/// when not.
class _TrailStar extends StatelessWidget {
  const _TrailStar({required this.filled});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.star_rounded,
      size: 24,
      color: filled
          ? WoodColors.goldBottom
          : WoodColors.lightWood.bevel.withValues(alpha: 0.32),
      shadows: [
        filled
            ? const Shadow(
                color: WoodColors.goldOutline,
                offset: Offset(0, 1.5),
              )
            : Shadow(
                color: WoodColors.lightWood.highlight.withValues(alpha: 0.9),
                offset: const Offset(0, 1.2),
              ),
      ],
    );
  }
}

/// A dashed wooden route linking the letter tiles, drawn over the blossom
/// scene behind them.
class _TrailRoutePainter extends CustomPainter {
  const _TrailRoutePainter({
    required this.nodeCount,
    required this.nodeSpacing,
  });

  final int nodeCount;
  final double nodeSpacing;

  /// Matches the tile layout in [WorldMapScreen._buildLetterTrail] via
  /// [_TrailLayout]: the route runs through the centre of each candy block.
  static const double _nodeInset = _TrailLayout.routeInset;
  static const double _firstNodeCenterY = _TrailLayout.firstRouteY;
  static const double _dash = 16;
  static const double _gap = 11;

  @override
  void paint(Canvas canvas, Size size) {
    if (nodeCount < 2) return;

    final route = Path();
    Offset? previous;
    for (var index = 0; index < nodeCount; index++) {
      final node = Offset(
        index.isEven ? _nodeInset : size.width - _nodeInset,
        _firstNodeCenterY + index * nodeSpacing,
      );
      if (previous == null) {
        route.moveTo(node.dx, node.dy);
      } else {
        route.cubicTo(
          previous.dx,
          previous.dy + nodeSpacing * 0.55,
          node.dx,
          node.dy - nodeSpacing * 0.55,
          node.dx,
          node.dy,
        );
      }
      previous = node;
    }

    final dashes = Path();
    for (final metric in route.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += _dash + _gap) {
        dashes.addPath(metric.extractPath(d, d + _dash), Offset.zero);
      }
    }

    canvas
      // Soft shadow and dark bevel give each dash the thickness of a plank.
      ..drawPath(
        dashes.shift(const Offset(0, 4)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12
          ..strokeCap = StrokeCap.round
          ..color = const Color(0x40000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      )
      ..drawPath(
        dashes.shift(const Offset(0, 2.5)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12
          ..strokeCap = StrokeCap.round
          ..color = WoodColors.lightWood.bevel,
      )
      ..drawPath(
        dashes,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12
          ..strokeCap = StrokeCap.round
          ..color = WoodColors.lightWood.rim,
      )
      ..drawPath(
        dashes,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round
          ..color = WoodColors.lightWood.top,
      );
  }

  @override
  bool shouldRepaint(covariant _TrailRoutePainter oldDelegate) {
    return oldDelegate.nodeCount != nodeCount ||
        oldDelegate.nodeSpacing != nodeSpacing;
  }
}
