import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:alphabet_adventure/ui/core/app_fonts.dart';
import 'package:alphabet_adventure/ui/core/wood/wood_palette.dart';
import 'package:alphabet_adventure/ui/core/wood/wood_surface.dart';
import 'package:alphabet_adventure/ui/core/wood/wood_text.dart';

/// A glossy green callout pill ("1.04% completed"), with an optional pointer
/// tail underneath aiming at what it describes.
class WoodPill extends StatelessWidget {
  const WoodPill({
    super.key,
    required this.label,
    this.leading,
    this.tail = false,
    this.colors = const WoodToneColors(
      top: Color(0xFF4CC792),
      bottom: WoodColors.pill,
      rim: WoodColors.pillShade,
      bevel: Color(0xFF166843),
      highlight: Color(0xFFBDF2D8),
      ink: Color(0xFFFFFFFF),
    ),
    this.fontSize = 16,
  });

  final String label;
  final Widget? leading;
  final bool tail;
  final WoodToneColors colors;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final pill = WoodPanel(
      colors: colors,
      radius: 40,
      depth: 3,
      rimWidth: 2,
      padding: EdgeInsets.symmetric(
        horizontal: fontSize * 0.9,
        vertical: fontSize * 0.3,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[leading!, SizedBox(width: fontSize * 0.5)],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.fredoka(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: colors.ink,
              ),
            ),
          ),
        ],
      ),
    );
    if (!tail) return pill;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        pill,
        Transform.translate(
          offset: const Offset(0, -2),
          child: CustomPaint(
            size: Size(fontSize * 1.1, fontSize * 0.55),
            painter: _TailPainter(colors.bevel),
          ),
        ),
      ],
    );
  }
}

class _TailPainter extends CustomPainter {
  const _TailPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height)
        ..close(),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_TailPainter oldDelegate) => oldDelegate.color != color;
}

/// A recessed wooden track with a glossy fill, for progress and mastery.
class WoodProgressBar extends StatelessWidget {
  const WoodProgressBar({
    super.key,
    required this.value,
    this.height = 18,
    this.fill = WoodColors.candyGreen,
    this.label,
  });

  /// Progress in [0, 1]; changes animate.
  final double value;
  final double height;
  final WoodToneColors fill;

  /// Optional text centred on the bar.
  final String? label;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, progress, _) {
        return SizedBox(
          height: height,
          child: CustomPaint(
            painter: _ProgressPainter(progress, fill),
            child: label == null
                ? null
                : Center(
                    child: Text(
                      label!,
                      style: WoodText.onBackground(fontSize: height * 0.62),
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _ProgressPainter extends CustomPainter {
  const _ProgressPainter(this.progress, this.fill);

  final double progress;
  final WoodToneColors fill;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.height / 2);
    final track = RRect.fromRectAndRadius(Offset.zero & size, radius);
    canvas
      ..drawRRect(track, Paint()..color = WoodColors.cellLine)
      ..drawRRect(track.deflate(2), Paint()..color = WoodColors.cellDark);
    if (progress <= 0) return;
    final inner = track.deflate(3).outerRect;
    final width = math.max(inner.height, inner.width * progress);
    final bar = RRect.fromRectAndRadius(
      Rect.fromLTWH(inner.left, inner.top, width, inner.height),
      Radius.circular(inner.height / 2),
    );
    canvas
      ..drawRRect(
        bar,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [fill.top, fill.bottom],
          ).createShader(bar.outerRect),
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            bar.left + inner.height * 0.3,
            bar.top + inner.height * 0.15,
            math.max(0, bar.width - inner.height * 0.6),
            inner.height * 0.28,
          ),
          Radius.circular(inner.height),
        ),
        Paint()..color = fill.highlight.withValues(alpha: 0.6),
      );
  }

  @override
  bool shouldRepaint(_ProgressPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.fill != fill;
}

/// One tab of a [WoodBottomTabBar].
@immutable
class WoodTabItem {
  const WoodTabItem({required this.icon, required this.label});

  /// Usually an [Icon] or a small illustration.
  final Widget icon;
  final String label;
}

/// The wooden bottom tab bar: the selected tab is pale wood with its icon
/// popping up above the bar and its label shown; the others are dark wood.
class WoodBottomTabBar extends StatelessWidget {
  const WoodBottomTabBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.height = 70,
  });

  final List<WoodTabItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final double height;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF3A1706), width: 3)),
      ),
      height: height + bottomInset,
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: _WoodTab(
                item: items[i],
                selected: i == selectedIndex,
                height: height,
                bottomInset: bottomInset,
                showDivider: i > 0,
                onTap: () => onSelected(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _WoodTab extends StatelessWidget {
  const _WoodTab({
    required this.item,
    required this.selected,
    required this.height,
    required this.bottomInset,
    required this.showDivider,
    required this.onTap,
  });

  final WoodTabItem item;
  final bool selected;
  final double height;
  final double bottomInset;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = selected ? WoodColors.lightWood : WoodColors.darkWood;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [colors.top, colors.bottom],
            ),
            border: showDivider
                ? const Border(
                    left: BorderSide(color: Color(0xFF3A1706), width: 3),
                  )
                : null,
          ),
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutBack,
                top: selected ? -height * 0.42 : height * 0.18,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutBack,
                  scale: selected ? 1.25 : 1,
                  child: SizedBox(
                    height: height * 0.62,
                    child: FittedBox(child: item.icon),
                  ),
                ),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: selected ? 1 : 0,
                child: Padding(
                  padding: EdgeInsets.only(top: height * 0.34),
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: WoodText.heading(
                      fontSize: height * 0.3,
                      color: WoodColors.ink,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A light wooden dialog with a dark plaque header carrying a golden title.
class WoodDialog extends StatelessWidget {
  const WoodDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions = const [],
    this.onClose,
  });

  final String title;
  final Widget content;

  /// Usually [WoodButton]s; laid out in a wrapping row.
  final List<Widget> actions;

  /// Shows a close button in the corner when set.
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: WoodPanel(
                radius: 28,
                depth: 8,
                padding: const EdgeInsets.fromLTRB(20, 44, 20, 18),
                child: DefaultTextStyle.merge(
                  style: WoodText.body(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Flexible(child: SingleChildScrollView(child: content)),
                      if (actions.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 12,
                          runSpacing: 10,
                          children: actions,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 36,
              right: 36,
              child: Center(
                child: WoodPanel(
                  tone: WoodTone.dark,
                  radius: 18,
                  depth: 5,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 4,
                  ),
                  child: FittedBox(
                    child: WoodTitle(title, fontSize: 28, maxLines: 1),
                  ),
                ),
              ),
            ),
            if (onClose != null)
              Positioned(
                top: 18,
                right: -6,
                child: WoodIconButton(
                  icon: Icons.close_rounded,
                  tone: WoodTone.red,
                  size: 40,
                  tooltip: 'Close',
                  onPressed: onClose,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A screen header: optional back button, golden title on a dark plaque and
/// optional trailing actions, laid over the wooden background.
class WoodHeader extends StatelessWidget {
  const WoodHeader({
    super.key,
    required this.title,
    this.onBack,
    this.trailing = const [],
  });

  final String title;
  final VoidCallback? onBack;
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          if (onBack != null)
            WoodIconButton(
              icon: Icons.arrow_back_rounded,
              tooltip: 'Back',
              size: 48,
              onPressed: onBack,
            )
          else if (trailing.isNotEmpty)
            const SizedBox(width: 48),
          const SizedBox(width: 8),
          Expanded(
            child: Center(
              child: WoodPanel(
                tone: WoodTone.dark,
                radius: 18,
                depth: 5,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 2,
                ),
                child: FittedBox(
                  child: WoodTitle(title, fontSize: 26, maxLines: 1),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (trailing.isNotEmpty)
            Row(mainAxisSize: MainAxisSize.min, children: trailing)
          else if (onBack != null)
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}
