import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:alphabet_adventure/data/models/word_data.dart';
import 'package:alphabet_adventure/ui/core/animations/bounce_animation.dart';
import 'package:alphabet_adventure/ui/core/app_colors.dart';

/// Interactive 3D styled learning object card displaying a vocabulary word, icon, and highlighted initial letter.
class InteractiveObject extends StatelessWidget {
  final WordData word;
  final VoidCallback? onTap;
  final double size;
  final bool isSelected;
  final bool isCorrect;
  final bool isIncorrect;
  final bool showLabel;

  const InteractiveObject({
    super.key,
    required this.word,
    this.onTap,
    this.size = 140.0,
    this.isSelected = false,
    this.isCorrect = false,
    this.isIncorrect = false,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.white;
    Color bgColor = Colors.white;

    if (isCorrect) {
      borderColor = AppColors.success;
      bgColor = AppColors.success.withValues(alpha: 0.15);
    } else if (isIncorrect) {
      borderColor = AppColors.tryAgain;
      bgColor = AppColors.tryAgain.withValues(alpha: 0.15);
    } else if (isSelected) {
      borderColor = AppColors.primary;
      bgColor = AppColors.primaryLight.withValues(alpha: 0.2);
    }

    return BounceAnimation(
      onTap: onTap,
      child: Container(
        width: size,
        height: showLabel ? size * 1.25 : size,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 3.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Object Icon/Visual representation
            Expanded(
              child: Center(
                child: _buildObjectVisual(word, size * 0.5),
              ),
            ),
            if (showLabel) ...[
              const SizedBox(height: 6),
              // Word label with initial letter highlighted
              _buildHighlightedWord(word),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedWord(WordData word) {
    final firstChar = word.word.isNotEmpty ? word.word[0] : '';
    final rest = word.word.length > 1 ? word.word.substring(1) : '';

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: firstChar.toUpperCase(),
            style: GoogleFonts.fredoka(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          TextSpan(
            text: rest.toLowerCase(),
            style: GoogleFonts.fredoka(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectVisual(WordData word, double iconSize) {
    // Map word to expressive visual icons
    final iconData = switch (word.word.toLowerCase()) {
      'apple' => Icons.apple_rounded,
      'alligator' => Icons.pets_rounded,
      'astronaut' => Icons.rocket_launch_rounded,
      'ball' => Icons.sports_basketball_rounded,
      'bear' => Icons.cruelty_free_rounded,
      'boat' => Icons.directions_boat_rounded,
      'cat' => Icons.pets_rounded,
      'cake' => Icons.cake_rounded,
      'car' => Icons.directions_car_rounded,
      'dog' => Icons.pets_rounded,
      'duck' => Icons.flutter_dash_rounded,
      'drum' => Icons.music_note_rounded,
      'elephant' => Icons.pets_rounded,
      'egg' => Icons.egg_rounded,
      'engine' => Icons.train_rounded,
      'fish' => Icons.set_meal_rounded,
      'frog' => Icons.spa_rounded,
      'flag' => Icons.flag_rounded,
      'giraffe' => Icons.pets_rounded,
      'guitar' => Icons.music_note_rounded,
      'garden' => Icons.yard_rounded,
      'house' => Icons.house_rounded,
      'hat' => Icons.face_rounded,
      'heart' => Icons.favorite_rounded,
      'ice cream' => Icons.icecream_rounded,
      'iguana' => Icons.pets_rounded,
      'island' => Icons.terrain_rounded,
      'jellyfish' => Icons.water_drop_rounded,
      'jacket' => Icons.checkroom_rounded,
      'juice' => Icons.local_drink_rounded,
      'kangaroo' => Icons.pets_rounded,
      'kite' => Icons.air_rounded,
      'king' => Icons.military_tech_rounded,
      'lion' => Icons.pets_rounded,
      'lemon' => Icons.eco_rounded,
      'leaf' => Icons.eco_rounded,
      'monkey' => Icons.pets_rounded,
      'moon' => Icons.nightlight_round,
      'mountain' => Icons.landscape_rounded,
      'nest' => Icons.home_rounded,
      'nurse' => Icons.local_hospital_rounded,
      'nut' => Icons.circle_rounded,
      'owl' => Icons.visibility_rounded,
      'orange' => Icons.circle_rounded,
      'ocean' => Icons.waves_rounded,
      'penguin' => Icons.pets_rounded,
      'pizza' => Icons.local_pizza_rounded,
      'piano' => Icons.piano_rounded,
      'queen' => Icons.star_rounded,
      'quilt' => Icons.grid_view_rounded,
      'quail' => Icons.flutter_dash_rounded,
      'rabbit' => Icons.cruelty_free_rounded,
      'rainbow' => Icons.looks_rounded,
      'robot' => Icons.smart_toy_rounded,
      'sun' => Icons.wb_sunny_rounded,
      'star' => Icons.star_rounded,
      'snake' => Icons.gesture_rounded,
      'tiger' => Icons.pets_rounded,
      'tree' => Icons.park_rounded,
      'train' => Icons.train_rounded,
      'umbrella' => Icons.beach_access_rounded,
      'unicorn' => Icons.auto_awesome_rounded,
      'urchin' => Icons.coronavirus_rounded,
      'violin' => Icons.music_note_rounded,
      'volcano' => Icons.local_fire_department_rounded,
      'van' => Icons.airport_shuttle_rounded,
      'whale' => Icons.water_rounded,
      'wagon' => Icons.shopping_cart_rounded,
      'window' => Icons.window_rounded,
      'xylophone' => Icons.music_note_rounded,
      'x-ray' => Icons.medical_services_rounded,
      'xenon' => Icons.light_mode_rounded,
      'yak' => Icons.pets_rounded,
      'yacht' => Icons.sailing_rounded,
      'yarn' => Icons.fiber_manual_record_rounded,
      'zebra' => Icons.pets_rounded,
      'zipper' => Icons.linear_scale_rounded,
      'zoo' => Icons.nature_people_rounded,
      _ => Icons.category_rounded,
    };

    return Container(
      width: iconSize * 1.3,
      height: iconSize * 1.3,
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          iconData,
          size: iconSize * 0.85,
          color: AppColors.secondaryDark,
        ),
      ),
    );
  }
}
