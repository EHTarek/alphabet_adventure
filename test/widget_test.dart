import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alphabet_adventure/data/content/alphabet_content.dart';
import 'package:alphabet_adventure/data/content/world_themes.dart';
import 'package:alphabet_adventure/data/repositories/content_repository.dart';
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
    });

    test('Content repository provides consistent access', () {
      const repo = ContentRepository();
      expect(repo.getAllLetters().length, equals(26));
      expect(repo.getLetterData('A')?.letter, equals('A'));
      expect(repo.getWordsForLetter('A').length, greaterThanOrEqualTo(3));
    });
  });

  group('Domain Engines Verification', () {
    test('QuestionEngine generates challenge questions for all modes', () {
      final engine = QuestionEngine();
      final letterA = AlphabetContent.letters.first;

      final letterHunt = engine.generateLetterHunt(targetLetter: letterA);
      expect(letterHunt.options.length, equals(4));
      expect(letterHunt.options[letterHunt.correctIndex], equals(letterHunt.targetSymbol));

      final objectHunt = engine.generateObjectHunt(targetLetter: letterA);
      expect(objectHunt.options.length, equals(4));
      expect(objectHunt.options[objectHunt.correctIndex], equals(objectHunt.targetWord));

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
      expect(wordBuilder.scrambledPool.length, greaterThan(wordBuilder.targetLetters.length));
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

    test('RewardEngine awards stars and achievements without punitive 0 stars', () {
      const engine = RewardEngine();

      expect(
        engine.calculateStars(totalQuestions: 5, correctAnswers: 5, hintsUsed: 0),
        equals(3),
      );

      expect(
        engine.calculateStars(totalQuestions: 5, correctAnswers: 4, hintsUsed: 1),
        equals(2),
      );

      // Completed with mistakes still earns 1 encouragement star
      expect(
        engine.calculateStars(totalQuestions: 5, correctAnswers: 1, hintsUsed: 4),
        equals(1),
      );
    });
  });

  group('UI Core Widgets Rendering', () {
    testWidgets('AnimatedLetter displays glyph and responds to tap', (tester) async {
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
          home: Scaffold(
            body: Center(
              child: StarCounter(count: 42),
            ),
          ),
        ),
      );

      expect(find.text('42'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    });

    testWidgets('MascotWidget renders Pip the Parrot with speech bubble', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: MascotWidget(
                speechBubbleText: 'Welcome Explorer!',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Welcome Explorer!'), findsOneWidget);
    });
  });
}
