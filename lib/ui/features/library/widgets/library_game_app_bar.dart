import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:alphabet_adventure/data/services/audio_service.dart';
import 'package:alphabet_adventure/ui/core/wood/wood.dart';

/// The library HUD: a dark walnut plaque holding a pale-wood back button and
/// the tab bar.
class LibraryGameAppBar extends StatelessWidget {
  const LibraryGameAppBar({super.key, required this.widget});
  final Widget widget;

  @override
  Widget build(BuildContext context) {
    final audioService = context.read<AudioService>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: WoodPanel(
        tone: WoodTone.dark,
        radius: 26,
        depth: 7,
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: Row(
          children: [
            WoodIconButton(
              icon: Icons.arrow_back_rounded,
              tooltip: 'Back',
              size: 54,
              onPressed: () {
                audioService.playTap();
                context.pop();
              },
            ),
            const SizedBox(width: 8),
            Expanded(child: widget),
          ],
        ),
      ),
    );
  }
}
