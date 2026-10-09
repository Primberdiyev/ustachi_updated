import 'dart:ui' show Offset, Rect;

import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_ui_models.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/window_zone_model.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/rom_design.dart';

class ProposalRomDesign {
  const ProposalRomDesign({required this.frames});

  final List<RomFrameDesign> frames;
}

const _eps = 1e-6;

double _mm(double v) => (v * 100).roundToDouble() / 100;

ProposalRomDesign proposalRomDesign(FramePreviewSpec spec, int widthMm, int heightMm) {
  final zone = WindowZone.fromFramePreviewSpecWithDefaults(spec);
  final w = widthMm.toDouble();
  final h = heightMm.toDouble();

  final leaves = <_Leaf>[];
  _collectLeaves(zone, const Rect.fromLTWH(0, 0, 1, 1), leaves);

  final openings = [
    for (final l in leaves)
      if (l.opening != WindowOpeningType.fixed) _Sash(l.rect, l.opening, l.isDoor, l.hasHandle),
  ];
  final sashes = zone.hasAnyDirectlyAppliedOpening() ? openings : _groupSashes(openings);

  final regions = spec.regions.isEmpty
      ? const [Rect.fromLTWH(0, 0, 1, 1)]
      : [for (final r in spec.regions) Rect.fromLTRB(r.left, r.top, r.right, r.bottom)];

  final builder = _TreeBuilder(zone, w, h);
  final frames = <RomFrameDesign>[];
  for (final region in regions) {
    final regionLeaves = [for (final l in leaves) if (_inside(region, l.rect.center)) l];
    if (regionLeaves.isEmpty) {
      throw const RomDesignException("Rom bo'lagida zona topilmadi.");
    }
    final regionSashes = [
      for (final s in sashes)
        if (_inside(region, s.rect.center)) _Sash(s.rect.intersect(region), s.type, s.isDoor, s.hasHandle),
    ];
    final root = builder.build(region, regionLeaves, regionSashes, insideWing: false);
    frames.add(RomFrameDesign(
      widthMm: _mm(region.width * w),
      heightMm: _mm(region.height * h),
      root: root,
      archRiseMm: spec.regions.isEmpty && spec.archHeightFactor > 0
          ? _mm(spec.archHeightFactor * h)
          : 0,
    ));
  }

  return ProposalRomDesign(frames: frames);
}

class _Leaf {
  const _Leaf(this.rect, this.opening, this.isDoor, this.layout, this.hasHandle);

  final Rect rect;
  final WindowOpeningType opening;
  final bool isDoor;
  final WindowLayoutPattern layout;
  final bool hasHandle;
}

class _Sash {
  const _Sash(this.rect, this.type, this.isDoor, this.hasHandle);

  final Rect rect;
  final WindowOpeningType type;
  final bool isDoor;
  final bool hasHandle;
}

bool _inside(Rect r, Offset p) =>
    p.dx > r.left - _eps && p.dx < r.right + _eps && p.dy > r.top - _eps && p.dy < r.bottom + _eps;

bool _same(Rect a, Rect b) =>
    (a.left - b.left).abs() < _eps &&
    (a.top - b.top).abs() < _eps &&
    (a.right - b.right).abs() < _eps &&
    (a.bottom - b.bottom).abs() < _eps;

Rect _childRect(Rect parent, SplitDirection dir, double offset, double ratio) =>
    dir == SplitDirection.vertical
        ? Rect.fromLTWH(parent.left + parent.width * offset, parent.top, parent.width * ratio,
            parent.height)
        : Rect.fromLTWH(parent.left, parent.top + parent.height * offset, parent.width,
            parent.height * ratio);

void _collectLeaves(WindowZone z, Rect bounds, List<_Leaf> out) {
  if (z.isLeaf) {
    out.add(_Leaf(bounds, z.openingType, z.isDoor, z.layoutPattern, z.hasHandle));
    return;
  }
  var offset = 0.0;
  for (var i = 0; i < z.children!.length; i++) {
    final ratio = z.ratios![i];
    _collectLeaves(z.children![i], _childRect(bounds, z.direction!, offset, ratio), out);
    offset += ratio;
  }
}

List<_Sash> _groupSashes(List<_Sash> parts) {
  final parent = List<int>.generate(parts.length, (i) => i);
  int find(int x) {
    while (parent[x] != x) {
      x = parent[x] = parent[parent[x]];
    }
    return x;
  }

  for (var i = 0; i < parts.length; i++) {
    for (var j = i + 1; j < parts.length; j++) {
      final a = parts[i];
      final b = parts[j];
      if (a.type != b.type || a.isDoor != b.isDoor) continue;
      final overlapX = (a.rect.right < b.rect.right ? a.rect.right : b.rect.right) -
          (a.rect.left > b.rect.left ? a.rect.left : b.rect.left);
      final touchY = (a.rect.bottom - b.rect.top).abs() < _eps ||
          (b.rect.bottom - a.rect.top).abs() < _eps;
      if (overlapX > _eps && touchY) parent[find(i)] = find(j);
    }
  }

  final groups = <int, _Sash>{};
  for (var i = 0; i < parts.length; i++) {
    final root = find(i);
    final g = groups[root];
    groups[root] = g == null
        ? parts[i]
        : _Sash(g.rect.expandToInclude(parts[i].rect), g.type, g.isDoor, g.hasHandle && parts[i].hasHandle);
  }
  return groups.values.toList();
}

class _TreeBuilder {
  _TreeBuilder(this.zone, this.widthMm, this.heightMm);

  final WindowZone zone;
  final double widthMm;
  final double heightMm;

  RomCell build(Rect cell, List<_Leaf> leaves, List<_Sash> sashes, {required bool insideWing}) {
    if (!insideWing) {
      for (final s in sashes) {
        if (_same(s.rect, cell)) {
          final rest = [for (final o in sashes) if (!identical(o, s)) o];
          return RomWing(_function(s), build(cell, leaves, rest, insideWing: true), _handleSide(s.type), s.hasHandle);
        }
      }
    }

    if (leaves.length == 1) return RomZone(_fill(leaves.single.layout));

    final vertical = _cuts(cell, leaves, sashes, RomAxis.vertical);
    final horizontal = _cuts(cell, leaves, sashes, RomAxis.horizontal);
    if (vertical.isEmpty && horizontal.isEmpty) {
      throw const RomDesignException("Chizmani impostlar bilan bo'lib bo'lmadi.");
    }
    final axis = vertical.isEmpty
        ? RomAxis.horizontal
        : horizontal.isEmpty
            ? RomAxis.vertical
            : _painterAxis(cell) ?? RomAxis.vertical;
    final cuts = axis == RomAxis.vertical ? vertical : horizontal;

    final bounds = [
      axis == RomAxis.vertical ? cell.left : cell.top,
      ...cuts,
      axis == RomAxis.vertical ? cell.right : cell.bottom,
    ];
    final children = <RomCell>[];
    for (var i = 0; i + 1 < bounds.length; i++) {
      final part = axis == RomAxis.vertical
          ? Rect.fromLTRB(bounds[i], cell.top, bounds[i + 1], cell.bottom)
          : Rect.fromLTRB(cell.left, bounds[i], cell.right, bounds[i + 1]);
      children.add(build(
        part,
        [for (final l in leaves) if (_inside(part, l.rect.center)) l],
        [for (final s in sashes) if (_inside(part, s.rect.center)) s],
        insideWing: insideWing,
      ));
    }
    final start = axis == RomAxis.vertical ? cell.left : cell.top;
    final scale = axis == RomAxis.vertical ? widthMm : heightMm;
    return RomSplit(
      axis: axis,
      positionsMm: [for (final c in cuts) _mm((c - start) * scale)],
      children: children,
      fromCell: true,
    );
  }

  List<double> _cuts(Rect cell, List<_Leaf> leaves, List<_Sash> sashes, RomAxis axis) {
    final vertical = axis == RomAxis.vertical;
    final lo = vertical ? cell.left : cell.top;
    final hi = vertical ? cell.right : cell.bottom;
    bool crosses(Rect r, double v) =>
        vertical ? r.left < v - _eps && r.right > v + _eps : r.top < v - _eps && r.bottom > v + _eps;

    final out = <double>[];
    for (final l in leaves) {
      for (final v in vertical ? [l.rect.left, l.rect.right] : [l.rect.top, l.rect.bottom]) {
        if (v <= lo + _eps || v >= hi - _eps) continue;
        if (out.any((o) => (o - v).abs() < _eps)) continue;
        if (leaves.any((o) => crosses(o.rect, v))) continue;
        if (sashes.any((s) => !_same(s.rect, cell) && crosses(s.rect, v))) continue;
        out.add(v);
      }
    }
    return out..sort();
  }

  RomAxis? _painterAxis(Rect cell) {
    RomAxis? find(WindowZone z, Rect bounds) {
      if (z.isLeaf) return null;
      if (_same(bounds, cell)) {
        return z.direction == SplitDirection.vertical ? RomAxis.vertical : RomAxis.horizontal;
      }
      var offset = 0.0;
      for (var i = 0; i < z.children!.length; i++) {
        final ratio = z.ratios![i];
        final child = _childRect(bounds, z.direction!, offset, ratio);
        offset += ratio;
        if (_inside(child, cell.topLeft) && _inside(child, cell.bottomRight)) {
          return find(z.children![i], child);
        }
      }
      return null;
    }

    return find(zone, const Rect.fromLTWH(0, 0, 1, 1));
  }

  static RomWingFunction _function(_Sash s) {
    if (s.isDoor) return RomWingFunction.door;
    return switch (s.type) {
      WindowOpeningType.tilt || WindowOpeningType.tiltReverse => RomWingFunction.tilt,
      WindowOpeningType.openRightTilt || WindowOpeningType.openLeftTilt => RomWingFunction.tiltTurn,
      _ => RomWingFunction.turn,
    };
  }

  static RomHandleSide _handleSide(WindowOpeningType t) => switch (t) {
        WindowOpeningType.openLeft || WindowOpeningType.openLeftTilt => RomHandleSide.left,
        WindowOpeningType.tilt => RomHandleSide.top,
        WindowOpeningType.tiltReverse => RomHandleSide.bottom,
        _ => RomHandleSide.right,
      };

  static RomFill _fill(WindowLayoutPattern p) => switch (p) {
        WindowLayoutPattern.verticalBars => RomFill.lambri,
        WindowLayoutPattern.horizontalBars => RomFill.lambriHorizontal,
        WindowLayoutPattern.emptyPanel => RomFill.panel,
        _ => RomFill.glass,
      };
}
