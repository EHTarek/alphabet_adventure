import 'package:flutter/foundation.dart';

import 'package:alphabet_adventure/data/content/world_themes.dart';
import 'package:alphabet_adventure/data/models/child_profile.dart';
import 'package:alphabet_adventure/data/models/lesson_data.dart';
import 'package:alphabet_adventure/data/models/letter_data.dart';
import 'package:alphabet_adventure/data/models/letter_progress.dart';
import 'package:alphabet_adventure/data/repositories/content_repository.dart';
import 'package:alphabet_adventure/data/repositories/progress_repository.dart';

/// View model for the World Map / Learning Trail screen (PRS Section 8 & 15).
class WorldMapViewModel extends ChangeNotifier {
  final ContentRepository _contentRepository;
  final ProgressRepository _progressRepository;

  WorldMapViewModel({
    required this._contentRepository,
    required this._progressRepository,
  }) {
    _progressRepository.addListener(notifyListeners);
  }

  int _selectedWorldIndex = 0;
  int get selectedWorldIndex => _selectedWorldIndex;

  List<WorldTheme> get worlds => _contentRepository.getAllWorlds();
  WorldTheme get currentWorld => worlds[_selectedWorldIndex];

  ChildProfile? get activeProfile => _progressRepository.activeProfile;
  int get totalStars => _progressRepository.totalStars;

  /// Letters assigned to the currently selected world.
  List<LetterData> get currentWorldLetters {
    return _contentRepository.getLettersForWorld(currentWorld.id);
  }

  /// Gets progress for a specific letter.
  LetterProgress getLetterProgress(String letterChar) {
    return _progressRepository.getProgress(letterChar);
  }

  /// Checks if a world is unlocked for the current child profile.
  bool isWorldUnlocked(WorldTheme world) {
    return _progressRepository.isWorldUnlocked(world.id);
  }

  /// Checks whether the world containing a letter is available.
  bool isLetterUnlocked(LetterData letter) {
    return isWorldUnlocked(currentWorld);
  }

  /// Selects a world to display.
  void selectWorld(int index) {
    if (index >= 0 && index < worlds.length) {
      _selectedWorldIndex = index;
      notifyListeners();
    }
  }

  /// Gets the lesson definition for a selected letter.
  LessonData getLessonForLetter(LetterData letter) {
    return _contentRepository
        .getLessonForLetter(letter.char)
        .copyWith(
          worldTheme: currentWorld.id,
          difficulty: currentWorld.difficulty,
        );
  }

  /// Returns recommended letters for adaptive daily review.
  List<LetterData> getAdaptiveReviewLetters() {
    return _progressRepository.getLettersNeedingReview(_contentRepository);
  }

  @override
  void dispose() {
    _progressRepository.removeListener(notifyListeners);
    super.dispose();
  }
}
