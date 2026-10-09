import 'dart:ui';
import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_ui_models.dart';

enum SplitDirection { vertical, horizontal }

enum MullionShape { t, z, y, sh, witraj }

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
    List<MullionShape>? dividerShapes,
  })  : openingType = WindowOpeningType.fixed,
        openingDirectlyApplied = false,
        isDoor = false,
        hasHandle = true,
        layoutPattern = WindowLayoutPattern.none,
        dividerShapes = dividerShapes ??
            List<MullionShape>.filled(children.length - 1, MullionShape.t,
                growable: true),
        assert(
          children.length == ratios.length,
          'children va ratios soni teng bo\'lishi kerak',
        ),
        assert(
          dividerShapes == null || dividerShapes.length == children.length - 1,
          'dividerShapes soni children-1 bo\'lishi kerak',
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

  static WindowZone fromAbsoluteWidths(List<int> widthsMm) {
    assert(widthsMm.isNotEmpty, 'widthsMm must not be empty');
    final sum = widthsMm.fold<int>(0, (p, e) => p + e);
    if (sum == 0) return WindowZone.leaf();
    final ratios = widthsMm.map((w) => w / sum).toList();
    final children = List<WindowZone>.generate(
      widthsMm.length,
      (_) => WindowZone.leaf(),
    );
    return WindowZone.split(
      direction: SplitDirection.vertical,
      children: children,
      ratios: ratios,
    );
  }

  static WindowZone fromAbsoluteHeights(List<int> heightsMm) {
    assert(heightsMm.isNotEmpty, 'heightsMm must not be empty');
    final sum = heightsMm.fold<int>(0, (p, e) => p + e);
    if (sum == 0) return WindowZone.leaf();
    final ratios = heightsMm.map((h) => h / sum).toList();
    final children = List<WindowZone>.generate(
      heightsMm.length,
      (_) => WindowZone.leaf(),
    );
    return WindowZone.split(
      direction: SplitDirection.horizontal,
      children: children,
      ratios: ratios,
    );
  }

  SplitDirection? direction;
  List<WindowZone>? children;
  List<double>? ratios;

  List<MullionShape>? dividerShapes;
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

  WindowZone copyDeep() {
    if (isLeaf) {
      return WindowZone.leaf(
        openingType: openingType,
        openingDirectlyApplied: openingDirectlyApplied,
        isDoor: isDoor,
        hasHandle: hasHandle,
        layoutPattern: layoutPattern,
      );
    }
    return WindowZone.split(
      direction: direction!,
      children: children!.map((c) => c.copyDeep()).toList(),
      ratios: List<double>.from(ratios!),
      dividerShapes: List<MullionShape>.from(dividerShapes!),
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

    final dir = direction!;
    final kids = children!;
    final rats = ratios!;
    var offset = 0.0;

    for (var i = 0; i < kids.length; i++) {
      final ratio = rats[i];
      final childRect = _childRect(rect, dir, offset, ratio);
      if (childRect.contains(position)) {
        final newKids = List<WindowZone>.from(kids);
        newKids[i] = kids[i].applyOpeningTypeAt(
          position,
          type,
          isDoor: isDoor,
          hasHandle: hasHandle,
          directlyApplied: directlyApplied,
          bounds: childRect,
        );
        return WindowZone.split(
          direction: dir,
          children: newKids,
          ratios: List<double>.from(rats),
          dividerShapes: List<MullionShape>.from(dividerShapes!),
        );
      }
      offset += ratio;
    }
    return copyDeep();
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
      dividerShapes: List<MullionShape>.from(dividerShapes!),
    );
  }

  List<FrameLine> toOpeningLines([Rect? bounds]) {
    final rect = bounds ?? const Rect.fromLTWH(0, 0, 1, 1);
    if (isLeaf) {
      final isFull = rect.width > 0.99 && rect.height > 0.99;
      return _openingTypeLines(
        openingType,
        rect,
        isFullWindow: isFull,
        isDoor: isDoor,
      );
    }

    final result = <FrameLine>[];
    final dir = direction!;
    final kids = children!;
    final rats = ratios!;
    var offset = 0.0;
    for (var i = 0; i < kids.length; i++) {
      final ratio = rats[i];
      final childRect = _childRect(rect, dir, offset, ratio);
      result.addAll(kids[i].toOpeningLines(childRect));
      offset += ratio;
    }
    return result;
  }

  static List<FrameLine> _openingTypeLines(
    WindowOpeningType type,
    Rect r, {
    bool isFullWindow = false,
    bool isDoor = false,
  }) {
    final tipFar = isFullWindow ? 0.92 : 0.89;
    final tipNear = isFullWindow ? 0.08 : 0.10;
    final hingeNear = isFullWindow ? 0.06 : 0.14;
    final hingeFar = isFullWindow ? 0.94 : 0.86;
    final hingeTop = isDoor ? 0.2 : 0.25;
    FrameLine l(double x1, double y1, double x2, double y2) => FrameLine(
          r.left + x1 * r.width,
          r.top + y1 * r.height,
          r.left + x2 * r.width,
          r.top + y2 * r.height,
        );
    switch (type) {
      case WindowOpeningType.fixed:
        return const [];
      case WindowOpeningType.openRight:
        return [
          l(hingeNear, hingeTop, tipFar, 0.50),
          l(hingeNear, 0.75, tipFar, 0.50),
        ];
      case WindowOpeningType.openLeft:
        return [
          l(hingeFar, hingeTop, tipNear, 0.50),
          l(hingeFar, 0.75, tipNear, 0.50),
        ];
      case WindowOpeningType.tilt:
        return [
          l(0.25, hingeNear, 0.50, tipFar),
          l(0.75, hingeNear, 0.50, tipFar),
        ];
      case WindowOpeningType.tiltReverse:
        return [
          l(0.25, hingeFar, 0.50, tipNear),
          l(0.75, hingeFar, 0.50, tipNear),
        ];
      case WindowOpeningType.openRightTilt:
        return [
          l(hingeNear, 0.25, tipFar, 0.50),
          l(hingeNear, 0.75, tipFar, 0.50),
          l(0.25, hingeFar, 0.50, tipNear),
          l(0.75, hingeFar, 0.50, tipNear),
        ];
      case WindowOpeningType.openLeftTilt:
        return [
          l(hingeFar, 0.25, tipNear, 0.50),
          l(hingeFar, 0.75, tipNear, 0.50),
          l(0.25, hingeFar, 0.50, tipNear),
          l(0.75, hingeFar, 0.50, tipNear),
        ];
    }
  }

  List<FrameLine> toFrameLines([Rect? bounds]) =>
      toFrameLinesTyped(bounds).map((e) => e.line).toList();

  List<({FrameLine line, MullionShape shape})> toFrameLinesTyped(
      [Rect? bounds]) {
    final rect = bounds ?? const Rect.fromLTWH(0, 0, 1, 1);
    if (isLeaf) return const [];

    final result = <({FrameLine line, MullionShape shape})>[];
    final dir = direction!;
    final kids = children!;
    final rats = ratios!;
    final shapes = dividerShapes!;
    var offset = 0.0;

    for (var i = 0; i < kids.length; i++) {
      final ratio = rats[i];
      final Rect childRect;

      if (dir == SplitDirection.vertical) {
        childRect = Rect.fromLTWH(
          rect.left + rect.width * offset,
          rect.top,
          rect.width * ratio,
          rect.height,
        );
      } else {
        childRect = Rect.fromLTWH(
          rect.left,
          rect.top + rect.height * offset,
          rect.width,
          rect.height * ratio,
        );
      }

      if (i > 0) {
        final shape = shapes[i - 1];
        if (dir == SplitDirection.vertical) {
          final x = childRect.left;
          result.add(
              (line: FrameLine(x, rect.top, x, rect.bottom), shape: shape));
        } else {
          final y = childRect.top;
          result.add(
              (line: FrameLine(rect.left, y, rect.right, y), shape: shape));
        }
      }

      result.addAll(kids[i].toFrameLinesTyped(childRect));
      offset += ratio;
    }

    return result;
  }

  WindowZone setDividerShapeAt(int flatIndex, MullionShape shape) {
    var counter = 0;
    WindowZone walk(WindowZone z) {
      if (z.isLeaf) return z.copyDeep();
      final kids = z.children!;
      final newShapes = List<MullionShape>.from(z.dividerShapes!);
      final newKids = <WindowZone>[];
      for (var i = 0; i < kids.length; i++) {
        if (i > 0) {
          if (counter == flatIndex) newShapes[i - 1] = shape;
          counter++;
        }
        newKids.add(walk(kids[i]));
      }
      return WindowZone.split(
        direction: z.direction!,
        children: newKids,
        ratios: List<double>.from(z.ratios!),
        dividerShapes: newShapes,
      );
    }

    return walk(this);
  }

  int? dividerIndexNear(Offset p, {double tol = 0.04}) {
    final lines = toFrameLinesTyped();
    int? best;
    var bestDist = tol;
    for (var i = 0; i < lines.length; i++) {
      final l = lines[i].line;
      final minX = l.startX < l.endX ? l.startX : l.endX;
      final maxX = l.startX < l.endX ? l.endX : l.startX;
      final minY = l.startY < l.endY ? l.startY : l.endY;
      final maxY = l.startY < l.endY ? l.endY : l.startY;
      final cx = p.dx.clamp(minX, maxX);
      final cy = p.dy.clamp(minY, maxY);
      final d = (Offset(cx, cy) - p).distance;
      if (d < bestDist) {
        bestDist = d;
        best = i;
      }
    }
    return best;
  }

  Map<MullionShape, ({double mm, int count, int tJunctions})>
      mullionStatsByShape(int totalWidthMm, int totalHeightMm,
          {Set<int>? skipLineIndices}) {
    const eps = 1e-6;
    bool onEdge(double v) => v.abs() < eps || (v - 1).abs() < eps;
    final acc = <MullionShape, List<num>>{}; 
    final typed = toFrameLinesTyped();
    for (var li = 0; li < typed.length; li++) {
      if (skipLineIndices != null && skipLineIndices.contains(li)) continue;
      final e = typed[li];
      final l = e.line;
      final isVertical = (l.startX - l.endX).abs() < eps;
      final mm = isVertical
          ? (l.endY - l.startY).abs() * totalHeightMm
          : (l.endX - l.startX).abs() * totalWidthMm;
      var tj = 0;
      if (!onEdge(l.startX) && !onEdge(l.startY)) tj++;
      if (!onEdge(l.endX) && !onEdge(l.endY)) tj++;
      final a = acc.putIfAbsent(e.shape, () => [0.0, 0, 0]);
      a[0] = (a[0] as double) + mm;
      a[1] = (a[1] as int) + 1;
      a[2] = (a[2] as int) + tj;
    }
    return {
      for (final e in acc.entries)
        e.key: (
          mm: e.value[0] as double,
          count: e.value[1] as int,
          tJunctions: e.value[2] as int
        ),
    };
  }

  List<FrameLine> toOpeningLinesForBoundingBox([Rect? bounds]) {
    final rect = bounds ?? const Rect.fromLTWH(0, 0, 1, 1);
    final infos = <(Rect, WindowOpeningType)>[];
    _collectOpeningZoneInfos(rect, infos);
    if (infos.isEmpty) return [];
    var bbox = infos.first.$1;
    for (var i = 1; i < infos.length; i++) {
      bbox = bbox.expandToInclude(infos[i].$1);
    }
    final isFull = bbox.width > 0.99 && bbox.height > 0.99;
    return _openingTypeLines(infos.first.$2, bbox, isFullWindow: isFull);
  }

  void _collectOpeningZoneInfos(
    Rect bounds,
    List<(Rect, WindowOpeningType)> result,
  ) {
    if (isLeaf) {
      if (openingType != WindowOpeningType.fixed) {
        result.add((bounds, openingType));
      }
      return;
    }
    var offset = 0.0;
    for (var i = 0; i < children!.length; i++) {
      final ratio = ratios![i];
      final childRect = _childRect(bounds, direction!, offset, ratio);
      children![i]._collectOpeningZoneInfos(childRect, result);
      offset += ratio;
    }
  }

  List<({Rect rect, WindowOpeningType type, bool isDoor, bool hasHandle})>
      groupedOpeningSashes([Rect? bounds]) {
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

    final ordered = clusters.values.toList()
      ..sort((p, q) => infos[p.first].$1.left.compareTo(infos[q.first].$1.left));

    final result =
        <({Rect rect, WindowOpeningType type, bool isDoor, bool hasHandle})>[];
    for (final cluster in ordered) {
      var bbox = infos[cluster.first].$1;
      for (final idx in cluster.skip(1)) {
        bbox = bbox.expandToInclude(infos[idx].$1);
      }
      final first = infos[cluster.first];
      result.add((
        rect: bbox,
        type: first.$2,
        isDoor: first.$3,
        hasHandle: first.$4,
      ));
    }
    return result;
  }

  List<FrameLine> groupedOpeningLines([Rect? bounds]) {
    final sashes = groupedOpeningSashes(bounds);
    final result = <FrameLine>[];
    for (final s in sashes) {
      final isFull = s.rect.width > 0.99 && s.rect.height > 0.99;
      result.addAll(
        _openingTypeLines(s.type, s.rect, isFullWindow: isFull, isDoor: s.isDoor),
      );
    }
    return result;
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

  Rect? leafRectContaining(Offset point, [Rect? bounds]) {
    final rect = bounds ?? const Rect.fromLTWH(0, 0, 1, 1);
    if (isLeaf) {
      return rect.contains(point) ? rect : null;
    }
    var offset = 0.0;
    for (var i = 0; i < children!.length; i++) {
      final ratio = ratios![i];
      final childRect = _childRect(rect, direction!, offset, ratio);
      if (childRect.contains(point)) {
        return children![i].leafRectContaining(point, childRect);
      }
      offset += ratio;
    }
    return null;
  }

  List<bool> openingZoneDoorFlags() {
    if (isLeaf) {
      return openingType != WindowOpeningType.fixed ? [isDoor] : [];
    }
    final result = <bool>[];
    for (final c in children!) {
      result.addAll(c.openingZoneDoorFlags());
    }
    return result;
  }

  List<bool> openingZoneHandleFlags() {
    if (isLeaf) {
      return openingType != WindowOpeningType.fixed ? [hasHandle] : [];
    }
    final result = <bool>[];
    for (final c in children!) {
      result.addAll(c.openingZoneHandleFlags());
    }
    return result;
  }

  List<WindowOpeningType> openingZoneTypes() {
    if (isLeaf) {
      return openingType != WindowOpeningType.fixed ? [openingType] : [];
    }
    final result = <WindowOpeningType>[];
    for (final c in children!) {
      result.addAll(c.openingZoneTypes());
    }
    return result;
  }

  WindowZone applyLayoutPatternAt(
    Offset position,
    WindowLayoutPattern pattern, {
    Rect? bounds,
  }) {
    final rect = bounds ?? const Rect.fromLTWH(0, 0, 1, 1);
    if (isLeaf) {
      if (pattern == WindowLayoutPattern.meshGrid &&
          (openingType == WindowOpeningType.fixed || isDoor)) {
        return copyDeep();
      }
      return WindowZone.leaf(
        openingType: openingType,
        openingDirectlyApplied: openingDirectlyApplied,
        isDoor: isDoor,
        hasHandle: hasHandle,
        layoutPattern: pattern,
      );
    }

    final dir = direction!;
    final kids = children!;
    final rats = ratios!;
    var offset = 0.0;

    for (var i = 0; i < kids.length; i++) {
      final ratio = rats[i];
      final childRect = _childRect(rect, dir, offset, ratio);
      if (childRect.contains(position)) {
        final newKids = List<WindowZone>.from(kids);
        newKids[i] = kids[i].applyLayoutPatternAt(
          position,
          pattern,
          bounds: childRect,
        );
        return WindowZone.split(
          direction: dir,
          children: newKids,
          ratios: List<double>.from(rats),
          dividerShapes: List<MullionShape>.from(dividerShapes!),
        );
      }
      offset += ratio;
    }
    return copyDeep();
  }

  List<({Rect rect, WindowLayoutPattern pattern})> layoutPatternRects([
    Rect? bounds,
  ]) {
    final rect = bounds ?? const Rect.fromLTWH(0, 0, 1, 1);
    if (isLeaf) {
      return layoutPattern != WindowLayoutPattern.none
          ? [(rect: rect, pattern: layoutPattern)]
          : const [];
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

  WindowZone applyDropAt(
    Offset position,
    WindowZone Function(Offset localPosition, WindowZone inheritedLeaf)
        splitFn, [
    Rect? bounds,
  ]) {
    final rect = bounds ?? const Rect.fromLTWH(0, 0, 1, 1);

    if (isLeaf) {
      final localX = (position.dx - rect.left) / rect.width;
      final localY = (position.dy - rect.top) / rect.height;
      return splitFn(
        Offset(localX.clamp(0, 1), localY.clamp(0, 1)),
        this,
      );
    }

    final dir = direction!;
    final kids = children!;
    final rats = ratios!;
    var offset = 0.0;

    for (var i = 0; i < kids.length; i++) {
      final ratio = rats[i];
      final Rect childRect;

      if (dir == SplitDirection.vertical) {
        childRect = Rect.fromLTWH(
          rect.left + rect.width * offset,
          rect.top,
          rect.width * ratio,
          rect.height,
        );
      } else {
        childRect = Rect.fromLTWH(
          rect.left,
          rect.top + rect.height * offset,
          rect.width,
          rect.height * ratio,
        );
      }

      if (childRect.contains(position)) {
        final newKids = List<WindowZone>.from(kids);
        newKids[i] = kids[i].applyDropAt(position, splitFn, childRect);
        return WindowZone.split(
          direction: dir,
          children: newKids,
          ratios: List<double>.from(rats),
          dividerShapes: List<MullionShape>.from(dividerShapes!),
        );
      }

      offset += ratio;
    }

    return copyDeep();
  }

  int bottomEdgeSegmentCount() {
    if (isLeaf) return 1;
    if (direction == SplitDirection.vertical) {
      var n = 0;
      for (final c in children!) {
        n += c.bottomEdgeSegmentCount();
      }
      return n;
    }
    return children!.last.bottomEdgeSegmentCount();
  }

  int rightEdgeSegmentCount() {
    if (isLeaf) return 1;
    if (direction == SplitDirection.horizontal) {
      var n = 0;
      for (final c in children!) {
        n += c.rightEdgeSegmentCount();
      }
      return n;
    }
    return children!.last.rightEdgeSegmentCount();
  }

  WindowZone applyColumnRatios(List<double> flatRatios) {
    if (isLeaf || flatRatios.length != bottomEdgeSegmentCount()) {
      return copyDeep();
    }
    return _applyColumnRatiosRecursive(flatRatios, 0, flatRatios.length);
  }

  WindowZone _applyColumnRatiosRecursive(
    List<double> flatRatios,
    int flatStart,
    int flatCount,
  ) {
    if (isLeaf) return copyDeep();

    final kids = children!;
    final rats = ratios!;

    if (direction == SplitDirection.vertical) {
      final newKids = <WindowZone>[];
      final newRatios = <double>[];
      var acc = flatStart;

      var segmentSum = 0.0;
      for (var k = flatStart; k < flatStart + flatCount; k++) {
        segmentSum += flatRatios[k];
      }
      if (segmentSum <= 1e-9) segmentSum = 1.0;

      for (var i = 0; i < kids.length; i++) {
        final cnt = kids[i].bottomEdgeSegmentCount();
        var childSum = 0.0;
        for (var k = acc; k < acc + cnt; k++) {
          childSum += flatRatios[k];
        }
        final childRatioInParent = childSum / segmentSum;
        newRatios.add(childRatioInParent);

        newKids.add(
          kids[i]._applyColumnRatiosRecursive(flatRatios, acc, cnt),
        );
        acc += cnt;
      }

      final ratioTotal = newRatios.fold(0.0, (a, b) => a + b);
      if (ratioTotal > 1e-9) {
        for (var i = 0; i < newRatios.length; i++) {
          newRatios[i] /= ratioTotal;
        }
      }

      return WindowZone.split(
        direction: SplitDirection.vertical,
        children: newKids,
        ratios: newRatios,
        dividerShapes: List<MullionShape>.from(dividerShapes!),
      );
    } else {
      final newKids = <WindowZone>[];
      for (var i = 0; i < kids.length; i++) {
        newKids.add(
          kids[i]._applyColumnRatiosRecursive(flatRatios, flatStart, flatCount),
        );
      }
      return WindowZone.split(
        direction: SplitDirection.horizontal,
        children: newKids,
        ratios: List<double>.from(rats),
        dividerShapes: List<MullionShape>.from(dividerShapes!),
      );
    }
  }

  WindowZone applyRowRatios(List<double> flatRatios) {
    if (isLeaf || flatRatios.length != rightEdgeSegmentCount()) {
      return copyDeep();
    }
    return _applyRowRatiosRecursive(flatRatios, 0, flatRatios.length);
  }

  WindowZone _applyRowRatiosRecursive(
    List<double> flatRatios,
    int flatStart,
    int flatCount,
  ) {
    if (isLeaf) return copyDeep();

    final kids = children!;
    final rats = ratios!;

    if (direction == SplitDirection.horizontal) {
      final newKids = <WindowZone>[];
      final newRatios = <double>[];
      var acc = flatStart;

      var segmentSum = 0.0;
      for (var k = flatStart; k < flatStart + flatCount; k++) {
        segmentSum += flatRatios[k];
      }
      if (segmentSum <= 1e-9) segmentSum = 1.0;

      for (var i = 0; i < kids.length; i++) {
        final cnt = kids[i].rightEdgeSegmentCount();
        var childSum = 0.0;
        for (var k = acc; k < acc + cnt; k++) {
          childSum += flatRatios[k];
        }
        final childRatioInParent = childSum / segmentSum;
        newRatios.add(childRatioInParent);

        newKids.add(
          kids[i]._applyRowRatiosRecursive(flatRatios, acc, cnt),
        );
        acc += cnt;
      }

      final ratioTotal = newRatios.fold(0.0, (a, b) => a + b);
      if (ratioTotal > 1e-9) {
        for (var i = 0; i < newRatios.length; i++) {
          newRatios[i] /= ratioTotal;
        }
      }

      return WindowZone.split(
        direction: SplitDirection.horizontal,
        children: newKids,
        ratios: newRatios,
        dividerShapes: List<MullionShape>.from(dividerShapes!),
      );
    } else {
      final newKids = <WindowZone>[];
      for (var i = 0; i < kids.length; i++) {
        newKids.add(
          kids[i]._applyRowRatiosRecursive(flatRatios, flatStart, flatCount),
        );
      }
      return WindowZone.split(
        direction: SplitDirection.vertical,
        children: newKids,
        ratios: List<double>.from(rats),
        dividerShapes: List<MullionShape>.from(dividerShapes!),
      );
    }
  }

  WindowZone updateVerticalRatioAt(int index, double newRatio,
      {Map<int, double> pinnedRatios = const {}}) {
    if (isLeaf) return copyDeep();
    return _resizeColumn(index, newRatio, 1.0, pinnedRatios: pinnedRatios);
  }

  WindowZone _resizeColumn(int flatIndex, double newAbs, double scale,
      {Map<int, double> pinnedRatios = const {}}) {
    if (isLeaf || flatIndex < 0 || flatIndex >= bottomEdgeSegmentCount()) {
      return copyDeep();
    }
    final kids = children!;
    final rats = ratios!;

    if (direction == SplitDirection.vertical) {
      var acc = 0;
      for (var i = 0; i < kids.length; i++) {
        final cnt = kids[i].bottomEdgeSegmentCount();
        if (flatIndex < acc + cnt) {
          if (cnt == 1) {
            final newRatios = List<double>.from(rats);
            final newLocal = newAbs / scale;

            if (pinnedRatios.isNotEmpty) {
              final pinnedSum = pinnedRatios.entries
                  .where((e) => e.key != i)
                  .fold(0.0, (a, e) => a + e.value);
              final remaining =
                  (1.0 - newLocal - pinnedSum).clamp(0.0, 1.0);
              final freeIndices = <int>[
                for (var j = 0; j < newRatios.length; j++)
                  if (j != i && !pinnedRatios.containsKey(j)) j
              ];
              if (freeIndices.isEmpty) return copyDeep();
              final minFree = 0.05 * freeIndices.length;
              if (newLocal < 0.05 || remaining < minFree) return copyDeep();
              final freeSum =
                  freeIndices.fold(0.0, (a, j) => a + newRatios[j]);
              newRatios[i] = newLocal;
              for (final j in freeIndices) {
                newRatios[j] = freeSum > 1e-9
                    ? newRatios[j] * remaining / freeSum
                    : remaining / freeIndices.length;
              }
              final total = newRatios.fold(0.0, (a, b) => a + b);
              if (total > 1e-9) {
                for (var j = 0; j < newRatios.length; j++) {
                  newRatios[j] /= total;
                }
              }
            } else {
              final neighbor = i == newRatios.length - 1
                  ? i - 1
                  : newRatios.length - 1;
              if (neighbor < 0) return copyDeep();
              final neighborNew =
                  newRatios[i] + newRatios[neighbor] - newLocal;
              if (newLocal < 0.1 || neighborNew < 0.1) return copyDeep();
              newRatios[i] = newLocal;
              newRatios[neighbor] = neighborNew;
            }

            return WindowZone.split(
              direction: direction!,
              children: kids.map((c) => c.copyDeep()).toList(),
              ratios: newRatios,
              dividerShapes: List<MullionShape>.from(dividerShapes!),
            );
          }
          final newKids = kids.map((c) => c.copyDeep()).toList();
          newKids[i] =
              kids[i]._resizeColumn(flatIndex - acc, newAbs, scale * rats[i]);
          return WindowZone.split(
            direction: direction!,
            children: newKids,
            ratios: List<double>.from(rats),
            dividerShapes: List<MullionShape>.from(dividerShapes!),
          );
        }
        acc += cnt;
      }
      return copyDeep();
    }

    return WindowZone.split(
      direction: direction!,
      children:
          kids.map((c) => c._resizeColumn(flatIndex, newAbs, scale)).toList(),
      ratios: List<double>.from(rats),
      dividerShapes: List<MullionShape>.from(dividerShapes!),
    );
  }

  WindowZone updateHorizontalRatioAt(int index, double newRatio) {
    if (isLeaf) return copyDeep();
    return _resizeRow(index, newRatio, 1.0);
  }

  WindowZone _resizeRow(int flatIndex, double newAbs, double scale) {
    if (isLeaf || flatIndex < 0 || flatIndex >= rightEdgeSegmentCount()) {
      return copyDeep();
    }
    final kids = children!;
    final rats = ratios!;

    if (direction == SplitDirection.horizontal) {
      var acc = 0;
      for (var i = 0; i < kids.length; i++) {
        final cnt = kids[i].rightEdgeSegmentCount();
        if (flatIndex < acc + cnt) {
          if (cnt == 1) {
            final newRatios = List<double>.from(rats);
            final newLocal = newAbs / scale;
            final neighbor = i == newRatios.length - 1
              ? i - 1
              : newRatios.length - 1;
            if (neighbor < 0) return copyDeep();
            final neighborNew =
                newRatios[i] + newRatios[neighbor] - newLocal;
            if (newLocal < 0.1 || neighborNew < 0.1) return copyDeep();
            newRatios[i] = newLocal;
            newRatios[neighbor] = neighborNew;
            return WindowZone.split(
              direction: direction!,
              children: kids.map((c) => c.copyDeep()).toList(),
              ratios: newRatios,
              dividerShapes: List<MullionShape>.from(dividerShapes!),
            );
          }
          final newKids = kids.map((c) => c.copyDeep()).toList();
          newKids[i] =
              kids[i]._resizeRow(flatIndex - acc, newAbs, scale * rats[i]);
          return WindowZone.split(
            direction: direction!,
            children: newKids,
            ratios: List<double>.from(rats),
            dividerShapes: List<MullionShape>.from(dividerShapes!),
          );
        }
        acc += cnt;
      }
      return copyDeep();
    }

    return WindowZone.split(
      direction: direction!,
      children:
          kids.map((c) => c._resizeRow(flatIndex, newAbs, scale)).toList(),
      ratios: List<double>.from(rats),
      dividerShapes: List<MullionShape>.from(dividerShapes!),
    );
  }

  List<int> widthSegments(int totalWidthMm) {
    final fractions = _collectBottomEdgeWidths();
    if (fractions.length <= 1) return const [];
    final segments = _fractionsToSegments(fractions, totalWidthMm);
    return segments.length > 1 ? segments : const [];
  }

  List<List<int>> widthSegmentBands(int totalWidthMm) {
    final bands = _collectWidthBandFractions();
    final result = <List<int>>[];
    for (final fractions in bands) {
      final segments = _fractionsToSegments(fractions, totalWidthMm);
      if (segments.length <= 1) continue;
      if (result.any((r) => _sameSegments(r, segments))) continue;
      result.add(segments);
    }
    return result;
  }

  static bool _sameSegments(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  List<int> heightSegments(int totalHeightMm) {
    final fractions = _collectRightEdgeHeights();
    if (fractions.length <= 1) return const [];
    final segments = _fractionsToSegments(fractions, totalHeightMm);
    return segments.length > 1 ? segments : const [];
  }

  List<double> _collectBottomEdgeWidths([Rect? bounds]) {
    final rect = bounds ?? const Rect.fromLTWH(0, 0, 1, 1);
    if (isLeaf) return [rect.width];

    final dir = direction!;
    final kids = children!;
    final rats = ratios!;
    var offset = 0.0;

    if (dir == SplitDirection.vertical) {
      final result = <double>[];
      for (var i = 0; i < kids.length; i++) {
        final childRect = Rect.fromLTWH(
          rect.left + rect.width * offset,
          rect.top,
          rect.width * rats[i],
          rect.height,
        );
        result.addAll(kids[i]._collectBottomEdgeWidths(childRect));
        offset += rats[i];
      }
      return result;
    }

    for (var i = 0; i < kids.length; i++) {
      final childRect = Rect.fromLTWH(
        rect.left,
        rect.top + rect.height * offset,
        rect.width,
        rect.height * rats[i],
      );
      offset += rats[i];
      if (i == kids.length - 1) {
        return kids[i]._collectBottomEdgeWidths(childRect);
      }
    }

    return [rect.width];
  }

  List<double> _collectRightEdgeHeights([Rect? bounds]) {
    final rect = bounds ?? const Rect.fromLTWH(0, 0, 1, 1);
    if (isLeaf) return [rect.height];

    final dir = direction!;
    final kids = children!;
    final rats = ratios!;
    var offset = 0.0;

    if (dir == SplitDirection.horizontal) {
      final result = <double>[];
      for (var i = 0; i < kids.length; i++) {
        final childRect = Rect.fromLTWH(
          rect.left,
          rect.top + rect.height * offset,
          rect.width,
          rect.height * rats[i],
        );
        result.addAll(kids[i]._collectRightEdgeHeights(childRect));
        offset += rats[i];
      }
      return result;
    }

    List<double>? best;
    List<double>? rightmost;
    for (var i = 0; i < kids.length; i++) {
      final childRect = Rect.fromLTWH(
        rect.left + rect.width * offset,
        rect.top,
        rect.width * rats[i],
        rect.height,
      );
      final segs = kids[i]._collectRightEdgeHeights(childRect);
      if (i == kids.length - 1) rightmost = segs;
      if (best == null || segs.length > best.length) best = segs;
      offset += rats[i];
    }
    if (rightmost != null && rightmost.length > 1) return rightmost;
    return best ?? [rect.height];
  }

  List<List<double>> _collectWidthBandFractions([Rect? bounds]) {
    final rect = bounds ?? const Rect.fromLTWH(0, 0, 1, 1);
    if (isLeaf) return const [];

    final dir = direction!;
    final kids = children!;
    final rats = ratios!;
    var offset = 0.0;

    if (dir == SplitDirection.horizontal) {
      final result = <List<double>>[];
      for (var i = 0; i < kids.length; i++) {
        final childRect = Rect.fromLTWH(
          rect.left,
          rect.top + rect.height * offset,
          rect.width,
          rect.height * rats[i],
        );
        result.addAll(kids[i]._collectWidthBandFractions(childRect));
        offset += rats[i];
      }
      return result;
    }

    final fractions = _collectVisibleWidthFractions(rect);
    if (fractions.length <= 1) return const [];
    return [fractions];
  }

  List<double> _collectVisibleWidthFractions([Rect? bounds]) {
    final rect = bounds ?? const Rect.fromLTWH(0, 0, 1, 1);
    if (isLeaf) return [rect.width];

    final dir = direction!;
    final kids = children!;
    final rats = ratios!;
    var offset = 0.0;

    if (dir == SplitDirection.horizontal) {
      return [rect.width];
    }

    final result = <double>[];
    for (var i = 0; i < kids.length; i++) {
      final childRect = Rect.fromLTWH(
        rect.left + rect.width * offset,
        rect.top,
        rect.width * rats[i],
        rect.height,
      );
      result.addAll(kids[i]._collectVisibleWidthFractions(childRect));
      offset += rats[i];
    }
    return result;
  }

  List<int> _fractionsToSegments(List<double> fractions, int total) {
    final segments = <int>[];
    var consumed = 0;
    for (var i = 0; i < fractions.length; i++) {
      final isLast = i == fractions.length - 1;
      final raw = fractions[i] * total;
      final value = isLast ? total - consumed : raw.round();
      segments.add(value);
      consumed += value;
    }
    return segments;
  }

  double totalMullionLengthMm(int totalWidthMm, int totalHeightMm) {
    const eps = 1e-6;
    var sum = 0.0;
    for (final line in toFrameLines()) {
      final isVertical = (line.startX - line.endX).abs() < eps;
      if (isVertical) {
        sum += (line.endY - line.startY).abs() * totalHeightMm;
      } else {
        sum += (line.endX - line.startX).abs() * totalWidthMm;
      }
    }
    return sum;
  }

  int mullionTJunctionCount() {
    const eps = 1e-6;
    bool onEdge(double v) => v.abs() < eps || (v - 1).abs() < eps;
    var count = 0;
    for (final line in toFrameLines()) {
      if (!onEdge(line.startX) && !onEdge(line.startY)) count++;
      if (!onEdge(line.endX) && !onEdge(line.endY)) count++;
    }
    return count;
  }

  int leafCount() {
    if (isLeaf) return 1;
    var n = 0;
    for (final c in children!) {
      n += c.leafCount();
    }
    return n;
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
    final verticalSplits = _collectVerticalSplits(bounds);
    if (verticalSplits.isNotEmpty) {
      final edges = [bounds.left, ...verticalSplits, bounds.right];
      final children = <WindowZone>[];
      final ratios = <double>[];

      for (var i = 0; i < edges.length - 1; i++) {
        final childRect = Rect.fromLTRB(
          edges[i],
          bounds.top,
          edges[i + 1],
          bounds.bottom,
        );
        children.add(build(childRect));
        final ratio = bounds.width > 0
            ? childRect.width / bounds.width
            : 1 / (edges.length - 1);
        ratios.add(ratio);
      }

      return WindowZone.split(
        direction: SplitDirection.vertical,
        children: children,
        ratios: ratios,
        dividerShapes: List<MullionShape>.filled(
            children.length - 1, MullionShape.witraj,
            growable: true),
      );
    }

    final horizontalSplits = _collectHorizontalSplits(bounds);
    if (horizontalSplits.isNotEmpty) {
      final edges = [bounds.top, ...horizontalSplits, bounds.bottom];
      final children = <WindowZone>[];
      final ratios = <double>[];

      for (var i = 0; i < edges.length - 1; i++) {
        final childRect = Rect.fromLTRB(
          bounds.left,
          edges[i],
          bounds.right,
          edges[i + 1],
        );
        children.add(build(childRect));
        final ratio = bounds.height > 0
            ? childRect.height / bounds.height
            : 1 / (edges.length - 1);
        ratios.add(ratio);
      }

      return WindowZone.split(
        direction: SplitDirection.horizontal,
        children: children,
        ratios: ratios,
      );
    }

    return WindowZone.leaf();
  }

  List<double> _collectVerticalSplits(Rect bounds) {
    final splits = <double>{};

    for (final line in lines) {
      final isVertical = (line.startX - line.endX).abs() < _epsilon;
      if (!isVertical) continue;
      final coversBounds = line.startY <= bounds.top + _epsilon &&
          line.endY >= bounds.bottom - _epsilon;
      final insideBounds = line.startX > bounds.left + _epsilon &&
          line.startX < bounds.right - _epsilon;

      if (coversBounds && insideBounds) {
        splits.add(line.startX);
      }
    }

    final sorted = splits.toList()..sort();
    return sorted;
  }

  List<double> _collectHorizontalSplits(Rect bounds) {
    final splits = <double>{};

    for (final line in lines) {
      final isHorizontal = (line.startY - line.endY).abs() < _epsilon;
      if (!isHorizontal) continue;
      final coversBounds = line.startX <= bounds.left + _epsilon &&
          line.endX >= bounds.right - _epsilon;
      final insideBounds = line.startY > bounds.top + _epsilon &&
          line.startY < bounds.bottom - _epsilon;

      if (coversBounds && insideBounds) {
        splits.add(line.startY);
      }
    }

    final sorted = splits.toList()..sort();
    return sorted;
  }
}
