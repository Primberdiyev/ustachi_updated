import 'dart:math' as math;

const proposalGridMm = 50;

const _minGapMm = 100;

const _eps = 1e-6;

const _mirrorToleranceMm = 12.0;

double Function(double) proposalSnapAxis(Iterable<double> coords, int sizeMm) {
  final size = sizeMm.toDouble();
  final unique = <double>[];
  for (final c in [...coords]..sort()) {
    if (c <= _eps || c >= 1 - _eps) continue;
    if (unique.isEmpty || c - unique.last > _eps) unique.add(c);
  }
  if (size <= 0 || unique.isEmpty) return (v) => v;

  double micron(double mm) => (mm * 1000).round() / 1000;
  double toGrid(double mm) => (micron(mm) / proposalGridMm).round() * proposalGridMm.toDouble();

  final snapped = List<double>.filled(unique.length, 0);
  final done = List<bool>.filled(unique.length, false);
  for (var i = 0; i < unique.length; i++) {
    if (done[i]) continue;
    final fromStart = unique[i] * size;

    var pair = -1;
    for (var k = unique.length - 1; k >= i; k--) {
      if (!done[k] && (unique[k] * size + fromStart - size).abs() <= _mirrorToleranceMm) {
        pair = k;
        break;
      }
    }
    if (pair == i) {
      snapped[i] = 0.5; 
    } else if (pair > i) {
      final edge = toGrid((fromStart + size - unique[pair] * size) / 2);
      snapped[i] = edge / size;
      snapped[pair] = (size - edge) / size;
      done[pair] = true;
    } else {
      final fromEnd = size - fromStart;
      snapped[i] = (fromStart < fromEnd ? toGrid(fromStart) : size - toGrid(fromEnd)) / size;
    }
    done[i] = true;
  }

  final before = [0.0, ...unique, 1.0];
  final after = [0.0, ...snapped, 1.0];
  for (var i = 1; i < before.length; i++) {
    final was = (before[i] - before[i - 1]) * size;
    final now = (after[i] - after[i - 1]) * size;
    if (now <= 0 || now < math.min(was, _minGapMm) - 0.5) return (v) => v;
  }

  return (v) {
    for (var i = 0; i < unique.length; i++) {
      if ((unique[i] - v).abs() <= _eps) return snapped[i];
    }
    return v;
  };
}
