
library;

import 'dart:math' as math;

import 'package:ustachi/features/calculate_prices/domain/services/radiator_catalog.dart';

enum HeatingJob {

  system(
    'Yangi isitish tizimi',
    'Radiator, truba va kotyol — butun uyni isitish.',
  ),

  warmFloorOnly(
    'Faqat issiq pol',
    'Radiator kerak emas — qaysi xonaga issiq pol qilamiz.',
  );

  const HeatingJob(this.title, this.desc);

  final String title;
  final String desc;

  bool get isWarmFloorOnly => this == HeatingJob.warmFloorOnly;
}

enum HeatingSystem {
  twoPipe(
    'Ikki trubali',
    'Borish va qaytish alohida — hamma radiator bir xil issiq.',

    pipePerRadiatorM: 12,

    pipeLines: 2,
    needsPump: true,
    needsCollector: false,
    farRadiatorExtraPct: 0,
  ),
  onePipe(
    'Bir trubali',
    'Bitta halqa (Leningradka) — truba kam ketadi, arzonroq.',

    pipePerRadiatorM: 6,

    pipeLines: 1,
    needsPump: true,
    needsCollector: false,

    farRadiatorExtraPct: 10,
  ),
  gravity(
    'Samotyok',
    'Suv o\'zi aylanadi — svet o\'chsa ham ishlaydi, nasos kerak emas.',

    pipePerRadiatorM: 12,
    extraPipe25M: 3,

    pipeLines: 2,
    needsPump: false,
    needsCollector: false,
    farRadiatorExtraPct: 0,
  ),
  radial(
    'Luchevoy',
    'Har radiatorga kollektordan alohida truba — pol ostidan tortiladi.',

    pipePerRadiatorM: 10,

    pipeLines: 0,
    needsPump: true,
    needsCollector: true,
    farRadiatorExtraPct: 0,
  );

  const HeatingSystem(
    this.title,
    this.desc, {
    required this.pipePerRadiatorM,
    required this.pipeLines,
    required this.needsPump,
    required this.needsCollector,
    required this.farRadiatorExtraPct,
    this.extraPipe25M = 0,
  });

  final String title;
  final String desc;

  final double pipePerRadiatorM;

  final double extraPipe25M;

  final int pipeLines;

  final bool needsPump;

  final bool needsCollector;

  String get pipeVariantName =>
      needsCollector ? 'Truba luchevoy (1 metr)' : 'Truba (1 metr)';

  String get valveVariantName =>
      needsCollector ? 'Radiator vintli (luchevoy)' : 'Radiator vintli';

  final int farRadiatorExtraPct;
}

enum RadiatorKind {

  panel(
    'Panel radiator',
    'Tekis panel — AKFA jadvalidagi o\'lchamlar bo\'yicha, butun dona.',
  ),

  sectional(
    'Qovurg\'ali (seksiyali)',
    'Seksiya bilan sotiladi — nechta kerak bo\'lsa shuncha ulanadi.',
  );

  const RadiatorKind(this.title, this.desc);

  final String title;
  final String desc;

  bool get isSectional => this == RadiatorKind.sectional;
}

enum HeatingWall {
  solid('Pishgan g\'isht yoki beton', 'Radiator devorga ilinadi.',
      needsLegs: false),
  xomGisht('Xom g\'isht', 'Devor yumshoq — radiatorga oyoqcha kerak.',
      needsLegs: true),
  penoblok('Penoblok', 'Devor yengil — radiatorga oyoqcha kerak.',
      needsLegs: true),
  shlakoblok('Shlakoblok', 'Devor yengil — radiatorga oyoqcha kerak.',
      needsLegs: true);

  const HeatingWall(this.title, this.desc, {required this.needsLegs});

  final String title;
  final String desc;

  final bool needsLegs;
}

enum HeatingBoiler {
  gas('Gaz kotyol', 'Gaz bor bo\'lsa eng arzon isitish.'),
  electric('Elektr kotyol', 'Gaz yo\'q joyda — o\'rnatish oson.'),
  solid('Qattiq yoqilg\'i', 'Ko\'mir yoki o\'tin bilan ishlaydi.');

  const HeatingBoiler(this.title, this.desc);

  final String title;
  final String desc;

  String get variantName => title;
}

enum WarmFloorUnderlay {
  barrier('Gidrobaryer', 'Sifatli tushama — suv o\'tkazmaydi.');

  const WarmFloorUnderlay(this.title, this.desc);

  final String title;
  final String desc;

  String get variantName => 'Issiq pol: $title (1 m²)';
}

enum WarmFloorPipeKind {
  plastic('Plastik shlang', 'Arzonroq.'),
  aluminium('Alumin shlang', 'Baquvvatroq — uzoqqa chidaydi.');

  const WarmFloorPipeKind(this.title, this.desc);

  final String title;
  final String desc;

  String get variantName => 'Issiq pol: $title (1 metr)';
}

class HeatingRoom {
  const HeatingRoom({
    required this.lengthM,
    required this.widthM,
    this.warmFloor = false,
    this.radiator = true,
  });

  final double lengthM;
  final double widthM;

  final bool warmFloor;

  final bool radiator;

  bool get hasRadiator => !warmFloor || radiator;

  double get areaM2 => lengthM <= 0 || widthM <= 0 ? 0 : lengthM * widthM;

  HeatingRoom copyWith({
    double? lengthM,
    double? widthM,
    bool? warmFloor,
    bool? radiator,
  }) =>
      HeatingRoom(
        lengthM: lengthM ?? this.lengthM,
        widthM: widthM ?? this.widthM,
        warmFloor: warmFloor ?? this.warmFloor,
        radiator: radiator ?? this.radiator,
      );
}

class HeatingRoomResult {
  const HeatingRoomResult({
    required this.room,
    required this.watts,
    required this.radiators,
    required this.sections,
    required this.warmFloorM2,
  });

  final HeatingRoom room;

  final int watts;

  final int sections;

  final int radiators;

  final double warmFloorM2;
}

class HeatingEstimate {
  const HeatingEstimate({
    required this.job,
    required this.system,
    required this.radiatorKind,
    required this.sections,
    required this.rooms,
    required this.totalAreaM2,
    required this.watts,
    required this.radiators,
    required this.warmFloorM2,
    required this.pipeM,
    required this.pipePerRadiatorM,
    required this.transitPipeM,
    required this.collectorPipeM,
    required this.pipe25M,
    required this.pipe25Cost,
    required this.boilerKw,
    required this.radiatorCost,
    required this.mountCost,
    required this.pipeCost,
    required this.underlay,
    required this.warmFloorPipeKind,
    required this.warmFloorPipeM,
    required this.warmFloorDowels,
    required this.warmFloorClips,
    required this.penopleksSheets,
    required this.penopleksCost,
    required this.warmFloorPipeCost,
    required this.underlayCost,
    required this.dowelCost,
    required this.clipCost,
    required this.collectorCost,
    required this.collectors,
    required this.amerikanka,
    required this.amerikankaCost,
    required this.collectorBoxCost,
    required this.branchPipeM,
    required this.tees,
    required this.valves,
    required this.branchPipeCost,
    required this.teeCost,
    required this.valveCost,
    required this.legs,
    required this.legCost,
    required this.insulationM,
    required this.insulationCost,
  });

  final HeatingJob job;

  final HeatingSystem system;

  final RadiatorKind radiatorKind;

  final int sections;

  final List<HeatingRoomResult> rooms;
  final double totalAreaM2;

  final int watts;

  final int radiators;

  final double warmFloorM2;

  final double pipeM;

  final double pipePerRadiatorM;

  final double transitPipeM;

  final double collectorPipeM;

  final double pipe25M;

  final int pipe25Cost;

  final double boilerKw;

  final int radiatorCost;

  final int mountCost;

  final int pipeCost;

  final WarmFloorUnderlay underlay;

  final WarmFloorPipeKind warmFloorPipeKind;

  final double warmFloorPipeM;

  final int warmFloorDowels;

  final int warmFloorClips;

  final int penopleksSheets;

  final int penopleksCost;
  final int warmFloorPipeCost;
  final int underlayCost;
  final int dowelCost;
  final int clipCost;

  int get warmFloorCost =>
      penopleksCost +
      warmFloorPipeCost +
      underlayCost +
      dowelCost +
      clipCost;

  int get boilerCost => 0;

  int get pumpCost => 0;

  final int collectorCost;

  final int collectors;

  final int amerikanka;
  final int amerikankaCost;

  final int collectorBoxCost;

  final double branchPipeM;

  final int tees;

  final int valves;

  final int branchPipeCost;
  final int teeCost;
  final int valveCost;

  final int legs;
  final int legCost;

  final double insulationM;
  final int insulationCost;

  int get total =>
      radiatorCost +
      mountCost +
      pipeCost +
      pipe25Cost +
      warmFloorCost +
      boilerCost +
      pumpCost +
      collectorCost +
      branchPipeCost +
      teeCost +
      valveCost +
      legCost +
      insulationCost +
      amerikankaCost +
      collectorBoxCost;

  int get points =>
      radiators +
      rooms.where((r) => r.warmFloorM2 > 0 && r.radiators == 0).length;
}

abstract final class HeatingCalculator {

  static const wattsPerM2 = 85;

  static int get radiatorWatts => RadiatorCatalog.anchor.watts;

  static const branchPipePerRadiatorM = 2.0;

  static const teesPerRadiator = 2;

  static const valvesPerRadiator = 2;

  static const legsPerRadiator = 2;

  static const warmFloorPipePerM2 = 8.0;

  static const warmFloorDowelsPerM2 = 4;

  static const penopleksSheetM2 = 0.75;

  static int penopleksSheetsFor(double areaM2) =>
      areaM2 <= 0 ? 0 : (areaM2 / penopleksSheetM2).ceil();

  static const warmFloorClipsPerM2 = 20;

  static const warmFloorHeightM = 1.20;

  static const metersPerCollector = 20.0;

  static const collectorReachM = 15.0;

  static const collectorMinOutlets = 2;
  static const collectorMaxOutlets = 10;

  static int collectorsFor(double buildingLengthM, {int radiators = 0}) {
    final byLength = buildingLengthM <= 0
        ? 1
        : (buildingLengthM / metersPerCollector).ceil();
    final byOutlets =
        radiators <= 0 ? 1 : (radiators / collectorMaxOutlets).ceil();
    return math.max(1, math.max(byLength, byOutlets));
  }

  static int outletsPerCollector(int radiators, int collectors) {
    if (radiators <= 0 || collectors <= 0) return 0;
    return math.max(
      collectorMinOutlets,
      (radiators / collectors).ceil(),
    );
  }

  static const amerikankaPerCollector = 2;

  static String collectorVariantName(int outlets) =>
      'Kollektor ($outlets chiqish)';

  static const radialPipeMinM = 10.0;
  static const radialPipeMaxM = 32.0;

  static double radialPipePerRadiator({
    required double buildingLengthM,
    required double totalAreaM2,
    required int collectors,
  }) {
    if (buildingLengthM <= 0 || collectors <= 0) return radialPipeMinM;
    final zoneM = buildingLengthM / collectors;
    final buildingWidthM = totalAreaM2 / buildingLengthM;
    final distanceM = zoneM / 4 + buildingWidthM / 2;
    return (2 * distanceM).clamp(radialPipeMinM, radialPipeMaxM);
  }

  static const sectionWatts = 150;

  static int sectionsFor(double areaM2, {int extraPct = 0}) {
    if (areaM2 <= 0) return 0;
    return math.max(
        1, (wattsFor(areaM2, extraPct: extraPct) / sectionWatts).ceil());
  }

  static int wattsFor(double areaM2, {int extraPct = 0}) => areaM2 <= 0
      ? 0
      : (areaM2 * wattsPerM2 * (100 + extraPct) / 100).round();

  static int radiatorsFor(double areaM2) {
    if (areaM2 <= 0) return 0;
    return math.max(1, (wattsFor(areaM2) / radiatorWatts).ceil());
  }

  static double boilerKwFor(double totalAreaM2, {int extraPct = 0}) {
    if (totalAreaM2 <= 0) return 0;
    return boilerKwForWatts(wattsFor(totalAreaM2, extraPct: extraPct));
  }

  static double boilerKwForWatts(int watts) {
    if (watts <= 0) return 0;
    return (watts / 1000 * 2).ceil() / 2;
  }

  static HeatingEstimate? calculate({
    HeatingJob job = HeatingJob.system,
    HeatingSystem system = HeatingSystem.twoPipe,
    RadiatorKind radiatorKind = RadiatorKind.panel,
    double sectionPrice = 0,
    required List<HeatingRoom> rooms,

    required double pipePricePerM,

    double pipe32PricePerM = 0,
    WarmFloorUnderlay underlay = WarmFloorUnderlay.barrier,
    WarmFloorPipeKind warmFloorPipeKind = WarmFloorPipeKind.plastic,

    double penopleksSheetPrice = 0,
    double warmFloorPipePricePerM = 0,
    double underlayPricePerM2 = 0,
    double dowelPrice = 0,
    double clipPrice = 0,

    double Function(int outlets)? collectorPriceFor,
    double amerikankaPrice = 0,
    double collectorBoxPrice = 0,
    double branchPipePricePerM = 0,
    double teePrice = 0,
    double valvePrice = 0,
    double radiatorPrice = 0,
    double mountPrice = 0,
    double pipe25PricePerM = 0,
    double buildingLengthM = 0,
    double boilerDistanceM = 0,
    HeatingWall wall = HeatingWall.solid,
    double legPrice = 0,
    double insulationPricePerM = 0,
  }) {
    final usable = [for (final r in rooms) if (r.areaM2 > 0) r];
    if (usable.isEmpty) return null;

    final onlyFloor = job.isWarmFloorOnly;

    final extraPct = onlyFloor ? 0 : system.farRadiatorExtraPct;

    final results = [
      for (final room in usable)
        HeatingRoomResult(
          room: room,
          watts: wattsFor(room.areaM2, extraPct: extraPct),

          radiators:
              (onlyFloor || !room.hasRadiator) ? 0 : radiatorsFor(room.areaM2),

          sections: (onlyFloor || !room.hasRadiator ||
                  !radiatorKind.isSectional)
              ? 0
              : sectionsFor(room.areaM2, extraPct: extraPct),

          warmFloorM2: (onlyFloor || room.warmFloor) ? room.areaM2 : 0,
        ),
    ];

    final totalArea = results.fold<double>(0, (s, r) => s + r.room.areaM2);
    final watts = results.fold<int>(0, (s, r) => s + r.watts);
    final radiators = results.fold<int>(0, (s, r) => s + r.radiators);
    final sections = results.fold<int>(0, (s, r) => s + r.sections);
    final warmFloor = results.fold<double>(0, (s, r) => s + r.warmFloorM2);

    final transit = (onlyFloor || radiators == 0)
        ? 0.0
        : results
                .where((r) => r.radiators == 0)
                .fold<double>(0, (s, r) => s + r.room.lengthM) *
            system.pipeLines;

    final collectors = (onlyFloor || !system.needsCollector || radiators == 0)
        ? 0
        : collectorsFor(buildingLengthM, radiators: radiators);

    final collectorPipe = collectors == 0
        ? 0.0
        : 2 *
            (collectors * boilerDistanceM + buildingLengthM * collectors / 2);

    final perRadiator = system.needsCollector
        ? radialPipePerRadiator(
            buildingLengthM: buildingLengthM,
            totalAreaM2: totalArea,
            collectors: collectors,
          )
        : system.pipePerRadiatorM;

    final pipe = onlyFloor
        ? 0.0
        : radiators * perRadiator + transit + collectorPipe;

    final pipe25 = onlyFloor ? 0.0 : radiators * system.extraPipe25M;

    final branchPipe = onlyFloor ? 0.0 : radiators * branchPipePerRadiatorM;

    final tees = (onlyFloor || system.needsCollector)
        ? 0
        : radiators * teesPerRadiator;
    final valves = onlyFloor ? 0 : radiators * valvesPerRadiator;

    final warmFloorPipe = warmFloor * warmFloorPipePerM2;
    final dowels = (warmFloor * warmFloorDowelsPerM2).ceil();
    final clips = (warmFloor * warmFloorClipsPerM2).ceil();

    final penopleksSheets = penopleksSheetsFor(warmFloor);

    final insulation32 = system.needsCollector
        ? collectorPipe
        : pipe + pipe25 + branchPipe;

    final legs =
        (onlyFloor || !wall.needsLegs) ? 0 : radiators * legsPerRadiator;

    return HeatingEstimate(
      job: job,
      system: system,
      radiatorKind: radiatorKind,
      sections: sections,
      rooms: results,
      totalAreaM2: totalArea,
      watts: watts,
      radiators: radiators,
      warmFloorM2: warmFloor,
      pipeM: pipe,
      pipePerRadiatorM: onlyFloor ? 0 : perRadiator,
      transitPipeM: transit,
      pipe25M: pipe25,
      pipe25Cost: (pipe25 * pipe25PricePerM).round(),

      boilerKw: onlyFloor ? 0 : boilerKwForWatts(watts),

      radiatorCost: radiatorKind.isSectional
          ? (sections * sectionPrice).round()
          : (radiators * radiatorPrice).round(),
      mountCost: (radiators * mountPrice).round(),

      pipeCost: system.needsCollector
          ? ((pipe - collectorPipe) * pipePricePerM +
                  collectorPipe * pipe32PricePerM)
              .round()
          : (pipe * pipePricePerM).round(),

      underlay: underlay,
      warmFloorPipeKind: warmFloorPipeKind,
      warmFloorPipeM: warmFloorPipe,
      warmFloorDowels: dowels,
      warmFloorClips: clips,
      penopleksSheets: penopleksSheets,
      penopleksCost: (penopleksSheets * penopleksSheetPrice).round(),
      warmFloorPipeCost: (warmFloorPipe * warmFloorPipePricePerM).round(),
      underlayCost: (warmFloor * underlayPricePerM2).round(),
      dowelCost: (dowels * dowelPrice).round(),
      clipCost: (clips * clipPrice).round(),

      collectorCost: collectors == 0 || collectorPriceFor == null
          ? 0
          : (collectors *
                  collectorPriceFor(
                      outletsPerCollector(radiators, collectors)))
              .round(),

      collectors: collectors,
      collectorPipeM: collectorPipe,

      amerikanka: collectors * amerikankaPerCollector,
      amerikankaCost:
          (collectors * amerikankaPerCollector * amerikankaPrice).round(),
      collectorBoxCost: (collectors * collectorBoxPrice).round(),
      branchPipeM: branchPipe,
      tees: tees,
      valves: valves,
      branchPipeCost: (branchPipe * branchPipePricePerM).round(),
      teeCost: (tees * teePrice).round(),
      valveCost: (valves * valvePrice).round(),
      legs: legs,
      legCost: (legs * legPrice).round(),
      insulationM: insulation32,
      insulationCost: (insulation32 * insulationPricePerM).round(),
    );
  }
}
