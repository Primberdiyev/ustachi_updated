
import 'package:flutter_test/flutter_test.dart';
import 'package:ustachi/features/calculate_prices/domain/services/heating_calculator.dart';

HeatingEstimate estimate(
  List<HeatingRoom> rooms, {
  HeatingJob job = HeatingJob.system,
  HeatingSystem system = HeatingSystem.twoPipe,
  RadiatorKind kind = RadiatorKind.panel,
  double section = 115000,
  double pipe = 28000,

  double pipe32 = 28000,

  double warmFloor = 150000,
  WarmFloorUnderlay underlay = WarmFloorUnderlay.barrier,
  WarmFloorPipeKind warmFloorPipeKind = WarmFloorPipeKind.plastic,
  double amerikanka = 52000,
  double collectorBox = 0,
  double penopleks = 0,
  double warmFloorPipe = 0,
  double dowel = 0,
  double clip = 0,

  double Function(int outlets)? collectorPriceFor,
  double branchPipe = 12500,
  double tee = 5000,
  double valve = 40000,
  double radiator = 1046000,
  double mount = 30000,
  double pipe25 = 19000,
  double building = 0,
  double boilerDistance = 0,
  HeatingWall wall = HeatingWall.solid,
  double leg = 100000,
  double insulation = 0,
}) =>
    HeatingCalculator.calculate(
      job: job,
      system: system,
      radiatorKind: kind,
      sectionPrice: section,
      rooms: rooms,
      pipePricePerM: pipe,
      underlay: underlay,
      warmFloorPipeKind: warmFloorPipeKind,
      amerikankaPrice: amerikanka,
      collectorBoxPrice: collectorBox,

      penopleksSheetPrice: penopleks,
      pipe32PricePerM: pipe32,
      warmFloorPipePricePerM: warmFloorPipe,
      underlayPricePerM2: warmFloor,
      dowelPrice: dowel,
      clipPrice: clip,
      collectorPriceFor:
          collectorPriceFor ?? (outlets) => outlets * 100000.0,
      branchPipePricePerM: branchPipe,
      teePrice: tee,
      valvePrice: valve,
      radiatorPrice: radiator,
      mountPrice: mount,
      pipe25PricePerM: pipe25,
      buildingLengthM: building,
      boilerDistanceM: boilerDistance,
      wall: wall,
      legPrice: leg,
      insulationPricePerM: insulation,
    )!;

void main() {

  test('24 m² xonaga ~2040 Vt kerak (mutaxassis: 2000–2500)', () {

    expect(HeatingCalculator.wattsFor(24), 2040);
    expect(HeatingCalculator.wattsPerM2, 85);
  });

  test('bitta AKFA 50×140 radiator 2100 Vt beradi (14 × 150)', () {
    expect(HeatingCalculator.radiatorWatts, 2100);
  });

  test('radiator soni: talab ÷ 2100', () {

    expect(HeatingCalculator.radiatorsFor(24), 1);
    expect(HeatingCalculator.radiatorsFor(9), 1);

    expect(HeatingCalculator.radiatorsFor(30), 2);
    expect(HeatingCalculator.radiatorsFor(60), 3);
  });

  test('har radiator bitta NUQTA (usta qarori)', () {
    final e = estimate(const [
      HeatingRoom(lengthM: 6, widthM: 4),
      HeatingRoom(lengthM: 3, widthM: 3),
    ]);

    expect(e.radiators, 2);
    expect(e.points, e.radiators);
  });

  test('RADIATOR butun dona bilan: 1 046 000 + 30 000', () {
    final e = estimate(const [HeatingRoom(lengthM: 3, widthM: 3)]);

    expect(e.radiators, 1);
    expect(e.radiatorCost, 1046000);
    expect(e.mountCost, 30000);
  });

  test('RADIATOR ULANISHI: 2 m truba + 2 troynik + 2 vintl = 115 000', () {
    final e = estimate(
      const [HeatingRoom(lengthM: 6, widthM: 4)],
      system: HeatingSystem.onePipe,
    );

    expect(e.branchPipeM, 2);
    expect(e.tees, 2);
    expect(e.valves, 2);
    expect(e.branchPipeCost + e.teeCost + e.valveCost, 115000);
  });

  test('BIR TRUBALI, 6 × 4 xona: 6 metr truba × 28 000', () {
    final e = estimate(
      const [HeatingRoom(lengthM: 6, widthM: 4)],
      system: HeatingSystem.onePipe,
    );

    expect(e.pipeM, closeTo(6, 1e-9));
    expect(e.pipeCost, 6 * 28000);
  });

  test('IKKI TRUBALI = bir trubali + 6 metr (mutaxassis 2026-09-22)', () {
    const rooms = [HeatingRoom(lengthM: 6, widthM: 4)];

    final onePipe = estimate(rooms, system: HeatingSystem.onePipe);
    final twoPipe = estimate(rooms, system: HeatingSystem.twoPipe);

    expect(twoPipe.pipeM, closeTo(onePipe.pipeM + 6, 1e-9));
    expect(twoPipe.pipeM, 12);
  });

  test('BIR TRUBALIDA issiqlik talabiga +10% (usta tasdiqladi)', () {

    expect(HeatingSystem.onePipe.farRadiatorExtraPct, 10);
    expect(HeatingSystem.twoPipe.farRadiatorExtraPct, 0);
    expect(HeatingSystem.gravity.farRadiatorExtraPct, 0);
    expect(HeatingSystem.radial.farRadiatorExtraPct, 0);

    expect(HeatingCalculator.wattsFor(24), 2040);
    expect(HeatingCalculator.wattsFor(24, extraPct: 10), 2244);

    const rooms = [HeatingRoom(lengthM: 6, widthM: 4)];
    final twoPipe = estimate(rooms);
    final onePipe = estimate(rooms, system: HeatingSystem.onePipe);

    expect(twoPipe.watts, 2040);
    expect(onePipe.watts, 2244);

    expect(twoPipe.radiators, 1);
    expect(onePipe.radiators, 1);
  });

  test('BIR TRUBALIDA seksiya ham +10% dan hisoblanadi', () {
    const rooms = [HeatingRoom(lengthM: 6, widthM: 4)];
    final twoPipe = estimate(rooms, kind: RadiatorKind.sectional);
    final onePipe = estimate(
      rooms,
      kind: RadiatorKind.sectional,
      system: HeatingSystem.onePipe,
    );

    expect(twoPipe.sections, 14);
    expect(onePipe.sections, 15);
  });

  test('KOTYOL QUVVATI ekrandagi issiqlik bilan bir xil', () {
    const rooms = [
      HeatingRoom(lengthM: 6, widthM: 4), 
      HeatingRoom(lengthM: 4, widthM: 4), 
    ];

    final twoPipe = estimate(rooms);
    expect(twoPipe.watts, 3400);
    expect(twoPipe.boilerKw, 3.5);

    final onePipe = estimate(rooms, system: HeatingSystem.onePipe);
    expect(onePipe.watts, 2244 + 1496);
    expect(onePipe.boilerKw, 4.0);
  });

  test('RADIATORSIZ, faqat polli xona ham bitta NUQTA', () {

    final e = estimate(const [
      HeatingRoom(lengthM: 6, widthM: 4), 
      HeatingRoom(lengthM: 6, widthM: 4, warmFloor: true, radiator: false),
    ]);

    expect(e.radiators, 1);
    expect(e.points, 2);
  });

  test('FAQAT ISSIQ POLDA +10% qo\'shilmaydi — radiator yo\'q', () {
    final e = estimate(
      const [HeatingRoom(lengthM: 6, widthM: 4)],
      job: HeatingJob.warmFloorOnly,
      system: HeatingSystem.onePipe,
    );

    expect(e.watts, 2040);
  });

  test('tannarx — hamma qatorlarning yig\'indisi', () {
    final e = estimate(
      const [HeatingRoom(lengthM: 6, widthM: 4)],
      system: HeatingSystem.radial,
    );

    expect(
      e.total,
      e.radiatorCost +
          e.mountCost +
          e.pipeCost +
          e.pipe25Cost +
          e.warmFloorCost +

          e.boilerCost +
          e.pumpCost +
          e.collectorCost +
          e.amerikankaCost +
          e.collectorBoxCost +
          e.branchPipeCost +
          e.teeCost +
          e.valveCost,
    );
  });

  test('narxi kiritilmagan bo\'lsa ham SONLAR chiqadi', () {
    final e = estimate(
      const [HeatingRoom(lengthM: 6, widthM: 4)],
      pipe: 0,
      warmFloor: 0,
      collectorPriceFor: (_) => 0,
      branchPipe: 0,
      tee: 0,
      valve: 0,
      radiator: 0,
      mount: 0,
      pipe25: 0,
    );

    expect(e.radiators, 1);
    expect(e.watts, 2040);
    expect(e.pipeM, greaterThan(0));
    expect(e.total, 0);
  });

  test('bitta seksiya 150 Vt beradi (mutaxassis: 150–200)', () {
    expect(HeatingCalculator.sectionWatts, 150);
  });

  test('24 m² xonaga 14 seksiya (2040 ÷ 150)', () {
    expect(HeatingCalculator.sectionsFor(24), 14);

    expect(HeatingCalculator.sectionsFor(9), 6);
  });

  test('QOVURG\'ALI radiator seksiya bilan narxlanadi (115 000)', () {
    final e = estimate(
      const [HeatingRoom(lengthM: 6, widthM: 4)],
      kind: RadiatorKind.sectional,
    );

    expect(e.sections, 14);
    expect(e.radiatorCost, 14 * 115000);

    expect(e.radiators, 1);
  });

  test('PANELDA seksiya hisoblanmaydi', () {
    final e = estimate(const [HeatingRoom(lengthM: 6, widthM: 4)]);

    expect(e.sections, 0);
    expect(e.radiatorCost, 1046000);
  });

  test('TIZIM truba sarfini o\'zgartiradi', () {
    const rooms = [
      HeatingRoom(lengthM: 6, widthM: 4),
      HeatingRoom(lengthM: 3, widthM: 3),
    ];

    final twoPipe = estimate(rooms);
    final onePipe = estimate(rooms, system: HeatingSystem.onePipe);

    final radial = estimate(
      rooms,
      system: HeatingSystem.radial,
      building: 12,
      boilerDistance: 5,
    );

    expect(onePipe.pipeM, lessThan(twoPipe.pipeM));
    expect(radial.pipeM, greaterThan(twoPipe.pipeM));
  });

  test('SAMOTYOKDA 25 mm trubadan 3 metr qo\'shiladi', () {

    const rooms = [HeatingRoom(lengthM: 6, widthM: 4)];

    final twoPipe = estimate(rooms);
    final gravity = estimate(rooms, system: HeatingSystem.gravity);

    expect(gravity.pipeM, twoPipe.pipeM);

    expect(gravity.pipe25M, 3);
    expect(gravity.pipe25Cost, 3 * 19000);
    expect(twoPipe.pipe25M, 0);
  });

  test('SAMOTYOKDA nasos hisoblanmaydi', () {
    const rooms = [HeatingRoom(lengthM: 6, widthM: 4)];

    expect(HeatingSystem.gravity.needsPump, isFalse);
    expect(HeatingSystem.twoPipe.needsPump, isTrue);
    expect(estimate(rooms).pumpCost, 0);
  });

  test('KOLLEKTOR narxi CHIQISHLAR soniga qarab (mutaxassis 2026-09-23)', () {
    const rooms = [
      HeatingRoom(lengthM: 6, widthM: 4),
      HeatingRoom(lengthM: 3, widthM: 3),
    ];

    expect(estimate(rooms).collectorCost, 0);

    final e = estimate(rooms, system: HeatingSystem.radial);
    expect(e.collectors, 1);
    expect(e.collectorCost, 200000);

    final real = estimate(
      const [
        HeatingRoom(lengthM: 6, widthM: 4),
        HeatingRoom(lengthM: 6, widthM: 4),
        HeatingRoom(lengthM: 6, widthM: 4),
      ],
      system: HeatingSystem.radial,
      collectorPriceFor: (outlets) => switch (outlets) {
        3 => 420000,
        4 => 520000,
        6 => 740000,
        10 => 1200000,
        _ => 0,
      },
    );
    expect(real.collectors, 1);
    expect(real.collectorCost, 420000);
  });

  test('HAR KOLLEKTORGA 2 ta amerikanka (52 000) va bitta shit', () {

    expect(HeatingCalculator.amerikankaPerCollector, 2);

    final e = estimate(
      const [
        HeatingRoom(lengthM: 6, widthM: 4),
        HeatingRoom(lengthM: 6, widthM: 4),
      ],
      system: HeatingSystem.radial,
      building: 40,
      collectorBox: 300000,
    );

    expect(e.collectors, 2);
    expect(e.amerikanka, 4);
    expect(e.amerikankaCost, 4 * 52000);
    expect(e.collectorBoxCost, 2 * 300000);
  });

  test('BOSHQA TIZIMDA amerikanka ham, shit ham yo\'q', () {
    final e = estimate(
      const [HeatingRoom(lengthM: 6, widthM: 4)],
      collectorBox: 300000,
    );

    expect(e.amerikanka, 0);
    expect(e.amerikankaCost, 0);
    expect(e.collectorBoxCost, 0);
  });

  test('LUCHEVOYDA vintl qimmatroq: 70 000 (mutaxassis 2026-09-23)', () {

    expect(HeatingSystem.radial.valveVariantName,
        'Radiator vintli (luchevoy)');
    expect(HeatingSystem.twoPipe.valveVariantName, 'Radiator vintli');
    expect(HeatingSystem.onePipe.valveVariantName, 'Radiator vintli');
    expect(HeatingSystem.gravity.valveVariantName, 'Radiator vintli');

    const rooms = [HeatingRoom(lengthM: 6, widthM: 4)];
    final radial = estimate(rooms, system: HeatingSystem.radial, valve: 70000);
    final twoPipe = estimate(rooms, valve: 40000);

    expect(radial.valves, 2);
    expect(radial.valveCost, 2 * 70000);
    expect(twoPipe.valveCost, 2 * 40000);
  });

  test('KOLLEKTOR narxi adminkadan chiqishi bo\'yicha olinadi', () {
    expect(HeatingCalculator.collectorVariantName(3), 'Kollektor (3 chiqish)');
    expect(
        HeatingCalculator.collectorVariantName(10), 'Kollektor (10 chiqish)');
  });

  test('IKKITA KOLLEKTOR bo\'lsa narx ikki marta olinadi', () {

    final e = estimate(
      const [
        HeatingRoom(lengthM: 6, widthM: 4),
        HeatingRoom(lengthM: 6, widthM: 4),
      ],
      system: HeatingSystem.radial,
      building: 40,
      collectorPriceFor: (outlets) => outlets == 2 ? 320000 : 0,
    );

    expect(e.collectors, 2);
    expect(e.collectorCost, 2 * 320000);
  });

  test('LUCHEVOYDA kollektor har 20 metrga bitta (mutaxassis)', () {

    expect(HeatingCalculator.metersPerCollector, 20);
    expect(HeatingCalculator.collectorReachM, 15);

    expect(HeatingCalculator.collectorsFor(12), 1);
    expect(HeatingCalculator.collectorsFor(20), 1);
    expect(HeatingCalculator.collectorsFor(21), 2);
    expect(HeatingCalculator.collectorsFor(60), 3);
  });

  test('kollektor 2 dan 10 chiqishgacha (mutaxassis 2026-09-22)', () {
    expect(HeatingCalculator.collectorMinOutlets, 2);
    expect(HeatingCalculator.collectorMaxOutlets, 10);

    expect(HeatingCalculator.collectorsFor(10, radiators: 12), 2);
    expect(HeatingCalculator.collectorsFor(10, radiators: 21), 3);

    expect(HeatingCalculator.outletsPerCollector(12, 2), 6);
    expect(HeatingCalculator.outletsPerCollector(1, 1), 2);
  });

  test('kollektorlar soni bino uzunligidan', () {
    const rooms = [HeatingRoom(lengthM: 6, widthM: 4)];

    final short = estimate(rooms, system: HeatingSystem.radial, building: 15);
    final long = estimate(rooms, system: HeatingSystem.radial, building: 45);

    expect(short.collectors, 1);
    expect(long.collectors, 3);

    expect(estimate(rooms, building: 45).collectors, 0);
  });

  test('LUCHEVOYDA troynik yo\'q — radiator kollektorga ulanadi', () {
    final e = estimate(
      const [HeatingRoom(lengthM: 6, widthM: 4)],
      system: HeatingSystem.radial,
    );

    expect(e.tees, 0);
    expect(e.valves, 2);
  });

  test('1 m² issiq polga: 8 m shlang, 4 qo\'ziqorin, 20 skoba', () {
    expect(HeatingCalculator.warmFloorPipePerM2, 8);
    expect(HeatingCalculator.warmFloorDowelsPerM2, 4);
    expect(HeatingCalculator.warmFloorClipsPerM2, 20);

    final e = estimate(const [
      HeatingRoom(lengthM: 6, widthM: 4, warmFloor: true),
    ]);

    expect(e.warmFloorM2, 24);
    expect(e.warmFloorPipeM, closeTo(192, 1e-9));
    expect(e.warmFloorDowels, 96);
    expect(e.warmFloorClips, 480);
  });

  test('PENOPLEKS butun list bilan: bittasi 0,75 m² (mutaxassis)', () {

    expect(HeatingCalculator.penopleksSheetM2, 0.75);
    expect(HeatingCalculator.penopleksSheetsFor(1.5), 2);

    expect(HeatingCalculator.penopleksSheetsFor(24), 32);
    expect(HeatingCalculator.penopleksSheetsFor(10), 14);
  });

  test('issiq polning narxi HAMMA DETALIDAN yig\'iladi', () {

    final e = estimate(
      const [HeatingRoom(lengthM: 6, widthM: 4, warmFloor: true)],
      penopleks: 15000, 
      warmFloorPipe: 5500, 
      warmFloor: 8000, 
      dowel: 1000, 
      clip: 300, 
    );

    expect(e.penopleksSheets, 32);
    expect(e.penopleksCost, 32 * 15000);
    expect(e.warmFloorPipeCost, 192 * 5500);
    expect(e.underlayCost, 24 * 8000);
    expect(e.dowelCost, 96 * 1000);
    expect(e.clipCost, 480 * 300);
    expect(e.warmFloorCost, 480000 + 1056000 + 192000 + 96000 + 144000);
  });

  test('LUCHEVOY SHLANGI arzonroq, magistral esa 32 mm narxida', () {

    expect(HeatingSystem.radial.pipeVariantName, 'Truba luchevoy (1 metr)');
    expect(HeatingSystem.twoPipe.pipeVariantName, 'Truba (1 metr)');

    final e = estimate(
      const [HeatingRoom(lengthM: 6, widthM: 4)],
      system: HeatingSystem.radial,
      building: 15,
      boilerDistance: 10,
      pipe: 18000,
      pipe32: 28000,
    );

    expect(e.collectorPipeM, closeTo(35, 1e-9));
    expect(e.pipeM, closeTo(45, 1e-9));
    expect(e.pipeCost, 35 * 28000 + 10 * 18000);
  });

  test('SHLANG ikki xil: plastik 5 500, alumin 9 500', () {

    const rooms = [HeatingRoom(lengthM: 6, widthM: 4, warmFloor: true)];

    final plastic = estimate(rooms, warmFloorPipe: 5500);
    final alumin = estimate(
      rooms,
      warmFloorPipeKind: WarmFloorPipeKind.aluminium,
      warmFloorPipe: 9500,
    );

    expect(plastic.warmFloorPipeKind, WarmFloorPipeKind.plastic);
    expect(plastic.warmFloorPipeCost, 192 * 5500);
    expect(alumin.warmFloorPipeKind, WarmFloorPipeKind.aluminium);
    expect(alumin.warmFloorPipeCost, 192 * 9500);
  });

  test('shlang narxi adminkadan turi bo\'yicha olinadi', () {
    expect(WarmFloorPipeKind.plastic.variantName,
        'Issiq pol: Plastik shlang (1 metr)');
    expect(WarmFloorPipeKind.aluminium.variantName,
        'Issiq pol: Alumin shlang (1 metr)');
  });

  test('TUSHAMA — gidrobaryer (folga hozircha yo\'q)', () {

    expect(WarmFloorUnderlay.values, hasLength(1));
    expect(WarmFloorUnderlay.barrier.variantName,
        'Issiq pol: Gidrobaryer (1 m²)');

    final e = estimate(
      const [HeatingRoom(lengthM: 6, widthM: 4, warmFloor: true)],
      warmFloor: 8000,
    );

    expect(e.underlay, WarmFloorUnderlay.barrier);
    expect(e.underlayCost, 24 * 8000);
  });

  test('issiq pol yo\'q bo\'lsa detallari ham yo\'q', () {
    final e = estimate(
      const [HeatingRoom(lengthM: 6, widthM: 4)],
      penopleks: 50000,
      warmFloorPipe: 9000,
      dowel: 1500,
      clip: 500,
    );

    expect(e.warmFloorPipeM, 0);
    expect(e.warmFloorDowels, 0);
    expect(e.warmFloorClips, 0);
    expect(e.warmFloorCost, 0);
  });

  test('issiq pol 1,20 metrgacha isitadi (mutaxassis)', () {
    expect(HeatingCalculator.warmFloorHeightM, 1.20);
  });

  test('ISSIQ POLLI XONADA radiator MIJOZ ixtiyorida', () {

    const rooms = [
      HeatingRoom(lengthM: 6, widthM: 4, warmFloor: true, radiator: false),
      HeatingRoom(lengthM: 6, widthM: 4),
    ];
    final e = estimate(rooms);

    expect(e.rooms.first.radiators, 0);
    expect(e.rooms.last.radiators, 1);
    expect(e.radiators, 1);

    expect(e.warmFloorM2, 24);
  });

  test('issiq pol belgilansa ham radiator ODATDA qo\'yiladi', () {
    final e = estimate(const [
      HeatingRoom(lengthM: 6, widthM: 4, warmFloor: true),
    ]);

    expect(e.radiators, 1);
    expect(e.warmFloorM2, 24);
  });

  test('RADIATORSIZ XONADAN truba o\'tib ketadi (usta 2026-09-22)', () {

    const rooms = [
      HeatingRoom(lengthM: 6, widthM: 4, warmFloor: true, radiator: false),
      HeatingRoom(lengthM: 6, widthM: 4),
    ];

    final one = estimate(rooms, system: HeatingSystem.onePipe);
    expect(one.radiators, 1);
    expect(one.transitPipeM, closeTo(6, 1e-9));
    expect(one.pipeM, closeTo(6 + 6, 1e-9));

    final two = estimate(rooms);
    expect(two.transitPipeM, closeTo(12, 1e-9));
    expect(two.pipeM, closeTo(12 + 12, 1e-9));
    expect(two.pipeCost, (12 + 12) * 28000);
  });

  test('LUCHEVOYDA truba 10 dan 32 metrgacha (mutaxassis 2026-09-22)', () {
    expect(HeatingCalculator.radialPipeMinM, 10);
    expect(HeatingCalculator.radialPipeMaxM, 32);

    expect(
      HeatingCalculator.radialPipePerRadiator(
          buildingLengthM: 6, totalAreaM2: 24, collectors: 1),
      10,
    );

    expect(
      HeatingCalculator.radialPipePerRadiator(
          buildingLengthM: 20, totalAreaM2: 200, collectors: 1),
      closeTo(20, 1e-9),
    );

    expect(
      HeatingCalculator.radialPipePerRadiator(
          buildingLengthM: 40, totalAreaM2: 1600, collectors: 1),
      32,
    );

    expect(
      HeatingCalculator.radialPipePerRadiator(
          buildingLengthM: 0, totalAreaM2: 0, collectors: 0),
      10,
    );
  });

  test('KOTYOLDAN HAR KOLLEKTORGA 2 ta truba (mutaxassis 2026-09-22)', () {

    final e = estimate(
      const [HeatingRoom(lengthM: 6, widthM: 4)],
      system: HeatingSystem.radial,
      building: 15,
      boilerDistance: 10,
    );

    expect(e.collectors, 1);
    expect(e.collectorPipeM, closeTo(35, 1e-9));
  });

  test('UCHTA KOLLEKTORGA 6 ta truba — uzog\'iga ko\'proq ketadi', () {

    final e = estimate(
      const [
        HeatingRoom(lengthM: 6, widthM: 4),
        HeatingRoom(lengthM: 6, widthM: 4),
        HeatingRoom(lengthM: 6, widthM: 4),
      ],
      system: HeatingSystem.radial,
      building: 60,
      boilerDistance: 5,
    );

    expect(e.collectors, 3);
    expect(e.collectorPipeM, closeTo(210, 1e-9));

    expect(e.pipePerRadiatorM, closeTo(11.2, 1e-9));

    expect(e.pipeM, closeTo(3 * 11.2 + 210, 1e-9));
  });

  test('BOSHQA TIZIMLARDA kotyol magistrali alohida hisoblanmaydi', () {
    final e = estimate(
      const [HeatingRoom(lengthM: 6, widthM: 4)],
      building: 60,
      boilerDistance: 10,
    );

    expect(e.collectorPipeM, 0);
  });

  test('LUCHEVOYDA o\'tkazma truba yo\'q — kollektordan alohida tortiladi',
      () {
    final e = estimate(
      const [
        HeatingRoom(lengthM: 6, widthM: 4, warmFloor: true, radiator: false),
        HeatingRoom(lengthM: 6, widthM: 4),
      ],
      system: HeatingSystem.radial,
    );

    expect(e.transitPipeM, 0);
  });

  test('hamma xonada radiator bo\'lsa o\'tkazma truba yo\'q', () {
    final e = estimate(const [
      HeatingRoom(lengthM: 6, widthM: 4, warmFloor: true),
      HeatingRoom(lengthM: 6, widthM: 4),
    ]);

    expect(e.transitPipeM, 0);
  });

  test('radiatorsiz xonada seksiya ham hisoblanmaydi', () {
    final e = estimate(
      const [
        HeatingRoom(lengthM: 6, widthM: 4, warmFloor: true, radiator: false),
      ],
      kind: RadiatorKind.sectional,
    );

    expect(e.sections, 0);
    expect(e.radiatorCost, 0);
  });

  test('issiq polsiz xonada radiator belgisi hisobga olinmaydi', () {

    final e = estimate(const [
      HeatingRoom(lengthM: 6, widthM: 4, radiator: false),
    ]);

    expect(e.radiators, 1);
  });

  test('BIR/IKKI TRUBALIDA hamma truba 32 li (11 000/m)', () {

    final e = estimate(
      const [HeatingRoom(lengthM: 6, widthM: 4)],
      system: HeatingSystem.onePipe,
      insulation: 11000,
    );

    expect(e.insulationM, closeTo(8, 1e-9));
    expect(e.insulationCost, 8 * 11000);
  });

  test('SAMOTYOKDA 25 mm truba ham uteplitelga kiradi', () {
    final e = estimate(
      const [HeatingRoom(lengthM: 6, widthM: 4)],
      system: HeatingSystem.gravity,
      insulation: 11000,
    );

    expect(e.insulationM, closeTo(17, 1e-9));
  });

  test('LUCHEVOYDA uteplitel faqat kotyoldan kollektorgacha', () {

    final e = estimate(
      const [HeatingRoom(lengthM: 6, widthM: 4)],
      system: HeatingSystem.radial,
      building: 15,
      boilerDistance: 10,
      insulation: 11000,
    );

    expect(e.collectorPipeM, closeTo(35, 1e-9));
    expect(e.insulationM, closeTo(35, 1e-9));
    expect(e.insulationCost, 35 * 11000);
  });

  test('ISSIQ POLNING shlangiga uteplitel KIYDIRILMAYDI', () {

    final e = estimate(
      const [HeatingRoom(lengthM: 6, widthM: 4, warmFloor: true)],
      system: HeatingSystem.onePipe,
      insulation: 11000,
    );

    expect(e.warmFloorPipeM, closeTo(192, 1e-9));

    expect(e.insulationM, closeTo(8, 1e-9));
  });

  test('uteplitel narxi UMUMIY tannarxga qo\'shiladi', () {
    const rooms = [HeatingRoom(lengthM: 6, widthM: 4)];
    final withOut = estimate(rooms, system: HeatingSystem.onePipe);
    final withIt =
        estimate(rooms, system: HeatingSystem.onePipe, insulation: 11000);

    expect(withIt.total - withOut.total, 8 * 11000);
  });

  test('FAQAT ISSIQ POLDA uteplitel umuman yo\'q', () {
    final e = estimate(
      const [HeatingRoom(lengthM: 6, widthM: 4)],
      job: HeatingJob.warmFloorOnly,
      insulation: 11000,
    );

    expect(e.insulationM, 0);
    expect(e.insulationCost, 0);
  });

  test('PISHGAN G\'ISHT devorda oyoqcha yo\'q', () {
    final e = estimate(const [HeatingRoom(lengthM: 6, widthM: 4)]);

    expect(e.legs, 0);
    expect(e.legCost, 0);
  });

  test('XOM G\'ISHT, PENOBLOK, SHLAKOBLOK: har radiatorga 2 ta oyoqcha', () {

    for (final wall in [
      HeatingWall.xomGisht,
      HeatingWall.penoblok,
      HeatingWall.shlakoblok,
    ]) {
      final e = estimate(
        const [
          HeatingRoom(lengthM: 6, widthM: 4), 
          HeatingRoom(lengthM: 6, widthM: 5), 
        ],
        wall: wall,
      );

      expect(e.radiators, 3, reason: wall.title);
      expect(e.legs, 6, reason: wall.title);
      expect(e.legCost, 6 * 100000, reason: wall.title);
    }
  });

  test('FAQAT ISSIQ POLDA oyoqcha yo\'q — radiator qo\'yilmaydi', () {
    final e = estimate(
      const [HeatingRoom(lengthM: 6, widthM: 4)],
      job: HeatingJob.warmFloorOnly,
      wall: HeatingWall.penoblok,
    );

    expect(e.legs, 0);
    expect(e.legCost, 0);
  });

  test('oyoqcha narxi UMUMIY tannarxga qo\'shiladi', () {
    const rooms = [HeatingRoom(lengthM: 6, widthM: 4)];
    final solid = estimate(rooms);
    final soft = estimate(rooms, wall: HeatingWall.shlakoblok);

    expect(soft.total - solid.total, 2 * 100000);
  });

  test('kotyol quvvati butun uy maydonidan (85 Vt/m²)', () {
    final e = estimate(const [
      HeatingRoom(lengthM: 6, widthM: 4), 
      HeatingRoom(lengthM: 4, widthM: 4), 
    ]);

    expect(e.totalAreaM2, 40);
    expect(e.watts, 3400);
    expect(e.boilerKw, 3.5);
  });

  test('issiq pol FAQAT belgilangan xonalarga', () {
    final e = estimate(const [
      HeatingRoom(lengthM: 6, widthM: 4, warmFloor: true),
      HeatingRoom(lengthM: 3, widthM: 3),
    ]);

    expect(e.warmFloorM2, 24);
    expect(e.warmFloorCost, 24 * 150000);
  });

  test('FAQAT ISSIQ POL: radiator, truba va kotyol hisoblanmaydi', () {
    final e = estimate(
      const [
        HeatingRoom(lengthM: 6, widthM: 4),
        HeatingRoom(lengthM: 3, widthM: 3),
      ],
      job: HeatingJob.warmFloorOnly,
    );

    expect(e.radiators, 0);
    expect(e.pipeM, 0);
    expect(e.boilerKw, 0);
    expect(e.boilerCost, 0);
    expect(e.radiatorCost, 0);

    expect(e.warmFloorM2, 33);
    expect(e.total, 33 * 150000);
  });

  test('FAQAT ISSIQ POLDA nuqta = xonalar soni (kontur)', () {
    final e = estimate(
      const [
        HeatingRoom(lengthM: 6, widthM: 4),
        HeatingRoom(lengthM: 3, widthM: 3),
      ],
      job: HeatingJob.warmFloorOnly,
    );

    expect(e.points, 2);
  });

  test('o\'lchamsiz xona hisobga kirmaydi', () {
    final e = estimate(const [
      HeatingRoom(lengthM: 6, widthM: 4),
      HeatingRoom(lengthM: 0, widthM: 0),
    ]);

    expect(e.rooms, hasLength(1));
  });

  test('birorta xona yo\'q — hisob ham yo\'q', () {
    expect(
      HeatingCalculator.calculate(
        rooms: const [],
        pipePricePerM: 1,
      ),
      isNull,
    );
  });

  test('KOTYOLXONA hisobga kirmaydi: na kotyol, na nasos', () {

    final e = estimate(const [HeatingRoom(lengthM: 6, widthM: 4)]);

    expect(e.boilerCost, 0);
    expect(e.pumpCost, 0);

    expect(e.boilerKw, greaterThan(0));
  });

  test('kotyol turlari: gaz, elektr, qattiq yoqilg\'i', () {
    expect(HeatingBoiler.values.map((b) => b.title).toList(), [
      'Gaz kotyol',
      'Elektr kotyol',
      'Qattiq yoqilg\'i',
    ]);
  });
}
