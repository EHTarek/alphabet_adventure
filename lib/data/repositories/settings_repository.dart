import 'package:alphabet_adventure/data/services/audio_service.dart';
import 'package:alphabet_adventure/data/services/storage_service.dart';
import 'package:flutter/foundation.dart';

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
  bool _parentalGateEnabled = true;
  bool _highContrastEnabled = false;

  bool get showSubtitles => _showSubtitles;
  bool get reducedAnimations => _reducedAnimations;
  bool get parentalGateEnabled => _parentalGateEnabled;
  bool get highContrastEnabled => _highContrastEnabled;

  /// Load settings from storage.
  Future<void> init() async {
    final settings = _storage.getSettings();

    _showSubtitles = settings['showSubtitles'] as bool? ?? false;
    _reducedAnimations = settings['reducedAnimations'] as bool? ?? false;
    _parentalGateEnabled = settings['parentalGateEnabled'] as bool? ?? true;
    _highContrastEnabled = settings['highContrastEnabled'] as bool? ?? false;

    // Restore audio settings
    _audioService.fromSettingsMap(settings);

    notifyListeners();
  }

  Future<void> initialize() => init();

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

  /// Toggle parental gate.
  void toggleParentalGate() {
    _parentalGateEnabled = !_parentalGateEnabled;
    _saveSettings();
    notifyListeners();
  }

  void setParentalGateEnabled(bool enabled) {
    _parentalGateEnabled = enabled;
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

  Future<void> _saveSettings() async {
    final settings = {
      'showSubtitles': _showSubtitles,
      'reducedAnimations': _reducedAnimations,
      'parentalGateEnabled': _parentalGateEnabled,
      'highContrastEnabled': _highContrastEnabled,
      ..._audioService.toSettingsMap(),
    };
    await _storage.saveSettings(settings);
  }
}
