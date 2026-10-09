
library;

import 'package:ustachi_hisob/ustachi_hisob.dart' as hisob;

const _same = 0.5;

const double minSegmentMm = 100;

double _total(hisob.FrameDesign d, hisob.Axis axis) =>
    axis == hisob.Axis.vertical ? d.widthMm : d.heightMm;

enum ChainSide { start, end }

bool _touches(ChainSide? side, double from, double to, double total) => switch (side) {
      null => true,
      ChainSide.start => from <= _same,
      ChainSide.end => to >= total - _same,
    };

List<double> lineMarks(hisob.FrameDesign d, hisob.Axis axis, {ChainSide? side}) {
  final total = _total(d, axis);
  final across = axis == hisob.Axis.vertical ? d.heightMm : d.widthMm;
  final cuts = <double>[];
  void add(double v) {
    if (v <= _same || v >= total - _same) return;
    if (cuts.any((c) => (c - v).abs() < _same)) return;
    cuts.add(v);
  }

  void walk(hisob.Cell cell, double start, double from, double to) {
    switch (cell) {
      case hisob.Split(axis: final a, :final positionsMm, :final children):
        if (a == axis) {
          final edges = [start, for (final p in positionsMm) start + p];
          if (_touches(side, from, to, across)) {
            for (final p in positionsMm) {
              add(start + p);
            }
          }
          for (var i = 0; i < children.length; i++) {
            walk(children[i], edges[i], from, to);
          }
        } else {
          final edges = [from, for (final p in positionsMm) from + p, to];
          for (var i = 0; i < children.length; i++) {
            walk(children[i], start, edges[i], edges[i + 1]);
          }
        }
      case hisob.Wing(:final content):
        walk(content, start, from, to);
      case hisob.Zone():
        break;
    }
  }

  walk(d.root, 0, 0, across);
  cuts.sort();
  return [0, ...cuts, total];
}

hisob.FrameDesign setSegment(
  hisob.FrameDesign d,
  hisob.Axis axis,
  int index,
  double lengthMm,
  hisob.SeriesSpec spec, {
  bool balconyDoor = false,
  ChainSide? side,
}) {
  final marks = lineMarks(d, axis, side: side);
  if (marks.length < 3) {
    throw const hisob.DesignException("Bu yo'nalishda impost yo'q — rom o'lchamini o'zgartiring.");
  }
  if (index < 0 || index > marks.length - 2) {
    throw const hisob.DesignException("Bo'lak topilmadi.");
  }
  final last = index == marks.length - 2;
  final k = last ? index : index + 1; 
  final from = marks[k];
  final to = last ? marks[index + 1] - lengthMm : marks[index] + lengthMm;
  if (to < marks[k - 1] + minSegmentMm || to > marks[k + 1] - minSegmentMm) {
    final room = marks[k + 1] - marks[k - 1] - minSegmentMm;
    throw hisob.DesignException(
      "Bo'lak ${minSegmentMm.round()} mm dan ${room.round()} mm gacha bo'lishi mumkin.",
    );
  }
  final moved = hisob.FrameDesign(
    widthMm: d.widthMm,
    heightMm: d.heightMm,
    root: _Mover(axis, side, axis == hisob.Axis.vertical ? d.heightMm : d.widthMm,
            (v) => (v - from).abs() < _same ? to : v)
        .move(d.root, 0, 0, 0, axis == hisob.Axis.vertical ? d.heightMm : d.widthMm),
    archRiseMm: d.archRiseMm,
  );
  final error = hisob.designError(moved, spec, balconyDoor: balconyDoor);
  if (error != null) throw hisob.DesignException(error);
  return moved;
}

class _Mover {
  _Mover(this.axis, this.side, this.across, this.f);

  final hisob.Axis axis;
  final ChainSide? side;
  final double across;
  final double Function(double) f;

  hisob.Cell move(hisob.Cell cell, double start, double newStart, double from, double to) => switch (cell) {
        hisob.Split(axis: final a, :final positionsMm, :final children) when a == axis => () {
            final abs = [for (final p in positionsMm) start + p];
            final moves = _touches(side, from, to, across);
            final newAbs = [for (final x in abs) moves ? f(x) : x];
            final edges = [start, ...abs];
            final newEdges = [newStart, ...newAbs];
            return cell.copyWith(
              positionsMm: [for (final x in newAbs) x - newStart],
              children: [
                for (var i = 0; i < children.length; i++) move(children[i], edges[i], newEdges[i], from, to),
              ],
            );
          }(),
        hisob.Split(:final positionsMm, :final children) => () {
            final edges = [from, for (final p in positionsMm) from + p, to];
            return cell.copyWith(
              children: [
                for (var i = 0; i < children.length; i++) move(children[i], start, newStart, edges[i], edges[i + 1]),
              ],
            );
          }(),
        final hisob.Wing w => w.copyWith(content: move(w.content, start, newStart, from, to)),
        hisob.Zone() => cell,
      };
}
