
library;

import 'package:ustachi_hisob/src/design.dart';
import 'package:ustachi_hisob/src/series.dart';

typedef CellPath = List<int>;

bool wingIsBalcony(SeriesSpec spec, WingKind kind, {required bool wingBalcony, bool balconyDoor = false}) =>
    wingBalcony || (kind == WingKind.door && (balconyDoor || spec.material == ProfileMaterial.plastic));

class MmRect {
  const MmRect(this.l, this.t, this.r, this.b);

  final double l, t, r, b;

  double get width => r - l;
  double get height => b - t;
  double get cx => (l + r) / 2;
  double get cy => (t + b) / 2;

  bool contains(double x, double y) => x >= l && x <= r && y >= t && y <= b;

  @override
  String toString() => 'MmRect($l, $t, $r, $b)';
}

class CellBox {
  const CellBox({
    required this.path,
    required this.cell,
    required this.region,
    required this.originX,
    required this.originY,
    required this.light,
    required this.insideWing,
    this.sash,
    this.inner,
  });

  final CellPath path;
  final Cell cell;

  final MmRect region;

  final double originX, originY;

  final MmRect light;
  final bool insideWing;

  final MmRect? sash;

  final MmRect? inner;

  bool get isZone => cell is Zone;
  bool get isSplit => cell is Split;
  bool get isWing => cell is Wing;

  double sizeAlong(Axis axis) => axis == Axis.vertical ? region.width : region.height;
}

enum _Edge { frame, mullion, sashInner }

class _Box {
  const _Box(this.l, this.t, this.r, this.b, this.el, this.et, this.er, this.eb);

  final double l, t, r, b;
  final _Edge el, et, er, eb;
}

List<CellBox> layoutCells(FrameDesign design, SeriesSpec spec, {bool balconyDoor = false}) {
  final out = <CellBox>[];

  double deduct(_Edge e) => switch (e) {
        _Edge.frame => spec.frameWidth,
        _Edge.mullion => spec.mullionWidth / 2,
        _Edge.sashInner => 0,
      };

  MmRect lightOf(_Box b) => MmRect(
        b.l + deduct(b.el),
        b.t + deduct(b.et),
        b.r - deduct(b.er),
        b.b - deduct(b.eb),
      );

  void walk(Cell cell, _Box box, CellPath path, double ox, double oy, bool inWing) {
    final region = MmRect(box.l, box.t, box.r, box.b);
    final light = lightOf(box);
    switch (cell) {
      case Zone():
        out.add(CellBox(
          path: path,
          cell: cell,
          region: region,
          originX: ox,
          originY: oy,
          light: light,
          insideWing: inWing,
        ));

      case Split(:final axis, :final positionsMm, :final children):
        out.add(CellBox(
          path: path,
          cell: cell,
          region: region,
          originX: ox,
          originY: oy,
          light: light,
          insideWing: inWing,
        ));
        if (children.length != positionsMm.length + 1) {
          throw const DesignException("Impostlar soni bo'laklardan bitta kam bo'lishi kerak.");
        }
        final vertical = axis == Axis.vertical;
        final origin = vertical ? ox : oy;
        final axes = [for (final p in positionsMm) origin + p];
        final start = vertical ? box.l : box.t;
        final end = vertical ? box.r : box.b;
        var previous = start;
        for (final c in axes) {
          if (!(c > previous) || !(c < end)) {
            throw const DesignException("Impost joylari bo'lim ichida va o'sib borishi kerak.");
          }
          previous = c;
        }
        final bounds = [start, ...axes, end];
        for (var i = 0; i < children.length; i++) {
          final a = bounds[i];
          final z = bounds[i + 1];
          final low = i == 0 ? (vertical ? box.el : box.et) : _Edge.mullion;
          final high = i == children.length - 1 ? (vertical ? box.er : box.eb) : _Edge.mullion;
          final child = vertical
              ? _Box(a, box.t, z, box.b, low, box.et, high, box.eb)
              : _Box(box.l, a, box.r, z, box.el, low, box.er, high);
          final childOrigin = i == 0 ? origin : axes[i - 1];
          walk(
            children[i],
            child,
            [...path, i],
            vertical ? childOrigin : ox,
            vertical ? oy : childOrigin,
            inWing,
          );
        }

      case Wing(:final kind, :final content, balcony: final wingBalcony):
        final ov = spec.overlap;
        final balcony = wingIsBalcony(spec, kind, wingBalcony: wingBalcony, balconyDoor: balconyDoor);
        final face = balcony ? spec.balconySashWidth : spec.sashWidth;
        final inner = _Box(
          light.l - ov + face,
          light.t - ov + face,
          light.r + ov - face,
          light.b + ov - face,
          _Edge.sashInner,
          _Edge.sashInner,
          _Edge.sashInner,
          _Edge.sashInner,
        );
        out.add(CellBox(
          path: path,
          cell: cell,
          region: region,
          originX: ox,
          originY: oy,
          light: light,
          insideWing: inWing,
          sash: MmRect(light.l - ov, light.t - ov, light.r + ov, light.b + ov),
          inner: MmRect(inner.l, inner.t, inner.r, inner.b),
        ));
        if (inner.r - inner.l > 0 && inner.b - inner.t > 0) {
          walk(content, inner, [...path, 0], ox, oy, true);
        }
    }
  }

  walk(
    design.root,
    _Box(0, 0, design.widthMm, design.heightMm, _Edge.frame, _Edge.frame, _Edge.frame, _Edge.frame),
    const [],
    0,
    0,
    false,
  );
  return out;
}

CellBox? hitTest(List<CellBox> boxes, double x, double y) {
  CellBox? best;
  for (final b in boxes) {
    if (b.isSplit) continue;
    final area = b.isWing ? b.sash! : b.region;
    if (!area.contains(x, y)) continue;
    if (best == null || b.path.length >= best.path.length) best = b;
  }
  return best;
}
