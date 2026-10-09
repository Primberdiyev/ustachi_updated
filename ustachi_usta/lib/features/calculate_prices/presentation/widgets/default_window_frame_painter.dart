import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_ui_models.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/schematic_frame_geometry.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/window_zone_model.dart';

enum RegionEdge { left, top, right, bottom }

List<Rect> computePanelRects(
  Rect container,
  List<FrameLine> dividers,
  Size size, {
  double dividerHalfWidth = 0.0,
  double minPanelSide = 1.0,
}) {
  final vCenters = <double>[];
  for (final line in dividers) {
    final isVertical = (line.startX - line.endX).abs() < 1e-6;
    if (!isVertical) continue;
    final x = line.startX * size.width;
    final y1 = line.startY * size.height;
    final y2 = line.endY * size.height;
    final spansContainer =
        y1 <= container.top + 0.5 && y2 >= container.bottom - 0.5;
    final insideContainer = x > container.left + dividerHalfWidth + 0.5 &&
        x < container.right - dividerHalfWidth - 0.5;
    if (spansContainer && insideContainer) vCenters.add(x);
  }

  if (vCenters.isNotEmpty) {
    vCenters.sort();
    final xSegs = splitInterval(container.left, container.right, vCenters,
        dividerHalfWidth, minPanelSide);
    final result = <Rect>[];
    for (final xs in xSegs) {
      final sub =
          Rect.fromLTRB(xs.start, container.top, xs.end, container.bottom);
      result.addAll(computePanelRects(
        sub,
        dividers,
        size,
        dividerHalfWidth: dividerHalfWidth,
        minPanelSide: minPanelSide,
      ));
    }
    return result;
  }

  final hCenters = <double>[];
  for (final line in dividers) {
    final isHorizontal = (line.startY - line.endY).abs() < 1e-6;
    if (!isHorizontal) continue;
    final y = line.startY * size.height;
    final x1 = line.startX * size.width;
    final x2 = line.endX * size.width;
    final spansContainer =
        x1 <= container.left + 0.5 && x2 >= container.right - 0.5;
    final insideContainer = y > container.top + dividerHalfWidth + 0.5 &&
        y < container.bottom - dividerHalfWidth - 0.5;
    if (spansContainer && insideContainer) hCenters.add(y);
  }

  if (hCenters.isNotEmpty) {
    hCenters.sort();
    final ySegs = splitInterval(container.top, container.bottom, hCenters,
        dividerHalfWidth, minPanelSide);
    final result = <Rect>[];
    for (final ys in ySegs) {
      final sub =
          Rect.fromLTRB(container.left, ys.start, container.right, ys.end);
      result.addAll(computePanelRects(
        sub,
        dividers,
        size,
        dividerHalfWidth: dividerHalfWidth,
        minPanelSide: minPanelSide,
      ));
    }
    return result;
  }

  return [container];
}

class DefaultWindowFramePainter extends CustomPainter {
  const DefaultWindowFramePainter({
    required this.dividerLines,
    required this.frameColor,
    required this.innerFrameColor,
    required this.glassColor,
    required this.dividerColor,
    required this.edgeColor,
    required this.showFrame,
    required this.showGlass,
    required this.layoutPatternRects,
    required this.layoutPatternColor,
    this.regions = const [],
    this.frameBandScale = 1.0,
  });

  final List<FrameLine> dividerLines;
  final Color frameColor;
  final Color innerFrameColor;
  final Color glassColor;
  final Color dividerColor;
  final Color edgeColor;
  final bool showFrame;
  final bool showGlass;
  final List<({Rect rect, WindowLayoutPattern pattern})> layoutPatternRects;
  final Color layoutPatternColor;
  final List<FrameRegion> regions;

  final double frameBandScale;

  @override
  void paint(Canvas canvas, Size size) {
    if (regions.isEmpty) {
      _paintRegion(canvas, size, Offset.zero & size, dividerLines, null);
      return;
    }
    for (final region in regions) {
      final regionRect = Rect.fromLTRB(
        region.left * size.width,
        region.top * size.height,
        region.right * size.width,
        region.bottom * size.height,
      );
      const e = 0.002;
      final regionLines = <FrameLine>[
        for (final l in dividerLines)
          if (((l.startX - l.endX).abs() < 1e-6 &&
                  l.startX > region.left + e &&
                  l.startX < region.right - e) ||
              ((l.startY - l.endY).abs() < 1e-6 &&
                  l.startY > region.top + e &&
                  l.startY < region.bottom - e))
            l,
      ];
      _paintRegion(canvas, size, regionRect, regionLines, region);
    }
  }

  ({bool left, bool top, bool right, bool bottom}) _adjacencyOf(
      FrameRegion region) {
    const epsilon = 1e-6;
    bool touchesLeft = false;
    bool touchesTop = false;
    bool touchesRight = false;
    bool touchesBottom = false;
    for (final other in regions) {
      if (identical(other, region)) continue;
      if ((other.right - region.left).abs() < epsilon &&
          other.bottom > region.top + epsilon &&
          other.top < region.bottom - epsilon) {
        touchesLeft = true;
      }
      if ((other.left - region.right).abs() < epsilon &&
          other.bottom > region.top + epsilon &&
          other.top < region.bottom - epsilon) {
        touchesRight = true;
      }
      if ((other.bottom - region.top).abs() < epsilon &&
          other.right > region.left + epsilon &&
          other.left < region.right - epsilon) {
        touchesTop = true;
      }
      if ((other.top - region.bottom).abs() < epsilon &&
          other.right > region.left + epsilon &&
          other.left < region.right - epsilon) {
        touchesBottom = true;
      }
    }
    return (
      left: touchesLeft,
      top: touchesTop,
      right: touchesRight,
      bottom: touchesBottom,
    );
  }

  void _paintOuterEdge(
    Canvas canvas,
    Rect r,
    RegionEdge edge,
    Paint paint,
    FrameRegion? region, {
    required bool skipFull,
    required bool hideOuter,
  }) {
    if (skipFull) return;
    final vertical = edge == RegionEdge.left || edge == RegionEdge.right;
    final fixed = switch (edge) {
      RegionEdge.left => r.left,
      RegionEdge.right => r.right,
      RegionEdge.top => r.top,
      RegionEdge.bottom => r.bottom,
    };
    final a = vertical ? r.top : r.left;
    final b = vertical ? r.bottom : r.right;
    if (!hideOuter || region == null) {
      _drawSeg(canvas, vertical, fixed, a, b, paint);
      return;
    }
    final normLo = vertical ? region.top : region.left;
    final normHi = vertical ? region.bottom : region.right;
    final span = normHi - normLo;
    double toPx(double n) => span <= 0 ? a : a + (n - normLo) / span * (b - a);
    final coveredPx = _coveredRangesOnEdge(region, edge)
        .map((c) => (start: toPx(c.start), end: toPx(c.end)))
        .toList()
      ..sort((x, y) => x.start.compareTo(y.start));
    var cursor = a;
    for (final c in coveredPx) {
      final cs = c.start.clamp(a, b);
      final ce = c.end.clamp(a, b);
      if (cs > cursor + 0.5) {
        _drawSeg(canvas, vertical, fixed, cursor, cs, paint);
      }
      if (ce > cursor) cursor = ce;
    }
    if (cursor < b - 0.5) _drawSeg(canvas, vertical, fixed, cursor, b, paint);
  }

  void _drawSeg(Canvas canvas, bool vertical, double fixed, double start,
      double end, Paint paint) {
    if (vertical) {
      canvas.drawLine(Offset(fixed, start), Offset(fixed, end), paint);
    } else {
      canvas.drawLine(Offset(start, fixed), Offset(end, fixed), paint);
    }
  }

  List<({double start, double end})> _coveredRangesOnEdge(
      FrameRegion region, RegionEdge edge) {
    const epsilon = 1e-6;
    final ranges = <({double start, double end})>[];
    for (final other in regions) {
      if (identical(other, region)) continue;
      late bool match;
      late double s;
      late double e;
      switch (edge) {
        case RegionEdge.left:
          match = (other.right - region.left).abs() < epsilon;
          s = math.max(other.top, region.top);
          e = math.min(other.bottom, region.bottom);
        case RegionEdge.right:
          match = (other.left - region.right).abs() < epsilon;
          s = math.max(other.top, region.top);
          e = math.min(other.bottom, region.bottom);
        case RegionEdge.top:
          match = (other.bottom - region.top).abs() < epsilon;
          s = math.max(other.left, region.left);
          e = math.min(other.right, region.right);
        case RegionEdge.bottom:
          match = (other.top - region.bottom).abs() < epsilon;
          s = math.max(other.left, region.left);
          e = math.min(other.right, region.right);
      }
      if (match && e > s + epsilon) ranges.add((start: s, end: e));
    }
    return ranges;
  }

  void _paintRegion(
    Canvas canvas,
    Size canvasSize,
    Rect bounds,
    List<FrameLine> innerDividers,
    FrameRegion? region,
  ) {
    final sharedLeft = region?.sharedLeft ?? false;
    final sharedTop = region?.sharedTop ?? false;
    final sharedRight = region?.sharedRight ?? false;
    final sharedBottom = region?.sharedBottom ?? false;
    final absorbedLeft = region?.absorbedLeft ?? false;
    final absorbedTop = region?.absorbedTop ?? false;
    final absorbedRight = region?.absorbedRight ?? false;
    final absorbedBottom = region?.absorbedBottom ?? false;
    final adjacency = region != null
        ? _adjacencyOf(region)
        : (left: false, top: false, right: false, bottom: false);
    double scaleFor(bool absorbed, bool shared) =>
        absorbed ? 0.0 : (shared ? 0.5 : 1.0);
    final geometry = DetailedWindowFrameGeometry.fromRect(
      bounds,
      referenceShortSide: canvasSize.shortestSide * frameBandScale,
      leftInsetScale: scaleFor(absorbedLeft, sharedLeft),
      topInsetScale: scaleFor(absorbedTop, sharedTop),
      rightInsetScale: scaleFor(absorbedRight, sharedRight),
      bottomInsetScale: scaleFor(absorbedBottom, sharedBottom),
      skipOuterDeflateLeft: adjacency.left || sharedLeft || absorbedLeft,
      skipOuterDeflateTop: adjacency.top || sharedTop || absorbedTop,
      skipOuterDeflateRight: adjacency.right || sharedRight || absorbedRight,
      skipOuterDeflateBottom:
          adjacency.bottom || sharedBottom || absorbedBottom,
    );
    final middleStrokeColor = edgeColor;
    final innerStrokeColor = edgeColor;

    final skipFullLeft = sharedLeft || absorbedLeft;
    final skipFullTop = sharedTop || absorbedTop;
    final skipFullRight = sharedRight || absorbedRight;
    final skipFullBottom = sharedBottom || absorbedBottom;
    final hideLeft = region?.hideOuterStrokeLeft ?? false;
    final hideTop = region?.hideOuterStrokeTop ?? false;
    final hideRight = region?.hideOuterStrokeRight ?? false;
    final hideBottom = region?.hideOuterStrokeBottom ?? false;

    if (showFrame) {
      canvas.drawRect(geometry.outerRect, Paint()..color = frameColor);
      canvas.drawRect(geometry.middleRect, Paint()..color = innerFrameColor);

      final hasSpecialEdge = skipFullLeft ||
          skipFullTop ||
          skipFullRight ||
          skipFullBottom ||
          hideLeft ||
          hideTop ||
          hideRight ||
          hideBottom;
      if (hasSpecialEdge) {
        final strokePaint = Paint()
          ..color = edgeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..strokeJoin = StrokeJoin.miter
          ..strokeMiterLimit = 8
          ..isAntiAlias = false;
        _paintOuterEdge(
            canvas, geometry.outerRect, RegionEdge.left, strokePaint, region,
            skipFull: skipFullLeft, hideOuter: hideLeft);
        _paintOuterEdge(
            canvas, geometry.outerRect, RegionEdge.top, strokePaint, region,
            skipFull: skipFullTop, hideOuter: hideTop);
        _paintOuterEdge(
            canvas, geometry.outerRect, RegionEdge.right, strokePaint, region,
            skipFull: skipFullRight, hideOuter: hideRight);
        _paintOuterEdge(
            canvas, geometry.outerRect, RegionEdge.bottom, strokePaint, region,
            skipFull: skipFullBottom, hideOuter: hideBottom);
      } else {
        final snappedOuterRect = Rect.fromLTRB(
          geometry.outerRect.left.floorToDouble() + 0.5,
          geometry.outerRect.top.floorToDouble() + 0.5,
          geometry.outerRect.right.ceilToDouble() - 0.5,
          geometry.outerRect.bottom.ceilToDouble() - 0.5,
        );
        canvas.drawRect(
          snappedOuterRect,
          Paint()
            ..color = edgeColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0
            ..strokeJoin = StrokeJoin.miter
            ..strokeMiterLimit = 8
            ..isAntiAlias = false,
        );
      }
    }

    final halfBand = geometry.frameBandWidth / 2;
    final panels = computePanelRects(
      geometry.middleRect,
      innerDividers,
      canvasSize,
      dividerHalfWidth: halfBand,
      minPanelSide: 2 * geometry.innerBandInset + 1,
    );

    final middleStrokePaint = Paint()
      ..color = middleStrokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = geometry.innerStrokeWidth;
    final panelBorderPaint = Paint()
      ..color = middleStrokeColor.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = geometry.innerStrokeWidth;
    final innerStrokePaint = Paint()
      ..color = innerStrokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = geometry.innerStrokeWidth * 0.75;
    final glassPaint = Paint()..color = glassColor;

    final hasAbsorbed =
        absorbedLeft || absorbedTop || absorbedRight || absorbedBottom;
    final useAbsorbedRendering = hasAbsorbed && panels.length == 1;

    for (final panel in panels) {
      if (showFrame) {
        if (useAbsorbedRendering) {
          canvas.drawRect(panel, panelBorderPaint);
          final panelGlassOutline =
              safeDeflate(panel, geometry.innerBandInset);
          canvas.drawRect(panelGlassOutline, innerStrokePaint);
          if (showGlass) {
            final panelGlass =
                safeDeflate(panelGlassOutline, geometry.glassInset);
            canvas.drawRect(panelGlass, glassPaint);
          }
        } else {
          canvas.drawRect(panel, panelBorderPaint);
          final panelGlassOutline =
              safeDeflate(panel, geometry.innerBandInset);
          canvas.drawRect(panelGlassOutline, innerStrokePaint);
          if (showGlass) {
            final panelGlass =
                safeDeflate(panelGlassOutline, geometry.glassInset);
            canvas.drawRect(panelGlass, glassPaint);
          }
        }
      } else if (showGlass) {
        final panelGlass = safeDeflate(
          safeDeflate(panel, geometry.innerBandInset),
          geometry.glassInset,
        );
        canvas.drawRect(panelGlass, glassPaint);
      }
    }

    if (innerDividers.isNotEmpty && showFrame) {
      drawDividers(
        canvas: canvas,
        size: canvasSize,
        clipRect: geometry.middleRect,
        dividerLines: innerDividers,
        halfBand: halfBand,
        fillPaint: Paint()..color = dividerColor,
        strokePaint: middleStrokePaint,
      );
    }

    if (regions.isEmpty && layoutPatternRects.isNotEmpty) {
      _drawLayoutPatterns(
        canvas: canvas,
        size: canvasSize,
        panels: panels,
        layoutPatternRects: layoutPatternRects,
        innerInset: geometry.innerBandInset,
        glassInset: geometry.glassInset,
        color: layoutPatternColor,
        glassColor: glassColor,
        frameColor: frameColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DefaultWindowFramePainter oldDelegate) {
    return !listEquals(oldDelegate.dividerLines, dividerLines) ||
        oldDelegate.frameColor != frameColor ||
        oldDelegate.innerFrameColor != innerFrameColor ||
        oldDelegate.glassColor != glassColor ||
        oldDelegate.dividerColor != dividerColor ||
        oldDelegate.edgeColor != edgeColor ||
        oldDelegate.showFrame != showFrame ||
        oldDelegate.showGlass != showGlass ||
        !listEquals(oldDelegate.layoutPatternRects, layoutPatternRects) ||
        oldDelegate.layoutPatternColor != layoutPatternColor ||
        oldDelegate.frameBandScale != frameBandScale ||
        !listEquals(oldDelegate.regions, regions);
  }
}

void _drawLayoutPatterns({
  required Canvas canvas,
  required Size size,
  required List<Rect> panels,
  required List<({Rect rect, WindowLayoutPattern pattern})> layoutPatternRects,
  required double innerInset,
  required double glassInset,
  required Color color,
  required Color glassColor,
  required Color frameColor,
}) {
  for (final panel in panels) {
    final centerNorm = Offset(
      panel.center.dx / size.width,
      panel.center.dy / size.height,
    );
    WindowLayoutPattern? pattern;
    for (final info in layoutPatternRects) {
      if (info.rect.contains(centerNorm)) {
        pattern = info.pattern;
        break;
      }
    }
    if (pattern == null || pattern == WindowLayoutPattern.none) continue;

    final inner = safeDeflate(safeDeflate(panel, innerInset), glassInset);
    if (inner.width <= 1 || inner.height <= 1) continue;

    drawLayoutPatternInRect(
      canvas: canvas,
      rect: inner,
      pattern: pattern,
      color: color,
      glassColor: glassColor,
      frameColor: frameColor,
    );
  }
}

void drawLayoutPatternInRect({
  required Canvas canvas,
  required Rect rect,
  required WindowLayoutPattern pattern,
  required Color color,
  required Color glassColor,
  required Color frameColor,
}) {
  switch (pattern) {
    case WindowLayoutPattern.none:
      return;
    case WindowLayoutPattern.verticalBars:
      canvas.drawRect(rect, Paint()..color = frameColor);
      final count = (rect.width / 10).round().clamp(8, 60);
      final stroke = Paint()
        ..color = color
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke;
      for (var i = 1; i < count; i++) {
        final x = rect.left + rect.width * i / count;
        canvas.drawLine(
          Offset(x, rect.top),
          Offset(x, rect.bottom),
          stroke,
        );
      }
      break;
    case WindowLayoutPattern.horizontalBars:
      canvas.drawRect(rect, Paint()..color = frameColor);
      final count = (rect.height / 10).round().clamp(8, 60);
      final stroke = Paint()
        ..color = color
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke;
      for (var i = 1; i < count; i++) {
        final y = rect.top + rect.height * i / count;
        canvas.drawLine(
          Offset(rect.left, y),
          Offset(rect.right, y),
          stroke,
        );
      }
      break;
    case WindowLayoutPattern.emptyPanel:
      canvas.drawRect(rect, Paint()..color = frameColor);
      break;
    case WindowLayoutPattern.glassPanel:
      canvas.drawRect(rect, Paint()..color = const Color(0xFFFFFFFF));
      canvas.drawRect(rect, Paint()..color = glassColor);
      break;
    case WindowLayoutPattern.meshGrid:
      canvas.drawRect(rect, Paint()..color = const Color(0xFFFFFFFF));
      canvas.drawRect(rect, Paint()..color = glassColor);
      final cellSize = math.min(rect.width, rect.height) / 28;
      if (cellSize <= 0.5) break;
      final stroke = Paint()
        ..color = color
        ..strokeWidth = 0.7
        ..style = PaintingStyle.stroke;
      for (var x = rect.left + cellSize; x < rect.right; x += cellSize) {
        canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), stroke);
      }
      for (var y = rect.top + cellSize; y < rect.bottom; y += cellSize) {
        canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), stroke);
      }
      break;
  }
}

List<({double start, double end})> splitInterval(
  double low,
  double high,
  List<double> centers,
  double halfWidth,
  double minSide,
) {
  final sorted = [...centers]..sort();
  final segments = <({double start, double end})>[];
  var start = low;
  for (final c in sorted) {
    final end = c - halfWidth;
    if (end - start >= minSide) {
      segments.add((start: start, end: end));
    }
    start = c + halfWidth;
  }
  if (high - start >= minSide) {
    segments.add((start: start, end: high));
  }
  return segments;
}

void drawDividers({
  required Canvas canvas,
  required Size size,
  required Rect clipRect,
  required List<FrameLine> dividerLines,
  required double halfBand,
  required Paint fillPaint,
  required Paint strokePaint,
}) {
  if (dividerLines.isEmpty) return;

  final verticalRects = <Rect>[];
  final horizontalRects = <Rect>[];

  for (final line in dividerLines) {
    final isVertical = (line.startX - line.endX).abs() < 1e-6;
    final isHorizontal = (line.startY - line.endY).abs() < 1e-6;

    if (isVertical) {
      final x = size.width * line.startX;
      final top = math.max(clipRect.top, size.height * line.startY);
      final bottom = math.min(clipRect.bottom, size.height * line.endY);
      if (bottom > top) {
        verticalRects
            .add(Rect.fromLTRB(x - halfBand, top, x + halfBand, bottom));
      }
    } else if (isHorizontal) {
      final y = size.height * line.startY;
      final left = math.max(clipRect.left, size.width * line.startX);
      final right = math.min(clipRect.right, size.width * line.endX);
      if (right > left) {
        horizontalRects
            .add(Rect.fromLTRB(left, y - halfBand, right, y + halfBand));
      }
    }
  }

  canvas.save();
  canvas.clipRect(clipRect);

  for (final r in verticalRects) {
    canvas.drawRect(r, fillPaint);
  }
  for (final r in horizontalRects) {
    canvas.drawRect(r, fillPaint);
  }

  const eps = 0.5;

  for (final r in verticalRects) {
    final skipLeft = <(double, double)>[];
    final skipRight = <(double, double)>[];
    for (final h in horizontalRects) {
      if (h.top >= r.bottom || h.bottom <= r.top) continue;
      final range = (math.max(h.top, r.top), math.min(h.bottom, r.bottom));
      if (r.left > h.left + eps && r.left < h.right - eps) skipLeft.add(range);
      if (r.right > h.left + eps && r.right < h.right - eps) {
        skipRight.add(range);
      }
    }
    skipLeft.sort((a, b) => a.$1.compareTo(b.$1));
    skipRight.sort((a, b) => a.$1.compareTo(b.$1));
    drawSegmentedLine(canvas, r.left, r.top, r.left, r.bottom, skipLeft,
        horizontal: false, paint: strokePaint);
    drawSegmentedLine(canvas, r.right, r.top, r.right, r.bottom, skipRight,
        horizontal: false, paint: strokePaint);
  }

  for (final r in horizontalRects) {
    final skipTop = <(double, double)>[];
    final skipBottom = <(double, double)>[];
    for (final v in verticalRects) {
      if (v.left >= r.right || v.right <= r.left) continue;
      final range = (math.max(v.left, r.left), math.min(v.right, r.right));
      if (r.top > v.top + eps && r.top < v.bottom - eps) skipTop.add(range);
      if (r.bottom > v.top + eps && r.bottom < v.bottom - eps) {
        skipBottom.add(range);
      }
    }
    skipTop.sort((a, b) => a.$1.compareTo(b.$1));
    skipBottom.sort((a, b) => a.$1.compareTo(b.$1));
    drawSegmentedLine(canvas, r.left, r.top, r.right, r.top, skipTop,
        horizontal: true, paint: strokePaint);
    drawSegmentedLine(canvas, r.left, r.bottom, r.right, r.bottom, skipBottom,
        horizontal: true, paint: strokePaint);
  }

  canvas.restore();
}
