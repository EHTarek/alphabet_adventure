import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:alphabet_adventure/data/repositories/progress_repository.dart';
import 'package:alphabet_adventure/data/services/audio_service.dart';
import 'package:alphabet_adventure/ui/core/animations/bounce_animation.dart';
import 'package:alphabet_adventure/ui/core/app_colors.dart';
import 'package:alphabet_adventure/ui/core/app_fonts.dart';
import 'package:alphabet_adventure/ui/core/widgets/mascot_widget.dart';
import 'package:alphabet_adventure/ui/core/widgets/star_counter.dart';
import 'package:alphabet_adventure/ui/features/profile/view_models/profile_view_model.dart';

/// Animated splash & hub screen introducing Pip and offering a choice option grid
/// to navigate to Game, A to Z, a to z, or Words.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    final progressRepo = context.watch<ProgressRepository>();
    final activeProfile = progressRepo.activeProfile;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F7FF), Color(0xFFFFF7D6), Color(0xFFFFE3E3)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Top Bar: Profile, Stars & Settings
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 4),
                          child: Row(
                            children: [
                              // Profile chip
                              BounceAnimation(
                                onTap: () => context.push('/profile'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.secondaryDark,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.08),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const CircleAvatar(
                                        radius: 14,
                                        backgroundColor: AppColors.secondary,
                                        child: Icon(
                                          Icons.face_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        activeProfile?.name ?? 'Explorer',
                                        style: AppFonts.fredoka(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Spacer(),
                              // Star Counter
                              StarCounter(count: progressRepo.totalStars),
                              const SizedBox(width: 8),
                              // Settings Button
                              BounceAnimation(
                                onTap: () => context.push('/settings'),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.primary,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.08),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.settings_rounded,
                                    size: 22,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Animated Logo & Title
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Column(
                            children: [
                              Text(
                                'ALPHABET',
                                style: AppFonts.fredoka(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                  letterSpacing: 2.0,
                                  shadows: [
                                    Shadow(
                                      color: AppColors.primaryDark
                                          .withValues(alpha: 0.6),
                                      offset: const Offset(0, 3),
                                      blurRadius: 0,
                                    ),
                                    const Shadow(
                                      color: Colors.black12,
                                      offset: Offset(0, 6),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'ADVENTURE',
                                    style: AppFonts.fredoka(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.secondaryDark,
                                      letterSpacing: 1.5,
                                      shadows: [
                                        Shadow(
                                          color: AppColors.secondaryDark
                                              .withValues(alpha: 0.4),
                                          offset: const Offset(0, 2),
                                          blurRadius: 0,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentYellow,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: AppColors.accentYellowDark,
                                        width: 2,
                                      ),
                                    ),
                                    child: Text(
                                      '3D',
                                      style: AppFonts.fredoka(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Mascot with welcoming speech bubble
                        MascotWidget(
                          mood: MascotMood.cheering,
                          speechBubbleText: 'What would you like to play today?',
                          size: 95,
                          onTap: () {
                            context
                                .read<AudioService>()
                                .playMascotEncouragement();
                          },
                        ),

                        const SizedBox(height: 12),

                        // Choice Option Grid: Game, A to Z, a to z, Words
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 1.15,
                            children: [
                              _ChoiceOptionCard(
                                title: 'Game',
                                subtitle: 'Play Adventure',
                                iconWidget: const Icon(
                                  Icons.sports_esports_rounded,
                                  size: 32,
                                  color: Colors.white,
                                ),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF06D6A0),
                                    Color(0xFF04A77D),
                                  ],
                                ),
                                shadowColor: AppColors.accentGreenDark,
                                onTap: () => _navigateTo('/world_map'),
                              ),
                              _ChoiceOptionCard(
                                title: 'A to Z',
                                subtitle: 'Capital Letters',
                                iconWidget: Text(
                                  'ABC',
                                  style: AppFonts.fredoka(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF118AB2),
                                    Color(0xFF073B4C),
                                  ],
                                ),
                                shadowColor: const Color(0xFF073B4C),
                                onTap: () => _navigateTo('/library?tab=0'),
                              ),
                              _ChoiceOptionCard(
                                title: 'a to z',
                                subtitle: 'Small Letters',
                                iconWidget: Text(
                                  'abc',
                                  style: AppFonts.fredoka(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFFFB703),
                                    Color(0xFFFB8500),
                                  ],
                                ),
                                shadowColor: const Color(0xFFFB8500),
                                onTap: () => _navigateTo('/library?tab=1'),
                              ),
                              _ChoiceOptionCard(
                                title: 'Words',
                                subtitle: 'Phonics & Objects',
                                iconWidget: const Icon(
                                  Icons.auto_stories_rounded,
                                  size: 32,
                                  color: Colors.white,
                                ),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF8338EC),
                                    Color(0xFF5A189A),
                                  ],
                                ),
                                shadowColor: const Color(0xFF5A189A),
                                onTap: () => _navigateTo('/library?tab=2'),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),
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

/// A bouncy, child-friendly 3D card used in the choice option grid.
class _ChoiceOptionCard extends StatelessWidget {
  const _ChoiceOptionCard({
    required this.title,
    required this.subtitle,
    required this.iconWidget,
    required this.gradient,
    required this.shadowColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Widget iconWidget;
  final LinearGradient gradient;
  final Color shadowColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BounceAnimation(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 3.5),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withValues(alpha: 0.5),
              offset: const Offset(0, 6),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(14),
              ),
              child: iconWidget,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppFonts.fredoka(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.5,
                shadows: [
                  const Shadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.fredoka(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.92),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
