import 'package:flutter/widgets.dart';

/// Centralized responsive spacing helpers for horizontal page padding.
class AppSpacing {
  /// Returns a responsive horizontal page padding based on screen width.
  /// Compact phones: 12, regular phones: 16, phablets: 20, tablets+: 24.
  static double pageH(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 800) return 24;
    if (w >= 480) return 20;
    if (w >= 360) return 16;
    return 12;
  }

  /// Convenience for symmetric horizontal padding with custom top/bottom.
  static EdgeInsets pageInsets({required BuildContext context, double top = 0, double bottom = 0}) {
    final h = pageH(context);
    return EdgeInsets.fromLTRB(h, top, h, bottom);
  }
}

