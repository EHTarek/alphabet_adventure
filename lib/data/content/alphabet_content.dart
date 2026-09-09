import 'package:alphabet_adventure/data/models/letter_data.dart';
import 'package:alphabet_adventure/data/models/word_data.dart';

/// Complete A–Z alphabet content with 78+ vocabulary words.
///
/// Each letter has at least 3 age-appropriate vocabulary examples
/// as specified in PRS Section 14.
class AlphabetContent {
  AlphabetContent._();

  /// All 26 letter definitions.
  static const List<LetterData> letters = [
    LetterData(letter: 'A', uppercase: 'A', lowercase: 'a', phonicsSound: '/æ/', letterAudioAsset: 'assets/audio/letters/a.m4a', phonicsAudioAsset: 'assets/audio/phonics/a.m4a', words: ['apple', 'ant', 'airplane']),
    LetterData(letter: 'B', uppercase: 'B', lowercase: 'b', phonicsSound: '/b/', letterAudioAsset: 'assets/audio/letters/b.m4a', phonicsAudioAsset: 'assets/audio/phonics/b.m4a', words: ['ball', 'bear', 'banana']),
    LetterData(letter: 'C', uppercase: 'C', lowercase: 'c', phonicsSound: '/k/', letterAudioAsset: 'assets/audio/letters/c.m4a', phonicsAudioAsset: 'assets/audio/phonics/c.m4a', words: ['cat', 'car', 'cup']),
    LetterData(letter: 'D', uppercase: 'D', lowercase: 'd', phonicsSound: '/d/', letterAudioAsset: 'assets/audio/letters/d.m4a', phonicsAudioAsset: 'assets/audio/phonics/d.m4a', words: ['dog', 'duck', 'drum']),
    LetterData(letter: 'E', uppercase: 'E', lowercase: 'e', phonicsSound: '/ɛ/', letterAudioAsset: 'assets/audio/letters/e.m4a', phonicsAudioAsset: 'assets/audio/phonics/e.m4a', words: ['egg', 'elephant', 'engine']),
    LetterData(letter: 'F', uppercase: 'F', lowercase: 'f', phonicsSound: '/f/', letterAudioAsset: 'assets/audio/letters/f.m4a', phonicsAudioAsset: 'assets/audio/phonics/f.m4a', words: ['fish', 'frog', 'flower']),
    LetterData(letter: 'G', uppercase: 'G', lowercase: 'g', phonicsSound: '/ɡ/', letterAudioAsset: 'assets/audio/letters/g.m4a', phonicsAudioAsset: 'assets/audio/phonics/g.m4a', words: ['goat', 'grape', 'guitar']),
    LetterData(letter: 'H', uppercase: 'H', lowercase: 'h', phonicsSound: '/h/', letterAudioAsset: 'assets/audio/letters/h.m4a', phonicsAudioAsset: 'assets/audio/phonics/h.m4a', words: ['hat', 'horse', 'house']),
    LetterData(letter: 'I', uppercase: 'I', lowercase: 'i', phonicsSound: '/ɪ/', letterAudioAsset: 'assets/audio/letters/i.m4a', phonicsAudioAsset: 'assets/audio/phonics/i.m4a', words: ['ice', 'igloo', 'insect']),
    LetterData(letter: 'J', uppercase: 'J', lowercase: 'j', phonicsSound: '/dʒ/', letterAudioAsset: 'assets/audio/letters/j.m4a', phonicsAudioAsset: 'assets/audio/phonics/j.m4a', words: ['jar', 'jellyfish', 'juice']),
    LetterData(letter: 'K', uppercase: 'K', lowercase: 'k', phonicsSound: '/k/', letterAudioAsset: 'assets/audio/letters/k.m4a', phonicsAudioAsset: 'assets/audio/phonics/k.m4a', words: ['kite', 'king', 'kangaroo']),
    LetterData(letter: 'L', uppercase: 'L', lowercase: 'l', phonicsSound: '/l/', letterAudioAsset: 'assets/audio/letters/l.m4a', phonicsAudioAsset: 'assets/audio/phonics/l.m4a', words: ['lamp', 'lion', 'leaf']),
    LetterData(letter: 'M', uppercase: 'M', lowercase: 'm', phonicsSound: '/m/', letterAudioAsset: 'assets/audio/letters/m.m4a', phonicsAudioAsset: 'assets/audio/phonics/m.m4a', words: ['moon', 'monkey', 'mango']),
    LetterData(letter: 'N', uppercase: 'N', lowercase: 'n', phonicsSound: '/n/', letterAudioAsset: 'assets/audio/letters/n.m4a', phonicsAudioAsset: 'assets/audio/phonics/n.m4a', words: ['nest', 'nurse', 'nut']),
    LetterData(letter: 'O', uppercase: 'O', lowercase: 'o', phonicsSound: '/ɒ/', letterAudioAsset: 'assets/audio/letters/o.m4a', phonicsAudioAsset: 'assets/audio/phonics/o.m4a', words: ['octopus', 'orange', 'owl']),
    LetterData(letter: 'P', uppercase: 'P', lowercase: 'p', phonicsSound: '/p/', letterAudioAsset: 'assets/audio/letters/p.m4a', phonicsAudioAsset: 'assets/audio/phonics/p.m4a', words: ['pig', 'pencil', 'pizza']),
    LetterData(letter: 'Q', uppercase: 'Q', lowercase: 'q', phonicsSound: '/kw/', letterAudioAsset: 'assets/audio/letters/q.m4a', phonicsAudioAsset: 'assets/audio/phonics/q.m4a', words: ['queen', 'quilt', 'question']),
    LetterData(letter: 'R', uppercase: 'R', lowercase: 'r', phonicsSound: '/r/', letterAudioAsset: 'assets/audio/letters/r.m4a', phonicsAudioAsset: 'assets/audio/phonics/r.m4a', words: ['rabbit', 'rocket', 'rain']),
    LetterData(letter: 'S', uppercase: 'S', lowercase: 's', phonicsSound: '/s/', letterAudioAsset: 'assets/audio/letters/s.m4a', phonicsAudioAsset: 'assets/audio/phonics/s.m4a', words: ['sun', 'star', 'snake']),
    LetterData(letter: 'T', uppercase: 'T', lowercase: 't', phonicsSound: '/t/', letterAudioAsset: 'assets/audio/letters/t.m4a', phonicsAudioAsset: 'assets/audio/phonics/t.m4a', words: ['tree', 'tiger', 'train']),
    LetterData(letter: 'U', uppercase: 'U', lowercase: 'u', phonicsSound: '/ʌ/', letterAudioAsset: 'assets/audio/letters/u.m4a', phonicsAudioAsset: 'assets/audio/phonics/u.m4a', words: ['umbrella', 'unicorn', 'up']),
    LetterData(letter: 'V', uppercase: 'V', lowercase: 'v', phonicsSound: '/v/', letterAudioAsset: 'assets/audio/letters/v.m4a', phonicsAudioAsset: 'assets/audio/phonics/v.m4a', words: ['van', 'violin', 'volcano']),
    LetterData(letter: 'W', uppercase: 'W', lowercase: 'w', phonicsSound: '/w/', letterAudioAsset: 'assets/audio/letters/w.m4a', phonicsAudioAsset: 'assets/audio/phonics/w.m4a', words: ['whale', 'water', 'wagon']),
    LetterData(letter: 'X', uppercase: 'X', lowercase: 'x', phonicsSound: '/ks/', letterAudioAsset: 'assets/audio/letters/x.m4a', phonicsAudioAsset: 'assets/audio/phonics/x.m4a', words: ['xylophone', 'fox', 'box']),
    LetterData(letter: 'Y', uppercase: 'Y', lowercase: 'y', phonicsSound: '/j/', letterAudioAsset: 'assets/audio/letters/y.m4a', phonicsAudioAsset: 'assets/audio/phonics/y.m4a', words: ['yak', 'yarn', 'yogurt']),
    LetterData(letter: 'Z', uppercase: 'Z', lowercase: 'z', phonicsSound: '/z/', letterAudioAsset: 'assets/audio/letters/z.m4a', phonicsAudioAsset: 'assets/audio/phonics/z.m4a', words: ['zebra', 'zipper', 'zoo']),
  ];

  /// All vocabulary words with full metadata.
  static const List<WordData> words = [
    // A
    WordData(wordId: 'apple', displayName: 'Apple', letter: 'A', word: 'APPLE', category: 'food', emoji: '🍎'),
    WordData(wordId: 'ant', displayName: 'Ant', letter: 'A', word: 'ANT', category: 'animal', emoji: '🐜'),
    WordData(wordId: 'airplane', displayName: 'Airplane', letter: 'A', word: 'AIRPLANE', category: 'vehicle', emoji: '✈️'),
    // B
    WordData(wordId: 'ball', displayName: 'Ball', letter: 'B', word: 'BALL', category: 'toy', emoji: '⚽'),
    WordData(wordId: 'bear', displayName: 'Bear', letter: 'B', word: 'BEAR', category: 'animal', emoji: '🐻'),
    WordData(wordId: 'banana', displayName: 'Banana', letter: 'B', word: 'BANANA', category: 'food', emoji: '🍌'),
    // C
    WordData(wordId: 'cat', displayName: 'Cat', letter: 'C', word: 'CAT', category: 'animal', emoji: '🐱'),
    WordData(wordId: 'car', displayName: 'Car', letter: 'C', word: 'CAR', category: 'vehicle', emoji: '🚗'),
    WordData(wordId: 'cup', displayName: 'Cup', letter: 'C', word: 'CUP', category: 'object', emoji: '☕'),
    // D
    WordData(wordId: 'dog', displayName: 'Dog', letter: 'D', word: 'DOG', category: 'animal', emoji: '🐕'),
    WordData(wordId: 'duck', displayName: 'Duck', letter: 'D', word: 'DUCK', category: 'animal', emoji: '🦆'),
    WordData(wordId: 'drum', displayName: 'Drum', letter: 'D', word: 'DRUM', category: 'music', emoji: '🥁'),
    // E
    WordData(wordId: 'egg', displayName: 'Egg', letter: 'E', word: 'EGG', category: 'food', emoji: '🥚'),
    WordData(wordId: 'elephant', displayName: 'Elephant', letter: 'E', word: 'ELEPHANT', category: 'animal', emoji: '🐘'),
    WordData(wordId: 'engine', displayName: 'Engine', letter: 'E', word: 'ENGINE', category: 'vehicle', emoji: '🚂'),
    // F
    WordData(wordId: 'fish', displayName: 'Fish', letter: 'F', word: 'FISH', category: 'animal', emoji: '🐟'),
    WordData(wordId: 'frog', displayName: 'Frog', letter: 'F', word: 'FROG', category: 'animal', emoji: '🐸'),
    WordData(wordId: 'flower', displayName: 'Flower', letter: 'F', word: 'FLOWER', category: 'nature', emoji: '🌸'),
    // G
    WordData(wordId: 'goat', displayName: 'Goat', letter: 'G', word: 'GOAT', category: 'animal', emoji: '🐐'),
    WordData(wordId: 'grape', displayName: 'Grape', letter: 'G', word: 'GRAPE', category: 'food', emoji: '🍇'),
    WordData(wordId: 'guitar', displayName: 'Guitar', letter: 'G', word: 'GUITAR', category: 'music', emoji: '🎸'),
    // H
    WordData(wordId: 'hat', displayName: 'Hat', letter: 'H', word: 'HAT', category: 'clothing', emoji: '🎩'),
    WordData(wordId: 'horse', displayName: 'Horse', letter: 'H', word: 'HORSE', category: 'animal', emoji: '🐴'),
    WordData(wordId: 'house', displayName: 'House', letter: 'H', word: 'HOUSE', category: 'building', emoji: '🏠'),
    // I
    WordData(wordId: 'ice', displayName: 'Ice', letter: 'I', word: 'ICE', category: 'nature', emoji: '🧊'),
    WordData(wordId: 'igloo', displayName: 'Igloo', letter: 'I', word: 'IGLOO', category: 'building', emoji: '🏠'),
    WordData(wordId: 'insect', displayName: 'Insect', letter: 'I', word: 'INSECT', category: 'animal', emoji: '🐛'),
    // J
    WordData(wordId: 'jar', displayName: 'Jar', letter: 'J', word: 'JAR', category: 'object', emoji: '🏺'),
    WordData(wordId: 'jellyfish', displayName: 'Jellyfish', letter: 'J', word: 'JELLYFISH', category: 'animal', emoji: '🪼'),
    WordData(wordId: 'juice', displayName: 'Juice', letter: 'J', word: 'JUICE', category: 'food', emoji: '🧃'),
    // K
    WordData(wordId: 'kite', displayName: 'Kite', letter: 'K', word: 'KITE', category: 'toy', emoji: '🪁'),
    WordData(wordId: 'king', displayName: 'King', letter: 'K', word: 'KING', category: 'people', emoji: '🤴'),
    WordData(wordId: 'kangaroo', displayName: 'Kangaroo', letter: 'K', word: 'KANGAROO', category: 'animal', emoji: '🦘'),
    // L
    WordData(wordId: 'lamp', displayName: 'Lamp', letter: 'L', word: 'LAMP', category: 'object', emoji: '💡'),
    WordData(wordId: 'lion', displayName: 'Lion', letter: 'L', word: 'LION', category: 'animal', emoji: '🦁'),
    WordData(wordId: 'leaf', displayName: 'Leaf', letter: 'L', word: 'LEAF', category: 'nature', emoji: '🍃'),
    // M
    WordData(wordId: 'moon', displayName: 'Moon', letter: 'M', word: 'MOON', category: 'space', emoji: '🌙'),
    WordData(wordId: 'monkey', displayName: 'Monkey', letter: 'M', word: 'MONKEY', category: 'animal', emoji: '🐵'),
    WordData(wordId: 'mango', displayName: 'Mango', letter: 'M', word: 'MANGO', category: 'food', emoji: '🥭'),
    // N
    WordData(wordId: 'nest', displayName: 'Nest', letter: 'N', word: 'NEST', category: 'nature', emoji: '🪹'),
    WordData(wordId: 'nurse', displayName: 'Nurse', letter: 'N', word: 'NURSE', category: 'people', emoji: '👩‍⚕️'),
    WordData(wordId: 'nut', displayName: 'Nut', letter: 'N', word: 'NUT', category: 'food', emoji: '🥜'),
    // O
    WordData(wordId: 'octopus', displayName: 'Octopus', letter: 'O', word: 'OCTOPUS', category: 'animal', emoji: '🐙'),
    WordData(wordId: 'orange', displayName: 'Orange', letter: 'O', word: 'ORANGE', category: 'food', emoji: '🍊'),
    WordData(wordId: 'owl', displayName: 'Owl', letter: 'O', word: 'OWL', category: 'animal', emoji: '🦉'),
    // P
    WordData(wordId: 'pig', displayName: 'Pig', letter: 'P', word: 'PIG', category: 'animal', emoji: '🐷'),
    WordData(wordId: 'pencil', displayName: 'Pencil', letter: 'P', word: 'PENCIL', category: 'object', emoji: '✏️'),
    WordData(wordId: 'pizza', displayName: 'Pizza', letter: 'P', word: 'PIZZA', category: 'food', emoji: '🍕'),
    // Q
    WordData(wordId: 'queen', displayName: 'Queen', letter: 'Q', word: 'QUEEN', category: 'people', emoji: '👸'),
    WordData(wordId: 'quilt', displayName: 'Quilt', letter: 'Q', word: 'QUILT', category: 'object', emoji: '🛏️'),
    WordData(wordId: 'question', displayName: 'Question', letter: 'Q', word: 'QUESTION', category: 'concept', emoji: '❓'),
    // R
    WordData(wordId: 'rabbit', displayName: 'Rabbit', letter: 'R', word: 'RABBIT', category: 'animal', emoji: '🐰'),
    WordData(wordId: 'rocket', displayName: 'Rocket', letter: 'R', word: 'ROCKET', category: 'space', emoji: '🚀'),
    WordData(wordId: 'rain', displayName: 'Rain', letter: 'R', word: 'RAIN', category: 'nature', emoji: '🌧️'),
    // S
    WordData(wordId: 'sun', displayName: 'Sun', letter: 'S', word: 'SUN', category: 'space', emoji: '☀️'),
    WordData(wordId: 'star', displayName: 'Star', letter: 'S', word: 'STAR', category: 'space', emoji: '⭐'),
    WordData(wordId: 'snake', displayName: 'Snake', letter: 'S', word: 'SNAKE', category: 'animal', emoji: '🐍'),
    // T
    WordData(wordId: 'tree', displayName: 'Tree', letter: 'T', word: 'TREE', category: 'nature', emoji: '🌳'),
    WordData(wordId: 'tiger', displayName: 'Tiger', letter: 'T', word: 'TIGER', category: 'animal', emoji: '🐯'),
    WordData(wordId: 'train', displayName: 'Train', letter: 'T', word: 'TRAIN', category: 'vehicle', emoji: '🚂'),
    // U
    WordData(wordId: 'umbrella', displayName: 'Umbrella', letter: 'U', word: 'UMBRELLA', category: 'object', emoji: '☂️'),
    WordData(wordId: 'unicorn', displayName: 'Unicorn', letter: 'U', word: 'UNICORN', category: 'animal', emoji: '🦄'),
    WordData(wordId: 'up', displayName: 'Up', letter: 'U', word: 'UP', category: 'concept', emoji: '⬆️'),
    // V
    WordData(wordId: 'van', displayName: 'Van', letter: 'V', word: 'VAN', category: 'vehicle', emoji: '🚐'),
    WordData(wordId: 'violin', displayName: 'Violin', letter: 'V', word: 'VIOLIN', category: 'music', emoji: '🎻'),
    WordData(wordId: 'volcano', displayName: 'Volcano', letter: 'V', word: 'VOLCANO', category: 'nature', emoji: '🌋'),
    // W
    WordData(wordId: 'whale', displayName: 'Whale', letter: 'W', word: 'WHALE', category: 'animal', emoji: '🐋'),
    WordData(wordId: 'water', displayName: 'Water', letter: 'W', word: 'WATER', category: 'nature', emoji: '💧'),
    WordData(wordId: 'wagon', displayName: 'Wagon', letter: 'W', word: 'WAGON', category: 'vehicle', emoji: '🛒'),
    // X
    WordData(wordId: 'xylophone', displayName: 'Xylophone', letter: 'X', word: 'XYLOPHONE', category: 'music', emoji: '🎵'),
    WordData(wordId: 'fox', displayName: 'Fox', letter: 'X', word: 'FOX', category: 'animal', emoji: '🦊', difficulty: 2),
    WordData(wordId: 'box', displayName: 'Box', letter: 'X', word: 'BOX', category: 'object', emoji: '📦', difficulty: 2),
    // Y
    WordData(wordId: 'yak', displayName: 'Yak', letter: 'Y', word: 'YAK', category: 'animal', emoji: '🐂'),
    WordData(wordId: 'yarn', displayName: 'Yarn', letter: 'Y', word: 'YARN', category: 'object', emoji: '🧶'),
    WordData(wordId: 'yogurt', displayName: 'Yogurt', letter: 'Y', word: 'YOGURT', category: 'food', emoji: '🥛'),
    // Z
    WordData(wordId: 'zebra', displayName: 'Zebra', letter: 'Z', word: 'ZEBRA', category: 'animal', emoji: '🦓'),
    WordData(wordId: 'zipper', displayName: 'Zipper', letter: 'Z', word: 'ZIPPER', category: 'object', emoji: '🔗'),
    WordData(wordId: 'zoo', displayName: 'Zoo', letter: 'Z', word: 'ZOO', category: 'place', emoji: '🦁'),
  ];

  /// Get a letter definition by its letter string.
  static LetterData? getLetterData(String letter) {
    final upper = letter.toUpperCase();
    try {
      return letters.firstWhere((l) => l.letter == upper);
    } catch (_) {
      return null;
    }
  }

  /// Get all words for a specific letter.
  static List<WordData> getWordsForLetter(String letter) {
    final upper = letter.toUpperCase();
    return words.where((w) => w.letter == upper).toList();
  }

  /// Get a word by its ID.
  static WordData? getWord(String wordId) {
    try {
      return words.firstWhere((w) => w.wordId == wordId);
    } catch (_) {
      return null;
    }
  }

  /// Get words by category.
  static List<WordData> getWordsByCategory(String category) {
    return words.where((w) => w.category == category).toList();
  }

  /// Get all unique categories.
  static List<String> get categories {
    return words.map((w) => w.category).toSet().toList()..sort();
  }
}
