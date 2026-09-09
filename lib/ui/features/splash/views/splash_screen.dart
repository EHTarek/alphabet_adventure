import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:alphabet_adventure/data/repositories/progress_repository.dart';
import 'package:alphabet_adventure/data/services/audio_service.dart';
import 'package:alphabet_adventure/ui/core/animations/bounce_animation.dart';
import 'package:alphabet_adventure/ui/core/app_colors.dart';
import 'package:alphabet_adventure/ui/core/app_fonts.dart';
import 'package:alphabet_adventure/ui/core/widgets/mascot_widget.dart';
import 'package:alphabet_adventure/ui/features/profile/view_models/profile_view_model.dart';

/// Animated splash screen introducing Pip the Parrot and guiding into profile or world map.
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
      duration: const Duration(milliseconds: 1200),
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

    // Play welcome sound and bg music
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final audio = context.read<AudioService>();
      audio.playCelebrationFanfare();
      // audio.playBackgroundMusic();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _onStartAdventure() async {
    final progressRepo = context.read<ProgressRepository>();
    if (progressRepo.activeProfile == null) {
      // First launch: auto-create a default profile so the child can play
      // immediately. Profiles can be managed anytime from the world map.
      final profileVM = context.read<ProfileViewModel>();
      await profileVM.createProfile(
        name: 'Explorer',
        avatarId: ProfileViewModel.avatarPresets.first.id,
      );
    }
    if (mounted) {
      context.go('/world_map');
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Scaled Animated Logo & Title
              ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  children: [
                    Text(
                      'ALPHABET',
                      style: AppFonts.fredoka(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        letterSpacing: 2.0,
                        shadows: [
                          Shadow(
                            color: AppColors.primaryDark.withValues(alpha: 0.6),
                            offset: const Offset(0, 4),
                            blurRadius: 0,
                          ),
                          const Shadow(
                            color: Colors.black12,
                            offset: Offset(0, 8),
                            blurRadius: 12,
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
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: AppColors.secondaryDark,
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(
                                color: AppColors.secondaryDark.withValues(alpha: 0.4),
                                offset: const Offset(0, 3),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accentYellow,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.accentYellowDark, width: 2),
                          ),
                          child: Text(
                            '3D',
                            style: AppFonts.fredoka(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Mascot with welcoming speech bubble
              const MascotWidget(
                mood: MascotMood.cheering,
                speechBubbleText: 'Hi friend! Ready to explore letters?',
                size: 130,
              ),
              const Spacer(),
              // Big Start Button with Fade Transition
              FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                  child: BounceAnimation(
                    onTap: _onStartAdventure,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.accentGreen, AppColors.accentGreenDark],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white, width: 3.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentGreenDark.withValues(alpha: 0.5),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.play_arrow_rounded,
                            size: 38,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'LET’S PLAY!',
                            style: AppFonts.fredoka(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
