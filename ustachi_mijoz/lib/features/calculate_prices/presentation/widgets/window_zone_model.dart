import 'dart:ui';
import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_ui_models.dart';

enum SplitDirection { vertical, horizontal }

enum WindowOpeningType {
  fixed,
  openRight,
  openLeft,
  tilt,
  tiltReverse,
  openRightTilt,
  openLeftTilt,
}

enum WindowLayoutPattern {
  none,
  verticalBars,
  horizontalBars,
  emptyPanel,
  glassPanel,
  meshGrid,
}

class WindowZone {
  WindowZone.leaf({
    this.openingType = WindowOpeningType.fixed,
    this.openingDirectlyApplied = false,
    this.isDoor = false,
    this.hasHandle = true,
    this.layoutPattern = WindowLayoutPattern.none,
  });

  WindowZone.split({
    required SplitDirection this.direction,
    required List<WindowZone> this.children,
    required List<double> this.ratios,
  })  : openingType = WindowOpeningType.fixed,
        openingDirectlyApplied = false,
        isDoor = false,
        hasHandle = true,
        layoutPattern = WindowLayoutPattern.none,
        assert(
          children.length == ratios.length,
          'children va ratios soni teng bo\'lishi kerak',
        );

  static WindowZone fromFramePreviewSpec(FramePreviewSpec spec) {
    final parser = _WindowZoneParser(spec.lines);
    return parser.build(const Rect.fromLTWH(0, 0, 1, 1));
  }

  static WindowZone fromFramePreviewSpecWithDefaults(FramePreviewSpec spec) {
    var zone = fromFramePreviewSpec(spec);

    final cat = spec.defaultOpeningCategory;
    if (cat != null && cat >= 1 && cat < WindowOpeningType.values.length) {
      zone = zone.applyOpeningToAllLeaves(
        WindowOpeningType.values[cat],
        isDoor: spec.defaultOpeningIsDoor,
        directlyApplied: !spec.defaultOpeningSingleSash,
      );
    }

    for (final setup in spec.defaultZoneSetups) {
      final oc = setup.openingCategory;
      if (oc != null && oc >= 1 && oc < WindowOpeningType.values.length) {
        zone = zone.applyOpeningTypeAt(
          setup.zoneCenter,
          WindowOpeningType.values[oc],
          isDoor: setup.openingIsDoor,
          hasHandle: setup.openingHasHandle,
          directlyApplied: !setup.openingSingleSash,
        );
      }
      final lc = setup.layoutCategory;
      if (lc != null && lc >= 1 && lc < WindowLayoutPattern.values.length) {
        zone = zone.applyLayoutPatternAt(
          setup.zoneCenter,
          WindowLayoutPattern.values[lc],
        );
      }
    }
    return zone;
  }

  SplitDirection? direction;
  List<WindowZone>? children;
  List<double>? ratios;
  WindowOpeningType openingType;
  bool openingDirectlyApplied;
  bool isDoor;
  bool hasHandle;
  WindowLayoutPattern layoutPattern;

  bool get isLeaf => children == null || children!.isEmpty;

  static Rect _childRect(
    Rect parent,
    SplitDirection dir,
    double offset,
    double ratio,
  ) {
    if (dir == SplitDirection.vertical) {
      return Rect.fromLTWH(
        parent.left + parent.width * offset,
        parent.top,
        parent.width * ratio,
        parent.height,
      );
    }
    return Rect.fromLTWH(
      parent.left,
      parent.top + parent.height * offset,
      parent.width,
      parent.height * ratio,
    );
  }

  bool hasAnyDirectlyAppliedOpening() {
    if (isLeaf) {
      return openingType != WindowOpeningType.fixed && openingDirectlyApplied;
    }
    for (final c in children!) {
      if (c.hasAnyDirectlyAppliedOpening()) return true;
    }
    return false;
  }

  WindowZone applyOpeningTypeAt(
    Offset position,
    WindowOpeningType type, {
    bool isDoor = false,
    bool hasHandle = true,
    bool directlyApplied = true,
    Rect? bounds,
  }) {
    final rect = bounds ?? const Rect.fromLTWH(0, 0, 1, 1);
    if (isLeaf) {
      return WindowZone.leaf(
        openingType: type,

        openingDirectlyApplied: directlyApplied,
        isDoor: isDoor,
        hasHandle: hasHandle,
        layoutPattern: layoutPattern,
      );
    }

    var offset = 0.0;
    for (var i = 0; i < children!.length; i++) {
      final ratio = ratios![i];
      final childRect = _childRect(rect, direction!, offset, ratio);
      if (childRect.contains(position)) {
        final newKids = List<WindowZone>.from(children!);
        newKids[i] = children![i].applyOpeningTypeAt(
          position,
          type,
          isDoor: isDoor,
          hasHandle: hasHandle,
          directlyApplied: directlyApplied,
          bounds: childRect,
        );
        return WindowZone.split(
          direction: direction!,
          children: newKids,
          ratios: List<double>.from(ratios!),
        );
      }
      offset += ratio;
    }
    return this;
  }

  WindowZone applyOpeningToAllLeaves(
    WindowOpeningType type, {
    bool isDoor = false,
    bool hasHandle = true,
    bool directlyApplied = true,
  }) {
    if (isLeaf) {
      return WindowZone.leaf(
        openingType: type,
        openingDirectlyApplied: directlyApplied,
        isDoor: isDoor,
        hasHandle: hasHandle,
        layoutPattern: layoutPattern,
      );
    }
    return WindowZone.split(
      direction: direction!,
      children: children!
          .map((c) => c.applyOpeningToAllLeaves(
                type,
                isDoor: isDoor,
                hasHandle: hasHandle,
                directlyApplied: directlyApplied,
              ))
          .toList(),
      ratios: List<double>.from(ratios!),
    );
  }

  List<Rect> openingZoneRects([Rect? bounds]) {
    final rect = bounds ?? const Rect.fromLTWH(0, 0, 1, 1);
    if (isLeaf) {
      return openingType != WindowOpeningType.fixed ? [rect] : [];
    }
    final result = <Rect>[];
    var offset = 0.0;
    for (var i = 0; i < children!.length; i++) {
      final ratio = ratios![i];
      final childRect = _childRect(rect, direction!, offset, ratio);
      result.addAll(children![i].openingZoneRects(childRect));
      offset += ratio;
    }
    return result;
  }

  List<bool> openingZoneDoorFlags() {
    if (isLeaf) {
      return openingType != WindowOpeningType.fixed ? [isDoor] : [];
    }
    return [for (final c in children!) ...c.openingZoneDoorFlags()];
  }

  List<WindowOpeningType> openingZoneTypes() {
    if (isLeaf) {
      return openingType != WindowOpeningType.fixed ? [openingType] : [];
    }
    return [for (final c in children!) ...c.openingZoneTypes()];
  }

  List<({Rect rect, WindowOpeningType type, bool isDoor, bool hasHandle})> groupedOpeningSashes([Rect? bounds]) {
    final rect = bounds ?? const Rect.fromLTWH(0, 0, 1, 1);
    final infos = <(Rect, WindowOpeningType, bool, bool)>[];
    _collectOpeningLeafInfos(rect, infos);
    if (infos.isEmpty) return const [];

    const eps = 1e-6;
    final n = infos.length;
    final parent = List<int>.generate(n, (i) => i);
    int find(int x) {
      while (parent[x] != x) {
        parent[x] = parent[parent[x]];
        x = parent[x];
      }
      return x;
    }

    for (var i = 0; i < n; i++) {
      for (var j = i + 1; j < n; j++) {
        final a = infos[i].$1;
        final b = infos[j].$1;
        final overlapLeft = a.left > b.left ? a.left : b.left;
        final overlapRight = a.right < b.right ? a.right : b.right;
        if (overlapRight - overlapLeft > eps) parent[find(i)] = find(j);
      }
    }

    final clusters = <int, List<int>>{};
    for (var i = 0; i < n; i++) {
      clusters.putIfAbsent(find(i), () => <int>[]).add(i);
    }

    final ordered = clusters.values.toList()..sort((p, q) => infos[p.first].$1.left.compareTo(infos[q.first].$1.left));

    return [
      for (final cluster in ordered)
        (
          rect: cluster.skip(1).fold(infos[cluster.first].$1, (bbox, idx) => bbox.expandToInclude(infos[idx].$1)),
          type: infos[cluster.first].$2,
          isDoor: infos[cluster.first].$3,
          hasHandle: infos[cluster.first].$4,
        ),
    ];
  }

  void _collectOpeningLeafInfos(
    Rect bounds,
    List<(Rect, WindowOpeningType, bool, bool)> result,
  ) {
    if (isLeaf) {
      if (openingType != WindowOpeningType.fixed) {
        result.add((bounds, openingType, isDoor, hasHandle));
      }
      return;
    }
    var offset = 0.0;
    for (var i = 0; i < children!.length; i++) {
      final ratio = ratios![i];
      final childRect = _childRect(bounds, direction!, offset, ratio);
      children![i]._collectOpeningLeafInfos(childRect, result);
      offset += ratio;
    }
  }

  WindowZone applyLayoutPatternAt(
    Offset position,
    WindowLayoutPattern pattern, {
    Rect? bounds,
  }) {
    final rect = bounds ?? const Rect.fromLTWH(0, 0, 1, 1);
    if (isLeaf) {

      if (pattern == WindowLayoutPattern.meshGrid && (openingType == WindowOpeningType.fixed || isDoor)) {
        return this;
      }
      return WindowZone.leaf(
        openingType: openingType,
        openingDirectlyApplied: openingDirectlyApplied,
        isDoor: isDoor,
        hasHandle: hasHandle,
        layoutPattern: pattern,
      );
    }

    var offset = 0.0;
    for (var i = 0; i < children!.length; i++) {
      final ratio = ratios![i];
      final childRect = _childRect(rect, direction!, offset, ratio);
      if (childRect.contains(position)) {
        final newKids = List<WindowZone>.from(children!);
        newKids[i] = children![i].applyLayoutPatternAt(
          position,
          pattern,
          bounds: childRect,
        );
        return WindowZone.split(
          direction: direction!,
          children: newKids,
          ratios: List<double>.from(ratios!),
        );
      }
      offset += ratio;
    }
    return this;
  }

  List<({Rect rect, WindowLayoutPattern pattern})> layoutPatternRects([
    Rect? bounds,
  ]) {
    final rect = bounds ?? const Rect.fromLTWH(0, 0, 1, 1);
    if (isLeaf) {
      return layoutPattern != WindowLayoutPattern.none ? [(rect: rect, pattern: layoutPattern)] : const [];
    }
    final result = <({Rect rect, WindowLayoutPattern pattern})>[];
    var offset = 0.0;
    for (var i = 0; i < children!.length; i++) {
      final ratio = ratios![i];
      final childRect = _childRect(rect, direction!, offset, ratio);
      result.addAll(children![i].layoutPatternRects(childRect));
      offset += ratio;
    }
    return result;
  }

  List<Rect> leafRects([Rect? bounds]) {
    final rect = bounds ?? const Rect.fromLTWH(0, 0, 1, 1);
    if (isLeaf) return [rect];
    final result = <Rect>[];
    var offset = 0.0;
    for (var i = 0; i < children!.length; i++) {
      final ratio = ratios![i];
      final childRect = _childRect(rect, direction!, offset, ratio);
      result.addAll(children![i].leafRects(childRect));
      offset += ratio;
    }
    return result;
  }
}

class _WindowZoneParser {
  static const _epsilon = 1e-6;

  _WindowZoneParser(this.lines);

  final List<FrameLine> lines;

  WindowZone build(Rect bounds) {
    final verticalSplits = _collectSplits(bounds, vertical: true);
    if (verticalSplits.isNotEmpty) {
      return _split(bounds, [bounds.left, ...verticalSplits, bounds.right], SplitDirection.vertical);
    }
    final horizontalSplits = _collectSplits(bounds, vertical: false);
    if (horizontalSplits.isNotEmpty) {
      return _split(bounds, [bounds.top, ...horizontalSplits, bounds.bottom], SplitDirection.horizontal);
    }
    return WindowZone.leaf();
  }

  WindowZone _split(Rect bounds, List<double> edges, SplitDirection direction) {
    final vertical = direction == SplitDirection.vertical;
    final size = vertical ? bounds.width : bounds.height;
    final children = <WindowZone>[];
    final ratios = <double>[];
    for (var i = 0; i < edges.length - 1; i++) {
      final childRect = vertical
          ? Rect.fromLTRB(edges[i], bounds.top, edges[i + 1], bounds.bottom)
          : Rect.fromLTRB(bounds.left, edges[i], bounds.right, edges[i + 1]);
      children.add(build(childRect));
      ratios.add(size > 0 ? (edges[i + 1] - edges[i]) / size : 1 / (edges.length - 1));
    }
    return WindowZone.split(direction: direction, children: children, ratios: ratios);
  }

  List<double> _collectSplits(Rect bounds, {required bool vertical}) {
    final splits = <double>{};
    for (final line in lines) {
      final along = vertical ? (line.startX - line.endX).abs() < _epsilon : (line.startY - line.endY).abs() < _epsilon;
      if (!along) continue;
      final covers = vertical
          ? line.startY <= bounds.top + _epsilon && line.endY >= bounds.bottom - _epsilon
          : line.startX <= bounds.left + _epsilon && line.endX >= bounds.right - _epsilon;
      final at = vertical ? line.startX : line.startY;
      final inside = vertical
          ? at > bounds.left + _epsilon && at < bounds.right - _epsilon
          : at > bounds.top + _epsilon && at < bounds.bottom - _epsilon;
      if (covers && inside) splits.add(at);
    }
    return splits.toList()..sort();
  }
}
