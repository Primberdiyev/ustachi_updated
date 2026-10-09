import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/schematic_frame_geometry.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/window_schematic_painter.dart';

class ArchOverlayPainter extends CustomPainter {
  const ArchOverlayPainter({
    required this.archHeightFactor,
    required this.hasTransom,
    required this.isPlainArch,
    required this.frameColor,
    required this.glassColor,
    required this.edgeColor,
    required this.showFrame,
    required this.showGlass,
    required this.frameBandScale,
    this.mullionXs = const [],
    this.capOpening = false,
    this.widthMm = 0,
    this.heightMm = 0,
  });

  final double archHeightFactor;
  final bool hasTransom;

  final bool capOpening;
  final double widthMm;
  final double heightMm;

  final List<double> mullionXs;

  final bool isPlainArch;
  final Color frameColor;
  final Color glassColor;
  final Color edgeColor;
  final bool showFrame;
  final bool showGlass;
  final double frameBandScale;

  Path _lune(double left, double right, double springY, double topY) {
    final rx = (right - left) / 2;
    final archHeight = springY - topY;
    final p = Path()..moveTo(left, springY);
    if (archHeight > 0.1 && rx > 0.1) {
      p.arcToPoint(
        Offset(right, springY),
        radius: Radius.elliptical(rx, archHeight),
        clockwise: true,
      );
    } else {
      p.lineTo(right, springY);
    }
    p.close();
    return p;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final geometry = DetailedWindowFrameGeometry.fromRect(
      Offset.zero & size,
      referenceShortSide: size.shortestSide * frameBandScale,
    );
    final halfBand = geometry.frameBandWidth / 2;
    final glassTotalInset =
        geometry.frameBandWidth + geometry.innerBandInset + geometry.glassInset;

    final w = size.width;
    final springY = size.height * archHeightFactor;
    const topY = 0.0;
    final arcSpringY = isPlainArch ? springY : (springY - halfBand);
    final glassSpringY =
        isPlainArch ? arcSpringY : (arcSpringY - geometry.innerBandInset);

    if (showFrame) {
      canvas.drawPath(
          _lune(0, w, arcSpringY, topY), Paint()..color = frameColor);
    }

    final capSash = capOpening && widthMm > 0 && heightMm > 0;
    final s = capSash ? math.min(w / widthMm, size.height / heightMm) : 0.0;
    final frameMmPx = capSash ? SchematicMm.frameFor(widthMm, heightMm) * s : 0.0;
    final sashOuterPx = frameMmPx; 
    final glassEdgePx = frameMmPx + SchematicMm.sash * s; 
    final glassFillPx = glassEdgePx + SchematicMm.glassInset * s;

    final glassInsetEff = capSash ? glassFillPx : glassTotalInset;
    final glassLeft = glassInsetEff;
    final glassRight = w - glassInsetEff;

    final glassPath =
        _lune(glassLeft, glassRight, glassSpringY, glassInsetEff);

    if (showGlass) {
      canvas.drawPath(glassPath, Paint()..color = glassColor);
    }

    if (!showFrame) return;

    void strokeArc(double inset, double sY, Paint paint) {
      final rx = w / 2 - inset;
      final ry = sY - inset;
      if (rx <= 0.1 || ry <= 0.1) return;
      canvas.drawPath(
        Path()
          ..moveTo(inset, sY)
          ..arcToPoint(
            Offset(w - inset, sY),
            radius: Radius.elliptical(rx, ry),
            clockwise: true,
          ),
        paint,
      );
    }

    strokeArc(
      geometry.outerStrokeWidth,
      springY,
      Paint()
        ..color = edgeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = geometry.outerStrokeWidth,
    );
    strokeArc(
      geometry.frameBandWidth,
      arcSpringY,
      Paint()
        ..color = edgeColor.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = geometry.innerStrokeWidth,
    );
    final glassOutlineInset = geometry.frameBandWidth + geometry.innerBandInset;
    final sashLinePaint = Paint()
      ..color = edgeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = geometry.innerStrokeWidth * 0.75;
    if (capSash) {
      strokeArc(sashOuterPx, glassSpringY, sashLinePaint);
      strokeArc(glassEdgePx, glassSpringY, sashLinePaint);
    } else {
      strokeArc(glassOutlineInset, glassSpringY, sashLinePaint);
    }

    if (mullionXs.isNotEmpty && glassRight > glassLeft) {
      final glassHalf =
          halfBand + geometry.innerBandInset + geometry.glassInset;
      final outlineHalf = halfBand + geometry.innerBandInset;

      double archYAt(double x, double inset, double sY) {
        final rx = w / 2 - inset;
        final ry = sY - inset;
        if (rx <= 0.1 || ry <= 0.1) return sY;
        final t = (x - w / 2) / rx;
        if (t.abs() >= 1) return sY;
        return sY - ry * math.sqrt(1 - t * t);
      }

      final fillTopInset = geometry.frameBandWidth * 0.5;

      final outlinePaint = Paint()
        ..color = edgeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = geometry.innerStrokeWidth * 0.75;
      final dividerPaint = Paint()
        ..color = edgeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = geometry.innerStrokeWidth;

      final fillRx = w / 2 - fillTopInset;
      final fillRy = arcSpringY - fillTopInset;
      for (final fx in mullionXs) {
        final mx = fx * w;
        final glassBottom = glassSpringY;
        final bandBottom = arcSpringY;

        void strokeMullionSide(
            double x, double inset, double sY, double bY, Paint paint) {
          canvas.drawLine(
              Offset(x, bY), Offset(x, archYAt(x, inset, sY)), paint);
        }

        final lx = mx - glassHalf;
        final rxEdge = mx + glassHalf;
        final yL = archYAt(lx, fillTopInset, arcSpringY);
        final yR = archYAt(rxEdge, fillTopInset, arcSpringY);
        final bandPath = Path()
          ..moveTo(lx, bandBottom)
          ..lineTo(lx, yL);
        if (fillRx > 0.1 && fillRy > 0.1) {
          bandPath.arcToPoint(
            Offset(rxEdge, yR),
            radius: Radius.elliptical(fillRx, fillRy),
            clockwise: true,
          );
        } else {
          bandPath.lineTo(rxEdge, yR);
        }
        bandPath
          ..lineTo(rxEdge, bandBottom)
          ..close();
        canvas.drawPath(bandPath, Paint()..color = frameColor);

        strokeMullionSide(mx - outlineHalf, glassOutlineInset, glassSpringY,
            glassBottom, outlinePaint);
        strokeMullionSide(mx + outlineHalf, glassOutlineInset, glassSpringY,
            glassBottom, outlinePaint);
        strokeMullionSide(mx - halfBand, geometry.frameBandWidth, arcSpringY,
            bandBottom, dividerPaint);
        strokeMullionSide(mx + halfBand, geometry.frameBandWidth, arcSpringY,
            bandBottom, dividerPaint);

        final panelBorderPaint = Paint()
          ..color = edgeColor.withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = geometry.innerStrokeWidth;

        void connectRing(
            double inset, double sY, double xFrom, double xTo, Paint paint) {
          final rx = w / 2 - inset;
          final ry = sY - inset;
          if (rx <= 0.1 || ry <= 0.1) return;
          canvas.drawPath(
            Path()
              ..moveTo(xFrom, archYAt(xFrom, inset, sY))
              ..arcToPoint(
                Offset(xTo, archYAt(xTo, inset, sY)),
                radius: Radius.elliptical(rx, ry),
                clockwise: true,
              ),
            paint,
          );
        }

        connectRing(glassOutlineInset, glassSpringY, lx, mx - outlineHalf,
            outlinePaint);
        connectRing(glassOutlineInset, glassSpringY, mx + outlineHalf, rxEdge,
            outlinePaint);
        connectRing(geometry.frameBandWidth, arcSpringY, lx, mx - halfBand,
            panelBorderPaint);
        connectRing(geometry.frameBandWidth, arcSpringY, mx + halfBand, rxEdge,
            panelBorderPaint);
      }
    }

    if (!isPlainArch && glassRight - glassOutlineInset > glassOutlineInset) {
      final mHalf = geometry.frameBandWidth / 2;
      final mOutline = mHalf + geometry.innerBandInset;
      List<(double, double)> skips(double half) => [
            for (final fx in mullionXs) (fx * w - half, fx * w + half),
          ]..sort((a, b) => a.$1.compareTo(b.$1));
      drawSegmentedLine(
        canvas,
        glassOutlineInset,
        glassSpringY,
        w - glassOutlineInset,
        glassSpringY,
        skips(mOutline),
        horizontal: true,
        paint: Paint()
          ..color = edgeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = geometry.innerStrokeWidth * 0.75,
      );
      drawSegmentedLine(
        canvas,
        geometry.frameBandWidth,
        arcSpringY,
        w - geometry.frameBandWidth,
        arcSpringY,
        skips(mHalf),
        horizontal: true,
        paint: Paint()
          ..color = edgeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = geometry.innerStrokeWidth,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ArchOverlayPainter oldDelegate) =>
      oldDelegate.archHeightFactor != archHeightFactor ||
      oldDelegate.hasTransom != hasTransom ||
      !listEquals(oldDelegate.mullionXs, mullionXs) ||
      oldDelegate.isPlainArch != isPlainArch ||
      oldDelegate.frameColor != frameColor ||
      oldDelegate.glassColor != glassColor ||
      oldDelegate.edgeColor != edgeColor ||
      oldDelegate.showFrame != showFrame ||
      oldDelegate.showGlass != showGlass ||
      oldDelegate.frameBandScale != frameBandScale;
}

class ArchClipper extends CustomClipper<Path> {
  const ArchClipper(this.archHeightFactor);

  final double archHeightFactor;

  @override
  Path getClip(Size size) {
    final springY = size.height * archHeightFactor;
    final p = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, springY);
    if (springY > 0.1 && size.width > 0.1) {
      p.arcToPoint(
        Offset(size.width, springY),
        radius: Radius.elliptical(size.width / 2, springY),
        clockwise: true,
      );
    } else {
      p.lineTo(size.width, springY);
    }
    p
      ..lineTo(size.width, size.height)
      ..close();
    return p;
  }

  @override
  bool shouldReclip(covariant ArchClipper oldClipper) =>
      oldClipper.archHeightFactor != archHeightFactor;
}
