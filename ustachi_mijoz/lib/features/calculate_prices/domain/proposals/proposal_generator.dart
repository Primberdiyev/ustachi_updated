import 'package:ustachi/features/calculate_prices/domain/proposals/door_width_advice.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_dimension_edit.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_layouts.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_models.dart'
    hide proposalMinSideMm, proposalMaxWidthMm, proposalMaxHeightMm;
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_rom_design.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_templates.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/rom_design.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_ui_models.dart';

class ProposalGenerator {
  const ProposalGenerator();

  List<ProposalOption> generate(ProposalRequest req) {
    final fixedSide = [
      for (final l in proposalDoorFixedSideLayouts(req.widthMm, req.heightMm))
        l.toTemplate(req.type, req.widthMm, req.heightMm),
    ];
    final fixedOnly = proposalFixedSideDoorReplaces(
      shape: req.shape,
      widthMm: req.widthMm,
    );
    final templates = fixedOnly
        ? fixedSide
        : [
            if (req.fixedSideDoor &&
                proposalIsWideSingleDoor(
                  shape: req.shape,
                  widthMm: req.widthMm,
                ))
              ...fixedSide,
            ...proposalTemplatesFor(
              req.type,
              req.widthMm,
              req.heightMm,
              floorGapMm: req.floorGapMm,
              doorOnRight: req.doorOnRight,
              tShape: req.shape == ProposalShape.tEshik,
            ),
          ];
    final options = <ProposalOption>[];
    for (final t in templates) {
      if (req.type == ProposalType.door &&
          proposalHasOverwideDoorLeaf(t, req.widthMm, req.heightMm)) {
        continue;
      }
      final option = optionFor(t, req);
      if (option != null) options.add(option);
    }

    return [
      ...options.where((o) => o.pinFirst),
      ...options.where((o) => !o.pinFirst && o.isPopular),
      ...options.where((o) => !o.pinFirst && !o.isPopular),
    ];
  }

  ProposalOption? optionFor(ProposalTemplate t, ProposalRequest req) {
    final spec = t.buildSpec(req.widthMm, req.heightMm);
    try {
      proposalRomDesign(spec, req.widthMm, req.heightMm);
    } on RomDesignException {
      return null;
    }
    return ProposalOption(
      spec: spec,
      title: t.title,
      subtitle: t.subtitle,
      isPopular: t.isPopular,
      pinFirst: t.pinFirst,
    );
  }
}

({ProposalOption option, bool sameShape})? proposalResize({
  required ProposalOption current,
  required ProposalRequest request,
}) {
  const gen = ProposalGenerator();
  final spec = current.spec;
  if (spec.widthMm == request.widthMm && spec.heightMm == request.heightMm) {
    return (option: current, sameShape: true);
  }

  final options = gen.generate(request);
  final found = options
          .where(
              (o) => o.title == current.title && o.subtitle == current.subtitle)
          .firstOrNull ??
      options.where((o) => o.title == current.title).firstOrNull;
  if (found != null) {
    return (
      option: _keepUnchangedAxes(found, current, request),
      sameShape: true
    );
  }
  final scaled = gen.optionFor(_templateOf(current, spec, request.type), request);
  if (scaled != null && proposalShapeIsBuildable(scaled.spec)) {
    return (
      option: _keepUnchangedAxes(scaled, current, request),
      sameShape: true
    );
  }
  if (options.isEmpty) return null;
  final popular = options.where((o) => o.isPopular);
  return (
    option: popular.isNotEmpty ? popular.first : options.first,
    sameShape: false
  );
}

ProposalOption _keepUnchangedAxes(
  ProposalOption o,
  ProposalOption current,
  ProposalRequest request,
) {
  if (o.title != current.title) return o;
  var spec = o.spec;
  var keptWidths = false;
  for (final horizontal in const [true, false]) {
    final total = horizontal ? spec.widthMm : spec.heightMm;
    if (total == null ||
        total != (horizontal ? current.spec.widthMm : current.spec.heightMm)) {
      continue;
    }
    final from = _axisCoords(spec, horizontal);
    final to = _axisCoords(current.spec, horizontal);
    if (from.length != to.length) continue;
    var same = true;
    for (var i = 0; i < from.length; i++) {
      if ((from[i] - to[i]).abs() > 1e-6) same = false;
    }
    if (same) continue;
    spec = proposalRemapSpecAxis(
      spec,
      horizontal: horizontal,
      fromMm: [0, for (final v in from) v * total, total.toDouble()],
      toMm: [0, for (final v in to) v * total, total.toDouble()],
    );
    if (horizontal) keptWidths = true;
  }
  if (identical(spec, o.spec)) return o;
  if (proposalShapeIsBuildable(o.spec) && !proposalShapeIsBuildable(spec)) {
    return o;
  }
  return const ProposalGenerator().optionFor(
        _templateOf(o, spec, request.type,
            subtitle: keptWidths ? current.subtitle : null, snap: false),
        request,
      ) ??
      o;
}

List<double> _axisCoords(FramePreviewSpec spec, bool horizontal) {
  final values = <double>[
    for (final l in spec.lines)
      ...(horizontal ? [l.startX, l.endX] : [l.startY, l.endY]),
    for (final r in spec.regions)
      ...(horizontal ? [r.left, r.right] : [r.top, r.bottom]),
    if (!horizontal && spec.archHeightFactor > 0) spec.archHeightFactor,
  ]..sort();
  final out = <double>[];
  for (final v in values) {
    if (v <= 1e-6 || v >= 1 - 1e-6) continue;
    if (out.isEmpty || v - out.last > 1e-6) out.add(v);
  }
  return out;
}

ProposalTemplate _templateOf(
  ProposalOption current,
  FramePreviewSpec spec,
  ProposalType type, {
  String? subtitle,
  bool snap = true,
}) =>
    ProposalTemplate(
      type: type,
      title: current.title,
      subtitle: subtitle ?? current.subtitle,
      lines: spec.lines,
      zoneSetups: spec.defaultZoneSetups,
      defaultOpeningCategory: spec.defaultOpeningCategory,
      defaultOpeningIsDoor: spec.defaultOpeningIsDoor,
      defaultOpeningSingleSash: spec.defaultOpeningSingleSash,
      isPopular: current.isPopular,
      pinFirst: current.pinFirst,
      archHeightFactor: spec.archHeightFactor,
      regions: spec.regions,
      snapToGrid: snap,
      plainDoorPosts: spec.plainDoorPosts,
    );

({ProposalOption? option, ProposalRequest request, String? error})
    proposalEditSegment({
  required ProposalOption current,
  required ProposalRequest request,
  required bool horizontal,
  required List<double> breaksMm,
  required int index,
  required int newMm,
}) {
  final breaks = proposalSegmentBreaks(breaksMm, index, newMm);
  if (breaks == null) {
    return (
      option: null,
      request: request,
      error: 'Har bo\'lak kamida $proposalMinSegmentMm mm bo\'lishi kerak'
    );
  }
  final spec = proposalRemapSpecAxis(current.spec,
      horizontal: horizontal, fromMm: breaksMm, toMm: breaks);
  final w = spec.widthMm ?? request.widthMm;
  final h = spec.heightMm ?? request.heightMm;
  try {
    proposalRomDesign(spec, w, h);
  } on RomDesignException {
    return (
      option: null,
      request: request,
      error: 'Bu o\'lchamda rom yasalmaydi'
    );
  }
  if (proposalShapeIsBuildable(current.spec) &&
      !proposalShapeIsBuildable(spec)) {
    return (
      option: null,
      request: request,
      error:
          'Ochiladigan tavaqa juda tor yoki keng bo\'lib qoladi (300–1000 mm)',
    );
  }

  var next = request;
  if (!horizontal && request.floorGapMm > 0) {
    for (final r in spec.regions) {
      if (r.bottom < 1 - 1e-6) {
        next = next.copyWith(floorGapMm: ((1 - r.bottom) * h).round());
        break;
      }
    }
  }

  final subtitle = horizontal
      ? proposalSubtitleWithWidths(current.subtitle, breaks)
      : current.subtitle;
  final option = const ProposalGenerator().optionFor(
      _templateOf(current, spec, next.type, subtitle: subtitle, snap: false),
      next);
  if (option == null) {
    return (
      option: null,
      request: request,
      error: 'Bu o\'lchamda rom yasalmaydi'
    );
  }
  return (option: option, request: next, error: null);
}

bool proposalShapeIsBuildable(FramePreviewSpec spec) {
  final w = spec.widthMm ?? 0;
  final h = spec.heightMm ?? 0;
  if (w <= 0 || h <= 0) return false;
  final ProposalRomDesign design;
  try {
    design = proposalRomDesign(spec, w, h);
  } on RomDesignException {
    return false;
  }
  var ok = true;
  void walk(RomCell c, double cw, double ch) {
    if (!ok) return;
    switch (c) {
      case RomZone():
        if (cw < 150 || ch < 150) ok = false;
      case RomSplit(:final axis, :final positionsMm, :final children):
        final vertical = axis == RomAxis.vertical;
        final size = vertical ? cw : ch;
        var prev = 0.0;
        for (var i = 0; i < children.length; i++) {
          final next = i < positionsMm.length ? positionsMm[i] : size;
          walk(children[i], vertical ? next - prev : cw,
              vertical ? ch : next - prev);
          prev = next;
        }
      case RomWing(:final function, :final content):
        final (minW, maxW) = switch (function) {
          RomWingFunction.door => (350.0, 1000.0),
          RomWingFunction.tilt => (300.0, 1700.0),
          _ => (300.0, 1000.0),
        };
        if (cw < minW || cw > maxW || ch < 300) ok = false;
        walk(content, cw, ch);
    }
  }

  for (final f in design.frames) {
    walk(f.root, f.widthMm, f.heightMm);
  }
  return ok;
}
