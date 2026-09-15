import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:alphabet_adventure/data/services/audio_service.dart';
import 'package:alphabet_adventure/ui/core/animations/bounce_animation.dart';
import 'package:alphabet_adventure/ui/core/wood/wood.dart';

/// A wooden segmented tab bar driven by a [TabController].
///
/// The tabs sit in a recessed dark-wood track; the selected tab is a raised
/// pale-wood slab that slides along with the page swipe, like the tabs of a
/// block-puzzle game.
class GameTabBar extends StatelessWidget {
  final TabController controller;

  const GameTabBar({super.key, required this.controller});

  static const List<String> _tabs = ['A-Z', 'a-z', 'Words'];

  static const double _height = 56;
  static const double _inset = 4;

  @override
  Widget build(BuildContext context) {
    final audioService = context.read<AudioService>();

    return SizedBox(
      height: _height,
      child: CustomPaint(
        painter: const _TrackPainter(),
        child: Padding(
          padding: const EdgeInsets.all(_inset),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final segmentWidth = constraints.maxWidth / _tabs.length;
              return AnimatedBuilder(
                animation: controller.animation ?? controller,
                builder: (context, _) {
                  // Follows the page swipe, so the slab glides between tabs.
                  final position =
                      (controller.animation?.value ??
                              controller.index.toDouble())
                          .clamp(0.0, _tabs.length - 1.0);

                  return Stack(
                    children: [
                      // The raised pale-wood slab under the selected label.
                      Positioned(
                        left: position * segmentWidth,
                        top: 0,
                        bottom: 0,
                        width: segmentWidth,
                        child: const IgnorePointer(
                          child: CustomPaint(
                            painter: WoodSurfacePainter(
                              colors: WoodColors.lightWood,
                              radius: 16,
                              depth: 5,
                              rimWidth: 2.5,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: List.generate(_tabs.length, (index) {
                          // 1 on the selected tab, fading to 0 one tab away.
                          final selection = (1 - (position - index).abs())
                              .clamp(0.0, 1.0);

                          return Expanded(
                            child: BounceAnimation(
                              onTap: () {
                                if (controller.index != index) {
                                  audioService.playTap();
                                  controller.animateTo(index);
                                }
                              },
                              child: Padding(
                                // Keeps the label centred on the slab's face,
                                // above its bevel.
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Center(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        _tabs[index],
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        style: WoodText.button(
                                          fontSize: 18 + 2 * selection,
                                          color: Color.lerp(
                                            WoodColors.darkWood.ink,
                                            WoodColors.ink,
                                            selection,
                                          )!,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

/// The recessed dark-wood groove the tabs sit in.
class _TrackPainter extends CustomPainter {
  const _TrackPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final track = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(20),
    );
    final inner = track.deflate(2);
    canvas
      ..drawRRect(track, Paint()..color = WoodColors.cellLine)
      ..drawRRect(inner, Paint()..color = WoodColors.cellDark)
      // An inner shadow along the top edge sells the groove's depth.
      ..save()
      ..clipRRect(inner)
      ..drawRect(
        Rect.fromLTWH(inner.left, inner.top, inner.width, 8),
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x66000000), Color(0x00000000)],
          ).createShader(Rect.fromLTWH(inner.left, inner.top, inner.width, 8)),
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_TrackPainter oldDelegate) => false;
}
