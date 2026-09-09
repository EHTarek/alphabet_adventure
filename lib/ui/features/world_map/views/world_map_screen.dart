import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:alphabet_adventure/data/models/letter_data.dart';
import 'package:alphabet_adventure/data/models/letter_progress.dart';
import 'package:alphabet_adventure/data/services/audio_service.dart';
import 'package:alphabet_adventure/domain/engines/lesson_controller.dart';
import 'package:alphabet_adventure/domain/models/mastery_level.dart';
import 'package:alphabet_adventure/ui/core/animations/bounce_animation.dart';
import 'package:alphabet_adventure/ui/core/app_colors.dart';
import 'package:alphabet_adventure/ui/core/app_fonts.dart';
import 'package:alphabet_adventure/ui/core/widgets/mascot_widget.dart';
import 'package:alphabet_adventure/ui/core/widgets/star_counter.dart';
import 'package:alphabet_adventure/ui/features/world_map/view_models/world_map_view_model.dart';

/// World map adventure screen with 6 themed environments and letter trails (PRS Section 8 & 15).
class WorldMapScreen extends StatelessWidget {
  const WorldMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<WorldMapViewModel>();
    final currentWorld = viewModel.currentWorld;
    final letters = viewModel.currentWorldLetters;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient based on selected world
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(currentWorld.primaryColorHex).withValues(alpha: 0.25),
                    Color(
                      currentWorld.secondaryColorHex,
                    ).withValues(alpha: 0.15),
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top App Bar: Profile, World Name, Star Counter, Settings
                _buildTopBar(context, viewModel),
                const SizedBox(height: 8),
                // World Selector Carousel
                _buildWorldSelector(context, viewModel),
                const SizedBox(height: 12),
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
    final themeAccent = Color(viewModel.currentWorld.secondaryColorHex);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color?.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: themeAccent.withValues(alpha: 0.65),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: themeAccent.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Avatar Button (switches back to profile selection)
          BounceAnimation(
            onTap: () => context.go('/profile'),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.secondaryDark, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.secondary,
                child: Icon(Icons.face_rounded, color: Colors.white, size: 28),
              ),
            ),
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
                  style: AppFonts.fredoka(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  viewModel.currentWorld.name,
                  maxLines: 1,
                  style: AppFonts.fredoka(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  'Level ${viewModel.currentWorld.difficulty}: '
                  '${viewModel.currentWorld.difficultyLabel}',
                  style: AppFonts.fredoka(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          // Star Counter
          StarCounter(count: viewModel.totalStars),
          // Home button to return to mode choice menu
          IconButton(
            icon: Icon(
              Icons.home_rounded,
              size: 28,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            onPressed: () => context.go('/'),
          ),
        ],
      ),
    );
  }

  Widget _buildWorldSelector(
    BuildContext context,
    WorldMapViewModel viewModel,
  ) {
    final worlds = viewModel.worlds;

    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: worlds.length,
        itemBuilder: (context, index) {
          final world = worlds[index];
          final isSelected = index == viewModel.selectedWorldIndex;
          final isUnlocked = viewModel.isWorldUnlocked(world);

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: BounceAnimation(
              onTap: () {
                if (isUnlocked) {
                  viewModel.selectWorld(index);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Unlock this world with ${world.requiredStarsToUnlock} stars!',
                        style: AppFonts.fredoka(),
                      ),
                      backgroundColor: AppColors.tryAgain,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Color(world.primaryColorHex)
                      : Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? Colors.white
                        : Color(world.primaryColorHex).withValues(alpha: 0.5),
                    width: isSelected ? 3 : 2,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: Color(
                          world.primaryColorHex,
                        ).withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isUnlocked) ...[
                      const Icon(
                        Icons.lock_rounded,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      world.name,
                      style: AppFonts.fredoka(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : (isUnlocked ? Theme.of(context).textTheme.bodyLarge?.color : Colors.grey),
                      ),
                    ),
                  ],
                ),
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
    const nodeHeight = 156.0;
    final trailHeight = (letters.length * nodeHeight) + 80;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: SizedBox(
        height: trailHeight,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _DesertTrailPainter(
                  nodeCount: letters.length,
                  worldId: viewModel.currentWorld.id,
                ),
              ),
            ),
            for (var index = 0; index < letters.length; index++)
              Positioned(
                top: 22 + (index * nodeHeight),
                left: index.isEven ? 24 : null,
                right: index.isOdd ? 24 : null,
                child: _buildLetterTrailNode(
                  context: context,
                  letter: letters[index],
                  progress: viewModel.getLetterProgress(letters[index].char),
                  isUnlocked: viewModel.isLetterUnlocked(letters[index]),
                  isLeftAligned: index.isEven,
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
    required bool isLeftAligned,
    required VoidCallback onTap,
  }) {
    final mastery = progress.masteryLevel;
    final stars = progress.starsEarned;

    final nodeColor = !isUnlocked
        ? AppColors.masteryUnlocked
        : switch (mastery) {
            MasteryLevel.unlocked => AppColors.primary,
            MasteryLevel.introduced => AppColors.secondary,
            MasteryLevel.practicing => AppColors.accentOrange,
            MasteryLevel.mastered => AppColors.accentGreen,
            MasteryLevel.superStar => AppColors.accentYellow,
          };

    final hintWord = letter.words.isNotEmpty ? letter.words.first : letter.char;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: isLeftAligned
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          BounceAnimation(
            onTap: onTap,
            child: Container(
              width: 130,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: nodeColor, width: 3.5),
                boxShadow: [
                  BoxShadow(
                    color: nodeColor.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Large Letter Glyph Circle
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: nodeColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${letter.uppercase}${letter.lowercase}',
                        style: AppFonts.fredoka(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Word name hint
                  Text(
                    hintWord,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.fredoka(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  if (!isUnlocked)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.lock_rounded,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'Preview',
                            style: AppFonts.fredoka(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 4),
                  // Stars Earned Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (starIndex) {
                      final isFilled = starIndex < stars;
                      return Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: isFilled
                            ? AppColors.accentYellowDark
                            : Colors.grey.shade300,
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Row(
          children: [
            const Icon(Icons.lock_rounded, color: AppColors.tryAgain),
            const SizedBox(width: 8),
            Text(
              'Adventure Preview',
              style: AppFonts.fredoka(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        content: Text(
          'Letter ${letter.uppercase}${letter.lowercase} is waiting in ${world.name}. '
          'You will meet ${previewWord.toUpperCase()} after earning '
          '${world.requiredStarsToUnlock} stars.',
          style: AppFonts.fredoka(
            fontSize: 17,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            height: 1.35,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Keep Exploring',
              style: AppFonts.fredoka(fontWeight: FontWeight.bold),
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

class _DesertTrailPainter extends CustomPainter {
  const _DesertTrailPainter({required this.nodeCount, required this.worldId});

  final int nodeCount;
  final String worldId;

  @override
  void paint(Canvas canvas, Size size) {
    final palette = _MapPalette.forWorld(worldId);
    final sand = Paint()..color = palette.ground;
    canvas.drawRect(Offset.zero & size, sand);

    final sky = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [palette.skyTop, palette.skyBottom],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, sky);

    final dunePaint = Paint()..color = palette.farLand;
    final farDune = Path()
      ..moveTo(0, size.height * 0.18)
      ..quadraticBezierTo(
        size.width * 0.27,
        size.height * 0.08,
        size.width * 0.52,
        size.height * 0.2,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.32,
        size.width,
        size.height * 0.17,
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(farDune, dunePaint);

    final nearDunePaint = Paint()..color = palette.nearLand;
    final nearDune = Path()
      ..moveTo(0, size.height * 0.73)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.6,
        size.width * 0.48,
        size.height * 0.74,
      )
      ..quadraticBezierTo(
        size.width * 0.76,
        size.height * 0.88,
        size.width,
        size.height * 0.67,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(nearDune, nearDunePaint);

    final road = Path();
    final roadLine = Path();
    final nodeSpacing = nodeCount <= 1
        ? size.height
        : (size.height - 48) / (nodeCount - 1);

    for (var index = 0; index < nodeCount; index++) {
      final y = 36 + (index * nodeSpacing);
      final direction = index.isEven ? 1.0 : -1.0;
      final centerX = size.width * 0.5 + direction * size.width * 0.13;
      final lineX = size.width * 0.5 + direction * size.width * 0.08;
      if (index == 0) {
        roadLine.moveTo(lineX, y);
      } else {
        roadLine.lineTo(lineX, y);
      }

      final depth = index / (nodeCount.clamp(2, 100) - 1);
      final roadWidth = 32 + (depth * 100);
      if (index == 0) {
        road.moveTo(centerX - roadWidth, y);
      } else {
        road.lineTo(centerX - roadWidth, y);
      }
    }

    for (var index = nodeCount - 1; index >= 0; index--) {
      final y = 36 + (index * nodeSpacing);
      final direction = index.isEven ? 1.0 : -1.0;
      final centerX = size.width * 0.5 + direction * size.width * 0.13;
      final depth = index / (nodeCount.clamp(2, 100) - 1);
      final roadWidth = 32 + (depth * 100);
      road.lineTo(centerX + roadWidth, y);
    }
    road.close();

    canvas.drawPath(road, Paint()..color = palette.road);
    canvas.drawPath(
      road,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = palette.roadEdge,
    );
    canvas.drawPath(
      roadLine,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..color = palette.route,
    );

    final cactusPaint = Paint()..color = palette.landmark;
    for (var index = 0; index < nodeCount; index += 3) {
      final y = 70 + index * nodeSpacing;
      final x = index.isEven ? size.width * 0.12 : size.width * 0.86;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, y), width: 12, height: 42),
          const Radius.circular(6),
        ),
        cactusPaint,
      );
      canvas.drawCircle(Offset(x - 9, y + 6), 6, cactusPaint);
      canvas.drawCircle(Offset(x + 9, y - 5), 6, cactusPaint);
    }

    final oasisPaint = Paint()..color = palette.water;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.78, size.height - 38),
        width: 72,
        height: 26,
      ),
      oasisPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.78, size.height - 46),
      Offset(size.width * 0.78, size.height - 92),
      Paint()
        ..color = palette.landmark
        ..strokeWidth = 7,
    );
    canvas.drawCircle(
      Offset(size.width * 0.75, size.height - 88),
      18,
      Paint()..color = palette.landmark,
    );

    _drawWorldLandmarks(canvas, size, palette, nodeSpacing);
  }

  void _drawWorldLandmarks(
    Canvas canvas,
    Size size,
    _MapPalette palette,
    double nodeSpacing,
  ) {
    final landmarkPaint = Paint()..color = palette.landmark;
    switch (worldId) {
      case 'ocean':
        for (var y = 90.0; y < size.height; y += 130) {
          canvas.drawArc(
            Rect.fromCenter(
              center: Offset(size.width * 0.18, y),
              width: 70,
              height: 24,
            ),
            0,
            3.14,
            false,
            landmarkPaint
              ..style = PaintingStyle.stroke
              ..strokeWidth = 5,
          );
        }
        break;
      case 'space':
        final starPaint = Paint()..color = palette.route;
        for (var index = 0; index < nodeCount; index++) {
          canvas.drawCircle(
            Offset(
              (index.isEven ? 0.13 : 0.86) * size.width,
              60 + index * nodeSpacing,
            ),
            index.isEven ? 3 : 5,
            starPaint,
          );
        }
        break;
      case 'forest':
        for (var index = 0; index < nodeCount; index += 2) {
          final x = index.isEven ? size.width * 0.12 : size.width * 0.87;
          final y = 92 + index * nodeSpacing;
          final trunk = Paint()..color = const Color(0xFF795548);
          canvas.drawRect(Rect.fromLTWH(x - 3, y, 6, 28), trunk);
          canvas.drawCircle(Offset(x, y - 5), 18, landmarkPaint);
        }
        break;
      case 'farm':
      case 'playground':
      case 'home':
      default:
        for (var index = 0; index < nodeCount; index += 3) {
          final x = index.isEven ? size.width * 0.12 : size.width * 0.87;
          final y = 90 + index * nodeSpacing;
          canvas.drawCircle(Offset(x, y), 10, landmarkPaint);
        }
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _DesertTrailPainter oldDelegate) {
    return oldDelegate.nodeCount != nodeCount || oldDelegate.worldId != worldId;
  }
}

class _MapPalette {
  const _MapPalette({
    required this.skyTop,
    required this.skyBottom,
    required this.ground,
    required this.farLand,
    required this.nearLand,
    required this.road,
    required this.roadEdge,
    required this.route,
    required this.landmark,
    required this.water,
  });

  final Color skyTop;
  final Color skyBottom;
  final Color ground;
  final Color farLand;
  final Color nearLand;
  final Color road;
  final Color roadEdge;
  final Color route;
  final Color landmark;
  final Color water;

  static _MapPalette forWorld(String worldId) {
    switch (worldId) {
      case 'farm':
        return const _MapPalette(
          skyTop: Color(0xFF9EDCF1),
          skyBottom: Color(0xFFFFE4A8),
          ground: Color(0xFFF2D38B),
          farLand: Color(0xFFC8D978),
          nearLand: Color(0xFFD8B45C),
          road: Color(0xFF9A7047),
          roadEdge: Color(0xFFF9E0A2),
          route: Color(0xFFFFF1B5),
          landmark: Color(0xFF78A94B),
          water: Color(0xFF5DB8C0),
        );
      case 'playground':
        return const _MapPalette(
          skyTop: Color(0xFF8BDCF2),
          skyBottom: Color(0xFFFFD2B8),
          ground: Color(0xFFF5B5A8),
          farLand: Color(0xFFF38F9B),
          nearLand: Color(0xFFE77A70),
          road: Color(0xFF7C79B8),
          roadEdge: Color(0xFFFFC8E2),
          route: Color(0xFFFFF4A8),
          landmark: Color(0xFF45A6B6),
          water: Color(0xFF72D3D5),
        );
      case 'home':
        return const _MapPalette(
          skyTop: Color(0xFFFFD6A1),
          skyBottom: Color(0xFFFFF0C2),
          ground: Color(0xFFEFCB9C),
          farLand: Color(0xFFDDB27E),
          nearLand: Color(0xFFC89162),
          road: Color(0xFF9B6B4A),
          roadEdge: Color(0xFFFFE2B8),
          route: Color(0xFFFFF4CC),
          landmark: Color(0xFFD86E56),
          water: Color(0xFF7CC8C0),
        );
      case 'ocean':
        return const _MapPalette(
          skyTop: Color(0xFF65CDE0),
          skyBottom: Color(0xFFB8F0E5),
          ground: Color(0xFF8FD6CA),
          farLand: Color(0xFF68BDBA),
          nearLand: Color(0xFF4DA5AD),
          road: Color(0xFF4D8C9F),
          roadEdge: Color(0xFFB9F4E6),
          route: Color(0xFFFFF2A8),
          landmark: Color(0xFF4D9B70),
          water: Color(0xFF197FA8),
        );
      case 'space':
        return const _MapPalette(
          skyTop: Color(0xFF20295F),
          skyBottom: Color(0xFF4C3D83),
          ground: Color(0xFF30295B),
          farLand: Color(0xFF3F3978),
          nearLand: Color(0xFF28244E),
          road: Color(0xFF6962A8),
          roadEdge: Color(0xFFA9A4F0),
          route: Color(0xFFFFE68A),
          landmark: Color(0xFFE37BC5),
          water: Color(0xFF4DAFC0),
        );
      case 'forest':
      default:
        return const _MapPalette(
          skyTop: Color(0xFF8ED9E8),
          skyBottom: Color(0xFFF7D99A),
          ground: Color(0xFFF4C978),
          farLand: Color(0xFFE6A956),
          nearLand: Color(0xFFD8954B),
          road: Color(0xFFB86F3B),
          roadEdge: Color(0xFFF8D58B),
          route: Color(0xFFFFE49A),
          landmark: Color(0xFF4E9B68),
          water: Color(0xFF4CB7B0),
        );
    }
  }
}
