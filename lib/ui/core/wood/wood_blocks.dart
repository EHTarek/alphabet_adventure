import 'package:flutter/material.dart';

import 'package:alphabet_adventure/ui/core/app_fonts.dart';
import 'package:alphabet_adventure/ui/core/wood/wood_palette.dart';
import 'package:alphabet_adventure/ui/core/wood/wood_surface.dart';
import 'package:alphabet_adventure/ui/core/wood/wood_text.dart';

/// A glossy candy cube, optionally holding a glyph: the building block of the
/// logo and of letter tiles.
class CandyBlock extends StatelessWidget {
  const CandyBlock({
    super.key,
    required this.colors,
    this.size = 56,
    this.child,
    this.letter,
    this.rotation = 0,
  });

  final WoodToneColors colors;
  final double size;
  final Widget? child;

  /// Shortcut for a white, dark-edged glyph filling the block.
  final String? letter;

  /// Tilt in radians, for a playful stacked look.
  final double rotation;

  @override
  Widget build(BuildContext context) {
    final depth = size * 0.1;
    Widget content = child ?? const SizedBox.shrink();
    if (letter != null) {
      content = Padding(
        padding: EdgeInsets.symmetric(horizontal: size * 0.1),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            letter!,
            style: AppFonts.fredoka(
              fontSize: size * 0.64,
              fontWeight: FontWeight.w700,
              color: colors.ink,
              height: 1,
              shadows: [
                Shadow(
                  color: colors.bevel.withValues(alpha: 0.85),
                  offset: Offset(0, size * 0.045),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final block = CustomPaint(
      painter: WoodSurfacePainter(
        colors: colors,
        radius: size * 0.24,
        depth: depth,
        rimWidth: size * 0.05,
      ),
      child: SizedBox(
        width: size,
        height: size + depth,
        child: Padding(
          padding: EdgeInsets.only(bottom: depth),
          child: Center(child: content),
        ),
      ),
    );
    return rotation == 0
        ? block
        : Transform.rotate(angle: rotation, child: block);
  }
}

/// A word spelled in tilted candy blocks, each letter a different colour.
class CandyBlockWord extends StatelessWidget {
  const CandyBlockWord(
    this.word, {
    super.key,
    this.blockSize = 44,
    this.overlap = 0.1,
  });

  final String word;
  final double blockSize;

  /// How far neighbouring blocks tuck under each other, as a share of size.
  final double overlap;

  /// Width taken by [letters] blocks of [blockSize] with [overlap].
  static double widthFor(
    int letters,
    double blockSize, {
    double overlap = 0.1,
  }) {
    if (letters == 0) return 0;
    // Extra room for the tilt of the outer blocks.
    return blockSize * (letters - (letters - 1) * overlap + 0.2);
  }

  @override
  Widget build(BuildContext context) {
    final letters = word.characters.toList();
    final step = blockSize * (1 - overlap);
    return Semantics(
      label: word,
      excludeSemantics: true,
      child: SizedBox(
        width: widthFor(letters.length, blockSize, overlap: overlap),
        height: blockSize * 1.25,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (var i = 0; i < letters.length; i++)
              Positioned(
                left: blockSize * 0.1 + i * step,
                top: i.isEven ? 0 : blockSize * 0.04,
                child: CandyBlock(
                  colors:
                      WoodColors.blockCycle[i % WoodColors.blockCycle.length],
                  size: blockSize,
                  letter: letters[i],
                  rotation: (i.isEven ? -1 : 1) * 0.07,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The app logo: "ALPHABET" in candy blocks riding on a dark wooden plaque
/// that carries "ADVENTURE" in golden lettering.
class WoodLogo extends StatelessWidget {
  const WoodLogo({
    super.key,
    this.top = 'ALPHABET',
    this.bottom = 'ADVENTURE',
    this.width = 320,
  });

  final String top;
  final String bottom;

  /// Overall width the logo is laid out for; it scales down to fit.
  final double width;

  @override
  Widget build(BuildContext context) {
    final blockSize = width / CandyBlockWord.widthFor(top.length, 1);
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        width: width,
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: EdgeInsets.only(top: blockSize * 0.78),
              child: WoodPanel(
                tone: WoodTone.dark,
                radius: width * 0.07,
                depth: width * 0.025,
                rimWidth: width * 0.012,
                padding: EdgeInsets.fromLTRB(
                  width * 0.04,
                  blockSize * 0.42,
                  width * 0.04,
                  width * 0.02,
                ),
                child: Center(
                  child: FittedBox(
                    child: WoodTitle(bottom, fontSize: width * 0.15),
                  ),
                ),
              ),
            ),
            CandyBlockWord(top, blockSize: blockSize),
          ],
        ),
      ),
    );
  }
}

/// A small recessed puzzle board with wooden blocks, used as a menu icon.
///
/// Each string in [pattern] is a row: `#` is a block, `*` is a gem, anything
/// else an empty cell.
class WoodBoardIcon extends StatelessWidget {
  const WoodBoardIcon({
    super.key,
    required this.pattern,
    this.size = 64,
    this.blockColors = WoodColors.lightWood,
    this.gemColor = const Color(0xFF3FC3F2),
  });

  final List<String> pattern;
  final double size;
  final WoodToneColors blockColors;
  final Color gemColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _BoardPainter(pattern, blockColors, gemColor),
    );
  }
}

class _BoardPainter extends CustomPainter {
  const _BoardPainter(this.pattern, this.blockColors, this.gemColor);

  final List<String> pattern;
  final WoodToneColors blockColors;
  final Color gemColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rows = pattern.length;
    final columns = pattern.fold<int>(0, (m, r) => r.length > m ? r.length : m);
    if (rows == 0 || columns == 0) return;
    final frame = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.width * 0.12),
    );
    canvas
      ..drawRRect(frame, Paint()..color = WoodColors.cellLine)
      ..drawRRect(
        frame.deflate(size.width * 0.04),
        Paint()..color = WoodColors.cellDark,
      );

    final inset = size.width * 0.07;
    final cell = (size.width - inset * 2) / columns;
    final line = Paint()
      ..color = WoodColors.cellLine.withValues(alpha: 0.7)
      ..strokeWidth = 1;
    for (var i = 1; i < columns; i++) {
      final x = inset + cell * i;
      canvas.drawLine(Offset(x, inset), Offset(x, size.height - inset), line);
    }
    for (var i = 1; i < rows; i++) {
      final y = inset + cell * i;
      canvas.drawLine(Offset(inset, y), Offset(size.width - inset, y), line);
    }

    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < pattern[r].length; c++) {
        final rect = Rect.fromLTWH(
          inset + c * cell,
          inset + r * cell,
          cell,
          cell,
        ).deflate(cell * 0.06);
        switch (pattern[r][c]) {
          case '#':
            final block = RRect.fromRectAndRadius(
              rect,
              Radius.circular(cell * 0.18),
            );
            canvas
              ..drawRRect(block, Paint()..color = blockColors.rim)
              ..drawRRect(
                block.deflate(cell * 0.1),
                Paint()
                  ..shader = LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [blockColors.top, blockColors.bottom],
                  ).createShader(rect),
              );
          case '*':
            final center = rect.center;
            final half = cell * 0.36;
            final gem = Path()
              ..moveTo(center.dx, center.dy - half)
              ..lineTo(center.dx + half, center.dy)
              ..lineTo(center.dx, center.dy + half)
              ..lineTo(center.dx - half, center.dy)
              ..close();
            canvas
              ..drawPath(gem, Paint()..color = gemColor)
              ..drawPath(
                gem,
                Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = cell * 0.06
                  ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.8),
              );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_BoardPainter oldDelegate) =>
      oldDelegate.pattern != pattern ||
      oldDelegate.blockColors != blockColors ||
      oldDelegate.gemColor != gemColor;
}
