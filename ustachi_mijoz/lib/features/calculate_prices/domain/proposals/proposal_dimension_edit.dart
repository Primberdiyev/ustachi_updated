import 'dart:ui' show Offset;

import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_ui_models.dart';

const proposalMinSegmentMm = 150;

const proposalMinSideMm = 300;
const proposalMaxWidthMm = 12000;
const proposalMaxHeightMm = 4000;

List<double>? proposalSegmentBreaks(
    List<double> breaksMm, int index, int newMm) {
  final n = breaksMm.length - 1;
  if (n < 2 || index < 0 || index >= n) return null;
  final delta = newMm - (breaksMm[index + 1] - breaksMm[index]);
  final out = [...breaksMm];
  if (index == 0) {
    out[1] += delta;
  } else if (index == n - 1) {
    out[n - 1] -= delta;
  } else {
    final left = (delta / 2).floorToDouble();
    out[index] -= left;
    out[index + 1] += delta - left;
  }
  for (var i = 0; i < n; i++) {
    if (out[i + 1] - out[i] < proposalMinSegmentMm - 0.5) return null;
  }
  return out;
}

FramePreviewSpec proposalRemapSpecAxis(
  FramePreviewSpec spec, {
  required bool horizontal,
  required List<double> fromMm,
  required List<double> toMm,
}) {
  final total = fromMm.last;
  final from = [for (final b in fromMm) b / total];
  final to = [for (final b in toMm) b / total];

  final tol = 0.5 / total;

  double map(double v) {
    if (v <= 0 || v >= 1) return v;
    for (var k = 0; k < from.length; k++) {
      if ((v - from[k]).abs() <= tol) return to[k];
    }
    for (var k = 0; k + 1 < from.length; k++) {
      if (v > from[k] && v < from[k + 1]) {
        return to[k] +
            (v - from[k]) / (from[k + 1] - from[k]) * (to[k + 1] - to[k]);
      }
    }
    return v;
  }

  double x(double v) => horizontal ? map(v) : v;
  double y(double v) => horizontal ? v : map(v);

  return FramePreviewSpec(
    aspectRatio: spec.aspectRatio,
    widthMm: spec.widthMm,
    heightMm: spec.heightMm,
    lines: [
      for (final l in spec.lines)
        FrameLine(x(l.startX), y(l.startY), x(l.endX), y(l.endY))
    ],
    showFrame: spec.showFrame,
    showGlass: spec.showGlass,
    lineThicknessScale: spec.lineThicknessScale,
    displayScale: spec.displayScale,
    detailAspectRatioScale: spec.detailAspectRatioScale,
    frameBandScale: spec.frameBandScale,
    hardwareTweaks: spec.hardwareTweaks,
    uniformFrameThickness: spec.uniformFrameThickness,
    defaultOpeningCategory: spec.defaultOpeningCategory,
    defaultOpeningIsDoor: spec.defaultOpeningIsDoor,
    defaultOpeningSingleSash: spec.defaultOpeningSingleSash,
    plainDoorPosts: spec.plainDoorPosts,
    defaultZoneSetups: [
      for (final z in spec.defaultZoneSetups)
        DefaultZoneSetup(
          zoneCenter: Offset(x(z.zoneCenter.dx), y(z.zoneCenter.dy)),
          openingCategory: z.openingCategory,
          openingIsDoor: z.openingIsDoor,
          openingHasHandle: z.openingHasHandle,
          openingSingleSash: z.openingSingleSash,
          layoutCategory: z.layoutCategory,
        ),
    ],
    archHeightFactor: spec.archHeightFactor > 0
        ? y(spec.archHeightFactor)
        : spec.archHeightFactor,
    regions: [
      for (final r in spec.regions)
        FrameRegion(
          x(r.left),
          y(r.top),
          x(r.right),
          y(r.bottom),
          sharedLeft: r.sharedLeft,
          sharedTop: r.sharedTop,
          sharedRight: r.sharedRight,
          sharedBottom: r.sharedBottom,
          absorbedLeft: r.absorbedLeft,
          absorbedTop: r.absorbedTop,
          absorbedRight: r.absorbedRight,
          absorbedBottom: r.absorbedBottom,
          hideOuterStrokeLeft: r.hideOuterStrokeLeft,
          hideOuterStrokeTop: r.hideOuterStrokeTop,
          hideOuterStrokeRight: r.hideOuterStrokeRight,
          hideOuterStrokeBottom: r.hideOuterStrokeBottom,
        ),
    ],
  );
}

final _sizeParts = RegExp(r'^\d+(?: \+ \d+)* mm');

String proposalSubtitleWithWidths(String subtitle, List<double> widthBreaksMm) {
  final match = _sizeParts.firstMatch(subtitle);
  if (match == null) return subtitle;
  final oldCount = ' + '.allMatches(match.group(0)!).length + 1;
  final widths = [
    for (var i = 0; i + 1 < widthBreaksMm.length; i++)
      (widthBreaksMm[i + 1] - widthBreaksMm[i]).round(),
  ];
  if (widths.length == oldCount)
    return subtitle.replaceRange(
        match.start, match.end, '${widths.join(' + ')} mm');
  final rest = subtitle.substring(match.end);
  return rest.startsWith(' · ') ? rest.substring(3) : rest.trimLeft();
}
