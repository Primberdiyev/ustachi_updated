library;

import 'package:ustachi_hisob/src/design.dart';
import 'package:ustachi_hisob/src/layout.dart';
import 'package:ustachi_hisob/src/series.dart';

const _same = 0.5;

String? designError(FrameDesign design, SeriesSpec spec, {bool balconyDoor = false}) {
  try {
    validateDesign(design, spec, balconyDoor: balconyDoor);
    return null;
  } on DesignException catch (e) {
    return e.message;
  }
}

void validateDesign(FrameDesign design, SeriesSpec spec, {bool balconyDoor = false}) {
  final w = design.widthMm;
  final h = design.heightMm;
  if (w <= 2 * spec.frameWidth || h <= 2 * spec.frameWidth) {
    throw const DesignException("Rom o'lchami rama enidan katta bo'lishi kerak.");
  }
  final rise = design.archRiseMm;
  if (rise < 0 || rise >= h) {
    throw const DesignException("Kamar balandligi rom bo'yidan kichik bo'lishi kerak.");
  }

  _checkStructure(design.root, insideWing: false);

  final boxes = layoutCells(design, spec, balconyDoor: balconyDoor);
  var leftCutouts = 0;
  var rightCutouts = 0;
  var cutoutWidth = 0.0;
  for (final box in boxes) {
    final cell = box.cell;
    if (cell is Wing) {
      final inner = box.inner!;
      if (inner.width <= 0 || inner.height <= 0) {
        throw const DesignException("Qanot uchun joy yetarli emas.");
      }
    }
    if (cell is! Zone) continue;
    if (cell.fill == Fill.cutout) {
      if (rise > 0) throw const DesignException("Kamarli romda kesik bo'lmaydi.");
      final region = box.region;
      final atBottom = (region.b - h).abs() < _same;
      final atLeft = region.l.abs() < _same;
      final atRight = (region.r - w).abs() < _same;
      if (!atBottom || !(atLeft || atRight)) {
        throw const DesignException("Kesik faqat pastki burchakda, yotiq impost ostida bo'ladi.");
      }
      if (atLeft) {
        if (++leftCutouts > 1) throw const DesignException('Chap pastda bittadan ortiq kesik.');
      } else {
        if (++rightCutouts > 1) throw const DesignException("O'ng pastda bittadan ortiq kesik.");
      }
      cutoutWidth += region.width;
      continue;
    }
    if (box.light.width <= 0 || box.light.height <= 0) {
      throw const DesignException("Oyna uchun joy yetarli emas.");
    }
  }
  if (cutoutWidth >= w - _same) throw const DesignException("Kesiklar orasida joy qolmadi.");
}

void _checkStructure(Cell cell, {required bool insideWing}) {
  switch (cell) {
    case Zone(:final fill):
      if (fill == Fill.cutout && insideWing) {
        throw const DesignException("Qanot ichida kesik bo'lmaydi.");
      }
    case Split(:final axis, :final children):
      if (axis == Axis.vertical && children.any((c) => c is Zone && c.fill == Fill.cutout)) {
        throw const DesignException("Kesik faqat yotiq impost ostida bo'ladi.");
      }
      for (final c in children) {
        _checkStructure(c, insideWing: insideWing);
      }
    case Wing(:final content):
      if (insideWing) {
        throw const DesignException("Qanot ichida yana qanot bo'lishi mumkin emas.");
      }
      _checkStructure(content, insideWing: true);
  }
}
