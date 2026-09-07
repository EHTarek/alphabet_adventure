import 'package:flutter/foundation.dart';

/// Privacy-safe analytics service for educational event tracking (PRS Section 29 & 32).
///
/// Only collects educational progress events; no personal identifying information.
class AnalyticsService {
  AnalyticsService();

  final List<Map<String, dynamic>> _eventLog = [];

  /// Get all logged events.
  List<Map<String, dynamic>> get events => List.unmodifiable(_eventLog);

  /// Log a lesson started event.
  void logLessonStarted({
    required String letter,
    required String lessonId,
  }) {
    _log('lesson_started', {'lessonId': lessonId, 'letter': letter});
  }

  /// Log a lesson completed event.
  void logLessonCompleted({
    required String letter,
    required int starsEarned,
    required int durationSeconds,
    required double accuracy,
  }) {
    _log('lesson_completed', {
      'letter': letter,
      'starsEarned': starsEarned,
      'durationSeconds': durationSeconds,
      'accuracy': accuracy,
    });
  }

  /// Log a mini-game challenge completion.
  void logChallengeCompleted({
    required String letter,
    required String challengeType,
    required bool isSuccess,
    required int durationSeconds,
  }) {
    _log('challenge_completed', {
      'letter': letter,
      'challengeType': challengeType,
      'isSuccess': isSuccess,
      'durationSeconds': durationSeconds,
    });
  }

  /// Log a hint request.
  void logHintRequested({
    required String letter,
    required String challengeType,
  }) {
    _log('hint_requested', {
      'letter': letter,
      'challengeType': challengeType,
    });
  }

  /// Log sticker unlocked.
  void logStickerUnlocked({
    required String stickerId,
    required String letter,
  }) {
    _log('sticker_unlocked', {
      'stickerId': stickerId,
      'letter': letter,
    });
  }

  void _log(String eventName, Map<String, dynamic> params) {
    final event = {
      'event': eventName,
      'timestamp': DateTime.now().toIso8601String(),
      ...params,
    };
    _eventLog.add(event);
    debugPrint('📊 Analytics: $eventName $params');
  }
}
