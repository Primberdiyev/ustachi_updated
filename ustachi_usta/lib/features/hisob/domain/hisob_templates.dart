
library;

import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_ui_models.dart';
import 'package:ustachi/features/hisob/domain/hisob_models.dart';
import 'package:ustachi/features/hisob/domain/template_specs.dart';
import 'package:ustachi_hisob/ustachi_hisob.dart' as hisob;

class HisobTemplateGroup {
  const HisobTemplateGroup(this.title, this.designs);

  final String title;
  final List<hisob.FrameDesign> designs;
}

List<HisobTemplateGroup> templateGroupsFor(HisobKind kind) => _cache[kind] ??= switch (kind) {
      HisobKind.window => _grouped(
          [
            ..._convert(CalculatePreviewSpecs.windowTemplateGroups, kind),
            ..._convert(CalculatePreviewSpecs.archTemplateGroups, kind),
          ],
          windowGroupTitles,
          windowGroupOf,
        ),
      HisobKind.door => _grouped(
          [..._convert(CalculatePreviewSpecs.doorTemplateGroups, kind), ..._cutoutDoors],
          doorGroupTitles,
          doorGroupOf,
        ),
    };

const windowGroupTitles = ['Kichik deraza', 'O\'rta deraza', 'Vitraj', 'Kamarli (arka)'];

const doorGroupTitles = [
  'Bir tavaqali eshik',
  'Juft eshik',
  'Yon oynali eshik',
  'Vitrajli juft eshik',
  'G va T shakl',
];

const smallWindowMaxMm = 1200.0;
const vitrageMinMm = 2000.0;

String windowGroupOf(hisob.FrameDesign d) {
  if (d.archRiseMm > 0) return windowGroupTitles[3];
  if (d.widthMm >= vitrageMinMm) return windowGroupTitles[2];
  return d.widthMm <= smallWindowMaxMm ? windowGroupTitles[0] : windowGroupTitles[1];
}

String doorGroupOf(hisob.FrameDesign d) {
  var doors = 0;
  var cutout = false;
  var side = false;
  void walk(hisob.Cell c, {required bool beside}) {
    switch (c) {
      case hisob.Zone(:final fill):
        if (fill == hisob.Fill.cutout) cutout = true;
        if (beside) side = true;
      case hisob.Wing(:final kind):
        if (kind == hisob.WingKind.door) {
          doors++;
        } else if (beside) {
          side = true;
        }
      case hisob.Split(:final axis, :final children):
        final vertical = axis == hisob.Axis.vertical;
        final hasDoor = children.any(_hasDoor);
        for (final child in children) {

          walk(child, beside: beside || (vertical && hasDoor && !_hasDoor(child)));
        }
    }
  }

  walk(d.root, beside: false);
  if (cutout) return doorGroupTitles[4];
  if (doors >= 2) return side ? doorGroupTitles[3] : doorGroupTitles[1];
  return side ? doorGroupTitles[2] : doorGroupTitles[0];
}

bool _hasDoor(hisob.Cell c) => switch (c) {
      hisob.Zone() => false,
      hisob.Wing(:final kind) => kind == hisob.WingKind.door,
      hisob.Split(:final children) => children.any(_hasDoor),
    };

List<HisobTemplateGroup> _grouped(
  List<hisob.FrameDesign> designs,
  List<String> titles,
  String Function(hisob.FrameDesign) groupOf,
) =>
    [
      for (final title in titles)
        if (designs.where((d) => groupOf(d) == title).toList() case final list when list.isNotEmpty)
          HisobTemplateGroup(title, list),
    ];

const _short = hisob.Split(
  axis: hisob.Axis.horizontal,
  positionsMm: [1500],
  children: [hisob.Zone(), hisob.Zone(hisob.Fill.cutout)],
);
const _doorHandleLeft = hisob.Wing(hisob.WingKind.door, hisob.Zone(), true, hisob.WingSide.left);
const _doorHandleRight = hisob.Wing(hisob.WingKind.door, hisob.Zone(), true, hisob.WingSide.right);

hisob.Split _withTransom(hisob.Cell lower) =>
    hisob.Split(axis: hisob.Axis.horizontal, positionsMm: const [500], children: [const hisob.Zone(), lower]);

List<hisob.FrameDesign> shapeTemplatesFor(HisobKind kind) =>
    kind == HisobKind.door ? _cutoutDoors : const [];

final List<hisob.FrameDesign> _cutoutDoors = [

  hisob.FrameDesign(
    widthMm: 2000,
    heightMm: 2800,
    root: _withTransom(const hisob.Split(axis: hisob.Axis.vertical, positionsMm: [800], children: [_doorHandleRight, _short])),
  ),

  hisob.FrameDesign(
    widthMm: 2000,
    heightMm: 2800,
    root: _withTransom(const hisob.Split(axis: hisob.Axis.vertical, positionsMm: [1200], children: [_short, _doorHandleLeft])),
  ),

  hisob.FrameDesign(
    widthMm: 2000,
    heightMm: 2800,
    root: _withTransom(const hisob.Split(
      axis: hisob.Axis.vertical,
      positionsMm: [600, 1400],
      children: [_short, _doorHandleRight, _short],
    )),
  ),

  const hisob.FrameDesign(
    widthMm: 2000,
    heightMm: 2300,
    root: hisob.Split(axis: hisob.Axis.vertical, positionsMm: [600, 1400], children: [_short, _doorHandleRight, _short]),
  ),

  const hisob.FrameDesign(
    widthMm: 2000,
    heightMm: 2300,
    root: hisob.Split(axis: hisob.Axis.vertical, positionsMm: [1200], children: [_short, _doorHandleLeft]),
  ),

  const hisob.FrameDesign(
    widthMm: 2000,
    heightMm: 2300,
    root: hisob.Split(axis: hisob.Axis.vertical, positionsMm: [800], children: [_doorHandleRight, _short]),
  ),
];

final _cache = <HisobKind, List<HisobTemplateGroup>>{};

List<hisob.FrameDesign> _convert(List<List<FramePreviewSpec>> groups, HisobKind kind) => [
      for (final group in groups)
        for (final spec in group) designFromSpec(spec, kind),
    ];

const _eps = 1e-4;

hisob.FrameDesign designFromSpec(FramePreviewSpec spec, HisobKind kind) {
  final aspect = spec.aspectRatio > 0 ? spec.aspectRatio : 1.0;
  final double heightMm;
  final double widthMm;
  if (spec.widthMm != null && spec.heightMm != null) {
    widthMm = spec.widthMm!.toDouble();
    heightMm = spec.heightMm!.toDouble();
  } else if (spec.heightMm != null) {
    heightMm = spec.heightMm!.toDouble();
    widthMm = _round10(heightMm * aspect);
  } else if (spec.widthMm != null) {
    widthMm = spec.widthMm!.toDouble();
    heightMm = _round10(widthMm / aspect);
  } else {
    heightMm = kind.defaultHeightMm;
    widthMm = _round10(heightMm * aspect);
  }

  final lines = _Lines.of(spec.lines);
  final root = _Node.build(lines, 0, 0, 1, 1);

  final all = _openingOf(spec.defaultOpeningCategory, isDoor: spec.defaultOpeningIsDoor);
  if (all != null) {
    for (final leaf in root.leaves) {
      leaf.wing = all;
    }
  }

  if (kind == HisobKind.door) {
    for (final region in spec.regions) {
      final isDoorRegion = region.hideOuterStrokeLeft ||
          region.hideOuterStrokeRight ||
          region.hideOuterStrokeTop ||
          region.hideOuterStrokeBottom;
      if (!isDoorRegion) continue;
      final leaf = root.leafAt((region.left + region.right) / 2, (region.top + region.bottom) / 2);
      leaf?.wing ??= const _Opening(hisob.WingKind.door, true, hisob.WingSide.right);
    }
  }
  for (final setup in spec.defaultZoneSetups) {
    final leaf = root.leafAt(setup.zoneCenter.dx, setup.zoneCenter.dy);
    if (leaf == null) continue;
    final opening = _openingOf(
      setup.openingCategory,
      isDoor: setup.openingIsDoor,
      hasHandle: setup.openingHasHandle,
    );
    if (opening != null) leaf.wing = opening;

    if (setup.layoutCategory == 3) leaf.fill = hisob.Fill.panel;
  }

  if (kind == HisobKind.door) {
    for (final leaf in root.leaves) {
      final w = leaf.wing;
      if (w != null && w.kind == hisob.WingKind.tiltTurn) {
        leaf.wing = _Opening(hisob.WingKind.turn, w.hasHandle, w.side);
      }
    }
  }

  return hisob.FrameDesign(
    widthMm: widthMm,
    heightMm: heightMm,
    root: (root.merged()..meetInMiddle()).toCell(widthMm, heightMm),
    archRiseMm: spec.archHeightFactor > 0 ? spec.archHeightFactor * heightMm : 0,
  );
}

double _round10(double v) => (v / 10).round() * 10.0;

_Opening? _openingOf(int? category, {bool isDoor = false, bool hasHandle = true}) {
  if (category == null || category < 1 || category > 6) {
    return isDoor ? _Opening(hisob.WingKind.door, hasHandle, hisob.WingSide.right) : null;
  }
  final side = switch (category) {
    1 || 5 => hisob.WingSide.left,
    3 || 4 => hisob.WingSide.top,
    _ => hisob.WingSide.right,
  };
  if (isDoor) {
    return _Opening(hisob.WingKind.door, hasHandle, side == hisob.WingSide.top ? hisob.WingSide.right : side);
  }
  final kind = switch (category) {
    3 || 4 => hisob.WingKind.tilt,
    5 || 6 => hisob.WingKind.tiltTurn,
    _ => hisob.WingKind.turn,
  };
  return _Opening(kind, hasHandle, side);
}

class _Opening {
  const _Opening(this.kind, this.hasHandle, this.side);

  final hisob.WingKind kind;
  final bool hasHandle;
  final hisob.WingSide side;
}

class _Lines {
  _Lines(this.vertical, this.horizontal);

  factory _Lines.of(List<FrameLine> lines) {
    final v = <(double, double, double)>[];
    final h = <(double, double, double)>[];
    for (final l in lines) {
      if ((l.startX - l.endX).abs() < _eps) {
        v.add((l.startX, _min(l.startY, l.endY), _max(l.startY, l.endY)));
      } else if ((l.startY - l.endY).abs() < _eps) {
        h.add((l.startY, _min(l.startX, l.endX), _max(l.startX, l.endX)));
      }

    }
    return _Lines(v, h);
  }

  final List<(double, double, double)> vertical;
  final List<(double, double, double)> horizontal;

  List<double> cuts(List<(double, double, double)> segments, double from, double to, double spanFrom, double spanTo) {
    final positions = <double>[];
    for (final s in segments) {
      final p = s.$1;
      if (p <= from + _eps || p >= to - _eps) continue;
      if (positions.any((x) => (x - p).abs() < _eps)) continue;
      if (_covers([for (final o in segments) if ((o.$1 - p).abs() < _eps) (o.$2, o.$3)], spanFrom, spanTo)) {
        positions.add(p);
      }
    }
    return positions..sort();
  }

  static bool _covers(List<(double, double)> parts, double from, double to) {
    parts.sort((a, b) => a.$1.compareTo(b.$1));
    var reach = from;
    for (final (a, b) in parts) {
      if (a > reach + _eps) return false;
      if (b > reach) reach = b;
      if (reach >= to - _eps) return true;
    }
    return reach >= to - _eps;
  }
}

double _min(double a, double b) => a < b ? a : b;
double _max(double a, double b) => a > b ? a : b;

class _Node {
  _Node.leaf(this.l, this.t, this.r, this.b)
      : axis = null,
        positions = const [],
        children = const [];

  _Node.split(this.l, this.t, this.r, this.b, this.axis, this.positions, this.children);

  bool get _isDoorLeaf => axis == null && wing?.kind == hisob.WingKind.door;

  bool get _isDoorRow => _isDoorLeaf || (axis == hisob.Axis.vertical && children.every((c) => c._isDoorLeaf));

  static _Opening _doorOf(Iterable<_Node> parts) {
    final list = parts.toList();
    final withHandle = list.where((c) => c.wing!.hasHandle);
    final side = (withHandle.isEmpty ? list.first : withHandle.first).wing!.side;
    return _Opening(hisob.WingKind.door, withHandle.isNotEmpty, side);
  }

  static void _clearWings(_Node n) {
    for (final leaf in n.leaves) {
      leaf.wing = null;
    }
  }

  static bool _samePositions(List<double> a, List<double> b) =>
      a.length == b.length && [for (var i = 0; i < a.length; i++) (a[i] - b[i]).abs() < _eps].every((x) => x);

  _Node merged() {
    final kids = [for (final c in children) c.merged()];
    if (axis != hisob.Axis.horizontal) {
      return axis == null ? this : (_Node.split(l, t, r, b, axis, positions, kids)..wing = wing);
    }
    final edges = [t, ...positions, b];
    final outKids = <_Node>[];
    final outPos = <double>[];
    var i = 0;
    while (i < kids.length) {
      var j = i;
      while (kids[i]._isDoorRow && j + 1 < kids.length && kids[j + 1]._isDoorRow) {
        j++;
      }
      if (j > i) {
        final rows = kids.sublist(i, j + 1);
        final inner = positions.sublist(i, j);
        final top = edges[i];
        final bottom = edges[j + 1];
        final first = rows.first;
        final pairable = rows.every((row) => row.axis == hisob.Axis.vertical) &&
            rows.every((row) => _samePositions(row.positions, first.positions));
        if (pairable) {
          final colEdges = [l, ...first.positions, r];
          final columns = <_Node>[];
          for (var k = 0; k < first.children.length; k++) {
            final parts = [for (final row in rows) row.children[k]];
            final door = _doorOf(parts);
            for (final p in parts) {
              p.wing = null;
            }
            columns.add(_Node.split(colEdges[k], top, colEdges[k + 1], bottom, hisob.Axis.horizontal, inner, parts)
              ..wing = door);
          }
          outKids.add(_Node.split(l, top, r, bottom, hisob.Axis.vertical, first.positions, columns));
        } else {
          final door = _doorOf([for (final row in rows) ...row.leaves]);
          for (final row in rows) {
            _clearWings(row);
          }
          outKids.add(_Node.split(l, top, r, bottom, hisob.Axis.horizontal, inner, rows)..wing = door);
        }
      } else {
        outKids.add(kids[i]);
      }
      if (j + 1 < kids.length) outPos.add(positions[j]);
      i = j + 1;
    }
    if (outKids.length == 1) return outKids.single;
    return _Node.split(l, t, r, b, axis, outPos, outKids)..wing = wing;
  }

  final double l, t, r, b;
  final hisob.Axis? axis;
  final List<double> positions;
  final List<_Node> children;

  _Opening? wing;
  hisob.Fill fill = hisob.Fill.glass;

  void meetInMiddle() {
    for (final c in children) {
      c.meetInMiddle();
    }
    if (axis != hisob.Axis.vertical) return;
    for (var i = 0; i + 1 < children.length; i++) {
      final a = children[i].wing;
      final b = children[i + 1].wing;
      if (a == null || b == null) continue;
      if (a.kind == hisob.WingKind.tilt || b.kind == hisob.WingKind.tilt) continue;
      children[i].wing = _Opening(a.kind, a.hasHandle, hisob.WingSide.right);
      children[i + 1].wing = _Opening(b.kind, b.hasHandle, hisob.WingSide.left);
      i++; 
    }
  }

  static _Node build(_Lines lines, double l, double t, double r, double b) {
    final xs = lines.cuts(lines.vertical, l, r, t, b);
    if (xs.isNotEmpty) {
      final edges = [l, ...xs, r];
      return _Node.split(l, t, r, b, hisob.Axis.vertical, xs, [
        for (var i = 0; i < edges.length - 1; i++) build(lines, edges[i], t, edges[i + 1], b),
      ]);
    }
    final ys = lines.cuts(lines.horizontal, t, b, l, r);
    if (ys.isNotEmpty) {
      final edges = [t, ...ys, b];
      return _Node.split(l, t, r, b, hisob.Axis.horizontal, ys, [
        for (var i = 0; i < edges.length - 1; i++) build(lines, l, edges[i], r, edges[i + 1]),
      ]);
    }
    return _Node.leaf(l, t, r, b);
  }

  Iterable<_Node> get leaves sync* {
    if (axis == null) {
      yield this;
    } else {
      for (final c in children) {
        yield* c.leaves;
      }
    }
  }

  _Node? leafAt(double x, double y) {
    for (final leaf in leaves) {
      if (x >= leaf.l - _eps && x <= leaf.r + _eps && y >= leaf.t - _eps && y <= leaf.b + _eps) return leaf;
    }
    return null;
  }

  hisob.Cell toCell(double widthMm, double heightMm) {
    final a = axis;
    final w = wing;
    if (a == null) {
      final zone = hisob.Zone(fill);
      return w == null ? zone : hisob.Wing(w.kind, zone, w.hasHandle, w.side);
    }
    final start = a == hisob.Axis.vertical ? l : t;
    final scale = a == hisob.Axis.vertical ? widthMm : heightMm;
    final split = hisob.Split(
      axis: a,
      positionsMm: [for (final p in positions) ((p - start) * scale * 10).roundToDouble() / 10],
      children: [for (final c in children) c.toCell(widthMm, heightMm)],
    );

    return w == null ? split : hisob.Wing(w.kind, split, w.hasHandle, w.side);
  }
}
