
library;

import 'package:ustachi/features/hisob/domain/hisob_models.dart';
import 'package:ustachi_hisob/ustachi_hisob.dart' as hisob;

const _same = 0.5;

hisob.FrameDesign normalizeDoorWings(HisobKind kind, hisob.FrameDesign design, hisob.SeriesSpec spec) {
  if (kind != HisobKind.door) return design;
  final List<hisob.CellBox> boxes;
  try {
    boxes = hisob.layoutCells(design, spec);
  } on hisob.DesignException {
    return design;
  }
  final toDoor = <hisob.CellPath>[
    for (final b in boxes)
      if (b.cell case hisob.Wing(kind: hisob.WingKind.turn))
        if (b.region.b >= design.heightMm - _same) b.path,
  ];
  if (toDoor.isEmpty) return design;

  var next = design;
  for (final path in toDoor) {
    next = hisob.setWing(next, path, hisob.WingKind.door);
    if (_besideActiveDoor(next, path)) next = hisob.setHandle(next, path, false);
  }
  return next;
}

bool _besideActiveDoor(hisob.FrameDesign d, hisob.CellPath path) {
  if (path.isEmpty) return false;
  final parent = hisob.cellAt(d.root, path.sublist(0, path.length - 1));
  if (parent is! hisob.Split || parent.axis != hisob.Axis.vertical) return false;
  bool active(int j) {
    if (j < 0 || j >= parent.children.length) return false;
    final c = parent.children[j];
    return c is hisob.Wing && c.kind == hisob.WingKind.door && c.hasHandle;
  }

  return active(path.last - 1) || active(path.last + 1);
}
