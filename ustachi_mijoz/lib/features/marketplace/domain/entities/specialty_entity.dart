import 'package:equatable/equatable.dart';
import 'package:ustachi/features/marketplace/domain/entities/specialty_calculator_defaults.dart';

enum SpecialtyCalculator {
  none,

  rom,

  area,

  variant,

  masonry,

  roof,

  beton,

  heating,
  electrical;

  static SpecialtyCalculator fromCode(String? code) => switch (code) {
        'rom' => SpecialtyCalculator.rom,
        'area' => SpecialtyCalculator.area,
        'variant' => SpecialtyCalculator.variant,
        'masonry' => SpecialtyCalculator.masonry,
        'roof' => SpecialtyCalculator.roof,
        'beton' => SpecialtyCalculator.beton,
        'heating' => SpecialtyCalculator.heating,
        'electrical' => SpecialtyCalculator.electrical,
        _ => SpecialtyCalculator.none,
      };
}

const penthouseServerName = 'Penthaus gidro tom';
const penthouseDisplayName = 'Tom gidro izolyatsiya terassa pent haus PVX TPO membrana';

String specialtyDisplayName(String name) => name.trim() == penthouseServerName ? penthouseDisplayName : name;

class SpecialtyEntity extends Equatable {
  const SpecialtyEntity({
    required this.id,
    required this.code,
    required this.name,
    this.unit = '',
    this.calculator = SpecialtyCalculator.none,
    this.areaTiers = const [],
    this.variants = const [],
    this.variantPriceIsMaterial = false,
    this.bricks = const [],
    this.calculatorFromServer = false,
    this.group = '',
    this.hasRepair = false,
    this.repairProblems = const [],
  });

  /// Bu sohada mijoz "Ta'mir"ni ham tanlay oladi (server belgisi).
  final bool hasRepair;

  /// Ta'mirda belgilanadigan tayyor muammolar (serverdan, tartibi bilan).
  final List<SpecialtyRepairProblem> repairProblems;

  static const String texnikaGroup = 'texnika';

  final String group;

  bool get isTexnika => group == texnikaGroup;

  final int id;

  final String code;

  final String name;

  final String unit;

  bool get isPerMetre => unit.trim().toLowerCase() == 'metr';

  final SpecialtyCalculator calculator;

  final List<AreaTier> areaTiers;

  final List<SpecialtyVariant> variants;

  final bool variantPriceIsMaterial;

  final List<SpecialtyBrick> bricks;

  final bool calculatorFromServer;

  static const String romCode = 'rom';

  bool get isRom => code == romCode;

  String get workName {
    final match = RegExp(
      r'^(.*?)\s+usta(si|chi)?$',
      caseSensitive: false,
    ).firstMatch(name.trim());
    final trimmed = match?.group(1)?.trim();
    return (trimmed == null || trimmed.isEmpty) ? name : trimmed;
  }

  bool get hasCalculator => switch (calculator) {
        SpecialtyCalculator.none => false,
        SpecialtyCalculator.rom => true,
        SpecialtyCalculator.area => areaTiers.isNotEmpty,
        SpecialtyCalculator.variant => variants.isNotEmpty,
        SpecialtyCalculator.masonry => bricks.isNotEmpty,

        SpecialtyCalculator.roof => true,

        SpecialtyCalculator.beton => variants.isNotEmpty,

        SpecialtyCalculator.heating => true,
        SpecialtyCalculator.electrical => true,
      };

  factory SpecialtyEntity.fromJson(Map<String, dynamic> json) {
    final code = (json['code'] ?? '').toString();
    final fromServer = json.containsKey('calculator');
    return SpecialtyEntity(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      code: code,
      name: specialtyDisplayName((json['name'] ?? '').toString()),
      unit: (json['unit'] ?? '').toString(),
      calculator: fromServer
          ? SpecialtyCalculator.fromCode(json['calculator']?.toString())
          : SpecialtyCalculatorDefaults.kindOf(code),
      areaTiers: json.containsKey('area_tiers')
          ? AreaTier.listFrom(json['area_tiers'])
          : SpecialtyCalculatorDefaults.tiersOf(code),
      variants: json.containsKey('variants')
          ? SpecialtyVariant.listFrom(json['variants'])
          : SpecialtyCalculatorDefaults.variantsOf(code),
      variantPriceIsMaterial: json.containsKey('variant_price_is_material')
          ? json['variant_price_is_material'] == true
          : SpecialtyCalculatorDefaults.priceIsMaterial(code),
      bricks: SpecialtyBrick.listFrom(json['bricks']),
      calculatorFromServer: fromServer,
      group: (json['group'] ?? '').toString(),
      hasRepair: json['has_repair'] == true,
      repairProblems: SpecialtyRepairProblem.listFrom(json['repair_problems']),
    );
  }

  static List<SpecialtyEntity> listFrom(Object? data) {
    if (data is! List) return const [];
    return [
      for (final row in data)
        if (row is Map)
          SpecialtyEntity.fromJson(Map<String, dynamic>.from(row)),
    ];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'unit': unit,
        if (group.isNotEmpty) 'group': group,
        if (hasRepair) 'has_repair': true,
        if (repairProblems.isNotEmpty)
          'repair_problems': [for (final p in repairProblems) p.toJson()],
        if (calculatorFromServer) ...{
          'calculator': calculator.name == 'none' ? '' : calculator.name,
          'area_tiers': [for (final tier in areaTiers) tier.toJson()],
          'variants': [for (final v in variants) v.toJson()],
          'variant_price_is_material': variantPriceIsMaterial,
          'bricks': [for (final b in bricks) b.toJson()],
        },
      };

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        unit,
        calculator,
        areaTiers,
        variants,
        variantPriceIsMaterial,
        bricks,
        group,
        hasRepair,
        repairProblems,
      ];
}

class SpecialtyBrick extends Equatable {
  const SpecialtyBrick({
    required this.name,
    this.kind = 'pishgan',
    required this.price,
    this.lengthMm = 250,
    this.widthMm = 125,
    this.heightMm = 88,
    this.jointMm = 10,
    this.bricksPerM2Half,
    this.mortarPerBrick = 0,
    this.wastePct = 1.8,
  });

  final String name;

  final String kind;

  final int lengthMm;
  final int widthMm;
  final int heightMm;

  final int jointMm;

  final double? bricksPerM2Half;

  final double price;

  final double mortarPerBrick;

  final double wastePct;

  String get sizeLabel => '$lengthMm×$widthMm×$heightMm mm';

  static double _num(Object? value, double fallback) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? fallback;
  }

  static int _int(Object? value, int fallback) {
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? fallback;
  }

  factory SpecialtyBrick.fromJson(Map<String, dynamic> json) => SpecialtyBrick(
        name: (json['name'] ?? '').toString(),
        kind: (json['kind'] ?? 'pishgan').toString(),
        lengthMm: _int(json['length_mm'], 250),
        widthMm: _int(json['width_mm'], 125),
        heightMm: _int(json['height_mm'], 88),
        jointMm: _int(json['joint_mm'], 10),
        bricksPerM2Half: json['bricks_per_m2_half'] == null
            ? null
            : _num(json['bricks_per_m2_half'], 0),
        price: _num(json['price'], 0),
        mortarPerBrick: _num(json['mortar_per_brick'], 0),
        wastePct: _num(json['waste_pct'], 1.8),
      );

  static List<SpecialtyBrick> listFrom(Object? data) {
    if (data is! List) return const [];
    return [
      for (final row in data)
        if (row is Map) SpecialtyBrick.fromJson(Map<String, dynamic>.from(row)),
    ];
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'kind': kind,
        'length_mm': lengthMm,
        'width_mm': widthMm,
        'height_mm': heightMm,
        'joint_mm': jointMm,
        'bricks_per_m2_half': bricksPerM2Half,
        'price': price,
        'mortar_per_brick': mortarPerBrick,
        'waste_pct': wastePct,
      };

  @override
  List<Object?> get props => [
        name,
        kind,
        lengthMm,
        widthMm,
        heightMm,
        jointMm,
        bricksPerM2Half,
        price,
        mortarPerBrick,
        wastePct
      ];
}

class AreaTier extends Equatable {
  const AreaTier({required this.upToArea, required this.pricePerM2});

  final double? upToArea;

  final double pricePerM2;

  bool get isUnlimited => upToArea == null;

  static double? _num(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  factory AreaTier.fromJson(Map<String, dynamic> json) => AreaTier(
        upToArea: _num(json['up_to_area']),
        pricePerM2: _num(json['price']) ?? 0,
      );

  static List<AreaTier> listFrom(Object? data) {
    if (data is! List) return const [];
    return [
      for (final row in data)
        if (row is Map) AreaTier.fromJson(Map<String, dynamic>.from(row)),
    ];
  }

  Map<String, dynamic> toJson() =>
      {'up_to_area': upToArea, 'price': pricePerM2};

  @override
  List<Object?> get props => [upToArea, pricePerM2];
}

class SpecialtyVariant extends Equatable {
  const SpecialtyVariant({
    required this.name,
    required this.pricePerM2,
    this.size = '',
    this.note = '',
  });

  final String name;

  final String size;

  final String note;

  final double pricePerM2;

  static double _num(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }

  factory SpecialtyVariant.fromJson(Map<String, dynamic> json) =>
      SpecialtyVariant(
        name: (json['name'] ?? '').toString(),
        size: (json['size'] ?? '').toString(),
        note: (json['note'] ?? '').toString(),
        pricePerM2: _num(json['price']),
      );

  static List<SpecialtyVariant> listFrom(Object? data) {
    if (data is! List) return const [];
    return [
      for (final row in data)
        if (row is Map)
          SpecialtyVariant.fromJson(Map<String, dynamic>.from(row)),
    ];
  }

  Map<String, dynamic> toJson() =>
      {'name': name, 'size': size, 'note': note, 'price': pricePerM2};

  @override
  List<Object?> get props => [name, size, note, pricePerM2];
}

class MasterRateEntity extends Equatable {
  const MasterRateEntity({
    this.specialtyId,
    this.variantName,
    required this.code,
    required this.name,
    required this.unit,
    required this.price,
  });

  final int? specialtyId;
  final String? variantName;
  final String code;
  final String name;

  final String unit;

  final int price;

  factory MasterRateEntity.fromJson(Map<String, dynamic> json) =>
      MasterRateEntity(
        specialtyId: int.tryParse('${json['specialty']}'),
        variantName: json['variant_name']?.toString(),
        code: (json['code'] ?? '').toString(),
        name: specialtyDisplayName((json['specialty_name'] ?? json['name'] ?? '').toString()),
        unit: (json['unit'] ?? '').toString(),
        price: json['price'] is int
            ? json['price'] as int
            : int.tryParse('${json['price']}') ?? 0,
      );

  static List<MasterRateEntity> listFrom(Object? data) {
    if (data is! List) return const [];
    return [
      for (final row in data)
        if (row is Map)
          MasterRateEntity.fromJson(Map<String, dynamic>.from(row)),
    ];
  }

  @override
  List<Object?> get props => [specialtyId, code, unit, price, variantName];
}

class MasterNoteEntity extends Equatable {
  const MasterNoteEntity({
    required this.code,
    required this.name,
    required this.text,
  });

  final String code;
  final String name;
  final String text;

  factory MasterNoteEntity.fromJson(Map<String, dynamic> json) =>
      MasterNoteEntity(
        code: (json['code'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        text: (json['text'] ?? '').toString(),
      );

  static List<MasterNoteEntity> listFrom(Object? data) {
    if (data is! List) return const [];
    return [
      for (final row in data)
        if (row is Map)
          MasterNoteEntity.fromJson(Map<String, dynamic>.from(row)),
    ].where((n) => n.text.trim().isNotEmpty).toList();
  }

  @override
  List<Object?> get props => [code, text];
}

/// Ta'mirda mijoz belgilaydigan tayyor muammo ("Kran oqyapti").
class SpecialtyRepairProblem extends Equatable {
  const SpecialtyRepairProblem({required this.code, required this.title, this.hint = ''});

  final String code;
  final String title;
  final String hint;

  static List<SpecialtyRepairProblem> listFrom(Object? data) {
    if (data is! List) return const [];
    return [
      for (final row in data)
        if (row is Map && '${row['code'] ?? ''}'.isNotEmpty && '${row['title'] ?? ''}'.isNotEmpty)
          SpecialtyRepairProblem(
            code: '${row['code']}',
            title: '${row['title']}',
            hint: '${row['hint'] ?? ''}',
          ),
    ];
  }

  Map<String, dynamic> toJson() => {'code': code, 'title': title, if (hint.isNotEmpty) 'hint': hint};

  @override
  List<Object?> get props => [code, title, hint];
}
