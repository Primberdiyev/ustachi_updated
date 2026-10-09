import 'dart:ui' show Offset;

import 'package:ustachi/features/calculate_prices/presentation/widgets/calculate_ui_models.dart';

abstract final class ProposalSpecCodec {
  static const _precision = 10000;

  static double _round(double value) =>
      (value * _precision).roundToDouble() / _precision;

  static Map<String, dynamic> encode(FramePreviewSpec spec) => {
        'ar': _round(spec.aspectRatio),
        'lines': [
          for (final line in spec.lines)
            [
              _round(line.startX),
              _round(line.startY),
              _round(line.endX),
              _round(line.endY),
            ],
        ],
        if (spec.archHeightFactor > 0) 'arch': _round(spec.archHeightFactor),
        if (spec.widthMm != null) 'w': spec.widthMm,
        if (spec.heightMm != null) 'h': spec.heightMm,
        if (!spec.showGlass) 'noGlass': true,
        if (spec.uniformFrameThickness) 'uniform': true,
        if (spec.defaultOpeningCategory != null)
          'openCat': spec.defaultOpeningCategory,
        if (spec.defaultOpeningIsDoor) 'openDoor': true,
        if (spec.defaultOpeningSingleSash) 'openSingle': true,
        if (spec.regions.isNotEmpty)
          'rg': [
            for (final r in spec.regions)
              [
                _round(r.left),
                _round(r.top),
                _round(r.right),
                _round(r.bottom),
                _regionFlags(r),
              ],
          ],
        if (spec.defaultZoneSetups.isNotEmpty)
          'zones': [
            for (final zone in spec.defaultZoneSetups)
              {
                'x': _round(zone.zoneCenter.dx),
                'y': _round(zone.zoneCenter.dy),
                if (zone.openingCategory != null) 'cat': zone.openingCategory,
                if (zone.openingIsDoor) 'door': true,
                if (!zone.openingHasHandle) 'noHandle': true,
                if (zone.openingSingleSash) 'single': true,
                if (zone.layoutCategory != null) 'fill': zone.layoutCategory,
              },
          ],
      };

  static FramePreviewSpec? decode(Object? raw) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);

    final lines = <FrameLine>[];
    for (final item in (json['lines'] as List? ?? const [])) {
      if (item is! List || item.length < 4) continue;
      final values = item.map(_toDouble).toList();
      if (values.any((v) => v == null)) continue;
      lines.add(FrameLine(values[0]!, values[1]!, values[2]!, values[3]!));
    }

    final aspect = _toDouble(json['ar']);
    if (aspect == null || aspect <= 0) return null;

    return FramePreviewSpec(
      aspectRatio: aspect,
      lines: lines,
      widthMm: _toInt(json['w']),
      heightMm: _toInt(json['h']),
      archHeightFactor: _toDouble(json['arch']) ?? 0.0,
      showGlass: json['noGlass'] != true,
      uniformFrameThickness: json['uniform'] == true,
      defaultOpeningCategory: _toInt(json['openCat']),
      defaultOpeningIsDoor: json['openDoor'] == true,
      defaultOpeningSingleSash: json['openSingle'] == true,
      regions: [
        for (final item in (json['rg'] as List? ?? const []))
          if (item is List && item.length >= 5) _decodeRegion(item),
      ].whereType<FrameRegion>().toList(),
      defaultZoneSetups: [
        for (final zone in (json['zones'] as List? ?? const []))
          if (zone is Map)
            DefaultZoneSetup(
              zoneCenter: Offset(
                _toDouble(zone['x']) ?? 0.5,
                _toDouble(zone['y']) ?? 0.5,
              ),
              openingCategory: _toInt(zone['cat']),
              openingIsDoor: zone['door'] == true,
              openingHasHandle: zone['noHandle'] != true,
              openingSingleSash: zone['single'] == true,
              layoutCategory: _toInt(zone['fill']),
            ),
      ],
    );
  }

  static int _regionFlags(FrameRegion r) {
    var bits = 0;
    final flags = [
      r.sharedLeft, r.sharedTop, r.sharedRight, r.sharedBottom,
      r.absorbedLeft, r.absorbedTop, r.absorbedRight, r.absorbedBottom,
      r.hideOuterStrokeLeft, r.hideOuterStrokeTop,
      r.hideOuterStrokeRight, r.hideOuterStrokeBottom,
    ];
    for (var i = 0; i < flags.length; i++) {
      if (flags[i]) bits |= 1 << i;
    }
    return bits;
  }

  static FrameRegion? _decodeRegion(List item) {
    final v = item.take(4).map(_toDouble).toList();
    if (v.any((e) => e == null)) return null;
    final bits = _toInt(item[4]) ?? 0;
    bool f(int i) => (bits & (1 << i)) != 0;
    return FrameRegion(
      v[0]!, v[1]!, v[2]!, v[3]!,
      sharedLeft: f(0), sharedTop: f(1), sharedRight: f(2), sharedBottom: f(3),
      absorbedLeft: f(4), absorbedTop: f(5),
      absorbedRight: f(6), absorbedBottom: f(7),
      hideOuterStrokeLeft: f(8), hideOuterStrokeTop: f(9),
      hideOuterStrokeRight: f(10), hideOuterStrokeBottom: f(11),
    );
  }

  static double? _toDouble(Object? value) => switch (value) {
        final num v => v.toDouble(),
        final String v => double.tryParse(v),
        _ => null,
      };

  static int? _toInt(Object? value) => switch (value) {
        final int v => v,
        final num v => v.toInt(),
        final String v => int.tryParse(v),
        _ => null,
      };
}
