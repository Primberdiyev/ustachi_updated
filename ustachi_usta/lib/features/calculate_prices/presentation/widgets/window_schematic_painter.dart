import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/arch_overlay_painter.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_ui_models.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/window_zone_model.dart';

abstract final class SchematicMm {
  static double frameFor(double widthMm, double heightMm) {
    final k = math.min(widthMm / 2000.0, heightMm / 2500.0);
    return (k * 60.0).clamp(60.0, 120.0);
  }

  static double mullionFor(double frameMm) => frameMm;

  static const double sash = 85;

  static const double glassInset = 20;

  static const double handleW = 20;
  static const double handleH = 85;

  static const double handleEdge = 35;

  static const double hingeW = 8;
  static const double hingeH = 64;

  static const double doorHandleW = 24;
  static const double doorHandleH = 110;

  static const double tallSash = 1400;
}

class SchematicPreviewWidget extends StatelessWidget {
  const SchematicPreviewWidget({
    super.key,
    required this.spec,
    this.profileColor = const Color(0xFFFEFEFC),
    this.glassColor = const Color(0xFFCBE2F4),
    this.outlineColor = const Color(0x8A2F3A44),
    this.background,
    this.showHardware = false,
    this.applySpecDefaults = false,
  });

  final FramePreviewSpec spec;
  final Color profileColor;
  final Color glassColor;
  final Color outlineColor;
  final Color? background;
  final bool showHardware;

  final bool applySpecDefaults;

  @override
  Widget build(BuildContext context) {
    final wMm = (spec.widthMm ?? (1500 * spec.aspectRatio).round()).toDouble();
    final hMm = (spec.heightMm ?? 1500).toDouble();
    final zone = applySpecDefaults
        ? WindowZone.fromFramePreviewSpecWithDefaults(spec)
        : WindowZone.fromFramePreviewSpec(spec);
    final panes = applySpecDefaults
        ? _panesWithOpenings(zone)
        : [for (final r in zone.leafRects()) SchematicPane(rect: r)];

    final base = CustomPaint(
      painter: WindowSchematicPainter(
        widthMm: wMm,
        heightMm: hMm,
        panes: panes,
        regions: spec.regions,
        profileColor: profileColor,
        glassColor: glassColor,
        outlineColor: outlineColor,
        background: background,
        showHardware: showHardware,
      ),
      child: const SizedBox.expand(),
    );

    final arch = spec.archHeightFactor;
    if (arch <= 0) {
      return AspectRatio(aspectRatio: wMm / hMm, child: base);
    }

    final hasTransom = spec.lines.any((l) =>
        (l.startY - l.endY).abs() < 0.001 &&
        (l.startY - arch).abs() < 0.001);
    final archMullionXs = [
      for (final l in spec.lines)
        if ((l.startX - l.endX).abs() < 0.001 &&
            (l.startY < l.endY ? l.startY : l.endY) < arch - 0.001)
          l.startX,
    ];

    return AspectRatio(
      aspectRatio: wMm / hMm,
      child: Stack(
        fit: StackFit.expand,
        children: [
          base,
          CustomPaint(
            painter: ArchOverlayPainter(
              archHeightFactor: arch,
              hasTransom: hasTransom,
              mullionXs: archMullionXs,
              isPlainArch: !hasTransom,
              frameColor: profileColor,
              glassColor: glassColor,
              edgeColor: outlineColor,
              showFrame: spec.showFrame,
              showGlass: spec.showGlass,
              frameBandScale: spec.frameBandScale,
              capOpening: panes
                  .any((p) => p.openingCategory > 0 && p.rect.top <= 0.001),
              widthMm: wMm,
              heightMm: hMm,
            ),
            child: const SizedBox.expand(),
          ),
        ],
      ),
    );
  }

  List<SchematicPane> _panesWithOpenings(WindowZone zone) =>
      schematicPanesOf(zone);

}

class SchematicPane {
  const SchematicPane({
    required this.rect,
    this.openingCategory = 0,
    this.isDoor = false,
    this.hasHandle = true,
    this.layoutPattern = 0,
    this.patternOverlays = const [],
    this.compartments = const [],
  });

  final Rect rect;

  final int openingCategory;

  final bool isDoor;
  final bool hasHandle;

  final int layoutPattern;

  final List<({Rect rect, int pattern})> patternOverlays;

  final List<({Rect rect, int pattern})> compartments;
}

class WindowSchematicPainter extends CustomPainter {
  WindowSchematicPainter({
    required this.widthMm,
    required this.heightMm,
    required this.panes,
    this.regions = const [],
    this.profileColor = const Color(0xFFFFFFFF),
    this.glassColor = const Color(0xFFB3DFF5),
    this.outlineColor = const Color(0xB3000000),
    this.openingLineColor = const Color(0xFF1A237E),
    this.background,
    this.showHardware = true,
    this.outlineWidthPx,
    this.heightStretch = 1.0,
    this.minFramePx = 0.0,
    this.hingeImage,
    this.handleImage,
    this.handleRightImage,
    this.windowHandleImage,
    this.transparent = false,
  });

  final double widthMm;
  final double heightMm;
  final List<SchematicPane> panes;

  final bool transparent;

  final List<FrameRegion> regions;

  final Color profileColor;
  final Color glassColor;

  final Color outlineColor;

  final Color openingLineColor;

  final Color? background;

  final bool showHardware;

  final double? outlineWidthPx;

  final double heightStretch;

  final double minFramePx;

  final ui.Image? hingeImage;
  final ui.Image? handleImage;
  final ui.Image? handleRightImage;
  final ui.Image? windowHandleImage;

  @override
  void paint(Canvas canvas, Size size) {
    if (widthMm <= 0 || heightMm <= 0 || size.isEmpty) return;
    final effHeightMm = heightMm * heightStretch;
    final s = math.min(size.width / widthMm, size.height / effHeightMm);
    final drawW = widthMm * s;
    final drawH = effHeightMm * s;
    final origin = Offset((size.width - drawW) / 2, (size.height - drawH) / 2);

    final outer = origin & Size(drawW, drawH);
    final strokeW = outlineWidthPx ?? 1.0;
    final crisp = Color.fromARGB(255, (outlineColor.r * 255).round(),
        (outlineColor.g * 255).round(), (outlineColor.b * 255).round());
    final outline = Paint()
      ..color = crisp
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..isAntiAlias = false;
    final thinOutline = Paint()
      ..color = crisp
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, strokeW * 0.8)
      ..isAntiAlias = false;

    if (background != null) {
      canvas.drawRect(outer, Paint()..color = background!);
    }

    Rect toPx(Rect r) => Rect.fromLTRB(
          origin.dx + r.left * drawW,
          origin.dy + r.top * drawH,
          origin.dx + r.right * drawW,
          origin.dy + r.bottom * drawH,
        );
    Offset ptPx(Offset p) =>
        Offset(origin.dx + p.dx * drawW, origin.dy + p.dy * drawH);

    if (transparent) {
    } else if (regions.isEmpty) {
      canvas.drawRect(outer, Paint()..color = profileColor);
      canvas.drawRect(outer, outline);
    } else {
      final fill = Paint()
        ..color = profileColor
        ..isAntiAlias = false;
      for (final r in regions) {
        canvas.drawRect(toPx(_rectOf(r)), fill);
      }
      for (final seg in _regionBoundarySegments()) {
        canvas.drawLine(ptPx(seg.a), ptPx(seg.b), outline);
      }
    }

    final frameMm = math.max(
      SchematicMm.frameFor(widthMm, heightMm),
      minFramePx / s,
    );
    final mullHalfMm = SchematicMm.mullionFor(frameMm) / 2;
    for (final pane in panes) {
      final paneRect = toPx(pane.rect);
      const eps = 1e-6;
      double insetL, insetT, insetR, insetB;
      if (regions.isEmpty) {
        insetL = (pane.rect.left <= eps ? frameMm : mullHalfMm) * s;
        insetT = (pane.rect.top <= eps ? frameMm : mullHalfMm) * s;
        insetR = (pane.rect.right >= 1 - eps ? frameMm : mullHalfMm) * s;
        insetB = (pane.rect.bottom >= 1 - eps ? frameMm : mullHalfMm) * s;
      } else {
        final reg = _regionForPane(pane.rect);
        if (reg == null) continue;
        insetL = _edgeInsetMm(pane.rect.left, reg.left, reg.absorbedLeft,
                reg.sharedLeft, frameMm, mullHalfMm) *
            s;
        insetT = _edgeInsetMm(pane.rect.top, reg.top, reg.absorbedTop,
                reg.sharedTop, frameMm, mullHalfMm) *
            s;
        insetR = _edgeInsetMm(pane.rect.right, reg.right, reg.absorbedRight,
                reg.sharedRight, frameMm, mullHalfMm) *
            s;
        insetB = _edgeInsetMm(pane.rect.bottom, reg.bottom, reg.absorbedBottom,
                reg.sharedBottom, frameMm, mullHalfMm) *
            s;
      }
      final proyom = Rect.fromLTRB(
        paneRect.left + insetL,
        paneRect.top + insetT,
        paneRect.right - insetR,
        paneRect.bottom - insetB,
      );
      if (proyom.width <= 0 || proyom.height <= 0) continue;

      if (pane.openingCategory == 0) {
        _drawGlass(canvas, proyom, s,
            outline: thinOutline, pattern: pane.layoutPattern);
        canvas.drawRect(proyom, outline);
      } else {
        final overlaysPx = [
          for (final ov in pane.patternOverlays)
            (rect: toPx(ov.rect), pattern: ov.pattern),
        ];
        const be = 1e-4;
        final comps = [
          for (final c in pane.compartments)
            (
              px: toPx(c.rect),
              pattern: c.pattern,
              bL: (c.rect.left - pane.rect.left).abs() < be,
              bT: (c.rect.top - pane.rect.top).abs() < be,
              bR: (c.rect.right - pane.rect.right).abs() < be,
              bB: (c.rect.bottom - pane.rect.bottom).abs() < be,
            ),
        ];
        _drawOpeningPane(canvas, proyom, s, pane, outline, thinOutline,
            overlaysPx: overlaysPx,
            comps: comps,
            mullHalfPx: mullHalfMm * s);
      }
    }
  }

  static Rect _rectOf(FrameRegion r) =>
      Rect.fromLTRB(r.left, r.top, r.right, r.bottom);

  FrameRegion? _regionForPane(Rect paneRect) {
    FrameRegion? best;
    var bestArea = 0.0;
    for (final r in regions) {
      final i = _rectOf(r).intersect(paneRect);
      if (i.width <= 0 || i.height <= 0) continue;
      final a = i.width * i.height;
      if (a > bestArea) {
        bestArea = a;
        best = r;
      }
    }
    final paneArea = paneRect.width * paneRect.height;
    return bestArea >= paneArea * 0.5 ? best : null;
  }

  static double _edgeInsetMm(double paneEdge, double regionEdge, bool absorbed,
      bool shared, double frameMm, double mullHalfMm) {
    const be = 1e-4;
    if ((paneEdge - regionEdge).abs() >= be) return mullHalfMm;
    if (absorbed) return 0;
    if (shared) return frameMm / 2;
    return frameMm;
  }

  List<({Offset a, Offset b})> _regionBoundarySegments() {
    const eps = 1e-6;
    final segs = <({Offset a, Offset b})>[];
    void edge(bool vertical, double coord, double s0, double s1,
        List<(double, double)> covers) {
      var spans = <(double, double)>[(s0, s1)];
      for (final (c0, c1) in covers) {
        final next = <(double, double)>[];
        for (final (a, b) in spans) {
          final lo = math.max(a, c0);
          final hi = math.min(b, c1);
          if (hi - lo <= eps) {
            next.add((a, b));
            continue;
          }
          if (lo - a > eps) next.add((a, lo));
          if (b - hi > eps) next.add((hi, b));
        }
        spans = next;
      }
      for (final (a, b) in spans) {
        segs.add(vertical
            ? (a: Offset(coord, a), b: Offset(coord, b))
            : (a: Offset(a, coord), b: Offset(b, coord)));
      }
    }

    for (final r in regions) {
      edge(true, r.left, r.top, r.bottom, [
        for (final o in regions)
          if (!identical(o, r) && (o.right - r.left).abs() < eps)
            (o.top, o.bottom),
      ]);
      edge(true, r.right, r.top, r.bottom, [
        for (final o in regions)
          if (!identical(o, r) && (o.left - r.right).abs() < eps)
            (o.top, o.bottom),
      ]);
      edge(false, r.top, r.left, r.right, [
        for (final o in regions)
          if (!identical(o, r) && (o.bottom - r.top).abs() < eps)
            (o.left, o.right),
      ]);
      edge(false, r.bottom, r.left, r.right, [
        for (final o in regions)
          if (!identical(o, r) && (o.top - r.bottom).abs() < eps)
            (o.left, o.right),
      ]);
    }
    return segs;
  }

  void _drawGlass(Canvas canvas, Rect proyom, double s,
      {required Paint outline, int pattern = 0}) {
    final g = proyom.deflate(SchematicMm.glassInset * s);
    if (g.width <= 0 || g.height <= 0) {
      if (!transparent) canvas.drawRect(proyom, Paint()..color = glassColor);
      return;
    }
    final profileFill = pattern == 1 || pattern == 2 || pattern == 3;
    if (profileFill) {
      canvas.drawRect(g, Paint()..color = profileColor);
    } else if (!transparent) {
      canvas.drawRect(g, Paint()..color = glassColor);
    }
    canvas.drawRect(g, outline);
    _drawBars(canvas, g, s, pattern, outline.strokeWidth);
  }

  void _drawBars(
      Canvas canvas, Rect area, double s, int pattern, double strokeWidth) {
    if (pattern != 1 && pattern != 2 && pattern != 5) return;
    final crisp = Color.fromARGB(255, (outlineColor.r * 255).round(),
        (outlineColor.g * 255).round(), (outlineColor.b * 255).round());
    final isLambri = pattern == 1 || pattern == 2;
    final lp = Paint()
      ..color = isLambri ? crisp : outlineColor.withValues(alpha: 0.4)
      ..strokeWidth = isLambri ? math.max(1.0, strokeWidth) : strokeWidth
      ..isAntiAlias = !isLambri;
    const stepMm = 60.0; 
    final step = stepMm * s;
    if (step <= 1) return;
    canvas.save();
    canvas.clipRect(area);
    if (pattern == 1 || pattern == 5) {
      for (var x = area.left + step; x < area.right; x += step) {
        canvas.drawLine(Offset(x, area.top), Offset(x, area.bottom), lp);
      }
    }
    if (pattern == 2 || pattern == 5) {
      for (var y = area.top + step; y < area.bottom; y += step) {
        canvas.drawLine(Offset(area.left, y), Offset(area.right, y), lp);
      }
    }
    canvas.restore();
  }

  void _drawOpeningPane(Canvas canvas, Rect proyom, double s,
      SchematicPane pane, Paint outline, Paint thinOutline,
      {List<({Rect rect, int pattern})> overlaysPx = const [],
      List<({Rect px, int pattern, bool bL, bool bT, bool bR, bool bB})> comps =
          const [],
      double mullHalfPx = 0}) {
    final sashOuter = proyom; 
    final sashInner = sashOuter.deflate(SchematicMm.sash * s);
    if (sashInner.width <= 0 || sashInner.height <= 0) {
      _drawGlass(canvas, proyom, s, outline: thinOutline);
      canvas.drawRect(proyom, outline);
      return;
    }

    bool isGlassPattern(int p) => p == 0 || p == 4 || p == 5;
    if (transparent) {
      final framePath = Path()..addRect(proyom);
      if (comps.isEmpty) {
        framePath.addRect(sashInner); 
      } else {
        for (final c in comps) {
          if (!isGlassPattern(c.pattern)) continue; 
          final l = c.bL ? sashInner.left : c.px.left + mullHalfPx;
          final t = c.bT ? sashInner.top : c.px.top + mullHalfPx;
          final r = c.bR ? sashInner.right : c.px.right - mullHalfPx;
          final b = c.bB ? sashInner.bottom : c.px.bottom - mullHalfPx;
          if (r - l > 0 && b - t > 0) {
            framePath.addRect(Rect.fromLTRB(l, t, r, b));
          }
        }
      }
      framePath.fillType = PathFillType.evenOdd;
      canvas.drawPath(
          framePath,
          Paint()
            ..color = profileColor
            ..isAntiAlias = false);
    }

    canvas.drawRect(proyom, outline);

    if (comps.isEmpty) {
      canvas.drawRect(sashInner, outline);
      _drawGlass(canvas, sashInner, s, outline: thinOutline);
      for (final ov in overlaysPx) {
        final area = ov.rect.intersect(sashInner);
        if (area.width <= 0 || area.height <= 0) continue;
        if (ov.pattern == 1 || ov.pattern == 2 || ov.pattern == 3) {
          canvas.drawRect(area, Paint()..color = profileColor);
          canvas.drawRect(area, thinOutline);
        }
        _drawBars(canvas, area, s, ov.pattern, thinOutline.strokeWidth);
      }
    } else {
      for (final c in comps) {
        final l = c.bL ? sashInner.left : c.px.left + mullHalfPx;
        final t = c.bT ? sashInner.top : c.px.top + mullHalfPx;
        final r = c.bR ? sashInner.right : c.px.right - mullHalfPx;
        final b = c.bB ? sashInner.bottom : c.px.bottom - mullHalfPx;
        if (r - l <= 0 || b - t <= 0) continue;
        final cp = Rect.fromLTRB(l, t, r, b);
        _drawGlass(canvas, cp, s, outline: thinOutline, pattern: c.pattern);
        canvas.drawRect(cp, outline);
      }
    }

    final cat = pane.openingCategory;
    final turnRight = cat == 1 || cat == 5; 
    final turnLeft = cat == 2 || cat == 6; 
    final tiltTop = cat == 3 || cat == 5 || cat == 6; 
    final tiltBottom = cat == 4; 

    final lp = Paint()
      ..color = openingLineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.4, 1.2 * s / 0.2);
    final g = sashInner;
    void line(Offset a, Offset b) => canvas.drawLine(a, b, lp);
    if (turnRight) {
      line(Offset(g.left, g.top + g.height * 0.25),
          Offset(g.right, g.center.dy));
      line(Offset(g.left, g.top + g.height * 0.75),
          Offset(g.right, g.center.dy));
    }
    if (turnLeft) {
      line(Offset(g.right, g.top + g.height * 0.25),
          Offset(g.left, g.center.dy));
      line(Offset(g.right, g.top + g.height * 0.75),
          Offset(g.left, g.center.dy));
    }
    if (tiltTop) {
      line(Offset(g.left + g.width * 0.25, g.bottom),
          Offset(g.center.dx, g.top));
      line(Offset(g.left + g.width * 0.75, g.bottom),
          Offset(g.center.dx, g.top));
    }
    if (tiltBottom) {
      line(Offset(g.left + g.width * 0.25, g.top),
          Offset(g.center.dx, g.bottom));
      line(Offset(g.left + g.width * 0.75, g.top),
          Offset(g.center.dx, g.bottom));
    }

    if (!showHardware) return;

    if (pane.hasHandle) {
      final ui.Image? handleImg = pane.isDoor
          ? (turnLeft ? (handleRightImage ?? handleImage) : handleImage)
          : windowHandleImage;
      const windowHandleLenMm = 180.0;
      const windowHandleInsetMm = 45.0;
      const windowHandleBiasMm = 13.0;
      const windowHandleWidthScale = 1.0;
      const doorHandleLenMm = 250.0;
      const doorHandleInsetLeftMm = 50.0; 
      const doorHandleInsetRightMm =85.0; 
      const doorHandleInsetTiltMm = 60.0; 
      const doorHandleWidthScale = 1.0;
      final handleLen =
          (pane.isDoor ? doorHandleLenMm : windowHandleLenMm) * s;
      final handleIn = (pane.isDoor
              ? (turnLeft
                  ? doorHandleInsetLeftMm
                  : turnRight
                      ? doorHandleInsetRightMm
                      : doorHandleInsetTiltMm)
              : windowHandleInsetMm) *
          s;
      Offset? hc;
      var hVertical = true;
      if (turnRight) {
        hc = Offset(proyom.right - handleIn, proyom.center.dy);
      } else if (turnLeft) {
        hc = Offset(proyom.left + handleIn, proyom.center.dy);
      } else if (tiltTop) {
        hc = Offset(proyom.center.dx, proyom.top + handleIn);
        hVertical = false;
      } else if (tiltBottom) {
        hc = Offset(proyom.center.dx, proyom.bottom - handleIn);
        hVertical = false;
      }
      if (hc != null) {
        if (handleImg != null) {
          _drawImageFit(canvas, handleImg,
              center: hc,
              length: handleLen,
              vertical: hVertical,
              widthScale:
                  pane.isDoor ? doorHandleWidthScale : windowHandleWidthScale,
              alongShiftPx: pane.isDoor ? 0.0 : windowHandleBiasMm * s);
        } else {
          _drawHandle(canvas, s, pane.isDoor,
              center: hc, vertical: hVertical, outline: outline);
        }
      }
    }

    final hingeLen =160.0 * s;

    const hingeOutwardMm = 10;
    final hingeOut = hingeOutwardMm * s;
    void hinge(Offset c, bool vertical) {
      if (hingeImage != null) {
        _drawImageFit(canvas, hingeImage!,
            center: c, length: hingeLen, vertical: vertical);
      } else {
        _drawHinge(canvas, s, center: c, vertical: vertical, outline: outline);
      }
    }

    final sashHmm = sashOuter.height / s;
    final three = pane.isDoor || sashHmm > SchematicMm.tallSash;
    final fr = three ? const [0.25, 0.5, 0.75] : const [0.25, 0.75];
    if (turnRight) {
      for (final f in fr) {
        hinge(Offset(proyom.left - hingeOut, proyom.top + proyom.height * f),
            true);
      }
    } else if (turnLeft) {
      for (final f in fr) {
        hinge(Offset(proyom.right + hingeOut, proyom.top + proyom.height * f),
            true);
      }
    } else if (tiltTop) {
      for (final f in const [0.25, 0.75]) {
        hinge(Offset(proyom.left + proyom.width * f, proyom.bottom + hingeOut),
            false);
      }
    } else if (tiltBottom) {
      for (final f in const [0.25, 0.75]) {
        hinge(Offset(proyom.left + proyom.width * f, proyom.top - hingeOut),
            false);
      }
    }
  }

  void _drawImageFit(Canvas canvas, ui.Image img,
      {required Offset center,
      required double length,
      required bool vertical,
      double widthScale = 1.0,
      double alongShiftPx = 0.0}) {
    if (length <= 1) return;
    final aspect = img.width / img.height;
    final dst = Rect.fromCenter(
        center: Offset.zero,
        width: length * aspect * widthScale,
        height: length);
    final src =
        Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble());
    canvas.save();
    canvas.translate(center.dx, center.dy);
    if (!vertical) canvas.rotate(-math.pi / 2);
    if (alongShiftPx != 0) canvas.translate(alongShiftPx, 0);
    canvas.drawImageRect(
        img, src, dst, Paint()..filterQuality = FilterQuality.medium);
    canvas.restore();
  }

  void _drawHandle(Canvas canvas, double s, bool isDoor,
      {required Offset center,
      required bool vertical,
      required Paint outline}) {
    final w = (isDoor ? SchematicMm.doorHandleW : SchematicMm.handleW) * s;
    final h = (isDoor ? SchematicMm.doorHandleH : SchematicMm.handleH) * s;
    final rect = vertical
        ? Rect.fromCenter(center: center, width: w, height: h)
        : Rect.fromCenter(center: center, width: h, height: w);
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(3 * s));
    canvas.drawRRect(rr, Paint()..color = profileColor);
    canvas.drawRRect(rr, outline);
    if (isDoor) {
      final r = 6 * s;
      final c = vertical
          ? Offset(center.dx, rect.bottom + 14 * s)
          : Offset(rect.right + 14 * s, center.dy);
      canvas.drawCircle(c, r, Paint()..color = profileColor);
      canvas.drawCircle(c, r, outline);
    }
  }

  void _drawHinge(Canvas canvas, double s,
      {required Offset center,
      required bool vertical,
      required Paint outline}) {
    final w = SchematicMm.hingeW * 2 * s; 
    final h = SchematicMm.hingeH * s;
    final rect = vertical
        ? Rect.fromCenter(center: center, width: w, height: h)
        : Rect.fromCenter(center: center, width: h, height: w);
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(2 * s));
    canvas.drawRRect(rr, Paint()..color = profileColor);
    canvas.drawRRect(rr, outline);
    if (vertical) {
      canvas.drawLine(
          Offset(center.dx, rect.top),
          Offset(center.dx, rect.bottom),
          outline..strokeWidth = outline.strokeWidth);
    } else {
      canvas.drawLine(
          Offset(rect.left, center.dy), Offset(rect.right, center.dy), outline);
    }
  }

  @override
  bool shouldRepaint(covariant WindowSchematicPainter old) =>
      old.widthMm != widthMm ||
      old.heightMm != heightMm ||
      old.profileColor != profileColor ||
      old.glassColor != glassColor ||
      old.outlineColor != outlineColor ||
      old.openingLineColor != openingLineColor ||
      old.background != background ||
      old.showHardware != showHardware ||
      old.outlineWidthPx != outlineWidthPx ||
      old.heightStretch != heightStretch ||
      old.minFramePx != minFramePx ||
      old.hingeImage != hingeImage ||
      old.handleImage != handleImage ||
      old.handleRightImage != handleRightImage ||
      old.windowHandleImage != windowHandleImage ||
      old.transparent != transparent ||
      !listEquals(old.regions, regions) ||
      !_panesEqual(old.panes, panes);

  static bool _panesEqual(List<SchematicPane> a, List<SchematicPane> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].rect != b[i].rect ||
          a[i].openingCategory != b[i].openingCategory ||
          a[i].isDoor != b[i].isDoor ||
          a[i].hasHandle != b[i].hasHandle ||
          a[i].layoutPattern != b[i].layoutPattern ||
          !_overlaysEqual(a[i].patternOverlays, b[i].patternOverlays) ||
          !_overlaysEqual(a[i].compartments, b[i].compartments)) {
        return false;
      }
    }
    return true;
  }

  static bool _overlaysEqual(
    List<({Rect rect, int pattern})> a,
    List<({Rect rect, int pattern})> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].rect != b[i].rect || a[i].pattern != b[i].pattern) return false;
    }
    return true;
  }
}

List<({Rect glass, int openingCategory})> schematicDecorationGlassRects({
  required Size size,
  required List<SchematicPane> panes,
  required double widthMm,
  required double heightMm,
  double heightStretch = 1.0,
  double minFramePx = 6.0,
}) {
  if (widthMm <= 0 || heightMm <= 0 || size.isEmpty || panes.isEmpty) {
    return const [];
  }
  final effHeightMm = heightMm * heightStretch;
  final s = math.min(size.width / widthMm, size.height / effHeightMm);
  final drawW = widthMm * s, drawH = effHeightMm * s;
  final origin = Offset((size.width - drawW) / 2, (size.height - drawH) / 2);
  Rect toPx(Rect r) => Rect.fromLTRB(
        origin.dx + r.left * drawW,
        origin.dy + r.top * drawH,
        origin.dx + r.right * drawW,
        origin.dy + r.bottom * drawH,
      );
  final frameMm =
      math.max(SchematicMm.frameFor(widthMm, heightMm), minFramePx / s);
  final mullHalfMm = SchematicMm.mullionFor(frameMm) / 2;
  const eps = 1e-6;
  final out = <({Rect glass, int openingCategory})>[];
  for (final pane in panes) {
    final paneRect = toPx(pane.rect);
    final insetL = (pane.rect.left <= eps ? frameMm : mullHalfMm) * s;
    final insetT = (pane.rect.top <= eps ? frameMm : mullHalfMm) * s;
    final insetR = (pane.rect.right >= 1 - eps ? frameMm : mullHalfMm) * s;
    final insetB = (pane.rect.bottom >= 1 - eps ? frameMm : mullHalfMm) * s;
    var proyom = Rect.fromLTRB(paneRect.left + insetL, paneRect.top + insetT,
        paneRect.right - insetR, paneRect.bottom - insetB);
    if (proyom.width <= 0 || proyom.height <= 0) continue;
    if (pane.openingCategory > 0) {
      final sashInner = proyom.deflate(SchematicMm.sash * s);
      if (sashInner.width > 0 && sashInner.height > 0) proyom = sashInner;
    }
    final glassEdge = proyom.deflate(SchematicMm.glassInset * s);
    if (glassEdge.width > 0 && glassEdge.height > 0) proyom = glassEdge;
    out.add((glass: proyom, openingCategory: pane.openingCategory));
  }
  return out;
}

List<SchematicPane> schematicPanesOf(WindowZone zone) {
    final leafs = zone.leafRects();
    final direct = zone.hasAnyDirectlyAppliedOpening();
    final grouped = direct ? null : zone.groupedOpeningSashes();
    final oRects =
        direct ? zone.openingZoneRects() : grouped!.map((s) => s.rect).toList();
    final oTypes =
        direct ? zone.openingZoneTypes() : grouped!.map((s) => s.type).toList();
    final oDoors = direct
        ? zone.openingZoneDoorFlags()
        : grouped!.map((s) => s.isDoor).toList();
    final oHandles = direct
        ? zone.openingZoneHandleFlags()
        : grouped!.map((s) => s.hasHandle).toList();
    final layout = zone.layoutPatternRects();

    int patternFor(Offset c) {
      for (final lp in layout) {
        if (lp.rect.contains(c)) return lp.pattern.index;
      }
      return 0;
    }

    final panes = <SchematicPane>[];
    for (var i = 0; i < oRects.length; i++) {
      final type = i < oTypes.length ? oTypes[i] : WindowOpeningType.fixed;
      if (type == WindowOpeningType.fixed) continue;
      final zoneRect = oRects[i];
      panes.add(SchematicPane(
        rect: zoneRect,
        openingCategory: type.index,
        isDoor: i < oDoors.length && oDoors[i],
        hasHandle: i >= oHandles.length || oHandles[i],
        compartments: [
          for (final leaf in leafs)
            if (zoneRect.contains(leaf.center))
              (rect: leaf, pattern: patternFor(leaf.center)),
        ],
      ));
    }
    for (final leaf in leafs) {
      final c = leaf.center;
      if (panes.any((p) => p.openingCategory > 0 && p.rect.contains(c))) {
        continue;
      }
      panes.add(SchematicPane(rect: leaf, layoutPattern: patternFor(c)));
    }
    return panes;
  }
