import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:alphabet_adventure/data/content/alphabet_content.dart';
import 'package:alphabet_adventure/data/repositories/progress_repository.dart';
import 'package:alphabet_adventure/data/services/audio_service.dart';
import 'package:alphabet_adventure/ui/core/widgets/mascot_widget.dart';
import 'package:alphabet_adventure/ui/core/widgets/star_counter.dart';
import 'package:alphabet_adventure/ui/core/wood/wood.dart';
import 'package:alphabet_adventure/ui/features/profile/view_models/profile_view_model.dart';

/// Animated home hub introducing Pip, in the wooden block-puzzle look: the
/// candy-block logo, a progress callout and big wooden menu buttons leading
/// to Game, A to Z, a to z and Words.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  /// Widest the hub content grows on tablets and landscape windows.
  static const double _maxContentWidth = 440;

  late AnimationController _entranceController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeIn,
    );

    _entranceController.forward();

    // Play welcome fanfare sound
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final audio = context.read<AudioService>();
      audio.playCelebrationFanfare();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _navigateTo(String route) async {
    final audio = context.read<AudioService>();
    audio.playTap();

    final progressRepo = context.read<ProgressRepository>();
    if (progressRepo.activeProfile == null) {
      // First launch: auto-create a default profile so the child can play
      // immediately. Profiles can be managed anytime from the world map or profile screen.
      final profileVM = context.read<ProfileViewModel>();
      await profileVM.createProfile(
        name: 'Explorer',
        avatarId: ProfileViewModel.avatarPresets.first.id,
      );
    }
    if (mounted) {
      context.push(route);
    }
  }

  /// The callout above the play button: the child's progress once they have
  /// started, otherwise a friendly prompt.
  String _progressLabel(ProgressRepository progressRepo) {
    final total = AlphabetContent.letters.length;
    final started = progressRepo.activeProfile == null
        ? 0
        : progressRepo.lettersStarted;
    if (started == 0) return 'What would you like to play today?';
    if (started >= total) return 'All $total letters explored!';
    return '$started of $total letters explored';
  }

  @override
  Widget build(BuildContext context) {
    final progressRepo = context.watch<ProgressRepository>();
    final activeProfile = progressRepo.activeProfile;

    return Scaffold(
      body: SizedBox.expand(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final logoWidth = (constraints.maxWidth - 48).clamp(260.0, 360.0);
              final showMascot = constraints.maxHeight >= 760;
              // Keep the menu phone-sized and centred on wide screens.
              final sidePadding = math.max(
                18.0,
                (constraints.maxWidth - _maxContentWidth) / 2 + 18,
              );
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: sidePadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Top Bar: Profile, Stars & Settings
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: _ProfileChip(
                                    name: activeProfile?.name ?? 'Explorer',
                                    avatarId: activeProfile?.avatarId,
                                    onPressed: () => context.push('/profile'),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              StarCounter(count: progressRepo.totalStars),
                              const SizedBox(width: 8),
                              WoodIconButton(
                                icon: Icons.settings_rounded,
                                tooltip: 'Settings',
                                size: 50,
                                onPressed: () => context.push('/settings'),
                              ),
                            ],
                          ),
                        ),

                        // Animated candy-block logo
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: WoodLogo(width: logoWidth),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Pip cheering above the menu, when the
                              // screen is tall enough to keep the menu in view.
                              if (showMascot) ...[
                                Center(
                                  child: MascotWidget(
                                    mood: MascotMood.cheering,
                                    showSpeechBubble: false,
                                    size: 84,
                                    onTap: () {
                                      context
                                          .read<AudioService>()
                                          .playMascotEncouragement();
                                    },
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],

                              // Wooden menu: Game, A to Z, a to z, Words
                              FadeTransition(
                                opacity: _fadeAnimation,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Center(
                                      child: WoodPill(
                                        label: _progressLabel(progressRepo),
                                        tail: true,
                                        fontSize: 15,
                                        leading: const Icon(
                                          Icons.auto_awesome_rounded,
                                          size: 17,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    _MenuButton(
                                      title: 'Game',
                                      subtitle: 'Play Adventure',
                                      icon: const WoodBoardIcon(
                                        size: 58,
                                        pattern: [
                                          '...*',
                                          '.##.',
                                          '##..',
                                          '#...',
                                        ],
                                      ),
                                      onPressed: () =>
                                          _navigateTo('/world_map'),
                                    ),
                                    const SizedBox(height: 12),
                                    _MenuButton(
                                      title: 'A to Z',
                                      subtitle: 'Capital Letters',
                                      icon: const _LetterTrayIcon(
                                        letters: ['A', 'B', 'C', 'D'],
                                      ),
                                      onPressed: () =>
                                          _navigateTo('/library?tab=0'),
                                    ),
                                    const SizedBox(height: 12),
                                    _MenuButton(
                                      title: 'a to z',
                                      subtitle: 'Small Letters',
                                      icon: const _LetterTrayIcon(
                                        letters: ['a', 'b', 'c', 'd'],
                                        colorOffset: 2,
                                      ),
                                      onPressed: () =>
                                          _navigateTo('/library?tab=1'),
                                    ),
                                    const SizedBox(height: 12),
                                    _MenuButton(
                                      title: 'Words',
                                      subtitle: 'Phonics & Objects',
                                      icon: const WoodBoardIcon(
                                        size: 58,
                                        blockColors: WoodColors.candyOrange,
                                        pattern: [
                                          '#..#',
                                          '####',
                                          '.*..',
                                          '###.',
                                        ],
                                      ),
                                      onPressed: () =>
                                          _navigateTo('/library?tab=2'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// The active explorer's name on a small wooden chip, with their avatar colour
/// as a candy block.
class _ProfileChip extends StatelessWidget {
  const _ProfileChip({
    required this.name,
    required this.avatarId,
    required this.onPressed,
  });

  final String name;
  final String? avatarId;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final avatar = ProfileViewModel.avatarPresets.firstWhere(
      (a) => a.id == avatarId,
      orElse: () => ProfileViewModel.avatarPresets.first,
    );
    final base = Color(avatar.colorHex);
    return WoodButton(
      onPressed: onPressed,
      height: 50,
      radius: 16,
      depth: 5,
      padding: const EdgeInsets.fromLTRB(6, 3, 14, 3),
      semanticLabel: 'Profile',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CandyBlock(
            size: 34,
            colors: WoodToneColors.fromColor(
              base,
              Color.lerp(base, Colors.black, 0.35)!,
            ),
            child: const Icon(
              Icons.face_rounded,
              size: 22,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: WoodText.heading(fontSize: 17),
            ),
          ),
        ],
      ),
    );
  }
}

/// A big pale-wood menu button: a board icon on the left, a bold italic label
/// and a small subtitle.
class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final Widget icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return WoodButton(
      onPressed: onPressed,
      // [_SplashScreenState._navigateTo] already plays the tap sound.
      playTapSound: false,
      height: 92,
      radius: 22,
      depth: 7,
      padding: const EdgeInsets.fromLTRB(14, 8, 12, 8),
      semanticLabel: title,
      child: Row(
        children: [
          icon,
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(title, style: WoodText.button(fontSize: 30)),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: WoodText.body(
                    fontSize: 14,
                    color: WoodColors.inkSoft,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.play_arrow_rounded,
            size: 30,
            color: WoodColors.inkSoft,
          ),
        ],
      ),
    );
  }
}

/// A recessed board holding a 2 by 2 stack of candy letter blocks, the
/// letter-set counterpart of [WoodBoardIcon].
class _LetterTrayIcon extends StatelessWidget {
  const _LetterTrayIcon({required this.letters, this.colorOffset = 0});

  final List<String> letters;

  /// Where in [WoodColors.blockCycle] the block colours start.
  final int colorOffset;

  static const double _size = 58;

  @override
  Widget build(BuildContext context) {
    const block = 21.0;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: _size,
        child: Stack(
          children: [
            const WoodBoardIcon(size: _size, pattern: ['..', '..']),
            for (var i = 0; i < letters.length && i < 4; i++)
              Positioned(
                left: 5 + (i % 2) * (block + 3.5),
                top: 3.5 + (i ~/ 2) * (block + 3.5),
                child: CandyBlock(
                  size: block,
                  letter: letters[i],
                  colors:
                      WoodColors.blockCycle[(i + colorOffset) %
                          WoodColors.blockCycle.length],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
