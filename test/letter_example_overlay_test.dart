import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:alphabet_adventure/data/content/alphabet_content.dart';
import 'package:alphabet_adventure/data/models/word_data.dart';
import 'package:alphabet_adventure/data/repositories/content_repository.dart';
import 'package:alphabet_adventure/data/repositories/progress_repository.dart';
import 'package:alphabet_adventure/data/services/audio_service.dart';
import 'package:alphabet_adventure/data/services/storage_service.dart';
import 'package:alphabet_adventure/ui/core/widgets/animated_letter.dart';
import 'package:alphabet_adventure/ui/core/widgets/highlighted_word_label.dart';
import 'package:alphabet_adventure/ui/core/widgets/interactive_object.dart';
import 'package:alphabet_adventure/ui/core/widgets/letter_example_overlay.dart';
import 'package:alphabet_adventure/ui/core/widgets/word_media_view.dart';
import 'package:alphabet_adventure/ui/features/library/views/library_screen.dart';

/// Records which words were spoken instead of touching platform audio.
class _RecordingAudioService extends AudioService {
  final List<String> spokenWords = [];

  @override
  Future<void> playWordPronunciation(String wordId) async {
    spokenWords.add(wordId);
  }

  @override
  Future<void> playLetterName(String letter) async {}

  @override
  Future<void> playPhonicsSound(String letter) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final channel in const [
    'xyz.luan/audioplayers.global',
    'xyz.luan/audioplayers',
  ]) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          MethodChannel(channel),
          (MethodCall methodCall) async => null,
        );
  }

  setUp(() {
    // The real 3D stage is a platform WebView; stand in for it here.
    WordMediaView.debugModelStageBuilder = (word) =>
        Text('3D:${word.wordId}', key: const Key('model-stage'));
  });

  tearDown(() {
    WordMediaView.debugModelStageBuilder = null;
  });

  Widget host(Widget child, AudioService audio) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AudioService>.value(value: audio),
        Provider<ContentRepository>.value(value: ContentRepository()),
      ],
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  group('WordData media kind', () {
    test('prefers a 3D model, then a picture, then the emoji', () {
      const base = WordData(
        wordId: 'x',
        displayName: 'X',
        letter: 'X',
        word: 'X',
        category: 'test',
        emoji: '❓',
      );
      expect(base.mediaKind, WordMediaKind.emoji);
      expect(base.hasRealExample, isFalse);

      const withImage = WordData(
        wordId: 'x',
        displayName: 'X',
        letter: 'X',
        word: 'X',
        category: 'test',
        imageAsset: 'assets/images/words/x.gif',
      );
      expect(withImage.mediaKind, WordMediaKind.image);

      const withBoth = WordData(
        wordId: 'x',
        displayName: 'X',
        letter: 'X',
        word: 'X',
        category: 'test',
        imageAsset: 'assets/images/words/x.gif',
        modelAsset: 'assets/models/x.glb',
      );
      expect(withBoth.mediaKind, WordMediaKind.model);
      expect(withBoth.hasRealExample, isTrue);
    });

    test('every bundled model path points at an existing .glb', () {
      final withModels = AlphabetContent.words
          .where((w) => w.modelAsset != null)
          .toList();
      // Every word ships with a 3D object.
      expect(withModels.length, AlphabetContent.words.length);
      for (final word in withModels) {
        expect(word.modelAsset, 'assets/models/${word.wordId}.glb');
        expect(
          File(word.modelAsset!).existsSync(),
          isTrue,
          reason: '${word.modelAsset} is missing from assets/models',
        );
      }
    });

    test('every .glb in assets/models is used by exactly one word', () {
      final files = Directory('assets/models')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.glb'))
          .map((f) => f.uri.pathSegments.last.replaceAll('.glb', ''))
          .toSet();
      final used = AlphabetContent.words
          .where((w) => w.modelAsset != null)
          .map((w) => w.wordId)
          .toSet();
      expect(files, used);
    });
  });

  group('glbPositionBounds', () {
    test('reads rest-pose bounds from a skinned GLB', () {
      final bytes = File('assets/models/fox.glb').readAsBytesSync();
      final bounds = glbPositionBounds(bytes)!;
      expect(bounds.max.y, greaterThan(bounds.min.y));
      expect(bounds.max.x, greaterThan(bounds.min.x));
    });

    test('returns null for data that is not a GLB', () {
      expect(glbPositionBounds(Uint8List.fromList([1, 2, 3])), isNull);
    });
  });

  group('WordMediaView', () {
    testWidgets('shows the floating emoji for a word with no assets', (
      tester,
    ) async {
      const word = WordData(
        wordId: 'kazoo',
        displayName: 'Kazoo',
        letter: 'K',
        word: 'KAZOO',
        category: 'music',
        emoji: '🎺',
      );
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: WordMediaView(word: word),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('🎺'), findsOneWidget);
      expect(find.byKey(const Key('model-stage')), findsNothing);
      await tester.pump(const Duration(milliseconds: 50));
    });
  });

  group('LetterExampleOverlay', () {
    test('puts words with a real example before emoji-only words', () {
      WordData word(String id, {String? model}) => WordData(
        wordId: id,
        displayName: id,
        letter: 'X',
        word: id.toUpperCase(),
        category: 'test',
        modelAsset: model,
      );
      final ordered = LetterExampleOverlay.orderedExamples([
        word('a'),
        word('b', model: 'assets/models/b.glb'),
        word('c'),
        word('d', model: 'assets/models/d.glb'),
      ]);
      expect(ordered.map((w) => w.wordId), ['b', 'd', 'a', 'c']);
    });

    testWidgets(
      'opens on the first real example and speaks it after the letter',
      (tester) async {
        final audio = _RecordingAudioService();
        final letterD = AlphabetContent.getLetterData('D')!;

        await tester.pumpWidget(
          host(LetterExampleOverlay(letter: letterD), audio),
        );
        await tester.pump();

        expect(find.text('D is for Dog'), findsOneWidget);
        expect(find.byKey(const Key('model-stage')), findsOneWidget);
        expect(find.text('3D:dog'), findsOneWidget);
        expect(find.text('Drag to spin it!'), findsOneWidget);
        expect(find.byType(HighlightedWordLabel), findsOneWidget);

        // The word is named only after the letter sound has had time to play.
        expect(audio.spokenWords, isEmpty);
        await tester.pump(const Duration(milliseconds: 1000));
        expect(audio.spokenWords, ['dog']);
      },
    );

    testWidgets('next arrow pages to the following word and speaks it', (
      tester,
    ) async {
      final audio = _RecordingAudioService();
      final letterD = AlphabetContent.getLetterData('D')!;

      await tester.pumpWidget(
        host(LetterExampleOverlay(letter: letterD), audio),
      );
      await tester.pump();

      await tester.tap(find.bySemanticsLabel('Next word'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('D is for Duck'), findsOneWidget);
      expect(find.text('3D:duck'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Next word'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('D is for Drum'), findsOneWidget);
      expect(find.text('3D:drum'), findsOneWidget);
      expect(find.text('Drag to spin it!'), findsOneWidget);
      expect(audio.spokenWords, ['duck', 'drum']);

      // Replay speaks the current word again.
      await tester.tap(find.bySemanticsLabel('Say the word again'));
      await tester.pump();
      expect(audio.spokenWords, ['duck', 'drum', 'drum']);

      // Flush the emoji stage's animation timer before teardown.
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets(
      'shows the lowercase glyph when opened from a lowercase letter',
      (tester) async {
        final audio = _RecordingAudioService();
        final letterA = AlphabetContent.getLetterData('A')!;

        await tester.pumpWidget(
          host(LetterExampleOverlay(letter: letterA, lowercase: true), audio),
        );
        await tester.pump();

        expect(find.text('a is for Apple'), findsOneWidget);
        expect(
          tester.widget<AnimatedLetter>(find.byType(AnimatedLetter)).letter,
          'a',
        );

        // Let the intro timer and animation timers fire before teardown.
        await tester.pump(const Duration(milliseconds: 1000));
        expect(audio.spokenWords, ['apple']);
      },
    );
  });

  group('Word entry point', () {
    testWidgets('opens on the tapped word and speaks it after a short delay', (
      tester,
    ) async {
      final audio = _RecordingAudioService();
      final letterD = AlphabetContent.getLetterData('D')!;
      final drum = AlphabetContent.getWord('drum')!;

      await tester.pumpWidget(
        host(
          LetterExampleOverlay(
            letter: letterD,
            initialWord: drum,
            speakDelay: const Duration(milliseconds: 300),
          ),
          audio,
        ),
      );
      await tester.pump();

      // Opens straight on "drum", not on the letter's first example.
      expect(find.text('D is for Drum'), findsOneWidget);
      expect(find.text('3D:drum'), findsOneWidget);

      expect(audio.spokenWords, isEmpty);
      await tester.pump(const Duration(milliseconds: 350));
      expect(audio.spokenWords, ['drum']);

      // The other words are still a page away.
      await tester.tap(find.bySemanticsLabel('Previous word'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('D is for Duck'), findsOneWidget);
      expect(audio.spokenWords, ['drum', 'duck']);

      // Flush the emoji stage's animation timer before teardown.
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('opens on a 3D word from the tapped word itself', (
      tester,
    ) async {
      final audio = _RecordingAudioService();
      final letterF = AlphabetContent.getLetterData('F')!;
      final flower = AlphabetContent.getWord('flower')!;

      await tester.pumpWidget(
        host(LetterExampleOverlay(letter: letterF, initialWord: flower), audio),
      );
      await tester.pump();

      expect(find.text('F is for Flower'), findsOneWidget);
      expect(find.text('3D:flower'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 1000));
      expect(audio.spokenWords, ['flower']);
    });
  });

  group('Library integration', () {
    testWidgets('tapping a letter in the library opens its example overlay', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService(await SharedPreferences.getInstance());
      final progress = ProgressRepository(storageService: storage);
      await progress.init();
      final audio = _RecordingAudioService();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ProgressRepository>.value(value: progress),
            ChangeNotifierProvider<AudioService>.value(value: audio),
            Provider<ContentRepository>.value(value: ContentRepository()),
          ],
          child: const MaterialApp(home: LibraryScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(LetterExampleOverlay), findsNothing);

      await tester.tap(find.widgetWithText(AnimatedLetter, 'B'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(LetterExampleOverlay), findsOneWidget);
      expect(find.text('B is for Ball'), findsOneWidget);

      // Close button dismisses it.
      await tester.tap(find.byTooltip('Close'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(LetterExampleOverlay), findsNothing);
    });

    testWidgets('tapping a word card in the library opens the overlay on it', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService(await SharedPreferences.getInstance());
      final progress = ProgressRepository(storageService: storage);
      await progress.init();
      final audio = _RecordingAudioService();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ProgressRepository>.value(value: progress),
            ChangeNotifierProvider<AudioService>.value(value: audio),
            Provider<ContentRepository>.value(value: ContentRepository()),
          ],
          child: const MaterialApp(home: LibraryScreen(initialIndex: 2)),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // "Ant" is the second word card in the grid.
      final antCard = find.byWidgetPredicate(
        (w) => w is InteractiveObject && w.word.wordId == 'ant',
      );
      expect(antCard, findsOneWidget);
      await tester.tap(antCard);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(LetterExampleOverlay), findsOneWidget);
      expect(find.text('A is for Ant'), findsOneWidget);
      // Spoken once, by the overlay — the tap itself stays silent.
      expect(audio.spokenWords, ['ant']);
    });
  });
}
