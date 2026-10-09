import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:ustachi/core/script/uz_script.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_rom_design.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_ui_models.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/rom_design.dart';

class FrameDrawing extends StatelessWidget {
  const FrameDrawing({
    super.key,
    required this.spec,
    this.frameTint,
    this.showDimensions = false,
    this.showSill = false,
    this.onDimensionTap,
    this.onTap,
  });

  final FramePreviewSpec spec;

  final Color? frameTint;

  final bool showDimensions;

  final bool showSill;

  final ValueChanged<FrameDimensionTarget>? onDimensionTap;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final widthMm = (spec.widthMm ?? (1500 * spec.aspectRatio).round()).toDouble();
    final heightMm = (spec.heightMm ?? 1500).toDouble();
    final painter = FrameDrawingPainter(
      frames: frameDrawingPlacements(spec, widthMm, heightMm),
      widthMm: widthMm,
      heightMm: heightMm,
      frameTint: frameTint,
      showDimensions: showDimensions,
      showSill: showSill,
      dark: Theme.of(context).brightness == Brightness.dark,
      dimensionAccent: onDimensionTap == null ? null : context.color.categorizedColor.primary,
    );
    final canvas = CustomPaint(painter: painter, child: const SizedBox.expand());
    final onDimension = onDimensionTap;
    if (showDimensions && onDimension != null) {
      return LayoutBuilder(
        builder: (context, constraints) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) {
            final hit = painter.dimensionTargetAt(constraints.biggest, details.localPosition);
            if (hit != null) {
              onDimension(hit);
            } else {
              onTap?.call();
            }
          },
          child: canvas,
        ),
      );
    }
    if (showDimensions) return canvas;
    final sillMm = showSill ? FrameDrawingPainter.sillDepthMm : 0.0;
    final overhangMm = showSill ? 2 * FrameDrawingPainter.sillOverhangMm : 0.0;
    return AspectRatio(
      aspectRatio: ((widthMm + overhangMm) / (heightMm + sillMm)).clamp(0.05, 20.0),
      child: canvas,
    );
  }
}

Color frameDrawingTileColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1D2733) : Colors.white;

typedef FramePlacement = ({Rect rectMm, RomFrameDesign design});

List<FramePlacement> frameDrawingPlacements(FramePreviewSpec spec, double widthMm, double heightMm) {
  final full = Rect.fromLTWH(0, 0, widthMm, heightMm);
  try {
    final design = proposalRomDesign(spec, widthMm.round(), heightMm.round());
    final regions = spec.regions.isEmpty
        ? [full]
        : [
            for (final r in spec.regions)
              Rect.fromLTRB(r.left * widthMm, r.top * heightMm, r.right * widthMm, r.bottom * heightMm),
          ];
    if (regions.length != design.frames.length) throw const RomDesignException('romlar soni');
    return [
      for (var i = 0; i < regions.length; i++) (rectMm: regions[i], design: design.frames[i]),
    ];
  } on RomDesignException {
    return [
      (
        rectMm: full,
        design: RomFrameDesign(
          widthMm: widthMm,
          heightMm: heightMm,
          archRiseMm: spec.archHeightFactor * heightMm,
        ),
      ),
    ];
  }
}

int frameWingCount(List<FramePlacement> frames) {
  int count(RomCell c) => switch (c) {
        RomZone() => 0,
        RomSplit(:final children) => children.fold(0, (s, x) => s + count(x)),
        RomWing(:final content) => 1 + count(content),
      };
  return frames.fold(0, (s, f) => s + count(f.design.root));
}

List<String> frameComposition(List<FramePlacement> frames) {
  final wings = <RomWingFunction, int>{};
  var fixedGlass = 0;
  var panels = 0;
  var lambri = 0;
  void walk(RomCell c, {required bool inWing}) {
    switch (c) {
      case RomZone(:final fill):
        switch (fill) {
          case RomFill.panel:
            panels++;
          case RomFill.lambri || RomFill.lambriHorizontal:
            lambri++;
          case RomFill.glass when !inWing:
            fixedGlass++;
          case RomFill.glass:
            break;
        }
      case RomSplit(:final children):
        for (final x in children) {
          walk(x, inWing: inWing);
        }
      case RomWing(:final function, :final content):
        wings[function] = (wings[function] ?? 0) + 1;
        walk(content, inWing: true);
    }
  }

  for (final f in frames) {
    walk(f.design.root, inWing: false);
  }
  return [
    for (final (fn, label) in const [
      (RomWingFunction.door, 'eshik tavaqasi'),
      (RomWingFunction.tiltTurn, 'ikki tomonlama ochiladi'),
      (RomWingFunction.turn, 'oddiy ochiladi'),
      (RomWingFunction.tilt, 'fortochka'),
    ])
      if ((wings[fn] ?? 0) > 0) '${wings[fn]} ta $label',
    if (fixedGlass > 0) '$fixedGlass ta qo\'zg\'almas oyna',
    if (panels > 0) '$panels ta panel',
    if (lambri > 0) '$lambri ta lambri',
  ];
}

List<double> frameWidthBreaks(List<FramePlacement> frames, double widthMm) {
  final out = <double>[0, widthMm];
  void walk(RomCell c, Rect outer) {
    switch (c) {
      case RomSplit(axis: RomAxis.vertical, :final positionsMm, :final children):
        var lo = outer.left;
        for (var i = 0; i < children.length; i++) {
          final hi = i < positionsMm.length ? outer.left + positionsMm[i] : outer.right;
          walk(children[i], Rect.fromLTRB(lo, outer.top, hi, outer.bottom));
          if (i < positionsMm.length) out.add(hi);
          lo = hi;
        }
      case RomSplit(axis: RomAxis.horizontal, :final positionsMm, :final children):
        final top = positionsMm.isEmpty ? outer.top : outer.top + positionsMm.last;
        walk(children.last, Rect.fromLTRB(outer.left, top, outer.right, outer.bottom));
      case RomZone() || RomWing():
        break;
    }
  }

  for (final f in frames) {
    out.addAll([f.rectMm.left, f.rectMm.right]);
    walk(f.design.root, f.rectMm);
  }
  return _breaks(out);
}

List<double> frameHeightBreaks(List<FramePlacement> frames, double widthMm, double heightMm) {
  final out = <double>[0, heightMm];
  void walk(RomCell c, Rect outer) {
    switch (c) {
      case RomSplit(axis: RomAxis.horizontal, :final positionsMm, :final children):
        var lo = outer.top;
        for (var i = 0; i < children.length; i++) {
          final hi = i < positionsMm.length ? outer.top + positionsMm[i] : outer.bottom;
          walk(children[i], Rect.fromLTRB(outer.left, lo, outer.right, hi));
          if (i < positionsMm.length) out.add(hi);
          lo = hi;
        }
      case RomSplit(axis: RomAxis.vertical, :final positionsMm, :final children):
        final left = positionsMm.isEmpty ? outer.left : outer.left + positionsMm.last;
        walk(children.last, Rect.fromLTRB(left, outer.top, outer.right, outer.bottom));
      case RomZone() || RomWing():
        break;
    }
  }

  for (final f in frames) {
    if ((f.rectMm.right - widthMm).abs() > 0.5) continue;
    out.addAll([f.rectMm.top, f.rectMm.bottom]);
    walk(f.design.root, f.rectMm);
  }
  return _breaks(out);
}

List<double> _breaks(List<double> values) {
  final sorted = [...values]..sort();
  final out = <double>[];
  for (final v in sorted) {
    if (out.isEmpty || v - out.last > 0.5) out.add(v);
  }
  return out;
}

class FrameDimensionTarget {
  const FrameDimensionTarget({
    required this.horizontal,
    required this.breaksMm,
    required this.index,
    required this.rect,
  });

  final bool horizontal;

  final List<double> breaksMm;

  final int index;

  final Rect rect;

  bool get isTotal => breaksMm.length == 2;
  int get valueMm => (breaksMm[index + 1] - breaksMm[index]).round();
}

typedef _Geometry = ({
  double scale,
  Offset origin,
  Set<int> sills,
  bool sillAtBottom,
  List<double> widthBreaks,
  List<double> heightBreaks,
});

typedef _DimRow = ({List<double> atPx, List<double> mm, double across, bool horizontal, bool total});

class FrameDrawingPainter extends CustomPainter {
  FrameDrawingPainter({
    required this.frames,
    required this.widthMm,
    required this.heightMm,
    this.frameTint,
    this.showDimensions = false,
    this.showSill = false,
    this.dark = false,
    this.dimensionAccent,
  });

  final List<FramePlacement> frames;
  final double widthMm;
  final double heightMm;
  final Color? frameTint;
  final bool showDimensions;
  final bool showSill;

  final bool dark;

  final Color? dimensionAccent;

  static const sillDepthMm = 45.0;
  static const sillOverhangMm = 50.0;

  static const _glassTop = Color(0xFFE9F4FB);
  static const _glassBottom = Color(0xFFB4D6EC);
  static const _metal = Color(0xFF38414B);

  static const _handleMetal = Color(0xFFC9CFD6);

  static const _dimBottom = 26.0;
  static const _dimRight = 44.0;
  static const _chainStep = 19.0;

  late Color _profile;
  late Color _profileShade;
  late Color _line;
  late double _s;
  late double _frameB;
  late double _mullionB;
  late double _sashB;
  late double _stroke;

  late bool _compact;

  _Geometry? _geometry(Size size) {
    if (widthMm <= 0 || heightMm <= 0 || size.isEmpty) return null;

    final sills = showSill ? _sillFrames() : const <int>{};
    final sillAtBottom = sills.any((i) => (frames[i].rectMm.bottom - heightMm).abs() < 0.5);
    final contentW = widthMm + (sills.isEmpty ? 0 : 2 * sillOverhangMm);
    final contentH = heightMm + (sillAtBottom ? sillDepthMm : 0);

    final widthBreaks = showDimensions ? frameWidthBreaks(frames, widthMm) : const <double>[];
    final heightBreaks = showDimensions ? frameHeightBreaks(frames, widthMm, heightMm) : const <double>[];
    final chainX = widthBreaks.length > 2;
    final chainY = heightBreaks.length > 2;

    final availW = size.width - (showDimensions ? _dimRight + (chainY ? _chainStep : 0) : 0);
    final availH = size.height - (showDimensions ? _dimBottom + (chainX ? _chainStep : 0) : 0);
    if (availW <= 0 || availH <= 0) return null;
    final scale = math.min(availW / contentW, availH / contentH);
    return (
      scale: scale,
      origin: Offset(
        (availW - contentW * scale) / 2 + (sills.isEmpty ? 0 : sillOverhangMm * scale),
        (availH - contentH * scale) / 2,
      ),
      sills: sills,
      sillAtBottom: sillAtBottom,
      widthBreaks: widthBreaks,
      heightBreaks: heightBreaks,
    );
  }

  List<_DimRow> _dimensionRows(_Geometry g) {
    final s = g.scale;
    final drawing = Rect.fromLTWH(g.origin.dx, g.origin.dy, widthMm * s, heightMm * s);
    final bottom = drawing.bottom + (g.sillAtBottom ? sillDepthMm * s : 0);
    final rows = <_DimRow>[];
    var y = bottom + 10;
    if (g.widthBreaks.length > 2) {
      rows.add((
        atPx: [for (final b in g.widthBreaks) drawing.left + b * s],
        mm: g.widthBreaks,
        across: y,
        horizontal: true,
        total: false,
      ));
      y += _chainStep;
    }
    rows.add((atPx: [drawing.left, drawing.right], mm: [0, widthMm], across: y, horizontal: true, total: true));

    var x = drawing.right + 12;
    if (g.heightBreaks.length > 2) {
      rows.add((
        atPx: [for (final b in g.heightBreaks) drawing.top + b * s],
        mm: g.heightBreaks,
        across: x,
        horizontal: false,
        total: false,
      ));
      x += _chainStep;
    }
    rows.add((atPx: [drawing.top, drawing.bottom], mm: [0, heightMm], across: x, horizontal: false, total: true));
    return rows;
  }

  List<FrameDimensionTarget> dimensionTargets(Size size) {
    if (!showDimensions) return const [];
    final g = _geometry(size);
    if (g == null) return const [];
    return [
      for (final row in _dimensionRows(g))
        for (var i = 0; i + 1 < row.atPx.length; i++)
          () {
            final mid = (row.atPx[i] + row.atPx[i + 1]) / 2;
            final half = math.max((row.atPx[i + 1] - row.atPx[i]).abs() / 2, 16.0);
            final lo = row.across - _chainStep / 2;
            final hi = row.across + (row.total ? _chainStep : _chainStep / 2);
            return FrameDimensionTarget(
              horizontal: row.horizontal,
              breaksMm: row.mm,
              index: i,
              rect: row.horizontal
                  ? Rect.fromLTRB(mid - half, lo, mid + half, hi)
                  : Rect.fromLTRB(lo, mid - half, hi, mid + half),
            );
          }(),
    ];
  }

  FrameDimensionTarget? dimensionTargetAt(Size size, Offset point) {
    FrameDimensionTarget? best;
    var bestDistance = double.infinity;
    for (final t in dimensionTargets(size)) {
      if (!t.rect.inflate(6).contains(point)) continue;
      final d = (t.rect.center - point).distanceSquared;
      if (d < bestDistance) {
        best = t;
        bestDistance = d;
      }
    }
    return best;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final g = _geometry(size);
    if (g == null) return;
    final sills = g.sills;
    _s = g.scale;
    final origin = g.origin;

    _compact = size.shortestSide < 110 && size.longestSide < 160;
    final minBand = (size.shortestSide * 0.03).clamp(2.0, 4.5);
    _frameB = math.max(minBand, 58 * _s);
    _mullionB = math.max(minBand * 0.9, 60 * _s);
    _sashB = math.max(minBand * 0.9, 48 * _s);
    _stroke = size.shortestSide < 80 ? 0.7 : 1.0;

    final tint = frameTint;
    _profile = tint ?? const Color(0xFFFBFCFD);
    _profileShade = Color.lerp(_profile, const Color(0xFF8795A6), 0.18)!;
    _line = tint == null ? const Color(0xFF566273) : Color.lerp(tint, Colors.black, 0.6)!;

    Rect px(Rect mm) => Rect.fromLTRB(
          origin.dx + mm.left * _s,
          origin.dy + mm.top * _s,
          origin.dx + mm.right * _s,
          origin.dy + mm.bottom * _s,
        );

    for (var i = 0; i < frames.length; i++) {
      if (sills.contains(i)) _drawSill(canvas, i, px(frames[i].rectMm));
    }
    for (final f in frames) {
      _drawFrame(canvas, px(f.rectMm), f.design);
    }

    if (showDimensions) _drawDimensions(canvas, g);
  }

  Set<int> _sillFrames() => {
        for (var i = 0; i < frames.length; i++)
          if (frames.length == 1 || (frames[i].rectMm.bottom - heightMm).abs() > 0.5) i,
      };

  void _drawSill(Canvas canvas, int index, Rect frame) {
    final rect = frames[index].rectMm;
    bool neighbour(double x) => frames.any((f) =>
        !identical(f, frames[index]) &&
        ((f.rectMm.left - x).abs() < 0.5 || (f.rectMm.right - x).abs() < 0.5) &&
        f.rectMm.bottom > rect.bottom - 0.5);
    final overhang = sillOverhangMm * _s;
    final depth = math.max(3.0, sillDepthMm * _s);
    final slab = Rect.fromLTRB(
      frame.left - (neighbour(rect.left) ? 0 : overhang),
      frame.bottom,
      frame.right + (neighbour(rect.right) ? 0 : overhang),
      frame.bottom + depth,
    );
    canvas.drawRect(
      slab.shift(const Offset(0, 1.5)),
      Paint()..color = Colors.black.withValues(alpha: 0.06),
    );
    canvas.drawRect(
      slab,
      Paint()..shader = ui.Gradient.linear(slab.topLeft, slab.bottomLeft, const [Color(0xFFFFFFFF), Color(0xFFDDE2E8)]),
    );
    canvas.drawRect(slab, _stroked(const Color(0xFF7A8594), _stroke * 0.9));
    final lip = slab.top + depth * 0.38;
    canvas.drawLine(Offset(slab.left, lip), Offset(slab.right, lip),
        _stroked(const Color(0xFF7A8594).withValues(alpha: 0.5), _stroke * 0.7));
  }

  void _drawFrame(Canvas canvas, Rect outer, RomFrameDesign design) {
    final band = math.min(_frameB, outer.shortestSide * 0.2);
    final rise = design.archRiseMm * _s;
    final inner = outer.deflate(band);
    if (inner.isEmpty) return;

    final outerPath = rise > 0 ? _archPath(outer, rise) : (Path()..addRect(outer));
    final innerPath = rise > 0 ? _archPath(inner, math.max(rise - band, 1)) : (Path()..addRect(inner));

    final bars = <Rect>[];
    canvas.save();
    canvas.clipPath(innerPath);
    _drawCell(canvas, design.root, outer, inner, bars);
    canvas.restore();

    final profile = _mergeBars(_combine(PathOperation.difference, outerPath, innerPath), bars, outerPath);
    canvas.drawPath(profile, _profilePaint(outer));
    canvas.drawPath(profile, _stroked(_line, _stroke));

    if (_compact) return;
    final miter = _stroked(_line.withValues(alpha: 0.55), _stroke * 0.8);
    canvas.drawLine(outer.bottomLeft, inner.bottomLeft, miter);
    canvas.drawLine(outer.bottomRight, inner.bottomRight, miter);
    if (rise <= 0) {
      canvas.drawLine(outer.topLeft, inner.topLeft, miter);
      canvas.drawLine(outer.topRight, inner.topRight, miter);
    }
  }

  Path _archPath(Rect r, double rise) {
    final springY = r.top + rise;
    return Path()
      ..moveTo(r.left, r.bottom)
      ..lineTo(r.left, springY)
      ..arcTo(Rect.fromLTRB(r.left, r.top, r.right, springY + rise), math.pi, math.pi, false)
      ..lineTo(r.right, r.bottom)
      ..close();
  }

  Path _mergeBars(Path band, List<Rect> bars, Path clip) {
    if (bars.isEmpty) return band;
    var merged = Path();
    for (final b in bars) {
      final grown = b.width >= b.height
          ? Rect.fromLTRB(b.left - 1, b.top, b.right + 1, b.bottom)
          : Rect.fromLTRB(b.left, b.top - 1, b.right, b.bottom + 1);
      merged = _combine(PathOperation.union, merged, Path()..addRect(grown));
    }
    merged = _combine(PathOperation.intersect, merged, clip);
    return _combine(PathOperation.union, band, merged);
  }

  void _drawCell(Canvas canvas, RomCell cell, Rect cellOuter, Rect opening, List<Rect> bars) {
    if (opening.width <= 0.5 || opening.height <= 0.5) return;
    switch (cell) {
      case RomZone(:final fill):
        switch (fill) {
          case RomFill.glass:
            _drawGlass(canvas, opening);
          case RomFill.panel:
            _drawPanel(canvas, opening);
          case RomFill.lambri:
            _drawLambri(canvas, opening, vertical: true);
          case RomFill.lambriHorizontal:
            _drawLambri(canvas, opening, vertical: false);
        }
      case RomSplit(:final axis, :final positionsMm, :final children):
        _drawSplit(canvas, axis, positionsMm, children, cellOuter, opening, bars);
      case RomWing():
        _drawWing(canvas, cell, cellOuter, opening);
    }
  }

  void _drawSplit(
    Canvas canvas,
    RomAxis axis,
    List<double> positionsMm,
    List<RomCell> children,
    Rect cellOuter,
    Rect opening,
    List<Rect> bars,
  ) {
    final vertical = axis == RomAxis.vertical;
    final start = vertical ? cellOuter.left : cellOuter.top;
    final end = vertical ? cellOuter.right : cellOuter.bottom;
    final lines = [for (final p in positionsMm) start + p * _s];
    final bounds = [start, ...lines, end];
    final half = _mullionB / 2;

    for (var i = 0; i < children.length && i + 1 < bounds.length; i++) {
      final lo = bounds[i];
      final hi = bounds[i + 1];
      final childOuter = vertical
          ? Rect.fromLTRB(lo, cellOuter.top, hi, cellOuter.bottom)
          : Rect.fromLTRB(cellOuter.left, lo, cellOuter.right, hi);
      final openLo = i == 0 ? (vertical ? opening.left : opening.top) : lo + half;
      final openHi = i == children.length - 1 ? (vertical ? opening.right : opening.bottom) : hi - half;
      final childOpening = vertical
          ? Rect.fromLTRB(openLo, opening.top, openHi, opening.bottom)
          : Rect.fromLTRB(opening.left, openLo, opening.right, openHi);
      _drawCell(canvas, children[i], childOuter, childOpening, bars);
    }

    for (final v in lines) {
      bars.add(vertical
          ? Rect.fromLTRB(v - half, opening.top, v + half, opening.bottom)
          : Rect.fromLTRB(opening.left, v - half, opening.right, v + half));
    }
  }

  void _drawWing(Canvas canvas, RomWing wing, Rect cellOuter, Rect opening) {
    final band = math.min(_sashB, opening.shortestSide * 0.22);
    final inner = opening.deflate(band);
    final bars = <Rect>[];
    if (inner.width <= 1 || inner.height <= 1) {
      _drawCell(canvas, wing.content, cellOuter, opening, bars);
      _drawBarsAlone(canvas, bars, opening);
      return;
    }

    _drawCell(canvas, wing.content, cellOuter, inner, bars);

    final outline = Path()..addRect(opening);
    final sashPath = _mergeBars(
      _combine(PathOperation.difference, outline, Path()..addRect(inner)),
      bars,
      outline,
    );
    canvas.drawPath(sashPath, _profilePaint(opening, lighter: true));
    canvas.drawPath(sashPath, _stroked(_line, _stroke * 0.9));
    canvas.drawRect(opening.deflate(0.5), _stroked(_line, _stroke * 1.2));
    _drawOpeningSymbol(canvas, wing, inner, opening, band);
    if (_compact) return;

    final miter = _stroked(_line.withValues(alpha: 0.45), _stroke * 0.7);
    canvas.drawLine(opening.topLeft, inner.topLeft, miter);
    canvas.drawLine(opening.topRight, inner.topRight, miter);
    canvas.drawLine(opening.bottomLeft, inner.bottomLeft, miter);
    canvas.drawLine(opening.bottomRight, inner.bottomRight, miter);
    _drawHinges(canvas, wing, opening, band);
    if (wing.hasHandle) _drawHandle(canvas, wing, opening, band);
  }

  void _drawBarsAlone(Canvas canvas, List<Rect> bars, Rect clip) {
    if (bars.isEmpty) return;
    final path = _mergeBars(Path(), bars, Path()..addRect(clip));
    canvas.drawPath(path, _profilePaint(clip));
    canvas.drawPath(path, _stroked(_line, _stroke * 0.9));
  }

  static const _openingArrow = Color(0xFFF39A1E);

  void _drawOpeningSymbol(Canvas canvas, RomWing wing, Rect g, Rect sash, double band) {
    final stroke = (g.shortestSide * 0.06).clamp(1.2, 5.5).toDouble();
    final paint = Paint()
      ..color = _openingArrow
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;
    final arrow = stroke * 2.8;

    void curve(Offset a, Offset b, Offset corner) {
      final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
      final control = Offset.lerp(mid, corner, 0.85)!;
      final full = Path()
        ..moveTo(a.dx, a.dy)
        ..quadraticBezierTo(control.dx, control.dy, b.dx, b.dy);
      final metric = full.computeMetrics().first;
      final head = math.min(arrow, metric.length * 0.3);
      final trim = head * 0.7;
      if (metric.length <= trim * 2.4) {
        canvas.drawPath(full, paint);
        return;
      }
      canvas.drawPath(metric.extractPath(trim, metric.length - trim), paint);
      final startTan = metric.getTangentForOffset(0)!;
      final endTan = metric.getTangentForOffset(metric.length)!;
      _arrowTip(canvas, a, -startTan.vector, head, _openingArrow);
      _arrowTip(canvas, b, endTan.vector, head, _openingArrow);
    }

    void turn(RomHandleSide handle) {
      final toRight = handle == RomHandleSide.left; 
      final gap = g.width * 0.14;
      final span = math.min(g.width * 0.62, g.height * 0.6);
      final rise = math.min(span * 1.1, g.height * 0.3);
      final handleY = _handleAlong(wing, sash)
          .clamp(g.top + rise * 1.05, math.max(g.top + rise * 1.05, g.bottom - rise * 1.05))
          .toDouble();
      final ax = toRight ? g.left + gap : g.right - gap;
      final bx = ax + (toRight ? span : -span);
      final split = rise * 0.25;
      final upA = Offset(ax, handleY - split);
      final upB = Offset(bx, handleY - rise);
      curve(upA, upB, Offset(upB.dx, upA.dy));
      final downA = Offset(ax, handleY + split);
      final downB = Offset(bx, handleY + rise);
      curve(downA, downB, Offset(downB.dx, downA.dy));
    }

    void tilt(RomHandleSide handle, {double along = 0.5}) {
      final down = handle == RomHandleSide.top;
      final gap = math.max(g.height * 0.1, math.min(60 * _s, g.height * 0.25));
      final span = math.min(g.height * 0.4, g.width * 0.5);
      final side = math.min(span * 0.8, g.width * 0.25);
      final x = g.left + g.width * along;
      final ay = down ? g.top + gap : g.bottom - gap;
      final a = Offset(x - side * 0.15, ay);
      final b = Offset(x + side, ay + (down ? span : -span));
      curve(a, b, Offset(a.dx, b.dy));
    }

    switch (wing.function) {
      case RomWingFunction.tilt:
        tilt(wing.handleSide == RomHandleSide.bottom ? RomHandleSide.bottom : RomHandleSide.top);
      case RomWingFunction.tiltTurn:
        turn(wing.handleSide);
        tilt(RomHandleSide.top, along: wing.handleSide == RomHandleSide.right ? 0.22 : 0.5);
      case RomWingFunction.turn || RomWingFunction.door:
        turn(wing.handleSide);
    }
  }

  void _arrowTip(Canvas canvas, Offset tip, Offset direction, double len, Color color) {
    final d = direction.distance;
    if (d <= 0) return;
    final dir = direction / d;
    final normal = Offset(-dir.dy, dir.dx);
    final base = tip - dir * len;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo((base + normal * len * 0.55).dx, (base + normal * len * 0.55).dy)
      ..lineTo((base - normal * len * 0.55).dx, (base - normal * len * 0.55).dy)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  double _handleAlong(RomWing wing, Rect sash) {
    final side = wing.handleSide;
    final isDoor = wing.function == RomWingFunction.door;
    return switch (side) {
      RomHandleSide.left || RomHandleSide.right => isDoor
          ? (sash.bottom - 1000 * _s).clamp(sash.top + sash.height * 0.3, sash.bottom - sash.height * 0.2)
          : sash.center.dy,
      _ => sash.center.dx,
    };
  }

  RomHandleSide _hingeSide(RomWing wing) => switch (wing.function) {
        RomWingFunction.tilt => wing.handleSide == RomHandleSide.bottom ? RomHandleSide.top : RomHandleSide.bottom,
        _ => wing.handleSide == RomHandleSide.left ? RomHandleSide.right : RomHandleSide.left,
      };

  void _drawHinges(Canvas canvas, RomWing wing, Rect sash, double band) {
    final side = _hingeSide(wing);
    final vertical = side == RomHandleSide.left || side == RomHandleSide.right;
    final length = vertical ? sash.height : sash.width;
    final along = math.max(5.0, math.min(70 * _s, length * 0.14));
    final across = math.max(2.5, band * 0.42);
    final tall = wing.function == RomWingFunction.door || length / _s > 1400;
    final paint = Paint()..color = _metal.withValues(alpha: 0.85);
    for (final t in tall ? const [0.12, 0.5, 0.88] : const [0.14, 0.86]) {
      final c = switch (side) {
        RomHandleSide.left => Offset(sash.left, sash.top + sash.height * t),
        RomHandleSide.right => Offset(sash.right, sash.top + sash.height * t),
        RomHandleSide.top => Offset(sash.left + sash.width * t, sash.top),
        RomHandleSide.bottom => Offset(sash.left + sash.width * t, sash.bottom),
      };
      final rect = vertical
          ? Rect.fromCenter(center: c, width: across, height: along)
          : Rect.fromCenter(center: c, width: along, height: across);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(across / 2)), paint);
    }
  }

  void _drawHandle(Canvas canvas, RomWing wing, Rect sash, double band) {
    final side = wing.handleSide;
    final vertical = side == RomHandleSide.left || side == RomHandleSide.right;
    final isDoor = wing.function == RomWingFunction.door;

    double mm(double v, double minPx) => math.max(minPx, v * _s);

    final alongCenter = _handleAlong(wing, sash);
    final bandMid = switch (side) {
      RomHandleSide.left => sash.left + band / 2,
      RomHandleSide.right => sash.right - band / 2,
      RomHandleSide.top => sash.top + band / 2,
      RomHandleSide.bottom => sash.bottom - band / 2,
    };
    final center = vertical ? Offset(bandMid, alongCenter) : Offset(alongCenter, bandMid);

    final plateLong = mm(isDoor ? 240 : 78, isDoor ? 14 : 8);
    final plateShort = mm(isDoor ? 40 : 32, 4);
    final leverLen = mm(isDoor ? 135 : 120, isDoor ? 9 : 8);
    final leverW = mm(17, 2.2);
    final boss = mm(isDoor ? 16 : 14, 2.4);

    final plate = vertical
        ? Rect.fromCenter(center: center, width: plateShort, height: plateLong)
        : Rect.fromCenter(center: center, width: plateLong, height: plateShort);
    final plateRRect = RRect.fromRectAndRadius(plate, Radius.circular(plateShort * 0.45));
    final outline = _stroked(const Color(0xFF3F4852).withValues(alpha: 0.7), math.max(0.6, _stroke * 0.6));
    canvas.drawRRect(
      plateRRect,
      Paint()
        ..shader = ui.Gradient.linear(
          plate.topLeft,
          plate.bottomRight,
          [Color.lerp(_handleMetal, Colors.white, 0.45)!, _handleMetal],
        ),
    );
    canvas.drawRRect(plateRRect, outline);

    final Offset pivot;
    final Offset tip;
    if (vertical && isDoor) {
      final inward = side == RomHandleSide.right ? -1.0 : 1.0;
      pivot = Offset(center.dx, plate.top + plateLong * 0.26);
      tip = pivot + Offset(inward * leverLen, 0);
    } else if (vertical) {
      pivot = Offset(center.dx, plate.top + plateLong * 0.32);
      tip = pivot + Offset(0, leverLen);
    } else {
      pivot = Offset(plate.left + plateLong * 0.32, center.dy);
      tip = pivot + Offset(leverLen, 0);
    }

    final edge = Paint()
      ..color = const Color(0xFF4A535D)
      ..strokeWidth = leverW + math.max(1.0, _stroke)
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(pivot, tip, edge);
    final leverPaint = Paint()
      ..color = _handleMetal
      ..strokeWidth = leverW
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(pivot, tip, leverPaint);
    canvas.drawCircle(pivot, boss, Paint()..color = const Color(0xFF4A535D));
    canvas.drawCircle(pivot, boss * 0.72, Paint()..color = Color.lerp(_handleMetal, Colors.white, 0.3)!);

    if (isDoor) {
      final keyCenter = vertical
          ? Offset(center.dx, plate.bottom - plateLong * 0.22)
          : Offset(plate.right - plateLong * 0.22, center.dy);
      final keyW = mm(12, 1.6);
      final keyH = mm(26, 3);
      final key = vertical
          ? Rect.fromCenter(center: keyCenter, width: keyW, height: keyH)
          : Rect.fromCenter(center: keyCenter, width: keyH, height: keyW);
      canvas.drawRRect(
        RRect.fromRectAndRadius(key, Radius.circular(keyW / 2)),
        Paint()..color = const Color(0xFF4A535D),
      );
    }
  }

  void _drawGlass(Canvas canvas, Rect r) {
    canvas.drawRect(
      r,
      Paint()..shader = ui.Gradient.linear(r.topLeft, r.bottomRight, const [_glassTop, _glassBottom]),
    );
    final d = r.shortestSide;
    if (!_compact && d > 12) {
      canvas.save();
      canvas.clipRect(r);
      Path strip(double from, double to) => Path()
        ..moveTo(r.left + d * from, r.top)
        ..lineTo(r.left + d * to, r.top)
        ..lineTo(r.left, r.top + d * to)
        ..lineTo(r.left, r.top + d * from)
        ..close();
      canvas.drawPath(strip(0.30, 0.44), Paint()..color = Colors.white.withValues(alpha: 0.38));
      canvas.drawPath(strip(0.52, 0.58), Paint()..color = Colors.white.withValues(alpha: 0.26));
      canvas.restore();
    }
  }

  void _drawPanel(Canvas canvas, Rect r) {
    canvas.drawRect(r, Paint()..color = Color.lerp(_profile, _profileShade, 0.35)!);
  }

  void _drawLambri(Canvas canvas, Rect r, {required bool vertical}) {
    canvas.drawRect(r, Paint()..color = Color.lerp(_profile, _profileShade, 0.2)!);

    final length = vertical ? r.width : r.height;
    final step = math.max(100 * _s, 3.0);
    final count = math.max(2, (length / step).round());
    final gap = length / count;

    final groove = _stroked(_line.withValues(alpha: 0.55), _stroke);
    final shine = _stroked(Colors.white.withValues(alpha: 0.45), _stroke);
    canvas.save();
    canvas.clipRect(r);
    for (var i = 1; i < count; i++) {
      if (vertical) {
        final x = r.left + gap * i;
        canvas.drawLine(Offset(x, r.top), Offset(x, r.bottom), groove);
        if (!_compact) {
          canvas.drawLine(Offset(x + 1, r.top), Offset(x + 1, r.bottom), shine);
        }
      } else {
        final y = r.top + gap * i;
        canvas.drawLine(Offset(r.left, y), Offset(r.right, y), groove);
        if (!_compact) {
          canvas.drawLine(Offset(r.left, y + 1), Offset(r.right, y + 1), shine);
        }
      }
    }
    canvas.restore();
  }

  Color get _dimension => dark ? const Color(0xFFA9B8C9) : const Color(0xFF64758A);

  void _drawDimensions(Canvas canvas, _Geometry g) {
    final paint = _stroked(_dimension.withValues(alpha: 0.7), 1);
    for (final row in _dimensionRows(g)) {
      _chain(canvas, row.atPx, row.mm, row.across, horizontal: row.horizontal, paint: paint, strong: row.total);
    }
  }

  void _chain(
    Canvas canvas,
    List<double> atPx,
    List<double> mm,
    double across, {
    required bool horizontal,
    required Paint paint,
    bool strong = false,
  }) {
    const tick = 4.0;
    Offset pt(double along, [double off = 0]) => horizontal ? Offset(along, across + off) : Offset(across + off, along);
    canvas.drawLine(pt(atPx.first), pt(atPx.last), paint);
    for (final a in atPx) {
      canvas.drawLine(pt(a, -tick), pt(a, tick), paint);
      final c = pt(a);
      canvas.drawLine(c + const Offset(-tick / 2, tick / 2), c + const Offset(tick / 2, -tick / 2), paint);
    }
    for (var i = 0; i + 1 < atPx.length; i++) {
      final text = '${(mm[i + 1] - mm[i]).round()}';
      final room = (atPx[i + 1] - atPx[i]).abs();
      _label(canvas, text, pt((atPx[i] + atPx[i + 1]) / 2), rotate: !horizontal, room: room, strong: strong);
    }
  }

  void _label(Canvas canvas, String text, Offset center,
      {bool rotate = false, double room = double.infinity, bool strong = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: uz(text),
        style: TextStyle(
          color: dimensionAccent ?? _dimension,
          fontSize: strong ? 11 : 10,
          fontWeight: strong || dimensionAccent != null ? FontWeight.w700 : FontWeight.w500,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    if (tp.width + 6 > room) return;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    if (rotate) canvas.rotate(-math.pi / 2);
    final accent = dimensionAccent;
    final box = Rect.fromCenter(center: Offset.zero, width: tp.width + (accent == null ? 8 : 12), height: tp.height + 2);
    final rrect = RRect.fromRectAndRadius(box, Radius.circular(accent == null ? 4 : box.height / 2));
    canvas.drawRRect(rrect, Paint()..color = dark ? const Color(0xFF1F2A36) : const Color(0xFFF4F7FA));
    if (accent != null) {
      canvas.drawRRect(rrect, Paint()..color = accent.withValues(alpha: dark ? 0.22 : 0.10));
      canvas.drawRRect(rrect, _stroked(accent.withValues(alpha: 0.45), 0.8));
    }
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  static Path _combine(PathOperation op, Path a, Path b) =>
      Path.combine(op, a, b)..fillType = PathFillType.evenOdd;

  Paint _profilePaint(Rect r, {bool lighter = false}) {
    final top = lighter ? Color.lerp(_profile, Colors.white, frameTint == null ? 0.5 : 0.12)! : _profile;
    final bottom = Color.lerp(_profile, _profileShade, lighter ? 0.45 : 0.7)!;
    return Paint()..shader = ui.Gradient.linear(r.topLeft, r.bottomLeft, [top, bottom]);
  }

  Paint _stroked(Color color, double width) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width;

  @override
  bool shouldRepaint(covariant FrameDrawingPainter old) =>
      old.widthMm != widthMm ||
      old.heightMm != heightMm ||
      old.frameTint != frameTint ||
      old.showDimensions != showDimensions ||
      old.showSill != showSill ||
      old.dark != dark ||
      old.dimensionAccent != dimensionAccent ||
      !identical(old.frames, frames) && !_sameFrames(old.frames, frames);

  static bool _sameFrames(List<FramePlacement> a, List<FramePlacement> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].rectMm != b[i].rectMm || !identical(a[i].design, b[i].design)) return false;
    }
    return true;
  }
}
