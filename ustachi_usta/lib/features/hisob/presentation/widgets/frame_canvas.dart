
library;

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:ustachi/core/utils/extensions.dart';
import 'package:ustachi/features/hisob/domain/hisob_dimensions.dart';
import 'package:ustachi/features/hisob/domain/hisob_impost_drop.dart';
import 'package:ustachi_hisob/ustachi_hisob.dart' as hisob;

class FramePalette {
  const FramePalette({required this.selected, required this.dimension, required this.error});

  final Color selected;
  final Color dimension;
  final Color error;

  factory FramePalette.of(BuildContext context) {
    final c = context.color;
    return FramePalette(
      selected: c.categorizedColor.primary,
      dimension: c.neutral.textMuted,
      error: Colors.redAccent,
    );
  }
}

class FrameCanvas extends StatelessWidget {
  const FrameCanvas({
    super.key,
    required this.design,
    required this.spec,
    this.balconyDoor = false,
    this.selected,
    this.onTapCell,
    this.onTapWidth,
    this.onTapHeight,
    this.onTapSegment,
    this.onTapArch,
    this.showDimensions = true,
    this.frameColor,
    this.onDropImpost,
  });

  final hisob.FrameDesign design;
  final hisob.SeriesSpec spec;
  final bool balconyDoor;

  final hisob.CellPath? selected;

  final ValueChanged<hisob.CellPath?>? onTapCell;
  final VoidCallback? onTapWidth;
  final VoidCallback? onTapHeight;

  final void Function(hisob.Axis axis, int index, ChainSide? side)? onTapSegment;

  final void Function(bool startPoint)? onTapArch;
  final bool showDimensions;

  final Color? frameColor;

  final void Function(ImpostTool tool, double xMm, double yMm)? onDropImpost;

  @override
  Widget build(BuildContext context) {
    final palette = FramePalette.of(context);
    List<hisob.CellBox>? boxes;
    String? error;
    try {
      boxes = hisob.layoutCells(design, spec, balconyDoor: balconyDoor);
    } on hisob.DesignException catch (e) {
      error = e.message;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final geometry = _Geometry(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          design: design,
          showDimensions: showDimensions,
        );

        void handleTap(Offset local) {
          final tap = onTapCell;
          if (tap == null || boxes == null) return;
          final mm = geometry.toMm(local);
          final hit = hisob.hitTest(boxes, mm.dx, mm.dy);

          final cell = hit?.cell;
          tap(cell is hisob.Zone && cell.fill == hisob.Fill.cutout ? null : hit?.path);
        }

        final stack = Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (d) => handleTap(d.localPosition),
              child: CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: _FramePainter(
                  design: design,
                  geometry: geometry,
                  palette: palette,
                  selected: selected,
                  showDimensions: showDimensions,
                  textStyle: context.text.label,
                  hasError: error != null,
                  frameColor: frameColor,
                ),
              ),
            ),

            if (showDimensions && onTapWidth != null)
              Positioned(
                left: geometry.originX,
                top: math.max(0.0, geometry.originY - _Geometry.dimBand),
                width: geometry.drawWidth,
                height: _Geometry.dimBand,
                child: _TapZone(onTap: onTapWidth!),
              ),
            if (showDimensions && onTapHeight != null)
              Positioned(
                left: math.max(0.0, geometry.heightLabelX - _Geometry.dimBand + 12),
                top: geometry.originY,
                width: _Geometry.dimBand,
                height: geometry.drawHeight,
                child: _TapZone(onTap: onTapHeight!),
              ),

            if (showDimensions && onTapArch != null && design.archRiseMm > 0 && geometry.chains.right.length < 3) ...[
              Positioned(
                left: geometry.originX + geometry.drawWidth,
                top: geometry.originY,
                width: _Geometry.dimBand,
                height: design.archRiseMm * geometry.scale,
                child: _TapZone(onTap: () => onTapArch!(false)),
              ),
              Positioned(
                left: geometry.originX + geometry.drawWidth,
                top: geometry.originY + design.archRiseMm * geometry.scale,
                width: _Geometry.dimBand,
                height: (design.heightMm - design.archRiseMm) * geometry.scale,
                child: _TapZone(onTap: () => onTapArch!(true)),
              ),
            ],

            if (showDimensions && onTapSegment != null) ...[
              for (final (i, seg) in _segments(geometry.chains.right).indexed)
                Positioned(
                  left: geometry.originX + geometry.drawWidth,
                  top: geometry.originY + seg.$1 * geometry.scale,
                  width: _Geometry.dimBand,
                  height: (seg.$2 - seg.$1) * geometry.scale,
                  child: _TapZone(
                    onTap: () => onTapSegment!(hisob.Axis.horizontal, i, geometry.chains.rightSide),
                  ),
                ),
              for (final (i, seg) in _segments(geometry.chains.left ?? const []).indexed)
                Positioned(
                  left: geometry.originX - _Geometry.dimBand,
                  top: geometry.originY + seg.$1 * geometry.scale,
                  width: _Geometry.dimBand,
                  height: (seg.$2 - seg.$1) * geometry.scale,
                  child: _TapZone(onTap: () => onTapSegment!(hisob.Axis.horizontal, i, ChainSide.start)),
                ),
              for (final (i, seg) in _segments(lineMarks(design, hisob.Axis.vertical)).indexed)
                Positioned(
                  left: geometry.originX + seg.$1 * geometry.scale,
                  top: geometry.originY + geometry.drawHeight,
                  width: (seg.$2 - seg.$1) * geometry.scale,
                  height: _Geometry.dimBand,
                  child: _TapZone(onTap: () => onTapSegment!(hisob.Axis.vertical, i, null)),
                ),
            ],
          ],
        );
        final drop = onDropImpost;
        if (drop == null) return stack;
        return _ImpostDropLayer(
          design: design,
          spec: spec,
          balconyDoor: balconyDoor,
          geometry: geometry,
          palette: palette,
          textStyle: context.text.label,
          onDrop: drop,
          child: stack,
        );
      },
    );
  }
}

const double impostDragLift = 56;

class _ImpostDropLayer extends StatefulWidget {
  const _ImpostDropLayer({
    required this.design,
    required this.spec,
    required this.balconyDoor,
    required this.geometry,
    required this.palette,
    required this.textStyle,
    required this.onDrop,
    required this.child,
  });

  final hisob.FrameDesign design;
  final hisob.SeriesSpec spec;
  final bool balconyDoor;
  final _Geometry geometry;
  final FramePalette palette;
  final TextStyle textStyle;
  final void Function(ImpostTool tool, double xMm, double yMm) onDrop;
  final Widget child;

  @override
  State<_ImpostDropLayer> createState() => _ImpostDropLayerState();
}

class _ImpostDropLayerState extends State<_ImpostDropLayer> {
  ImpostDrop? _plan;

  Offset? _mm(Offset global) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return null;
    final local = box.globalToLocal(global - const Offset(0, impostDragLift));
    return widget.geometry.toMm(local);
  }

  void _hover(ImpostTool tool, Offset global) {
    final mm = _mm(global);
    final plan = mm == null
        ? null
        : planImpost(widget.design, widget.spec, tool.axis, mm.dx, mm.dy,
            balconyDoor: widget.balconyDoor, pair: tool.pair, chiftQuloq: tool.chiftQuloq);
    setState(() => _plan = plan);
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<ImpostTool>(
      onMove: (d) => _hover(d.data, d.offset),
      onLeave: (_) => setState(() => _plan = null),
      onAcceptWithDetails: (d) {
        final mm = _mm(d.offset);
        setState(() => _plan = null);
        if (mm != null) widget.onDrop(d.data, mm.dx, mm.dy);
      },
      builder: (context, _, __) => Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          if (_plan != null)
            IgnorePointer(
              child: CustomPaint(
                painter: _ImpostPreviewPainter(
                  plan: _plan!,
                  geometry: widget.geometry,
                  palette: widget.palette,
                  textStyle: widget.textStyle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ImpostPreviewPainter extends CustomPainter {
  _ImpostPreviewPainter({required this.plan, required this.geometry, required this.palette, required this.textStyle});

  final ImpostDrop plan;
  final _Geometry geometry;
  final FramePalette palette;
  final TextStyle textStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final g = geometry;
    final color = plan.ok ? palette.selected : palette.error;
    final r = plan.region;
    final rect = Rect.fromLTRB(
      g.originX + r.l * g.scale,
      g.originY + r.t * g.scale,
      g.originX + r.r * g.scale,
      g.originY + r.b * g.scale,
    );
    canvas.drawRect(rect, Paint()..color = color.withValues(alpha: 0.10));
    canvas.drawRect(
      rect,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final vertical = plan.axis == hisob.Axis.vertical;
    final base = vertical ? g.originX : g.originY;
    final lines = [for (final m in plan.positionsMm) base + m * g.scale];
    final bar = Paint()
      ..color = color
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    for (final p in lines) {
      final a = vertical ? Offset(p, rect.top) : Offset(rect.left, p);
      final b = vertical ? Offset(p, rect.bottom) : Offset(rect.right, p);
      canvas.drawLine(a, b, bar);
    }

    final style = textStyle.copyWith(color: Colors.white, fontWeight: FontWeight.w700);
    void label(String text, Offset at) {
      final tp = TextPainter(text: TextSpan(text: text, style: style), textDirection: TextDirection.ltr)..layout();
      final box = Rect.fromCenter(center: at, width: tp.width + 10, height: tp.height + 4);
      canvas.drawRRect(RRect.fromRectAndRadius(box, const Radius.circular(6)), Paint()..color = color);
      tp.paint(canvas, box.topLeft + const Offset(5, 2));
    }

    final bounds = [vertical ? rect.left : rect.top, ...lines, vertical ? rect.right : rect.bottom];
    final sizes = plan.segmentsMm;
    for (var i = 0; i < sizes.length && i + 1 < bounds.length; i++) {
      final mid = (bounds[i] + bounds[i + 1]) / 2;
      label('${sizes[i].round()}', vertical ? Offset(mid, rect.center.dy) : Offset(rect.center.dx, mid));
    }
  }

  @override
  bool shouldRepaint(covariant _ImpostPreviewPainter old) => true;
}

class _HeightChains {
  factory _HeightChains.of(hisob.FrameDesign d) {
    final all = lineMarks(d, hisob.Axis.horizontal);
    final right = lineMarks(d, hisob.Axis.horizontal, side: ChainSide.end);
    final left = lineMarks(d, hisob.Axis.horizontal, side: ChainSide.start);
    bool same(List<double> a, List<double> b) =>
        a.length == b.length && [for (var i = 0; i < a.length; i++) (a[i] - b[i]).abs() < 0.5].every((x) => x);

    if (right.length < 3 && left.length < 3) return _HeightChains._(all, null, null);
    if (same(left, right)) return _HeightChains._(right, same(all, right) ? null : ChainSide.end, null);
    return _HeightChains._(right, ChainSide.end, left.length < 3 ? null : left);
  }

  const _HeightChains._(this.right, this.rightSide, this.left);

  final List<double> right;

  final ChainSide? rightSide;

  final List<double>? left;
}

List<(double, double)> _segments(List<double> marks) =>
    marks.length < 3 ? const [] : [for (var i = 0; i + 1 < marks.length; i++) (marks[i], marks[i + 1])];

class _TapZone extends StatelessWidget {
  const _TapZone({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) =>
      GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: const SizedBox.expand());
}

class _Geometry {
  _Geometry({required this.size, required this.design, required this.showDimensions})
      : chains = _HeightChains.of(design) {

    final leftChain = showDimensions && chains.left != null;
    final band = showDimensions ? dimBand : 4.0;
    final left = leftChain ? 2 * dimBand : band;

    final right = showDimensions ? dimBand : 4.0;
    final availW = math.max(1.0, size.width - left - right);

    final bottom = showDimensions ? dimBand : 4.0;
    final availH = math.max(1.0, size.height - band - bottom);
    scale = math.min(availW / design.widthMm, availH / design.heightMm);
    drawWidth = design.widthMm * scale;
    drawHeight = design.heightMm * scale;
    originX = left + (availW - drawWidth) / 2;
    originY = band + (availH - drawHeight) / 2;
    heightLabelX = originX - 12 - (leftChain ? dimBand : 0);
  }

  static const double dimBand = 30;

  final Size size;
  final hisob.FrameDesign design;
  final bool showDimensions;
  final _HeightChains chains;

  late final double heightLabelX;

  late final double scale;
  late final double drawWidth;
  late final double drawHeight;
  late final double originX;
  late final double originY;

  Offset toMm(Offset local) => Offset((local.dx - originX) / scale, (local.dy - originY) / scale);
}

class _FramePainter extends CustomPainter {
  _FramePainter({
    required this.design,
    required this.geometry,
    required this.palette,
    required this.selected,
    required this.showDimensions,
    required this.textStyle,
    required this.hasError,
    this.frameColor,
  });

  final hisob.FrameDesign design;
  final _Geometry geometry;
  final FramePalette palette;
  final hisob.CellPath? selected;
  final bool showDimensions;
  final TextStyle textStyle;
  final bool hasError;
  final Color? frameColor;

  static const _white = Color(0xFFFBFCFD);

  Color get _profile => frameColor ?? _white;
  Color get _profileShade => Color.lerp(_profile, const Color(0xFF8795A6), frameColor == null ? 0.18 : 0.12)!;
  static const _line = Color(0xFF566273);
  static const _glassTop = Color(0xFFE9F4FB);
  static const _glassBottom = Color(0xFFB4D6EC);
  static const _metal = Color(0xFF38414B);

  static const _handleMetal = Color(0xFFC9CFD6);

  static const _openingArrow = Color(0xFFF39A1E);

  late double _s;
  late double _frameB;
  late double _mullionB;
  late double _sashB;
  late double _stroke;

  late bool _compact;

  Rect? _selectedRect;

  final List<Rect> _chiftBars = [];

  final List<Rect> _balconyBars = [];

  void _drawChiftQuloq(Canvas canvas) {
    final paint = _stroked(_metal, math.max(1.2, _stroke * 1.4));
    for (final b in _balconyBars) {
      if (b.width < b.height) {
        canvas.drawLine(Offset(b.center.dx, b.top), Offset(b.center.dx, b.bottom), paint);
      } else {
        canvas.drawLine(Offset(b.left, b.center.dy), Offset(b.right, b.center.dy), paint);
      }
    }
    for (final b in _chiftBars) {
      if (b.width < b.height) {
        final d = b.width * 0.22;
        canvas.drawLine(Offset(b.center.dx - d, b.top), Offset(b.center.dx - d, b.bottom), paint);
        canvas.drawLine(Offset(b.center.dx + d, b.top), Offset(b.center.dx + d, b.bottom), paint);
      } else {
        final d = b.height * 0.22;
        canvas.drawLine(Offset(b.left, b.center.dy - d), Offset(b.right, b.center.dy - d), paint);
        canvas.drawLine(Offset(b.left, b.center.dy + d), Offset(b.right, b.center.dy + d), paint);
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    _selectedRect = null;
    _chiftBars.clear();
    _balconyBars.clear();
    final g = geometry;
    if (g.drawWidth <= 0 || g.drawHeight <= 0) return;

    final outer = Rect.fromLTWH(g.originX, g.originY, g.drawWidth, g.drawHeight);
    _s = g.scale;

    _compact = size.shortestSide < 110 && size.longestSide < 160;
    final minBand = (size.shortestSide * 0.03).clamp(2.0, 4.5);
    _frameB = math.max(minBand, 58 * _s);
    _mullionB = math.max(minBand * 0.9, 60 * _s);
    _sashB = math.max(minBand * 0.9, 48 * _s);
    _stroke = size.shortestSide < 80 ? 0.7 : 1.0;

    final cutouts = _cutoutRects(design);
    if (cutouts.isNotEmpty) canvas.saveLayer(Offset.zero & size, Paint());
    _drawFrame(canvas, outer, design, const []);
    if (cutouts.isNotEmpty) {
      final half = _mullionB / 2;
      final clear = Paint()..blendMode = BlendMode.clear;
      final holes = <Rect>[];
      for (final c in cutouts) {
        final leftSide = c.left < 0.5;
        final r = Rect.fromLTRB(
          leftSide ? outer.left - 1 : g.originX + c.left * _s + half,
          g.originY + c.top * _s + half,
          leftSide ? g.originX + c.right * _s - half : outer.right + 1,
          outer.bottom + 1,
        );
        canvas.drawRect(r, clear);
        holes.add(r);
      }
      canvas.restore();

      final edge = _stroked(hasError ? palette.error : _line, hasError ? 2 : _stroke);
      for (final r in holes) {
        final leftSide = r.left < outer.left;
        canvas.drawLine(Offset(r.left, r.top), Offset(r.right, r.top), edge);
        final x = leftSide ? r.right : r.left;
        canvas.drawLine(Offset(x, r.top), Offset(x, outer.bottom), edge);
      }
    }
    _drawChiftQuloq(canvas);
    if (_selectedRect case final r?) {
      canvas.drawRect(r, Paint()..color = palette.selected.withValues(alpha: .18));
      canvas.drawRect(
        r,
        Paint()
          ..color = palette.selected
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
    if (showDimensions) _drawDimensions(canvas);
  }

  void _drawFrame(Canvas canvas, Rect outer, hisob.FrameDesign design, hisob.CellPath path) {
    final band = math.min(_frameB, outer.shortestSide * 0.2);
    final rise = design.archRiseMm * _s;
    final inner = outer.deflate(band);
    if (inner.isEmpty) return;

    final outerPath = rise > 0 ? _archPath(outer, rise) : (Path()..addRect(outer));
    final innerPath = rise > 0 ? _archPath(inner, math.max(rise - band, 1)) : (Path()..addRect(inner));

    final bars = <Rect>[];
    canvas.save();
    canvas.clipPath(innerPath);
    _drawCell(canvas, design.root, outer, inner, bars, path);
    canvas.restore();

    final profile = _mergeBars(_combine(PathOperation.difference, outerPath, innerPath), bars, outerPath);
    canvas.drawPath(profile, _profilePaint(outer));
    canvas.drawPath(profile, _stroked(hasError ? palette.error : _line, hasError ? 2 : _stroke));

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

  void _drawCell(
    Canvas canvas,
    hisob.Cell cell,
    Rect cellOuter,
    Rect opening,
    List<Rect> bars,
    hisob.CellPath path,
  ) {
    if (opening.width <= 0.5 || opening.height <= 0.5) return;
    if (selected != null && _samePath(path, selected!)) _selectedRect = opening;
    switch (cell) {
      case hisob.Zone(:final fill):
        switch (fill) {
          case hisob.Fill.glass:
            _drawGlass(canvas, opening);
          case hisob.Fill.panel:
            _drawPanel(canvas, opening);
          case hisob.Fill.lambriVertical:
            _drawLambri(canvas, opening, vertical: true);
          case hisob.Fill.lambriHorizontal:
            _drawLambri(canvas, opening, vertical: false);
          case hisob.Fill.cutout:
            break; 
        }
      case hisob.Split(:final axis, :final positionsMm, :final children, :final balcony):
        _drawSplit(canvas, axis, positionsMm, children, cellOuter, opening, bars, path);

        if (cell.hasChift && axis == hisob.Axis.vertical && !_compact) {
          final own = bars.sublist(bars.length - positionsMm.length);
          for (var i = 0; i < own.length; i++) {
            if (cell.isChift(i)) _chiftBars.add(own[i]);
          }
        }

        if (balcony && !_compact) _balconyBars.addAll(bars.sublist(bars.length - positionsMm.length));
      case hisob.Wing():
        _drawWing(canvas, cell, cellOuter, opening, path);
    }
  }

  void _drawSplit(
    Canvas canvas,
    hisob.Axis axis,
    List<double> positionsMm,
    List<hisob.Cell> children,
    Rect cellOuter,
    Rect opening,
    List<Rect> bars,
    hisob.CellPath path,
  ) {
    final vertical = axis == hisob.Axis.vertical;
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
      _drawCell(canvas, children[i], childOuter, childOpening, bars, [...path, i]);
    }

    for (final v in lines) {
      bars.add(vertical
          ? Rect.fromLTRB(v - half, opening.top, v + half, opening.bottom)
          : Rect.fromLTRB(opening.left, v - half, opening.right, v + half));
    }
  }

  void _drawWing(Canvas canvas, hisob.Wing wing, Rect cellOuter, Rect opening, hisob.CellPath path) {
    final band = math.min(_sashB, opening.shortestSide * 0.22);
    final inner = opening.deflate(band);
    final bars = <Rect>[];
    if (inner.width <= 1 || inner.height <= 1) {
      _drawCell(canvas, wing.content, cellOuter, opening, bars, [...path, 0]);
      _drawBarsAlone(canvas, bars, opening);
      return;
    }

    _drawCell(canvas, wing.content, cellOuter, inner, bars, [...path, 0]);

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

  void _drawOpeningSymbol(Canvas canvas, hisob.Wing wing, Rect g, Rect sash, double band) {
    final stroke = (g.shortestSide * 0.06).clamp(1.2, 5.5).toDouble();
    final paint = Paint()
      ..color = _openingArrow
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;
    final arrow = stroke * 2.8;

    void curve(Offset a, Offset b, Offset corner) {
      final full = Path()
        ..moveTo(a.dx, a.dy)
        ..lineTo(b.dx, b.dy);
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
      _arrowTip(canvas, a, -startTan.vector, head);
      _arrowTip(canvas, b, endTan.vector, head);
    }

    double turn(hisob.WingSide handle, {double room = 1}) {
      final toRight = handle == hisob.WingSide.left; 
      final gap = g.width * 0.14;
      final span = math.min(g.width * 0.62, g.height * 0.6);
      final rise = math.min(span * 1.1, g.height * 0.3) * room;
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
      return handleY - rise;
    }

    void tilt(hisob.WingSide handle, {double? limitY}) {
      final down = handle == hisob.WingSide.top;
      final gap = math.max(g.height * 0.1, math.min(60 * _s, g.height * 0.25));
      var span = math.min(g.height * 0.4, g.width * 0.5);
      final ay = down ? g.top + gap : g.bottom - gap;
      if (limitY != null && down) span = math.min(span, limitY - stroke * 2.5 - ay);
      if (span < stroke * 5) return;
      final x = g.center.dx;
      final a = Offset(x, ay);
      final b = Offset(x, ay + (down ? span : -span));
      curve(a, b, a);
    }

    switch (wing.kind) {
      case hisob.WingKind.tilt:
        tilt(wing.handleSide == hisob.WingSide.bottom ? hisob.WingSide.bottom : hisob.WingSide.top);
      case hisob.WingKind.tiltTurn:
        final top = turn(wing.handleSide, room: 0.6);
        tilt(hisob.WingSide.top, limitY: top);
      case hisob.WingKind.turn || hisob.WingKind.door:
        turn(wing.handleSide);
    }
  }

  void _arrowTip(Canvas canvas, Offset tip, Offset direction, double len) {
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
    canvas.drawPath(path, Paint()..color = _openingArrow);
  }

  double _handleAlong(hisob.Wing wing, Rect sash) {
    final side = wing.handleSide;
    final isDoor = wing.kind == hisob.WingKind.door;
    return switch (side) {
      hisob.WingSide.left || hisob.WingSide.right => isDoor
          ? (sash.bottom - 1000 * _s).clamp(sash.top + sash.height * 0.3, sash.bottom - sash.height * 0.2)
          : sash.center.dy,
      _ => sash.center.dx,
    };
  }

  hisob.WingSide _hingeSide(hisob.Wing wing) => switch (wing.kind) {
        hisob.WingKind.tilt =>
          wing.handleSide == hisob.WingSide.bottom ? hisob.WingSide.top : hisob.WingSide.bottom,
        _ => wing.handleSide == hisob.WingSide.left ? hisob.WingSide.right : hisob.WingSide.left,
      };

  void _drawHinges(Canvas canvas, hisob.Wing wing, Rect sash, double band) {
    final side = _hingeSide(wing);
    final vertical = side == hisob.WingSide.left || side == hisob.WingSide.right;
    final length = vertical ? sash.height : sash.width;

    final along = _compact ? math.max(5.0, length * 0.12) : math.max(18.0, math.min(130 * _s, length * 0.18));
    final across = _compact ? math.max(2.5, band * 0.5) : math.max(7.0, band * 1.0);
    final tall = wing.kind == hisob.WingKind.door || length / _s > 1400;
    for (final t in tall ? const [0.12, 0.5, 0.88] : const [0.14, 0.86]) {
      final c = switch (side) {
        hisob.WingSide.left => Offset(sash.left, sash.top + sash.height * t),
        hisob.WingSide.right => Offset(sash.right, sash.top + sash.height * t),
        hisob.WingSide.top => Offset(sash.left + sash.width * t, sash.top),
        hisob.WingSide.bottom => Offset(sash.left + sash.width * t, sash.bottom),
      };
      final rect = vertical
          ? Rect.fromCenter(center: c, width: across, height: along)
          : Rect.fromCenter(center: c, width: along, height: across);
      final rrect = RRect.fromRectAndRadius(rect, Radius.circular(across / 2));
      canvas.drawRRect(
        rrect,
        Paint()
          ..shader = ui.Gradient.linear(
            vertical ? rect.centerLeft : rect.topCenter,
            vertical ? rect.centerRight : rect.bottomCenter,
            [const Color(0xFFEEF1F4), _handleMetal, const Color(0xFF8E98A3)],
            [0, 0.5, 1],
          ),
      );
      canvas.drawRRect(rrect, _stroked(_metal, _compact ? 0.6 : 1.1));
      if (_compact) continue;

      final cap = _stroked(_metal.withValues(alpha: 0.8), 1.0);
      if (vertical) {
        canvas.drawLine(Offset(rect.left + 1, rect.top + across * 0.55), Offset(rect.right - 1, rect.top + across * 0.55), cap);
        canvas.drawLine(Offset(rect.left + 1, rect.bottom - across * 0.55), Offset(rect.right - 1, rect.bottom - across * 0.55), cap);
        canvas.drawLine(Offset(rect.center.dx, rect.top + across), Offset(rect.center.dx, rect.bottom - across), cap);
      } else {
        canvas.drawLine(Offset(rect.left + across * 0.55, rect.top + 1), Offset(rect.left + across * 0.55, rect.bottom - 1), cap);
        canvas.drawLine(Offset(rect.right - across * 0.55, rect.top + 1), Offset(rect.right - across * 0.55, rect.bottom - 1), cap);
        canvas.drawLine(Offset(rect.left + across, rect.center.dy), Offset(rect.right - across, rect.center.dy), cap);
      }
    }
  }

  void _drawHandle(Canvas canvas, hisob.Wing wing, Rect sash, double band) {
    final side = wing.handleSide;
    final vertical = side == hisob.WingSide.left || side == hisob.WingSide.right;
    final isDoor = wing.kind == hisob.WingKind.door;

    double mm(double v, double minPx) => math.max(minPx, v * _s);

    final alongCenter = _handleAlong(wing, sash);
    final bandMid = switch (side) {
      hisob.WingSide.left => sash.left + band / 2,
      hisob.WingSide.right => sash.right - band / 2,
      hisob.WingSide.top => sash.top + band / 2,
      hisob.WingSide.bottom => sash.bottom - band / 2,
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
      final inward = side == hisob.WingSide.right ? -1.0 : 1.0;
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
        if (!_compact) canvas.drawLine(Offset(x + 1, r.top), Offset(x + 1, r.bottom), shine);
      } else {
        final y = r.top + gap * i;
        canvas.drawLine(Offset(r.left, y), Offset(r.right, y), groove);
        if (!_compact) canvas.drawLine(Offset(r.left, y + 1), Offset(r.right, y + 1), shine);
      }
    }
    canvas.restore();
  }

  void _drawDimensions(Canvas canvas) {
    final g = geometry;
    final line = Paint()
      ..color = palette.dimension
      ..strokeWidth = 1;
    final style = textStyle.copyWith(color: palette.dimension, fontWeight: FontWeight.w600);

    final y = g.originY - 12;
    canvas.drawLine(Offset(g.originX, y), Offset(g.originX + g.drawWidth, y), line);
    for (final x in [g.originX, g.originX + g.drawWidth]) {
      canvas.drawLine(Offset(x, y - 4), Offset(x, y + 4), line);
    }
    _text(canvas, '${design.widthMm.round()}', Offset(g.originX + g.drawWidth / 2, y - 9), style, center: true);

    final x = g.heightLabelX;
    canvas.drawLine(Offset(x, g.originY), Offset(x, g.originY + g.drawHeight), line);
    for (final yy in [g.originY, g.originY + g.drawHeight]) {
      canvas.drawLine(Offset(x - 4, yy), Offset(x + 4, yy), line);
    }
    canvas.save();
    canvas.translate(x - 9, g.originY + g.drawHeight / 2);
    canvas.rotate(-math.pi / 2);
    _text(canvas, '${design.heightMm.round()}', Offset.zero, style, center: true);
    canvas.restore();

    _drawHeightChain(canvas, line, style);
    _drawArchDimension(canvas, line, style);
  }

  void _drawArchDimension(Canvas canvas, Paint line, TextStyle style) {
    final rise = design.archRiseMm;
    if (rise <= 0) return;
    final g = geometry;
    final springY = g.originY + rise * g.scale;
    final centerX = g.originX + g.drawWidth / 2;

    final mark = Paint()
      ..color = palette.dimension
      ..strokeWidth = 1.5;
    for (final x in [g.originX, g.originX + g.drawWidth]) {
      canvas.drawLine(Offset(x - 6, springY), Offset(x + 6, springY), mark);
      canvas.drawCircle(Offset(x, springY), 2.5, Paint()..color = palette.dimension);
    }

    const dash = 6.0;
    const gap = 4.0;
    for (var y = g.originY; y < springY; y += dash + gap) {
      canvas.drawLine(Offset(centerX, y), Offset(centerX, math.min(y + dash, springY)), mark);
    }
    for (final y in [g.originY, springY]) {
      canvas.drawLine(Offset(centerX - 4, y), Offset(centerX + 4, y), mark);
    }
    if (rise * g.scale >= 22) {
      final label = '${rise.round()}';
      final tp = TextPainter(text: TextSpan(text: label, style: style), textDirection: TextDirection.ltr)..layout();
      final at = Offset(centerX + 6, g.originY + rise * g.scale / 2 - tp.height / 2);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(at.dx - 3, at.dy - 1, tp.width + 6, tp.height + 2),
          const Radius.circular(4),
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.85),
      );
      tp.paint(canvas, at);
    }

    if (g.chains.right.length < 3) {
      final x = g.originX + g.drawWidth + 12;
      canvas.drawLine(Offset(x, g.originY), Offset(x, g.originY + g.drawHeight), line);
      final ys = [0.0, rise, design.heightMm];
      for (final m in ys) {
        final yy = g.originY + m * g.scale;
        canvas.drawLine(Offset(x - 4, yy), Offset(x + 4, yy), line);
      }
      for (var i = 0; i < 2; i++) {
        final len = ys[i + 1] - ys[i];
        if (len * g.scale < 22) continue;
        canvas.save();
        canvas.translate(x + 9, g.originY + (ys[i] + len / 2) * g.scale);
        canvas.rotate(-math.pi / 2);
        _text(canvas, '${len.round()}', Offset.zero, style, center: true);
        canvas.restore();
      }
    }
  }

  void _drawHeightChain(Canvas canvas, Paint line, TextStyle style) {
    final g = geometry;

    void heightChain(List<double> ys, double x, double textDx) {
      if (ys.length <= 2) return;
      canvas.drawLine(Offset(x, g.originY), Offset(x, g.originY + g.drawHeight), line);
      for (final m in ys) {
        final yy = g.originY + m * g.scale;
        canvas.drawLine(Offset(x - 4, yy), Offset(x + 4, yy), line);
      }
      for (var i = 0; i < ys.length - 1; i++) {
        final len = ys[i + 1] - ys[i];

        if (len * g.scale < 22) continue;
        canvas.save();
        canvas.translate(x + textDx, g.originY + (ys[i] + len / 2) * g.scale);
        canvas.rotate(-math.pi / 2);
        _text(canvas, '${len.round()}', Offset.zero, style, center: true);
        canvas.restore();
      }
    }

    heightChain(g.chains.right, g.originX + g.drawWidth + 12, 9);
    final left = g.chains.left;
    if (left != null) heightChain(left, g.originX - 12, -9);

    final xs = lineMarks(design, hisob.Axis.vertical);
    if (xs.length > 2) {
      final y = g.originY + g.drawHeight + 12;
      canvas.drawLine(Offset(g.originX, y), Offset(g.originX + g.drawWidth, y), line);
      for (final m in xs) {
        final xx = g.originX + m * g.scale;
        canvas.drawLine(Offset(xx, y - 4), Offset(xx, y + 4), line);
      }
      for (var i = 0; i < xs.length - 1; i++) {
        final len = xs[i + 1] - xs[i];
        if (len * g.scale < 26) continue;
        _text(canvas, '${len.round()}', Offset(g.originX + (xs[i] + len / 2) * g.scale, y + 9), style, center: true);
      }
    }
  }

  void _text(Canvas canvas, String text, Offset at, TextStyle style, {bool center = false}) {
    final tp = TextPainter(text: TextSpan(text: text, style: style), textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, center ? at - Offset(tp.width / 2, tp.height / 2) : at);
  }

  bool _samePath(hisob.CellPath a, hisob.CellPath b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static Path _combine(PathOperation op, Path a, Path b) =>
      Path.combine(op, a, b)..fillType = PathFillType.evenOdd;

  Paint _profilePaint(Rect r, {bool lighter = false}) {

    final top = lighter ? Color.lerp(_profile, Colors.white, frameColor == null ? 0.5 : 0.12)! : _profile;
    final bottom = Color.lerp(_profile, _profileShade, lighter ? 0.45 : 0.7)!;
    return Paint()..shader = ui.Gradient.linear(r.topLeft, r.bottomLeft, [top, bottom]);
  }

  Paint _stroked(Color color, double width) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width;

  @override
  bool shouldRepaint(covariant _FramePainter old) => true;
}

List<Rect> _cutoutRects(hisob.FrameDesign d) {
  final out = <Rect>[];
  void walk(hisob.Cell c, Rect r) {
    switch (c) {
      case hisob.Zone(:final fill):
        if (fill == hisob.Fill.cutout) out.add(r);
      case hisob.Split(:final axis, :final positionsMm, :final children):
        final v = axis == hisob.Axis.vertical;
        final start = v ? r.left : r.top;
        final edges = [start, for (final p in positionsMm) start + p, v ? r.right : r.bottom];
        for (var i = 0; i < children.length && i + 1 < edges.length; i++) {
          walk(children[i], v ? Rect.fromLTRB(edges[i], r.top, edges[i + 1], r.bottom)
              : Rect.fromLTRB(r.left, edges[i], r.right, edges[i + 1]));
        }
      case hisob.Wing(:final content):
        walk(content, r);
    }
  }

  walk(d.root, Rect.fromLTWH(0, 0, d.widthMm, d.heightMm));
  return out;
}
