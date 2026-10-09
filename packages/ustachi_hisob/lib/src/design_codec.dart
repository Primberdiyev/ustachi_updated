
library;

import 'package:ustachi_hisob/src/design.dart';

const designCodecVersion = 1;

Map<String, dynamic> designToJson(FrameDesign d) => {
      'v': designCodecVersion,
      'w': d.widthMm,
      'h': d.heightMm,
      if (d.archRiseMm > 0) 'arch': d.archRiseMm,
      'root': cellToJson(d.root),
    };

FrameDesign designFromJson(Map<String, dynamic> json) {
  final v = (json['v'] as num?)?.toInt() ?? 1;
  if (v > designCodecVersion) {
    throw DesignException("Chizma yangi versiyada saqlangan (v$v) — ilovani yangilang.");
  }
  return FrameDesign(
    widthMm: (json['w'] as num).toDouble(),
    heightMm: (json['h'] as num).toDouble(),
    archRiseMm: (json['arch'] as num?)?.toDouble() ?? 0,
    root: cellFromJson(Map<String, dynamic>.from(json['root'] as Map)),
  );
}

Map<String, dynamic> cellToJson(Cell c) => switch (c) {
      Zone(:final fill) => {'t': 'z', if (fill != Fill.glass) 'f': fill.name},
      Split(:final axis, :final positionsMm, :final children, :final chiftQuloq, :final chiftImposts, :final balcony) => {
          't': 's',
          'a': axis.name,
          'p': positionsMm,
          if (chiftQuloq) 'cq': true,
          if (chiftImposts.isNotEmpty) 'cqi': chiftImposts.toList()..sort(),
          if (balcony) 'bk': true,
          'c': [for (final k in children) cellToJson(k)],
        },
      Wing(:final kind, :final content, :final hasHandle, :final handleSide, :final balcony) => {
          't': 'w',
          'k': kind.name,
          if (!hasHandle) 'nh': true,
          if (handleSide != WingSide.right) 'hs': handleSide.name,
          if (balcony) 'bk': true,
          'c': cellToJson(content),
        },
    };

T _byName<T extends Enum>(List<T> values, Object? name, String what) {
  for (final v in values) {
    if (v.name == name) return v;
  }
  throw DesignException("Saqlangan chizmada noma'lum $what: $name");
}

Cell cellFromJson(Map<String, dynamic> json) {
  switch (json['t']) {
    case 'z':
      return Zone(json['f'] == null ? Fill.glass : _byName(Fill.values, json['f'], "to'ldirma"));
    case 's':
      return Split(
        axis: _byName(Axis.values, json['a'], "yo'nalish"),
        positionsMm: [for (final p in json['p'] as List) (p as num).toDouble()],
        children: [
          for (final k in json['c'] as List) cellFromJson(Map<String, dynamic>.from(k as Map)),
        ],
        chiftQuloq: json['cq'] == true,
        chiftImposts: {for (final i in (json['cqi'] as List?) ?? const []) (i as num).toInt()},
        balcony: json['bk'] == true,
      );
    case 'w':
      return Wing(
        _byName(WingKind.values, json['k'], 'qanot turi'),
        cellFromJson(Map<String, dynamic>.from(json['c'] as Map)),
        json['nh'] != true,
        json['hs'] == null ? WingSide.right : _byName(WingSide.values, json['hs'], 'tutqich tomoni'),
        json['bk'] == true,
      );
  }
  throw DesignException("Saqlangan chizmada noma'lum katak: ${json['t']}");
}
