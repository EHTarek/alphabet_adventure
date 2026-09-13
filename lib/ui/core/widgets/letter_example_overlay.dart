import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:alphabet_adventure/data/content/alphabet_content.dart';
import 'package:alphabet_adventure/data/models/letter_data.dart';
import 'package:alphabet_adventure/data/models/word_data.dart';
import 'package:alphabet_adventure/data/services/audio_service.dart';
import 'package:alphabet_adventure/ui/core/app_colors.dart';
import 'package:alphabet_adventure/ui/core/app_fonts.dart';
import 'package:alphabet_adventure/ui/core/widgets/animated_letter.dart';
import 'package:alphabet_adventure/ui/core/widgets/audio_replay_button.dart';
import 'package:alphabet_adventure/ui/core/widgets/highlighted_word_label.dart';
import 'package:alphabet_adventure/ui/core/widgets/word_media_view.dart';

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

  /// The letter's words with bundled 3D objects and pictures first, so the
  /// richest example is the one that opens. Order within each group is kept.
  static List<WordData> orderedExamples(LetterData letter) {
    final words = letter.vocabularyWords;
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
    widget.letter,
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
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color ?? Colors.white;
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
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: AppColors.accentYellow, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                // Scrolls rather than overflows on very short screens.
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(context, glyph),
                      const SizedBox(height: 12),
                      _buildStage(screen),
                      const SizedBox(height: 10),
                      _buildHint(theme),
                      const SizedBox(height: 4),
                      if (_words.isNotEmpty)
                        HighlightedWordLabel(word: _current.word, fontSize: 30),
                      const SizedBox(height: 10),
                      _buildControls(),
                      if (_words.length > 1) ...[
                        const SizedBox(height: 8),
                        _buildDots(),
                      ],
                    ],
                  ),
                ),
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

    return Row(
      children: [
        AnimatedLetter(
          letter: glyph,
          size: 64,
          primaryColor: AppColors.primary,
          shadowColor: AppColors.primaryDark,
          onTap: () => widget.lowercase
              ? audio.playPhonicsSound(widget.letter.char)
              : audio.playLetterName(widget.letter.char),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.fredoka(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Close',
          iconSize: 34,
          color: AppColors.textMuted,
          icon: const Icon(Icons.cancel_rounded),
        ),
      ],
    );
  }

  Widget _buildStage(Size screen) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Square stage, but never so tall that the controls fall off a small
        // phone.
        final side = math.min(constraints.maxWidth, screen.height * 0.42);

        return SizedBox(
          height: side,
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.secondary.withValues(alpha: 0.18),
                  AppColors.secondary.withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: _words.isEmpty
                  ? const SizedBox.shrink()
                  : PageView.builder(
                      controller: _pageController,
                      itemCount: _words.length,
                      onPageChanged: _onPageChanged,
                      itemBuilder: (context, index) =>
                          WordMediaView(word: _words[index]),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHint(ThemeData theme) {
    if (_words.isEmpty) return const SizedBox.shrink();

    final (icon, text) = switch (_current.mediaKind) {
      WordMediaKind.model => (
        Icons.threed_rotation_rounded,
        'Drag to spin it!',
      ),
      WordMediaKind.image => (Icons.play_circle_rounded, 'Watch it move!'),
      WordMediaKind.emoji => (Icons.volume_up_rounded, 'Tap to hear it!'),
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Text(
          text,
          style: AppFonts.fredoka(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
      ],
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
        const SizedBox(width: 20),
        AudioReplayButton(
          size: 60,
          semanticLabel: 'Say the word again',
          onTap: () {
            if (_words.isNotEmpty) _speak(_current);
          },
        ),
        const SizedBox(width: 20),
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
            width: i == _page ? 22 : 10,
            height: 10,
            decoration: BoxDecoration(
              color: i == _page
                  ? AppColors.primary
                  : AppColors.textMuted.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(5),
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
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Material(
        color: enabled
            ? AppColors.accentYellow
            : AppColors.textMuted.withValues(alpha: 0.15),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? onTap : null,
          child: SizedBox(
            width: 52,
            height: 52,
            child: Icon(
              icon,
              size: 36,
              color: enabled ? AppColors.textDark : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
