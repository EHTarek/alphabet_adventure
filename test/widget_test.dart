import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:alphabet_adventure/data/content/alphabet_content.dart';
import 'package:alphabet_adventure/data/content/world_themes.dart';
import 'package:alphabet_adventure/data/repositories/content_repository.dart';
import 'package:alphabet_adventure/data/repositories/progress_repository.dart';
import 'package:alphabet_adventure/data/repositories/settings_repository.dart';
import 'package:alphabet_adventure/data/services/audio_service.dart';
import 'package:alphabet_adventure/data/services/storage_service.dart';
import 'package:alphabet_adventure/domain/engines/mastery_engine.dart';
import 'package:alphabet_adventure/domain/engines/question_engine.dart';
import 'package:alphabet_adventure/domain/engines/reward_engine.dart';
import 'package:alphabet_adventure/domain/models/mastery_level.dart';
import 'package:alphabet_adventure/ui/core/widgets/animated_letter.dart';
import 'package:alphabet_adventure/ui/core/widgets/mascot_widget.dart';
import 'package:alphabet_adventure/ui/core/widgets/star_counter.dart';

void main() {
  group('Educational Content Verification', () {
    test('All 26 letters A–Z are defined with vocabulary and phonics', () {
      expect(AlphabetContent.letters.length, equals(26));
      expect(AlphabetContent.words.length, greaterThanOrEqualTo(78));

      for (final letter in AlphabetContent.letters) {
        expect(letter.letter.length, equals(1));
        expect(letter.uppercase, equals(letter.letter.toUpperCase()));
        expect(letter.lowercase, equals(letter.letter.toLowerCase()));
        expect(letter.phonicsSound, isNotEmpty);
        expect(letter.words.length, greaterThanOrEqualTo(3));
      }
    });

    test('All 6 world themes are defined and cover all letters', () {
      expect(WorldThemes.all.length, equals(6));
      final allThemeLetters = WorldThemes.all.expand((w) => w.letters).toSet();
      expect(allThemeLetters.length, equals(26));
      expect(WorldThemes.all.first.letters.length, equals(26));
      expect(WorldThemes.all.last.letters.length, equals(26));
      expect(WorldThemes.all.first.difficulty, equals(1));
      expect(WorldThemes.all.last.difficulty, equals(6));
    });

    test('Content repository provides consistent access', () {
      const repo = ContentRepository();
      expect(repo.getAllLetters().length, equals(26));
      expect(repo.getLetterData('A')?.letter, equals('A'));
      expect(repo.getWordsForLetter('A').length, greaterThanOrEqualTo(3));
    });

    test('World map content supports the complete A-Z trail', () {
      const repo = ContentRepository();
      expect(repo.getAllLetters().length, equals(26));
      expect(repo.getLettersForWorld('forest').length, equals(26));
    });

    test('World unlocks follow star thresholds', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final progress = ProgressRepository(
        storageService: StorageService(preferences),
      );
      await progress.init();
      final profile = await progress.createProfile(
        name: 'Explorer',
        avatarIndex: 0,
      );
      await progress.setActiveProfile(profile.id);

      expect(progress.isWorldUnlocked('forest'), isTrue);
      expect(progress.isWorldUnlocked('farm'), isFalse);

      await progress.recordLessonCompletion(
        letterChar: 'A',
        starsEarned: 5,
        newMastery: MasteryLevel.introduced,
        sessionAttempts: 1,
        sessionCorrect: 1,
        sessionHints: 0,
      );

      expect(progress.totalStars, equals(5));
      expect(progress.isWorldUnlocked('farm'), isTrue);
    });
  });

  group('Domain Engines Verification', () {
    test('QuestionEngine generates challenge questions for all modes', () {
      final engine = QuestionEngine();
      final letterA = AlphabetContent.letters.first;

      final letterHunt = engine.generateLetterHunt(targetLetter: letterA);
      expect(letterHunt.options.length, equals(4));
      expect(
        letterHunt.options[letterHunt.correctIndex],
        equals(letterHunt.targetSymbol),
      );

      final objectHunt = engine.generateObjectHunt(targetLetter: letterA);
      expect(objectHunt.options.length, equals(4));
      expect(
        objectHunt.options[objectHunt.correctIndex],
        equals(objectHunt.targetWord),
      );

      final soundMatch = engine.generateSoundMatch(targetLetter: letterA);
      expect(soundMatch.options.length, equals(3));
      expect(soundMatch.options[soundMatch.correctIndex], equals(letterA));

      final wordMatch = engine.generateWordMatch(targetLetter: letterA);
      expect(wordMatch.options.length, equals(4));
      expect(
        wordMatch.options[wordMatch.correctIndex],
        equals(wordMatch.targetWord),
      );

      final wordBuilder = engine.generateWordBuilder(targetLetter: letterA);
      expect(wordBuilder.targetLetters.isNotEmpty, isTrue);
      expect(
        wordBuilder.scrambledPool.length,
        greaterThan(wordBuilder.targetLetters.length),
      );
    });

    test('MasteryEngine evaluates progression and levels up accurately', () {
      const engine = MasteryEngine();

      expect(
        engine.calculateMasteryLevel(
          totalAttempts: 0,
          successfulAttempts: 0,
          hintsUsed: 0,
          currentStreak: 0,
          sessionCount: 0,
        ),
        equals(MasteryLevel.unlocked),
      );

      expect(
        engine.calculateMasteryLevel(
          totalAttempts: 2,
          successfulAttempts: 2,
          hintsUsed: 0,
          currentStreak: 1,
          sessionCount: 1,
        ),
        equals(MasteryLevel.introduced),
      );

      expect(
        engine.calculateMasteryLevel(
          totalAttempts: 10,
          successfulAttempts: 10,
          hintsUsed: 0,
          currentStreak: 4,
          sessionCount: 3,
        ),
        equals(MasteryLevel.superStar),
      );
    });

    test(
      'RewardEngine awards stars and achievements without punitive 0 stars',
      () {
        const engine = RewardEngine();

        expect(
          engine.calculateStars(
            totalQuestions: 5,
            correctAnswers: 5,
            hintsUsed: 0,
          ),
          equals(3),
        );

        expect(
          engine.calculateStars(
            totalQuestions: 5,
            correctAnswers: 4,
            hintsUsed: 1,
          ),
          equals(2),
        );

        // Completed with mistakes still earns 1 encouragement star
        expect(
          engine.calculateStars(
            totalQuestions: 5,
            correctAnswers: 1,
            hintsUsed: 4,
          ),
          equals(1),
        );
      },
    );
  });

  group('UI Core Widgets Rendering', () {
    testWidgets('AnimatedLetter displays glyph and responds to tap', (
      tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AnimatedLetter(
                letter: 'A',
                size: 100,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('StarCounter displays total star count', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: StarCounter(count: 42))),
        ),
      );

      expect(find.text('42'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    });

    testWidgets('MascotWidget renders Pip the Parrot with speech bubble', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: MascotWidget(speechBubbleText: 'Welcome Explorer!'),
            ),
          ),
        ),
      );

      expect(find.text('Welcome Explorer!'), findsOneWidget);
    });
  });

  group('Settings & Audio Persistence Verification', () {
    test('SettingsRepository persists and restores audio configuration across restarts', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final storage = StorageService(preferences);

      final audio1 = AudioService();
      final settingsRepo1 = SettingsRepository(
        storageService: storage,
        audioService: audio1,
      );
      await settingsRepo1.init();

      // Defaults
      expect(audio1.isMuted, isFalse);

      // Change mute to true
      settingsRepo1.setMuted(true);
      expect(audio1.isMuted, isTrue);

      // Verify SharedPreferences has the saved config
      final savedSettings = storage.getSettings();
      expect(savedSettings['isMuted'], isTrue);

      // Simulate app restart 1
      final audio2 = AudioService();
      final settingsRepo2 = SettingsRepository(
        storageService: storage,
        audioService: audio2,
      );
      await settingsRepo2.init();

      // Should still be muted
      expect(audio2.isMuted, isTrue);

      // Now unmute
      settingsRepo2.setMuted(false);
      expect(audio2.isMuted, isFalse);
      expect(storage.getSettings()['isMuted'], isFalse);

      // Simulate app restart 2
      final audio3 = AudioService();
      final settingsRepo3 = SettingsRepository(
        storageService: storage,
        audioService: audio3,
      );
      await settingsRepo3.init();

      // Should be unmuted after restart
      expect(audio3.isMuted, isFalse);

      // Test volume persistence
      settingsRepo3.setVoiceVolume(0.45);
      settingsRepo3.setSfxVolume(0.65);

      final audio4 = AudioService();
      final settingsRepo4 = SettingsRepository(
        storageService: storage,
        audioService: audio4,
      );
      await settingsRepo4.init();

      expect(audio4.voiceVolume, closeTo(0.45, 0.001));
      expect(audio4.sfxVolume, closeTo(0.65, 0.001));
      expect(audio4.isMuted, isFalse);
    });
  });
}
