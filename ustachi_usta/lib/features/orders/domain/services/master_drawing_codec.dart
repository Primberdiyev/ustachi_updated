import 'dart:ui' show Offset;

import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_ui_models.dart';
import 'package:ustachi/features/marketplace/domain/proposal_spec_codec.dart';

abstract final class MasterDrawingCodec {
  static const int version = 2;

  static const _precision = 10000;

  static double _round(double value) =>
      (value * _precision).roundToDouble() / _precision;

  static const _flagShared = [1, 2, 4, 8]; 
  static const _flagAbsorbed = [16, 32, 64, 128];
  static const _flagHideStroke = [256, 512, 1024, 2048];

  static Map<String, dynamic> encode(FramePreviewSpec spec) => {
        ...ProposalSpecCodec.encode(spec),
        'v': version,
        if (!spec.showFrame) 'noFrame': true,
        if (spec.lineThicknessScale != 1.0)
          'lineScale': _round(spec.lineThicknessScale),
        if (spec.displayScale != 1.0) 'dispScale': _round(spec.displayScale),
        if (spec.detailAspectRatioScale != 1.0)
          'arScale': _round(spec.detailAspectRatioScale),
        if (spec.frameBandScale != 1.0)
          'bandScale': _round(spec.frameBandScale),
        if (spec.regions.isNotEmpty)
          'regions': [
            for (final region in spec.regions)
              [
                _round(region.left),
                _round(region.top),
                _round(region.right),
                _round(region.bottom),
                _regionFlags(region),
              ],
          ],
        if (spec.hardwareTweaks.isNotEmpty)
          'tweaks': [
            for (final tweak in spec.hardwareTweaks) _encodeTweak(tweak),
          ],
      };

  static FramePreviewSpec? decode(Object? raw) {
    final base = ProposalSpecCodec.decode(raw);
    if (base == null || raw is! Map) return base;

    final json = Map<String, dynamic>.from(raw);

    return FramePreviewSpec(
      aspectRatio: base.aspectRatio,
      lines: base.lines,
      widthMm: base.widthMm,
      heightMm: base.heightMm,
      archHeightFactor: base.archHeightFactor,
      showGlass: base.showGlass,
      uniformFrameThickness: base.uniformFrameThickness,
      defaultOpeningCategory: base.defaultOpeningCategory,
      defaultOpeningIsDoor: base.defaultOpeningIsDoor,
      defaultOpeningSingleSash: base.defaultOpeningSingleSash,
      defaultZoneSetups: base.defaultZoneSetups,
      showFrame: json['noFrame'] != true,
      lineThicknessScale: _double(json['lineScale']) ?? 1.0,
      displayScale: _double(json['dispScale']) ?? 1.0,
      detailAspectRatioScale: _double(json['arScale']) ?? 1.0,
      frameBandScale: _double(json['bandScale']) ?? 1.0,
      regions: _decodeRegions(json['regions']),
      hardwareTweaks: _decodeTweaks(json['tweaks']),
    );
  }

  static int _regionFlags(FrameRegion region) {
    var flags = 0;
    final shared = [
      region.sharedLeft,
      region.sharedTop,
      region.sharedRight,
      region.sharedBottom,
    ];
    final absorbed = [
      region.absorbedLeft,
      region.absorbedTop,
      region.absorbedRight,
      region.absorbedBottom,
    ];
    final hidden = [
      region.hideOuterStrokeLeft,
      region.hideOuterStrokeTop,
      region.hideOuterStrokeRight,
      region.hideOuterStrokeBottom,
    ];
    for (var i = 0; i < 4; i++) {
      if (shared[i]) flags |= _flagShared[i];
      if (absorbed[i]) flags |= _flagAbsorbed[i];
      if (hidden[i]) flags |= _flagHideStroke[i];
    }
    return flags;
  }

  static List<FrameRegion> _decodeRegions(Object? raw) {
    if (raw is! List) return const [];

    final regions = <FrameRegion>[];
    for (final item in raw) {
      if (item is! List || item.length < 4) continue;
      final values = item.take(4).map(_double).toList();
      if (values.any((v) => v == null)) continue;

      final flags = item.length > 4 ? (_double(item[4])?.toInt() ?? 0) : 0;
      bool has(int bit) => flags & bit != 0;

      regions.add(FrameRegion(
        values[0]!,
        values[1]!,
        values[2]!,
        values[3]!,
        sharedLeft: has(_flagShared[0]),
        sharedTop: has(_flagShared[1]),
        sharedRight: has(_flagShared[2]),
        sharedBottom: has(_flagShared[3]),
        absorbedLeft: has(_flagAbsorbed[0]),
        absorbedTop: has(_flagAbsorbed[1]),
        absorbedRight: has(_flagAbsorbed[2]),
        absorbedBottom: has(_flagAbsorbed[3]),
        hideOuterStrokeLeft: has(_flagHideStroke[0]),
        hideOuterStrokeTop: has(_flagHideStroke[1]),
        hideOuterStrokeRight: has(_flagHideStroke[2]),
        hideOuterStrokeBottom: has(_flagHideStroke[3]),
      ));
    }
    return regions;
  }

  static Map<String, dynamic> _encodeTweak(ZoneHardwareTweak tweak) => {
        'x': _round(tweak.zoneCenter.dx),
        'y': _round(tweak.zoneCenter.dy),
        if (tweak.edge != null) 'edge': tweak.edge!.index,
        if (tweak.handleShiftFactor != null)
          'hsf': _round(tweak.handleShiftFactor!),
        if (tweak.hingeShift != null) 'hs': _round(tweak.hingeShift!),
        if (tweak.hingeAlongShift != null)
          'has': _round(tweak.hingeAlongShift!),
        if (tweak.hingeScale != null) 'hsc': _round(tweak.hingeScale!),
        if (tweak.handleScale != null) 'hasc': _round(tweak.handleScale!),
        if (tweak.handleFlushInset != null)
          'hfi': _round(tweak.handleFlushInset!),
        if (tweak.hingeFlushInset != null)
          'hgfi': _round(tweak.hingeFlushInset!),
        if (tweak.frameThicknessFactor != null)
          'ftf': _round(tweak.frameThicknessFactor!),
        if (tweak.frameInsetFactor != null)
          'fif': _round(tweak.frameInsetFactor!),
        if (tweak.minZoneWidth != 0) 'minW': _round(tweak.minZoneWidth),
        if (tweak.minZoneHeight != 0) 'minH': _round(tweak.minZoneHeight),
        if (tweak.maxZoneWidth != 1.01) 'maxW': _round(tweak.maxZoneWidth),
        if (tweak.maxZoneHeight != 1.01) 'maxH': _round(tweak.maxZoneHeight),
      };

  static List<ZoneHardwareTweak> _decodeTweaks(Object? raw) {
    if (raw is! List) return const [];

    final tweaks = <ZoneHardwareTweak>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final json = Map<String, dynamic>.from(item);
      final edgeIndex = _double(json['edge'])?.toInt();

      tweaks.add(ZoneHardwareTweak(
        zoneCenter: Offset(
          _double(json['x']) ?? 0.5,
          _double(json['y']) ?? 0.5,
        ),
        edge: (edgeIndex != null &&
                edgeIndex >= 0 &&
                edgeIndex < HardwareEdge.values.length)
            ? HardwareEdge.values[edgeIndex]
            : null,
        handleShiftFactor: _double(json['hsf']),
        hingeShift: _double(json['hs']),
        hingeAlongShift: _double(json['has']),
        hingeScale: _double(json['hsc']),
        handleScale: _double(json['hasc']),
        handleFlushInset: _double(json['hfi']),
        hingeFlushInset: _double(json['hgfi']),
        frameThicknessFactor: _double(json['ftf']),
        frameInsetFactor: _double(json['fif']),
        minZoneWidth: _double(json['minW']) ?? 0,
        minZoneHeight: _double(json['minH']) ?? 0,
        maxZoneWidth: _double(json['maxW']) ?? 1.01,
        maxZoneHeight: _double(json['maxH']) ?? 1.01,
      ));
    }
    return tweaks;
  }

  static double? _double(Object? value) => switch (value) {
        final num v => v.toDouble(),
        final String v => double.tryParse(v),
        _ => null,
      };
}
