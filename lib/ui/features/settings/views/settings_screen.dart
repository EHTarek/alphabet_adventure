import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:alphabet_adventure/data/repositories/progress_repository.dart';
import 'package:alphabet_adventure/data/repositories/settings_repository.dart';
import 'package:alphabet_adventure/data/services/audio_service.dart';
import 'package:alphabet_adventure/ui/core/app_fonts.dart';
import 'package:alphabet_adventure/ui/core/wood/wood.dart';

/// Settings screen for audio sliders, accessibility preferences, and progress management (PRS Section 21 & 22).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsRepo = context.watch<SettingsRepository>();
    final audioService = context.watch<AudioService>();
    final progressRepo = context.read<ProgressRepository>();
    final navigator = Navigator.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            WoodHeader(
              title: 'Settings',
              onBack: navigator.canPop() ? () => navigator.maybePop() : null,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Audio Controls Group
                    _SettingsSection(
                      title: 'Audio Settings',
                      icon: Icons.volume_up_rounded,
                      iconColors: WoodColors.candyBlue,
                      children: [
                        _buildSlider(
                          label: 'Voice Narration',
                          icon: Icons.record_voice_over_rounded,
                          value: audioService.voiceVolume,
                          onChanged: (val) => settingsRepo.setVoiceVolume(val),
                        ),
                        const _InsetDivider(),
                        _buildSlider(
                          label: 'Sound Effects (SFX)',
                          icon: Icons.music_note_rounded,
                          value: audioService.sfxVolume,
                          onChanged: (val) => settingsRepo.setSfxVolume(val),
                        ),
                        // const _InsetDivider(),
                        // _buildSlider(
                        //   label: 'Background Music',
                        //   value: audioService.musicVolume,
                        //   onChanged: (val) => settingsRepo.setMusicVolume(val),
                        // ),
                        const _InsetDivider(),
                        _buildSwitch(
                          title: 'Mute All Sounds',
                          value: audioService.isMuted,
                          onChanged: (val) => settingsRepo.setMuted(val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Accessibility Preferences Group
                    _SettingsSection(
                      title: 'Accessibility & Display',
                      icon: Icons.accessibility_new_rounded,
                      iconColors: WoodColors.candyPurple,
                      children: [
                        _buildSwitch(
                          title: 'Show Subtitles',
                          subtitle: 'Show spoken learning prompts on screen',
                          value: settingsRepo.showSubtitles,
                          onChanged: (_) => settingsRepo.toggleSubtitles(),
                        ),
                        const _InsetDivider(),
                        _buildSwitch(
                          title: 'Reduced Motion',
                          subtitle:
                              'Use simpler animations and camera movement',
                          value: settingsRepo.reducedAnimations,
                          onChanged: (_) =>
                              settingsRepo.toggleReducedAnimations(),
                        ),
                        const _InsetDivider(),
                        _buildSwitch(
                          title: 'High Contrast Mode',
                          subtitle: 'Increases visual clarity and outlines',
                          value: settingsRepo.highContrastEnabled,
                          onChanged: (val) =>
                              settingsRepo.setHighContrastEnabled(val),
                        ),
                        const _InsetDivider(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('App Theme', style: _rowTitleStyle),
                              Text(
                                'Choose light or dark mode',
                                style: _rowSubtitleStyle,
                              ),
                              const SizedBox(height: 12),
                              _ThemeModePicker(
                                selected: settingsRepo.themeMode,
                                onSelected: settingsRepo.setThemeMode,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Grown-up actions
                    _SettingsSection(
                      title: 'Grown-Ups',
                      icon: Icons.family_restroom_rounded,
                      iconColors: WoodColors.candyGreen,
                      inset: false,
                      children: [
                        // Parent Dashboard Link
                        _ActionButton(
                          label: 'Open Parent Dashboard',
                          icon: Icons.analytics_rounded,
                          tone: WoodTone.light,
                          showChevron: true,
                          onPressed: () => context.push('/parent'),
                        ),
                        const SizedBox(height: 12),
                        // Reset Progress (Destructive action with confirmation)
                        _ActionButton(
                          label: 'Reset Current Profile Progress',
                          icon: Icons.refresh_rounded,
                          tone: WoodTone.red,
                          onPressed: () => _confirmReset(context, progressRepo),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static final TextStyle _rowTitleStyle = WoodText.body(
    fontSize: 17,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle _rowSubtitleStyle = WoodText.body(
    fontSize: 14,
    color: WoodColors.inkSoft,
  );

  Widget _buildSwitch({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      title: Text(title, style: _rowTitleStyle),
      subtitle: subtitle == null
          ? null
          : Text(subtitle, style: _rowSubtitleStyle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildSlider({
    required String label,
    required IconData icon,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: WoodColors.inkSoft),
              const SizedBox(width: 8),
              Expanded(child: Text(label, style: _rowTitleStyle)),
              WoodPanel(
                tone: WoodTone.dark,
                radius: 12,
                depth: 3,
                rimWidth: 2,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                child: Text(
                  '${(value * 100).round()}%',
                  style: AppFonts.fredoka(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: WoodColors.goldTop,
                  ),
                ),
              ),
            ],
          ),
          Slider(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, ProgressRepository progressRepo) {
    showDialog(
      context: context,
      builder: (dialogContext) => WoodDialog(
        title: 'Reset Learning Progress?',
        onClose: () => Navigator.pop(dialogContext),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CandyBlock(
              colors: WoodColors.candyRed,
              size: 60,
              child: Icon(Icons.refresh_rounded, size: 36, color: Colors.white),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: _parchmentDecoration(radius: 16),
              child: Text(
                'This will clear stars and mastery records for the current profile.',
                textAlign: TextAlign.center,
                style: WoodText.body(fontSize: 17),
              ),
            ),
          ],
        ),
        actions: [
          WoodButton(
            width: 128,
            height: 56,
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: WoodText.button(fontSize: 20)),
          ),
          WoodButton(
            tone: WoodTone.red,
            width: 128,
            height: 56,
            padding: EdgeInsets.zero,
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
            child: Text(
              'Reset',
              style: WoodText.button(fontSize: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _parchmentDecoration({double radius = 18}) {
  return BoxDecoration(
    color: WoodColors.parchment,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: WoodColors.parchmentEdge, width: 2),
    boxShadow: const [
      BoxShadow(color: Color(0x33000000), offset: Offset(0, -1)),
    ],
  );
}

/// A pale-wood panel with an ink heading and its rows on a parchment inset.
class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.iconColors,
    required this.children,
    this.inset = true,
  });

  final String title;
  final IconData icon;
  final WoodToneColors iconColors;
  final List<Widget> children;

  /// Whether [children] sit on a parchment inset rather than on the wood.
  final bool inset;

  @override
  Widget build(BuildContext context) {
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
    return WoodPanel(
      radius: 26,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CandyBlock(
                colors: iconColors,
                size: 38,
                child: Icon(icon, size: 24, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title, style: WoodText.heading(fontSize: 21)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (inset)
            Material(
              type: MaterialType.transparency,
              child: Ink(
                decoration: _parchmentDecoration(),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: body,
                ),
              ),
            )
          else
            body,
        ],
      ),
    );
  }
}

class _InsetDivider extends StatelessWidget {
  const _InsetDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 2,
      thickness: 2,
      indent: 12,
      endIndent: 12,
      color: WoodColors.parchmentEdge,
    );
  }
}

/// Three wooden keys for system, light and dark mode.
class _ThemeModePicker extends StatelessWidget {
  const _ThemeModePicker({required this.selected, required this.onSelected});

  final ThemeMode selected;
  final ValueChanged<ThemeMode> onSelected;

  static const _options = [
    (ThemeMode.system, Icons.brightness_auto, 'Auto'),
    (ThemeMode.light, Icons.light_mode, 'Light'),
    (ThemeMode.dark, Icons.dark_mode, 'Dark'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (index, (mode, icon, label)) in _options.indexed) ...[
          if (index > 0) const SizedBox(width: 10),
          Expanded(
            child: Semantics(
              selected: mode == selected,
              child: WoodButton(
                tone: mode == selected ? WoodTone.green : WoodTone.light,
                height: 58,
                radius: 16,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                semanticLabel: label,
                onPressed: () {
                  if (mode != selected) onSelected(mode);
                },
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 22),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: WoodText.button(
                          fontSize: 17,
                          color: mode == selected
                              ? Colors.white
                              : WoodColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// A full-width wooden action key with a leading icon block.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.tone,
    required this.onPressed,
    this.showChevron = false,
  });

  final String label;
  final IconData icon;
  final WoodTone tone;
  final VoidCallback onPressed;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final colors = tone.colors;
    return WoodButton(
      tone: tone,
      width: double.infinity,
      radius: 18,
      padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
      onPressed: onPressed,
      child: Row(
        children: [
          CandyBlock(
            colors: tone == WoodTone.light
                ? WoodColors.candyBlue
                : WoodColors.darkWood,
            size: 36,
            child: Icon(icon, size: 22, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: WoodText.button(fontSize: 18, color: colors.ink),
            ),
          ),
          if (showChevron)
            Icon(Icons.arrow_forward_ios_rounded, size: 18, color: colors.ink),
        ],
      ),
    );
  }
}
