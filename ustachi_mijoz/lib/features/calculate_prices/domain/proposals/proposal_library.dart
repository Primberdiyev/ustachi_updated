import 'dart:ui' show Offset, Rect;

import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_layouts.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_models.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_symmetry.dart';
import 'package:ustachi/features/calculate_prices/domain/proposals/proposal_templates.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_preview_specs.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_ui_models.dart';
import 'package:ustachi/features/calculate_prices/presentation/widgets/window_zone_model.dart';

const _tolerance = 0.15; 

const _maxLibrary = 3;

const _casementMinMm = 400;
const _casementMaxMm = 900;
const _casementMinHeightMm = 600;

const _ventMinHeightMm = 250;

List<ProposalTemplate> proposalLibraryMatches(
  ProposalType type,
  int widthMm,
  int heightMm, {
  int limit = _maxLibrary,
}) {
  if (widthMm <= 0 || heightMm <= 0) return const [];

  final groups = switch (type) {
    ProposalType.window => CalculatePreviewSpecs.windowTemplateGroups,
    ProposalType.door => CalculatePreviewSpecs.doorTemplateGroups,
    ProposalType.arch => CalculatePreviewSpecs.archTemplateGroups,
  };

  final scored = <({FramePreviewSpec spec, double dist})>[];
  final seen = <String>{};
  for (final group in groups) {
    for (final spec in group) {
      final sw = spec.widthMm;
      final sh = spec.heightMm;
      if (sw == null || sh == null || sw <= 0 || sh <= 0) continue;

      if (spec.regions.isNotEmpty) continue;

      if (spec.lines.isEmpty) continue;

      if (type == ProposalType.window &&
          !paneLayoutIsMirrorSymmetric(
              WindowZone.fromFramePreviewSpec(spec).leafRects())) {
        continue;
      }

      final dw = (sw - widthMm).abs() / widthMm;
      final dh = (sh - heightMm).abs() / heightMm;
      if (dw > _tolerance || dh > _tolerance) continue;

      final sig = spec.lines
          .map((l) => '${l.startX},${l.startY},${l.endX},${l.endY}')
          .join(';');
      if (!seen.add(sig)) continue;

      scored.add((spec: spec, dist: dw > dh ? dw : dh));
    }
  }
  if (scored.isEmpty) return const [];
  scored.sort((a, b) => a.dist.compareTo(b.dist));

  return [
    for (final s in scored.take(limit))
      _toTemplate(s.spec, type, widthMm, heightMm),
  ];
}

ProposalTemplate _toTemplate(
    FramePreviewSpec spec, ProposalType type, int widthMm, int heightMm) {

  final hasOpening = spec.defaultOpeningCategory != null ||
      spec.defaultZoneSetups.any((s) => s.openingCategory != null);

  final setups = <DefaultZoneSetup>[
    ...spec.defaultZoneSetups,

    if (!hasOpening) ..._autoOpenings(spec, widthMm, heightMm),
  ];

  final leafCount = WindowZone.fromFramePreviewSpec(spec).leafRects().length;
  final kind = switch (type) {
    ProposalType.door => 'eshik',
    ProposalType.arch => 'arka',
    ProposalType.window => 'deraza',
  };
  return ProposalTemplate(
    type: type,
    title: 'Tayyor shablon: $leafCount bo\'lmali $kind',
    subtitle: '${spec.widthMm}×${spec.heightMm} mm dizayni',
    lines: spec.lines,
    zoneSetups: setups,
    defaultOpeningCategory: spec.defaultOpeningCategory,
    defaultOpeningIsDoor: spec.defaultOpeningIsDoor,
    defaultOpeningSingleSash: spec.defaultOpeningSingleSash,
    archHeightFactor: spec.archHeightFactor,
  );
}

List<DefaultZoneSetup> _autoOpenings(
    FramePreviewSpec spec, int widthMm, int heightMm) {
  final leaves = WindowZone.fromFramePreviewSpec(spec).leafRects();
  final out = <DefaultZoneSetup>[..._ventOpenings(leaves, widthMm, heightMm)];

  final cands = <Rect>[];
  for (final r in leaves) {
    if (r.bottom < 0.9) continue; 
    final mmW = r.width * widthMm;
    final mmH = r.height * heightMm;
    if (mmW < _casementMinMm || mmW > _casementMaxMm) continue;
    if (mmH < _casementMinHeightMm) continue;
    cands.add(r);
  }
  if (cands.isEmpty) return out;
  cands.sort((a, b) => a.left.compareTo(b.left));
  final picked = cands.length >= 3
      ? <Rect>[cands.first, cands.last]
      : <Rect>[cands[cands.length ~/ 2]];
  return [
    ...out,
    for (final r in picked)
      DefaultZoneSetup(
        zoneCenter: Offset(r.center.dx, r.center.dy),
        openingCategory: proposalCasementCategory(
          widthMm: (r.width * widthMm).round(),
          heightMm: (r.height * heightMm).round(),
          leftSide: r.center.dx < 0.5,
        ),
      ),
  ];
}

List<DefaultZoneSetup> _ventOpenings(
    List<Rect> leaves, int widthMm, int heightMm) {
  final out = <DefaultZoneSetup>[];
  for (final r in leaves) {
    if (r.top > 0.001) continue; 
    final mmW = r.width * widthMm;
    final mmH = r.height * heightMm;
    if (mmH < _ventMinHeightMm || mmH >= _casementMinHeightMm) continue;
    if (mmW < _casementMinMm || mmW > _casementMaxMm) continue;
    out.add(DefaultZoneSetup(
      zoneCenter: Offset(r.center.dx, r.center.dy),
      openingCategory: proposalTiltCategory,
    ));
  }
  return out;
}
