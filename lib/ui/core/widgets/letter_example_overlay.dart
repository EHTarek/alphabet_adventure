import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:alphabet_adventure/data/content/alphabet_content.dart';
import 'package:alphabet_adventure/data/models/letter_data.dart';
import 'package:alphabet_adventure/data/models/word_data.dart';
import 'package:alphabet_adventure/data/services/audio_service.dart';
import 'package:alphabet_adventure/ui/core/app_colors.dart';
import 'package:alphabet_adventure/ui/core/widgets/animated_letter.dart';
import 'package:alphabet_adventure/ui/core/widgets/audio_replay_button.dart';
import 'package:alphabet_adventure/ui/core/widgets/highlighted_word_label.dart';
import 'package:alphabet_adventure/ui/core/widgets/word_media_view.dart';
import 'package:alphabet_adventure/ui/core/wood/wood.dart';

/// Pops the "real example" overlay for [letter] over the current screen.
///
/// Call it from a letter's tap handler after the letter sound has started; the
/// overlay waits briefly before it says the first word so the two do not
/// overlap. [lowercase] shows the tapped case in the header.
Future<void> showLetterExampleOverlay(
  BuildContext context,
  LetterData letter, {
  bool lowercase = false,
}) {
  return _show(
    context,
    LetterExampleOverlay(letter: letter, lowercase: lowercase),
  );
}

/// Pops the overlay open on [word] — the 3D object, picture or emoji for that
/// one word — with its letter's other words a swipe away.
///
/// The overlay says the word itself, so the tap handler should not also play
/// it. Does nothing if the word's letter is unknown.
Future<void> showWordExampleOverlay(BuildContext context, WordData word) {
  final letter = AlphabetContent.getLetterData(word.letter);
  if (letter == null) return Future.value();
  return _show(
    context,
    LetterExampleOverlay(
      letter: letter,
      initialWord: word,
      // Nothing is playing yet, so only wait for the pop-in to settle.
      speakDelay: const Duration(milliseconds: 300),
    ),
  );
}

Future<void> _show(BuildContext context, LetterExampleOverlay overlay) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close examples',
    barrierColor: Colors.black.withValues(alpha: 0.6),
    transitionDuration: const Duration(milliseconds: 340),
    pageBuilder: (_, _, _) => overlay,
    transitionBuilder: (context, animation, _, child) {
      final scale = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      );
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: scale, child: child),
      );
    },
  );
}

/// Card that shows each of a letter's words as a real object — a 3D model a
/// child can spin, an animated picture, or the emoji — with the word spoken
/// aloud as they page through.
class LetterExampleOverlay extends StatefulWidget {
  final LetterData letter;
  final bool lowercase;

  /// Word to open on; defaults to the letter's first real example.
  final WordData? initialWord;

  /// How long to wait before saying the opening word, so it does not talk
  /// over a sound the tap already started.
  final Duration speakDelay;

  const LetterExampleOverlay({
    super.key,
    required this.letter,
    this.lowercase = false,
    this.initialWord,
    this.speakDelay = const Duration(milliseconds: 900),
  });

  /// [words] with bundled 3D objects and pictures first, so the richest
  /// example is the one that opens. Order within each group is kept.
  static List<WordData> orderedExamples(Iterable<WordData> words) {
    return [
      ...words.where((w) => w.hasRealExample),
      ...words.where((w) => !w.hasRealExample),
    ];
  }

  @override
  State<LetterExampleOverlay> createState() => _LetterExampleOverlayState();
}

class _LetterExampleOverlayState extends State<LetterExampleOverlay> {
  late final List<WordData> _words = LetterExampleOverlay.orderedExamples(
    widget.letter.vocabularyWords,
  );
  late final PageController _pageController;
  Timer? _introTimer;
  late int _page;

  WordData get _current => _words[_page];

  @override
  void initState() {
    super.initState();
    final initial = widget.initialWord;
    final start = initial == null ? -1 : _words.indexOf(initial);
    _page = start < 0 ? 0 : start;
    _pageController = PageController(initialPage: _page);
    // Let any sound from the tap finish before naming the object.
    _introTimer = Timer(widget.speakDelay, () {
      if (mounted && _words.isNotEmpty) _speak(_current);
    });
  }

  @override
  void dispose() {
    _introTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _speak(WordData word) {
    context.read<AudioService>().playWordPronunciation(word.wordId);
  }

  void _onPageChanged(int index) {
    _introTimer?.cancel();
    setState(() => _page = index);
    _speak(_words[index]);
  }

  void _goTo(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final glyph = widget.lowercase
        ? widget.letter.lowercase
        : widget.letter.uppercase;
    final screen = MediaQuery.sizeOf(context);

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Material(
              type: MaterialType.transparency,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    // Room for the close button riding the top corner.
                    padding: const EdgeInsets.fromLTRB(10, 12, 10, 0),
                    child: WoodPanel(
                      radius: 30,
                      depth: 8,
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                      // Scrolls rather than overflows on very short screens.
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildHeader(context, glyph),
                            const SizedBox(height: 12),
                            _buildStage(screen),
                            const SizedBox(height: 10),
                            _buildHint(),
                            const SizedBox(height: 10),
                            if (_words.isNotEmpty)
                              HighlightedWordLabel(
                                word: _current.word,
                                fontSize: 30,
                              ),
                            const SizedBox(height: 12),
                            _buildControls(),
                            if (_words.length > 1) ...[
                              const SizedBox(height: 10),
                              _buildDots(),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: WoodIconButton(
                      icon: Icons.close_rounded,
                      tone: WoodTone.red,
                      size: 48,
                      iconSize: 30,
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String glyph) {
    final audio = context.read<AudioService>();
    final title = _words.isEmpty
        ? 'The letter $glyph'
        : '$glyph is for ${_current.displayName}';

    return WoodPanel(
      tone: WoodTone.dark,
      radius: 20,
      depth: 5,
      // The right side stays clear of the close button on the corner.
      padding: const EdgeInsets.fromLTRB(6, 6, 34, 6),
      child: Row(
        children: [
          AnimatedLetter(
            letter: glyph,
            size: 60,
            primaryColor: AppColors.primary,
            shadowColor: AppColors.primaryDark,
            onTap: () => widget.lowercase
                ? audio.playPhonicsSound(widget.letter.char)
                : audio.playLetterName(widget.letter.char),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: WoodTitle(title, fontSize: 28, maxLines: 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStage(Size screen) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Square stage, but never so tall that the controls fall off a small
        // phone.
        final side = math.min(constraints.maxWidth, screen.height * 0.42);

        // A dark recessed board; each word's framed tile slides across it.
        return Container(
          height: side,
          width: double.infinity,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: WoodColors.cellDark,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: WoodColors.cellLine, width: 3),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: _words.isEmpty
                ? const SizedBox.shrink()
                : PageView.builder(
                    controller: _pageController,
                    itemCount: _words.length,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: WordMediaView(word: _words[index]),
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildHint() {
    if (_words.isEmpty) return const SizedBox.shrink();

    final (icon, text) = switch (_current.mediaKind) {
      WordMediaKind.model => (
        Icons.threed_rotation_rounded,
        'Drag to spin it!',
      ),
      WordMediaKind.image => (Icons.play_circle_rounded, 'Watch it move!'),
      WordMediaKind.emoji => (Icons.volume_up_rounded, 'Tap to hear it!'),
    };

    return WoodPill(
      label: text,
      fontSize: 16,
      leading: Icon(icon, size: 18, color: Colors.white),
    );
  }

  Widget _buildControls() {
    final hasPrev = _page > 0;
    final hasNext = _page < _words.length - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ArrowButton(
          icon: Icons.chevron_left_rounded,
          label: 'Previous word',
          enabled: hasPrev,
          onTap: () => _goTo(_page - 1),
        ),
        const SizedBox(width: 22),
        AudioReplayButton(
          size: 64,
          backgroundColor: WoodColors.candyOrange.bottom,
          semanticLabel: 'Say the word again',
          onTap: () {
            if (_words.isNotEmpty) _speak(_current);
          },
        ),
        const SizedBox(width: 22),
        _ArrowButton(
          icon: Icons.chevron_right_rounded,
          label: 'Next word',
          enabled: hasNext,
          onTap: () => _goTo(_page + 1),
        ),
      ],
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < _words.length; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == _page ? 26 : 12,
            height: 12,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: i == _page
                    ? const [WoodColors.goldTop, WoodColors.goldBottom]
                    : const [WoodColors.cellDark, WoodColors.cellDark],
              ),
              border: Border.all(
                color: i == _page
                    ? WoodColors.goldOutline
                    : WoodColors.cellLine,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _ArrowButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return WoodButton(
      onPressed: enabled ? onTap : null,
      tone: WoodTone.green,
      width: 56,
      height: 56,
      radius: 17,
      depth: 6,
      padding: EdgeInsets.zero,
      semanticLabel: label,
      child: Icon(
        icon,
        size: 40,
        shadows: const [Shadow(color: Color(0xFF145A2E), offset: Offset(0, 2))],
      ),
    );
  }
}
