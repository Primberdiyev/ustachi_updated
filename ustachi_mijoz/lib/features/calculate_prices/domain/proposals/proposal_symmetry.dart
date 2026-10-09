
library;

import 'dart:ui' show Rect;

bool paneLayoutIsMirrorSymmetric(List<Rect> panes, {double eps = 0.01}) {
  if (panes.isEmpty) return true;

  final pool = [...panes];
  for (final pane in panes) {
    final mirror = Rect.fromLTRB(
      1 - pane.right,
      pane.top,
      1 - pane.left,
      pane.bottom,
    );
    final match = pool.indexWhere(
      (c) =>
          (c.left - mirror.left).abs() <= eps &&
          (c.right - mirror.right).abs() <= eps &&
          (c.top - mirror.top).abs() <= eps &&
          (c.bottom - mirror.bottom).abs() <= eps,
    );
    if (match < 0) return false;
    pool.removeAt(match);
  }
  return pool.isEmpty;
}
