import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:alphabet_adventure/data/models/child_profile.dart';
import 'package:alphabet_adventure/data/models/letter_data.dart';
import 'package:alphabet_adventure/data/models/letter_progress.dart';
import 'package:alphabet_adventure/data/repositories/content_repository.dart';
import 'package:alphabet_adventure/data/services/storage_service.dart';
import 'package:alphabet_adventure/domain/models/mastery_level.dart';

/// Repository for managing child profiles and learning progress (PRS Section 17 & 24).
class ProgressRepository extends ChangeNotifier {
  ProgressRepository({required StorageService storageService})
      : _storage = storageService;

  final StorageService _storage;
  static const _uuid = Uuid();

  ChildProfile? _activeProfile;
  List<ChildProfile> _profiles = [];
  Map<String, LetterProgress> _letterProgress = {};
  int _totalStars = 0;

  /// The currently active child profile.
  ChildProfile? get activeProfile => _activeProfile;

  /// All saved child profiles.
  List<ChildProfile> get profiles => List.unmodifiable(_profiles);

  /// All letter progress for the active profile.
  Map<String, LetterProgress> get letterProgress =>
      Map.unmodifiable(_letterProgress);

  /// Total stars earned by the active profile.
  int get totalStars => _totalStars;

  /// Number of letters started (mastery > 0).
  int get lettersStarted =>
      _letterProgress.values.where((p) => p.mastery.isStarted).length;

  /// Number of letters mastered.
  int get lettersMastered =>
      _letterProgress.values.where((p) => p.mastery.isMastered).length;

  int get masteredLetterCount => lettersMastered;

  /// Total words learned across all letters.
  int get totalWordsLearned =>
      _letterProgress.values.fold(0, (sum, p) => sum + p.wordsLearned.length);

  /// Overall accuracy across all letters.
  double get overallAccuracy {
    final total = _letterProgress.values.fold(
      0,
      (sum, p) => sum + p.correctAnswers + p.incorrectAnswers,
    );
    if (total == 0) return 0.0;
    final correct =
        _letterProgress.values.fold(0, (sum, p) => sum + p.correctAnswers);
    return correct / total;
  }

  /// Initialize — load profiles and progress from storage.
  Future<void> init() async {
    _loadProfiles();
    final activeId = _storage.getActiveProfileId();
    if (activeId != null) {
      _activeProfile = _profiles
          .cast<ChildProfile?>()
          .firstWhere((p) => p?.id == activeId, orElse: () => null);
      if (_activeProfile != null) {
        _loadProgress(activeId);
      }
    } else if (_profiles.isNotEmpty) {
      _activeProfile = _profiles.first;
      _loadProgress(_activeProfile!.id);
    }
    notifyListeners();
  }

  Future<void> initialize() => init();

  /// Create a new child profile.
  Future<ChildProfile> createProfile({
    required String name,
    required int avatarIndex,
  }) async {
    final profile = ChildProfile(
      id: _uuid.v4(),
      name: name,
      avatarIndex: avatarIndex,
      createdAt: DateTime.now(),
    );
    _profiles.add(profile);
    await _saveProfiles();
    notifyListeners();
    return profile;
  }

  /// Save or update a child profile.
  Future<void> saveProfile(ChildProfile profile) async {
    final index = _profiles.indexWhere((p) => p.id == profile.id);
    if (index >= 0) {
      _profiles[index] = profile;
    } else {
      _profiles.add(profile);
    }
    if (_activeProfile?.id == profile.id) {
      _activeProfile = profile;
    }
    await _saveProfiles();
    notifyListeners();
  }

  /// Set the active profile by object or ID.
  Future<void> setActiveProfile(dynamic profileOrId) async {
    if (profileOrId is ChildProfile) {
      _activeProfile = profileOrId;
    } else if (profileOrId is String) {
      _activeProfile = _profiles.firstWhere(
        (p) => p.id == profileOrId,
        orElse: () => _profiles.first,
      );
    }
    if (_activeProfile != null) {
      await _storage.setActiveProfileId(_activeProfile!.id);
      _loadProgress(_activeProfile!.id);
    }
    notifyListeners();
  }

  /// Delete profile.
  Future<void> deleteProfile(String profileId) async {
    _profiles.removeWhere((p) => p.id == profileId);
    if (_activeProfile?.id == profileId) {
      _activeProfile = _profiles.isNotEmpty ? _profiles.first : null;
    }
    await _saveProfiles();
    notifyListeners();
  }

  /// Get progress for a specific letter.
  LetterProgress getLetterProgressFor(String letter) {
    return _letterProgress[letter.toUpperCase()] ??
        LetterProgress(letter: letter.toUpperCase());
  }

  LetterProgress getProgress(String letter) => getLetterProgressFor(letter);

  /// Check if a world is unlocked for the active profile.
  bool isWorldUnlocked(String worldId) {
    if (_activeProfile == null) return true;
    return _activeProfile!.unlockedWorldIds.contains(worldId) ||
        worldId == 'forest' ||
        worldId == 'world_jungle';
  }

  /// Record full lesson completion with stars and mastery evaluation.
  Future<void> recordLessonCompletion({
    required String letterChar,
    required int starsEarned,
    required MasteryLevel newMastery,
    required int sessionAttempts,
    required int sessionCorrect,
    required int sessionHints,
  }) async {
    final upper = letterChar.toUpperCase();
    final current = getLetterProgressFor(upper);

    _letterProgress[upper] = current.copyWith(
      mastery: newMastery,
      starsEarned: current.starsEarned + starsEarned,
      correctAnswers: current.correctAnswers + sessionCorrect,
      incorrectAnswers: current.incorrectAnswers + (sessionAttempts - sessionCorrect),
      hintsUsed: current.hintsUsed + sessionHints,
      sessionCount: current.sessionCount + 1,
      lastPracticed: DateTime.now(),
    );

    _totalStars += starsEarned;
    if (_activeProfile != null) {
      await _storage.setTotalStars(_activeProfile!.id, _totalStars);
      _activeProfile = _activeProfile!.copyWith(totalStars: _totalStars);
      await saveProfile(_activeProfile!);
    }
    await _saveProgress();
    notifyListeners();
  }

  /// Unlock achievement sticker.
  Future<void> unlockSticker(String stickerId) async {
    if (_activeProfile == null) return;
    if (!_activeProfile!.unlockedStickerIds.contains(stickerId)) {
      final updatedStickers = [..._activeProfile!.unlockedStickerIds, stickerId];
      _activeProfile = _activeProfile!.copyWith(unlockedStickerIds: updatedStickers);
      await saveProfile(_activeProfile!);
      notifyListeners();
    }
  }

  /// Reset all progress for the active profile.
  Future<void> resetAllProgress() async {
    _letterProgress.clear();
    _totalStars = 0;
    if (_activeProfile != null) {
      await _storage.setTotalStars(_activeProfile!.id, 0);
      _activeProfile = _activeProfile!.copyWith(
        totalStars: 0,
        currentStreak: 0,
        unlockedStickerIds: [],
      );
      await saveProfile(_activeProfile!);
      await _saveProgress();
    }
    notifyListeners();
  }

  /// Adaptive review letters recommendation.
  List<LetterData> getLettersNeedingReview(ContentRepository contentRepo) {
    final allLetters = contentRepo.getAllLetters();
    final reviewProgress = getLettersByReviewPriority();

    if (reviewProgress.isEmpty) {
      return allLetters.take(3).toList();
    }

    final letters = <LetterData>[];
    for (final p in reviewProgress.take(4)) {
      final match = contentRepo.getLetterData(p.letter);
      if (match != null) letters.add(match);
    }
    return letters.isNotEmpty ? letters : allLetters.take(3).toList();
  }

  /// Get letters sorted by review priority (highest first).
  List<LetterProgress> getLettersByReviewPriority() {
    final started = _letterProgress.values
        .where((p) => p.mastery.isStarted)
        .toList();
    started.sort((a, b) => b.reviewPriority.compareTo(a.reviewPriority));
    return started;
  }

  // --- Private helpers ---

  void _loadProfiles() {
    final raw = _storage.getProfiles();
    _profiles = raw.map((json) => ChildProfile.fromJson(json)).toList();
  }

  Future<void> _saveProfiles() async {
    final json = _profiles.map((p) => p.toJson()).toList();
    await _storage.saveProfiles(json);
  }

  void _loadProgress(String profileId) {
    final raw = _storage.getLetterProgress(profileId);
    _letterProgress = raw.map(
      (key, value) => MapEntry(key, LetterProgress.fromJson(value)),
    );
    _totalStars = _storage.getTotalStars(profileId);
  }

  Future<void> _saveProgress() async {
    if (_activeProfile == null) return;
    final json = _letterProgress.map(
      (key, value) => MapEntry(key, value.toJson()),
    );
    await _storage.saveLetterProgress(_activeProfile!.id, json);
  }
}
