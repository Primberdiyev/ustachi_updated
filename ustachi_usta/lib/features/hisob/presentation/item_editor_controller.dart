
library;

import 'package:flutter/foundation.dart';
import 'package:ustachi/features/hisob/domain/hisob_models.dart';
import 'package:ustachi/features/hisob/domain/hisob_dimensions.dart' as hisob_dim;
import 'package:ustachi/features/hisob/domain/hisob_door_wings.dart';
import 'package:ustachi/features/hisob/domain/hisob_impost_drop.dart';
import 'package:ustachi/features/hisob/domain/settings_options.dart';
import 'package:ustachi_hisob/ustachi_hisob.dart' as hisob;

class ItemEditorController extends ChangeNotifier {
  ItemEditorController(HisobItem item) : _item = item {

    _item = _item.copyWith(design: normalizeDoorWings(_item.kind, _item.design, spec));
  }

  HisobItem _item;
  hisob.CellPath? _selected;
  String? _message;
  final List<HisobItem> _history = [];

  HisobItem get item => _item;
  hisob.FrameDesign get design => _item.design;
  ItemSettings get settings => _item.settings;

  hisob.CellPath? get selected => _selected;

  String? get message => _message;

  bool get canUndo => _history.isNotEmpty;

  hisob.SeriesSpec get spec => seriesSpecOf(settings.material);

  List<hisob.CellBox> get boxes => hisob.layoutCells(design, spec, balconyDoor: settings.balconyDoor);

  hisob.Cell? get selectedCell {
    final path = _selected;
    if (path == null) return null;
    try {
      return hisob.cellAt(design.root, path);
    } on hisob.DesignException {
      return null;
    }
  }

  bool get selectedInsideWing {
    final path = _selected;
    if (path == null) return false;
    var cell = design.root;
    for (final i in path) {
      if (cell is hisob.Wing) return true;
      cell = switch (cell) {
        hisob.Split(:final children) => children[i],
        hisob.Wing(:final content) => content,
        hisob.Zone() => cell,
      };
    }
    return false;
  }

  bool get selectedHasSplitParent {
    final path = _selected;
    if (path == null || path.isEmpty) return false;
    try {
      return hisob.cellAt(design.root, path.sublist(0, path.length - 1)) is hisob.Split;
    } on hisob.DesignException {
      return false;
    }
  }

  hisob.CellBox? get selectedBox {
    final path = _selected;
    if (path == null) return null;
    for (final b in boxes) {
      if (b.path.length == path.length && _samePath(b.path, path)) return b;
    }
    return null;
  }

  static bool _samePath(List<int> a, List<int> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  hisob.CellPath? get enclosingWing {
    final path = _selected;
    if (path == null) return null;
    hisob.CellPath? found;
    var cell = design.root;
    for (var i = 0; i < path.length; i++) {
      if (cell is hisob.Wing) found = path.sublist(0, i);
      cell = switch (cell) {
        hisob.Split(:final children) => children[path[i]],
        hisob.Wing(:final content) => content,
        hisob.Zone() => cell,
      };
    }
    return found;
  }

  void select(hisob.CellPath? path) {
    _selected = path;
    _message = null;
    notifyListeners();
  }

  bool edit(hisob.FrameDesign Function(hisob.FrameDesign) op, {hisob.CellPath? selectAfter, bool keepSelection = true}) {
    try {

      final next = normalizeDoorWings(_item.kind, op(design), spec);
      _history.add(_item);
      _item = _item.copyWith(design: next);
      _message = null;
      if (!keepSelection) {
        _selected = selectAfter;
      } else if (selectAfter != null) {
        _selected = selectAfter;
      }
      _fixSelection();
      notifyListeners();
      return true;
    } on hisob.DesignException catch (e) {
      _message = e.message;
      notifyListeners();
      return false;
    }
  }

  void _fixSelection() {
    var path = _selected;
    if (path == null) return;
    while (path!.isNotEmpty) {
      try {
        hisob.cellAt(design.root, path);
        break;
      } on hisob.DesignException {
        path = path.sublist(0, path.length - 1);
      }
    }
    _selected = path;
  }

  void undo() {
    if (_history.isEmpty) return;
    _item = _history.removeLast();
    _message = null;
    _fixSelection();
    notifyListeners();
  }

  void split(hisob.Axis axis, int parts) {
    final path = _selected;
    if (path == null) return;
    edit((d) => hisob.splitZone(d, spec, path, axis, parts, balconyDoor: settings.balconyDoor));
  }

  bool dropImpost(ImpostTool tool, double xMm, double yMm, {ImpostKind kind = ImpostKind.plain}) {
    final drop = planImpost(
      design,
      spec,
      tool.axis,
      xMm,
      yMm,
      balconyDoor: settings.balconyDoor,

      chiftQuloq: tool.chiftQuloq && tool.pair && chiftQuloqAvailable(settings.material),
      balcony: kind == ImpostKind.balcony,
      pair: tool.pair,
    );
    if (drop == null) {
      _message = "Tayoqchani rom ichidagi oyna ustiga qo'ying.";
      notifyListeners();
      return false;
    }
    return edit(
      (d) => applyImpostDrop(d, drop, spec: spec, balconyDoor: settings.balconyDoor),
      keepSelection: false,
    );
  }

  bool? get selectedChiftQuloq {
    final path = _selected;
    if (path == null) return null;
    final pair = chiftPairFor(design.root, path);
    if (pair == null) return null;
    final split = hisob.cellAt(design.root, pair.split) as hisob.Split;
    return split.isChift(pair.left) && split.isChift(pair.right);
  }

  void setChiftQuloq(bool on) {
    final path = _selected;
    if (path == null) return;
    final pair = chiftPairFor(design.root, path);
    if (pair == null) return;
    edit((d) => hisob.setChiftImposts(d, pair.split, {pair.left, pair.right}, on));
  }

  bool? get selectedBalconyMullion {
    final path = _selected;
    if (path == null || path.isEmpty) return null;
    try {
      final parent = hisob.cellAt(design.root, path.sublist(0, path.length - 1));
      return parent is hisob.Split ? parent.balcony : null;
    } on hisob.DesignException {
      return null;
    }
  }

  void setBalconyMullion(bool on) {
    final path = _selected;
    if (path == null || path.isEmpty) return;
    edit((d) => hisob.setBalconyMullion(d, path.sublist(0, path.length - 1), on));
  }

  hisob.CellPath? get selectedWingPath => selectedCell is hisob.Wing ? _selected : enclosingWing;

  bool? get selectedWingBalcony {
    final path = selectedWingPath;
    if (path == null) return null;
    try {
      final cell = hisob.cellAt(design.root, path);
      return cell is hisob.Wing ? cell.balcony || _alwaysBalcony(cell) : null;
    } on hisob.DesignException {
      return null;
    }
  }

  bool _alwaysBalcony(hisob.Wing wing) =>
      !wing.balcony && hisob.wingIsBalcony(spec, wing.kind, wingBalcony: false);

  void setWingBalcony(bool on) {
    final path = selectedWingPath;
    if (path == null) return;
    final selected = hisob.cellAt(design.root, path);
    if (!on && selected is hisob.Wing && _alwaysBalcony(selected)) {
      _message = 'Plastik eshik qanoti doim balkon qanotdan bo\'ladi.';
      notifyListeners();
      return;
    }
    edit((d) {

      final group = <hisob.CellPath>[path];
      if (path.isNotEmpty) {
        final parentPath = path.sublist(0, path.length - 1);
        final parent = hisob.cellAt(d.root, parentPath);
        if (parent is hisob.Split) {
          group
            ..clear()
            ..addAll([
              for (var i = 0; i < parent.children.length; i++)
                if (parent.children[i] is hisob.Wing) [...parentPath, i],
            ]);
        }
      }
      var next = d;
      for (final p in group) {
        next = hisob.setWingBalcony(next, p, on);

        final wing = hisob.cellAt(next.root, p) as hisob.Wing;
        if (on && wing.kind == hisob.WingKind.turn) next = hisob.setWing(next, p, hisob.WingKind.door);
      }

      if (on && group.length > 1) {
        final doors = [
          for (final p in group)
            if ((hisob.cellAt(next.root, p) as hisob.Wing).kind == hisob.WingKind.door) p,
        ];
        if (doors.length > 1 && doors.every((p) => (hisob.cellAt(next.root, p) as hisob.Wing).hasHandle)) {
          next = hisob.setHandle(next, doors.last, false);
        }
      }
      final error = hisob.designError(next, spec, balconyDoor: settings.balconyDoor);
      if (error != null) throw hisob.DesignException(error);
      return next;
    });
  }

  void equalize() {
    final path = _selected;
    final hasParent = path != null && path.isNotEmpty;
    if (!hasParent && !canEqualize) {
      _message = 'Tenglashtiradigan tik impost yo\'q.';
      notifyListeners();
      return;
    }
    edit((d) {
      if (hasParent) {
        return hisob.equalizeSplit(d, spec, path.sublist(0, path.length - 1), balconyDoor: settings.balconyDoor);
      }
      var next = d;

      for (final p in _verticalSplitPaths(d.root)) {
        next = hisob.equalizeSplit(next, spec, p, balconyDoor: settings.balconyDoor);
      }
      return next;
    });
  }

  bool get canEqualize => _verticalSplitPaths(design.root).isNotEmpty;

  static List<hisob.CellPath> _verticalSplitPaths(hisob.Cell root) {
    final out = <hisob.CellPath>[];
    void walk(hisob.Cell c, hisob.CellPath path) {
      switch (c) {
        case hisob.Split(:final axis, :final children):
          if (axis == hisob.Axis.vertical) out.add(path);
          for (var i = 0; i < children.length; i++) {
            walk(children[i], [...path, i]);
          }

        case hisob.Wing() || hisob.Zone():
          break;
      }
    }

    walk(root, const []);
    return out;
  }

  void removeSplit() {
    final path = _selected;
    if (path == null || path.isEmpty) return;
    final parent = path.sublist(0, path.length - 1);
    edit((d) => hisob.mergeSplit(d, parent), selectAfter: parent);
  }

  bool wingKindAllowed(hisob.WingKind kind) =>
      !(item.kind == HisobKind.door && kind == hisob.WingKind.tiltTurn);

  void setWing(hisob.WingKind? kind) {
    final path = _selected;
    if (path == null) return;
    if (kind != null && !wingKindAllowed(kind)) {
      _message = "Eshikda ikki tomonlama ochilish bo'lmaydi — u faqat derazada.";
      notifyListeners();
      return;
    }
    edit((d) => _passiveSecondDoor(_meetInMiddle(hisob.setWing(d, path, kind), path, kind), path, kind));
  }

  static hisob.FrameDesign _passiveSecondDoor(hisob.FrameDesign d, hisob.CellPath path, hisob.WingKind? kind) {
    if (kind != hisob.WingKind.door || path.isEmpty) return d;
    final parentPath = path.sublist(0, path.length - 1);
    final parent = hisob.cellAt(d.root, parentPath);
    if (parent is! hisob.Split || parent.axis != hisob.Axis.vertical) return d;
    final self = parent.children[path.last];
    if (self is! hisob.Wing || !self.hasHandle) return d;
    bool activeDoor(int j) {
      if (j < 0 || j >= parent.children.length) return false;
      final c = parent.children[j];
      return c is hisob.Wing && c.kind == hisob.WingKind.door && c.hasHandle;
    }

    return activeDoor(path.last - 1) || activeDoor(path.last + 1) ? hisob.setHandle(d, path, false) : d;
  }

  static hisob.FrameDesign _meetInMiddle(hisob.FrameDesign d, hisob.CellPath path, hisob.WingKind? kind) {
    if (kind == null || kind == hisob.WingKind.tilt || path.isEmpty) return d;
    final parentPath = path.sublist(0, path.length - 1);
    final parent = hisob.cellAt(d.root, parentPath);
    if (parent is! hisob.Split || parent.axis != hisob.Axis.vertical) return d;
    final i = path.last;
    bool isPartner(int j) =>
        j >= 0 &&
        j < parent.children.length &&
        parent.children[j] is hisob.Wing &&
        (parent.children[j] as hisob.Wing).kind != hisob.WingKind.tilt;
    if (isPartner(i - 1)) {
      d = hisob.setHandleSide(d, [...parentPath, i - 1], hisob.WingSide.right);
      return hisob.setHandleSide(d, path, hisob.WingSide.left);
    }
    if (isPartner(i + 1)) {
      d = hisob.setHandleSide(d, path, hisob.WingSide.right);
      return hisob.setHandleSide(d, [...parentPath, i + 1], hisob.WingSide.left);
    }
    return d;
  }

  void setFill(hisob.Fill fill) {
    final path = _selected;
    if (path == null) return;
    edit((d) {
      final out = hisob.setFill(d, path, fill);

      if (fill == hisob.Fill.cutout) {
        final error = hisob.designError(out, spec, balconyDoor: settings.balconyDoor);
        if (error != null) throw hisob.DesignException(error);
      }
      return out;
    });
  }

  void setHandle(bool hasHandle) {
    final path = _selected;
    if (path == null) return;
    edit((d) => hisob.setHandle(d, path, hasHandle));
  }

  void setHandleSide(hisob.WingSide side) {
    final path = _selected;
    if (path == null) return;
    edit((d) => hisob.setHandleSide(d, path, side));
  }

  void resizeSelected(double sizeMm) {
    final path = _selected;
    if (path == null) return;
    edit((d) => hisob.resizeSection(d, spec, path, sizeMm, balconyDoor: settings.balconyDoor));
  }

  void setSegment(hisob.Axis axis, int index, double lengthMm, {hisob_dim.ChainSide? side}) => edit((d) {
        final moved =
            hisob_dim.setSegment(d, axis, index, lengthMm, spec, balconyDoor: settings.balconyDoor, side: side);

        if (axis != hisob.Axis.horizontal || d.archRiseMm <= 0) return moved;
        final before = hisob_dim.lineMarks(d, axis);
        final after = hisob_dim.lineMarks(moved, axis);
        final i = before.indexWhere((m) => (m - d.archRiseMm).abs() < 0.5);
        if (i <= 0 || i >= before.length - 1 || after.length != before.length) return moved;
        return hisob.setArch(moved, spec, after[i], balconyDoor: settings.balconyDoor);
      });

  void resizeFrame(double widthMm, double heightMm) =>
      edit((d) => hisob.resizeFrame(d, spec, widthMm, heightMm, balconyDoor: settings.balconyDoor));

  void setArch(double riseMm) =>
      edit((d) => hisob.setArch(d, spec, snapArchRise(d, riseMm), balconyDoor: settings.balconyDoor));

  bool updateSettings(ItemSettings next) {

    final design = chiftQuloqAvailable(next.material) ? _item.design : withoutChiftQuloq(_item.design);
    final candidate = _item.copyWith(settings: next, design: design);
    final error = hisob.designError(
      candidate.design,
      seriesSpecOf(next.material),
      balconyDoor: next.balconyDoor,
    );
    if (error != null) {
      _message = error;
      notifyListeners();
      return false;
    }
    _item = candidate;
    _message = null;
    notifyListeners();
    return true;
  }

  void clearMessage() {
    if (_message == null) return;
    _message = null;
    notifyListeners();
  }
}
