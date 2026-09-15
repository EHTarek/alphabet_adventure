import 'package:flutter/material.dart';

/// Page transition for an app whose pages are transparent over one shared,
/// app-wide background (the blossom parallax scene).
///
/// The built-in transitions either paint an opaque surface behind the pages
/// while they animate (zoom, fade-forwards) or slide one transparent page over
/// another (Cupertino), which would hide or muddle the shared background.
/// Instead the incoming page fades in while rising slightly and the outgoing
/// page fades out, so the background stays visible and steady throughout.
class SceneFadePageTransitionsBuilder extends PageTransitionsBuilder {
  const SceneFadePageTransitionsBuilder();

  static const Offset _rise = Offset(0, 0.02);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 320);

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final enter = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    // The page underneath clears out during the first part of the push, so
    // the two pages never stack as a double exposure.
    final exit = CurvedAnimation(
      parent: secondaryAnimation,
      curve: const Interval(0, 0.45, curve: Curves.easeOut),
      reverseCurve: const Interval(0.55, 1, curve: Curves.easeIn),
    );

    return FadeTransition(
      opacity: ReverseAnimation(exit),
      child: FadeTransition(
        opacity: enter,
        child: SlideTransition(
          position: Tween(begin: _rise, end: Offset.zero).animate(enter),
          child: child,
        ),
      ),
    );
  }
}
