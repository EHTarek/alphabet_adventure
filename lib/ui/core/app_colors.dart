import 'package:flutter/material.dart';

/// Child-friendly, high-contrast, joyful color palette (PRS Section 16 & 23).
///
/// Designed with rounded aesthetics, saturated tones, and clear visual hierarchy.
class AppColors {
  // --- Brand & Main Accents ---
  static const Color primary = Color(0xFFFF6B6B); // Joyful Coral Red
  static const Color primaryDark = Color(0xFFE54B4B);
  static const Color primaryLight = Color(0xFFFF8E8E);

  static const Color secondary = Color(0xFF4ECDC4); // Sunny Turquoise
  static const Color secondaryDark = Color(0xFF38B2A9);
  static const Color secondaryLight = Color(0xFF72E2DA);

  static const Color accentYellow = Color(0xFFFFD166); // Golden Sun Yellow
  static const Color accentYellowDark = Color(0xFFF4B825);

  static const Color accentGreen = Color(0xFF06D6A0); // Meadow Emerald Green
  static const Color accentGreenDark = Color(0xFF04A77D);

  static const Color accentPurple = Color(0xFF8338EC); // Magic Violet
  static const Color accentPurpleLight = Color(0xFFA56CF4);

  static const Color accentBlue = Color(0xFF118AB2); // Ocean Sky Blue
  static const Color accentBlueLight = Color(0xFF3FA7D6);

  static const Color accentOrange = Color(0xFFFF8811); // Citrus Orange

  // --- Mastery Tiers ---
  static const Color masteryUnlocked = Color(0xFFB0BEC5);
  static const Color masteryIntroduced = Color(0xFF64B5F6);
  static const Color masteryPracticing = Color(0xFFFFB74D);
  static const Color masteryMastered = Color(0xFF81C784);
  static const Color masterySuperStar = Color(0xFFFFD54F);

  // --- Backgrounds & Neutrals ---
  static const Color bgSky = Color(0xFFE8F7FF);
  static const Color bgCream = Color(0xFFFFFDF5);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color bgCardDark = Color(0xFF37474F);
  static const Color bgDark = Color(0xFF263238);

  // --- Feedback ---
  static const Color success = Color(0xFF06D6A0);
  static const Color tryAgain = Color(0xFFFF8811); // Warm orange instead of aggressive red
  static const Color info = Color(0xFF118AB2);

  // --- Text Colors ---
  static const Color textDark = Color(0xFF2D3142);
  static const Color textMuted = Color(0xFF757D8A);
  static const Color textLight = Color(0xFFFFFFFF);

  // --- World Theme Gradients ---
  static const LinearGradient sunnyJungleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF56AB2F), Color(0xFFA8E063)],
  );

  static const LinearGradient oceanCoveGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
  );

  static const LinearGradient magicCastleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
  );

  static const LinearGradient starryGalaxyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
  );

  static const LinearGradient dinosaurValleyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF37335), Color(0xFFFDC830)],
  );

  static const LinearGradient rainbowCloudGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF758C), Color(0xFFFF7EB3)],
  );

  static const LinearGradient cardShadowGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FA)],
  );
}
