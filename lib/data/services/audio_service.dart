import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Centralized audio service managing narration, SFX, and music (PRS Section 21).
class AudioService extends ChangeNotifier {
  AudioService();

  // Audio players
  final AudioPlayer _narrationPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  // Volume levels (0.0–1.0)
  double _voiceVolume = 1.0;
  double _sfxVolume = 0.8;
  double _musicVolume = 0.05;
  bool _isMuted = false;

  bool _isNarrating = false;

  double get voiceVolume => _voiceVolume;
  double get sfxVolume => _sfxVolume;
  double get musicVolume => _musicVolume;
  bool get isMuted => _isMuted;
  bool get isNarrating => _isNarrating;

  /// Initialize the audio service.
  Future<void> init() async {
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _updateVolumes();
  }

  Future<void> initialize() => init();

  /// Play letter pronunciation (e.g., "A").
  Future<void> playLetterName(String letter) async {
    await _playNarration('assets/audio/letters/${letter.toLowerCase()}.m4a');
  }

  /// Play phonics sound (e.g., "/æ/" for A).
  Future<void> playPhonicsSound(String letter) async {
    await _playNarration('assets/audio/phonics/${letter.toLowerCase()}.m4a');
  }

  /// Play word pronunciation (e.g., "Apple").
  Future<void> playWordPronunciation(String wordId) async {
    await _playNarration('assets/audio/words/$wordId.m4a');
  }

  Future<void> playWord(String word) async {
    await playWordPronunciation(word.toLowerCase().replaceAll(' ', '_'));
  }

  /// Play generic voice narration from asset path.
  Future<void> playVoice(String assetPath) async {
    await _playNarration(assetPath);
  }

  /// Play mascot dialogue.
  Future<void> playMascotDialogue(String dialogueId) async {
    await _playNarration('assets/audio/mascot/$dialogueId.m4a');
  }

  Future<void> playMascotEncouragement() async {
    await playMascotDialogue('cheer');
  }

  /// Play success sound effect.
  Future<void> playSuccess() async {
    await _playSfx('assets/audio/sfx/success.m4a');
  }

  Future<void> playSuccessSound() => playSuccess();

  /// Play incorrect/try-again sound effect (gentle, encouraging).
  Future<void> playTryAgain() async {
    await _playSfx('assets/audio/sfx/try_again.m4a');
  }

  Future<void> playTryAgainSound() => playTryAgain();

  /// Play hint sound effect.
  Future<void> playHintSound() async {
    await _playSfx('assets/audio/sfx/hint.m4a');
  }

  /// Play star earned sound effect.
  Future<void> playStarEarned() async {
    await _playSfx('assets/audio/sfx/star_earned.m4a');
  }

  /// Play celebration/lesson-complete sound.
  Future<void> playCelebration() async {
    await _playSfx('assets/audio/sfx/celebration.m4a');
  }

  Future<void> playCelebrationFanfare() => playCelebration();

  /// Play tap/click sound.
  Future<void> playTap() async {
    await _playSfx('assets/audio/sfx/tap.m4a');
  }

  /// Start background music for a world theme.
  Future<void> startBackgroundMusic([String themeId = 'forest']) async {
    if (_isMuted) return;
    try {
      // One shared loop is currently bundled; world-specific tracks can be
      // added later without making the current theme ID a missing asset path.
      await _musicPlayer.play(
        AssetSource('audio/music/background.m4a'),
        volume: _musicVolume,
      );
    } catch (e) {
      debugPrint('Background music not available: $e');
    }
  }

  Future<void> playBackgroundMusic([String themeId = 'forest']) =>
      startBackgroundMusic(themeId);

  /// Stop background music.
  Future<void> stopBackgroundMusic() async {
    await _musicPlayer.stop();
  }

  /// Set voice volume (0.0–1.0).
  void setVoiceVolume(double volume) {
    _voiceVolume = volume.clamp(0.0, 1.0);
    _updateVolumes();
    notifyListeners();
  }

  /// Set SFX volume (0.0–1.0).
  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
    _updateVolumes();
    notifyListeners();
  }

  /// Set music volume (0.0–1.0).
  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
    _updateVolumes();
    notifyListeners();
  }

  /// Toggle mute.
  void toggleMute() {
    _isMuted = !_isMuted;
    _updateVolumes();
    notifyListeners();
  }

  void setMuted(bool muted) {
    _isMuted = muted;
    _updateVolumes();
    notifyListeners();
  }

  /// Get settings map for persistence.
  Map<String, dynamic> toSettingsMap() {
    return {
      'voiceVolume': _voiceVolume,
      'sfxVolume': _sfxVolume,
      'musicVolume': _musicVolume,
      'isMuted': _isMuted,
    };
  }

  /// Restore from settings map.
  void fromSettingsMap(Map<String, dynamic> settings) {
    _voiceVolume = (settings['voiceVolume'] as num?)?.toDouble() ?? 1.0;
    _sfxVolume = (settings['sfxVolume'] as num?)?.toDouble() ?? 0.8;
    _musicVolume = (settings['musicVolume'] as num?)?.toDouble() ?? 0.05;
    _isMuted = settings['isMuted'] as bool? ?? false;
    _updateVolumes();
    notifyListeners();
  }

  // --- Private helpers ---

  Future<void> _playNarration(String assetPath) async {
    if (_isMuted) return;

    _isNarrating = true;
    await _musicPlayer.setVolume(_musicVolume * 0.2);

    try {
      await _narrationPlayer.play(
        AssetSource(assetPath.replaceFirst('assets/', '')),
        volume: _voiceVolume,
      );

      _narrationPlayer.onPlayerComplete.first.then((_) {
        _isNarrating = false;
        _musicPlayer.setVolume(_isMuted ? 0.0 : _musicVolume);
      });
    } catch (e) {
      debugPrint('Narration audio not available: $e');
      _isNarrating = false;
      await _musicPlayer.setVolume(_isMuted ? 0.0 : _musicVolume);
    }
  }

  Future<void> _playSfx(String assetPath) async {
    if (_isMuted) return;
    try {
      await _sfxPlayer.play(
        AssetSource(assetPath.replaceFirst('assets/', '')),
        volume: _sfxVolume,
      );
    } catch (e) {
      debugPrint('SFX audio not available: $e');
    }
  }

  Future<void> _updateVolumes() async {
    final effectiveMute = _isMuted ? 0.0 : 1.0;
    await _narrationPlayer.setVolume(_voiceVolume * effectiveMute);
    await _sfxPlayer.setVolume(_sfxVolume * effectiveMute);
    await _musicPlayer.setVolume(_musicVolume * effectiveMute);
  }

  @override
  void dispose() {
    _narrationPlayer.dispose();
    _sfxPlayer.dispose();
    _musicPlayer.dispose();
    super.dispose();
  }
}
