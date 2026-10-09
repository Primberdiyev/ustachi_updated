import 'dart:ui' show Offset;

enum CalculateCategory {
  window,
  door,
  glass,
}

enum CalculateMaterial {
  plastic,
  aluminium,
  termo,
}

class CalculateMaterialItem {
  const CalculateMaterialItem({
    required this.material,
    required this.label,
  });

  final CalculateMaterial material;
  final String label;
}

class FramePreviewSpec {
  const FramePreviewSpec({
    required this.aspectRatio,
    required this.lines,
    this.showFrame = true,
    this.showGlass = true,
    this.lineThicknessScale = 1.0,
    this.widthMm,
    this.heightMm,
    this.displayScale = 1.0,
    this.detailAspectRatioScale = 1.0,
    this.frameBandScale = 1.0,
    this.regions = const [],
    this.hardwareTweaks = const [],
    this.uniformFrameThickness = false,
    this.defaultOpeningCategory,
    this.defaultOpeningIsDoor = false,
    this.defaultOpeningSingleSash = false,
    this.defaultZoneSetups = const [],
    this.archHeightFactor = 0.0,
  });

  final double aspectRatio;
  final List<FrameLine> lines;

  final double archHeightFactor;
  final bool showFrame;
  final bool showGlass;
  final double lineThicknessScale;
  final int? widthMm;
  final int? heightMm;

  final List<FrameRegion> regions;

  final double displayScale;

  final double detailAspectRatioScale;

  final double frameBandScale;

  final List<ZoneHardwareTweak> hardwareTweaks;

  final bool uniformFrameThickness;

  final int? defaultOpeningCategory;

  final bool defaultOpeningIsDoor;

  final bool defaultOpeningSingleSash;

  final List<DefaultZoneSetup> defaultZoneSetups;

  FramePreviewSpec copyWith({bool? uniformFrameThickness}) => FramePreviewSpec(
        aspectRatio: aspectRatio,
        lines: lines,
        showFrame: showFrame,
        showGlass: showGlass,
        lineThicknessScale: lineThicknessScale,
        widthMm: widthMm,
        heightMm: heightMm,
        displayScale: displayScale,
        detailAspectRatioScale: detailAspectRatioScale,
        regions: regions,
        hardwareTweaks: hardwareTweaks,
        uniformFrameThickness:
            uniformFrameThickness ?? this.uniformFrameThickness,
        defaultOpeningCategory: defaultOpeningCategory,
        defaultOpeningIsDoor: defaultOpeningIsDoor,
        defaultOpeningSingleSash: defaultOpeningSingleSash,
        defaultZoneSetups: defaultZoneSetups,
        archHeightFactor: archHeightFactor,
      );
}

class DefaultZoneSetup {
  const DefaultZoneSetup({
    required this.zoneCenter,
    this.openingCategory,
    this.openingIsDoor = false,
    this.openingHasHandle = true,
    this.openingSingleSash = false,
    this.layoutCategory,
  });

  final Offset zoneCenter;
  final int? openingCategory;
  final bool openingIsDoor;

  final bool openingHasHandle;

  final bool openingSingleSash;

  final int? layoutCategory;
}

enum HardwareEdge { left, right, top, bottom }

class ZoneHardwareTweak {
  const ZoneHardwareTweak({
    required this.zoneCenter,
    this.edge,
    this.handleShiftFactor,
    this.hingeShift,
    this.hingeAlongShift,
    this.hingeScale,
    this.handleScale,
    this.handleFlushInset,
    this.hingeFlushInset,
    this.frameThicknessFactor,
    this.frameInsetFactor,
    this.minZoneWidth = 0,
    this.minZoneHeight = 0,
    this.maxZoneWidth = 1.01,
    this.maxZoneHeight = 1.01,
  });

  final Offset zoneCenter;

  final double minZoneWidth;
  final double minZoneHeight;

  final double maxZoneWidth;
  final double maxZoneHeight;

  final HardwareEdge? edge;

  final double? handleShiftFactor;

  final double? hingeShift;

  final double? hingeAlongShift;

  final double? hingeScale;

  final double? handleScale;

  final double? handleFlushInset;

  final double? hingeFlushInset;

  final double? frameThicknessFactor;

  final double? frameInsetFactor;
}

class HeightMeasureSegment {
  const HeightMeasureSegment({
    required this.valueMm,
    this.editIndex,
    this.offsetMm = 0,
    this.isArch = false,
    this.editsTotalHeight = false,
    this.decorOverlays,
  });

  final int valueMm;
  final int? editIndex;
  final int offsetMm;
  final bool isArch;

  final bool editsTotalHeight;

  final List<int>? decorOverlays;
}

class FrameLine {
  const FrameLine(
    this.startX,
    this.startY,
    this.endX,
    this.endY,
  );

  final double startX;
  final double startY;
  final double endX;
  final double endY;

  @override
  bool operator ==(Object other) =>
      other is FrameLine &&
      startX == other.startX &&
      startY == other.startY &&
      endX == other.endX &&
      endY == other.endY;

  @override
  int get hashCode => Object.hash(startX, startY, endX, endY);
}

class FrameRegion {
  const FrameRegion(
    this.left,
    this.top,
    this.right,
    this.bottom, {
    this.sharedLeft = false,
    this.sharedTop = false,
    this.sharedRight = false,
    this.sharedBottom = false,
    this.absorbedLeft = false,
    this.absorbedTop = false,
    this.absorbedRight = false,
    this.absorbedBottom = false,
    this.hideOuterStrokeLeft = false,
    this.hideOuterStrokeTop = false,
    this.hideOuterStrokeRight = false,
    this.hideOuterStrokeBottom = false,
  });

  final double left;
  final double top;
  final double right;
  final double bottom;

  final bool sharedLeft;
  final bool sharedTop;
  final bool sharedRight;
  final bool sharedBottom;

  final bool absorbedLeft;
  final bool absorbedTop;
  final bool absorbedRight;
  final bool absorbedBottom;

  final bool hideOuterStrokeLeft;
  final bool hideOuterStrokeTop;
  final bool hideOuterStrokeRight;
  final bool hideOuterStrokeBottom;

  @override
  bool operator ==(Object other) =>
      other is FrameRegion &&
      left == other.left &&
      top == other.top &&
      right == other.right &&
      bottom == other.bottom &&
      sharedLeft == other.sharedLeft &&
      sharedTop == other.sharedTop &&
      sharedRight == other.sharedRight &&
      sharedBottom == other.sharedBottom &&
      absorbedLeft == other.absorbedLeft &&
      absorbedTop == other.absorbedTop &&
      absorbedRight == other.absorbedRight &&
      absorbedBottom == other.absorbedBottom &&
      hideOuterStrokeLeft == other.hideOuterStrokeLeft &&
      hideOuterStrokeTop == other.hideOuterStrokeTop &&
      hideOuterStrokeRight == other.hideOuterStrokeRight &&
      hideOuterStrokeBottom == other.hideOuterStrokeBottom;

  @override
  int get hashCode => Object.hash(
        left,
        top,
        right,
        bottom,
        sharedLeft,
        sharedTop,
        sharedRight,
        sharedBottom,
        absorbedLeft,
        absorbedTop,
        absorbedRight,
        absorbedBottom,
        hideOuterStrokeLeft,
        hideOuterStrokeTop,
        hideOuterStrokeRight,
        hideOuterStrokeBottom,
      );
}
