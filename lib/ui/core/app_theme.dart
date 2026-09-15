import 'package:flutter/material.dart';

import 'package:alphabet_adventure/ui/core/app_colors.dart';
import 'package:alphabet_adventure/ui/core/app_fonts.dart';
import 'package:alphabet_adventure/ui/core/scene_fade_page_transitions_builder.dart';
import 'package:alphabet_adventure/ui/core/sound_splash_factory.dart';
import 'package:alphabet_adventure/ui/core/wood/wood_palette.dart';

/// App theme configuring child-friendly typography, oversized touch targets,
/// and rounded vibrant components (PRS Section 16 & 23).
class AppTheme {
  /// Pages are transparent: the app-wide blossom parallax scene (hosted in
  /// `MaterialApp.builder`) is the background of every screen, so every
  /// platform uses a transition that keeps it visible.
  static const PageTransitionsTheme _scenePageTransitions =
      PageTransitionsTheme(
        builders: {
          TargetPlatform.android: SceneFadePageTransitionsBuilder(),
          TargetPlatform.iOS: SceneFadePageTransitionsBuilder(),
          TargetPlatform.macOS: SceneFadePageTransitionsBuilder(),
          TargetPlatform.windows: SceneFadePageTransitionsBuilder(),
          TargetPlatform.linux: SceneFadePageTransitionsBuilder(),
          TargetPlatform.fuchsia: SceneFadePageTransitionsBuilder(),
        },
      );

  static ThemeData get lightTheme {
    final baseTextTheme = AppFonts.fredokaTextTheme();

    return ThemeData(
      useMaterial3: true,
      splashFactory: const SoundSplashFactory(),
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: Colors.transparent,
      pageTransitionsTheme: _scenePageTransitions,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.bgCard,
        onSurface: AppColors.textDark,
        error: AppColors.tryAgain,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
          letterSpacing: 1.2,
        ),
        displayMedium: baseTextTheme.displayMedium?.copyWith(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
        displaySmall: baseTextTheme.displaySmall?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        titleSmall: baseTextTheme.titleSmall?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          fontSize: 18,
          color: AppColors.textDark,
          height: 1.4,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          fontSize: 16,
          color: AppColors.textDark,
          height: 1.4,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          fontSize: 14,
          color: AppColors.textDark,
          height: 1.4,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textLight,
          elevation: 6,
          shadowColor: AppColors.primaryDark.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          minimumSize: const Size(64, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: AppFonts.fredoka(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(56, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: AppFonts.fredoka(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgCard,
        elevation: 6,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: const EdgeInsets.all(8),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.bgCard,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        titleTextStyle: AppFonts.fredoka(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
        contentTextStyle: AppFonts.fredoka(
          fontSize: 16,
          color: AppColors.textDark,
          height: 1.4,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: WoodColors.darkWood.bottom,
        contentTextStyle: AppFonts.fredoka(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: WoodColors.darkWood.ink,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: WoodColors.darkWood.rim, width: 3),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? WoodColors.candyGreen.bottom
              : WoodColors.cellDark,
        ),
        trackOutlineColor: WidgetStatePropertyAll(WoodColors.cellLine),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: WoodColors.candyGreen.bottom,
        inactiveTrackColor: WoodColors.cellDark,
        thumbColor: WoodColors.candyGold.bottom,
        overlayColor: WoodColors.candyGold.bottom.withValues(alpha: 0.2),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: WoodColors.candyGreen.bottom,
        linearTrackColor: WoodColors.cellDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textDark, size: 28),
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTextTheme = AppFonts.fredokaTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      splashFactory: const SoundSplashFactory(),
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: Colors.transparent,
      pageTransitionsTheme: _scenePageTransitions,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.bgCardDark,
        onSurface: AppColors.textLight,
        error: AppColors.tryAgain,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: AppColors.textLight,
          letterSpacing: 1.2,
        ),
        displayMedium: baseTextTheme.displayMedium?.copyWith(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: AppColors.textLight,
        ),
        displaySmall: baseTextTheme.displaySmall?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textLight,
        ),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textLight,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textLight,
        ),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textLight,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textLight,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textLight,
        ),
        titleSmall: baseTextTheme.titleSmall?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textLight,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          fontSize: 18,
          color: AppColors.textLight,
          height: 1.4,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          fontSize: 16,
          color: AppColors.textLight,
          height: 1.4,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          fontSize: 14,
          color: AppColors.textLight,
          height: 1.4,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textLight,
          elevation: 6,
          shadowColor: AppColors.primaryDark.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          minimumSize: const Size(64, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: AppFonts.fredoka(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          side: const BorderSide(color: AppColors.primaryLight, width: 3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(56, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: AppFonts.fredoka(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgCardDark,
        elevation: 6,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: const EdgeInsets.all(8),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.bgCardDark,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        titleTextStyle: AppFonts.fredoka(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textLight,
        ),
        contentTextStyle: AppFonts.fredoka(
          fontSize: 16,
          color: AppColors.textLight,
          height: 1.4,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: WoodColors.darkWood.bottom,
        contentTextStyle: AppFonts.fredoka(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: WoodColors.darkWood.ink,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: WoodColors.darkWood.rim, width: 3),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? WoodColors.candyGreen.bottom
              : WoodColors.cellDark,
        ),
        trackOutlineColor: WidgetStatePropertyAll(WoodColors.cellLine),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: WoodColors.candyGreen.bottom,
        inactiveTrackColor: WoodColors.cellDark,
        thumbColor: WoodColors.candyGold.bottom,
        overlayColor: WoodColors.candyGold.bottom.withValues(alpha: 0.2),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: WoodColors.candyGreen.bottom,
        linearTrackColor: WoodColors.cellDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textLight, size: 28),
      ),
    );
  }
}
