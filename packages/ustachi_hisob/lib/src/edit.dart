
library;

import 'package:ustachi_hisob/src/design.dart';
import 'package:ustachi_hisob/src/layout.dart';
import 'package:ustachi_hisob/src/series.dart';
import 'package:ustachi_hisob/src/validate.dart';

Cell cellAt(Cell root, CellPath path) {
  var cell = root;
  for (final i in path) {
    cell = switch (cell) {
      Split(:final children) when i >= 0 && i < children.length => children[i],
      Wing(:final content) when i == 0 => content,
      _ => throw DesignException("Katak yo'li noto'g'ri: $path"),
    };
  }
  return cell;
}

Cell replaceAt(Cell root, CellPath path, Cell replacement) {
  if (path.isEmpty) return replacement;
  final i = path.first;
  final rest = path.sublist(1);
  return switch (root) {
    final Split s when i >= 0 && i < s.children.length => s.copyWith(
        children: [
          for (var k = 0; k < s.children.length; k++) k == i ? replaceAt(s.children[k], rest, replacement) : s.children[k],
        ],
      ),
    final Wing w when i == 0 => w.copyWith(content: replaceAt(w.content, rest, replacement)),
    _ => throw DesignException("Katak yo'li noto'g'ri: $path"),
  };
}

FrameDesign _withRoot(FrameDesign d, Cell root) =>
    FrameDesign(widthMm: d.widthMm, heightMm: d.heightMm, root: root, archRiseMm: d.archRiseMm);

bool _same(CellPath a, CellPath b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

CellBox _boxOf(FrameDesign design, SeriesSpec spec, CellPath path, {bool balconyDoor = false}) {
  for (final b in layoutCells(design, spec, balconyDoor: balconyDoor)) {
    if (_same(b.path, path)) return b;
  }
  throw DesignException('Katak topilmadi: $path');
}

FrameDesign splitZone(
  FrameDesign design,
  SeriesSpec spec,
  CellPath path,
  Axis axis,
  int parts, {
  bool balconyDoor = false,
}) {
  if (parts < 2) throw const DesignException("Kamida ikki bo'lakka bo'linadi.");
  final cell = cellAt(design.root, path);
  if (cell is! Zone) throw const DesignException("Faqat oyna o'rni bo'linadi. Qanotni avval olib tashlang.");
  final box = _boxOf(design, spec, path, balconyDoor: balconyDoor);
  final vertical = axis == Axis.vertical;
  final start = vertical ? box.region.l : box.region.t;
  final size = box.sizeAlong(axis);
  final origin = vertical ? box.originX : box.originY;
  final split = Split(
    axis: axis,
    positionsMm: [for (var k = 1; k < parts; k++) start - origin + size * k / parts],
    children: [for (var k = 0; k < parts; k++) Zone(cell.fill)],
  );
  return _checked(_withRoot(design, replaceAt(design.root, path, split)), spec, balconyDoor);
}

FrameDesign equalizeSplit(FrameDesign design, SeriesSpec spec, CellPath path, {bool balconyDoor = false}) {
  final cell = cellAt(design.root, path);
  if (cell is! Split) throw const DesignException("Bu katakda impost yo'q.");
  final box = _boxOf(design, spec, path, balconyDoor: balconyDoor);
  final vertical = cell.axis == Axis.vertical;
  final start = vertical ? box.region.l : box.region.t;
  final size = box.sizeAlong(cell.axis);
  final origin = vertical ? box.originX : box.originY;
  final parts = cell.children.length;
  final next = cell.copyWith(
    positionsMm: [for (var k = 1; k < parts; k++) (start - origin + size * k / parts).roundToDouble()],
  );
  return _checked(_withRoot(design, replaceAt(design.root, path, next)), spec, balconyDoor);
}

FrameDesign _checked(FrameDesign design, SeriesSpec spec, bool balconyDoor) {
  final error = designError(design, spec, balconyDoor: balconyDoor);
  if (error != null) throw DesignException(error);
  return design;
}

FrameDesign mergeSplit(FrameDesign design, CellPath path) {
  final cell = cellAt(design.root, path);
  if (cell is! Split) throw const DesignException("Bu katakda impost yo'q.");
  var fill = Fill.glass;
  for (final c in cell.children) {
    if (c is Zone) {
      fill = c.fill;
      break;
    }
  }
  return _withRoot(design, replaceAt(design.root, path, Zone(fill)));
}

FrameDesign setWing(FrameDesign design, CellPath path, WingKind? kind) {
  final cell = cellAt(design.root, path);

  if (kind != null && cell is! Wing && _insideWing(design.root, path)) {
    throw const DesignException("Qanot ichida yana qanot bo'lishi mumkin emas.");
  }
  final Cell next = switch ((cell, kind)) {
    (Zone(), null) => cell,
    (Zone(), final k?) => Wing(k, cell, true, _defaultHandleSide(k)),
    (Wing(:final content), null) => content,
    (final Wing w, final k?) => w.copyWith(kind: k, handleSide: _normalizeHandleSide(k, w.handleSide)),
    (Split(), _) => throw const DesignException("Avval impostlarni olib tashlang yoki bo'limni tanlang."),
  };
  return _withRoot(design, replaceAt(design.root, path, next));
}

bool _insideWing(Cell root, CellPath path) {
  var cell = root;
  for (final i in path) {
    if (cell is Wing) return true;
    cell = switch (cell) {
      Split(:final children) => children[i],
      Wing(:final content) => content,
      Zone() => cell,
    };
  }
  return false;
}

FrameDesign setFill(FrameDesign design, CellPath path, Fill fill) {
  final cell = cellAt(design.root, path);
  if (cell is! Zone) throw const DesignException("To'ldirma faqat oyna o'rniga qo'yiladi.");
  return _withRoot(design, replaceAt(design.root, path, Zone(fill)));
}

FrameDesign setHandle(FrameDesign design, CellPath path, bool hasHandle) {
  final cell = cellAt(design.root, path);
  if (cell is! Wing) throw const DesignException('Tutqich faqat qanotga qo\'yiladi.');
  return _withRoot(design, replaceAt(design.root, path, cell.copyWith(hasHandle: hasHandle)));
}

WingSide _defaultHandleSide(WingKind kind) => kind == WingKind.tilt ? WingSide.top : WingSide.right;

WingSide _normalizeHandleSide(WingKind kind, WingSide side) {
  final vertical = side == WingSide.left || side == WingSide.right;
  final wantsVertical = kind != WingKind.tilt;
  return vertical == wantsVertical ? side : _defaultHandleSide(kind);
}

FrameDesign setHandleSide(FrameDesign design, CellPath path, WingSide side) {
  final cell = cellAt(design.root, path);
  if (cell is! Wing) throw const DesignException('Tutqich tomoni faqat qanotga qo\'yiladi.');
  return _withRoot(design, replaceAt(design.root, path, cell.copyWith(handleSide: side)));
}

FrameDesign resizeSection(
  FrameDesign design,
  SeriesSpec spec,
  CellPath path,
  double sizeMm, {
  bool balconyDoor = false,
}) {
  if (path.isEmpty) throw const DesignException("Butun rom o'lchamini rom sozlamasidan o'zgartiring.");
  final parentPath = path.sublist(0, path.length - 1);
  final parent = cellAt(design.root, parentPath);
  if (parent is! Split) throw const DesignException("Bu bo'lim o'lchami o'zgarmaydi.");
  final index = path.last;
  final parentBox = _boxOf(design, spec, parentPath, balconyDoor: balconyDoor);
  final vertical = parent.axis == Axis.vertical;
  final start = vertical ? parentBox.region.l : parentBox.region.t;
  final origin = vertical ? parentBox.originX : parentBox.originY;
  final end = vertical ? parentBox.region.r : parentBox.region.b;

  final axes = [for (final p in parent.positionsMm) origin + p];
  final bounds = [start, ...axes, end];
  final last = index == parent.children.length - 1;
  final edge = last ? index - 1 : index; 
  axes[edge] = last ? bounds[index + 1] - sizeMm : bounds[index] + sizeMm;

  final next = parent.copyWith(positionsMm: [for (final a in axes) a - origin]);
  return _checked(_withRoot(design, replaceAt(design.root, parentPath, next)), spec, balconyDoor);
}

FrameDesign resizeFrame(
  FrameDesign design,
  SeriesSpec spec,
  double widthMm,
  double heightMm, {
  bool balconyDoor = false,
}) {
  if (!(widthMm > 0) || !(heightMm > 0)) throw const DesignException("Rom o'lchami noldan katta bo'lishi kerak.");
  final sx = widthMm / design.widthMm;
  final sy = heightMm / design.heightMm;
  Cell scale(Cell c) => switch (c) {
        Zone() => c,
        final Split s => s.copyWith(
            positionsMm: [for (final p in s.positionsMm) p * (s.axis == Axis.vertical ? sx : sy)],
            children: [for (final k in s.children) scale(k)],
          ),
        final Wing w => w.copyWith(content: scale(w.content)),
      };
  return _checked(
    FrameDesign(
      widthMm: widthMm,
      heightMm: heightMm,
      root: scale(design.root),
      archRiseMm: design.archRiseMm * sy,
    ),
    spec,
    balconyDoor,
  );
}

FrameDesign setArch(FrameDesign design, SeriesSpec spec, double riseMm, {bool balconyDoor = false}) {
  if (riseMm < 0) throw const DesignException("Kamar balandligi manfiy bo'lmaydi.");
  return _checked(
    FrameDesign(widthMm: design.widthMm, heightMm: design.heightMm, root: design.root, archRiseMm: riseMm),
    spec,
    balconyDoor,
  );
}

FrameDesign setChiftQuloq(FrameDesign design, CellPath path, bool on) {
  final cell = cellAt(design.root, path);
  if (cell is! Split) throw const DesignException("Bu katakda impost yo'q.");
  if (on && cell.axis != Axis.vertical) {
    throw const DesignException("Chift quloq faqat tik impostga qo'yiladi.");
  }

  return _withRoot(
    design,
    replaceAt(design.root, path, cell.copyWith(chiftQuloq: on, chiftImposts: const {}, balcony: on ? false : null)),
  );
}

FrameDesign setChiftImposts(FrameDesign design, CellPath path, Set<int> imposts, bool on) {
  final cell = cellAt(design.root, path);
  if (cell is! Split) throw const DesignException("Bu katakda impost yo'q.");
  if (cell.axis != Axis.vertical) {
    throw const DesignException("Chift quloq faqat tik impostga qo'yiladi.");
  }
  final all = {for (var i = 0; i < cell.positionsMm.length; i++) i};
  final current = cell.chiftQuloq ? all : cell.chiftImposts;
  final next = on ? {...current, ...imposts.where(all.contains)} : current.difference(imposts);
  return _withRoot(
    design,
    replaceAt(
      design.root,
      path,
      cell.copyWith(chiftQuloq: false, chiftImposts: next, balcony: on ? false : null),
    ),
  );
}

FrameDesign setBalconyMullion(FrameDesign design, CellPath path, bool on) {
  final cell = cellAt(design.root, path);
  if (cell is! Split) throw const DesignException("Bu katakda impost yo'q.");
  return _withRoot(design, replaceAt(design.root, path, cell.copyWith(balcony: on, chiftQuloq: on ? false : null, chiftImposts: on ? const {} : null)));
}

FrameDesign setWingBalcony(FrameDesign design, CellPath path, bool on) {
  final cell = cellAt(design.root, path);
  if (cell is! Wing) throw const DesignException('Balkon qanot faqat qanotga qo\'yiladi.');
  return _withRoot(design, replaceAt(design.root, path, cell.copyWith(balcony: on)));
}
