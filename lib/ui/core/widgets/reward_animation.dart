import 'package:flutter/material.dart';

import 'package:alphabet_adventure/ui/core/animations/celebration_animation.dart';
import 'package:alphabet_adventure/ui/core/wood/wood.dart';

/// Full-screen or modal celebration reward animation displaying 1 to 3 animated stars.
class RewardAnimation extends StatefulWidget {
  final int stars;
  final String title;
  final String subtitle;
  final VoidCallback onContinue;

  const RewardAnimation({
    super.key,
    required this.stars,
    this.title = 'Super Star!',
    this.subtitle = 'You finished this challenge!',
    required this.onContinue,
  });

  @override
  State<RewardAnimation> createState() => _RewardAnimationState();
}

class _RewardAnimationState extends State<RewardAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _revealedStars = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _controller.forward();
    _animateStars();
  }

  Future<void> _animateStars() async {
    for (int i = 1; i <= widget.stars; i++) {
      await Future.delayed(const Duration(milliseconds: 350));
      if (mounted) {
        setState(() {
          _revealedStars = i;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CelebrationAnimation(
      isPlaying: true,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: WoodPanel(
                    radius: 30,
                    depth: 8,
                    padding: const EdgeInsets.fromLTRB(20, 46, 20, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          widget.subtitle,
                          textAlign: TextAlign.center,
                          style: WoodText.body(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _StarTray(revealed: _revealedStars),
                        const SizedBox(height: 22),
                        WoodButton(
                          onPressed: widget.onContinue,
                          tone: WoodTone.green,
                          height: 64,
                          radius: 22,
                          depth: 7,
                          child: Text(
                            'Keep Going!',
                            style:
                                WoodText.button(
                                  fontSize: 24,
                                  color: Colors.white,
                                ).copyWith(
                                  shadows: const [
                                    Shadow(
                                      color: Color(0xFF145A2E),
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 28,
                  right: 28,
                  child: Center(
                    child: WoodPanel(
                      tone: WoodTone.dark,
                      radius: 20,
                      depth: 6,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: WoodTitle(
                          widget.title,
                          fontSize: 34,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Three star slots recessed into a dark board; earned stars pop in gold.
class _StarTray extends StatelessWidget {
  final int revealed;

  const _StarTray({required this.revealed});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: WoodColors.cellDark,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: WoodColors.cellLine, width: 3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final isEarned = index < revealed;
            return Flexible(
              child: AnimatedScale(
                scale: isEarned ? 1.15 : 0.85,
                duration: const Duration(milliseconds: 300),
                curve: Curves.elasticOut,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _GoldStar(earned: isEarned, lifted: index == 1),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _GoldStar extends StatelessWidget {
  final bool earned;

  /// The middle star sits a little higher, like a podium.
  final bool lifted;

  const _GoldStar({required this.earned, required this.lifted});

  @override
  Widget build(BuildContext context) {
    const size = 64.0;
    return Transform.translate(
      offset: Offset(0, lifted ? -6 : 2),
      child: SizedBox(
        width: size + 12,
        height: size + 12,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Outline and drop edge behind the fill.
            Transform.translate(
              offset: const Offset(0, 3),
              child: Icon(
                Icons.star_rounded,
                size: size + 8,
                color: earned ? WoodColors.goldOutline : WoodColors.cellLine,
              ),
            ),
            Icon(
              Icons.star_rounded,
              size: size + 8,
              color: earned ? WoodColors.goldOutline : WoodColors.cellLine,
            ),
            if (earned)
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [WoodColors.goldTop, WoodColors.goldBottom],
                ).createShader(bounds),
                child: const Icon(Icons.star_rounded, size: size - 4),
              )
            else
              Icon(
                Icons.star_rounded,
                size: size - 4,
                color: const Color(0xFF8A5530).withValues(alpha: 0.6),
              ),
          ],
        ),
      ),
    );
  }
}
