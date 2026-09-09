import 'package:flutter/material.dart';

import 'package:alphabet_adventure/data/services/audio_service.dart';
import 'package:alphabet_adventure/data/services/storage_service.dart';

/// Repository for app settings and preferences (PRS Section 21 & 22).
class SettingsRepository extends ChangeNotifier {
  SettingsRepository({
    required StorageService storageService,
    required this._audioService,
  })  : _storage = storageService;

  final StorageService _storage;
  final AudioService _audioService;

  bool _showSubtitles = false;
  bool _reducedAnimations = false;
  bool _highContrastEnabled = false;
  ThemeMode _themeMode = ThemeMode.system;

  bool get showSubtitles => _showSubtitles;
  bool get reducedAnimations => _reducedAnimations;
  bool get highContrastEnabled => _highContrastEnabled;
  ThemeMode get themeMode => _themeMode;

  bool _listeningToAudio = false;

  /// Load settings from storage.
  Future<void> init() async {
    final settings = _storage.getSettings();

    _showSubtitles = settings['showSubtitles'] as bool? ?? false;
    _reducedAnimations = settings['reducedAnimations'] as bool? ?? false;
    _highContrastEnabled = settings['highContrastEnabled'] as bool? ?? false;

    final themeStr = settings['themeMode'] as String?;
    if (themeStr == 'light') {
      _themeMode = ThemeMode.light;
    } else if (themeStr == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }

    // Restore audio settings
    _audioService.fromSettingsMap(settings);

    if (!_listeningToAudio) {
      _audioService.addListener(_saveSettings);
      _listeningToAudio = true;
    }

    notifyListeners();
  }

  Future<void> initialize() => init();

  @override
  void dispose() {
    if (_listeningToAudio) {
      _audioService.removeListener(_saveSettings);
      _listeningToAudio = false;
    }
    super.dispose();
  }

  /// Toggle mute.
  void toggleMute() {
    _audioService.toggleMute();
  }

  /// Set muted state.
  void setMuted(bool muted) {
    _audioService.setMuted(muted);
  }

  /// Set voice volume (0.0–1.0).
  void setVoiceVolume(double volume) {
    _audioService.setVoiceVolume(volume);
  }

  /// Set sound effects volume (0.0–1.0).
  void setSfxVolume(double volume) {
    _audioService.setSfxVolume(volume);
  }

  /// Set background music volume (0.0–1.0).
  void setMusicVolume(double volume) {
    _audioService.setMusicVolume(volume);
  }

  /// Toggle subtitles display.
  void toggleSubtitles() {
    _showSubtitles = !_showSubtitles;
    _saveSettings();
    notifyListeners();
  }

  /// Toggle reduced animations.
  void toggleReducedAnimations() {
    _reducedAnimations = !_reducedAnimations;
    _saveSettings();
    notifyListeners();
  }

  /// Toggle high contrast mode.
  void toggleHighContrast() {
    _highContrastEnabled = !_highContrastEnabled;
    _saveSettings();
    notifyListeners();
  }

  void setHighContrastEnabled(bool enabled) {
    _highContrastEnabled = enabled;
    _saveSettings();
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveSettings();
    notifyListeners();
  }

  Future<void> saveSettings() => _saveSettings();

  Future<void> _saveSettings() async {
    final settings = {
      'showSubtitles': _showSubtitles,
      'reducedAnimations': _reducedAnimations,
      'highContrastEnabled': _highContrastEnabled,
      'themeMode': _themeMode.name,
      ..._audioService.toSettingsMap(),
    };
    await _storage.saveSettings(settings);
  }
}
