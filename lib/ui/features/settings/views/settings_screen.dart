import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:alphabet_adventure/data/repositories/progress_repository.dart';
import 'package:alphabet_adventure/data/repositories/settings_repository.dart';
import 'package:alphabet_adventure/data/services/audio_service.dart';
import 'package:alphabet_adventure/ui/core/app_colors.dart';
import 'package:alphabet_adventure/ui/features/parent/widgets/parental_gate_dialog.dart';

/// Settings screen for audio sliders, accessibility preferences, and progress management (PRS Section 21 & 22).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isUnlocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final passed = await ParentalGateDialog.verify(context);
      if (!mounted) return;
      if (passed) {
        setState(() => _isUnlocked = true);
      } else {
        context.pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isUnlocked) {
      return const Scaffold(
        backgroundColor: AppColors.bgSky,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final settingsRepo = context.watch<SettingsRepository>();
    final audioService = context.watch<AudioService>();
    final progressRepo = context.read<ProgressRepository>();

    return Scaffold(
      backgroundColor: AppColors.bgSky,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.fredoka(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Audio Controls Group
            _buildSectionCard(
              title: 'Audio Settings',
              icon: Icons.volume_up_rounded,
              children: [
                _buildSlider(
                  label: 'Voice Narration',
                  value: audioService.voiceVolume,
                  onChanged: (val) => audioService.setVoiceVolume(val),
                ),
                const SizedBox(height: 12),
                _buildSlider(
                  label: 'Sound Effects (SFX)',
                  value: audioService.sfxVolume,
                  onChanged: (val) => audioService.setSfxVolume(val),
                ),
                const SizedBox(height: 12),
                _buildSlider(
                  label: 'Background Music',
                  value: audioService.musicVolume,
                  onChanged: (val) => audioService.setMusicVolume(val),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: Text(
                    'Mute All Sounds',
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  value: audioService.isMuted,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => audioService.setMuted(val),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Accessibility Preferences Group
            _buildSectionCard(
              title: 'Accessibility & Display',
              icon: Icons.accessibility_new_rounded,
              children: [
                SwitchListTile(
                  title: Text(
                    'Show Subtitles',
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  subtitle: Text(
                    'Show spoken learning prompts on screen',
                    style: GoogleFonts.fredoka(fontSize: 13, color: AppColors.textMuted),
                  ),
                  value: settingsRepo.showSubtitles,
                  activeThumbColor: AppColors.primary,
                  onChanged: (_) => settingsRepo.toggleSubtitles(),
                ),
                const Divider(),
                SwitchListTile(
                  title: Text(
                    'Reduced Motion',
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  subtitle: Text(
                    'Use simpler animations and camera movement',
                    style: GoogleFonts.fredoka(fontSize: 13, color: AppColors.textMuted),
                  ),
                  value: settingsRepo.reducedAnimations,
                  activeThumbColor: AppColors.primary,
                  onChanged: (_) => settingsRepo.toggleReducedAnimations(),
                ),
                const Divider(),
                SwitchListTile(
                  title: Text(
                    'High Contrast Mode',
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  subtitle: Text(
                    'Increases visual clarity and outlines',
                    style: GoogleFonts.fredoka(fontSize: 13, color: AppColors.textMuted),
                  ),
                  value: settingsRepo.highContrastEnabled,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => settingsRepo.setHighContrastEnabled(val),
                ),
                const Divider(),
                SwitchListTile(
                  title: Text(
                    'Parental Gate for Settings',
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  subtitle: Text(
                    'Require math puzzle before changing options',
                    style: GoogleFonts.fredoka(fontSize: 13, color: AppColors.textMuted),
                  ),
                  value: settingsRepo.parentalGateEnabled,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => settingsRepo.setParentalGateEnabled(val),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Parent Dashboard Link
            ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              leading: const Icon(Icons.analytics_rounded, color: AppColors.secondaryDark),
              title: Text(
                'Open Parent Dashboard',
                style: GoogleFonts.fredoka(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
              onTap: () => context.push('/parent'),
            ),
            const SizedBox(height: 16),
            // Reset Progress (Destructive action with confirmation)
            ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              leading: const Icon(Icons.refresh_rounded, color: AppColors.primary),
              title: Text(
                'Reset Current Profile Progress',
                style: GoogleFonts.fredoka(
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
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.fredoka(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSlider({
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
              style: GoogleFonts.fredoka(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            Text(
              '${(value * 100).round()}%',
              style: GoogleFonts.fredoka(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.bgSky,
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
          style: GoogleFonts.fredoka(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This will clear stars and mastery records for the current profile.',
          style: GoogleFonts.fredoka(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: GoogleFonts.fredoka(fontSize: 16)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await progressRepo.resetAllProgress();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Progress reset!', style: GoogleFonts.fredoka()),
                  ),
                );
              }
            },
            child: Text('Reset', style: GoogleFonts.fredoka(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
