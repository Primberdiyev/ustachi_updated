import 'dart:math' as math;

import 'package:ustachi/features/marketplace/domain/entities/specialty_entity.dart';

enum MasonryPurpose {
  building(
    'Bino quramiz',
    'Uy, hovli imorati, do\'kon yoki omborxona devorlari.',
  ),
  fence(
    'Devor quramiz',
    'Tekis devor — hovli yoki uchastka atrofidagi zabor.',
  );

  const MasonryPurpose(this.title, this.desc);

  final String title;
  final String desc;
}

enum MasonryMaterial {
  pishgan(
    'pishgan',
    'Pishgan g\'isht',
    'Pechda pishirilgan qizil g\'isht — mustahkam, namga chidamli.',
  ),
  xom(
    'xom',
    'Xom g\'isht',
    'Loydan quyilib quyoshda quritilgan g\'isht — arzon va issiq saqlaydi.',
  ),
  penoblok(
    'penoblok',
    'Penoblok',
    'Yengil va katta blok — tez teriladi, issiqlikni yaxshi saqlaydi.',
  ),

  shlakoblok(
    'shlakoblok',
    'Shlakoblok',
    'Arzon va katta blok — tez teriladi.',
  );

  const MasonryMaterial(this.code, this.title, this.desc);

  final String code;
  final String title;
  final String desc;

  bool get isBlock => this == penoblok || this == shlakoblok;

  bool allowedFor(MasonryPurpose purpose) =>
      this != shlakoblok || purpose == MasonryPurpose.fence;

  List<MasonryThickness> get thicknesses =>
      isBlock ? const [MasonryThickness.half] : MasonryThickness.values;

  static MasonryMaterial? fromCode(String code) {
    for (final m in values) {
      if (m.code == code) return m;
    }
    return null;
  }
}

enum MasonryThickness {
  half(1, 'Yarim g\'isht'),
  one(2, 'Bir g\'isht'),

  oneAndHalf(3, 'Bir yarim g\'isht');

  const MasonryThickness(this.halves, this.label);

  final int halves;
  final String label;

  int thicknessMm(SpecialtyBrick brick) => switch (this) {
        half => brick.widthMm,
        one => brick.lengthMm,
        oneAndHalf => brick.lengthMm + brick.jointMm + brick.widthMm,
      };
}

abstract final class MasonryFrame {

  static double housePerimeterM(double lengthM, double widthM) =>
      (lengthM <= 0 || widthM <= 0) ? 0 : 2 * (lengthM + widthM);

  static const columnStepM = 4.0;
  static const columnWidthM = 0.40;
  static const beamHeightM = 0.40;

  static const minColumns = 4;

  static int columns(double lengthM) => lengthM <= 0
      ? 0
      : math.max(minColumns, (lengthM / columnStepM - 1e-9).ceil());

  static int columnsForHouse(double lengthM, double widthM) {
    if (lengthM <= 0 || widthM <= 0) return 0;
    int spans(double side) => math.max(1, (side / columnStepM - 1e-9).ceil());
    return 2 * (spans(lengthM) + spans(widthM));
  }

  static double areaM2({
    required double lengthM,
    required double heightM,
    int? columnCount,
  }) {
    if (lengthM <= 0 || heightM <= 0) return 0;
    final beam = math.min(beamHeightM, heightM);
    final count = columnCount ?? columns(lengthM);
    final columnArea = count * columnWidthM * (heightM - beam);
    return columnArea + lengthM * beam;
  }
}

enum MasonryRoom {
  yotoqxona('Yotoqxona', 4.0, 4.0),
  bolalar('Bolalar xonasi', 3.5, 4.0),
  mehmonxona('Mehmonxona (zal)', 5.0, 4.5),
  oshxona('Oshxona', 3.5, 4.0),
  sanuzel('Sanuzel (hammom, hojatxona)', 2.0, 2.5, partition: true),
  koridor('Koridor', 1.5, 6.0);

  const MasonryRoom(this.title, this.defaultWidthM, this.defaultLengthM,
      {this.partition = false});

  final String title;
  final double defaultWidthM;
  final double defaultLengthM;
  final bool partition;
}

class MasonryRoomSpec {
  const MasonryRoomSpec({
    required this.room,
    required this.count,
    required this.widthM,
    required this.lengthM,
  });

  MasonryRoomSpec.standard(this.room, this.count)
      : widthM = room.defaultWidthM,
        lengthM = room.defaultLengthM;

  final MasonryRoom room;
  final int count;
  final double widthM;
  final double lengthM;

  double get perimeterM => 2 * (widthM + lengthM);

  double get areaM2 => widthM * lengthM;

  MasonryRoomSpec copyWith({int? count, double? widthM, double? lengthM}) =>
      MasonryRoomSpec(
        room: room,
        count: count ?? this.count,
        widthM: widthM ?? this.widthM,
        lengthM: lengthM ?? this.lengthM,
      );
}

abstract final class MasonryRooms {
  static int count(List<MasonryRoomSpec> rooms) =>
      rooms.fold(0, (sum, r) => sum + math.max(0, r.count));

  static double areaM2(List<MasonryRoomSpec> rooms) =>
      rooms.fold(0, (sum, r) => sum + math.max(0, r.count) * r.areaM2);

  static const usableShare = 0.85;
  static const looseShare = 0.6;

  static MasonryFit fit({
    required double floorAreaM2,
    required List<MasonryRoomSpec> rooms,
  }) {

    if (count(rooms) <= 1) return MasonryFit.unknown;
    final area = areaM2(rooms);
    if (floorAreaM2 <= 0 || area <= 0) return MasonryFit.unknown;
    if (area > floorAreaM2 * usableShare) return MasonryFit.tooMany;
    if (area < floorAreaM2 * looseShare) return MasonryFit.tooFew;
    return MasonryFit.ok;
  }

  static ({double bearingM, double partitionM}) interiorWalls({
    required double lengthM,
    required double widthM,
    required List<MasonryRoomSpec> rooms,
  }) {
    const none = (bearingM: 0.0, partitionM: 0.0);
    if (lengthM <= 0 || widthM <= 0 || count(rooms) <= 1) return none;

    var perimeters = 0.0;
    var partitionPerimeters = 0.0;
    for (final spec in rooms) {
      if (spec.count <= 0 || spec.perimeterM <= 0) continue;
      final p = spec.count * spec.perimeterM;
      perimeters += p;
      if (spec.room.partition) partitionPerimeters += p;
    }

    final share = math.min(1.0, areaM2(rooms) / (lengthM * widthM));
    final total = math.max(
        0.0,
        (perimeters - MasonryFrame.housePerimeterM(lengthM, widthM) * share) /
            2);
    final partition = math.min(total, partitionPerimeters / 2);
    return (bearingM: total - partition, partitionM: partition);
  }
}

enum MasonryFit {

  unknown,

  tooMany,

  tooFew,

  ok;
}

class MasonryOpening {
  const MasonryOpening({
    required this.count,
    required this.widthM,
    required this.heightM,
  });

  const MasonryOpening.door()
      : count = 0,
        widthM = 0.9,
        heightM = 2.1;
  const MasonryOpening.window()
      : count = 0,
        widthM = 1.5,
        heightM = 1.5;
  const MasonryOpening.innerDoor()
      : count = 0,
        widthM = 0.8,
        heightM = 2.0;

  final int count;
  final double widthM;
  final double heightM;

  double get areaM2 => math.max(0, count) * widthM * heightM;

  MasonryOpening copyWith({int? count, double? widthM, double? heightM}) =>
      MasonryOpening(
        count: count ?? this.count,
        widthM: widthM ?? this.widthM,
        heightM: heightM ?? this.heightM,
      );
}

class MasonryPart {
  const MasonryPart({
    required this.kind,
    required this.lengthM,
    required this.areaM2,
    required this.thickness,
    required this.bricks,
  });

  final MasonryPartKind kind;

  final double lengthM;

  final double areaM2;
  final MasonryThickness thickness;

  final double bricks;
}

enum MasonryPartKind {
  exterior('Tashqi devor'),
  interior('Ichki devorlar'),
  partition('Sanuzel devorlari');

  const MasonryPartKind(this.title);
  final String title;
}

class MasonryEstimate {
  const MasonryEstimate({
    required this.wallAreaM2,
    required this.openingsM2,
    this.frameM2 = 0,
    required this.netAreaM2,
    required this.bricksPerM2,
    required this.laidBricks,
    required this.totalBricks,
    required this.brickCost,
    required this.mortarCost,
    this.parts = const [],
  });

  final double wallAreaM2;

  final double openingsM2;

  final double frameM2;

  final double netAreaM2;

  final double bricksPerM2;

  final int laidBricks;

  final int totalBricks;

  final int brickCost;

  final int mortarCost;

  final List<MasonryPart> parts;

  int get total => brickCost + mortarCost;
}

abstract final class MasonryCalculator {
  static double bricksPerM2(SpecialtyBrick brick, MasonryThickness thickness) {
    final practice = brick.bricksPerM2Half;
    if (practice != null && practice > 0) return thickness.halves * practice;
    final faceM2 = (brick.lengthMm + brick.jointMm) /
        1000 *
        ((brick.heightMm + brick.jointMm) / 1000);
    if (faceM2 <= 0) return 0;
    return thickness.halves / faceM2;
  }

  static MasonryEstimate? calculate({
    required SpecialtyBrick brick,
    required MasonryThickness thickness,
    required double lengthM,
    required double heightM,
    double openingsM2 = 0,
    bool frame = false,
    int? frameColumns,
  }) {
    if (lengthM <= 0 || heightM <= 0) return null;
    final wall = lengthM * heightM;
    final openings = openingsM2.clamp(0, wall).toDouble();
    final frameArea = frame
        ? MasonryFrame.areaM2(
                lengthM: lengthM, heightM: heightM, columnCount: frameColumns)
            .clamp(0, wall - openings)
            .toDouble()
        : 0.0;
    final net = wall - openings - frameArea;
    if (net <= 0) return null;

    final perM2 = bricksPerM2(brick, thickness);
    return _finish(
      brick: brick,
      wall: wall,
      openings: openings,
      frameArea: frameArea,
      net: net,
      perM2: perM2,
      rawLaid: net * perM2,
    );
  }

  static MasonryEstimate? calculateBuilding({
    required SpecialtyBrick brick,
    required MasonryThickness thickness,
    required double lengthM,
    required double widthM,
    required double floorHeightM,
    required List<List<MasonryRoomSpec>> floors,
    double openingsM2 = 0,
    double innerOpeningsM2 = 0,
    bool frame = false,
  }) {
    if (lengthM <= 0 || widthM <= 0 || floorHeightM <= 0 || floors.isEmpty) {
      return null;
    }
    final perimeter = MasonryFrame.housePerimeterM(lengthM, widthM);
    final wall = perimeter * floorHeightM * floors.length;
    final openings = openingsM2.clamp(0, wall).toDouble();
    final frameArea = frame
        ? (MasonryFrame.areaM2(
                  lengthM: perimeter,
                  heightM: floorHeightM,
                  columnCount: MasonryFrame.columnsForHouse(lengthM, widthM),
                ) *
                floors.length)
            .clamp(0, wall - openings)
            .toDouble()
        : 0.0;
    final exteriorNet = wall - openings - frameArea;
    if (exteriorNet <= 0) return null;

    var bearingM = 0.0;
    var partitionM = 0.0;
    for (final rooms in floors) {
      final walls = MasonryRooms.interiorWalls(
          lengthM: lengthM, widthM: widthM, rooms: rooms);
      bearingM += walls.bearingM;
      partitionM += walls.partitionM;
    }

    final interiorThickness = thickness.halves < MasonryThickness.one.halves
        ? thickness
        : MasonryThickness.one;

    final interiorGross = bearingM * floorHeightM;
    final partitionGross = partitionM * floorHeightM;
    final innerCut =
        innerOpeningsM2.clamp(0, interiorGross + partitionGross).toDouble();
    final interiorNet = math.max(0.0, interiorGross - innerCut);
    final partitionNet =
        math.max(0.0, partitionGross - math.max(0.0, innerCut - interiorGross));
    final parts = <MasonryPart>[
      MasonryPart(
        kind: MasonryPartKind.exterior,
        lengthM: perimeter * floors.length,
        areaM2: exteriorNet,
        thickness: thickness,
        bricks: exteriorNet * bricksPerM2(brick, thickness),
      ),
      if (interiorNet > 0)
        MasonryPart(
          kind: MasonryPartKind.interior,
          lengthM: bearingM,
          areaM2: interiorNet,
          thickness: interiorThickness,
          bricks: interiorNet * bricksPerM2(brick, interiorThickness),
        ),
      if (partitionNet > 0)
        MasonryPart(
          kind: MasonryPartKind.partition,
          lengthM: partitionM,
          areaM2: partitionNet,
          thickness: MasonryThickness.half,
          bricks: partitionNet * bricksPerM2(brick, MasonryThickness.half),
        ),
    ];

    return _finish(
      brick: brick,
      wall: wall,
      openings: openings,
      frameArea: frameArea,
      net: parts.fold(0.0, (sum, p) => sum + p.areaM2),
      perM2: bricksPerM2(brick, thickness),
      rawLaid: parts.fold(0.0, (sum, p) => sum + p.bricks),
      parts: parts,
    );
  }

  static MasonryEstimate _finish({
    required SpecialtyBrick brick,
    required double wall,
    required double openings,
    required double frameArea,
    required double net,
    required double perM2,
    required double rawLaid,
    List<MasonryPart> parts = const [],
  }) {

    final laid = (rawLaid - 1e-9).ceil();
    final total = (laid * (1 + brick.wastePct / 100) - 1e-9).ceil();
    return MasonryEstimate(
      wallAreaM2: wall,
      openingsM2: openings,
      frameM2: frameArea,
      netAreaM2: net,
      bricksPerM2: perM2,
      laidBricks: laid,
      totalBricks: total,
      brickCost: (total * brick.price).round(),
      mortarCost: (laid * brick.mortarPerBrick).round(),
      parts: parts,
    );
  }
}
