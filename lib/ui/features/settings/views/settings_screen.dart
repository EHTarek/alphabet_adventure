import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:alphabet_adventure/data/repositories/progress_repository.dart';
import 'package:alphabet_adventure/data/repositories/settings_repository.dart';
import 'package:alphabet_adventure/data/services/audio_service.dart';
import 'package:alphabet_adventure/ui/core/app_colors.dart';
import 'package:alphabet_adventure/ui/core/app_fonts.dart';

/// Settings screen for audio sliders, accessibility preferences, and progress management (PRS Section 21 & 22).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsRepo = context.watch<SettingsRepository>();
    final audioService = context.watch<AudioService>();
    final progressRepo = context.read<ProgressRepository>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppFonts.fredoka(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Audio Controls Group
            _buildSectionCard(
              context: context,
              title: 'Audio Settings',
              icon: Icons.volume_up_rounded,
              children: [
                _buildSlider(
                  context: context,
                  label: 'Voice Narration',
                  value: audioService.voiceVolume,
                  onChanged: (val) => settingsRepo.setVoiceVolume(val),
                ),
                const SizedBox(height: 12),
                _buildSlider(
                  context: context,
                  label: 'Sound Effects (SFX)',
                  value: audioService.sfxVolume,
                  onChanged: (val) => settingsRepo.setSfxVolume(val),
                ),
                // const SizedBox(height: 12),
                // _buildSlider(
                //   label: 'Background Music',
                //   value: audioService.musicVolume,
                //   onChanged: (val) => settingsRepo.setMusicVolume(val),
                // ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: Text(
                    'Mute All Sounds',
                    style: AppFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  value: audioService.isMuted,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => settingsRepo.setMuted(val),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Accessibility Preferences Group
            _buildSectionCard(
              context: context,
              title: 'Accessibility & Display',
              icon: Icons.accessibility_new_rounded,
              children: [
                SwitchListTile(
                  title: Text(
                    'Show Subtitles',
                    style: AppFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  subtitle: Text(
                    'Show spoken learning prompts on screen',
                    style: AppFonts.fredoka(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                  value: settingsRepo.showSubtitles,
                  activeThumbColor: AppColors.primary,
                  onChanged: (_) => settingsRepo.toggleSubtitles(),
                ),
                const Divider(),
                SwitchListTile(
                  title: Text(
                    'Reduced Motion',
                    style: AppFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  subtitle: Text(
                    'Use simpler animations and camera movement',
                    style: AppFonts.fredoka(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                  value: settingsRepo.reducedAnimations,
                  activeThumbColor: AppColors.primary,
                  onChanged: (_) => settingsRepo.toggleReducedAnimations(),
                ),
                const Divider(),
                SwitchListTile(
                  title: Text(
                    'High Contrast Mode',
                    style: AppFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  subtitle: Text(
                    'Increases visual clarity and outlines',
                    style: AppFonts.fredoka(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                  value: settingsRepo.highContrastEnabled,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => settingsRepo.setHighContrastEnabled(val),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'App Theme',
                        style: AppFonts.fredoka(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      Text(
                        'Choose light or dark mode',
                        style: AppFonts.fredoka(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<ThemeMode>(
                          style: SegmentedButton.styleFrom(
                            selectedForegroundColor: Theme.of(
                              context,
                            ).cardTheme.color,
                            selectedBackgroundColor: AppColors.primary,
                          ),
                          segments: const [
                            ButtonSegment(
                              value: ThemeMode.system,
                              icon: Icon(Icons.brightness_auto),
                            ),
                            ButtonSegment(
                              value: ThemeMode.light,
                              icon: Icon(Icons.light_mode),
                            ),
                            ButtonSegment(
                              value: ThemeMode.dark,
                              icon: Icon(Icons.dark_mode),
                            ),
                          ],
                          selected: {settingsRepo.themeMode},
                          onSelectionChanged: (Set<ThemeMode> newSelection) {
                            settingsRepo.setThemeMode(newSelection.first);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Parent Dashboard Link
            ListTile(
              tileColor: Theme.of(context).cardTheme.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              leading: const Icon(
                Icons.analytics_rounded,
                color: AppColors.secondaryDark,
              ),
              title: Text(
                'Open Parent Dashboard',
                style: AppFonts.fredoka(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
              onTap: () => context.push('/parent'),
            ),
            const SizedBox(height: 16),
            // Reset Progress (Destructive action with confirmation)
            ListTile(
              tileColor: Theme.of(context).cardTheme.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              leading: const Icon(
                Icons.refresh_rounded,
                color: AppColors.primary,
              ),
              title: Text(
                'Reset Current Profile Progress',
                style: AppFonts.fredoka(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              onTap: () => _confirmReset(context, progressRepo),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Material(
      color: Theme.of(context).cardTheme.color,
      borderRadius: BorderRadius.circular(24),
      elevation: 1.5,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppFonts.fredoka(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSlider({
    required BuildContext context,
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppFonts.fredoka(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            Text(
              '${(value * 100).round()}%',
              style: AppFonts.fredoka(fontSize: 14, color: AppColors.textMuted),
            ),
          ],
        ),
        Slider(
          value: value,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.primary.withValues(alpha: 0.2),
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _confirmReset(BuildContext context, ProgressRepository progressRepo) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Reset Learning Progress?',
          style: AppFonts.fredoka(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This will clear stars and mastery records for the current profile.',
          style: AppFonts.fredoka(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: AppFonts.fredoka(fontSize: 16)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await progressRepo.resetAllProgress();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Progress reset!', style: AppFonts.fredoka()),
                  ),
                );
              }
            },
            child: Text('Reset', style: AppFonts.fredoka(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
