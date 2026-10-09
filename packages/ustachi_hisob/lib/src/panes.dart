
library;

import 'package:ustachi_hisob/src/design.dart';

class PaneRect {
  const PaneRect({
    required this.l,
    required this.t,
    required this.r,
    required this.b,
    required this.cell,
  });

  final double l;
  final double t;
  final double r;
  final double b;

  final Cell cell;

  double get centerX => (l + r) / 2;
  double get centerY => (t + b) / 2;
}

const _eps = 1e-6;

Cell cellFromPanes(
  List<PaneRect> panes, {
  required double widthMm,
  required double heightMm,
}) {
  if (panes.isEmpty) throw const DesignException("Chizmada bo'lak yo'q.");
  return _build(panes, 0, 0, 1, 1, widthMm, heightMm);
}

Cell _build(List<PaneRect> panes, double l, double t, double r, double b, double w, double h) {
  if (panes.length == 1) return panes.single.cell;

  List<double> cuts(bool vertical) {
    final lo = vertical ? l : t;
    final hi = vertical ? r : b;
    final out = <double>{};
    for (final p in panes) {
      for (final v in vertical ? [p.l, p.r] : [p.t, p.b]) {
        if (v <= lo + _eps || v >= hi - _eps) continue;
        final crosses = panes.any((q) => vertical ? q.l < v - _eps && q.r > v + _eps : q.t < v - _eps && q.b > v + _eps);
        if (!crosses) out.add((v * 1e6).round() / 1e6);
      }
    }
    return out.toList()..sort();
  }

  final vCuts = cuts(true);
  final hCuts = cuts(false);
  if (vCuts.isEmpty && hCuts.isEmpty) {
    throw const DesignException("Bo'laklarni impostlar bilan ajratib bo'lmadi.");
  }
  final vertical = vCuts.isNotEmpty;
  final chosen = vertical ? vCuts : hCuts;
  final lo = vertical ? l : t;
  final hi = vertical ? r : b;
  final bounds = [lo, ...chosen, hi];
  final children = <Cell>[];
  for (var i = 0; i + 1 < bounds.length; i++) {
    final a = bounds[i];
    final z = bounds[i + 1];
    final inside = [
      for (final p in panes)
        if ((vertical ? p.centerX : p.centerY) > a && (vertical ? p.centerX : p.centerY) < z) p,
    ];
    children.add(vertical ? _build(inside, a, t, z, b, w, h) : _build(inside, l, a, r, z, w, h));
  }
  final scale = vertical ? w : h;
  return Split(
    axis: vertical ? Axis.vertical : Axis.horizontal,
    positionsMm: [for (final c in chosen) (c - lo) * scale],
    children: children,
  );
}
