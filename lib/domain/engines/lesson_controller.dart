import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:alphabet_adventure/data/models/lesson_data.dart';
import 'package:alphabet_adventure/data/models/letter_data.dart';
import 'package:alphabet_adventure/data/repositories/progress_repository.dart';
import 'package:alphabet_adventure/data/services/analytics_service.dart';
import 'package:alphabet_adventure/data/services/audio_service.dart';
import 'package:alphabet_adventure/domain/engines/mastery_engine.dart';
import 'package:alphabet_adventure/domain/engines/question_engine.dart';
import 'package:alphabet_adventure/domain/engines/reward_engine.dart';

/// The 5 instructional phases in a standard Alphabet Adventure lesson (PRS Section 11).
enum LessonPhase {
  introduction, // Step 1: Meet the letter, hear pronunciation, visual intro
  objectHunt,   // Step 2: Find objects starting with the target sound
  miniGame,     // Step 3: Sound match or Word Builder
  review,       // Step 4: Rapid recall challenge
  celebration,  // Step 5: Reward stars, mastery badge, stickers
}

/// Status of feedback for child interaction.
enum AnswerFeedbackStatus {
  none,
  correct,
  tryAgain,
}

/// Orchestrates the entire lifecycle of a learning session per PRS Section 11 & 24.
class LessonController extends ChangeNotifier {
  final QuestionEngine _questionEngine;
  final MasteryEngine _masteryEngine;
  final RewardEngine _rewardEngine;
  final ProgressRepository _progressRepository;
  final AudioService _audioService;
  final AnalyticsService _analyticsService;

  LessonController({
    required this._questionEngine,
    required this._masteryEngine,
    required this._rewardEngine,
    required this._progressRepository,
    required this._audioService,
    required this._analyticsService,
  });

  // --- Current Lesson State ---
  LessonData? _currentLesson;
  LessonData? get currentLesson => _currentLesson;

  LetterData? get currentLetter => _currentLesson?.letter;

  LessonPhase _currentPhase = LessonPhase.introduction;
  LessonPhase get currentPhase => _currentPhase;

  ChallengeQuestion? _currentQuestion;
  ChallengeQuestion? get currentQuestion => _currentQuestion;

  AnswerFeedbackStatus _feedbackStatus = AnswerFeedbackStatus.none;
  AnswerFeedbackStatus get feedbackStatus => _feedbackStatus;

  String? _feedbackMessage;
  String? get feedbackMessage => _feedbackMessage;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  bool _hintRevealed = false;
  bool get hintRevealed => _hintRevealed;

  int _miniGameRound = 0;

  // --- Session Metrics ---
  int _totalQuestions = 0;
  int get totalQuestions => _totalQuestions;

  int _correctAnswers = 0;
  int get correctAnswers => _correctAnswers;

  int _hintsUsed = 0;
  int get hintsUsed => _hintsUsed;

  int _currentCombo = 0;
  int get currentCombo => _currentCombo;

  int _maxCombo = 0;
  int get maxCombo => _maxCombo;

  DateTime? _sessionStartTime;
  int get sessionDurationSeconds => _sessionStartTime != null
      ? DateTime.now().difference(_sessionStartTime!).inSeconds
      : 0;

  // --- Completion Results ---
  int _earnedStars = 0;
  int get earnedStars => _earnedStars;

  MasteryEvaluationResult? _masteryResult;
  MasteryEvaluationResult? get masteryResult => _masteryResult;

  List<AchievementReward> _earnedAchievements = const [];
  List<AchievementReward> get earnedAchievements => _earnedAchievements;

  // --- Lifecycle Methods ---

  /// Initializes and starts a new lesson for the active profile.
  void startLesson(LessonData lesson) {
    _currentLesson = lesson;
    _currentPhase = LessonPhase.introduction;
    _totalQuestions = 0;
    _correctAnswers = 0;
    _hintsUsed = 0;
    _currentCombo = 0;
    _maxCombo = 0;
    _earnedStars = 0;
    _masteryResult = null;
    _earnedAchievements = const [];
    _hintRevealed = false;
    _miniGameRound = 0;
    _feedbackStatus = AnswerFeedbackStatus.none;
    _feedbackMessage = null;
    _sessionStartTime = DateTime.now();

    _analyticsService.logLessonStarted(
      letter: lesson.letter.char,
      lessonId: lesson.id,
    );

    // Play letter intro audio
    _audioService.playLetterName(lesson.letter.char);

    notifyListeners();
  }

  /// Advances to the next phase in the lesson sequence.
  void advancePhase() {
    switch (_currentPhase) {
      case LessonPhase.introduction:
        _currentPhase = LessonPhase.objectHunt;
        _loadNextQuestion();
        break;
      case LessonPhase.objectHunt:
        _currentPhase = LessonPhase.miniGame;
        _loadNextQuestion();
        break;
      case LessonPhase.miniGame:
        if (_miniGameRound < 2) {
          _miniGameRound++;
          _loadNextQuestion();
        } else {
          _currentPhase = LessonPhase.review;
          _loadNextQuestion();
        }
        break;
      case LessonPhase.review:
        _currentPhase = LessonPhase.celebration;
        _finalizeLesson();
        break;
      case LessonPhase.celebration:
        // Already at the end
        break;
    }
    notifyListeners();
  }

  /// Loads the question appropriate for the current phase.
  void _loadNextQuestion() {
    if (_currentLesson == null) return;
    final letter = _currentLesson!.letter;

    _hintRevealed = false;
    _feedbackStatus = AnswerFeedbackStatus.none;
    _feedbackMessage = null;

    switch (_currentPhase) {
      case LessonPhase.introduction:
        _currentQuestion = null;
        break;
      case LessonPhase.objectHunt:
        _currentQuestion = _questionEngine.generateObjectHunt(targetLetter: letter);
        break;
      case LessonPhase.miniGame:
        // Run Sound Match, Word Match, then Word Builder in sequence.
        if (_miniGameRound == 0) {
          _currentQuestion = _questionEngine.generateSoundMatch(targetLetter: letter);
        } else if (_miniGameRound == 1) {
          _currentQuestion = _questionEngine.generateWordMatch(targetLetter: letter);
        } else {
          _currentQuestion = _questionEngine.generateWordBuilder(targetLetter: letter);
        }
        break;
      case LessonPhase.review:
        _currentQuestion = _questionEngine.generateLetterHunt(targetLetter: letter);
        break;
      case LessonPhase.celebration:
        _currentQuestion = null;
        break;
    }

    if (_currentQuestion?.audioAsset != null) {
      _audioService.playVoice(_currentQuestion!.audioAsset!);
    }
  }

  /// Submits an answer with positive/encouraging feedback and no penalty (PRS Section 18).
  Future<bool> submitAnswer(dynamic answer) async {
    if (_isProcessing || _currentQuestion == null) return false;

    _isProcessing = true;
    _totalQuestions++;
    notifyListeners();

    bool isCorrect = false;
    final q = _currentQuestion!;

    if (q is LetterHuntQuestion) {
      isCorrect = (answer == q.correctIndex) || (answer == q.targetSymbol);
    } else if (q is ObjectHuntQuestion) {
      isCorrect = (answer == q.correctIndex) || (answer == q.targetWord);
    } else if (q is SoundMatchQuestion) {
      isCorrect = (answer == q.correctIndex) || (answer == q.targetLetter);
    } else if (q is WordMatchQuestion) {
      isCorrect = (answer == q.correctIndex) || (answer == q.targetWord);
    } else if (q is WordBuilderQuestion) {
      if (answer is List<String>) {
        isCorrect = answer.join('').toUpperCase() == q.targetWord.word.toUpperCase();
      }
    } else if (q is ReviewChallengeQuestion) {
      isCorrect = (answer == q.correctIndex);
    }

    if (isCorrect) {
      _correctAnswers++;
      _currentCombo++;
      if (_currentCombo > _maxCombo) {
        _maxCombo = _currentCombo;
      }

      _feedbackStatus = AnswerFeedbackStatus.correct;
      _feedbackMessage = _getEncouragingMessage();
      _audioService.playSuccessSound();
      _audioService.playMascotEncouragement();

      _analyticsService.logChallengeCompleted(
        letter: _currentLesson?.letter.char ?? '',
        challengeType: q.type.name,
        isSuccess: true,
        durationSeconds: 5,
      );

      notifyListeners();

      // Wait briefly for celebration animation before advancing
      await Future.delayed(const Duration(milliseconds: 1400));
      _isProcessing = false;
      advancePhase();
      return true;
    } else {
      _currentCombo = 0;
      _feedbackStatus = AnswerFeedbackStatus.tryAgain;
      _feedbackMessage = "Let's try again! You're so close!";
      _audioService.playTryAgainSound();

      _analyticsService.logChallengeCompleted(
        letter: _currentLesson?.letter.char ?? '',
        challengeType: q.type.name,
        isSuccess: false,
        durationSeconds: 5,
      );

      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 1000));
      _feedbackStatus = AnswerFeedbackStatus.none;
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  /// Reveals hint for current question (non-punitive).
  void requestHint() {
    if (_hintRevealed) return;
    _hintRevealed = true;
    _hintsUsed++;
    _audioService.playHintSound();
    _analyticsService.logHintRequested(
      letter: _currentLesson?.letter.char ?? '',
      challengeType: _currentQuestion?.type.name ?? 'unknown',
    );
    notifyListeners();
  }

  /// Replays the current question's prompt and audio narration.
  void replayAudio() {
    if (_currentQuestion?.audioAsset != null) {
      _audioService.playVoice(_currentQuestion!.audioAsset!);
    } else if (_currentLesson != null) {
      _audioService.playLetterName(_currentLesson!.letter.char);
    }
  }

  /// Concludes lesson, calculates stars, evaluates mastery, checks achievements, and persists progress.
  Future<void> _finalizeLesson() async {
    if (_currentLesson == null) return;
    final letter = _currentLesson!.letter;

    _earnedStars = _rewardEngine.calculateStars(
      totalQuestions: _totalQuestions > 0 ? _totalQuestions : 3,
      correctAnswers: _correctAnswers > 0 ? _correctAnswers : 3,
      hintsUsed: _hintsUsed,
    );

    final currentProfile = _progressRepository.activeProfile;
    final previousProgress = _progressRepository.getProgress(letter.char);

    // Evaluate mastery
    _masteryResult = _masteryEngine.evaluateSession(
      letter: letter,
      sessionAttempts: _totalQuestions,
      sessionCorrect: _correctAnswers,
      sessionHints: _hintsUsed,
      previousMastery: previousProgress.masteryLevel,
      historicalAttempts: previousProgress.totalAttempts,
      historicalCorrect: previousProgress.successfulAttempts,
      historicalHints: previousProgress.hintsUsed,
      historicalSessions: previousProgress.sessionCount,
      currentStreak: currentProfile?.currentStreak ?? 0,
    );

    // Update progress in repository
    await _progressRepository.recordLessonCompletion(
      letterChar: letter.char,
      starsEarned: _earnedStars,
      newMastery: _masteryResult!.newLevel,
      sessionAttempts: _totalQuestions,
      sessionCorrect: _correctAnswers,
      sessionHints: _hintsUsed,
    );

    // Check achievement unlocks
    if (currentProfile != null) {
      final updatedProfile = _progressRepository.activeProfile ?? currentProfile;
      _earnedAchievements = _rewardEngine.checkAchievements(
        profile: updatedProfile,
        context: {
          'masteredLetterCount': _progressRepository.masteredLetterCount,
          'isPerfectSession': _correctAnswers == _totalQuestions && _hintsUsed == 0,
        },
      );

      for (final achievement in _earnedAchievements) {
        await _progressRepository.unlockSticker(achievement.id);
        _analyticsService.logStickerUnlocked(
          stickerId: achievement.id,
          letter: letter.char,
        );
      }
    }

    _audioService.playCelebrationFanfare();

    _analyticsService.logLessonCompleted(
      letter: letter.char,
      starsEarned: _earnedStars,
      durationSeconds: sessionDurationSeconds,
      accuracy: _totalQuestions > 0 ? (_correctAnswers / _totalQuestions) : 1.0,
    );

    notifyListeners();
  }

  String _getEncouragingMessage() {
    final messages = [
      'Awesome job!',
      'You are amazing!',
      'Super star!',
      'Great learning!',
      'Way to go!',
      'Brilliant!',
      'Pip is proud of you!',
    ];
    return messages[_correctAnswers % messages.length];
  }
}
