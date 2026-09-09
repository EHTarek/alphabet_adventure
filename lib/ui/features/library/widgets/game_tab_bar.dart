import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:alphabet_adventure/data/services/audio_service.dart';
import 'package:alphabet_adventure/ui/core/animations/bounce_animation.dart';
import 'package:alphabet_adventure/ui/core/app_colors.dart';
import 'package:alphabet_adventure/ui/core/app_fonts.dart';

class _TabItemData {
  final String title;
  final Color activeColor;
  final Color shadowColor;

  const _TabItemData({
    required this.title,
    required this.activeColor,
    required this.shadowColor,
  });
}

/// A tactile 3D segmented game tab bar designed for kids.
class GameTabBar extends StatelessWidget {
  final TabController controller;

  const GameTabBar({super.key, required this.controller});

  static const List<_TabItemData> _tabs = [
    _TabItemData(
      title: 'A-Z',
      activeColor: AppColors.primary,
      shadowColor: AppColors.primaryDark,
    ),
    _TabItemData(
      title: 'a-z',
      activeColor: AppColors.secondary,
      shadowColor: AppColors.secondaryDark,
    ),
    _TabItemData(
      title: 'Words',
      activeColor: AppColors.accentPurple,
      shadowColor: Color(0xFF651FFF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final audioService = context.read<AudioService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: controller.animation ?? controller,
      builder: (context, _) {
        final currentIndex = controller.index;

        return Container(
          // margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF232533)
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.06),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: List.generate(_tabs.length, (index) {
              final tab = _tabs[index];
              final isSelected = currentIndex == index;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: BounceAnimation(
                    onTap: () {
                      if (controller.index != index) {
                        audioService.playTap();
                        controller.animateTo(index);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? tab.activeColor
                            : (isDark
                                  ? const Color(0xFF2B2D42)
                                  : Colors.black.withValues(alpha: 0.03)),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.8)
                              : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: tab.shadowColor.withValues(alpha: 0.7),
                                  offset: const Offset(0, 3.5),
                                ),
                                BoxShadow(
                                  color: tab.activeColor.withValues(
                                    alpha: 0.35,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        tab.title,
                        textAlign: TextAlign.center,
                        style: AppFonts.fredoka(
                          fontSize: isSelected ? 18 : 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white : AppColors.textDark),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
