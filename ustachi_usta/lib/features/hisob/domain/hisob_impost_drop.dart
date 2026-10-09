
library;

import 'package:ustachi/features/hisob/domain/hisob_dimensions.dart';
import 'package:ustachi_hisob/ustachi_hisob.dart' as hisob;

const double impostSnapMm = 10;

const double pairGapMm = 1400;

const double archSnapMm = 60;

double snapArchRise(hisob.FrameDesign d, double riseMm) {
  if (riseMm <= 0) return riseMm;
  final marks = lineMarks(d, hisob.Axis.horizontal);
  var best = riseMm;
  var bestGap = archSnapMm;
  for (final m in marks.sublist(1, marks.length - 1)) {
    final gap = (m - riseMm).abs();
    if (gap <= bestGap) {
      best = m;
      bestGap = gap;
    }
  }
  return best;
}

double pairGapFor(double sizeMm) => sizeMm >= pairGapMm + 2 * minSegmentMm
    ? pairGapMm
    : (sizeMm / 3 / impostSnapMm).round() * impostSnapMm;

class ImpostTool {
  const ImpostTool(this.axis, {this.pair = false, this.chiftQuloq = false});

  final hisob.Axis axis;

  final bool pair;

  final bool chiftQuloq;
}

enum ImpostKind { plain, balcony }

class ImpostDrop {
  const ImpostDrop({
    required this.axis,
    required this.path,
    required this.region,
    required this.positionsMm,
    this.chiftQuloq = false,
    this.balcony = false,
    this.error,
  });

  final hisob.Axis axis;

  final bool chiftQuloq;

  final bool balcony;

  final hisob.CellPath path;

  final hisob.MmRect region;

  final List<double> positionsMm;

  final String? error;

  bool get ok => error == null;

  double get _start => axis == hisob.Axis.vertical ? region.l : region.t;
  double get _end => axis == hisob.Axis.vertical ? region.r : region.b;

  List<double> get segmentsMm {
    final b = [_start, ...positionsMm, _end];
    return [for (var i = 0; i + 1 < b.length; i++) b[i + 1] - b[i]];
  }
}

ImpostDrop? planImpost(
  hisob.FrameDesign d,
  hisob.SeriesSpec spec,
  hisob.Axis axis,
  double xMm,
  double yMm, {
  bool balconyDoor = false,
  bool chiftQuloq = false,
  bool balcony = false,
  bool pair = false,
}) {
  final List<hisob.CellBox> boxes;
  try {
    boxes = hisob.layoutCells(d, spec, balconyDoor: balconyDoor);
  } on hisob.DesignException {
    return null;
  }
  var hit = hisob.hitTest(boxes, xMm, yMm);
  if (hit == null) return null;

  final cell = hit.cell;
  if (cell is hisob.Wing) {
    final inner = [...hit.path, 0];
    hit = boxes.where((b) => _same(b.path, inner)).firstOrNull;
    if (hit == null || hit.cell is! hisob.Zone) return null;
  }
  final zone = hit.cell;
  if (zone is! hisob.Zone || zone.fill == hisob.Fill.cutout) return null;

  final vertical = axis == hisob.Axis.vertical;
  final start = vertical ? hit.region.l : hit.region.t;
  final end = vertical ? hit.region.r : hit.region.b;
  var pos = ((vertical ? xMm : yMm) / impostSnapMm).round() * impostSnapMm;

  final rise = d.archRiseMm;
  if (!vertical && !pair && rise > 0 && (pos - rise).abs() <= archSnapMm && rise > start && rise < end) {
    pos = rise;
  }
  final min = start + minSegmentMm, max = end - minSegmentMm;
  final List<double> positions;
  String? tooSmall;
  if (!pair) {
    if (max < min) tooSmall = "Bo'lim juda kichik — bo'lib bo'lmaydi.";
    positions = [pos.clamp(min, max < min ? min : max)];
  } else {

    final gap = pairGapFor(end - start);

    final lastFirst = max - gap;
    if (lastFirst < min) tooSmall = "Bo'lim juda kichik — juft tayoqcha sig'maydi.";
    final centred = ((pos - gap / 2) / impostSnapMm).round() * impostSnapMm;
    final first = centred.clamp(min, lastFirst < min ? min : lastFirst);
    positions = [first, first + gap];
  }
  final drop = ImpostDrop(
    axis: axis,
    path: hit.path,
    region: hit.region,
    positionsMm: positions,

    chiftQuloq: chiftQuloq && vertical && !balcony,
    balcony: balcony,
  );
  if (tooSmall != null) return _withError(drop, tooSmall);
  final error = hisob.designError(applyImpostDrop(d, drop, check: false), spec, balconyDoor: balconyDoor);
  return error == null ? drop : _withError(drop, error);
}

ImpostDrop _withError(ImpostDrop d, String error) => ImpostDrop(
      axis: d.axis,
      path: d.path,
      region: d.region,
      positionsMm: d.positionsMm,
      chiftQuloq: d.chiftQuloq,
      balcony: d.balcony,
      error: error,
    );

hisob.FrameDesign applyImpostDrop(
  hisob.FrameDesign d,
  ImpostDrop drop, {
  hisob.SeriesSpec? spec,
  bool balconyDoor = false,
  bool check = true,
}) {
  if (check && drop.error != null) throw hisob.DesignException(drop.error!);
  final path = drop.path;
  final zone = hisob.cellAt(d.root, path) as hisob.Zone;
  final parentPath = path.isEmpty ? null : path.sublist(0, path.length - 1);
  final parent = parentPath == null ? null : hisob.cellAt(d.root, parentPath);
  final hisob.Cell replaced;
  final hisob.CellPath at;

  if (parent is hisob.Split && parent.axis == drop.axis && parent.balcony == drop.balcony) {

    final i = path.last;
    final origin = _originOf(d.root, parentPath!, drop.axis);
    replaced = parent.copyWith(
      positionsMm: [
        ...parent.positionsMm.sublist(0, i),
        for (final p in drop.positionsMm) p - origin,
        ...parent.positionsMm.sublist(i),
      ],
      children: [
        ...parent.children.sublist(0, i),
        for (var k = 0; k <= drop.positionsMm.length; k++) hisob.Zone(zone.fill),
        ...parent.children.sublist(i + 1),
      ],

      chiftQuloq: false,
      chiftImposts: {
        for (var c = 0; c < parent.positionsMm.length; c++)
          if (parent.isChift(c)) c >= i ? c + drop.positionsMm.length : c,
        if (drop.chiftQuloq)
          for (var k = 0; k < drop.positionsMm.length; k++) i + k,
      },
    );
    at = parentPath;
  } else {
    final origin = _originOf(d.root, path, drop.axis);
    replaced = hisob.Split(
      axis: drop.axis,
      positionsMm: [for (final p in drop.positionsMm) p - origin],
      children: [for (var k = 0; k <= drop.positionsMm.length; k++) hisob.Zone(zone.fill)],
      chiftQuloq: drop.chiftQuloq,
      balcony: drop.balcony,
    );
    at = path;
  }
  final next = hisob.FrameDesign(
    widthMm: d.widthMm,
    heightMm: d.heightMm,
    root: hisob.replaceAt(d.root, at, replaced),
    archRiseMm: d.archRiseMm,
  );
  if (check && spec != null) {
    final error = hisob.designError(next, spec, balconyDoor: balconyDoor);
    if (error != null) throw hisob.DesignException(error);
  }
  return next;
}

bool chiftQuloqAvailable(int material) => material == 1;

hisob.FrameDesign withoutChiftQuloq(hisob.FrameDesign d) {
  var changed = false;
  hisob.Cell walk(hisob.Cell c) => switch (c) {
        hisob.Split(:final children, :final chiftQuloq) => () {
            if (chiftQuloq || c.chiftImposts.isNotEmpty) changed = true;
            return c.copyWith(children: [for (final k in children) walk(k)], chiftQuloq: false, chiftImposts: const {});
          }(),
        final hisob.Wing w => w.copyWith(content: walk(w.content)),
        hisob.Zone() => c,
      };
  final root = walk(d.root);
  if (!changed) return d;
  return hisob.FrameDesign(widthMm: d.widthMm, heightMm: d.heightMm, root: root, archRiseMm: d.archRiseMm);
}

({hisob.CellPath split, int left, int right})? chiftPairFor(hisob.Cell root, hisob.CellPath path) {
  for (var depth = path.length - 1; depth >= 0; depth--) {
    final parentPath = path.sublist(0, depth);
    final hisob.Cell parent;
    try {
      parent = hisob.cellAt(root, parentPath);
    } on hisob.DesignException {
      return null;
    }
    if (parent is! hisob.Split || parent.axis != hisob.Axis.vertical) continue;
    final k = path[depth];
    if (k > 0 && k < parent.children.length - 1) return (split: parentPath, left: k - 1, right: k);
  }
  return null;
}

double _originOf(hisob.Cell root, hisob.CellPath path, hisob.Axis axis) {
  var origin = 0.0;
  var cell = root;
  for (final i in path) {
    switch (cell) {
      case hisob.Split(axis: final a, :final positionsMm, :final children):
        if (a == axis && i > 0) origin += positionsMm[i - 1];
        cell = children[i];
      case hisob.Wing(:final content):
        cell = content;
      case hisob.Zone():
        return origin;
    }
  }
  return origin;
}

bool _same(hisob.CellPath a, hisob.CellPath b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
