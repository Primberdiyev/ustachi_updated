
import 'package:flutter/material.dart';

class DetailedWindowFrameGeometry {
  const DetailedWindowFrameGeometry({
    required this.outerRect,
    required this.middleRect,
    required this.glassOutlineRect,
    required this.glassRect,
    required this.outerStrokeWidth,
    required this.innerStrokeWidth,
    required this.dividerStrokeWidth,
    required this.frameBandWidth,
    required this.innerBandInset,
    required this.glassInset,
  });

  factory DetailedWindowFrameGeometry.fromRect(
    Rect bounds, {
    double? referenceShortSide,
    double leftInsetScale = 1.0,
    double topInsetScale = 1.0,
    double rightInsetScale = 1.0,
    double bottomInsetScale = 1.0,
    bool skipOuterDeflateLeft = false,
    bool skipOuterDeflateTop = false,
    bool skipOuterDeflateRight = false,
    bool skipOuterDeflateBottom = false,
  }) {
    final shortSide = referenceShortSide ?? bounds.shortestSide;
    final outerStrokeWidth = (shortSide * 0.005).clamp(1.0, 1).toDouble();
    final innerStrokeWidth = (shortSide * 0.0045).clamp(1.0, 1.6).toDouble();
    final outerBandInset = (shortSide * 0.055).clamp(5.0, 16.0).toDouble();
    final innerBandInset = (shortSide * 0.020).clamp(3.0, 8.0).toDouble();
    final glassInset = (shortSide * 0.004).clamp(1.0, 2.5).toDouble();
    final dividerStrokeWidth = (shortSide * 0.045).clamp(3.0, 8.0).toDouble();
    final frameBandWidth = outerBandInset;

    final strokeHalf = outerStrokeWidth / 2;
    final outerRect = Rect.fromLTRB(
      bounds.left + (skipOuterDeflateLeft ? 0 : strokeHalf),
      bounds.top + (skipOuterDeflateTop ? 0 : strokeHalf),
      bounds.right - (skipOuterDeflateRight ? 0 : strokeHalf),
      bounds.bottom - (skipOuterDeflateBottom ? 0 : strokeHalf),
    );
    final usesUniformInset = leftInsetScale == 1.0 &&
        topInsetScale == 1.0 &&
        rightInsetScale == 1.0 &&
        bottomInsetScale == 1.0;
    final middleRect = usesUniformInset
        ? safeDeflate(outerRect, outerBandInset)
        : Rect.fromLTRB(
            outerRect.left + outerBandInset * leftInsetScale,
            outerRect.top + outerBandInset * topInsetScale,
            outerRect.right - outerBandInset * rightInsetScale,
            outerRect.bottom - outerBandInset * bottomInsetScale,
          );
    final glassOutlineRect = safeDeflate(middleRect, innerBandInset);
    final glassRect = safeDeflate(glassOutlineRect, glassInset);

    return DetailedWindowFrameGeometry(
      outerRect: outerRect,
      middleRect: middleRect,
      glassOutlineRect: glassOutlineRect,
      glassRect: glassRect,
      outerStrokeWidth: outerStrokeWidth,
      innerStrokeWidth: innerStrokeWidth,
      dividerStrokeWidth: dividerStrokeWidth,
      frameBandWidth: frameBandWidth,
      innerBandInset: innerBandInset,
      glassInset: glassInset,
    );
  }
  final Rect outerRect;
  final Rect middleRect;
  final Rect glassOutlineRect;
  final Rect glassRect;
  final double outerStrokeWidth;
  final double innerStrokeWidth;
  final double dividerStrokeWidth;
  final double frameBandWidth;
  final double innerBandInset;
  final double glassInset;
}

enum ZoneEdge { left, top, right, bottom }

void drawSegmentedLine(
  Canvas canvas,
  double x1,
  double y1,
  double x2,
  double y2,
  List<(double, double)> skipRanges, {
  required bool horizontal,
  required Paint paint,
}) {
  if (horizontal) {
    var cur = x1;
    for (final (start, end) in skipRanges) {
      if (start > cur) {
        canvas.drawLine(Offset(cur, y1), Offset(start, y1), paint);
      }
      if (end > cur) cur = end;
    }
    if (cur < x2) {
      canvas.drawLine(Offset(cur, y1), Offset(x2, y1), paint);
    }
  } else {
    var cur = y1;
    for (final (start, end) in skipRanges) {
      if (start > cur) {
        canvas.drawLine(Offset(x1, cur), Offset(x1, start), paint);
      }
      if (end > cur) cur = end;
    }
    if (cur < y2) {
      canvas.drawLine(Offset(x1, cur), Offset(x1, y2), paint);
    }
  }
}

Rect safeDeflate(Rect rect, double value) {
  final maxInset = (rect.shortestSide / 2) - 0.5;
  if (maxInset <= 0) return rect;
  return rect.deflate(value.clamp(0.0, maxInset).toDouble());
}
