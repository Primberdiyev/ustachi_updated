import 'dart:ui' show Offset, Rect;

import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_ui_models.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/window_zone_model.dart';

const proposalDoorLambriMm = 800;

const _minUpperMm = 300;

const _eps = 1e-6;

class _Cell {
  const _Cell(this.rect, this.isDoor, this.opening, this.layout);

  final Rect rect;
  final bool isDoor;
  final WindowOpeningType opening;
  final WindowLayoutPattern layout;

  bool get doorPart => isDoor && opening != WindowOpeningType.fixed;
}

Rect _childRect(Rect p, SplitDirection d, double offset, double ratio) => d ==
        SplitDirection.vertical
    ? Rect.fromLTWH(p.left + p.width * offset, p.top, p.width * ratio, p.height)
    : Rect.fromLTWH(
        p.left, p.top + p.height * offset, p.width, p.height * ratio);

void _collect(WindowZone z, Rect bounds, List<_Cell> out) {
  if (z.isLeaf) {
    out.add(_Cell(bounds, z.isDoor, z.openingType, z.layoutPattern));
    return;
  }
  var offset = 0.0;
  for (var i = 0; i < z.children!.length; i++) {
    final ratio = z.ratios![i];
    _collect(
        z.children![i], _childRect(bounds, z.direction!, offset, ratio), out);
    offset += ratio;
  }
}

List<_Cell> _cells(FramePreviewSpec spec) {
  final out = <_Cell>[];
  _collect(WindowZone.fromFramePreviewSpecWithDefaults(spec),
      const Rect.fromLTWH(0, 0, 1, 1), out);
  return out;
}

bool _near(double a, double b) => (a - b).abs() < 1e-4;

bool _isLambri(WindowLayoutPattern p) =>
    p == WindowLayoutPattern.verticalBars ||
    p == WindowLayoutPattern.horizontalBars ||
    p == WindowLayoutPattern.emptyPanel;

double _overlapX(Rect a, Rect b) =>
    (a.right < b.right ? a.right : b.right) -
    (a.left > b.left ? a.left : b.left);

class _LowerGroup {
  _LowerGroup(this.oldY);

  final double oldY;
  final lowers = <_Cell>[];
  final uppers = <_Cell>[];
}

_LowerGroup? _findLower(List<_Cell> cells, Set<int> done, int heightMm) {
  for (final lower in cells) {
    final r = lower.rect;
    final key = (r.top * heightMm).round();
    if (done.contains(key)) continue;

    final hasBelow = cells.any((c) =>
        !identical(c, lower) &&
        _near(c.rect.top, r.bottom) &&
        _overlapX(c.rect, r) > _eps);
    if (hasBelow) continue;

    _Cell? upper;
    for (final c in cells) {
      if (identical(c, lower)) continue;
      if (_near(c.rect.bottom, r.top) &&
          _overlapX(c.rect, r) >= r.width * 0.5 - _eps) {
        upper = c;
        break;
      }
    }
    if (upper == null) continue;
    if (!lower.doorPart && !upper.doorPart) continue;

    if (!_isLambri(lower.layout)) continue;

    var stackTop = upper.rect.top;
    var cursor = upper;
    while (true) {
      _Cell? above;
      for (final c in cells) {
        if (_near(c.rect.bottom, cursor.rect.top) &&
            _overlapX(c.rect, cursor.rect) >= cursor.rect.width * 0.5 - _eps &&
            c.doorPart) {
          above = c;
          break;
        }
      }
      if (above == null) break;
      stackTop = above.rect.top;
      cursor = above;
    }
    if (r.height > (r.bottom - stackTop) * 0.5 + _eps) continue;

    final group = _LowerGroup(r.top);
    for (final c in cells) {
      if (!_near(c.rect.top, r.top)) continue;
      final u = cells.where((o) =>
          _near(o.rect.bottom, c.rect.top) &&
          _overlapX(o.rect, c.rect) >= c.rect.width * 0.5 - _eps);
      if (u.isEmpty) continue;
      if (!c.doorPart && !u.first.doorPart) continue;
      if (!_isLambri(c.layout)) continue;
      if (cells.any((o) =>
          _near(o.rect.top, c.rect.bottom) && _overlapX(o.rect, c.rect) > _eps))
        continue;
      group.lowers.add(c);
      group.uppers.add(u.first);
    }
    return group;
  }
  return null;
}

FramePreviewSpec _copy(FramePreviewSpec s, List<FrameLine> lines,
        List<DefaultZoneSetup> setups) =>
    FramePreviewSpec(
      aspectRatio: s.aspectRatio,
      lines: lines,
      showFrame: s.showFrame,
      showGlass: s.showGlass,
      lineThicknessScale: s.lineThicknessScale,
      widthMm: s.widthMm,
      heightMm: s.heightMm,
      displayScale: s.displayScale,
      detailAspectRatioScale: s.detailAspectRatioScale,
      frameBandScale: s.frameBandScale,
      regions: s.regions,
      hardwareTweaks: s.hardwareTweaks,
      uniformFrameThickness: s.uniformFrameThickness,
      defaultOpeningCategory: s.defaultOpeningCategory,
      defaultOpeningIsDoor: s.defaultOpeningIsDoor,
      defaultOpeningSingleSash: s.defaultOpeningSingleSash,
      defaultZoneSetups: setups,
      archHeightFactor: s.archHeightFactor,
      plainDoorPosts: s.plainDoorPosts,
    );

FramePreviewSpec proposalDoorLowerLambri(FramePreviewSpec spec,
    {bool fixHeight = true}) {
  if (!fixHeight) return spec;
  final heightMm = spec.heightMm;
  if (heightMm == null || heightMm <= 0 || spec.lines.isEmpty) return spec;

  var current = spec;
  final done = <int>{};
  for (var iteration = 0; iteration < 8; iteration++) {
    final cells = _cells(current);
    final group = _findLower(cells, done, heightMm);
    if (group == null || group.lowers.isEmpty) break;

    final oldY = group.oldY;
    final bottom = group.lowers.first.rect.bottom;
    var newY = oldY;
    if (fixHeight) {
      final target = bottom - proposalDoorLambriMm / heightMm;
      final upperOk = group.uppers
          .every((u) => target - u.rect.top >= _minUpperMm / heightMm - _eps);
      if (upperOk && target > _eps) newY = target;
    }

    var spanL =
        group.lowers.map((c) => c.rect.left).reduce((a, b) => a < b ? a : b);
    var spanR =
        group.lowers.map((c) => c.rect.right).reduce((a, b) => a > b ? a : b);

    final lines = <FrameLine>[...current.lines];
    if (!_near(newY, oldY)) {
      for (var i = 0; i < lines.length; i++) {
        final l = lines[i];
        final horizontal = _near(l.startY, oldY) && _near(l.endY, oldY);
        if (!horizontal) continue;
        final lx0 = l.startX < l.endX ? l.startX : l.endX;
        final lx1 = l.startX < l.endX ? l.endX : l.startX;
        if (lx1 <= spanL + _eps || lx0 >= spanR - _eps) continue;
        lines[i] = FrameLine(l.startX, newY, l.endX, newY);
        if (lx0 < spanL) spanL = lx0;
        if (lx1 > spanR) spanR = lx1;
      }
      for (var i = 0; i < lines.length; i++) {
        final l = lines[i];
        final vertical = _near(l.startX, l.endX);
        if (!vertical) continue;
        if (l.startX < spanL - _eps || l.startX > spanR + _eps) continue;
        lines[i] = FrameLine(
          l.startX,
          _near(l.startY, oldY) ? newY : l.startY,
          l.endX,
          _near(l.endY, oldY) ? newY : l.endY,
        );
      }
    }

    double remapY(double y, Rect cell) {
      final top = _near(cell.top, oldY) ? newY : cell.top;
      final bot = _near(cell.bottom, oldY) ? newY : cell.bottom;
      final v = cell.height <= _eps ? 0.5 : (y - cell.top) / cell.height;
      return top + v * (bot - top);
    }

    final setups = <DefaultZoneSetup>[];
    for (final s in current.defaultZoneSetups) {
      var center = s.zoneCenter;
      if (!_near(newY, oldY)) {
        for (final c in cells) {
          final r = c.rect;
          final inside = center.dx > r.left - _eps &&
              center.dx < r.right + _eps &&
              center.dy > r.top - _eps &&
              center.dy < r.bottom + _eps;
          if (!inside) continue;
          if (r.left >= spanL - _eps && r.right <= spanR + _eps) {
            center = Offset(center.dx, remapY(center.dy, r));
          }
          break;
        }
      }
      setups.add(DefaultZoneSetup(
        zoneCenter: center,
        openingCategory: s.openingCategory,
        openingIsDoor: s.openingIsDoor,
        openingHasHandle: s.openingHasHandle,
        openingSingleSash: s.openingSingleSash,
        layoutCategory: s.layoutCategory,
      ));
    }

    done.add((newY * heightMm).round());
    done.add((oldY * heightMm).round());
    current = _copy(current, lines, setups);
  }
  return current;
}
