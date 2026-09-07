import 'dart:math';

import 'package:alphabet_adventure/data/content/alphabet_content.dart';
import 'package:alphabet_adventure/data/models/letter_data.dart';
import 'package:alphabet_adventure/data/models/word_data.dart';

/// Question types supported across all mini-games and review challenges.
enum QuestionType {
  letterHunt,
  objectHunt,
  soundMatch,
  wordBuilder,
  reviewChallenge,
}

/// Base challenge question model.
sealed class ChallengeQuestion {
  final String id;
  final QuestionType type;
  final String prompt;
  final String? audioAsset;
  final LetterData targetLetter;
  final String hintText;

  const ChallengeQuestion({
    required this.id,
    required this.type,
    required this.prompt,
    this.audioAsset,
    required this.targetLetter,
    required this.hintText,
  });
}

/// Letter Hunt challenge: find the target letter among distractor letters.
class LetterHuntQuestion extends ChallengeQuestion {
  final bool isUppercase;
  final String targetSymbol;
  final List<String> options;
  final int correctIndex;

  const LetterHuntQuestion({
    required super.id,
    required super.prompt,
    super.audioAsset,
    required super.targetLetter,
    required super.hintText,
    required this.isUppercase,
    required this.targetSymbol,
    required this.options,
    required this.correctIndex,
  }) : super(type: QuestionType.letterHunt);
}

/// Object Hunt challenge: find the object starting with target letter/sound among distractors.
class ObjectHuntQuestion extends ChallengeQuestion {
  final WordData targetWord;
  final List<WordData> options;
  final int correctIndex;

  const ObjectHuntQuestion({
    required super.id,
    required super.prompt,
    super.audioAsset,
    required super.targetLetter,
    required super.hintText,
    required this.targetWord,
    required this.options,
    required this.correctIndex,
  }) : super(type: QuestionType.objectHunt);
}

/// Sound Match challenge: listen to a sound/word and select the matching letter.
class SoundMatchQuestion extends ChallengeQuestion {
  final String soundPrompt;
  final List<LetterData> options;
  final int correctIndex;

  const SoundMatchQuestion({
    required super.id,
    required super.prompt,
    super.audioAsset,
    required super.targetLetter,
    required super.hintText,
    required this.soundPrompt,
    required this.options,
    required this.correctIndex,
  }) : super(type: QuestionType.soundMatch);
}

/// Word Builder challenge: assemble the letters of a word in the correct order.
class WordBuilderQuestion extends ChallengeQuestion {
  final WordData targetWord;
  final List<String> targetLetters;
  final List<String> scrambledPool;

  const WordBuilderQuestion({
    required super.id,
    required super.prompt,
    super.audioAsset,
    required super.targetLetter,
    required super.hintText,
    required this.targetWord,
    required this.targetLetters,
    required this.scrambledPool,
  }) : super(type: QuestionType.wordBuilder);
}

/// Review Challenge question: mixed rapid-fire review questions.
class ReviewChallengeQuestion extends ChallengeQuestion {
  final String subType; // 'letter_to_sound', 'word_to_letter', 'find_letter'
  final List<dynamic> options;
  final int correctIndex;
  final String explanation;

  const ReviewChallengeQuestion({
    required super.id,
    required super.prompt,
    super.audioAsset,
    required super.targetLetter,
    required super.hintText,
    required this.subType,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  }) : super(type: QuestionType.reviewChallenge);
}

/// Engine that generates balanced, age-appropriate questions for all mini-game modes.
class QuestionEngine {
  final Random _random;

  QuestionEngine({Random? random}) : _random = random ?? Random();

  /// Generates a Letter Hunt question.
  LetterHuntQuestion generateLetterHunt({
    required LetterData targetLetter,
    int optionCount = 4,
    bool? uppercaseOnly,
  }) {
    final isUpper = uppercaseOnly ?? _random.nextBool();
    final targetSymbol = isUpper ? targetLetter.uppercase : targetLetter.lowercase;

    // Pick distractor letters
    final allOtherLetters = AlphabetContent.letters
        .where((l) => l.char != targetLetter.char)
        .toList()
      ..shuffle(_random);

    final distractorLetters = allOtherLetters.take(optionCount - 1).map((l) {
      return isUpper ? l.uppercase : l.lowercase;
    }).toList();

    final options = <String>[targetSymbol, ...distractorLetters]..shuffle(_random);
    final correctIndex = options.indexOf(targetSymbol);

    return LetterHuntQuestion(
      id: 'lh_${targetLetter.char}_${DateTime.now().millisecondsSinceEpoch}',
      prompt: 'Find the letter "$targetSymbol"!',
      audioAsset: targetLetter.audioLetterName,
      targetLetter: targetLetter,
      hintText: 'Look for the letter "$targetSymbol". Pip believes in you!',
      isUppercase: isUpper,
      targetSymbol: targetSymbol,
      options: options,
      correctIndex: correctIndex,
    );
  }

  /// Generates an Object Hunt question.
  ObjectHuntQuestion generateObjectHunt({
    required LetterData targetLetter,
    WordData? specificTargetWord,
    int optionCount = 4,
  }) {
    final words = targetLetter.vocabularyWords.isNotEmpty
        ? targetLetter.vocabularyWords
        : AlphabetContent.words.where((w) => w.letter == targetLetter.char).toList();

    final targetWord = specificTargetWord ??
        (words.isNotEmpty ? words[_random.nextInt(words.length)] : AlphabetContent.words.first);

    // Pick distractor words from other letters
    final otherWords = AlphabetContent.words
        .where((w) => w.letter != targetLetter.char)
        .toList()
      ..shuffle(_random);

    final distractors = otherWords.take(optionCount - 1).toList();
    final options = <WordData>[targetWord, ...distractors]..shuffle(_random);
    final correctIndex = options.indexOf(targetWord);

    return ObjectHuntQuestion(
      id: 'oh_${targetLetter.char}_${targetWord.word}_${DateTime.now().millisecondsSinceEpoch}',
      prompt: 'Find the object that starts with "${targetLetter.uppercase}" (${targetWord.phoneticSpelling})!',
      audioAsset: targetLetter.audioPhonicsSound,
      targetLetter: targetLetter,
      hintText: '${targetWord.displayName} starts with the letter ${targetLetter.uppercase}!',
      targetWord: targetWord,
      options: options,
      correctIndex: correctIndex,
    );
  }

  /// Generates a Sound Match question.
  SoundMatchQuestion generateSoundMatch({
    required LetterData targetLetter,
    int optionCount = 3,
  }) {
    final allOtherLetters = AlphabetContent.letters
        .where((l) => l.char != targetLetter.char)
        .toList()
      ..shuffle(_random);

    final distractors = allOtherLetters.take(optionCount - 1).toList();
    final options = <LetterData>[targetLetter, ...distractors]..shuffle(_random);
    final correctIndex = options.indexOf(targetLetter);

    return SoundMatchQuestion(
      id: 'sm_${targetLetter.char}_${DateTime.now().millisecondsSinceEpoch}',
      prompt: 'Which letter makes the sound: /${targetLetter.phonicsSound}/?',
      audioAsset: targetLetter.audioPhonicsSound,
      targetLetter: targetLetter,
      hintText: 'Listen closely to the sound /${targetLetter.phonicsSound}/!',
      soundPrompt: targetLetter.phonicsSound,
      options: options,
      correctIndex: correctIndex,
    );
  }

  /// Generates a Word Builder question.
  WordBuilderQuestion generateWordBuilder({
    required LetterData targetLetter,
    WordData? specificTargetWord,
    int extraDistractors = 2,
  }) {
    final words = targetLetter.vocabularyWords.isNotEmpty
        ? targetLetter.vocabularyWords
        : AlphabetContent.words.where((w) => w.letter == targetLetter.char).toList();

    final targetWord = specificTargetWord ??
        (words.isNotEmpty ? words[_random.nextInt(words.length)] : AlphabetContent.words.first);

    final wordLetters = targetWord.word.toUpperCase().split('');
    final distractorChars = <String>[];

    final availableAlphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('')
      ..removeWhere((c) => wordLetters.contains(c))
      ..shuffle(_random);

    distractorChars.addAll(availableAlphabet.take(extraDistractors));

    final scrambledPool = [...wordLetters, ...distractorChars]..shuffle(_random);

    return WordBuilderQuestion(
      id: 'wb_${targetLetter.char}_${targetWord.word}_${DateTime.now().millisecondsSinceEpoch}',
      prompt: 'Spell the word: "${targetWord.word.toUpperCase()}"!',
      audioAsset: targetWord.audioPronunciation,
      targetLetter: targetLetter,
      hintText: 'The first letter is ${wordLetters.first}!',
      targetWord: targetWord,
      targetLetters: wordLetters,
      scrambledPool: scrambledPool,
    );
  }

  /// Generates a Review Challenge batch with a mix of questions.
  List<ChallengeQuestion> generateReviewBatch({
    required List<LetterData> lettersToReview,
    int questionCount = 5,
  }) {
    var reviewList = lettersToReview;
    if (reviewList.isEmpty) {
      reviewList = AlphabetContent.letters.take(3).toList();
    }

    final questions = <ChallengeQuestion>[];
    for (int i = 0; i < questionCount; i++) {
      final letter = reviewList[i % reviewList.length];
      final mode = i % 4;

      switch (mode) {
        case 0:
          questions.add(generateLetterHunt(targetLetter: letter));
          break;
        case 1:
          questions.add(generateObjectHunt(targetLetter: letter));
          break;
        case 2:
          questions.add(generateSoundMatch(targetLetter: letter));
          break;
        case 3:
          questions.add(generateWordBuilder(targetLetter: letter));
          break;
      }
    }

    return questions..shuffle(_random);
  }
}
